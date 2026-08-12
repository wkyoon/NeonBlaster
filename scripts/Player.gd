extends CharacterBody2D
## Player ship - movement (touch joystick + keyboard), auto-fire, collision.

signal player_died
signal player_hit
signal weapon_changed(weapon_level: int)
signal powerup_collected(type: int)
signal shield_activated(duration: float)
signal bomb_triggered

enum WeaponType { SINGLE, DOUBLE, TRIPLE, SPREAD }

@export var max_speed: float = 700.0
@export var acceleration: float = 3600.0
@export var friction: float = 3000.0
## 초당 발사 수. "잘하는 것처럼 느끼게" 하려면 화면이 계속 터져야 하는데,
## 처치 속도의 병목은 스폰이 아니라 **플레이어의 화력 커버리지**였다
## (스폰만 늘리자 처치는 1.12→1.21회/초로 거의 안 오르고 사망만 생겼다).
@export var fire_rate: float = 10.0  # shots per second
@export var bullet_damage: int = 1
## 피격 후 무적 시간. 게임의 목적이 "잘하는 것처럼 느끼게" 하는 것이라 관대하게 준다.
## 연속 피격으로 목숨이 우수수 빠지면 실력 부족으로 느껴진다.
@export var invincible_duration: float = 1.6
## 손가락과 기체 사이의 최소 세로 간격(px). 이보다 가까이 잡아도 기체는 이만큼 위에 뜬다.
## 130~150 이면 기체와 바로 앞 탄이 손가락에 가리지 않고 함께 보인다.
@export var touch_lift: float = 140.0
## 플레이어 탄 속도(유닛/초).
## ⚠️ 예전에는 `Bullet.gd` 의 기본값(800)에 기대고 있었다. 적 탄은 자기 값을 명시하므로
##    그 기본값은 사실상 플레이어 전용인데, 그게 코드에 드러나지 않아 위험했다.
## ⚠️ 느릴수록 적이 죽기까지 시간이 늘어 **화면에 더 오래 보인다** — 이 게임에서는
##    그게 곧 학습 시간이라 좋은 방향이다. 대신 처치가 느려져 밀도와 난이도가 함께 오른다.
const BULLET_SPEED := 720.0
## 탄 사거리(화면 높이 대비). 기체에서부터 재는 거리다.
## ⚠️ 이 값이 곧 교전 띠의 두께이고, 밸런스는 여기에 맞춰져 있다.
const BULLET_RANGE_RATIO := 0.47
## 기체가 올라갈 수 있는 **최상단**(화면 높이 대비). 0.15 = 화면의 85% 까지 올라간다.
##
## ⚠️ 62% → 45% → 15% 로 두 번 풀었다. 묶을수록 "재미없다" 는 지적이 나왔다.
##    이 게임에서 위로 파고드는 것 자체가 재미의 큰 부분이다.
## ⚠️ **완성 단어가 화면 33% 에 나온다**(`WordReveal.WORD_ANCHOR`). 기체가 그 위로 올라가면
##    단어를 가릴 수 있다 — 이동 자유를 위해 감수한 것이다. 단어가 가려 보인다는 말이 나오면
##    기체를 반투명하게 하거나 단어 위치를 옮기는 쪽으로 풀 것(상한을 다시 조이지 말 것).
const MIN_PLAY_Y_RATIO := 0.15
## 손가락에서 기체까지 허용되는 **추가** 세로 간격과 좌우 간격.
## 이 상한이 없으면 멀리서 잡은 간격이 그대로 유지돼 기체가 화면 위에 갇힌다.
const MAX_GRAB_LIFT := 110.0
const MAX_GRAB_SIDE := 130.0
## 배너 높이(dp). AdMob 표준 배너는 50dp 다.
const BANNER_DP := 50.0

## 화면 하단에서 조작을 받지 않는 높이(게임 유닛). **실행 시 계산한다.**
##
## `stretch/aspect = keep` 라 세로가 긴 기기에서는 아래에 여백(레터박스)이 생기고,
## 배너는 그 여백 안에 뜬다 — 이때는 플레이 영역을 깎을 필요가 **전혀 없다**(0).
## 여백이 배너보다 작은 기기(16:9 등)에서만 모자란 만큼 비운다.
## ⚠️ 상수로 박아 두면 세로가 긴 기기에서 멀쩡한 플레이 영역을 괜히 깎는다.
var _bottom_reserve: float = 0.0


## 기기의 아래 여백을 재서 배너와 겹치는 만큼만 조작 영역에서 뺀다.
func _compute_bottom_reserve() -> void:
	_bottom_reserve = 0.0
	var win := Vector2(DisplayServer.window_get_size())
	if win.x <= 0.0 or win.y <= 0.0 or _screen_size.x <= 0.0:
		return
	var scale: float = win.x / _screen_size.x          # 게임유닛 → 물리픽셀
	var bar_px: float = (win.y - _screen_size.y * scale) * 0.5   # 아래 여백(물리픽셀)
	var dpi: float = float(DisplayServer.screen_get_dpi())
	if dpi <= 0.0:
		dpi = 160.0
	var banner_px: float = BANNER_DP * dpi / 160.0
	if banner_px > bar_px:
		_bottom_reserve = (banner_px - bar_px) / scale

var weapon_type: WeaponType = WeaponType.SINGLE
## 시작 화력. 1은 단발이라 화면을 못 덮는다. 2(2줄기)로 시작해 첫 순간부터 시원하게 터진다.
var weapon_level: int = 2  # 1-3  (레벨3 확산은 탄이 벌어져 오히려 처치가 줄었다: 1.39→1.33회/초)
var rapid_fire_timer: float = 0.0  # countdown for rapid fire buff
## SPREAD 파워업은 **일시 버프**다.
## ⚠️ 예전에는 판 내내 영구히 무기 레벨을 올렸다. 레벨 2(2줄기) → 4(5줄기)면 **DPS 2.5배**라
##    시작 몇 초에 화력이 최대가 되고(실측 3레벨 도달 **중앙값 6.1초**, 한 판 파워업 115개)
##    그 뒤로는 적이 도착하는 즉시 녹았다 — "적이 화면에 나오기 전에 다 죽어 있다" 의
##    또 다른 뿌리다. AGENTS.md 가 보상 쪽에 적어 둔 원칙("무기 레벨을 정수로 올리지 마라")을
##    판 안의 파워업이 그대로 위반하고 있었다.
## ⚠️ 기본 레벨(2)은 절대 바뀌지 않는다. 난이도 곡선이 이 값을 전제로 맞춰져 있다.
const BASE_WEAPON_LEVEL := 2
const SPREAD_DURATION := 8.0
const SPREAD_MAX_STACKS := 2
var _spread_stacks: int = 0
var _spread_timer: float = 0.0
var shield_timer: float = 0.0  # countdown for shield buff
var laser_timer: float = 0.0  # countdown for laser buff
var time_slow_timer: float = 0.0  # countdown for time slow (global)
var _base_fire_rate: float = 8.0
## @export 로 정해진 원래 연사값. 보상 배수를 매번 여기에 곱해 누적을 막는다.
var _export_fire_rate: float = 10.0
var _rapid_effect: Node2D = null
var _shield_effect: Node2D = null
var _laser_effect: Node2D = null

@onready var _sprite: Polygon2D = $Sprite
@onready var _glow: PointLight2D = $Glow
@onready var _muzzle: Marker2D = $Muzzle
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _fire_timer: Timer = $FireTimer
@onready var _engine_particles: CPUParticles2D = $EngineParticles

## 스킨 오라(있는 스킨만). 색이 도는 스킨의 기준 색도 여기서 가져온다.
var _skin_aura: ShipAura = null
## 스폰하는 탄에 넘길 색. 스킨의 glow 색을 쓴다(본체 색은 HDR 이라 탄에는 너무 밝다).
var _skin_bullet_color: Color = Color(0.3, 0.9, 1.0)

var _bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
var _move_input: Vector2 = Vector2.ZERO
var _can_fire: bool = true
var _is_invincible: bool = false
var _screen_size: Vector2
var _is_touching: bool = false
var _touch_offset: Vector2 = Vector2.ZERO
var _target_pos: Vector2 = Vector2.ZERO
var _invincible_timer: float = 0.0


func _ready() -> void:
	_screen_size = get_viewport_rect().size
	# 시작 위치는 화면 비율로 잡는다(함정 3). Game.tscn 의 Vector2(360, 960) 은 720x1280 전용이라
	# 세로가 긴 기기(예: 1080x2316 = 1:2.14)에서는 화면의 62% 지점 — 거의 한가운데에 떠 있었다.
	# 부활 경로(Game._respawn_player)가 쓰는 0.75 와 같은 비율로 맞춘다.
	global_position = Vector2(_screen_size.x * 0.5, _screen_size.y * 0.75)
	_compute_bottom_reserve()
	_apply_skin()
	# ⚠️ 보상 버프는 여기서 읽으면 안 된다. 자식(Player)의 _ready 는 부모(Game)의 _ready 보다
	#    **먼저** 실행되므로, 이 시점의 GameManager.reward_* 는 아직 이전 판의 값이다.
	#    Game._ready 가 start_game() 직후 호출하는 revive() 에서 적용한다.
	_export_fire_rate = fire_rate
	_base_fire_rate = fire_rate
	_fire_timer.wait_time = 1.0 / fire_rate
	_fire_timer.timeout.connect(_on_fire_timer)
	add_to_group("player")
	collision_layer = 1  # player layer
	collision_mask = 2 | 16  # enemy + pickup


func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	_handle_input()
	_apply_movement(delta)
	_handle_fire()
	_handle_invincibility(delta)
	_handle_buffs(delta)
	_handle_laser(delta)
	_handle_time_slow(delta)
	_update_skin_color()


func _handle_buffs(delta: float) -> void:
	# Rapid fire countdown
	if _spread_timer > 0.0:
		_spread_timer -= delta
		if _spread_timer <= 0.0:
			_spread_stacks = 0
			weapon_level = BASE_WEAPON_LEVEL
			weapon_changed.emit(weapon_level)
	if rapid_fire_timer > 0:
		rapid_fire_timer -= delta
		if rapid_fire_timer <= 0:
			fire_rate = _base_fire_rate
			_fire_timer.wait_time = 1.0 / fire_rate
			_remove_rapid_effect()
	# Shield countdown
	if shield_timer > 0:
		shield_timer -= delta
		if shield_timer <= 0:
			_remove_shield_effect()
		elif _shield_effect:
			_shield_effect.modulate.a = 0.4 + sin(Time.get_ticks_msec() * 0.01) * 0.2


func _handle_input() -> void:
	_move_input = Vector2.ZERO

	# Auto-play: AI controls the ship
	if GameManager.auto_play:
		_move_input = _compute_ai_input()
		_move_input = _move_input.limit_length(1.0)
		return

	# Keyboard fallback (desktop testing)
	if Input.is_action_pressed("ui_right"):
		_move_input.x += 1
	if Input.is_action_pressed("ui_left"):
		_move_input.x -= 1
	if Input.is_action_pressed("ui_down"):
		_move_input.y += 1
	if Input.is_action_pressed("ui_up"):
		_move_input.y -= 1

	# Touch steering is handled directly in _unhandled_input (drag-to-follow).
	_move_input = _move_input.limit_length(1.0)


# ---------------- Auto-Play AI ----------------

func _compute_ai_input() -> Vector2:
	var target_pos := global_position
	var best_enemy: Node2D = null
	var best_dist := INF
	var target_letter := WordManager.get_target_letter()

	# Find the nearest enemy with the target letter (highest priority)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		# letter 속성이 있는 Enemy 노드만 처리 (HitArea 등 제외)
		if not ("letter" in enemy):
			continue
		# Prefer enemies with target letter
		if target_letter != "" and enemy.letter == target_letter:
			var d := global_position.distance_to(enemy.global_position)
			if d < best_dist:
				best_dist = d
				best_enemy = enemy
	# If no target-letter enemy, find nearest enemy overall
	if not best_enemy:
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if not is_instance_valid(enemy):
				continue
			if not ("letter" in enemy):
				continue
			var d := global_position.distance_to(enemy.global_position)
			if d < best_dist:
				best_dist = d
				best_enemy = enemy

	var ai_input := Vector2.ZERO
	var screen_h := _screen_size.y

	if best_enemy:
		var to_enemy: Vector2 = best_enemy.global_position - global_position
		var enemy_y := best_enemy.global_position.y

		# Horizontal tracking: align with enemy x
		if absf(to_enemy.x) > 20:
			ai_input.x = signf(to_enemy.x)

		# Vertical: stay in the lower third of the screen
		# Let enemies come to us; only move up slightly when enemy is in shooting range
		if global_position.y < screen_h * 0.6:
			# Too high - go back down
			ai_input.y = 1.0
		elif enemy_y > global_position.y - 100:
			# Enemy is close enough vertically - hold position or slight retreat
			ai_input.y = 0.2
		else:
			# Stay in place
			ai_input.y = 0.0

	# Dodge nearby enemy bullets
	# NOTE: AI is intentionally imperfect to simulate human reaction time / mistakes.
	# ai_dodge_error (0.0=perfect, 1.0=never dodges) adds realism for balance tuning.
	var dodge_error: float = GameManager.ai_dodge_error
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		if not is_instance_valid(bullet):
			continue
		var bpos: Vector2 = bullet.global_position
		var bd := global_position.distance_to(bpos)
		if bd < 120:
			# Check if bullet is coming toward us
			var to_us: Vector2 = (global_position - bpos).normalized()
			var bdir: Vector2 = bullet.direction
			if bdir.dot(to_us) > 0.5:
				# AI occasionally fails to dodge (simulates human imperfection)
				if randf() < dodge_error:
					continue
				# Dodge perpendicular
				var dodge_dir: Vector2 = Vector2(-bdir.y, bdir.x)
				if dodge_dir.dot(Vector2(global_position - bpos)) < 0:
					dodge_dir = -dodge_dir
				ai_input += dodge_dir * 1.5

	# Collect nearby powerups
	for pu in get_tree().get_nodes_in_group("pickup"):
		if not is_instance_valid(pu):
			continue
		var pd := global_position.distance_to(pu.global_position)
		if pd < 200:
			ai_input += (pu.global_position - global_position).normalized() * 0.5

	return ai_input.limit_length(1.0)


func _get_touch_joystick_input() -> Vector2:
	# Virtual dynamic joystick on touch
	var joy := get_node_or_null("/root/Game/UI/Joystick")
	if joy and joy.has_method("get_vector"):
		return joy.get_vector()
	return Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.auto_play:
		return
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	# Direct drag-to-follow: the ship sticks under the finger. On press we capture
	# the gap between the finger and the ship so dragging mirrors finger motion 1:1.
	if event is InputEventScreenTouch:
		if event.pressed and not _is_touching:
			_is_touching = true
			_touch_offset = global_position - event.position
			# ⚠️ 기체를 손가락 위로 띄운다.
			# 상대 위치만 잡으면 플레이어가 본능적으로 기체를 직접 눌렀을 때 오프셋이 0이 되어
			# 그 판 내내 **엄지가 기체를 덮는다.** 실측 환산으로 손가락 접촉면은 지름 82~103px,
			# 기체는 43x36px — 손가락이 기체보다 2배 이상 커서 자기 위치도, 코앞의 탄도 안 보인다.
			# 아래에서 잡았을 때만 보정하고(위에서 잡으면 그 간격을 존중), 이동은 기존 추종
			# 로직이 부드럽게 처리하므로 튀지 않는다.
			# ⚠️ **상한도 걸어야 한다.** 예전에는 minf 로 최소 간격만 강제해서,
			#    화면 아래에서 기체를 잡으면 그 큰 간격(수백 px)이 드래그 내내 유지됐다.
			#    손가락은 화면 아래 끝까지밖에 못 가므로 **기체가 계속 화면 위쪽에 붙어 있게 된다** —
			#    실기기에서 손을 안 대도 기체가 31% 지점에 떠 있던 원인이다.
			#    좌우도 마찬가지로 묶는다. 멀리서 잡아도 기체가 손가락 근처로 따라온다.
			_touch_offset.y = clampf(_touch_offset.y, -(touch_lift + MAX_GRAB_LIFT), -touch_lift)
			_touch_offset.x = clampf(_touch_offset.x, -MAX_GRAB_SIDE, MAX_GRAB_SIDE)
			_target_pos = global_position
		elif not event.pressed:
			_is_touching = false
	elif event is InputEventScreenDrag and _is_touching:
		_target_pos = event.position + _touch_offset
		# 손가락이 배너 자리까지 내려가도 기체는 그 위에 머문다.
		_target_pos.y = clampf(_target_pos.y,
			_screen_size.y * MIN_PLAY_Y_RATIO,
			_screen_size.y - 30.0 - _bottom_reserve)


func _apply_movement(delta: float) -> void:
	if _is_touching:
		# Drag-to-follow: fly toward the finger at FULL speed regardless of
		# distance. The previous limit_length() approach caused the ship to crawl
		# whenever the finger was close — now we always use max_speed, only
		# clipping the last step so we never overshoot the target.
		var to_target := _target_pos - global_position
		var dist := to_target.length()
		if dist > 1.0:
			var dir := to_target / dist
			var step := max_speed * delta
			if dist > step:
				velocity = dir * max_speed
			else:
				# Within one frame of the finger — cover exactly the remaining gap.
				velocity = to_target / delta
		else:
			velocity = Vector2.ZERO
		_sprite.rotation = lerp(_sprite.rotation, clampf(velocity.x / max_speed, -1.0, 1.0) * 0.3, 10 * delta)
		_engine_particles.emitting = velocity.length() > 10.0
	else:
		if _move_input != Vector2.ZERO:
			velocity = velocity.move_toward(_move_input * max_speed, acceleration * delta)
			# Tilt sprite slightly based on horizontal movement
			_sprite.rotation = lerp(_sprite.rotation, _move_input.x * 0.3, 10 * delta)
			_engine_particles.emitting = true
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			_sprite.rotation = lerp(_sprite.rotation, 0.0, 10 * delta)
			_engine_particles.emitting = false

	move_and_slide()
	# Clamp to screen
	var margin := 30.0
	global_position.x = clamp(global_position.x, margin, _screen_size.x - margin)
	# 위쪽은 교전 거리를 일정하게 하려고 묶고(MIN_PLAY_Y_RATIO),
	# 아래쪽은 배너와 겹치는 만큼만 비운다(_compute_bottom_reserve 참조).
	# ⚠️ 드래그 목표점(_target_pos)만 묶으면 안 된다 — 가속·관성으로 넘어간다.
	global_position.y = clamp(global_position.y,
		maxf(margin, _screen_size.y * MIN_PLAY_Y_RATIO),
		_screen_size.y - margin - _bottom_reserve)


func _handle_fire() -> void:
	# Auto-fire when playing
	if _can_fire:
		_fire()
		_can_fire = false
		_fire_timer.start()


func _handle_invincibility(delta: float) -> void:
	if _is_invincible:
		_invincible_timer -= delta
		_sprite.visible = fmod(_invincible_timer, 0.2) > 0.1
		if _invincible_timer <= 0:
			_is_invincible = false
			_sprite.visible = true


## 장착 중인 기체 스킨을 입힌다. 출석 보상으로 해금되는 **보이는 보상**의 실체다.
## 성능에는 영향을 주지 않는다 — 색과 오라만 바꾼다.
func _apply_skin() -> void:
	var skin := RewardManager.get_equipped_skin()
	# 실루엣도 스킨을 따른다 — 결제 기체는 색이 아니라 **형태**가 다르다.
	_sprite.polygon = ShipSkins.get_hull(skin)
	_sprite.color = skin["body"]
	_glow.color = skin["glow"]
	_engine_particles.color = skin["engine"]
	_skin_bullet_color = skin["glow"]
	# 응원 배지는 오라가 없는 스킨에서도 보여야 한다 — 오라 노드를 그 목적으로도 쓴다.
	if int(skin.get("aura", 0)) <= 0 and not bool(skin.get("hue", false)) \
			and not PurchaseManager.is_owned("support_tip"):
		return
	# 오라는 기체 **뒤**에 그린다(기체 실루엣을 가리지 않게).
	var aura := ShipAura.new()
	aura.name = "SkinAura"
	aura.z_index = -1
	aura.set_skin(skin)
	add_child(aura)
	move_child(aura, 0)
	_skin_aura = aura


## PRISM 처럼 색이 도는 스킨은 기체 본체 색도 함께 돌려야 한 몸으로 보인다.
func _update_skin_color() -> void:
	if _skin_aura == null:
		return
	var c := _skin_aura.current_body()
	_sprite.color = c
	_glow.color = c
	_skin_bullet_color = c


func _fire() -> void:
	# Fire pattern based on weapon level
	match weapon_level:
		1:
			_spawn_bullet(_muzzle.global_position, Vector2.UP)
		2:
			_spawn_bullet(_muzzle.global_position + Vector2(-12, 0), Vector2.UP)
			_spawn_bullet(_muzzle.global_position + Vector2(12, 0), Vector2.UP)
		3:
			_spawn_bullet(_muzzle.global_position, Vector2.UP)
			_spawn_bullet(_muzzle.global_position + Vector2(-15, 5), Vector2(-0.2, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(15, 5), Vector2(0.2, -1).normalized())
		_:
			# Level 4+: spread shot
			_spawn_bullet(_muzzle.global_position, Vector2.UP)
			_spawn_bullet(_muzzle.global_position + Vector2(-15, 5), Vector2(-0.3, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(15, 5), Vector2(0.3, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(-20, 10), Vector2(-0.5, -1).normalized())
			_spawn_bullet(_muzzle.global_position + Vector2(20, 10), Vector2(0.5, -1).normalized())
	AudioManager.play_shoot(weapon_level)
	# Muzzle flash
	EffectsManager.flash(_muzzle.global_position, Color(0.3, 0.8, 1.0), 0.08)


func _spawn_bullet(pos: Vector2, dir: Vector2) -> void:
	var bullet := _bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.direction = dir
	bullet.damage = bullet_damage
	bullet.is_player_bullet = true
	# 탄도 기체 스킨 색을 따른다 — 화면 대부분을 차지하는 게 탄이라 여기가 제일 눈에 띈다.
	bullet.skin_color = _skin_bullet_color
	# 보상 화력은 탄을 조금 굵게 만든다. 개수를 늘리는 대신 **같은 탄이 세 보이게** 한다.
	bullet.scale = Vector2.ONE * (1.0 + GameManager.reward_power * 0.6)
	# 사거리를 화면 높이에 비례시킨다 — 기기가 달라도 "화면의 몇 %까지 닿는가"가 같아야 한다.
	# ⚠️ 예전에는 "화면 상단 절대선 위로는 탄이 못 간다" 는 제한을 함께 걸었다.
	#    적이 보이기 전에 죽는 것을 막으려던 것인데, **기체 바로 앞의 적도 못 맞히게 되어**
	#    "총알이 맞지 않아서 짜증난다" 는 지적을 받았다. 제거했다 —
	#    "안 보이는 상태에서 죽지 않는다" 는 `Enemy` 의 진입 보호가 이미 보장한다.
	bullet.max_travel = _screen_size.y * BULLET_RANGE_RATIO
	# 적과 같은 화면 높이 보정. 세로가 긴 기기에서 총알이 화면을 가로지르는 시간이
	# 늘어나면 사거리 체감과 교전 리듬이 달라진다.
	bullet.speed = BULLET_SPEED * GameManager.screen_speed_scale()
	get_tree().current_scene.add_child(bullet)


func _on_fire_timer() -> void:
	_can_fire = true


# ---------------- PowerUp Collection ----------------

func collect_powerup(type: int) -> void:
	powerup_collected.emit(type)
	match type:
		GameManager.PowerUpType.RAPID:
			_activate_rapid_fire(6.0)
		GameManager.PowerUpType.SPREAD:
			_upgrade_weapon()
		GameManager.PowerUpType.SHIELD:
			_activate_shield(6.0)
		GameManager.PowerUpType.BOMB:
			_trigger_bomb()
		GameManager.PowerUpType.LASER:
			_activate_laser(5.0)
		GameManager.PowerUpType.TIME_SLOW:
			_activate_time_slow(4.0)
		GameManager.PowerUpType.LIGHTNING:
			_trigger_lightning()


func _upgrade_weapon() -> void:
	# 중복 획득은 레벨을 더 올리는 대신 시간을 갱신한다(최대 +2 = 5줄기).
	_spread_stacks = mini(_spread_stacks + 1, SPREAD_MAX_STACKS)
	_spread_timer = SPREAD_DURATION
	weapon_level = BASE_WEAPON_LEVEL + _spread_stacks
	weapon_changed.emit(weapon_level)
	EffectsManager.flash(global_position, Color(0.2, 1.0, 0.5), 0.15)
	EffectsManager.shake(3.0, 0.1)


func _activate_rapid_fire(duration: float) -> void:
	rapid_fire_timer = duration
	fire_rate = _base_fire_rate * 2.0
	_fire_timer.wait_time = 1.0 / fire_rate
	_create_rapid_effect()


func _activate_shield(duration: float) -> void:
	shield_timer = duration
	_is_invincible = true
	shield_activated.emit(duration)
	_create_shield_effect()


func _trigger_bomb() -> void:
	bomb_triggered.emit()
	EffectsManager.shake(30.0, 0.8)
	EffectsManager.screen_flash(Color(1, 0.5, 0.2), 0.4)
	# Clear all enemies and enemy bullets on screen
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and enemy.has_method("die"):
			enemy.die()
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
	AudioManager.play_sfx("explosion")


func _create_rapid_effect() -> void:
	if _rapid_effect:
		return
	_rapid_effect = Node2D.new()
	_rapid_effect.name = "RapidEffect"
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(Vector2(cos(a), sin(a)) * 35)
	ring.polygon = pts
	ring.color = Color(1.0, 0.9, 0.2, 0.3)
	_rapid_effect.add_child(ring)
	add_child(_rapid_effect)


func _remove_rapid_effect() -> void:
	if _rapid_effect:
		_rapid_effect.queue_free()
		_rapid_effect = null


func _create_shield_effect() -> void:
	if _shield_effect:
		return
	_shield_effect = Node2D.new()
	_shield_effect.name = "ShieldEffect"
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		pts.append(Vector2(cos(a), sin(a)) * 40)
	ring.polygon = pts
	ring.color = Color(0.3, 0.6, 1.0, 0.4)
	_shield_effect.add_child(ring)
	var glow := PointLight2D.new()
	glow.color = Color(0.3, 0.6, 1.0)
	glow.energy = 1.5
	glow.texture_scale = 2.0
	_shield_effect.add_child(glow)
	add_child(_shield_effect)


func _remove_shield_effect() -> void:
	if _shield_effect:
		_shield_effect.queue_free()
		_shield_effect = null
	_is_invincible = false


func take_damage() -> void:
	if _is_invincible:
		return
	player_hit.emit()
	EffectsManager.shake(8.0, 0.3)
	EffectsManager.flash(global_position, Color(1.0, 0.3, 0.3), 0.2)
	AudioManager.play_sfx("hit")

	var died := GameManager.lose_life()
	if died:
		die()
	else:
		_start_invincibility()


func _start_invincibility() -> void:
	_is_invincible = true
	_invincible_timer = invincible_duration


func die() -> void:
	# Reset global time scale in case time slow was active
	EffectsManager.set_base_time_scale(1.0)
	time_slow_timer = 0.0
	laser_timer = 0.0
	_remove_laser_effect()
	EffectsManager.shake(20.0, 0.6)
	EffectsManager.explosion(global_position, Color(0.3, 0.8, 1.0))
	AudioManager.play_sfx("explosion")
	player_died.emit()
	queue_free()


func revive() -> void:
	# 부활 시 버프는 초기화하되 **기본 화력은 시작값(2)으로 되돌린다.**
	# 1로 떨어뜨리면 부활 직후 단발이 되어 가장 힘든 순간에 가장 약해진다 —
	# "잘하는 것처럼 느끼게" 하려는 방향과 정반대다.
	# 출석 보상 화력을 여기서 적용한다. Game._ready 가 start_game() 직후 호출하므로
	# 판 시작·부활 양쪽에서 같은 값이 걸린다(부활 후에도 그 판 내내 유효).
	# ⚠️ 무기 레벨은 건드리지 않는다 — 레벨을 올리면 탄 개수가 뛰어 판이 통째로 달라진다.
	#    보상은 연사와 탄 크기를 소수 배수로만 올린다.
	weapon_level = BASE_WEAPON_LEVEL
	_spread_stacks = 0
	_spread_timer = 0.0
	_base_fire_rate = _export_fire_rate * (1.0 + GameManager.reward_power)
	rapid_fire_timer = 0.0
	shield_timer = 0.0
	laser_timer = 0.0
	time_slow_timer = 0.0
	EffectsManager.set_base_time_scale(1.0)
	fire_rate = _base_fire_rate
	_fire_timer.wait_time = 1.0 / fire_rate
	_remove_rapid_effect()
	_remove_shield_effect()
	_remove_laser_effect()
	weapon_changed.emit(weapon_level)
	_start_invincibility()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
		take_damage()
	elif area.is_in_group("enemy"):
		take_damage()


# ---------------- LASER ----------------

func _activate_laser(duration: float) -> void:
	laser_timer = duration
	_create_laser_effect()
	AudioManager.play_sfx("explosion")
	EffectsManager.screen_flash(Color(1.0, 0.2, 0.8, 0.3), 0.2)
	EffectsManager.shake(5.0, 0.2)


func _handle_laser(delta: float) -> void:
	if laser_timer > 0:
		laser_timer -= delta
		# Continuous damage to enemies in laser beam path
		_damage_enemies_in_laser()
		if laser_timer <= 0:
			_remove_laser_effect()
	elif _laser_effect:
		_remove_laser_effect()


func _damage_enemies_in_laser() -> void:
	var beam_x := global_position.x
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		if abs(enemy.global_position.x - beam_x) < 30 and enemy.global_position.y < global_position.y:
			if enemy.has_method("take_damage"):
				enemy.take_damage(3)
				EffectsManager.flash(enemy.global_position, Color(1, 0.2, 0.8), 0.05)
	# Also destroy enemy bullets in the beam
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		if is_instance_valid(bullet) and abs(bullet.global_position.x - beam_x) < 30:
			bullet.queue_free()


func _create_laser_effect() -> void:
	if _laser_effect:
		return
	_laser_effect = Node2D.new()
	_laser_effect.name = "LaserEffect"
	# Main beam
	var beam := Polygon2D.new()
	beam.polygon = PackedVector2Array([
		Vector2(-15, -2000), Vector2(15, -2000),
		Vector2(15, -10), Vector2(-15, -10)
	])
	beam.color = Color(1.0, 0.2, 0.8, 0.5)
	_laser_effect.add_child(beam)
	# Inner bright core
	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-5, -2000), Vector2(5, -2000),
		Vector2(5, -10), Vector2(-5, -10)
	])
	core.color = Color(1.0, 0.9, 1.0, 0.9)
	_laser_effect.add_child(core)
	# Glow
	var glow := PointLight2D.new()
	glow.color = Color(1.0, 0.2, 0.8)
	glow.energy = 4.0
	glow.texture_scale = 3.0
	_laser_effect.add_child(glow)
	add_child(_laser_effect)


func _remove_laser_effect() -> void:
	if _laser_effect:
		_laser_effect.queue_free()
		_laser_effect = null


# ---------------- TIME SLOW ----------------

func _activate_time_slow(duration: float) -> void:
	time_slow_timer = duration
	# ⚠️ Engine.time_scale 을 직접 만지지 않는다 — 히트스톱과 싸운다.
	#    EffectsManager 가 한 곳에서 (지속 배율 x 히트스톱)을 계산한다.
	EffectsManager.set_base_time_scale(0.3)
	EffectsManager.screen_flash(Color(0.5, 0.8, 1.0, 0.3), 0.3)
	AudioManager.play_sfx("hit")


func _handle_time_slow(delta: float) -> void:
	if time_slow_timer > 0:
		time_slow_timer -= delta
		if time_slow_timer <= 0:
			EffectsManager.set_base_time_scale(1.0)


# ---------------- LIGHTNING ----------------

func _trigger_lightning() -> void:
	EffectsManager.screen_flash(Color(1.0, 0.9, 0.3), 0.2)
	EffectsManager.shake(15.0, 0.4)
	AudioManager.play_sfx("explosion")
	var enemies := get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return
	# Find nearest enemy as starting point
	var start_enemy: Node2D = null
	var min_dist := INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var d := global_position.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			start_enemy = enemy
	if not start_enemy:
		return
	# Chain lightning to nearby enemies
	var hit_enemies: Array = [start_enemy]
	var current: Node2D = start_enemy
	var chain_count: int = min(enemies.size(), 8)  # up to 8 chains
	_draw_lightning(global_position, current.global_position)
	if current.has_method("die"):
		current.die()
	for i in range(chain_count - 1):
		var next_enemy: Node2D = null
		var nearest_dist := INF
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if not is_instance_valid(enemy) or enemy in hit_enemies:
				continue
			var d := current.global_position.distance_to(enemy.global_position)
			if d < nearest_dist and d < 250:
				nearest_dist = d
				next_enemy = enemy
		if next_enemy == null:
			break
		_draw_lightning(current.global_position, next_enemy.global_position)
		if next_enemy.has_method("die"):
			next_enemy.die()
		hit_enemies.append(next_enemy)
		current = next_enemy


func _draw_lightning(from: Vector2, to: Vector2) -> void:
	# Draw jagged lightning bolt between two points
	var bolt := Line2D.new()
	bolt.width = 4.0
	bolt.default_color = Color(1.0, 0.9, 0.3)
	bolt.joint_mode = Line2D.LINE_JOINT_ROUND
	var segments := 8
	var direction := (to - from)
	var perpendicular := Vector2(-direction.y, direction.x).normalized()
	for i in range(segments + 1):
		var t := float(i) / segments
		var pos := from.lerp(to, t)
		if i > 0 and i < segments:
			pos += perpendicular * randf_range(-20, 20)
		bolt.add_point(pos)
	get_tree().current_scene.add_child(bolt)
	# Fade out and remove
	var tween := create_tween()
	tween.tween_property(bolt, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bolt.queue_free)
	# Flash at target
	EffectsManager.flash(to, Color(1.0, 0.9, 0.3), 0.1)
