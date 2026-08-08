extends Node2D
## EnemySpawner - manages enemy wave spawning with increasing difficulty.

signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_killed(enemy_type: int, points: int)

## ⚠️ 이 네 값은 Game.tscn 의 EnemySpawner 노드가 **덮어쓴다**.
## 여기만 고치면 게임에 반영되지 않는다 — 반드시 Game.tscn 값도 같이 수정할 것.
@export var initial_spawn_interval: float = 1.1
@export var min_spawn_interval: float = 0.3
@export var difficulty_scale: float = 0.91  # 웨이브당 스폰 간격 배수 (작을수록 빠른 램프)
@export var wave_duration: float = 11.0

# 난이도별 배수 (WordManager.current_difficulty 기반)
# spawn_interval: 스폰 간격 배수 (작을수록 빈번)
# enemy_hp: 적 체력 배수
# enemy_speed: 적 속도 배수
# wave_duration: 웨이브 지속시간 배수 (작을수록 빠른 웨이브 진행)
func _get_diff_mult() -> Dictionary:
	match WordManager.current_difficulty:
		WordManager.Difficulty.EASY:
			# EASY 는 **랭크 0 = 신규 플레이어가 처음 만나는 판**이다. 여기서 잘한다고 느껴야
			# NORMAL/HARD 를 열고 싶어진다(난이도 해금은 RewardManager.DIFFICULTY_RANK).
			# 목표 사망률 0~15%.
			#
			# ⚠️ 예전 값(spawn 0.62 / hp 0.5)은 **"EASY 도 방심하면 죽어야 한다(목표 45%)"**
			#    시절의 튜닝이다. 이후 "잘하는 것처럼 느끼게" 방향으로 바뀌며 목표가 0~15% 로
			#    내려갔는데 배수는 그대로여서 실측 사망률이 40% 였다.
			# ⚠️ hp 0.5 는 NORMAL(0.45)보다 **높아 역전**이었다. EASY 적이 더 단단해
			#    처치시간 1.6초(NORMAL 1.4초)로 잔존이 늘고 동시 적 수까지 EASY 가 더 많았다.
			#
			# 튜닝 기록 (전부 오차 0.15·fixed-fps·해금 랭크 측정):
			#  · 적 속도 상향(0.85→1.05)은 실패. 적이 화면을 빨리 지나가 잔존이 줄어
			#    밀도가 떨어지면서 위협 증가분이 상쇄됐다. 0.85 유지.
			#  · 적 탄속은 계단형 응답이라 미세 조정에 못 쓴다(0.85→13% / 0.90→53%).
			# 실측(10게임·오차0.15·랭크0): 동시 적 3.1 / 사망률 0% / 생존 100% / 4.6단어분
			return {"spawn_interval": 0.85, "enemy_hp": 0.38, "enemy_speed": 0.85, "wave_duration": 1.25, "bullet_speed": 0.80}
		WordManager.Difficulty.NORMAL:
			# NORMAL 은 랭크 1(영구 화력 +6%)에서 열린다. 목표 사망률 10~35%.
			# 압박(동시 적)은 이미 목표 안이었고 사망률만 60% 로 과다했다 →
			# 밀도는 두고 **치사율**(적 탄속)만 낮춘다. 그 뒤 밀도로 미세 조정했는데
			# 밀도 응답이 매우 가파르다: spawn_interval 0.58→0% / 0.53→43% / 0.48→80%.
			# 0.56 이 목표 구간 한가운데다.
			# 실측(10게임·오차0.15·랭크1): 동시 적 3.7 / 사망률 20% / 생존 92% / 6.6단어분
			return {"spawn_interval": 0.56, "enemy_hp": 0.45, "enemy_speed": 1.0, "wave_duration": 1.0, "bullet_speed": 0.90}
		WordManager.Difficulty.HARD:
			# HARD 는 랭크 2(영구 화력 +12%)에서 열린다. 목표 사망률 35~70%.
			# 밀도가 아니라 속도·체력으로 어려워야 한다. 실측 100% 였으므로
			# 탄속과 적 속도를 함께 내려 치사율만 낮춘다(압박은 목표 안이었다).
			# 실측(10게임·오차0.15·랭크2): 동시 적 4.4 / 사망률 50% / 생존 83% / 7.0단어분
			return {"spawn_interval": 0.52, "enemy_hp": 0.6, "enemy_speed": 1.15, "wave_duration": 0.8, "bullet_speed": 1.0}
	return {"spawn_interval": 1.0, "enemy_hp": 1.0, "enemy_speed": 1.0, "wave_duration": 1.0, "bullet_speed": 1.0}

var _enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
var _spawn_timer: float = 0.0
var _spawn_interval: float = 2.0
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
	var dm := _get_diff_mult()
	_spawn_interval = initial_spawn_interval * float(dm["spawn_interval"])
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
		_spawn_timer = _spawn_interval

	_wave_timer += delta
	var dm := _get_diff_mult()
	var effective_wave_duration: float = wave_duration * float(dm["wave_duration"])
	if _wave_timer >= effective_wave_duration:
		_next_wave()


func _spawn_enemy() -> void:
	var enemy: Enemy = _enemy_scene.instantiate()
	var type: Enemy.EnemyType = _pick_enemy_type()
	enemy.enemy_type = type

	match type:
		Enemy.EnemyType.CHASER:
			enemy.max_health = 1 + _current_wave / 5
			enemy.move_speed = randf_range(160.0, 230.0)
			enemy.score_value = 10
		Enemy.EnemyType.SHOOTER:
			enemy.max_health = 2 + _current_wave / 4
			enemy.move_speed = randf_range(130.0, 180.0)
			enemy.fire_rate = randf_range(1.2, 2.2)
			enemy.score_value = 20
		Enemy.EnemyType.TANK:
			enemy.max_health = 5 + _current_wave / 2
			enemy.move_speed = randf_range(90.0, 130.0)
			enemy.fire_rate = randf_range(0.5, 1.0)
			enemy.score_value = 50
		Enemy.EnemyType.DASHER:
			# 빠른 지그재그 돌진형 - 체력 낮음, 속도 매우 빠름
			enemy.max_health = 1 + _current_wave / 6
			enemy.move_speed = randf_range(250.0, 330.0)
			enemy.score_value = 15
		Enemy.EnemyType.BOMBER:
			# 자폭형 - 체력 보통, 보통 속도
			enemy.max_health = 2 + _current_wave / 5
			enemy.move_speed = randf_range(140.0, 190.0)
			enemy.score_value = 25
		Enemy.EnemyType.SPLITTER:
			# 분열형 - 체력 높음 (죽으면 3마리로 분열)
			enemy.max_health = 3 + _current_wave / 3
			enemy.move_speed = randf_range(100.0, 140.0)
			enemy.score_value = 30
		Enemy.EnemyType.SHIELDER:
			# 쉴드형 - 체력 매우 높음, 재생, 원형 탄막
			enemy.max_health = 6 + _current_wave / 2
			enemy.move_speed = randf_range(90.0, 130.0)
			enemy.fire_rate = randf_range(0.6, 1.0)
			enemy.score_value = 40

	# 난이도 배수 적용 (체력/속도/총알속도)
	var dm := _get_diff_mult()
	enemy.max_health = max(1, int(round(enemy.max_health * float(dm["enemy_hp"]))))
	# 화면 높이 보정: 세로가 긴 기기에서 적이 화면을 지나는 시간이 같아지도록
	# 픽셀 속도를 높이에 비례시킨다(GameManager.screen_speed_scale 주석 참조).
	var hs := GameManager.screen_speed_scale()
	enemy.move_speed *= float(dm["enemy_speed"]) * hs
	enemy.bullet_speed *= float(dm["bullet_speed"]) * hs

	# Assign a letter from WordManager (target letter or random decoy)
	# 타겟 글자가 붙어 나올 확률. 0.3 은 첫 단어 완성이 34.8초까지 늘어져 학습 루프가 느렸다.
	enemy.letter = WordManager.get_random_letter(0.45)

	# Spawn position: top edge, random X
	enemy.global_position = Vector2(randf_range(60, _screen_size.x - 60), -50)
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
	var tank_chance: float = clampf(0.05 + w * 0.02, 0.05, 0.15)
	var shooter_chance: float = clampf(0.15 + w * 0.025, 0.15, 0.25)
	var dasher_chance: float = clampf(0.05 + w * 0.02, 0.05, 0.15)
	var bomber_chance: float = clampf(0.03 + w * 0.015, 0.03, 0.12)
	var splitter_chance: float = clampf(0.03 + w * 0.012, 0.03, 0.10)
	var shielder_chance: float = clampf(0.02 + w * 0.01, 0.02, 0.08)

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
	# 나머지는 CHASER (가장 흔한 기본 적)
	return Enemy.EnemyType.CHASER


func _next_wave() -> void:
	wave_cleared.emit(_current_wave)
	_current_wave += 1
	var dm := _get_diff_mult()
	var min_int: float = min_spawn_interval * float(dm["spawn_interval"])
	_spawn_interval = max(min_int, _spawn_interval * difficulty_scale)
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