class_name StoryData
## StoryData - NeonBlaster 세계관 데이터베이스
## 루미노스 은하의 스토리, 세력, 용어를 제공

# ============================================================
# 메인 스토리 (챕터)
# ============================================================
const STORY_INTRO := {
	"title": "프롤로그: 빛의 언어", "title_en": "Prologue: The Language of Light",
	"ko": """어느 먼 미래, 우주는 '루미나(Lumina)'라는 신비한 에너지로 가득 차 있었다.

루미나는 특별한 힘을 가진 에너지였다.
바로 '언어'를 물리적인 힘으로 바꾸는 능력.

별빛이 모이는 곳에서 태어난 단어들은 살아 숨 쉬며,
그것을 발음하는 자에게 강력한 힘을 부여했다.

그래서 우주의 모든 존재는 말을 조심했다.
한 단어가 곧 한 발의 포탄이 될 수 있었기 때문이다.

그러나 어둠의 심연에서 '보이드(Void)'라는 세력이 깨어났다.
그들은 빛의 언어를 삼키고, 우주를 침묵의 어둠으로 물들이려 한다.

이제 마지막 루미나 가디언인 너만이 은하를 지킬 수 있다.
단어의 힘을 쏴 적을 처치하고, 우주의 빛을 되찾아라!""",
	"en": """In a distant future, the universe was filled with a mysterious energy called 'Lumina'.

Lumina possessed a special power:
the ability to transform 'language' into physical force.

Words born where starlight gathered were alive and breathing,
granting mighty power to those who spoke them.

So every being in the cosmos chose their words with care,
for a single word could become a single cannon blast.

But from the abyss of darkness, a force called 'Void' awoke.
They devour the Words of Light, seeking to drown the universe in silent darkness.

Now, only you - the last Lumina Guardian - can defend the galaxy.
Fire the power of words to defeat the enemy, and reclaim the light of the cosmos!"""
}

# ============================================================
# 챕터 진행 (wave 구간별 스토리)
# ============================================================
const STORY_CHAPTERS: Array = [
	{
		"wave": 1,
		"title": "제1장: 보이드의 침공", "title_en": "Chapter 1: The Void Invasion",
		"ko": """보이드의 첫 번째 파병이 도착했다.
'추적자(Chaser)' 무리가 은하의 외곽을 향해 몰려온다.

이들은 작고 빠르지만, 단 한 발의 단어탄으로 처치할 수 있다.
조준하고, 쏴라. 루미나 가디언의 사격을 보여줘!""",
		"en": """The first wave of Void has arrived.
Swarms of 'Chasers' rush toward the galactic frontier.

They are small and fast, but fall to a single word-bullet.
Take aim, and fire. Show them the marksmanship of a Lumina Guardian!"""
	},
	{
		"wave": 3,
		"title": "제2장: 원거리 위협", "title_en": "Chapter 2: Threats from Afar",
		"ko": """이제 '포격수(Shooter)'들이 전장에 합류한다.
이들은 멀리서 어둠의 탄환을 쏴대는 위험한 적이다.

더 강한 단어가 필요하다. 콤보를 연속으로 쌓아
루미나의 배수된 힘을 느껴봐라!""",
		"en": """Now 'Shooters' join the battlefield.
These foes fire dark bullets from afar - truly dangerous.

Stronger words are needed. Chain your combos
and feel the multiplied power of Lumina!"""
	},
	{
		"wave": 5,
		"title": "제3장: 중갑의 벽", "title_en": "Chapter 3: The Armored Wall",
		"ko": """보이드의 '중갑병(Tank)'이 모습을 드러낸다.
두꺼운 어둠의 장갑은 단어 여러 발을 맞아야 뚫린다.

집중 공격으로 적의 방어를 돌파하라.
이들을 처치하면 귀중한 파워업을 얻을 수 있다!""",
		"en": """The Void 'Tank' reveals itself.
Its thick armor of darkness needs many word-bullets to pierce.

Focus your fire to break through their defense.
Defeating them yields precious power-ups!"""
	},
	{
		"wave": 8,
		"title": "제4장: 보이드의 분노", "title_en": "Chapter 4: Wrath of the Void",
		"ko": """보이드가 남은 네 병과를 모두 풀어놓는다.

지그재그로 파고드는 '돌진자(Dasher)',
품에서 터지는 '자폭병(Bomber)',
부수면 셋이 되는 '분열체(Splitter)',
스스로 상처를 메우는 '방벽병(Shielder)'.

하지만 두려워하지 마라.
파워업을 모아 레이저, 번개, 시간 감속 등
강력한 루미나의 기술을 사용할 수 있다!""",
		"en": """The Void unleashes its four remaining branches.

The zigzagging 'Dasher',
the 'Bomber' that bursts in your face,
the 'Splitter' that becomes three when broken,
the 'Shielder' that mends its own wounds.

But do not fear.
Collect power-ups to wield mighty Lumina arts -
Laser, Lightning, Time Slow and more!"""
	},
	{
		"wave": 12,
		"title": "제5장: 최후의 결전", "title_en": "Chapter 5: The Final Battle",
		"ko": """은하의 중심부. 별빛이 가장 밝은 곳에서
최후의 결전이 시작된다.

네가 쏘는 모든 단어는, 이 우주를 지키는 빛이 된다.
루미나 가디언이여, 끝까지 싸워라!""",
		"en": """The heart of the galaxy, where starlight burns brightest.
Here begins the final battle.

Every word you fire becomes light that guards this universe.
Fight on, Lumina Guardian, to the very end!"""
	}
]

# ============================================================
# 세력 소개
# ============================================================
const FACTIONS: Dictionary = {
	"GUARDIAN": {
		"name": "루미나 가디언",
		"name_en": "Lumina Guardian",
		"color": "0.3, 0.9, 1.0",
		"ko": """빛의 언어를 다루는 은하의 수호자.

네온 빛으로 이루어진 전투기를 조종하며,
적의 약점 알파벳을 맞춰 단어탄(Word Bullet)을 발사한다.

콤보를 연속으로 쌓을수록 루미나 에너지가 증폭되어
점수가 최대 5배까지 커진다.""",
		"en": """Defenders of the galaxy who wield the Words of Light.

They pilot neon fighters and fire Word Bullets
by matching the enemy's weak-point letters.

Chaining combos amplifies their Lumina energy,
boosting score up to 5x."""
	},
	"VOID": {
		"name": "보이드",
		"name_en": "The Void",
		"color": "1.0, 0.2, 0.5",
		"ko": """어둠의 심연에서 온 세력.

빛의 언어를 삼키고, 우주를 영원한 침묵으로
만들려는 존재들이다.

일곱 가지 병과로 구성된다:
• 추적자 (Chaser) - 빠르고 약한 정찰대
• 포격수 (Shooter) - 원거리 공격 담당
• 중갑병 (Tank) - 느리지만 강한 방어력
• 돌진자 (Dasher) - 지그재그로 파고드는 급습대
• 자폭병 (Bomber) - 접근해 열두 방향으로 터진다
• 분열체 (Splitter) - 부수면 셋으로 갈라진다
• 방벽병 (Shielder) - 스스로 체력을 되돌린다""",
		"en": """A force from the abyss of darkness.

They devour the Words of Light and seek to
condemn the universe to eternal silence.

Seven military branches:
• Chaser - fast, weak scouts
• Shooter - ranged attackers
• Tank - slow, heavily armored
• Dasher - zigzagging raiders
• Bomber - closes in and bursts twelve ways
• Splitter - breaks into three
• Shielder - regenerates its own health"""
	}
}

# ============================================================
# 적 상세 정보
# ============================================================
const ENEMY_LORE: Dictionary = {
	"CHASER": {
		"name": "추적자",
		"name_en": "Void Chaser",
		"ko": """보이드의 최전선 정찰 유닛.

크기는 작지만 속도가 빨라
초보 가디언에게 치명적이다.

하지만 장갑이 얇아 단 한 발의 단어탄으로 처치 가능하다.""",
		"en": """The frontline scout unit of the Void.

Small but fast, deadly to novice Guardians.
Thin armor means a single word-bullet suffices."""
	},
	"SHOOTER": {
		"name": "포격수",
		"name_en": "Void Shooter",
		"ko": """원거리 공격을 담당하는 보이드 병과.

어둠의 탄환을 발사하며,
처치하기 위해서는 더 강한 단어가 필요하다.""",
		"en": """The ranged branch of the Void.

Fires dark bullets and requires
stronger words to defeat."""
	},
	"TANK": {
		"name": "중갑병",
		"name_en": "Void Juggernaut",
		"ko": """두꺼운 어둠의 장갑으로 무장한 보이드 정예.

느리지만 매우 단단하며,
많은 단어탄을 맞아야 격파할 수 있다.

처치 시 높은 점수와 파워업을 보상으로 얻는다.""",
		"en": """A Void elite clad in thick dark armor.

Slow but very durable -
requires many word-bullets to destroy.

Yields high score and power-up rewards."""
	},
	"DASHER": {
		"name": "돌진자",
		"name_en": "Void Dasher",
		"ko": """지그재그로 파고드는 보이드의 급습 유닛.

보이드에서 가장 빠르며, 직선으로 오지 않아
조준선을 흘리며 품으로 파고든다.

대신 장갑이 가장 얇다 — 한 발이면 사라진다.""",
		"en": """A Void raider that weaves in a zigzag.

The fastest of the Void; it never comes straight,
slipping past your line of fire.

But its armor is the thinnest - one hit ends it."""
	},
	"BOMBER": {
		"name": "자폭병",
		"name_en": "Void Bomber",
		"ko": """제 몸을 폭탄으로 쓰는 보이드 결사대.

일직선으로 달려들다 가까워지면 점멸하기 시작하고,
잠시 뒤 열두 방향으로 어둠의 탄환을 터뜨린다.

깜빡이기 시작하면 이미 늦다 — 다가오기 전에 끊어라.""",
		"en": """A Void zealot that uses its own body as a bomb.

It charges in a straight line, starts blinking when close,
then bursts into twelve dark bullets.

Once it blinks it is already too late - cut it down early."""
	},
	"SPLITTER": {
		"name": "분열체",
		"name_en": "Void Splitter",
		"ko": """하나를 죽이면 셋이 되는 보이드의 증식체.

느리게 다가오지만, 부수는 순간 작은 셋으로 갈라진다.
갈라진 것들은 더 이상 나뉘지 않는다.

화면이 한산할 때 처리해 두는 편이 낫다 —
몰릴 때 부수면 그 자리에서 숫자가 불어난다.""",
		"en": """A Void breeder: kill one and three take its place.

It closes in slowly, but splits into three smaller
units the moment it breaks. Those do not split again.

Clear it while the screen is quiet - breaking it in
a crowd multiplies the crowd."""
	},
	"SHIELDER": {
		"name": "방벽병",
		"name_en": "Void Shielder",
		"ko": """스스로 상처를 메우는 보이드의 방벽.

가장 두꺼운 장갑에 더해 이 초마다 체력을 되돌리고,
여덟 방향으로 원형 탄막을 뿌린다.

화력이 재생을 넘지 못하면 영영 쓰러지지 않는다 —
연사를 올리고 한 번에 몰아쳐라.""",
		"en": """A Void bulwark that mends its own wounds.

On top of the thickest armor it regenerates every
two seconds and sprays bullets in eight directions.

If your damage cannot outpace its healing it will
never fall - raise your fire rate and burst it down."""
	}
}

# ============================================================
# 파워업 세계관
# ============================================================
const POWERUP_LORE: Dictionary = {
	"RAPID": {
		"name": "연사 룬",
		"name_en": "Rapid Rune",
		"ko": """발사 속도를 2배로 높여주는 빛의 룬.

잠시 동안 폭풍처럼 단어를 쏟아낼 수 있다.""",
		"en": """A rune of light that doubles fire rate.
Unleash a storm of words for a short time."""
	},
	"SPREAD": {
		"name": "확산 결정",
		"name_en": "Spread Crystal",
		"ko": """무기를 업그레이드하는 결정체.

단어탄이 부채꼴로 퍼지며, 더 넓은 적을 공격한다.""",
		"en": """A crystal that upgrades your weapon.
Word bullets spread in a fan, hitting wider areas."""
	},
	"SHIELD": {
		"name": "보호막 코어",
		"name_en": "Shield Core",
		"ko": """루미나의 힘으로 보호막을 생성.

잠시 동안 모든 피해를 막아준다.""",
		"en": """Generates a shield of Lumina.
Blocks all damage for a short duration."""
	},
	"BOMB": {
		"name": "정화 폭탄",
		"name_en": "Purge Bomb",
		"ko": """화면의 모든 적과 탄환을 정화하는 강력한 폭탄.

위기의 순간에 사용하라.""",
		"en": """A powerful bomb that purges all enemies and bullets on screen.
Use it in moments of crisis."""
	},
	"LASER": {
		"name": "루미나 레이저",
		"name_en": "Lumina Laser",
		"ko": """수직으로 뻗어나가는 순수 빛의 레이저.

레이저가 닿는 모든 적에게 연속 데미지를 입힌다.""",
		"en": """A vertical beam of pure light.
Deals continuous damage to all enemies in its path."""
	},
	"TIME_SLOW": {
		"name": "시간 왜곡",
		"name_en": "Time Warp",
		"ko": """루미나 에너지로 시간을 늦추는 마법.

적의 움직임이 느려져 숨통을 돌릴 수 있다.""",
		"en": """Magic that slows time with Lumina energy.
Enemies slow down, giving you breathing room."""
	},
	"LIGHTNING": {
		"name": "연쇄 번개",
		"name_en": "Chain Lightning",
		"ko": """적들 사이를 튕기는 번개.

최대 8명의 적을 연쇄로 처치한다.""",
		"en": """Lightning that bounces between enemies.
Chains to up to 8 targets."""
	}
}

# ============================================================
# 카테고리별 세계관 설명
# ============================================================
const CATEGORY_LORE: Dictionary = {
	"ALL": {
		"ko": "루미노스 은하의 모든 단어. 각 단어는 고유한 힘을 지닌다.",
		"en": "All words of the Luminous Galaxy. Each carries unique power."
	},
	"SPACE": {
		"ko": "별과 행성의 이름. 우주의 가장 순수한 루미나를 담고 있다.",
		"en": "Names of stars and planets. They hold the purest Lumina."
	},
	"ANIMAL": {
		"ko": "생명체의 이름. 다양한 행성의 동물에서 유래한 단어들.",
		"en": "Names of living creatures. Words from animals across many planets."
	},
	"NATURE": {
		"ko": "자연의 힘. 불, 폭풍, 얼음 등 파괴적인 자연 에너지를 상징한다.",
		"en": "Forces of nature. Fire, storm, ice - symbols of destructive elemental energy."
	},
	"SCIENCE": {
		"ko": "과학의 언어. 레이저, 기체 등 지성이 만들어낸 힘의 단어들.",
		"en": "The language of science. Laser, gas - words of power born from intellect."
	},
	"WEAPON": {
		"ko": "무기의 이름. 가장 직접적이고 파괴적인 루미나를 발산한다.",
		"en": "Names of weapons. They radiate the most direct and destructive Lumina."
	},
	"VEHICLE": {
		"ko": "탈것의 이름. 속도와 기동성의 에너지를 가진 단어들.",
		"en": "Names of vehicles. Words carrying energy of speed and mobility."
	},
	"MAGIC": {
		"ko": "마법의 단어. 신비롭고 예측 불가능한 힘을 숨기고 있다.",
		"en": "Words of magic. They hide mysterious and unpredictable power."
	},
	"COLOR": {
		"ko": "색의 이름. 루미나의 다양한 파장을 의미한다.",
		"en": "Names of colors. They represent the many wavelengths of Lumina."
	},
	"TREASURE": {
		"ko": "보물의 이름. 가치와 풍요의 에너지를 지닌 단어들.",
		"en": "Names of treasures. Words carrying energy of value and prosperity."
	},
	"BODY": {
		"ko": "신체의 이름. 생명 그 자체의 루미나를 상징한다.",
		"en": "Names of body parts. Symbols of life's own Lumina."
	},
	"FUN": {
		"ko": "즐거움의 단어. 가볍지만 결코 무시할 수 없는 밝은 에너지.",
		"en": "Words of fun. Light but bright energy, never to be dismissed."
	},
	"ACTION": {
		"ko": "행동의 단어. 움직임과 변화의 에너지를 담고 있다.",
		"en": "Words of action. Energy of movement and change."
	},
	"ENERGY": {
		"ko": "에너지의 단어. 루미나 그 자체와 가장 가까운 힘.",
		"en": "Words of energy. The force closest to Lumina itself."
	},
	"MACHINE": {
		"ko": "기계의 이름. 로봇과 안드로이드는 보이드와도 자주 동맹한다.",
		"en": "Names of machines. Robots and androids often ally with the Void."
	},
	"DEFENSE": {
		"ko": "방어의 단어. 보호와 인내의 에너지를 의미한다.",
		"en": "Words of defense. Energy of protection and endurance."
	},
	"LIGHT": {
		"ko": "빛의 단어. 루미나 가디언의 정수이자 가장 신성한 힘.",
		"en": "Words of light. The essence of Lumina Guardians, the most sacred power."
	},
	"GAME": {
		"ko": "게임의 단어. 승리와 도전의 에너지를 담고 있다.",
		"en": "Words of games. Energy of victory and challenge."
	}
}


# ============================================================
# 조회 함수
# ============================================================

## wave에 해당하는 챕터 인덱스 반환
static func get_chapter_index_for_wave(wave: int) -> int:
	var idx := -1
	for i in STORY_CHAPTERS.size():
		if wave >= STORY_CHAPTERS[i]["wave"]:
			idx = i
		else:
			break
	return idx


## wave에 해당하는 챕터 딕셔너리 반환 (없으면 null)
static func get_chapter_for_wave(wave: int) -> Dictionary:
	var idx := get_chapter_index_for_wave(wave)
	if idx >= 0:
		return STORY_CHAPTERS[idx]
	return {}


## 모든 파워업 키 반환
static func get_powerup_keys() -> Array:
	return POWERUP_LORE.keys()


## 모든 적 키 반환
static func get_enemy_keys() -> Array:
	return ENEMY_LORE.keys()


## 모든 세력 키 반환
static func get_faction_keys() -> Array:
	return FACTIONS.keys()