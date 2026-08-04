class_name WordDictionary
## WordDictionary - 단어 설명 데이터베이스
## 각 단어의 카테고리와 한국어/영어 설명을 제공

const WORD_DATA: Dictionary = {
	# ---- EASY (3 letters) ----
	"SUN": {"category": "SPACE", "emoji": "☀️", "ko": "태양. 낮에 하늘에서 빛나는 커다란 별이에요.", "en": "The bright star that lights up our daytime sky."},
	"CAT": {"category": "ANIMAL", "emoji": "🐱", "ko": "고양이. 야옹하고 우는 귀여운 동물이에요.", "en": "A small furry pet that says 'meow'."},
	"DOG": {"category": "ANIMAL", "emoji": "🐶", "ko": "강아지. 멍멍 짖는 충실한 친구예요.", "en": "A loyal pet that says 'woof'."},
	"BAT": {"category": "ANIMAL", "emoji": "🦇", "ko": "박쥐. 밤에 날아다니는 동물이에요.", "en": "A flying animal that is active at night."},
	"OWL": {"category": "ANIMAL", "emoji": "🦉", "ko": "부엉이. 밤에 '뿌hu' 하고 우는 새예요.", "en": "A wise bird that is awake at night."},
	"FOX": {"category": "ANIMAL", "emoji": "🦊", "ko": "여우. 영리하고 빠른 동물이에요.", "en": "A clever, fast animal with a bushy tail."},
	"BEE": {"category": "ANIMAL", "emoji": "🐝", "ko": "꿀벌. 꿀을 만드는 바쁜 곤충이에요.", "en": "A small insect that makes honey."},
	"FLY": {"category": "ANIMAL", "emoji": "🪰", "ko": "파리. 날아다니는 작은 곤충이에요.", "en": "A small flying insect."},
	"SKY": {"category": "NATURE", "emoji": "🌌", "ko": "하늘. 머리 위에 보이는 파란 곳이에요.", "en": "The blue space above us."},
	"RAY": {"category": "SCIENCE", "emoji": "🔅", "ko": "광선. 빛이 일직선으로 나아가는 것이에요.", "en": "A line of light shining from a source."},
	"GUN": {"category": "WEAPON", "emoji": "🔫", "ko": "총. 총알을 쏘는 무기예요.", "en": "A weapon that shoots bullets."},
	"JET": {"category": "VEHICLE", "emoji": "✈️", "ko": "제트기. 아주 빠르게 날아가는 비행기예요.", "en": "A very fast airplane."},
	"ORB": {"category": "MAGIC", "emoji": "🔮", "ko": "구슬. 둥글고 빛나는 마법 구체예요.", "en": "A glowing magic sphere."},
	"ARC": {"category": "SCIENCE", "emoji": "🌈", "ko": "호. 둥글게 휘어진 선이에요.", "en": "A curved line, like part of a circle."},
	"ICE": {"category": "NATURE", "emoji": "🧊", "ko": "얼음. 차갑고 딱딱하게 언 물이에요.", "en": "Frozen water, cold and hard."},
	"GAS": {"category": "SCIENCE", "emoji": "💨", "ko": "기체. 공기처럼 보이지 않는 물질이에요.", "en": "An invisible substance like air."},
	"RED": {"category": "COLOR", "emoji": "🔴", "ko": "빨간색. 사과와 같은 색이에요.", "en": "The color of apples and fire."},
	"GEM": {"category": "TREASURE", "emoji": "💎", "ko": "보석. 반짝이는 귀한 돌이에요.", "en": "A shiny, precious stone."},
	"EYE": {"category": "BODY", "emoji": "👁️", "ko": "눈. 세상을 보는 우리의 기관이에요.", "en": "The body part we use to see."},
	"ARM": {"category": "BODY", "emoji": "💪", "ko": "팔. 물건을 들고 잡을 수 있어요.", "en": "The body part we use to hold things."},
	"LEG": {"category": "BODY", "emoji": "🦵", "ko": "다리. 걷고 뛸 수 있게 해줘요.", "en": "The body part we use to walk and run."},
	"EAR": {"category": "BODY", "emoji": "👂", "ko": "귀. 소리를 들을 수 있어요.", "en": "The body part we use to hear."},

	# ---- NORMAL (4-5 letters) ----
	"STAR": {"category": "SPACE", "emoji": "⭐", "ko": "별. 밤하늘에서 반짝이는 빛이에요.", "en": "A twinkling light in the night sky."},
	"MOON": {"category": "SPACE", "emoji": "🌙", "ko": "달. 밤에 보이는 둥근 천체예요.", "en": "The round object that shines at night."},
	"MARS": {"category": "SPACE", "emoji": "🔴", "ko": "화성. 붉은색 행성이에요.", "en": "The red planet in our solar system."},
	"BIRD": {"category": "ANIMAL", "emoji": "🐦", "ko": "새. 하늘을 날아다니는 동물이에요.", "en": "An animal that can fly in the sky."},
	"FISH": {"category": "ANIMAL", "emoji": "🐟", "ko": "물고기. 물속에서 헤엄치는 동물이에요.", "en": "An animal that swims in water."},
	"BEAR": {"category": "ANIMAL", "emoji": "🐻", "ko": "곰. 크고 힘센 동물이에요.", "en": "A big, strong furry animal."},
	"WOLF": {"category": "ANIMAL", "emoji": "🐺", "ko": "늑대. 숲속에 사는 야생 개과 동물이에요.", "en": "A wild animal that lives in forests."},
	"BLUE": {"category": "COLOR", "emoji": "🔵", "ko": "파란색. 하늘과 바다의 색이에요.", "en": "The color of the sky and ocean."},
	"GOLD": {"category": "TREASURE", "emoji": "🥇", "ko": "금. 노랗고 빛나는 귀금속이에요.", "en": "A shiny, yellow precious metal."},
	"PINK": {"category": "COLOR", "emoji": "🩷", "ko": "분홍색. 부드러운 연한 붉은색이에요.", "en": "A soft, light red color."},
	"GAME": {"category": "FUN", "emoji": "🎮", "ko": "게임. 즐겁게 노는 놀이예요.", "en": "Something fun you play."},
	"PLAY": {"category": "FUN", "emoji": "🎯", "ko": "놀다. 즐겁게 활동하는 것이에요.", "en": "To have fun doing an activity."},
	"MOVE": {"category": "ACTION", "emoji": "🏃", "ko": "움직이다. 한 곳에서 다른 곳으로 가요.", "en": "To change position or go somewhere."},
	"FIRE": {"category": "NATURE", "emoji": "🔥", "ko": "불. 뜨겁고 밝게 타오르는 것이에요.", "en": "Hot flames that burn and glow."},
	"COMET": {"category": "SPACE", "emoji": "☄️", "ko": "혜성. 긴 꼬리를 남기며 날아가는 천체예요.", "en": "A space object with a glowing tail."},
	"EARTH": {"category": "SPACE", "emoji": "🌍", "ko": "지구. 우리가 사는 파란 행성이에요.", "en": "Our home planet, the blue planet."},
	"VENUS": {"category": "SPACE", "emoji": "🪐", "ko": "금성. 아주 뜨거운 행성이에요.", "en": "The hottest planet in our solar system."},
	"SOLAR": {"category": "SPACE", "emoji": "☀️", "ko": "태양의. 태양과 관련된 것이에요.", "en": "Relating to the sun."},
	"ORBIT": {"category": "SPACE", "emoji": "🛰️", "ko": "궤도. 행성이 도는 길이에요.", "en": "The path a planet takes around the sun."},
	"LASER": {"category": "SCIENCE", "emoji": "🔆", "ko": "레이저. 강한 빛의 줄기예요.", "en": "A powerful beam of focused light."},
	"ALIEN": {"category": "SPACE", "emoji": "👽", "ko": "외계인. 다른 별에서 온 존재예요.", "en": "A being from another planet."},
	"ROBOT": {"category": "MACHINE", "emoji": "🤖", "ko": "로봇. 스스로 움직이는 기계예요.", "en": "A machine that can move on its own."},
	"POWER": {"category": "ENERGY", "emoji": "⚡", "ko": "힘. 무엇이든 할 수 있는 에너지예요.", "en": "The energy to do things."},
	"SWORD": {"category": "WEAPON", "emoji": "⚔️", "ko": "칼. 날카로운 무기예요.", "en": "A sharp blade weapon."},
	"BLADE": {"category": "WEAPON", "emoji": "🗡️", "ko": "칼날. 베는 도구의 날카로운 부분이에요.", "en": "The sharp cutting part of a weapon."},
	"SHIELD": {"category": "DEFENSE", "emoji": "🛡️", "ko": "방패. 공격을 막아주는 도구예요.", "en": "Something that protects you from attacks."},
	"GHOST": {"category": "MAGIC", "emoji": "👻", "ko": "유령. 투명한 영혼이에요.", "en": "A transparent spirit of the dead."},
	"STORM": {"category": "NATURE", "emoji": "⛈️", "ko": "폭풍. 비와 바람이 몰아치는 날씨예요.", "en": "Violent weather with wind and rain."},
	"FLAME": {"category": "NATURE", "emoji": "🔥", "ko": "화염. 타오르는 불꽃이에요.", "en": "A burning tongue of fire."},
	"SHINE": {"category": "LIGHT", "emoji": "✨", "ko": "빛나다. 밝게 반짝이는 것이에요.", "en": "To glow brightly."},
	"LIGHT": {"category": "LIGHT", "emoji": "💡", "ko": "빛. 어둠을 밝혀주는 것이에요.", "en": "Brightness that helps us see."},

	# ---- HARD (6+ letters) ----
	"ROCKET": {"category": "VEHICLE", "emoji": "🚀", "ko": "로켓. 우주로 날아가는 비행체예요.", "en": "A vehicle that flies into space."},
	"GALAXY": {"category": "SPACE", "emoji": "🌌", "ko": "은하. 수많은 별들의 모임이에요.", "en": "A huge group of stars in space."},
	"PLANET": {"category": "SPACE", "emoji": "🪐", "ko": "행성. 별 주위를 도는 천체예요.", "en": "A large object orbiting a star."},
	"COSMOS": {"category": "SPACE", "emoji": "🌠", "ko": "우주. 끝없이 넓은 공간이에요.", "en": "The entire universe."},
	"NEBULA": {"category": "SPACE", "emoji": "🌫️", "ko": "성운. 우주의 아름다운 가스 구름이에요.", "en": "A beautiful cloud of gas in space."},
	"METEOR": {"category": "SPACE", "emoji": "☄️", "ko": "유성. 빛을 내며 떨어지는 돌이에요.", "en": "A shooting star that falls from the sky."},
	"SATURN": {"category": "SPACE", "emoji": "🪐", "ko": "토성. 고리가 있는 행성이에요.", "en": "The planet famous for its rings."},
	"URANUS": {"category": "SPACE", "emoji": "🪐", "ko": "천왕성. 옆으로 누워 도는 행성이에요.", "en": "An ice giant planet that spins on its side."},
	"COMETS": {"category": "SPACE", "emoji": "☄️", "ko": "혜성들. 꼬리가 있는 우주 얼음 덩어리예요.", "en": "Plural of comet - icy space objects with tails."},
	"STARDUST": {"category": "SPACE", "emoji": "✨", "ko": "별가루. 별이 만든 빛나는 먼지예요.", "en": "Magical dust from stars."},
	"SPACESHIP": {"category": "VEHICLE", "emoji": "🛸", "ko": "우주선. 우주를 여행하는 배예요.", "en": "A vehicle that travels through space."},
	"ASTEROID": {"category": "SPACE", "emoji": "☄️", "ko": "소행성. 우주를 떠다니는 큰 바위예요.", "en": "A large rock floating in space."},
	"ANDROID": {"category": "MACHINE", "emoji": "🤖", "ko": "안드로이드. 사람처럼 생긴 로봇이에요.", "en": "A robot that looks like a human."},
	"CYBORG": {"category": "MACHINE", "emoji": "🦾", "ko": "사이보그. 기계와 생물이 합쳐진 존재예요.", "en": "Part human, part machine."},
	"VOLCANO": {"category": "NATURE", "emoji": "🌋", "ko": "화산. 불과 암석을 뿜어내는 산이에요.", "en": "A mountain that erupts with lava."},
	"CRYSTAL": {"category": "TREASURE", "emoji": "💎", "ko": "크리스탈. 투명하고 빛나는 보석이에요.", "en": "A clear, shiny, precious mineral."},
	"THUNDER": {"category": "NATURE", "emoji": "⚡", "ko": "천둥. 번개 칠 때 나는 큰 소리예요.", "en": "The loud sound that follows lightning."},
	"PHANTOM": {"category": "MAGIC", "emoji": "👻", "ko": "유령. 보이지 않는 신비한 존재예요.", "en": "A mysterious ghostly figure."},
	"HARDCORE": {"category": "GAME", "emoji": "💀", "ko": "하드코어. 아주 어려운 최고 난이도예요.", "en": "The most difficult level of challenge."},
	"VICTORY": {"category": "GAME", "emoji": "🏆", "ko": "승리. 게임에서 이기는 것이에요.", "en": "Winning the game!"},
}


static func get_description(word: String) -> Dictionary:
	var w := word.to_upper()
	if WORD_DATA.has(w):
		return WORD_DATA[w]
	return {"category": "?", "ko": "설명이 없습니다.", "en": "No description available."}


## 단어에 해당하는 이모지를 반환 (없으면 ✨)
static func get_emoji(word: String) -> String:
	var w := word.to_upper()
	if WORD_DATA.has(w) and WORD_DATA[w].has("emoji"):
		return WORD_DATA[w]["emoji"]
	return "✨"


static func get_all_words() -> Array:
	return WORD_DATA.keys()


static func get_words_by_category(category: String) -> Array:
	var result: Array = []
	for word in WORD_DATA.keys():
		if WORD_DATA[word]["category"] == category:
			result.append(word)
	return result


static func get_categories() -> Array:
	var cats: Array = []
	for word in WORD_DATA.keys():
		var c: String = WORD_DATA[word]["category"]
		if c not in cats:
			cats.append(c)
	return cats