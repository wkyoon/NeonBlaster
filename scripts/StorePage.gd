extends Control
## StorePage - 상점 화면. 파는 것을 한눈에 보여주고 그 자리에서 장착까지 한다.
##
## ⚠️ **가격은 코드에 적지 않는다.** Google Play 에서 받아온 값을 그대로 보여준다
##    (`PurchaseManager.get_price`). 나라별 통화·현지 가격이 맞아야 하고, 자체 결제는 정책 위반이다.
##    Play 응답이 없으면(데스크톱 stub) "—" 로 표시한다.
##
## ⚠️ **구매 복원 버튼은 필수다.** 기기를 바꾸거나 재설치한 사람이 쓸 곳이 없으면
##    스토어 정책에도 걸리고 환불 문의가 들어온다.
##
## 구매하면 **즉시 장착**한다 — 출석 보상이 그렇게 동작하고(받는 순간 기체가 바뀐다),
## 산 것이 상품이 아니라 보상처럼 느껴지려면 같은 흐름이어야 한다.

const CARD_HEIGHT := 96

var _list: VBoxContainer
var _preview: ShipAura
var _preview_label: Label
var _status: Label


func _ready() -> void:
	_build()
	PurchaseManager.purchase_state_changed.connect(_on_purchase_state)
	PurchaseManager.prices_updated.connect(_rebuild)
	PurchaseManager.purchase_failed.connect(_on_failed)
	RewardManager.skin_unlocked.connect(func(_id): _rebuild())


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vp := get_viewport_rect().size

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.05)
	add_child(bg)

	var title := Label.new()
	title.text = "🛒 STORE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 28)
	title.size = Vector2(vp.x, 50)
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(0.6, 1.0, 0.8))
	add_child(title)

	# 기본은 무료라는 것을 먼저 말한다. 상점을 열자마자 불안해지지 않게.
	var note := Label.new()
	# ⚠️ 개수를 박지 말 것. 어휘가 늘면 이 문구가 곧 거짓이 된다.
	note.text = "ALL %d WORDS ARE FREE — THESE ARE JUST FOR LOOKS" % WordManager.get_collection_progress().y
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.position = Vector2(0, 82)
	note.size = Vector2(vp.x, 24)
	note.add_theme_font_size_override("font_size", 14)
	note.add_theme_color_override("font_color", Color(0.55, 0.62, 0.72))
	add_child(note)

	# 장착 중인 기체 미리보기.
	_preview = ShipAura.new()
	_preview.draw_hull = true
	_preview.position = Vector2(vp.x * 0.5, 178)
	_preview.scale = Vector2(1.5, 1.5)
	add_child(_preview)

	_preview_label = Label.new()
	_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_label.position = Vector2(0, 226)
	_preview_label.size = Vector2(vp.x, 30)
	_preview_label.add_theme_font_size_override("font_size", 20)
	add_child(_preview_label)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(24, 272)
	scroll.size = Vector2(vp.x - 48, vp.y - 272 - 150)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(vp.x - 48, 0)
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.position = Vector2(0, vp.y - 146)
	_status.size = Vector2(vp.x, 24)
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
	add_child(_status)

	var restore := Button.new()
	restore.text = "RESTORE PURCHASES"
	restore.position = Vector2(vp.x * 0.5 - 160, vp.y - 118)
	restore.size = Vector2(320, 44)
	restore.add_theme_font_size_override("font_size", 16)
	restore.add_theme_color_override("font_color", Color(0.6, 0.7, 0.85))
	restore.focus_mode = Control.FOCUS_NONE
	restore.pressed.connect(func():
		AudioManager.play_sfx("button")
		PurchaseManager.restore_purchases()
		_status.text = "RESTORING...")
	add_child(restore)

	var back := Button.new()
	back.text = "BACK"
	back.position = Vector2(vp.x * 0.5 - 110, vp.y - 66)
	back.size = Vector2(220, 52)
	back.add_theme_font_size_override("font_size", 22)
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(func():
		AudioManager.play_sfx("button")
		SceneManager.goto_menu())
	add_child(back)

	_rebuild()


func _rebuild() -> void:
	if _list == null:
		return
	for c in _list.get_children():
		c.queue_free()
	for kind in [StoreItems.Kind.SHIP, StoreItems.Kind.REVEAL, StoreItems.Kind.SUPPORT]:
		var items := StoreItems.by_kind(kind)
		if items.is_empty():
			continue
		var header := Label.new()
		header.text = StoreItems.kind_label(kind)
		header.add_theme_font_size_override("font_size", 20)
		header.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
		_list.add_child(header)
		for item in items:
			_list.add_child(_make_card(item))
		if kind == StoreItems.Kind.REVEAL:
			_list.add_child(_make_default_reveal_row())
	_refresh_preview()


func _refresh_preview() -> void:
	var skin := RewardManager.get_equipped_skin()
	_preview.set_skin(skin)
	_preview_label.text = String(skin["name_en"])
	_preview_label.add_theme_color_override("font_color", skin["body"])


## 산 연출을 끄고 기본으로 돌아가는 줄. 되돌릴 수 없으면 사고 나서 후회한다.
func _make_default_reveal_row() -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 64)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)
	var info := Label.new()
	info.text = "DEFAULT"
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 17)
	info.add_theme_color_override("font_color", Color(0.6, 0.66, 0.75))
	row.add_child(info)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(150, 48)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 17)
	btn.focus_mode = Control.FOCUS_NONE
	var on: bool = RewardManager.equipped_reveal == "default"
	btn.text = "● USING" if on else "EQUIP"
	btn.disabled = on
	if not on:
		btn.pressed.connect(_on_equip_reveal.bind("default"))
	row.add_child(btn)
	return card


func _make_card(item: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, CARD_HEIGHT)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.custom_minimum_size = Vector2(410, CARD_HEIGHT)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 17)
	info.text = "%s\n   %s" % [item["name"], item["desc_en"]]
	row.add_child(info)

	var id := String(item["id"])
	var owned := PurchaseManager.is_owned(id)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(150, 60)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 17)
	btn.focus_mode = Control.FOCUS_NONE

	if not owned:
		var price := PurchaseManager.get_price(id)
		btn.text = price if price != "" else "—"
		btn.pressed.connect(_on_buy.bind(id))
	elif item["kind"] == StoreItems.Kind.SHIP:
		# 산 기체는 그 자리에서 갈아입을 수 있어야 한다.
		var equipped: bool = RewardManager.equipped_skin == String(item["ref"])
		btn.text = "● USING" if equipped else "EQUIP"
		btn.disabled = equipped
		if not equipped:
			btn.pressed.connect(_on_equip.bind(String(item["ref"])))
	elif item["kind"] == StoreItems.Kind.REVEAL:
		var on: bool = RewardManager.equipped_reveal == String(item["ref"])
		btn.text = "● USING" if on else "EQUIP"
		btn.disabled = on
		if not on:
			btn.pressed.connect(_on_equip_reveal.bind(String(item["ref"])))
	else:
		btn.text = "✓ OWNED"
		btn.disabled = true
	row.add_child(btn)
	return card


func _on_buy(product_id: String) -> void:
	AudioManager.play_sfx("button")
	_status.text = ""
	PurchaseManager.buy(product_id)


## 완성 연출을 갈아입는다. 기본 연출로 되돌릴 수 있어야 하므로 목록 위에 DEFAULT 버튼도 둔다.
func _on_equip_reveal(reveal_id: String) -> void:
	AudioManager.play_sfx("powerup")
	RewardManager.equip_reveal(reveal_id)
	_rebuild()


func _on_equip(skin_id: String) -> void:
	AudioManager.play_sfx("powerup")
	RewardManager.equip_skin(skin_id)
	_rebuild()


## 구매가 끝나면 **즉시 장착**한다. 산 것이 보상처럼 느껴지려면 바로 보여야 한다.
func _on_purchase_state(product_id: String) -> void:
	var item := StoreItems.get_item(product_id)
	if not item.is_empty():
		# 구매 즉시 장착한다 — 산 것이 보상처럼 느껴지려면 바로 보여야 한다.
		match item["kind"]:
			StoreItems.Kind.SHIP:
				RewardManager.unlock_skin(String(item["ref"]), true)
			StoreItems.Kind.REVEAL:
				RewardManager.equip_reveal(String(item["ref"]))
	AudioManager.play_sfx("powerup")
	_status.text = ""
	_rebuild()


func _on_failed(reason: String) -> void:
	_status.text = reason
