class_name TitleEmblem
extends Node2D
## TitleEmblem - 타이틀 위에 그리는 절차적 네온 엠블럼.
##
## 로고가 글자뿐이라 게임의 얼굴이 비어 보였다. 프로젝트가 전부 `_draw` 기반이므로
## 이미지 에셋을 추가하지 않고 같은 방식으로 그린다(APK 증가 0, 어떤 해상도에서도 선명).
##
## 구성: 이중 네온 링 + 궤도를 도는 글자 스파크 + 가운데 플레이어 기체 실루엣.
## "단어(글자)를 쏘는 우주선"이라는 게임의 정체성을 한 장에 담는다.

## 링 반지름. 타이틀 폰트(72)와 균형이 맞는 크기.
@export var radius: float = 52.0
## 궤도를 도는 글자. 게임의 소재가 알파벳임을 드러낸다.
@export var orbit_letters: PackedStringArray = ["W", "O", "R", "D"]
@export var accent: Color = Color(0.35, 0.85, 1.0)
@export var ship_color: Color = Color(0.6, 1.0, 1.0)

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	# 가운데 기체는 **장착 중인 스킨 색**으로 그린다 — 보상을 받으면 타이틀부터 달라진다.
	var skin := RewardManager.get_equipped_skin()
	ship_color = ShipSkins.shifted(skin["body"], _t) if bool(skin.get("hue", false)) else skin["body"]
	# 바깥 글로우 — 얇은 링을 여러 겹 겹쳐 네온 번짐을 만든다(셰이더 없이).
	for i in 4:
		var r: float = radius + i * 3.0
		var a: float = 0.16 - i * 0.035
		if a <= 0.0:
			continue
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(accent.r, accent.g, accent.b, a), 3.0, true)

	# 본체 링 — 숨쉬듯 미세하게 뛴다
	var pulse: float = 1.0 + sin(_t * 2.0) * 0.03
	draw_arc(Vector2.ZERO, radius * pulse, 0.0, TAU, 64, accent, 2.5, true)
	# 안쪽 보조 링(끊어진 호) — 기계적인 인상
	for i in 3:
		var start: float = _t * 0.6 + i * TAU / 3.0
		draw_arc(Vector2.ZERO, radius * 0.72, start, start + 0.9, 16,
			Color(accent.r, accent.g, accent.b, 0.5), 2.0, true)

	_draw_orbit_letters()
	_draw_ship()


## 링 위를 도는 글자들. 게임의 소재가 알파벳임을 시각적으로 알린다.
func _draw_orbit_letters() -> void:
	var font := ThemeDB.fallback_font
	if font == null or orbit_letters.is_empty():
		return
	var n: int = orbit_letters.size()
	for i in n:
		var ang: float = _t * 0.7 + TAU * i / float(n)
		var pos := Vector2(cos(ang), sin(ang)) * (radius + 18.0)
		# 뒤쪽(아래)으로 갈수록 흐리게 — 궤도의 깊이감
		var depth: float = (sin(ang) + 1.0) * 0.5
		var col := Color(1.0, 0.95, 0.5, 0.35 + depth * 0.55)
		var size := 21
		var w: float = font.get_string_size(orbit_letters[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		draw_string(font, pos - Vector2(w * 0.5, -6.0), orbit_letters[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


## 가운데 플레이어 기체. Player.tscn 의 실루엣과 같은 모양을 축소해 쓴다
## (목숨 아이콘도 같은 실루엣이라 화면 전체에서 "내 기체" 기호가 일관된다).
func _draw_ship() -> void:
	# 타이틀도 장착 기체의 실루엣을 쓴다 — 산 기체가 첫 화면부터 보여야 한다.
	var pts := PackedVector2Array()
	for v in ShipSkins.get_hull(RewardManager.get_equipped_skin()):
		pts.append(v * 0.8)
	# 글로우 먼저(크게, 흐리게) → 본체
	draw_colored_polygon(pts, Color(ship_color.r, ship_color.g, ship_color.b, 0.25))
	var inner := PackedVector2Array()
	for p in pts:
		inner.append(p * 0.82)
	draw_colored_polygon(inner, ship_color)
