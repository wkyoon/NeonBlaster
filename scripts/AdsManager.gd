extends Node
## AdsManager (Autoload)
## **하단 배너 하나만** 쓴다. 전면·보상형은 없다 — 노출을 최소로 유지한다.
##
## ⚠️ 배너는 **플레이 중에만** 띄운다. 메뉴·도감·상점에서는 내린다.
##
## ⚠️ **배너와 조작이 충돌한다.** 이 게임은 드래그로 기체를 끄는데 배너는 Godot 뷰 위에 얹히는
##    네이티브 뷰라 그 자리의 터치를 가로챈다. 그래서 `Player.BOTTOM_RESERVE` 만큼
##    **화면 하단을 조작 영역에서 제외**한다. 둘 중 하나라도 빠지면 손가락이 배너에 닿는 순간
##    기체 조작이 끊기고 광고가 열린다(오클릭 → AdMob 무효 트래픽 위험).
##
## ⚠️ `Admob` / `LoadAdRequest` 를 식별자로 쓰지 마라. 애드온을 지운 환경에서 이 스크립트가
##    컴파일에 실패해 오토로드가 통째로 죽는다. 경로로 로드해서 쓴다.
## ⚠️ stub 판정은 애드온 존재가 아니라 **안드로이드 싱글톤 유무**로 한다.
##    Admob 노드는 싱글톤이 없으면 모든 호출을 오류 로그만 남기고 무시한다.

signal banner_loaded()

## AdMob 테스트 ID. 출시 전에 실제 ID 로 교체할 것.
## ⚠️ 개발 중에 실제 ID 를 넣고 자기 광고를 누르면 계정이 정지된다 — 테스트 ID 를 유지할 것.
const ADMOB_APP_ID := "ca-app-pub-3940256099942544~3347511713"
const BANNER_ID := "ca-app-pub-3940256099942544/6300978111"

const ADMOB_SCRIPT := "res://addons/AdmobPlugin/Admob.gd"
const ANDROID_SINGLETON := "AdmobPlugin"
## LoadAdRequest.AdPosition.BOTTOM 과 같은 값. enum 을 직접 참조하지 않으려고 상수로 둔다.
const AD_POSITION_BOTTOM := 1

var _admob: Node = null
var _is_stub: bool = true
var _banner_ready: bool = false
var _banner_shown: bool = false


func _ready() -> void:
	if not ResourceLoader.exists(ADMOB_SCRIPT) or not Engine.has_singleton(ANDROID_SINGLETON):
		print("[AdsManager] AdMob 플러그인 없음. stub 모드(광고 없음).")
		return
	var script: Script = load(ADMOB_SCRIPT)
	_admob = script.new()
	if _admob == null:
		return
	_is_stub = false
	_admob.set("android_real_application_id", ADMOB_APP_ID)
	_admob.set("android_real_banner_id", BANNER_ID)
	add_child(_admob)
	# ⚠️ 신호 인자 개수가 제각각(AdInfo, ResponseInfo …)이라 그대로 연결하면 터진다.
	if _admob.has_signal("banner_ad_loaded"):
		_admob.connect("banner_ad_loaded", func(_a = null, _b = null): _on_banner_loaded())
	if _admob.has_method("set_banner_position"):
		_admob.set_banner_position(AD_POSITION_BOTTOM)
	if _admob.has_method("initialize"):
		_admob.initialize()
	print("[AdsManager] AdMob 초기화 — 하단 배너만 사용.")


func _on_banner_loaded() -> void:
	_banner_ready = true
	banner_loaded.emit()
	# 로드가 늦게 끝났는데 이미 플레이 중이면 그때 띄운다.
	if _banner_shown:
		_admob.show_banner_ad()


## 플레이가 시작될 때 부른다.
func show_banner() -> void:
	_banner_shown = true
	if _is_stub or _admob == null:
		return
	if not _banner_ready and _admob.has_method("load_banner_ad"):
		_admob.load_banner_ad()
		return
	if _admob.has_method("show_banner_ad"):
		_admob.show_banner_ad()


## 플레이가 끝나거나 다른 화면으로 갈 때 부른다.
func hide_banner() -> void:
	_banner_shown = false
	if _is_stub or _admob == null:
		return
	if _admob.has_method("hide_banner_ad"):
		_admob.hide_banner_ad()
