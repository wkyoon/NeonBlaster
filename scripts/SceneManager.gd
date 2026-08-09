extends Node
## SceneManager (Autoload)
## Handles scene transitions with fade animation.

const MENU_SCENE := "res://scenes/Menu.tscn"
const GAME_SCENE := "res://scenes/Game.tscn"
const DICTIONARY_SCENE := "res://scenes/Dictionary.tscn"
const STORY_SCENE := "res://scenes/Story.tscn"
const SFX_LAB_SCENE := "res://scenes/SfxLab.tscn"
const STORE_SCENE := "res://scenes/Store.tscn"

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


## 안드로이드 뒤로 가기(그리고 데스크톱 ESC). 게임·하위 화면에서는 **메뉴로 돌아간다.**
##
## ⚠️ `application/config/quit_on_go_back` 을 false 로 꺼 두어야 여기까지 온다.
##    기본값은 true 라 뒤로 가기가 곧바로 **앱 종료**였다 — 플레이 중에 눌러도 그냥 꺼졌다.
## ⚠️ iOS 에는 하드웨어 뒤로 가기가 없다. 같은 동작을 주려면 화면 안에 버튼이 필요하다
##    (게임 화면의 일시정지 → 메뉴 경로가 그 역할을 한다).
func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_GO_BACK_REQUEST:
		return
	_handle_go_back()


## 데스크톱 확인용 — ESC 도 같은 경로를 탄다.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_handle_go_back()
		get_viewport().set_input_as_handled()


func _handle_go_back() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var name := String(scene.name)
	if name == "Menu":
		# 메뉴에서 한 번 더 누르면 앱을 닫는다.
		get_tree().quit()
		return
	# 게임에서 나갈 때는 배너를 내리고 상태를 정리한다.
	if name == "Game":
		AdsManager.hide_banner()
		get_tree().paused = false
		GameManager.go_to_menu()
	goto_menu()


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


func goto_store() -> void:
	change_scene(STORE_SCENE)
