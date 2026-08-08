extends Node
## WordManager (Autoload)
## 게임용 단어 데이터를 관리하고 현재 타겟 단어와 진행 상황을 추적합니다.
##
## ## 단어 구성은 **주제(테마)** 단위다
## 글자 수 기준 난이도 분할(3글자/4-5글자/6+)은 폐기했다. 단어는 [ThemeStages](ThemeStages.gd) 의
## 주제별 묶음에서 나오고, 한 테마의 단어를 `WORDS_PER_STAGE`개 완성하면 **다음 테마 스테이지**로
## 넘어간다(배경 팔레트·파티클 모티프도 함께 전환된다).
## 그래서 한 테마 안에 RED(3글자)와 YELLOW(6글자)가 같이 들어간다 — 주제가 1순위다.
##
## ⚠️ `Difficulty`(EASY/NORMAL/HARD)는 **단어와 무관**하다. 적 밀도·속도·체력만 담당한다
##    ([EnemySpawner._get_diff_mult](EnemySpawner.gd) 참조).
##
## 테마 안에서의 단어 순서는 학습 원칙을 가중치로 결합해 정한다:
##   1. 간격 반복 노출 (Spaced Repetition): 방금 배운 단어는 적절한 간격으로 다시 등장해
##      기억을 굳히고, 충분히 학습된 단어는 점점 덜 등장합니다.
##   2. 새 단어 우대: 아직 안 본 단어를 먼저 보여줍니다.

signal word_completed(word: String)
signal word_progress_updated(filled: String, target: String)
signal new_word_started(word: String)
## 테마 스테이지가 바뀔 때 (배경 전환용). stage 는 ThemeStages.STAGES 의 항목.
signal stage_changed(index: int, stage: Dictionary)
## 한 테마의 목표 단어 수를 다 채웠을 때 (클리어 연출용).
signal stage_cleared(index: int, stage: Dictionary)
## 처음 수집한 단어일 때만 발생한다(도감에 새로 등록됨).
signal word_collected(word: String, total: int, goal: int)
## 한 테마의 단어를 **전부** 모았을 때 발생한다(중간 목표 달성).
signal theme_mastered(theme_id: String, name_en: String)

enum Difficulty { EASY, NORMAL, HARD }

const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# --- 단어 학습 가중치 설정 (튜닝 포인트) ---
const ASSOCIATION_BONUS := 2.5   # 같은 카테고리 연관성 가산점 (테마 후보가 없어 전체에서 뽑을 때만 작용)
const REPETITION_BONUS := 1.8    # 최근 학습 단어 반복 강화 가산점
const REPETITION_GAP_MAX := 4    # 이 간격(선택 횟수) 이내에서 반복 강화 적용
const REPETITION_GAP_MIN := 3    # 이 간격보다 가까우면 반복 강화 안 함 (바로 또 나오는 느낌 방지)
const NOVELTY_BONUS := 1.2       # 새 단어(첫 노출) 우대 가산점
const MASTERY_THRESHOLD := 4     # 이 횟수 이상 노출 시 숙달로 간주
const MASTERY_PENALTY := 0.3     # 숙달 단어 가중치 감소 비율(곱)


## 적 밸런스용 난이도. 단어 구성과는 무관하다.
var current_difficulty: Difficulty = Difficulty.EASY
var current_word: String = ""
var _filled_indices: Array[int] = []
# 단어별 학습 통계: word -> {"exposure": int, "last_seen": int}
# Autoload이므로 게임 재시작에도 유지되어 여러 판에 걸친 학습이 누적됩니다.
var _word_stats: Dictionary = {}
# 단어 선택 카운터 (간격 반복 계산용). 세션 전체에 걸쳐 단조 증가.
var _selection_counter: int = 0

# --- 테마 스테이지 진행 상태 ---
## 현재 테마 스테이지 인덱스 (ThemeStages.STAGES 기준).
var stage_index: int = 0
## 현재 스테이지에서 완성한 단어들. 크기가 WORDS_PER_STAGE 에 닿으면 다음 스테이지로.
var _stage_done: Array[String] = []

## 도감 수집 기록. 완성한 적 있는 단어 → true.
## ⚠️ 학습 통계(_word_stats)와 달리 **디스크에 저장**한다. 수집은 앱을 껐다 켜도 남아야
## 모으는 동기가 생긴다(예전에는 오토로드 메모리에만 있어 재시작하면 사라졌다).
var _collected: Dictionary = {}
const COLLECTION_PATH := "user://neonblaster_collection.cfg"


func _ready() -> void:
	_load_collection()


func set_difficulty(diff: Difficulty) -> void:
	current_difficulty = diff


## 현재 테마 스테이지 정보 (id / name_ko / words / bg / accent / particle / motif).
func get_stage() -> Dictionary:
	return ThemeStages.get_stage(stage_index)


## 현재 스테이지의 단어 풀. (WordSim 등 기존 호출부 호환용 이름)
##
## 기본 단어 8개를 **모두 수집한 뒤에는** 심화 단어가 합류한다.
## 단, 한 번에 하나만 — 아직 수집하지 않은 심화 단어 중 **맨 앞 하나**만 넣는다.
## 어려운 단어를 한꺼번에 풀면 전부 반쯤 익힌 상태로 흩어져 학습이 무너진다.
func get_word_list() -> Array:
	var words: Array = ThemeStages.get_words(stage_index)
	var next_adv := get_pending_advanced()
	if next_adv != "":
		words.append(next_adv)
	return words


## 이 테마에서 지금 노출 중인 심화 단어. 없으면 "".
## 기본 단어를 전부 모으기 전에는 항상 "" 다.
func get_pending_advanced() -> String:
	for w in ThemeStages.get_words(stage_index):
		if not is_collected(w):
			return ""
	for w in ThemeStages.get_advanced(stage_index):
		if not is_collected(w):
			return w
	return ""


## 현재 스테이지에서 완성한 단어 수 / 목표 수.
func get_stage_progress() -> Vector2i:
	return Vector2i(_stage_done.size(), ThemeStages.WORDS_PER_STAGE)


## 테마 스테이지를 특정 인덱스로 설정하고 진행을 초기화합니다. (스테이지 전환 / 게임 시작)
func set_stage(index: int) -> void:
	stage_index = posmod(index, maxi(1, ThemeStages.count()))
	_stage_done.clear()
	stage_changed.emit(stage_index, get_stage())


## 가중치 기반으로 현재 테마 안에서 새 단어를 선택합니다.
## 가중치는 (1) 간격 반복 강화, (2) 새 단어 우대, (3) 숙달 단어 감소,
## (4) 연속 중복 회피, (5) 이번 스테이지에서 이미 완성한 단어 회피를 결합합니다.
func start_new_word() -> String:
	var current_category: String = _get_category(current_word)

	# 현재 테마의 단어 중, 이번 스테이지에서 아직 완성하지 않은 것들이 후보다.
	var all_words: Array = get_word_list()
	var words: Array = []
	for w in all_words:
		if not _stage_done.has(w):
			words.append(w)
	# 후보가 없으면(테마 단어 수 < 목표 수 등) 테마 전체로 폴백해 항상 진행 가능하게 한다.
	if words.is_empty():
		words = all_words
	if words.is_empty():
		return current_word

	# 각 단어의 가중치를 계산
	var weights: Array[float] = []
	weights.resize(words.size())
	var total_weight := 0.0
	for i in words.size():
		var w: String = words[i]
		var weight := _compute_weight(w, current_category)
		weights[i] = weight
		total_weight += weight

	# 가중치 룰렛 선택
	var chosen: String = words[0]
	if total_weight > 0.0:
		var roll := randf() * total_weight
		var cumulative := 0.0
		for i in words.size():
			cumulative += weights[i]
			if roll <= cumulative:
				chosen = words[i]
				break

	# 노출 기록 및 상태 설정
	_record_exposure(chosen)
	current_word = chosen
	_filled_indices.clear()
	word_progress_updated.emit(get_display_word(), current_word)
	new_word_started.emit(current_word)
	return current_word


## 단일 단어의 선택 가중치를 계산합니다.
func _compute_weight(word: String, current_category: String) -> float:
	# 직전 단어와 같으면 연속 중복 방지
	if word == current_word and current_word != "":
		return 0.0

	var stats: Dictionary = _get_or_init_stats(word)
	var exposure: int = int(stats.get("exposure", 0))
	var last_seen: int = int(stats.get("last_seen", -999))

	var weight := 1.0
	var category := _get_category(word)

	# 1) 연관성: 현재 카테고리와 같으면 가산
	if category != "" and category == current_category:
		weight += ASSOCIATION_BONUS

	# 2) 간격 반복 강화: 최근 1~(MASTERY-1)회 노출된 단어가
	#    적절한 간격(REPETITION_GAP_MAX 이내)이면 가산
	if exposure >= 1 and exposure < MASTERY_THRESHOLD:
		var gap := _selection_counter - last_seen
		if gap >= REPETITION_GAP_MIN and gap <= REPETITION_GAP_MAX:
			weight += REPETITION_BONUS

	# 3) 새 단어(첫 노출) 우대
	if exposure == 0:
		weight += NOVELTY_BONUS

	# 4) 숙달 단어는 가중치 감소
	if exposure >= MASTERY_THRESHOLD:
		weight *= MASTERY_PENALTY

	return weight


## 단어의 카테고리를 WordDictionary에서 조회합니다. (없으면 빈 문자열)
func _get_category(word: String) -> String:
	if word == "":
		return ""
	return String(WordDictionary.get_description(word).get("category", ""))


## 단어의 학습 통계를 가져오거나 초기화합니다.
func _get_or_init_stats(word: String) -> Dictionary:
	if not _word_stats.has(word):
		_word_stats[word] = {"exposure": 0, "last_seen": -999}
	return _word_stats[word]


## 단어 노출을 기록합니다. (start_new_word에서 선택 시 호출)
func _record_exposure(word: String) -> void:
	_selection_counter += 1
	var stats: Dictionary = _get_or_init_stats(word)
	stats["exposure"] = int(stats["exposure"]) + 1
	stats["last_seen"] = _selection_counter


## ---------------- 도감 수집 ----------------

func is_collected(word: String) -> bool:
	return _collected.has(word.to_upper())


## (모은 수, 전체 수집 가능 수). 전체는 테마에 실제로 등장하는 단어만 센다 —
## 게임에 나오지 않는 단어를 목표에 넣으면 도감을 영원히 못 채운다.
func get_collection_progress() -> Vector2i:
	# 도감이 심화 단어까지 보여주므로 총수에도 함께 센다(48 → 72).
	# ⚠️ 테마 완주(mastery)는 여전히 **기본 8개** 기준이다 — get_theme_progress 참조.
	var goal := ThemeStages.get_all_words()
	goal.append_array(ThemeStages.get_all_advanced())
	var got := 0
	for w in goal:
		if _collected.has(w):
			got += 1
	return Vector2i(got, goal.size())


## 특정 테마의 (모은 수, 전체 수).
func get_theme_progress(theme_id: String) -> Vector2i:
	for st in ThemeStages.STAGES:
		if String(st["id"]) != theme_id:
			continue
		var words: Array = st["words"]
		var got := 0
		for w in words:
			if _collected.has(w):
				got += 1
		return Vector2i(got, words.size())
	return Vector2i(0, 0)


func is_theme_mastered(theme_id: String) -> bool:
	var p := get_theme_progress(theme_id)
	return p.y > 0 and p.x >= p.y


## 가장 가까운 목표(남은 개수가 가장 적은 미완성 테마). 메뉴가 "다음에 뭘 하면 되는지" 보여줄 때 쓴다.
## "48개 중 3개" 보다 "동물 3개 남음" 이 훨씬 강한 동기다.
func get_next_goal() -> Dictionary:
	var best := {}
	for st in ThemeStages.STAGES:
		var p := get_theme_progress(String(st["id"]))
		if p.x >= p.y:
			continue
		var left: int = p.y - p.x
		if best.is_empty() or left < int(best["left"]):
			best = {"id": st["id"], "name_en": st["name_en"], "left": left, "got": p.x, "goal": p.y}
	if not best.is_empty():
		return best
	# 기본 단어를 다 모았으면 심화 단어가 다음 목표다.
	# 여기서 빈 사전을 돌려주면 메뉴가 "다 모았다"고 표시해 더 할 일이 없어 보인다.
	for st in ThemeStages.STAGES:
		var adv: Array = st.get("advanced", [])
		var left_adv := 0
		for w in adv:
			if not _collected.has(w):
				left_adv += 1
		if left_adv > 0:
			return {"id": st["id"], "name_en": "%s✦" % st["name_en"], "left": left_adv,
				"got": adv.size() - left_adv, "goal": adv.size()}
	return {}


func _save_collection() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("collection", "words", _collected.keys())
	cfg.save(COLLECTION_PATH)


func _load_collection() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(COLLECTION_PATH) != OK:
		return
	_collected.clear()
	for w in cfg.get_value("collection", "words", []):
		_collected[String(w)] = true


## 단어의 학습 통계(복사본)를 반환합니다. (HUD/디버그용)
func get_word_stats(word: String) -> Dictionary:
	return _get_or_init_stats(word).duplicate()


## 전체 학습 통계(복사본)를 반환합니다.
func get_all_stats() -> Dictionary:
	return _word_stats.duplicate(true)


## 학습 통계를 완전히 초기화합니다. (메뉴의 '학습 초기화' 등에서 사용)
func reset_learning() -> void:
	_word_stats.clear()
	_selection_counter = 0
	_stage_done.clear()


## Returns the word with unfilled letters as underscores.
## e.g., "C_T" for "CAT" with index 1 unfilled.
func get_display_word() -> String:
	var display := ""
	for i in current_word.length():
		if i in _filled_indices:
			display += current_word[i]
		else:
			display += "_"
		if i < current_word.length() - 1:
			display += " "
	return display


## Returns the next unfilled letter (the target letter to shoot).
func get_target_letter() -> String:
	for i in current_word.length():
		if i not in _filled_indices:
			return current_word[i]
	return ""


## Returns all letters of the current word (for spawning enemies).
func get_word_letters() -> Array[String]:
	var letters: Array[String] = []
	for c in current_word:
		letters.append(c)
	return letters


## Check if a letter matches the current target letter.
## Returns true if correct (and fills the slot), false if wrong.
func check_letter(letter: String) -> bool:
	var target := get_target_letter()
	if target == "":
		return false

	if letter.to_upper() == target:
		# Find and fill the index
		for i in current_word.length():
			if i not in _filled_indices and current_word[i] == target:
				_filled_indices.append(i)
				break
		word_progress_updated.emit(get_display_word(), current_word)

		# Check if word is complete
		if _filled_indices.size() >= current_word.length():
			_on_word_finished(current_word)

		return true
	else:
		return false


## 단어 하나를 완성했을 때: 스테이지 진행을 기록하고, 목표 수를 채우면 다음 테마로 넘긴다.
func _on_word_finished(word: String) -> void:
	if not _stage_done.has(word):
		_stage_done.append(word)

	# 도감 수집 — 처음 완성한 단어면 기록하고 알린다.
	if not _collected.has(word):
		_collected[word] = true
		_save_collection()
		var p := get_collection_progress()
		word_collected.emit(word, p.x, p.y)
		# 이 단어로 테마가 완성됐는지 — 48개는 멀지만 8개는 손에 잡히는 목표다.
		var st := get_stage()
		var tid := String(st.get("id", ""))
		if tid != "" and is_theme_mastered(tid):
			theme_mastered.emit(tid, String(st.get("name_en", tid)))

	word_completed.emit(word)

	if _stage_done.size() >= ThemeStages.WORDS_PER_STAGE:
		var cleared_index := stage_index
		stage_cleared.emit(cleared_index, get_stage())
		# 다음 테마로 전환 (마지막 테마 뒤에는 처음으로 순환 — set_stage 가 감싼다)
		set_stage(cleared_index + 1)


## Returns a random letter, with higher chance of being the target letter.
func get_random_letter(target_weight: float = 0.3) -> String:
	var target := get_target_letter()
	if target != "" and randf() < target_weight:
		return target
	# Random letter that's NOT the target (to create decoy enemies)
	# Try up to 26 times, fallback to a guaranteed non-target letter
	for _i in 26:
		var letter := ALPHABET[randi() % 26]
		if letter != target:
			return letter
	# Fallback: return any letter (extremely rare to reach here)
	return ALPHABET[randi() % 26]


func is_word_complete() -> bool:
	return _filled_indices.size() >= current_word.length()


func get_word_length() -> int:
	return current_word.length()


## 현재 단어 진행 상태를 초기화합니다. (게임 시작 시 호출)
## 학습 통계(_word_stats)는 유지되어 여러 게임에 걸쳐 단어 학습이 누적됩니다.
## 테마 스테이지는 **첫 테마로 되돌린다** — 매 판이 "색깔 → 동물 → …" 순서로 시작해야
## 스테이지 진행감과 배경 전환이 성립한다.
func reset() -> void:
	current_word = ""
	_filled_indices.clear()
	set_stage(0)