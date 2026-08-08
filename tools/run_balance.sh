#!/bin/bash
# run_balance.sh - NeonBlaster 밸런스 자동 테스트
# 사용법:
#   ./run_balance.sh                          # 기본: 난이도별 3게임, 60초, 가속, 완벽한 AI
#   BENCH_GAMES=5 ./run_balance.sh            # 난이도당 5게임
#   BENCH_TIME=120 ./run_balance.sh           # 게임당 120초
#   BENCH_DIFFICULTY=hard ./run_balance.sh    # hard만
#   BENCH_FAST=0 ./run_balance.sh             # 실제 속도 (가속 없음)
#   BENCH_AI_ERROR=0.2 ./run_balance.sh       # 일반 플레이어 시뮬레이션 (20% 회피 실패)
#   BENCH_AI_ERROR=0.1 ./run_balance.sh       # 숙련자 시뮬레이션 (10% 회피 실패)
#   BENCH_AI_ERROR=0.0 ./run_balance.sh       # 완벽한 AI (기본값은 0.15 = 목표치 정의 기준)

set -e
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/swyoon/homebrew/bin/godot}"

echo "======================================"
echo "NeonBlaster Balance Auto-Runner"
echo "======================================"
echo "Config: games/diff=${BENCH_GAMES:-3} time=${BENCH_TIME:-60}s diff=${BENCH_DIFFICULTY:-all} fast=${BENCH_FAST:-1} ai_error=${BENCH_AI_ERROR:-0.15}"
echo ""

# ⚠️ 난이도는 **반드시 별도 프로세스**로 측정한다.
#    한 프로세스에서 easy→normal→hard 를 이어 돌리면 WordManager(오토로드)의 학습 통계·
#    테마 상태와 난수 소비량이 난이도 사이로 이어져 앞 난이도가 뒤 난이도를 오염시킨다.
#    실측: NORMAL 의 spawn_interval 만 바꿨는데 손대지 않은 HARD 사망률이 60%→80% 로 움직였다.
# --fixed-fps 도 필수다. 없으면 시드를 고정해도 결과가 재현되지 않는다
#    (실측: 동일 시드 2회에 생존 37.05s vs 28.59s, 킬 35 vs 24).
: > /tmp/neon_bench_live.log
if [ -n "${BENCH_DIFFICULTY:-}" ] && [ "${BENCH_DIFFICULTY}" != "all" ]; then
	DIFFS="${BENCH_DIFFICULTY}"
else
	DIFFS="easy normal hard"
fi
for d in $DIFFS; do
	echo "――― $d ―――"
	BENCH_DIFFICULTY="$d" "$GODOT" --headless --fixed-fps "${BENCH_FPS:-60}" \
		res://scenes/Benchmark.tscn 2>&1 | tee -a /tmp/neon_bench_live.log
done

echo ""
echo "======================================"
echo "Results saved to:"
echo "  - NeonBlaster/benchmark_log.txt     (텍스트 로그)"
echo "  - NeonBlaster/benchmark_results.json (JSON 데이터)"
echo "======================================"