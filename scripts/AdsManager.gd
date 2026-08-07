extends Node
## AdsManager (Autoload)
## AdMob integration for Banner, Interstitial, and Rewarded ads.
## Uses Poing Studios Godot AdMob plugin when available (Android export).
## Falls back to safe stubs in the editor/desktop for testing.
## In stub mode, draws on-screen DUMMY ad placeholders for layout testing.

signal banner_loaded()
signal banner_destroyed()
signal interstitial_loaded()
signal interstitial_closed()
signal interstitial_failed_to_load()
signal rewarded_loaded()
signal rewarded_closed()
signal rewarded_earned(amount: int)
signal rewarded_failed_to_load()

# AdMob test App ID (replace with real ID at release)
const ADMOB_APP_ID := "ca-app-pub-3940256099942544~3347511713"
# Test ad unit IDs (replace with real IDs at release)
const BANNER_ID := "ca-app-pub-3940256099942544/6300978111"
const INTERSTITIAL_ID := "ca-app-pub-3940256099942544/1033173712"
const REWARDED_ID := "ca-app-pub-3940256099942544/5224354917"

# Frequency capping for interstitials
const INTERSTITIAL_MIN_INTERVAL := 120.0  # seconds between interstitials

var _admob: Node = null  # Reference to AdMob plugin node
var _is_plugin_available: bool = false

var _interstitial_ready: bool = false
var _rewarded_ready: bool = false
var _last_interstitial_time: float = -INF
var _interstitial_load_requested: bool = false
var _rewarded_load_requested: bool = false

# Rewarded callback context
var _rewarded_callback: Callable = Callable()

# Dummy ad overlay nodes (stub mode only)
var _dummy_layer: CanvasLayer = null
var _dummy_banner: Panel = null
var _dummy_interstitial: Panel = null
var _dummy_rewarded: Panel = null
var _dummy_banner_visible: bool = false


func _ready() -> void:
	_initialize_plugin()
	if not _is_plugin_available:
		_create_dummy_overlay()


func _initialize_plugin() -> void:
	if Engine.has_singleton("AdMob"):
		_admob = Engine.get_singleton("AdMob")
		_is_plugin_available = true
		_connect_plugin_signals()
		_admob.initialize(true, ADMOB_APP_ID)
		print("[AdsManager] AdMob plugin initialized.")
	else:
		# Try loading via the plugin's autoload (Poing Studios pattern)
		var plugin_path := "res://addons/admob/src/core/android/AdMob.gd"
		if ResourceLoader.exists(plugin_path):
			var script := load(plugin_path)
			if script:
				_admob = script.new()
				add_child(_admob)
				_is_plugin_available = true
				_connect_plugin_signals()
				_admob.initialize(true, ADMOB_APP_ID)
				print("[AdsManager] AdMob plugin loaded from addons.")
				return
		print("[AdsManager] AdMob plugin not found. Running in stub mode (no ads).")


func _connect_plugin_signals() -> void:
	if not _is_plugin_available or _admob == null:
		return

	if _admob.has_signal("banner_loaded"):
		_admob.banner_loaded.connect(_on_banner_loaded)
	if _admob.has_signal("banner_destroyed"):
		_admob.banner_destroyed.connect(_on_banner_destroyed)
	if _admob.has_signal("interstitial_loaded"):
		_admob.interstitial_loaded.connect(_on_interstitial_loaded)
	if _admob.has_signal("interstitial_closed"):
		_admob.interstitial_closed.connect(_on_interstitial_closed)
	if _admob.has_signal("interstitial_failed_to_load"):
		_admob.interstitial_failed_to_load.connect(_on_interstitial_failed)
	if _admob.has_signal("rewarded_loaded"):
		_admob.rewarded_loaded.connect(_on_rewarded_loaded)
	if _admob.has_signal("rewarded_closed"):
		_admob.rewarded_closed.connect(_on_rewarded_closed)
	if _admob.has_signal("rewarded_failed_to_load"):
		_admob.rewarded_failed_to_load.connect(_on_rewarded_failed)
	# Rewarded amount earned (plugin variants use different signal names)
	if _admob.has_signal("rewarded_interstitial_loaded"):
		pass
	if _admob.has_signal("rewarded_currency_granted"):
		_admob.rewarded_currency_granted.connect(_on_rewarded_earned)


# ---------------- Banner ----------------

func load_banner() -> void:
	if _is_plugin_available and _admob:
		_admob.load_banner(BANNER_ID, "BANNER", "BOTTOM")
	else:
		# Stub: simulate banner load in editor
		_show_dummy_banner()
		banner_loaded.emit()


func show_banner() -> void:
	if _is_plugin_available and _admob:
		_admob.show_banner()
	else:
		_show_dummy_banner()
		banner_loaded.emit()


func hide_banner() -> void:
	if _is_plugin_available and _admob:
		_admob.hide_banner()
	else:
		_hide_dummy_banner()
		banner_destroyed.emit()


func destroy_banner() -> void:
	if _is_plugin_available and _admob:
		_admob.destroy_banner()
	else:
		_hide_dummy_banner()
		banner_destroyed.emit()


# ---------------- Interstitial ----------------

func request_interstitial() -> void:
	if not _is_plugin_available or _admob == null:
		_interstitial_ready = true
		interstitial_loaded.emit()
		return
	if _interstitial_ready or _interstitial_load_requested:
		return
	_interstitial_load_requested = true
	_admob.load_interstitial(INTERSTITIAL_ID)


func show_interstitial_if_ready() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_interstitial_time < INTERSTITIAL_MIN_INTERVAL:
		return false
	if not _interstitial_ready:
		request_interstitial()
		return false
	if _is_plugin_available and _admob:
		_admob.show_interstitial()
		_last_interstitial_time = now
		_interstitial_ready = false
		return true
	# Stub: show dummy interstitial for 2.5s
	_last_interstitial_time = now
	_interstitial_ready = false
	_show_dummy_fullscreen("Interstitial Ad", "전면 광고 (Dummy)", Color(0.1, 0.3, 0.1), "interstitial")
	var fs := get_tree().create_timer(2.5)
	fs.timeout.connect(func():
		_close_dummy_fullscreen("interstitial")
		interstitial_closed.emit()
	)
	return true


# ---------------- Rewarded ----------------

func request_rewarded() -> void:
	if not _is_plugin_available or _admob == null:
		_rewarded_ready = true
		rewarded_loaded.emit()
		return
	if _rewarded_ready or _rewarded_load_requested:
		return
	_rewarded_load_requested = true
	_admob.load_rewarded(REWARDED_ID)


func show_rewarded_if_ready(on_earned: Callable) -> bool:
	if not _rewarded_ready:
		request_rewarded()
		return false
	_rewarded_callback = on_earned
	if _is_plugin_available and _admob:
		_admob.show_rewarded()
		return true
	# Stub: show dummy rewarded ad for 3s, then grant reward
	_show_dummy_fullscreen("Rewarded Ad", "리워드 광고 (Dummy) — 보상 획득!", Color(0.2, 0.15, 0.4), "rewarded")
	var fs := get_tree().create_timer(3.0)
	fs.timeout.connect(func():
		_close_dummy_fullscreen("rewarded")
		rewarded_earned.emit(1)
		_rewarded_ready = false
		if _rewarded_callback.is_valid():
			_rewarded_callback.call(1)
			_rewarded_callback = Callable()
		rewarded_closed.emit()
	)
	return true


# ---------------- Signal Handlers ----------------

func _on_banner_loaded() -> void:
	banner_loaded.emit()


func _on_banner_destroyed() -> void:
	banner_destroyed.emit()


func _on_interstitial_loaded() -> void:
	_interstitial_ready = true
	_interstitial_load_requested = false
	interstitial_loaded.emit()


func _on_interstitial_failed() -> void:
	_interstitial_ready = false
	_interstitial_load_requested = false
	interstitial_failed_to_load.emit()


func _on_interstitial_closed() -> void:
	_interstitial_ready = false
	_interstitial_load_requested = false
	interstitial_closed.emit()
	# Preload next interstitial
	request_interstitial()


func _on_rewarded_loaded() -> void:
	_rewarded_ready = true
	_rewarded_load_requested = false
	rewarded_loaded.emit()


func _on_rewarded_failed() -> void:
	_rewarded_ready = false
	_rewarded_load_requested = false
	rewarded_failed_to_load.emit()


func _on_rewarded_earned(amount: int) -> void:
	rewarded_earned.emit(amount)
	if _rewarded_callback.is_valid():
		_rewarded_callback.call(amount)
		_rewarded_callback = Callable()


func _on_rewarded_closed() -> void:
	_rewarded_ready = false
	_rewarded_load_requested = false
	rewarded_closed.emit()
	# Preload next rewarded
	request_rewarded()


# ---------------- Dummy Ad Overlay (stub mode) ----------------

func _create_dummy_overlay() -> void:
	_dummy_layer = CanvasLayer.new()
	_dummy_layer.name = "DummyAdLayer"
	_dummy_layer.layer = 100
	add_child(_dummy_layer)
	print("[AdsManager] Dummy ad overlay created for testing.")


func _make_ad_stylebox(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_width_left = 3
	sb.border_width_right = 3
	sb.border_width_top = 3
	sb.border_width_bottom = 3
	sb.border_color = border
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	return sb


func _show_dummy_banner() -> void:
	if _dummy_layer == null:
		_create_dummy_overlay()
	if _dummy_banner != null:
		_dummy_banner.visible = true
		_dummy_banner_visible = true
		return
	_dummy_banner = Panel.new()
	_dummy_banner.name = "DummyBanner"
	var vp := get_viewport().get_visible_rect().size
	_dummy_banner.position = Vector2(vp.x / 2 - 160, vp.y - 70)
	_dummy_banner.size = Vector2(320, 50)
	_dummy_banner.add_theme_stylebox_override("panel", _make_ad_stylebox(Color(0.05, 0.05, 0.12, 0.95), Color(1.0, 0.8, 0.2)))
	var lbl := Label.new()
	lbl.text = "📢 BANNER AD (Dummy 320×50)"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dummy_banner.add_child(lbl)
	_dummy_layer.add_child(_dummy_banner)
	_dummy_banner_visible = true


func _hide_dummy_banner() -> void:
	if _dummy_banner != null:
		_dummy_banner.visible = false
	_dummy_banner_visible = false


func _show_dummy_fullscreen(title: String, subtitle: String, bg: Color, tag: String) -> void:
	if _dummy_layer == null:
		_create_dummy_overlay()
	# 화면 전체를 광고 색으로 덮지 않는다.
	# 예전에는 full-rect 패널을 alpha 0.96 으로 칠해서 게임오버 화면이 **초록 물감으로 덮여**
	# GAME OVER·점수·버튼이 거의 보이지 않았다. 어두운 스크림 + 가운데 카드로 바꾼다.
	var panel := Panel.new()
	panel.name = "Dummy" + tag.capitalize()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel",
		_make_ad_stylebox(Color(0.02, 0.02, 0.05, 0.72), Color(0, 0, 0, 0)))

	var card := Panel.new()
	card.name = "Card"
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.anchor_left = 0.5
	card.anchor_right = 0.5
	card.anchor_top = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -260.0
	card.offset_right = 260.0
	card.offset_top = -140.0
	card.offset_bottom = 140.0
	card.add_theme_stylebox_override("panel",
		_make_ad_stylebox(Color(bg.r, bg.g, bg.b, 0.96), Color(0.3, 1.0, 0.9)))
	panel.add_child(card)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	card.add_child(vbox)
	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 48)
	t.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	vbox.add_child(t)
	var s := Label.new()
	s.text = subtitle
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_theme_font_size_override("font_size", 24)
	s.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(s)
	var hint := Label.new()
	hint.text = "(자동으로 닫힙니다...)"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(hint)
	_dummy_layer.add_child(panel)
	if tag == "interstitial":
		_dummy_interstitial = panel
	else:
		_dummy_rewarded = panel


func _close_dummy_fullscreen(tag: String) -> void:
	if tag == "interstitial" and _dummy_interstitial != null:
		_dummy_interstitial.queue_free()
		_dummy_interstitial = null
	elif _dummy_rewarded != null:
		_dummy_rewarded.queue_free()
		_dummy_rewarded = null
