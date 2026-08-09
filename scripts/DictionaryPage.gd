extends Control
## DictionaryPage - 단어 사전 페이지
## 모든 단어를 카테고리별로 보여주고, 아이콘과 설명을 제공

var _bg: ColorRect
var _title_label: Label
var _back_btn: Button
var _category_container: HBoxContainer
## 탭이 26개라 화면을 넘는다 — 가로 스크롤 안에 담는다.
var _category_scroll: ScrollContainer
var _category_desc: Label
var _scroll: ScrollContainer
var _grid: GridContainer
var _detail_panel: Panel
var _detail_icon: Label
var _detail_word: Label
var _detail_category: Label
var _detail_phrase: Label
var _detail_desc_en: Label
var _detail_speak_btn: Button
var _detail_close_btn: Button
var _detail_share_btn: Button
var _selected_category: String = "ALL"
var _progress_label: Label = null


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_create_background()
	_create_title()
	_create_back_button()
	_create_category_filter()
	_create_category_desc_label()
	_create_scroll_grid()
	_create_detail_panel()
	_populate_grid()


func _create_background() -> void:
	_bg = ColorRect.new()
	_bg.color = Color(0.04, 0.03, 0.09, 1.0)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)


func _create_title() -> void:
	_title_label = Label.new()
	_title_label.text = "📖 WORD DICTIONARY"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 42)
	_title_label.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))
	_title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_title_label.position = Vector2(-300, 30)
	_title_label.size = Vector2(600, 60)
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


func _create_category_filter() -> void:
	_category_container = HBoxContainer.new()
	_category_container.name = "CategoryFilter"
	# ⚠️ 테마가 25개로 늘면서 탭 줄이 폭 2239px 이 됐다(화면 720px의 3배).
	#    20개 넘는 테마가 화면 밖이라 **누를 수조차 없었다.**
	#    가로 스크롤 안에 넣어 전부 닿게 한다.
	_category_scroll = ScrollContainer.new()
	_category_scroll.set_anchors_preset(Control.PRESET_CENTER_TOP)
	# ⚠️ 헤더는 겹치기 쉬운 구간이다. 세로 띠를 명확히 나눠 둔다:
	#    제목 30~90 / 수집 진행 96~126 / 테마 탭 132~180 / 테마 설명 186~222 / 카드 230~
	#    (예전에는 진행 라벨과 탭이 둘 다 y100 이라 겹쳐 있었다.)
	_category_scroll.position = Vector2(-350, 132)
	_category_scroll.size = Vector2(700, 48)
	_category_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_category_scroll)

	_category_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_category_container.add_theme_constant_override("separation", 6)
	_category_scroll.add_child(_category_container)

	# ⚠️ 사전의 17개 카테고리가 아니라 **테마 6개**로 탭을 만든다.
	# 도감이 테마 단어만 보여주므로, 사전 카테고리로 탭을 만들면 WEAPON·VEHICLE 처럼
	# 아무것도 안 나오는 빈 탭이 생긴다.
	var categories := ["ALL"]
	for st in ThemeStages.STAGES:
		categories.append(String(st["id"]))
	for cat in categories:
		var btn := Button.new()
		# 완주한 테마에는 ★ — 8개는 48개보다 손에 잡히는 중간 목표다.
		if cat != "ALL" and WordManager.is_theme_mastered(cat):
			btn.text = "★ " + cat
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		else:
			btn.text = cat
		btn.custom_minimum_size = Vector2(80, 40)
		btn.add_theme_font_size_override("font_size", 14)
		btn.focus_mode = Control.FOCUS_NONE
		btn.tooltip_text = StoryData.CATEGORY_LORE.get(cat, {}).get("en", "")
		btn.pressed.connect(_on_category_selected.bind(cat, btn))
		_category_container.add_child(btn)
	# Highlight ALL
	if _category_container.get_child_count() > 0:
		_highlight_category(_category_container.get_child(0))


func _create_category_desc_label() -> void:
	_category_desc = Label.new()
	_category_desc.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_category_desc.position = Vector2(-310, 186)
	_category_desc.size = Vector2(620, 36)
	_category_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_category_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_category_desc.add_theme_font_size_override("font_size", 15)
	_category_desc.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	# Set initial description for ALL
	var initial_lore: Dictionary = StoryData.CATEGORY_LORE.get("ALL", {})
	_category_desc.text = initial_lore.get("en", "")
	add_child(_category_desc)
	_refresh_progress()


## 수집 진행도. 도감을 "채우는 것"으로 만들려면 얼마나 남았는지가 늘 보여야 한다.
func _refresh_progress() -> void:
	var p := WordManager.get_collection_progress()
	if _progress_label == null:
		_progress_label = Label.new()
		_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_progress_label.add_theme_font_size_override("font_size", 20)
		_progress_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
		_progress_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		# 제목과 테마 탭 사이. 위 헤더 구간표 참조.
		_progress_label.offset_top = 96.0
		_progress_label.offset_bottom = 126.0
		add_child(_progress_label)
	_progress_label.text = "📖  %d / %d  COLLECTED" % [p.x, p.y]


func _on_category_selected(cat: String, btn: Button) -> void:
	AudioManager.play_sfx("button")
	_selected_category = cat
	_highlight_category(btn)
	# Update category lore description
	var lore: Dictionary = StoryData.CATEGORY_LORE.get(cat, {})
	_category_desc.text = lore.get("en", "")
	_populate_grid()


## 선택한 탭이 화면 밖에 있으면 그 자리로 스크롤한다.
## 스크롤 막대가 안 보이는 기기도 있어서, 눌린 탭이 안 보이면 고장으로 느껴진다.
func _scroll_to_tab(btn: Control) -> void:
	if _category_scroll == null or btn == null:
		return
	var target: float = btn.position.x + btn.size.x * 0.5 - _category_scroll.size.x * 0.5
	_category_scroll.scroll_horizontal = int(maxf(target, 0.0))


func _highlight_category(selected: Button) -> void:
	_scroll_to_tab(selected)
	for child in _category_container.get_children():
		child.modulate = Color(0.5, 0.5, 0.5)
	selected.modulate = Color.WHITE


func _create_scroll_grid() -> void:
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.offset_left = 20
	_scroll.offset_top = 230
	_scroll.offset_right = -20
	_scroll.offset_bottom = -20
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)

	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	_scroll.add_child(_grid)


func _populate_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()

	# ⚠️ 사전 전체가 아니라 **테마에 실제로 등장하는 단어만** 보여준다.
	# 게임에 안 나오는 단어를 도감에 두면 영원히 못 채우는 칸이 생겨 수집 동기가 무너진다.
	var words: Array = _filter(ThemeStages.get_all_words())
	words.sort()
	# 심화 단어는 기본 단어 **뒤에** 붙인다 — 도감에서도 "기본을 먼저, 심화는 그다음"이라는
	# 게임 안의 학습 순서가 그대로 보여야 한다.
	var advanced: Array = _filter(ThemeStages.get_all_advanced())
	advanced.sort()

	for word in words:
		_grid.add_child(_create_word_card(word, false))
	for word in advanced:
		_grid.add_child(_create_word_card(word, true))


## 선택된 카테고리 탭에 해당하는 단어만 남긴다.
func _filter(pool: Array) -> Array:
	var out: Array = []
	for w in pool:
		if _selected_category == "ALL" or String(WordDictionary.get_description(w).get("category", "")) == _selected_category:
			out.append(w)
	return out


## is_advanced 인 카드는 ✦ 로 표시한다 — 기본 8개를 다 모아야 나오는 보너스 단어다.
func _create_word_card(word: String, is_advanced: bool) -> Control:
	var card := Button.new()
	card.custom_minimum_size = Vector2(210, 220)
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	var got: bool = WordManager.is_collected(word)
	if got:
		card.pressed.connect(_show_detail.bind(word))
	else:
		# 미수집 카드는 눌러도 열리지 않는다 — 게임에서 완성해야 열린다.
		card.disabled = true
		card.modulate = Color(1, 1, 1, 0.55)

	# Container for icon + label
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Icon (emoji)
	var icon_wrapper := Control.new()
	icon_wrapper.custom_minimum_size = Vector2(120, 120)
	vbox.add_child(icon_wrapper)

	var icon_node := Label.new()
	icon_node.text = WordDictionary.get_emoji(word) if got else "❓"
	icon_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_node.add_theme_font_size_override("font_size", 64)
	icon_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_wrapper.add_child(icon_node)

	# Word label
	var label := Label.new()
	# 미수집은 글자 수만 알려준다 — 무엇을 모아야 하는지 힌트는 주되 답은 감춘다.
	label.text = word if got else "_ ".repeat(word.length()).strip_edges()
	if is_advanced:
		label.text = "✦ " + label.text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0) if got else Color(0.45, 0.5, 0.6))
	vbox.add_child(label)

	# Category tag
	var desc := WordDictionary.get_description(word)
	var cat_label := Label.new()
	cat_label.text = "[" + desc["category"] + "]"
	cat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_label.add_theme_font_size_override("font_size", 13)
	cat_label.add_theme_color_override("font_color",
		Color(1.0, 0.8, 0.35) if is_advanced else Color(0.6, 0.7, 0.9))
	vbox.add_child(cat_label)

	return card


func _create_detail_panel() -> void:
	_detail_panel = Panel.new()
	_detail_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_detail_panel.offset_left = 60
	_detail_panel.offset_top = 120
	_detail_panel.offset_right = -60
	_detail_panel.offset_bottom = -120
	_detail_panel.visible = false

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.06, 0.05, 0.14, 0.98)
	bg.border_width_left = 3
	bg.border_width_right = 3
	bg.border_width_top = 3
	bg.border_width_bottom = 3
	bg.border_color = Color(0.3, 0.9, 1.0)
	bg.corner_radius_top_left = 16
	bg.corner_radius_top_right = 16
	bg.corner_radius_bottom_left = 16
	bg.corner_radius_bottom_right = 16
	_detail_panel.add_theme_stylebox_override("panel", bg)
	add_child(_detail_panel)

	# Icon area
	var icon_wrapper := Control.new()
	icon_wrapper.position = Vector2(260, 30)
	icon_wrapper.size = Vector2(140, 140)
	_detail_panel.add_child(icon_wrapper)

	_detail_icon = Label.new()
	_detail_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_detail_icon.add_theme_font_size_override("font_size", 80)
	_detail_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_wrapper.add_child(_detail_icon)

	# Word
	_detail_word = Label.new()
	_detail_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_word.add_theme_font_size_override("font_size", 48)
	_detail_word.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	_detail_word.position = Vector2(50, 190)
	_detail_word.size = Vector2(560, 60)
	_detail_panel.add_child(_detail_word)

	# Category
	_detail_category = Label.new()
	_detail_category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_category.add_theme_font_size_override("font_size", 20)
	_detail_category.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	_detail_category.position = Vector2(50, 255)
	_detail_category.size = Vector2(560, 30)
	_detail_panel.add_child(_detail_category)

	# 예문 — 🔊 LISTEN 이 읽어주는 바로 그 문장이다(WordDictionary.phrase).
	# 예전에는 이 자리에 한국어 뜻이 있었으나 게임 문구를 영문으로 통일하면서 예문으로 바꿨다.
	_detail_phrase = Label.new()
	_detail_phrase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_phrase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_phrase.add_theme_font_size_override("font_size", 24)
	_detail_phrase.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	_detail_phrase.position = Vector2(50, 300)
	_detail_phrase.size = Vector2(560, 80)
	_detail_panel.add_child(_detail_phrase)

	# English description
	_detail_desc_en = Label.new()
	_detail_desc_en.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_desc_en.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_desc_en.add_theme_font_size_override("font_size", 18)
	_detail_desc_en.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	_detail_desc_en.position = Vector2(50, 390)
	_detail_desc_en.size = Vector2(560, 60)
	_detail_panel.add_child(_detail_desc_en)

	# Speak button
	_detail_speak_btn = Button.new()
	_detail_speak_btn.text = "🔊 LISTEN"
	_detail_speak_btn.position = Vector2(120, 470)
	_detail_speak_btn.size = Vector2(140, 50)
	_detail_speak_btn.add_theme_font_size_override("font_size", 20)
	_detail_speak_btn.pressed.connect(_on_speak_detail)
	_detail_panel.add_child(_detail_speak_btn)

	# 공유 버튼 — 말풍선에 예문을 담은 카드를 만들어 보낸다.
	_detail_share_btn = Button.new()
	_detail_share_btn.text = "↗ SHARE"
	_detail_share_btn.position = Vector2(270, 470)
	_detail_share_btn.size = Vector2(130, 50)
	_detail_share_btn.add_theme_font_size_override("font_size", 20)
	_detail_share_btn.add_theme_color_override("font_color", Color(0.5, 1.0, 0.85))
	_detail_share_btn.pressed.connect(_on_share_detail)
	_detail_panel.add_child(_detail_share_btn)

	# Close button
	_detail_close_btn = Button.new()
	_detail_close_btn.text = "✕ CLOSE"
	_detail_close_btn.position = Vector2(410, 470)
	_detail_close_btn.size = Vector2(140, 50)
	_detail_close_btn.add_theme_font_size_override("font_size", 20)
	_detail_close_btn.pressed.connect(_on_close_detail)
	_detail_panel.add_child(_detail_close_btn)


var _detail_word_text: String = ""


## 단어 카드를 만들어 공유한다. 카드 렌더에 한 프레임이 걸려서 중복 요청을 막는다.
func _on_share_detail() -> void:
	AudioManager.play_sfx("button")
	if _detail_word_text == "":
		return
	_detail_share_btn.disabled = true
	_detail_share_btn.text = "..."
	await ShareManager.share_word(_detail_word_text)
	_detail_share_btn.disabled = false
	_detail_share_btn.text = "↗ SHARE"


func _show_detail(word: String) -> void:
	AudioManager.play_sfx("button")
	_detail_word_text = word
	# Show emoji icon
	_detail_icon.text = WordDictionary.get_emoji(word)
	var desc := WordDictionary.get_description(word)
	_detail_word.text = word
	# 몇 번 봤는지 함께 보여준다 — 학습 통계를 저장하기 전에는 띄울 수가 없던 정보다.
	var seen := int(WordManager.get_word_stats(word).get("exposure", 0))
	if seen > 0:
		_detail_category.text = "[%s]   ● %d회 봄" % [desc["category"], seen]
	else:
		_detail_category.text = "[" + desc["category"] + "]"
	_detail_phrase.text = WordDictionary.get_phrase(word)
	_detail_desc_en.text = desc["en"]
	_detail_panel.visible = true
	# Pop animation
	_detail_panel.scale = Vector2(0.7, 0.7)
	var tween := create_tween()
	tween.tween_property(_detail_panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_speak_detail() -> void:
	AudioManager.speak_word(_detail_word_text)


func _on_close_detail() -> void:
	AudioManager.play_sfx("button")
	_detail_panel.visible = false


func _on_back() -> void:
	AudioManager.play_sfx("button")
	SceneManager.goto_menu()