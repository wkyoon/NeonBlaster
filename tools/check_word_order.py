#!/usr/bin/env python3
"""테마 단어가 **쉬운 것 → 어려운 것** 순으로 정렬돼 있는지 확인한다.

왜 필요한가:
    WordManager 는 ThemeStages 의 배열 **순서 그대로** 단어를 낸다.
    배열 정렬이 깨지면 어려운 단어가 먼저 나와 학습 순서가 무너지는데,
    파스 검사로는 잡히지 않는다.

사용법:
    python3 tools/check_word_order.py     # 문제 없으면 종료 코드 0
"""

import pathlib
import re
import sys


def main() -> int:
    src = pathlib.Path("scripts/ThemeStages.gd").read_text()
    problems = []
    basic_tail = ""
    for m in re.finditer(r'"id": "(\w+)".*?"words": \[(.*?)\].*?"advanced": \[(.*?)\]', src, re.S):
        theme = m.group(1)
        for label, raw in (("words", m.group(2)), ("advanced", m.group(3))):
            words = re.findall(r'"(\w+)"', raw)
            lengths = [len(w) for w in words]
            for i in range(len(lengths) - 1):
                if lengths[i] > lengths[i + 1]:
                    problems.append(
                        "%s/%s: %s(%d) 다음에 %s(%d) — 어려운 단어가 먼저 나온다"
                        % (theme, label, words[i], lengths[i], words[i + 1], lengths[i + 1])
                    )
            if label == "words":
                basic_tail = words[-1] if words else ""
            else:
                # 두 층의 경계도 이어져야 한다. 기본의 마지막이 심화의 첫 단어보다 길면
                # 심화로 넘어가는 순간 난이도가 거꾸로 간다.
                if basic_tail and words and len(basic_tail) > len(words[0]):
                    problems.append(
                        "%s: 기본 마지막 %s(%d) > 심화 첫 %s(%d) — 층 경계에서 역전"
                        % (theme, basic_tail, len(basic_tail), words[0], len(words[0]))
                    )
    if problems:
        print("단어 순서 역전 %d건:" % len(problems))
        for p in problems:
            print("  " + p)
        return 1
    print("모든 테마의 단어가 글자 수 오름차순입니다.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
