extends Control
## Virtual touch joystick for mobile controls.
## Dynamic: appears where the player touches on the control area.

signal joystick_moved(vector: Vector2)

@export var max_distance: float = 120.0
@export var deadzone: float = 0.1

var _touch_index: int = -1
var _touch_origin: Vector2 = Vector2.ZERO
var _vector: Vector2 = Vector2.ZERO
var _pause_button: Control

@onready var _base: ColorRect = $Base
@onready var _stick: ColorRect = $Stick


func _ready() -> void:
	# Direct drag-to-follow steering is handled by Player._unhandled_input.
	# Virtual joystick is disabled (node kept in the scene tree for compatibility).
	set_process_input(false)
	_hide_joystick()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			if _is_in_control_area(event.position):
				_touch_index = event.index
				_touch_origin = event.position
				_show_joystick(_touch_origin)
		elif not event.pressed and event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_stick(event.position)


func _is_in_control_area(pos: Vector2) -> bool:
	# Allow steering from anywhere on the screen. Only skip taps that land on
	# interactive UI (the pause button) so it stays clickable. HUD labels are
	# non-interactive, so dragging over them is fine.
	if _pause_button and _pause_button.get_global_rect().grow(28.0).has_point(pos):
		return false
	return true


func _show_joystick(pos: Vector2) -> void:
	_base.position = pos - _base.size / 2
	_base.visible = true
	_stick.position = pos - _stick.size / 2
	_stick.visible = true


func _hide_joystick() -> void:
	_base.visible = false
	_stick.visible = false


func _update_stick(touch_pos: Vector2) -> void:
	var offset := touch_pos - _touch_origin
	var dist := offset.length()
	if dist > max_distance:
		offset = offset.normalized() * max_distance
	_stick.position = _touch_origin + offset - _stick.size / 2
	_vector = offset / max_distance
	if _vector.length() < deadzone:
		_vector = Vector2.ZERO
	joystick_moved.emit(_vector)


func _reset() -> void:
	_touch_index = -1
	_vector = Vector2.ZERO
	joystick_moved.emit(Vector2.ZERO)
	_hide_joystick()


func get_vector() -> Vector2:
	return _vector


func _make_base() -> ColorRect:
	var rect := ColorRect.new()
	rect.size = Vector2(160, 160)
	rect.color = Color(0.3, 0.6, 1.0, 0.15)
	rect.z_index = 50
	return rect


func _make_stick() -> ColorRect:
	var rect := ColorRect.new()
	rect.size = Vector2(70, 70)
	rect.color = Color(0.3, 0.9, 1.0, 0.6)
	rect.z_index = 51
	return rect