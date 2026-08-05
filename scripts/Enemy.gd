class_name Enemy
extends CharacterBody2D
## Enemy - multiple types: chaser, shooter, tank, dasher, bomber, splitter, shielder.
## Spawns at top of screen, moves toward player, collides with player/bullets.

signal enemy_destroyed(points: int)

enum EnemyType { CHASER, SHOOTER, TANK, DASHER, BOMBER, SPLITTER, SHIELDER }

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
var _is_entering: bool = true

# 신규 적 타입용 상태 변수
var _zigzag_phase: float = 0.0        # DASHER 지그재그 위상
var _bomb_triggered: bool = false     # BOMBER 자폭 시작 여부
var _regen_timer: float = 0.0         # SHIELDER 체력 재생 타이머
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
			_zigzag_phase += delta * 8.0
			var dash_dir := to_player.normalized()
			var perp := Vector2(-dash_dir.y, dash_dir.x)
			var zigzag := perp * sin(_zigzag_phase) * move_speed * 0.8
			velocity = dash_dir * move_speed + zigzag
			_sprite.rotation = velocity.angle() + PI / 2

		EnemyType.BOMBER:
			# 플레이어를 향해 직선 돌진, 가까이 오면 자폭
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

		EnemyType.SHIELDER:
			# 느리게 다가오며 체력 자동 재생
			velocity = to_player.normalized() * move_speed * 0.6
			_sprite.rotation += delta * 0.3
			_regen_timer -= delta
			if _regen_timer <= 0 and health < max_health:
				health = mini(health + 1, max_health)
				if _health_bar:
					_health_bar.value = health
				_regen_timer = 2.0  # 2초마다 1 회복
			# 일정 거리 유지하면 원형 총탄 발사
			_fire_timer -= delta
			if _fire_timer <= 0:
				_fire_circle()
				_fire_timer = 1.0 / fire_rate


func _fire_at_player() -> void:
	var bullet := _bullet_scene.instantiate()
	bullet.global_position = global_position
	var dir := (_player.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.is_player_bullet = false
	get_tree().current_scene.add_child(bullet)
	AudioManager.play_sfx("hit")


func _fire_spread() -> void:
	for i in 3:
		var bullet := _bullet_scene.instantiate()
		bullet.global_position = global_position
		var angle := (_player.global_position - global_position).angle() + (i - 1) * 0.3
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.speed = bullet_speed * 0.9
		bullet.is_player_bullet = false
		get_tree().current_scene.add_child(bullet)


func _fire_circle() -> void:
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


func _explode_bomb() -> void:
	# BOMBER: 12방향 폭발 탄막
	var count := 12
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
	powerup.global_position = global_position
	# Use call_deferred to avoid physics query flush error
	get_tree().current_scene.add_child.call_deferred(powerup)


func _on_area_entered(area: Area2D) -> void:
	# Collision with player handled by player
	pass