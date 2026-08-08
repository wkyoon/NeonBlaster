class_name WordDictionary
## WordDictionary - 단어 설명 데이터베이스
## 각 단어의 카테고리와 한국어/영어 설명을 제공

const WORD_DATA: Dictionary = {
	# ---- EASY (3 letters) ----
	"SUN": {"category": "SPACE", "emoji": "☀️", "ko": "태양. 낮에 하늘에서 빛나는 커다란 별이에요.", "en": "The bright star that lights up our daytime sky.", "phrase": "The sun rises every morning."},
	"CAT": {"category": "ANIMAL", "emoji": "🐱", "ko": "고양이. 야옹하고 우는 귀여운 동물이에요.", "en": "A small furry pet that says 'meow'.", "phrase": "The cat drinks warm milk."},
	"DOG": {"category": "ANIMAL", "emoji": "🐶", "ko": "강아지. 멍멍 짖는 충실한 친구예요.", "en": "A loyal pet that says 'woof'.", "phrase": "My dog wags its tail."},
	"BAT": {"category": "ANIMAL", "emoji": "🦇", "ko": "박쥐. 밤에 날아다니는 동물이에요.", "en": "A flying animal that is active at night.", "phrase": "The bat sleeps upside down."},
	"OWL": {"category": "ANIMAL", "emoji": "🦉", "ko": "부엉이. 밤에 '뿌hu' 하고 우는 새예요.", "en": "A wise bird that is awake at night.", "phrase": "An owl hunts at night."},
	"FOX": {"category": "ANIMAL", "emoji": "🦊", "ko": "여우. 영리하고 빠른 동물이에요.", "en": "A clever, fast animal with a bushy tail.", "phrase": "The fox runs very fast."},
	"BEE": {"category": "ANIMAL", "emoji": "🐝", "ko": "꿀벌. 꿀을 만드는 바쁜 곤충이에요.", "en": "A small insect that makes honey.", "phrase": "The bee makes sweet honey."},
	"FLY": {"category": "ANIMAL", "emoji": "🪰", "ko": "파리. 날아다니는 작은 곤충이에요.", "en": "A small flying insect."},
	"SKY": {"category": "NATURE", "emoji": "🌌", "ko": "하늘. 머리 위에 보이는 파란 곳이에요.", "en": "The blue space above us.", "phrase": "Birds fly across the sky."},
	"RAY": {"category": "SCIENCE", "emoji": "🔅", "ko": "광선. 빛이 일직선으로 나아가는 것이에요.", "en": "A line of light shining from a source."},
	"GUN": {"category": "WEAPON", "emoji": "🔫", "ko": "총. 총알을 쏘는 무기예요.", "en": "A weapon that shoots bullets."},
	"JET": {"category": "VEHICLE", "emoji": "✈️", "ko": "제트기. 아주 빠르게 날아가는 비행기예요.", "en": "A very fast airplane.", "phrase": "The jet flies above the clouds."},
	"ORB": {"category": "MAGIC", "emoji": "🔮", "ko": "구슬. 둥글고 빛나는 마법 구체예요.", "en": "A glowing magic sphere."},
	"ARC": {"category": "SCIENCE", "emoji": "🌈", "ko": "호. 둥글게 휘어진 선이에요.", "en": "A curved line, like part of a circle."},
	"ICE": {"category": "NATURE", "emoji": "🧊", "ko": "얼음. 차갑고 딱딱하게 언 물이에요.", "en": "Frozen water, cold and hard.", "phrase": "Ice melts in warm water."},
	"GAS": {"category": "SCIENCE", "emoji": "💨", "ko": "기체. 공기처럼 보이지 않는 물질이에요.", "en": "An invisible substance like air."},
	"RED": {"category": "COLOR", "emoji": "🔴", "ko": "빨간색. 사과와 같은 색이에요.", "en": "The color of apples and fire.", "phrase": "A red apple is sweet."},
	"GEM": {"category": "TREASURE", "emoji": "💎", "ko": "보석. 반짝이는 귀한 돌이에요.", "en": "A shiny, precious stone."},
	"EYE": {"category": "BODY", "emoji": "👁️", "ko": "눈. 세상을 보는 우리의 기관이에요.", "en": "The body part we use to see.", "phrase": "I see with my eye."},
	"ARM": {"category": "BODY", "emoji": "💪", "ko": "팔. 물건을 들고 잡을 수 있어요.", "en": "The body part we use to hold things.", "phrase": "He lifts a heavy box with his arm."},
	"LEG": {"category": "BODY", "emoji": "🦵", "ko": "다리. 걷고 뛸 수 있게 해줘요.", "en": "The body part we use to walk and run.", "phrase": "She runs on strong legs."},
	"EAR": {"category": "BODY", "emoji": "👂", "ko": "귀. 소리를 들을 수 있어요.", "en": "The body part we use to hear.", "phrase": "I hear with my ear."},

	# ---- NORMAL (4-5 letters) ----
	"STAR": {"category": "SPACE", "emoji": "⭐", "ko": "별. 밤하늘에서 반짝이는 빛이에요.", "en": "A twinkling light in the night sky.", "phrase": "A bright star shines tonight."},
	"MOON": {"category": "SPACE", "emoji": "🌙", "ko": "달. 밤에 보이는 둥근 천체예요.", "en": "The round object that shines at night.", "phrase": "The moon glows in the dark."},
	"MARS": {"category": "SPACE", "emoji": "🔴", "ko": "화성. 붉은색 행성이에요.", "en": "The red planet in our solar system.", "phrase": "Mars is the red planet."},
	"BIRD": {"category": "ANIMAL", "emoji": "🐦", "ko": "새. 하늘을 날아다니는 동물이에요.", "en": "An animal that can fly in the sky.", "phrase": "A little bird can fly."},
	"FISH": {"category": "ANIMAL", "emoji": "🐟", "ko": "물고기. 물속에서 헤엄치는 동물이에요.", "en": "An animal that swims in water.", "phrase": "The fish swims in water."},
	"BEAR": {"category": "ANIMAL", "emoji": "🐻", "ko": "곰. 크고 힘센 동물이에요.", "en": "A big, strong furry animal.", "phrase": "A big bear loves honey."},
	"WOLF": {"category": "ANIMAL", "emoji": "🐺", "ko": "늑대. 숲속에 사는 야생 개과 동물이에요.", "en": "A wild animal that lives in forests.", "phrase": "A wolf howls at the moon."},
	"BLUE": {"category": "COLOR", "emoji": "🔵", "ko": "파란색. 하늘과 바다의 색이에요.", "en": "The color of the sky and ocean.", "phrase": "The sky is blue today."},
	"GOLD": {"category": "TREASURE", "emoji": "🥇", "ko": "금. 노랗고 빛나는 귀금속이에요.", "en": "A shiny, yellow precious metal."},
	"PINK": {"category": "COLOR", "emoji": "🩷", "ko": "분홍색. 부드러운 연한 붉은색이에요.", "en": "A soft, light red color.", "phrase": "She wears a pink dress."},
	"GAME": {"category": "FUN", "emoji": "🎮", "ko": "게임. 즐겁게 노는 놀이예요.", "en": "Something fun you play."},
	"PLAY": {"category": "FUN", "emoji": "🎯", "ko": "놀다. 즐겁게 활동하는 것이에요.", "en": "To have fun doing an activity."},
	"MOVE": {"category": "ACTION", "emoji": "🏃", "ko": "움직이다. 한 곳에서 다른 곳으로 가요.", "en": "To change position or go somewhere."},
	"FIRE": {"category": "NATURE", "emoji": "🔥", "ko": "불. 뜨겁고 밝게 타오르는 것이에요.", "en": "Hot flames that burn and glow.", "phrase": "The fire keeps us warm."},
	"COMET": {"category": "SPACE", "emoji": "☄️", "ko": "혜성. 긴 꼬리를 남기며 날아가는 천체예요.", "en": "A space object with a glowing tail.", "phrase": "A comet has a long tail."},
	"EARTH": {"category": "SPACE", "emoji": "🌍", "ko": "지구. 우리가 사는 파란 행성이에요.", "en": "Our home planet, the blue planet.", "phrase": "We all live on Earth."},
	"VENUS": {"category": "SPACE", "emoji": "🪐", "ko": "금성. 아주 뜨거운 행성이에요.", "en": "The hottest planet in our solar system."},
	"SOLAR": {"category": "SPACE", "emoji": "☀️", "ko": "태양의. 태양과 관련된 것이에요.", "en": "Relating to the sun."},
	"ORBIT": {"category": "SPACE", "emoji": "🛰️", "ko": "궤도. 행성이 도는 길이에요.", "en": "The path a planet takes around the sun.", "phrase": "The moon stays in orbit."},
	"LASER": {"category": "SCIENCE", "emoji": "🔆", "ko": "레이저. 강한 빛의 줄기예요.", "en": "A powerful beam of focused light.", "phrase": "A laser cuts through metal."},
	"ALIEN": {"category": "SPACE", "emoji": "👽", "ko": "외계인. 다른 별에서 온 존재예요.", "en": "A being from another planet."},
	"ROBOT": {"category": "MACHINE", "emoji": "🤖", "ko": "로봇. 스스로 움직이는 기계예요.", "en": "A machine that can move on its own.", "phrase": "This robot can walk and talk."},
	"POWER": {"category": "ENERGY", "emoji": "⚡", "ko": "힘. 무엇이든 할 수 있는 에너지예요.", "en": "The energy to do things."},
	"SWORD": {"category": "WEAPON", "emoji": "⚔️", "ko": "칼. 날카로운 무기예요.", "en": "A sharp blade weapon."},
	"BLADE": {"category": "WEAPON", "emoji": "🗡️", "ko": "칼날. 베는 도구의 날카로운 부분이에요.", "en": "The sharp cutting part of a weapon."},
	"SHIELD": {"category": "DEFENSE", "emoji": "🛡️", "ko": "방패. 공격을 막아주는 도구예요.", "en": "Something that protects you from attacks."},
	"GHOST": {"category": "MAGIC", "emoji": "👻", "ko": "유령. 투명한 영혼이에요.", "en": "A transparent spirit of the dead."},
	"STORM": {"category": "NATURE", "emoji": "⛈️", "ko": "폭풍. 비와 바람이 몰아치는 날씨예요.", "en": "Violent weather with wind and rain.", "phrase": "A storm brings wind and rain."},
	"FLAME": {"category": "NATURE", "emoji": "🔥", "ko": "화염. 타오르는 불꽃이에요.", "en": "A burning tongue of fire.", "phrase": "A small flame lights the candle."},
	"SHINE": {"category": "LIGHT", "emoji": "✨", "ko": "빛나다. 밝게 반짝이는 것이에요.", "en": "To glow brightly."},
	"LIGHT": {"category": "LIGHT", "emoji": "💡", "ko": "빛. 어둠을 밝혀주는 것이에요.", "en": "Brightness that helps us see."},

	# ---- HARD (6+ letters) ----
	"ROCKET": {"category": "VEHICLE", "emoji": "🚀", "ko": "로켓. 우주로 날아가는 비행체예요.", "en": "A vehicle that flies into space.", "phrase": "The rocket blasts into space."},
	"GALAXY": {"category": "SPACE", "emoji": "🌌", "ko": "은하. 수많은 별들의 모임이에요.", "en": "A huge group of stars in space.", "phrase": "Our galaxy holds many stars."},
	"PLANET": {"category": "SPACE", "emoji": "🪐", "ko": "행성. 별 주위를 도는 천체예요.", "en": "A large object orbiting a star.", "phrase": "Each planet circles a star."},
	"COSMOS": {"category": "SPACE", "emoji": "🌠", "ko": "우주. 끝없이 넓은 공간이에요.", "en": "The entire universe."},
	"NEBULA": {"category": "SPACE", "emoji": "🌫️", "ko": "성운. 우주의 아름다운 가스 구름이에요.", "en": "A beautiful cloud of gas in space.", "phrase": "A nebula is a cloud of gas."},
	"METEOR": {"category": "SPACE", "emoji": "☄️", "ko": "유성. 빛을 내며 떨어지는 돌이에요.", "en": "A shooting star that falls from the sky.", "phrase": "A meteor streaks across the sky."},
	"SATURN": {"category": "SPACE", "emoji": "🪐", "ko": "토성. 고리가 있는 행성이에요.", "en": "The planet famous for its rings."},
	"URANUS": {"category": "SPACE", "emoji": "🪐", "ko": "천왕성. 옆으로 누워 도는 행성이에요.", "en": "An ice giant planet that spins on its side."},
	"COMETS": {"category": "SPACE", "emoji": "☄️", "ko": "혜성들. 꼬리가 있는 우주 얼음 덩어리예요.", "en": "Plural of comet - icy space objects with tails."},
	"STARDUST": {"category": "SPACE", "emoji": "✨", "ko": "별가루. 별이 만든 빛나는 먼지예요.", "en": "Magical dust from stars."},
	"SPACESHIP": {"category": "VEHICLE", "emoji": "🛸", "ko": "우주선. 우주를 여행하는 배예요.", "en": "A vehicle that travels through space.", "phrase": "The spaceship travels between planets."},
	"ASTEROID": {"category": "SPACE", "emoji": "☄️", "ko": "소행성. 우주를 떠다니는 큰 바위예요.", "en": "A large rock floating in space.", "phrase": "An asteroid flies past the earth."},
	"ANDROID": {"category": "MACHINE", "emoji": "🤖", "ko": "안드로이드. 사람처럼 생긴 로봇이에요.", "en": "A robot that looks like a human.", "phrase": "An android looks just like a human."},
	"CYBORG": {"category": "MACHINE", "emoji": "🦾", "ko": "사이보그. 기계와 생물이 합쳐진 존재예요.", "en": "Part human, part machine.", "phrase": "A cyborg is part machine."},
	"VOLCANO": {"category": "NATURE", "emoji": "🌋", "ko": "화산. 불과 암석을 뿜어내는 산이에요.", "en": "A mountain that erupts with lava.", "phrase": "The volcano shoots hot lava."},
	"CRYSTAL": {"category": "TREASURE", "emoji": "💎", "ko": "크리스탈. 투명하고 빛나는 보석이에요.", "en": "A clear, shiny, precious mineral."},
	"THUNDER": {"category": "NATURE", "emoji": "⚡", "ko": "천둥. 번개 칠 때 나는 큰 소리예요.", "en": "The loud sound that follows lightning.", "phrase": "Thunder rumbles after the lightning."},
	"PHANTOM": {"category": "MAGIC", "emoji": "👻", "ko": "유령. 보이지 않는 신비한 존재예요.", "en": "A mysterious ghostly figure."},
	"HARDCORE": {"category": "GAME", "emoji": "💀", "ko": "하드코어. 아주 어려운 최고 난이도예요.", "en": "The most difficult level of challenge."},
	"VICTORY": {"category": "GAME", "emoji": "🏆", "ko": "승리. 게임에서 이기는 것이에요.", "en": "Winning the game!"},

	# ---- 테마 스테이지용 보강 단어 ----
	# 단어는 글자 수가 아니라 **주제**로 묶인다([ThemeStages](ThemeStages.gd) 참조).
	# 각 테마가 스테이지 하나를 채울 만큼(최소 WORDS_PER_STAGE개) 단어를 갖도록 채운 것들이다.
	"YELLOW": {"category": "COLOR", "emoji": "🟡", "ko": "노란색. 병아리와 바나나의 색이에요.", "en": "The color of bananas and baby chicks.", "phrase": "A yellow banana looks tasty."},
	"BLACK": {"category": "COLOR", "emoji": "⚫", "ko": "검정색. 밤처럼 어두운 색이에요.", "en": "The darkest color, like the night sky.", "phrase": "A black cat is sleeping."},
	"GREEN": {"category": "COLOR", "emoji": "🟢", "ko": "초록색. 풀과 나뭇잎의 색이에요.", "en": "The color of grass and leaves.", "phrase": "Green leaves cover the tree."},
	"WHITE": {"category": "COLOR", "emoji": "⚪", "ko": "흰색. 눈과 구름의 색이에요.", "en": "The color of snow and clouds.", "phrase": "White snow covers the hill."},
	"TIGER": {"category": "ANIMAL", "emoji": "🐯", "ko": "호랑이. 줄무늬가 있는 힘센 맹수예요.", "en": "A big striped cat, strong and fierce.", "phrase": "A tiger has orange stripes."},
	"SNAKE": {"category": "ANIMAL", "emoji": "🐍", "ko": "뱀. 다리가 없이 기어다니는 동물이에요.", "en": "A long animal with no legs that slithers.", "phrase": "The snake slides through grass."},
	"RACCOON": {"category": "ANIMAL", "emoji": "🦝", "ko": "너구리. 눈가에 검은 무늬가 있는 동물이에요.", "en": "A furry animal with a black mask around its eyes.", "phrase": "A raccoon washes its food."},
	"HAND": {"category": "BODY", "emoji": "✋", "ko": "손. 물건을 쥐고 만질 수 있어요.", "en": "The body part we use to grab and touch.", "phrase": "Wave your hand and say hi."},
	"FOOT": {"category": "BODY", "emoji": "🦶", "ko": "발. 땅을 딛고 서게 해줘요.", "en": "The body part we stand on.", "phrase": "My foot fits this shoe."},
	"HEAD": {"category": "BODY", "emoji": "🧠", "ko": "머리. 생각하고 기억하는 곳이에요.", "en": "The body part we think with.", "phrase": "Wear a helmet on your head."},


	# ---- 테마 균형용 보강 단어 ----
	# 각 테마를 8단어로 맞추기 위해 추가. MACHINE 은 사전에 3단어(ROBOT/CYBORG/ANDROID)뿐이라
	# 예전에는 탈것(JET/ROCKET/SPACESHIP)과 과학(LASER)을 섞어 주제와 단어가 어긋나 있었다.
	"NOSE": {"category": "BODY", "emoji": "👃", "ko": "코. 냄새를 맡는 기관이에요.", "en": "The body part we smell with.", "phrase": "I smell flowers with my nose."},
	"GRAY": {"category": "COLOR", "emoji": "⬜", "ko": "회색. 검정과 흰색의 중간색이에요.", "en": "The color between black and white.", "phrase": "Gray clouds fill the sky."},
	"RAIN": {"category": "NATURE", "emoji": "🌧️", "ko": "비. 하늘에서 떨어지는 물방울이에요.", "en": "Water falling from the clouds.", "phrase": "Rain taps on the window."},
	"GEAR": {"category": "MACHINE", "emoji": "⚙️", "ko": "톱니바퀴. 기계를 돌리는 부품이에요.", "en": "A toothed wheel that turns a machine.", "phrase": "The gear turns inside the clock."},
	"WIRE": {"category": "MACHINE", "emoji": "🔌", "ko": "전선. 전기가 흐르는 줄이에요.", "en": "A thin metal line that carries electricity.", "phrase": "A wire carries power to the lamp."},
	"MOTOR": {"category": "MACHINE", "emoji": "🛠️", "ko": "모터. 힘을 만들어 돌리는 장치예요.", "en": "A device that makes things spin.", "phrase": "The motor spins the tiny fan."},
	"ENGINE": {"category": "MACHINE", "emoji": "🚂", "ko": "엔진. 연료로 힘을 만드는 기계예요.", "en": "A machine that turns fuel into power.", "phrase": "The engine roars and the truck moves."},
	"CIRCUIT": {"category": "MACHINE", "emoji": "💡", "ko": "회로. 전기가 도는 길이에요.", "en": "The path electricity travels along.", "phrase": "Electricity flows through the circuit."},
	# --- 심화 단어 — 테마의 기본 단어를 모두 모은 뒤 하나씩 등장한다(ThemeStages.advanced).
	"FINGER": {"category": "BODY", "emoji": "☝️", "ko": "손가락. 손 끝에 달린 다섯 개예요.", "en": "One of the five parts at the end of your hand.", "phrase": "She points with one finger."},
	"ELBOW": {"category": "BODY", "emoji": "💪", "ko": "팔꿈치. 팔이 접히는 부분이에요.", "en": "The joint in the middle of your arm.", "phrase": "He bent his elbow slowly."},
	"SHOULDER": {"category": "BODY", "emoji": "🧍", "ko": "어깨. 팔이 몸에 붙는 곳이에요.", "en": "The part where your arm joins your body.", "phrase": "A bird sat on his shoulder."},
	"STOMACH": {"category": "BODY", "emoji": "🍽️", "ko": "배. 먹은 음식이 모이는 곳이에요.", "en": "The part of your body that holds food.", "phrase": "My stomach is full now."},
	"DOLPHIN": {"category": "ANIMAL", "emoji": "🐬", "ko": "돌고래. 똑똑하고 헤엄을 잘 쳐요.", "en": "A clever sea animal that jumps out of the water.", "phrase": "A dolphin jumps over the waves."},
	"PENGUIN": {"category": "ANIMAL", "emoji": "🐧", "ko": "펭귄. 날지 못하고 헤엄치는 새예요.", "en": "A black and white bird that swims but cannot fly.", "phrase": "The penguin slides on the ice."},
	"ELEPHANT": {"category": "ANIMAL", "emoji": "🐘", "ko": "코끼리. 긴 코를 가진 가장 큰 동물이에요.", "en": "The biggest land animal, with a long trunk.", "phrase": "An elephant drinks with its trunk."},
	"BUTTERFLY": {"category": "ANIMAL", "emoji": "🦋", "ko": "나비. 알록달록한 날개로 날아다녀요.", "en": "An insect with colorful wings.", "phrase": "A butterfly lands on the flower."},
	"PURPLE": {"category": "COLOR", "emoji": "🟣", "ko": "보라색. 빨강과 파랑을 섞은 색이에요.", "en": "The color you get by mixing red and blue.", "phrase": "She wears a purple scarf."},
	"ORANGE": {"category": "COLOR", "emoji": "🟠", "ko": "주황색. 오렌지 껍질의 색이에요.", "en": "The color of an orange fruit.", "phrase": "The orange sun sets slowly."},
	"SILVER": {"category": "COLOR", "emoji": "🥈", "ko": "은색. 반짝이는 금속의 색이에요.", "en": "The shiny color of metal.", "phrase": "A silver coin shines brightly."},
	"CRIMSON": {"category": "COLOR", "emoji": "🟥", "ko": "진홍색. 아주 진한 빨강이에요.", "en": "A deep, dark shade of red.", "phrase": "The crimson sky glows at dusk."},
	"RIVER": {"category": "NATURE", "emoji": "🏞️", "ko": "강. 물이 흐르는 넓은 길이에요.", "en": "A long line of water flowing to the sea.", "phrase": "The river flows to the sea."},
	"DESERT": {"category": "NATURE", "emoji": "🏜️", "ko": "사막. 비가 거의 오지 않는 모래 땅이에요.", "en": "A dry, sandy place with almost no rain.", "phrase": "The desert is hot and dry."},
	"GLACIER": {"category": "NATURE", "emoji": "🧊", "ko": "빙하. 아주 크고 오래된 얼음덩어리예요.", "en": "A huge, slow-moving river of ice.", "phrase": "The glacier moves very slowly."},
	"RAINBOW": {"category": "NATURE", "emoji": "🌈", "ko": "무지개. 비 온 뒤 하늘에 뜨는 색 띠예요.", "en": "A curve of colors in the sky after rain.", "phrase": "A rainbow appears after the rain."},
	"MAGNET": {"category": "MACHINE", "emoji": "🧲", "ko": "자석. 쇠를 끌어당기는 물건이에요.", "en": "A piece of metal that pulls iron toward it.", "phrase": "The magnet pulls the nail."},
	"BATTERY": {"category": "MACHINE", "emoji": "🔋", "ko": "전지. 전기를 담아 두는 통이에요.", "en": "A box that stores electric power.", "phrase": "The battery powers the robot."},
	"TURBINE": {"category": "MACHINE", "emoji": "🌀", "ko": "터빈. 바람이나 물로 도는 날개예요.", "en": "A wheel that spins with wind or water.", "phrase": "The turbine spins in the wind."},
	"PROPELLER": {"category": "MACHINE", "emoji": "🚁", "ko": "프로펠러. 돌면서 바람을 만드는 날개예요.", "en": "Spinning blades that push air or water.", "phrase": "The propeller spins very fast."},
}


static func get_description(word: String) -> Dictionary:
	var w := word.to_upper()
	if WORD_DATA.has(w):
		return WORD_DATA[w]
	return {"category": "?", "ko": "설명이 없습니다.", "en": "No description available."}


## 단어를 **실제로 사용하는 짧은 영어 문장**을 반환합니다. (없으면 빈 문자열)
##
## 음성 안내는 "The word is black." 같은 설명 문구가 아니라 이 문장을 읽어준다 —
## 단어가 문맥 속에서 어떻게 쓰이는지 들려주는 것이 학습에 낫다는 판단.
## 이 문장이 곧 tools/gen_voice.sh 가 굽는 음성 파일의 대사다.
static func get_phrase(word: String) -> String:
	var w := word.to_upper()
	if WORD_DATA.has(w) and WORD_DATA[w].has("phrase"):
		return String(WORD_DATA[w]["phrase"])
	return ""


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