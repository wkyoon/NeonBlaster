#!/bin/bash
# sfx_lab.sh - NeonBlaster SFX 후보 비교 도구
# 사용법:
#   ./tools/sfx_lab.sh              # SFX Lab 화면 실행 (눌러서 듣기)
#   ./tools/sfx_lab.sh dump         # 모든 후보를 export/sfx_preview/*.wav 로 덤프
#   ./tools/sfx_lab.sh play         # 덤프 후 afplay 로 전체 순차 재생 (macOS)
#   ./tools/sfx_lab.sh play shoot   # 특정 카테고리만 순차 재생

set -e
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/swyoon/homebrew/bin/godot}"
OUT_DIR="export/sfx_preview"
MODE="${1:-gui}"
FILTER="${2:-}"

do_dump() {
	echo "== SFX 후보 WAV 덤프 =="
	"$GODOT" --headless --path . scenes/SfxLab.tscn -- --dump
	echo ""
	ls -1 "$OUT_DIR" | sed 's/^/  /'
}

case "$MODE" in
	gui)
		exec "$GODOT" --path . scenes/SfxLab.tscn
		;;
	dump)
		do_dump
		;;
	play)
		do_dump
		echo ""
		echo "== 순차 재생 (${FILTER:-전체}) =="
		for f in "$OUT_DIR"/${FILTER:+${FILTER}__}*.wav; do
			[ -e "$f" ] || { echo "일치하는 파일 없음: $FILTER"; exit 1; }
			echo "  ▶ $(basename "$f")"
			afplay "$f"
			sleep 0.35
		done
		;;
	*)
		echo "알 수 없는 모드: $MODE (gui | dump | play)" >&2
		exit 1
		;;
esac
