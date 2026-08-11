extends Node2D
## EnemySpawner - manages enemy wave spawning with increasing difficulty.

signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_killed(enemy_type: int, points: int)

## ⚠️ 이 네 값은 Game.tscn 의 EnemySpawner 노드가 **덮어쓴다**.
## 여기만 고치면 게임에 반영되지 않는다 — 반드시 Game.tscn 값도 같이 수정할 것.
@export var initial_spawn_interval: float = 1.1
@export var min_spawn_interval: float = 0.16
## ⚠️ 더 이상 쓰지 않는다. 난이도 램프는 DifficultyDirector 가 경과 시간으로 만든다.
## (Game.tscn 이 이 @export 를 덮어쓰고 있으므로 선언은 남겨 둔다.)
@export var difficulty_scale: float = 0.91
@export var wave_duration: float = 11.0
## 적 체력 가산에 쓰이는 웨이브 상한. 이 위로는 더 단단해지지 않는다.
const MAX_STAT_WAVE := 8

## 스포너 배수. 난이도는 **플레이어가 고르지 않고** DifficultyDirector 가 맞춘다.
## 조절 폭과 튜닝 기록은 그쪽에 모여 있다(CALM ~ INTENSE 보간).
##
## ⚠️ 예전에는 EASY/NORMAL/HARD 를 여기서 분기했는데, 틈새 시간용 게임에
##    난이도 선택이 맞지 않았다 — 켤 때마다 판단을 요구하고, 해금할수록 더 자주 죽어
##    보상이 벌처럼 느껴졌다(실측 사망률 EASY 0% → HARD 50%).
func _get_diff_mult() -> Dictionary:
	return DifficultyDirector.get_multipliers()


var _enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
var _spawn_timer: float = 0.0
var _wave_timer: float = 0.0
var _current_wave: int = 1
var _enemies_alive: int = 0
var _screen_size: Vector2
var _is_active: bool = false


func _ready() -> void:
	_screen_size = get_viewport_rect().size
	stop()


func start() -> void:
	_current_wave = 1
	_spawn_timer = 1.0  # first spawn after 1s
	_wave_timer = 0.0
	_is_active = true


func stop() -> void:
	_is_active = false


func _process(delta: float) -> void:
	if not _is_active:
		return
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_enemy()
		_spawn_timer = _current_spawn_interval()

	_wave_timer += delta
	var dm := _get_diff_mult()
	var effective_wave_duration: float = wave_duration * float(dm["wave_duration"])
	if _wave_timer >= effective_wave_duration:
		_next_wave()


func _spawn_enemy() -> void:
	var enemy: Enemy = _enemy_scene.instantiate()
	var type: Enemy.EnemyType = _pick_enemy_type()
	# ⚠️ 웨이브 기반 체력 가산에는 상한이 필요하다. 목표가 10분이면 웨이브가 50을 넘어
	#    체력이 끝없이 불어난다(예전엔 90초 판이라 웨이브 8이 최대였다).
	#    시간에 따른 난이도 상승은 DifficultyDirector 가 담당한다.
	var wave := mini(_current_wave, MAX_STAT_WAVE)
	_apply_stats(enemy, type, wave)
	# Assign a letter from WordManager (target letter or random decoy)
	# 타겟 글자가 붙어 나올 확률. 0.3 은 첫 단어 완성이 34.8초까지 늘어져 학습 루프가 느렸다.
	enemy.letter = WordManager.get_random_letter(0.45)
	_place_and_register(enemy, type, wave)


## 종류별 스탯 + 난이도 배수. ⚠️ 군체는 여러 마리를 만들므로 **한 곳에 모여 있어야** 한다 —
## 흩어져 있으면 무리의 뒤쪽만 다른 능력치를 갖게 된다.
## ⚠️ **적 연사는 이 게임에서 가장 강한 치사율 노브다.** 기체 범위를 묶고 사거리를 줄이자
## 적이 2~7초를 살아 남아 적 탄이 4.8 → 7.4발/초로 늘었고, 그게 곧 사망 원인이 됐다.
## ⚠️ 적 **속도**를 낮추는 것으로 대신하려 하지 말 것 — 느려진 적이 화면에 더 오래 남아
##    밀도와 탄이 함께 늘어 오히려 어려워진다(실측 NORMAL 77%→67%, HARD 60%→49%).
func _apply_stats(enemy: Enemy, type: Enemy.EnemyType, wave: int) -> void:
	enemy.enemy_type = type

	match type:
		Enemy.EnemyType.CHASER:
			enemy.max_health = 1 + wave / 5
			enemy.move_speed = randf_range(160.0, 230.0)
			enemy.score_value = 10
		Enemy.EnemyType.SHOOTER:
			enemy.max_health = 2 + wave / 4
			enemy.move_speed = randf_range(130.0, 180.0)
			enemy.fire_rate = randf_range(0.53, 0.98)
			enemy.score_value = 20
		Enemy.EnemyType.TANK:
			enemy.max_health = 5 + wave / 2
			enemy.move_speed = randf_range(90.0, 130.0)
			enemy.fire_rate = randf_range(0.22, 0.44)
			enemy.score_value = 50
		Enemy.EnemyType.DASHER:
			# 빠른 지그재그 돌진형 - 체력 낮음, 속도 매우 빠름
			enemy.max_health = 1 + wave / 6
			enemy.move_speed = randf_range(250.0, 330.0)
			enemy.score_value = 15
		Enemy.EnemyType.BOMBER:
			# 자폭형 - 체력 보통, 보통 속도
			enemy.max_health = 2 + wave / 5
			enemy.move_speed = randf_range(140.0, 190.0)
			enemy.score_value = 25
		Enemy.EnemyType.SPLITTER:
			# 분열형 - 체력 높음 (죽으면 3마리로 분열)
			enemy.max_health = 3 + wave / 3
			enemy.move_speed = randf_range(100.0, 140.0)
			enemy.score_value = 30
		Enemy.EnemyType.SHIELDER:
			# 쉴드형 - 체력 매우 높음, 재생, 원형 탄막
			enemy.max_health = 6 + wave / 2
			enemy.move_speed = randf_range(90.0, 130.0)
			enemy.fire_rate = randf_range(0.26, 0.44)
			enemy.score_value = 40
		Enemy.EnemyType.SWARM:
			# 군체 - 한 마리는 약하다. 여럿이 한 번에 나오는 것이 위협이다.
			enemy.max_health = 1
			enemy.move_speed = randf_range(150.0, 190.0)
			enemy.score_value = 5
		Enemy.EnemyType.TURRET:
			# 포탑 - 멈춰 서서 버틴다. 체력이 곧 수명이다.
			# ⚠️ 정지선까지 살아서 가야 정체성이 발현된다. 체력이 곧 그 조건이다.
			enemy.max_health = 9 + wave / 2
			enemy.move_speed = randf_range(140.0, 180.0)
			enemy.fire_rate = randf_range(0.35, 0.58)
			enemy.score_value = 45
		Enemy.EnemyType.PHANTOM:
			# 환영 - 절반은 무적이라 실효 체력이 두 배다. 표기 체력은 낮게 둔다.
			enemy.max_health = 2 + wave / 5
			enemy.move_speed = randf_range(120.0, 160.0)
			enemy.score_value = 35

	# 난이도 배수 적용 (체력/속도/총알속도)
	var dm := _get_diff_mult()
	enemy.max_health = max(1, int(round(enemy.max_health * float(dm["enemy_hp"]))))
	# 화면 높이 보정: 세로가 긴 기기에서 적이 화면을 지나는 시간이 같아지도록
	# 픽셀 속도를 높이에 비례시킨다(GameManager.screen_speed_scale 주석 참조).
	var hs := GameManager.screen_speed_scale()
	enemy.move_speed *= float(dm["enemy_speed"]) * hs
	enemy.bullet_speed *= float(dm["bullet_speed"]) * hs


func _place_and_register(enemy: Enemy, type: Enemy.EnemyType, wave: int) -> void:
	# Spawn position: top edge, random X
	enemy.global_position = Vector2(randf_range(60, _screen_size.x - 60), -50)
	_register(enemy, type)

	# ⚠️ 군체는 **한 마리가 아니라 한 무리**다. 혼자 나오면 그냥 약한 적이라
	#    다른 종류와 구분되지 않는다. 위 개체를 무리의 중심으로 삼아 나머지를 붙인다.
	if type == Enemy.EnemyType.SWARM:
		_spawn_swarm_mates(enemy, wave)


## 무리의 나머지를 중심 좌우로 V 대형으로 붙인다.
func _spawn_swarm_mates(leader: Enemy, wave: int) -> void:
	var cx: float = leader.global_position.x
	for i in range(1, Enemy.SWARM_COUNT):
		var side := 1.0 if i % 2 == 1 else -1.0
		var step := float((i + 1) / 2)
		var mate: Enemy = _enemy_scene.instantiate()
		mate.enemy_type = Enemy.EnemyType.SWARM
		_apply_stats(mate, Enemy.EnemyType.SWARM, wave)
		mate.letter = WordManager.get_random_letter(0.45)
		mate.global_position = Vector2(
			clampf(cx + side * step * 52.0, 40.0, _screen_size.x - 40.0),
			-50.0 - step * 46.0)
		_register(mate, Enemy.EnemyType.SWARM)


## 화면에 올리고 처치 신호를 잇는다.
func _register(enemy: Enemy, type: Enemy.EnemyType) -> void:
	get_tree().current_scene.add_child(enemy)
	_enemies_alive += 1
	# Pass enemy_type via lambda so spawner can emit a typed kill signal
	var captured_type: int = int(type)
	enemy.enemy_destroyed.connect(func(points: int) -> void:
		_on_enemy_destroyed(points)
		enemy_killed.emit(captured_type, points)
	)


func _pick_enemy_type() -> Enemy.EnemyType:
	var roll := randf()
	var w := float(_current_wave)

	# 웨이브 기반 확률 분포 (누적)
	# 고급 적일수록 뒷부분에 등장, 상한선 존재
	# ⚠️ 상한의 합이 1을 넘으면 뒤쪽 종류가 영영 안 나온다. 10종 기준 합 0.89(나머지 CHASER).
	var tank_chance: float = clampf(0.04 + w * 0.016, 0.04, 0.12)
	var shooter_chance: float = clampf(0.12 + w * 0.02, 0.12, 0.20)
	var dasher_chance: float = clampf(0.04 + w * 0.016, 0.04, 0.12)
	var bomber_chance: float = clampf(0.03 + w * 0.012, 0.03, 0.10)
	var splitter_chance: float = clampf(0.02 + w * 0.010, 0.02, 0.08)
	var shielder_chance: float = clampf(0.02 + w * 0.008, 0.02, 0.07)
	# ⚠️ 군체는 한 번 뽑히면 SWARM_COUNT 마리가 나온다. 확률을 다른 종류와 같게 두면
	#    화면이 노란 마름모로 뒤덮인다 — 낮게 잡을 것.
	#    실측: 확률 0.05 로 뒀더니 **개체 비중이 22.4%** 가 됐다(한 번에 5마리이므로).
	var swarm_chance: float = clampf(0.008 + w * 0.002, 0.008, 0.022)
	var turret_chance: float = clampf(0.02 + w * 0.008, 0.02, 0.07)
	var phantom_chance: float = clampf(0.02 + w * 0.008, 0.02, 0.07)

	var cumulative := 0.0
	cumulative += tank_chance
	if roll < cumulative:
		return Enemy.EnemyType.TANK
	cumulative += shooter_chance
	if roll < cumulative:
		return Enemy.EnemyType.SHOOTER
	cumulative += dasher_chance
	if roll < cumulative:
		return Enemy.EnemyType.DASHER
	cumulative += bomber_chance
	if roll < cumulative:
		return Enemy.EnemyType.BOMBER
	cumulative += splitter_chance
	if roll < cumulative:
		return Enemy.EnemyType.SPLITTER
	cumulative += shielder_chance
	if roll < cumulative:
		return Enemy.EnemyType.SHIELDER
	cumulative += swarm_chance
	if roll < cumulative:
		return Enemy.EnemyType.SWARM
	cumulative += turret_chance
	if roll < cumulative:
		return Enemy.EnemyType.TURRET
	cumulative += phantom_chance
	if roll < cumulative:
		return Enemy.EnemyType.PHANTOM
	# 나머지는 CHASER (가장 흔한 기본 적)
	return Enemy.EnemyType.CHASER


## 지금 이 순간의 스폰 간격. **경과 시간에 따라 매번 다시 계산한다.**
##
## ⚠️ 예전에는 웨이브마다 `_spawn_interval *= difficulty_scale`(0.91) 로 누적했다.
##    그 램프는 90초짜리 판 기준이라, 목표가 10분으로 늘어난 지금은 폭주한다
##    (웨이브 11초 × 55웨이브 → 0.91^54 ≈ 0.006, 사실상 무한 스폰).
##    난이도 곡선의 주인은 DifficultyDirector 하나뿐이어야 한다.
func _current_spawn_interval() -> float:
	var dm := _get_diff_mult()
	return maxf(min_spawn_interval, initial_spawn_interval * float(dm["spawn_interval"]))


func _next_wave() -> void:
	wave_cleared.emit(_current_wave)
	_current_wave += 1
	_wave_timer = 0.0
	wave_started.emit(_current_wave)
	# Bonus score for wave clear
	GameManager.add_score(_current_wave * 5)


func _on_enemy_destroyed(_points: int) -> void:
	_enemies_alive = max(0, _enemies_alive - 1)


func get_current_wave() -> int:
	return _current_wave


func get_enemies_alive() -> int:
	return _enemies_alive