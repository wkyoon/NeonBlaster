#!/bin/bash
# balance_sweep.sh - NeonBlaster 밸런스 스윕 러너
#
# 단일 벤치마크는 분산이 커서(관측: HARD 동일 조건 2게임에서 생존 26.2s vs 6.7s)
# 평균 하나로 노브를 만지면 노이즈를 쫓게 된다. 이 스크립트는
#   (시드) × (AI 회피 실패율) 격자로 반복 측정해 표본을 모은 뒤
#   tools/balance_report.py 로 중앙값·분산·스킬 민감도를 뽑는다.
#
# 사용법:
#   ./tools/balance_sweep.sh                        # 기본 격자로 스윕 + 리포트
#   SWEEP_SEEDS="1 2 3" ./tools/balance_sweep.sh    # 시드 3개만
#   SWEEP_ERRORS="0.15" ./tools/balance_sweep.sh    # 오차 1개만 (빠른 확인)
#   SWEEP_TIME=90 ./tools/balance_sweep.sh          # 게임당 90초
#   SWEEP_KEEP=1 ./tools/balance_sweep.sh           # 기존 결과에 이어붙이기
#
# 환경변수:
#   SWEEP_SEEDS      - 시드 목록 (기본 "1 2 3 4 5")
#   SWEEP_ERRORS     - AI 회피 실패율 목록 (기본 "0.0 0.15 0.3")
#                      0.0=완벽 / 0.15=평균적인 인간(목표 기준점) / 0.3=초보
#   SWEEP_GAMES      - 시드당·난이도당 게임 수 (기본 1)
#   SWEEP_TIME       - 게임당 제한시간 초 (기본 60)
#   SWEEP_DIFFICULTY - easy / normal / hard / all (기본 all)
#   SWEEP_KEEP       - 1이면 기존 결과 JSON 유지 (기본 0 = 지우고 새로 시작)

set -e
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/swyoon/homebrew/bin/godot}"
OUT_DIR="export/balance"

SEEDS="${SWEEP_SEEDS:-1 2 3 4 5}"
ERRORS="${SWEEP_ERRORS:-0.0 0.15 0.3}"
GAMES="${SWEEP_GAMES:-1}"
TIME_LIMIT="${SWEEP_TIME:-60}"
DIFFICULTY="${SWEEP_DIFFICULTY:-all}"

mkdir -p "$OUT_DIR"
if [ "${SWEEP_KEEP:-0}" != "1" ]; then
	rm -f "$OUT_DIR"/sweep_*.json "$OUT_DIR"/sweep_*.txt
fi

n_seeds=$(echo $SEEDS | wc -w | tr -d ' ')
n_errors=$(echo $ERRORS | wc -w | tr -d ' ')
n_diffs=1
[ "$DIFFICULTY" = "all" ] && n_diffs=3
total_games=$(( n_seeds * n_errors * n_diffs * GAMES ))
# fast 모드(time_scale=3)라 벽시계 시간은 대략 sim시간/3 + 게임당 오버헤드
est_sec=$(( total_games * TIME_LIMIT / 3 + total_games * 3 ))

echo "======================================"
echo "NeonBlaster Balance Sweep"
echo "======================================"
echo "  시드:     $SEEDS ($n_seeds개)"
echo "  AI 오차:  $ERRORS ($n_errors개)"
echo "  난이도:    $DIFFICULTY | 게임/조합: $GAMES | 제한시간: ${TIME_LIMIT}s"
echo "  총 게임 수: $total_games  (예상 소요 약 $((est_sec / 60))분 $((est_sec % 60))초)"
echo "======================================"
echo ""

# ⚠️ 난이도는 **반드시 별도 프로세스**로 돌린다.
# 한 프로세스에서 easy→normal→hard 를 순차 실행하면 WordManager(오토로드)의 학습 통계·테마 상태와
# 난수 소비량이 난이도 간에 이어져, 앞 난이도의 결과가 뒤 난이도를 오염시킨다.
# (실측: EASY 배수만 바꿨는데 NORMAL 사망률 60%→80%, HARD 생존 54.3s→33.9s 로 함께 움직였다.)
if [ "$DIFFICULTY" = "all" ]; then
	DIFF_LIST="easy normal hard"
else
	DIFF_LIST="$DIFFICULTY"
fi

n_total=$(( n_seeds * n_errors * $(echo $DIFF_LIST | wc -w | tr -d ' ') ))
run_i=0
for err in $ERRORS; do
	for sd in $SEEDS; do
		for df in $DIFF_LIST; do
			run_i=$(( run_i + 1 ))
			tag="sweep_e${err}_s${sd}_${df}"
			printf "[%2d/%d] err=%-5s seed=%-3s diff=%-7s ... " "$run_i" "$n_total" "$err" "$sd" "$df"
			BENCH_GAMES="$GAMES" \
			BENCH_TIME="$TIME_LIMIT" \
			BENCH_DIFFICULTY="$df" \
			BENCH_AI_ERROR="$err" \
			BENCH_SEED="$sd" \
			BENCH_OUT="res://$OUT_DIR/$tag" \
				"$GODOT" --headless --fixed-fps "${BENCH_FPS:-60}" res://scenes/Benchmark.tscn > "/tmp/${tag}.stdout" 2>&1
			if [ -f "$OUT_DIR/$tag.json" ]; then
				echo "OK"
			else
				echo "실패 (로그: /tmp/${tag}.stdout)"
			fi
		done
	done
done

echo ""
echo "======================================"
echo "스윕 완료 — 리포트 생성"
echo "======================================"
python3 tools/balance_report.py "$OUT_DIR"
