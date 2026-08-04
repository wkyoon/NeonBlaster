extends Area2D
## Bullet - travels in a direction, damages on collision, auto-despawns off-screen.

@export var speed: float = 800.0
@export var damage: int = 1
@export var lifetime: float = 2.5

var direction: Vector2 = Vector2.UP
var is_player_bullet: bool = true
var _age: float = 0.0
var _consumed: bool = false  # 충돌 후 중복 처리 방지

@onready var _sprite: Polygon2D = $Sprite
@onready var _trail: Line2D = $Trail
@onready var _glow: PointLight2D = $Glow


func _ready() -> void:
	# Set collision layers
	if is_player_bullet:
		collision_layer = 4   # bullet_player
		collision_mask = 2    # enemy
		add_to_group("player_bullet")
		_sprite.color = Color(0.3, 0.9, 1.0)
		_glow.color = Color(0.3, 0.9, 1.0)
	else:
		collision_layer = 8   # bullet_enemy
		collision_mask = 1    # player
		add_to_group("enemy_bullet")
		_sprite.color = Color(1.0, 0.4, 0.3)
		_glow.color = Color(1.0, 0.4, 0.3)

	_trail.clear_points()
	_trail.add_point(global_position)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	global_position += direction * speed * delta
	# Update trail
	_trail.add_point(global_position)
	if _trail.get_point_count() > 6:
		_trail.remove_point(0)
	# Despawn if off-screen
	var screen := get_viewport_rect()
	if not screen.grow(100).has_point(global_position):
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _consumed:
		return
	if is_player_bullet and body.is_in_group("enemy"):
		_consumed = true
		_check_letter_hit(body)
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_dissipate()
	elif not is_player_bullet and body.is_in_group("player"):
		_consumed = true
		if body.has_method("take_damage"):
			body.take_damage()
		_dissipate()


func _on_area_entered(area: Area2D) -> void:
	if _consumed:
		return
	# HitArea(Area2D)가 Enemy(CharacterBody2D)의 자식인 경우 부모를 확인
	var target_enemy: Node = area
	if is_player_bullet and not area.is_in_group("enemy"):
		# 부모 노드가 enemy 그룹인지 확인
		var parent := area.get_parent()
		if parent and parent.is_in_group("enemy"):
			target_enemy = parent

	if is_player_bullet and target_enemy.is_in_group("enemy"):
		_consumed = true
		_check_letter_hit(target_enemy)
		if target_enemy.has_method("take_damage"):
			target_enemy.take_damage(damage)
		_dissipate()
	elif not is_player_bullet and area.is_in_group("player"):
		_consumed = true
		if area.has_method("take_damage"):
			area.take_damage()
		_dissipate()


## Check if the hit enemy has the correct target letter
func _check_letter_hit(enemy: Node) -> void:
	if not ("letter" in enemy):
		return
	var hit_letter: String = enemy.letter
	if hit_letter == "":
		return
	var is_correct := WordManager.check_letter(hit_letter)
	if is_correct:
		# Correct letter hit! Green feedback
		EffectsManager.flash(enemy.global_position, Color(0.2, 1.0, 0.5), 0.15)
		EffectsManager.shake(5.0, 0.15)
		AudioManager.play_sfx("enemy_die")
		GameManager.add_score(50)
	else:
		# Wrong letter hit - 콤보 리셋만으로 충분한 페널티
		EffectsManager.flash(enemy.global_position, Color(1.0, 0.3, 0.3), 0.15)
		GameManager.reset_combo()


func _dissipate() -> void:
	EffectsManager.flash(global_position, _sprite.color, 0.06)
	queue_free()