extends Control
## MainMenu - title screen with start button and high score display.
## Now includes difficulty selection for Word Blaster mode.

@onready var _title: Label = $Title
@onready var _subtitle: Label = $Subtitle
@onready var _start_button: Button = $StartButton
@onready var _high_score_label: Label = $HighScoreLabel
var _difficulty_buttons: VBoxContainer
var _selected_difficulty: WordManager.Difficulty = WordManager.Difficulty.EASY
var _auto_play_btn: Button = null
var _score_panel: Control = null

var _sfx_btn: Button
var _music_btn: Button
var _tts_btn: Button


func _ready() -> void:
	_start_button.pressed.connect(_on_start)
	GameManager.high_score_changed.connect(_update_high_score)
	_update_high_score(GameManager.high_score)
	_animate_title()
	_create_title_emblem()
	_create_difficulty_selector()
	_create_audio_toggles()
	_create_auto_play_toggle()
	_create_bottom_buttons()


## Create difficulty selection buttons (Easy / Normal / Hard)
## PRESET_CENTER_BOTTOM 은 **앵커만** 중앙에 두고 컨트롤의 크기는 고려하지 않는다.
## 그래서 컨테이너의 왼쪽 끝이 화면 중앙에 붙어 오른쪽으로 넘쳐 나간다.
## 실측(720 폭): 하단 버튼 행이 x 360~999 로 STORY 버튼이 통째로 화면 밖이었고,
## 난이도 버튼과 AUTO PLAY 버튼도 같은 이유로 오른쪽으로 밀려 서로 겹쳤다.
## 크기가 정해질 때마다 폭의 절반만큼 왼쪽으로 당겨 실제로 가운데 정렬한다.
func _center_horizontally(ctl: Control) -> void:
	var apply := func() -> void:
		# position 은 앵커 기준이 아니라 부모 원점 기준 절대값이다.
		# (-size/2 로 두면 화면 중앙이 아니라 x=0 을 중심으로 몰린다 — 실제로 겪음)
		ctl.position.x = (get_viewport_rect().size.x - ctl.size.x) * 0.5
	apply.call()
	ctl.resized.connect(apply)


## 타이틀 위 네온 엠블럼. 로고가 글자뿐이라 게임의 얼굴이 비어 보였다.
## 이미지 에셋 대신 절차적으로 그린다(TitleEmblem) — APK 증가 0, 해상도 무관하게 선명.
func _create_title_emblem() -> void:
	var emblem := TitleEmblem.new()
	emblem.name = "TitleEmblem"
	var vp := get_viewport_rect().size
	# 타이틀(화면 20% 지점) 위쪽에 놓는다.
	emblem.position = Vector2(vp.x * 0.5, vp.y * 0.2 - 150.0)
	add_child(emblem)


func _create_difficulty_selector() -> void:
	_difficulty_buttons = VBoxContainer.new()
	_difficulty_buttons.name = "DifficultySelector"
	_difficulty_buttons.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_difficulty_buttons.position.y = -320
	_center_horizontally(_difficulty_buttons)
	_difficulty_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_difficulty_buttons.add_theme_constant_override("separation", 10)
	add_child(_difficulty_buttons)

	var label := Label.new()
	label.text = "DIFFICULTY"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	_difficulty_buttons.add_child(label)

	var btn_container := HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 12)
	_difficulty_buttons.add_child(btn_container)

	var difficulties := [
		# 별 개수로 난이도를 한눈에 보이게 한다(글자만으로는 상대적 세기가 안 읽힌다).
		{ "name": "★\nEASY", "value": WordManager.Difficulty.EASY, "color": Color(0.3, 1.0, 0.5) },
		{ "name": "★★\nNORMAL", "value": WordManager.Difficulty.NORMAL, "color": Color(1.0, 0.8, 0.2) },
		{ "name": "★★★\nHARD", "value": WordManager.Difficulty.HARD, "color": Color(1.0, 0.3, 0.3) },
	]

	for diff in difficulties:
		var btn := Button.new()
		btn.text = diff["name"]
		btn.custom_minimum_size = Vector2(110, 62)
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_color_override("font_color", diff["color"])
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.pressed.connect(_on_difficulty_selected.bind(diff["value"], btn, btn_container))
		btn_container.add_child(btn)

	# Highlight first button (Easy) by default
	_highlight_selected(btn_container.get_child(0), btn_container)


func _on_difficulty_selected(diff: WordManager.Difficulty, btn: Button, container: HBoxContainer) -> void:
	AudioManager.play_sfx("button")
	_selected_difficulty = diff
	_highlight_selected(btn, container)


func _highlight_selected(selected: Button, container: HBoxContainer) -> void:
	for child in container.get_children():
		child.modulate = Color(0.6, 0.6, 0.6)
	selected.modulate = Color(1.0, 1.0, 1.0)
	selected.add_theme_color_override("font_color", Color.WHITE)


func _create_bottom_buttons() -> void:
	# Row container for Scores + Dictionary + Story buttons
	var container := HBoxContainer.new()
	container.name = "BottomButtons"
	container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	container.position.y = -145
	_center_horizontally(container)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 12)
	add_child(container)

	var scores_btn := Button.new()
	scores_btn.name = "ScoresButton"
	scores_btn.text = "★ SCORES"
	scores_btn.custom_minimum_size = Vector2(205, 50)
	scores_btn.add_theme_font_size_override("font_size", 18)
	scores_btn.add_theme_color_override("font_color", Color(1.0, 0.75, 0.25))
	scores_btn.focus_mode = Control.FOCUS_NONE
	scores_btn.pressed.connect(_show_score_history)
	container.add_child(scores_btn)

	var dict_btn := Button.new()
	dict_btn.name = "DictionaryButton"
	dict_btn.text = "📖 DICTIONARY"
	dict_btn.custom_minimum_size = Vector2(205, 50)
	dict_btn.add_theme_font_size_override("font_size", 18)
	dict_btn.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	dict_btn.focus_mode = Control.FOCUS_NONE
	dict_btn.pressed.connect(_on_dictionary)
	container.add_child(dict_btn)

	var story_btn := Button.new()
	story_btn.name = "StoryButton"
	story_btn.text = "✦ STORY"
	story_btn.custom_minimum_size = Vector2(205, 50)
	story_btn.add_theme_font_size_override("font_size", 18)
	story_btn.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	story_btn.focus_mode = Control.FOCUS_NONE
	story_btn.pressed.connect(_on_story)
	container.add_child(story_btn)

	_create_sfx_lab_button()
	_create_score_panel()


## SFX 후보 비교 화면 진입 버튼 (개발용). 우측 상단 구석에 작게 배치.
func _create_sfx_lab_button() -> void:
	var btn := Button.new()
	btn.name = "SfxLabButton"
	btn.text = "🔊 SFX"
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	# 오디오 토글(y 20~64) 아래로. 예전 위치(y14)는 TTS 버튼과 겹쳤다.
	btn.position = Vector2(-104, 74)
	btn.custom_minimum_size = Vector2(90, 38)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.55, 0.62, 0.8))
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_sfx_lab)
	add_child(btn)


func _on_sfx_lab() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_sfx_lab()


func _create_score_panel() -> void:
	_score_panel = Control.new()
	_score_panel.name = "ScoreHistoryPanel"
	_score_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_score_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_score_panel.visible = false
	add_child(_score_panel)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.01, 0.04, 0.92)
	_score_panel.add_child(dimmer)

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-290, -420)
	panel.size = Vector2(580, 840)
	_score_panel.add_child(panel)

	var content := VBoxContainer.new()
	content.position = Vector2(35, 30)
	content.size = Vector2(510, 780)
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	var title := Label.new()
	title.text = "★ SCORE RECORDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(1.0, 0.75, 0.25))
	content.add_child(title)

	var header := Label.new()
	header.text = " NO.      SCORE       MODE       DATE"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0))
	content.add_child(header)

	var records := Label.new()
	records.name = "Records"
	records.custom_minimum_size = Vector2(510, 580)
	records.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	records.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	records.add_theme_font_size_override("font_size", 22)
	records.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	content.add_child(records)

	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.custom_minimum_size = Vector2(220, 58)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.pressed.connect(_hide_score_history)
	content.add_child(close_btn)


func _show_score_history() -> void:
	AudioManager.play_sfx("button")
	var records: Label = _score_panel.get_node("Panel/VBoxContainer/Records")
	var history := GameManager.get_score_history()
	if history.is_empty():
		records.text = "\n\nNo records yet.\nPlay a game to set your first score!"
	else:
		var lines: Array[String] = []
		for i in history.size():
			var item: Dictionary = history[i]
			var date := Time.get_date_dict_from_unix_time(int(item.get("timestamp", 0)))
			var date_text := "%02d/%02d" % [int(date.get("month", 0)), int(date.get("day", 0))]
			lines.append("%2d      %06d      %-6s      %s" % [
				i + 1,
				int(item.get("score", 0)),
				String(item.get("difficulty", "EASY")),
				date_text,
			])
		records.text = "\n".join(lines)
	_score_panel.visible = true
	_score_panel.move_to_front()


func _hide_score_history() -> void:
	AudioManager.play_sfx("button")
	_score_panel.visible = false


func _on_dictionary() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_dictionary()


func _on_story() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_story()


func _create_auto_play_toggle() -> void:
	var btn := Button.new()
	btn.name = "AutoPlayButton"
	btn.text = "▶ AUTO PLAY: OFF"
	btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	btn.position.y = -210
	_center_horizontally(btn)
	btn.custom_minimum_size = Vector2(280, 50)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_auto_play_toggle)
	add_child(btn)
	_auto_play_btn = btn
	_update_auto_play_btn()


func _update_auto_play_btn() -> void:
	if not _auto_play_btn:
		return
	if GameManager.auto_play:
		_auto_play_btn.text = "▶ AUTO PLAY: ON"
		_auto_play_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	else:
		_auto_play_btn.text = "▶ AUTO PLAY: OFF"
		_auto_play_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))


func _on_auto_play_toggle() -> void:
	AudioManager.play_sfx("button")
	GameManager.auto_play = not GameManager.auto_play
	_update_auto_play_btn()


func _on_start() -> void:
	AudioManager.play_sfx("button")
	WordManager.set_difficulty(_selected_difficulty)
	GameManager.start_game()
	SceneManager.goto_game()


## Create SFX / BGM / TTS toggle buttons (top-right corner)
func _create_audio_toggles() -> void:
	var container := HBoxContainer.new()
	container.name = "AudioToggles"
	container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	container.position = Vector2(-270, 20)
	container.add_theme_constant_override("separation", 8)
	add_child(container)

	_sfx_btn = Button.new()
	_sfx_btn.focus_mode = Control.FOCUS_NONE
	_sfx_btn.custom_minimum_size = Vector2(60, 52)
	_sfx_btn.add_theme_font_size_override("font_size", 16)
	_sfx_btn.pressed.connect(_on_sfx_toggle)
	container.add_child(_sfx_btn)

	_music_btn = Button.new()
	_music_btn.focus_mode = Control.FOCUS_NONE
	_music_btn.custom_minimum_size = Vector2(60, 52)
	_music_btn.add_theme_font_size_override("font_size", 16)
	_music_btn.pressed.connect(_on_music_toggle)
	container.add_child(_music_btn)

	_tts_btn = Button.new()
	_tts_btn.focus_mode = Control.FOCUS_NONE
	_tts_btn.custom_minimum_size = Vector2(60, 52)
	_tts_btn.add_theme_font_size_override("font_size", 16)
	_tts_btn.pressed.connect(_on_tts_toggle)
	container.add_child(_tts_btn)

	_update_audio_buttons()


func _update_audio_buttons() -> void:
	if _sfx_btn:
		_sfx_btn.text = "🔊" if AudioManager.sfx_enabled else "🔇"
		_sfx_btn.modulate = Color.WHITE if AudioManager.sfx_enabled else Color(0.5, 0.5, 0.5)
	if _music_btn:
		_music_btn.text = "🎵"
		_music_btn.modulate = Color.WHITE if AudioManager.music_enabled else Color(0.5, 0.5, 0.5)
	if _tts_btn:
		_tts_btn.text = "💬"
		_tts_btn.modulate = Color.WHITE if AudioManager.tts_enabled else Color(0.5, 0.5, 0.5)


func _on_sfx_toggle() -> void:
	AudioManager.toggle_sfx()
	if AudioManager.sfx_enabled:
		AudioManager.play_sfx("button")
	_update_audio_buttons()


func _on_music_toggle() -> void:
	AudioManager.toggle_music()
	if AudioManager.sfx_enabled:
		AudioManager.play_sfx("button")
	_update_audio_buttons()


func _on_tts_toggle() -> void:
	AudioManager.toggle_tts()
	if AudioManager.sfx_enabled:
		AudioManager.play_sfx("button")
	if AudioManager.tts_enabled and DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		AudioManager.speak_word("Word Blaster")
	_update_audio_buttons()


func _update_high_score(score: int) -> void:
	_high_score_label.text = "🏆  %06d" % score


func _animate_title() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_title, "modulate", Color(0.3, 0.9, 1.0, 1.0), 1.0)
	tween.tween_property(_title, "modulate", Color(0.8, 0.3, 1.0, 1.0), 1.0)
