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


## 게임오버 화면의 "한 판 더" 유인 문구. 씬에 노드를 추가하는 대신 코드로 만든다
## (Game.tscn 의 패널 레이아웃을 건드리지 않기 위해).
var _nudge: Label = null


func _ready() -> void:
	_create_nudge()
	_restart_button.pressed.connect(_on_restart)
	_revive_button.pressed.connect(_on_revive)
	_menu_button.pressed.connect(_on_menu)
	hide_panel()


func show_panel(score: int, high_score: int, can_revive: bool) -> void:
	_score_label.text = "SCORE  %06d" % score
	_high_score_label.text = "BEST   %06d" % high_score
	_new_record.visible = score >= high_score and score > 0
	_update_nudge()
	_revive_button.visible = can_revive
	if can_revive:
		_revive_button.text = "▶ WATCH AD & REVIVE"
	_revive_button.disabled = false
	visible = true
	_animate_in()


func _create_nudge() -> void:
	_nudge = Label.new()
	_nudge.name = "RewardNudge"
	_nudge.set_anchors_preset(Control.PRESET_TOP_LEFT)
	# MenuButton(bottom 480) 아래 남은 자리.
	_nudge.offset_left = 0.0
	_nudge.offset_top = 492.0
	_nudge.offset_right = 560.0
	_nudge.offset_bottom = 532.0
	_nudge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nudge.add_theme_font_size_override("font_size", 21)
	_nudge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_panel.add_child(_nudge)


## 게임오버는 그만둘지 한 판 더 할지 정하는 순간이다. 여기서 "얼마 안 남았다"를 보여준다.
func _update_nudge() -> void:
	if _nudge == null:
		return
	if not RewardManager.get_claimable().is_empty():
		_nudge.text = "🎁 REWARD READY — CHECK THE MENU"
		return
	var left := RewardManager.DAILY_GOAL_SECONDS - RewardManager.today_seconds
	if left > 0.0:
		_nudge.text = "▸ %d:%02d MORE TODAY → POWER +5%%" % [int(left) / 60, int(left) % 60]
		return
	# 오늘 몫은 끝났다 — 다음 연속 마일스톤까지 며칠 남았는지 보여준다.
	for m in RewardManager.STREAK_MILESTONES:
		if RewardManager.streak_days < m:
			var days: int = m - RewardManager.streak_days
			# 다음에 받을 기체 이름을 박아 준다 — "며칠 남음"보다 물건이 보이는 쪽이 세다.
			var skin := ShipSkins.by_streak(m)
			var what: String = String(skin["name_en"]) if not skin.is_empty() else "%d-DAY" % m
			_nudge.text = "🔥 %d DAY%s TO THE %s SHIP" % [
				days, "" if days == 1 else "S", what]
			return
	_nudge.text = "🔥 %d DAY STREAK — KEEP IT UP" % RewardManager.streak_days


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