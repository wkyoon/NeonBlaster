extends Control
## GameOverPanel - shows on game over with score, revive (rewarded ad), and restart.

signal restart_requested
signal revive_requested
signal menu_requested

@onready var _panel: Panel = $Panel
@onready var _title: Label = $Panel/Title
@onready var _score_label: Label = $Panel/ScoreLabel
@onready var _high_score_label: Label = $Panel/HighScoreLabel
@onready var _new_record: Label = $Panel/NewRecord
@onready var _restart_button: Button = $Panel/RestartButton
@onready var _revive_button: Button = $Panel/ReviveButton
@onready var _menu_button: Button = $Panel/MenuButton


func _ready() -> void:
	_restart_button.pressed.connect(_on_restart)
	_revive_button.pressed.connect(_on_revive)
	_menu_button.pressed.connect(_on_menu)
	hide_panel()


func show_panel(score: int, high_score: int, can_revive: bool) -> void:
	_score_label.text = "SCORE  %06d" % score
	_high_score_label.text = "BEST   %06d" % high_score
	_new_record.visible = score >= high_score and score > 0
	_revive_button.visible = can_revive
	if can_revive:
		_revive_button.text = "▶ WATCH AD & REVIVE"
	_revive_button.disabled = false
	visible = true
	_animate_in()


func hide_panel() -> void:
	visible = false


func _on_restart() -> void:
	AudioManager.play_sfx("button")
	hide_panel()
	restart_requested.emit()


func _on_revive() -> void:
	AudioManager.play_sfx("button")
	_revive_button.disabled = true
	revive_requested.emit()


func _on_menu() -> void:
	AudioManager.play_sfx("button")
	hide_panel()
	menu_requested.emit()


func _animate_in() -> void:
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.8, 0.8)
	_panel.pivot_offset = _panel.size / 2
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func disable_revive() -> void:
	_revive_button.disabled = true
	_revive_button.text = "NO REVIVES LEFT"