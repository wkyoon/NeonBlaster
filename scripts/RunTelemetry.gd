extends Node
## RunTelemetry — 한 판의 밸런스 지표를 모아 `Telemetry` 큐에 넣는다.
##
## ⚠️ **`Benchmark.gd` 와 별개여야 한다.** 벤치마크는 릴리스 프리셋의 `exclude_filter` 로
##    빠지므로, 알파 테스터가 받는 빌드에는 아예 존재하지 않는다.
##    대신 **지표 이름은 벤치마크와 똑같이** 쓴다 — 갈라지면 두 자료를 같은 리포트에서 못 본다.
##
## ⚠️ **`end_reason` 이 이 파일에서 가장 중요한 값이다.**
##    AI 벤치마크는 사망률 100% 지만 사람은 지하철에서 내리면서 그냥 끈다.
##    중도 이탈 판의 생존 시간을 사망 판과 같이 평균 내면 "너무 어렵다" 로 잘못 읽힌다.
##    분석에서 반드시 갈라 봐야 하므로 여기서 정확히 남긴다.
##
## ⚠️ 판이 끝나는 경로가 여러 개다(사망 → 메뉴 / 사망 → 재시작 / 뒤로 가기 / 홈 버튼).
##    그래서 개별 경로에 붙이지 않고 **씬에서 빠질 때**(`_exit_tree`)와
##    **앱이 백그라운드로 갈 때** 두 곳에서만 마감한다. 하나라도 빠지면 판이 통째로 사라진다.

## 시계열 표본 간격. 30분 판이 60줄이라 크기가 문제되지 않고,
## `DifficultyDirector` 의 밀도 곡선(DENSITY_SHAPE / RUSH_PERIOD)을 직접 검증할 수 있다.
const SAMPLE_INTERVAL := 30.0

var _elapsed: float = 0.0
var _recorded: bool = false
var _died: bool = false
var _sample_timer: float = 0.0

var _kills: int = 0
var _kills_chaser: int = 0
var _kills_shooter: int = 0
var _kills_tank: int = 0
var _hits_taken: int = 0
var _near_death: int = 0
var _max_wave: int = 1
var _words_completed: int = 0
var _words_new: int = 0
var _powerups: int = 0

## 동시 적 수의 시간가중 합. 압박은 이 값(alive_avg)으로 본다 —
## 피격 수는 목숨 5개에서 포화돼 난이도 판별력이 없다(AGENTS.md 참조).
var _alive_time_sum: float = 0.0
var _alive_max: int = 0

## 프레임 성능. 글로우는 모바일에서 fill-rate 비용이 있는데
## 헤드리스 벤치마크는 렌더를 안 하므로 실기기 자료로만 확인할 수 있다.
var _fps_samples: PackedFloat32Array = PackedFloat32Array()
var _fps_accum: float = 0.0

var _samples: Array = []

var _player: Node = null
var _spawner: Node = null


func start(player: Node, spawner: Node) -> void:
	# ⚠️ **AI 플레이는 사람 자료가 아니다.** `Benchmark` 는 이 `Game.tscn` 을 그대로 띄우므로
	#    막지 않으면 벤치마크 수백 판이 알파 자료에 섞여 들어간다(메뉴의 AUTO 토글도 마찬가지).
	#    섞이면 실력 분포가 통째로 거짓이 되고, 그걸 근거로 BENCH_AI_ERROR 를 보정하면
	#    AI 가 AI 를 기준으로 자기를 맞추는 순환이 된다.
	if GameManager.auto_play:
		_recorded = true
		set_process(false)
		return
	_player = player
	_spawner = spawner
	if _player != null:
		if _player.has_signal("player_hit"):
			_player.player_hit.connect(_on_player_hit)
		if _player.has_signal("player_died"):
			_player.player_died.connect(_on_player_died)
		if _player.has_signal("powerup_collected"):
			_player.powerup_collected.connect(func(_t): _powerups += 1)
	if _spawner != null:
		if _spawner.has_signal("wave_started"):
			_spawner.wave_started.connect(func(w: int): _max_wave = maxi(_max_wave, w))
		if _spawner.has_signal("enemy_killed"):
			_spawner.enemy_killed.connect(_on_enemy_killed)
	WordManager.word_completed.connect(func(_w): _words_completed += 1)
	WordManager.word_collected.connect(func(_w, _t, _g): _words_new += 1)
	set_process(true)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	_elapsed += delta
	var alive := get_tree().get_nodes_in_group("enemy").size()
	_alive_time_sum += float(alive) * delta
	_alive_max = maxi(_alive_max, alive)
	_fps_accum += delta
	if _fps_accum >= 1.0:
		_fps_accum = 0.0
		_fps_samples.append(float(Engine.get_frames_per_second()))
	_sample_timer += delta
	if _sample_timer >= SAMPLE_INTERVAL:
		_sample_timer = 0.0
		_samples.append([
			int(_elapsed), alive, GameManager.lives, GameManager.score, _words_completed,
		])


func _notification(what: int) -> void:
	# 홈 버튼·전화 수신 등으로 앱이 내려가면 그 뒤 시간은 밸런스 자료로 못 쓴다.
	# 여기서 마감하고 사유를 남긴다(분석에서 제외된다).
	if what == NOTIFICATION_APPLICATION_PAUSED:
		_finalize("background")


func _exit_tree() -> void:
	_finalize("")


func _on_player_hit() -> void:
	_hits_taken += 1
	if GameManager.lives <= 1:
		_near_death += 1


func _on_player_died() -> void:
	_died = true


func _on_enemy_killed(enemy_type: int, _points: int) -> void:
	_kills += 1
	match enemy_type:
		0: _kills_chaser += 1
		1: _kills_shooter += 1
		2: _kills_tank += 1


## `reason` 이 비어 있으면 상태에서 추론한다.
func _finalize(reason: String) -> void:
	if _recorded or _elapsed < 5.0:
		# 5초 미만은 잘못 눌러 들어온 판이다. 평균을 흐리므로 버린다.
		_recorded = true
		return
	_recorded = true
	set_process(false)
	var target: float = DifficultyDirector.get_target_seconds()
	if reason == "":
		if _died:
			reason = "died"
		elif _elapsed >= target:
			reason = "survived"
		else:
			reason = "quit"
	var progress: Vector2i = WordManager.get_collection_progress()
	Telemetry.record_run({
		# --- 상황: 어느 지점의 플레이인가 (없으면 비교 자체가 불가능하다) ---
		"bonus_minutes": DifficultyDirector.bonus_minutes,
		"target_seconds": target,
		"rank": RewardManager.get_rank(),
		"reward_power": GameManager.reward_power,
		"skin": String(RewardManager.get_equipped_skin().get("id", "")),
		"total_play_seconds": int(RewardManager.total_seconds),
		"collected": progress.x,
		"collect_goal": progress.y,
		# --- 결과 ---
		"end_reason": reason,
		"survival_time": _elapsed,
		"survival_ratio": (_elapsed / target) if target > 0.0 else 0.0,
		"score": GameManager.score,
		"revives_used": GameManager.revives_used,
		# --- 압박 ---
		"alive_avg": (_alive_time_sum / _elapsed) if _elapsed > 0.0 else 0.0,
		"alive_max": _alive_max,
		"hits_taken": _hits_taken,
		"near_death": _near_death,
		"max_wave": _max_wave,
		"kills": _kills,
		"kills_chaser": _kills_chaser,
		"kills_shooter": _kills_shooter,
		"kills_tank": _kills_tank,
		# --- 학습(본체) ---
		"words_completed": _words_completed,
		"words_new": _words_new,
		"words_per_min": (_words_completed / (_elapsed / 60.0)) if _elapsed > 0.0 else 0.0,
		"powerups_collected": _powerups,
		# --- 성능: 글로우 fill-rate 는 헤드리스로 검증할 수 없다 ---
		"fps_avg": _fps_avg(),
		"fps_p10": _fps_p10(),
		# --- 시계열: [경과, 동시적, 목숨, 점수, 완성단어] ---
		"samples": _samples,
	})


func _fps_avg() -> float:
	if _fps_samples.is_empty():
		return 0.0
	var sum := 0.0
	for v in _fps_samples:
		sum += v
	return sum / float(_fps_samples.size())


## 하위 10% 프레임. 평균만 보면 "가끔 뚝 끊긴다" 를 놓친다.
func _fps_p10() -> float:
	if _fps_samples.is_empty():
		return 0.0
	var arr := Array(_fps_samples)
	arr.sort()
	var idx := int(floor(float(arr.size()) * 0.1))
	return float(arr[clampi(idx, 0, arr.size() - 1)])
