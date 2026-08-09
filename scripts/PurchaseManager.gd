extends Node
## PurchaseManager (Autoload)
## Google Play 인앱 결제. 지금 파는 것은 **광고 제거** 하나뿐이다.
##
## 플러그인이 없으면(데스크톱·에디터) 자동으로 stub 모드로 돈다 — AdsManager 와 같은 방식이라
## 플러그인 설치를 기다리지 않고 결제 흐름과 UI 를 완성할 수 있다.
##
## ⚠️ **`BillingClient` 를 식별자로 직접 쓰면 안 된다.** 플러그인의 `class_name` 이라
##    애드온을 지운 환경에서는 **이 스크립트가 컴파일에 실패하고 오토로드가 통째로 죽는다**
##    (HUD 에서 같은 사고를 이미 겪었다). 스크립트를 **경로로 로드**해서 쓴다.
## ⚠️ `ClassDB.class_exists("BillingClient")` 로는 못 찾는다 — ClassDB 에는 엔진 클래스만 있고
##    GDScript 의 `class_name` 은 들어 있지 않다. 처음에 이렇게 짰다가 실기기에서 조용히
##    stub 으로 떨어질 뻔했다.
##
## ⚠️ 로컬 저장(user://)은 **캐시일 뿐 근거가 아니다.** 진짜 소유 여부는 앱을 켤 때마다
##    Play 에 질의해서 받는다(`_query_purchases`). 로컬 파일은 오프라인에서 쓰기 위한 것이다.

signal purchase_state_changed(ads_removed: bool)
signal purchase_failed(reason: String)
signal store_ready(available: bool)

const SAVE_PATH := "user://neonblaster_purchase.cfg"
## Play Console 의 인앱 상품 ID 와 **정확히 같아야** 한다(일회성 관리형 상품).
const PRODUCT_REMOVE_ADS := "remove_ads"
## 플러그인 스크립트 경로. 식별자가 아니라 경로로 접근한다(위 주의 참조).
const BILLING_SCRIPT := "res://addons/GodotGooglePlayBilling/BillingClient.gd"
## BillingClient.ProductType.INAPP 과 같은 값. enum 을 직접 참조하지 않으려고 상수로 둔다.
const PRODUCT_TYPE_INAPP := 0
## 플러그인이 안드로이드에서 등록하는 싱글톤 이름. 이게 없으면 실제 결제가 불가능하다.
const ANDROID_SINGLETON := "GodotGooglePlayBilling"

## 광고 제거를 구매했는가. 이 값 하나가 게임 전체의 광고 표시를 결정한다.
var ads_removed: bool = false
## 스토어에 연결됐는가. false 면 구매 버튼을 눌러도 아무 일도 일어나지 않는다.
var store_available: bool = false

var _client: Object = null
var _is_stub: bool = true


func _ready() -> void:
	_load()
	_connect_store()


# ---------------- 스토어 연결 ----------------

func _connect_store() -> void:
	# ⚠️ 애드온이 설치돼 있어도 **안드로이드 싱글톤이 없으면** 아무 응답이 오지 않는다.
	#    BillingClient 는 싱글톤이 없을 때 모든 메서드를 조용히 무시하므로, 데스크톱에서는
	#    구매를 눌러도 영영 아무 일도 안 일어난다(연결 신호조차 안 온다).
	#    애드온 설치 여부가 아니라 **싱글톤 유무**로 stub 을 판정해야 한다.
	if not ResourceLoader.exists(BILLING_SCRIPT) or not Engine.has_singleton(ANDROID_SINGLETON):
		_is_stub = true
		store_available = false
		print("[PurchaseManager] 결제 플러그인 없음. stub 모드로 동작합니다.")
		store_ready.emit(false)
		return

	var script: Script = load(BILLING_SCRIPT)
	_client = script.new()
	if _client == null:
		_is_stub = true
		store_ready.emit(false)
		return
	_is_stub = false
	if _client is Node:
		add_child(_client)
	# 신호 이름은 플러그인 3.3.0 기준. 버전이 바뀔 수 있어 있는 것만 연결한다.
	_try_connect("connected", _on_store_connected)
	_try_connect("disconnected", _on_store_disconnected)
	_try_connect("connect_error", _on_connect_error)
	_try_connect("on_purchase_updated", _on_purchase_updated)
	_try_connect("query_purchases_response", _on_query_purchases_response)
	if _client.has_method("start_connection"):
		_client.start_connection()
	print("[PurchaseManager] 결제 플러그인 초기화(3.3.0 API).")


func _try_connect(signal_name: String, target: Callable) -> void:
	if _client != null and _client.has_signal(signal_name):
		_client.connect(signal_name, target)


func _on_store_connected() -> void:
	store_available = true
	store_ready.emit(true)
	_query_purchases()


func _on_store_disconnected() -> void:
	store_available = false
	store_ready.emit(false)


## 이미 산 것이 있는지 Play 에 물어본다. 기기를 바꾸거나 재설치해도 여기서 복원된다.
func _query_purchases() -> void:
	if _is_stub or _client == null:
		return
	if _client.has_method("query_purchases"):
		_client.query_purchases(PRODUCT_TYPE_INAPP)


# ---------------- 구매 ----------------

## 광고 제거를 구매한다. stub 모드에서는 즉시 성공 처리한다(UI 흐름 확인용).
func buy_remove_ads() -> void:
	if ads_removed:
		return
	if _is_stub:
		print("[PurchaseManager] stub 구매 — 실제 결제 없음.")
		_grant_ads_removed()
		return
	if not store_available or _client == null:
		purchase_failed.emit("STORE NOT AVAILABLE")
		return
	if not _client.has_method("purchase"):
		purchase_failed.emit("PLUGIN API MISMATCH")
		return
	# purchase() 는 흐름을 띄우고 즉시 결과 코드를 돌려준다.
	# 실제 구매 성사는 on_purchase_updated 신호로 온다.
	var res: Dictionary = _client.purchase(PRODUCT_REMOVE_ADS)
	var code := int(res.get("response_code", 0))
	if code == 7:  # ITEM_ALREADY_OWNED — 이미 산 사람이다. 복원해 준다.
		_grant_ads_removed()
	elif code != 0:
		purchase_failed.emit(String(res.get("debug_message", "ERROR")) + " (%d)" % code)


## 구매 복원. 기기 변경·재설치 후 사용자가 직접 누른다.
func restore_purchases() -> void:
	if _is_stub:
		print("[PurchaseManager] stub 복원 — 저장된 상태 유지.")
		purchase_state_changed.emit(ads_removed)
		return
	_query_purchases()


## 구매가 갱신됐을 때(구매 완료 포함). 응답은 {response_code, purchases:[...]} 형태다.
func _on_purchase_updated(response: Dictionary) -> void:
	_scan_purchases(response)


## query_purchases 의 응답. 이미 소유한 상품이 여기로 온다(재설치·기기 변경 복원).
func _on_query_purchases_response(response: Dictionary) -> void:
	_scan_purchases(response)


func _on_connect_error(response_code: int, debug_message: String) -> void:
	store_available = false
	purchase_failed.emit("%s (%d)" % [debug_message, response_code])
	store_ready.emit(false)


## 응답 안에서 remove_ads 를 찾아 지급한다.
## ⚠️ 필드 이름은 플러그인/빌링 버전에 따라 다를 수 있어 여러 후보를 본다.
func _scan_purchases(response: Dictionary) -> void:
	var list: Array = response.get("purchases", [])
	for p in list:
		if not (p is Dictionary):
			continue
		var ids: Array = p.get("products", p.get("product_ids", []))
		if PRODUCT_REMOVE_ADS in ids:
			_acknowledge(p)
			_grant_ads_removed()


## 일회성 상품은 **확인(acknowledge)** 하지 않으면 3일 뒤 자동 환불된다.
func _acknowledge(purchase: Dictionary) -> void:
	if _is_stub or _client == null:
		return
	# 이미 확인된 구매를 또 확인하면 오류가 난다.
	if bool(purchase.get("is_acknowledged", false)):
		return
	var token := String(purchase.get("purchase_token", purchase.get("purchaseToken", "")))
	if token != "" and _client.has_method("acknowledge_purchase"):
		_client.acknowledge_purchase(token)


func _grant_ads_removed() -> void:
	if ads_removed:
		return
	ads_removed = true
	_save()
	purchase_state_changed.emit(true)


# ---------------- 저장 ----------------

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("purchase", "ads_removed", ads_removed)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	ads_removed = cfg.get_value("purchase", "ads_removed", false)
