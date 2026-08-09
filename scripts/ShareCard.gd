class_name ShareCard
extends Node2D
## 소셜에 공유할 단어 카드를 그린다. 이모지 + 단어 + **말풍선에 담긴 예문**.
##
## 프로젝트가 전부 `_draw` 기반이라 이미지 에셋 없이 같은 방식으로 그린다.
## `SubViewport` 안에서 한 프레임 렌더해 텍스처로 뽑는다(`ShareManager.render_card`).
##
## ⚠️ 카드 크기는 **정사각형 1080x1080** 이다. 소셜 미리보기가 대부분 정사각형으로 잘리는데,
##    세로로 길게 만들면 위아래가 잘려 말풍선이 사라진다.
## ⚠️ 배경을 투명하게 두면 안 된다 — 어두운 테마 앱에서만 읽히고 밝은 배경에서는 글자가 사라진다.

const SIZE := 1080.0
## 게임 이름. 카드 아래에 작게 넣는다 — 공유가 곧 홍보다.
const FOOTER := "WORD BLASTER"

var word: String = ""
var emoji: String = ""
var phrase: String = ""
var accent: Color = Color(0.35, 1.0, 0.9)


func setup(a_word: String) -> void:
	word = a_word.to_upper()
	emoji = WordDictionary.get_emoji(word)
	phrase = WordDictionary.get_phrase(word)
	# 그 단어가 속한 테마의 색을 쓴다 — 카드마다 색이 달라 모으는 맛이 생긴다.
	for st in ThemeStages.STAGES:
		if word in st["words"] or word in st.get("advanced", []):
			accent = st["accent"]
			break
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return

	# 배경 — 게임 톤의 어두운 판. 투명하게 두면 밝은 배경에서 글자가 사라진다.
	draw_rect(Rect2(0, 0, SIZE, SIZE), Color(0.04, 0.03, 0.09))
	# 테두리 네온
	for i in 3:
		draw_rect(Rect2(18 + i * 3, 18 + i * 3, SIZE - 36 - i * 6, SIZE - 36 - i * 6),
			Color(accent.r, accent.g, accent.b, 0.30 - i * 0.09), false, 3.0)

	# 이모지
	_centered(font, emoji, Vector2(SIZE * 0.5, 330.0), 210, Color.WHITE)
	# 단어 — 카드의 주인공이라 가장 크게.
	_centered(font, word, Vector2(SIZE * 0.5, 560.0), 130, accent, 14, Color(0, 0, 0, 0.9))

	if phrase != "":
		_draw_bubble(font)

	_centered(font, FOOTER, Vector2(SIZE * 0.5, SIZE - 56.0), 34,
		Color(accent.r, accent.g, accent.b, 0.55))


## 예문을 담는 말풍선. 꼬리는 단어 쪽(위)을 향한다.
func _draw_bubble(font: Font) -> void:
	var margin := 90.0
	var top := 660.0
	var w := SIZE - margin * 2.0
	var lines := _wrap(font, phrase, 46, w - 80.0)
	var h: float = 70.0 + lines.size() * 58.0
	var rect := Rect2(margin, top, w, h)

	draw_rect(rect, Color(0.10, 0.11, 0.16, 0.96))
	draw_rect(rect, Color(accent.r, accent.g, accent.b, 0.55), false, 3.0)
	# 꼬리 — 위쪽 가운데에서 단어를 가리킨다.
	draw_colored_polygon(PackedVector2Array([
		Vector2(SIZE * 0.5 - 26, top + 2),
		Vector2(SIZE * 0.5 + 26, top + 2),
		Vector2(SIZE * 0.5, top - 34),
	]), Color(0.10, 0.11, 0.16, 0.96))

	var y := top + 62.0
	for line in lines:
		_centered(font, line, Vector2(SIZE * 0.5, y), 46, Color(0.92, 0.95, 1.0))
		y += 58.0


## 가로 폭에 맞춰 줄바꿈한다. 예문이 길면 카드 밖으로 나간다.
func _wrap(font: Font, text: String, size: int, max_w: float) -> PackedStringArray:
	var out := PackedStringArray()
	var line := ""
	for wtok in text.split(" ", false):
		var test := wtok if line == "" else line + " " + wtok
		if font.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > max_w and line != "":
			out.append(line)
			line = wtok
		else:
			line = test
	if line != "":
		out.append(line)
	return out


func _centered(font: Font, text: String, center: Vector2, size: int, color: Color,
		outline: int = 0, outline_color: Color = Color.BLACK) -> void:
	var w: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := Vector2(center.x - w * 0.5, center.y)
	if outline > 0:
		for off in [Vector2(-outline, 0), Vector2(outline, 0), Vector2(0, -outline), Vector2(0, outline)]:
			draw_string(font, pos + off, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, outline_color)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
