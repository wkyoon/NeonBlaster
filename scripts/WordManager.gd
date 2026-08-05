extends Node
## WordManager (Autoload)
## 게임용 단어 데이터를 관리하고 현재 타겟 단어와 진행 상황을 추적합니다.
##
## 단어 선택은 두 가지 학습 원칙을 가중치로 결합합니다:
##   1. 연관성 (Thematic Clustering): 현재 단어와 같은 카테고리의 단어가
##      다음에 더 자주 등장합니다. 관련 단어를 함께 학습하면 기억이 강화됩니다.
##      (예: SUN -> STAR -> MOON -> MARS, 모두 SPACE)
##   2. 간격 반복 노출 (Spaced Repetition): 방금 배운 단어는 짧은 간격으로
##      다시 등장해 기억을 굳히고, 충분히 학습된 단어는 점점 덜 등장합니다.

signal word_completed(word: String)
signal word_progress_updated(filled: String, target: String)
signal new_word_started(word: String)

enum Difficulty { EASY, NORMAL, HARD }

const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# --- 단어 학습 가중치 설정 (튜닝 포인트) ---
const ASSOCIATION_BONUS := 2.5   # 같은 카테고리 연관성 가산점
const REPETITION_BONUS := 1.8    # 최근 학습 단어 반복 강화 가산점
const REPETITION_GAP_MAX := 4    # 이 간격(선택 횟수) 이내에서 반복 강화 적용
const NOVELTY_BONUS := 1.2       # 새 단어(첫 노출) 우대 가산점
const MASTERY_THRESHOLD := 4     # 이 횟수 이상 노출 시 숙달로 간주
const MASTERY_PENALTY := 0.3     # 숙달 단어 가중치 감소 비율(곱)

# Word lists grouped by theme (space/sci-fi themed for the neon shooter vibe)
const WORDS_EASY := [
	# 3 letters
	"SUN", "CAT", "DOG", "BAT", "OWL", "FOX", "BEE", "FLY",
	"SKY", "RAY", "GUN", "JET", "ORB", "ARC", "ICE", "GAS",
	"RED", "GEM", "EYE", "ARM", "LEG", "EAR"
]

const WORDS_NORMAL := [
	# 4-5 letters
	"STAR", "MOON", "MARS", "BIRD", "FISH", "BEAR", "WOLF",
	"BLUE", "GOLD", "PINK", "GAME", "PLAY", "MOVE", "FIRE",
	"COMET", "EARTH", "VENUS", "SOLAR", "ORBIT", "LASER",
	"ALIEN", "ROBOT", "POWER", "SWORD", "BLADE", "SHIELD",
	"GHOST", "STORM", "FLAME", "SHINE", "LIGHT"
]

const WORDS_HARD := [
	# 6+ letters
	"ROCKET", "GALAXY", "PLANET", "COSMOS", "NEBULA",
	"METEOR", "SATURN", "URANUS", "COMETS", "STARDUST",
	"SPACESHIP", "ASTEROID", "ANDROID", "CYBORG", "VOLCANO",
	"CRYSTAL", "THUNDER", "PHANTOM", "HARDCORE", "VICTORY"
]

var current_difficulty: Difficulty = Difficulty.EASY
var current_word: String = ""
var _filled_indices: Array[int] = []
# 단어별 학습 통계: word -> {"exposure": int, "last_seen": int}
# Autoload이므로 게임 재시작에도 유지되어 여러 판에 걸친 학습이 누적됩니다.
var _word_stats: Dictionary = {}
# 단어 선택 카운터 (간격 반복 계산용). 세션 전체에 걸쳐 단조 증가.
var _selection_counter: int = 0


func _ready() -> void:
	pass


func set_difficulty(diff: Difficulty) -> void:
	current_difficulty = diff


func get_word_list() -> Array:
	match current_difficulty:
		Difficulty.EASY:
			return WORDS_EASY.duplicate()
		Difficulty.NORMAL:
			return WORDS_NORMAL.duplicate()
		Difficulty.HARD:
			return WORDS_HARD.duplicate()
		_:
			return WORDS_EASY.duplicate()


## 가중치 기반으로 새 단어를 선택합니다.
## 가중치는 (1) 카테고리 연관성, (2) 간격 반복 강화, (3) 새 단어 우대,
## (4) 숙달 단어 감소, (5) 연속 중복 회피를 결합합니다.
func start_new_word() -> String:
	var words: Array = get_word_list()
	var current_category: String = _get_category(current_word)

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
		if gap >= 1 and gap <= REPETITION_GAP_MAX:
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
			word_completed.emit(current_word)

		return true
	else:
		return false


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


## 현재 단어 진행 상태를 초기화합니다.
## 학습 통계(_word_stats)는 유지되어 여러 게임에 걸쳐 단어 학습이 누적됩니다.
func reset() -> void:
	current_word = ""
	_filled_indices.clear()