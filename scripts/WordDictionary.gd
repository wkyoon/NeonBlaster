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
	"EGG": {"category": "FOOD", "emoji": "🥚", "ko": "달걀. 껍질 안에 노른자가 있어요.", "en": "A round food with a shell and a yellow center.", "phrase": "I ate an egg for breakfast."},
	"RICE": {"category": "FOOD", "emoji": "🍚", "ko": "쌀밥. 밥그릇에 담아 먹어요.", "en": "Small white grains cooked and eaten warm.", "phrase": "She eats rice every day."},
	"MEAT": {"category": "FOOD", "emoji": "🍖", "ko": "고기. 구워서 먹는 음식이에요.", "en": "Food that comes from animals.", "phrase": "The meat is on the grill."},
	"SOUP": {"category": "FOOD", "emoji": "🍲", "ko": "국. 따뜻하게 떠먹는 음식이에요.", "en": "A warm liquid food you eat with a spoon.", "phrase": "The soup is very hot."},
	"BREAD": {"category": "FOOD", "emoji": "🍞", "ko": "빵. 밀가루로 구운 음식이에요.", "en": "A baked food made from flour.", "phrase": "He cuts the bread slowly."},
	"PIZZA": {"category": "FOOD", "emoji": "🍕", "ko": "피자. 둥글고 치즈가 올라가요.", "en": "A round flat food covered with cheese.", "phrase": "We share a big pizza."},
	"SALAD": {"category": "FOOD", "emoji": "🥗", "ko": "샐러드. 채소를 섞어 먹어요.", "en": "A cold mix of fresh vegetables.", "phrase": "The salad tastes fresh."},
	"CHEESE": {"category": "FOOD", "emoji": "🧀", "ko": "치즈. 우유로 만든 노란 음식이에요.", "en": "A yellow food made from milk.", "phrase": "Cheese melts on the bread."},
	"NOODLE": {"category": "FOOD", "emoji": "🍜", "ko": "국수. 길고 가는 면이에요.", "en": "A long thin strip of food made from flour.", "phrase": "The noodle is long and soft."},
	"BUTTER": {"category": "FOOD", "emoji": "🧈", "ko": "버터. 빵에 발라 먹어요.", "en": "A soft yellow food you spread on bread.", "phrase": "Butter melts on warm bread."},
	"SANDWICH": {"category": "FOOD", "emoji": "🥪", "ko": "샌드위치. 빵 사이에 재료를 넣어요.", "en": "Food put between two slices of bread.", "phrase": "He makes a big sandwich."},
	"CHOCOLATE": {"category": "FOOD", "emoji": "🍫", "ko": "초콜릿. 달고 갈색인 간식이에요.", "en": "A sweet brown treat that melts easily.", "phrase": "The chocolate melts in my hand."},
	# FRUIT
	"FIG": {"category": "FRUIT", "emoji": "🫒", "ko": "무화과. 작고 달콤한 과일이에요.", "en": "A small sweet fruit with many seeds.", "phrase": "The fig is soft and sweet."},
	"KIWI": {"category": "FRUIT", "emoji": "🥝", "ko": "키위. 속이 초록색인 과일이에요.", "en": "A small fruit that is green inside.", "phrase": "The kiwi is green inside."},
	"PEAR": {"category": "FRUIT", "emoji": "🍐", "ko": "배. 아삭하고 물이 많아요.", "en": "A sweet juicy fruit shaped like a bell.", "phrase": "This pear is very juicy."},
	"PLUM": {"category": "FRUIT", "emoji": "🍑", "ko": "자두. 작고 새콤한 과일이에요.", "en": "A small round fruit with a stone inside.", "phrase": "The plum tastes a bit sour."},
	"APPLE": {"category": "FRUIT", "emoji": "🍎", "ko": "사과. 빨갛고 아삭한 과일이에요.", "en": "A round red fruit that is crisp to bite.", "phrase": "She bites a red apple."},
	"GRAPE": {"category": "FRUIT", "emoji": "🍇", "ko": "포도. 송이로 달린 작은 열매예요.", "en": "A small round fruit that grows in bunches.", "phrase": "The grape is small and sweet."},
	"LEMON": {"category": "FRUIT", "emoji": "🍋", "ko": "레몬. 아주 신 노란 과일이에요.", "en": "A yellow fruit with a very sour taste.", "phrase": "The lemon is very sour."},
	"PEACH": {"category": "FRUIT", "emoji": "🍑", "ko": "복숭아. 겉에 솜털이 있어요.", "en": "A soft fruit with fuzzy skin.", "phrase": "The peach smells sweet."},
	"BANANA": {"category": "FRUIT", "emoji": "🍌", "ko": "바나나. 길고 노란 과일이에요.", "en": "A long yellow fruit you peel.", "phrase": "He peels a yellow banana."},
	"CHERRY": {"category": "FRUIT", "emoji": "🍒", "ko": "체리. 작고 빨간 열매예요.", "en": "A small red fruit with a stone inside.", "phrase": "A cherry hangs on the tree."},
	"AVOCADO": {"category": "FRUIT", "emoji": "🥑", "ko": "아보카도. 초록색이고 부드러워요.", "en": "A green fruit that is soft and creamy.", "phrase": "The avocado is soft inside."},
	"PINEAPPLE": {"category": "FRUIT", "emoji": "🍍", "ko": "파인애플. 껍질이 거칠어요.", "en": "A large fruit with rough skin and sweet flesh.", "phrase": "The pineapple has rough skin."},
	# DRINK
	"TEA": {"category": "DRINK", "emoji": "🍵", "ko": "차. 따뜻하게 우려 마셔요.", "en": "A hot drink made from leaves in water.", "phrase": "She drinks hot tea."},
	"MILK": {"category": "DRINK", "emoji": "🥛", "ko": "우유. 하얗고 고소해요.", "en": "A white drink that comes from cows.", "phrase": "The milk is cold and white."},
	"SODA": {"category": "DRINK", "emoji": "🥤", "ko": "탄산음료. 톡 쏘는 맛이에요.", "en": "A sweet drink with bubbles in it.", "phrase": "The soda has many bubbles."},
	"WINE": {"category": "DRINK", "emoji": "🍷", "ko": "포도주. 포도로 만든 어른 음료예요.", "en": "A drink made from grapes.", "phrase": "Wine is made from grapes."},
	"JUICE": {"category": "DRINK", "emoji": "🧃", "ko": "주스. 과일을 짜서 만들어요.", "en": "A drink squeezed from fruit.", "phrase": "I drink orange juice."},
	"WATER": {"category": "DRINK", "emoji": "💧", "ko": "물. 가장 중요한 음료예요.", "en": "The clear drink our body needs most.", "phrase": "Please give me some water."},
	"COCOA": {"category": "DRINK", "emoji": "☕", "ko": "코코아. 달고 따뜻한 음료예요.", "en": "A sweet warm brown drink.", "phrase": "The cocoa is warm and sweet."},
	"COFFEE": {"category": "DRINK", "emoji": "☕", "ko": "커피. 쓰고 진한 음료예요.", "en": "A dark bitter drink that wakes you up.", "phrase": "He drinks coffee every morning."},
	"NECTAR": {"category": "DRINK", "emoji": "🍯", "ko": "꽃꿀. 벌이 모으는 달콤한 즙이에요.", "en": "The sweet liquid inside flowers.", "phrase": "Bees collect sweet nectar."},
	"YOGURT": {"category": "DRINK", "emoji": "🥣", "ko": "요구르트. 우유를 발효한 음식이에요.", "en": "A thick food made from sour milk.", "phrase": "The yogurt tastes sour."},
	"LEMONADE": {"category": "DRINK", "emoji": "🍋", "ko": "레모네이드. 레몬으로 만든 음료예요.", "en": "A cold drink made from lemons and sugar.", "phrase": "We sell cold lemonade."},
	"SMOOTHIE": {"category": "DRINK", "emoji": "🥤", "ko": "스무디. 과일을 갈아 만든 음료예요.", "en": "A thick drink made from blended fruit.", "phrase": "The smoothie is thick and cold."},
	# FAMILY
	"MOM": {"category": "FAMILY", "emoji": "👩", "ko": "엄마. 나를 낳아 주신 분이에요.", "en": "The woman who is your parent.", "phrase": "My mom reads me a book."},
	"DAD": {"category": "FAMILY", "emoji": "👨", "ko": "아빠. 나를 키워 주신 분이에요.", "en": "The man who is your parent.", "phrase": "My dad drives the car."},
	"SON": {"category": "FAMILY", "emoji": "👦", "ko": "아들. 부모의 남자 아이예요.", "en": "A boy child of a parent.", "phrase": "Their son is very tall."},
	"AUNT": {"category": "FAMILY", "emoji": "👩‍🦰", "ko": "이모나 고모. 부모의 자매예요.", "en": "The sister of your mother or father.", "phrase": "My aunt lives near us."},
	"BABY": {"category": "FAMILY", "emoji": "👶", "ko": "아기. 아주 어린 아이예요.", "en": "A very young child.", "phrase": "The baby is sleeping now."},
	"UNCLE": {"category": "FAMILY", "emoji": "🧔", "ko": "삼촌. 부모의 형제예요.", "en": "The brother of your mother or father.", "phrase": "My uncle tells funny stories."},
	"SISTER": {"category": "FAMILY", "emoji": "👧", "ko": "여자 형제예요.", "en": "A girl with the same parents as you.", "phrase": "My sister plays the piano."},
	"FATHER": {"category": "FAMILY", "emoji": "👨‍🦱", "ko": "아버지. 아빠를 부르는 말이에요.", "en": "Another word for your dad.", "phrase": "His father works at night."},
	"COUSIN": {"category": "FAMILY", "emoji": "🧑", "ko": "사촌. 삼촌의 아이예요.", "en": "The child of your aunt or uncle.", "phrase": "My cousin visits every summer."},
	"MOTHER": {"category": "FAMILY", "emoji": "👩‍🦳", "ko": "어머니. 엄마를 부르는 말이에요.", "en": "Another word for your mom.", "phrase": "Her mother bakes fresh bread."},
	"BROTHER": {"category": "FAMILY", "emoji": "👦", "ko": "남자 형제예요.", "en": "A boy with the same parents as you.", "phrase": "My brother rides a bike."},
	"DAUGHTER": {"category": "FAMILY", "emoji": "👧", "ko": "딸. 부모의 여자 아이예요.", "en": "A girl child of a parent.", "phrase": "Their daughter sings very well."},
	# HOUSE
	"BED": {"category": "HOUSE", "emoji": "🛏️", "ko": "침대. 잠을 자는 곳이에요.", "en": "The furniture you sleep on.", "phrase": "I sleep in a soft bed."},
	"CUP": {"category": "HOUSE", "emoji": "🥤", "ko": "컵. 마실 것을 담아요.", "en": "A small container for drinking.", "phrase": "The cup is on the table."},
	"DOOR": {"category": "HOUSE", "emoji": "🚪", "ko": "문. 방을 드나드는 곳이에요.", "en": "The part of a wall you open to go through.", "phrase": "Please close the door."},
	"LAMP": {"category": "HOUSE", "emoji": "💡", "ko": "등. 어두울 때 켜요.", "en": "A light you turn on in a dark room.", "phrase": "The lamp lights the room."},
	"SOFA": {"category": "HOUSE", "emoji": "🛋️", "ko": "소파. 여럿이 앉는 의자예요.", "en": "A long soft seat for a few people.", "phrase": "We sit on the sofa."},
	"CHAIR": {"category": "HOUSE", "emoji": "🪑", "ko": "의자. 한 사람이 앉아요.", "en": "A seat for one person.", "phrase": "He pulls out a chair."},
	"TABLE": {"category": "HOUSE", "emoji": "🍽️", "ko": "탁자. 물건을 올려 두어요.", "en": "A flat surface with legs to put things on.", "phrase": "Books are on the table."},
	"WINDOW": {"category": "HOUSE", "emoji": "🪟", "ko": "창문. 밖을 볼 수 있어요.", "en": "An opening in a wall with glass.", "phrase": "Open the window for air."},
	"MIRROR": {"category": "HOUSE", "emoji": "🪞", "ko": "거울. 내 모습을 비춰요.", "en": "A glass that shows your own face.", "phrase": "She looks in the mirror."},
	"PILLOW": {"category": "HOUSE", "emoji": "🛏️", "ko": "베개. 머리를 받쳐요.", "en": "A soft bag you rest your head on.", "phrase": "The pillow is very soft."},
	"BLANKET": {"category": "HOUSE", "emoji": "🧣", "ko": "담요. 몸을 덮어 따뜻하게 해요.", "en": "A warm cover you use in bed.", "phrase": "He pulls up the blanket."},
	"FURNITURE": {"category": "HOUSE", "emoji": "🪑", "ko": "가구. 집 안의 큰 물건들이에요.", "en": "The large things inside a room.", "phrase": "The furniture is made of wood."},
	# SCHOOL
	"PEN": {"category": "SCHOOL", "emoji": "🖊️", "ko": "펜. 잉크로 글씨를 써요.", "en": "A tool that writes with ink.", "phrase": "I write with a blue pen."},
	"BOOK": {"category": "SCHOOL", "emoji": "📕", "ko": "책. 글이 담긴 물건이에요.", "en": "Pages with words bound together.", "phrase": "She reads a thick book."},
	"DESK": {"category": "SCHOOL", "emoji": "🪑", "ko": "책상. 앉아서 공부하는 곳이에요.", "en": "A table you study at.", "phrase": "My desk is near the window."},
	"NOTE": {"category": "SCHOOL", "emoji": "📝", "ko": "쪽지. 짧게 적어 두는 글이에요.", "en": "A short piece of writing.", "phrase": "He writes a quick note."},
	"CHALK": {"category": "SCHOOL", "emoji": "🖍️", "ko": "분필. 칠판에 쓰는 도구예요.", "en": "A white stick for writing on a board.", "phrase": "The chalk is white and dusty."},
	"PAPER": {"category": "SCHOOL", "emoji": "📄", "ko": "종이. 글을 쓰는 얇은 것이에요.", "en": "A thin flat sheet you write on.", "phrase": "Write it on this paper."},
	"RULER": {"category": "SCHOOL", "emoji": "📏", "ko": "자. 길이를 재는 도구예요.", "en": "A tool for measuring length.", "phrase": "Use a ruler to draw lines."},
	"PENCIL": {"category": "SCHOOL", "emoji": "✏️", "ko": "연필. 지울 수 있는 필기구예요.", "en": "A writing tool you can erase.", "phrase": "Sharpen your pencil first."},
	"ERASER": {"category": "SCHOOL", "emoji": "🧽", "ko": "지우개. 쓴 것을 지워요.", "en": "A tool that removes pencil marks.", "phrase": "The eraser removes the mistake."},
	"TEACHER": {"category": "SCHOOL", "emoji": "👩‍🏫", "ko": "선생님. 가르쳐 주는 분이에요.", "en": "A person who teaches students.", "phrase": "Our teacher explains the lesson."},
	"STUDENT": {"category": "SCHOOL", "emoji": "🧑‍🎓", "ko": "학생. 배우는 사람이에요.", "en": "A person who learns at school.", "phrase": "Every student has a book."},
	"CLASSROOM": {"category": "SCHOOL", "emoji": "🏫", "ko": "교실. 수업을 하는 방이에요.", "en": "The room where lessons happen.", "phrase": "The classroom is very quiet."},
	# CLOTHES
	"CAP": {"category": "CLOTHES", "emoji": "🧢", "ko": "모자. 챙이 달린 모자예요.", "en": "A soft hat with a curved front.", "phrase": "He wears a blue cap."},
	"HAT": {"category": "CLOTHES", "emoji": "👒", "ko": "모자. 머리에 쓰는 것이에요.", "en": "Something you wear on your head.", "phrase": "Her hat blocks the sun."},
	"COAT": {"category": "CLOTHES", "emoji": "🧥", "ko": "외투. 추울 때 겉에 입어요.", "en": "A warm piece of clothing for outside.", "phrase": "Put on your warm coat."},
	"SHOE": {"category": "CLOTHES", "emoji": "👟", "ko": "신발. 발에 신어요.", "en": "Something you wear on your foot.", "phrase": "My shoe is too small."},
	"SOCK": {"category": "CLOTHES", "emoji": "🧦", "ko": "양말. 신발 안에 신어요.", "en": "Soft clothing for your foot.", "phrase": "One sock is missing."},
	"DRESS": {"category": "CLOTHES", "emoji": "👗", "ko": "원피스. 한 벌로 된 옷이에요.", "en": "A one-piece garment worn by girls.", "phrase": "She wears a red dress."},
	"SHIRT": {"category": "CLOTHES", "emoji": "👕", "ko": "셔츠. 윗옷이에요.", "en": "Clothing for the top of your body.", "phrase": "His shirt has blue stripes."},
	"SKIRT": {"category": "CLOTHES", "emoji": "👚", "ko": "치마. 아래에 입는 옷이에요.", "en": "Clothing that hangs from the waist.", "phrase": "The skirt is very long."},
	"JACKET": {"category": "CLOTHES", "emoji": "🧥", "ko": "재킷. 짧은 겉옷이에요.", "en": "A short coat for cool weather.", "phrase": "He zips up his jacket."},
	"SWEATER": {"category": "CLOTHES", "emoji": "🧶", "ko": "스웨터. 털실로 짠 옷이에요.", "en": "A warm top made of wool.", "phrase": "The sweater keeps me warm."},
	"UNIFORM": {"category": "CLOTHES", "emoji": "👔", "ko": "교복. 같은 모양으로 입는 옷이에요.", "en": "Clothing everyone in a group wears.", "phrase": "Students wear the same uniform."},
	"TROUSERS": {"category": "CLOTHES", "emoji": "👖", "ko": "바지. 다리에 입는 옷이에요.", "en": "Clothing that covers both legs.", "phrase": "These trousers are too long."},
	# SPORT
	"RUN": {"category": "SPORT", "emoji": "🏃", "ko": "달리기. 빠르게 뛰는 운동이에요.", "en": "To move fast on your feet.", "phrase": "They run around the field."},
	"SWIM": {"category": "SPORT", "emoji": "🏊", "ko": "수영. 물에서 하는 운동이에요.", "en": "To move through water.", "phrase": "We swim in the pool."},
	"GOLF": {"category": "SPORT", "emoji": "⛳", "ko": "골프. 공을 쳐서 구멍에 넣어요.", "en": "A game of hitting a ball into holes.", "phrase": "He plays golf on Sunday."},
	"JUMP": {"category": "SPORT", "emoji": "🤸", "ko": "점프. 위로 뛰어오르는 거예요.", "en": "To push yourself up into the air.", "phrase": "She can jump very high."},
	"CLIMB": {"category": "SPORT", "emoji": "🧗", "ko": "등반. 위로 올라가는 운동이에요.", "en": "To go up using hands and feet.", "phrase": "They climb the tall wall."},
	"SKATE": {"category": "SPORT", "emoji": "⛸️", "ko": "스케이트. 얼음 위를 달려요.", "en": "To glide on ice or wheels.", "phrase": "We skate on the frozen lake."},
	"TENNIS": {"category": "SPORT", "emoji": "🎾", "ko": "테니스. 라켓으로 공을 쳐요.", "en": "A game played with rackets and a ball.", "phrase": "They play tennis every week."},
	"SOCCER": {"category": "SPORT", "emoji": "⚽", "ko": "축구. 발로 공을 차요.", "en": "A game where you kick a ball into a goal.", "phrase": "Soccer needs eleven players."},
	"BOXING": {"category": "SPORT", "emoji": "🥊", "ko": "권투. 주먹으로 겨루는 운동이에요.", "en": "A sport of fighting with fists in gloves.", "phrase": "Boxing needs strong arms."},
	"HOCKEY": {"category": "SPORT", "emoji": "🏒", "ko": "하키. 스틱으로 퍽을 쳐요.", "en": "A game played with sticks on ice.", "phrase": "Hockey is played on ice."},
	"BASEBALL": {"category": "SPORT", "emoji": "⚾", "ko": "야구. 방망이로 공을 쳐요.", "en": "A game of hitting a ball with a bat.", "phrase": "He hits the baseball hard."},
	"BASKETBALL": {"category": "SPORT", "emoji": "🏀", "ko": "농구. 공을 골대에 넣어요.", "en": "A game of throwing a ball into a hoop.", "phrase": "Basketball players are very tall."},
	# MUSIC
	"BAND": {"category": "MUSIC", "emoji": "🎸", "ko": "밴드. 함께 연주하는 무리예요.", "en": "A group that plays music together.", "phrase": "The band plays on stage."},
	"BEAT": {"category": "MUSIC", "emoji": "🥁", "ko": "박자. 음악의 규칙적인 소리예요.", "en": "The regular rhythm of music.", "phrase": "Clap along with the beat."},
	"DRUM": {"category": "MUSIC", "emoji": "🥁", "ko": "북. 두드려 소리를 내요.", "en": "An instrument you hit to make sound.", "phrase": "He hits the drum loudly."},
	"HARP": {"category": "MUSIC", "emoji": "🎼", "ko": "하프. 줄을 뜯는 큰 악기예요.", "en": "A large instrument with many strings.", "phrase": "The harp sounds very gentle."},
	"FLUTE": {"category": "MUSIC", "emoji": "🎶", "ko": "플루트. 불어서 소리를 내요.", "en": "A thin instrument you blow into.", "phrase": "She plays a silver flute."},
	"PIANO": {"category": "MUSIC", "emoji": "🎹", "ko": "피아노. 건반을 눌러 연주해요.", "en": "An instrument with black and white keys.", "phrase": "The piano has many keys."},
	"VIOLIN": {"category": "MUSIC", "emoji": "🎻", "ko": "바이올린. 활로 줄을 켜요.", "en": "A small string instrument played with a bow.", "phrase": "The violin makes a sweet sound."},
	"GUITAR": {"category": "MUSIC", "emoji": "🎸", "ko": "기타. 줄을 튕겨 연주해요.", "en": "A string instrument you strum.", "phrase": "He plays guitar in the park."},
	"MELODY": {"category": "MUSIC", "emoji": "🎵", "ko": "선율. 노래의 흐르는 가락이에요.", "en": "The main tune of a song.", "phrase": "That melody is easy to sing."},
	"TRUMPET": {"category": "MUSIC", "emoji": "🎺", "ko": "트럼펫. 금관 악기예요.", "en": "A loud brass instrument you blow.", "phrase": "The trumpet is very loud."},
	"ORCHESTRA": {"category": "MUSIC", "emoji": "🎻", "ko": "관현악단. 많은 악기가 함께 연주해요.", "en": "A large group of many instruments.", "phrase": "The orchestra plays together."},
	"SAXOPHONE": {"category": "MUSIC", "emoji": "🎷", "ko": "색소폰. 굽은 관악기예요.", "en": "A curved brass instrument with keys.", "phrase": "The saxophone sounds warm."},
	# JOB
	"CHEF": {"category": "JOB", "emoji": "👨‍🍳", "ko": "요리사. 음식을 만들어요.", "en": "A person who cooks food for others.", "phrase": "The chef cooks a fine meal."},
	"NURSE": {"category": "JOB", "emoji": "👩‍⚕️", "ko": "간호사. 환자를 돌봐요.", "en": "A person who cares for sick people.", "phrase": "The nurse checks my arm."},
	"PILOT": {"category": "JOB", "emoji": "👨‍✈️", "ko": "조종사. 비행기를 몰아요.", "en": "A person who flies an airplane.", "phrase": "The pilot lands the plane."},
	"BAKER": {"category": "JOB", "emoji": "👩‍🍳", "ko": "제빵사. 빵을 구워요.", "en": "A person who bakes bread and cakes.", "phrase": "The baker makes fresh bread."},
	"ACTOR": {"category": "JOB", "emoji": "🎭", "ko": "배우. 연기를 해요.", "en": "A person who acts in plays or films.", "phrase": "The actor learns his lines."},
	"DOCTOR": {"category": "JOB", "emoji": "👨‍⚕️", "ko": "의사. 병을 고쳐요.", "en": "A person who treats sick people.", "phrase": "The doctor helps the patient."},
	"FARMER": {"category": "JOB", "emoji": "👨‍🌾", "ko": "농부. 곡식과 채소를 길러요.", "en": "A person who grows food on land.", "phrase": "The farmer grows corn."},
	"POLICE": {"category": "JOB", "emoji": "👮", "ko": "경찰. 사람들을 지켜요.", "en": "People who keep others safe.", "phrase": "The police help lost children."},
	"ARTIST": {"category": "JOB", "emoji": "🎨", "ko": "화가. 그림을 그려요.", "en": "A person who makes art.", "phrase": "The artist paints a river."},
	"DENTIST": {"category": "JOB", "emoji": "🦷", "ko": "치과의사. 이를 치료해요.", "en": "A doctor who takes care of teeth.", "phrase": "The dentist checks my teeth."},
	"ENGINEER": {"category": "JOB", "emoji": "🔧", "ko": "기술자. 기계를 설계하고 고쳐요.", "en": "A person who designs and builds machines.", "phrase": "The engineer fixes the engine."},
	"SCIENTIST": {"category": "JOB", "emoji": "🔬", "ko": "과학자. 실험하고 연구해요.", "en": "A person who studies how things work.", "phrase": "The scientist studies the stars."},
	# CITY
	"MAP": {"category": "CITY", "emoji": "🗺️", "ko": "지도. 길을 그린 그림이에요.", "en": "A drawing that shows where places are.", "phrase": "We look at the map."},
	"BANK": {"category": "CITY", "emoji": "🏦", "ko": "은행. 돈을 맡기는 곳이에요.", "en": "A place where people keep money.", "phrase": "The bank opens at nine."},
	"PARK": {"category": "CITY", "emoji": "🏞️", "ko": "공원. 나무가 많은 넓은 곳이에요.", "en": "An open green place in a city.", "phrase": "Children play in the park."},
	"SHOP": {"category": "CITY", "emoji": "🏪", "ko": "가게. 물건을 파는 곳이에요.", "en": "A place where things are sold.", "phrase": "The shop sells fresh fruit."},
	"HOTEL": {"category": "CITY", "emoji": "🏨", "ko": "호텔. 여행 중에 자는 곳이에요.", "en": "A building where travelers sleep.", "phrase": "We stay at a small hotel."},
	"TOWER": {"category": "CITY", "emoji": "🗼", "ko": "탑. 아주 높은 건물이에요.", "en": "A very tall narrow building.", "phrase": "The tower is very tall."},
	"BRIDGE": {"category": "CITY", "emoji": "🌉", "ko": "다리. 강을 건너는 길이에요.", "en": "A road built over water.", "phrase": "The bridge crosses the river."},
	"MARKET": {"category": "CITY", "emoji": "🏬", "ko": "시장. 여러 가게가 모인 곳이에요.", "en": "A place where many things are sold.", "phrase": "The market is busy today."},
	"STATION": {"category": "CITY", "emoji": "🚉", "ko": "역. 기차를 타는 곳이에요.", "en": "A place where trains stop.", "phrase": "The train leaves the station."},
	"LIBRARY": {"category": "CITY", "emoji": "📚", "ko": "도서관. 책을 빌리는 곳이에요.", "en": "A quiet place full of books.", "phrase": "The library is very quiet."},
	"HOSPITAL": {"category": "CITY", "emoji": "🏥", "ko": "병원. 아플 때 가는 곳이에요.", "en": "A place where sick people are treated.", "phrase": "The hospital is near here."},
	"RESTAURANT": {"category": "CITY", "emoji": "🍽️", "ko": "식당. 음식을 사 먹는 곳이에요.", "en": "A place where you buy and eat meals.", "phrase": "We eat at a new restaurant."},
	# VEHICLE
	"BUS": {"category": "VEHICLE", "emoji": "🚌", "ko": "버스. 여러 사람이 함께 타요.", "en": "A big road vehicle for many people.", "phrase": "The bus stops at the corner."},
	"CAR": {"category": "VEHICLE", "emoji": "🚗", "ko": "자동차. 바퀴 네 개로 달려요.", "en": "A road vehicle with four wheels.", "phrase": "The car turns left."},
	"VAN": {"category": "VEHICLE", "emoji": "🚐", "ko": "밴. 짐과 사람을 함께 실어요.", "en": "A vehicle for carrying people or goods.", "phrase": "The van carries many boxes."},
	"BIKE": {"category": "VEHICLE", "emoji": "🚲", "ko": "자전거. 발로 굴려서 타요.", "en": "A two-wheeled vehicle you pedal.", "phrase": "He rides his bike to school."},
	"BOAT": {"category": "VEHICLE", "emoji": "⛵", "ko": "배. 물 위를 다녀요.", "en": "A small vessel that travels on water.", "phrase": "The boat floats on the lake."},
	"SHIP": {"category": "VEHICLE", "emoji": "🚢", "ko": "배. 바다를 건너는 큰 배예요.", "en": "A large vessel that crosses the sea.", "phrase": "The ship sails at dawn."},
	"TRAIN": {"category": "VEHICLE", "emoji": "🚆", "ko": "기차. 선로 위를 달려요.", "en": "A long vehicle that runs on rails.", "phrase": "The train arrives on time."},
	"TRUCK": {"category": "VEHICLE", "emoji": "🚚", "ko": "트럭. 무거운 짐을 실어요.", "en": "A large vehicle that carries heavy loads.", "phrase": "The truck carries wood."},
	"SUBWAY": {"category": "VEHICLE", "emoji": "🚇", "ko": "지하철. 땅 밑으로 달려요.", "en": "A train that runs under the ground.", "phrase": "The subway runs underground."},
	"BICYCLE": {"category": "VEHICLE", "emoji": "🚴", "ko": "자전거. 페달을 밟아 달려요.", "en": "A vehicle with two wheels and pedals.", "phrase": "She locks her bicycle."},
	"AIRPLANE": {"category": "VEHICLE", "emoji": "✈️", "ko": "비행기. 하늘을 날아요.", "en": "A machine that flies through the sky.", "phrase": "The airplane flies above clouds."},
	"HELICOPTER": {"category": "VEHICLE", "emoji": "🚁", "ko": "헬리콥터. 날개가 돌며 떠요.", "en": "A flying machine with spinning blades.", "phrase": "The helicopter lands slowly."},
	# WEATHER
	"FOG": {"category": "WEATHER", "emoji": "🌫️", "ko": "안개. 앞이 뿌옇게 보여요.", "en": "Thick cloud close to the ground.", "phrase": "The fog hides the road."},
	"HOT": {"category": "WEATHER", "emoji": "🔥", "ko": "덥다. 온도가 높아요.", "en": "Having a high temperature.", "phrase": "Today is very hot."},
	"COLD": {"category": "WEATHER", "emoji": "🥶", "ko": "춥다. 온도가 낮아요.", "en": "Having a low temperature.", "phrase": "The wind feels cold."},
	"WARM": {"category": "WEATHER", "emoji": "🌤️", "ko": "따뜻하다. 기분 좋은 온도예요.", "en": "Pleasantly a little hot.", "phrase": "The room is warm inside."},
	"WIND": {"category": "WEATHER", "emoji": "🌬️", "ko": "바람. 공기가 움직이는 거예요.", "en": "Air that moves outside.", "phrase": "The wind moves the leaves."},
	"CLOUD": {"category": "WEATHER", "emoji": "☁️", "ko": "구름. 하늘에 떠 있는 물방울이에요.", "en": "A white shape floating in the sky.", "phrase": "One cloud covers the sun."},
	"FROST": {"category": "WEATHER", "emoji": "❄️", "ko": "서리. 얇게 언 얼음이에요.", "en": "Thin ice that forms on cold mornings.", "phrase": "Frost covers the grass."},
	"SHOWER": {"category": "WEATHER", "emoji": "🌦️", "ko": "소나기. 잠깐 내리는 비예요.", "en": "A short fall of rain.", "phrase": "A shower passes quickly."},
	"BREEZE": {"category": "WEATHER", "emoji": "🍃", "ko": "산들바람. 부드러운 바람이에요.", "en": "A light gentle wind.", "phrase": "A cool breeze feels nice."},
	"DROUGHT": {"category": "WEATHER", "emoji": "🏜️", "ko": "가뭄. 비가 오래 안 와요.", "en": "A long time with no rain.", "phrase": "The drought dries the fields."},
	"TYPHOON": {"category": "WEATHER", "emoji": "🌀", "ko": "태풍. 아주 센 비바람이에요.", "en": "A very strong storm with heavy rain.", "phrase": "The typhoon brings heavy rain."},
	"LIGHTNING": {"category": "WEATHER", "emoji": "⚡", "ko": "번개. 하늘에서 번쩍여요.", "en": "A bright flash of light in a storm.", "phrase": "Lightning flashes in the sky."},
	# TIME
	"DAY": {"category": "TIME", "emoji": "📅", "ko": "하루. 아침부터 밤까지예요.", "en": "The time from morning until night.", "phrase": "Today is a sunny day."},
	"HOUR": {"category": "TIME", "emoji": "🕐", "ko": "시간. 60분이에요.", "en": "A period of sixty minutes.", "phrase": "Wait for one hour."},
	"WEEK": {"category": "TIME", "emoji": "📆", "ko": "주. 이레, 일곱 날이에요.", "en": "A period of seven days.", "phrase": "We meet once a week."},
	"YEAR": {"category": "TIME", "emoji": "🗓️", "ko": "해. 열두 달이에요.", "en": "A period of twelve months.", "phrase": "A year has four seasons."},
	"MONTH": {"category": "TIME", "emoji": "📅", "ko": "달. 한 해의 열두 부분 중 하나예요.", "en": "One of the twelve parts of a year.", "phrase": "This month is very busy."},
	"NIGHT": {"category": "TIME", "emoji": "🌙", "ko": "밤. 어두운 시간이에요.", "en": "The dark part of the day.", "phrase": "The night is quiet."},
	"TODAY": {"category": "TIME", "emoji": "📌", "ko": "오늘. 지금 이 날이에요.", "en": "This present day.", "phrase": "Today is my birthday."},
	"MINUTE": {"category": "TIME", "emoji": "⌚", "ko": "분. 60초예요.", "en": "A period of sixty seconds.", "phrase": "Wait just one minute."},
	"SECOND": {"category": "TIME", "emoji": "⏳", "ko": "초. 가장 짧은 시간 단위예요.", "en": "A very short unit of time.", "phrase": "It takes only a second."},
	"MORNING": {"category": "TIME", "emoji": "🌅", "ko": "아침. 하루가 시작되는 때예요.", "en": "The early part of the day.", "phrase": "The morning air is fresh."},
	"EVENING": {"category": "TIME", "emoji": "🌆", "ko": "저녁. 해가 지는 때예요.", "en": "The time when the sun goes down.", "phrase": "We walk in the evening."},
	"YESTERDAY": {"category": "TIME", "emoji": "⏪", "ko": "어제. 오늘의 하루 전이에요.", "en": "The day before today.", "phrase": "Yesterday was very cold."},
	# SHAPE
	"DOT": {"category": "SHAPE", "emoji": "⚫", "ko": "점. 아주 작은 동그라미예요.", "en": "A very small round mark.", "phrase": "Draw a small dot here."},
	"CUBE": {"category": "SHAPE", "emoji": "🧊", "ko": "정육면체. 여섯 면이 같은 상자예요.", "en": "A box with six equal square sides.", "phrase": "The cube has six sides."},
	"CONE": {"category": "SHAPE", "emoji": "🍦", "ko": "원뿔. 위가 뾰족한 모양이에요.", "en": "A shape that is round below and pointed above.", "phrase": "The cone has a sharp top."},
	"LINE": {"category": "SHAPE", "emoji": "➖", "ko": "선. 곧게 이어진 자국이에요.", "en": "A long straight mark.", "phrase": "Draw a straight line."},
	"OVAL": {"category": "SHAPE", "emoji": "🥚", "ko": "타원. 길쭉한 동그라미예요.", "en": "A shape like a stretched circle.", "phrase": "An egg is an oval."},
	"CIRCLE": {"category": "SHAPE", "emoji": "⭕", "ko": "원. 완전히 둥근 모양이에요.", "en": "A perfectly round shape.", "phrase": "The circle has no corners."},
	"SPIRAL": {"category": "SHAPE", "emoji": "🌀", "ko": "나선. 빙글빙글 도는 모양이에요.", "en": "A curve that winds around a center.", "phrase": "The spiral turns inward."},
	"SQUARE": {"category": "SHAPE", "emoji": "🟦", "ko": "정사각형. 네 변이 같아요.", "en": "A shape with four equal sides.", "phrase": "A square has four sides."},
	"SPHERE": {"category": "SHAPE", "emoji": "🔮", "ko": "구. 공처럼 둥근 입체예요.", "en": "A perfectly round solid like a ball.", "phrase": "A ball is a sphere."},
	"CYLINDER": {"category": "SHAPE", "emoji": "🥫", "ko": "원기둥. 캔 같은 모양이에요.", "en": "A solid shaped like a can.", "phrase": "The can is a cylinder."},
	"TRIANGLE": {"category": "SHAPE", "emoji": "🔺", "ko": "삼각형. 변이 세 개예요.", "en": "A shape with three sides.", "phrase": "A triangle has three corners."},
	"RECTANGLE": {"category": "SHAPE", "emoji": "🟧", "ko": "직사각형. 마주 보는 변이 같아요.", "en": "A shape with four sides and square corners.", "phrase": "The door is a rectangle."},
	# EMOTION
	"JOY": {"category": "EMOTION", "emoji": "😄", "ko": "기쁨. 아주 좋은 느낌이에요.", "en": "A feeling of great happiness.", "phrase": "Her face shows pure joy."},
	"FEAR": {"category": "EMOTION", "emoji": "😨", "ko": "두려움. 무서운 느낌이에요.", "en": "The feeling of being afraid.", "phrase": "He hides his fear."},
	"LOVE": {"category": "EMOTION", "emoji": "❤️", "ko": "사랑. 아끼는 마음이에요.", "en": "A deep warm feeling for someone.", "phrase": "They share a deep love."},
	"CALM": {"category": "EMOTION", "emoji": "😌", "ko": "차분함. 마음이 고요해요.", "en": "Feeling quiet and peaceful.", "phrase": "Stay calm and breathe."},
	"ANGRY": {"category": "EMOTION", "emoji": "😠", "ko": "화남. 몹시 기분이 나빠요.", "en": "Feeling very upset.", "phrase": "He looks angry today."},
	"HAPPY": {"category": "EMOTION", "emoji": "😊", "ko": "행복함. 기분이 좋아요.", "en": "Feeling pleased and glad.", "phrase": "She feels happy today."},
	"PROUD": {"category": "EMOTION", "emoji": "😤", "ko": "자랑스러움. 뿌듯한 느낌이에요.", "en": "Feeling glad about something you did.", "phrase": "I am proud of you."},
	"SCARED": {"category": "EMOTION", "emoji": "😱", "ko": "겁남. 갑자기 무서워요.", "en": "Suddenly afraid of something.", "phrase": "The loud noise scared me."},
	"LONELY": {"category": "EMOTION", "emoji": "😔", "ko": "외로움. 혼자라 쓸쓸해요.", "en": "Feeling sad because you are alone.", "phrase": "He feels lonely at night."},
	"NERVOUS": {"category": "EMOTION", "emoji": "😰", "ko": "긴장됨. 마음이 조마조마해요.", "en": "Feeling worried about what will happen.", "phrase": "She feels nervous before the test."},
	"EXCITED": {"category": "EMOTION", "emoji": "🤩", "ko": "신남. 기대가 커요.", "en": "Feeling very eager and happy.", "phrase": "The kids are excited today."},
	"SURPRISED": {"category": "EMOTION", "emoji": "😲", "ko": "놀람. 예상 못한 일에 놀라요.", "en": "Feeling shocked by something unexpected.", "phrase": "We were surprised by the gift."},
	# SEA
	"FIN": {"category": "SEA", "emoji": "🐟", "ko": "지느러미. 물고기의 헤엄 도구예요.", "en": "The part a fish uses to swim.", "phrase": "The fin cuts the water."},
	"CRAB": {"category": "SEA", "emoji": "🦀", "ko": "게. 옆으로 걷는 바다 동물이에요.", "en": "A sea animal that walks sideways.", "phrase": "The crab walks sideways."},
	"SEAL": {"category": "SEA", "emoji": "🦭", "ko": "물개. 물에서 헤엄치는 동물이에요.", "en": "A smooth sea animal that swims fast.", "phrase": "The seal claps its flippers."},
	"WAVE": {"category": "SEA", "emoji": "🌊", "ko": "파도. 바다에서 밀려와요.", "en": "Moving water that rises on the sea.", "phrase": "A big wave hits the rock."},
	"CORAL": {"category": "SEA", "emoji": "🪸", "ko": "산호. 바다 속 딱딱한 생물이에요.", "en": "A hard sea growth of many colors.", "phrase": "The coral has bright colors."},
	"SHARK": {"category": "SEA", "emoji": "🦈", "ko": "상어. 이가 날카로운 물고기예요.", "en": "A large fish with sharp teeth.", "phrase": "The shark swims very fast."},
	"WHALE": {"category": "SEA", "emoji": "🐋", "ko": "고래. 바다에서 가장 큰 동물이에요.", "en": "The biggest animal in the sea.", "phrase": "The whale sings under water."},
	"SHRIMP": {"category": "SEA", "emoji": "🦐", "ko": "새우. 작고 굽은 바다 생물이에요.", "en": "A small curved sea animal.", "phrase": "The shrimp is small and pink."},
	"LOBSTER": {"category": "SEA", "emoji": "🦞", "ko": "바닷가재. 집게가 큰 생물이에요.", "en": "A sea animal with two big claws.", "phrase": "The lobster has strong claws."},
	"OCTOPUS": {"category": "SEA", "emoji": "🐙", "ko": "문어. 다리가 여덟 개예요.", "en": "A sea animal with eight arms.", "phrase": "The octopus has eight arms."},
	"SEAWEED": {"category": "SEA", "emoji": "🌿", "ko": "해초. 바다에서 자라는 풀이에요.", "en": "A plant that grows in the sea.", "phrase": "Seaweed floats near the shore."},
	"JELLYFISH": {"category": "SEA", "emoji": "🎐", "ko": "해파리. 투명하고 말랑해요.", "en": "A soft clear sea animal that stings.", "phrase": "The jellyfish drifts slowly."},
	# INSECT
	"ANT": {"category": "INSECT", "emoji": "🐜", "ko": "개미. 줄지어 다니는 작은 곤충이에요.", "en": "A tiny insect that walks in lines.", "phrase": "An ant carries a crumb."},
	"MOTH": {"category": "INSECT", "emoji": "🦋", "ko": "나방. 밤에 불빛으로 모여요.", "en": "An insect that flies toward light at night.", "phrase": "A moth circles the lamp."},
	"WASP": {"category": "INSECT", "emoji": "🐝", "ko": "말벌. 침이 있는 곤충이에요.", "en": "A stinging insect with a thin waist.", "phrase": "The wasp builds a nest."},
	"BEETLE": {"category": "INSECT", "emoji": "🪲", "ko": "딱정벌레. 등껍질이 단단해요.", "en": "An insect with a hard shiny shell.", "phrase": "The beetle has a hard shell."},
	"SPIDER": {"category": "INSECT", "emoji": "🕷️", "ko": "거미. 줄을 쳐서 먹이를 잡아요.", "en": "A small animal that spins webs.", "phrase": "The spider spins a web."},
	"HORNET": {"category": "INSECT", "emoji": "🐝", "ko": "장수말벌. 크고 위험한 벌이에요.", "en": "A large wasp with a painful sting.", "phrase": "The hornet is very large."},
	"CRICKET": {"category": "INSECT", "emoji": "🦗", "ko": "귀뚜라미. 밤에 소리를 내요.", "en": "An insect that chirps at night.", "phrase": "A cricket sings at night."},
	"LADYBUG": {"category": "INSECT", "emoji": "🐞", "ko": "무당벌레. 점이 있는 빨간 벌레예요.", "en": "A small red beetle with black spots.", "phrase": "The ladybug has black spots."},
	"DRAGONFLY": {"category": "INSECT", "emoji": "🪰", "ko": "잠자리. 날개가 네 장이에요.", "en": "An insect with four clear wings.", "phrase": "A dragonfly hovers over water."},
	"GRASSHOPPER": {"category": "INSECT", "emoji": "🦗", "ko": "메뚜기. 잘 뛰는 곤충이에요.", "en": "An insect that jumps very far.", "phrase": "The grasshopper jumps away."},
	# PLANT
	"OAK": {"category": "PLANT", "emoji": "🌳", "ko": "참나무. 크고 단단한 나무예요.", "en": "A large strong tree.", "phrase": "The oak is very old."},
	"LEAF": {"category": "PLANT", "emoji": "🍃", "ko": "잎. 나무에 달린 초록 부분이에요.", "en": "The flat green part of a plant.", "phrase": "One leaf falls slowly."},
	"PINE": {"category": "PLANT", "emoji": "🌲", "ko": "소나무. 잎이 뾰족해요.", "en": "A tree with thin sharp leaves.", "phrase": "The pine stays green all year."},
	"ROOT": {"category": "PLANT", "emoji": "🌱", "ko": "뿌리. 땅 속에 있는 부분이에요.", "en": "The part of a plant under the ground.", "phrase": "The root goes deep down."},
	"SEED": {"category": "PLANT", "emoji": "🌰", "ko": "씨. 새 식물이 되는 알갱이예요.", "en": "A small thing that grows into a plant.", "phrase": "Plant the seed in soil."},
	"GRASS": {"category": "PLANT", "emoji": "🌿", "ko": "풀. 땅을 덮는 초록 식물이에요.", "en": "Short green plants that cover the ground.", "phrase": "The grass is wet with dew."},
	"TULIP": {"category": "PLANT", "emoji": "🌷", "ko": "튤립. 컵 모양의 꽃이에요.", "en": "A spring flower shaped like a cup.", "phrase": "The tulip opens in spring."},
	"FLOWER": {"category": "PLANT", "emoji": "🌸", "ko": "꽃. 식물의 예쁜 부분이에요.", "en": "The colorful part of a plant.", "phrase": "The flower smells sweet."},
	"BAMBOO": {"category": "PLANT", "emoji": "🎋", "ko": "대나무. 곧고 빠르게 자라요.", "en": "A tall grass that grows very fast.", "phrase": "Bamboo grows very fast."},
	"CACTUS": {"category": "PLANT", "emoji": "🌵", "ko": "선인장. 가시가 있고 물을 저장해요.", "en": "A desert plant with sharp spines.", "phrase": "The cactus stores water."},
	"MUSHROOM": {"category": "PLANT", "emoji": "🍄", "ko": "버섯. 우산 모양으로 자라요.", "en": "A soft growth shaped like an umbrella.", "phrase": "A mushroom grows in shade."},
	"SUNFLOWER": {"category": "PLANT", "emoji": "🌻", "ko": "해바라기. 해를 따라 도는 꽃이에요.", "en": "A tall yellow flower that faces the sun.", "phrase": "The sunflower faces the sun."},
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