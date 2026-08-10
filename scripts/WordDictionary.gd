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
	"FLY": {"category": "ANIMAL", "emoji": "🪰", "ko": "파리. 날아다니는 작은 곤충이에요.", "en": "A small flying insect.", "phrase": "A fly lands on the plate."},
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
	# --- 확장 어휘 --- tools/vocab_new.py 에서 생성. 손으로 고치지 말 것.
	# FOOD
	# FRUIT
	# DRINK
	# FAMILY
	# HOUSE
	# SCHOOL
	# CLOTHES
	# SPORT
	# MUSIC
	# JOB
	# CITY
	# VEHICLE
	# WEATHER
	# TIME
	# SHAPE
	# EMOTION
	# SEA
	# INSECT
	# PLANT
	# HEALTH
	"BONE": {"category": "HEALTH", "emoji": "🦴", "ko": "뼈. 몸을 받쳐 주는 단단한 부분이에요.", "en": "A hard white part inside the body.", "phrase": "The dog found a big bone."},
	"PILL": {"category": "HEALTH", "emoji": "💊", "ko": "알약. 물과 함께 삼켜요.", "en": "A small round medicine you swallow.", "phrase": "She takes one pill a day."},
	"MASK": {"category": "HEALTH", "emoji": "😷", "ko": "마스크. 입과 코를 덮어요.", "en": "A cover you wear over your mouth and nose.", "phrase": "He wears a mask on the bus."},
	"COUGH": {"category": "HEALTH", "emoji": "🤧", "ko": "기침. 목이 아플 때 나와요.", "en": "A sudden loud sound from a sore throat.", "phrase": "My cough is getting better."},
	"FEVER": {"category": "HEALTH", "emoji": "🤒", "ko": "열. 몸이 뜨거워지는 증상이에요.", "en": "A body that is hotter than normal.", "phrase": "The baby has a small fever."},
	"TOOTH": {"category": "HEALTH", "emoji": "🦷", "ko": "이. 음식을 씹는 데 써요.", "en": "A hard white part in your mouth for chewing.", "phrase": "One tooth hurts a little."},
	"HEART": {"category": "HEALTH", "emoji": "❤️", "ko": "심장. 가슴에서 쿵쿵 뛰어요.", "en": "The organ that pumps blood in your chest.", "phrase": "I can hear my heart beat."},
	"SYRINGE": {"category": "HEALTH", "emoji": "💉", "ko": "주사기. 약을 몸에 넣어요.", "en": "A tool with a needle used to give medicine.", "phrase": "The nurse holds a syringe."},
	"BANDAGE": {"category": "HEALTH", "emoji": "🩹", "ko": "반창고. 다친 곳에 붙여요.", "en": "A strip you put over a cut.", "phrase": "Put a bandage on your knee."},
	"VITAMIN": {"category": "HEALTH", "emoji": "🍊", "ko": "비타민. 몸에 좋은 영양분이에요.", "en": "Something in food that keeps you healthy.", "phrase": "Fruit is full of vitamin C."},
	"MEDICINE": {"category": "HEALTH", "emoji": "💊", "ko": "약. 아플 때 먹어요.", "en": "Something you take to feel better.", "phrase": "Take your medicine after lunch."},
	"THERMOMETER": {"category": "HEALTH", "emoji": "🌡️", "ko": "체온계. 열을 재는 도구예요.", "en": "A tool that measures how hot something is.", "phrase": "The thermometer shows a fever."},
	# TRAVEL
	"BAG": {"category": "TRAVEL", "emoji": "🎒", "ko": "가방. 짐을 넣어 들고 다녀요.", "en": "Something you carry your things in.", "phrase": "My bag is very heavy."},
	"TENT": {"category": "TRAVEL", "emoji": "⛺", "ko": "텐트. 밖에서 잘 때 쳐요.", "en": "A cloth shelter you sleep in outdoors.", "phrase": "We sleep in a small tent."},
	"VISA": {"category": "TRAVEL", "emoji": "🛂", "ko": "비자. 다른 나라에 들어갈 허가예요.", "en": "Permission to enter another country.", "phrase": "I need a visa for that trip."},
	"BEACH": {"category": "TRAVEL", "emoji": "🏖️", "ko": "해변. 바다 옆 모래밭이에요.", "en": "Sand next to the sea.", "phrase": "The beach is warm today."},
	"TICKET": {"category": "TRAVEL", "emoji": "🎫", "ko": "표. 타거나 들어갈 때 내요.", "en": "A paper that lets you enter or ride.", "phrase": "Keep your ticket in your bag."},
	"CAMERA": {"category": "TRAVEL", "emoji": "📷", "ko": "사진기. 사진을 찍어요.", "en": "A device for taking pictures.", "phrase": "She holds the camera up."},
	"JOURNEY": {"category": "TRAVEL", "emoji": "🧭", "ko": "여정. 긴 여행길이에요.", "en": "A long trip from one place to another.", "phrase": "Our journey starts at dawn."},
	"LUGGAGE": {"category": "TRAVEL", "emoji": "🧳", "ko": "짐. 여행에 가져가는 가방들이에요.", "en": "The bags you take on a trip.", "phrase": "My luggage is still in the car."},
	"PASSPORT": {"category": "TRAVEL", "emoji": "🛂", "ko": "여권. 나라 밖으로 나갈 때 필요해요.", "en": "A book that proves who you are abroad.", "phrase": "Show your passport at the gate."},
	"SOUVENIR": {"category": "TRAVEL", "emoji": "🎁", "ko": "기념품. 여행에서 사 오는 물건이에요.", "en": "Something you buy to remember a place.", "phrase": "I bought a small souvenir."},
	"SUITCASE": {"category": "TRAVEL", "emoji": "🧳", "ko": "여행 가방. 바퀴가 달려 있어요.", "en": "A flat bag with wheels for clothes.", "phrase": "The suitcase will not close."},
	"ADVENTURE": {"category": "TRAVEL", "emoji": "🏔️", "ko": "모험. 신나고 새로운 경험이에요.", "en": "An exciting and unusual experience.", "phrase": "It was a real adventure."},
	# AIRPORT
	"GATE": {"category": "AIRPORT", "emoji": "🛫", "ko": "탑승구. 비행기를 타러 가는 문이에요.", "en": "The door where you get on a plane.", "phrase": "Our gate is number nine."},
	"BELT": {"category": "AIRPORT", "emoji": "🧷", "ko": "안전벨트. 앉으면 매요.", "en": "A strap that holds you in your seat.", "phrase": "Please fasten your belt."},
	"SEAT": {"category": "AIRPORT", "emoji": "💺", "ko": "좌석. 앉는 자리예요.", "en": "A place to sit down.", "phrase": "My seat is by the window."},
	"CABIN": {"category": "AIRPORT", "emoji": "🛩️", "ko": "객실. 비행기 안 사람이 타는 곳이에요.", "en": "The part of a plane where people sit.", "phrase": "The cabin is quiet now."},
	"FLIGHT": {"category": "AIRPORT", "emoji": "✈️", "ko": "비행. 비행기가 가는 길이에요.", "en": "A trip made by plane.", "phrase": "The flight takes two hours."},
	"RUNWAY": {"category": "AIRPORT", "emoji": "🛫", "ko": "활주로. 비행기가 달리는 길이에요.", "en": "The long road a plane rolls on.", "phrase": "The plane waits on the runway."},
	"LANDING": {"category": "AIRPORT", "emoji": "🛬", "ko": "착륙. 비행기가 땅에 내려요.", "en": "The moment a plane touches the ground.", "phrase": "The landing was very smooth."},
	"BOARDING": {"category": "AIRPORT", "emoji": "🎫", "ko": "탑승. 비행기에 올라타요.", "en": "Getting on a plane or ship.", "phrase": "Boarding starts in ten minutes."},
	"TERMINAL": {"category": "AIRPORT", "emoji": "🏢", "ko": "터미널. 공항의 큰 건물이에요.", "en": "The big building at an airport.", "phrase": "We meet at terminal two."},
	"DEPARTURE": {"category": "AIRPORT", "emoji": "🛫", "ko": "출발. 떠나는 것이에요.", "en": "The act of leaving a place.", "phrase": "Check the departure time."},
	"PASSENGER": {"category": "AIRPORT", "emoji": "🧍", "ko": "승객. 타고 가는 사람이에요.", "en": "A person who travels in a vehicle.", "phrase": "Every passenger is seated."},
	"RESERVATION": {"category": "AIRPORT", "emoji": "📋", "ko": "예약. 미리 자리를 잡아 두는 거예요.", "en": "An arrangement made in advance.", "phrase": "I have a reservation for two."},
	# KITCHEN
	"POT": {"category": "KITCHEN", "emoji": "🍲", "ko": "냄비. 국을 끓여요.", "en": "A deep round dish for cooking.", "phrase": "The pot is on the stove."},
	"PAN": {"category": "KITCHEN", "emoji": "🍳", "ko": "프라이팬. 부치거나 볶아요.", "en": "A flat dish for frying food.", "phrase": "Put the egg in the pan."},
	"BOWL": {"category": "KITCHEN", "emoji": "🥣", "ko": "그릇. 둥글고 깊어요.", "en": "A round deep dish for food.", "phrase": "She fills the bowl with soup."},
	"FORK": {"category": "KITCHEN", "emoji": "🍴", "ko": "포크. 찍어서 먹어요.", "en": "A tool with points for picking up food.", "phrase": "Use a fork for the salad."},
	"KNIFE": {"category": "KITCHEN", "emoji": "🔪", "ko": "칼. 자를 때 써요.", "en": "A sharp tool for cutting.", "phrase": "This knife cuts bread well."},
	"SPOON": {"category": "KITCHEN", "emoji": "🥄", "ko": "숟가락. 떠서 먹어요.", "en": "A round tool for eating liquid food.", "phrase": "Stir it with a spoon."},
	"PLATE": {"category": "KITCHEN", "emoji": "🍽️", "ko": "접시. 음식을 담아요.", "en": "A flat dish you put food on.", "phrase": "My plate is already empty."},
	"KETTLE": {"category": "KITCHEN", "emoji": "🫖", "ko": "주전자. 물을 끓여요.", "en": "A pot used to boil water.", "phrase": "The kettle is boiling now."},
	"FRIDGE": {"category": "KITCHEN", "emoji": "🧊", "ko": "냉장고. 음식을 차게 보관해요.", "en": "A cold box that keeps food fresh.", "phrase": "The milk is in the fridge."},
	"BLENDER": {"category": "KITCHEN", "emoji": "🥤", "ko": "믹서. 갈아서 음료를 만들어요.", "en": "A machine that mixes food into liquid.", "phrase": "The blender makes a loud noise."},
	"CUPBOARD": {"category": "KITCHEN", "emoji": "🗄️", "ko": "찬장. 그릇을 넣어 두는 곳이에요.", "en": "A closed shelf for dishes and food.", "phrase": "The cups are in the cupboard."},
	"MICROWAVE": {"category": "KITCHEN", "emoji": "♨️", "ko": "전자레인지. 음식을 빨리 데워요.", "en": "A machine that heats food quickly.", "phrase": "Warm the rice in the microwave."},
	# VEGETABLE
	"PEA": {"category": "VEGETABLE", "emoji": "🫛", "ko": "완두콩. 작고 둥근 초록 콩이에요.", "en": "A small round green seed you eat.", "phrase": "One pea rolled off the plate."},
	"CORN": {"category": "VEGETABLE", "emoji": "🌽", "ko": "옥수수. 노란 알이 줄지어 있어요.", "en": "A tall plant with yellow seeds in rows.", "phrase": "We grill corn in summer."},
	"BEAN": {"category": "VEGETABLE", "emoji": "🫘", "ko": "콩. 껍질 안에 씨가 있어요.", "en": "A seed that grows inside a pod.", "phrase": "Every bean is soft now."},
	"LEEK": {"category": "VEGETABLE", "emoji": "🌿", "ko": "대파. 길고 흰 줄기가 있어요.", "en": "A long white vegetable that tastes like onion.", "phrase": "Cut the leek into rings."},
	"ONION": {"category": "VEGETABLE", "emoji": "🧅", "ko": "양파. 껍질을 벗기면 눈이 매워요.", "en": "A round vegetable with many layers.", "phrase": "This onion makes me cry."},
	"GARLIC": {"category": "VEGETABLE", "emoji": "🧄", "ko": "마늘. 향이 아주 강해요.", "en": "A small strong-smelling bulb.", "phrase": "Add garlic to the soup."},
	"CARROT": {"category": "VEGETABLE", "emoji": "🥕", "ko": "당근. 주황색이고 길어요.", "en": "A long orange root you can eat.", "phrase": "The rabbit eats a carrot."},
	"PEPPER": {"category": "VEGETABLE", "emoji": "🌶️", "ko": "고추. 매운맛이 나요.", "en": "A vegetable that can taste hot.", "phrase": "That red pepper is very hot."},
	"POTATO": {"category": "VEGETABLE", "emoji": "🥔", "ko": "감자. 땅속에서 자라요.", "en": "A round root that grows under the ground.", "phrase": "Bake the potato for an hour."},
	"SPINACH": {"category": "VEGETABLE", "emoji": "🥬", "ko": "시금치. 초록 잎을 먹어요.", "en": "A green leaf vegetable full of iron.", "phrase": "Spinach makes you strong."},
	"CABBAGE": {"category": "VEGETABLE", "emoji": "🥬", "ko": "양배추. 잎이 겹겹이 싸여 있어요.", "en": "A round vegetable with tight leaves.", "phrase": "She cuts the cabbage thin."},
	"CUCUMBER": {"category": "VEGETABLE", "emoji": "🥒", "ko": "오이. 길고 시원한 맛이에요.", "en": "A long green vegetable that tastes cool.", "phrase": "The cucumber is fresh and cold."},
	# BIRD
	"HEN": {"category": "BIRD", "emoji": "🐔", "ko": "암탉. 달걀을 낳아요.", "en": "A female chicken that lays eggs.", "phrase": "The hen sits on her eggs."},
	"DUCK": {"category": "BIRD", "emoji": "🦆", "ko": "오리. 물에서 헤엄쳐요.", "en": "A water bird with a flat beak.", "phrase": "A duck swims in the pond."},
	"CROW": {"category": "BIRD", "emoji": "🐦", "ko": "까마귀. 검고 울음소리가 커요.", "en": "A big black bird with a loud call.", "phrase": "The crow sits on the wire."},
	"DOVE": {"category": "BIRD", "emoji": "🕊️", "ko": "비둘기. 평화를 뜻해요.", "en": "A white bird that means peace.", "phrase": "A dove lands on the roof."},
	"SWAN": {"category": "BIRD", "emoji": "🦢", "ko": "백조. 목이 길고 하얘요.", "en": "A large white bird with a long neck.", "phrase": "The swan glides on the lake."},
	"EAGLE": {"category": "BIRD", "emoji": "🦅", "ko": "독수리. 높이 날고 눈이 좋아요.", "en": "A large bird that flies very high.", "phrase": "The eagle watches from above."},
	"ROBIN": {"category": "BIRD", "emoji": "🐦", "ko": "울새. 가슴이 붉어요.", "en": "A small bird with a red chest.", "phrase": "A robin sings every morning."},
	"PARROT": {"category": "BIRD", "emoji": "🦜", "ko": "앵무새. 말을 따라 해요.", "en": "A colorful bird that copies words.", "phrase": "My parrot says my name."},
	"TURKEY": {"category": "BIRD", "emoji": "🦃", "ko": "칠면조. 크고 꼬리를 펴요.", "en": "A large bird with a wide tail.", "phrase": "The turkey spreads its tail."},
	"PEACOCK": {"category": "BIRD", "emoji": "🦚", "ko": "공작. 꼬리가 아주 화려해요.", "en": "A bird with a huge bright tail.", "phrase": "The peacock opens its tail."},
	"FLAMINGO": {"category": "BIRD", "emoji": "🦩", "ko": "플라밍고. 분홍색이고 다리가 길어요.", "en": "A pink bird that stands on one leg.", "phrase": "The flamingo stands very still."},
	"WOODPECKER": {"category": "BIRD", "emoji": "🪶", "ko": "딱따구리. 나무를 두드려요.", "en": "A bird that knocks holes in trees.", "phrase": "The woodpecker taps the old tree."},
	# TREE
	"ELM": {"category": "TREE", "emoji": "🌳", "ko": "느티나무. 잎이 넓게 퍼져요.", "en": "A tall shade tree with wide leaves.", "phrase": "An old elm stands by the road."},
	"BARK": {"category": "TREE", "emoji": "🪵", "ko": "나무껍질. 줄기를 덮고 있어요.", "en": "The hard cover on a tree trunk.", "phrase": "The bark feels rough."},
	"TWIG": {"category": "TREE", "emoji": "🌿", "ko": "잔가지. 아주 얇은 가지예요.", "en": "A very thin branch.", "phrase": "A twig snapped under my shoe."},
	"PALM": {"category": "TREE", "emoji": "🌴", "ko": "야자나무. 더운 곳에서 자라요.", "en": "A tall tree with big leaves on top.", "phrase": "One palm leans over the sand."},
	"MAPLE": {"category": "TREE", "emoji": "🍁", "ko": "단풍나무. 가을에 잎이 붉어져요.", "en": "A tree whose leaves turn red in autumn.", "phrase": "The maple turns red in fall."},
	"BIRCH": {"category": "TREE", "emoji": "🌲", "ko": "자작나무. 껍질이 하얘요.", "en": "A tree with thin white bark.", "phrase": "The birch shines in the snow."},
	"BRANCH": {"category": "TREE", "emoji": "🌿", "ko": "가지. 줄기에서 뻗어 나와요.", "en": "A part that grows out from a trunk.", "phrase": "A bird sits on the branch."},
	"WILLOW": {"category": "TREE", "emoji": "🌾", "ko": "버드나무. 가지가 늘어져요.", "en": "A tree with long hanging branches.", "phrase": "The willow bends to the water."},
	"FOREST": {"category": "TREE", "emoji": "🌲", "ko": "숲. 나무가 아주 많은 곳이에요.", "en": "A large area covered with trees.", "phrase": "The forest is dark and cool."},
	"ORCHARD": {"category": "TREE", "emoji": "🍎", "ko": "과수원. 과일나무를 기르는 밭이에요.", "en": "A field where fruit trees grow.", "phrase": "The orchard smells of apples."},
	"CHESTNUT": {"category": "TREE", "emoji": "🌰", "ko": "밤. 가시 껍질 안에 들어 있어요.", "en": "A brown nut inside a spiky shell.", "phrase": "He roasts one chestnut."},
	"EUCALYPTUS": {"category": "TREE", "emoji": "🌿", "ko": "유칼립투스. 잎에서 시원한 향이 나요.", "en": "A tree with leaves that smell fresh.", "phrase": "Koalas eat eucalyptus leaves."},
	# FLOWER
	"BUD": {"category": "FLOWER", "emoji": "🌷", "ko": "꽃봉오리. 아직 피지 않은 꽃이에요.", "en": "A flower before it opens.", "phrase": "A tiny bud opened today."},
	"ROSE": {"category": "FLOWER", "emoji": "🌹", "ko": "장미. 향이 좋고 가시가 있어요.", "en": "A flower with a sweet smell and thorns.", "phrase": "He gives her one rose."},
	"LILY": {"category": "FLOWER", "emoji": "🪷", "ko": "백합. 크고 향이 진해요.", "en": "A large flower with a strong smell.", "phrase": "The lily floats on the pond."},
	"IRIS": {"category": "FLOWER", "emoji": "🌸", "ko": "아이리스. 보라색 잎이 펼쳐져요.", "en": "A flower with wide purple petals.", "phrase": "The iris blooms by the gate."},
	"PETAL": {"category": "FLOWER", "emoji": "🌸", "ko": "꽃잎. 꽃의 얇은 잎이에요.", "en": "One thin colored part of a flower.", "phrase": "A petal fell on the desk."},
	"DAISY": {"category": "FLOWER", "emoji": "🌼", "ko": "데이지. 가운데가 노랗고 작아요.", "en": "A small flower with a yellow center.", "phrase": "She picks a white daisy."},
	"POLLEN": {"category": "FLOWER", "emoji": "🐝", "ko": "꽃가루. 벌이 옮겨 줘요.", "en": "Yellow dust that bees carry.", "phrase": "Pollen covers the window."},
	"ORCHID": {"category": "FLOWER", "emoji": "🪻", "ko": "난초. 모양이 특이하고 귀해요.", "en": "An unusual flower with a strange shape.", "phrase": "The orchid needs little water."},
	"BLOSSOM": {"category": "FLOWER", "emoji": "🌸", "ko": "만개한 꽃. 나무에 가득 피어요.", "en": "A flower on a fruit tree.", "phrase": "The blossom covers the branch."},
	"LAVENDER": {"category": "FLOWER", "emoji": "💜", "ko": "라벤더. 연보라색이고 향이 좋아요.", "en": "A purple plant with a calm smell.", "phrase": "Lavender helps me sleep."},
	"CARNATION": {"category": "FLOWER", "emoji": "🌺", "ko": "카네이션. 감사할 때 드려요.", "en": "A ruffled flower given as thanks.", "phrase": "I give my mother a carnation."},
	"CHRYSANTHEMUM": {"category": "FLOWER", "emoji": "🌼", "ko": "국화. 가을에 피는 꽃이에요.", "en": "A round autumn flower with many petals.", "phrase": "The chrysanthemum blooms in fall."},
	# TOOL
	"SAW": {"category": "TOOL", "emoji": "🪚", "ko": "톱. 나무를 자를 때 써요.", "en": "A tool with teeth for cutting wood.", "phrase": "The saw cuts through the board."},
	"NAIL": {"category": "TOOL", "emoji": "🔨", "ko": "못. 망치로 박아요.", "en": "A thin metal pin you hammer in.", "phrase": "Hit the nail once more."},
	"BOLT": {"category": "TOOL", "emoji": "🔩", "ko": "볼트. 너트와 짝을 이뤄요.", "en": "A thick metal pin with a thread.", "phrase": "Tighten the bolt by hand."},
	"TAPE": {"category": "TOOL", "emoji": "📏", "ko": "테이프. 붙이거나 길이를 재요.", "en": "A long strip used to stick or measure.", "phrase": "Pull the tape a little more."},
	"DRILL": {"category": "TOOL", "emoji": "🪛", "ko": "드릴. 구멍을 뚫어요.", "en": "A tool that makes round holes.", "phrase": "The drill is very loud."},
	"SCREW": {"category": "TOOL", "emoji": "🔩", "ko": "나사. 돌려서 박아요.", "en": "A metal pin you turn to fasten.", "phrase": "One screw is missing."},
	"HAMMER": {"category": "TOOL", "emoji": "🔨", "ko": "망치. 두드려서 박아요.", "en": "A heavy tool used to hit nails.", "phrase": "He swings the hammer down."},
	"WRENCH": {"category": "TOOL", "emoji": "🔧", "ko": "렌치. 볼트를 조여요.", "en": "A tool for turning bolts.", "phrase": "Hand me the small wrench."},
	"LADDER": {"category": "TOOL", "emoji": "🪜", "ko": "사다리. 높은 곳에 올라가요.", "en": "Steps you climb to reach high places.", "phrase": "The ladder leans on the wall."},
	"SHOVEL": {"category": "TOOL", "emoji": "🪓", "ko": "삽. 땅을 파요.", "en": "A tool for digging soil.", "phrase": "He digs with a wide shovel."},
	"TOOLBOX": {"category": "TOOL", "emoji": "🧰", "ko": "공구함. 도구를 담아 두어요.", "en": "A box that holds tools.", "phrase": "The toolbox is under the bench."},
	"SCREWDRIVER": {"category": "TOOL", "emoji": "🪛", "ko": "드라이버. 나사를 돌려요.", "en": "A tool for turning screws.", "phrase": "I need a thin screwdriver."},
	# MONEY
	"COIN": {"category": "MONEY", "emoji": "🪙", "ko": "동전. 둥글고 단단한 돈이에요.", "en": "A small round piece of metal money.", "phrase": "One coin fell on the floor."},
	"CASH": {"category": "MONEY", "emoji": "💵", "ko": "현금. 종이돈과 동전이에요.", "en": "Money in notes and coins.", "phrase": "I pay in cash today."},
	"BILL": {"category": "MONEY", "emoji": "💴", "ko": "지폐. 종이로 된 돈이에요.", "en": "A paper note of money.", "phrase": "He folds the bill twice."},
	"SAVE": {"category": "MONEY", "emoji": "🏦", "ko": "저축하다. 돈을 모아 둬요.", "en": "To keep money for later.", "phrase": "I save a little each week."},
	"PRICE": {"category": "MONEY", "emoji": "🏷️", "ko": "값. 물건이 얼마인지예요.", "en": "How much something costs.", "phrase": "The price is too high."},
	"WALLET": {"category": "MONEY", "emoji": "👛", "ko": "지갑. 돈을 넣어 다녀요.", "en": "A small case for money.", "phrase": "My wallet is in the bag."},
	"CREDIT": {"category": "MONEY", "emoji": "💳", "ko": "신용. 나중에 내겠다는 약속이에요.", "en": "A promise to pay later.", "phrase": "She buys it on credit."},
	"BUDGET": {"category": "MONEY", "emoji": "📊", "ko": "예산. 쓸 돈을 미리 정해요.", "en": "A plan for how to spend money.", "phrase": "Our budget is very tight."},
	"INCOME": {"category": "MONEY", "emoji": "💰", "ko": "수입. 벌어들이는 돈이에요.", "en": "The money you earn.", "phrase": "His income grew this year."},
	"PAYMENT": {"category": "MONEY", "emoji": "🧾", "ko": "지불. 돈을 내는 거예요.", "en": "Money given for something.", "phrase": "The payment is due today."},
	"DISCOUNT": {"category": "MONEY", "emoji": "🏷️", "ko": "할인. 값을 깎아 줘요.", "en": "An amount taken off the price.", "phrase": "They give a small discount."},
	"INVESTMENT": {"category": "MONEY", "emoji": "📈", "ko": "투자. 늘리려고 돈을 넣어요.", "en": "Money put in to grow more money.", "phrase": "It was a smart investment."},
	# FARM
	"COW": {"category": "FARM", "emoji": "🐄", "ko": "소. 우유를 줘요.", "en": "A large farm animal that gives milk.", "phrase": "The cow eats green grass."},
	"PIG": {"category": "FARM", "emoji": "🐖", "ko": "돼지. 코가 넓적해요.", "en": "A pink farm animal with a flat nose.", "phrase": "A pig sleeps in the mud."},
	"HAY": {"category": "FARM", "emoji": "🌾", "ko": "건초. 말린 풀이에요.", "en": "Dry grass fed to animals.", "phrase": "The hay smells sweet."},
	"BARN": {"category": "FARM", "emoji": "🏚️", "ko": "헛간. 동물과 짐을 두는 곳이에요.", "en": "A big farm building for animals.", "phrase": "The horses go in the barn."},
	"GOAT": {"category": "FARM", "emoji": "🐐", "ko": "염소. 뿔이 있고 잘 올라가요.", "en": "A farm animal with horns that climbs.", "phrase": "The goat climbs the rock."},
	"SHEEP": {"category": "FARM", "emoji": "🐑", "ko": "양. 털이 두껍고 폭신해요.", "en": "A farm animal with thick wool.", "phrase": "We count every sheep."},
	"HORSE": {"category": "FARM", "emoji": "🐴", "ko": "말. 빠르게 달려요.", "en": "A large animal people ride.", "phrase": "The horse runs very fast."},
	"FENCE": {"category": "FARM", "emoji": "🚧", "ko": "울타리. 밭이나 마당을 둘러요.", "en": "A wall of wood or wire around land.", "phrase": "The fence needs a new board."},
	"HARVEST": {"category": "FARM", "emoji": "🌾", "ko": "수확. 다 자란 것을 거둬요.", "en": "Gathering crops when they are ready.", "phrase": "The harvest starts in autumn."},
	"PASTURE": {"category": "FARM", "emoji": "🐄", "ko": "목초지. 동물이 풀을 뜯는 들이에요.", "en": "A field where animals eat grass.", "phrase": "The cows walk to the pasture."},
	"TRACTOR": {"category": "FARM", "emoji": "🚜", "ko": "트랙터. 밭을 가는 기계예요.", "en": "A strong machine that pulls farm tools.", "phrase": "The tractor turns the soil."},
	"SCARECROW": {"category": "FARM", "emoji": "🎃", "ko": "허수아비. 새를 쫓아요.", "en": "A figure that frightens birds away.", "phrase": "The scarecrow wears an old hat."},
	# DESSERT
	"PIE": {"category": "DESSERT", "emoji": "🥧", "ko": "파이. 속을 채워 구워요.", "en": "A baked dish with filling inside.", "phrase": "The apple pie is warm."},
	"JAM": {"category": "DESSERT", "emoji": "🍯", "ko": "잼. 과일을 졸여 만들어요.", "en": "Sweet fruit spread for bread.", "phrase": "Spread jam on the toast."},
	"CAKE": {"category": "DESSERT", "emoji": "🍰", "ko": "케이크. 생일에 먹어요.", "en": "A soft sweet food for parties.", "phrase": "We cut the cake together."},
	"TART": {"category": "DESSERT", "emoji": "🥧", "ko": "타르트. 얇은 껍질에 과일을 올려요.", "en": "A small open pie with fruit on top.", "phrase": "This tart has fresh berries."},
	"HONEY": {"category": "DESSERT", "emoji": "🍯", "ko": "꿀. 벌이 만든 단 액체예요.", "en": "A sweet liquid made by bees.", "phrase": "Honey drips from the spoon."},
	"CANDY": {"category": "DESSERT", "emoji": "🍬", "ko": "사탕. 입에서 천천히 녹아요.", "en": "A small hard sweet you suck.", "phrase": "One candy is left."},
	"DONUT": {"category": "DESSERT", "emoji": "🍩", "ko": "도넛. 가운데 구멍이 있어요.", "en": "A round sweet cake with a hole.", "phrase": "The donut is still warm."},
	"COOKIE": {"category": "DESSERT", "emoji": "🍪", "ko": "쿠키. 바삭하게 구운 과자예요.", "en": "A small flat sweet baked crisp.", "phrase": "She bakes one more cookie."},
	"WAFFLE": {"category": "DESSERT", "emoji": "🧇", "ko": "와플. 네모 무늬가 있어요.", "en": "A crisp cake with square holes.", "phrase": "The waffle holds the syrup."},
	"PUDDING": {"category": "DESSERT", "emoji": "🍮", "ko": "푸딩. 부드럽게 떠먹어요.", "en": "A soft sweet food eaten with a spoon.", "phrase": "The pudding wobbles a little."},
	"BROWNIE": {"category": "DESSERT", "emoji": "🍫", "ko": "브라우니. 초콜릿을 넣어 구워요.", "en": "A dense chocolate cake square.", "phrase": "One brownie is enough."},
	"ICECREAM": {"category": "DESSERT", "emoji": "🍨", "ko": "아이스크림. 차갑고 달아요.", "en": "A frozen sweet food.", "phrase": "My icecream melts too fast."},
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