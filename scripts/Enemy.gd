class_name Enemy
extends CharacterBody2D
## Enemy - multiple types: chaser, shooter, tank, dasher, bomber, splitter, shielder.
## Spawns at top of screen, moves toward player, collides with player/bullets.

signal enemy_destroyed(points: int)

enum EnemyType { CHASER, SHOOTER, TANK, DASHER, BOMBER, SPLITTER, SHIELDER, SWARM, TURRET, PHANTOM }

## SHIELDER 체력 재생 주기. ⚠️ **이 적의 수명보다 짧아야 한다** —
##    같거나 길면 대부분 한 번도 재생하지 못하고 죽어 정체성이 사라진다(실측 10%).
const REGEN_INTERVAL := 0.6
## BOMBER 가 **격추될 때** 뿌리는 탄 수. 접근 자폭(12발)보다 적게 둔다 —
## 자폭병이 전체 스폰의 14% 라 격추 폭발까지 12발이면 탄막이 판을 뒤덮는다.
const BOMB_DEATH_BULLETS := 5

## 포탑이 멈춰 서는 높이(화면 비율). 적은 보통 최상단에서 죽는데, 포탑은 **스스로 멈춰서**
## 오래 버티는 것이 정체성이다 — 다가가지 않으므로 수명이 체력으로만 정해진다.
## ⚠️⚠️ **어떤 기체 위치에서도 사격이 닿는 곳이어야 한다.** 교전선은 기체 위치에 따라
##    화면 15%(기체가 위) ~ 42%(기체가 아래) 사이를 오간다. 이보다 위에 멈춰 서면
##    기체가 아래에 있을 때 **정상 사격으로 못 죽인다**(실측: 8% 에 세웠더니 수명 중앙 12초,
##    폭탄 파워업으로만 사라졌다). 그래서 가장 아래 교전선(42%)보다 더 아래에 세운다.
## ⚠️ 그렇다고 너무 아래면 도달 전에 죽어 정체성이 발현되지 않는다(0.18 시절 발동률 13%).
const TURRET_STOP_RATIO := 0.46
## 환영의 위상 주기. ⚠️ **수명(0.6~2.7초)보다 짧아야** 한 판에서 깜빡이는 게 보인다.
const PHANTOM_SOLID := 0.5
const PHANTOM_FADED := 0.35
## 군체 한 무리의 마릿수. 스포너가 이 수만큼 한 번에 낸다.
const SWARM_COUNT := 5

@export var enemy_type: EnemyType = EnemyType.CHASER
@export var max_health: int = 1
@export var move_speed: float = 120.0
@export var score_value: int = 10
@export var fire_rate: float = 1.5
@export var bullet_speed: float = 420.0
@export var drop_chance: float = 0.15  # chance to drop a powerup
@export var letter: String = ""  # alphabet letter displayed on this enemy

var _powerup_scene: PackedScene = preload("res://scenes/PowerUp.tscn")

var health: int = 1
var _is_dead: bool = false
var _player: Node2D = null
var _fire_timer: float = 0.0
var _spawn_y: float = -50.0
## 화면에 몸이 다 들어오기 전에는 맞지 않는다.
## ⚠️ 예전에는 이 변수가 **선언만 되고 쓰이지 않았다.** 그래서 적이 스폰선(y=-50)에서
##    바로 죽어 "적이 화면에 나오기 전에 다 죽어 있다" 는 상태가 됐다.
## ⚠️ 무적으로 두면 탄을 **먹어 버려서** 왜 안 죽는지 알 수 없다 — 충돌을 꺼서 통과시킨다.
var _is_entering: bool = true
## 이 높이까지 내려오면 교전을 시작한다. 도형 반지름(최대 22)보다 넉넉히 아래.
const ENTRY_Y := 46.0

# 신규 적 타입용 상태 변수
var _zigzag_phase: float = 0.0        # DASHER 지그재그 위상
var _bomb_triggered: bool = false     # BOMBER 자폭 시작 여부
var _regen_timer: float = 0.0         # SHIELDER 체력 재생 타이머
var _bomb_exploded: bool = false      # BOMBER 탄막을 이미 뿌렸는지(이중 폭발 방지)
var _turret_parked: bool = false      # TURRET 정지 위치 도달 여부
var _phase_timer: float = 0.0         # PHANTOM 위상 타이머
var _phased: bool = false             # PHANTOM 이 지금 흐릿한(무적) 상태인가
var _swarm_phase: float = 0.0         # SWARM 대형 좌우 흔들림 위상
var _is_child: bool = false           # SPLITTER 분열된 자식 여부 (자식은 분열 안 함)

@onready var _sprite: Polygon2D = $Sprite
@onready var _glow: PointLight2D = $Glow
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _health_bar: ProgressBar = $HealthBar
var _letter_label: Label = null

var _bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")


func _ready() -> void:
	health = max_health
	add_to_group("enemy")
	collision_layer = 2  # enemy layer
	collision_mask = 4 | 1  # bullet_player + player
	_configure_type()
	# 스폰 직후에는 화면 밖이므로 맞지 않는다(아래 _physics_process 에서 해제).
	if global_position.y < ENTRY_Y:
		collision_layer = 0
	else:
		_is_entering = false
	_find_player()
	if _health_bar:
		_health_bar.max_value = max_health
		_health_bar.value = health
		_health_bar.visible = max_health > 1
	_setup_letter_label()


func _setup_letter_label() -> void:
	if not _letter_label:
		# Create label dynamically if not in scene
		_letter_label = Label.new()
		_letter_label.name = "LetterLabel"
		add_child(_letter_label)
	_letter_label.text = letter
	_letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_letter_label.add_theme_font_size_override("font_size", 28)
	_letter_label.add_theme_color_override("font_color", Color.WHITE)
	_letter_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_letter_label.add_theme_constant_override("outline_size", 6)
	_letter_label.position = Vector2(-16, -16)
	_letter_label.size = Vector2(32, 32)
	# Highlight if this is the target letter
	_update_letter_color()


var _last_target_letter: String = "__init__"


func _update_letter_color() -> void:
	if not _letter_label:
		return
	var target := WordManager.get_target_letter()
	# 타겟 글자가 변경된 경우에만 색상 업데이트 (매 프레임 재설정 방지)
	if target == _last_target_letter and _last_target_letter != "__init__":
		return
	_last_target_letter = target
	if letter != "" and letter == target:
		# Target letter - highlight in green
		_letter_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		_sprite.color = Color(0.2, 0.6, 0.3)
		_glow.color = Color(0.2, 1.0, 0.5)
	else:
		# Non-target letter - restore type-based color
		_letter_label.add_theme_color_override("font_color", Color.WHITE)
		_configure_type()


func _configure_type() -> void:
	match enemy_type:
		EnemyType.CHASER:
			_sprite.color = Color(1.0, 0.3, 0.5)
			_glow.color = Color(1.0, 0.3, 0.5)
			_sprite.polygon = _make_triangle(18)
		EnemyType.SHOOTER:
			_sprite.color = Color(1.0, 0.6, 0.2)
			_glow.color = Color(1.0, 0.6, 0.2)
			_sprite.polygon = _make_diamond(16)
		EnemyType.TANK:
			_sprite.color = Color(0.8, 0.3, 1.0)
			_glow.color = Color(0.8, 0.3, 1.0)
			_sprite.polygon = _make_hexagon(22)
		EnemyType.DASHER:
			# 지그재그 돌진형 - 밝은 청록색 번개 모양
			_sprite.color = Color(0.2, 1.0, 1.0)
			_glow.color = Color(0.2, 1.0, 1.0)
			_sprite.polygon = _make_star(16)
		EnemyType.BOMBER:
			# 자폭형 - 주황색 둥근 폭탄
			_sprite.color = Color(1.0, 0.4, 0.1)
			_glow.color = Color(1.0, 0.4, 0.1)
			_sprite.polygon = _make_circle(18)
		EnemyType.SPLITTER:
			# 분열형 - 초록색 팔각형
			_sprite.color = Color(0.3, 1.0, 0.3)
			_glow.color = Color(0.3, 1.0, 0.3)
			_sprite.polygon = _make_octagon(20)
		EnemyType.SHIELDER:
			# 쉴드형 - 파란색 정사각형 (체력 재생)
			_sprite.color = Color(0.3, 0.5, 1.0)
			_glow.color = Color(0.3, 0.5, 1.0)
			_sprite.polygon = _make_square(18)
		EnemyType.SWARM:
			# 군체 - 노란 작은 마름모. 여럿이 대형으로 몰려온다
			_sprite.color = Color(1.0, 0.85, 0.2)
			_glow.color = Color(1.0, 0.85, 0.2)
			_sprite.polygon = _make_diamond(12)
		EnemyType.TURRET:
			# 포탑 - 짙은 빨강 오각형. 멈춰 서서 쏜다
			_sprite.color = Color(0.9, 0.15, 0.25)
			_glow.color = Color(0.9, 0.15, 0.25)
			_sprite.polygon = _make_pentagon(21)
		EnemyType.PHANTOM:
			# 환영 - 창백한 백색 쐐기. 주기적으로 흐려지며 탄이 통과한다
			_sprite.color = Color(1.0, 0.95, 0.85)
			_glow.color = Color(1.0, 0.95, 0.85)
			_sprite.polygon = _make_chevron(20)


func _make_triangle(size: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, size),
		Vector2(-size * 0.866, -size * 0.5),
		Vector2(size * 0.866, -size * 0.5)
	])


func _make_diamond(size: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, size),
		Vector2(size, 0),
		Vector2(0, -size),
		Vector2(-size, 0)
	])


func _make_hexagon(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := TAU * i / 6.0
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	return pts


func _make_star(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var angle := TAU * i / 10.0 - PI / 2.0
		var r := size if i % 2 == 0 else size * 0.45
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	return pts


func _make_square(size: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-size, -size),
		Vector2(size, -size),
		Vector2(size, size),
		Vector2(-size, size)
	])


func _make_octagon(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 8:
		var angle := TAU * i / 8.0 + PI / 8.0
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	return pts


func _make_pentagon(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 5:
		var angle := TAU * i / 5.0 - PI / 2.0
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	return pts


## 아래를 향한 쐐기(V). 다른 어떤 적과도 안 겹치는 실루엣이다.
func _make_chevron(size: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, size), Vector2(-size, -size * 0.7), Vector2(-size * 0.45, -size),
		Vector2(0, -size * 0.25), Vector2(size * 0.45, -size), Vector2(size, -size * 0.7)
	])


func _make_circle(size: float, segments: int = 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / float(segments)
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	return pts


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if not is_instance_valid(_player):
		_find_player()
		if not _player:
			return

	if _is_entering and global_position.y >= ENTRY_Y:
		_is_entering = false
		# 환영은 자기 위상에 따라 켜고 끄므로 여기서 건드리지 않는다.
		if enemy_type != EnemyType.PHANTOM or not _phased:
			set_deferred("collision_layer", 2)

	_behave(delta)
	move_and_slide()

	# Update letter color in real-time (target letter may change)
	_update_letter_color()

	# Despawn off-screen bottom
	if global_position.y > get_viewport_rect().size.y + 80:
		queue_free()


func _behave(delta: float) -> void:
	var to_player := _player.global_position - global_position
	var dist := to_player.length()

	match enemy_type:
		EnemyType.CHASER:
			velocity = to_player.normalized() * move_speed
			_sprite.rotation = velocity.angle() + PI / 2

		EnemyType.SHOOTER:
			# Keep distance, strafe
			if dist > 300:
				velocity = to_player.normalized() * move_speed
			elif dist < 200:
				velocity = -to_player.normalized() * move_speed * 0.5
			else:
				# Strafe perpendicular
				var perp := Vector2(-to_player.y, to_player.x).normalized()
				velocity = perp * move_speed * 0.7
			_sprite.rotation = to_player.angle() + PI / 2
			# Fire at player
			_fire_timer -= delta
			if _fire_timer <= 0 and dist < 500:
				_fire_at_player()
				_fire_timer = 1.0 / fire_rate

		EnemyType.TANK:
			# Slow advance, fire spread
			velocity = to_player.normalized() * move_speed * 0.5
			_sprite.rotation += delta * 0.5
			_fire_timer -= delta
			if _fire_timer <= 0:
				_fire_spread()
				_fire_timer = 1.0 / fire_rate

		EnemyType.DASHER:
			# 지그재그 패턴으로 빠르게 돌진
			# ⚠️ 주기가 곧 정체성이다. 예전 8.0 은 한 주기가 0.785초인데 이 적의 **수명 중앙값이
			#    0.67초**라 절반 이상이 한 번도 꺾지 못하고 죽었다(실측 특수발동 41% / 2주기 3%).
			#    지그재그가 안 보이면 CHASER 와 구분되지 않는다. 20.0 = 주기 0.31초.
			_zigzag_phase += delta * 20.0
			var dash_dir := to_player.normalized()
			var perp := Vector2(-dash_dir.y, dash_dir.x)
			var zigzag := perp * sin(_zigzag_phase) * move_speed * 0.8
			velocity = dash_dir * move_speed + zigzag
			_sprite.rotation = velocity.angle() + PI / 2

		EnemyType.BOMBER:
			# 플레이어를 향해 직선 돌진, 가까이 오면 자폭
			# ⚠️ **접근 자폭은 실측 발동률이 0% 였다.** 탄 사거리가 화면의 60% 라
			#    자폭병은 플레이어에게 닿기 한참 전에 죽는다 — 트리거 거리(150)의 다섯 배다.
			#    이 적의 정체성이 통째로 발현되지 않았다는 뜻이라, `die()` 에서 **격추될 때도**
			#    터지게 했다(작은 탄막). 접근 자폭은 그대로 두되 사실상 예비 경로다.
			velocity = to_player.normalized() * move_speed
			_sprite.rotation += delta * 3.0
			# 가까워지면 깜빡임 시작
			if dist < 150 and not _bomb_triggered:
				_bomb_triggered = true
				_fire_timer = 0.5  # 0.5초 후 자폭
			if _bomb_triggered:
				_fire_timer -= delta
				# 깜빡임 효과 (빨라짐)
				_sprite.color.a = 0.5 + sin(_fire_timer * 30.0) * 0.5
				if _fire_timer <= 0:
					_explode_bomb()
					die()

		EnemyType.SPLITTER:
			# 느리게 다가오며, 죽으면 3개로 분열
			velocity = to_player.normalized() * move_speed * 0.7
			_sprite.rotation += delta * 1.0

		EnemyType.SWARM:
			# 군체: 대형을 유지한 채 곧게 내려온다. 좌우로 얕게 흔들려 무리처럼 보인다.
			# ⚠️ 플레이어를 쫓지 않는다 — 쫓게 하면 대형이 한 점으로 뭉쳐 무리로 안 보인다.
			_swarm_phase += delta * 3.0
			velocity = Vector2(sin(_swarm_phase) * 55.0, move_speed)
			_sprite.rotation += delta * 2.0

		EnemyType.TURRET:
			# 포탑: 정해진 높이까지 내려와 **멈춘 뒤** 계속 쏜다.
			# 다가가지 않으므로 수명이 접근 속도가 아니라 체력으로 정해진다 —
			# 이 게임에서 특수 행동을 확실히 보여줄 수 있는 유일한 방식이다.
			var stop_y := get_viewport_rect().size.y * TURRET_STOP_RATIO
			if not _turret_parked and global_position.y >= stop_y:
				_turret_parked = true
			velocity = Vector2.ZERO if _turret_parked else Vector2(0, move_speed)
			_sprite.rotation = to_player.angle() + PI / 2
			if _turret_parked:
				_fire_timer -= delta
				if _fire_timer <= 0:
					_fire_at_player()
					_fire_timer = 1.0 / fire_rate

		EnemyType.PHANTOM:
			# 환영: 주기적으로 흐려지며 **탄이 통과**한다(충돌 자체를 끈다).
			# 조준이 없는 게임이라 "맞출 타이밍"을 요구할 수 없다 —
			# 대신 처치에 걸리는 시간이 늘어나 화면에 오래 남는다.
			velocity = to_player.normalized() * move_speed * 0.8
			_sprite.rotation = velocity.angle() + PI / 2
			_phase_timer -= delta
			if _phase_timer <= 0.0:
				_set_phased(not _phased)

		EnemyType.SHIELDER:
			# 느리게 다가오며 체력 자동 재생
			velocity = to_player.normalized() * move_speed * 0.6
			_sprite.rotation += delta * 0.3
			_regen_timer -= delta
			if _regen_timer <= 0 and health < max_health:
				health = mini(health + 1, max_health)
				if _health_bar:
					_health_bar.value = health
				# ⚠️ 예전 2.0 초는 이 적의 **수명 중앙값 2.0 초**와 같아서 실측 재생률이 10% 였다.
				#    한 번도 회복하지 못하고 죽으면 "재생하는 적"이라는 정체성이 없는 것과 같다.
				_regen_timer = REGEN_INTERVAL
				_flash_regen()
			# 일정 거리 유지하면 원형 총탄 발사
			_fire_timer -= delta
			if _fire_timer <= 0:
				_fire_circle()
				_fire_timer = 1.0 / fire_rate


func _fire_at_player() -> void:
	AudioManager.play_sfx("enemy_shoot")
	var bullet := _bullet_scene.instantiate()
	bullet.global_position = global_position
	var dir := (_player.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.is_player_bullet = false
	get_tree().current_scene.add_child(bullet)
	AudioManager.play_sfx("hit")


func _fire_spread() -> void:
	AudioManager.play_sfx("enemy_shoot")
	for i in 3:
		var bullet := _bullet_scene.instantiate()
		bullet.global_position = global_position
		var angle := (_player.global_position - global_position).angle() + (i - 1) * 0.3
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.speed = bullet_speed * 0.9
		bullet.is_player_bullet = false
		get_tree().current_scene.add_child(bullet)


## 환영의 위상 전환. ⚠️ 색만 바꾸면 탄을 **먹어 버려서** 플레이어는 왜 안 죽는지 알 수 없다.
## 충돌 레이어를 꺼서 탄이 그대로 통과하게 해야 "지금은 못 맞힌다" 가 눈에 보인다.
func _set_phased(on: bool) -> void:
	_phased = on
	_phase_timer = PHANTOM_FADED if on else PHANTOM_SOLID
	# ⚠️ 진입 중이면 충돌을 켜지 않는다 — 위상 전환이 진입 보호를 뚫어 버린다.
	set_deferred("collision_layer", 0 if (on or _is_entering) else 2)
	if _sprite:
		_sprite.color.a = 0.25 if on else 1.0
	if _glow:
		_glow.energy = 0.3 if on else 1.0


## 재생을 **눈에 보이게** 한다. 숫자만 오르고 화면에 아무 일도 없으면
## "재생하는 적" 이라는 성질을 플레이어가 알 방법이 없다.
func _flash_regen() -> void:
	if _sprite == null:
		return
	var tween := create_tween()
	tween.tween_property(_sprite, "scale", Vector2(1.25, 1.25), 0.08)
	tween.tween_property(_sprite, "scale", Vector2.ONE, 0.16)


func _fire_circle() -> void:
	AudioManager.play_sfx("enemy_shoot")
	# SHIELDER: 8방향 원형 탄막
	var count := 8
	for i in count:
		var bullet := _bullet_scene.instantiate()
		bullet.global_position = global_position
		var angle := TAU * i / float(count)
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.speed = bullet_speed * 0.85
		bullet.is_player_bullet = false
		get_tree().current_scene.add_child(bullet)


## `count` 방향으로 탄막을 뿌린다. 접근 자폭은 12발, 격추 폭발은 그보다 적다.
func _explode_bomb(count: int = 12) -> void:
	if _bomb_exploded:
		return
	_bomb_exploded = true
	for i in count:
		var bullet := _bullet_scene.instantiate()
		bullet.global_position = global_position
		var angle := TAU * i / float(count)
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.speed = bullet_speed
		bullet.is_player_bullet = false
		get_tree().current_scene.add_child(bullet)
	EffectsManager.shake(8.0, 0.3)
	AudioManager.play_sfx("enemy_die")


func take_damage(amount: int) -> void:
	if _is_dead:
		return
	health -= amount
	if _health_bar:
		_health_bar.value = health
	EffectsManager.flash(global_position, _sprite.color, 0.05)
	if health <= 0:
		die()
	else:
		AudioManager.play_sfx("hit")


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	# SPLITTER: 부모일 경우 죽으면 3개의 작은 자식으로 분열
	# Use call_deferred to avoid "Can't change this state while flushing queries" error
	# (die() is called inside physics collision callback)
	if enemy_type == EnemyType.SPLITTER and not _is_child:
		_split_into_children.call_deferred()
	# ⚠️ 자폭병은 **격추돼도 터진다.** 접근 자폭만 두면 실측 발동률이 0% 라
	#    (탄 사거리가 트리거 거리의 다섯 배다) 이 적이 사실상 존재하지 않았다.
	#    가까이 붙은 자폭병을 쏘면 그 자리에서 터지므로 "언제 쏠지" 라는 판단이 생긴다.
	if enemy_type == EnemyType.BOMBER:
		_explode_bomb.call_deferred(BOMB_DEATH_BULLETS)
	# Register kill with combo system and get multiplied points
	var points := GameManager.register_kill(score_value)
	enemy_destroyed.emit(points)
	# Score popup
	_spawn_score_popup(points)
	# Drop powerup chance (higher for tougher enemies)
	var chance := drop_chance
	match enemy_type:
		EnemyType.TANK:
			chance = 0.35
		EnemyType.SHOOTER:
			chance = 0.2
		EnemyType.BOMBER:
			chance = 0.25
		EnemyType.SPLITTER:
			chance = 0.30
		EnemyType.SHIELDER:
			chance = 0.30
		EnemyType.DASHER:
			chance = 0.15
	if randf() < chance:
		_drop_powerup()
	EffectsManager.explosion(global_position, _sprite.color)
	EffectsManager.shake(4.0, 0.15)
	AudioManager.play_sfx("enemy_die")
	queue_free()


func _split_into_children() -> void:
	# SPLITTER 사망 시 3마리의 작은 CHASER 생성
	# 이미 위에서 call_deferred로 호출되므로 여기서는 안전하게 add_child 가능
	for i in 3:
		var child: Enemy = _get_enemy_scene().instantiate()
		child.enemy_type = EnemyType.CHASER
		child._is_child = true
		child.max_health = 1
		child.move_speed = move_speed * 1.3
		child.score_value = 5
		child.letter = letter  # 같은 글자 상속
		# 부모 주변에 흩뿌리기
		var offset := Vector2(randf_range(-40, 40), randf_range(-40, 40))
		child.global_position = global_position + offset
		get_tree().current_scene.add_child(child)
		# 자식도 destroy 시그널 연결 (카운트 유지)
		child.enemy_destroyed.connect(func(_p: int) -> void:
			_on_child_destroyed()
		)


func _on_child_destroyed() -> void:
	pass  # 자식 사망 처리 (필요시 확장)


func _get_enemy_scene() -> PackedScene:
	# preload 대신 load를 사용하여 순환 참조(circular dependency) 방지
	# (Enemy.gd → Enemy.tscn → Enemy.gd 무한 루프)
	return load("res://scenes/Enemy.tscn")


func _spawn_score_popup(points: int) -> void:
	var popup := Label.new()
	popup.set_script(preload("res://scripts/ScorePopup.gd"))
	get_tree().current_scene.add_child(popup)
	var color := Color(1, 0.9, 0.3)
	if GameManager.combo_multiplier > 2.0:
		color = Color(1.0, 0.5, 0.2)
	elif GameManager.combo_multiplier > 1.0:
		color = Color(1.0, 0.8, 0.2)
	popup.setup(points, global_position, color)


func _drop_powerup() -> void:
	var powerup: Area2D = _powerup_scene.instantiate()
	# Weighted random type selection (rare items are special)
	var roll := randf()
	if roll < 0.25:
		powerup.type = GameManager.PowerUpType.RAPID      # 25% common
	elif roll < 0.45:
		powerup.type = GameManager.PowerUpType.SPREAD     # 20% common
	elif roll < 0.60:
		powerup.type = GameManager.PowerUpType.SHIELD     # 15% uncommon
	elif roll < 0.72:
		powerup.type = GameManager.PowerUpType.BOMB       # 12% uncommon
	elif roll < 0.84:
		powerup.type = GameManager.PowerUpType.LIGHTNING  # 12% rare
	elif roll < 0.94:
		powerup.type = GameManager.PowerUpType.LASER      # 10% rare
	else:
		powerup.type = GameManager.PowerUpType.TIME_SLOW  # 6%  legendary

	# 잔잔한 구간에서는 시간 감속(TIME_SLOW)을 드롭하지 않는다.
	# 이 게임의 타겟은 속도감을 즐기는 유저인데, 이미 느린 판에서
	# time_scale 0.3 을 4초간 걸면 체감이 더 늘어진다. 6%는 LIGHTNING 으로 넘긴다.
	if powerup.type == GameManager.PowerUpType.TIME_SLOW \
			and DifficultyDirector.get_intensity() < 0.4:
		powerup.type = GameManager.PowerUpType.LIGHTNING

	powerup.global_position = global_position
	# Use call_deferred to avoid physics query flush error
	get_tree().current_scene.add_child.call_deferred(powerup)


func _on_area_entered(area: Area2D) -> void:
	# Collision with player handled by player
	pass
