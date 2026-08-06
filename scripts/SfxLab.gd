extends Control
## SfxLab — SFX 후보 A/B 비교 화면.
##
## `SfxLibrary` 의 변형들을 카테고리별로 나열하고, 눌러서 바로 들어봅니다.
## 실행:
##   godot --path . scenes/SfxLab.tscn                        # GUI 로 듣기
##   godot --headless --path . scenes/SfxLab.tscn -- --dump   # WAV 파일로 덤프 후 종료
##
## 조작: 숫자키 1~9 = 현재 카테고리 n번째 재생 / ←→ = 카테고리 이동 / Space = 순차 재생

const DUMP_DIR := "res://export/sfx_preview"
const NEON_CYAN := Color(0.3, 0.95, 1.0)
const NEON_PINK := Color(1.0, 0.35, 0.75)
const NEON_DIM := Color(0.55, 0.62, 0.8)

var _lib := SfxLibrary.new()
var _player: AudioStreamPlayer
var _cache: Dictionary = {}

var _cat_index: int = 0
var _cat_buttons: Array[Button] = []
var _variant_box: VBoxContainer
var _status: Label
var _bgm_button: Button

var _sequence_running: bool = false
var _sfx_bus_was_muted: bool = false


func _ready() -> void:
	if _wants_dump():
		_run_dump()
		return
	_setup_audio()
	_build_ui()
	_show_category(0)


# ---------------- 헤드리스 덤프 모드 ----------------

func _wants_dump() -> bool:
	return OS.get_cmdline_user_args().has("--dump")


## 모든 변형을 .wav 로 저장한다. afplay 등으로 밖에서 비교하기 위한 용도.
func _run_dump() -> void:
	var abs_dir := ProjectSettings.globalize_path(DUMP_DIR)
	var err := DirAccess.make_dir_recursive_absolute(abs_dir)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("[SfxLab] 덤프 디렉터리 생성 실패: %s (%d)" % [abs_dir, err])
		get_tree().quit(1)
		return
	print("[SfxLab] WAV 덤프 → %s" % abs_dir)
	var count := 0
	for v in SfxLibrary.variants():
		var wav := _lib.generate(v["id"])
		if wav == null:
			continue
		var path := "%s/%s__%s.wav" % [abs_dir, v["cat"], v["id"]]
		var save_err := wav.save_to_wav(path)
		if save_err != OK:
			push_error("[SfxLab] 저장 실패: %s (%d)" % [path, save_err])
			continue
		count += 1
		print("  %-14s %-18s %s" % [v["cat"], v["id"], v["desc"]])
	print("[SfxLab] %d개 저장 완료." % count)
	get_tree().quit(0)


# ---------------- 오디오 ----------------

func _setup_audio() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "SFX"
	add_child(_player)
	# 랩에서는 비교에 방해되지 않게 BGM 을 끄고 시작한다.
	AudioManager.stop_music()
	# SFX 가 꺼져 있어도 랩에서는 들려야 한다 (종료 시 원복).
	var idx := AudioServer.get_bus_index("SFX")
	if idx != -1:
		_sfx_bus_was_muted = AudioServer.is_bus_mute(idx)
		AudioServer.set_bus_mute(idx, false)


func _exit_tree() -> void:
	var idx := AudioServer.get_bus_index("SFX")
	if idx != -1:
		AudioServer.set_bus_mute(idx, _sfx_bus_was_muted)


func _stream_for(id: String) -> AudioStreamWAV:
	if not _cache.has(id):
		_cache[id] = _lib.generate(id)
	return _cache[id]


func _play(v: Dictionary) -> void:
	var wav := _stream_for(v["id"])
	if wav == null:
		return
	_player.stream = wav
	_player.play()
	var length := wav.data.size() / 4.0 / float(wav.mix_rate)
	_status.text = "▶ %s  (%s · %.2fs)" % [v["label"], v["id"], length]


# ---------------- UI ----------------

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.09)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16
	root.offset_right = -16
	root.offset_top = 20
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var title := Label.new()
	title.text = "SFX LAB"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", NEON_CYAN)
	root.add_child(title)

	var hint := Label.new()
	hint.text = "후보를 눌러 들어보고 비교하세요 · 숫자키 1~9 / ←→ 카테고리 / Space 순차재생"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", NEON_DIM)
	root.add_child(hint)

	root.add_child(_build_category_grid())

	var sep := HSeparator.new()
	root.add_child(sep)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_variant_box = VBoxContainer.new()
	_variant_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_variant_box.add_theme_constant_override("separation", 8)
	scroll.add_child(_variant_box)

	_status = Label.new()
	_status.text = "대기 중"
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", NEON_PINK)
	root.add_child(_status)

	root.add_child(_build_bottom_bar())


func _build_category_grid() -> Control:
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	var cats := SfxLibrary.categories()
	for i in cats.size():
		var btn := Button.new()
		btn.text = cats[i]["label"]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 15)
		btn.pressed.connect(_show_category.bind(i))
		grid.add_child(btn)
		_cat_buttons.append(btn)
	return grid


func _build_bottom_bar() -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)

	var seq_btn := Button.new()
	seq_btn.text = "순차 재생"
	seq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seq_btn.custom_minimum_size = Vector2(0, 52)
	seq_btn.pressed.connect(_play_sequence)
	box.add_child(seq_btn)

	_bgm_button = Button.new()
	_bgm_button.text = "BGM 켜기"
	_bgm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bgm_button.custom_minimum_size = Vector2(0, 52)
	_bgm_button.pressed.connect(_toggle_bgm)
	box.add_child(_bgm_button)

	var back_btn := Button.new()
	back_btn.text = "메뉴로"
	back_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_btn.custom_minimum_size = Vector2(0, 52)
	back_btn.add_theme_color_override("font_color", NEON_DIM)
	back_btn.pressed.connect(SceneManager.goto_menu)
	box.add_child(back_btn)

	return box


func _show_category(index: int) -> void:
	var cats := SfxLibrary.categories()
	_cat_index = wrapi(index, 0, cats.size())
	for i in _cat_buttons.size():
		_cat_buttons[i].modulate = Color.WHITE if i == _cat_index else Color(0.55, 0.55, 0.62)

	for child in _variant_box.get_children():
		child.queue_free()

	var key: String = cats[_cat_index]["key"]
	var list := SfxLibrary.variants_in(key)
	for i in list.size():
		_variant_box.add_child(_build_variant_row(i, list[i]))


func _build_variant_row(index: int, v: Dictionary) -> Control:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 62)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.text = "  %d.  %s\n      %s" % [index + 1, v["label"], v["desc"]]
	btn.add_theme_font_size_override("font_size", 16)
	# 기준점(현재 게임에 들어간 소리)은 다른 색으로 구분
	var is_current: bool = String(v["id"]).ends_with("_cur")
	btn.add_theme_color_override("font_color", NEON_DIM if is_current else NEON_CYAN)
	btn.pressed.connect(_play.bind(v))
	return btn


# ---------------- 동작 ----------------

func _toggle_bgm() -> void:
	if AudioManager.is_music_playing():
		AudioManager.stop_music()
		_bgm_button.text = "BGM 켜기"
	else:
		AudioManager.play_bgm()
		_bgm_button.text = "BGM 끄기"


## 현재 카테고리의 모든 후보를 0.7초 간격으로 순서대로 재생.
func _play_sequence() -> void:
	if _sequence_running:
		return
	_sequence_running = true
	var key: String = SfxLibrary.categories()[_cat_index]["key"]
	for v in SfxLibrary.variants_in(key):
		if not is_inside_tree():
			break
		_play(v)
		await get_tree().create_timer(0.7).timeout
	_sequence_running = false
	_status.text = "순차 재생 완료"


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key_event := event as InputEventKey
	match key_event.keycode:
		KEY_LEFT:
			_show_category(_cat_index - 1)
		KEY_RIGHT:
			_show_category(_cat_index + 1)
		KEY_SPACE:
			_play_sequence()
		KEY_ESCAPE:
			SceneManager.goto_menu()
		_:
			var n := key_event.keycode - KEY_1
			if n >= 0 and n < 9:
				var list := SfxLibrary.variants_in(SfxLibrary.categories()[_cat_index]["key"])
				if n < list.size():
					_play(list[n])
