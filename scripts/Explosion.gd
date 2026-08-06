extends Node2D
## Explosion / Flash effect - particle burst with auto-cleanup.
## 파티클 텍스처는 Kenney Particle Pack(CC0) — assets/particles/ 참조.
## 색은 전부 흰색 텍스처 + 부모 modulate 로 결정되므로 호출부에서 네온 색을 그대로 넘기면 된다.

const STAR_TEXTURE: Texture2D = preload("res://assets/particles/star_04.png")
const GLOW_TEXTURE: Texture2D = preload("res://assets/particles/light_01.png")

@onready var _particles: CPUParticles2D = $Particles
@onready var _sparks: CPUParticles2D = $Sparks

var _is_freeing: bool = false


func _ready() -> void:
	if _particles:
		_particles.finished.connect(_safe_free)


func play(duration: float = 0.6) -> void:
	_particles.emitting = true
	# Auto-free after duration + margin
	get_tree().create_timer(duration + 0.5).timeout.connect(_safe_free)


func play_flash(duration: float = 0.1) -> void:
	# 짧은 반짝임 — 별 모양 스파클로 교체하고 확산을 줄인다.
	_particles.texture = STAR_TEXTURE
	_particles.amount = 8
	_particles.lifetime = duration
	_particles.initial_velocity_min = 40.0
	_particles.initial_velocity_max = 120.0
	_particles.scale_amount_min = 0.12
	_particles.scale_amount_max = 0.28
	_particles.emitting = true
	get_tree().create_timer(duration + 0.3).timeout.connect(_safe_free)


func play_explosion() -> void:
	# 발광 덩어리(글로우) + 전기 스파크 2개 레이어를 동시에 터뜨린다.
	_particles.texture = GLOW_TEXTURE
	_particles.amount = 24
	_particles.lifetime = 0.5
	_particles.explosiveness = 1.0
	_particles.emitting = true
	if _sparks:
		_sparks.emitting = true
	get_tree().create_timer(1.0).timeout.connect(_safe_free)


func _safe_free() -> void:
	if _is_freeing:
		return
	_is_freeing = true
	queue_free()
