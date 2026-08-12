extends Node
## 연출이 **실제로 보이는지** 확인한다 (개발용).
##
##   godot --headless --path . scenes/EffectsCheck.tscn
##
## ⚠️ 이 종류의 버그는 조용하다. 위기 비네트를 캔버스 레이어 -1 에 두었더니 게임 배경 뒤에
##    깔려 아무것도 안 보였다(월드 0 / HUD 10 / UI 20 사이인 5 가 맞다).
##    PointLight2D 의 텍스처를 비워 글로우가 전부 죽어 있던 전례도 있다(AGENTS.md).
## ⚠️ `--script` 모드로 돌리지 말 것 — 오토로드가 전역 식별자로 안 잡힌다.

var _t: float = 0.0
var _fails: int = 0


func _process(delta: float) -> void:
	_t += delta
	if _t < 0.6:
		return
	set_process(false)

	var layer := EffectsManager.get_node_or_null("DangerVignette") as CanvasLayer
	if layer == null:
		print("FAIL 위기 비네트 레이어가 없다")
		_fails += 1
	else:
		print("비네트 레이어 %d (월드 0 / HUD 10 / UI 20 사이여야 한다)" % layer.layer)
		if layer.layer <= 0 or layer.layer >= 10:
			print("FAIL 비네트가 월드 뒤 또는 HUD 위에 있다")
			_fails += 1
		var edges := layer.get_children()
		if edges.size() != 4:
			print("FAIL 비네트 변이 4개가 아니다: %d" % edges.size())
			_fails += 1
		# 중앙(단어 자리 33%)을 덮지 않아야 한다.
		var vp := Vector2(720, 1280)
		var center := Rect2(vp.x * 0.2, vp.y * 0.25, vp.x * 0.6, vp.y * 0.2)
		for e in edges:
			var c := e as ColorRect
			if c != null and Rect2(c.position, c.size).intersects(center):
				print("FAIL %s 가 단어 영역을 덮는다" % c.name)
				_fails += 1

	# 위험 상태를 켜면 알파가 올라가는가
	EffectsManager.set_danger(true)
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var max_a := 0.0
	if layer != null:
		for e in layer.get_children():
			var c := e as ColorRect
			if c != null:
				max_a = maxf(max_a, c.color.a)
	print("위험 켠 뒤 최대 알파 %.2f" % max_a)
	if max_a <= 0.01:
		print("FAIL 위험 상태인데 비네트가 투명하다")
		_fails += 1
	EffectsManager.set_danger(false)

	# 히트스톱이 시간 배율을 실제로 내리는가 (AI 플레이에서는 꺼지는 것이 정상)
	GameManager.auto_play = false
	EffectsManager.set_base_time_scale(1.0)
	EffectsManager.hitstop()
	# ⚠️ 한 프레임만 기다리면 EffectsManager._process 가 아직 안 돈 시점일 수 있다.
	await get_tree().process_frame
	await get_tree().process_frame
	print("히트스톱 중 time_scale %.2f" % Engine.time_scale)
	if Engine.time_scale >= 0.99:
		print("FAIL 히트스톱이 시간을 늦추지 않는다")
		_fails += 1
	await get_tree().create_timer(0.3).timeout
	print("히트스톱 뒤 time_scale %.2f" % Engine.time_scale)
	if absf(Engine.time_scale - 1.0) > 0.01:
		print("FAIL 히트스톱이 끝난 뒤 시간이 되돌아오지 않는다")
		_fails += 1

	print("결과: %s" % ("통과" if _fails == 0 else "실패 %d건" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)
