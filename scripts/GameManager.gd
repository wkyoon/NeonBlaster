extends Node
## GameManager (Autoload)
## Manages global game state: score, high score, lives, combo, and game flow signals.

signal score_changed(score: int)
signal high_score_changed(high_score: int)
signal lives_changed(lives: int)
signal game_state_changed(state: int)
signal combo_changed(combo: int, multiplier: float)

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
enum PowerUpType { RAPID, SPREAD, SHIELD, BOMB, LASER, TIME_SLOW, LIGHTNING }

const SAVE_PATH := "user://neonblaster_save.cfg"
const MAX_LIVES := 3
const COMBO_WINDOW := 2.5  # seconds before combo resets
const COMBO_STEP := 5  # kills needed per multiplier level

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

var revives_used: int = 0
var max_revives: int = 1

# Auto-play mode (AI plays the game for demonstration)
var auto_play: bool = false


func _ready() -> void:
	load_save()


func _process(delta: float) -> void:
	if combo > 0 and current_state == GameState.PLAYING:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()


func start_game() -> void:
	score = 0
	lives = MAX_LIVES
	revives_used = 0
	combo = 0
	combo_timer = 0.0
	combo_multiplier = 1.0
	current_state = GameState.PLAYING


func game_over() -> void:
	current_state = GameState.GAME_OVER
	if score >= high_score:
		high_score = score
	save_game()


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


func _update_multiplier() -> void:
	var level := combo / COMBO_STEP
	combo_multiplier = 1.0 + level * 0.5
	combo_multiplier = min(combo_multiplier, 5.0)
	combo_changed.emit(combo, combo_multiplier)


func reset_combo() -> void:
	combo = 0
	combo_timer = 0.0
	combo_multiplier = 1.0
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


func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.save(SAVE_PATH)