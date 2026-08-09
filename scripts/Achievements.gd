class_name Achievements
extends RefCounted
## 훈장 정의. 목표를 채우면 하나씩 열린다.
##
## ⚠️ **훈장은 성능에 아무 영향이 없다.** 순수하게 "해냈다"는 기록이다.
##    화력이나 기체를 걸면 훈장을 모으는 게 의무가 되고, 이 게임의 목적(학습)에서 멀어진다.
##
## ⚠️ **플레이 중에는 화면에 늘어놓지 않는다.** 이 게임의 각인 대상은 단어다 —
##    훈장이 화면을 차지하면 정작 단어가 안 보인다(콤보 UI 를 없앤 것과 같은 이유).
##    딴 순간에만 배너로 알리고, 평소에는 메뉴의 훈장 화면에 모아 둔다.
##
## 조건은 이미 추적 중인 값에서 읽는다 — 새로 저장할 것이 없다:
##   STREAK   연속 접속 일수(RewardManager.streak_days)
##   PLAYTIME 누적 플레이 시간(RewardManager.total_seconds)
##   WORDS    도감 수집 수(WordManager.get_collection_progress)
##   THEMES   완주한 테마 수
##   RUN_WORDS 한 판에서 완성한 단어 수 (Game 이 넘긴다)
##   SURVIVE  한 판에서 목표 시간을 채웠는가 (Game 이 넘긴다)

enum Kind { STREAK, PLAYTIME, WORDS, THEMES, RUN_WORDS, SURVIVE }

## tier: 1 동 / 2 은 / 3 금. 색과 형태가 달라진다.
const BADGES: Array[Dictionary] = [
	# ---- 연속 접속 — 보상에서 뺀 축을 기록으로 남긴다 ----
	{"id": "streak3", "kind": Kind.STREAK, "goal": 3, "tier": 1,
		"name": "THREE DAYS", "desc": "3일 연속 플레이"},
	{"id": "streak7", "kind": Kind.STREAK, "goal": 7, "tier": 2,
		"name": "ONE WEEK", "desc": "7일 연속 플레이"},
	{"id": "streak30", "kind": Kind.STREAK, "goal": 30, "tier": 3,
		"name": "ONE MONTH", "desc": "30일 연속 플레이"},
	# ---- 누적 플레이 ----
	{"id": "time1h", "kind": Kind.PLAYTIME, "goal": 3600, "tier": 1,
		"name": "ONE HOUR", "desc": "누적 1시간"},
	{"id": "time10h", "kind": Kind.PLAYTIME, "goal": 36000, "tier": 3,
		"name": "TEN HOURS", "desc": "누적 10시간"},
	# ---- 학습: 이 게임의 본체 ----
	{"id": "words50", "kind": Kind.WORDS, "goal": 50, "tier": 1,
		"name": "FIRST FIFTY", "desc": "단어 50개 수집"},
	{"id": "words150", "kind": Kind.WORDS, "goal": 150, "tier": 2,
		"name": "HALFWAY", "desc": "단어 150개 수집"},
	{"id": "words300", "kind": Kind.WORDS, "goal": 300, "tier": 3,
		"name": "ALL WORDS", "desc": "단어 300개 전부 수집"},
	{"id": "theme1", "kind": Kind.THEMES, "goal": 1, "tier": 1,
		"name": "FIRST THEME", "desc": "테마 1개 완주"},
	{"id": "theme10", "kind": Kind.THEMES, "goal": 10, "tier": 2,
		"name": "TEN THEMES", "desc": "테마 10개 완주"},
	{"id": "theme25", "kind": Kind.THEMES, "goal": 25, "tier": 3,
		"name": "EVERY THEME", "desc": "테마 25개 전부 완주"},
	# ---- 한 판의 성과 ----
	{"id": "run20", "kind": Kind.RUN_WORDS, "goal": 20, "tier": 1,
		"name": "TWENTY IN A RUN", "desc": "한 판에 단어 20개"},
	{"id": "run50", "kind": Kind.RUN_WORDS, "goal": 50, "tier": 2,
		"name": "FIFTY IN A RUN", "desc": "한 판에 단어 50개"},
	{"id": "survive", "kind": Kind.SURVIVE, "goal": 1, "tier": 3,
		"name": "FULL SURVIVAL", "desc": "목표 시간까지 생존"},
]

## 등급별 색. 동/은/금.
const TIER_COLORS: Array[Color] = [
	Color(0.85, 0.55, 0.35),
	Color(0.80, 0.85, 0.92),
	Color(1.00, 0.82, 0.30),
]


static func get_badge(id: String) -> Dictionary:
	for b in BADGES:
		if b["id"] == id:
			return b
	return {}


static func tier_color(tier: int) -> Color:
	return TIER_COLORS[clampi(tier - 1, 0, TIER_COLORS.size() - 1)]


## 지금 상태에서 달성한 훈장 id 목록.
## `run_words` / `survived` 는 방금 끝난 판의 결과다(없으면 0/false).
static func earned_now(run_words: int = 0, survived: bool = false) -> Array[String]:
	var mastered := 0
	for st in ThemeStages.STAGES:
		if WordManager.is_theme_mastered(String(st["id"])):
			mastered += 1
	var collected := WordManager.get_collection_progress().x

	var out: Array[String] = []
	for b in BADGES:
		var value := 0.0
		match b["kind"]:
			Kind.STREAK:
				value = float(RewardManager.streak_days)
			Kind.PLAYTIME:
				value = RewardManager.total_seconds
			Kind.WORDS:
				value = float(collected)
			Kind.THEMES:
				value = float(mastered)
			Kind.RUN_WORDS:
				value = float(run_words)
			Kind.SURVIVE:
				value = 1.0 if survived else 0.0
		if value >= float(b["goal"]):
			out.append(String(b["id"]))
	return out


## 진행률 문구. 잠긴 훈장에도 "얼마나 왔는지"를 보여준다.
static func progress_text(id: String) -> String:
	var b := get_badge(id)
	if b.is_empty():
		return ""
	match b["kind"]:
		Kind.STREAK:
			return "%d / %d DAYS" % [RewardManager.streak_days, int(b["goal"])]
		Kind.PLAYTIME:
			return "%d / %d MIN" % [int(RewardManager.total_seconds / 60.0), int(b["goal"]) / 60]
		Kind.WORDS:
			return "%d / %d WORDS" % [WordManager.get_collection_progress().x, int(b["goal"])]
		Kind.THEMES:
			var n := 0
			for st in ThemeStages.STAGES:
				if WordManager.is_theme_mastered(String(st["id"])):
					n += 1
			return "%d / %d THEMES" % [n, int(b["goal"])]
		Kind.RUN_WORDS:
			return "%d WORDS IN ONE RUN" % int(b["goal"])
		Kind.SURVIVE:
			return "REACH THE SURVIVAL GOAL"
	return ""
