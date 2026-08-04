extends Node
## EffectsManager (Autoload)
## Screen shake, flash, and particle explosion effects.

var _camera: Camera2D = null
var _shake_amount: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _shake_offset: Vector2 = Vector2.ZERO

var _flash_layer: CanvasLayer
var _flash_rect: ColorRect
var _explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")


func _ready() -> void:
	_create_flash_layer()


func _process(delta: float) -> void:
	if _shake_timer > 0:
		_shake_timer -= delta
		var intensity := _shake_amount * (_shake_timer / _shake_duration)
		_shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		if _camera:
			_camera.offset = _shake_offset
		if _shake_timer <= 0:
			_shake_offset = Vector2.ZERO
			if _camera:
				_camera.offset = Vector2.ZERO


func set_camera(cam: Camera2D) -> void:
	_camera = cam
	# Reset any lingering shake offset from previous scene
	_shake_timer = 0.0
	_shake_amount = 0.0
	_shake_offset = Vector2.ZERO


func shake(amount: float, duration: float) -> void:
	_shake_amount = max(_shake_amount, amount)
	_shake_duration = max(_shake_duration, duration)
	_shake_timer = max(_shake_timer, duration)


func flash(position: Vector2, color: Color, duration: float = 0.1) -> void:
	var flash_node := _explosion_scene.instantiate() as Node2D
	if flash_node:
		flash_node.global_position = position
		flash_node.modulate = color
		get_tree().current_scene.add_child(flash_node)
		if flash_node.has_method("play_flash"):
			flash_node.play_flash(duration)
		elif flash_node.has_method("play"):
			flash_node.play(duration)
		else:
			flash_node.queue_free()


func explosion(position: Vector2, color: Color = Color(1.0, 0.5, 0.2)) -> void:
	var expl := _explosion_scene.instantiate() as Node2D
	if expl:
		expl.global_position = position
		expl.modulate = color
		get_tree().current_scene.add_child(expl)
		if expl.has_method("play_explosion"):
			expl.play_explosion()
		elif expl.has_method("play"):
			expl.play(0.6)
		else:
			expl.queue_free()
	# Extra screen punch
	shake(12.0, 0.25)


func _create_flash_layer() -> void:
	_flash_layer = CanvasLayer.new()
	_flash_layer.layer = 90
	_flash_layer.name = "FlashLayer"
	add_child(_flash_layer)

	_flash_rect = ColorRect.new()
	_flash_rect.color = Color.WHITE
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.modulate.a = 0.0
	_flash_layer.add_child(_flash_rect)


func screen_flash(color: Color = Color.WHITE, duration: float = 0.15) -> void:
	_flash_rect.color = color
	var tween := create_tween()
	tween.tween_property(_flash_rect, "modulate:a", 0.7, duration * 0.3)
	tween.tween_property(_flash_rect, "modulate:a", 0.0, duration * 0.7)