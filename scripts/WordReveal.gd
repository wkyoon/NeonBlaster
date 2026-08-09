class_name WordReveal
extends Control
## WordReveal - shows a celebration overlay when a word is completed.
## Displays a neon-style procedural icon + the word + TTS pronunciation.

## 리빌이 놓이는 세로 기준점(화면 높이 비율).
## 0.5(정중앙)에서 0.38로 올렸다 — 플레이 중 기체가 화면 위쪽에 머무는 시간이 많아
## 정중앙에 띄우면 액션과 겹친다. 약간 위로 올려 시선 흐름과 맞춘다.
## 리빌이 끝났을 때. 다음 단어 시작 타이밍을 여기에 맞춘다.
signal reveal_finished

## 완성된 단어가 뜨는 세로 위치. **HUD 의 진행 스펠(WordSlots)과 같은 자리**여야 한다.
## ⚠️ 예전에는 진행 스펠이 화면 14%, 완성 단어가 46% 에 떠서 시선이 점프했다.
##    "한 자씩 채워지다 → 그 자리에서 완성돼 커진다"가 이 게임의 핵심 순간이라 한 자리에서 일어나야 한다.
const WORD_ANCHOR := 0.33
## 아이콘은 단어 **위**에 둔다. 학습 대상은 이모지가 아니라 글자다.
const ICON_OFFSET := -150.0
## 아이콘 묶음(이모지 + 링 + 글로우) 축소 배율.
## ⚠️ 이모지가 160pt, 단어가 64pt 라 **아이콘이 단어의 2.5배**였다. 주인공이 뒤바뀌어 있었다.
const ICON_SCALE := 0.5
## 등장·퇴장에 쓰는 시간과, 온전히 보이는 시간의 하한/상한.
## 하한은 음성이 없거나 아주 짧을 때도 읽을 수 있게, 상한은 판이 늘어지지 않게.
const FADE_IN := 0.3
const FADE_OUT := 0.45
const MIN_HOLD := 1.0
const MAX_HOLD := 2.6

var _icon_container: Node2D
var _word_label: Label
var _bg: ColorRect
var _ring: Node2D
var _tween: Tween
var _icon_tween: Tween

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_background()
	_create_icon_container()
	_create_word_label()
	visible = false


func _create_background() -> void:
	_bg = ColorRect.new()
	# ⚠️ 화면 전체를 어둡게 덮지 않는다.
	# alpha 0.7 로 덮던 시절에는 이 2.5초 동안 앞이 안 보인 채로 적에게 맞았고,
	# 그래서 게임을 멈춰야 했다. 멈춤은 "끊긴다"는 느낌을 줘서 멈추지 않기로 했으므로,
	# 대신 오버레이가 시야를 가리지 않아야 한다. 아주 옅은 톤만 남긴다.
	_bg.color = Color(0.02, 0.02, 0.08, 0.12)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	# Decorative pulsing ring behind the icon
	_ring = _create_glow_ring()
	# ⚠️ 링은 _icon_container 의 자식이 아니라 형제다 — 컨테이너만 줄이면 링만 원래 크기로 남는다.
	#    같은 배율을 직접 걸어 아이콘 묶음 전체가 함께 작아지게 한다.
	_ring.scale = Vector2(ICON_SCALE, ICON_SCALE)
	_ring.position = Vector2(
		get_viewport_rect().size.x / 2,
		get_viewport_rect().size.y * WORD_ANCHOR + ICON_OFFSET
	)
	add_child(_ring)


func _create_glow_ring() -> Node2D:
	var ring := Node2D.new()
	ring.name = "GlowRing"
	# Outer glow ring
	var outer := Polygon2D.new()
	outer.polygon = _make_circle_polygon(40, 120)
	outer.color = Color(0.3, 0.6, 1.0, 0.08)
	ring.add_child(outer)
	# Mid glow ring
	var mid := Polygon2D.new()
	mid.polygon = _make_circle_polygon(40, 95)
	mid.color = Color(0.3, 0.9, 1.0, 0.12)
	ring.add_child(mid)
	# Inner ring outline
	var inner := Line2D.new()
	var pts := PackedVector2Array()
	for i in 40:
		var a := TAU * i / 40.0
		pts.append(Vector2(cos(a), sin(a)) * 85)
	pts.append(pts[0])
	inner.points = pts
	inner.width = 3.0
	inner.default_color = Color(0.3, 1.0, 0.9, 0.5)
	inner.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.add_child(inner)
	# Ring light
	var light := PointLight2D.new()
	light.color = Color(0.3, 0.9, 1.0)
	light.energy = 2.0
	light.texture_scale = 5.0
	ring.add_child(light)
	return ring


func _create_icon_container() -> void:
	_icon_container = Node2D.new()
	_icon_container.position = Vector2(
		get_viewport_rect().size.x / 2,
		get_viewport_rect().size.y * WORD_ANCHOR + ICON_OFFSET
	)
	_icon_container.scale = Vector2(ICON_SCALE, ICON_SCALE)
	add_child(_icon_container)


func _create_word_label() -> void:
	_word_label = Label.new()
	_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_word_label.add_theme_font_size_override("font_size", 76)
	_word_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.9))
	_word_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_word_label.add_theme_color_override("font_outline_color", Color(0, 0.3, 0.4))
	_word_label.add_theme_constant_override("shadow_offset_x", 3)
	_word_label.add_theme_constant_override("shadow_offset_y", 3)
	_word_label.add_theme_constant_override("outline_size", 10)
	# ⚠️ 이 노드(WordReveal)의 size 는 실제로 (0,0) 이다 — FULL_RECT 프리셋이 적용되지 않는다.
	#    그래서 자식의 PRESET_CENTER 는 "화면 중앙"이 아니라 **원점(0,0)** 을 기준으로 잡는다.
	#    예전에는 여기에 position.x = -300 을 더해 라벨이 화면 x −300~+300 에 놓였고,
	#    단어 중심이 화면 왼쪽 끝이라 **글자가 절반 잘려 나갔다**(BLUE→"UE", YELLOW→"LOW").
	#    아이콘(_icon_container)처럼 뷰포트 크기로 직접 배치해야 한다.
	var vp := get_viewport_rect().size
	var label_size := Vector2(vp.x, 100.0)
	_word_label.size = label_size
	# 진행 스펠(WordSlots)과 정확히 같은 자리 — 그 자리에서 커진다.
	_word_label.position = Vector2(0.0, vp.y * WORD_ANCHOR - label_size.y * 0.5)
	add_child(_word_label)


## 처음 수집한 단어면 "NEW" 배지를 띄운다. 수집의 순간을 눈에 보이게 만들어야
## 도감이 동기가 된다 — 조용히 채워지면 모으는 재미가 생기지 않는다.
func _show_new_badge(total: int, goal: int) -> void:
	var badge := Label.new()
	badge.text = "★ NEW!  %d / %d" % [total, goal]
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 30)
	badge.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))
	badge.add_theme_color_override("font_outline_color", Color(0.3, 0.2, 0.0))
	badge.add_theme_constant_override("outline_size", 8)
	var vp := get_viewport_rect().size
	badge.size = Vector2(vp.x, 40)
	badge.position = Vector2(0.0, vp.y * WORD_ANCHOR + 90.0)
	add_child(badge)
	var tw := create_tween()
	badge.modulate.a = 0.0
	tw.tween_property(badge, "modulate:a", 1.0, 0.25)
	tw.tween_property(badge, "position:y", badge.position.y - 24.0, 0.9)
	tw.parallel().tween_property(badge, "modulate:a", 0.0, 0.9)
	tw.tween_callback(badge.queue_free)


func reveal_word(word: String) -> void:
	for child in _icon_container.get_children():
		child.queue_free()
	_word_label.text = word
	visible = true
	_draw_neon_icon(word)
	_ring.scale = Vector2(ICON_SCALE, ICON_SCALE)
	_spawn_sparkles()
	if _tween:
		_tween.kill()
	modulate.a = 0.0
	scale = Vector2(0.5, 0.5)
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# Pulsing ring effect
	_tween.parallel().tween_property(_ring, "scale", Vector2(ICON_SCALE * 1.3, ICON_SCALE * 1.3), 0.6).set_ease(Tween.EASE_OUT)
	# ⚠️ 표시 시간을 **음성 길이에 맞춘다.**
	#    고정 0.9초였을 때 음성(중앙값 1.91초)이 81개 중 80개나 더 길어서
	#    단어가 사라진 뒤에도 문장이 계속 나왔다 — 눈으로 익히는 게임에서 치명적이다.
	#    이 게임의 목적은 "완성된 단어를 눈으로 보게 하는 것"이라 이 시간이 곧 학습 시간이다.
	_animate_icon(word)
	var speech: float = AudioManager.speak_word(word)
	# 페이드 인/아웃을 뺀 나머지가 "온전히 보이는" 시간이다.
	var hold: float = clampf(speech - FADE_IN - FADE_OUT, MIN_HOLD, MAX_HOLD)
	_tween.tween_interval(hold)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT)
	_tween.tween_callback(_on_reveal_complete)


func _spawn_sparkles() -> void:
	var icon_pos := Vector2(
		get_viewport_rect().size.x / 2,
		get_viewport_rect().size.y * WORD_ANCHOR + ICON_OFFSET
	)
	# Burst sparkles
	for i in 24:
		var sparkle := Polygon2D.new()
		var pts := PackedVector2Array()
		for j in 8:
			var a := -PI / 2 + TAU * j / 8.0
			var r := 6.0 if j % 2 == 0 else 2.0
			pts.append(Vector2(cos(a), sin(a)) * r)
		sparkle.polygon = pts
		var colors := [Color(1.0, 0.9, 0.3), Color(0.3, 1.0, 0.9), Color(1.0, 0.3, 0.8), Color(0.5, 0.8, 1.0)]
		sparkle.color = colors[i % colors.size()]
		sparkle.position = icon_pos
		add_child(sparkle)
		var angle := TAU * i / 24.0
		var dist := randf_range(80, 160)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(sparkle, "position", icon_pos + Vector2(cos(angle), sin(angle)) * dist, 0.8).set_ease(Tween.EASE_OUT)
		tw.tween_property(sparkle, "scale", Vector2(0.1, 0.1), 0.8).set_ease(Tween.EASE_IN)
		tw.tween_property(sparkle, "rotation", randf_range(-PI, PI), 0.8)
		tw.chain().tween_callback(sparkle.queue_free)
	# Radial light burst
	var burst := PointLight2D.new()
	burst.color = Color(1.0, 0.9, 0.5)
	burst.energy = 8.0
	burst.texture_scale = 6.0
	burst.position = icon_pos
	add_child(burst)
	var bt := create_tween()
	bt.tween_property(burst, "energy", 0.0, 0.6)
	bt.tween_callback(burst.queue_free)


func _on_reveal_complete() -> void:
	visible = false
	reveal_finished.emit()
	scale = Vector2.ONE


# ---------------- TTS ----------------
# (이제 AudioManager.speak_word()를 사용합니다 - 짧은 단어를 스펠링이 아닌 단어로 발음)


# ---------------- Neon Icon Drawing ----------------

func _draw_neon_icon(word: String) -> void:
	var emoji := WordDictionary.get_emoji(word)
	var label := Label.new()
	label.text = emoji
	label.name = "EmojiIcon"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 160)
	label.size = Vector2(300, 300)
	label.position = Vector2(-150, -150)
	_icon_container.add_child(label)
	_add_glow(_icon_container, Color(1.0, 0.9, 0.3), 3.0, 5.0)


# ---- Helpers ----

func _make_node(icon_name: String, pos: Vector2) -> Node2D:
	var node := Node2D.new()
	node.name = icon_name
	node.position = pos
	_icon_container.add_child(node)
	return node


func _add_glow(parent: Node2D, color: Color, energy: float, scale_val: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.color = color
	light.energy = energy
	light.texture_scale = scale_val
	parent.add_child(light)
	return light


func _make_circle_polygon(segments: int, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var a := TAU * i / segments
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts


func _circle(r: float) -> PackedVector2Array:
	return _make_circle_polygon(30, r)


func _ellipse(rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 30:
		var a := TAU * i / 30.0
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	return pts


# ---- Simple Icons ----

func _draw_sun(color: Color) -> void:
	var node := _make_node("Sun", Vector2.ZERO)
	# Outer corona glow
	var corona := Polygon2D.new()
	corona.polygon = _make_circle_polygon(40, 60)
	corona.color = Color(color.r, color.g, color.b, 0.15)
	node.add_child(corona)
	# Rays behind core
	var rays := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 12:
		var a := TAU * i / 12.0
		pts.append(Vector2(cos(a - 0.12), sin(a - 0.12)) * 50)
		pts.append(Vector2(cos(a), sin(a)) * 80)
		pts.append(Vector2(cos(a + 0.12), sin(a + 0.12)) * 50)
	rays.polygon = pts
	rays.color = Color(color.r * 0.9, color.g * 0.9, color.b * 0.9)
	node.add_child(rays)
	# Main body
	var circle := Polygon2D.new()
	circle.polygon = _circle(42)
	circle.color = color
	node.add_child(circle)
	# Darker rim for depth
	var rim := Polygon2D.new()
	rim.polygon = _circle(42)
	rim.color = Color(color.r * 0.7, color.g * 0.5, color.b * 0.3, 0.4)
	node.add_child(rim)
	# Highlight (top-left)
	var highlight := Polygon2D.new()
	highlight.polygon = _make_circle_polygon(24, 15)
	highlight.color = Color(1.0, 1.0, 1.0, 0.5)
	highlight.position = Vector2(-12, -12)
	node.add_child(highlight)
	# Inner bright core
	var core := Polygon2D.new()
	core.polygon = _circle(25)
	core.color = Color(minf(color.r + 0.3, 1.0), minf(color.g + 0.3, 1.0), minf(color.b + 0.2, 1.0), 0.5)
	core.position = Vector2(-5, -5)
	node.add_child(core)
	_add_glow(node, color, 3.5, 4.5)


func _draw_star(color: Color) -> void:
	var node := _make_node("Star", Vector2.ZERO)
	var star := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + TAU * i / 10.0
		var r := 70.0 if i % 2 == 0 else 28.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	star.polygon = pts
	star.color = color
	node.add_child(star)
	_add_glow(node, color, 3.0, 4.0)


func _draw_moon(color: Color) -> void:
	var node := _make_node("Moon", Vector2.ZERO)
	var moon := Polygon2D.new()
	moon.polygon = _circle(50)
	moon.color = color
	node.add_child(moon)
	var shadow := Polygon2D.new()
	shadow.polygon = _circle(45)
	shadow.color = Color(0.02, 0.02, 0.08)
	shadow.position = Vector2(25, -10)
	node.add_child(shadow)
	_add_glow(node, color, 2.0, 3.0)


func _draw_planet(color: Color) -> void:
	var node := _make_node("Planet", Vector2.ZERO)
	# Atmospheric glow halo
	var halo := Polygon2D.new()
	halo.polygon = _make_circle_polygon(40, 58)
	halo.color = Color(color.r, color.g, color.b, 0.15)
	node.add_child(halo)
	# Main body
	var planet := Polygon2D.new()
	planet.polygon = _circle(50)
	planet.color = color
	node.add_child(planet)
	# Dark side (shadow)
	var shadow := Polygon2D.new()
	shadow.polygon = _circle(50)
	shadow.color = Color(0.0, 0.0, 0.1, 0.4)
	shadow.position = Vector2(18, 12)
	node.add_child(shadow)
	# Surface bands
	for i in 3:
		var band := Polygon2D.new()
		var band_pts := PackedVector2Array()
		for j in 20:
			var a := PI * j / 19.0 - PI / 2
			var y := -30 + i * 25 + sin(a) * 8
			band_pts.append(Vector2(cos(a) * 48, y - 4))
		for j in range(19, -1, -1):
			var a := PI * j / 19.0 - PI / 2
			var y := -30 + i * 25 + sin(a) * 8
			band_pts.append(Vector2(cos(a) * 48, y + 4))
		band.polygon = band_pts
		band.color = Color(color.r * 0.7, color.g * 0.7, color.b * 0.7, 0.3)
		node.add_child(band)
	# Highlight
	var highlight := Polygon2D.new()
	highlight.polygon = _make_circle_polygon(20, 18)
	highlight.color = Color(1.0, 1.0, 1.0, 0.3)
	highlight.position = Vector2(-18, -18)
	node.add_child(highlight)
	_add_glow(node, color, 2.5, 3.5)


func _draw_planet_ring(color: Color) -> void:
	_draw_planet(color)
	var ring := Polygon2D.new()
	ring.polygon = _ellipse(80, 20)
	ring.color = Color(color.r * 0.8, color.g * 0.8, color.b * 0.8, 0.7)
	_icon_container.get_child(0).add_child(ring)


func _draw_comet(color: Color) -> void:
	var node := _make_node("Comet", Vector2.ZERO)
	var head := Polygon2D.new()
	head.polygon = _make_circle_polygon(16, 25)
	head.color = color
	node.add_child(head)
	var tail := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 20:
		var t := float(i) / 20.0
		var width := 20.0 * (1.0 - t)
		pts.append(Vector2(30 + t * 100, -width + sin(t * 8.0) * 5))
	for i in range(19, -1, -1):
		var t := float(i) / 20.0
		var width := 20.0 * (1.0 - t)
		pts.append(Vector2(30 + t * 100, width + sin(t * 8.0) * 5))
	tail.polygon = pts
	tail.color = Color(color.r, color.g, color.b, 0.5)
	node.add_child(tail)
	_add_glow(node, color, 2.0, 3.0)


func _draw_sky(color: Color) -> void:
	var node := _make_node("Sky", Vector2.ZERO)
	var c1 := Polygon2D.new()
	c1.polygon = _circle(40)
	c1.color = color
	c1.position = Vector2(-20, 0)
	node.add_child(c1)
	var c2 := Polygon2D.new()
	c2.polygon = _make_circle_polygon(16, 30)
	c2.color = color
	c2.position = Vector2(20, 5)
	node.add_child(c2)
	_add_glow(node, color, 1.5, 3.0)


func _draw_eye(color: Color) -> void:
	var node := _make_node("Eye", Vector2.ZERO)
	var outer := Polygon2D.new()
	outer.polygon = _ellipse(60, 35)
	outer.color = Color.WHITE
	node.add_child(outer)
	var iris := Polygon2D.new()
	iris.polygon = _make_circle_polygon(20, 22)
	iris.color = color
	node.add_child(iris)
	var pupil := Polygon2D.new()
	pupil.polygon = _make_circle_polygon(12, 10)
	pupil.color = Color.BLACK
	node.add_child(pupil)
	_add_glow(node, color, 2.0, 2.0)


func _draw_flame(color: Color) -> void:
	var node := _make_node("Flame", Vector2.ZERO)
	var flame := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -70), Vector2(25, -30), Vector2(35, 10), Vector2(20, 40), Vector2(0, 50), Vector2(-20, 40), Vector2(-35, 10), Vector2(-25, -30)]:
		pts.append(v)
	flame.polygon = pts
	flame.color = color
	node.add_child(flame)
	var inner := Polygon2D.new()
	var pts2 := PackedVector2Array()
	for v in [Vector2(0, -45), Vector2(15, -15), Vector2(18, 10), Vector2(0, 30), Vector2(-18, 10), Vector2(-15, -15)]:
		pts2.append(v)
	inner.polygon = pts2
	inner.color = Color(1.0, 0.9, 0.3)
	node.add_child(inner)
	_add_glow(node, color, 3.0, 3.0)


func _draw_gem(color: Color) -> void:
	var node := _make_node("Gem", Vector2.ZERO)
	var gem := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(45, -25), Vector2(30, 50), Vector2(-30, 50), Vector2(-45, -25)]:
		pts.append(v)
	gem.polygon = pts
	gem.color = color
	node.add_child(gem)
	var facet := Polygon2D.new()
	var pts2 := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(45, -25), Vector2(0, -25)]:
		pts2.append(v)
	facet.polygon = pts2
	facet.color = Color(color.r * 1.3, color.g * 1.3, color.b * 1.3, 0.8)
	node.add_child(facet)
	_add_glow(node, color, 3.0, 3.0)


func _draw_circle_icon(color: Color) -> void:
	var node := _make_node("Circle", Vector2.ZERO)
	var circle := Polygon2D.new()
	circle.polygon = _circle(50)
	circle.color = color
	node.add_child(circle)
	_add_glow(node, color, 3.0, 3.0)


func _draw_rocket(color: Color) -> void:
	var node := _make_node("Rocket", Vector2.ZERO)
	# Engine flame (behind body)
	var flame_outer := Polygon2D.new()
	var fo_pts := PackedVector2Array()
	for v in [Vector2(0, 95), Vector2(15, 40), Vector2(-15, 40)]:
		fo_pts.append(v)
	flame_outer.polygon = fo_pts
	flame_outer.color = Color(1.0, 0.3, 0.1, 0.6)
	node.add_child(flame_outer)
	var flame := Polygon2D.new()
	var flame_pts := PackedVector2Array()
	for v in [Vector2(0, 80), Vector2(10, 40), Vector2(-10, 40)]:
		flame_pts.append(v)
	flame.polygon = flame_pts
	flame.color = Color(1.0, 0.7, 0.2)
	node.add_child(flame)
	var flame_core := Polygon2D.new()
	var fc_pts := PackedVector2Array()
	for v in [Vector2(0, 65), Vector2(5, 40), Vector2(-5, 40)]:
		fc_pts.append(v)
	flame_core.polygon = fc_pts
	flame_core.color = Color(1.0, 1.0, 0.8)
	node.add_child(flame_core)
	# Body shadow side
	var body_shadow := Polygon2D.new()
	var bs_pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(20, -20), Vector2(20, 40), Vector2(-20, 40), Vector2(-20, -20)]:
		bs_pts.append(v)
	body_shadow.polygon = bs_pts
	body_shadow.color = Color(0.3, 0.3, 0.4)
	node.add_child(body_shadow)
	# Main body
	var body := Polygon2D.new()
	var body_pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(18, -20), Vector2(18, 38), Vector2(-18, 38), Vector2(-18, -20)]:
		body_pts.append(v)
	body.polygon = body_pts
	body.color = color
	node.add_child(body)
	# Highlight stripe
	var stripe := Polygon2D.new()
	var stripe_pts := PackedVector2Array()
	for v in [Vector2(-12, -20), Vector2(-6, -20), Vector2(-6, 38), Vector2(-12, 38)]:
		stripe_pts.append(v)
	stripe.polygon = stripe_pts
	stripe.color = Color(1.0, 1.0, 1.0, 0.3)
	node.add_child(stripe)
	# Window
	var window_bg := Polygon2D.new()
	window_bg.polygon = _make_circle_polygon(12, 12)
	window_bg.color = Color(0.2, 0.3, 0.5)
	window_bg.position = Vector2(0, -15)
	node.add_child(window_bg)
	var window_glass := Polygon2D.new()
	window_glass.polygon = _make_circle_polygon(12, 10)
	window_glass.color = Color(0.3, 0.8, 1.0)
	window_glass.position = Vector2(0, -15)
	node.add_child(window_glass)
	var window_hl := Polygon2D.new()
	window_hl.polygon = _make_circle_polygon(8, 4)
	window_hl.color = Color(1.0, 1.0, 1.0, 0.6)
	window_hl.position = Vector2(-3, -18)
	node.add_child(window_hl)
	# Fins
	for sx in [1, -1]:
		var fin_shadow := Polygon2D.new()
		var fs_pts := PackedVector2Array()
		for v in [Vector2(sx * 22, 12), Vector2(sx * 42, 52), Vector2(sx * 22, 42)]:
			fs_pts.append(v)
		fin_shadow.polygon = fs_pts
		fin_shadow.color = Color(0.6, 0.1, 0.1)
		node.add_child(fin_shadow)
		var fin := Polygon2D.new()
		var fin_pts := PackedVector2Array()
		for v in [Vector2(sx * 20, 10), Vector2(sx * 38, 48), Vector2(sx * 20, 40)]:
			fin_pts.append(v)
		fin.polygon = fin_pts
		fin.color = Color(1.0, 0.3, 0.3)
		node.add_child(fin)
	_add_glow(node, Color(1.0, 0.5, 0.2), 2.5, 3.0)


func _draw_laser(color: Color) -> void:
	var node := _make_node("Laser", Vector2.ZERO)
	var beam := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-10, -70), Vector2(10, -70), Vector2(10, 70), Vector2(-10, 70)]:
		pts.append(v)
	beam.polygon = pts
	beam.color = color
	node.add_child(beam)
	var core := Polygon2D.new()
	var core_pts := PackedVector2Array()
	for v in [Vector2(-4, -70), Vector2(4, -70), Vector2(4, 70), Vector2(-4, 70)]:
		core_pts.append(v)
	core.polygon = core_pts
	core.color = Color.WHITE
	node.add_child(core)
	_add_glow(node, color, 4.0, 3.0)


func _draw_gun(color: Color) -> void:
	var node := _make_node("Gun", Vector2.ZERO)
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-40, -15), Vector2(30, -15), Vector2(30, 0), Vector2(10, 0), Vector2(10, 30), Vector2(-10, 30), Vector2(-10, 0), Vector2(-40, 0)]:
		pts.append(v)
	body.polygon = pts
	body.color = color
	node.add_child(body)
	_add_glow(node, color, 1.5, 2.0)


func _draw_jet(color: Color) -> void:
	var node := _make_node("Jet", Vector2.ZERO)
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(15, 20), Vector2(50, 40), Vector2(15, 40), Vector2(0, 55), Vector2(-15, 40), Vector2(-50, 40), Vector2(-15, 20)]:
		pts.append(v)
	body.polygon = pts
	body.color = color
	node.add_child(body)
	_add_glow(node, color, 1.5, 2.0)


func _draw_fish(color: Color) -> void:
	var node := _make_node("Fish", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _ellipse(45, 25)
	body.color = color
	node.add_child(body)
	var tail := Polygon2D.new()
	var tail_pts := PackedVector2Array()
	for v in [Vector2(40, 0), Vector2(70, -25), Vector2(70, 25)]:
		tail_pts.append(v)
	tail.polygon = tail_pts
	tail.color = color
	node.add_child(tail)
	var eye := Polygon2D.new()
	eye.polygon = _make_circle_polygon(8, 5)
	eye.color = Color.WHITE
	eye.position = Vector2(-20, -5)
	node.add_child(eye)
	_add_glow(node, color, 1.5, 2.0)


func _draw_bee(color: Color) -> void:
	var node := _make_node("Bee", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _make_circle_polygon(20, 30)
	body.color = color
	node.add_child(body)
	for i in 3:
		var stripe := Polygon2D.new()
		var pts := PackedVector2Array()
		var x1 := -20 + i * 15
		var x2 := -12 + i * 15
		for v in [Vector2(x1, -25), Vector2(x2, -25), Vector2(x2, 25), Vector2(x1, 25)]:
			pts.append(v)
		stripe.polygon = pts
		stripe.color = Color(0.2, 0.15, 0.1)
		node.add_child(stripe)
	for sx in [-1, 1]:
		var wing := Polygon2D.new()
		wing.polygon = _make_circle_polygon(12, 20)
		wing.color = Color(0.8, 0.8, 1.0, 0.5)
		wing.position = Vector2(sx * 5, -30)
		node.add_child(wing)
	_add_glow(node, color, 1.5, 2.0)


func _draw_fly(color: Color) -> void:
	var node := _make_node("Fly", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _make_circle_polygon(16, 25)
	body.color = color
	node.add_child(body)
	var wing := Polygon2D.new()
	wing.polygon = _make_circle_polygon(10, 22)
	wing.color = Color(0.7, 0.7, 0.8, 0.4)
	wing.position = Vector2(0, -25)
	node.add_child(wing)
	_add_glow(node, color, 1.0, 2.0)


func _draw_owl(color: Color) -> void:
	var node := _make_node("Owl", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _make_circle_polygon(20, 45)
	body.color = color
	node.add_child(body)
	for x in [-18, 18]:
		var eye := Polygon2D.new()
		eye.polygon = _make_circle_polygon(14, 18)
		eye.color = Color.WHITE
		eye.position = Vector2(x, -15)
		node.add_child(eye)
		var pupil := Polygon2D.new()
		pupil.polygon = _make_circle_polygon(8, 8)
		pupil.color = Color.BLACK
		pupil.position = Vector2(x, -15)
		node.add_child(pupil)
	for x in [-35, 35]:
		var ear := Polygon2D.new()
		var pts := PackedVector2Array()
		for v in [Vector2(x, -45), Vector2(x - 12, -25), Vector2(x + 12, -25)]:
			pts.append(v)
		ear.polygon = pts
		ear.color = color
		node.add_child(ear)
	_add_glow(node, color, 1.5, 2.0)


func _draw_fox(color: Color) -> void:
	var node := _make_node("Fox", Vector2.ZERO)
	var face := Polygon2D.new()
	var face_pts := PackedVector2Array()
	for v in [Vector2(0, -35), Vector2(30, 0), Vector2(20, 30), Vector2(0, 45), Vector2(-20, 30), Vector2(-30, 0)]:
		face_pts.append(v)
	face.polygon = face_pts
	face.color = color
	node.add_child(face)
	for x in [-25, 25]:
		var ear := Polygon2D.new()
		var pts := PackedVector2Array()
		for v in [Vector2(x, -35), Vector2(x - 15, -60), Vector2(x + 5, -40)]:
			pts.append(v)
		ear.polygon = pts
		ear.color = color
		node.add_child(ear)
	var nose := Polygon2D.new()
	nose.polygon = _make_circle_polygon(6, 6)
	nose.color = Color.BLACK
	nose.position = Vector2(0, 25)
	node.add_child(nose)
	_add_glow(node, color, 1.5, 2.0)


func _draw_bat(color: Color) -> void:
	var node := _make_node("Bat", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _make_circle_polygon(12, 18)
	body.color = color
	node.add_child(body)
	var lw := Polygon2D.new()
	var lw_pts := PackedVector2Array()
	for v in [Vector2(-15, -10), Vector2(-60, -30), Vector2(-50, 0), Vector2(-60, 25), Vector2(-15, 15)]:
		lw_pts.append(v)
	lw.polygon = lw_pts
	lw.color = color
	node.add_child(lw)
	var rw := Polygon2D.new()
	var rw_pts := PackedVector2Array()
	for v in [Vector2(15, -10), Vector2(60, -30), Vector2(50, 0), Vector2(60, 25), Vector2(15, 15)]:
		rw_pts.append(v)
	rw.polygon = rw_pts
	rw.color = color
	node.add_child(rw)
	for x in [-8, 8]:
		var ear := Polygon2D.new()
		var pts := PackedVector2Array()
		for v in [Vector2(x, -18), Vector2(x - 4, -30), Vector2(x + 4, -30)]:
			pts.append(v)
		ear.polygon = pts
		ear.color = color
		node.add_child(ear)
	_add_glow(node, color, 1.5, 2.0)


func _draw_cat(color: Color) -> void:
	var node := _make_node("Cat", Vector2.ZERO)
	var face := Polygon2D.new()
	face.polygon = _make_circle_polygon(20, 40)
	face.color = color
	node.add_child(face)
	for x in [-30, 30]:
		var ear := Polygon2D.new()
		var pts := PackedVector2Array()
		for v in [Vector2(x, -35), Vector2(x - 15, -60), Vector2(x + 5, -40)]:
			pts.append(v)
		ear.polygon = pts
		ear.color = color
		node.add_child(ear)
	for x in [-15, 15]:
		var eye := Polygon2D.new()
		eye.polygon = _make_circle_polygon(8, 7)
		eye.color = Color(0.2, 1.0, 0.3)
		eye.position = Vector2(x, -5)
		node.add_child(eye)
	var nose := Polygon2D.new()
	var nose_pts := PackedVector2Array()
	for v in [Vector2(0, 15), Vector2(-5, 10), Vector2(5, 10)]:
		nose_pts.append(v)
	nose.polygon = nose_pts
	nose.color = Color(1.0, 0.3, 0.5)
	node.add_child(nose)
	_add_glow(node, color, 1.5, 2.0)


func _draw_dog(color: Color) -> void:
	var node := _make_node("Dog", Vector2.ZERO)
	var face := Polygon2D.new()
	face.polygon = _make_circle_polygon(20, 40)
	face.color = color
	node.add_child(face)
	for x in [-35, 35]:
		var ear := Polygon2D.new()
		var pts := PackedVector2Array()
		for v in [Vector2(x, -30), Vector2(x - 15, -10), Vector2(x + 5, -20)]:
			pts.append(v)
		ear.polygon = pts
		ear.color = Color(color.r * 0.7, color.g * 0.7, color.b * 0.7)
		node.add_child(ear)
	var nose := Polygon2D.new()
	nose.polygon = _make_circle_polygon(8, 10)
	nose.color = Color.BLACK
	nose.position = Vector2(0, 15)
	node.add_child(nose)
	_add_glow(node, color, 1.5, 2.0)


func _draw_bear(color: Color) -> void:
	var node := _make_node("Bear", Vector2.ZERO)
	var face := Polygon2D.new()
	face.polygon = _make_circle_polygon(20, 45)
	face.color = color
	node.add_child(face)
	for x in [-35, 35]:
		var ear := Polygon2D.new()
		ear.polygon = _make_circle_polygon(12, 18)
		ear.color = color
		ear.position = Vector2(x, -40)
		node.add_child(ear)
	var snout := Polygon2D.new()
	snout.polygon = _make_circle_polygon(10, 18)
	snout.color = Color(0.9, 0.8, 0.6)
	snout.position = Vector2(0, 12)
	node.add_child(snout)
	var nose := Polygon2D.new()
	nose.polygon = _make_circle_polygon(6, 7)
	nose.color = Color.BLACK
	nose.position = Vector2(0, 8)
	node.add_child(nose)
	_add_glow(node, color, 1.5, 2.0)


func _draw_wolf(color: Color) -> void:
	var node := _make_node("Wolf", Vector2.ZERO)
	var face := Polygon2D.new()
	var face_pts := PackedVector2Array()
	for v in [Vector2(0, -40), Vector2(28, -10), Vector2(22, 25), Vector2(0, 45), Vector2(-22, 25), Vector2(-28, -10)]:
		face_pts.append(v)
	face.polygon = face_pts
	face.color = color
	node.add_child(face)
	for x in [-25, 25]:
		var ear := Polygon2D.new()
		var pts := PackedVector2Array()
		for v in [Vector2(x, -38), Vector2(x - 15, -65), Vector2(x + 8, -42)]:
			pts.append(v)
		ear.polygon = pts
		ear.color = color
		node.add_child(ear)
	for x in [-12, 12]:
		var eye := Polygon2D.new()
		eye.polygon = _make_circle_polygon(6, 6)
		eye.color = Color(1.0, 0.9, 0.1)
		eye.position = Vector2(x, -5)
		node.add_child(eye)
	var nose := Polygon2D.new()
	nose.polygon = _make_circle_polygon(5, 6)
	nose.color = Color.BLACK
	nose.position = Vector2(0, 25)
	node.add_child(nose)
	_add_glow(node, color, 1.5, 2.0)


func _draw_bird(color: Color) -> void:
	var node := _make_node("Bird", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _make_circle_polygon(16, 30)
	body.color = color
	node.add_child(body)
	var wing := Polygon2D.new()
	var wing_pts := PackedVector2Array()
	for v in [Vector2(0, 0), Vector2(-30, -20), Vector2(-20, 15)]:
		wing_pts.append(v)
	wing.polygon = wing_pts
	wing.color = Color(color.r * 0.7, color.g * 0.7, color.b * 0.7)
	node.add_child(wing)
	var beak := Polygon2D.new()
	var beak_pts := PackedVector2Array()
	for v in [Vector2(25, -5), Vector2(45, 0), Vector2(25, 5)]:
		beak_pts.append(v)
	beak.polygon = beak_pts
	beak.color = Color(1.0, 0.7, 0.2)
	node.add_child(beak)
	var eye := Polygon2D.new()
	eye.polygon = _make_circle_polygon(6, 5)
	eye.color = Color.BLACK
	eye.position = Vector2(12, -8)
	node.add_child(eye)
	_add_glow(node, color, 1.5, 2.0)


func _draw_ghost(color: Color) -> void:
	var node := _make_node("Ghost", Vector2.ZERO)
	var ghost := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 16:
		var a := PI + PI * i / 15.0
		pts.append(Vector2(cos(a) * 35, sin(a) * 35 - 10))
	pts.append(Vector2(35, 25))
	pts.append(Vector2(20, 45))
	pts.append(Vector2(10, 25))
	pts.append(Vector2(0, 45))
	pts.append(Vector2(-10, 25))
	pts.append(Vector2(-20, 45))
	pts.append(Vector2(-35, 25))
	ghost.polygon = pts
	ghost.color = Color(color.r, color.g, color.b, 0.85)
	node.add_child(ghost)
	for x in [-12, 12]:
		var eye := Polygon2D.new()
		eye.polygon = _make_circle_polygon(6, 5)
		eye.color = Color.BLACK
		eye.position = Vector2(x, -15)
		node.add_child(eye)
	_add_glow(node, color, 2.0, 2.0)


func _draw_robot(color: Color) -> void:
	var node := _make_node("Robot", Vector2.ZERO)
	var head := Polygon2D.new()
	var head_pts := PackedVector2Array()
	for v in [Vector2(-35, -50), Vector2(35, -50), Vector2(35, 10), Vector2(-35, 10)]:
		head_pts.append(v)
	head.polygon = head_pts
	head.color = color
	node.add_child(head)
	var ant := Polygon2D.new()
	var ant_pts := PackedVector2Array()
	for v in [Vector2(-3, -50), Vector2(3, -50), Vector2(3, -70)]:
		ant_pts.append(v)
	ant.polygon = ant_pts
	ant.color = Color(0.5, 0.5, 0.5)
	node.add_child(ant)
	var ball := Polygon2D.new()
	ball.polygon = _make_circle_polygon(6, 6)
	ball.color = Color(1.0, 0.3, 0.3)
	ball.position = Vector2(0, -72)
	node.add_child(ball)
	for x in [-15, 15]:
		var eye := Polygon2D.new()
		eye.polygon = _make_circle_polygon(8, 8)
		eye.color = Color(0.2, 1.0, 0.3)
		eye.position = Vector2(x, -25)
		node.add_child(eye)
	var mouth := Polygon2D.new()
	var mouth_pts := PackedVector2Array()
	for v in [Vector2(-15, 0), Vector2(15, 0), Vector2(15, 5), Vector2(-15, 5)]:
		mouth_pts.append(v)
	mouth.polygon = mouth_pts
	mouth.color = Color.BLACK
	node.add_child(mouth)
	_add_glow(node, color, 1.5, 2.0)


func _draw_alien(color: Color) -> void:
	var node := _make_node("Alien", Vector2.ZERO)
	var head := Polygon2D.new()
	var head_pts := PackedVector2Array()
	for v in [Vector2(0, -50), Vector2(30, -20), Vector2(25, 20), Vector2(0, 35), Vector2(-25, 20), Vector2(-30, -20)]:
		head_pts.append(v)
	head.polygon = head_pts
	head.color = color
	node.add_child(head)
	for x in [-12, 12]:
		var eye := Polygon2D.new()
		var pts := PackedVector2Array()
		for i in 16:
			var a := TAU * i / 16.0
			pts.append(Vector2(cos(a) * 10, sin(a) * 5))
		eye.polygon = pts
		eye.color = Color.BLACK
		eye.position = Vector2(x, -10)
		eye.rotation = 0.3 if x > 0 else -0.3
		node.add_child(eye)
	_add_glow(node, color, 2.0, 2.0)


func _draw_storm(color: Color) -> void:
	var node := _make_node("Storm", Vector2.ZERO)
	var cloud := Polygon2D.new()
	cloud.polygon = _make_circle_polygon(20, 40)
	cloud.color = color
	cloud.position = Vector2(0, -10)
	node.add_child(cloud)
	var bolt := Polygon2D.new()
	var bolt_pts := PackedVector2Array()
	for v in [Vector2(5, 10), Vector2(-10, 40), Vector2(0, 40), Vector2(-5, 60), Vector2(10, 30), Vector2(0, 30)]:
		bolt_pts.append(v)
	bolt.polygon = bolt_pts
	bolt.color = Color(1.0, 0.9, 0.2)
	node.add_child(bolt)
	_add_glow(node, Color(1.0, 0.9, 0.2), 3.0, 2.0)


func _draw_thunder(color: Color) -> void:
	var node := _make_node("Thunder", Vector2.ZERO)
	var bolt := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(15, -60), Vector2(-10, 0), Vector2(5, 0), Vector2(-15, 60), Vector2(10, 10), Vector2(-5, 10)]:
		pts.append(v)
	bolt.polygon = pts
	bolt.color = color
	node.add_child(bolt)
	_add_glow(node, color, 4.0, 3.0)


func _draw_light(color: Color) -> void:
	var node := _make_node("Light", Vector2.ZERO)
	var bulb := Polygon2D.new()
	bulb.polygon = _make_circle_polygon(24, 35)
	bulb.color = color
	bulb.position = Vector2(0, -10)
	node.add_child(bulb)
	var base := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-12, 20), Vector2(12, 20), Vector2(10, 40), Vector2(-10, 40)]:
		pts.append(v)
	base.polygon = pts
	base.color = Color(0.5, 0.5, 0.5)
	node.add_child(base)
	_add_glow(node, color, 4.0, 3.0)


func _draw_shine(color: Color) -> void:
	var node := _make_node("Shine", Vector2.ZERO)
	var main := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 8:
		var a := -PI / 2 + TAU * i / 8.0
		var r := 60.0 if i % 2 == 0 else 12.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	main.polygon = pts
	main.color = color
	node.add_child(main)
	var small := Polygon2D.new()
	var pts2 := PackedVector2Array()
	for i in 8:
		var a := -PI / 2 + TAU * i / 8.0
		var r := 20.0 if i % 2 == 0 else 5.0
		pts2.append(Vector2(cos(a), sin(a)) * r + Vector2(45, -40))
	small.polygon = pts2
	small.color = color
	node.add_child(small)
	_add_glow(node, color, 3.0, 3.0)


func _draw_galaxy(color: Color) -> void:
	var node := _make_node("Galaxy", Vector2.ZERO)
	for arm in 3:
		var arm_pts := PackedVector2Array()
		for i in 40:
			var t := float(i) / 40.0
			var a := t * TAU * 2 + arm * TAU / 3.0
			var r := t * 60
			arm_pts.append(Vector2(cos(a), sin(a)) * r)
		var line := Line2D.new()
		line.points = arm_pts
		line.width = 8.0
		line.default_color = color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		node.add_child(line)
	var center := Polygon2D.new()
	center.polygon = _make_circle_polygon(16, 18)
	center.color = Color(1.0, 1.0, 0.8)
	node.add_child(center)
	_add_glow(node, color, 3.0, 3.0)


func _draw_nebula(color: Color) -> void:
	var node := _make_node("Nebula", Vector2.ZERO)
	for i in 6:
		var blob := Polygon2D.new()
		blob.polygon = _make_circle_polygon(16, randf_range(20, 40))
		blob.color = Color(color.r + randf_range(-0.1, 0.1), color.g + randf_range(-0.1, 0.1), color.b + randf_range(-0.1, 0.1), 0.4)
		blob.position = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		node.add_child(blob)
	_add_glow(node, color, 2.0, 4.0)


func _draw_cosmos(color: Color) -> void:
	var node := _make_node("Cosmos", Vector2.ZERO)
	for i in 15:
		var star := Polygon2D.new()
		var pts := PackedVector2Array()
		for j in 8:
			var a := -PI / 2 + TAU * j / 8.0
			var r := 10.0 if j % 2 == 0 else 3.0
			pts.append(Vector2(cos(a), sin(a)) * r)
		star.polygon = pts
		star.color = Color(color.r + randf_range(-0.2, 0.2), color.g + randf_range(-0.2, 0.2), color.b + randf_range(-0.2, 0.2))
		star.position = Vector2(randf_range(-60, 60), randf_range(-60, 60))
		node.add_child(star)
	_add_glow(node, color, 1.5, 4.0)


func _draw_orbit(color: Color) -> void:
	var node := _make_node("Orbit", Vector2.ZERO)
	var sun := Polygon2D.new()
	sun.polygon = _make_circle_polygon(12, 15)
	sun.color = Color(1.0, 0.8, 0.2)
	node.add_child(sun)
	var path := Line2D.new()
	var path_pts := PackedVector2Array()
	for i in 32:
		var a := TAU * i / 32.0
		path_pts.append(Vector2(cos(a) * 55, sin(a) * 55))
	path.points = path_pts
	path.width = 2.0
	path.default_color = Color(color.r, color.g, color.b, 0.4)
	node.add_child(path)
	var planet := Polygon2D.new()
	planet.polygon = _make_circle_polygon(8, 10)
	planet.color = color
	planet.position = Vector2(55, 0)
	node.add_child(planet)
	_add_glow(node, color, 1.5, 2.0)


func _draw_power(color: Color) -> void:
	var node := _make_node("Power", Vector2.ZERO)
	var circle := Polygon2D.new()
	circle.polygon = _make_circle_polygon(24, 45)
	circle.color = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3)
	node.add_child(circle)
	var bolt := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(10, -30), Vector2(-10, 5), Vector2(3, 5), Vector2(-10, 30), Vector2(10, -5), Vector2(-3, -5)]:
		pts.append(v)
	bolt.polygon = pts
	bolt.color = color
	node.add_child(bolt)
	_add_glow(node, color, 3.0, 3.0)


func _draw_sword(color: Color) -> void:
	var node := _make_node("Sword", Vector2.ZERO)
	var blade := Polygon2D.new()
	var blade_pts := PackedVector2Array()
	for v in [Vector2(0, -65), Vector2(8, -50), Vector2(8, 20), Vector2(-8, 20), Vector2(-8, -50)]:
		blade_pts.append(v)
	blade.polygon = blade_pts
	blade.color = color
	node.add_child(blade)
	var guard := Polygon2D.new()
	var guard_pts := PackedVector2Array()
	for v in [Vector2(-25, 20), Vector2(25, 20), Vector2(25, 28), Vector2(-25, 28)]:
		guard_pts.append(v)
	guard.polygon = guard_pts
	guard.color = Color(1.0, 0.8, 0.2)
	node.add_child(guard)
	var handle := Polygon2D.new()
	var handle_pts := PackedVector2Array()
	for v in [Vector2(-5, 28), Vector2(5, 28), Vector2(5, 50), Vector2(-5, 50)]:
		handle_pts.append(v)
	handle.polygon = handle_pts
	handle.color = Color(0.5, 0.3, 0.2)
	node.add_child(handle)
	_add_glow(node, color, 1.5, 2.0)


func _draw_shield(color: Color) -> void:
	var node := _make_node("Shield", Vector2.ZERO)
	var shield := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -55), Vector2(40, -35), Vector2(40, 10), Vector2(0, 55), Vector2(-40, 10), Vector2(-40, -35)]:
		pts.append(v)
	shield.polygon = pts
	shield.color = color
	node.add_child(shield)
	var v_bar := Polygon2D.new()
	var v_pts := PackedVector2Array()
	for v in [Vector2(-5, -30), Vector2(5, -30), Vector2(5, 30), Vector2(-5, 30)]:
		v_pts.append(v)
	v_bar.polygon = v_pts
	v_bar.color = Color(1.0, 1.0, 0.9)
	node.add_child(v_bar)
	var h_bar := Polygon2D.new()
	var h_pts := PackedVector2Array()
	for v in [Vector2(-20, -5), Vector2(20, -5), Vector2(20, 5), Vector2(-20, 5)]:
		h_pts.append(v)
	h_bar.polygon = h_pts
	h_bar.color = Color(1.0, 1.0, 0.9)
	node.add_child(h_bar)
	_add_glow(node, color, 2.0, 2.0)


func _draw_gamepad(color: Color) -> void:
	var node := _make_node("Gamepad", Vector2.ZERO)
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-50, -25), Vector2(50, -25), Vector2(55, 10), Vector2(35, 30), Vector2(-35, 30), Vector2(-55, 10)]:
		pts.append(v)
	body.polygon = pts
	body.color = color
	node.add_child(body)
	for dir in [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]:
		var btn := Polygon2D.new()
		var btn_pts := PackedVector2Array()
		for v in [Vector2(-5, -5), Vector2(5, -5), Vector2(5, 5), Vector2(-5, 5)]:
			btn_pts.append(v)
		btn.polygon = btn_pts
		btn.color = Color(0.2, 0.2, 0.2)
		btn.position = Vector2(-25, 0) + dir * 12
		node.add_child(btn)
	for pos in [Vector2(20, -8), Vector2(35, 0), Vector2(20, 8), Vector2(28, -2)]:
		var btn := Polygon2D.new()
		btn.polygon = _make_circle_polygon(8, 6)
		btn.color = Color(0.2, 0.2, 0.2)
		btn.position = pos
		node.add_child(btn)
	_add_glow(node, color, 1.5, 2.0)


func _draw_ice(color: Color) -> void:
	var node := _make_node("Ice", Vector2.ZERO)
	var shard := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(30, 0), Vector2(0, 60), Vector2(-30, 0)]:
		pts.append(v)
	shard.polygon = pts
	shard.color = color
	node.add_child(shard)
	var shine := Polygon2D.new()
	var pts2 := PackedVector2Array()
	for v in [Vector2(0, -40), Vector2(15, 0), Vector2(0, 40), Vector2(-15, 0)]:
		pts2.append(v)
	shine.polygon = pts2
	shine.color = Color(0.9, 0.95, 1.0, 0.7)
	node.add_child(shine)
	_add_glow(node, color, 2.0, 2.0)


func _draw_arc_icon(color: Color) -> void:
	var node := _make_node("Arc", Vector2.ZERO)
	var arc := Line2D.new()
	arc.width = 12.0
	arc.default_color = color
	for i in 20:
		var t := float(i) / 19.0
		var a := PI * t
		arc.add_point(Vector2(cos(a) * 60, -sin(a) * 60))
	node.add_child(arc)
	_add_glow(node, color, 2.0, 3.0)


func _draw_orb(color: Color) -> void:
	var node := _make_node("Orb", Vector2.ZERO)
	var orb := Polygon2D.new()
	orb.polygon = _make_circle_polygon(24, 50)
	orb.color = color
	node.add_child(orb)
	var inner := Polygon2D.new()
	inner.polygon = _make_circle_polygon(16, 25)
	inner.color = Color(1.0, 1.0, 1.0, 0.3)
	inner.position = Vector2(-10, -10)
	node.add_child(inner)
	_add_glow(node, color, 3.0, 3.0)


func _draw_gas(color: Color) -> void:
	var node := _make_node("Gas", Vector2.ZERO)
	for i in 5:
		var blob := Polygon2D.new()
		blob.polygon = _make_circle_polygon(12, randf_range(20, 35))
		blob.color = Color(color.r, color.g, color.b, 0.3)
		blob.position = Vector2(randf_range(-25, 25), randf_range(-25, 25))
		node.add_child(blob)
	_add_glow(node, color, 1.5, 3.0)


func _draw_ray(color: Color) -> void:
	var node := _make_node("Ray", Vector2.ZERO)
	var ray := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-40, 50), Vector2(40, 50), Vector2(5, -50), Vector2(-5, -50)]:
		pts.append(v)
	ray.polygon = pts
	ray.color = color
	node.add_child(ray)
	var src := Polygon2D.new()
	src.polygon = _make_circle_polygon(12, 12)
	src.color = Color.WHITE
	src.position = Vector2(0, -50)
	node.add_child(src)
	_add_glow(node, color, 3.0, 2.0)


func _draw_body_part(color: Color) -> void:
	var node := _make_node("Body", Vector2.ZERO)
	var part := Polygon2D.new()
	part.polygon = _make_circle_polygon(20, 40)
	part.color = color
	node.add_child(part)
	_add_glow(node, color, 1.5, 2.0)


func _draw_default(color: Color) -> void:
	var node := _make_node("Default", Vector2.ZERO)
	for i in 8:
		var a := TAU * i / 8.0
		var line := Line2D.new()
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2(cos(a), sin(a)) * 60)
		line.width = 6.0
		line.default_color = color
		node.add_child(line)
	var center := Polygon2D.new()
	center.polygon = _make_circle_polygon(16, 20)
	center.color = color
	node.add_child(center)
	_add_glow(node, color, 3.0, 3.0)


# ---- Animation ----

func _animate_icon(word: String) -> void:
	if _icon_tween:
		_icon_tween.kill()
	if _icon_container.get_child_count() == 0:
		return
	var icon := _icon_container.get_child(0)
	var w := word.to_upper()
	match w:
		"SUN", "SOLAR":
			_icon_tween = create_tween().set_loops(3)
			_icon_tween.tween_property(icon, "rotation", TAU, 2.0)
			_icon_tween.parallel().tween_property(icon, "scale", Vector2(1.1, 1.1), 0.5)
			_icon_tween.tween_property(icon, "scale", Vector2.ONE, 0.5)
		"STAR", "SHINE":
			_icon_tween = create_tween().set_loops(4)
			_icon_tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.2)
			_icon_tween.tween_property(icon, "scale", Vector2.ONE, 0.2)
		"EYE":
			_icon_tween = create_tween().set_loops(3)
			_icon_tween.tween_property(icon, "scale:y", 0.1, 0.1)
			_icon_tween.tween_property(icon, "scale:y", 1.0, 0.1)
			_icon_tween.tween_interval(0.5)
		"FIRE", "FLAME":
			_icon_tween = create_tween().set_loops(5)
			_icon_tween.tween_property(icon, "scale", Vector2(1.05, 1.15), 0.1)
			_icon_tween.tween_property(icon, "scale", Vector2(0.95, 0.95), 0.1)
		"ROCKET", "SPACESHIP", "JET":
			_icon_tween = create_tween().set_loops(6)
			_icon_tween.tween_property(icon, "position:x", -3.0, 0.03)
			_icon_tween.tween_property(icon, "position:x", 3.0, 0.03)
		"MOON", "GHOST", "FLY", "ALIEN":
			_icon_tween = create_tween().set_loops(3)
			_icon_tween.tween_property(icon, "position:y", icon.position.y - 15, 0.5).set_trans(Tween.TRANS_SINE)
			_icon_tween.tween_property(icon, "position:y", icon.position.y, 0.5).set_trans(Tween.TRANS_SINE)
		"BEE", "BIRD":
			_icon_tween = create_tween().set_loops(3)
			_icon_tween.tween_property(icon, "position:y", icon.position.y - 10, 0.3)
			_icon_tween.tween_property(icon, "position:y", icon.position.y, 0.3)
		"GALAXY", "PLANET", "EARTH", "MARS", "VENUS", "URANUS", "SATURN", "COSMOS":
			_icon_tween = create_tween().set_loops(2)
			_icon_tween.tween_property(icon, "rotation", TAU, 1.5)
		"LASER", "RAY":
			_icon_tween = create_tween().set_loops(4)
			_icon_tween.tween_property(icon, "modulate:a", 0.5, 0.05)
			_icon_tween.tween_property(icon, "modulate:a", 1.0, 0.05)
		"THUNDER", "STORM", "LIGHT", "POWER":
			_icon_tween = create_tween().set_loops(5)
			_icon_tween.tween_property(icon, "modulate:a", 0.3, 0.05)
			_icon_tween.tween_property(icon, "modulate:a", 1.0, 0.05)
			_icon_tween.tween_property(icon, "scale", Vector2(1.1, 1.1), 0.05)
			_icon_tween.tween_property(icon, "scale", Vector2.ONE, 0.05)
		_:
			_icon_tween = create_tween().set_loops(3)
			_icon_tween.tween_property(icon, "scale", Vector2(1.1, 1.1), 0.3)
			_icon_tween.tween_property(icon, "scale", Vector2.ONE, 0.3)