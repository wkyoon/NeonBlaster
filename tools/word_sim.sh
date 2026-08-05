#!/bin/bash
# word_sim.sh - NeonBlaster 단어 선택 알고리즘(연관성/간격반복) 검증
# 가중치 튜닝 후 이 스크립트로 연관성 군집화/반복 노출 효과를 확인하세요.
set -e
cd "$(dirname "$0")/.."

GODOT="${GODOT:-/Users/swyoon/homebrew/bin/godot}"

echo "======================================"
echo "NeonBlaster Word Selection Simulator"
echo "======================================"
echo ""

"$GODOT" --headless res://scenes/WordSim.tscn
