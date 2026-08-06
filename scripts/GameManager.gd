extends Node
## GameManager (Autoload)
## Manages global game state: score, high score, lives, combo, and game flow signals.

signal score_changed(score: int)
signal high_score_changed(high_score: int)
signal lives_changed(lives: int)
signal game_state_changed(state: int)
signal combo_changed(combo: int, multiplier: float)
## 콤보 배수 단계가 새로 돌파될 때만 발생한다(연출을 단계 돌파에만 터뜨리기 위함).
signal combo_level_up(level: int, multiplier: float)

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
enum PowerUpType { RAPID, SPREAD, SHIELD, BOMB, LASER, TIME_SLOW, LIGHTNING }

const SAVE_PATH := "user://neonblaster_save.cfg"
const MAX_SCORE_HISTORY := 10
## 목숨 수. 3에서 5로 올렸다 — 동시 적 3~4마리 밀도에서 피격 3회는 거의 필연이라
## 목숨 3개로는 "밀도 높은 속도감"과 "매번 죽지는 않음"을 동시에 만족시킬 수 없었다.
## ⚠️ Benchmark 의 `hits` 목표는 이 값에 사실상 붙는다(피격 1회 = 목숨 1개, 부활로 +1 가능).
##    사망이 확실한 난이도에서 hits 는 "목숨 수"만 보고하므로 난이도 판별력이 없다 —
##    그런 구간은 사망률·생존시간·단어/분으로 판단할 것. 목숨 수를 바꾸면 목표도 함께 조정.
const MAX_LIVES := 5
## 콤보가 끊기기까지의 시간. 2.5초는 **평균 처치 간격(약 2.0~2.6초)보다 짧아서
## 콤보가 성립조차 하지 않았다** — 18초 자동 플레이에서 콤보가 1~2에 머물고 배수가 x1.0을 못 벗어났다.
## 처치 간격의 약 2배로 잡아야 연쇄가 유지된다.
const COMBO_WINDOW := 4.5  # seconds before combo resets
const COMBO_STEP := 5  # kills needed per multiplier level
## 단어 하나를 완성하면 콤보를 이만큼 밀어준다 (학습 → 액션 보상 연결).
const WORD_COMBO_BONUS := 4
## 단어 완성 직후에는 콤보 창을 이 배수만큼 늘려 콤보를 이어갈 여유를 준다.
const WORD_COMBO_WINDOW_BOOST := 1.8

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)
		if score > high_score:
			high_score = score

var high_score: int = 0:
	set(value):
		high_score = value
		high_score_changed.emit(high_score)

var score_history: Array[Dictionary] = []
var _current_session_id: int = 0

var lives: int = MAX_LIVES:
	set(value):
		lives = clamp(value, 0, MAX_LIVES)
		lives_changed.emit(lives)

var current_state: int = GameState.MENU:
	set(value):
		current_state = value
		game_state_changed.emit(current_state)

var combo: int = 0
var combo_timer: float = 0.0
var combo_multiplier: float = 1.0
## 이번 콤보에서 도달한 최고 배수 단계. 같은 단계를 다시 넘을 때 연출이 중복되지 않게 한다.
var _peak_combo_level: int = 0

var revives_used: int = 0
var max_revives: int = 1

# Auto-play mode (AI plays the game for demonstration)
var auto_play: bool = false
# AI dodge error rate for benchmark realism (0.0=perfect, 0.15~avg human, 0.3~beginner)
var ai_dodge_error: float = 0.0


func _ready() -> void:
	load_save()


func _process(delta: float) -> void:
	if combo > 0 and current_state == GameState.PLAYING:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()


func start_game() -> void:
	_current_session_id = int(Time.get_unix_time_from_system() * 1000.0)
	score = 0
	lives = MAX_LIVES
	revives_used = 0
	combo = 0
	combo_timer = 0.0
	combo_multiplier = 1.0
	_peak_combo_level = 0
	current_state = GameState.PLAYING


func game_over() -> void:
	current_state = GameState.GAME_OVER
	if score >= high_score:
		high_score = score
	_record_current_score()
	save_game()


func _record_current_score() -> void:
	var difficulty_names: Array[String] = ["EASY", "NORMAL", "HARD"]
	var difficulty_idx := clampi(int(WordManager.current_difficulty), 0, difficulty_names.size() - 1)
	var record := {
		"session_id": _current_session_id,
		"score": score,
		"difficulty": difficulty_names[difficulty_idx],
		"timestamp": Time.get_unix_time_from_system(),
	}
	# 부활 후 다시 게임오버가 되어도 같은 플레이 기록을 최종 점수로 갱신합니다.
	for i in score_history.size():
		if int(score_history[i].get("session_id", -1)) == _current_session_id:
			score_history.remove_at(i)
			break
	score_history.push_front(record)
	if score_history.size() > MAX_SCORE_HISTORY:
		score_history.resize(MAX_SCORE_HISTORY)


func get_score_history() -> Array[Dictionary]:
	return score_history.duplicate(true)


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false


func go_to_menu() -> void:
	current_state = GameState.MENU


func add_score(amount: int) -> void:
	# 점수가 음수가 되지 않도록 보정
	score = max(0, score + amount)


## Called when an enemy is destroyed. Adds combo and returns the points
## already multiplied by the current combo multiplier.
func register_kill(base_points: int) -> int:
	combo += 1
	combo_timer = COMBO_WINDOW
	_update_multiplier()
	var points := int(base_points * combo_multiplier)
	score += points
	return points


## 단어를 완성했을 때 콤보를 크게 밀어준다.
## 학습(단어)과 액션(콤보)을 묶는 장치다 — 단어를 맞힐수록 콤보가 터지고 점수 배수가 올라간다.
## 콤보 창도 함께 갱신해서 단어 완성 직후에 콤보를 이어갈 여유를 준다.
func register_word_bonus() -> int:
	var before_level := combo / COMBO_STEP
	combo += WORD_COMBO_BONUS
	combo_timer = COMBO_WINDOW * WORD_COMBO_WINDOW_BOOST
	_update_multiplier()
	var after_level := combo / COMBO_STEP
	return after_level - before_level  # 이번에 돌파한 콤보 단계 수 (연출 강도용)


func _update_multiplier() -> void:
	var level := combo / COMBO_STEP
	combo_multiplier = 1.0 + level * 0.5
	combo_multiplier = min(combo_multiplier, 5.0)
	if level > _peak_combo_level:
		_peak_combo_level = level
		combo_level_up.emit(level, combo_multiplier)
	combo_changed.emit(combo, combo_multiplier)


func reset_combo() -> void:
	combo = 0
	combo_timer = 0.0
	combo_multiplier = 1.0
	_peak_combo_level = 0
	combo_changed.emit(combo, combo_multiplier)


func lose_life() -> bool:
	lives -= 1
	return lives <= 0


func can_revive() -> bool:
	return revives_used < max_revives


func use_revive() -> void:
	revives_used += 1
	lives = 1
	current_state = GameState.PLAYING


func load_save() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		high_score = config.get_value("score", "high_score", 0)
		var saved_history: Array = config.get_value("score", "history", [])
		score_history.clear()
		for item in saved_history:
			if item is Dictionary:
				score_history.append(item)


func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.set_value("score", "history", score_history)
	config.save(SAVE_PATH)
