extends CharacterBody2D
## Player ship - movement (touch joystick + keyboard), auto-fire, collision.

signal player_died
signal player_hit
signal weapon_changed(weapon_level: int)
signal shield_activated(duration: float)
signal bomb_triggered

enum WeaponType { SINGLE, DOUBLE, TRIPLE, SPREAD }

@export var max_speed: float = 320.0
@export var acceleration: float = 2400.0
@export var friction: float = 1800.0
@export var fire_rate: float = 8.0  # shots per second
@export var bullet_damage: int = 1
@export var invincible_duration: float = 1.0

var weapon_type: WeaponType = WeaponType.SINGLE
var weapon_level: int = 1  # 1-3
var rapid_fire_timer: float = 0.0  # countdown for rapid fire buff
var shield_timer: float = 0.0  # countdown for shield buff
var laser_timer: float = 0.0  # countdown for laser buff
var time_slow_timer: float = 0.0  # countdown for time slow (global)
var _base_fire_rate: float = 8.0
var _rapid_effect: Node2D = null
var _shield_effect: Node2D = null
var _laser_effect: Node2D = null

@onready var _sprite: Polygon2D = $Sprite
@onready var _glow: PointLight2D = $Glow
@onready var _muzzle: Marker2D = $Muzzle
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _fire_timer: Timer = $FireTimer
@onready var _engine_particles: CPUParticles2D = $EngineParticles

var _bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
var _move_input: Vector2 = Vector2.ZERO
var _can_fire: bool = true
var _is_invincible: bool = false
var _screen_size: Vector2
var _invincible_timer: float = 0.0


func _ready() -> void:
	_screen_size = get_viewport_rect().size
	_base_fire_rate = fire_rate
	_fire_timer.wait_time = 1.0 / fire_rate
	_fire_timer.timeout.connect(_on_fire_timer)
	add_to_group("player")
	collision_layer = 1  # player layer
	collision_mask = 2 | 16  # enemy + pickup


func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	_handle_input()
	_apply_movement(delta)
	_handle_fire()
	_handle_invincibility(delta)
	_handle_buffs(delta)
	_handle_laser(delta)
	_handle_time_slow(delta)


func _handle_buffs(delta: float) -> void:
	# Rapid fire countdown
	if rapid_fire_timer > 0:
		rapid_fire_timer -= delta
		if rapid_fire_timer <= 0:
			fire_rate = _base_fire_rate
			_fire_timer.wait_time = 1.0 / fire_rate
			_remove_rapid_effect()
	# Shield countdown
	if shield_timer > 0:
		shield_timer -= delta
		if shield_timer <= 0:
			_remove_shield_effect()
		elif _shield_effect:
			_shield_effect.modulate.a = 0.4 + sin(Time.get_ticks_msec() * 0.01) * 0.2


func _handle_input() -> void:
	_move_input = Vector2.ZERO

	# Auto-play: AI controls the ship
	if GameManager.auto_play:
		_move_input = _compute_ai_input()
		_move_input = _move_input.limit_length(1.0)
		return

	# Keyboard fallback (desktop testing)
	if Input.is_action_pressed("ui_right"):
		_move_input.x += 1
	if Input.is_action_pressed("ui_left"):
		_move_input.x -= 1
	if Input.is_action_pressed("ui_down"):
		_move_input.y += 1
	if Input.is_action_pressed("ui_up"):
		_move_input.y -= 1

	# Touch joystick: drag anywhere on left half to move
	var touch_input := _get_touch_joystick_input()
	if touch_input != Vector2.ZERO:
		_move_input = touch_input

	_move_input = _move_input.limit_length(1.0)


# ---------------- Auto-Play AI ----------------

func _compute_ai_input() -> Vector2:
	var target_pos := global_position
	var best_enemy: Node2D = null
	var best_dist := INF
	var target_letter := WordManager.get_target_letter()

	# Find the nearest enemy with the target letter (highest priority)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		# letter 속성이 있는 Enemy 노드만 처리 (HitArea 등 제외)
		if not ("letter" in enemy):
			continue
		# Prefer enemies with target letter
		if target_letter != "" and enemy.letter == target_letter:
			var d := global_position.distance_to(enemy.global_position)
			if d < best_dist:
				best_dist = d
				best_enemy = enemy
	# If no target-letter enemy, find nearest enemy overall
	if not best_enemy:
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if not is_instance_valid(enemy):
				continue
			if not ("letter" in enemy):
				continue
			var d := global_position.distance_to(enemy.global_position)
			if d < best_dist:
				best_dist = d
				best_enemy = enemy

	var ai_input := Vector2.ZERO
	var screen_h := _screen_size.y

	if best_enemy:
		var to_enemy: Vector2 = best_enemy.global_position - global_position
		var enemy_y := best_enemy.global_position.y

		# Horizontal tracking: align with enemy x
		if absf(to_enemy.x) > 20:
			ai_input.x = signf(to_enemy.x)

		# Vertical: stay in the lower third of the screen
		# Let enemies come to us; only move up slightly when enemy is in shooting range
		if global_position.y < screen_h * 0.6:
			# Too high - go back down
			ai_input.y = 1.0
		elif enemy_y > global_position.y - 100:
			# Enemy is close enough vertically - hold position or slight retreat
			ai_input.y = 0.2
		else:
			# Stay in place
			ai_input.y = 0.0

	# Dodge nearby enemy bullets
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		if not is_instance_valid(bullet):
			continue
		var bpos: Vector2 = bullet.global_position
		var bd := global_position.distance_to(bpos)
		if bd < 120:
			# Check if bullet is coming toward us
			var to_us: Vector2 = (global_position - bpos).normalized()
			var bdir: Vector2 = bullet.direction
			if bdir.dot(to_us) > 0.5:
				# Dodge perpendicular
				var dodge_dir: Vector2 = Vector2(-bdir.y, bdir.x)
				if dodge_dir.dot(Vector2(global_position - bpos)) < 0:
					dodge_dir = -dodge_dir
				ai_input += dodge_dir * 1.5

	# Collect nearby powerups
	for pu in get_tree().get_nodes_in_group("pickup"):
		if not is_instance_valid(pu):
			continue
		var pd := global_position.distance_to(pu.global_position)
		if pd < 200:
			ai_input += (pu.global_position - global_position).normalized() * 0.5

	return ai_input.limit_length(1.0)


func _get_touch_joystick_input() -> Vector2:
	# Virtual dynamic joystick on touch
	var joy := get_node_or_null("/root/Game/UI/Joystick")
	if joy and joy.has_method("get_vector"):
		return joy.get_vector()
	return Vector2.ZERO


func _apply_movement(delta: float) -> void:
	if _move_input != Vector2.ZERO:
		velocity = velocity.move_toward(_move_input * max_speed, acceleration * delta)
		# Tilt sprite slightly based on horizontal movement
		_sprite.rotation = lerp(_sprite.rotation, _move_input.x * 0.3, 10 * delta)
		_engine_particles.emitting = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_sprite.rotation = lerp(_sprite.rotation, 0.0, 10 * delta)
		_engine_particles.emitting = false

	move_and_slide()
	# Clamp to screen
	var margin := 30.0
	global_position.x = clamp(global_position.x, margin, _screen_size.x - margin)
	global_position.y = clamp(global_position.y, margin, _screen_size.y - margin)


func _handle_fire() -> void:
	# Auto-fire when playing
	if _can_fire:
		_fire()
		_can_fire = false
		_fire_timer.start()


func _handle_invincibility(delta: float) -> void:
	if _is_invincible:
		_invincible_timer -= delta
		_sprite.visible = fmod(_invincible_timer, 0.2) > 0.1
		if _invincible_timer <= 0:
			_is_invincible = false
			_sprite.visible = true


func _fire() -> void:
	# Fire pattern based on weapon level
	match weapon_level:
		1:
			_spawn_bullet(_muzzle.global_position, Vector2.UP)
		2:
			_spawn_bullet(_muzzle.global_position + Vector2(-12, 0), Vector2.UP)
			_spawn_bullet(_muzzle.global_position + Vector2(12, 0), Vector2.UP)
		3:
			_spawn_bullet(_muzzle.global_position, Vector2.UP)
			_spawn_bullet(_muzzle.global_position + Vector2(-15, 5), Vector2(-0.2, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(15, 5), Vector2(0.2, -1).normalized())
		_:
			# Level 4+: spread shot
			_spawn_bullet(_muzzle.global_position, Vector2.UP)
			_spawn_bullet(_muzzle.global_position + Vector2(-15, 5), Vector2(-0.3, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(15, 5), Vector2(0.3, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(-20, 10), Vector2(-0.5, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(20, 10), Vector2(0.5, -1).normalized())
	AudioManager.play_sfx("shoot")
	# Muzzle flash
	EffectsManager.flash(_muzzle.global_position, Color(0.3, 0.8, 1.0), 0.08)


func _spawn_bullet(pos: Vector2, dir: Vector2) -> void:
	var bullet := _bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.direction = dir
	bullet.damage = bullet_damage
	bullet.is_player_bullet = true
	get_tree().current_scene.add_child(bullet)


func _on_fire_timer() -> void:
	_can_fire = true


# ---------------- PowerUp Collection ----------------

func collect_powerup(type: int) -> void:
	match type:
		GameManager.PowerUpType.RAPID:
			_activate_rapid_fire(6.0)
		GameManager.PowerUpType.SPREAD:
			_upgrade_weapon()
		GameManager.PowerUpType.SHIELD:
			_activate_shield(6.0)
		GameManager.PowerUpType.BOMB:
			_trigger_bomb()
		GameManager.PowerUpType.LASER:
			_activate_laser(5.0)
		GameManager.PowerUpType.TIME_SLOW:
			_activate_time_slow(4.0)
		GameManager.PowerUpType.LIGHTNING:
			_trigger_lightning()


func _upgrade_weapon() -> void:
	weapon_level = min(weapon_level + 1, 4)
	weapon_changed.emit(weapon_level)
	EffectsManager.flash(global_position, Color(0.2, 1.0, 0.5), 0.15)
	EffectsManager.shake(3.0, 0.1)


func _activate_rapid_fire(duration: float) -> void:
	rapid_fire_timer = duration
	fire_rate = _base_fire_rate * 2.0
	_fire_timer.wait_time = 1.0 / fire_rate
	_create_rapid_effect()


func _activate_shield(duration: float) -> void:
	shield_timer = duration
	_is_invincible = true
	shield_activated.emit(duration)
	_create_shield_effect()


func _trigger_bomb() -> void:
	bomb_triggered.emit()
	EffectsManager.shake(30.0, 0.8)
	EffectsManager.screen_flash(Color(1, 0.5, 0.2), 0.4)
	# Clear all enemies and enemy bullets on screen
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and enemy.has_method("die"):
			enemy.die()
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
	AudioManager.play_sfx("explosion")


func _create_rapid_effect() -> void:
	if _rapid_effect:
		return
	_rapid_effect = Node2D.new()
	_rapid_effect.name = "RapidEffect"
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(Vector2(cos(a), sin(a)) * 35)
	ring.polygon = pts
	ring.color = Color(1.0, 0.9, 0.2, 0.3)
	_rapid_effect.add_child(ring)
	add_child(_rapid_effect)


func _remove_rapid_effect() -> void:
	if _rapid_effect:
		_rapid_effect.queue_free()
		_rapid_effect = null


func _create_shield_effect() -> void:
	if _shield_effect:
		return
	_shield_effect = Node2D.new()
	_shield_effect.name = "ShieldEffect"
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		pts.append(Vector2(cos(a), sin(a)) * 40)
	ring.polygon = pts
	ring.color = Color(0.3, 0.6, 1.0, 0.4)
	_shield_effect.add_child(ring)
	var glow := PointLight2D.new()
	glow.color = Color(0.3, 0.6, 1.0)
	glow.energy = 1.5
	glow.texture_scale = 2.0
	_shield_effect.add_child(glow)
	add_child(_shield_effect)


func _remove_shield_effect() -> void:
	if _shield_effect:
		_shield_effect.queue_free()
		_shield_effect = null
	_is_invincible = false


func take_damage() -> void:
	if _is_invincible:
		return
	player_hit.emit()
	EffectsManager.shake(8.0, 0.3)
	EffectsManager.flash(global_position, Color(1.0, 0.3, 0.3), 0.2)
	AudioManager.play_sfx("hit")

	var died := GameManager.lose_life()
	if died:
		die()
	else:
		_start_invincibility()


func _start_invincibility() -> void:
	_is_invincible = true
	_invincible_timer = invincible_duration


func die() -> void:
	# Reset global time scale in case time slow was active
	Engine.time_scale = 1.0
	time_slow_timer = 0.0
	laser_timer = 0.0
	_remove_laser_effect()
	EffectsManager.shake(20.0, 0.6)
	EffectsManager.explosion(global_position, Color(0.3, 0.8, 1.0))
	AudioManager.play_sfx("explosion")
	player_died.emit()
	queue_free()


func revive() -> void:
	# Reset weapon and buffs on respawn
	weapon_level = 1
	rapid_fire_timer = 0.0
	shield_timer = 0.0
	laser_timer = 0.0
	time_slow_timer = 0.0
	Engine.time_scale = 1.0
	fire_rate = _base_fire_rate
	_fire_timer.wait_time = 1.0 / fire_rate
	_remove_rapid_effect()
	_remove_shield_effect()
	_remove_laser_effect()
	weapon_changed.emit(weapon_level)
	_start_invincibility()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
		take_damage()
	elif area.is_in_group("enemy"):
		take_damage()


# ---------------- LASER ----------------

func _activate_laser(duration: float) -> void:
	laser_timer = duration
	_create_laser_effect()
	AudioManager.play_sfx("explosion")
	EffectsManager.screen_flash(Color(1.0, 0.2, 0.8, 0.3), 0.2)
	EffectsManager.shake(5.0, 0.2)


func _handle_laser(delta: float) -> void:
	if laser_timer > 0:
		laser_timer -= delta
		# Continuous damage to enemies in laser beam path
		_damage_enemies_in_laser()
		if laser_timer <= 0:
			_remove_laser_effect()
	elif _laser_effect:
		_remove_laser_effect()


func _damage_enemies_in_laser() -> void:
	var beam_x := global_position.x
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		if abs(enemy.global_position.x - beam_x) < 30 and enemy.global_position.y < global_position.y:
			if enemy.has_method("take_damage"):
				enemy.take_damage(3)
				EffectsManager.flash(enemy.global_position, Color(1, 0.2, 0.8), 0.05)
	# Also destroy enemy bullets in the beam
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		if is_instance_valid(bullet) and abs(bullet.global_position.x - beam_x) < 30:
			bullet.queue_free()


func _create_laser_effect() -> void:
	if _laser_effect:
		return
	_laser_effect = Node2D.new()
	_laser_effect.name = "LaserEffect"
	# Main beam
	var beam := Polygon2D.new()
	beam.polygon = PackedVector2Array([
		Vector2(-15, -2000), Vector2(15, -2000),
		Vector2(15, -10), Vector2(-15, -10)
	])
	beam.color = Color(1.0, 0.2, 0.8, 0.5)
	_laser_effect.add_child(beam)
	# Inner bright core
	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-5, -2000), Vector2(5, -2000),
		Vector2(5, -10), Vector2(-5, -10)
	])
	core.color = Color(1.0, 0.9, 1.0, 0.9)
	_laser_effect.add_child(core)
	# Glow
	var glow := PointLight2D.new()
	glow.color = Color(1.0, 0.2, 0.8)
	glow.energy = 4.0
	glow.texture_scale = 3.0
	_laser_effect.add_child(glow)
	add_child(_laser_effect)


func _remove_laser_effect() -> void:
	if _laser_effect:
		_laser_effect.queue_free()
		_laser_effect = null


# ---------------- TIME SLOW ----------------

func _activate_time_slow(duration: float) -> void:
	time_slow_timer = duration
	Engine.time_scale = 0.3
	EffectsManager.screen_flash(Color(0.5, 0.8, 1.0, 0.3), 0.3)
	AudioManager.play_sfx("hit")


func _handle_time_slow(delta: float) -> void:
	if time_slow_timer > 0:
		time_slow_timer -= delta
		if time_slow_timer <= 0:
			Engine.time_scale = 1.0


# ---------------- LIGHTNING ----------------

func _trigger_lightning() -> void:
	EffectsManager.screen_flash(Color(1.0, 0.9, 0.3), 0.2)
	EffectsManager.shake(15.0, 0.4)
	AudioManager.play_sfx("explosion")
	var enemies := get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return
	# Find nearest enemy as starting point
	var start_enemy: Node2D = null
	var min_dist := INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var d := global_position.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			start_enemy = enemy
	if not start_enemy:
		return
	# Chain lightning to nearby enemies
	var hit_enemies: Array = [start_enemy]
	var current: Node2D = start_enemy
	var chain_count: int = min(enemies.size(), 8)  # up to 8 chains
	_draw_lightning(global_position, current.global_position)
	if current.has_method("die"):
		current.die()
	for i in range(chain_count - 1):
		var next_enemy: Node2D = null
		var nearest_dist := INF
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if not is_instance_valid(enemy) or enemy in hit_enemies:
				continue
			var d := current.global_position.distance_to(enemy.global_position)
			if d < nearest_dist and d < 250:
				nearest_dist = d
				next_enemy = enemy
		if next_enemy == null:
			break
		_draw_lightning(current.global_position, next_enemy.global_position)
		if next_enemy.has_method("die"):
			next_enemy.die()
		hit_enemies.append(next_enemy)
		current = next_enemy


func _draw_lightning(from: Vector2, to: Vector2) -> void:
	# Draw jagged lightning bolt between two points
	var bolt := Line2D.new()
	bolt.width = 4.0
	bolt.default_color = Color(1.0, 0.9, 0.3)
	bolt.joint_mode = Line2D.LINE_JOINT_ROUND
	var segments := 8
	var direction := (to - from)
	var perpendicular := Vector2(-direction.y, direction.x).normalized()
	for i in range(segments + 1):
		var t := float(i) / segments
		var pos := from.lerp(to, t)
		if i > 0 and i < segments:
			pos += perpendicular * randf_range(-20, 20)
		bolt.add_point(pos)
	get_tree().current_scene.add_child(bolt)
	# Fade out and remove
	var tween := create_tween()
	tween.tween_property(bolt, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bolt.queue_free)
	# Flash at target
	EffectsManager.flash(to, Color(1.0, 0.9, 0.3), 0.1)
