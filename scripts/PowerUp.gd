extends Area2D
## PowerUp - collectible item dropped by enemies.
## Types: RAPID (fire rate), SPREAD (multi-shot), SHIELD (temp invincibility), BOMB (clear screen).

signal collected(type: int)

## 자석이 작동하는 거리와 끌어당기는 속도.
## ⚠️ 범위를 크게 잡으면 아이템이 전부 저절로 들어와 **판이 통째로 쉬워진다.**
##    실측: 220 유닛에서 생존이 87/110/70% → 129/131/122% 로 무너졌다(파워업 획득량이 급증).
##    목적은 "아이템을 쫓다 시선이 단어에서 떠나는 것" 을 막는 것뿐이니,
##    마지막 순간에 착 붙는 정도면 충분하다.
const MAGNET_RANGE := 105.0
const MAGNET_SPEED := 330.0

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
	# 자석: 기체가 가까우면 끌려간다.
	# ⚠️ 장르 표준 기법이다(뱀파이어 서바이버즈·슈팅 전반). 아이템을 "쫓아가서 먹는" 대신
	#    "빨려 들어오게" 하면 만족감이 크게 오르고, 이 게임에서는 특히 중요하다 —
	#    아이템을 쫓다 보면 시선이 단어에서 떠난다.
	var player := get_tree().get_first_node_in_group("player")
	if player != null and is_instance_valid(player):
		var to_player: Vector2 = player.global_position - global_position
		var dist := to_player.length()
		if dist < MAGNET_RANGE and dist > 1.0:
			# 가까울수록 빠르게 — 마지막 순간에 착 붙는 느낌이 난다.
			var pull: float = MAGNET_SPEED * (1.0 - dist / MAGNET_RANGE) + MAGNET_SPEED * 0.35
			global_position += to_player / dist * pull * delta
			_sprite.rotation += delta * 6.0
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
