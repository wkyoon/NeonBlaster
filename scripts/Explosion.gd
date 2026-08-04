extends Node2D
## Explosion / Flash effect - particle burst with auto-cleanup.

@onready var _particles: CPUParticles2D = $Particles

var _is_freeing: bool = false


func _ready() -> void:
	if _particles:
		_particles.finished.connect(_safe_free)


func play(duration: float = 0.6) -> void:
	_particles.emitting = true
	# Auto-free after duration + margin
	get_tree().create_timer(duration + 0.5).timeout.connect(_safe_free)


func play_flash(duration: float = 0.1) -> void:
	_particles.amount = 8
	_particles.lifetime = duration
	_particles.scale_amount_min = 2.0
	_particles.scale_amount_max = 5.0
	_particles.emitting = true
	get_tree().create_timer(duration + 0.3).timeout.connect(_safe_free)


func play_explosion() -> void:
	_particles.amount = 24
	_particles.lifetime = 0.5
	_particles.explosiveness = 1.0
	_particles.emitting = true
	get_tree().create_timer(1.0).timeout.connect(_safe_free)


func _safe_free() -> void:
	if _is_freeing:
		return
	_is_freeing = true
	queue_free()