extends Node
## 어휘 규모가 늘었을 때 깨지는 곳을 확인한다 (개발용).
##
##   godot --headless --path . scenes/VocabScaleCheck.tscn
##
## ⚠️ 어휘를 늘리면 **단어만 늘지 않는다.** "전부 수집" 훈장의 목표가 어긋나고,
##    수집 보상 기체의 최고 기준이 총량보다 한참 아래로 남고, 도감 탭 줄이 길어진다.
##
## ⚠️ **`--script` 모드로 돌리면 안 된다.** `Achievements` 같은 `class_name` 스크립트 안의
##    오토로드 참조(`WordManager.…`)가 전역 식별자로 잡히지 않아 컴파일에 실패한다
##    (실제로 겪었다). 씬으로 띄우면 정상이다 — `WordOrderCheck.tscn` 과 같은 이유다.


func _ready() -> void:
	var fails := 0
	var total: int = WordManager.get_collection_progress().y
	var themes: int = ThemeStages.count()
	print("어휘 %d개 / 테마 %d개 (기본 %d + 심화 %d)" % [
		total, themes, ThemeStages.get_all_words().size(), ThemeStages.get_all_advanced().size()])

	# 1) "전부 수집" 훈장의 목표가 실제 총량과 같은가
	for id in ["words300", "theme25"]:
		var b := Achievements.get_badge(id)
		if b.is_empty():
			print("FAIL 훈장 %s 이 없다" % id)
			fails += 1
			continue
		var goal := Achievements.goal_of(b)
		var want := float(total) if int(b["kind"]) == Achievements.Kind.WORDS else float(themes)
		print("  훈장 %-10s 목표 %.0f / 총량 %.0f" % [id, goal, want])
		if absf(goal - want) > 0.5:
			print("FAIL %s 의 목표가 총량과 다르다 — 숫자가 박혀 있다" % id)
			fails += 1

	# 2) 수집 보상 기체의 최고 기준이 총량에 비해 너무 낮지 않은가
	var top := 0
	for skin in ShipSkins.SKINS:
		top = maxi(top, int(skin.get("collect", 0)))
	var ratio := float(top) / float(total) * 100.0
	print("  수집 해금 기체 최고 기준 %d개 (총량의 %.0f%%)" % [top, ratio])
	if ratio < 60.0:
		print("FAIL 총량의 %.0f%% 지점 이후로는 수집 보상이 없다 — 기준을 늘릴 것" % ratio)
		fails += 1

	# 3) 단어별 음성 파일이 다 있는가. 없으면 기기 TTS 로 떨어져 발음이 흔들린다.
	var missing: Array[String] = []
	var all_words := ThemeStages.get_all_words()
	all_words.append_array(ThemeStages.get_all_advanced())
	for w in all_words:
		if not ResourceLoader.exists("res://assets/voice/%s.mp3" % String(w).to_lower()):
			missing.append(String(w))
	print("  음성 누락 %d개%s" % [missing.size(),
		("" if missing.is_empty() else " — " + ", ".join(missing.slice(0, 8)))])
	if not missing.is_empty():
		print("FAIL 음성이 없는 단어가 있다 — ./tools/gen_voice.sh 를 돌릴 것")
		fails += 1

	print("결과: %s" % ("통과" if fails == 0 else "실패 %d건" % fails))
	get_tree().quit(0 if fails == 0 else 1)
