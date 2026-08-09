extends SceneTree
## 실제 Game.tscn 에 RunTelemetry 가 붙어 판이 기록되는지 확인 (개발용).
##
##   godot --headless --path . --script tools/telemetry_run_check.gd
##
## 두 가지를 본다:
##   1) 사람 플레이(auto_play=false) → 판이 큐에 쌓인다
##   2) AI 플레이(auto_play=true)    → **쌓이지 않는다** (벤치마크가 자료를 오염시키면 안 된다)
## ⚠️ 실행하면 `user://telemetry_queue.jsonl` 과 동의 설정을 덮어쓴다.

const PLAY_SECONDS := 7.0

var _t: float = 0.0
var _scene: Node = null
var _phase: int = 0
var _fails: int = 0
var _tel: Node = null


func _initialize() -> void:
	_tel = root.get_node("Telemetry")
	_tel._load_config()
	_tel.set_consent(true)
	_tel._clear_queue()


func _process(delta: float) -> bool:
	_t += delta
	if _t < 0.5:
		return false

	if _scene == null:
		# ⚠️ --script 모드에서는 오토로드가 전역 식별자로 잡히지 않는다. 노드로 얻는다.
		root.get_node("GameManager").auto_play = (_phase == 1)
		_scene = load("res://scenes/Game.tscn").instantiate()
		root.add_child(_scene)
		# ⚠️ 적·탄·이펙트가 전부 `get_tree().current_scene` 에 붙는다.
		#    --script 모드에서는 current_scene 이 비어 있어 매 프레임 터진다.
		current_scene = _scene
		_t = 0.5
		return false

	if _t < PLAY_SECONDS:
		return false

	# 씬에서 빼면 RunTelemetry._exit_tree 가 판을 마감한다.
	current_scene = null
	root.remove_child(_scene)
	_scene.free()
	_scene = null

	var lines: int = _tel._read_lines().size()
	if _phase == 0:
		if lines != 1:
			print("FAIL 사람 플레이가 기록되지 않았다 (줄 %d)" % lines)
			_fails += 1
		else:
			var run: Dictionary = JSON.parse_string(_tel._read_lines()[0])
			print("기록됨: end_reason=%s survival=%.1fs alive_avg=%.2f words=%s samples=%d" % [
				run.get("end_reason"), float(run.get("survival_time", 0.0)),
				float(run.get("alive_avg", 0.0)), run.get("words_completed"),
				(run.get("samples", []) as Array).size()])
			for key in ["bonus_minutes", "target_seconds", "rank", "end_reason",
					"survival_ratio", "alive_avg", "hits_taken", "words_per_min", "fps_avg"]:
				if not run.has(key):
					print("FAIL 항목 누락: %s" % key)
					_fails += 1
		_tel._clear_queue()
		_phase = 1
		_t = 0.0
		return false

	if lines != 0:
		print("FAIL AI 플레이가 기록됐다 — 벤치마크가 알파 자료를 오염시킨다 (줄 %d)" % lines)
		_fails += 1

	print("결과: %s" % ("통과" if _fails == 0 else "실패 %d건" % _fails))
	quit(0 if _fails == 0 else 1)
	return true
