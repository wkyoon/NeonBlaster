class_name ThemeStages
## ThemeStages - 테마(주제) 스테이지 정의
##
## 단어는 **글자 수가 아니라 주제**로 묶인다. 한 테마의 단어를 WORDS_PER_STAGE개 완성하면
## 다음 테마로 넘어가고 배경 팔레트·파티클 모티프도 함께 바뀐다.
## (난이도 EASY/NORMAL/HARD 는 적 밀도·속도·체력만 담당한다 — AGENTS.md 밸런스 절차 참조.)
##
## 단어는 두 층이다:
##   - `words`(기본 8개) — 그 테마에서 먼저 익히는 단어. 다 모으면 **테마 완주**.
##   - `advanced`(심화 4개) — 기본 8개를 다 모은 뒤부터 **한 번에 하나씩만** 등장한다.
##     하나를 수집해야 다음 하나가 풀린다. 어려운 단어를 한꺼번에 쏟으면 학습이 무너진다.
##
## ⚠️ 테마 구성 규칙 (이 셋이 어긋나면 학습 흐름이 무너진다)
##   1. words 는 전부 **그 테마와 같은 카테고리**여야 한다. 예전 MACHINE 은 사전에 단어가
##      3개뿐이라 탈것(JET/ROCKET/SPACESHIP)과 과학(LASER)을 섞어 놨었다 — 주제와 단어가 어긋났다.
##   2. 테마마다 **같은 개수**(현재 8개). 예전에는 ANIMAL 13 / MACHINE 7 로 편중돼 있었다.
##   3. 스테이지 순서는 **평균 글자수 오름차순** — 진행할수록 조금씩 어려워진다.
##      예전 순서는 4.6 → 3.9 → 3.4 → 4.9 → 4.9 → 5.9 로 중간에 쉬워졌다.
##
## 새 테마를 추가할 때:
##   1. words/advanced 는 전부 [WordDictionary](WordDictionary.gd) 에 등록돼 있어야 한다(설명·이모지·TTS용).
##   2. words 는 WORDS_PER_STAGE개 이상이어야 스테이지가 완주 가능하다.
##   3. motif 는 [StarField](StarField.gd) 가 그릴 수 있는 값이어야 한다.

## 한 테마 스테이지를 클리어하는 데 필요한 단어 수.
## ⚠️ 5는 도달 불가능했다 — 실측(EASY·완벽 AI) 첫 단어 34.8초, 단어당 7~16초라
##    5단어 완주에 75~115초가 필요한데 73.5초에 사망해 테마 전환을 한 번도 못 봤다.
const WORDS_PER_STAGE := 3

## 파티클 모티프 종류 — StarField._draw_motif() 가 해석한다.
enum Motif { STAR, BLOB, PAW, LEAF, PULSE, GEAR }

const STAGES: Array[Dictionary] = [
	{
		"id": "BODY",
		"name_ko": "몸",
		"name_en": "BODY",
		# 평균 3.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["EYE", "ARM", "LEG", "EAR", "NOSE", "HAND", "FOOT", "HEAD"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["FINGER", "ELBOW", "STOMACH", "SHOULDER"],
		"bg": Color(0.11, 0.05, 0.07),
		"accent": Color(1.0, 0.35, 0.45),
		"particle": Color(1.0, 0.55, 0.6),
		"motif": Motif.PULSE,
	},
	{
		"id": "ANIMAL",
		"name_ko": "동물",
		"name_en": "ANIMALS",
		# 평균 3.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["CAT", "DOG", "BAT", "BIRD", "FISH", "WOLF", "TIGER", "SNAKE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["DOLPHIN", "PENGUIN", "ELEPHANT", "BUTTERFLY"],
		"bg": Color(0.05, 0.10, 0.06),
		"accent": Color(1.0, 0.72, 0.25),
		"particle": Color(0.75, 1.0, 0.55),
		"motif": Motif.PAW,
	},
	{
		"id": "COLOR",
		"name_ko": "색깔",
		"name_en": "COLORS",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["RED", "BLUE", "PINK", "GRAY", "BLACK", "GREEN", "WHITE", "YELLOW"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["PURPLE", "ORANGE", "SILVER", "CRIMSON"],
		"bg": Color(0.10, 0.04, 0.13),
		"accent": Color(1.0, 0.45, 0.85),
		"particle": Color(1.0, 0.75, 0.35),
		"motif": Motif.BLOB,
		"particle_rainbow": true,
	},
	{
		"id": "SPACE",
		"name_ko": "우주",
		"name_en": "SPACE",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SUN", "STAR", "MOON", "MARS", "COMET", "EARTH", "PLANET", "GALAXY"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["ORBIT", "METEOR", "NEBULA", "ASTEROID"],
		"bg": Color(0.04, 0.03, 0.09),
		"accent": Color(0.4, 0.85, 1.0),
		"particle": Color(1.0, 1.0, 1.0),
		"motif": Motif.STAR,
	},
	{
		"id": "NATURE",
		"name_ko": "자연",
		"name_en": "NATURE",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SKY", "ICE", "FIRE", "RAIN", "STORM", "FLAME", "VOLCANO", "THUNDER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["RIVER", "DESERT", "RAINBOW", "GLACIER"],
		"bg": Color(0.03, 0.09, 0.11),
		"accent": Color(0.35, 1.0, 0.8),
		"particle": Color(0.6, 1.0, 0.85),
		"motif": Motif.LEAF,
	},
	{
		"id": "MACHINE",
		"name_ko": "기계",
		"name_en": "MACHINES",
		# 평균 5.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["GEAR", "WIRE", "MOTOR", "ROBOT", "ENGINE", "CYBORG", "ANDROID", "CIRCUIT"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["MAGNET", "BATTERY", "TURBINE", "PROPELLER"],
		"bg": Color(0.06, 0.07, 0.10),
		"accent": Color(0.7, 0.8, 1.0),
		"particle": Color(0.55, 0.7, 0.9),
		"motif": Motif.GEAR,
	},
]


## 모든 테마의 **기본** 단어를 한 배열로.
## ⚠️ 심화 단어는 넣지 않는다 — 테마 완주(mastery)와 도감 기본 목표의 기준이 기본 8개이기 때문이다.
##    심화까지 세면 완주가 12개가 되어 "자주 오는 성취"라는 설계가 깨진다.
static func get_all_words() -> Array:
	var out: Array = []
	for st in STAGES:
		for w in st["words"]:
			if not out.has(w):
				out.append(w)
	return out


## 심화 단어 전체. 도감이 보너스 항목으로 함께 보여준다.
static func get_all_advanced() -> Array:
	var out: Array = []
	for st in STAGES:
		for w in st.get("advanced", []):
			if not out.has(w):
				out.append(w)
	return out


static func get_advanced(index: int) -> Array:
	var stage := get_stage(index)
	if stage.is_empty():
		return []
	return (stage.get("advanced", []) as Array).duplicate()


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
