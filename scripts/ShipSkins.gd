class_name ShipSkins
extends RefCounted
## 기체 스킨 정의. 출석 보상으로 해금되는 **눈에 보이는** 보상이다.
##
## 목숨 +1 같은 숫자 보상은 화면에 드러나지 않아 "받았다"는 느낌이 약했다.
## 스킨은 판을 시작하는 순간부터 계속 보이고, 타이틀 화면 엠블럼에도 반영된다.
##
## ⚠️ 스킨은 **영구 해금 + 순수 코스메틱**이다. 성능에 영향을 주면 안 된다
##    (성능 보상은 그 판에만 적용되는 무기/연사 버프 쪽이 담당한다).
## ⚠️ 색이 1.0 을 넘는 것은 의도적이다 — `neon_env.tres` 의 glow_hdr_threshold 가 1.0 이라
##    1.0 을 초과하는 픽셀만 번진다. 상위 스킨일수록 더 세게 번지도록 값을 올렸다.

const DEFAULT_ID := "aurora"

## body/glow/engine = 기체 폴리곤 · PointLight2D · 분사 파티클 색.
## aura = 기체 주위 링 연출 강도(0 없음 / 1 단일 링 / 2 이중 링 + 궤도 스파크).
## hue = 시간에 따라 색상환을 도는 스킨(PRISM).
## rank = 이 스킨을 해금하는 **누적 플레이 랭크**(0 = 기본 제공, -1 = 랭크로는 못 얻음).
## hull = 기체 실루엣. 없으면 기본 실루엣(DEFAULT_HULL)을 쓴다.
## product = 이 기체를 여는 상품 ID(StoreItems).
## collect = 이 기체를 여는 **도감 수집 개수**. 이 게임의 본체는 학습이므로
##           단어를 모으는 것 자체가 기체로 보상돼야 한다.
##
## 기체를 얻는 축은 셋이고 서로 겹치지 않는다:
##   플레이시간(rank) → 색 변주 / **수집(collect) → 형태 변주(무료)** / 결제(product) → 형태 변주
##
## ⚠️ **출석 보상과 결제 상품은 계열을 나눈다.**
##    출석은 같은 실루엣의 **색 변주**, 결제는 **형태 변주**다.
##    같은 축으로 주면 결제가 출석 보상의 값어치를 깎는다.
const SKINS: Array[Dictionary] = [
	{
		"id": "aurora", "name_en": "AURORA", "rank": 0, "aura": 0, "hue": false,
		"body": Color(0.36, 1.15, 1.3), "glow": Color(0.3, 0.9, 1.0),
		"engine": Color(0.3, 0.9, 1.0, 0.8),
	},
	{
		"id": "solar", "name_en": "SOLAR", "rank": 1, "aura": 1, "hue": false,
		"body": Color(1.35, 1.0, 0.3), "glow": Color(1.0, 0.78, 0.25),
		"engine": Color(1.0, 0.72, 0.2, 0.85),
	},
	{
		"id": "plasma", "name_en": "PLASMA", "rank": 2, "aura": 1, "hue": false,
		"body": Color(1.3, 0.45, 1.25), "glow": Color(1.0, 0.35, 1.0),
		"engine": Color(1.0, 0.4, 1.0, 0.85),
	},
	{
		"id": "prism", "name_en": "PRISM", "rank": 3, "aura": 2, "hue": true,
		"body": Color(1.2, 1.2, 1.2), "glow": Color(1.0, 1.0, 1.0),
		"engine": Color(1.0, 1.0, 1.0, 0.85),
	},
	{
		"id": "nova", "name_en": "NOVA", "rank": 4, "aura": 2, "hue": false,
		"body": Color(1.45, 1.25, 0.75), "glow": Color(1.0, 0.9, 0.5),
		"engine": Color(1.0, 0.9, 0.55, 0.9),
	},
	# ---- 수집 기체: 단어를 모으면 열린다(무료). 학습이 곧 보상이다 ----
	{
		"id": "wing", "name_en": "WING", "rank": -1, "aura": 0, "hue": false,
		"hull": "wing", "collect": 25,
		"body": Color(0.9, 1.2, 0.7), "glow": Color(0.7, 1.0, 0.5),
		"engine": Color(0.7, 1.0, 0.5, 0.8),
	},
	{
		"id": "delta", "name_en": "DELTA", "rank": -1, "aura": 0, "hue": false,
		"hull": "delta", "collect": 75,
		"body": Color(0.7, 1.0, 1.25), "glow": Color(0.5, 0.85, 1.0),
		"engine": Color(0.5, 0.85, 1.0, 0.8),
	},
	{
		"id": "fork", "name_en": "FORK", "rank": -1, "aura": 1, "hue": false,
		"hull": "fork", "collect": 150,
		"body": Color(1.25, 0.9, 0.7), "glow": Color(1.0, 0.7, 0.45),
		"engine": Color(1.0, 0.7, 0.45, 0.85),
	},
	{
		"id": "star", "name_en": "STAR", "rank": -1, "aura": 2, "hue": false,
		"hull": "star", "collect": 300,
		"body": Color(1.35, 1.2, 0.6), "glow": Color(1.0, 0.9, 0.4),
		"engine": Color(1.0, 0.9, 0.4, 0.9),
	},
	# ---- 결제 기체: 형태가 다르다(출석 보상은 색만 다르다) ----
	{
		"id": "dart", "name_en": "DART", "rank": -1, "aura": 1, "hue": false,
		"hull": "dart", "product": "ship_dart",
		"body": Color(0.55, 1.3, 1.0), "glow": Color(0.4, 1.0, 0.85),
		"engine": Color(0.4, 1.0, 0.85, 0.85),
	},
	{
		"id": "aegis", "name_en": "AEGIS", "rank": -1, "aura": 1, "hue": false,
		"hull": "aegis", "product": "ship_aegis",
		"body": Color(1.15, 0.85, 1.35), "glow": Color(0.85, 0.6, 1.0),
		"engine": Color(0.85, 0.6, 1.0, 0.85),
	},
	{
		"id": "beetle", "name_en": "BEETLE", "rank": -1, "aura": 2, "hue": false,
		"hull": "beetle", "product": "ship_beetle",
		"body": Color(1.3, 1.0, 0.55), "glow": Color(1.0, 0.75, 0.35),
		"engine": Color(1.0, 0.75, 0.35, 0.85),
	},
	{
		"id": "raptor", "name_en": "RAPTOR", "rank": -1, "aura": 2, "hue": false,
		"hull": "raptor", "product": "ship_raptor",
		"body": Color(1.35, 0.6, 0.6), "glow": Color(1.0, 0.4, 0.4),
		"engine": Color(1.0, 0.4, 0.4, 0.85),
	},
	{
		"id": "halo", "name_en": "HALO", "rank": -1, "aura": 2, "hue": true,
		"hull": "halo", "product": "ship_halo",
		"body": Color(1.2, 1.2, 1.2), "glow": Color(1.0, 1.0, 1.0),
		"engine": Color(1.0, 1.0, 1.0, 0.85),
	},
]

## 기본 기체 실루엣. Player.tscn 의 Sprite 폴리곤과 같은 모양이라
## 미리보기·타이틀 엠블럼·게임 내 기체가 모두 같은 기호로 읽힌다.
static var DEFAULT_HULL: PackedVector2Array = PackedVector2Array([
	Vector2(0, -25), Vector2(-18, 15), Vector2(-8, 10),
	Vector2(0, 18), Vector2(8, 10), Vector2(18, 15)
])

## 결제 기체의 실루엣. 폴리곤만 다르면 완전히 다른 기체로 읽힌다 —
## 절차적 _draw 라 에셋 없이 형태를 늘릴 수 있다.
static var HULLS: Dictionary = {
	# ---- 수집으로 여는 형태 (무료) ----
	# 삼각 날개 — 가장 단순한 변형. 첫 수집 보상.
	"wing": PackedVector2Array([
		Vector2(0, -22), Vector2(-20, 14), Vector2(0, 6), Vector2(20, 14),
	]),
	# 델타익 — 뒤로 젖혀진 날개.
	"delta": PackedVector2Array([
		Vector2(0, -26), Vector2(-6, 2), Vector2(-24, 16), Vector2(0, 10),
		Vector2(24, 16), Vector2(6, 2),
	]),
	# 갈래형 — 앞이 둘로 갈라진다.
	"fork": PackedVector2Array([
		Vector2(-7, -26), Vector2(-3, -6), Vector2(-18, 16), Vector2(0, 8),
		Vector2(18, 16), Vector2(3, -6), Vector2(7, -26), Vector2(0, -14),
	]),
	# 별형 — 네 갈래로 뻗는다. 마지막 수집 보상.
	"star": PackedVector2Array([
		Vector2(0, -28), Vector2(-8, -8), Vector2(-26, 0), Vector2(-9, 7),
		Vector2(-14, 24), Vector2(0, 12), Vector2(14, 24), Vector2(9, 7),
		Vector2(26, 0), Vector2(8, -8),
	]),
	# ---- 결제로 여는 형태 ----
	# 화살형 — 길고 날카롭다. 빠른 인상.
	"dart": PackedVector2Array([
		Vector2(0, -30), Vector2(-9, 6), Vector2(-16, 18), Vector2(-5, 13),
		Vector2(0, 20), Vector2(5, 13), Vector2(16, 18), Vector2(9, 6),
	]),
	# 방패형 — 넓고 묵직하다. 단단한 인상.
	"aegis": PackedVector2Array([
		Vector2(0, -20), Vector2(-14, -10), Vector2(-22, 8), Vector2(-10, 16),
		Vector2(0, 12), Vector2(10, 16), Vector2(22, 8), Vector2(14, -10),
	]),
	# 곤충형 — 날개가 벌어진다. 유기적인 인상.
	"beetle": PackedVector2Array([
		Vector2(0, -24), Vector2(-7, -8), Vector2(-21, -2), Vector2(-12, 8),
		Vector2(-6, 18), Vector2(0, 12), Vector2(6, 18), Vector2(12, 8),
		Vector2(21, -2), Vector2(7, -8),
	]),
	# 맹금형 — 날개 끝이 위로 꺾인다.
	"raptor": PackedVector2Array([
		Vector2(0, -27), Vector2(-8, -6), Vector2(-24, -12), Vector2(-16, 6),
		Vector2(-8, 18), Vector2(0, 11), Vector2(8, 18), Vector2(16, 6),
		Vector2(24, -12), Vector2(8, -6),
	]),
	# 고리형 — 몸통 뒤로 고리가 벌어진다.
	"halo": PackedVector2Array([
		Vector2(0, -25), Vector2(-6, -4), Vector2(-19, 4), Vector2(-13, 20),
		Vector2(-5, 10), Vector2(0, 22), Vector2(5, 10), Vector2(13, 20),
		Vector2(19, 4), Vector2(6, -4),
	]),
}


## 이 스킨의 실루엣. 지정이 없으면 기본형.
static func get_hull(skin: Dictionary) -> PackedVector2Array:
	var key := String(skin.get("hull", ""))
	return HULLS.get(key, DEFAULT_HULL)


static func get_skin(id: String) -> Dictionary:
	for s in SKINS:
		if s["id"] == id:
			return s
	return SKINS[0]


## 수집 개수로 열리는 스킨들. 수집이 늘 때 확인한다.
static func by_collect_threshold(count: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for s in SKINS:
		if s.has("collect") and int(s["collect"]) <= count:
			out.append(s)
	return out


## 이 랭크까지 열리는 스킨들.
static func by_rank(rank: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for s in SKINS:
		var r := int(s.get("rank", -1))
		if r >= 0 and r <= rank:
			out.append(s)
	return out


## 정확히 이 랭크에서 열리는 스킨. 없으면 빈 사전.
static func at_rank(rank: int) -> Dictionary:
	for s in SKINS:
		if int(s.get("rank", -1)) == rank:
			return s
	return {}


## PRISM 처럼 색이 도는 스킨의 현재 색. t 는 누적 시간(초).
static func shifted(base: Color, t: float) -> Color:
	var c := Color.from_hsv(fposmod(t * 0.18, 1.0), 0.75, 1.0)
	# 밝기는 원래 스킨 값을 유지해 glow 세기가 흔들리지 않게 한다.
	return Color(c.r * base.r, c.g * base.g, c.b * base.b, base.a)
