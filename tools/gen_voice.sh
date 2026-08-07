#!/bin/bash
# gen_voice.sh - 단어별 음성 안내 파일을 미리 구워 assets/voice/ 에 넣는다.
#
# 왜 미리 굽는가:
#   1) 기기 TTS 엔진마다 발음이 다르다. macOS 는 소문자로 넘기면 단어로 읽지만,
#      안드로이드 엔진은 동작이 달라 같은 문장이 다르게 들린다. 파일로 구우면 편차가 사라진다.
#   2) 대사가 "The word is black." 이 아니라 단어를 실제로 쓰는 문장이다
#      (WordDictionary 의 phrase 필드). 문맥 속 발음을 들려주는 게 학습에 낫다.
#   3) 나중에 **진짜 성우 녹음**으로 교체할 때 같은 파일명으로 덮어쓰기만 하면 된다.
#      게임 코드는 파일이 있으면 재생하고 없으면 TTS 로 폴백한다(AudioManager.speak_word).
#
# 사용법:
#   ./tools/gen_voice.sh              # 전체 생성 (기존 파일은 건너뜀)
#   VOICE=Allison ./tools/gen_voice.sh   # 음성 변경
#   FORCE=1 ./tools/gen_voice.sh      # 기존 파일도 다시 생성
#
# 음성 목록 확인: say -v '?'

set -e
cd "$(dirname "$0")/.."

VOICE="${VOICE:-Ava}"      # macOS 프리미엄 음성. Samantha 보다 자연스럽다.
RATE="${RATE:-165}"        # 학습용이라 조금 느리게 (기본 175~200)
OUT_DIR="assets/voice"

mkdir -p "$OUT_DIR"

if ! say -v "$VOICE" -o /tmp/_voicetest.aiff "test" 2>/dev/null; then
	echo "음성 '$VOICE' 를 쓸 수 없습니다. 사용 가능한 음성: say -v '?'"
	exit 1
fi

echo "음성: $VOICE / 속도: $RATE / 출력: $OUT_DIR"
echo ""

# WordDictionary 에서 (단어, 문장) 쌍을 뽑는다.
python3 - "$OUT_DIR" "$VOICE" "$RATE" "${FORCE:-0}" <<'PY'
import re, subprocess, sys, pathlib

out_dir, voice, rate, force = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "1"
src = pathlib.Path("scripts/WordDictionary.gd").read_text()

pairs = re.findall(r'"([A-Z]+)": \{[^}]*?"phrase": "((?:[^"\\]|\\.)*)"', src)
print("대상 단어 %d개" % len(pairs))

made = skipped = 0
for word, phrase in pairs:
    wav = pathlib.Path(out_dir) / ("%s.wav" % word)
    if wav.exists() and not force:
        skipped += 1
        continue
    aiff = pathlib.Path("/tmp") / ("_voice_%s.aiff" % word)
    subprocess.run(["say", "-v", voice, "-r", rate, "-o", str(aiff), phrase], check=True)
    # 16kHz 모노 16bit PCM. 음성 대역에는 16kHz 로 충분하고 22.05kHz 대비 26% 작다.
    # (Godot 은 임포트 시 QOA 로 한 번 더 압축한다 — 실제 APK 크기는 여기서 다시 5배 준다)
    subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEI16@16000", "-c", "1",
                    str(aiff), str(wav)], check=True)
    aiff.unlink(missing_ok=True)
    made += 1

print("생성 %d개 / 건너뜀 %d개" % (made, skipped))
PY

echo ""
echo "완료. Godot 에서 임포트하려면:"
echo "  godot --headless --import --path ."
