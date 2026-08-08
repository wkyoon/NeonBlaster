extends Control
## DictionaryPage - 단어 사전 페이지
## 모든 단어를 카테고리별로 보여주고, 아이콘과 설명을 제공

var _bg: ColorRect
var _title_label: Label
var _back_btn: Button
var _category_container: HBoxContainer
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
var _selected_category: String = "ALL"


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
	_category_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_category_container.position = Vector2(-330, 100)
	_category_container.size = Vector2(660, 44)
	_category_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_category_container.add_theme_constant_override("separation", 6)
	add_child(_category_container)

	var categories := ["ALL"]
	categories.append_array(WordDictionary.get_categories())
	for cat in categories:
		var btn := Button.new()
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
	_category_desc.position = Vector2(-310, 148)
	_category_desc.size = Vector2(620, 70)
	_category_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_category_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_category_desc.add_theme_font_size_override("font_size", 15)
	_category_desc.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	# Set initial description for ALL
	var initial_lore: Dictionary = StoryData.CATEGORY_LORE.get("ALL", {})
	_category_desc.text = initial_lore.get("en", "")
	add_child(_category_desc)


func _on_category_selected(cat: String, btn: Button) -> void:
	AudioManager.play_sfx("button")
	_selected_category = cat
	_highlight_category(btn)
	# Update category lore description
	var lore: Dictionary = StoryData.CATEGORY_LORE.get(cat, {})
	_category_desc.text = lore.get("en", "")
	_populate_grid()


func _highlight_category(selected: Button) -> void:
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

	var words: Array = []
	if _selected_category == "ALL":
		words = WordDictionary.get_all_words()
	else:
		words = WordDictionary.get_words_by_category(_selected_category)
	words.sort()

	for word in words:
		var card := _create_word_card(word)
		_grid.add_child(card)


func _create_word_card(word: String) -> Control:
	var card := Button.new()
	card.custom_minimum_size = Vector2(210, 220)
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	card.pressed.connect(_show_detail.bind(word))

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
	icon_node.text = WordDictionary.get_emoji(word)
	icon_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_node.add_theme_font_size_override("font_size", 64)
	icon_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_wrapper.add_child(icon_node)

	# Word label
	var label := Label.new()
	label.text = word
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	vbox.add_child(label)

	# Category tag
	var desc := WordDictionary.get_description(word)
	var cat_label := Label.new()
	cat_label.text = "[" + desc["category"] + "]"
	cat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_label.add_theme_font_size_override("font_size", 13)
	cat_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
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
	_detail_speak_btn.position = Vector2(200, 470)
	_detail_speak_btn.size = Vector2(140, 50)
	_detail_speak_btn.add_theme_font_size_override("font_size", 20)
	_detail_speak_btn.pressed.connect(_on_speak_detail)
	_detail_panel.add_child(_detail_speak_btn)

	# Close button
	_detail_close_btn = Button.new()
	_detail_close_btn.text = "✕ CLOSE"
	_detail_close_btn.position = Vector2(360, 470)
	_detail_close_btn.size = Vector2(140, 50)
	_detail_close_btn.add_theme_font_size_override("font_size", 20)
	_detail_close_btn.pressed.connect(_on_close_detail)
	_detail_panel.add_child(_detail_close_btn)


var _detail_word_text: String = ""


func _show_detail(word: String) -> void:
	AudioManager.play_sfx("button")
	_detail_word_text = word
	# Show emoji icon
	_detail_icon.text = WordDictionary.get_emoji(word)
	var desc := WordDictionary.get_description(word)
	_detail_word.text = word
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