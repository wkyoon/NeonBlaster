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
##   4. ⚠️ `words`/`advanced` 배열은 **글자 수 오름차순으로 정렬**해 둘 것.
##      **기본의 마지막 단어가 심화의 첫 단어보다 길면 안 된다** — 두 층의 경계에서 난이도가
##      거꾸로 간다(실측: SPACE 기본 GALAXY(6) → 심화 ORBIT(5)).
##      WordManager 가 이 배열 순서 그대로 단어를 낸다(쉬운 것 → 어려운 것).
##      정렬이 깨지면 어려운 단어가 먼저 나온다. `tools/check_word_order.py` 로 확인.
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
		"advanced": ["ELBOW", "FINGER", "STOMACH", "SHOULDER"],
		"bg": Color(0.11, 0.05, 0.07),
		"accent": Color(1.0, 0.35, 0.45),
		"particle": Color(1.0, 0.55, 0.6),
		"motif": Motif.PULSE,
	},
	{
		"id": "NUMBER",
		"name_ko": "숫자",
		"name_en": "NUMBER",
		# 평균 3.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["ONE", "TWO", "SIX", "TEN", "FOUR", "FIVE", "NINE", "THREE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SEVEN", "EIGHT", "TWELVE", "TWENTY", "HUNDRED", "MILLION", "THOUSAND", "FRACTION"],
		"bg": Color(0.06, 0.09, 0.09),
		"accent": Color(0.50, 1.00, 0.90),
		"particle": Color(0.70, 1.00, 0.95),
		"motif": Motif.STAR,
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
		"id": "VEHICLE",
		"name_ko": "탈것",
		"name_en": "VEHICLES",
		# 평균 3.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BUS", "CAR", "VAN", "BIKE", "BOAT", "SHIP", "TRAIN", "TRUCK"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SUBWAY", "BICYCLE", "SCOOTER", "TRAILER", "AIRPLANE", "AMBULANCE", "HELICOPTER", "MOTORCYCLE"],
		"bg": Color(0.05, 0.08, 0.10),
		"accent": Color(0.50, 0.90, 1.00),
		"particle": Color(0.70, 0.95, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "ACTION",
		"name_ko": "동작",
		"name_en": "ACTION",
		# 평균 3.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["EAT", "SIT", "CUT", "READ", "WALK", "WASH", "SPEAK", "WRITE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SLEEP", "BUILD", "SHARE", "LISTEN", "FOLLOW", "GATHER", "REMEMBER", "PRACTICE"],
		"bg": Color(0.10, 0.06, 0.09),
		"accent": Color(1.00, 0.55, 0.80),
		"particle": Color(1.00, 0.75, 0.90),
		"motif": Motif.PULSE,
	},
	{
		"id": "STATE",
		"name_ko": "상태",
		"name_en": "STATE",
		# 평균 3.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["NEW", "OLD", "WET", "DRY", "FULL", "EMPTY", "CLEAN", "DIRTY"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["RUSTY", "SPARE", "BROKEN", "PERFECT", "FRAGILE", "DAMAGED", "USELESS", "COMPLETE"],
		"bg": Color(0.08, 0.08, 0.09),
		"accent": Color(0.85, 0.90, 1.00),
		"particle": Color(0.95, 1.00, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "DIRECTION",
		"name_ko": "방향",
		"name_en": "DIRECTION",
		# 평균 3.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["UP", "TOP", "LEFT", "EAST", "WEST", "DOWN", "NORTH", "RIGHT"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SOUTH", "MIDDLE", "CORNER", "FORWARD", "BACKWARD", "DIAGONAL", "OPPOSITE", "HORIZONTAL"],
		"bg": Color(0.08, 0.07, 0.10),
		"accent": Color(0.75, 0.80, 1.00),
		"particle": Color(0.90, 0.90, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "FARM",
		"name_ko": "농장",
		"name_en": "FARM",
		# 평균 4.0글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["COW", "PIG", "HAY", "BARN", "GOAT", "SHEEP", "HORSE", "FENCE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["PLOUGH", "MANURE", "HARVEST", "PASTURE", "TRACTOR", "SCARECROW", "LIVESTOCK", "IRRIGATION"],
		"bg": Color(0.09, 0.08, 0.05),
		"accent": Color(1.00, 0.80, 0.45),
		"particle": Color(1.00, 0.90, 0.60),
		"motif": Motif.PAW,
	},
	{
		"id": "CLOTHES",
		"name_ko": "옷",
		"name_en": "CLOTHES",
		# 평균 4.1글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["CAP", "HAT", "COAT", "SHOE", "SOCK", "DRESS", "SHIRT", "SKIRT"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["JACKET", "POCKET", "SWEATER", "UNIFORM", "SANDALS", "TROUSERS", "RAINCOAT", "TURTLENECK"],
		"bg": Color(0.10, 0.05, 0.11),
		"accent": Color(1.00, 0.60, 0.95),
		"particle": Color(1.00, 0.80, 1.00),
		"motif": Motif.BLOB,
	},
	{
		"id": "FAMILY",
		"name_ko": "가족",
		"name_en": "FAMILY",
		# 평균 4.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["MOM", "DAD", "SON", "AUNT", "BABY", "UNCLE", "SISTER", "FATHER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["COUSIN", "MOTHER", "NEPHEW", "BROTHER", "GRANDMA", "GRANDPA", "DAUGHTER", "RELATIVE"],
		"bg": Color(0.10, 0.05, 0.09),
		"accent": Color(1.00, 0.55, 0.75),
		"particle": Color(1.00, 0.75, 0.85),
		"motif": Motif.PULSE,
	},
	{
		"id": "HOUSE",
		"name_ko": "집",
		"name_en": "HOUSE",
		# 평균 4.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BED", "CUP", "DOOR", "LAMP", "SOFA", "CHAIR", "TABLE", "WINDOW"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["MIRROR", "PILLOW", "GARAGE", "BLANKET", "CEILING", "BALCONY", "BASEMENT", "FURNITURE"],
		"bg": Color(0.09, 0.07, 0.05),
		"accent": Color(1.00, 0.80, 0.45),
		"particle": Color(0.95, 0.85, 0.60),
		"motif": Motif.GEAR,
	},
	{
		"id": "WEATHER",
		"name_ko": "날씨",
		"name_en": "WEATHER",
		# 평균 4.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["FOG", "HOT", "COLD", "WARM", "WIND", "CLOUD", "FROST", "SHOWER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BREEZE", "DROUGHT", "TYPHOON", "DRIZZLE", "TEMPEST", "HUMIDITY", "LIGHTNING", "HAILSTONE"],
		"bg": Color(0.04, 0.08, 0.11),
		"accent": Color(0.50, 0.90, 1.00),
		"particle": Color(0.75, 0.95, 1.00),
		"motif": Motif.LEAF,
	},
	{
		"id": "NATURE",
		"name_ko": "자연",
		"name_en": "NATURE",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SKY", "ICE", "FIRE", "RAIN", "RIVER", "STORM", "FLAME", "DESERT"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["RAINBOW", "VOLCANO", "THUNDER", "GLACIER"],
		"bg": Color(0.03, 0.09, 0.11),
		"accent": Color(0.35, 1.0, 0.8),
		"particle": Color(0.6, 1.0, 0.85),
		"motif": Motif.LEAF,
	},
	{
		"id": "FRUIT",
		"name_ko": "과일",
		"name_en": "FRUIT",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["FIG", "KIWI", "PEAR", "PLUM", "APPLE", "GRAPE", "LEMON", "PEACH"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BANANA", "CHERRY", "AVOCADO", "APRICOT", "COCONUT", "MANDARIN", "PINEAPPLE", "WATERMELON"],
		"bg": Color(0.06, 0.10, 0.05),
		"accent": Color(1.00, 0.50, 0.50),
		"particle": Color(1.00, 0.80, 0.40),
		"motif": Motif.LEAF,
	},
	{
		"id": "INSECT",
		"name_ko": "곤충",
		"name_en": "INSECTS",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["ANT", "BEE", "FLY", "MOTH", "WASP", "BEETLE", "SPIDER", "HORNET"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CICADA", "CRICKET", "LADYBUG", "TERMITE", "MOSQUITO", "DRAGONFLY", "GRASSHOPPER", "CATERPILLAR"],
		"bg": Color(0.06, 0.09, 0.04),
		"accent": Color(0.75, 1.00, 0.40),
		"particle": Color(0.85, 1.00, 0.60),
		"motif": Motif.PAW,
	},
	{
		"id": "PLANT",
		"name_ko": "식물",
		"name_en": "PLANTS",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["OAK", "LEAF", "PINE", "ROOT", "SEED", "GRASS", "TULIP", "FLOWER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BAMBOO", "CACTUS", "THISTLE", "MUSHROOM", "SEEDLING", "SUNFLOWER", "POLLINATE", "CHLOROPHYLL"],
		"bg": Color(0.04, 0.10, 0.05),
		"accent": Color(0.50, 1.00, 0.50),
		"particle": Color(0.70, 1.00, 0.65),
		"motif": Motif.LEAF,
	},
	{
		"id": "KITCHEN",
		"name_ko": "주방",
		"name_en": "KITCHEN",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["POT", "PAN", "BOWL", "FORK", "KNIFE", "SPOON", "PLATE", "KETTLE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["FRIDGE", "BLENDER", "SPATULA", "TOASTER", "CUPBOARD", "STRAINER", "MICROWAVE", "DISHWASHER"],
		"bg": Color(0.11, 0.07, 0.05),
		"accent": Color(1.00, 0.70, 0.40),
		"particle": Color(1.00, 0.85, 0.55),
		"motif": Motif.BLOB,
	},
	{
		"id": "BIRD",
		"name_ko": "새",
		"name_en": "BIRD",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["HEN", "DUCK", "CROW", "DOVE", "SWAN", "EAGLE", "ROBIN", "PARROT"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["TURKEY", "PEACOCK", "FEATHER", "SPARROW", "OSTRICH", "FLAMINGO", "WOODPECKER", "NIGHTINGALE"],
		"bg": Color(0.07, 0.09, 0.12),
		"accent": Color(0.70, 0.90, 1.00),
		"particle": Color(0.85, 0.95, 1.00),
		"motif": Motif.PAW,
	},
	{
		"id": "DESSERT",
		"name_ko": "디저트",
		"name_en": "DESSERT",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["PIE", "JAM", "CAKE", "TART", "HONEY", "CANDY", "DONUT", "COOKIE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["WAFFLE", "SORBET", "PUDDING", "BROWNIE", "CUSTARD", "ICECREAM", "MERINGUE", "CHEESECAKE"],
		"bg": Color(0.11, 0.06, 0.08),
		"accent": Color(1.00, 0.60, 0.75),
		"particle": Color(1.00, 0.80, 0.90),
		"motif": Motif.BLOB,
	},
	{
		"id": "SIZE",
		"name_ko": "크기",
		"name_en": "SIZE",
		# 평균 4.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BIG", "TINY", "WIDE", "TALL", "DEEP", "SMALL", "SHORT", "NARROW"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["LITTLE", "MEDIUM", "MASSIVE", "SLENDER", "GIGANTIC", "ENORMOUS", "COLOSSAL", "MICROSCOPIC"],
		"bg": Color(0.07, 0.09, 0.06),
		"accent": Color(0.60, 1.00, 0.60),
		"particle": Color(0.80, 1.00, 0.80),
		"motif": Motif.BLOB,
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
		"words": ["SUN", "STAR", "MOON", "MARS", "ORBIT", "COMET", "EARTH", "PLANET"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["GALAXY", "METEOR", "NEBULA", "ASTEROID"],
		"bg": Color(0.04, 0.03, 0.09),
		"accent": Color(0.4, 0.85, 1.0),
		"particle": Color(1.0, 1.0, 1.0),
		"motif": Motif.STAR,
	},
	{
		"id": "FOOD",
		"name_ko": "음식",
		"name_en": "FOOD",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["EGG", "RICE", "MEAT", "SOUP", "BREAD", "PIZZA", "SALAD", "CHEESE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["NOODLE", "BUTTER", "PANCAKE", "SANDWICH", "PORRIDGE", "DUMPLING", "CHOCOLATE", "SPAGHETTI"],
		"bg": Color(0.11, 0.07, 0.04),
		"accent": Color(1.00, 0.65, 0.30),
		"particle": Color(1.00, 0.80, 0.45),
		"motif": Motif.BLOB,
	},
	{
		"id": "DRINK",
		"name_ko": "음료",
		"name_en": "DRINKS",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["TEA", "MILK", "SODA", "WINE", "JUICE", "WATER", "COCOA", "COFFEE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["NECTAR", "YOGURT", "LEMONADE", "SMOOTHIE", "BEVERAGE", "ESPRESSO", "MILKSHAKE", "REFRESHMENT"],
		"bg": Color(0.04, 0.08, 0.11),
		"accent": Color(0.40, 0.85, 1.00),
		"particle": Color(0.60, 0.95, 1.00),
		"motif": Motif.BLOB,
	},
	{
		"id": "SCHOOL",
		"name_ko": "학교",
		"name_en": "SCHOOL",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["PEN", "BOOK", "DESK", "NOTE", "CHALK", "PAPER", "RULER", "PENCIL"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["ERASER", "LESSON", "TEACHER", "STUDENT", "HOMEWORK", "CLASSROOM", "PRINCIPAL", "GYMNASIUM"],
		"bg": Color(0.05, 0.06, 0.12),
		"accent": Color(0.55, 0.75, 1.00),
		"particle": Color(0.70, 0.85, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "TIME",
		"name_ko": "시간",
		"name_en": "TIME",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["DAY", "HOUR", "WEEK", "YEAR", "MONTH", "NIGHT", "TODAY", "MINUTE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SECOND", "DECADE", "MORNING", "EVENING", "CENTURY", "MIDNIGHT", "YESTERDAY", "AFTERNOON"],
		"bg": Color(0.06, 0.05, 0.10),
		"accent": Color(0.75, 0.75, 1.00),
		"particle": Color(0.85, 0.85, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "EMOTION",
		"name_ko": "감정",
		"name_en": "FEELINGS",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["JOY", "FEAR", "LOVE", "CALM", "ANGRY", "HAPPY", "PROUD", "SCARED"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["LONELY", "BORING", "NERVOUS", "EXCITED", "JEALOUS", "GRATEFUL", "SURPRISED", "CONFIDENT"],
		"bg": Color(0.10, 0.04, 0.08),
		"accent": Color(1.00, 0.50, 0.70),
		"particle": Color(1.00, 0.70, 0.85),
		"motif": Motif.PULSE,
	},
	{
		"id": "SEA",
		"name_ko": "바다",
		"name_en": "SEA",
		# 평균 4.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["FIN", "CRAB", "SEAL", "WAVE", "CORAL", "SHARK", "WHALE", "SHRIMP"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["ANCHOR", "LAGOON", "LOBSTER", "OCTOPUS", "SEAWEED", "SEASHELL", "JELLYFISH", "SUBMARINE"],
		"bg": Color(0.03, 0.07, 0.11),
		"accent": Color(0.35, 0.85, 1.00),
		"particle": Color(0.60, 0.95, 1.00),
		"motif": Motif.LEAF,
	},
	{
		"id": "SPORT",
		"name_ko": "운동",
		"name_en": "SPORTS",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["RUN", "SWIM", "GOLF", "JUMP", "CLIMB", "SKATE", "TENNIS", "SOCCER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BOXING", "HOCKEY", "ARCHERY", "CYCLING", "BASEBALL", "MARATHON", "BADMINTON", "BASKETBALL"],
		"bg": Color(0.05, 0.10, 0.07),
		"accent": Color(0.40, 1.00, 0.60),
		"particle": Color(0.60, 1.00, 0.70),
		"motif": Motif.PULSE,
	},
	{
		"id": "CITY",
		"name_ko": "도시",
		"name_en": "CITY",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["MAP", "BANK", "PARK", "SHOP", "HOTEL", "TOWER", "BRIDGE", "MARKET"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["STREET", "STATION", "LIBRARY", "TRAFFIC", "HOSPITAL", "SIDEWALK", "RESTAURANT", "SKYSCRAPER"],
		"bg": Color(0.07, 0.06, 0.09),
		"accent": Color(0.60, 0.80, 1.00),
		"particle": Color(0.75, 0.85, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "SHAPE",
		"name_ko": "모양",
		"name_en": "SHAPES",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["DOT", "CUBE", "CONE", "LINE", "OVAL", "CIRCLE", "SPIRAL", "SQUARE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SPHERE", "DIAMOND", "HEXAGON", "PYRAMID", "CYLINDER", "TRIANGLE", "PENTAGON", "RECTANGLE"],
		"bg": Color(0.05, 0.09, 0.09),
		"accent": Color(0.40, 1.00, 0.90),
		"particle": Color(0.60, 1.00, 0.95),
		"motif": Motif.BLOB,
	},
	{
		"id": "TREE",
		"name_ko": "나무",
		"name_en": "TREE",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["ELM", "BARK", "TWIG", "PALM", "MAPLE", "BIRCH", "BRANCH", "WILLOW"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["FOREST", "CANOPY", "TIMBER", "ORCHARD", "SAPLING", "CHESTNUT", "EVERGREEN", "EUCALYPTUS"],
		"bg": Color(0.05, 0.09, 0.05),
		"accent": Color(0.45, 0.95, 0.50),
		"particle": Color(0.65, 1.00, 0.65),
		"motif": Motif.LEAF,
	},
	{
		"id": "FLOWER",
		"name_ko": "꽃",
		"name_en": "FLOWER",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BUD", "ROSE", "LILY", "IRIS", "PETAL", "DAISY", "POLLEN", "ORCHID"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BLOSSOM", "BOUQUET", "GARLAND", "FLORIST", "LAVENDER", "CARNATION", "WILDFLOWER", "CHRYSANTHEMUM"],
		"bg": Color(0.10, 0.05, 0.10),
		"accent": Color(1.00, 0.60, 0.90),
		"particle": Color(1.00, 0.80, 0.95),
		"motif": Motif.LEAF,
	},
	{
		"id": "TOOL",
		"name_ko": "공구",
		"name_en": "TOOL",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SAW", "NAIL", "BOLT", "TAPE", "DRILL", "SCREW", "HAMMER", "WRENCH"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["LADDER", "SHOVEL", "CHISEL", "PLIERS", "TOOLBOX", "SANDPAPER", "WORKBENCH", "SCREWDRIVER"],
		"bg": Color(0.08, 0.08, 0.10),
		"accent": Color(0.85, 0.85, 0.95),
		"particle": Color(1.00, 1.00, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "FISHING",
		"name_ko": "낚시",
		"name_en": "FISHING",
		# 평균 4.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["NET", "BAIT", "HOOK", "REEL", "POLE", "TACKLE", "HARBOR", "SINKER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["TROLLING", "FISHERMAN", "FRESHWATER", "AQUACULTURE"],
		"bg": Color(0.05, 0.08, 0.11),
		"accent": Color(0.50, 0.85, 1.00),
		"particle": Color(0.70, 0.95, 1.00),
		"motif": Motif.PAW,
	},
	{
		"id": "MUSIC",
		"name_ko": "음악",
		"name_en": "MUSIC",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BAND", "BEAT", "DRUM", "HARP", "FLUTE", "PIANO", "VIOLIN", "GUITAR"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["MELODY", "RHYTHM", "TRUMPET", "CONCERT", "SYMPHONY", "ORCHESTRA", "SAXOPHONE", "INSTRUMENT"],
		"bg": Color(0.08, 0.04, 0.12),
		"accent": Color(0.80, 0.50, 1.00),
		"particle": Color(0.90, 0.70, 1.00),
		"motif": Motif.PULSE,
	},
	{
		"id": "VEGETABLE",
		"name_ko": "채소",
		"name_en": "VEGETABLE",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["PEA", "CORN", "BEAN", "LEEK", "ONION", "GARLIC", "CARROT", "PEPPER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["POTATO", "RADISH", "SPINACH", "CABBAGE", "CUCUMBER", "BROCCOLI", "ZUCCHINI", "ASPARAGUS"],
		"bg": Color(0.05, 0.11, 0.06),
		"accent": Color(0.50, 1.00, 0.45),
		"particle": Color(0.70, 1.00, 0.60),
		"motif": Motif.LEAF,
	},
	{
		"id": "MOTION",
		"name_ko": "움직임",
		"name_en": "MOTION",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SPIN", "ROLL", "DIVE", "SLIDE", "CRAWL", "DANCE", "FLOAT", "BOUNCE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["GALLOP", "TUMBLE", "SPRINT", "WANDER", "SWERVE", "PLUNGE", "WHIRLWIND", "SOMERSAULT"],
		"bg": Color(0.06, 0.09, 0.11),
		"accent": Color(0.50, 0.90, 1.00),
		"particle": Color(0.70, 1.00, 1.00),
		"motif": Motif.PULSE,
	},
	{
		"id": "SENSE",
		"name_ko": "감각",
		"name_en": "SENSE",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SEE", "HEAR", "FEEL", "TASTE", "SMELL", "TOUCH", "WATCH", "SILENCE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["WHISPER", "TEXTURE", "HEARING", "PERFUME", "LOUDNESS", "EYESIGHT", "FRAGRANCE", "SENSATION"],
		"bg": Color(0.08, 0.06, 0.12),
		"accent": Color(0.80, 0.70, 1.00),
		"particle": Color(0.90, 0.85, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "GARDEN",
		"name_ko": "정원",
		"name_en": "GARDEN",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["POND", "SOIL", "HOSE", "WEED", "BENCH", "HEDGE", "GRAVEL", "SPROUT"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["SHEARS", "TRELLIS", "COMPOST", "WATERING", "FLOWERBED", "LANDSCAPE", "GREENHOUSE", "WHEELBARROW"],
		"bg": Color(0.05, 0.10, 0.06),
		"accent": Color(0.55, 1.00, 0.50),
		"particle": Color(0.75, 1.00, 0.70),
		"motif": Motif.LEAF,
	},
	{
		"id": "BATHROOM",
		"name_ko": "욕실",
		"name_en": "BATHROOM",
		# 평균 4.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["TUB", "SOAP", "SINK", "COMB", "TOWEL", "DRAIN", "FAUCET", "SHAMPOO"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BATHROBE", "TOOTHPASTE", "TOOTHBRUSH", "VENTILATION"],
		"bg": Color(0.05, 0.09, 0.11),
		"accent": Color(0.50, 0.90, 1.00),
		"particle": Color(0.70, 1.00, 1.00),
		"motif": Motif.BLOB,
	},
	{
		"id": "HEALTH",
		"name_ko": "건강",
		"name_en": "HEALTH",
		# 평균 4.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BONE", "PILL", "MASK", "COUGH", "FEVER", "TOOTH", "HEART", "SYRINGE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BANDAGE", "VITAMIN", "SURGERY", "ALLERGY", "MEDICINE", "EXERCISE", "NUTRITION", "THERMOMETER"],
		"bg": Color(0.05, 0.10, 0.10),
		"accent": Color(0.40, 1.00, 0.85),
		"particle": Color(0.60, 1.00, 0.90),
		"motif": Motif.PULSE,
	},
	{
		"id": "MONEY",
		"name_ko": "돈",
		"name_en": "MONEY",
		# 평균 4.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["COIN", "CASH", "BILL", "SAVE", "PRICE", "WALLET", "CREDIT", "BUDGET"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["INCOME", "PROFIT", "SALARY", "PAYMENT", "DISCOUNT", "EXCHANGE", "CURRENCY", "INVESTMENT"],
		"bg": Color(0.09, 0.09, 0.05),
		"accent": Color(1.00, 0.85, 0.35),
		"particle": Color(1.00, 0.95, 0.60),
		"motif": Motif.STAR,
	},
	{
		"id": "READING",
		"name_ko": "독서",
		"name_en": "READING",
		# 평균 4.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["PAGE", "POEM", "TALE", "NOVEL", "TITLE", "COMIC", "LETTER", "AUTHOR"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CHAPTER", "PREFACE", "SUMMARY", "MAGAZINE", "BOOKMARK", "BIOGRAPHY", "DICTIONARY", "ENCYCLOPEDIA"],
		"bg": Color(0.07, 0.08, 0.06),
		"accent": Color(0.70, 1.00, 0.70),
		"particle": Color(0.85, 1.00, 0.85),
		"motif": Motif.LEAF,
	},
	{
		"id": "FLAVOR",
		"name_ko": "맛",
		"name_en": "FLAVOR",
		# 평균 5.0글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SOUR", "MILD", "SALTY", "SWEET", "SPICY", "FRESH", "BITTER", "SAVORY"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CREAMY", "SMOKED", "CRUNCHY", "BUTTERY", "AROMATIC", "DELICIOUS", "FLAVORFUL", "REFRESHING"],
		"bg": Color(0.11, 0.08, 0.05),
		"accent": Color(1.00, 0.75, 0.40),
		"particle": Color(1.00, 0.90, 0.60),
		"motif": Motif.BLOB,
	},
	{
		"id": "SPEED",
		"name_ko": "속도",
		"name_en": "SPEED",
		# 평균 5.1글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["FAST", "SLOW", "RUSH", "QUICK", "RAPID", "STEADY", "SUDDEN", "GRADUAL"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["INSTANT", "SWIFTLY", "SLUGGISH", "MOMENTUM", "VELOCITY", "IMMEDIATE", "LEISURELY", "ACCELERATE"],
		"bg": Color(0.09, 0.06, 0.11),
		"accent": Color(0.90, 0.60, 1.00),
		"particle": Color(1.00, 0.80, 1.00),
		"motif": Motif.PULSE,
	},
	{
		"id": "CALENDAR",
		"name_ko": "달",
		"name_en": "CALENDAR",
		# 평균 5.1글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["MAY", "JUNE", "JULY", "APRIL", "MARCH", "AUGUST", "JANUARY", "OCTOBER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["EQUINOX", "QUARTER", "FEBRUARY", "NOVEMBER", "DECEMBER", "SEMESTER", "SEPTEMBER", "MILLENNIUM"],
		"bg": Color(0.07, 0.07, 0.11),
		"accent": Color(0.70, 0.80, 1.00),
		"particle": Color(0.85, 0.90, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "ART",
		"name_ko": "예술",
		"name_en": "ART",
		# 평균 5.1글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["INK", "CLAY", "PAINT", "BRUSH", "EASEL", "CANVAS", "SKETCH", "GALLERY"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["PALETTE", "DRAWING", "PATTERN", "PORTRAIT", "SCULPTURE", "EXHIBITION", "WATERCOLOR", "MASTERPIECE"],
		"bg": Color(0.10, 0.06, 0.11),
		"accent": Color(1.00, 0.65, 1.00),
		"particle": Color(1.00, 0.85, 1.00),
		"motif": Motif.BLOB,
	},
	{
		"id": "JOB",
		"name_ko": "직업",
		"name_en": "JOBS",
		# 평균 5.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["CHEF", "NURSE", "PILOT", "BAKER", "ACTOR", "DOCTOR", "FARMER", "POLICE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["ARTIST", "WRITER", "LAWYER", "DENTIST", "ENGINEER", "MECHANIC", "SCIENTIST", "ARCHITECT"],
		"bg": Color(0.06, 0.07, 0.10),
		"accent": Color(0.70, 0.85, 1.00),
		"particle": Color(0.80, 0.90, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "TRAVEL",
		"name_ko": "여행",
		"name_en": "TRAVEL",
		# 평균 5.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["BAG", "TENT", "VISA", "BEACH", "TICKET", "CAMERA", "JOURNEY", "LUGGAGE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["PASSPORT", "SOUVENIR", "SUITCASE", "BACKPACK", "ADVENTURE", "ITINERARY", "SIGHTSEEING", "DESTINATION"],
		"bg": Color(0.06, 0.07, 0.13),
		"accent": Color(0.50, 0.85, 1.00),
		"particle": Color(0.70, 0.95, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "TEMPERATURE",
		"name_ko": "온도",
		"name_en": "TEMPERATURE",
		# 평균 5.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["ICY", "COOL", "DAMP", "HUMID", "CHILLY", "FROZEN", "BURNING", "BOILING"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["THAWING", "FREEZING", "LUKEWARM", "TROPICAL", "SCORCHING", "TEMPERATE", "SWELTERING", "THERMOSTAT"],
		"bg": Color(0.06, 0.08, 0.12),
		"accent": Color(0.60, 0.85, 1.00),
		"particle": Color(0.80, 0.95, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "COMPUTER",
		"name_ko": "컴퓨터",
		"name_en": "COMPUTER",
		# 평균 5.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["KEY", "FILE", "DATA", "MOUSE", "SCREEN", "LAPTOP", "FOLDER", "KEYBOARD"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["INTERNET", "PASSWORD", "DOWNLOAD", "SOFTWARE", "HARDWARE", "ALGORITHM", "PROGRAMMER", "APPLICATION"],
		"bg": Color(0.05, 0.08, 0.11),
		"accent": Color(0.50, 0.90, 1.00),
		"particle": Color(0.70, 1.00, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "PHONE",
		"name_ko": "통신",
		"name_en": "PHONE",
		# 평균 5.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["CALL", "TEXT", "CHAT", "PHONE", "EMAIL", "SIGNAL", "MESSAGE", "CHARGER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["ANTENNA", "ROAMING", "WIRELESS", "CONTACTS", "BROADCAST", "VOICEMAIL", "SMARTPHONE", "NOTIFICATION"],
		"bg": Color(0.07, 0.06, 0.11),
		"accent": Color(0.80, 0.70, 1.00),
		"particle": Color(0.90, 0.85, 1.00),
		"motif": Motif.PULSE,
	},
	{
		"id": "MOUNTAIN",
		"name_ko": "산",
		"name_en": "MOUNTAIN",
		# 평균 5.2글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["PEAK", "CAVE", "CLIFF", "RIDGE", "SLOPE", "VALLEY", "SUMMIT", "BOULDER"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["PLATEAU", "ALTITUDE", "AVALANCHE", "MOUNTAINEER"],
		"bg": Color(0.06, 0.08, 0.07),
		"accent": Color(0.60, 0.95, 0.80),
		"particle": Color(0.80, 1.00, 0.90),
		"motif": Motif.LEAF,
	},
	{
		"id": "MACHINE",
		"name_ko": "기계",
		"name_en": "MACHINES",
		# 평균 5.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["GEAR", "WIRE", "MOTOR", "ROBOT", "ENGINE", "CYBORG", "MAGNET", "ANDROID"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BATTERY", "TURBINE", "CIRCUIT", "PROPELLER"],
		"bg": Color(0.06, 0.07, 0.10),
		"accent": Color(0.7, 0.8, 1.0),
		"particle": Color(0.55, 0.7, 0.9),
		"motif": Motif.GEAR,
	},
	{
		"id": "SAFETY",
		"name_ko": "안전",
		"name_en": "SAFETY",
		# 평균 5.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["EXIT", "HELP", "ALARM", "GUARD", "HELMET", "ESCAPE", "DANGER", "WARNING"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CAUTION", "ACCIDENT", "LIFEBOAT", "SEATBELT", "EMERGENCY", "PRECAUTION", "PROTECTION", "EXTINGUISHER"],
		"bg": Color(0.11, 0.07, 0.05),
		"accent": Color(1.00, 0.70, 0.35),
		"particle": Color(1.00, 0.85, 0.50),
		"motif": Motif.PULSE,
	},
	{
		"id": "DINING",
		"name_ko": "식당",
		"name_en": "DINING",
		# 평균 5.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["TIP", "MENU", "ORDER", "STRAW", "WAITER", "NAPKIN", "RECEIPT", "SERVING"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["TAKEOUT", "CUISINE", "PORTION", "LEFTOVER", "GRATUITY", "APPETIZER", "SPECIALTY", "INGREDIENT"],
		"bg": Color(0.10, 0.08, 0.05),
		"accent": Color(1.00, 0.80, 0.45),
		"particle": Color(1.00, 0.90, 0.60),
		"motif": Motif.BLOB,
	},
	{
		"id": "BAKERY",
		"name_ko": "제빵",
		"name_en": "BAKERY",
		# 평균 5.4글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["OVEN", "DOUGH", "YEAST", "FLOUR", "CRUST", "BAGEL", "MUFFIN", "BAGUETTE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CROISSANT", "SOURDOUGH", "CONFECTION", "GINGERBREAD"],
		"bg": Color(0.10, 0.08, 0.05),
		"accent": Color(1.00, 0.80, 0.45),
		"particle": Color(1.00, 0.90, 0.65),
		"motif": Motif.BLOB,
	},
	{
		"id": "AIRPORT",
		"name_ko": "공항",
		"name_en": "AIRPORT",
		# 평균 5.5글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["GATE", "BELT", "SEAT", "CABIN", "FLIGHT", "RUNWAY", "LANDING", "BOARDING"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["TERMINAL", "SECURITY", "AIRCRAFT", "DEPARTURE", "PASSENGER", "TURBULENCE", "RESERVATION", "INTERNATIONAL"],
		"bg": Color(0.05, 0.08, 0.12),
		"accent": Color(0.60, 0.90, 1.00),
		"particle": Color(0.80, 0.95, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "MINERAL",
		"name_ko": "광물",
		"name_en": "MINERAL",
		# 평균 5.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["IRON", "COAL", "SALT", "COPPER", "MARBLE", "QUARTZ", "GRANITE", "OBSIDIAN"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["AMETHYST", "SAPPHIRE", "LIMESTONE", "TURQUOISE"],
		"bg": Color(0.07, 0.07, 0.09),
		"accent": Color(0.80, 0.85, 1.00),
		"particle": Color(0.95, 0.95, 1.00),
		"motif": Motif.GEAR,
	},
	{
		"id": "LAUNDRY",
		"name_ko": "세탁",
		"name_en": "LAUNDRY",
		# 평균 5.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SOAK", "STAIN", "DRYER", "STEAM", "FABRIC", "BASKET", "IRONING", "WASHING"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["LAUNDRY", "SOFTENER", "DETERGENT", "CLOTHESLINE"],
		"bg": Color(0.06, 0.08, 0.10),
		"accent": Color(0.60, 0.90, 1.00),
		"particle": Color(0.80, 1.00, 1.00),
		"motif": Motif.PULSE,
	},
	{
		"id": "SHOPPING",
		"name_ko": "쇼핑",
		"name_en": "SHOPPING",
		# 평균 5.6글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["CART", "SALE", "AISLE", "QUEUE", "COUPON", "CASHIER", "TROLLEY", "BARGAIN"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CHECKOUT", "BOUTIQUE", "WAREHOUSE", "SUPERMARKET"],
		"bg": Color(0.09, 0.06, 0.09),
		"accent": Color(1.00, 0.70, 0.95),
		"particle": Color(1.00, 0.85, 1.00),
		"motif": Motif.STAR,
	},
	{
		"id": "PARTY",
		"name_ko": "축제",
		"name_en": "PARTY",
		# 평균 5.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["GIFT", "FLAG", "PRIZE", "CANDLE", "RIBBON", "PARADE", "BALLOON", "FIREWORK"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["CARNIVAL", "CONFETTI", "FESTIVAL", "STREAMER", "INVITATION", "DECORATION", "CELEBRATION", "ENTERTAINMENT"],
		"bg": Color(0.10, 0.06, 0.10),
		"accent": Color(1.00, 0.60, 0.90),
		"particle": Color(1.00, 0.80, 0.95),
		"motif": Motif.STAR,
	},
	{
		"id": "BEDROOM",
		"name_ko": "침실",
		"name_en": "BEDROOM",
		# 평균 6.1글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["RUG", "SHEET", "DRAWER", "CLOSET", "HANGER", "CURTAIN", "MATTRESS", "WARDROBE"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BEDSPREAD", "HEADBOARD", "NIGHTSTAND", "CHANDELIER"],
		"bg": Color(0.08, 0.06, 0.11),
		"accent": Color(0.75, 0.70, 1.00),
		"particle": Color(0.90, 0.85, 1.00),
		"motif": Motif.BLOB,
	},
	{
		"id": "POSTAL",
		"name_ko": "우편",
		"name_en": "POSTAL",
		# 평균 6.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["STAMP", "PARCEL", "SENDER", "ADDRESS", "MAILBOX", "COURIER", "ENVELOPE", "POSTCARD"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["DELIVERY", "SHIPMENT", "RECIPIENT", "REGISTERED"],
		"bg": Color(0.09, 0.07, 0.06),
		"accent": Color(1.00, 0.75, 0.50),
		"particle": Color(1.00, 0.90, 0.70),
		"motif": Motif.GEAR,
	},
	{
		"id": "SEASON",
		"name_ko": "계절",
		"name_en": "SEASON",
		# 평균 6.8글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["SPRING", "SUMMER", "AUTUMN", "WINTER", "SNOWMAN", "MONSOON", "SUNSHINE", "BLIZZARD"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["HEATWAVE", "SNOWFLAKE", "HIBERNATE", "MIGRATION"],
		"bg": Color(0.07, 0.09, 0.08),
		"accent": Color(0.65, 1.00, 0.75),
		"particle": Color(0.85, 1.00, 0.90),
		"motif": Motif.LEAF,
	},
	{
		"id": "WEEKDAY",
		"name_ko": "요일",
		"name_en": "WEEKDAY",
		# 평균 6.9글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).
		"words": ["MONDAY", "FRIDAY", "SUNDAY", "TUESDAY", "WEEKEND", "HOLIDAY", "THURSDAY", "SATURDAY"],
		# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).
		"advanced": ["BIRTHDAY", "SCHEDULE", "WORKWEEK", "OVERTIME", "DEADLINE", "WEDNESDAY", "ANNIVERSARY", "APPOINTMENT"],
		"bg": Color(0.06, 0.08, 0.10),
		"accent": Color(0.60, 0.90, 0.95),
		"particle": Color(0.80, 1.00, 1.00),
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
