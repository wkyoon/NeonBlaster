extends SceneTree
## 적 구성 실측 (개발용).
##
##   godot --headless --fixed-fps 60 --path . --script tools/enemy_mix_check.gd
##   ENEMY_BONUS=20 ENEMY_TIME=600 godot --headless --fixed-fps 60 --path . --script tools/enemy_mix_check.gd
##
## 종류별로 **몇 마리 나오는지**가 아니라 **얼마나 살아서 무엇을 했는지**를 본다.
## 소개를 7종으로 늘려도 특수 행동이 발동 전에 죽으면 체감은 여전히 3종이다.
##
## ⚠️ `--fixed-fps 60` 없이 돌리면 재현되지 않는다(AGENTS.md 측정 함정 1).
## ⚠️ 도감 수집이 오염되지 않게 저장을 끄고 학습 상태를 비운다(측정 함정 0).

const TYPE_NAMES := ["CHASER", "SHOOTER", "TANK", "DASHER", "BOMBER", "SPLITTER", "SHIELDER",
	"SWARM", "TURRET", "PHANTOM"]

## DASHER 지그재그 한 주기. ⚠️ `Enemy._behave` 의 `_zigzag_phase += delta * N` 과 맞출 것 —
## 게임 쪽만 바꾸면 옛 기준으로 재게 되어 수치가 통째로 무의미해진다(실제로 겪었다).
const ZIGZAG_RATE := 20.0
const ZIGZAG_PERIOD := TAU / ZIGZAG_RATE
## BOMBER 는 점화 후 이 시간이 지나야 실제로 터진다(`_fire_timer = 0.5`).
const BOMB_FUSE := 0.5

var _t: float = 0.0
var _elapsed: float = 0.0
var _game: Node = null
var _limit: float = 300.0
var _screen_h: float = 1280.0

## instance_id -> 관측 기록
var _seen: Dictionary = {}
## 타입별 집계
var _stats: Dictionary = {}
var _children_spawned: int = 0
## ⚠️ --script 모드에서는 오토로드가 전역 식별자로 안 잡힌다. 노드로 들고 있는다.
var _gm: Node = null
var _player_y: Array[float] = []
## 적 탄 누적 수. 자폭병 격추 폭발이 실제로 탄을 뿌리는지, 그리고 그 탄이
## 판을 얼마나 무겁게 하는지(밸런스 비용)를 직접 센다.
var _enemy_bullets_seen: Dictionary = {}
var _enemy_bullet_total: int = 0


func _initialize() -> void:
	_limit = float(_env("ENEMY_TIME", "300"))
	seed(int(_env("ENEMY_SEED", "42")))
	for name in TYPE_NAMES:
		_stats[name] = {
			"spawned": 0, "lifetimes": [] as Array[float], "death_y": [] as Array[float],
			"special": 0, "special_full": 0,
		}


func _process(delta: float) -> bool:
	_t += delta
	if _game == null:
		if _t < 0.3:
			return false
		_start()
		return false

	_elapsed += delta
	_scan(delta)
	# ⚠️ 플레이어 위치를 모르면 "적이 위에서 죽는다"를 해석할 수 없다.
	#    기체가 위로 붙어 있어서인지, 탄 사거리 때문인지 구분되지 않는다.
	var p := _game.get_node_or_null("Player")
	if p != null:
		_player_y.append(p.global_position.y / _screen_h * 100.0)

	if _elapsed >= _limit or _gm.current_state != _gm.GameState.PLAYING:
		_report()
		quit(0)
		return true
	return false


func _start() -> void:
	_gm = root.get_node("GameManager")
	var gm := _gm
	var wm := root.get_node("WordManager")
	var dd := root.get_node("DifficultyDirector")
	var rm := root.get_node("RewardManager")

	# 측정이 스스로를 바꾸지 않게 한다(AGENTS.md 측정 함정 0).
	wm.persist_enabled = false
	wm._collected.clear()
	wm.reset_learning()
	wm.set_stage(0)

	var bonus := int(_env("ENEMY_BONUS", "0"))
	dd.force_intensity = -1.0
	dd.bonus_minutes = bonus
	# 그 시점의 플레이어가 실제로 갖고 있을 랭크로 맞춘다(측정 함정 0-1).
	rm.bench_rank_override = 0 if bonus <= 0 else (1 if bonus < 10 else 2)

	gm.auto_play = true
	gm.ai_dodge_error = float(_env("ENEMY_AI_ERROR", "0.15"))

	_game = load("res://scenes/Game.tscn").instantiate()
	root.add_child(_game)
	current_scene = _game
	_screen_h = root.get_visible_rect().size.y
	print("측정 시작 — 보너스 %d분 (목표 %.0f초) / 관측 %.0f초" % [
		bonus, dd.get_target_seconds(), _limit])


func _scan(delta: float) -> void:
	var alive := {}
	for e in _game.get_tree().get_nodes_in_group("enemy"):
		var id := e.get_instance_id()
		alive[id] = true
		if not _seen.has(id):
			var is_child: bool = bool(e.get("_is_child"))
			if is_child:
				_children_spawned += 1
			_seen[id] = {
				"type": int(e.enemy_type), "born": _elapsed, "last": _elapsed,
				"y": e.global_position.y, "is_child": is_child,
				"bomb_at": -1.0, "hp_dropped": false, "regen": false,
				"parked": false, "phased": false,
				"max_hp": int(e.get("health")),
			}
			if not is_child:
				_stats[TYPE_NAMES[int(e.enemy_type)]]["spawned"] += 1
			continue

		var rec: Dictionary = _seen[id]
		rec["last"] = _elapsed
		rec["y"] = e.global_position.y

		# BOMBER: 점화 시각을 기록해 두면 실제로 터졌는지(도화선을 다 태웠는지) 알 수 있다.
		if rec["bomb_at"] < 0.0 and bool(e.get("_bomb_triggered")):
			rec["bomb_at"] = _elapsed

		if bool(e.get("_turret_parked")):
			rec["parked"] = true
		if bool(e.get("_phased")):
			rec["phased"] = true

		# SHIELDER: 체력이 깎였다가 다시 오르면 재생이 실제로 일어난 것이다.
		var hp := int(e.get("health"))
		if hp < int(rec["max_hp"]):
			rec["hp_dropped"] = true
		elif bool(rec["hp_dropped"]) and hp > 0:
			rec["regen"] = true
		rec["max_hp"] = maxi(int(rec["max_hp"]), hp)

	for b in _game.get_tree().get_nodes_in_group("enemy_bullet"):
		var bid := b.get_instance_id()
		if not _enemy_bullets_seen.has(bid):
			_enemy_bullets_seen[bid] = true
			_enemy_bullet_total += 1

	for id in _seen.keys():
		if alive.has(id):
			continue
		_retire(_seen[id])
		_seen.erase(id)


func _retire(rec: Dictionary) -> void:
	# 분열로 생긴 자식은 원래 종류의 통계를 흐린다 — 따로 센다.
	if bool(rec["is_child"]):
		return
	var name: String = TYPE_NAMES[int(rec["type"])]
	var life: float = float(rec["last"]) - float(rec["born"])
	var s: Dictionary = _stats[name]
	(s["lifetimes"] as Array).append(life)
	(s["death_y"] as Array).append(float(rec["y"]) / _screen_h * 100.0)

	# "특수 행동을 보여줬는가" 의 기준은 종류마다 다르다.
	match name:
		"DASHER":
			# 지그재그를 한 주기라도 그렸는가
			if life >= ZIGZAG_PERIOD:
				s["special"] += 1
			if life >= ZIGZAG_PERIOD * 2.0:
				s["special_full"] += 1
		"BOMBER":
			# 이제 격추돼도 터지므로 사실상 전부 폭발한다. '완전발동' 은 접근 자폭
			# (도화선을 다 태운 경우)만 센다 — 원래 의도한 연출이 살아 있는지 보는 값이다.
			s["special"] += 1
			if float(rec["bomb_at"]) >= 0.0 and float(rec["last"]) - float(rec["bomb_at"]) >= BOMB_FUSE:
				s["special_full"] += 1
		"SPLITTER":
			s["special"] += 1                  # 죽으면 무조건 분열한다
			s["special_full"] += 1
		"TURRET":
			# 멈춰 서서 한 발이라도 쐈는가. 정지 지점까지 못 가면 그냥 느린 적이다.
			if bool(rec["parked"]):
				s["special"] += 1
				s["special_full"] += 1
		"PHANTOM":
			# 한 번이라도 흐려졌는가(= 탄이 통과하는 구간을 보여줬는가)
			if bool(rec["phased"]):
				s["special"] += 1
				s["special_full"] += 1
		"SHIELDER":
			if bool(rec["regen"]):
				s["special"] += 1
				s["special_full"] += 1
		_:
			s["special"] += 1
			s["special_full"] += 1


func _report() -> void:
	print("\n관측 %.0f초 / 총 스폰 %d마리 (분열 자식 %d 제외)" % [
		_elapsed, _total_spawned(), _children_spawned])
	print("%-9s %6s %7s %9s %9s %10s %10s" % [
		"종류", "스폰", "비율", "수명중앙", "사망위치", "특수발동", "완전발동"])
	print("-".repeat(70))
	for name in TYPE_NAMES:
		var s: Dictionary = _stats[name]
		var n: int = int(s["spawned"])
		if n == 0:
			print("%-9s %6d %7s %9s %9s %10s %10s" % [name, 0, "-", "-", "-", "-", "-"])
			continue
		var lifes: Array = s["lifetimes"]
		var deaths: int = lifes.size()
		print("%-9s %6d %6.1f%% %8.2fs %8.0f%% %9s %9s" % [
			name, n, float(n) / float(_total_spawned()) * 100.0,
			_median(lifes), _median(s["death_y"]),
			_pct(int(s["special"]), deaths), _pct(int(s["special_full"]), deaths)])
	print("적 탄 누적 %d발 (%.1f발/초)" % [
		_enemy_bullet_total, float(_enemy_bullet_total) / maxf(_elapsed, 1.0)])
	var py := _median(_player_y)
	print("\n플레이어 세로 위치 중앙 %.0f%% → 탄 사거리 %.0f%% 위까지 닿는다(BULLET_RANGE_RATIO 0.60)" % [
		py, maxf(py - 60.0, 0.0)])
	print("· 사망위치 = 화면 세로 기준(0%% 위, 100%% 아래). 낮을수록 위에서 죽는다.")
	print("· 특수발동 = 그 종류의 특징을 한 번이라도 보여준 비율.")
	print("  DASHER 지그재그 1주기 / BOMBER 점화 / SHIELDER 체력재생 / SPLITTER 분열(항상)")
	print("· 완전발동 = 끝까지 간 비율. BOMBER 는 실제 폭발, DASHER 는 2주기.")


func _total_spawned() -> int:
	var t := 0
	for name in TYPE_NAMES:
		t += int(_stats[name]["spawned"])
	return t


func _median(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var a := values.duplicate()
	a.sort()
	return float(a[a.size() / 2])


func _pct(part: int, whole: int) -> String:
	if whole <= 0:
		return "-"
	return "%.0f%%" % (float(part) / float(whole) * 100.0)


func _env(key: String, fallback: String) -> String:
	var v := OS.get_environment(key)
	return v if v != "" else fallback
