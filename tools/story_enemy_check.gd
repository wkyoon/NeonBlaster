extends SceneTree
## STORY 화면의 적 탭 확인 (개발용).
##
##   godot --headless --path . --script tools/story_enemy_check.gd
##
## ⚠️ `StoryArt.draw_void_enemy` 의 match 는 **모르는 키를 조용히 CHASER 로 떨어뜨린다.**
##    그래서 `ENEMY_LORE` 에만 추가하면 패널 수는 늘지만 그림이 전부 같아진다.
##    실제로 그런 상태였다(7종 중 4종이 소개에 없었고, 넣어도 그림이 안 붙었다).
##    이 검사는 종류마다 **다른 노드가 그려졌는지**까지 본다.

var _t: float = 0.0
var _page: Node = null


func _process(delta: float) -> bool:
	_t += delta
	if _page == null:
		_page = load("res://scenes/Story.tscn").instantiate()
		root.add_child(_page)
		current_scene = _page
		return false
	if _t < 1.0:
		return false

	var fails := 0
	var keys: Array = StoryData.get_enemy_keys()
	print("소개된 적: %d종 %s" % [keys.size(), str(keys)])

	# 게임이 실제로 스폰하는 종류와 같아야 한다.
	var spawned := ["CHASER", "SHOOTER", "TANK", "DASHER", "BOMBER", "SPLITTER", "SHIELDER"]
	for k in spawned:
		if not keys.has(k):
			print("FAIL %s 가 게임에는 있는데 소개에 없다" % k)
			fails += 1

	# 종류마다 다른 그림이 나와야 한다. 폴리곤 개수와 총 정점 수로 지문을 만든다.
	var probe := Node2D.new()
	root.add_child(probe)
	var seen := {}
	for k in keys:
		var art: Node2D = StoryArt.draw_void_enemy(probe, k, 1.0)
		var polys := 0
		var verts := 0
		# ⚠️ 개수만으로는 부족하다. TANK 와 SPLITTER 가 우연히 둘 다 폴리곤 7개·정점 56개라
		#    오탐이 났다. 색까지 넣어야 실제로 다른 그림인지 구분된다.
		var sig := ""
		for c in art.get_children():
			var p := c as Polygon2D
			if p != null:
				polys += 1
				verts += p.polygon.size()
				sig += "%d:%s|" % [p.polygon.size(), str(p.color)]
		print("  %-9s 폴리곤 %2d개 정점 %3d개" % [k, polys, verts])
		if polys == 0:
			print("FAIL %s 가 아무것도 그리지 않는다" % k)
			fails += 1
		if seen.has(sig):
			print("FAIL %s 가 %s 와 같은 그림이다 (match 에서 빠져 기본값으로 떨어졌다)" % [k, seen[sig]])
			fails += 1
		seen[sig] = k

	# 세력 소개의 병과 수도 같이 맞아야 한다.
	var void_ko: String = StoryData.FACTIONS["VOID"]["ko"]
	var bullets := void_ko.count("•")
	if bullets != spawned.size():
		print("FAIL 세력 소개의 병과가 %d개다 (적은 %d종)" % [bullets, spawned.size()])
		fails += 1

	print("결과: %s" % ("통과" if fails == 0 else "실패 %d건" % fails))
	quit(0 if fails == 0 else 1)
	return true
