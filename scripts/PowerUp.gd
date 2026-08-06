extends Area2D
## PowerUp - collectible item dropped by enemies.
## Types: RAPID (fire rate), SPREAD (multi-shot), SHIELD (temp invincibility), BOMB (clear screen).

signal collected(type: int)

@export var type: int = GameManager.PowerUpType.RAPID
@export var move_speed: float = 80.0
@export var lifetime: float = 8.0

var _age: float = 0.0

@onready var _sprite: Polygon2D = $Sprite
@onready var _glow: PointLight2D = $Glow


func _ready() -> void:
	collision_layer = 16  # pickup layer
	collision_mask = 1    # player layer
	add_to_group("pickup")
	_configure_visual()
	body_entered.connect(_on_body_entered)


func _configure_visual() -> void:
	match type:
		GameManager.PowerUpType.RAPID:
			_sprite.color = Color(1.0, 0.9, 0.2)  # yellow
			_glow.color = Color(1.0, 0.9, 0.2)
			_sprite.polygon = _make_star(14)
		GameManager.PowerUpType.SPREAD:
			_sprite.color = Color(0.2, 1.0, 0.5)  # green
			_glow.color = Color(0.2, 1.0, 0.5)
			_sprite.polygon = _make_diamond(14)
		GameManager.PowerUpType.SHIELD:
			_sprite.color = Color(0.3, 0.6, 1.0)  # blue
			_glow.color = Color(0.3, 0.6, 1.0)
			_sprite.polygon = _make_hexagon(14)
		GameManager.PowerUpType.BOMB:
			_sprite.color = Color(1.0, 0.3, 0.3)  # red
			_glow.color = Color(1.0, 0.3, 0.3)
			_sprite.polygon = _make_circle(14)
		GameManager.PowerUpType.LASER:
			_sprite.color = Color(1.0, 0.2, 0.8)  # magenta
			_glow.color = Color(1.0, 0.2, 0.8)
			_sprite.polygon = _make_lightning(14)
		GameManager.PowerUpType.TIME_SLOW:
			_sprite.color = Color(0.5, 0.8, 1.0)  # cyan-white
			_glow.color = Color(0.5, 0.8, 1.0)
			_sprite.polygon = _make_clock(14)
		GameManager.PowerUpType.LIGHTNING:
			_sprite.color = Color(1.0, 0.9, 0.3)  # bright yellow
			_glow.color = Color(1.0, 0.9, 0.3)
			_glow.energy = 3.0
			_sprite.polygon = _make_lightning(14)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	# Drift downward slowly
	global_position.y += move_speed * delta
	# Gentle rotation
	_sprite.rotation += delta * 2.0
	# Blink when about to expire
	if _age > lifetime - 2.0:
		_sprite.visible = fmod(_age, 0.2) > 0.1
	# Despawn off-screen bottom
	if global_position.y > get_viewport_rect().size.y + 40:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		collected.emit(type)
		if body.has_method("collect_powerup"):
			body.collect_powerup(type)
		AudioManager.play_sfx("powerup")
		EffectsManager.flash(global_position, _sprite.color, 0.1)
		queue_free()


# --- Shape generators ---

func _make_star(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var angle := TAU * i / 10.0 - PI / 2.0
		var r := size if i % 2 == 0 else size * 0.5
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	return pts


func _make_diamond(size: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, size), Vector2(size, 0),
		Vector2(0, -size), Vector2(-size, 0)
	])


func _make_hexagon(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := TAU * i / 6.0
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	return pts


func _make_circle(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var count := 16
	for i in count:
		var angle := TAU * i / float(count)
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	return pts


func _make_lightning(size: float) -> PackedVector2Array:
	# Lightning bolt zigzag shape
	return PackedVector2Array([
		Vector2(-size * 0.3, -size),
		Vector2(size * 0.4, -size * 0.2),
		Vector2(0, -size * 0.1),
		Vector2(size * 0.5, size),
		Vector2(-size * 0.3, size * 0.2),
		Vector2(size * 0.1, size * 0.1),
	])


func _make_clock(size: float) -> PackedVector2Array:
	# Clock shape (circle + hands)
	var pts := PackedVector2Array()
	var count := 12
	for i in count:
		var angle := TAU * i / float(count) - PI / 2.0
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	# Add clock hand indentations
	pts.append(Vector2(0, -size * 0.5))
	pts.append(Vector2(size * 0.5, 0))
	return pts
