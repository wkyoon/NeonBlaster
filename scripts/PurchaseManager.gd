extends Node
## PurchaseManager (Autoload)
## Google Play 인앱 결제. 지금 파는 것은 **광고 제거** 하나뿐이다.
##
## 플러그인이 없으면(데스크톱·에디터) 자동으로 stub 모드로 돈다 — AdsManager 와 같은 방식이라
## 플러그인 설치를 기다리지 않고 결제 흐름과 UI 를 완성할 수 있다.
##
## ⚠️ **플러그인 클래스를 식별자로 직접 쓰면 안 된다.** `BillingClient` 를 코드에 그대로 적으면
##    플러그인이 없는 환경에서 **이 스크립트 자체가 컴파일에 실패**하고, 오토로드가 통째로 죽는다.
##    (같은 실수를 HUD 에서 이미 겪었다 — `class_name` 이 없어 HUD 가 스크립트 없는 노드로 떨어졌다.)
##    그래서 `ClassDB.class_exists` / `ClassDB.instantiate` 로 **이름 문자열**을 통해서만 접근한다.
##
## ⚠️ 로컬 저장(user://)은 **캐시일 뿐 근거가 아니다.** 진짜 소유 여부는 앱을 켤 때마다
##    Play 에 질의해서 받는다(`_query_purchases`). 로컬 파일은 오프라인에서 쓰기 위한 것이다.

signal purchase_state_changed(ads_removed: bool)
signal purchase_failed(reason: String)
signal store_ready(available: bool)

const SAVE_PATH := "user://neonblaster_purchase.cfg"
## Play Console 의 인앱 상품 ID 와 **정확히 같아야** 한다(일회성 관리형 상품).
const PRODUCT_REMOVE_ADS := "remove_ads"
## 플러그인이 등록하는 클래스 이름. 문자열로만 쓴다(위 주의 참조).
const BILLING_CLASS := "BillingClient"

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
	if not ClassDB.class_exists(BILLING_CLASS):
		_is_stub = true
		store_available = false
		print("[PurchaseManager] 결제 플러그인 없음. stub 모드로 동작합니다.")
		store_ready.emit(false)
		return

	_client = ClassDB.instantiate(BILLING_CLASS)
	if _client == null:
		_is_stub = true
		store_ready.emit(false)
		return
	_is_stub = false
	if _client is Node:
		add_child(_client)
	# 신호 이름은 플러그인 버전에 따라 다를 수 있어 있는 것만 연결한다.
	_try_connect("connected", _on_store_connected)
	_try_connect("disconnected", _on_store_disconnected)
	_try_connect("purchases_updated", _on_purchases_updated)
	_try_connect("purchase_error", _on_purchase_error)
	if _client.has_method("start_connection"):
		_client.start_connection()
	print("[PurchaseManager] 결제 플러그인 초기화.")


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
		_client.query_purchases()


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
	if _client.has_method("purchase"):
		_client.purchase(PRODUCT_REMOVE_ADS)
	else:
		purchase_failed.emit("PLUGIN API MISMATCH")


## 구매 복원. 기기 변경·재설치 후 사용자가 직접 누른다.
func restore_purchases() -> void:
	if _is_stub:
		print("[PurchaseManager] stub 복원 — 저장된 상태 유지.")
		purchase_state_changed.emit(ads_removed)
		return
	_query_purchases()


func _on_purchases_updated(purchases: Array) -> void:
	for p in purchases:
		var ids: Array = []
		if p is Dictionary:
			ids = p.get("product_ids", p.get("products", []))
		elif "product_ids" in p:
			ids = p.product_ids
		if PRODUCT_REMOVE_ADS in ids:
			_acknowledge(p)
			_grant_ads_removed()


## 일회성 상품은 **확인(acknowledge)** 하지 않으면 3일 뒤 자동 환불된다.
func _acknowledge(purchase: Variant) -> void:
	if _is_stub or _client == null:
		return
	var token := ""
	if purchase is Dictionary:
		token = String(purchase.get("purchase_token", ""))
	elif "purchase_token" in purchase:
		token = String(purchase.purchase_token)
	if token != "" and _client.has_method("acknowledge_purchase"):
		_client.acknowledge_purchase(token)


func _on_purchase_error(code: int, message: String) -> void:
	purchase_failed.emit("%s (%d)" % [message, code])


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
