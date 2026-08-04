extends Node2D
## StarField - scrolling parallax star background for depth.

@export var star_count: int = 80
@export var speed: float = 60.0

var _stars: Array = []
var _screen_size: Vector2


func _ready() -> void:
	_screen_size = get_viewport_rect().size
	_generate_stars()


func _generate_stars() -> void:
	for i in star_count:
		var star := {
			pos = Vector2(randf() * _screen_size.x, randf() * _screen_size.y),
			size = randf_range(0.5, 2.5),
			brightness = randf_range(0.3, 1.0),
			speed_mult = randf_range(0.3, 1.0),
		}
		_stars.append(star)


func _process(delta: float) -> void:
	queue_redraw()
	for star in _stars:
		star.pos.y += speed * star.speed_mult * delta
		if star.pos.y > _screen_size.y:
			star.pos.y = -5
			star.pos.x = randf() * _screen_size.x


func _draw() -> void:
	for star in _stars:
		var c := Color(1, 1, 1, star.brightness)
		# Small stars as 1px, bigger as circles
		if star.size < 1.0:
			draw_rect(Rect2(star.pos, Vector2(1, 1)), c)
		else:
			draw_circle(star.pos, star.size, c)