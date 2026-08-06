class_name ThemeStages
## ThemeStages - 테마(주제) 스테이지 정의
##
## 단어는 **글자 수가 아니라 주제**로 묶인다. 한 테마의 단어를 WORDS_PER_STAGE개 완성하면
## 다음 테마로 넘어가고 배경 팔레트·파티클 모티프도 함께 바뀐다.
## (난이도 EASY/NORMAL/HARD 는 적 밀도·속도·체력만 담당한다 — AGENTS.md 밸런스 절차 참조.)
##
## 새 테마를 추가할 때:
##   1. words 는 전부 [WordDictionary](WordDictionary.gd) 에 등록돼 있어야 한다(설명·이모지·TTS용).
##   2. words 는 WORDS_PER_STAGE개 이상이어야 스테이지가 완주 가능하다.
##   3. motif 는 [StarField](StarField.gd) 가 그릴 수 있는 값이어야 한다.

## 한 테마 스테이지를 클리어하는 데 필요한 단어 수.
const WORDS_PER_STAGE := 5

## 파티클 모티프 종류 — StarField._draw_motif() 가 해석한다.
enum Motif { STAR, BLOB, PAW, LEAF, PULSE, GEAR }

const STAGES: Array[Dictionary] = [
	{
		"id": "COLOR",
		"name_ko": "색깔",
		"name_en": "COLORS",
		"words": ["RED", "BLUE", "PINK", "YELLOW", "BLACK", "GREEN", "WHITE"],
		"bg": Color(0.10, 0.04, 0.13),
		"accent": Color(1.0, 0.45, 0.85),
		"particle": Color(1.0, 0.75, 0.35),
		"motif": Motif.BLOB,
		# 색깔 테마만 입자마다 다른 색을 쓴다(무지개 방울).
		"particle_rainbow": true,
	},
	{
		"id": "ANIMAL",
		"name_ko": "동물",
		"name_en": "ANIMALS",
		"words": ["DOG", "CAT", "TIGER", "SNAKE", "RACCOON", "FOX", "BEAR", "OWL", "BEE", "BIRD", "FISH", "WOLF", "BAT"],
		"bg": Color(0.05, 0.10, 0.06),
		"accent": Color(1.0, 0.72, 0.25),
		"particle": Color(0.75, 1.0, 0.55),
		"motif": Motif.PAW,
	},
	{
		"id": "BODY",
		"name_ko": "몸",
		"name_en": "BODY",
		"words": ["EYE", "EAR", "ARM", "LEG", "HAND", "FOOT", "HEAD"],
		"bg": Color(0.11, 0.05, 0.07),
		"accent": Color(1.0, 0.35, 0.45),
		"particle": Color(1.0, 0.55, 0.6),
		"motif": Motif.PULSE,
	},
	{
		"id": "NATURE",
		"name_ko": "자연",
		"name_en": "NATURE",
		"words": ["SKY", "ICE", "FIRE", "STORM", "FLAME", "THUNDER", "VOLCANO"],
		"bg": Color(0.03, 0.09, 0.11),
		"accent": Color(0.35, 1.0, 0.8),
		"particle": Color(0.6, 1.0, 0.85),
		"motif": Motif.LEAF,
	},
	{
		"id": "SPACE",
		"name_ko": "우주",
		"name_en": "SPACE",
		"words": ["SUN", "STAR", "MOON", "MARS", "COMET", "EARTH", "PLANET", "GALAXY", "NEBULA", "METEOR"],
		"bg": Color(0.04, 0.03, 0.09),
		"accent": Color(0.4, 0.85, 1.0),
		"particle": Color(1.0, 1.0, 1.0),
		"motif": Motif.STAR,
	},
	{
		"id": "MACHINE",
		"name_ko": "기계",
		"name_en": "MACHINES",
		"words": ["JET", "ROBOT", "ROCKET", "ANDROID", "CYBORG", "SPACESHIP", "LASER"],
		"bg": Color(0.06, 0.07, 0.10),
		"accent": Color(0.7, 0.8, 1.0),
		"particle": Color(0.55, 0.7, 0.9),
		"motif": Motif.GEAR,
	},
]


static func count() -> int:
	return STAGES.size()


## index 를 스테이지 수로 감싸서 항상 유효한 테마를 돌려준다(마지막 테마 뒤에는 처음으로 순환).
static func get_stage(index: int) -> Dictionary:
	if STAGES.is_empty():
		return {}
	return STAGES[posmod(index, STAGES.size())]


static func get_words(index: int) -> Array:
	var stage := get_stage(index)
	if stage.is_empty():
		return []
	return (stage["words"] as Array).duplicate()
