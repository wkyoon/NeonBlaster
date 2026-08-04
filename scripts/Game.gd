extends Node2D
## Game - main gameplay scene controller.
## Manages player, spawner, HUD, UI panels, and ad integration.

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


func _ready() -> void:
	EffectsManager.set_camera(_camera)
	# Create word reveal overlay
	_word_reveal = Control.new()
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
	GameManager.start_game()
	_spawner.start()
	_player.revive()
	# Start the first word
	WordManager.reset()
	WordManager.start_new_word()
	# Handle word completion -> start new word + bonus
	WordManager.word_completed.connect(_on_word_completed)

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
func _on_word_completed(word: String) -> void:
	# Bonus score for completing a word
	var bonus := word.length() * 100
	GameManager.add_score(bonus)
	# Celebration effects
	EffectsManager.screen_flash(Color(0.2, 1.0, 0.5, 0.4), 0.5)
	EffectsManager.shake(8.0, 0.3)
	AudioManager.play_sfx("explosion")
	# Show the word reveal overlay (icon + pronunciation)
	if _word_reveal:
		_word_reveal.reveal_word(word)
	# Start next word after the reveal duration (2.5s)
	get_tree().create_timer(2.5).timeout.connect(_start_next_word)


func _start_next_word() -> void:
	if not _is_game_over and GameManager.current_state == GameManager.GameState.PLAYING:
		WordManager.start_new_word()
