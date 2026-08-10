#!/usr/bin/env python3
"""`vocab_new.py` 의 테마·단어를 WordDictionary.gd / ThemeStages.gd 에 반영한다.

왜 생성기로 두는가:
    단어가 300개를 넘어가면 GDScript 를 손으로 고치다 규칙(글자 수 오름차순, 층 경계,
    테마 간 중복 없음)이 깨진다. 데이터는 vocab_new.py 한 곳에 두고 여기서 찍어낸다.

실행:
    python3 tools/gen_vocab.py          # 미리보기만
    python3 tools/gen_vocab.py --write  # 실제 반영
반영 뒤에는 반드시:
    ./tools/gen_voice.sh                # 새 단어 음성 생성
    python3 tools/check_word_order.py
    godot --headless --path . scenes/WordOrderCheck.tscn
"""

import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import vocab_new  # noqa: E402

DICT_PATH = pathlib.Path("scripts/WordDictionary.gd")
STAGE_PATH = pathlib.Path("scripts/ThemeStages.gd")


def avg_len(theme):
	words = [w[0] for w in theme["basic"]]
	return sum(len(w) for w in words) / len(words)


def dict_entry(word, emoji, ko, en, phrase, category):
	return ('\t"%s": {"category": "%s", "emoji": "%s", "ko": "%s", "en": "%s", "phrase": "%s"},'
			% (word, category, emoji, ko, en, phrase))


def build_dict_block(existing):
	lines = ["\t# --- 확장 어휘 --- tools/vocab_new.py 에서 생성. 손으로 고치지 말 것."]
	for theme in vocab_new.THEMES:
		lines.append("\t# %s" % theme["id"])
		for tup in theme["basic"] + theme["advanced"]:
			if tup[0] in existing:
				continue  # 이미 사전에 있는 단어는 건드리지 않는다
			lines.append(dict_entry(tup[0], tup[1], tup[2], tup[3], tup[4], theme["id"]))
	return "\n".join(lines)


def build_stage_block(theme):
	basic = ", ".join('"%s"' % w[0] for w in theme["basic"])
	adv = ", ".join('"%s"' % w[0] for w in theme["advanced"])
	c = lambda t: "Color(%s)" % ", ".join("%.2f" % v for v in t)
	return (
		'\t{\n'
		'\t\t"id": "%s",\n\t\t"name_ko": "%s",\n\t\t"name_en": "%s",\n'
		'\t\t# 평균 %.1f글자 — 스테이지는 이 값 오름차순으로 배치한다(난이도 램프).\n'
		'\t\t"words": [%s],\n'
		'\t\t# 심화 단어 — 위 8개를 모두 모은 뒤 **한 번에 하나씩** 풀린다(글자수 오름차순).\n'
		'\t\t"advanced": [%s],\n'
		'\t\t"bg": %s,\n\t\t"accent": %s,\n\t\t"particle": %s,\n'
		'\t\t"motif": Motif.%s,\n\t},'
		% (theme["id"], theme["name_ko"], theme["name_en"], avg_len(theme),
		   basic, adv, c(theme["bg"]), c(theme["accent"]), c(theme["particle"]), theme["motif"])
	)


def main() -> int:
	write = "--write" in sys.argv
	dict_src = DICT_PATH.read_text()
	# ⚠️ **확장 어휘 블록 안의 단어는 `existing` 에 넣지 마라.**
	#    블록은 아래에서 통째로 새로 쓰인다. 블록 안 단어를 "이미 있음" 으로 건너뛰면
	#    새 블록에 다시 안 담기고, 교체되는 순간 **사전에서 사라진다.**
	#    실제로 겪었다: 1차 확장에서 사전 항목이 337 → 255 로 줄고 EGG·RICE·PIZZA 등
	#    기존 단어가 통째로 빠졌다(ThemeStages 는 목록만 갖고 있어 순서 검사는 통과했다).
	marker_ = "\t# --- 확장 어휘 ---"
	outside = dict_src[:dict_src.index(marker_)] if marker_ in dict_src else dict_src
	existing = set(re.findall(r'^\t"(\w+)":', outside, re.M))

	# 1) 사전 — WORD_DATA 의 닫는 중괄호 앞에 삽입
	block = build_dict_block(existing)
	marker = "\t# --- 확장 어휘 ---"
	if marker in dict_src:
		start = dict_src.index(marker)
		end = dict_src.index("\n}", start)
		new_dict = dict_src[:start] + block + dict_src[end:]
	else:
		close = dict_src.index("\n}\n")
		new_dict = dict_src[:close] + "\n" + block + dict_src[close:]

	# 2) 스테이지 — 기존 6개 + 신규를 평균 글자수 오름차순으로 재배치
	stage_src = STAGE_PATH.read_text()
	head = stage_src[:stage_src.index("const STAGES: Array[Dictionary] = [")]
	tail = stage_src[stage_src.index("\n]\n\n\n## 모든 테마"):]
	body = stage_src[len(head):len(stage_src) - len(tail)]
	old_blocks = re.findall(r'\t\{\n.*?\n\t\},', body, re.S)
	# ⚠️ **vocab_new 에 있는 테마는 기존 블록을 버리고 새로 찍는다.**
	#    이 걸러내기가 없으면 --write 를 두 번 돌릴 때 그 테마가 통째로 **중복**된다
	#    (실측: 25개 → 44개, 19개가 두 벌씩). 생성기는 몇 번 돌려도 결과가 같아야 한다.
	new_ids = {t["id"] for t in vocab_new.THEMES}
	entries = []
	for blk in old_blocks:
		tid = re.search(r'"id": "(\w+)"', blk).group(1)
		if tid in new_ids:
			continue
		words = re.findall(r'"(\w+)"', re.search(r'"words": \[(.*?)\]', blk, re.S).group(1))
		entries.append((sum(len(w) for w in words) / len(words), blk))
	for theme in vocab_new.THEMES:
		entries.append((avg_len(theme), build_stage_block(theme)))
	entries.sort(key=lambda e: e[0])
	new_stage = (head + "const STAGES: Array[Dictionary] = [\n"
				 + "\n".join(e[1] for e in entries) + tail)

	added = block.count('"category"')
	print("사전에 추가할 단어: %d개 (이미 있는 것은 건너뜀)" % added)
	print("스테이지: %d개 → 평균 글자수 순으로 재배치" % len(entries))
	print("  " + " → ".join("%s(%.1f)" % (re.search(r'"id": "(\w+)"', e[1]).group(1), e[0]) for e in entries))
	if not write:
		print("\n(미리보기입니다. 실제 반영하려면 --write)")
		return 0
	DICT_PATH.write_text(new_dict)
	STAGE_PATH.write_text(new_stage)
	print("\n반영 완료.")
	return 0


if __name__ == "__main__":
	sys.exit(main())
