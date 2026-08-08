extends CharacterBody2D
## Player ship - movement (touch joystick + keyboard), auto-fire, collision.

signal player_died
signal player_hit
signal weapon_changed(weapon_level: int)
signal powerup_collected(type: int)
signal shield_activated(duration: float)
signal bomb_triggered

enum WeaponType { SINGLE, DOUBLE, TRIPLE, SPREAD }

@export var max_speed: float = 700.0
@export var acceleration: float = 3600.0
@export var friction: float = 3000.0
@export var fire_rate: float = 8.0  # shots per second
@export var bullet_damage: int = 1
@export var invincible_duration: float = 1.0
## 손가락과 기체 사이의 최소 세로 간격(px). 이보다 가까이 잡아도 기체는 이만큼 위에 뜬다.
## 130~150 이면 기체와 바로 앞 탄이 손가락에 가리지 않고 함께 보인다.
@export var touch_lift: float = 140.0

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
var _is_touching: bool = false
var _touch_offset: Vector2 = Vector2.ZERO
var _target_pos: Vector2 = Vector2.ZERO
var _invincible_timer: float = 0.0
## 기체 위에 붙는 '지금 쏴야 할 글자' 라벨.
var _target_letter_label: Label = null


func _ready() -> void:
	_screen_size = get_viewport_rect().size
	# 시작 위치는 화면 비율로 잡는다(함정 3). Game.tscn 의 Vector2(360, 960) 은 720x1280 전용이라
	# 세로가 긴 기기(예: 1080x2316 = 1:2.14)에서는 화면의 62% 지점 — 거의 한가운데에 떠 있었다.
	# 부활 경로(Game._respawn_player)가 쓰는 0.75 와 같은 비율로 맞춘다.
	global_position = Vector2(_screen_size.x * 0.5, _screen_size.y * 0.75)
	_base_fire_rate = fire_rate
	_fire_timer.wait_time = 1.0 / fire_rate
	_fire_timer.timeout.connect(_on_fire_timer)
	add_to_group("player")
	collision_layer = 1  # player layer
	collision_mask = 2 | 16  # enemy + pickup
	_create_target_letter()


# ---------------- 타겟 글자 표시 ----------------

## 지금 쏴야 할 글자를 **기체 바로 위**에 띄운다.
##
## 폰에서는 단어 표시(화면 상단)와 기체(75% 지점)가 화면 높이의 65%,
## 6.5인치 기준 약 9~10cm 떨어져 있다. 피하면서 단어를 읽으려면 시선이 위아래로 왕복한다.
## 게다가 플레이 중 실제로 필요한 정보는 전체 단어가 아니라 **다음 글자 하나**다
## (적들이 글자를 달고 내려오고, 그중 맞는 것을 고른다).
## 전체 단어는 상단에 맥락으로 두고, 조준에 쓰는 글자만 액션 옆으로 가져온다.
func _create_target_letter() -> void:
	_target_letter_label = Label.new()
	_target_letter_label.name = "TargetLetter"
	_target_letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_target_letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_target_letter_label.add_theme_font_size_override("font_size", 34)
	_target_letter_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))
	_target_letter_label.add_theme_color_override("font_outline_color", Color(0.25, 0.15, 0.0))
	_target_letter_label.add_theme_constant_override("outline_size", 8)
	# 기체 바로 위 중앙. 손가락은 기체 아래(touch_lift)에 있으므로 가려지지 않는다.
	_target_letter_label.size = Vector2(120, 44)
	_target_letter_label.position = Vector2(-60, -86)
	_target_letter_label.z_index = 5
	add_child(_target_letter_label)
	_refresh_target_letter()
	WordManager.word_progress_updated.connect(func(_f, _t): _refresh_target_letter())
	WordManager.new_word_started.connect(func(_w): _refresh_target_letter())


func _refresh_target_letter() -> void:
	if _target_letter_label == null:
		return
	_target_letter_label.text = WordManager.get_target_letter()


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

	# Touch steering is handled directly in _unhandled_input (drag-to-follow).
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
	# NOTE: AI is intentionally imperfect to simulate human reaction time / mistakes.
	# ai_dodge_error (0.0=perfect, 1.0=never dodges) adds realism for balance tuning.
	var dodge_error: float = GameManager.ai_dodge_error
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
				# AI occasionally fails to dodge (simulates human imperfection)
				if randf() < dodge_error:
					continue
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


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.auto_play:
		return
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	# Direct drag-to-follow: the ship sticks under the finger. On press we capture
	# the gap between the finger and the ship so dragging mirrors finger motion 1:1.
	if event is InputEventScreenTouch:
		if event.pressed and not _is_touching:
			_is_touching = true
			_touch_offset = global_position - event.position
			# ⚠️ 기체를 손가락 위로 띄운다.
			# 상대 위치만 잡으면 플레이어가 본능적으로 기체를 직접 눌렀을 때 오프셋이 0이 되어
			# 그 판 내내 **엄지가 기체를 덮는다.** 실측 환산으로 손가락 접촉면은 지름 82~103px,
			# 기체는 43x36px — 손가락이 기체보다 2배 이상 커서 자기 위치도, 코앞의 탄도 안 보인다.
			# 아래에서 잡았을 때만 보정하고(위에서 잡으면 그 간격을 존중), 이동은 기존 추종
			# 로직이 부드럽게 처리하므로 튀지 않는다.
			_touch_offset.y = minf(_touch_offset.y, -touch_lift)
			_target_pos = global_position
		elif not event.pressed:
			_is_touching = false
	elif event is InputEventScreenDrag and _is_touching:
		_target_pos = event.position + _touch_offset


func _apply_movement(delta: float) -> void:
	if _is_touching:
		# Drag-to-follow: fly toward the finger at FULL speed regardless of
		# distance. The previous limit_length() approach caused the ship to crawl
		# whenever the finger was close — now we always use max_speed, only
		# clipping the last step so we never overshoot the target.
		var to_target := _target_pos - global_position
		var dist := to_target.length()
		if dist > 1.0:
			var dir := to_target / dist
			var step := max_speed * delta
			if dist > step:
				velocity = dir * max_speed
			else:
				# Within one frame of the finger — cover exactly the remaining gap.
				velocity = to_target / delta
		else:
			velocity = Vector2.ZERO
		_sprite.rotation = lerp(_sprite.rotation, clampf(velocity.x / max_speed, -1.0, 1.0) * 0.3, 10 * delta)
		_engine_particles.emitting = velocity.length() > 10.0
	else:
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
	AudioManager.play_shoot(weapon_level)
	# Muzzle flash
	EffectsManager.flash(_muzzle.global_position, Color(0.3, 0.8, 1.0), 0.08)


func _spawn_bullet(pos: Vector2, dir: Vector2) -> void:
	var bullet := _bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.direction = dir
	bullet.damage = bullet_damage
	bullet.is_player_bullet = true
	# 적과 같은 화면 높이 보정. 세로가 긴 기기에서 총알이 화면을 가로지르는 시간이
	# 늘어나면 사거리 체감과 교전 리듬이 달라진다.
	bullet.speed *= GameManager.screen_speed_scale()
	get_tree().current_scene.add_child(bullet)


func _on_fire_timer() -> void:
	_can_fire = true


# ---------------- PowerUp Collection ----------------

func collect_powerup(type: int) -> void:
	powerup_collected.emit(type)
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
