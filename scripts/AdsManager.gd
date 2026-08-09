extends Node
## AdsManager (Autoload)
## AdMob integration for Interstitial and Rewarded ads.
##
## ⚠️ **배너 광고는 없다. 다시 넣지 마라.**
##    조작이 드래그 추적이라 손가락이 화면 하단을 지나는데, 배너는 Godot 뷰 위에 얹히는
##    네이티브 뷰라 그 터치를 가로챈다. 기하: 기체가 화면 84% 아래로만 내려가도
##    손가락(기체 y + touch_lift 140)이 배너 영역(하단 70px)에 들어간다 — 회피 중 흔한 위치다.
##    결과는 **조작 끊김 + 오클릭**이었다. 수익은 전면·보상형과 인앱 결제로 낸다.
## Uses Poing Studios Godot AdMob plugin when available (Android export).
## Falls back to safe stubs in the editor/desktop for testing.
## In stub mode, draws on-screen DUMMY ad placeholders for layout testing.

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
const INTERSTITIAL_ID := "ca-app-pub-3940256099942544/1033173712"
const REWARDED_ID := "ca-app-pub-3940256099942544/5224354917"
## 플러그인 스크립트 경로와 안드로이드 싱글톤 이름.
## ⚠️ `Admob` 을 식별자로 쓰면 애드온을 지운 환경에서 **이 스크립트가 컴파일에 실패**한다.
##    경로로 로드해서 쓴다(PurchaseManager 와 같은 이유).
const ADMOB_SCRIPT := "res://addons/AdmobPlugin/Admob.gd"
const ANDROID_SINGLETON := "AdmobPlugin"

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
var _dummy_interstitial: Panel = null
var _dummy_rewarded: Panel = null


func _ready() -> void:
	_initialize_plugin()
	if not _is_plugin_available:
		_create_dummy_overlay()


func _initialize_plugin() -> void:
	# ⚠️ 애드온이 있어도 **안드로이드 싱글톤이 없으면** 광고가 전혀 오지 않는다.
	#    Admob 노드는 싱글톤이 없을 때 모든 호출을 오류 로그만 남기고 무시한다.
	#    애드온 존재가 아니라 **싱글톤 유무**로 stub 을 판정해야 데스크톱 테스트가 산다.
	if not ResourceLoader.exists(ADMOB_SCRIPT) or not Engine.has_singleton(ANDROID_SINGLETON):
		print("[AdsManager] AdMob plugin not found. Running in stub mode (no ads).")
		return

	var script: Script = load(ADMOB_SCRIPT)
	_admob = script.new()
	if _admob == null:
		print("[AdsManager] AdMob 노드 생성 실패. stub 모드.")
		return
	# 광고 단위 ID 는 노드의 @export 속성으로 넘긴다(플러그인이 요청을 만들 때 쓴다).
	_admob.set("android_real_application_id", ADMOB_APP_ID)
	_admob.set("android_real_interstitial_id", INTERSTITIAL_ID)
	_admob.set("android_real_rewarded_id", REWARDED_ID)
	add_child(_admob)
	_is_plugin_available = true
	_connect_plugin_signals()
	if _admob.has_method("initialize"):
		_admob.initialize()
	print("[AdsManager] AdMob plugin initialized (AdmobPlugin 7.0).")


func _connect_plugin_signals() -> void:
	if not _is_plugin_available or _admob == null:
		return
	# 신호 이름은 AdmobPlugin 7.0 기준. 버전이 바뀔 수 있어 있는 것만 연결한다.
	_bind("interstitial_ad_loaded", _on_interstitial_loaded)
	_bind("interstitial_ad_failed_to_load", _on_interstitial_failed)
	_bind("interstitial_ad_dismissed_full_screen_content", _on_interstitial_closed)
	_bind("rewarded_ad_loaded", _on_rewarded_loaded)
	_bind("rewarded_ad_failed_to_load", _on_rewarded_failed)
	_bind("rewarded_ad_dismissed_full_screen_content", _on_rewarded_closed)
	_bind("rewarded_ad_user_earned_reward", _on_rewarded_earned)


## 인자 개수가 신호마다 달라 그대로 연결하면 터진다. 인자를 버리는 래퍼로 감싼다.
func _bind(signal_name: String, target: Callable) -> void:
	if _admob != null and _admob.has_signal(signal_name):
		_admob.connect(signal_name, func(_a = null, _b = null): target.call())


# ---------------- Banner ----------------


# ---------------- Interstitial ----------------

func request_interstitial() -> void:
	if not _is_plugin_available or _admob == null:
		_interstitial_ready = true
		interstitial_loaded.emit()
		return
	if _interstitial_ready or _interstitial_load_requested:
		return
	_interstitial_load_requested = true
	_admob.load_interstitial_ad()


## ⚠️ 광고 제거를 구매했으면 전면 광고를 띄우지 않는다. 이 분기가 상품의 실체다.
func show_interstitial_if_ready() -> bool:
	if PurchaseManager.ads_removed:
		return false
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_interstitial_time < INTERSTITIAL_MIN_INTERVAL:
		return false
	if not _interstitial_ready:
		request_interstitial()
		return false
	if _is_plugin_available and _admob:
		_admob.show_interstitial_ad()
		_last_interstitial_time = now
		_interstitial_ready = false
		return true
	# Stub: show dummy interstitial for 2.5s
	_last_interstitial_time = now
	_interstitial_ready = false
	_show_dummy_fullscreen("Interstitial Ad", "Interstitial (Dummy)", Color(0.1, 0.3, 0.1), "interstitial")
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
	_admob.load_rewarded_ad()


## 광고 제거 구매자는 광고를 보지 않고 보상을 바로 받는다 —
## 상품을 산 사람이 부활하려고 광고를 봐야 한다면 산 의미가 없다.
func show_rewarded_if_ready(on_earned: Callable) -> bool:
	if PurchaseManager.ads_removed:
		on_earned.call()
		return true
	if not _rewarded_ready:
		request_rewarded()
		return false
	_rewarded_callback = on_earned
	if _is_plugin_available and _admob:
		_admob.show_rewarded_ad()
		return true
	# Stub: show dummy rewarded ad for 3s, then grant reward
	_show_dummy_fullscreen("Rewarded Ad", "Rewarded (Dummy) — Reward earned!", Color(0.2, 0.15, 0.4), "rewarded")
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
	hint.text = "(closing automatically...)"
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
