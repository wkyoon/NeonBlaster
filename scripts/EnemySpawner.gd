extends Node2D
## EnemySpawner - manages enemy wave spawning with increasing difficulty.

signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_killed(enemy_type: int, points: int)

## ⚠️ 이 네 값은 Game.tscn 의 EnemySpawner 노드가 **덮어쓴다**.
## 여기만 고치면 게임에 반영되지 않는다 — 반드시 Game.tscn 값도 같이 수정할 것.
@export var initial_spawn_interval: float = 1.1
@export var min_spawn_interval: float = 0.3
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
	enemy.enemy_type = type
	# ⚠️ 웨이브 기반 체력 가산에는 상한이 필요하다. 목표가 10분이면 웨이브가 50을 넘어
	#    체력이 끝없이 불어난다(예전엔 90초 판이라 웨이브 8이 최대였다).
	#    시간에 따른 난이도 상승은 DifficultyDirector 가 담당한다.
	var wave := mini(_current_wave, MAX_STAT_WAVE)

	match type:
		Enemy.EnemyType.CHASER:
			enemy.max_health = 1 + wave / 5
			enemy.move_speed = randf_range(160.0, 230.0)
			enemy.score_value = 10
		Enemy.EnemyType.SHOOTER:
			enemy.max_health = 2 + wave / 4
			enemy.move_speed = randf_range(130.0, 180.0)
			enemy.fire_rate = randf_range(1.2, 2.2)
			enemy.score_value = 20
		Enemy.EnemyType.TANK:
			enemy.max_health = 5 + wave / 2
			enemy.move_speed = randf_range(90.0, 130.0)
			enemy.fire_rate = randf_range(0.5, 1.0)
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