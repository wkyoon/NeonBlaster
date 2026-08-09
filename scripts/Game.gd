extends Node2D
## Game - main gameplay scene controller.
## Manages player, spawner, HUD, UI panels, and ad integration.

## 테마 하나(8단어)를 다 모았을 때 주는 보너스 점수.
const THEME_MASTER_BONUS := 2000

## 단어 완성 후 다음 단어가 시작되기까지의 시간(초). 리빌이 뜨고 사라지는 동안 플레이는 계속된다.

@onready var _player: CharacterBody2D = $Player
@onready var _spawner: Node2D = $EnemySpawner
@onready var _hud: CanvasLayer = $HUD
@onready var _game_over_panel: Control = $UI/GameOverPanel
@onready var _pause_panel: Control = $UI/PausePanel
@onready var _pause_button: Button = $UI/PauseButton
@onready var _joystick: Control = $UI/Joystick
@onready var _camera: Camera2D = $Camera2D

var _is_game_over: bool = false
var _word_reveal: Control


## 이번 판의 경과 시간. 난이도 자동 조절이 "제대로 한 판이었는지" 판단하는 데 쓴다.
var _run_seconds: float = 0.0


func _ready() -> void:
	EffectsManager.set_camera(_camera)
	# Create word reveal overlay
	_word_reveal = Control.new()
	# ⚠️ 이름을 지정하지 않으면 런타임에 "@Control@31" 로 자동 생성돼
	#    get_node("WordReveal") 로 찾을 수 없다(테스트·디버깅에서 실제로 막혔다).
	_word_reveal.name = "WordReveal"
	_word_reveal.set_script(preload("res://scripts/WordReveal.gd"))
	add_child(_word_reveal)
	_player.player_died.connect(_on_player_died)
	_spawner.wave_started.connect(_on_wave_started)
	_game_over_panel.restart_requested.connect(_on_restart)
	_game_over_panel.revive_requested.connect(_on_revive)
	_game_over_panel.menu_requested.connect(_on_quit_to_menu)
	_pause_panel.resume_requested.connect(_on_resume)
	_pause_panel.quit_requested.connect(_on_quit_to_menu)
	_pause_button.pressed.connect(_on_pause_button)

	# Start game
	DifficultyDirector.reset_run()
	GameManager.start_game()
	_spawner.start()
	_player.revive()
	# Start the first word
	WordManager.reset()
	WordManager.start_new_word()
	# Handle word completion -> start new word + bonus
	WordManager.word_completed.connect(_on_word_completed)
	WordManager.word_collected.connect(_on_word_collected)
	WordManager.theme_mastered.connect(_on_theme_mastered)
	RewardManager.daily_goal_reached.connect(_on_daily_goal_reached)
	if _word_reveal:
		_word_reveal.reveal_finished.connect(_start_next_word)

	# Preload ads
	AdsManager.request_interstitial()
	AdsManager.request_rewarded()

	# Load banner
	AdsManager.load_banner()
	AdsManager.show_banner()


func _on_player_died() -> void:
	if _is_game_over:
		return
	_is_game_over = true
	_spawner.stop()
	# Disconnect word completion handler
	if WordManager.word_completed.is_connected(_on_word_completed):
		WordManager.word_completed.disconnect(_on_word_completed)
	GameManager.game_over()
	AudioManager.play_sfx("game_over")
	EffectsManager.screen_flash(Color(1, 0.2, 0.2), 0.3)
	# Show game over after delay
	get_tree().create_timer(0.8).timeout.connect(_show_game_over)


func _show_game_over() -> void:
	var can_revive := GameManager.can_revive()
	_game_over_panel.show_panel(GameManager.score, GameManager.high_score, can_revive)
	# Show interstitial ad (frequency-capped)
	AdsManager.show_interstitial_if_ready()


func _on_restart() -> void:
	AdsManager.hide_banner()
	SceneManager.goto_game()


func _on_revive() -> void:
	var success := AdsManager.show_rewarded_if_ready(_on_revive_rewarded)
	if not success:
		# Ad not ready - grant revive anyway (or wait)
		_on_revive_rewarded(1)


func _on_revive_rewarded(_amount: int) -> void:
	GameManager.use_revive()
	_is_game_over = false
	_game_over_panel.hide_panel()
	# Clear nearby enemies for safety
	_clear_nearby_enemies()
	# Respawn player
	_respawn_player()
	_spawner.start()


func _clear_nearby_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()


func _respawn_player() -> void:
	if not is_instance_valid(_player):
		_player = preload("res://scenes/Player.tscn").instantiate()
		_player.global_position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y * 0.75)
		add_child(_player)
		_player.player_died.connect(_on_player_died)
	_player.revive()
	_player.global_position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y * 0.75)


func _on_wave_started(wave: int) -> void:
	_hud.set_wave(wave)


func _on_pause_button() -> void:
	AudioManager.play_sfx("button")
	GameManager.pause_game()
	_pause_panel.show_panel()


func _on_resume() -> void:
	GameManager.resume_game()


func _on_quit_to_menu() -> void:
	AdsManager.hide_banner()
	GameManager.go_to_menu()
	get_tree().paused = false
	SceneManager.goto_menu()


## Called when a word is fully spelled - grant bonus, show reveal, start new word
## 도감에 새로 등록된 순간 — 리빌 위에 NEW 배지를 띄운다.
func _on_word_collected(_word: String, total: int, goal: int) -> void:
	if _word_reveal and _word_reveal.has_method("_show_new_badge"):
		_word_reveal._show_new_badge(total, goal)


## 테마 완주 — 8개를 다 모은 순간. 48개 전체보다 훨씬 자주 오는 "해냈다" 지점이라
## 여기에 보상을 몰아준다(화면 배너 + 보너스 점수 + 목숨 1개).
func _on_theme_mastered(_theme_id: String, name_en: String) -> void:
	GameManager.add_score(THEME_MASTER_BONUS)
	# 목숨을 하나 돌려준다 — 수집이 곧 생존으로 이어져 계속 플레이할 이유가 된다.
	if GameManager.lives < GameManager.MAX_LIVES:
		GameManager.lives += 1
	AudioManager.play_sfx("powerup")
	_show_banner("★ %s COMPLETE!  +%d" % [name_en, THEME_MASTER_BONUS])


## 오늘 10분 플레이 달성 — 플레이를 끊지 않고 그 자리에서 알려준다.
## 보상 자체는 메뉴에서 받는다(판 중간에 목숨이 늘어나면 밸런스가 흔들린다).
func _on_daily_goal_reached() -> void:
	AudioManager.play_sfx("powerup")
	_show_banner("🎁 DAILY GOAL! CLAIM IN MENU")


## 화면 위쪽에서 떠올랐다 사라지는 배너. 단어를 가리지 않게 위쪽에만 머문다.
func _show_banner(text: String) -> void:
	var layer := get_node_or_null("UI")
	if layer == null:
		return
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 34)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))
	lbl.add_theme_color_override("font_outline_color", Color(0.3, 0.2, 0.0))
	lbl.add_theme_constant_override("outline_size", 10)
	lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	lbl.offset_top = 240.0
	lbl.offset_bottom = 290.0
	layer.add_child(lbl)
	lbl.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.4)
	tw.parallel().tween_property(lbl, "offset_top", 205.0, 1.4)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.queue_free)


func _on_word_completed(word: String) -> void:
	# Bonus score for completing a word
	var bonus := word.length() * 100
	GameManager.add_score(bonus)
	# 단어 완성은 콤보를 크게 밀어준다 — 학습과 액션을 묶는 핵심 연결이다.
	# 돌파한 단계 수만큼 연출을 세게 한다(단계 돌파 자체의 연출은 HUD 가 combo_level_up 으로 처리).
	var _levels_gained := GameManager.register_word_bonus()
	# 축하 연출은 **단어 자체**에 몰아준다(HUD._on_word_completed).
	# 화면 전체 플래시와 카메라 셰이크는 정작 단어를 가리고 읽기 어렵게 만들어서
	# 아주 약하게만 남긴다 — 이 게임의 각인 대상은 단어다.
	EffectsManager.screen_flash(Color(0.2, 1.0, 0.5, 0.12), 0.25)
	AudioManager.play_sfx("explosion")
	# Show the word reveal overlay (icon + pronunciation)
	# ⚠️ 리빌 동안 게임을 **멈추지 않는다.** 멈추면 흐름이 끊기는 느낌이 든다.
	# 대신 오버레이가 시야를 가리지 않도록 만들었다(WordReveal 의 배경 alpha 0.12).
	# 자연스럽게 떴다가 사라지고, 그 사이 플레이는 계속된다.
	#
	# ⚠️ 다음 단어를 **고정 시간(예전 2.0초)으로 시작하면 안 된다.**
	# 리빌 길이가 이제 음성 길이에 맞춰 1.75~3.35초로 변하므로 겹치거나 빈 시간이 생긴다.
	# 리빌이 끝나는 순간(reveal_finished)에 맞춰 시작한다.
	if _word_reveal:
		_word_reveal.reveal_word(word)
	else:
		_start_next_word()


func _start_next_word() -> void:
	if not _is_game_over and GameManager.current_state == GameManager.GameState.PLAYING:
		WordManager.start_new_word()


func _process(delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		_run_seconds += delta
		# 난이도는 경과 시간으로 정해진다 — 목표 시간 근처에서 판이 끝나도록.
		DifficultyDirector.set_elapsed(_run_seconds)
