extends Control
## StoryPage - 세계관 스토리 페이지
## 루미노스 은하의 스토리, 세력, 적, 파워업 소개
## StoryData(텍스트) + StoryArt(이미지/애니메이션) 통합

var _bg: ColorRect
var _title_label: Label
var _back_btn: Button
var _tab_container: TabContainer
var _sparkle_layer: Node2D


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_create_background()
	_create_title()
	_create_back_button()
	_create_sparkle_layer()
	_create_tabs()


func _create_background() -> void:
	_bg = ColorRect.new()
	_bg.color = Color(0.04, 0.03, 0.09, 1.0)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)


func _create_title() -> void:
	_title_label = Label.new()
	_title_label.text = "✦ LUMINOUS GALAXY ✦"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 40)
	_title_label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	_title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_title_label.position = Vector2(-300, 25)
	_title_label.size = Vector2(600, 55)
	add_child(_title_label)


func _create_back_button() -> void:
	_back_btn = Button.new()
	_back_btn.text = "◀ BACK"
	_back_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_back_btn.position = Vector2(20, 20)
	_back_btn.custom_minimum_size = Vector2(100, 50)
	_back_btn.add_theme_font_size_override("font_size", 20)
	_back_btn.pressed.connect(_on_back)
	add_child(_back_btn)


## 배경 별빛 스파클 레이어 (전체 페이지 배경)
func _create_sparkle_layer() -> void:
	_sparkle_layer = Node2D.new()
	_sparkle_layer.name = "SparkleLayer"
	add_child(_sparkle_layer)
	StoryArt.create_sparkles(_sparkle_layer, 30, 360.0, Color(0.5, 0.8, 1.0))


func _create_tabs() -> void:
	_tab_container = TabContainer.new()
	_tab_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tab_container.offset_left = 20
	_tab_container.offset_top = 100
	_tab_container.offset_right = -20
	_tab_container.offset_bottom = -20
	_tab_container.clip_tabs = true
	add_child(_tab_container)

	_create_intro_tab()
	_create_chapters_tab()
	_create_factions_tab()
	_create_enemies_tab()
	_create_powerups_tab()


# ============================================================
# Tab: 프롤로그 (루미나 에너지 구체 + 스파클)
# ============================================================
func _create_intro_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "📖 Prologue"
	_tab_container.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	# --- 루미나 에너지 구체 아트 ---
	var art_container := Control.new()
	art_container.custom_minimum_size = Vector2(600, 250)
	vbox.add_child(art_container)

	# Node2D를 감싸는 SubViewport방식 대신 직접 노드 배치
	var lumina_node := Node2D.new()
	lumina_node.position = Vector2(300, 120)
	art_container.add_child(lumina_node)
	var orb := StoryArt.draw_lumina_orb(lumina_node, 1.0)
	StoryArt.animate_pulse(orb, 0.9, 1.15, 2.0)

	# 구체 주변 스파클
	StoryArt.create_sparkles(lumina_node, 8, 80.0, Color(0.5, 0.9, 1.0))

	# --- 제목 ---
	var title := Label.new()
	title.text = StoryData.STORY_INTRO.get("title_en", StoryData.STORY_INTRO["title"])
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	vbox.add_child(title)

	# --- 스토리 (영문) ---
	# 게임 문구를 영문으로 통일하면서 한국어 라벨과 구분선을 제거하고 영문만 남겼다.
	# 데이터에는 ko 가 그대로 있으므로 한국어판이 필요하면 여기만 되돌리면 된다.
	var en_label := Label.new()
	en_label.text = StoryData.STORY_INTRO["en"]
	en_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	en_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	en_label.add_theme_font_size_override("font_size", 20)
	en_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	vbox.add_child(en_label)


# ============================================================
# Tab: 챕터
# ============================================================
func _create_chapters_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "⚔️ Chapters"
	_tab_container.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	for chapter in StoryData.STORY_CHAPTERS:
		var panel := _create_chapter_panel(chapter)
		vbox.add_child(panel)


func _create_chapter_panel(chapter: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.14, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.7, 1.0, 0.6)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)

	var inner_vbox := VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(inner_vbox)

	# 챕터별 시각 아이콘
	var icon_ctrl := Control.new()
	icon_ctrl.custom_minimum_size = Vector2(600, 120)
	inner_vbox.add_child(icon_ctrl)

	var art_node := Node2D.new()
	art_node.position = Vector2(80, 60)
	icon_ctrl.add_child(art_node)
	# wave에 따라 다른 아트
	var wave: int = chapter["wave"]
	_draw_chapter_icon(art_node, wave)

	# Wave 배지 + 제목
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	inner_vbox.add_child(header)

	var wave_badge := Label.new()
	wave_badge.text = "WAVE %d+" % wave
	wave_badge.add_theme_font_size_override("font_size", 16)
	wave_badge.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
	header.add_child(wave_badge)

	var title := Label.new()
	title.text = chapter.get("title_en", chapter["title"])
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	header.add_child(title)

	# 한국어 설명
	var ko := Label.new()
	ko.text = chapter["en"]
	ko.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ko.add_theme_font_size_override("font_size", 18)
	ko.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	inner_vbox.add_child(ko)

	return panel


## 챕터 wave에 따라 적절한 아트 표시
func _draw_chapter_icon(art_node: Node2D, wave: int) -> void:
	match wave:
		1:
			# 보이드의 침공 - 추적자
			var enemy := StoryArt.draw_void_enemy(art_node, "CHASER", 0.5)
			StoryArt.animate_float(enemy, 5.0, 1.5)
		3:
			# 원거리 위협 - 포격수
			var enemy := StoryArt.draw_void_enemy(art_node, "SHOOTER", 0.5)
			StoryArt.animate_float(enemy, 5.0, 1.5)
		5:
			# 중갑의 벽 - 중갑병
			var enemy := StoryArt.draw_void_enemy(art_node, "TANK", 0.45)
			StoryArt.animate_rotation(enemy, 4.0)
		8:
			# 보이드의 분노 - 파워업들
			for i in 3:
				var pw_node := Node2D.new()
				pw_node.position = Vector2(i * 60 - 30, 0)
				art_node.add_child(pw_node)
				var keys := ["LASER", "LIGHTNING", "TIME_SLOW"]
				var pw := StoryArt.draw_powerup_icon(pw_node, keys[i], 0.3)
				StoryArt.animate_pulse(pw, 0.9, 1.1, 1.5)
		12:
			# 최후의 결전 - 가디언 전투기
			var ship := StoryArt.draw_guardian_ship(art_node, 0.55)
			StoryArt.animate_engine_flicker(ship)
			StoryArt.animate_float(ship, 8.0, 2.0)
		_:
			var orb := StoryArt.draw_lumina_orb(art_node, 0.4)
			StoryArt.animate_pulse(orb, 0.9, 1.1, 2.0)


# ============================================================
# Tab: 세력 (뱃지 + 애니메이션)
# ============================================================
func _create_factions_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "◈ Factions"
	_tab_container.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	# GUARDIAN
	var guardian_data: Dictionary = StoryData.FACTIONS["GUARDIAN"]
	var guardian_panel := _create_faction_panel(guardian_data, "GUARDIAN")
	vbox.add_child(guardian_panel)

	# VOID
	var void_data: Dictionary = StoryData.FACTIONS["VOID"]
	var void_panel := _create_faction_panel(void_data, "VOID")
	vbox.add_child(void_panel)


func _create_faction_panel(data: Dictionary, faction_key: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var color_str: String = data["color"]
	var parts := color_str.split_floats(",")
	var accent := Color(parts[0], parts[1], parts[2])

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.14, 0.9)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = accent
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# --- 뱃지 아트 ---
	var badge_ctrl := Control.new()
	badge_ctrl.custom_minimum_size = Vector2(600, 160)
	vbox.add_child(badge_ctrl)

	var badge_node := Node2D.new()
	badge_node.position = Vector2(300, 80)
	badge_ctrl.add_child(badge_node)

	if faction_key == "GUARDIAN":
		var badge := StoryArt.draw_guardian_badge(badge_node, 0.9)
		StoryArt.animate_pulse(badge, 0.95, 1.05, 2.0)
		# 가디언 전투기 추가
		var ship_node := Node2D.new()
		ship_node.position = Vector2(150, 0)
		badge_node.add_child(ship_node)
		var ship := StoryArt.draw_guardian_ship(ship_node, 0.4)
		StoryArt.animate_engine_flicker(ship)
		StoryArt.animate_float(ship, 8.0, 2.0)

		var ship2_node := Node2D.new()
		ship2_node.position = Vector2(-150, 0)
		badge_node.add_child(ship2_node)
		var ship2 := StoryArt.draw_guardian_ship(ship2_node, 0.4)
		ship2.rotation = PI
		StoryArt.animate_engine_flicker(ship2)

	elif faction_key == "VOID":
		var badge := StoryArt.draw_void_badge(badge_node, 0.9)
		StoryArt.animate_rotation(badge, 8.0)

	# --- 이름 ---
	var name_label := Label.new()
	name_label.text = data["name_en"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 26)
	name_label.add_theme_color_override("font_color", accent)
	vbox.add_child(name_label)

	# --- 설명 ---
	var ko := Label.new()
	ko.text = data["en"]
	ko.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ko.add_theme_font_size_override("font_size", 18)
	ko.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	vbox.add_child(ko)

	return panel


# ============================================================
# Tab: 적 (각 타입별 그림)
# ============================================================
func _create_enemies_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "💀 Enemies"
	_tab_container.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	for key in StoryData.get_enemy_keys():
		var data: Dictionary = StoryData.ENEMY_LORE[key]
		var panel := _create_enemy_panel(data, key)
		vbox.add_child(panel)


func _create_enemy_panel(data: Dictionary, enemy_key: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.14, 0.9)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(1.0, 0.3, 0.5)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)

	# --- 적 아트 (좌측) ---
	var art_ctrl := Control.new()
	art_ctrl.custom_minimum_size = Vector2(150, 150)
	hbox.add_child(art_ctrl)

	var art_node := Node2D.new()
	art_node.position = Vector2(75, 75)
	art_ctrl.add_child(art_node)

	var enemy := StoryArt.draw_void_enemy(art_node, enemy_key, 0.7)
	# 타입별 애니메이션
	match enemy_key:
		"CHASER":
			StoryArt.animate_float(enemy, 6.0, 1.0)
		"SHOOTER":
			StoryArt.animate_float(enemy, 4.0, 1.2)
		"TANK":
			StoryArt.animate_rotation(enemy, 6.0)
		# 아래 넷은 **그 유닛의 특징이 곧 움직임**이 되게 고른다.
		# 글로 읽기 전에 그림만 봐도 무엇이 위험한지 짐작되어야 한다.
		"DASHER":
			StoryArt.animate_float(enemy, 12.0, 0.5)   # 빠르게 흔들린다
		"BOMBER":
			StoryArt.animate_pulse(enemy, 0.88, 1.12, 0.6)  # 터지기 직전의 점멸
		"SPLITTER":
			StoryArt.animate_rotation(enemy, 10.0)     # 느리게 굴러온다
		"SHIELDER":
			StoryArt.animate_pulse(enemy, 0.96, 1.06, 2.0)  # 재생하는 보호막

	# --- 텍스트 정보 (우측) ---
	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 8)
	hbox.add_child(text_vbox)

	var name_label := Label.new()
	name_label.text = data["name_en"]
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	text_vbox.add_child(name_label)

	var ko := Label.new()
	ko.text = data["en"]
	ko.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ko.add_theme_font_size_override("font_size", 17)
	ko.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	text_vbox.add_child(ko)

	return panel


# ============================================================
# Tab: 파워업 (각 아이콘)
# ============================================================
func _create_powerups_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "✦ Power-Ups"
	_tab_container.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	for key in StoryData.get_powerup_keys():
		var data: Dictionary = StoryData.POWERUP_LORE[key]
		var panel := _create_powerup_panel(data, key)
		vbox.add_child(panel)


func _create_powerup_panel(data: Dictionary, powerup_key: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.14, 0.9)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.3, 1.0, 0.5)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)

	# --- 파워업 아트 (좌측) ---
	var art_ctrl := Control.new()
	art_ctrl.custom_minimum_size = Vector2(150, 150)
	hbox.add_child(art_ctrl)

	var art_node := Node2D.new()
	art_node.position = Vector2(75, 75)
	art_ctrl.add_child(art_node)

	var pw := StoryArt.draw_powerup_icon(art_node, powerup_key, 0.7)
	StoryArt.animate_pulse(pw, 0.9, 1.1, 1.5)
	# 특별 애니메이션
	match powerup_key:
		"LIGHTNING", "LASER":
			StoryArt.animate_pulse(pw, 0.85, 1.15, 0.6)
		"TIME_SLOW":
			StoryArt.animate_rotation(pw, 8.0)

	# --- 텍스트 정보 (우측) ---
	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 8)
	hbox.add_child(text_vbox)

	var name_label := Label.new()
	name_label.text = data["name_en"]
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.7))
	text_vbox.add_child(name_label)

	var ko := Label.new()
	ko.text = data["en"]
	ko.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ko.add_theme_font_size_override("font_size", 17)
	ko.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	text_vbox.add_child(ko)

	return panel


# ============================================================
# Helper: 구분선
# ============================================================
func _create_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	return sep


# ============================================================
# Callbacks
# ============================================================
func _on_back() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_menu()