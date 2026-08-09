extends CanvasLayer
## HUD - score, lives, wave, combo display during gameplay.

@onready var _score_label: Label = $UI/ScoreLabel
@onready var _wave_label: Label = $UI/WaveLabel
@onready var _lives_container: HBoxContainer = $UI/LivesContainer

## 현재 콤보 배수 단계. 단어 스타일(색·글로우·크기)을 여기서 파생시킨다.
var _combo_level: int = 0
var _word_slots: WordSlots
var _word_tween: Tween

var _sfx_btn: Button
var _music_btn: Button
var _tts_btn: Button
var _auto_label: Label = null


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.combo_changed.connect(_on_combo_changed)
	GameManager.combo_level_up.connect(_on_combo_level_up)
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)
	_create_word_slots()
	# 완성 리빌이 슬롯과 **같은 자리**에 뜨므로, 리빌 동안에는 슬롯을 감춘다.
	# 그래야 "채워지던 글자가 그대로 커진다"로 보인다.
	WordManager.word_completed.connect(func(_w): _set_slots_visible(false))
	WordManager.new_word_started.connect(func(_w): _set_slots_visible(true))
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
	_sfx_btn.custom_minimum_size = Vector2(56, 46)
	_sfx_btn.add_theme_font_size_override("font_size", 22)
	_sfx_btn.pressed.connect(_on_sfx_toggle)
	container.add_child(_sfx_btn)

	_music_btn = Button.new()
	_music_btn.focus_mode = Control.FOCUS_NONE
	_music_btn.custom_minimum_size = Vector2(56, 46)
	_music_btn.add_theme_font_size_override("font_size", 22)
	_music_btn.pressed.connect(_on_music_toggle)
	container.add_child(_music_btn)

	_tts_btn = Button.new()
	_tts_btn.focus_mode = Control.FOCUS_NONE
	_tts_btn.custom_minimum_size = Vector2(56, 46)
	_tts_btn.add_theme_font_size_override("font_size", 22)
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
	# ⚠️ y=10 은 WAVE 라벨(x 312~446, y 24~56)과 86x17px 겹쳤다(실측).
	#    목숨 표시(y 74~100) 아래로 내린다.
	_auto_label.position.y = 108
	_auto_label.visible = GameManager.auto_play
	$UI.add_child(_auto_label)


func set_wave(wave: int) -> void:
	if _wave_label:
		_wave_label.text = "👾 WAVE %d" % wave


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

## 리빌과 자리가 겹치므로 표시를 껐다 켠다.
func _set_slots_visible(v: bool) -> void:
	if _word_slots:
		_word_slots.visible = v


func _create_word_slots() -> void:
	# ⚠️ Label 에 "W _ _ _" 를 그대로 넣으면 밑줄 문자가 글자 baseline 아래에 그려져
	# 채워진 글자와 빈 칸의 높이가 어긋나 보인다. 글자와 칸을 각각 고정 위치에 그린다.
	_word_slots = WordSlots.new()
	_word_slots.name = "WordSlots"
	# ⚠️ 세로 위치는 **WordReveal.WORD_ANCHOR 와 같아야 한다.**
	#    예전에는 진행 스펠이 화면 14%(y 178), 완성 단어가 46% 에 떠서 시선이 점프했다.
	#    "한 자씩 채워지다 → 그 자리에서 완성돼 커진다"가 이 게임의 핵심 순간이라
	#    한 자리에서 일어나야 한다. 상단은 시선이 가장 덜 가는 자리이기도 하다.
	var vp := get_viewport().get_visible_rect().size
	_word_slots.position = Vector2(vp.x * 0.5, vp.y * WordReveal.WORD_ANCHOR)
	$UI.add_child(_word_slots)
	_refresh_word_style()


## 콤보 단계를 단어 스타일에 반영한다 — **콤보의 보상이 단어에 나타나는 지점.**
## 단계가 오를수록 단어가 콤보 색으로 물들고, 외곽 글로우가 두꺼워지고, 글자가 조금 커진다.
func _refresh_word_style() -> void:
	if not _word_slots:
		return
	var color: Color = WORD_BASE_COLOR if _combo_level <= 0 \
		else COMBO_COLORS[clampi(_combo_level, 0, COMBO_COLORS.size() - 1)]
	# 외곽선을 콤보 색의 어두운 버전으로 — 네온 글로우가 단계와 함께 강해진다
	var outline := color
	outline.s = minf(outline.s + 0.2, 1.0)
	outline.v *= 0.35
	_word_slots.set_style(WORD_FONT_SIZE + _combo_level * 3, color, outline)


## 현재 글자 수·폰트에서 화면을 넘지 않는 최대 확대 배율.
## ⚠️ 이걸 안 걸면 긴 단어(YELLOW=6글자)가 콤보 최고 단계 폰트(71px) + 완성 펀치(1.85배)에서
##    화면 폭을 넘어 **글자가 좌우로 잘려 나갔다**(실제로 발생).
func _max_word_scale() -> float:
	if _word_slots == null:
		return 1.6
	var w: float = _word_slots.get_line_width()
	if w <= 1.0:
		return 1.6
	var avail: float = get_viewport().get_visible_rect().size.x * 0.94
	return clampf(avail / w, 1.0, 1.9)


## 단어 라벨을 튕긴다. 콤보 단계가 높을수록 크게 튀지만 화면을 넘지는 않는다.
func _punch_word(pop: float) -> void:
	if not _word_slots:
		return
	pop = minf(pop, _max_word_scale())
	if _word_tween:
		_word_tween.kill()
	_word_slots.scale = Vector2(pop, pop)
	_word_tween = create_tween()
	_word_tween.tween_property(_word_slots, "scale", Vector2.ONE, 0.18) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_word_progress_updated(filled: String, _target: String) -> void:
	if _word_slots:
		_word_slots.set_tokens(filled.split(" ", false))
		# 글자를 맞힐 때마다 팝 — 콤보가 높으면 더 크게 튄다
		_punch_word(1.16 + _combo_level * 0.04)


func _on_word_completed(word: String) -> void:
	if not _word_slots:
		return
	# 단어 완성이 이 게임의 최고 보상 순간이다 — 연출을 여기에 몰아준다.
	# 콤보 단계가 높을수록 더 크게 터진다(콤보를 쌓은 보람이 단어에서 나타난다).
	var done := PackedStringArray()
	for c in word:
		done.append(c)
	_word_slots.set_tokens(done)
	_word_slots.set_style(WORD_FONT_SIZE + _combo_level * 3, Color(0.35, 1.0, 0.5), Color(0.0, 0.25, 0.1))
	if _word_tween:
		_word_tween.kill()
	var peak: float = minf(1.45 + _combo_level * 0.08, _max_word_scale())
	_word_tween = create_tween()
	_word_tween.tween_property(_word_slots, "scale", Vector2(peak, peak), 0.22) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_word_tween.tween_property(_word_slots, "scale", Vector2.ONE, 0.24)
	# 완성 직후에는 WordReveal 오버레이(아이콘 + 발음)가 같은 단어를 크게 보여준다.
	# HUD 라벨을 그대로 두면 두 개가 겹쳐 보이므로 잠시 숨긴다.
	_word_tween.tween_property(_word_slots, "modulate:a", 0.0, 0.2)
	_word_tween.tween_interval(0.8)
	# 색은 현재 콤보 단계 기준으로 되돌린다(기본색으로 되돌리면 콤보 보상이 사라져 보인다)
	_word_tween.tween_callback(_refresh_word_style)


func _on_new_word_started(_word: String) -> void:
	if _word_slots:
		# 완성 연출에서 숨겼던 표시를 다시 켠다(WordReveal 오버레이와 겹치지 않게 숨겼다).
		if _word_tween:
			_word_tween.kill()
		_word_slots.modulate.a = 1.0
		_word_slots.scale = Vector2.ONE
		_refresh_word_style()


func _on_score_changed(score: int) -> void:
	if _score_label:
		_score_label.text = "%06d" % score


func _on_lives_changed(lives: int) -> void:
	if not _lives_container:
		return
	for child in _lives_container.get_children():
		child.queue_free()
	for i in lives:
		var icon := Polygon2D.new()
		# ⚠️ 예전에는 아래를 향한 삼각형이라 위를 향한 플레이어 기체와 방향이 반대였다.
		# 목숨은 "내 기체"를 뜻하므로 기체 실루엣을 축소해 쓴다.
		icon.polygon = PackedVector2Array([
			Vector2(0, -10), Vector2(-7, 6), Vector2(-3, 4),
			Vector2(0, 7), Vector2(3, 4), Vector2(7, 6)
		])
		icon.color = Color(0.3, 0.9, 1.0)
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(24, 24)
		wrapper.add_child(icon)
		_lives_container.add_child(wrapper)
