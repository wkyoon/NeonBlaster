class_name StoreItems
extends RefCounted
## 상점에서 파는 것들의 **단일 출처**. ThemeStages 가 단어의 단일 출처인 것과 같은 방식이다.
##
## ⚠️ **기본은 절대 팔지 않는다.**
##    단어 300개, 25테마, 출석·랭크·도감, 모든 게임 기능은 전부 무료다.
##    학습에 필요한 것을 잠그면 "공부를 돈 주고 사는" 게임이 된다.
##    파는 것은 **없어도 되지만 있으면 내 화면이 달라지는 것**뿐이다.
##
## ⚠️ **출석 보상과 계열을 나눈다.**
##    출석 = 같은 실루엣의 **색 변주**(AURORA→NOVA), 결제 = **형태 변주**(DART/AEGIS/BEETLE).
##    같은 축으로 주면 결제가 출석 보상의 값어치를 깎는다.
##
## ⚠️ 가격은 여기 적지 않는다. Google Play 에서 받아 와야 나라별 통화·현지 가격이 맞고,
##    자체 결제는 정책 위반이다. 여기 있는 `id` 는 Play Console 의 상품 ID 와 **정확히 같아야** 한다.

enum Kind { SHIP, REVEAL, SUPPORT }

const ITEMS: Array[Dictionary] = [
	{
		"id": "ship_dart", "kind": Kind.SHIP, "ref": "dart",
		"name": "DART", "desc": "길고 날카로운 기체. 빠른 인상.",
		"desc_en": "A long, sharp hull. Built for speed.",
	},
	{
		"id": "ship_aegis", "kind": Kind.SHIP, "ref": "aegis",
		"name": "AEGIS", "desc": "넓고 묵직한 기체. 단단한 인상.",
		"desc_en": "A wide, heavy hull. Built to hold the line.",
	},
	{
		"id": "ship_beetle", "kind": Kind.SHIP, "ref": "beetle",
		"name": "BEETLE", "desc": "날개가 벌어진 기체. 유기적인 인상.",
		"desc_en": "Spread wings. Something alive.",
	},
	{
		"id": "ship_raptor", "kind": Kind.SHIP, "ref": "raptor",
		"name": "RAPTOR", "desc": "날개 끝이 위로 꺾인 기체. 맹금의 인상.",
		"desc_en": "Wingtips swept upward. A bird of prey.",
	},
	{
		"id": "ship_halo", "kind": Kind.SHIP, "ref": "halo",
		"name": "HALO", "desc": "고리가 벌어지고 색이 도는 기체.",
		"desc_en": "Open rings, shifting colors.",
	},
	{
		"id": "reveal_ink", "kind": Kind.REVEAL, "ref": "ink",
		"name": "INK", "desc": "단어가 먹물처럼 번지며 나타납니다.",
		"desc_en": "Words bloom like ink on paper.",
	},
	{
		"id": "reveal_glass", "kind": Kind.REVEAL, "ref": "glass",
		"name": "GLASS", "desc": "단어가 유리처럼 조각나며 나타납니다.",
		"desc_en": "Words shatter into place like glass.",
	},
	{
		"id": "support_tip", "kind": Kind.SUPPORT, "ref": "",
		"name": "SUPPORT", "desc": "만든 사람을 응원합니다. 기체에 작은 배지가 붙습니다.",
		"desc_en": "Back the developer. Adds a small badge to your ship.",
	},
]


static func get_item(id: String) -> Dictionary:
	for it in ITEMS:
		if it["id"] == id:
			return it
	return {}


## 한 종류의 상품만 추린다. 상점이 종류별로 묶어서 보여준다.
static func by_kind(kind: Kind) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for it in ITEMS:
		if it["kind"] == kind:
			out.append(it)
	return out


static func kind_label(kind: Kind) -> String:
	match kind:
		Kind.SHIP:
			return "🚀 SHIPS"
		Kind.REVEAL:
			return "✦ WORD EFFECTS"
		Kind.SUPPORT:
			return "❤ SUPPORT"
	return ""


## 모든 상품 ID. PurchaseManager 가 Play 에 가격을 물을 때 쓴다.
static func all_ids() -> PackedStringArray:
	var out := PackedStringArray()
	for it in ITEMS:
		out.append(String(it["id"]))
	return out
