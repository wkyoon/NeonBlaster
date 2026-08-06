extends Node2D
## StarField - 테마별 색 팔레트 + 파티클 모티프로 흐르는 배경.
##
## 테마(주제) 스테이지가 바뀌면 [WordManager] 의 `stage_changed` 를 받아
## 배경색·입자색·입자 모양을 함께 전환한다([ThemeStages](ThemeStages.gd) 가 값을 정의).
##
## ⚠️ 모바일 GL 은 draw call 에 민감하다. 입자 하나당 그리기 호출이 많은 모티프는
##    `MOTIF_DENSITY` 로 개수를 줄여 총 호출 수를 비슷하게 유지한다.

@export var star_count: int = 80
@export var speed: float = 60.0

## 모티프별 입자 수 배율 — 그리기 호출이 많은 모양은 개수를 줄인다.
const MOTIF_DENSITY := {
	ThemeStages.Motif.STAR: 1.0,   # draw 1회
	ThemeStages.Motif.BLOB: 0.8,   # 2회
	ThemeStages.Motif.PAW: 0.45,   # 4회
	ThemeStages.Motif.LEAF: 0.9,   # 1회 (폴리곤)
	ThemeStages.Motif.PULSE: 0.9,  # 1회 (arc)
	ThemeStages.Motif.GEAR: 0.7,   # 2회
}

var _stars: Array = []
var _screen_size: Vector2

var _motif: ThemeStages.Motif = ThemeStages.Motif.STAR
var _particle_color: Color = Color.WHITE
var _rainbow: bool = false


func _ready() -> void:
	_screen_size = get_viewport_rect().size
	# 현재 테마로 초기화한 뒤, 이후 전환을 구독한다.
	apply_stage(WordManager.get_stage())
	WordManager.stage_changed.connect(_on_stage_changed)


func _on_stage_changed(_index: int, stage: Dictionary) -> void:
	apply_stage(stage)


## 테마 스테이지의 팔레트·모티프를 적용하고 입자를 다시 만든다.
func apply_stage(stage: Dictionary) -> void:
	if stage.is_empty():
		return
	_motif = stage.get("motif", ThemeStages.Motif.STAR)
	_particle_color = stage.get("particle", Color.WHITE)
	_rainbow = bool(stage.get("particle_rainbow", false))
	RenderingServer.set_default_clear_color(stage.get("bg", Color(0.04, 0.03, 0.09)))
	_generate_stars()
	queue_redraw()


func _generate_stars() -> void:
	_stars.clear()
	var density: float = float(MOTIF_DENSITY.get(_motif, 1.0))
	var count := int(round(star_count * density))
	for i in count:
		var star := {
			pos = Vector2(randf() * _screen_size.x, randf() * _screen_size.y),
			size = randf_range(0.5, 2.5),
			brightness = randf_range(0.3, 1.0),
			speed_mult = randf_range(0.3, 1.0),
			# 색깔 테마에서만 입자마다 색조를 흩뿌린다(무지개 방울).
			hue = randf(),
			spin = randf_range(-1.5, 1.5),
			angle = randf() * TAU,
		}
		_stars.append(star)


func _process(delta: float) -> void:
	queue_redraw()
	for star in _stars:
		star.pos.y += speed * star.speed_mult * delta
		star.angle += star.spin * delta
		if star.pos.y > _screen_size.y:
			star.pos.y = -5
			star.pos.x = randf() * _screen_size.x


func _draw() -> void:
	for star in _stars:
		var c: Color = _particle_color
		if _rainbow:
			c = Color.from_hsv(star.hue, 0.55, 1.0)
		c.a = star.brightness
		_draw_motif(star, c)


## 모티프 하나를 그린다. 그리기 호출 수는 MOTIF_DENSITY 의 주석과 맞춰야 한다.
func _draw_motif(star: Dictionary, c: Color) -> void:
	var p: Vector2 = star.pos
	var s: float = star.size

	match _motif:
		ThemeStages.Motif.STAR:
			# 우주 — 작은 별은 1px 점, 큰 별은 원
			if s < 1.0:
				draw_rect(Rect2(p, Vector2(1, 1)), c)
			else:
				draw_circle(p, s, c)

		ThemeStages.Motif.BLOB:
			# 색깔 — 번지는 색 방울(바깥 흐림 + 밝은 코어)
			var outer := c
			outer.a = c.a * 0.35
			draw_circle(p, s * 2.2, outer)
			draw_circle(p, s * 0.9, c)

		ThemeStages.Motif.PAW:
			# 동물 — 발바닥(큰 패드 + 발가락 3개)
			draw_circle(p, s * 1.5, c)
			var toe := c
			toe.a = c.a * 0.85
			for i in 3:
				var a: float = star.angle - 0.7 + i * 0.7
				draw_circle(p + Vector2(cos(a), sin(a)) * s * 2.4, s * 0.6, toe)

		ThemeStages.Motif.LEAF:
			# 자연 — 잎/물방울(회전하는 다이아몬드)
			var r: float = s * 2.0
			var dir := Vector2(cos(star.angle), sin(star.angle))
			var side := Vector2(-dir.y, dir.x)
			draw_colored_polygon(PackedVector2Array([
				p + dir * r, p + side * r * 0.45, p - dir * r, p - side * r * 0.45
			]), c)

		ThemeStages.Motif.PULSE:
			# 몸 — 맥박 링(숨쉬듯 크기 변화)
			var pulse: float = 1.0 + sin(star.angle * 2.0) * 0.35
			draw_arc(p, s * 2.0 * pulse, 0.0, TAU, 10, c, maxf(1.0, s * 0.5))

		ThemeStages.Motif.GEAR:
			# 기계 — 겹친 사각형(볼트/기어 느낌)
			var half: float = s * 1.3
			draw_rect(Rect2(p - Vector2(half, half), Vector2(half * 2, half * 2)), c)
			var inner := c
			inner.a = c.a * 0.5
			draw_rect(Rect2(p - Vector2(half * 0.45, half * 2.0), Vector2(half * 0.9, half * 4.0)), inner)
