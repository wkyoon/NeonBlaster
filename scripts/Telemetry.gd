extends Node
## Telemetry (Autoload) — 알파 테스트 밸런스 자료 수집
##
## 판 하나가 끝날 때마다 JSON 한 줄을 `user://` 큐에 쌓고, **다음 실행 때** 서버로 보낸다.
##
## ⚠️ **판이 끝나는 즉시 보내면 안 된다.** 이 게임은 지하철·버스에서 하는 게임이라
##    네트워크가 없는 경우가 흔하고, 앱이 백그라운드에서 죽으면 요청이 통째로 사라진다.
##    큐에 쌓아 두면 다음에 앱을 열 때 밀린 판이 한 번에 올라간다.
##
## ⚠️ **동의 없이는 아무것도 보내지 않는다**(`consent`). 거부해도 게임은 100% 그대로 동작한다.
##    수집을 게임 기능의 조건으로 걸면 정책 위반이다.
##
## ⚠️ **개인을 식별할 수 있는 것은 담지 않는다.** 계정·이메일·광고ID(AAID)·IMEI 없이
##    설치할 때 만든 난수 `install_id` 만 쓴다. 이 값은 앱을 지우면 사라진다.
##    항목을 추가할 때 이 원칙을 깨면 Play 데이터 보안 양식 신고 내용과 어긋난다.
##
## ⚠️ 스키마는 `Benchmark.gd` 의 지표 이름과 **일부러 똑같이** 맞춰 두었다.
##    이름이 갈라지면 알파 자료를 기존 밸런스 리포트에 태울 수 없다.

## ⚠️ 서버 배포 후 실제 주소로 확인할 것. 수신부는 NestJS — `server/` 참조.
##    전용 서브도메인이라 경로 프리픽스가 없다(`nb-api.won-solution.com/collect`).
##    ⚠️ **반드시 https 여야 한다.** `flush()` 가 http 주소면 아예 보내지 않는다 —
##    평문으로 나가면 중간에서 읽히고, 안드로이드 기본 설정이 평문을 막기도 한다.
const ENDPOINT := "https://nb-api.won-solution.com/collect"

## ⚠️ 인증이 아니라 **잡음 차단**용이다. APK 를 뜯으면 나오므로 민감한 것을 걸지 말 것.
##    서버의 `NB_TOKEN` 환경변수와 같은 값이어야 한다.
const TOKEN := "CHANGE_ME_BEFORE_DEPLOY"

const QUEUE_PATH := "user://telemetry_queue.jsonl"
const CONFIG_PATH := "user://telemetry.cfg"

## 레코드 형식 버전. 항목을 바꾸면 올린다 — 서버가 섞인 스키마를 구분할 수 있어야 한다.
const SCHEMA := 1

## 큐 상한. 네트워크가 계속 없어도 파일이 무한히 자라지 않게 한다(오래된 것부터 버린다).
const MAX_QUEUE_RUNS := 300
const REQUEST_TIMEOUT := 20.0

## 0 = 아직 안 물어봄, 1 = 동의, -1 = 거부
const CONSENT_UNSET := 0
const CONSENT_YES := 1
const CONSENT_NO := -1

var consent: int = CONSENT_UNSET
var install_id: String = ""

var _http: HTTPRequest = null
var _sending: bool = false
## 이번 전송에 실어 보낸 줄 수. 성공하면 큐 앞에서 이만큼만 지운다
## (전송 중에 새 판이 끝나 큐 뒤에 붙을 수 있으므로 통째로 지우면 그 판을 잃는다).
var _inflight_lines: int = 0


func _ready() -> void:
	_load_config()
	_http = HTTPRequest.new()
	_http.name = "TelemetryHTTP"
	_http.timeout = REQUEST_TIMEOUT
	_http.request_completed.connect(_on_request_completed)
	add_child(_http)
	# 시작하자마자 보내면 첫 화면이 버벅인다. 조금 늦춘다.
	get_tree().create_timer(3.0).timeout.connect(flush)


func has_consent() -> bool:
	return consent == CONSENT_YES


func set_consent(agreed: bool) -> void:
	consent = CONSENT_YES if agreed else CONSENT_NO
	if not agreed:
		# 거부하면 이미 쌓인 것도 지운다 — 남겨 두면 나중에 실려 나간다.
		DirAccess.remove_absolute(ProjectSettings.globalize_path(QUEUE_PATH))
		if FileAccess.file_exists(QUEUE_PATH):
			var f := FileAccess.open(QUEUE_PATH, FileAccess.WRITE)
			if f != null:
				f.close()
	_save_config()
	if agreed:
		flush()


## 판이 끝날 때 `RunTelemetry` 가 부른다.
func record_run(run: Dictionary) -> void:
	if not has_consent():
		return
	run["schema"] = SCHEMA
	run["install_id"] = install_id
	run["app_version"] = ProjectSettings.get_setting("application/config/version", "0")
	run["platform"] = OS.get_name()
	run["device"] = OS.get_model_name()
	run["debug_build"] = OS.is_debug_build()
	var win := DisplayServer.window_get_size()
	run["window_px"] = "%dx%d" % [win.x, win.y]
	run["dpi"] = DisplayServer.screen_get_dpi()
	# ⚠️ 로컬 날짜 문자열. 유닉스 시간만 두면 시차 때문에 "며칠째"가 어긋난다.
	run["local_date"] = Time.get_date_string_from_system()
	run["unix_time"] = Time.get_unix_time_from_system()
	_append_line(JSON.stringify(run))


## 큐에 밀린 판을 한 번에 올린다. 실패하면 그냥 둔다(다음 실행 때 다시 시도).
func flush() -> void:
	if _sending or not has_consent() or _http == null:
		return
	if ENDPOINT.begins_with("https://") == false:
		return
	var lines := _read_lines()
	if lines.is_empty():
		return
	var runs: Array = []
	for line in lines:
		var parsed = JSON.parse_string(line)
		if parsed is Dictionary:
			runs.append(parsed)
	if runs.is_empty():
		_clear_queue()
		return
	var body := JSON.stringify({
		"schema": SCHEMA,
		"install_id": install_id,
		"runs": runs,
	})
	_inflight_lines = lines.size()
	_sending = true
	var headers := PackedStringArray([
		"Content-Type: application/json",
		"X-NB-Token: " + TOKEN,
	])
	var err := _http.request(ENDPOINT, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_sending = false
		_inflight_lines = 0


func _on_request_completed(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_sending = false
	var ok := result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300
	if ok:
		_drop_front(_inflight_lines)
	_inflight_lines = 0


# --- 큐 파일 ---------------------------------------------------------------

func _read_lines() -> Array[String]:
	var out: Array[String] = []
	if not FileAccess.file_exists(QUEUE_PATH):
		return out
	var f := FileAccess.open(QUEUE_PATH, FileAccess.READ)
	if f == null:
		return out
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line != "":
			out.append(line)
	f.close()
	return out


func _write_lines(lines: Array[String]) -> void:
	var f := FileAccess.open(QUEUE_PATH, FileAccess.WRITE)
	if f == null:
		return
	for line in lines:
		f.store_line(line)
	f.close()


## 판 수가 적어(상한 300) 통째로 다시 쓰는 편이 append + 부분 삭제보다 안전하다.
func _append_line(line: String) -> void:
	var lines := _read_lines()
	lines.append(line)
	while lines.size() > MAX_QUEUE_RUNS:
		lines.remove_at(0)
	_write_lines(lines)


func _drop_front(count: int) -> void:
	if count <= 0:
		return
	var lines := _read_lines()
	if count >= lines.size():
		_clear_queue()
		return
	_write_lines(lines.slice(count))


func _clear_queue() -> void:
	_write_lines([] as Array[String])


# --- 설정 -----------------------------------------------------------------

func _load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		consent = int(cfg.get_value("telemetry", "consent", CONSENT_UNSET))
		install_id = String(cfg.get_value("telemetry", "install_id", ""))
	if install_id == "":
		install_id = _new_install_id()
		_save_config()


func _save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("telemetry", "consent", consent)
	cfg.set_value("telemetry", "install_id", install_id)
	cfg.save(CONFIG_PATH)


## 기기와 무관한 난수. 앱을 지우면 사라지고 복구되지 않는다.
func _new_install_id() -> String:
	var crypto := Crypto.new()
	return crypto.generate_random_bytes(8).hex_encode()
