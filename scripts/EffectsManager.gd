extends Node
## EffectsManager (Autoload)
## Screen shake, flash, and particle explosion effects.
##
## 셰이크는 trauma 누적 방식이다(Trauma / GDC "Math for Game Programmers" 패턴).
## 기존 max() 방식과 다른 점:
##   1) 타격이 겹치면 trauma 가 **누적**된다 — 연속 피격이 점점 세게 흔들린다.
##   2) 오프셋이 trauma 의 **제곱**이라 약한 타격은 거의 안 흔들리고 큰 타격만 확 튄다.
##   3) 난수 대신 FastNoiseLite 를 써서 프레임마다 튀지 않고 연속적으로 흔들린다.

## trauma 1.0 에서의 최대 카메라 오프셋(px).
const MAX_TRAUMA_OFFSET: float = 44.0
## 오프셋 = trauma^TRAUMA_POWER. 2.0 이면 제곱 곡선.
const TRAUMA_POWER: float = 2.0
## shake(amount) 의 amount 를 trauma 로 환산하는 기준값(=Player 사망 시 30.0 이 거의 1.0).
const SHAKE_AMOUNT_SCALE: float = 30.0
## 노이즈 진행 속도 — 초당 흔들림 횟수를 결정한다.
const NOISE_SPEED: float = 32.0
## duration 이 지정되지 않은 add_trauma() 의 기본 감쇠율(초당).
const DEFAULT_TRAUMA_DECAY: float = 2.4

var _camera: Camera2D = null
var _trauma: float = 0.0
var _trauma_decay: float = DEFAULT_TRAUMA_DECAY
var _noise: FastNoiseLite = FastNoiseLite.new()
var _noise_time: float = 0.0

## ---------------- 히트스톱 ----------------
## 처치 순간 아주 짧게 시간을 늦춘다. 격투·액션·슈팅 장르의 기본 타격감 기법이고,
## 화면을 흔들거나 밝히지 않아 **글자 가독성을 해치지 않는다**
## (이 게임은 전체 플래시·셰이크를 금지한다 — AGENTS.md 참조).
const HITSTOP_SCALE := 0.18
const HITSTOP_TIME := 0.045
## ⚠️ `Engine.time_scale` 은 전역이라 TIME_SLOW 파워업과 싸운다.
##    그래서 여기서 **한 곳에서만** 관리한다: 최종 배율 = base_time_scale x 히트스톱.
##    TIME_SLOW 는 `set_base_time_scale()` 로 들어온다.
var base_time_scale: float = 1.0
var _hitstop: float = 0.0
var _hitstop_scale: float = HITSTOP_SCALE

## ---------------- 위기 비네트 ----------------
## 목숨이 하나 남으면 화면 **가장자리만** 붉게 맥동한다.
## ⚠️ 전체 화면을 덮지 않는 이유가 이 게임의 핵심이다 — 중앙에 단어가 있다.
const VIGNETTE_THICK := 46.0
const VIGNETTE_MAX_ALPHA := 0.34
var _vignette: Array[ColorRect] = []
var _vignette_on: bool = false
var _vignette_phase: float = 0.0

var _flash_layer: CanvasLayer
var _flash_rect: ColorRect
var _explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")


func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.4
	_create_flash_layer()
	_create_vignette()


## 처치 타격감. 아주 짧아야 한다 — 길면 조작이 끈적하게 느껴진다.
func hitstop(scale: float = HITSTOP_SCALE, duration: float = HITSTOP_TIME) -> void:
	_hitstop = maxf(_hitstop, duration)
	_hitstop_scale = scale


## TIME_SLOW 처럼 **지속되는** 시간 배율. 히트스톱과 곱해진다.
func set_base_time_scale(v: float) -> void:
	base_time_scale = maxf(v, 0.01)


## 목숨이 하나 남았는지 알려 준다(`GameManager.lives_changed` 로 호출).
func set_danger(on: bool) -> void:
	_vignette_on = on
	if not on:
		for r in _vignette:
			r.color.a = 0.0


func _process(delta: float) -> void:
	_update_time_scale(delta)
	_update_vignette(delta)
	if _trauma <= 0.0:
		return

	_noise_time += delta * NOISE_SPEED
	_trauma = maxf(_trauma - _trauma_decay * delta, 0.0)

	if _trauma <= 0.0:
		# 카메라가 없어도 감쇠율은 반드시 되돌려야 다음 셰이크가 정상 길이로 재생된다.
		_trauma_decay = DEFAULT_TRAUMA_DECAY
		if _camera:
			_camera.offset = Vector2.ZERO
		return

	if _camera == null:
		return

	var strength := pow(_trauma, TRAUMA_POWER)
	_camera.offset = Vector2(
		_noise.get_noise_2d(_noise_time, 0.0),
		_noise.get_noise_2d(0.0, _noise_time)
	) * MAX_TRAUMA_OFFSET * strength


func set_camera(cam: Camera2D) -> void:
	_camera = cam
	# Reset any lingering shake offset from previous scene
	_trauma = 0.0
	_trauma_decay = DEFAULT_TRAUMA_DECAY
	if _camera:
		_camera.offset = Vector2.ZERO


## 기존 호출부 호환 API. amount 는 SHAKE_AMOUNT_SCALE 기준으로 trauma 로 환산된다.
func shake(amount: float, duration: float) -> void:
	add_trauma(amount / SHAKE_AMOUNT_SCALE, duration)


## trauma 를 누적한다. duration > 0 이면 그 시간 안에 소진되도록 감쇠율을 잡고,
## 이미 더 오래 끌고 있는 셰이크가 있으면 느린 쪽(긴 쪽)을 유지한다.
func add_trauma(amount: float, duration: float = 0.0) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)
	if duration > 0.0:
		_trauma_decay = minf(_trauma_decay, _trauma / duration)


func flash(position: Vector2, color: Color, duration: float = 0.1) -> void:
	var flash_node := _explosion_scene.instantiate() as Node2D
	if flash_node:
		flash_node.global_position = position
		flash_node.modulate = color
		get_tree().current_scene.add_child(flash_node)
		if flash_node.has_method("play_flash"):
			flash_node.play_flash(duration)
		elif flash_node.has_method("play"):
			flash_node.play(duration)
		else:
			flash_node.queue_free()


func explosion(position: Vector2, color: Color = Color(1.0, 0.5, 0.2)) -> void:
	var expl := _explosion_scene.instantiate() as Node2D
	if expl:
		expl.global_position = position
		expl.modulate = color
		get_tree().current_scene.add_child(expl)
		if expl.has_method("play_explosion"):
			expl.play_explosion()
		elif expl.has_method("play"):
			expl.play(0.6)
		else:
			expl.queue_free()
	# Extra screen punch
	shake(12.0, 0.25)


func _create_flash_layer() -> void:
	_flash_layer = CanvasLayer.new()
	_flash_layer.layer = 90
	_flash_layer.name = "FlashLayer"
	add_child(_flash_layer)

	_flash_rect = ColorRect.new()
	_flash_rect.color = Color.WHITE
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.modulate.a = 0.0
	_flash_layer.add_child(_flash_rect)


func screen_flash(color: Color = Color.WHITE, duration: float = 0.15) -> void:
	_flash_rect.color = color
	var tween := create_tween()
	tween.tween_property(_flash_rect, "modulate:a", 0.7, duration * 0.3)
	tween.tween_property(_flash_rect, "modulate:a", 0.0, duration * 0.7)

## ⚠️ 벤치마크는 `Engine.time_scale` 을 매 프레임 자기 값으로 덮어쓴다(가속 측정).
##    거기서 히트스톱까지 끼어들면 측정이 재현되지 않으므로 AI 플레이에서는 손대지 않는다.
func _update_time_scale(delta: float) -> void:
	if GameManager.auto_play:
		return
	if _hitstop > 0.0:
		# ⚠️ 히트스톱 자체는 **실시간**으로 줄여야 한다. 스케일된 delta 로 줄이면
		#    느려진 만큼 더 오래 걸려 정지가 늘어붙는다.
		_hitstop -= delta / maxf(Engine.time_scale, 0.01)
		Engine.time_scale = base_time_scale * _hitstop_scale
		if _hitstop <= 0.0:
			Engine.time_scale = base_time_scale
	else:
		Engine.time_scale = base_time_scale


## 화면 네 변에만 얇게 깔린다. 중앙(단어 자리)은 절대 덮지 않는다.
func _create_vignette() -> void:
	var layer := CanvasLayer.new()
	layer.name = "DangerVignette"
	# ⚠️ 게임 월드는 캔버스 레이어 0, HUD 는 10, UI 는 20 이다(`Game.tscn`).
	#    -1 로 두면 **배경 뒤에 깔려 보이지 않는다**(처음에 그렇게 넣었다).
	#    월드 위·HUD 아래인 5 가 맞다.
	layer.layer = 5
	add_child(layer)
	var vp := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width", 720),
		ProjectSettings.get_setting("display/window/size/viewport_height", 1280))
	var rects := [
		Rect2(0, 0, vp.x, VIGNETTE_THICK),
		Rect2(0, vp.y - VIGNETTE_THICK, vp.x, VIGNETTE_THICK),
		Rect2(0, 0, VIGNETTE_THICK, vp.y),
		Rect2(vp.x - VIGNETTE_THICK, 0, VIGNETTE_THICK, vp.y),
	]
	for i in rects.size():
		var r := ColorRect.new()
		r.name = "Edge%d" % i
		r.position = (rects[i] as Rect2).position
		r.size = (rects[i] as Rect2).size
		r.color = Color(1.0, 0.15, 0.25, 0.0)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(r)
		_vignette.append(r)


func _update_vignette(delta: float) -> void:
	if not _vignette_on:
		return
	_vignette_phase += delta * 4.2
	var a: float = (1.0 - cos(_vignette_phase)) * 0.5 * VIGNETTE_MAX_ALPHA
	for r in _vignette:
		r.color.a = a
