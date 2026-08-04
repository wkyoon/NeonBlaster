extends CanvasLayer
## HUD - score, lives, wave, combo display during gameplay.

@onready var _score_label: Label = $UI/ScoreLabel
@onready var _high_score_label: Label = $UI/HighScoreLabel
@onready var _wave_label: Label = $UI/WaveLabel
@onready var _lives_container: HBoxContainer = $UI/LivesContainer

var _combo_label: Label
var _combo_tween: Tween
var _word_label: Label
var _word_tween: Tween

var _sfx_btn: Button
var _music_btn: Button
var _tts_btn: Button
var _auto_label: Label = null


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.high_score_changed.connect(_on_high_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.combo_changed.connect(_on_combo_changed)
	_on_score_changed(GameManager.score)
	_on_high_score_changed(GameManager.high_score)
	_on_lives_changed(GameManager.lives)
	_create_combo_label()
	_create_word_label()
	_create_audio_toggles()
	_create_auto_play_indicator()
	# Connect to WordManager signals
	WordManager.word_progress_updated.connect(_on_word_progress_updated)
	WordManager.word_completed.connect(_on_word_completed)
	WordManager.new_word_started.connect(_on_new_word_started)


# ---------------- Audio Toggles (in-game) ----------------

func _create_audio_toggles() -> void:
	var container := HBoxContainer.new()
	container.name = "AudioToggles"
	container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	container.position = Vector2(-270, 10)
	container.add_theme_constant_override("separation", 6)
	$UI.add_child(container)

	_sfx_btn = Button.new()
	_sfx_btn.focus_mode = Control.FOCUS_NONE
	_sfx_btn.custom_minimum_size = Vector2(72, 36)
	_sfx_btn.add_theme_font_size_override("font_size", 13)
	_sfx_btn.pressed.connect(_on_sfx_toggle)
	container.add_child(_sfx_btn)

	_music_btn = Button.new()
	_music_btn.focus_mode = Control.FOCUS_NONE
	_music_btn.custom_minimum_size = Vector2(72, 36)
	_music_btn.add_theme_font_size_override("font_size", 13)
	_music_btn.pressed.connect(_on_music_toggle)
	container.add_child(_music_btn)

	_tts_btn = Button.new()
	_tts_btn.focus_mode = Control.FOCUS_NONE
	_tts_btn.custom_minimum_size = Vector2(72, 36)
	_tts_btn.add_theme_font_size_override("font_size", 13)
	_tts_btn.pressed.connect(_on_tts_toggle)
	container.add_child(_tts_btn)

	_update_audio_buttons()


func _update_audio_buttons() -> void:
	if _sfx_btn:
		_sfx_btn.text = "SFX\nON" if AudioManager.sfx_enabled else "SFX\nOFF"
		_sfx_btn.modulate = Color.WHITE if AudioManager.sfx_enabled else Color(0.5, 0.5, 0.5)
	if _music_btn:
		_music_btn.text = "BGM\nON" if AudioManager.music_enabled else "BGM\nOFF"
		_music_btn.modulate = Color.WHITE if AudioManager.music_enabled else Color(0.5, 0.5, 0.5)
	if _tts_btn:
		_tts_btn.text = "TTS\nON" if AudioManager.tts_enabled else "TTS\nOFF"
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
	_update_audio_buttons()


func _create_auto_play_indicator() -> void:
	_auto_label = Label.new()
	_auto_label.name = "AutoPlayLabel"
	_auto_label.text = "🤖 AUTO"
	_auto_label.add_theme_font_size_override("font_size", 22)
	_auto_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	_auto_label.add_theme_color_override("font_outline_color", Color(0, 0.3, 0.1))
	_auto_label.add_theme_constant_override("outline_size", 6)
	_auto_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_auto_label.position.y = 10
	_auto_label.visible = GameManager.auto_play
	$UI.add_child(_auto_label)


func set_wave(wave: int) -> void:
	if _wave_label:
		_wave_label.text = "WAVE %d" % wave


func _create_combo_label() -> void:
	_combo_label = Label.new()
	_combo_label.name = "ComboLabel"
	_combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_combo_label.add_theme_font_size_override("font_size", 42)
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	_combo_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_combo_label.add_theme_constant_override("shadow_offset_x", 2)
	_combo_label.add_theme_constant_override("shadow_offset_y", 2)
	_combo_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_combo_label.position.y = 80
	_combo_label.modulate.a = 0.0
	$UI.add_child(_combo_label)


func _on_combo_changed(combo: int, multiplier: float) -> void:
	if combo < 2:
		_hide_combo()
		return
	_combo_label.text = "x%d  COMBO %d" % [multiplier, combo]
	_combo_label.modulate.a = 1.0
	# Color based on multiplier
	if multiplier >= 3.0:
		_combo_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
	elif multiplier >= 2.0:
		_combo_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	else:
		_combo_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	# Pop animation
	if _combo_tween:
		_combo_tween.kill()
	_combo_label.scale = Vector2(1.3, 1.3)
	_combo_tween = create_tween()
	_combo_tween.tween_property(_combo_label, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)


func _hide_combo() -> void:
	if _combo_tween:
		_combo_tween.kill()
	_combo_tween = create_tween()
	_combo_tween.tween_property(_combo_label, "modulate:a", 0.0, 0.3)


# ---------------- Word Display ----------------

func _create_word_label() -> void:
	_word_label = Label.new()
	_word_label.name = "WordLabel"
	_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_word_label.add_theme_font_size_override("font_size", 56)
	_word_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	_word_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_word_label.add_theme_color_override("font_outline_color", Color(0, 0.3, 0.4))
	_word_label.add_theme_constant_override("shadow_offset_x", 2)
	_word_label.add_theme_constant_override("shadow_offset_y", 3)
	_word_label.add_theme_constant_override("outline_size", 8)
	_word_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_word_label.position.y = 120
	$UI.add_child(_word_label)


func _on_word_progress_updated(filled: String, _target: String) -> void:
	if _word_label:
		_word_label.text = filled
		# Pop animation on letter fill
		if _word_tween:
			_word_tween.kill()
		_word_label.scale = Vector2(1.2, 1.2)
		_word_tween = create_tween()
		_word_tween.tween_property(_word_label, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)


func _on_word_completed(word: String) -> void:
	if not _word_label:
		return
	# Celebration animation
	_word_label.text = word
	_word_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	if _word_tween:
		_word_tween.kill()
	_word_tween = create_tween()
	_word_tween.tween_property(_word_label, "scale", Vector2(1.4, 1.4), 0.2).set_ease(Tween.EASE_OUT)
	_word_tween.tween_property(_word_label, "scale", Vector2.ONE, 0.2)
	_word_tween.tween_interval(0.8)
	_word_tween.tween_callback(func(): _word_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9)))
	EffectsManager.screen_flash(Color(0.2, 1.0, 0.5, 0.3), 0.4)


func _on_new_word_started(_word: String) -> void:
	if _word_label:
		_word_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))


func _on_score_changed(score: int) -> void:
	if _score_label:
		_score_label.text = "%06d" % score


func _on_high_score_changed(high_score: int) -> void:
	if _high_score_label:
		_high_score_label.text = "BEST %06d" % high_score


func _on_lives_changed(lives: int) -> void:
	if not _lives_container:
		return
	for child in _lives_container.get_children():
		child.queue_free()
	for i in lives:
		var icon := Polygon2D.new()
		icon.polygon = PackedVector2Array([
			Vector2(0, 10), Vector2(-8, -5), Vector2(8, -5)
		])
		icon.color = Color(0.3, 0.9, 1.0)
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(24, 24)
		wrapper.add_child(icon)
		_lives_container.add_child(wrapper)