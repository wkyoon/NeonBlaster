extends Label
## ScorePopup - floating "+points" text that rises and fades.

var _age: float = 0.0
var _duration: float = 0.8
var _start_pos: Vector2


func _init() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func setup(points: int, pos: Vector2, color: Color = Color(1, 0.9, 0.3)) -> void:
	text = "+%d" % points
	if points >= 50:
		text = "%s!" % text
	add_theme_font_size_override("font_size", 28 if points < 50 else 36)
	add_theme_color_override("font_color", color)
	z_index = 100
	_start_pos = pos
	global_position = pos - size / 2.0


func _process(delta: float) -> void:
	_age += delta
	var t := _age / _duration
	# Rise upward
	global_position.y = _start_pos.y - 60.0 * t
	# Scale pop: quick grow then settle
	var s := 1.0
	if t < 0.2:
		s = lerp(0.5, 1.2, t / 0.2)
	else:
		s = lerp(1.2, 1.0, (t - 0.2) / 0.3)
	scale = Vector2(s, s)
	# Fade out in last 40%
	if t > 0.6:
		modulate.a = 1.0 - (t - 0.6) / 0.4
	if _age >= _duration:
		queue_free()