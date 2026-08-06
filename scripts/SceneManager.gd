extends Node
## SceneManager (Autoload)
## Handles scene transitions with fade animation.

const MENU_SCENE := "res://scenes/Menu.tscn"
const GAME_SCENE := "res://scenes/Game.tscn"
const DICTIONARY_SCENE := "res://scenes/Dictionary.tscn"
const STORY_SCENE := "res://scenes/Story.tscn"
const SFX_LAB_SCENE := "res://scenes/SfxLab.tscn"

var _transition: ColorRect
var _transition_tween: Tween


func _ready() -> void:
	_create_transition_layer()


func _create_transition_layer() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.name = "TransitionLayer"
	add_child(canvas)

	_transition = ColorRect.new()
	_transition.color = Color.BLACK
	_transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition.modulate.a = 0.0
	canvas.add_child(_transition)


func change_scene(scene_path: String, fade_duration: float = 0.4) -> void:
	if _transition_tween and _transition_tween.is_valid():
		_transition_tween.kill()

	_transition.mouse_filter = Control.MOUSE_FILTER_STOP
	_transition_tween = create_tween()
	_transition_tween.tween_property(_transition, "modulate:a", 1.0, fade_duration)
	_transition_tween.tween_callback(ResourceLoader.load_threaded_request.bind(scene_path))
	_transition_tween.tween_callback(_finish_scene_load.bind(scene_path, fade_duration))


func _finish_scene_load(scene_path: String, fade_duration: float) -> void:
	var res := ResourceLoader.load_threaded_get(scene_path)
	if res is PackedScene:
		get_tree().change_scene_to_packed(res)
	_transition_tween = create_tween()
	_transition_tween.tween_property(_transition, "modulate:a", 0.0, fade_duration)
	_transition_tween.tween_callback(_on_fade_out_done)


func _on_fade_out_done() -> void:
	_transition.mouse_filter = Control.MOUSE_FILTER_IGNORE


func goto_menu() -> void:
	change_scene(MENU_SCENE)


func goto_game() -> void:
	change_scene(GAME_SCENE)


func goto_dictionary() -> void:
	change_scene(DICTIONARY_SCENE)


func goto_story() -> void:
	change_scene(STORY_SCENE)


## SFX 후보 비교 화면 (개발용).
func goto_sfx_lab() -> void:
	change_scene(SFX_LAB_SCENE)
