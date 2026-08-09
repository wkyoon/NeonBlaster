extends Control
## MainMenu - title screen with start button and high score display.
## Now includes difficulty selection for Word Blaster mode.

@onready var _title: Label = $Title
@onready var _subtitle: Label = $Subtitle
@onready var _start_button: Button = $StartButton
@onready var _high_score_label: Label = $HighScoreLabel
var _difficulty_buttons: VBoxContainer
var _auto_play_btn: Button = null
var _score_panel: Control = null

var _sfx_btn: Button
var _music_btn: Button
var _tts_btn: Button

## 출석/플레이시간 보상 UI.
var _reward_strip: Button = null
var _reward_panel: Control = null
var _skin_panel: Control = null
var _badge_panel: Control = null
var _consent_panel: Control = null


func _ready() -> void:
	_start_button.pressed.connect(_on_start)
	GameManager.high_score_changed.connect(_update_high_score)
	_update_high_score(GameManager.high_score)
	_animate_title()
	_create_title_emblem()
	_create_difficulty_selector()
	_create_audio_toggles()
	_create_auto_play_toggle()
	_create_bottom_buttons()
	_create_reward_strip()
	_create_reward_panel()
	_create_badge_panel()
	_create_skin_panel()
	_refresh_reward_strip()
	_maybe_ask_consent()


## Create difficulty selection buttons (Easy / Normal / Hard)
## PRESET_CENTER_BOTTOM 은 **앵커만** 중앙에 두고 컨트롤의 크기는 고려하지 않는다.
## 그래서 컨테이너의 왼쪽 끝이 화면 중앙에 붙어 오른쪽으로 넘쳐 나간다.
## 실측(720 폭): 하단 버튼 행이 x 360~999 로 STORY 버튼이 통째로 화면 밖이었고,
## 난이도 버튼과 AUTO PLAY 버튼도 같은 이유로 오른쪽으로 밀려 서로 겹쳤다.
## 크기가 정해질 때마다 폭의 절반만큼 왼쪽으로 당겨 실제로 가운데 정렬한다.
func _center_horizontally(ctl: Control) -> void:
	var apply := func() -> void:
		# position 은 앵커 기준이 아니라 부모 원점 기준 절대값이다.
		# (-size/2 로 두면 화면 중앙이 아니라 x=0 을 중심으로 몰린다 — 실제로 겪음)
		ctl.position.x = (get_viewport_rect().size.x - ctl.size.x) * 0.5
	apply.call()
	ctl.resized.connect(apply)


## 타이틀 위 네온 엠블럼. 로고가 글자뿐이라 게임의 얼굴이 비어 보였다.
## 이미지 에셋 대신 절차적으로 그린다(TitleEmblem) — APK 증가 0, 해상도 무관하게 선명.
func _create_title_emblem() -> void:
	var emblem := TitleEmblem.new()
	emblem.name = "TitleEmblem"
	var vp := get_viewport_rect().size
	# 타이틀(화면 20% 지점) 위쪽에 놓는다.
	emblem.position = Vector2(vp.x * 0.5, vp.y * 0.2 - 150.0)
	add_child(emblem)


## 난이도 선택 대신 **랭크·화력 표시**만 둔다.
## 난이도는 DifficultyDirector 가 최근 판 결과로 알아서 맞춘다 —
## 틈새 시간에 켜는 게임이라 시작 전에 판단을 요구하면 안 된다.
func _create_difficulty_selector() -> void:
	_difficulty_buttons = VBoxContainer.new()
	_difficulty_buttons.name = "DifficultySelector"
	_difficulty_buttons.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_difficulty_buttons.position.y = -300
	_center_horizontally(_difficulty_buttons)
	_difficulty_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_difficulty_buttons.add_theme_constant_override("separation", 6)
	add_child(_difficulty_buttons)

	# 오늘의 목표 생존 시간. 이 게임의 성장 축이라 반드시 보여야 한다 —
	# "매일 하면 1분씩 더 오래 산다"가 화면에 없으면 성장이 안 보인다.
	var goal_label := Label.new()
	goal_label.name = "GoalLabel"
	goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goal_label.add_theme_font_size_override("font_size", 26)
	goal_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.85))
	var secs := int(DifficultyDirector.get_target_seconds())
	goal_label.text = "SURVIVE  %d:%02d" % [secs / 60, secs % 60]
	_difficulty_buttons.add_child(goal_label)

	var hint := Label.new()
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.6, 0.7, 0.85))
	hint.text = "+1 MIN EVERY DAY YOU PLAY"
	_difficulty_buttons.add_child(hint)

	var power_label := Label.new()
	power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	power_label.add_theme_font_size_override("font_size", 16)
	power_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.95))
	power_label.text = "RANK %d/%d   SHIP POWER +%d%%" % [
		RewardManager.get_rank(), RewardManager.MAX_RANK,
		roundi(RewardManager.get_rank_power() * 100.0)]
	_difficulty_buttons.add_child(power_label)


## 보상 수령 등으로 랭크가 바뀌었을 때 다시 만든다.
func _rebuild_difficulty_selector() -> void:
	if _difficulty_buttons != null:
		# ⚠️ queue_free() 만 하면 이 프레임 안에서는 노드가 살아 있어 이름을 계속 붙잡는다.
		#    새로 만든 컨테이너가 다른 이름을 받아 get_node 가 실패한다(실측).
		remove_child(_difficulty_buttons)
		_difficulty_buttons.queue_free()
		_difficulty_buttons = null
	_create_difficulty_selector()


func _create_bottom_buttons() -> void:
	# Row container for Scores + Dictionary + Story buttons
	var container := HBoxContainer.new()
	container.name = "BottomButtons"
	# ⚠️ 버튼 4개다. 205px 로 두면 856px 이 되어 화면(720)을 넘쳐 양끝이 잘린다(실측).
	#    164 x 4 + 간격 12 x 3 = 692 로 맞춘다. 버튼을 더 늘리려면 폭을 다시 계산할 것.
	container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	container.position.y = -145
	_center_horizontally(container)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 12)
	add_child(container)

	var scores_btn := Button.new()
	scores_btn.name = "ScoresButton"
	scores_btn.text = "★ SCORES"
	scores_btn.custom_minimum_size = Vector2(164, 50)
	scores_btn.add_theme_font_size_override("font_size", 18)
	scores_btn.add_theme_color_override("font_color", Color(1.0, 0.75, 0.25))
	scores_btn.focus_mode = Control.FOCUS_NONE
	scores_btn.pressed.connect(_show_score_history)
	container.add_child(scores_btn)

	var dict_btn := Button.new()
	dict_btn.name = "DictionaryButton"
	# 메뉴에서 **다음 목표를 구체적으로** 보여준다.
	# "48개 중 3개" 보다 "ANIMALS 3개 남음" 이 훨씬 강한 동기다.
	var _cp := WordManager.get_collection_progress()
	var _goal := WordManager.get_next_goal()
	if _goal.is_empty():
		dict_btn.text = "📖 %d/%d ★" % [_cp.x, _cp.y]
	else:
		dict_btn.text = "📖 %s -%d" % [_goal["name_en"], _goal["left"]]
	dict_btn.custom_minimum_size = Vector2(164, 50)
	dict_btn.add_theme_font_size_override("font_size", 15)
	dict_btn.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	dict_btn.focus_mode = Control.FOCUS_NONE
	dict_btn.pressed.connect(_on_dictionary)
	container.add_child(dict_btn)

	var story_btn := Button.new()
	story_btn.name = "StoryButton"
	story_btn.text = "✦ STORY"
	story_btn.custom_minimum_size = Vector2(164, 50)
	story_btn.add_theme_font_size_override("font_size", 18)
	story_btn.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	story_btn.focus_mode = Control.FOCUS_NONE
	story_btn.pressed.connect(_on_story)
	container.add_child(story_btn)

	# ⚠️ 상점은 지금 노출하지 않는다. 코드와 화면(scenes/Store.tscn)은 그대로 두고
	#    진입 버튼만 감춘다 — 다시 열 때 이 분기만 되돌리면 된다.
	var SHOW_STORE := false
	var store_btn := Button.new()
	store_btn.name = "StoreButton"
	store_btn.text = "🛒 STORE"
	store_btn.custom_minimum_size = Vector2(164, 50)
	store_btn.add_theme_font_size_override("font_size", 18)
	store_btn.add_theme_color_override("font_color", Color(0.6, 1.0, 0.8))
	store_btn.focus_mode = Control.FOCUS_NONE
	store_btn.pressed.connect(_on_store)
	if SHOW_STORE:
		container.add_child(store_btn)
	else:
		store_btn.queue_free()

	_create_sfx_lab_button()
	_create_score_panel()


## SFX 후보 비교 화면 진입 버튼 (개발용). 우측 상단 구석에 작게 배치.
## ⚠️ 개발 도구다. **디버그 빌드에서만** 보인다.
## 지우지는 않는다 — 효과음 비교(SfxLab)와 자동 플레이(벤치마크)는 개발에 계속 쓴다.
## `OS.is_debug_build()` 는 에디터·디버그 export 에서 true, 릴리스 export 에서 false 다.
func _create_sfx_lab_button() -> void:
	if not OS.is_debug_build():
		return
	var btn := Button.new()
	btn.name = "SfxLabButton"
	btn.text = "🔊 SFX"
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	# 오디오 토글(y 20~64) 아래로. 예전 위치(y14)는 TTS 버튼과 겹쳤다.
	btn.position = Vector2(-104, 74)
	btn.custom_minimum_size = Vector2(90, 38)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.55, 0.62, 0.8))
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_sfx_lab)
	add_child(btn)


func _on_sfx_lab() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_sfx_lab()


func _create_score_panel() -> void:
	_score_panel = Control.new()
	_score_panel.name = "ScoreHistoryPanel"
	_score_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_score_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_score_panel.visible = false
	add_child(_score_panel)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.01, 0.04, 0.92)
	_score_panel.add_child(dimmer)

	var panel := Panel.new()
	# ⚠️ 이름을 지정하지 않으면 런타임에 "@Panel@29" 로 자동 생성되어
	#    get_node("Panel/VBoxContainer/Records") 가 실패한다(에디터에서만 예쁜 이름이 붙는다).
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-290, -420)
	panel.size = Vector2(580, 840)
	_score_panel.add_child(panel)

	var content := VBoxContainer.new()
	content.name = "VBoxContainer"
	content.position = Vector2(35, 30)
	content.size = Vector2(510, 780)
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	var title := Label.new()
	title.text = "★ SCORE RECORDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(1.0, 0.75, 0.25))
	content.add_child(title)

	var header := Label.new()
	header.text = " NO.      SCORE       MODE       DATE"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(0.5, 0.85, 1.0))
	content.add_child(header)

	var records := Label.new()
	records.name = "Records"
	records.custom_minimum_size = Vector2(510, 580)
	records.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	records.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	records.add_theme_font_size_override("font_size", 22)
	records.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	content.add_child(records)

	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.custom_minimum_size = Vector2(220, 58)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.pressed.connect(_hide_score_history)
	content.add_child(close_btn)


func _show_score_history() -> void:
	AudioManager.play_sfx("button")
	var records: Label = _score_panel.get_node("Panel/VBoxContainer/Records")
	var history := GameManager.get_score_history()
	if history.is_empty():
		records.text = "\n\nNo records yet.\nPlay a game to set your first score!"
	else:
		var lines: Array[String] = []
		for i in history.size():
			var item: Dictionary = history[i]
			var date := Time.get_date_dict_from_unix_time(int(item.get("timestamp", 0)))
			var date_text := "%02d/%02d" % [int(date.get("month", 0)), int(date.get("day", 0))]
			lines.append("%2d      %06d      %-6s      %s" % [
				i + 1,
				int(item.get("score", 0)),
				String(item.get("difficulty", "EASY")),
				date_text,
			])
		records.text = "\n".join(lines)
	_score_panel.visible = true
	_score_panel.move_to_front()


func _hide_score_history() -> void:
	AudioManager.play_sfx("button")
	_score_panel.visible = false


# ---------------- 출석 / 플레이시간 보상 ----------------

## 메뉴 하단 버튼 위에 붙는 가로 띠. 연속 일수와 오늘 진행을 항상 보이게 해서
## "오늘 조금만 더 하면 받는다"를 메뉴에 진입할 때마다 상기시킨다.
func _create_reward_strip() -> void:
	_reward_strip = Button.new()
	_reward_strip.name = "RewardStrip"
	_reward_strip.custom_minimum_size = Vector2(639, 46)
	_reward_strip.size = Vector2(639, 46)
	_reward_strip.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_reward_strip.position.y = -205
	_center_horizontally(_reward_strip)
	_reward_strip.add_theme_font_size_override("font_size", 19)
	_reward_strip.focus_mode = Control.FOCUS_NONE
	_reward_strip.pressed.connect(_show_reward_panel)
	add_child(_reward_strip)


## 띠의 문구·색을 현재 상태로 갱신한다. 보상을 받은 직후에도 호출된다.
func _refresh_reward_strip() -> void:
	if _reward_strip == null:
		return
	var claimable := RewardManager.get_claimable()
	var mins := int(RewardManager.today_seconds) / 60
	var secs := int(RewardManager.today_seconds) % 60
	var goal_min := int(RewardManager.DAILY_GOAL_SECONDS) / 60
	if claimable.is_empty():
		_reward_strip.text = "🔥 %d DAY STREAK    ▸ %d:%02d / %d:00" % [
			RewardManager.streak_days, mins, secs, goal_min]
		_reward_strip.add_theme_color_override("font_color", Color(0.6, 0.8, 0.95))
		_reward_strip.modulate = Color(1, 1, 1)
	else:
		# 받을 게 있으면 눈에 띄게 — 색을 바꾸고 천천히 맥동시킨다.
		_reward_strip.text = "🎁 %d REWARD%s READY — TAP" % [
			claimable.size(), "" if claimable.size() == 1 else "S"]
		_reward_strip.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
		var tw := create_tween().set_loops()
		tw.tween_property(_reward_strip, "modulate", Color(1.35, 1.2, 0.7), 0.6)
		tw.tween_property(_reward_strip, "modulate", Color(1, 1, 1), 0.6)


func _create_reward_panel() -> void:
	_reward_panel = Control.new()
	_reward_panel.name = "RewardPanel"
	_reward_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reward_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_reward_panel.visible = false
	add_child(_reward_panel)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.01, 0.04, 0.985)
	_reward_panel.add_child(dimmer)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-290, -420)
	panel.size = Vector2(580, 840)
	_reward_panel.add_child(panel)

	var content := VBoxContainer.new()
	content.name = "VBoxContainer"
	content.position = Vector2(35, 30)
	content.size = Vector2(510, 780)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var title := Label.new()
	title.text = "🎁 DAILY REWARDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	content.add_child(title)

	var streak := Label.new()
	streak.name = "StreakLine"
	streak.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	streak.add_theme_font_size_override("font_size", 22)
	streak.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	content.add_child(streak)

	# 보상 항목이 들어갈 자리. 열 때마다 다시 채운다.
	var rows := VBoxContainer.new()
	rows.name = "Rows"
	rows.custom_minimum_size = Vector2(510, 470)
	rows.add_theme_constant_override("separation", 10)
	content.add_child(rows)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 14)
	content.add_child(footer)

	var badge_btn := Button.new()
	badge_btn.text = "🏅 BADGES"
	badge_btn.custom_minimum_size = Vector2(220, 58)
	badge_btn.add_theme_font_size_override("font_size", 24)
	badge_btn.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	badge_btn.focus_mode = Control.FOCUS_NONE
	badge_btn.pressed.connect(_show_badge_panel)
	footer.add_child(badge_btn)

	var ship_btn := Button.new()
	ship_btn.text = "🚀 SHIPS"
	ship_btn.custom_minimum_size = Vector2(220, 58)
	ship_btn.add_theme_font_size_override("font_size", 24)
	ship_btn.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	ship_btn.focus_mode = Control.FOCUS_NONE
	ship_btn.pressed.connect(_show_skin_panel)
	footer.add_child(ship_btn)

	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.custom_minimum_size = Vector2(220, 58)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(_hide_reward_panel)
	footer.add_child(close_btn)

	# 구매 복원. 기기를 바꾸거나 재설치한 사람이 쓸 곳이 반드시 있어야 한다
	# (스토어 정책상으로도 복원 수단 제공이 요구된다).
	var restore_btn := Button.new()
	restore_btn.text = "RESTORE PURCHASES"
	restore_btn.custom_minimum_size = Vector2(454, 44)
	restore_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restore_btn.add_theme_font_size_override("font_size", 16)
	restore_btn.add_theme_color_override("font_color", Color(0.6, 0.7, 0.85))
	restore_btn.focus_mode = Control.FOCUS_NONE
	restore_btn.pressed.connect(func():
		AudioManager.play_sfx("button")
		PurchaseManager.restore_purchases())
	content.add_child(restore_btn)


func _show_reward_panel() -> void:
	AudioManager.play_sfx("button")
	_rebuild_reward_rows()
	_reward_panel.visible = true
	_reward_panel.move_to_front()


func _hide_reward_panel() -> void:
	AudioManager.play_sfx("button")
	_reward_panel.visible = false


## 보상 목록을 현재 상태로 다시 그린다.
## 세 상태를 색으로 구분한다: 받을 수 있음(금색+버튼) / 이미 받음(회색 ✓) / 아직(어두움 + 남은 조건).
func _rebuild_reward_rows() -> void:
	var streak_line: Label = _reward_panel.get_node("Panel/VBoxContainer/StreakLine")
	var mins := int(RewardManager.today_seconds) / 60
	var secs := int(RewardManager.today_seconds) % 60
	streak_line.text = "🔥 %d DAY   RANK %d   POWER +%d%%" % [
		RewardManager.streak_days, RewardManager.get_rank(),
		roundi(RewardManager.get_rank_power() * 100.0)]

	var rows: VBoxContainer = _reward_panel.get_node("Panel/VBoxContainer/Rows")
	for child in rows.get_children():
		child.queue_free()

	_add_reward_row(rows, "daily", 0, "TODAY 10 MIN", "POWER +5% (THIS RUN)",
		RewardManager.today_seconds >= RewardManager.DAILY_GOAL_SECONDS,
		"%d:%02d / 10:00" % [mins, secs])
	# 연속 접속 마일스톤 수령은 없앴다 — 기체는 이제 **누적 플레이 랭크**로 열린다.
	# 대신 그 진행을 보여준다(자동 해금이라 수령 버튼이 없다).
	_add_rank_row(rows)


## 누적 플레이 랭크 진행. 수령 버튼이 없는 안내 줄이다.
func _add_rank_row(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(510, 88)
	parent.add_child(row)
	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size = Vector2(510, 88)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 18)
	info.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0))
	var rank := RewardManager.get_rank()
	var total := int(RewardManager.total_seconds / 60.0)
	if rank >= RewardManager.MAX_RANK:
		info.text = "RANK %d/%d — %d MIN PLAYED\n   ALL SHIPS UNLOCKED" % [
			rank, RewardManager.MAX_RANK, total]
	else:
		var left := int(RewardManager.seconds_to_next_rank() / 60.0)
		var nxt := ShipSkins.at_rank(rank + 1)
		info.text = "RANK %d/%d — %d MIN PLAYED\n   %d MIN MORE → %s SHIP" % [
			rank, RewardManager.MAX_RANK, total, left,
			String(nxt["name_en"]) if not nxt.is_empty() else "NEXT"]
	row.add_child(info)

	var cap := Label.new()
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cap.custom_minimum_size = Vector2(148, 88)
	cap.add_theme_font_size_override("font_size", 14)
	cap.add_theme_color_override("font_color", Color(0.6, 0.68, 0.8))
	# 하루 상한을 알려 준다 — 안 보이면 "왜 안 늘지?" 가 된다.
	cap.text = "TODAY\n%d/30 MIN" % int(minf(RewardManager.today_seconds, RewardManager.DAILY_CREDIT_CAP) / 60.0)
	row.add_child(cap)


func _add_reward_row(parent: VBoxContainer, kind: String, days: int, name_text: String,
		effect: String, unlocked: bool, progress_text: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(510, 88)
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var claimed := RewardManager.is_claimed(kind, days)
	var info := Label.new()
	# ⚠️ autowrap 을 켜지 않으면 Label 의 최소 폭이 **문구 길이만큼** 커져서
	#    옆의 GET 버튼을 화면 밖으로 밀어낸다(30일 보상 문구에서 실제로 그랬다).
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size = Vector2(344, 88)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 18)
	if claimed:
		info.text = "✓ %s\n   %s" % [name_text, effect]
		info.add_theme_color_override("font_color", Color(0.45, 0.5, 0.55))
	elif unlocked:
		info.text = "%s\n   %s" % [name_text, effect]
		info.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	else:
		info.text = "%s  (%s)\n   %s" % [name_text, progress_text, effect]
		info.add_theme_color_override("font_color", Color(0.55, 0.6, 0.7))
	row.add_child(info)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(148, 62)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 20)
	btn.focus_mode = Control.FOCUS_NONE
	if claimed:
		btn.text = "DONE"
		btn.disabled = true
	elif unlocked:
		btn.text = "GET"
		btn.pressed.connect(_on_claim.bind(kind, days))
	else:
		btn.text = "LOCKED"
		btn.disabled = true
	row.add_child(btn)


func _on_claim(kind: String, days: int) -> void:
	if not RewardManager.claim(kind, days):
		return
	AudioManager.play_sfx("powerup")
	_rebuild_reward_rows()
	_refresh_reward_strip()
	# 랭크가 올랐으면 난이도 잠금이 바로 풀려야 한다 —
	# 메뉴를 나갔다 와야 반영되면 보상을 받은 순간의 보람이 사라진다.
	_rebuild_difficulty_selector()


## 상점 진입 버튼은 하단 버튼 행에 있다(_create_bottom_buttons).
## ⚠️ 상점을 팝업이나 배너로 밀지 않는다 — 학습 게임에서 상점이 눈에 띄면 거슬린다.
##    사용자가 스스로 들어올 때만 보여준다.
func _on_store() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_store()


## 훈장 진열 화면.
## ⚠️ 플레이 중에는 훈장을 화면에 늘어놓지 않는다 — 각인 대상은 단어다.
##    딴 순간에만 배너로 알리고(Game._on_badge_earned), 모아 보는 건 여기서 한다.
func _create_badge_panel() -> void:
	_badge_panel = Control.new()
	_badge_panel.name = "BadgePanel"
	_badge_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_badge_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_badge_panel.visible = false
	add_child(_badge_panel)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.01, 0.04, 0.985)
	_badge_panel.add_child(dimmer)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-290, -420)
	panel.size = Vector2(580, 840)
	_badge_panel.add_child(panel)

	var title := Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(35, 26)
	title.size = Vector2(510, 46)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	panel.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.name = "ListScroll"
	scroll.position = Vector2(35, 86)
	scroll.size = Vector2(510, 656)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var list := VBoxContainer.new()
	list.name = "List"
	list.custom_minimum_size = Vector2(510, 0)
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)

	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.position = Vector2(180, 752)
	close_btn.size = Vector2(220, 58)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(_hide_badge_panel)
	panel.add_child(close_btn)


func _show_badge_panel() -> void:
	AudioManager.play_sfx("button")
	_rebuild_badges()
	_badge_panel.visible = true
	_badge_panel.move_to_front()


func _hide_badge_panel() -> void:
	AudioManager.play_sfx("button")
	_badge_panel.visible = false


func _rebuild_badges() -> void:
	var panel := _badge_panel.get_node("Panel")
	panel.get_node("Title").text = "🏅 BADGES  %d/%d" % [
		RewardManager.badge_count(), Achievements.BADGES.size()]
	var list: VBoxContainer = panel.get_node("ListScroll/List")
	for c in list.get_children():
		c.queue_free()
	for b in Achievements.BADGES:
		list.add_child(_make_badge_row(b))


func _make_badge_row(b: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(510, 84)
	row.add_theme_constant_override("separation", 14)

	# 훈장 그림. 잠긴 것도 형태는 보여준다 — 무엇이 남았는지 알아야 모을 마음이 생긴다.
	var got := RewardManager.has_badge(String(b["id"]))
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(76, 84)
	row.add_child(holder)
	var icon := BadgeIcon.new()
	icon.position = Vector2(38, 34)
	icon.setup(int(b["tier"]), not got, 24.0)
	holder.add_child(icon)

	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size = Vector2(400, 84)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 17)
	if got:
		info.text = "%s\n   %s" % [b["name"], b["desc"]]
		info.add_theme_color_override("font_color", Achievements.tier_color(int(b["tier"])))
	else:
		info.text = "%s\n   %s" % [b["name"], Achievements.progress_text(String(b["id"]))]
		info.add_theme_color_override("font_color", Color(0.5, 0.55, 0.63))
	row.add_child(info)
	return row


## 기체 선택 화면. 해금한 스킨을 **큰 미리보기로 보여주고** 그 자리에서 갈아끼운다.
## 보상이 눈에 보이는 물건이라는 걸 확인하는 자리다.
func _create_skin_panel() -> void:
	_skin_panel = Control.new()
	_skin_panel.name = "SkinPanel"
	_skin_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_skin_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_skin_panel.visible = false
	add_child(_skin_panel)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.01, 0.04, 0.985)
	_skin_panel.add_child(dimmer)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-290, -420)
	panel.size = Vector2(580, 840)
	_skin_panel.add_child(panel)

	var title := Label.new()
	title.text = "🚀 SHIPS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(35, 26)
	title.size = Vector2(510, 46)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	panel.add_child(title)

	# 미리보기 — 실제 게임과 같은 실루엣·오라를 그린다(ShipAura.draw_hull).
	var preview := ShipAura.new()
	preview.name = "Preview"
	preview.draw_hull = true
	preview.position = Vector2(290, 182)
	preview.scale = Vector2(1.75, 1.75)
	panel.add_child(preview)

	var pname := Label.new()
	pname.name = "PreviewName"
	pname.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pname.position = Vector2(35, 268)
	pname.size = Vector2(510, 40)
	pname.add_theme_font_size_override("font_size", 26)
	panel.add_child(pname)

	# ⚠️ 기체가 14종이라 목록이 972px 이 된다 — 패널(840)을 넘쳐 아래가 잘린다(실측).
	#    스크롤 안에 넣는다. 기체를 더 늘려도 여기는 안 건드려도 된다.
	var list_scroll := ScrollContainer.new()
	list_scroll.name = "ListScroll"
	list_scroll.position = Vector2(35, 318)
	list_scroll.size = Vector2(510, 424)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(list_scroll)

	var list := VBoxContainer.new()
	list.name = "List"
	list.custom_minimum_size = Vector2(510, 0)
	list.add_theme_constant_override("separation", 8)
	list_scroll.add_child(list)

	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.position = Vector2(180, 752)
	close_btn.size = Vector2(220, 58)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(_hide_skin_panel)
	panel.add_child(close_btn)


func _show_skin_panel() -> void:
	AudioManager.play_sfx("button")
	_rebuild_skin_list()
	_skin_panel.visible = true
	_skin_panel.move_to_front()


func _hide_skin_panel() -> void:
	AudioManager.play_sfx("button")
	_skin_panel.visible = false


func _rebuild_skin_list() -> void:
	var panel := _skin_panel.get_node("Panel")
	var preview: ShipAura = panel.get_node("Preview")
	preview.set_skin(RewardManager.get_equipped_skin())
	var pname: Label = panel.get_node("PreviewName")
	var eq := RewardManager.get_equipped_skin()
	pname.text = String(eq["name_en"])
	pname.add_theme_color_override("font_color", eq["body"])

	var list: VBoxContainer = panel.get_node("ListScroll/List")
	for child in list.get_children():
		child.queue_free()

	for skin in ShipSkins.SKINS:
		var id := String(skin["id"])
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(510, 62)
		btn.add_theme_font_size_override("font_size", 22)
		btn.focus_mode = Control.FOCUS_NONE
		if not RewardManager.is_skin_unlocked(id):
			# 잠긴 기체도 이름과 조건을 보여준다 — 목표가 보여야 계속 온다.
			# 조건이 셋(출석/수집/결제)이라 각각 다르게 안내한다.
			if skin.has("collect"):
				var got: int = WordManager.get_collection_progress().x
				btn.text = "🔒 %s — %d/%d WORDS" % [skin["name_en"], got, int(skin["collect"])]
			elif skin.has("product"):
				btn.text = "🔒 %s — STORE" % skin["name_en"]
			else:
				var need: float = RewardManager.RANK_SECONDS[clampi(int(skin["rank"]), 0, RewardManager.MAX_RANK)]
				btn.text = "🔒 %s — %d MIN PLAYED" % [skin["name_en"], int(need / 60.0)]
			btn.disabled = true
		elif RewardManager.equipped_skin == id:
			# disabled 로 두면 색 오버라이드가 회색으로 덮여 어떤 기체인지 안 읽힌다.
			btn.text = "● %s" % skin["name_en"]
			btn.add_theme_color_override("font_color", skin["body"])
		else:
			btn.text = String(skin["name_en"])
			btn.add_theme_color_override("font_color", skin["body"])
			btn.pressed.connect(_on_equip_skin.bind(id))
		list.add_child(btn)


func _on_equip_skin(id: String) -> void:
	if not RewardManager.equip_skin(id):
		return
	AudioManager.play_sfx("powerup")
	_rebuild_skin_list()


func _on_dictionary() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_dictionary()


func _on_story() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_story()


## ⚠️ 개발 도구다. 디버그 빌드에서만 보인다(_create_sfx_lab_button 주석 참조).
## 벤치마크는 이 버튼이 아니라 `GameManager.auto_play` 를 직접 켜므로 영향이 없다.
func _create_auto_play_toggle() -> void:
	if not OS.is_debug_build():
		return
	var btn := Button.new()
	btn.name = "AutoPlayButton"
	btn.text = "▶ AUTO: OFF"
	# 보상 띠가 하단 -205 를 쓰게 되면서 자리가 겹쳤다(둘 다 같은 y 였다).
	# 상시 노출이 필요한 건 보상 띠 쪽이므로, 개발용 토글은 SFX 랩 버튼처럼 구석으로 뺀다.
	btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	btn.position = Vector2(14, 74)
	btn.custom_minimum_size = Vector2(130, 38)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_auto_play_toggle)
	add_child(btn)
	_auto_play_btn = btn
	_update_auto_play_btn()


func _update_auto_play_btn() -> void:
	if not _auto_play_btn:
		return
	if GameManager.auto_play:
		_auto_play_btn.text = "▶ AUTO: ON"
		_auto_play_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	else:
		_auto_play_btn.text = "▶ AUTO: OFF"
		_auto_play_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))


func _on_auto_play_toggle() -> void:
	AudioManager.play_sfx("button")
	GameManager.auto_play = not GameManager.auto_play
	_update_auto_play_btn()


func _on_start() -> void:
	AudioManager.play_sfx("button")
	GameManager.start_game()
	SceneManager.goto_game()


## Create SFX / BGM / TTS toggle buttons (top-right corner)
func _create_audio_toggles() -> void:
	var container := HBoxContainer.new()
	container.name = "AudioToggles"
	container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	container.position = Vector2(-270, 20)
	container.add_theme_constant_override("separation", 8)
	add_child(container)

	_sfx_btn = Button.new()
	_sfx_btn.focus_mode = Control.FOCUS_NONE
	_sfx_btn.custom_minimum_size = Vector2(60, 52)
	_sfx_btn.add_theme_font_size_override("font_size", 16)
	_sfx_btn.pressed.connect(_on_sfx_toggle)
	container.add_child(_sfx_btn)

	_music_btn = Button.new()
	_music_btn.focus_mode = Control.FOCUS_NONE
	_music_btn.custom_minimum_size = Vector2(60, 52)
	_music_btn.add_theme_font_size_override("font_size", 16)
	_music_btn.pressed.connect(_on_music_toggle)
	container.add_child(_music_btn)

	_tts_btn = Button.new()
	_tts_btn.focus_mode = Control.FOCUS_NONE
	_tts_btn.custom_minimum_size = Vector2(60, 52)
	_tts_btn.add_theme_font_size_override("font_size", 16)
	_tts_btn.pressed.connect(_on_tts_toggle)
	container.add_child(_tts_btn)

	_update_audio_buttons()


func _update_audio_buttons() -> void:
	if _sfx_btn:
		_sfx_btn.text = "🔊" if AudioManager.sfx_enabled else "🔇"
		_sfx_btn.modulate = Color.WHITE if AudioManager.sfx_enabled else Color(0.5, 0.5, 0.5)
	if _music_btn:
		_music_btn.text = "🎵"
		_music_btn.modulate = Color.WHITE if AudioManager.music_enabled else Color(0.5, 0.5, 0.5)
	if _tts_btn:
		_tts_btn.text = "💬"
		_tts_btn.modulate = Color.WHITE if AudioManager.tts_enabled else Color(0.5, 0.5, 0.5)


func _on_sfx_toggle() -> void:
	AudioManager.toggle_sfx()
	if AudioManager.sfx_enabled:
		AudioManager.play_sfx("button")
	_update_audio_buttons()


func _on_music_toggle() -> void:
	AudioManager.toggle_music()
	if AudioManager.sfx_enabled:
		AudioManager.play_sfx("button")
	_update_audio_buttons()


func _on_tts_toggle() -> void:
	AudioManager.toggle_tts()
	if AudioManager.sfx_enabled:
		AudioManager.play_sfx("button")
	if AudioManager.tts_enabled and DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		AudioManager.speak_word("Word Blaster")
	_update_audio_buttons()


func _update_high_score(score: int) -> void:
	_high_score_label.text = "🏆  %06d" % score


func _animate_title() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_title, "modulate", Color(0.3, 0.9, 1.0, 1.0), 1.0)
	tween.tween_property(_title, "modulate", Color(0.8, 0.3, 1.0, 1.0), 1.0)


## 알파 테스트 자료 수집 동의. 처음 한 번만 묻는다.
##
## ⚠️ **거부해도 게임은 100% 그대로 동작해야 한다.** 수집을 기능의 조건으로 걸면 정책 위반이고,
##    무엇보다 이 게임의 목적(학습)과 아무 상관이 없다.
## ⚠️ 무엇을 보내는지 **구체적으로** 적을 것. "익명 정보" 같은 뭉뚱그린 문구는
##    Play 데이터 보안 양식과 대조했을 때 설명이 안 된다.
func _maybe_ask_consent() -> void:
	if Telemetry.consent != Telemetry.CONSENT_UNSET:
		return
	_create_consent_panel()
	_consent_panel.visible = true
	_consent_panel.move_to_front()


func _create_consent_panel() -> void:
	_consent_panel = Control.new()
	_consent_panel.name = "ConsentPanel"
	_consent_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_consent_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_consent_panel.visible = false
	add_child(_consent_panel)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.01, 0.04, 0.985)
	_consent_panel.add_child(dimmer)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-300, -330)
	panel.size = Vector2(600, 660)
	_consent_panel.add_child(panel)

	var title := Label.new()
	title.name = "Title"
	title.text = "🧪 테스트 참여 안내"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(30, 28)
	title.size = Vector2(540, 46)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.4, 1.0, 0.9))
	panel.add_child(title)

	var body := Label.new()
	body.name = "Body"
	body.position = Vector2(40, 96)
	body.size = Vector2(520, 400)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 22)
	body.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
	body.text = """게임 난이도를 다듬기 위해 한 판이 끝날 때마다 아래 기록을 보냅니다.

· 생존 시간과 종료 사유(사망 / 중단)
· 화면의 적 수, 피격 횟수, 웨이브
· 완성한 단어 수
· 기기 모델과 화면 크기, 프레임 수

계정, 이름, 연락처, 광고 ID(AAID)는 수집하지 않습니다. 앱을 지우면 기록도 함께 사라집니다.

거부하셔도 게임의 모든 기능을 그대로 쓰실 수 있습니다."""
	panel.add_child(body)

	var link := Label.new()
	link.name = "PolicyLink"
	link.text = "개인정보처리방침 · nb.won-solution.com/privacy.html"
	link.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	link.position = Vector2(30, 506)
	link.size = Vector2(540, 30)
	link.add_theme_font_size_override("font_size", 18)
	link.add_theme_color_override("font_color", Color(0.55, 0.6, 0.72))
	panel.add_child(link)

	var agree := Button.new()
	agree.name = "AgreeButton"
	agree.text = "보내기 동의"
	agree.position = Vector2(310, 556)
	agree.size = Vector2(250, 72)
	agree.add_theme_font_size_override("font_size", 24)
	agree.focus_mode = Control.FOCUS_NONE
	agree.pressed.connect(_on_consent.bind(true))
	panel.add_child(agree)

	var deny := Button.new()
	deny.name = "DenyButton"
	deny.text = "보내지 않음"
	deny.position = Vector2(40, 556)
	deny.size = Vector2(250, 72)
	deny.add_theme_font_size_override("font_size", 24)
	deny.focus_mode = Control.FOCUS_NONE
	deny.pressed.connect(_on_consent.bind(false))
	panel.add_child(deny)


func _on_consent(agreed: bool) -> void:
	AudioManager.play_sfx("button")
	Telemetry.set_consent(agreed)
	_consent_panel.visible = false
