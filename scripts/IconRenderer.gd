class_name IconRenderer
## IconRenderer - 단어별 네온 아이콘을 그려주는 유틸리티
## WordReveal과 DictionaryPage에서 공통으로 사용

static func draw_icon(word: String, container: Node2D) -> void:
	var w := word.to_upper()
	var gold := Color(1.0, 0.9, 0.3)
	match w:
		"SUN", "SOLAR":
			_draw_sun(container, gold if w == "SUN" else Color(1.0, 0.7, 0.2))
		"STAR":
			_draw_star(container, gold)
		"MOON":
			_draw_moon(container, Color(0.8, 0.8, 1.0))
		"MARS":
			_draw_planet(container, Color(1.0, 0.4, 0.2))
		"EARTH":
			_draw_planet(container, Color(0.2, 0.6, 1.0))
		"VENUS":
			_draw_planet(container, Color(1.0, 0.7, 0.3))
		"SATURN":
			_draw_planet_ring(container, Color(0.9, 0.8, 0.5))
		"COMET", "COMETS", "METEOR":
			_draw_comet(container, Color(0.5, 0.9, 1.0) if w == "COMET" else Color(1.0, 0.5, 0.3))
		"SKY":
			_draw_sky(container, Color(0.3, 0.6, 2.0))
		"EYE":
			_draw_eye(container, Color(0.3, 1.0, 0.5))
		"FIRE", "FLAME":
			_draw_flame(container, Color(1.0, 0.4, 0.1))
		"GEM", "CRYSTAL", "GOLD":
			_draw_gem(container, gold if w == "GOLD" else (Color(0.3, 1.0, 0.9) if w == "GEM" else Color(0.6, 0.3, 1.0)))
		"RED":
			_draw_circle_icon(container, Color(1.0, 0.2, 0.2))
		"BLUE":
			_draw_circle_icon(container, Color(0.2, 0.4, 1.0))
		"PINK":
			_draw_circle_icon(container, Color(1.0, 0.4, 0.8))
		"GREEN":
			_draw_circle_icon(container, Color(0.2, 1.0, 0.3))
		"ROCKET":
			_draw_rocket(container, Color(0.9, 0.9, 1.0))
		"SPACESHIP":
			_draw_rocket(container, Color(0.7, 0.8, 1.0))
		"LASER":
			_draw_laser(container, Color(1.0, 0.2, 0.8))
		"RAY":
			_draw_ray(container, gold)
		"GUN":
			_draw_gun(container, Color(0.7, 0.7, 0.8))
		"JET":
			_draw_jet(container, Color(0.8, 0.8, 0.9))
		"FISH":
			_draw_fish(container, Color(0.3, 0.8, 1.0))
		"BEE":
			_draw_bee(container, Color(1.0, 0.8, 0.2))
		"FLY":
			_draw_fly(container, Color(0.6, 0.6, 0.7))
		"OWL":
			_draw_owl(container, Color(0.7, 0.5, 0.3))
		"FOX":
			_draw_fox(container, Color(1.0, 0.5, 0.2))
		"BAT":
			_draw_bat(container, Color(0.5, 0.3, 0.7))
		"CAT":
			_draw_cat(container, Color(0.8, 0.6, 0.3))
		"DOG":
			_draw_dog(container, Color(0.7, 0.5, 0.3))
		"BEAR":
			_draw_bear(container, Color(0.6, 0.4, 0.2))
		"WOLF":
			_draw_wolf(container, Color(0.5, 0.5, 0.6))
		"BIRD":
			_draw_bird(container, Color(0.3, 0.9, 1.0))
		"GHOST":
			_draw_ghost(container, Color(0.8, 0.8, 1.0))
		"ROBOT", "ANDROID", "CYBORG":
			_draw_robot(container, Color(0.6, 0.8, 1.0))
		"ALIEN":
			_draw_alien(container, Color(0.4, 1.0, 0.4))
		"STORM":
			_draw_storm(container, Color(0.5, 0.5, 0.8))
		"THUNDER":
			_draw_thunder(container, Color(1.0, 0.9, 0.2))
		"LIGHT":
			_draw_light(container, Color(1.0, 1.0, 0.8))
		"SHINE":
			_draw_shine(container, Color(1.0, 0.9, 0.5))
		"POWER":
			_draw_power(container, gold)
		"GALAXY":
			_draw_galaxy(container, Color(0.6, 0.3, 1.0))
		"NEBULA":
			_draw_nebula(container, Color(0.5, 0.2, 0.8))
		"COSMOS":
			_draw_cosmos(container, Color(0.3, 0.5, 1.0))
		"PLANET", "URANUS":
			_draw_planet(container, Color(0.3, 0.7, 1.0) if w == "PLANET" else Color(0.4, 0.9, 0.9))
		"ORBIT":
			_draw_orbit(container, Color(0.4, 0.8, 1.0))
		"SWORD", "BLADE":
			_draw_sword(container, Color(0.8, 0.8, 0.9))
		"SHIELD":
			_draw_shield(container, Color(0.3, 0.6, 1.0))
		"GAME", "PLAY", "MOVE":
			_draw_gamepad(container, Color(0.3, 1.0, 0.5))
		"ICE":
			_draw_ice(container, Color(0.5, 0.9, 1.0))
		"ARC":
			_draw_arc_icon(container, Color(0.3, 1.0, 0.9))
		"ORB":
			_draw_orb(container, Color(0.5, 0.3, 1.0))
		"GAS":
			_draw_gas(container, Color(0.6, 0.8, 0.4))
		"LEG", "ARM", "EAR":
			_draw_body_part(container, Color(0.9, 0.7, 0.5))
		"STARDUST":
			_draw_cosmos(container, Color(1.0, 0.9, 0.5))
		"SPACESHIP":
			_draw_rocket(container, Color(0.7, 0.8, 1.0))
		"ASTEROID":
			_draw_gas(container, Color(0.6, 0.5, 0.4))
		"VOLCANO":
			_draw_flame(container, Color(1.0, 0.3, 0.1))
		"PHANTOM":
			_draw_ghost(container, Color(0.6, 0.4, 1.0))
		"HARDCORE":
			_draw_thunder(container, Color(1.0, 0.2, 0.2))
		"VICTORY":
			_draw_star(container, gold)
		_:
			_draw_default(container, gold)


# ---- Helpers ----

static func _make_node(parent: Node2D, icon_name: String, pos: Vector2) -> Node2D:
	var node := Node2D.new()
	node.name = icon_name
	node.position = pos
	parent.add_child(node)
	return node

static func _add_glow(parent: Node2D, color: Color, energy: float, scale_val: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.color = color
	light.energy = energy
	light.texture_scale = scale_val
	parent.add_child(light)
	return light

static func _make_circle_polygon(segments: int, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var a := TAU * i / segments
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

static func _circle(r: float) -> PackedVector2Array:
	return _make_circle_polygon(30, r)

static func _ellipse(rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 30:
		var a := TAU * i / 30.0
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	return pts


# ---- Icons ----

static func _draw_sun(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Sun", Vector2.ZERO)
	var corona := Polygon2D.new()
	corona.polygon = _make_circle_polygon(40, 60)
	corona.color = Color(color.r, color.g, color.b, 0.15)
	node.add_child(corona)
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
	var circle := Polygon2D.new()
	circle.polygon = _circle(42)
	circle.color = color
	node.add_child(circle)
	var highlight := Polygon2D.new()
	highlight.polygon = _make_circle_polygon(24, 15)
	highlight.color = Color(1.0, 1.0, 1.0, 0.5)
	highlight.position = Vector2(-12, -12)
	node.add_child(highlight)
	var core := Polygon2D.new()
	core.polygon = _circle(25)
	core.color = Color(minf(color.r + 0.3, 1.0), minf(color.g + 0.3, 1.0), minf(color.b + 0.2, 1.0), 0.5)
	core.position = Vector2(-5, -5)
	node.add_child(core)
	_add_glow(node, color, 3.5, 4.5)

static func _draw_star(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Star", Vector2.ZERO)
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

static func _draw_moon(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Moon", Vector2.ZERO)
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

static func _draw_planet(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Planet", Vector2.ZERO)
	var halo := Polygon2D.new()
	halo.polygon = _make_circle_polygon(40, 58)
	halo.color = Color(color.r, color.g, color.b, 0.15)
	node.add_child(halo)
	var planet := Polygon2D.new()
	planet.polygon = _circle(50)
	planet.color = color
	node.add_child(planet)
	var shadow := Polygon2D.new()
	shadow.polygon = _circle(50)
	shadow.color = Color(0.0, 0.0, 0.1, 0.4)
	shadow.position = Vector2(18, 12)
	node.add_child(shadow)
	var highlight := Polygon2D.new()
	highlight.polygon = _make_circle_polygon(20, 18)
	highlight.color = Color(1.0, 1.0, 1.0, 0.3)
	highlight.position = Vector2(-18, -18)
	node.add_child(highlight)
	_add_glow(node, color, 2.5, 3.5)

static func _draw_planet_ring(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "PlanetRing", Vector2.ZERO)
	var halo := Polygon2D.new()
	halo.polygon = _make_circle_polygon(40, 58)
	halo.color = Color(color.r, color.g, color.b, 0.15)
	node.add_child(halo)
	var planet := Polygon2D.new()
	planet.polygon = _circle(50)
	planet.color = color
	node.add_child(planet)
	var shadow := Polygon2D.new()
	shadow.polygon = _circle(50)
	shadow.color = Color(0.0, 0.0, 0.1, 0.4)
	shadow.position = Vector2(18, 12)
	node.add_child(shadow)
	var ring := Polygon2D.new()
	ring.polygon = _ellipse(85, 22)
	ring.color = Color(color.r * 0.8, color.g * 0.8, color.b * 0.8, 0.7)
	node.add_child(ring)
	var highlight := Polygon2D.new()
	highlight.polygon = _make_circle_polygon(20, 18)
	highlight.color = Color(1.0, 1.0, 1.0, 0.3)
	highlight.position = Vector2(-18, -18)
	node.add_child(highlight)
	_add_glow(node, color, 2.5, 3.5)

static func _draw_comet(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Comet", Vector2.ZERO)
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

static func _draw_sky(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Sky", Vector2.ZERO)
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

static func _draw_eye(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Eye", Vector2.ZERO)
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

static func _draw_flame(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Flame", Vector2.ZERO)
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

static func _draw_gem(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Gem", Vector2.ZERO)
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

static func _draw_circle_icon(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Circle", Vector2.ZERO)
	var circle := Polygon2D.new()
	circle.polygon = _circle(50)
	circle.color = color
	node.add_child(circle)
	_add_glow(node, color, 3.0, 3.0)

static func _draw_rocket(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Rocket", Vector2.ZERO)
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
	var body := Polygon2D.new()
	var body_pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(18, -20), Vector2(18, 38), Vector2(-18, 38), Vector2(-18, -20)]:
		body_pts.append(v)
	body.polygon = body_pts
	body.color = color
	node.add_child(body)
	var window_glass := Polygon2D.new()
	window_glass.polygon = _make_circle_polygon(12, 10)
	window_glass.color = Color(0.3, 0.8, 1.0)
	window_glass.position = Vector2(0, -15)
	node.add_child(window_glass)
	for sx in [1, -1]:
		var fin := Polygon2D.new()
		var fin_pts := PackedVector2Array()
		for v in [Vector2(sx * 20, 10), Vector2(sx * 38, 48), Vector2(sx * 20, 40)]:
			fin_pts.append(v)
		fin.polygon = fin_pts
		fin.color = Color(1.0, 0.3, 0.3)
		node.add_child(fin)
	_add_glow(node, Color(1.0, 0.5, 0.2), 2.5, 3.0)

static func _draw_laser(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Laser", Vector2.ZERO)
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

static func _draw_gun(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Gun", Vector2.ZERO)
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-40, -15), Vector2(30, -15), Vector2(30, 0), Vector2(10, 0), Vector2(10, 30), Vector2(-10, 30), Vector2(-10, 0), Vector2(-40, 0)]:
		pts.append(v)
	body.polygon = pts
	body.color = color
	node.add_child(body)
	_add_glow(node, color, 1.5, 2.0)

static func _draw_jet(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Jet", Vector2.ZERO)
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(15, 20), Vector2(50, 40), Vector2(15, 40), Vector2(0, 55), Vector2(-15, 40), Vector2(-50, 40), Vector2(-15, 20)]:
		pts.append(v)
	body.polygon = pts
	body.color = color
	node.add_child(body)
	_add_glow(node, color, 1.5, 2.0)

static func _draw_fish(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Fish", Vector2.ZERO)
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

static func _draw_bee(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Bee", Vector2.ZERO)
	var body := Polygon2D.new()
	body.polygon = _make_circle_polygon(20, 30)
	body.color = color
	node.add_child(body)
	for sx in [-1, 1]:
		var wing := Polygon2D.new()
		wing.polygon = _make_circle_polygon(12, 20)
		wing.color = Color(0.8, 0.8, 1.0, 0.5)
		wing.position = Vector2(sx * 5, -30)
		node.add_child(wing)
	_add_glow(node, color, 1.5, 2.0)

static func _draw_fly(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Fly", Vector2.ZERO)
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

static func _draw_owl(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Owl", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_fox(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Fox", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_bat(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Bat", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_cat(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Cat", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_dog(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Dog", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_bear(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Bear", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_wolf(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Wolf", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_bird(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Bird", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_ghost(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Ghost", Vector2.ZERO)
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
	_add_glow(node, color, 2.0, 2.0)

static func _draw_robot(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Robot", Vector2.ZERO)
	var head := Polygon2D.new()
	var head_pts := PackedVector2Array()
	for v in [Vector2(-35, -50), Vector2(35, -50), Vector2(35, 10), Vector2(-35, 10)]:
		head_pts.append(v)
	head.polygon = head_pts
	head.color = color
	node.add_child(head)
	for x in [-15, 15]:
		var eye := Polygon2D.new()
		eye.polygon = _make_circle_polygon(8, 8)
		eye.color = Color(0.2, 1.0, 0.3)
		eye.position = Vector2(x, -25)
		node.add_child(eye)
	_add_glow(node, color, 1.5, 2.0)

static func _draw_alien(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Alien", Vector2.ZERO)
	var head := Polygon2D.new()
	var head_pts := PackedVector2Array()
	for v in [Vector2(0, -50), Vector2(30, -20), Vector2(25, 20), Vector2(0, 35), Vector2(-25, 20), Vector2(-30, -20)]:
		head_pts.append(v)
	head.polygon = head_pts
	head.color = color
	node.add_child(head)
	_add_glow(node, color, 2.0, 2.0)

static func _draw_storm(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Storm", Vector2.ZERO)
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

static func _draw_thunder(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Thunder", Vector2.ZERO)
	var bolt := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(15, -60), Vector2(-10, 0), Vector2(5, 0), Vector2(-15, 60), Vector2(10, 10), Vector2(-5, 10)]:
		pts.append(v)
	bolt.polygon = pts
	bolt.color = color
	node.add_child(bolt)
	_add_glow(node, color, 4.0, 3.0)

static func _draw_light(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Light", Vector2.ZERO)
	var bulb := Polygon2D.new()
	bulb.polygon = _make_circle_polygon(24, 35)
	bulb.color = color
	bulb.position = Vector2(0, -10)
	node.add_child(bulb)
	_add_glow(node, color, 4.0, 3.0)

static func _draw_shine(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Shine", Vector2.ZERO)
	var main := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 8:
		var a := -PI / 2 + TAU * i / 8.0
		var r := 60.0 if i % 2 == 0 else 12.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	main.polygon = pts
	main.color = color
	node.add_child(main)
	_add_glow(node, color, 3.0, 3.0)

static func _draw_galaxy(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Galaxy", Vector2.ZERO)
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
		node.add_child(line)
	var center := Polygon2D.new()
	center.polygon = _make_circle_polygon(16, 18)
	center.color = Color(1.0, 1.0, 0.8)
	node.add_child(center)
	_add_glow(node, color, 3.0, 3.0)

static func _draw_nebula(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Nebula", Vector2.ZERO)
	for i in 6:
		var blob := Polygon2D.new()
		blob.polygon = _make_circle_polygon(16, randf_range(20, 40))
		blob.color = Color(color.r + randf_range(-0.1, 0.1), color.g + randf_range(-0.1, 0.1), color.b + randf_range(-0.1, 0.1), 0.4)
		blob.position = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		node.add_child(blob)
	_add_glow(node, color, 2.0, 4.0)

static func _draw_cosmos(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Cosmos", Vector2.ZERO)
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

static func _draw_orbit(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Orbit", Vector2.ZERO)
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

static func _draw_power(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Power", Vector2.ZERO)
	var bolt := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(10, -30), Vector2(-10, 5), Vector2(3, 5), Vector2(-10, 30), Vector2(10, -5), Vector2(-3, -5)]:
		pts.append(v)
	bolt.polygon = pts
	bolt.color = color
	node.add_child(bolt)
	_add_glow(node, color, 3.0, 3.0)

static func _draw_sword(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Sword", Vector2.ZERO)
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
	_add_glow(node, color, 1.5, 2.0)

static func _draw_shield(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Shield", Vector2.ZERO)
	var shield := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -55), Vector2(40, -35), Vector2(40, 10), Vector2(0, 55), Vector2(-40, 10), Vector2(-40, -35)]:
		pts.append(v)
	shield.polygon = pts
	shield.color = color
	node.add_child(shield)
	_add_glow(node, color, 2.0, 2.0)

static func _draw_gamepad(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Gamepad", Vector2.ZERO)
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-50, -25), Vector2(50, -25), Vector2(55, 10), Vector2(35, 30), Vector2(-35, 30), Vector2(-55, 10)]:
		pts.append(v)
	body.polygon = pts
	body.color = color
	node.add_child(body)
	_add_glow(node, color, 1.5, 2.0)

static func _draw_ice(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Ice", Vector2.ZERO)
	var shard := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(0, -60), Vector2(30, 0), Vector2(0, 60), Vector2(-30, 0)]:
		pts.append(v)
	shard.polygon = pts
	shard.color = color
	node.add_child(shard)
	_add_glow(node, color, 2.0, 2.0)

static func _draw_arc_icon(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Arc", Vector2.ZERO)
	var arc := Line2D.new()
	arc.width = 12.0
	arc.default_color = color
	for i in 20:
		var t := float(i) / 19.0
		var a := PI * t
		arc.add_point(Vector2(cos(a) * 60, -sin(a) * 60))
	node.add_child(arc)
	_add_glow(node, color, 2.0, 3.0)

static func _draw_orb(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Orb", Vector2.ZERO)
	var orb := Polygon2D.new()
	orb.polygon = _make_circle_polygon(24, 50)
	orb.color = color
	node.add_child(orb)
	_add_glow(node, color, 3.0, 3.0)

static func _draw_gas(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Gas", Vector2.ZERO)
	for i in 5:
		var blob := Polygon2D.new()
		blob.polygon = _make_circle_polygon(12, randf_range(20, 35))
		blob.color = Color(color.r, color.g, color.b, 0.3)
		blob.position = Vector2(randf_range(-25, 25), randf_range(-25, 25))
		node.add_child(blob)
	_add_glow(node, color, 1.5, 3.0)

static func _draw_ray(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Ray", Vector2.ZERO)
	var ray := Polygon2D.new()
	var pts := PackedVector2Array()
	for v in [Vector2(-40, 50), Vector2(40, 50), Vector2(5, -50), Vector2(-5, -50)]:
		pts.append(v)
	ray.polygon = pts
	ray.color = color
	node.add_child(ray)
	_add_glow(node, color, 3.0, 2.0)

static func _draw_body_part(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Body", Vector2.ZERO)
	var part := Polygon2D.new()
	part.polygon = _make_circle_polygon(20, 40)
	part.color = color
	node.add_child(part)
	_add_glow(node, color, 1.5, 2.0)

static func _draw_default(container: Node2D, color: Color) -> void:
	var node := _make_node(container, "Default", Vector2.ZERO)
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