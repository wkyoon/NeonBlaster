class_name WordSlots
extends Node2D
## WordSlots - 단어 진행 상황을 "글자 슬롯"으로 그린다.
##
## 예전에는 Label 에 `get_display_word()` 결과("W _ _ _")를 그대로 넣었는데,
## 밑줄 문자(_)가 글자 baseline **아래**에 그려져서 채워진 글자와 빈 칸의 높이가 어긋나 보였다.
## 문자로 빈 칸을 표현하는 한 폰트마다 이 문제가 생기므로, 글자와 칸을 **각각 고정 위치에**
## 직접 그린다. 덤으로 칸 너비가 일정해져 글자가 채워져도 줄 전체가 흔들리지 않는다.
##
## 색·크기는 콤보 단계에 따라 HUD 가 넘겨준다(콤보의 보상을 단어로 표현하는 규칙).

## 칸 하나의 너비와 칸 사이 간격.
@export var slot_width: float = 44.0
@export var slot_gap: float = 12.0
## 빈 칸 밑줄의 두께와 글자 baseline 으로부터의 거리.
@export var bar_thickness: float = 5.0
@export var bar_offset: float = 14.0

var font_size: int = 56
var accent: Color = Color(0.3, 1.0, 0.9)
var outline: Color = Color(0, 0.3, 0.4)

var _tokens: PackedStringArray = PackedStringArray()


## HUD 가 `WordManager.get_display_word()` 를 공백으로 잘라 넘긴다. ("W", "_", "_")
func set_tokens(tokens: PackedStringArray) -> void:
	_tokens = tokens
	queue_redraw()


func set_style(size: int, color: Color, outline_color: Color) -> void:
	font_size = size
	accent = color
	outline = outline_color
	queue_redraw()


## 그려지는 줄의 전체 너비. HUD 가 화면을 넘지 않게 배율을 제한할 때 쓴다.
func get_line_width() -> float:
	var n: int = _tokens.size()
	if n <= 0:
		return 0.0
	return n * slot_width + (n - 1) * slot_gap


func _draw() -> void:
	var n: int = _tokens.size()
	if n <= 0:
		return
	var font := ThemeDB.fallback_font
	if font == null:
		return

	var total := get_line_width()
	var x := -total * 0.5

	for i in n:
		var token: String = _tokens[i]
		var cx: float = x + slot_width * 0.5
		if token == "_" or token == "":
			# 빈 칸 — 밑줄을 글자 baseline 기준 고정 위치에 직접 그린다.
			var bar := Rect2(x + 4.0, bar_offset, slot_width - 8.0, bar_thickness)
			draw_rect(bar, Color(accent.r, accent.g, accent.b, 0.45))
		else:
			# 채워진 글자 — 외곽선(글로우)을 먼저 여러 겹, 그 위에 본체.
			var w: float = font.get_string_size(token, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			var pos := Vector2(cx - w * 0.5, 0.0)
			for off in [Vector2(-2, 0), Vector2(2, 0), Vector2(0, -2), Vector2(0, 2)]:
				draw_string(font, pos + off, token, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline)
			draw_string(font, pos, token, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, accent)
		x += slot_width + slot_gap
