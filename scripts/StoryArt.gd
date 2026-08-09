class_name StoryArt
## StoryArt - 세계관 기반 절차적 네온 아트 & 애니메이션
## StoryData의 세력/적/파워업/프롤로그 데이터를 시각화


# ============================================================
# 세력 아트
# ============================================================

## 루미나 가디언 전투기 (애니메이션 포함)
static func draw_guardian_ship(parent: Node2D, scale_factor: float = 1.0) -> Node2D:
	var node := Node2D.new()
	node.name = "GuardianShip"
	node.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(node)

	# 엔진 화염 (애니메이션)
	var flame_outer := Polygon2D.new()
	flame_outer.polygon = PackedVector2Array([
		Vector2(-15, 45), Vector2(0, 90), Vector2(15, 45)
	])
	flame_outer.color = Color(0.3, 0.9, 1.0, 0.5)
	flame_outer.name = "FlameOuter"
	node.add_child(flame_outer)

	var flame_inner := Polygon2D.new()
	flame_inner.polygon = PackedVector2Array([
		Vector2(-8, 45), Vector2(0, 70), Vector2(8, 45)
	])
	flame_inner.color = Color(1.0, 1.0, 1.0, 0.8)
	flame_inner.name = "FlameInner"
	node.add_child(flame_inner)

	# 동체
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(0, -60), Vector2(12, -40), Vector2(20, 10),
		Vector2(12, 45), Vector2(-12, 45), Vector2(-20, 10),
		Vector2(-12, -40)
	])
	body.color = Color(0.2, 0.7, 1.0)
	body.name = "Body"
	node.add_child(body)

	# 동체 하이라이트
	var highlight := Polygon2D.new()
	highlight.polygon = PackedVector2Array([
		Vector2(0, -55), Vector2(8, -35), Vector2(0, 40), Vector2(-8, -35)
	])
	highlight.color = Color(0.5, 0.9, 1.0, 0.6)
	node.add_child(highlight)

	# 조종석
	var cockpit := Polygon2D.new()
	cockpit.polygon = PackedVector2Array([
		Vector2(0, -30), Vector2(8, -10), Vector2(8, 10),
		Vector2(-8, 10), Vector2(-8, -10)
	])
	cockpit.color = Color(1.0, 1.0, 1.0, 0.9)
	node.add_child(cockpit)

	# 날개
	for sx in [1, -1]:
		var wing := Polygon2D.new()
		wing.polygon = PackedVector2Array([
			Vector2(sx * 20, 5), Vector2(sx * 50, 35),
			Vector2(sx * 45, 45), Vector2(sx * 20, 40)
		])
		wing.color = Color(0.3, 0.6, 0.9)
		node.add_child(wing)
		# 날개 끝 네온 라인
		var edge := Line2D.new()
		edge.points = PackedVector2Array([
			Vector2(sx * 20, 5), Vector2(sx * 50, 35), Vector2(sx * 45, 45)
		])
		edge.width = 3.0
		edge.default_color = Color(0.3, 0.9, 1.0)
		node.add_child(edge)

	# 글로우
	_add_light(node, Color(0.3, 0.9, 1.0), 3.0, 4.0)

	return node


## 보이드 적 (타입별)
static func draw_void_enemy(parent: Node2D, enemy_key: String, scale_factor: float = 1.0) -> Node2D:
	var node := Node2D.new()
	node.name = "Void_" + enemy_key
	node.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(node)

	match enemy_key:
		"CHASER":
			_draw_void_chaser(node)
		"SHOOTER":
			_draw_void_shooter(node)
		"TANK":
			_draw_void_tank(node)
		"DASHER":
			_draw_void_dasher(node)
		"BOMBER":
			_draw_void_bomber(node)
		"SPLITTER":
			_draw_void_splitter(node)
		"SHIELDER":
			_draw_void_shielder(node)
		_:
			# ⚠️ **CHASER 로 떨어뜨리지 마라.** 예전에는 그랬는데, 그러면 match 에서 빠진 적이
			#    멀쩡한 삼각형으로 그려져 **빠진 사실 자체가 안 보였다**(적 4종이 그 상태였다).
			#    어느 유닛도 아닌 회색 경고 표식을 그려서 화면만 봐도 바로 드러나게 한다.
			push_warning("StoryArt: '%s' 의 그림이 없다. draw_void_enemy 의 match 에 추가할 것." % enemy_key)
			_draw_void_unknown(node)

	return node


static func _draw_void_chaser(node: Node2D) -> void:
	# 추적자: 날카로운 삼각형, 어두운 핵심
	var outer := Polygon2D.new()
	outer.polygon = PackedVector2Array([
		Vector2(0, -55), Vector2(35, 30), Vector2(0, 15), Vector2(-35, 30)
	])
	outer.color = Color(0.8, 0.15, 0.4)
	node.add_child(outer)

	# 어두운 핵심
	var core := Polygon2D.new()
	core.polygon = _circle_polygon(20, 15)
	core.color = Color(0.1, 0.0, 0.1)
	node.add_child(core)

	# 눈
	var eye := Polygon2D.new()
	eye.polygon = _circle_polygon(8, 6)
	eye.color = Color(1.0, 0.3, 0.5)
	eye.position = Vector2(0, -5)
	node.add_child(eye)

	_add_light(node, Color(1.0, 0.2, 0.5), 2.5, 3.0)


static func _draw_void_shooter(node: Node2D) -> void:
	# 포격수: 마름모 + 총구
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(0, -50), Vector2(40, 0), Vector2(0, 50), Vector2(-40, 0)
	])
	body.color = Color(0.9, 0.4, 0.1)
	node.add_child(body)

	# 어두운 코어
	var core := Polygon2D.new()
	core.polygon = _circle_polygon(16, 18)
	core.color = Color(0.1, 0.05, 0.0)
	node.add_child(core)

	# 눈 (위를 향함)
	for sx in [-1, 1]:
		var eye := Polygon2D.new()
		eye.polygon = _circle_polygon(6, 5)
		eye.color = Color(1.0, 0.6, 0.2)
		eye.position = Vector2(sx * 10, -15)
		node.add_child(eye)

	# 총구
	var muzzle := Polygon2D.new()
	muzzle.polygon = PackedVector2Array([
		Vector2(-6, -60), Vector2(6, -60), Vector2(4, -50), Vector2(-4, -50)
	])
	muzzle.color = Color(1.0, 0.8, 0.3)
	node.add_child(muzzle)

	_add_light(node, Color(1.0, 0.5, 0.1), 2.5, 3.0)


static func _draw_void_tank(node: Node2D) -> void:
	# 중갑병: 육각형 + 장갑 플레이트
	var armor := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 6:
		var a := TAU * i / 6.0 - PI / 2
		pts.append(Vector2(cos(a), sin(a)) * 55)
	armor.polygon = pts
	armor.color = Color(0.6, 0.2, 0.8)
	node.add_child(armor)

	# 내장 장갑
	var inner_armor := Polygon2D.new()
	var pts2 := PackedVector2Array()
	for i in 6:
		var a := TAU * i / 6.0 - PI / 2
		pts2.append(Vector2(cos(a), sin(a)) * 40)
	inner_armor.polygon = pts2
	inner_armor.color = Color(0.4, 0.1, 0.6)
	node.add_child(inner_armor)

	# 어두운 코어
	var core := Polygon2D.new()
	core.polygon = _circle_polygon(20, 22)
	core.color = Color(0.05, 0.0, 0.1)
	node.add_child(core)

	# 위협적인 눈들
	for pos in [Vector2(-15, 0), Vector2(15, 0), Vector2(0, -15), Vector2(0, 15)]:
		var eye := Polygon2D.new()
		eye.polygon = _circle_polygon(6, 4)
		eye.color = Color(1.0, 0.2, 0.8)
		eye.position = pos
		node.add_child(eye)

	_add_light(node, Color(0.8, 0.3, 1.0), 3.0, 3.5)


## 그림이 아직 없는 적. **일부러 어느 유닛과도 안 닮게** 그린다 —
## 회색 팔각 테두리 + 노란 느낌표. 실제 7종에는 회색도 노란색도 없다.
static func _draw_void_unknown(node: Node2D) -> void:
	var ring := Polygon2D.new()
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in 8:
		var a := TAU * i / 8.0 - PI / 8
		var dir := Vector2(cos(a), sin(a))
		outer.append(dir * 55)
		inner.append(dir * 42)
	# 속이 빈 고리 = 아직 안 채워졌다는 뜻
	var band := PackedVector2Array()
	for i in 8:
		band.append(outer[i])
		band.append(outer[(i + 1) % 8])
		band.append(inner[(i + 1) % 8])
		band.append(inner[i])
	ring.polygon = band
	ring.polygons = [
		PackedInt32Array([0, 1, 2, 3]), PackedInt32Array([4, 5, 6, 7]),
		PackedInt32Array([8, 9, 10, 11]), PackedInt32Array([12, 13, 14, 15]),
		PackedInt32Array([16, 17, 18, 19]), PackedInt32Array([20, 21, 22, 23]),
		PackedInt32Array([24, 25, 26, 27]), PackedInt32Array([28, 29, 30, 31]),
	]
	ring.color = Color(0.45, 0.45, 0.5)
	node.add_child(ring)

	var bar := Polygon2D.new()
	bar.polygon = PackedVector2Array([
		Vector2(-7, -28), Vector2(7, -28), Vector2(5, 10), Vector2(-5, 10)
	])
	bar.color = Color(1.0, 0.85, 0.2)
	node.add_child(bar)

	var dot := Polygon2D.new()
	dot.polygon = _circle_polygon(10, 7)
	dot.color = Color(1.0, 0.85, 0.2)
	dot.position = Vector2(0, 26)
	node.add_child(dot)

	_add_light(node, Color(1.0, 0.85, 0.2), 2.0, 2.5)


## ⚠️ 아래 네 종은 **실제 게임의 모양·색과 맞춰야 한다**(`Enemy._configure_type`).
##    설명 화면에서 본 것과 판에서 만나는 것이 다르면 소개가 오히려 방해가 된다.
##    별/청록, 원/주홍, 팔각/초록, 사각/파랑 — 이 대응을 바꾸려면 양쪽을 같이 바꿀 것.

static func _draw_void_dasher(node: Node2D) -> void:
	# 돌진자: 별 모양 + 잔상. 게임에서는 지그재그로 파고든다.
	var star := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0 - PI / 2
		var r: float = 55.0 if i % 2 == 0 else 22.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	star.polygon = pts
	star.color = Color(0.15, 0.85, 0.9)
	node.add_child(star)

	var core := Polygon2D.new()
	core.polygon = _circle_polygon(16, 16)
	core.color = Color(0.0, 0.1, 0.12)
	node.add_child(core)

	# 속도를 드러내는 잔상 두 줄
	for sx in [-1, 1]:
		var trail := Polygon2D.new()
		trail.polygon = PackedVector2Array([
			Vector2(sx * 14, 20), Vector2(sx * 22, 20), Vector2(sx * 16, 62), Vector2(sx * 8, 62)
		])
		trail.color = Color(0.2, 1.0, 1.0, 0.45)
		node.add_child(trail)

	var eye := Polygon2D.new()
	eye.polygon = _circle_polygon(8, 6)
	eye.color = Color(0.5, 1.0, 1.0)
	eye.position = Vector2(0, -6)
	node.add_child(eye)

	_add_light(node, Color(0.2, 1.0, 1.0), 3.0, 3.0)


static func _draw_void_bomber(node: Node2D) -> void:
	# 자폭병: 둥근 폭탄 + 도화선. 가까워지면 깜빡이다 12방향으로 터진다.
	var body := Polygon2D.new()
	body.polygon = _circle_polygon(24, 48)
	body.color = Color(0.9, 0.35, 0.08)
	node.add_child(body)

	var core := Polygon2D.new()
	core.polygon = _circle_polygon(20, 26)
	core.color = Color(0.15, 0.03, 0.0)
	node.add_child(core)

	# 터질 방향을 암시하는 가시
	for i in 12:
		var a := TAU * i / 12.0
		var spike := Polygon2D.new()
		var dir := Vector2(cos(a), sin(a))
		var perp := Vector2(-dir.y, dir.x)
		spike.polygon = PackedVector2Array([
			dir * 48 + perp * 5, dir * 48 - perp * 5, dir * 64
		])
		spike.color = Color(1.0, 0.55, 0.15, 0.75)
		node.add_child(spike)

	# 도화선 불꽃
	var fuse := Polygon2D.new()
	fuse.polygon = _circle_polygon(10, 9)
	fuse.color = Color(1.0, 0.9, 0.4)
	fuse.position = Vector2(0, -58)
	node.add_child(fuse)

	_add_light(node, Color(1.0, 0.45, 0.1), 3.2, 3.2)


static func _draw_void_splitter(node: Node2D) -> void:
	# 분열체: 팔각형 + 갈라짐 선. 죽으면 작은 셋으로 나뉜다.
	var body := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 8:
		var a := TAU * i / 8.0 - PI / 8
		pts.append(Vector2(cos(a), sin(a)) * 52)
	body.polygon = pts
	node.add_child(body)
	body.color = Color(0.25, 0.8, 0.3)

	# 갈라질 자리를 미리 보여주는 어두운 균열
	for i in 3:
		var a := TAU * i / 3.0 - PI / 2
		var dir := Vector2(cos(a), sin(a))
		var perp := Vector2(-dir.y, dir.x)
		var crack := Polygon2D.new()
		crack.polygon = PackedVector2Array([
			perp * 4, dir * 52 + perp * 9, dir * 52 - perp * 9, -perp * 4
		])
		crack.color = Color(0.03, 0.12, 0.04)
		node.add_child(crack)

	# 나뉘어 나올 세 개의 씨앗
	for i in 3:
		var a := TAU * i / 3.0 + PI / 6
		var seed_dot := Polygon2D.new()
		seed_dot.polygon = _circle_polygon(12, 11)
		seed_dot.color = Color(0.5, 1.0, 0.5)
		seed_dot.position = Vector2(cos(a), sin(a)) * 24
		node.add_child(seed_dot)

	_add_light(node, Color(0.3, 1.0, 0.3), 2.8, 3.0)


static func _draw_void_shielder(node: Node2D) -> void:
	# 방벽병: 사각형 + 육각 보호막. 체력을 재생하고 8방향 탄막을 뿌린다.
	var shield := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 6:
		var a := TAU * i / 6.0 - PI / 2
		pts.append(Vector2(cos(a), sin(a)) * 60)
	shield.polygon = pts
	shield.color = Color(0.25, 0.45, 0.95, 0.35)
	node.add_child(shield)

	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-38, -38), Vector2(38, -38), Vector2(38, 38), Vector2(-38, 38)
	])
	body.color = Color(0.25, 0.45, 0.95)
	node.add_child(body)

	var core := Polygon2D.new()
	core.polygon = _circle_polygon(20, 20)
	core.color = Color(0.02, 0.05, 0.15)
	node.add_child(core)

	# 8방향 탄막을 암시하는 포구
	for i in 8:
		var a := TAU * i / 8.0
		var port := Polygon2D.new()
		port.polygon = _circle_polygon(8, 5)
		port.color = Color(0.6, 0.8, 1.0)
		port.position = Vector2(cos(a), sin(a)) * 44
		node.add_child(port)

	# 재생을 뜻하는 십자
	for r in [Rect2(-4, -14, 8, 28), Rect2(-14, -4, 28, 8)]:
		var bar := Polygon2D.new()
		bar.polygon = PackedVector2Array([
			r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)
		])
		bar.color = Color(0.7, 0.95, 1.0)
		node.add_child(bar)

	_add_light(node, Color(0.3, 0.5, 1.0), 3.0, 3.4)


# ============================================================
# 파워업 아트
# ============================================================

static func draw_powerup_icon(parent: Node2D, powerup_key: String, scale_factor: float = 1.0) -> Node2D:
	var node := Node2D.new()
	node.name = "PowerUp_" + powerup_key
	node.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(node)

	match powerup_key:
		"RAPID":
			_draw_powerup_rapid(node)
		"SPREAD":
			_draw_powerup_spread(node)
		"SHIELD":
			_draw_powerup_shield(node)
		"BOMB":
			_draw_powerup_bomb(node)
		"LASER":
			_draw_powerup_laser(node)
		"TIME_SLOW":
			_draw_powerup_time_slow(node)
		"LIGHTNING":
			_draw_powerup_lightning(node)
		_:
			_draw_powerup_rapid(node)

	return node


static func _draw_powerup_rapid(node: Node2D) -> void:
	# 연사: 세 개의 총알
	for i in 3:
		var bullet := Polygon2D.new()
		bullet.polygon = PackedVector2Array([
			Vector2(0, -40 + i * 15), Vector2(12, -30 + i * 15),
			Vector2(12, -10 + i * 15), Vector2(-12, -10 + i * 15),
			Vector2(-12, -30 + i * 15)
		])
		bullet.color = Color(1.0, 0.8, 0.2)
		node.add_child(bullet)
	_add_light(node, Color(1.0, 0.8, 0.2), 2.5, 3.0)


static func _draw_powerup_spread(node: Node2D) -> void:
	# 확산: 부채꼴 화살표
	for i in [-1, 0, 1]:
		var a: float = i * 0.35 - PI / 2
		var arrow := Polygon2D.new()
		arrow.polygon = PackedVector2Array([
			Vector2(cos(a) * 20, sin(a) * 20),
			Vector2(cos(a) * 50 - sin(a) * 10, sin(a) * 50 + cos(a) * 10),
			Vector2(cos(a) * 55, sin(a) * 55),
			Vector2(cos(a) * 50 + sin(a) * 10, sin(a) * 50 - cos(a) * 10)
		])
		arrow.color = Color(0.3, 0.9, 0.5)
		node.add_child(arrow)
	_add_light(node, Color(0.3, 1.0, 0.5), 2.5, 3.0)


static func _draw_powerup_shield(node: Node2D) -> void:
	# 보호막: 방패 + 링
	var shield := Polygon2D.new()
	shield.polygon = PackedVector2Array([
		Vector2(0, -45), Vector2(35, -25), Vector2(35, 15),
		Vector2(0, 45), Vector2(-35, 15), Vector2(-35, -25)
	])
	shield.color = Color(0.3, 0.6, 1.0)
	node.add_child(shield)

	var ring := Line2D.new()
	for i in 36:
		var a := TAU * i / 36.0
		ring.add_point(Vector2(cos(a) * 52, sin(a) * 52))
	ring.add_point(Vector2(52, 0))
	ring.width = 3.0
	ring.default_color = Color(0.5, 0.8, 1.0)
	node.add_child(ring)

	_add_light(node, Color(0.3, 0.6, 1.0), 2.5, 3.0)


static func _draw_powerup_bomb(node: Node2D) -> void:
	# 폭탄: 원 + 퓨즈
	var bomb := Polygon2D.new()
	bomb.polygon = _circle_polygon(28, 35)
	bomb.color = Color(0.1, 0.1, 0.15)
	node.add_child(bomb)

	var highlight := Polygon2D.new()
	highlight.polygon = _circle_polygon(16, 12)
	highlight.color = Color(0.3, 0.3, 0.4)
	highlight.position = Vector2(-12, -12)
	node.add_child(highlight)

	# 퓨즈
	var fuse := Line2D.new()
	fuse.points = PackedVector2Array([Vector2(0, -35), Vector2(5, -50), Vector2(-3, -55)])
	fuse.width = 4.0
	fuse.default_color = Color(0.6, 0.4, 0.2)
	node.add_child(fuse)

	# 스파크
	var spark := Polygon2D.new()
	spark.polygon = PackedVector2Array([
		Vector2(-3, -55), Vector2(0, -70), Vector2(3, -55),
		Vector2(8, -62), Vector2(0, -58), Vector2(-8, -62)
	])
	spark.color = Color(1.0, 0.9, 0.2)
	node.add_child(spark)

	_add_light(node, Color(1.0, 0.4, 0.1), 3.0, 3.5)


static func _draw_powerup_laser(node: Node2D) -> void:
	# 레이저: 수직 빔
	var beam := Polygon2D.new()
	beam.polygon = PackedVector2Array([
		Vector2(-12, -60), Vector2(12, -60), Vector2(12, 60), Vector2(-12, 60)
	])
	beam.color = Color(1.0, 0.2, 0.8)
	node.add_child(beam)

	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(-4, -60), Vector2(4, -60), Vector2(4, 60), Vector2(-4, 60)
	])
	core.color = Color.WHITE
	node.add_child(core)

	_add_light(node, Color(1.0, 0.2, 0.8), 4.0, 4.0)


static func _draw_powerup_time_slow(node: Node2D) -> void:
	# 시간 감속: 시계
	var ring := Line2D.new()
	for i in 60:
		var a := TAU * i / 60.0 - PI / 2
		ring.add_point(Vector2(cos(a) * 45, sin(a) * 45))
	ring.add_point(Vector2(0, -45))
	ring.width = 3.0
	ring.default_color = Color(0.5, 0.8, 1.0)
	node.add_child(ring)

	# 시계 바늘
	var hour_hand := Line2D.new()
	hour_hand.points = PackedVector2Array([Vector2.ZERO, Vector2(0, -20)])
	hour_hand.width = 5.0
	hour_hand.default_color = Color(0.5, 0.8, 1.0)
	node.add_child(hour_hand)

	var min_hand := Line2D.new()
	min_hand.points = PackedVector2Array([Vector2.ZERO, Vector2(20, 10)])
	min_hand.width = 3.0
	min_hand.default_color = Color(0.7, 0.9, 1.0)
	node.add_child(min_hand)

	# 중앙 점
	var center := Polygon2D.new()
	center.polygon = _circle_polygon(8, 5)
	center.color = Color(0.5, 0.8, 1.0)
	node.add_child(center)

	_add_light(node, Color(0.5, 0.8, 1.0), 2.5, 3.0)


static func _draw_powerup_lightning(node: Node2D) -> void:
	# 번개: 지그재그
	var bolt := Polygon2D.new()
	bolt.polygon = PackedVector2Array([
		Vector2(15, -60), Vector2(-10, -10), Vector2(8, -10),
		Vector2(-15, 60), Vector2(10, 10), Vector2(-8, 10)
	])
	bolt.color = Color(1.0, 0.9, 0.2)
	node.add_child(bolt)

	# 보조 번개
	for sx in [-1, 1]:
		var mini := Line2D.new()
		mini.points = PackedVector2Array([
			Vector2(sx * 20, -30), Vector2(sx * 30, -15),
			Vector2(sx * 22, 0), Vector2(sx * 35, 20)
		])
		mini.width = 3.0
		mini.default_color = Color(1.0, 0.9, 0.2, 0.6)
		node.add_child(mini)

	_add_light(node, Color(1.0, 0.9, 0.2), 4.0, 3.5)


# ============================================================
# 프롤로그 씬 아트
# ============================================================

## 루미나 에너지 구체 (펄스 애니메이션용)
static func draw_lumina_orb(parent: Node2D, scale_factor: float = 1.0) -> Node2D:
	var node := Node2D.new()
	node.name = "LuminaOrb"
	node.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(node)

	# 외곽 코로나
	var corona := Polygon2D.new()
	corona.polygon = _circle_polygon(40, 70)
	corona.color = Color(0.3, 0.9, 1.0, 0.1)
	corona.name = "Corona"
	node.add_child(corona)

	# 중간 광역
	var mid := Polygon2D.new()
	mid.polygon = _circle_polygon(32, 50)
	mid.color = Color(0.5, 0.9, 1.0, 0.3)
	node.add_child(mid)

	# 핵심
	var core := Polygon2D.new()
	core.polygon = _circle_polygon(24, 35)
	core.color = Color(0.8, 1.0, 1.0, 0.9)
	node.add_child(core)

	# 하이라이트
	var hl := Polygon2D.new()
	hl.polygon = _circle_polygon(12, 12)
	hl.color = Color.WHITE
	hl.position = Vector2(-10, -10)
	node.add_child(hl)

	_add_light(node, Color(0.3, 0.9, 1.0), 5.0, 6.0)

	return node


## 루미나 가디언 뱃지 (방패 + 별)
static func draw_guardian_badge(parent: Node2D, scale_factor: float = 1.0) -> Node2D:
	var node := Node2D.new()
	node.name = "GuardianBadge"
	node.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(node)

	# 방패 배경
	var shield := Polygon2D.new()
	shield.polygon = PackedVector2Array([
		Vector2(0, -60), Vector2(45, -35), Vector2(45, 15),
		Vector2(0, 60), Vector2(-45, 15), Vector2(-45, -35)
	])
	shield.color = Color(0.1, 0.3, 0.5, 0.8)
	node.add_child(shield)

	# 방패 테두리
	var border := Line2D.new()
	border.points = PackedVector2Array([
		Vector2(0, -60), Vector2(45, -35), Vector2(45, 15),
		Vector2(0, 60), Vector2(-45, 15), Vector2(-45, -35), Vector2(0, -60)
	])
	border.width = 3.0
	border.default_color = Color(0.3, 0.9, 1.0)
	node.add_child(border)

	# 중앙 별
	var star := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + TAU * i / 10.0
		var r := 35.0 if i % 2 == 0 else 14.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	star.polygon = pts
	star.color = Color(0.3, 0.9, 1.0)
	node.add_child(star)

	_add_light(node, Color(0.3, 0.9, 1.0), 2.5, 3.0)

	return node


## 보이드 뱃지 (소용돌이 + 어둠)
static func draw_void_badge(parent: Node2D, scale_factor: float = 1.0) -> Node2D:
	var node := Node2D.new()
	node.name = "VoidBadge"
	node.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(node)

	# 소용돌이 라인들
	for arm in 3:
		var pts := PackedVector2Array()
		for i in 40:
			var t := float(i) / 40.0
			var a := t * TAU * 1.5 + arm * TAU / 3.0
			var r := t * 55
			pts.append(Vector2(cos(a), sin(a)) * r)
		var line := Line2D.new()
		line.points = pts
		line.width = 6.0
		line.default_color = Color(1.0, 0.2, 0.5, 0.7)
		node.add_child(line)

	# 중앙 어두운 핵심
	var core := Polygon2D.new()
	core.polygon = _circle_polygon(20, 18)
	core.color = Color(0.05, 0.0, 0.05)
	node.add_child(core)

	# 붉은 눈
	var eye := Polygon2D.new()
	eye.polygon = _circle_polygon(8, 6)
	eye.color = Color(1.0, 0.2, 0.3)
	node.add_child(eye)

	_add_light(node, Color(1.0, 0.2, 0.5), 2.5, 3.0)

	return node


# ============================================================
# 애니메이션 헬퍼
# ============================================================

## 회전 애니메이션 추가
static func animate_rotation(node: Node2D, speed: float = 1.0) -> void:
	var tween := node.create_tween().set_loops()
	tween.tween_property(node, "rotation", TAU, speed).set_trans(Tween.TRANS_LINEAR)


## 펄스 스케일 애니메이션
static func animate_pulse(node: Node2D, min_scale: float = 0.9, max_scale: float = 1.1, duration: float = 1.5) -> void:
	var tween := node.create_tween().set_loops()
	tween.tween_property(node, "scale", Vector2(max_scale, max_scale), duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", Vector2(min_scale, min_scale), duration).set_trans(Tween.TRANS_SINE)


## 떠다니는 애니메이션 (상하)
static func animate_float(node: Node2D, amplitude: float = 10.0, duration: float = 2.0) -> void:
	var orig_y := node.position.y
	var tween := node.create_tween().set_loops()
	tween.tween_property(node, "position:y", orig_y - amplitude, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", orig_y + amplitude, duration).set_trans(Tween.TRANS_SINE)


## 화염 깜빡임 애니메이션 (전투기 엔진용)
static func animate_engine_flicker(ship: Node2D) -> void:
	var flame_outer := ship.get_node_or_null("FlameOuter")
	var flame_inner := ship.get_node_or_null("FlameInner")
	if flame_outer:
		var tw := flame_outer.create_tween().set_loops()
		tw.tween_property(flame_outer, "scale", Vector2(1.2, 0.8), 0.1)
		tw.tween_property(flame_outer, "scale", Vector2(0.9, 1.1), 0.1)
		tw.tween_property(flame_outer, "scale", Vector2(1.0, 1.0), 0.1)
	if flame_inner:
		var tw2 := flame_inner.create_tween().set_loops()
		tw2.tween_property(flame_inner, "scale", Vector2(0.8, 1.3), 0.08)
		tw2.tween_property(flame_inner, "scale", Vector2(1.1, 0.9), 0.08)
		tw2.tween_property(flame_inner, "scale", Vector2(1.0, 1.0), 0.08)


## 스파클 입자 (별빛 효과)
static func create_sparkles(parent: Node2D, count: int = 20, area: float = 200.0, color: Color = Color.WHITE) -> Node2D:
	var container := Node2D.new()
	container.name = "Sparkles"
	parent.add_child(container)
	for i in count:
		var star := Polygon2D.new()
		var pts := PackedVector2Array()
		for j in 6:
			var a := -PI / 2 + TAU * j / 6.0
			var r := 4.0 if j % 2 == 0 else 1.0
			pts.append(Vector2(cos(a), sin(a)) * r)
		star.polygon = pts
		star.color = Color(color.r + randf_range(-0.2, 0.2), color.g + randf_range(-0.2, 0.2), color.b + randf_range(-0.2, 0.2))
		star.position = Vector2(randf_range(-area, area), randf_range(-area, area))
		container.add_child(star)
		# 깜빡임 애니메이션
		var tw := star.create_tween().set_loops()
		tw.tween_property(star, "modulate:a", 0.2, randf_range(0.5, 1.5))
		tw.tween_property(star, "modulate:a", 1.0, randf_range(0.5, 1.5))
	return container


# ============================================================
# 공통 헬퍼
# ============================================================

static func _circle_polygon(segments: int, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in segments:
		var a := TAU * i / segments
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts


static func _add_light(parent: Node2D, color: Color, energy: float, scale_val: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.color = color
	light.energy = energy
	light.texture_scale = scale_val
	parent.add_child(light)
	return light