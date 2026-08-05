extends Node2D
## Benchmark - 게임을 자동 실행(AI)하여 밸런스 메트릭을 수집하고 로그를 출력.
##
## 사용법:
##   godot --headless res://scenes/Benchmark.tscn
##
## 옵션(환경변수):
##   BENCH_GAMES      - 난이도당 실행할 게임 수 (기본 3)
##   BENCH_TIME       - 게임당 최대 시뮬레이션 시간 초 (기본 90)
##   BENCH_SEED       - 랜덤 시드 (기본 42)
##   BENCH_DIFFICULTY - easy / normal / hard / all (기본 all)
##   BENCH_FAST       - 1이면 시뮬레이션 가속 (time_scale=3) (기본 1)

const LOG_PATH := "res://benchmark_log.txt"
const JSON_PATH := "res://benchmark_results.json"

const DIFFS := ["EASY", "NORMAL", "HARD"]

var _game_scene: Node2D = null
var _metrics: Dictionary = {}
var _run_index: int = 0
var _total_runs: int = 3
var _max_time: float = 90.0
var _elapsed: float = 0.0
var _log_lines: Array = []
var _start_msec: int = 0
var _is_ending: bool = false
var _player: Node = null
var _spawner: Node = null

var _difficulty_queue: Array = []          # 큐에 남은 난이도 (String)
var _current_difficulty: String = "EASY"
var _per_difficulty_results: Dictionary = {}  # difficulty -> Array[metrics]
var _fast_mode: bool = true
var _time_scale_target: float = 1.0


func _ready() -> void:
	_total_runs = int(_env_or("BENCH_GAMES", "3"))
	_max_time = float(_env_or("BENCH_TIME", "90"))
	var seed_str := _env_or("BENCH_SEED", "42")
	seed(int(seed_str))
	_fast_mode = _env_or("BENCH_FAST", "1") == "1"
	_time_scale_target = 3.0 if _fast_mode else 1.0
	Engine.time_scale = _time_scale_target

	# AI 회피 실수율 (0=완벽, 0.1=숙련자, 0.2=일반, 0.3=초보)
	GameManager.ai_dodge_error = float(_env_or("BENCH_AI_ERROR", "0.0"))

	var diff_arg := _env_or("BENCH_DIFFICULTY", "all").to_upper()
	if diff_arg == "ALL":
		_difficulty_queue = DIFFS.duplicate()
	else:
		_difficulty_queue = [diff_arg]

	_log("\n" + "=".repeat(72))
	_log("NeonBlaster Balance Benchmark")
	_log("Difficulties: %s | Games/diff: %d | MaxTime: %.0fs | Seed: %s | Fast: %s (x%.1f)" % [
		str(_difficulty_queue), _total_runs, _max_time, seed_str, _fast_mode, _time_scale_target
	])
	_log("AI dodge error: %.0f%% (0=perfect AI, 20=avg human)" % (GameManager.ai_dodge_error * 100))
	_log("=".repeat(72))

	_start_msec = Time.get_ticks_msec()
	_start_next_difficulty()


func _env_or(key: String, default: String) -> String:
	var v := OS.get_environment(key)
	return v if v != "" else default


func _process(delta: float) -> void:
	# time_slow가 걸려 있으면 강제 해제 (단, fast 가속은 유지)
	Engine.time_scale = _time_scale_target
	if not is_instance_valid(_game_scene):
		return
	# 참고: Engine.time_scale이 설정되면 _process(delta)는 이미 스케일된 delta를 받음.
	# 따라서 delta 자체가 시뮬레이션 시간이므로 추가 곱셈 없음.
	_elapsed += delta
	_metrics["survival_time"] = _elapsed

	# 매 10초(시뮬레이션 시간)마다 진행 상황 로그
	if fmod(_elapsed, 10.0) < delta:
		_log("  [%.0fs][%s] wave=%d kills=%d score=%d alive=%d" % [
			_elapsed, _current_difficulty,
			_metrics["max_wave"],
			_metrics["kills"],
			GameManager.score,
			_get_enemy_count()
		])

	if _elapsed >= _max_time:
		_log("  >> [%s] 시간 초과 - 생존 달성!" % _current_difficulty)
		_metrics["score"] = GameManager.score
		_end_run()


func _start_next_difficulty() -> void:
	if _difficulty_queue.is_empty():
		_finish_all()
		return
	_current_difficulty = _difficulty_queue.pop_front()
	_per_difficulty_results[_current_difficulty] = []
	WordManager.set_difficulty(_parse_difficulty(_current_difficulty))
	_log("\n" + "#".repeat(72))
	_log("# Difficulty: %s" % _current_difficulty)
	_log("#".repeat(72))
	_run_index = 0
	_start_next_run()


func _start_next_run() -> void:
	if _run_index >= _total_runs:
		# 현재 난이도 요약
		_summarize_difficulty(_current_difficulty)
		_start_next_difficulty()
		return
	_is_ending = false
	_elapsed = 0.0
	_metrics = _new_metrics()
	_log("\n--- [%s] Run %d/%d ---" % [_current_difficulty, _run_index + 1, _total_runs])

	# 인스턴스화
	var game_res := load("res://scenes/Game.tscn") as PackedScene
	_game_scene = game_res.instantiate() as Node2D
	add_child(_game_scene)

	# 게임 시작 상태로 전환 (Game.gd의 _ready가 MENU로 설정할 수 있으므로 강제)
	GameManager.start_game()
	# AI 자동 실행 활성화
	GameManager.auto_play = true

	# 메트릭 수집을 위한 신호 연결 (다음 프레임에 노드가 준비된 후)
	call_deferred("_connect_signals")


func _parse_difficulty(name: String) -> int:
	match name:
		"EASY":   return WordManager.Difficulty.EASY
		"NORMAL": return WordManager.Difficulty.NORMAL
		"HARD":   return WordManager.Difficulty.HARD
	return WordManager.Difficulty.EASY


func _connect_signals() -> void:
	if not is_instance_valid(_game_scene):
		return
	_player = _game_scene.get_node_or_null("Player")
	if _player and _player.has_signal("player_died"):
		if not _player.player_died.is_connected(_on_player_died):
			_player.player_died.connect(_on_player_died)
	# 피격 추적 (목숨이 줄어들 때마다 카운트)
	if _player and _player.has_signal("player_hit"):
		if _player.player_hit.is_connected(_on_player_hit):
			_player.player_hit.disconnect(_on_player_hit)
		_player.player_hit.connect(_on_player_hit)
	_spawner = _game_scene.get_node_or_null("EnemySpawner")
	if _spawner and _spawner.has_signal("wave_started"):
		if not _spawner.wave_started.is_connected(_on_wave_started):
			_spawner.wave_started.connect(_on_wave_started)
	if _spawner and _spawner.has_signal("enemy_killed"):
		if not _spawner.enemy_killed.is_connected(_on_enemy_killed):
			_spawner.enemy_killed.connect(_on_enemy_killed)
	# WordManager 신호
	if WordManager.word_completed.is_connected(_on_word_completed):
		WordManager.word_completed.disconnect(_on_word_completed)
	WordManager.word_completed.connect(_on_word_completed)


func _new_metrics() -> Dictionary:
	return {
		"difficulty": _current_difficulty,
		"survival_time": 0.0,
		"max_wave": 1,
		"kills": 0,
		"kills_chaser": 0,
		"kills_shooter": 0,
		"kills_tank": 0,
		"score": 0,
		"words_completed": 0,
		"powerups_collected": 0,
		"hits_taken": 0,
		"near_death": 0,
		"deaths": 0,
		"timeout": false,
	}


func _on_player_died() -> void:
	if _is_ending:
		return
	_is_ending = true
	_metrics["deaths"] += 1
	_log("  >> [%s] 플레이어 사망 (생존 시간: %.1fs, 웨이브: %d, 피격: %d회)" % [
		_current_difficulty, _elapsed, _metrics["max_wave"], _metrics["hits_taken"]
	])
	_metrics["score"] = GameManager.score
	call_deferred("_end_run")


func _on_player_hit() -> void:
	_metrics["hits_taken"] += 1
	# 목숨이 1개 남으면 near_death 카운트
	if GameManager.lives <= 1:
		_metrics["near_death"] += 1
		_log("  !! [%s] 위험! 피격 %d회, 목숨 %d개 남음 (%.1fs)" % [
			_current_difficulty, _metrics["hits_taken"], GameManager.lives, _elapsed
		])
	else:
		_log("  !  [%s] 피격 (%d회, 목숨 %d) (%.1fs)" % [
			_current_difficulty, _metrics["hits_taken"], GameManager.lives, _elapsed
		])


func _on_wave_started(wave: int) -> void:
	_metrics["max_wave"] = max(_metrics["max_wave"], wave)


func _on_word_completed(_word: String) -> void:
	_metrics["words_completed"] += 1


func _on_enemy_killed(enemy_type: int, _points: int) -> void:
	_metrics["kills"] += 1
	match enemy_type:
		0:  _metrics["kills_chaser"] += 1
		1:  _metrics["kills_shooter"] += 1
		2:  _metrics["kills_tank"] += 1


func _end_run() -> void:
	if not is_instance_valid(_game_scene) and _run_index > 0 and (_per_difficulty_results[_current_difficulty] as Array).size() >= _run_index:
		return  # 이미 종료됨
	_metrics["score"] = GameManager.score
	_metrics["timeout"] = _elapsed >= _max_time - 0.5
	_per_difficulty_results[_current_difficulty].append(_metrics.duplicate(true))
	_log("  결과: %s" % str(_metrics))

	# 정리
	if is_instance_valid(_game_scene):
		if WordManager.word_completed.is_connected(_on_word_completed):
			WordManager.word_completed.disconnect(_on_word_completed)
		_game_scene.queue_free()
	_game_scene = null

	_run_index += 1
	call_deferred("_start_next_run")


func _summarize_difficulty(diff: String) -> void:
	var results: Array = _per_difficulty_results[diff]
	if results.is_empty():
		_log("\n[%s] 결과 없음" % diff)
		return
	var avg := _compute_avg(results)
	_log("\n" + "-".repeat(72))
	_log("[%s] 평균 (%d 게임)" % [diff, results.size()])
	_log("-".repeat(72))
	_log("  평균 생존: %.1fs / %.0fs" % [avg["survival_time"], _max_time])
	_log("  평균 웨이브: %.1f" % avg["max_wave"])
	_log("  평균 킬: %.1f (chaser:%.0f shooter:%.0f tank:%.0f)" % [
		avg["kills"], avg["kills_chaser"], avg["kills_shooter"], avg["kills_tank"]
	])
	_log("  평균 점수: %.0f" % avg["score"])
	_log("  평균 완성 단어: %.1f" % avg["words_completed"])
	_log("  평균 피격: %.1f회 (위험상황: %.1f회)" % [avg["hits_taken"], avg["near_death"]])
	var deaths := 0
	var timeouts := 0
	for r in results:
		if r["deaths"] > 0: deaths += 1
		if r["timeout"]: timeouts += 1
	_log("  사망: %d/%d | 생존(시간초과): %d/%d" % [deaths, results.size(), timeouts, results.size()])


func _compute_avg(results: Array) -> Dictionary:
	var sum := _new_metrics()
	var n := float(results.size())
	var keys := ["survival_time", "max_wave", "kills", "kills_chaser", "kills_shooter", "kills_tank", "score", "words_completed", "hits_taken", "near_death"]
	for r in results:
		for key in keys:
			sum[key] += r[key]
	for key in keys:
		sum[key] /= n
	return sum


func _finish_all() -> void:
	Engine.time_scale = 1.0
	_log("\n" + "=".repeat(72))
	_log("Benchmark Complete")
	_log("=".repeat(72))

	# JSON 저장
	_save_json()
	# 최종 밸런스 진단
	_log("")
	_log("=== 밸런스 종합 진단 ===")
	for diff in DIFFS:
		if not _per_difficulty_results.has(diff):
			continue
		var results: Array = _per_difficulty_results[diff]
		if results.is_empty():
			continue
		_log("")
		_log("[%s]" % diff)
		var avg := _compute_avg(results)
		var deaths := 0
		var timeouts := 0
		for r in results:
			if r["deaths"] > 0: deaths += 1
			if r["timeout"]: timeouts += 1
		for line in _diagnose_balance(avg, deaths, timeouts, results.size()):
			_log("  " + line)

	_log("")
	_log("총 소요 시간: %.1fs" % ((Time.get_ticks_msec() - _start_msec) / 1000.0))
	_write_log()
	get_tree().quit()


func _diagnose_balance(avg: Dictionary, deaths: int, timeouts: int, n: int) -> Array:
	var lines := []
	var survival_ratio: float = float(avg["survival_time"]) / _max_time
	var hits: float = float(avg["hits_taken"])
	var near_death: float = float(avg["near_death"])

	# 피격 기반 난이도 진단 (사망보다 정밀함)
	# 목표: EASY ~0-2피격, NORMAL ~2-5, HARD ~5+ (AI 기준, 인간은 더 많이 맞음)
	if hits < 1.0:
		lines.append("○ 매우 안전 (피격 %.1f): AI가 거의 안 맞음." % hits)
		if survival_ratio > 0.9 and deaths == 0:
			lines.append("  → EASY로서는 적절. NORMAL/HARD면 압박 증가 필요.")
	elif hits < 3.0:
		lines.append("✓ 약간의 압박 (피격 %.1f, 위험 %.1f): 양호한 난이도." % [hits, near_death])
	elif hits < 6.0:
		lines.append("✓ 높은 압박 (피격 %.1f, 위험 %.1f): 챌린징한 난이도." % [hits, near_death])
		if deaths == 0:
			lines.append("  → 사망 없이 생존하지만 긴장감 있음. 양호.")
	else:
		lines.append("⚠ 매우 높은 압박 (피격 %.1f, 위험 %.1f): 사망 위험 높음." % [hits, near_death])
		if deaths == 0:
			lines.append("  → 운 좋게 생존. 인간 플레이어는 사망 예상.")

	# 사망률 진단 (보조 지표)
	if survival_ratio > 0.9 and deaths == 0 and hits < 1.0:
		lines.append("  ⚠ 사망 0 + 피격 0 = 너무 쉬움.")

	# 웨이브 진행 속도
	if avg["max_wave"] < 3:
		lines.append("⚠ 웨이브 진행 느림 (avg %.1f): 너무 빨리 죽거나 적 부족." % avg["max_wave"])
	elif avg["max_wave"] > 12:
		lines.append("⚠ 웨이브 진행 빠름 (avg %.1f): 후반 난이도 상승 필요." % avg["max_wave"])
	else:
		lines.append("✓ 웨이브 진행 양호 (avg %.1f)." % avg["max_wave"])

	# 점수 대비 킬
	if avg["kills"] > 0:
		var score_per_kill: float = avg["score"] / max(avg["kills"], 1.0)
		lines.append("  킬당 평균 점수: %.1f" % score_per_kill)

	# 단어 완성률
	if avg["words_completed"] < 1:
		lines.append("⚠ 단어 완성 부족 (%.1f): 타겟 글자 적 출현 점검." % avg["words_completed"])
	else:
		lines.append("✓ 단어 완성 양호 (%.1f)." % avg["words_completed"])

	# 적 종류 분포
	var total: float = float(avg["kills"])
	if total > 0:
		lines.append("  적 분포: chaser %.0f%% shooter %.0f%% tank %.0f%%" % [
			float(avg["kills_chaser"]) / total * 100.0,
			float(avg["kills_shooter"]) / total * 100.0,
			float(avg["kills_tank"]) / total * 100.0,
		])

	return lines


func _save_json() -> void:
	var data := {
		"config": {
			"games_per_difficulty": _total_runs,
			"max_time": _max_time,
			"fast_mode": _fast_mode,
			"time_scale": _time_scale_target,
		},
		"results": _per_difficulty_results,
		"summary": {},
	}
	for diff in _per_difficulty_results.keys():
		var results: Array = _per_difficulty_results[diff]
		if not results.is_empty():
			data["summary"][diff] = _compute_avg(results)
	var f := FileAccess.open(JSON_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "  "))
		f.close()
		print("\nJSON 저장됨: " + JSON_PATH)


func _get_enemy_count() -> int:
	if not is_instance_valid(_game_scene):
		return 0
	return _game_scene.get_tree().get_nodes_in_group("enemy").size()


func _log(msg: String) -> void:
	print(msg)
	_log_lines.append(msg)


func _write_log() -> void:
	var f := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if f:
		f.store_string("\n".join(_log_lines) + "\n")
		f.close()
		print("\n로그 저장됨: " + LOG_PATH)