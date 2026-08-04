#!/bin/bash
# run_balance.sh - NeonBlaster 밸런스 자동 테스트
# 사용법:
#   ./run_balance.sh                  # 기본: 난이도별 3게임, 90초, 가속
#   BENCH_GAMES=5 ./run_balance.sh    # 난이도당 5게임
#   BENCH_TIME=120 ./run_balance.sh   # 게임당 120초
#   BENCH_DIFFICULTY=hard ./run_balance.sh  # hard만
#   BENCH_FAST=0 ./run_balance.sh     # 실제 속도 (가속 없음)

set -e
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/swyoon/homebrew/bin/godot}"

echo "======================================"
echo "NeonBlaster Balance Auto-Runner"
echo "======================================"
echo "Config: games/diff=${BENCH_GAMES:-3} time=${BENCH_TIME:-90}s diff=${BENCH_DIFFICULTY:-all} fast=${BENCH_FAST:-1}"
echo ""

"$GODOT" --headless res://scenes/Benchmark.tscn 2>&1 | tee /tmp/neon_bench_live.log

echo ""
echo "======================================"
echo "Results saved to:"
echo "  - NeonBlaster/benchmark_log.txt     (텍스트 로그)"
echo "  - NeonBlaster/benchmark_results.json (JSON 데이터)"
echo "======================================"