class_name ShipAura
extends Node2D
## 기체 주위에 도는 네온 오라. 상위 스킨일수록 강해지는 **보이는 보상**이다.
##
## 프로젝트가 전부 `_draw` 기반이라 이미지 에셋 없이 같은 방식으로 그린다
## (APK 증가 0, 어떤 해상도에서도 선명).
##
## `draw_hull = true` 로 두면 기체 실루엣까지 함께 그린다 — 메뉴의 스킨 미리보기용.
## 게임 안에서는 Player.tscn 의 Polygon2D 가 기체를 그리므로 오라만 그린다.

@export var draw_hull: bool = false

var skin: Dictionary = ShipSkins.SKINS[0]
var _t: float = 0.0


func set_skin(s: Dictionary) -> void:
	skin = s
	queue_redraw()


func _process(delta: float) -> void:
	# 오라가 없고 색도 안 도는 스킨이면 매 프레임 다시 그릴 이유가 없다(모바일 draw call).
	if int(skin.get("aura", 0)) <= 0 and not bool(skin.get("hue", false)) and not draw_hull:
		return
	_t += delta
	queue_redraw()


## 색이 도는 스킨(PRISM)은 시간에 따라 색상환을 돈다.
func current_body() -> Color:
	var base: Color = skin.get("body", Color.WHITE)
	return ShipSkins.shifted(base, _t) if bool(skin.get("hue", false)) else base


func _draw() -> void:
	var level: int = int(skin.get("aura", 0))
	var accent := current_body()
	if level >= 1:
		# 끊어진 호가 천천히 돈다 — 기체가 "동력을 두르고 있다"는 인상.
		var r: float = 34.0
		for i in 3:
			var start: float = _t * 1.1 + TAU * i / 3.0
			draw_arc(Vector2.ZERO, r, start, start + 1.0, 14,
				Color(accent.r, accent.g, accent.b, 0.55), 2.5, true)
	if level >= 2:
		# 바깥 링 + 반대 방향으로 도는 스파크. 최상위 스킨의 차이를 확실히 보이게 한다.
		var r2: float = 46.0
		for i in 2:
			var start: float = -_t * 0.7 + TAU * i / 2.0
			draw_arc(Vector2.ZERO, r2, start, start + 1.4, 18,
				Color(accent.r, accent.g, accent.b, 0.32), 2.0, true)
		for i in 4:
			var ang: float = -_t * 1.6 + TAU * i / 4.0
			draw_circle(Vector2(cos(ang), sin(ang)) * r2, 3.0,
				Color(accent.r, accent.g, accent.b, 0.8))
	if draw_hull:
		# 미리보기 — 글로우를 크게 깔고 그 위에 본체.
		var hull := ShipSkins.get_hull(skin)
		draw_colored_polygon(hull, Color(accent.r, accent.g, accent.b, 0.25))
		var inner := PackedVector2Array()
		for p in hull:
			inner.append(p * 0.84)
		draw_colored_polygon(inner, accent)
