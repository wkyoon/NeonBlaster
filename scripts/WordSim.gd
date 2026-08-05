extends Node2D
## WordSim - 단어 선택 알고리즘 검증용 헤드리스 시뮬레이터
## 연관성 군집화(Thematic Clustering)와 간격 반복 노출(Spaced Repetition)이
## 실제로 일어나는지 확인합니다.

const ROUNDS := 40


func _ready() -> void:
	print("")
	_simulate("EASY", WordManager.Difficulty.EASY)
	print("")
	_simulate("NORMAL", WordManager.Difficulty.NORMAL)
	print("")
	_simulate("HARD", WordManager.Difficulty.HARD)
	get_tree().quit()


func _simulate(label: String, diff: WordManager.Difficulty) -> void:
	WordManager.reset_learning()
	WordManager.set_difficulty(diff)
	WordManager.reset()

	print("===== %s 단어 선택 시뮬레이션 (%d회) =====" % [label, ROUNDS])
	var words_seq: Array = []
	var cats_seq: Array = []
	for i in ROUNDS:
		var w := WordManager.start_new_word()
		words_seq.append(w)
		cats_seq.append(String(WordDictionary.get_description(w).get("category", "?")))

	# 단어/카테고리 시퀀스 출력 (그룹화 보기 쉽게)
	print("단어:     ", words_seq)
	print("카테고리: ", cats_seq)

	# 연관성 분석: 연속 같은 카테고리 횟수
	var same_cat := 0
	for i in range(1, cats_seq.size()):
		if cats_seq[i] == cats_seq[i - 1]:
			same_cat += 1
	var same_pct := 100.0 * same_cat / (cats_seq.size() - 1)
	print(">> 연속 같은 카테고리: %d/%d (%.1f%%)" % [same_cat, cats_seq.size() - 1, same_pct])

	# 고유 단어 노출 수 + 반복 노출 분석
	var stats := WordManager.get_all_stats()
	var word_count := WordManager.get_word_list().size()
	var seen := 0
	var max_exp := 0
	var repeated := 0 # 2회 이상 노출된 단어 수
	for word in stats.keys():
		var e := int(stats[word].get("exposure", 0))
		if e > 0:
			seen += 1
		if e >= 2:
			repeated += 1
		max_exp = max(max_exp, e)
	print(">> 고유 단어 노출: %d/%d  |  반복 노출(2회+) 단어: %d개  |  최대 노출: %d회" % [seen, word_count, repeated, max_exp])

	# 카테고리별 노출 빈도
	var cat_counts: Dictionary = {}
	for c in cats_seq:
		cat_counts[c] = int(cat_counts.get(c, 0)) + 1
	print(">> 카테고리 빈도: ", cat_counts)