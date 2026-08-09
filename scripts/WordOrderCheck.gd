extends Node
## 단어가 실제로 **쉬운 것 → 어려운 것** 순으로 나오는지 검사한다. (개발 도구)
##
## 배열 정렬만 보는 tools/check_word_order.py 로는 부족하다 —
## 배열이 정렬돼 있어도 **선택 로직**이 순서를 깨뜨릴 수 있다.
## 실제로 복습 단어를 스테이지 끝에 붙였더니 "EAR(3) NOSE(4) EYE(3)" 이 나왔다.
##
## 실행: godot --headless --path . scenes/WordOrderCheck.tscn

## 검사할 단어 수. 6개 테마 × 여러 바퀴를 돌 만큼.
const SAMPLE := 400


func _ready() -> void:
	var W := WordManager
	W._collected.clear()
	W.persist_enabled = false
	W.reset_learning()
	W.set_stage(0)

	var stage_words: Array = []
	var stage_id := ""
	var failures := 0
	var checked := 0

	for i in SAMPLE:
		var w := W.start_new_word()
		var sid := String(W.get_stage().get("id", "?"))
		if sid != stage_id:
			failures += _check_stage(stage_id, stage_words)
			checked += 1 if stage_words.size() > 1 else 0
			stage_id = sid
			stage_words = []
		stage_words.append(w)
		W._on_word_finished(w)
	failures += _check_stage(stage_id, stage_words)

	print("검사한 스테이지 %d개 / 순서 역전 %d건" % [checked, failures])
	if failures > 0:
		print("실패: 단어가 쉬운 것 → 어려운 순으로 나오지 않는다.")
	else:
		print("통과: 모든 스테이지가 글자 수 오름차순이다.")
	get_tree().quit(1 if failures > 0 else 0)


## 한 스테이지 안에서 글자 수가 줄어드는 지점을 센다.
func _check_stage(sid: String, words: Array) -> int:
	if words.size() < 2:
		return 0
	var bad := 0
	var text := ""
	for i in words.size():
		var n: int = String(words[i]).length()
		var mark := ""
		if i > 0 and n < String(words[i - 1]).length():
			mark = " ←역전"
			bad += 1
		text += " %s(%d)%s" % [words[i], n, mark]
	if bad > 0:
		print("  %-8s:%s" % [sid, text])
	return bad
