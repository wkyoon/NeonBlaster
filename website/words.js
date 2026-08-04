/* ========================================
   NeonBlaster — Word Gallery Data
   게임 내 단어 + 이모지 아이콘 + 설명
   ======================================== */

// ============================================================
// 학습 코스 정보 (카테고리별)
// 게임 StoryData.gd의 CATEGORY_LORE와 연동
// ============================================================
const COURSE_INFO = {
	"SPACE":    { icon: "🚀", ko: "별과 행성의 이름", desc: "우주의 가장 순수한 루미나를 담고 있어요.", order: 1 },
	"ANIMAL":   { icon: "🐾", ko: "생명체의 이름", desc: "여러 행성의 동물 친구들이에요.", order: 2 },
	"NATURE":   { icon: "🌿", ko: "자연의 힘", desc: "불, 폭풍, 얼음 등 파괴적인 자연 에너지!", order: 3 },
	"SCIENCE":  { icon: "🔬", ko: "과학의 언어", desc: "지성이 만들어낸 힘의 단어들이에요.", order: 4 },
	"WEAPON":   { icon: "⚔️", ko: "무기의 이름", desc: "가장 직접적이고 파괴적인 힘!", order: 5 },
	"VEHICLE":  { icon: "🚗", ko: "탈것의 이름", desc: "속도와 기동성의 에너지를 가진 단어.", order: 6 },
	"MAGIC":    { icon: "🔮", ko: "마법의 단어", desc: "신비롭고 예측 불가능한 힘을 숨겨요.", order: 7 },
	"COLOR":    { icon: "🎨", ko: "색의 이름", desc: "루미나의 다양한 파장을 의미해요.", order: 8 },
	"TREASURE": { icon: "💎", ko: "보물의 이름", desc: "가치와 풍요의 에너지를 지닌 단어.", order: 9 },
	"BODY":     { icon: "🧍", ko: "신체의 이름", desc: "생명 그 자체의 루미나를 상징해요.", order: 10 },
	"FUN":      { icon: "🎉", ko: "즐거움의 단어", desc: "가볍지만 결코 무시할 수 없는 밝은 에너지!", order: 11 },
	"ACTION":   { icon: "🏃", ko: "행동의 단어", desc: "움직임과 변화의 에너지를 담고 있어요.", order: 12 },
	"ENERGY":   { icon: "⚡", ko: "에너지의 단어", desc: "루미나 그 자체와 가장 가까운 힘!", order: 13 },
	"MACHINE":  { icon: "🤖", ko: "기계의 이름", desc: "로봇과 안드로이드는 보이드와도 동맹해요.", order: 14 },
	"DEFENSE":  { icon: "🛡️", ko: "방어의 단어", desc: "보호와 인내의 에너지를 의미해요.", order: 15 },
	"LIGHT":    { icon: "💡", ko: "빛의 단어", desc: "루미나 가디언의 정수! 가장 신성한 힘.", order: 16 },
	"GAME":     { icon: "🎮", ko: "게임의 단어", desc: "승리와 도전의 에너지를 담고 있어요!", order: 17 },
};

// 레벨 변환 헬퍼: difficulty → level (1=기초, 2=중급, 3=고급)
function difficultyToLevel(diff) {
	if (diff === "EASY") return 1;
	if (diff === "NORMAL") return 2;
	return 3;
}

const LEVEL_INFO = {
	1: { stars: "⭐", name: "기초", color: "#00ff88" },
	2: { stars: "⭐⭐", name: "중급", color: "#ffdd00" },
	3: { stars: "⭐⭐⭐", name: "고급", color: "#ff0080" },
};

const WORD_GALLERY = {
	// ---- EASY (3 letters) ----
	"SUN":    { emoji: "☀️",  category: "SPACE",    color: "#ffdd00", ko: "태양. 낮에 하늘에서 빛나는 커다란 별이에요.", en: "The bright star that lights up our daytime sky.", difficulty: "EASY" },
	"CAT":    { emoji: "🐱",  category: "ANIMAL",   color: "#ff9944", ko: "고양이. 야옹하고 우는 귀여운 동물이에요.", en: "A small furry pet that says 'meow'.", difficulty: "EASY" },
	"DOG":    { emoji: "🐶",  category: "ANIMAL",   color: "#cc8844", ko: "강아지. 멍멍 짖는 충실한 친구예요.", en: "A loyal pet that says 'woof'.", difficulty: "EASY" },
	"BAT":    { emoji: "🦇",  category: "ANIMAL",   color: "#9944cc", ko: "박쥐. 밤에 날아다니는 동물이에요.", en: "A flying animal that is active at night.", difficulty: "EASY" },
	"OWL":    { emoji: "🦉",  category: "ANIMAL",   color: "#aa7744", ko: "부엉이. 밤에 우는 새예요.", en: "A wise bird that is awake at night.", difficulty: "EASY" },
	"FOX":    { emoji: "🦊",  category: "ANIMAL",   color: "#ff6622", ko: "여우. 영리하고 빠른 동물이에요.", en: "A clever, fast animal with a bushy tail.", difficulty: "EASY" },
	"BEE":    { emoji: "🐝",  category: "ANIMAL",   color: "#ffcc00", ko: "꿀벌. 꿀을 만드는 바쁜 곤충이에요.", en: "A small insect that makes honey.", difficulty: "EASY" },
	"FLY":    { emoji: "🪰",  category: "ANIMAL",   color: "#999999", ko: "파리. 날아다니는 작은 곤충이에요.", en: "A small flying insect.", difficulty: "EASY" },
	"SKY":    { emoji: "🌌",  category: "NATURE",   color: "#3399ff", ko: "하늘. 머리 위에 보이는 파란 곳이에요.", en: "The blue space above us.", difficulty: "EASY" },
	"RAY":    { emoji: "🔅",  category: "SCIENCE",  color: "#ffdd44", ko: "광선. 빛이 일직선으로 나아가는 것이에요.", en: "A line of light shining from a source.", difficulty: "EASY" },
	"GUN":    { emoji: "🔫",  category: "WEAPON",   color: "#aaaaaa", ko: "총. 총알을 쏘는 무기예요.", en: "A weapon that shoots bullets.", difficulty: "EASY" },
	"JET":    { emoji: "✈️",  category: "VEHICLE",  color: "#cccccc", ko: "제트기. 아주 빠르게 날아가는 비행기예요.", en: "A very fast airplane.", difficulty: "EASY" },
	"ORB":    { emoji: "🔮",  category: "MAGIC",    color: "#9933ff", ko: "구슬. 둥글고 빛나는 마법 구체예요.", en: "A glowing magic sphere.", difficulty: "EASY" },
	"ARC":    { emoji: "🌈",  category: "SCIENCE",  color: "#33ffcc", ko: "호. 둥글게 휘어진 선이에요.", en: "A curved line, like part of a circle.", difficulty: "EASY" },
	"ICE":    { emoji: "🧊",  category: "NATURE",   color: "#66ddff", ko: "얼음. 차갑고 딱딱하게 언 물이에요.", en: "Frozen water, cold and hard.", difficulty: "EASY" },
	"GAS":    { emoji: "💨",  category: "SCIENCE",  color: "#88cc44", ko: "기체. 공기처럼 보이지 않는 물질이에요.", en: "An invisible substance like air.", difficulty: "EASY" },
	"RED":    { emoji: "🔴",  category: "COLOR",    color: "#ff3333", ko: "빨간색. 사과와 같은 색이에요.", en: "The color of apples and fire.", difficulty: "EASY" },
	"GEM":    { emoji: "💎",  category: "TREASURE", color: "#33ffee", ko: "보석. 반짝이는 귀한 돌이에요.", en: "A shiny, precious stone.", difficulty: "EASY" },
	"EYE":    { emoji: "👁️", category: "BODY",     color: "#33ff88", ko: "눈. 세상을 보는 우리의 기관이에요.", en: "The body part we use to see.", difficulty: "EASY" },
	"ARM":    { emoji: "💪",  category: "BODY",     color: "#ee9955", ko: "팔. 물건을 들고 잡을 수 있어요.", en: "The body part we use to hold things.", difficulty: "EASY" },
	"LEG":    { emoji: "🦵",  category: "BODY",     color: "#ee9955", ko: "다리. 걷고 뛸 수 있게 해줘요.", en: "The body part we use to walk and run.", difficulty: "EASY" },
	"EAR":    { emoji: "👂",  category: "BODY",     color: "#ee9955", ko: "귀. 소리를 들을 수 있어요.", en: "The body part we use to hear.", difficulty: "EASY" },

	// ---- NORMAL (4-5 letters) ----
	"STAR":   { emoji: "⭐",  category: "SPACE",    color: "#ffdd00", ko: "별. 밤하늘에서 반짝이는 빛이에요.", en: "A twinkling light in the night sky.", difficulty: "NORMAL" },
	"MOON":   { emoji: "🌙",  category: "SPACE",    color: "#ccccff", ko: "달. 밤에 보이는 둥근 천체예요.", en: "The round object that shines at night.", difficulty: "NORMAL" },
	"MARS":   { emoji: "🔴",  category: "SPACE",    color: "#ff6633", ko: "화성. 붉은색 행성이에요.", en: "The red planet in our solar system.", difficulty: "NORMAL" },
	"BIRD":   { emoji: "🐦",  category: "ANIMAL",   color: "#44ddff", ko: "새. 하늘을 날아다니는 동물이에요.", en: "An animal that can fly in the sky.", difficulty: "NORMAL" },
	"FISH":   { emoji: "🐟",  category: "ANIMAL",   color: "#44ccff", ko: "물고기. 물속에서 헤엄치는 동물이에요.", en: "An animal that swims in water.", difficulty: "NORMAL" },
	"BEAR":   { emoji: "🐻",  category: "ANIMAL",   color: "#996633", ko: "곰. 크고 힘센 동물이에요.", en: "A big, strong furry animal.", difficulty: "NORMAL" },
	"WOLF":   { emoji: "🐺",  category: "ANIMAL",   color: "#888899", ko: "늑대. 숲속에 사는 야생 동물이에요.", en: "A wild animal that lives in forests.", difficulty: "NORMAL" },
	"BLUE":   { emoji: "🔵",  category: "COLOR",    color: "#3366ff", ko: "파란색. 하늘과 바다의 색이에요.", en: "The color of the sky and ocean.", difficulty: "NORMAL" },
	"GOLD":   { emoji: "🥇",  category: "TREASURE", color: "#ffdd00", ko: "금. 노랗고 빛나는 귀금속이에요.", en: "A shiny, yellow precious metal.", difficulty: "NORMAL" },
	"PINK":   { emoji: "🩷",  category: "COLOR",    color: "#ff66aa", ko: "분홍색. 부드러운 연한 붉은색이에요.", en: "A soft, light red color.", difficulty: "NORMAL" },
	"GAME":   { emoji: "🎮",  category: "FUN",      color: "#33ff88", ko: "게임. 즐겁게 노는 놀이예요.", en: "Something fun you play.", difficulty: "NORMAL" },
	"PLAY":   { emoji: "🎯",  category: "FUN",      color: "#33ff88", ko: "놀다. 즐겁게 활동하는 것이에요.", en: "To have fun doing an activity.", difficulty: "NORMAL" },
	"MOVE":   { emoji: "🏃",  category: "ACTION",   color: "#33ff88", ko: "움직이다. 한 곳에서 다른 곳으로 가요.", en: "To change position or go somewhere.", difficulty: "NORMAL" },
	"FIRE":   { emoji: "🔥",  category: "NATURE",   color: "#ff6611", ko: "불. 뜨겁고 밝게 타오르는 것이에요.", en: "Hot flames that burn and glow.", difficulty: "NORMAL" },
	"COMET":  { emoji: "☄️", category: "SPACE",    color: "#66ccff", ko: "혜성. 긴 꼬리를 남기며 날아가는 천체예요.", en: "A space object with a glowing tail.", difficulty: "NORMAL" },
	"EARTH":  { emoji: "🌍",  category: "SPACE",    color: "#3399ff", ko: "지구. 우리가 사는 파란 행성이에요.", en: "Our home planet, the blue planet.", difficulty: "NORMAL" },
	"VENUS":  { emoji: "🪐",  category: "SPACE",    color: "#ffaa44", ko: "금성. 아주 뜨거운 행성이에요.", en: "The hottest planet in our solar system.", difficulty: "NORMAL" },
	"SOLAR":  { emoji: "☀️",  category: "SPACE",    color: "#ffaa22", ko: "태양의. 태양과 관련된 것이에요.", en: "Relating to the sun.", difficulty: "NORMAL" },
	"ORBIT":  { emoji: "🛰️", category: "SPACE",    color: "#66ccff", ko: "궤도. 행성이 도는 길이에요.", en: "The path a planet takes around the sun.", difficulty: "NORMAL" },
	"LASER":  { emoji: "🔆",  category: "SCIENCE",  color: "#ff22cc", ko: "레이저. 강한 빛의 줄기예요.", en: "A powerful beam of focused light.", difficulty: "NORMAL" },
	"ALIEN":  { emoji: "👽",  category: "SPACE",    color: "#44ff44", ko: "외계인. 다른 별에서 온 존재예요.", en: "A being from another planet.", difficulty: "NORMAL" },
	"ROBOT":  { emoji: "🤖",  category: "MACHINE",  color: "#99ccff", ko: "로봇. 스스로 움직이는 기계예요.", en: "A machine that can move on its own.", difficulty: "NORMAL" },
	"POWER":  { emoji: "⚡",  category: "ENERGY",   color: "#ffdd00", ko: "힘. 무엇이든 할 수 있는 에너지예요.", en: "The energy to do things.", difficulty: "NORMAL" },
	"SWORD":  { emoji: "⚔️", category: "WEAPON",   color: "#ccccdd", ko: "칼. 날카로운 무기예요.", en: "A sharp blade weapon.", difficulty: "NORMAL" },
	"BLADE":  { emoji: "🗡️", category: "WEAPON",   color: "#ccccdd", ko: "칼날. 베는 도구의 날카로운 부분이에요.", en: "The sharp cutting part of a weapon.", difficulty: "NORMAL" },
	"SHIELD": { emoji: "🛡️", category: "DEFENSE",  color: "#3399ff", ko: "방패. 공격을 막아주는 도구예요.", en: "Something that protects you from attacks.", difficulty: "NORMAL" },
	"GHOST":  { emoji: "👻",  category: "MAGIC",    color: "#ccccee", ko: "유령. 투명한 영혼이에요.", en: "A transparent spirit of the dead.", difficulty: "NORMAL" },
	"STORM":  { emoji: "⛈️", category: "NATURE",   color: "#8888cc", ko: "폭풍. 비와 바람이 몰아치는 날씨예요.", en: "Violent weather with wind and rain.", difficulty: "NORMAL" },
	"FLAME":  { emoji: "🔥",  category: "NATURE",   color: "#ff4400", ko: "화염. 타오르는 불꽃이에요.", en: "A burning tongue of fire.", difficulty: "NORMAL" },
	"SHINE":  { emoji: "✨",  category: "LIGHT",    color: "#ffdd66", ko: "빛나다. 밝게 반짝이는 것이에요.", en: "To glow brightly.", difficulty: "NORMAL" },
	"LIGHT":  { emoji: "💡",  category: "LIGHT",    color: "#ffffaa", ko: "빛. 어둠을 밝혀주는 것이에요.", en: "Brightness that helps us see.", difficulty: "NORMAL" },

	// ---- HARD (6+ letters) ----
	"ROCKET":    { emoji: "🚀", category: "VEHICLE",  color: "#ddddff", ko: "로켓. 우주로 날아가는 비행체예요.", en: "A vehicle that flies into space.", difficulty: "HARD" },
	"GALAXY":    { emoji: "🌌", category: "SPACE",    color: "#9933ff", ko: "은하. 수많은 별들의 모임이에요.", en: "A huge group of stars in space.", difficulty: "HARD" },
	"PLANET":    { emoji: "🪐", category: "SPACE",    color: "#44aaff", ko: "행성. 별 주위를 도는 천체예요.", en: "A large object orbiting a star.", difficulty: "HARD" },
	"COSMOS":    { emoji: "🌠", category: "SPACE",    color: "#4488ff", ko: "우주. 끝없이 넓은 공간이에요.", en: "The entire universe.", difficulty: "HARD" },
	"NEBULA":    { emoji: "🌫️", category: "SPACE",    color: "#9933cc", ko: "성운. 우주의 아름다운 가스 구름이에요.", en: "A beautiful cloud of gas in space.", difficulty: "HARD" },
	"METEOR":    { emoji: "☄️", category: "SPACE",    color: "#ff7733", ko: "유성. 빛을 내며 떨어지는 돌이에요.", en: "A shooting star that falls from the sky.", difficulty: "HARD" },
	"SATURN":    { emoji: "🪐", category: "SPACE",    color: "#ddcc88", ko: "토성. 고리가 있는 행성이에요.", en: "The planet famous for its rings.", difficulty: "HARD" },
	"URANUS":    { emoji: "🪐", category: "SPACE",    color: "#66dddd", ko: "천왕성. 옆으로 누워 도는 행성이에요.", en: "An ice giant planet that spins on its side.", difficulty: "HARD" },
	"COMETS":    { emoji: "☄️", category: "SPACE",    color: "#ff6644", ko: "혜성들. 꼬리가 있는 우주 얼음 덩어리예요.", en: "Plural of comet - icy space objects with tails.", difficulty: "HARD" },
	"STARDUST":  { emoji: "✨", category: "SPACE",    color: "#ffdd66", ko: "별가루. 별이 만든 빛나는 먼지예요.", en: "Magical dust from stars.", difficulty: "HARD" },
	"SPACESHIP": { emoji: "🛸", category: "VEHICLE",  color: "#aabbff", ko: "우주선. 우주를 여행하는 배예요.", en: "A vehicle that travels through space.", difficulty: "HARD" },
	"ASTEROID":  { emoji: "☄️", category: "SPACE",    color: "#aa8866", ko: "소행성. 우주를 떠다니는 큰 바위예요.", en: "A large rock floating in space.", difficulty: "HARD" },
	"ANDROID":   { emoji: "🤖", category: "MACHINE",  color: "#99ccff", ko: "안드로이드. 사람처럼 생긴 로봇이에요.", en: "A robot that looks like a human.", difficulty: "HARD" },
	"CYBORG":    { emoji: "🦾", category: "MACHINE",  color: "#cc9999", ko: "사이보그. 기계와 생물이 합쳐진 존재예요.", en: "Part human, part machine.", difficulty: "HARD" },
	"VOLCANO":   { emoji: "🌋", category: "NATURE",   color: "#ff4411", ko: "화산. 불과 암석을 뿜어내는 산이에요.", en: "A mountain that erupts with lava.", difficulty: "HARD" },
	"CRYSTAL":   { emoji: "💎", category: "TREASURE", color: "#9933ff", ko: "크리스탈. 투명하고 빛나는 보석이에요.", en: "A clear, shiny, precious mineral.", difficulty: "HARD" },
	"THUNDER":   { emoji: "⚡", category: "NATURE",   color: "#ffdd00", ko: "천둥. 번개 칠 때 나는 큰 소리예요.", en: "The loud sound that follows lightning.", difficulty: "HARD" },
	"PHANTOM":   { emoji: "👻", category: "MAGIC",    color: "#9966ff", ko: "유령. 보이지 않는 신비한 존재예요.", en: "A mysterious ghostly figure.", difficulty: "HARD" },
	"HARDCORE":  { emoji: "💀", category: "GAME",     color: "#ff2222", ko: "하드코어. 아주 어려운 최고 난이도예요.", en: "The most difficult level of challenge.", difficulty: "HARD" },
	"VICTORY":   { emoji: "🏆", category: "GAME",     color: "#ffdd00", ko: "승리. 게임에서 이기는 것이에요.", en: "Winning the game!", difficulty: "HARD" },
};