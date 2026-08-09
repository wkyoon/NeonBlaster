extends Node
## DifficultyDirector (Autoload)
## 난이도를 플레이어가 고르지 않는다. **한 판이 목표 시간쯤에 끝나도록** 게임이 맞춘다.
##
## 왜 선택을 없앴나:
##   지하철·버스 대기 같은 틈새 시간용 게임이라 켤 때마다 판단을 요구하면 안 된다.
##   그리고 상위 난이도를 열수록 더 자주 죽어서 **보상으로 연 것이 벌처럼** 느껴졌다
##   (실측 사망률 EASY 0% → HARD 50%).
##
## 대신 "얼마나 오래 버티느냐"를 성장 축으로 삼는다:
##   · 처음 시작하면 약 `BASE_TARGET`(10분) 안에 죽는다 — 판에 확실한 끝이 생긴다.
##   · 하루 플레이할 때마다 목표가 `MINUTE_PER_DAY`(1분)씩 늘어난다.
##   · 하루 거르면 거른 날수만큼 다시 줄어든다(처음으로 조금씩 되돌아간다).
##
## ⚠️ EASY 는 사망률 0% 라 **판이 영영 끝나지 않았다**. 틈새 게임에서 이건 결함이다 —
##    플레이어가 스스로 끊어야 하고, 그러면 성취 없이 종료된다.
##    그래서 강도를 **경과 시간에 따라** 올려 목표 시간 근처에서 반드시 죽게 만든다.
##
## ⚠️ 이 값은 `RewardManager.streak_days` 와 다르다. streak 은 하루만 걸러도 1로 초기화되지만
##    여기 `bonus_minutes` 는 **거른 날수만큼만** 줄어든다("조금씩 되돌아간다").

signal target_changed(seconds: float)

const SAVE_PATH := "user://neonblaster_dda.cfg"

## 처음 시작하는 사람의 목표 생존 시간.
const BASE_TARGET := 600.0
## 하루 플레이할 때마다 늘어나는 시간, 하루 거를 때마다 줄어드는 시간.
const MINUTE_PER_DAY := 60.0
## 늘어날 수 있는 최대 분수. 30분이면 틈새 시간 게임의 상한으로 충분하다.
const MAX_BONUS_MINUTES := 20

## 강도 곡선의 세 지점. 경과 시간 비율(progress)에 따라 이 사이를 보간한다.
## CALM(초반) → INTENSE(목표 시간) → LETHAL(초과 구간, 확실히 죽는다)
## ⚠️ CALM/INTENSE 는 예전 EASY/NORMAL 실측값이다(사망률 0% / 20%, 10게임·오차 0.15).
const CALM := {
	"spawn_interval": 0.98, "enemy_hp": 0.24, "enemy_speed": 0.68,
	"wave_duration": 1.25, "bullet_speed": 0.55,
}
const INTENSE := {
	"spawn_interval": 0.52, "enemy_hp": 0.32, "enemy_speed": 0.75,
	"wave_duration": 1.0, "bullet_speed": 0.65,
}
## 목표 시간을 넘겼을 때 도달하는 지점. 여기까지 오면 버티기 어렵다 —
## 판에 끝을 보장하는 장치라서 의도적으로 가혹하게 잡는다.
const LETHAL := {
	"spawn_interval": 0.28, "enemy_hp": 0.44, "enemy_speed": 1.05,
	"wave_duration": 0.7, "bullet_speed": 0.95,
}

## 시작 직후 잔잔한 구간. 목표 시간의 `CALM_RATIO` 만큼 두되 `CALM_MAX` 를 넘지 않는다.
## ⚠️ 순수 비율(0.35)만 쓰면 목표 30분에서 잔잔한 구간이 10분을 넘어 오래 한 사람일수록
##    초반이 지루하다(실측 동시 적 2.0 → 1.5 → 1.3).
## ⚠️ 210초로 잡았더니 10분 판의 첫 3.5분이 강도 0 이라 **밋밋했다**(실측 동시 적 1.4).
##    시간은 잔잔한 도입부가 아니라 러시 사이의 **골짜기**와 낮은 치사율로 번다.
const CALM_RATIO := 0.35
const CALM_MAX := 45.0
## 밀도(화면이 얼마나 북적이는가)와 치사율(얼마나 위험한가)은 **다른 속도로** 오른다.
##
## 왜 나눴나: 둘을 같은 곡선으로 올리면 긴 판에서 중반이 길어진 만큼 피격이 누적돼
## 목표 시간 전에 죽는다(실측 30분 목표에서 1328초 = 74%). 반대로 곡선을 통째로 늦추면
## 화면이 한산해 지루하다(동시 적 1.4).
## 그래서 **밀도는 초반에 빨리 올리고(스펙터클), 치사율은 뒤에 몰아준다(끝맺음)**.
## 이 게임의 목적이 "잘하는 것처럼 느끼게" 하는 것이므로 화려함과 위험은 붙어 있을 이유가 없다.
const DENSITY_SHAPE := 0.5   # 작을수록 일찍 북적인다
const LETHAL_SHAPE := 3.0    # 클수록 위험이 늦게 온다
## 밀도 쪽 노브와 치사율 쪽 노브.
const DENSITY_KEYS: Array[String] = ["spawn_interval", "enemy_hp", "wave_duration"]
## 목표 시간을 이 배수만큼 넘기면 LETHAL 에 도달한다.
const LETHAL_AT := 1.25

## ---- 러시 리듬 ----
## 강도를 평탄하게 올리기만 하면 **밋밋하다**. 실측: 30분 판 내내 동시 적 0.8~3.0,
## 평균 1.6 — 클라이맥스도 리듬도 없었다.
## 슈팅 게임의 기본 재미는 "밀려온다 → 쓸어낸다 → 숨 돌린다"의 반복이다.
## 예전에는 웨이브마다 조여드는 계단이 그 역할을 했는데, 웨이브 램프를 없애며 리듬까지 사라졌다.
##
## ⚠️ 러시는 **밀도에만** 얹는다. 치사율까지 같이 흔들면 죽는 타이밍이 운에 좌우된다.
const RUSH_PERIOD := 30.0
## 러시 최고조에서 밀도 진행도를 이만큼 밀어올린다.
const RUSH_STRENGTH := 0.55

## 하루 플레이로 쌓인 보너스 분수(0 ~ MAX_BONUS_MINUTES).
var bonus_minutes: int = 0
## 이 값을 마지막으로 갱신한 날짜(YYYY-MM-DD).
var last_day: String = ""
## 벤치마크 전용 강제 강도(-1 이면 사용 안 함).
var force_intensity: float = -1.0

## 이번 판의 경과 시간. Game 이 매 프레임 넘겨준다.
var _elapsed: float = 0.0


func _ready() -> void:
	_load()
	RewardManager.day_advanced.connect(_on_day_advanced)


## 오늘 목표 생존 시간.
func get_target_seconds() -> float:
	return BASE_TARGET + bonus_minutes * MINUTE_PER_DAY


## 하루가 지났을 때 RewardManager 가 알려준다. days_missed 는 건너뛴 날수(0 = 어제 했음).
func _on_day_advanced(days_missed: int) -> void:
	if days_missed <= 0:
		bonus_minutes = mini(bonus_minutes + 1, MAX_BONUS_MINUTES)
	else:
		# 거른 날수만큼 되돌린다. streak 처럼 0 으로 초기화하지 않는다 —
		# 며칠 못 했다고 그동안 늘린 걸 통째로 잃으면 돌아올 이유가 사라진다.
		bonus_minutes = maxi(bonus_minutes - days_missed, 0)
	_save()
	target_changed.emit(get_target_seconds())


## Game 이 매 프레임 경과 시간을 넘긴다.
func set_elapsed(seconds: float) -> void:
	_elapsed = seconds


func reset_run() -> void:
	_elapsed = 0.0


## 지금 강도(0=CALM, 1=INTENSE, 그 이상은 LETHAL 쪽으로).
func get_intensity() -> float:
	if force_intensity >= 0.0:
		return force_intensity
	var calm := minf(get_target_seconds() * CALM_RATIO, CALM_MAX)
	if _elapsed <= calm:
		return 0.0
	var span := maxf(1.0, get_target_seconds() - calm)
	var progress := (_elapsed - calm) / span
	# 여기서는 **선형 진행도**만 돌려준다. 밀도/치사율의 곡선 차이는 get_multipliers 가 준다.
	return maxf(progress, 0.0)


## 현재 강도에 해당하는 스포너 배수. EnemySpawner 가 적을 만들 때마다 읽는다.
func get_multipliers() -> Dictionary:
	var p := get_intensity()
	var base := clampf(p, 0.0, 1.0)
	# 밀도는 초반에 빨리 오르고(스펙터클), 치사율은 뒤에 몰린다(끝맺음).
	var t_density := pow(base, DENSITY_SHAPE) if p <= 1.0 else p
	var t_lethal := pow(base, LETHAL_SHAPE) if p <= 1.0 else p
	# 러시가 밀도를 주기적으로 밀어올린다. 골짜기에서 숨을 돌리고 마루에서 쏟아진다.
	t_density = minf(t_density + _rush_factor() * RUSH_STRENGTH, LETHAL_AT)

	var out := {}
	for key in CALM:
		out[key] = _blend(key, t_density if key in DENSITY_KEYS else t_lethal)
	return out


## 0(골짜기) ~ 1(마루) 로 오가는 러시 계수.
func _rush_factor() -> float:
	return (1.0 - cos(TAU * _elapsed / RUSH_PERIOD)) * 0.5


## 진행도 t 를 CALM → INTENSE → LETHAL 구간에 대응시킨다.
func _blend(key: String, t: float) -> float:
	if t <= 1.0:
		return lerpf(float(CALM[key]), float(INTENSE[key]), maxf(t, 0.0))
	var over := clampf((t - 1.0) / maxf(0.01, LETHAL_AT - 1.0), 0.0, 1.0)
	return lerpf(float(INTENSE[key]), float(LETHAL[key]), over)


## 표시용 단계(1~5). 점수 기록에만 쓴다 — 플레이 중에 띄우면 결국 난이도를 의식하게 된다.
func get_level() -> int:
	return clampi(bonus_minutes / 4 + 1, 1, 5)


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("dda", "bonus_minutes", bonus_minutes)
	cfg.set_value("dda", "last_day", last_day)
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	bonus_minutes = clampi(int(cfg.get_value("dda", "bonus_minutes", 0)), 0, MAX_BONUS_MINUTES)
	last_day = cfg.get_value("dda", "last_day", "")
