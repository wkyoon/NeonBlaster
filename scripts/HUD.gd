extends CanvasLayer
## HUD - score, lives, wave, combo display during gameplay.

@onready var _score_label: Label = $UI/ScoreLabel
@onready var _high_score_label: Label = $UI/HighScoreLabel
@onready var _wave_label: Label = $UI/WaveLabel
@onready var _lives_container: HBoxContainer = $UI/LivesContainer

## 현재 콤보 배수 단계. 단어 스타일(색·글로우·크기)을 여기서 파생시킨다.
var _combo_level: int = 0
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
	GameManager.combo_level_up.connect(_on_combo_level_up)
	_on_score_changed(GameManager.score)
	_on_high_score_changed(GameManager.high_score)
	_on_lives_changed(GameManager.lives)
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


## 단어 기본 색 (콤보 0단계).
const WORD_BASE_COLOR := Color(0.3, 1.0, 0.9)
## 단어 기본 폰트 크기. 콤보 단계마다 +3 씩 커진다.
const WORD_FONT_SIZE := 56

## 콤보 단계별 색 — **단어 기본색(시안)에서 시작해 점점 뜨거워지는 상승 배열.**
## 이 색은 콤보 라벨보다 **단어 라벨**에 쓰이는 게 핵심이다(콤보의 보상 = 단어가 화려해짐).
## ⚠️ 배열 끝을 시안 계열로 두면 최고 단계에서 단어가 기본색으로 돌아와 보상 신호가 사라진다.
##    실제로 그런 배열이었고(끝이 시안), 최고 콤보에서 단어가 평소와 구분되지 않았다.
const COMBO_COLORS: Array[Color] = [
	Color(0.55, 1.0, 0.8),   # x1   민트 (기본색에서 살짝 벗어남)
	Color(0.85, 1.0, 0.45),  # x1.5 라임
	Color(1.0, 0.92, 0.35),  # x2   노랑
	Color(1.0, 0.65, 0.25),  # x2.5 주황
	Color(1.0, 0.42, 0.5),   # x3   핑크
	Color(1.0, 0.45, 1.0),   # x3.5+ 마젠타 (최고 단계 — 가장 눈에 띈다)
]


## 콤보는 **화면에 표시하지 않는다.**
## 이 게임의 학습 대상은 단어인데, 콤보 숫자를 띄우면 시선과 각인이 콤보로 갔다
## (실제 피드백: "콤보가 터지니까 단어가 눈에 들어오지 않는다").
## 콤보 로직과 점수 배수는 그대로 살아 있고, 플레이어는 **단어가 화려해지는 것으로만** 콤보를 감지한다.
## → 콤보 단계를 추적해서 단어 스타일에 넘기는 것이 이 함수의 유일한 역할이다.
func _on_combo_changed(_combo: int, multiplier: float) -> void:
	var level: int = 0
	if _combo >= 2:
		level = clampi(int(round((multiplier - 1.0) / 0.5)), 0, COMBO_COLORS.size() - 1)
	if level != _combo_level:
		_combo_level = level
		_refresh_word_style()


## 콤보 배수 단계를 새로 돌파했을 때: 화면을 흔드는 대신 **단어를 터뜨린다.**
## 카메라 셰이크와 큰 화면 플래시는 글자 가독성을 직접 해치므로 쓰지 않는다.
func _on_combo_level_up(level: int, _multiplier: float) -> void:
	if level <= 0:
		return
	_combo_level = clampi(level, 0, COMBO_COLORS.size() - 1)
	_refresh_word_style()
	_punch_word(1.18 + _combo_level * 0.05)
	AudioManager.play_sfx("powerup")


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
	# 화면 전체 폭을 가진 라벨 안에서 정렬해야 글자 수와 기기 비율에 관계없이
	# 텍스트의 실제 중심이 화면 중심과 일치합니다.
	_word_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_word_label.offset_left = 0.0
	_word_label.offset_top = 120.0
	_word_label.offset_right = 0.0
	_word_label.offset_bottom = 200.0
	$UI.add_child(_word_label)
	_word_label.resized.connect(_update_word_label_pivot)
	_update_word_label_pivot()


func _update_word_label_pivot() -> void:
	if _word_label:
		_word_label.pivot_offset = _word_label.size * 0.5


## 콤보 단계를 단어 스타일에 반영한다 — **콤보의 보상이 단어에 나타나는 지점.**
## 단계가 오를수록 단어가 콤보 색으로 물들고, 외곽 글로우가 두꺼워지고, 글자가 조금 커진다.
func _refresh_word_style() -> void:
	if not _word_label:
		return
	var color: Color = WORD_BASE_COLOR if _combo_level <= 0 \
		else COMBO_COLORS[clampi(_combo_level, 0, COMBO_COLORS.size() - 1)]
	_word_label.add_theme_color_override("font_color", color)
	# 외곽선을 콤보 색의 어두운 버전으로 — 네온 글로우가 단계와 함께 강해진다
	var outline := color
	outline.s = minf(outline.s + 0.2, 1.0)
	outline.v *= 0.35
	_word_label.add_theme_color_override("font_outline_color", outline)
	_word_label.add_theme_constant_override("outline_size", 8 + _combo_level * 3)
	_word_label.add_theme_font_size_override("font_size", WORD_FONT_SIZE + _combo_level * 3)


## 단어 라벨을 튕긴다. 콤보 단계가 높을수록 크게 튀도록 호출부에서 배율을 준다.
func _punch_word(pop: float) -> void:
	if not _word_label:
		return
	if _word_tween:
		_word_tween.kill()
	_word_label.scale = Vector2(pop, pop)
	_word_tween = create_tween()
	_word_tween.tween_property(_word_label, "scale", Vector2.ONE, 0.18) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_word_progress_updated(filled: String, _target: String) -> void:
	if _word_label:
		_word_label.text = filled
		# 글자를 맞힐 때마다 팝 — 콤보가 높으면 더 크게 튄다
		_punch_word(1.16 + _combo_level * 0.04)


func _on_word_completed(word: String) -> void:
	if not _word_label:
		return
	# 단어 완성이 이 게임의 최고 보상 순간이다 — 연출을 여기에 몰아준다.
	# 콤보 단계가 높을수록 더 크게 터진다(콤보를 쌓은 보람이 단어에서 나타난다).
	_word_label.text = word
	_word_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.5))
	if _word_tween:
		_word_tween.kill()
	var peak := 1.45 + _combo_level * 0.08
	_word_tween = create_tween()
	_word_tween.tween_property(_word_label, "scale", Vector2(peak, peak), 0.22) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_word_tween.tween_property(_word_label, "scale", Vector2.ONE, 0.24)
	_word_tween.tween_interval(0.8)
	# 색은 현재 콤보 단계 기준으로 되돌린다(기본색으로 되돌리면 콤보 보상이 사라져 보인다)
	_word_tween.tween_callback(_refresh_word_style)


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
