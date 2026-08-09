#!/usr/bin/env python3
"""알파 테스터 판 기록(JSONL)을 밸런스 관점으로 집계한다.

    python3 tools/telemetry_report.py export/telemetry/*.jsonl

⚠️ **end_reason 으로 먼저 갈라야 한다.** AI 벤치마크는 사망률 100% 지만 사람은 지하철에서
   내리면서 그냥 끈다. 중도 이탈(quit) 판의 생존 시간을 사망 판과 같이 평균 내면
   "너무 어렵다" 로 잘못 읽힌다. 밸런스 판단에는 died/survived 만 쓴다.

⚠️ **표본이 적으면 아무것도 판단하지 마라.** 같은 조건 2게임에서 생존 26.2s vs 6.7s(4배)
   가 관측된 게임이다. 구간당 MIN_RUNS 미만이면 수치를 내되 판단은 보류한다.
"""

from __future__ import annotations

import json
import sys
from collections import defaultdict
from statistics import median

# 이 미만이면 중앙값이 흔들려 노브를 만질 근거가 못 된다.
MIN_RUNS = 30

# 벤치마크의 세 지점과 맞춘 보너스 분수 구간 (Benchmark.DIFFICULTY_TARGETS 와 대응).
BUCKETS = [
    ("첫날 (EASY)", 0, 2),
    ("중반 (NORMAL)", 3, 9),
    ("상한 (HARD)", 10, 20),
]

# Benchmark.DIFFICULTY_TARGETS 와 같은 값. 여기가 갈라지면 두 자료를 못 비교한다.
TARGET_ALIVE = (3.5, 8.0)
TARGET_DEATH_RATE = (0.90, 1.00)

# 밸런스 판단에 쓰는 종료 사유. 나머지는 세기만 한다.
VALID_REASONS = {"died", "survived"}


def load(paths: list[str]) -> list[dict]:
    runs: list[dict] = []
    for p in paths:
        with open(p, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    runs.append(json.loads(line))
                except json.JSONDecodeError:
                    print(f"  ! 깨진 줄 무시: {p}", file=sys.stderr)
    return runs


def med(values: list[float]) -> float:
    return median(values) if values else 0.0


def fmt_mmss(seconds: float) -> str:
    return f"{int(seconds) // 60}:{int(seconds) % 60:02d}"


def bucket_of(run: dict) -> str | None:
    bonus = run.get("bonus_minutes")
    if bonus is None:
        return None
    for name, lo, hi in BUCKETS:
        if lo <= bonus <= hi:
            return name
    return None


def main(paths: list[str]) -> int:
    runs = load(paths)
    if not runs:
        print("자료가 없다.")
        return 1

    testers = {r.get("install_id") for r in runs}
    reasons: dict[str, int] = defaultdict(int)
    for r in runs:
        reasons[str(r.get("end_reason", "?"))] += 1

    print(f"판 {len(runs)}개 · 테스터 {len(testers)}명")
    print("종료 사유:", "  ".join(f"{k}={v}" for k, v in sorted(reasons.items())))
    dropped = sum(v for k, v in reasons.items() if k not in VALID_REASONS)
    if dropped:
        pct = dropped / len(runs) * 100
        print(f"  → 밸런스 판단에서 제외: {dropped}판 ({pct:.0f}%) — quit/background 는 난이도 신호가 아니다")
    print()

    by_bucket: dict[str, list[dict]] = defaultdict(list)
    for r in runs:
        if str(r.get("end_reason")) not in VALID_REASONS:
            continue
        name = bucket_of(r)
        if name:
            by_bucket[name].append(r)

    header = f"{'구간':<16}{'판':>5}{'생존(중앙)':>12}{'목표대비':>10}{'사망률':>8}{'동시적':>8}{'단어/분':>9}{'fps p10':>9}"
    print(header)
    print("-" * 77)

    verdicts: list[str] = []
    for name, _lo, _hi in BUCKETS:
        rs = by_bucket.get(name, [])
        if not rs:
            print(f"{name:<16}{0:>5}{'-':>12}{'-':>10}{'-':>8}{'-':>8}{'-':>9}{'-':>9}")
            continue
        surv = med([float(r.get("survival_time", 0)) for r in rs])
        ratio = med([float(r.get("survival_ratio", 0)) for r in rs])
        death = sum(1 for r in rs if r.get("end_reason") == "died") / len(rs)
        alive = med([float(r.get("alive_avg", 0)) for r in rs])
        wpm = med([float(r.get("words_per_min", 0)) for r in rs])
        fps = med([float(r.get("fps_p10", 0)) for r in rs])
        print(
            f"{name:<16}{len(rs):>5}{fmt_mmss(surv):>12}{ratio * 100:>9.0f}%"
            f"{death * 100:>7.0f}%{alive:>8.1f}{wpm:>9.1f}{fps:>9.0f}"
        )

        if len(rs) < MIN_RUNS:
            verdicts.append(f"  · {name}: 표본 {len(rs)}판 — {MIN_RUNS}판 미만이라 판단 보류")
            continue
        if not TARGET_ALIVE[0] <= alive <= TARGET_ALIVE[1]:
            side = "한산하다" if alive < TARGET_ALIVE[0] else "북적인다"
            verdicts.append(
                f"  · {name}: 동시 적 {alive:.1f} — 목표 {TARGET_ALIVE[0]}~{TARGET_ALIVE[1]} 밖이다({side})"
            )
        if death < TARGET_DEATH_RATE[0]:
            verdicts.append(
                f"  · {name}: 사망률 {death * 100:.0f}% — 판에 끝이 없다(목표 90% 이상)"
            )
        if ratio < 0.8:
            verdicts.append(f"  · {name}: 목표의 {ratio * 100:.0f}% 에서 죽는다 — 너무 어렵다")
        elif ratio > 1.25:
            verdicts.append(f"  · {name}: 목표의 {ratio * 100:.0f}% 까지 산다 — 너무 쉽다")

    print()
    if verdicts:
        print("진단:")
        for v in verdicts:
            print(v)
    else:
        print("진단: 목표 범위 안이다.")

    # AI 오차 보정 근거. BENCH_AI_ERROR=0.15 가 "평균적인 인간" 이라는 가정은
    # 지금까지 검증된 적이 없다 — 실제 분포를 보고 맞춰야 벤치마크가 사람을 대변한다.
    valid = [r for r in runs if str(r.get("end_reason")) in VALID_REASONS]
    if len(valid) >= MIN_RUNS:
        ratios = sorted(float(r.get("survival_ratio", 0)) for r in valid)
        p25 = ratios[len(ratios) // 4]
        p75 = ratios[len(ratios) * 3 // 4]
        print()
        print("실력 분포(목표 대비 생존):")
        print(f"  하위25% {p25 * 100:.0f}%   중앙 {med(ratios) * 100:.0f}%   상위25% {p75 * 100:.0f}%")
        print("  → 벤치마크 BENCH_AI_ERROR 를 중앙값이 맞는 값으로 재보정할 것")

    per_tester: dict[str, int] = defaultdict(int)
    for r in runs:
        per_tester[str(r.get("install_id"))] += 1
    counts = sorted(per_tester.values(), reverse=True)
    if counts:
        print()
        print(f"테스터별 판 수: 최대 {counts[0]} · 중앙 {int(med([float(c) for c in counts]))} · 최소 {counts[-1]}")
        if counts[0] > len(runs) * 0.5:
            print("  ⚠ 한 명이 절반 넘게 차지한다 — 그 사람의 실력이 곧 결론이 된다")
    return 0


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(args))
