extends Control
## PausePanel - pause menu with resume and quit options.

signal resume_requested
signal quit_requested

@onready var _panel: Panel = $Panel
@onready var _resume_button: Button = $Panel/ResumeButton
@onready var _quit_button: Button = $Panel/QuitButton


func _ready() -> void:
	_resume_button.pressed.connect(_on_resume)
	_quit_button.pressed.connect(_on_quit)
	hide_panel()


func show_panel() -> void:
	visible = true
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.85, 0.85)
	_panel.pivot_offset = _panel.size / 2
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_panel() -> void:
	visible = false


func _on_resume() -> void:
	AudioManager.play_sfx("button")
	hide_panel()
	resume_requested.emit()


func _on_quit() -> void:
	AudioManager.play_sfx("button")
	hide_panel()
	quit_requested.emit()