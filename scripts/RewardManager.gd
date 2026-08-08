extends Node
## RewardManager (Autoload)
## 매일 접속·플레이 시간에 대한 보상을 관리한다. 계속 플레이할 이유를 만드는 장치.
##
## 두 축으로 본다:
##   1. 하루 플레이 시간 — 오늘 DAILY_GOAL_SECONDS 이상 플레이하면 보상 1회
##   2. 연속 접속 일수(streak) — 3/7/15/30일 마일스톤마다 보상 1회
##
## 보상은 두 종류다:
##   - **기체 스킨** — 영구 해금, 순수 코스메틱. 눈에 보이는 보상이 여기다([[ShipSkins]]).
##   - **화력 버프**(무기 레벨·연사·점수 배수) — **다음 판에만** 적용.
## ⚠️ 성능 보상을 영구로 주면 맞춰 놓은 난이도가 무너진다
##    (사망률 EASY 0% / NORMAL 20% / HARD 60%). 그래서 영구인 것은 코스메틱뿐이다.
## ⚠️ 목숨은 보상에서 뺐다 — 숫자만 늘고 화면에 드러나지 않아 보상으로 느껴지지 않았다.
##
## ⚠️ 날짜는 **로컬 날짜 문자열(YYYY-MM-DD)** 로 비교한다. 유닉스 시간으로 24시간을 재면
##    자정을 넘겨도 "같은 날"이 되거나 그 반대가 되어 출석 판정이 어긋난다.

signal daily_goal_reached()
signal skin_unlocked(skin_id: String)
signal streak_milestone_reached(days: int)
signal reward_claimed(kind: String, days: int)

const SAVE_PATH := "user://neonblaster_rewards.cfg"
## 하루 목표 플레이 시간(초).
const DAILY_GOAL_SECONDS := 600.0
## 연속 접속 보상이 나오는 지점.
const STREAK_MILESTONES: Array[int] = [3, 7, 15, 30]
## 한 판에 얹을 수 있는 버프 상한(누적 수령 방지). 30일 보상 한 개와 같은 크기.
const MAX_PENDING_WEAPON := 2
const MAX_PENDING_FIRE_RATE := 1.4

## 오늘 날짜(YYYY-MM-DD)와 오늘 누적 플레이 시간.
var today: String = ""
var today_seconds: float = 0.0
## 연속 접속 일수와 마지막으로 플레이한 날짜.
var streak_days: int = 0
var last_played: String = ""
## 이미 수령한 보상. "daily:2026-08-08", "streak:7" 형태로 저장한다.
var _claimed: Dictionary = {}
## 다음 판에 적용될 보류 중인 버프.
## ⚠️ 목숨은 일부러 뺐다 — 숫자가 늘 뿐 화면에 드러나지 않아 보상으로 느껴지지 않았다.
##    보이는 보상은 화력(탄 개수·연사)과 기체 스킨이 담당한다.
var pending_weapon: int = 0
var pending_fire_rate: float = 1.0
var pending_score_mult: float = 1.0

## 해금한 기체 스킨(영구)과 현재 장착 중인 스킨.
var unlocked_skins: Dictionary = {ShipSkins.DEFAULT_ID: true}
var equipped_skin: String = ShipSkins.DEFAULT_ID

var _daily_emitted: bool = false


func _ready() -> void:
	_load()
	_roll_over_day()


func _process(delta: float) -> void:
	# 실제로 플레이 중일 때만 시간을 센다 — 메뉴를 켜둔 시간은 "플레이"가 아니다.
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	_roll_over_day()
	today_seconds += delta
	if not _daily_emitted and today_seconds >= DAILY_GOAL_SECONDS:
		_daily_emitted = true
		_save()
		daily_goal_reached.emit()


## 날짜가 바뀌었으면 오늘 기록을 초기화하고 연속 일수를 갱신한다.
func _roll_over_day() -> void:
	var d := _today_string()
	if d == today:
		return
	today = d
	today_seconds = 0.0
	_daily_emitted = false

	if last_played == "":
		streak_days = 1
	elif last_played == _yesterday_string():
		streak_days += 1
	elif last_played != d:
		# 하루 이상 걸렀다 — 연속 기록이 끊긴다.
		streak_days = 1
	last_played = d
	_save()

	for m in STREAK_MILESTONES:
		if streak_days == m and not is_claimed("streak", m):
			streak_milestone_reached.emit(m)


func _today_string() -> String:
	var t := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [t["year"], t["month"], t["day"]]


func _yesterday_string() -> String:
	var unix := Time.get_unix_time_from_system() - 86400.0
	var t := Time.get_date_dict_from_unix_time(int(unix))
	return "%04d-%02d-%02d" % [t["year"], t["month"], t["day"]]


# ---------------- 수령 ----------------

func is_claimed(kind: String, days: int = 0) -> bool:
	return _claimed.has(_key(kind, days))


## 지금 받을 수 있는 보상 목록. 메뉴가 이걸로 버튼을 만든다.
func get_claimable() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if today_seconds >= DAILY_GOAL_SECONDS and not is_claimed("daily"):
		out.append({"kind": "daily", "days": 0, "label": "TODAY 10 MIN"})
	for m in STREAK_MILESTONES:
		if streak_days >= m and not is_claimed("streak", m):
			out.append({"kind": "streak", "days": m, "label": "%d DAY STREAK" % m})
	return out


## 보상을 수령해 다음 판 버프로 쌓는다. 이미 받았으면 아무 일도 하지 않는다.
func claim(kind: String, days: int = 0) -> bool:
	if is_claimed(kind, days):
		return false
	_claimed[_key(kind, days)] = true
	match kind:
		"daily":
			pending_weapon += 1
		"streak":
			match days:
				3:
					pending_weapon += 1
				7:
					pending_weapon += 2
				15:
					pending_weapon += 2
					pending_fire_rate = maxf(pending_fire_rate, 1.25)
				30:
					pending_weapon += 2
					pending_fire_rate = maxf(pending_fire_rate, 1.4)
					pending_score_mult = maxf(pending_score_mult, 2.0)
			# 마일스톤마다 기체 스킨을 해금하고 바로 장착한다 —
			# 받은 즉시 타이틀 화면의 기체가 바뀌어 보상이 눈에 보인다.
			var skin: Dictionary = ShipSkins.by_streak(days)
			if not skin.is_empty():
				unlock_skin(String(skin["id"]), true)
	# 여러 보상을 한꺼번에 수령하면(30일까지 안 열어본 경우) 버프가 누적된다.
	# 가장 센 단일 보상(30일)을 천장으로 잡는다 — 정상 흐름에서는 닿지 않는다.
	pending_weapon = mini(pending_weapon, MAX_PENDING_WEAPON)
	pending_fire_rate = minf(pending_fire_rate, MAX_PENDING_FIRE_RATE)
	_save()
	reward_claimed.emit(kind, days)
	return true


## 게임 시작 시 호출 — 쌓인 버프를 돌려주고 비운다(다음 판에만 적용).
func consume_pending() -> Dictionary:
	var out := {
		"weapon": pending_weapon,
		"fire_rate": pending_fire_rate,
		"score_mult": pending_score_mult,
	}
	pending_weapon = 0
	pending_fire_rate = 1.0
	pending_score_mult = 1.0
	_save()
	return out


func _key(kind: String, days: int) -> String:
	# 일일 보상은 날짜별로, 연속 보상은 일수별로 한 번씩만 받는다.
	return "daily:%s" % today if kind == "daily" else "streak:%d" % days


# ---------------- 기체 스킨 ----------------

func is_skin_unlocked(id: String) -> bool:
	return unlocked_skins.has(id)


func unlock_skin(id: String, equip: bool = false) -> void:
	unlocked_skins[id] = true
	if equip:
		equipped_skin = id
	_save()
	skin_unlocked.emit(id)


func equip_skin(id: String) -> bool:
	if not is_skin_unlocked(id):
		return false
	equipped_skin = id
	_save()
	return true


func get_equipped_skin() -> Dictionary:
	return ShipSkins.get_skin(equipped_skin)


# ---------------- 저장 ----------------

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("reward", "today", today)
	cfg.set_value("reward", "today_seconds", today_seconds)
	cfg.set_value("reward", "streak_days", streak_days)
	cfg.set_value("reward", "last_played", last_played)
	cfg.set_value("reward", "claimed", _claimed.keys())
	cfg.set_value("reward", "pending_weapon", pending_weapon)
	cfg.set_value("reward", "pending_fire_rate", pending_fire_rate)
	cfg.set_value("reward", "pending_score_mult", pending_score_mult)
	cfg.set_value("reward", "unlocked_skins", unlocked_skins.keys())
	cfg.set_value("reward", "equipped_skin", equipped_skin)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	today = cfg.get_value("reward", "today", "")
	today_seconds = cfg.get_value("reward", "today_seconds", 0.0)
	streak_days = cfg.get_value("reward", "streak_days", 0)
	last_played = cfg.get_value("reward", "last_played", "")
	_claimed.clear()
	for k in cfg.get_value("reward", "claimed", []):
		_claimed[String(k)] = true
	pending_weapon = cfg.get_value("reward", "pending_weapon", 0)
	pending_fire_rate = cfg.get_value("reward", "pending_fire_rate", 1.0)
	pending_score_mult = cfg.get_value("reward", "pending_score_mult", 1.0)
	unlocked_skins = {ShipSkins.DEFAULT_ID: true}
	for k in cfg.get_value("reward", "unlocked_skins", []):
		unlocked_skins[String(k)] = true
	equipped_skin = cfg.get_value("reward", "equipped_skin", ShipSkins.DEFAULT_ID)
	if not unlocked_skins.has(equipped_skin):
		equipped_skin = ShipSkins.DEFAULT_ID
	_daily_emitted = today_seconds >= DAILY_GOAL_SECONDS
