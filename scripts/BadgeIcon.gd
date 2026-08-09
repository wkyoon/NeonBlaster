class_name BadgeIcon
extends Node2D
## 훈장을 그린다. 프로젝트가 전부 `_draw` 기반이라 이미지 에셋 없이 같은 방식으로 그린다
## (APK 증가 0, 어떤 해상도에서도 선명).
##
## 구성: 리본 두 갈래 + 메달 원판 + 등급별 테두리 + 가운데 등급 표시(●/◆/★).
## 잠긴 훈장은 회색으로 흐리게 그려 "무엇이 남았는지"를 보여준다.

## 메달 반지름. 목록에서는 작게, 획득 연출에서는 크게 쓴다.
@export var radius: float = 26.0
## 잠긴 상태로 그릴지.
@export var locked: bool = false

var tier: int = 1


func setup(a_tier: int, a_locked: bool, a_radius: float = 26.0) -> void:
	tier = a_tier
	locked = a_locked
	radius = a_radius
	queue_redraw()


func _draw() -> void:
	var accent := Achievements.tier_color(tier)
	if locked:
		# 잠긴 것은 형태만 남기고 색을 뺀다 — 목표가 보여야 모을 마음이 생긴다.
		accent = Color(0.42, 0.46, 0.52)

	# 리본 두 갈래 — 메달 아래로 뻗는다.
	var rw: float = radius * 0.42
	var rh: float = radius * 1.5
	for dir in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(dir * rw * 0.4, 0),
			Vector2(dir * rw * 1.6, radius * 0.2),
			Vector2(dir * rw * 1.3, radius * 0.2 + rh),
			Vector2(dir * rw * 0.2, radius * 0.2 + rh * 0.72),
		]), Color(accent.r * 0.6, accent.g * 0.6, accent.b * 0.6, 0.9))

	# 바깥 글로우 — 얇은 원을 겹쳐 번짐을 만든다(셰이더 없이).
	if not locked:
		for i in 3:
			draw_circle(Vector2.ZERO, radius + i * 2.5,
				Color(accent.r, accent.g, accent.b, 0.10 - i * 0.03))

	# 원판
	draw_circle(Vector2.ZERO, radius, Color(0.10, 0.10, 0.14, 0.95))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, accent, 3.0, true)
	draw_arc(Vector2.ZERO, radius * 0.74, 0.0, TAU, 32,
		Color(accent.r, accent.g, accent.b, 0.45), 1.5, true)

	# 가운데 등급 표시. 동=점, 은=마름모, 금=별.
	match tier:
		1:
			draw_circle(Vector2.ZERO, radius * 0.26, accent)
		2:
			var d: float = radius * 0.36
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -d), Vector2(d, 0), Vector2(0, d), Vector2(-d, 0)
			]), accent)
		_:
			_draw_star(radius * 0.44, accent)


## 오각별. 금 훈장에만 쓴다.
func _draw_star(r: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI * 0.5 + TAU * i / 10.0
		var rr: float = r if i % 2 == 0 else r * 0.45
		pts.append(Vector2(cos(a), sin(a)) * rr)
	draw_colored_polygon(pts, color)
