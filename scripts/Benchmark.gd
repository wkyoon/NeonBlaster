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
##   BENCH_AI_ERROR   - AI 회피 실패율 0.0~1.0 (기본 0.0). 인간 스킬 근사치.
##   BENCH_OUT        - 결과 파일 경로 prefix (기본 res://benchmark_results / res://benchmark_log)
##                      스윕 시 런마다 다른 값을 주어 결과 덮어쓰기를 방지한다.

const LOG_PATH := "res://benchmark_log.txt"
const JSON_PATH := "res://benchmark_results.json"

const DIFFS := ["EASY", "NORMAL", "HARD"]

## 평균/중앙값/최소/최대를 계산할 수치 지표. (difficulty·timeout 같은 비수치 키는 제외)
const METRIC_KEYS := [
	"survival_time", "max_wave", "kills", "kills_chaser", "kills_shooter", "kills_tank",
	"score", "words_completed", "powerups_collected", "hits_taken", "near_death",
	"alive_avg", "alive_max", "ttk_avg", "words_per_min", "weapon3_time",
]

## 난이도별 밸런스 목표. `hits`/`death_rate` 는 [최소, 최대] 허용 구간.
##
## 주의: 이 목표치는 **BENCH_AI_ERROR=0.15**(평균적인 인간 근사) 기준으로 정의되어 있다.
## 다른 오차값으로 측정하면 진단이 의미를 잃으므로 경고를 출력한다.
const TARGET_AI_ERROR := 0.15
## ⚠️ `hits` 는 GameManager.MAX_LIVES 에 사실상 붙는다(피격 1회 = 목숨 1개, 부활로 +1).
##    이전 목표의 HARD `hits 5~12` 는 목숨 3개 시절 설정이라 **도달 불가능**했다.
##    목숨 수를 바꾸면 이 목표도 반드시 함께 조정할 것.
##    또한 사망이 확실한 난이도에서 hits 는 사실상 목숨 수만 보고하므로 난이도 판별력이 없다.
##    (실측: HARD 5게임 중 4게임이 정확히 hits=5=MAX_LIVES, 1게임은 hits=10 이상치)
##    HARD 상한을 6.0 으로 넉넉히 둔 이유는 부활분과 이 이상치 때문이다.
##
## 목표 유저는 "속도감을 즐기고 너무 쉬우면 이탈하는" 층이다. 그래서 이전 목표
## (EASY 사망률 0~25%, NORMAL 20~55%)보다 전반적으로 상향했다.
## 특히 EASY 는 사망률 0%가 정상으로 판정되던 문제가 있었다 — 자극이 없으면 이탈한다.
const DIFFICULTY_TARGETS := {
	"EASY":   { "hits": [1.0, 3.0], "death_rate": [0.25, 0.45], "survival_ratio": 0.65 },
	"NORMAL": { "hits": [3.0, 5.0], "death_rate": [0.45, 0.75], "survival_ratio": 0.35 },
	"HARD":   { "hits": [4.0, 6.0], "death_rate": [0.75, 1.00], "survival_ratio": 0.15 },
}

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
var _seed_value: int = 42
var _log_path: String = LOG_PATH
var _json_path: String = JSON_PATH

# 런 단위 누적 상태 (동시 적 수 / 적 처치 소요시간)
var _alive_time_sum: float = 0.0     # ∫(적 수)dt — 시간가중 평균용
var _enemy_seen: Dictionary = {}     # instance_id -> 최초 관측 시각
var _ttk_sum: float = 0.0
var _ttk_count: int = 0


func _ready() -> void:
	_total_runs = int(_env_or("BENCH_GAMES", "3"))
	_max_time = float(_env_or("BENCH_TIME", "90"))
	var seed_str := _env_or("BENCH_SEED", "42")
	_seed_value = int(seed_str)
	seed(_seed_value)
	_fast_mode = _env_or("BENCH_FAST", "1") == "1"
	_time_scale_target = 3.0 if _fast_mode else 1.0
	Engine.time_scale = _time_scale_target

	# 스윕 시 런마다 결과 파일이 덮이지 않도록 경로를 분리할 수 있다.
	var out_prefix := _env_or("BENCH_OUT", "")
	if out_prefix != "":
		_json_path = out_prefix + ".json"
		_log_path = out_prefix + ".txt"

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

	# 동시 적 수를 시간가중으로 누적 (압박의 직접 원인 지표)
	var alive := _track_enemies()
	_alive_time_sum += float(alive) * delta
	_metrics["alive_max"] = max(int(_metrics["alive_max"]), alive)

	# 매 10초(시뮬레이션 시간)마다 진행 상황 로그
	if fmod(_elapsed, 10.0) < delta:
		_log("  [%.0fs][%s] wave=%d kills=%d score=%d alive=%d" % [
			_elapsed, _current_difficulty,
			_metrics["max_wave"],
			_metrics["kills"],
			GameManager.score,
			alive
		])

	if _elapsed >= _max_time:
		_log("  >> [%s] 시간 초과 - 생존 달성!" % _current_difficulty)
		_metrics["score"] = GameManager.score
		_end_run()


## 화면 내 적을 스캔해 개수를 돌려주고, 처음 본 적에는 TTK 측정을 연결한다.
## (처치 시각 - 최초 관측 시각 = 그 적을 없애는 데 걸린 시간)
func _track_enemies() -> int:
	var enemies := _game_scene.get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		var id := e.get_instance_id()
		if _enemy_seen.has(id):
			continue
		_enemy_seen[id] = _elapsed
		if e.has_signal("enemy_destroyed"):
			e.enemy_destroyed.connect(_on_tracked_enemy_destroyed.bind(id))
	return enemies.size()


func _on_tracked_enemy_destroyed(_points: int, id: int) -> void:
	if not _enemy_seen.has(id):
		return
	_ttk_sum += _elapsed - float(_enemy_seen[id])
	_ttk_count += 1
	_enemy_seen.erase(id)


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
	_alive_time_sum = 0.0
	_enemy_seen.clear()
	_ttk_sum = 0.0
	_ttk_count = 0
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
	# 파워업 획득 추적
	if _player and _player.has_signal("powerup_collected"):
		if _player.powerup_collected.is_connected(_on_powerup_collected):
			_player.powerup_collected.disconnect(_on_powerup_collected)
		_player.powerup_collected.connect(_on_powerup_collected)
	# 무기 레벨 추적 (3레벨 도달 시각 = 후반 화력 급증 시점)
	if _player and _player.has_signal("weapon_changed"):
		if _player.weapon_changed.is_connected(_on_weapon_changed):
			_player.weapon_changed.disconnect(_on_weapon_changed)
		_player.weapon_changed.connect(_on_weapon_changed)
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
		"alive_avg": 0.0,      # 시간가중 평균 동시 적 수
		"alive_max": 0,        # 최대 동시 적 수
		"ttk_avg": 0.0,        # 적 1마리 처치까지 평균 소요 시간(초)
		"words_per_min": 0.0,  # 분당 단어 완성 수 (학습 KPI)
		"weapon3_time": -1.0,  # 무기 3레벨 최초 도달 시각 (-1 = 미도달)
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


func _on_powerup_collected(_type: int) -> void:
	_metrics["powerups_collected"] += 1


func _on_weapon_changed(weapon_level: int) -> void:
	if weapon_level >= 3 and float(_metrics["weapon3_time"]) < 0.0:
		_metrics["weapon3_time"] = _elapsed
		_log("  ↑  [%s] 무기 3레벨 도달 (%.1fs)" % [_current_difficulty, _elapsed])


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
	# 파생 지표 확정
	if _elapsed > 0.0:
		_metrics["alive_avg"] = _alive_time_sum / _elapsed
		_metrics["words_per_min"] = float(_metrics["words_completed"]) / _elapsed * 60.0
	if _ttk_count > 0:
		_metrics["ttk_avg"] = _ttk_sum / float(_ttk_count)
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
	var st := _compute_stats(results)
	var avg: Dictionary = st["avg"]
	_log("\n" + "-".repeat(72))
	_log("[%s] 통계 (%d 게임) — 평균 [중앙값] (최소~최대)" % [diff, st["n"]])
	_log("-".repeat(72))
	_log("  생존:      %s / %.0fs" % [_fmt(st, "survival_time"), _max_time])
	_log("  피격:      %s   (위험상황 %s)" % [_fmt(st, "hits_taken"), _fmt(st, "near_death")])
	_log("  동시 적수:  %s   (최대 %s)" % [_fmt(st, "alive_avg"), _fmt(st, "alive_max")])
	_log("  처치시간:   %s초/마리" % _fmt(st, "ttk_avg"))
	_log("  킬:        %s (chaser:%.0f shooter:%.0f tank:%.0f)" % [
		_fmt(st, "kills"), avg["kills_chaser"], avg["kills_shooter"], avg["kills_tank"]
	])
	_log("  점수:      %s" % _fmt(st, "score"))
	_log("  단어:      %s개  (%s개/분)" % [_fmt(st, "words_completed"), _fmt(st, "words_per_min")])
	_log("  파워업:     %s개  (무기3레벨 도달 %s초, -1=미도달)" % [
		_fmt(st, "powerups_collected"), _fmt(st, "weapon3_time")
	])
	_log("  웨이브:     %s  ※ 시간 함수 (생존시간/웨이브길이) — 독립 지표 아님" % _fmt(st, "max_wave"))
	_log("  사망: %d/%d (%.0f%%) | 생존(시간초과): %d/%d" % [
		st["deaths"], st["n"], float(st["death_rate"]) * 100.0, st["timeouts"], st["n"]
	])


## "평균 [중앙값] (최소~최대)" 형태로 지표 하나를 포맷.
func _fmt(st: Dictionary, key: String) -> String:
	return "%.1f [%.1f] (%.1f~%.1f)" % [
		st["avg"][key], st["med"][key], st["min"][key], st["max"][key]
	]


## 수치 지표의 평균/중앙값/최소/최대 + 사망률/생존율을 계산한다.
##
## 이전 구현은 `_new_metrics()` 를 합계의 시작점으로 써서 `max_wave` 초기값 1이
## 합계에 더해졌고(평균 +1/n 편향), 키 목록에서 빠진 지표는 초기값이 그대로
## 결과처럼 보였다. 0에서 누적하고 METRIC_KEYS 전체를 다룬다.
func _compute_stats(results: Array) -> Dictionary:
	var n := results.size()
	var avg := {}
	var med := {}
	var lo := {}
	var hi := {}
	for key in METRIC_KEYS:
		var values: Array[float] = []
		for r in results:
			values.append(float(r[key]))
		values.sort()
		var total := 0.0
		for v in values:
			total += v
		avg[key] = total / float(n)
		med[key] = _median(values)
		lo[key] = values[0]
		hi[key] = values[n - 1]
	var deaths := 0
	var timeouts := 0
	for r in results:
		if int(r["deaths"]) > 0:
			deaths += 1
		if bool(r["timeout"]):
			timeouts += 1
	return {
		"n": n,
		"deaths": deaths,
		"death_rate": float(deaths) / float(n),
		"timeouts": timeouts,
		"timeout_rate": float(timeouts) / float(n),
		"avg": avg,
		"med": med,
		"min": lo,
		"max": hi,
	}


func _median(sorted_values: Array[float]) -> float:
	var n := sorted_values.size()
	if n == 0:
		return 0.0
	if n % 2 == 1:
		return sorted_values[n / 2]
	return (sorted_values[n / 2 - 1] + sorted_values[n / 2]) * 0.5


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
	if absf(GameManager.ai_dodge_error - TARGET_AI_ERROR) > 0.001:
		_log("⚠ 목표치는 BENCH_AI_ERROR=%.2f 기준입니다. 현재 %.2f — 판정을 그대로 신뢰하지 마세요." % [
			TARGET_AI_ERROR, GameManager.ai_dodge_error
		])
	if _total_runs < 5:
		_log("⚠ 난이도당 %d게임은 분산이 커서 판정이 불안정합니다 (권장 5게임 이상 + 다중 시드)." % _total_runs)
	for diff in DIFFS:
		if not _per_difficulty_results.has(diff):
			continue
		var results: Array = _per_difficulty_results[diff]
		if results.is_empty():
			continue
		_log("")
		_log("[%s]" % diff)
		for line in _diagnose_balance(diff, _compute_stats(results)):
			_log("  " + line)

	_log("")
	_log("총 소요 시간: %.1fs" % ((Time.get_ticks_msec() - _start_msec) / 1000.0))
	_write_log()
	get_tree().quit()


## 난이도별 목표치와 비교해 PASS/FAIL 판정과 조정할 노브를 제시한다.
##
## 노브는 모두 EnemySpawner.DIFFICULTY_MULTIPLIERS 에 모여 있다:
##   spawn_interval(작을수록 촘촘) / enemy_hp / enemy_speed / wave_duration / bullet_speed
## 한 번에 하나만 바꾸고 동일 시드셋으로 재측정할 것.
func _diagnose_balance(diff: String, st: Dictionary) -> Array:
	var lines: Array[String] = []
	var target: Dictionary = DIFFICULTY_TARGETS.get(diff, DIFFICULTY_TARGETS["NORMAL"])
	var avg: Dictionary = st["avg"]
	var hits := float(avg["hits_taken"])
	var death_rate := float(st["death_rate"])
	var survival_ratio := float(avg["survival_time"]) / _max_time
	var hits_lo := float(target["hits"][0])
	var hits_hi := float(target["hits"][1])
	var dr_lo := float(target["death_rate"][0])
	var dr_hi := float(target["death_rate"][1])
	var sr_min := float(target["survival_ratio"])

	# --- 1) 압박: 피격 횟수 ---
	if hits < hits_lo:
		lines.append("✗ 압박 부족 — 피격 %.1f, 목표 %.1f~%.1f" % [hits, hits_lo, hits_hi])
		lines.append("  → spawn_interval 낮추거나(적 더 촘촘) bullet_speed 올릴 것")
	elif hits > hits_hi:
		lines.append("✗ 압박 과다 — 피격 %.1f, 목표 %.1f~%.1f" % [hits, hits_lo, hits_hi])
		lines.append("  → spawn_interval 올리거나 enemy_speed 낮출 것")
	else:
		lines.append("✓ 압박 적정 — 피격 %.1f (목표 %.1f~%.1f), 위험상황 %.1f회" % [
			hits, hits_lo, hits_hi, avg["near_death"]
		])

	# --- 2) 사망률 ---
	if death_rate < dr_lo:
		lines.append("✗ 너무 관대 — 사망률 %.0f%%, 목표 %.0f~%.0f%%" % [
			death_rate * 100.0, dr_lo * 100.0, dr_hi * 100.0
		])
	elif death_rate > dr_hi:
		lines.append("✗ 너무 가혹 — 사망률 %.0f%%, 목표 %.0f~%.0f%%" % [
			death_rate * 100.0, dr_lo * 100.0, dr_hi * 100.0
		])
	else:
		lines.append("✓ 사망률 적정 — %.0f%% (목표 %.0f~%.0f%%)" % [
			death_rate * 100.0, dr_lo * 100.0, dr_hi * 100.0
		])

	# --- 3) 생존 길이 ---
	if survival_ratio < sr_min:
		lines.append("✗ 생존 짧음 — 제한시간의 %.0f%%, 목표 %.0f%% 이상" % [
			survival_ratio * 100.0, sr_min * 100.0
		])
		if float(avg["ttk_avg"]) > 3.0:
			lines.append("  → 처치시간 %.1f초/마리로 김. enemy_hp 낮춰 화력 회전 개선" % avg["ttk_avg"])
		else:
			lines.append("  → spawn_interval 올려 동시 압박 완화")
	else:
		lines.append("✓ 생존 길이 적정 — 제한시간의 %.0f%% (목표 %.0f%% 이상)" % [
			survival_ratio * 100.0, sr_min * 100.0
		])

	# --- 4) 표본 신뢰도: 스프레드가 평균만큼 크면 판정 자체가 불안정 ---
	var spread := float(st["max"]["survival_time"]) - float(st["min"]["survival_time"])
	if st["n"] > 1 and spread > float(avg["survival_time"]):
		lines.append("⚠ 생존시간 스프레드 %.0fs > 평균 %.0fs — 표본 부족. 게임 수/시드를 늘릴 것" % [
			spread, avg["survival_time"]
		])

	# --- 5) 참고 지표 ---
	lines.append("  동시 적수 %.1f (최대 %.0f) | 처치시간 %.1f초/마리" % [
		avg["alive_avg"], avg["alive_max"], avg["ttk_avg"]
	])
	if float(avg["words_per_min"]) < 1.0:
		lines.append("⚠ 학습 진도 느림 — %.1f단어/분. 타겟 글자 적 출현률 점검" % avg["words_per_min"])
	else:
		lines.append("  학습 진도 %.1f단어/분 (총 %.1f개)" % [avg["words_per_min"], avg["words_completed"]])
	var w3 := float(avg["weapon3_time"])
	if w3 >= 0.0:
		lines.append("  파워업 %.1f개 | 무기3레벨 %.0fs에 도달 — 이후 화력 급증 구간" % [
			avg["powerups_collected"], w3
		])
	else:
		lines.append("  파워업 %.1f개 | 무기3레벨 미도달" % avg["powerups_collected"])
	var kills := float(avg["kills"])
	if kills > 0.0:
		lines.append("  킬 %.1f (킬당 %.1f점) | 적 분포 chaser %.0f%% shooter %.0f%% tank %.0f%%" % [
			kills, float(avg["score"]) / kills,
			float(avg["kills_chaser"]) / kills * 100.0,
			float(avg["kills_shooter"]) / kills * 100.0,
			float(avg["kills_tank"]) / kills * 100.0,
		])

	return lines


func _save_json() -> void:
	var data := {
		"config": {
			"games_per_difficulty": _total_runs,
			"max_time": _max_time,
			"fast_mode": _fast_mode,
			"time_scale": _time_scale_target,
			"seed": _seed_value,
			"ai_dodge_error": GameManager.ai_dodge_error,
			"target_ai_error": TARGET_AI_ERROR,
			"targets": DIFFICULTY_TARGETS,
		},
		"results": _per_difficulty_results,
		"summary": {},
	}
	for diff in _per_difficulty_results.keys():
		var results: Array = _per_difficulty_results[diff]
		if not results.is_empty():
			data["summary"][diff] = _compute_stats(results)
	var f := FileAccess.open(_json_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "  "))
		f.close()
		print("\nJSON 저장됨: " + _json_path)


func _get_enemy_count() -> int:
	if not is_instance_valid(_game_scene):
		return 0
	return _game_scene.get_tree().get_nodes_in_group("enemy").size()


func _log(msg: String) -> void:
	print(msg)
	_log_lines.append(msg)


func _write_log() -> void:
	var f := FileAccess.open(_log_path, FileAccess.WRITE)
	if f:
		f.store_string("\n".join(_log_lines) + "\n")
		f.close()
		print("\n로그 저장됨: " + _log_path)