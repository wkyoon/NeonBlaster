extends SceneTree
## 동의 화면 레이아웃 확인 (개발용).
##
##   godot --headless --path . --script tools/consent_check.gd
##
## ⚠️ 이 패널에는 **개인정보처리방침 주소가 글자로** 적혀 있다. 주소가 바뀌면 길이가 달라져
##    잘릴 수 있고, 잘린 주소는 고지로서 무효다. 문구를 고칠 때마다 이걸 돌릴 것.

var _t: float = 0.0
var _menu: Node = null


func _process(delta: float) -> bool:
	_t += delta
	if _menu == null:
		# 오토로드 _ready 가 _initialize 뒤에 돌며 설정을 다시 읽는다. 여기서 되돌린다.
		root.get_node("Telemetry").consent = 0
		_menu = load("res://scenes/Menu.tscn").instantiate()
		root.add_child(_menu)
		current_scene = _menu
		return false
	if _t < 1.0:
		return false

	var vp: Vector2 = root.get_visible_rect().size
	var holder: Node = _menu.find_child("ConsentPanel", true, false)
	if holder == null:
		print("FAIL ConsentPanel 이 없다")
		quit(1)
		return true
	var panel: Control = holder.get_node("Panel")
	var fails := 0

	var pr := Rect2(panel.global_position, panel.size)
	print("뷰포트 %s / 패널 x %.0f~%.0f y %.0f~%.0f" % [vp, pr.position.x, pr.end.x, pr.position.y, pr.end.y])
	if pr.position.x < 0.0 or pr.end.x > vp.x or pr.position.y < 0.0 or pr.end.y > vp.y:
		print("FAIL 패널이 화면 밖으로 나간다")
		fails += 1

	# 본문은 자동 줄바꿈이라 **높이**가, 링크는 한 줄이라 **폭**이 문제가 된다.
	fails += _check_wrapped(panel.get_node("Body"))
	fails += _check_single_line(panel.get_node("PolicyLink"))
	fails += _check_single_line(panel.get_node("Title"))

	for child in panel.get_children():
		var c := child as Control
		if c == null:
			continue
		if c.position.x < 0.0 or c.position.x + c.size.x > panel.size.x:
			print("FAIL %s 가 패널 폭을 벗어난다" % c.name)
			fails += 1
		if c.position.y + c.size.y > panel.size.y:
			print("FAIL %s 가 패널 아래로 넘친다" % c.name)
			fails += 1

	print("결과: %s" % ("통과" if fails == 0 else "실패 %d건" % fails))
	quit(0 if fails == 0 else 1)
	return true


func _check_wrapped(label: Label) -> int:
	var need: float = label.get_theme_font("font").get_multiline_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, label.size.x,
		label.get_theme_font_size("font_size")).y
	print("  %s 필요 높이 %.0f / 확보 %.0f" % [label.name, need, label.size.y])
	if need > label.size.y:
		print("FAIL %s 가 잘린다 (%.0f 초과)" % [label.name, need - label.size.y])
		return 1
	return 0


func _check_single_line(label: Label) -> int:
	var need: float = label.get_theme_font("font").get_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
		label.get_theme_font_size("font_size")).x
	print("  %s 필요 폭 %.0f / 확보 %.0f" % [label.name, need, label.size.x])
	if need > label.size.x:
		print("FAIL %s 가 잘린다 (%.0f 초과)" % [label.name, need - label.size.x])
		return 1
	return 0
