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
## streak = 이 스킨을 해금하는 연속 접속 일수(0 = 기본 제공, -1 = 출석으로는 못 얻음).
## hull = 기체 실루엣. 없으면 기본 실루엣(DEFAULT_HULL)을 쓴다.
## product = 이 기체를 여는 상품 ID(StoreItems). 없으면 출석 보상으로만 얻는다.
##
## ⚠️ **출석 보상과 결제 상품은 계열을 나눈다.**
##    출석은 같은 실루엣의 **색 변주**, 결제는 **형태 변주**다.
##    같은 축으로 주면 결제가 출석 보상의 값어치를 깎는다.
const SKINS: Array[Dictionary] = [
	{
		"id": "aurora", "name_en": "AURORA", "streak": 0, "aura": 0, "hue": false,
		"body": Color(0.36, 1.15, 1.3), "glow": Color(0.3, 0.9, 1.0),
		"engine": Color(0.3, 0.9, 1.0, 0.8),
	},
	{
		"id": "solar", "name_en": "SOLAR", "streak": 3, "aura": 1, "hue": false,
		"body": Color(1.35, 1.0, 0.3), "glow": Color(1.0, 0.78, 0.25),
		"engine": Color(1.0, 0.72, 0.2, 0.85),
	},
	{
		"id": "plasma", "name_en": "PLASMA", "streak": 7, "aura": 1, "hue": false,
		"body": Color(1.3, 0.45, 1.25), "glow": Color(1.0, 0.35, 1.0),
		"engine": Color(1.0, 0.4, 1.0, 0.85),
	},
	{
		"id": "prism", "name_en": "PRISM", "streak": 15, "aura": 2, "hue": true,
		"body": Color(1.2, 1.2, 1.2), "glow": Color(1.0, 1.0, 1.0),
		"engine": Color(1.0, 1.0, 1.0, 0.85),
	},
	{
		"id": "nova", "name_en": "NOVA", "streak": 30, "aura": 2, "hue": false,
		"body": Color(1.45, 1.25, 0.75), "glow": Color(1.0, 0.9, 0.5),
		"engine": Color(1.0, 0.9, 0.55, 0.9),
	},
	# ---- 결제 기체: 형태가 다르다(출석 보상은 색만 다르다) ----
	{
		"id": "dart", "name_en": "DART", "streak": -1, "aura": 1, "hue": false,
		"hull": "dart", "product": "ship_dart",
		"body": Color(0.55, 1.3, 1.0), "glow": Color(0.4, 1.0, 0.85),
		"engine": Color(0.4, 1.0, 0.85, 0.85),
	},
	{
		"id": "aegis", "name_en": "AEGIS", "streak": -1, "aura": 1, "hue": false,
		"hull": "aegis", "product": "ship_aegis",
		"body": Color(1.15, 0.85, 1.35), "glow": Color(0.85, 0.6, 1.0),
		"engine": Color(0.85, 0.6, 1.0, 0.85),
	},
	{
		"id": "beetle", "name_en": "BEETLE", "streak": -1, "aura": 2, "hue": false,
		"hull": "beetle", "product": "ship_beetle",
		"body": Color(1.3, 1.0, 0.55), "glow": Color(1.0, 0.75, 0.35),
		"engine": Color(1.0, 0.75, 0.35, 0.85),
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


## 해당 연속 접속 일수에서 해금되는 스킨. 없으면 빈 사전.
static func by_streak(days: int) -> Dictionary:
	for s in SKINS:
		if int(s["streak"]) == days:
			return s
	return {}


## PRISM 처럼 색이 도는 스킨의 현재 색. t 는 누적 시간(초).
static func shifted(base: Color, t: float) -> Color:
	var c := Color.from_hsv(fposmod(t * 0.18, 1.0), 0.75, 1.0)
	# 밝기는 원래 스킨 값을 유지해 glow 세기가 흔들리지 않게 한다.
	return Color(c.r * base.r, c.g * base.g, c.b * base.b, base.a)
