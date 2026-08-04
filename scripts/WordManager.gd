extends Node
## WordManager (Autoload)
## Manages word data for the spelling shooter game.
## Provides words by difficulty and tracks the current target word + progress.

signal word_completed(word: String)
signal word_progress_updated(filled: String, target: String)
signal new_word_started(word: String)

enum Difficulty { EASY, NORMAL, HARD }

const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

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
var _used_words: Array[String] = []


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


## Start a new random word. Returns the word.
func start_new_word() -> String:
	var words := get_word_list()
	# Filter out recently used words
	var available: Array = []
	for w in words:
		if w not in _used_words:
			available.append(w)
	if available.is_empty():
		_used_words.clear()
		available = words.duplicate()

	current_word = available[randi() % available.size()]
	_used_words.append(current_word)
	_filled_indices.clear()
	word_progress_updated.emit(get_display_word(), current_word)
	new_word_started.emit(current_word)
	return current_word


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


func reset() -> void:
	current_word = ""
	_filled_indices.clear()
	_used_words.clear()