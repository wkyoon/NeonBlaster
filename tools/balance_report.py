#!/usr/bin/env python3
"""balance_report.py - 밸런스 스윕 결과 집계 리포트.

tools/balance_sweep.sh 가 만든 export/balance/sweep_*.json 을 모아
난이도 × AI오차 격자로 통계를 내고, 난이도별 목표치와 비교한다.

시드 하나의 평균은 신뢰할 수 없으므로(관측: 동일 조건 2게임에서 생존 4배 차이)
모든 시드의 개별 게임 결과를 풀링해서 중앙값과 사분위 범위를 본다.

사용법:
    python3 tools/balance_report.py [결과_디렉터리]
"""

import glob
import json
import os
import statistics
import sys

DIFFS = ["EASY", "NORMAL", "HARD"]


def load_runs(out_dir):
    """스윕 JSON 들을 읽어 (오차, 난이도) -> 개별 게임 결과 리스트 로 모은다."""
    grid = {}
    targets = {}
    meta = {"files": 0, "max_time": None, "target_ai_error": 0.15}
    for path in sorted(glob.glob(os.path.join(out_dir, "sweep_*.json"))):
        with open(path) as f:
            data = json.load(f)
        cfg = data.get("config", {})
        err = round(float(cfg.get("ai_dodge_error", 0.0)), 3)
        meta["files"] += 1
        meta["max_time"] = cfg.get("max_time", meta["max_time"])
        meta["target_ai_error"] = round(float(cfg.get("target_ai_error", 0.15)), 3)
        if cfg.get("targets"):
            targets = cfg["targets"]
        for diff, runs in data.get("results", {}).items():
            grid.setdefault((err, diff), []).extend(runs)
    return grid, targets, meta


def stat(runs, key):
    vals = [float(r[key]) for r in runs]
    return {
        "avg": statistics.fmean(vals),
        "med": statistics.median(vals),
        "min": min(vals),
        "max": max(vals),
    }


def death_rate(runs):
    return sum(1 for r in runs if int(r["deaths"]) > 0) / len(runs)


def fmt_range(s):
    return f"{s['med']:5.1f} ({s['min']:.0f}~{s['max']:.0f})"


def print_grid(grid, meta):
    errors = sorted({e for e, _ in grid})
    print("\n" + "=" * 78)
    print("난이도 × AI 오차 격자 — 중앙값 (최소~최대)")
    print("=" * 78)
    for diff in DIFFS:
        rows = [(e, grid[(e, diff)]) for e in errors if (e, diff) in grid]
        if not rows:
            continue
        print(f"\n[{diff}]")
        print(f"  {'AI오차':>7} {'n':>3} {'생존s':>14} {'피격':>14} {'동시적수':>14} "
              f"{'사망률':>7} {'단어/분':>8} {'처치s':>7}")
        for err, runs in rows:
            print(f"  {err:>7.2f} {len(runs):>3} "
                  f"{fmt_range(stat(runs, 'survival_time')):>14} "
                  f"{fmt_range(stat(runs, 'hits_taken')):>14} "
                  f"{fmt_range(stat(runs, 'alive_avg')):>14} "
                  f"{death_rate(runs) * 100:>6.0f}% "
                  f"{stat(runs, 'words_per_min')['med']:>8.1f} "
                  f"{stat(runs, 'ttk_avg')['med']:>7.1f}")


def check_targets(grid, targets, meta):
    """목표 기준 오차값에서 난이도별 PASS/FAIL 판정."""
    ref = meta["target_ai_error"]
    max_time = float(meta["max_time"] or 60.0)
    print("\n" + "=" * 78)
    print(f"목표 대비 판정 (기준 AI오차 {ref:.2f} = 평균적인 인간 근사)")
    print("=" * 78)
    if not targets:
        print("  목표치 정보 없음 (config.targets 누락)")
        return []
    verdicts = []
    for diff in DIFFS:
        runs = grid.get((ref, diff))
        if not runs:
            print(f"\n[{diff}] 기준 오차 데이터 없음")
            continue
        t = targets[diff]
        hits = stat(runs, "hits_taken")["avg"]
        dr = death_rate(runs)
        sr = stat(runs, "survival_time")["avg"] / max_time
        h_lo, h_hi = float(t["hits"][0]), float(t["hits"][1])
        d_lo, d_hi = float(t["death_rate"][0]), float(t["death_rate"][1])
        s_min = float(t["survival_ratio"])
        print(f"\n[{diff}]  n={len(runs)}")
        rows = [
            ("피격", hits, h_lo, h_hi, "%.1f"),
            ("사망률", dr, d_lo, d_hi, "%.2f"),
        ]
        failed = []
        for name, val, lo, hi, f in rows:
            ok = lo <= val <= hi
            mark = "✓" if ok else "✗"
            direction = ""
            if not ok:
                direction = " (목표보다 낮음)" if val < lo else " (목표보다 높음)"
                failed.append((name, val, lo, hi, val < lo))
            print(f"  {mark} {name:<6} {f % val:>7}  목표 {f % lo}~{f % hi}{direction}")
        ok_sr = sr >= s_min
        if not ok_sr:
            failed.append(("생존율", sr, s_min, 1.0, True))
        print(f"  {'✓' if ok_sr else '✗'} {'생존율':<6} {sr:>7.2f}  목표 {s_min:.2f} 이상")
        verdicts.append((diff, failed))
    return verdicts


def check_monotonic(grid, meta):
    """난이도 순서(EASY<NORMAL<HARD)와 스킬 민감도 확인."""
    errors = sorted({e for e, _ in grid})
    print("\n" + "=" * 78)
    print("난이도 순서 & 스킬 민감도")
    print("=" * 78)
    print("\n난이도 순서 (각 오차에서 피격이 EASY < NORMAL < HARD 여야 정상):")
    for err in errors:
        vals = []
        for d in DIFFS:
            runs = grid.get((err, d))
            vals.append(stat(runs, "hits_taken")["avg"] if runs else None)
        if any(v is None for v in vals):
            continue
        ok = vals[0] <= vals[1] <= vals[2]
        print(f"  오차 {err:.2f}: EASY {vals[0]:.1f} → NORMAL {vals[1]:.1f} → HARD {vals[2]:.1f}"
              f"   {'✓ 단조 증가' if ok else '✗ 순서 역전!'}")

    print("\n스킬 민감도 (오차가 커질 때 피격이 얼마나 늘어나는가):")
    print("  기울기가 0에 가까우면 플레이어 실력이 결과에 반영되지 않는다는 뜻.")
    for diff in DIFFS:
        pts = [(e, stat(grid[(e, diff)], "hits_taken")["avg"])
               for e in errors if (e, diff) in grid]
        if len(pts) < 2:
            continue
        e0, h0 = pts[0]
        e1, h1 = pts[-1]
        slope = (h1 - h0) / (e1 - e0) if e1 != e0 else 0.0
        curve = " → ".join(f"{h:.1f}" for _, h in pts)
        verdict = "✓ 실력 반영" if abs(slope) >= 3.0 else "⚠ 실력 반영 약함"
        print(f"  {diff:<7} 피격 {curve}   기울기 {slope:+.1f}/오차1.0  {verdict}")


def suggest(verdicts):
    """FAIL 항목별로 조정할 노브를 제시."""
    print("\n" + "=" * 78)
    print("조정 제안 — EnemySpawner.DIFFICULTY_MULTIPLIERS")
    print("=" * 78)
    print("  ※ 한 번에 하나만 바꾸고 동일 시드셋으로 재측정할 것.\n")
    any_fail = False
    for diff, failed in verdicts:
        if not failed:
            print(f"  [{diff}] 목표 충족 — 변경 불필요")
            continue
        any_fail = True
        print(f"  [{diff}]")
        for name, val, lo, hi, too_low in failed:
            if name == "피격":
                if too_low:
                    print(f"    피격 {val:.1f} < {lo:.1f}: spawn_interval 10~15% 낮추기 (적 더 촘촘)")
                    print(f"                     또는 bullet_speed 10% 올리기")
                else:
                    print(f"    피격 {val:.1f} > {hi:.1f}: spawn_interval 10~15% 올리기")
                    print(f"                     또는 enemy_speed 10% 낮추기")
            elif name == "사망률":
                if too_low:
                    print(f"    사망률 {val:.0%} < {lo:.0%}: 압박이 사망으로 이어지지 않음.")
                    print(f"                     동시 적수를 늘리거나(spawn_interval↓) 무적시간 점검")
                else:
                    print(f"    사망률 {val:.0%} > {hi:.0%}: enemy_hp 낮춰 처치 회전 개선")
            elif name == "생존율":
                print(f"    생존율 {val:.2f} < {lo:.2f}: enemy_hp 또는 spawn_interval 완화")
    if not any_fail:
        print("\n  전 난이도 목표 충족.")


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "export/balance"
    grid, targets, meta = load_runs(out_dir)
    if not grid:
        print(f"결과 없음: {out_dir}/sweep_*.json — 먼저 ./tools/balance_sweep.sh 실행")
        return 1
    total = sum(len(v) for v in grid.values())
    print(f"\n스윕 파일 {meta['files']}개 / 총 게임 {total}개 / 제한시간 {meta['max_time']}s")
    print_grid(grid, meta)
    verdicts = check_targets(grid, targets, meta)
    check_monotonic(grid, meta)
    suggest(verdicts)
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
