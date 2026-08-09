extends SceneTree
## 텔레메트리 큐 동작 확인 (개발용).
##
##   godot --headless --path . --script tools/telemetry_check.gd
##
## 동의 없음 → 아무것도 쌓이지 않는가 / 동의 → 쌓이는가 / 거부로 바꾸면 비워지는가
## / 상한(MAX_QUEUE_RUNS)에서 오래된 것부터 버리는가 를 확인한다.
## ⚠️ 실행하면 `user://telemetry_queue.jsonl` 과 동의 설정을 덮어쓴다.

func _initialize() -> void:
	var t := root.get_node("Telemetry")
	var fails := 0
	# ⚠️ SceneTree._initialize 는 오토로드의 _ready 보다 **먼저** 돈다.
	#    이때 install_id 는 아직 비어 있으므로 설정을 직접 읽어 둔다.
	t._load_config()

	t.set_consent(false)
	t.record_run({"end_reason": "died", "survival_time": 12.3})
	if _lines(t) != 0:
		print("FAIL 동의하지 않았는데 기록됐다"); fails += 1

	t.set_consent(true)
	t.record_run({"end_reason": "died", "survival_time": 12.3})
	t.record_run({"end_reason": "quit", "survival_time": 4.0})
	if _lines(t) != 2:
		print("FAIL 동의 후 2판이 안 쌓였다: %d" % _lines(t)); fails += 1

	var first: Dictionary = JSON.parse_string(t._read_lines()[0])
	for key in ["install_id", "app_version", "platform", "local_date", "schema"]:
		if not first.has(key):
			print("FAIL 필수 항목 누락: %s" % key); fails += 1
	if String(first.get("install_id", "")).length() != 16:
		print("FAIL install_id 길이가 16이 아니다"); fails += 1

	# 상한 초과분은 **오래된 것부터** 버려야 한다(최근 판이 밸런스에 더 가깝다).
	for i in range(t.MAX_QUEUE_RUNS + 10):
		t.record_run({"end_reason": "died", "seq": i})
	if _lines(t) != t.MAX_QUEUE_RUNS:
		print("FAIL 큐 상한이 안 걸렸다: %d" % _lines(t)); fails += 1
	var oldest: Dictionary = JSON.parse_string(t._read_lines()[0])
	# 앞서 2판이 들어 있었으므로 312 - 300 = 12개가 버려지고 seq 10 이 맨 앞이 된다.
	if int(oldest.get("seq", -1)) != 10:
		print("FAIL 오래된 것부터 버리지 않았다 (맨 앞 seq=%s)" % oldest.get("seq")); fails += 1

	t.set_consent(false)
	if _lines(t) != 0:
		print("FAIL 거부했는데 큐가 남아 있다"); fails += 1

	print("결과: %s" % ("통과" if fails == 0 else "실패 %d건" % fails))
	quit(0 if fails == 0 else 1)


func _lines(t: Node) -> int:
	return t._read_lines().size()
