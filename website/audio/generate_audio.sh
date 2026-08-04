#!/bin/bash
# NeonBlaster 단어 발음 파일 생성 스크립트
# macOS say + afconvert 사용 (Samantha 고품질 보이스)

set -e

AUDIO_DIR="$(cd "$(dirname "$0")" && pwd)"
VOICE="Samantha"

# 72개 단어 목록
WORDS=(
	# EASY (3 letters)
	SUN CAT DOG BAT OWL FOX BEE FLY SKY RAY GUN JET ORB ARC ICE GAS RED GEM EYE ARM LEG EAR
	# NORMAL (4-5 letters)
	STAR MOON MARS BIRD FISH BEAR WOLF BLUE GOLD PINK GAME PLAY MOVE FIRE COMET EARTH VENUS SOLAR ORBIT LASER ALIEN ROBOT POWER SWORD BLADE SHIELD GHOST STORM FLAME SHINE LIGHT
	# HARD (6+ letters)
	ROCKET GALAXY PLANET COSMOS NEBULA METEOR SATURN URANUS COMETS STARDUST SPACESHIP ASTEROID ANDROID CYBORG VOLCANO CRYSTAL THUNDER PHANTOM HARDCORE VICTORY
)

echo "🎙️  총 ${#WORDS[@]}개 단어 발음 파일 생성 시작..."
echo "🔊 보이스: $VOICE"
echo "📁 폴더: $AUDIO_DIR"
echo "---"

# 임시 AIFF 파일 정리
rm -f "$AUDIO_DIR"/*.aiff

# 기존 m4a 파일 모두 삭제 (대문자 약어 문제로 재생성)
rm -f "$AUDIO_DIR"/*.m4a
echo "🗑️  기존 파일 삭제 후 재생성 (소문자 발음 수정)"
echo "---"

success=0
fail=0

for word in "${WORDS[@]}"; do
	lower=$(echo "$word" | tr '[:upper:]' '[:lower:]')
	aiff_file="$AUDIO_DIR/${lower}.aiff"
	m4a_file="$AUDIO_DIR/${lower}.m4a"

	# 이미 m4a가 있으면 건너뛰기
	if [ -f "$m4a_file" ]; then
		echo "⏭️  $word (이미 존재)"
		success=$((success + 1))
		continue
	fi

	# say로 AIFF 생성 (소문자로 전달하여 약어 인식 방지)
	if say -v "$VOICE" "$lower" -o "$aiff_file" 2>/dev/null; then
		# afconvert로 m4a 변환 (AAC, 고품질)
		if afconvert -f mp4f -d aac -b 128000 "$aiff_file" "$m4a_file" 2>/dev/null; then
			echo "✅ $word"
			success=$((success + 1))
		else
			echo "🔄 $word (재시도: 기본 비트레이트)"
			if afconvert -f mp4f -d aac "$aiff_file" "$m4a_file" 2>/dev/null; then
				echo "✅ $word"
				success=$((success + 1))
			else
				echo "❌ $word (afconvert 실패)"
				fail=$((fail + 1))
			fi
		fi
	else
		echo "❌ $word (say 실패)"
		fail=$((fail + 1))
	fi

	# AIFF 임시 파일 삭제
	rm -f "$aiff_file"
done

echo "---"
echo "🎉 완료! 성공: $success, 실패: $fail"

# 파일 크기 총합
total_size=$(du -sh "$AUDIO_DIR"/*.m4a 2>/dev/null | tail -1 | awk '{print $1}')
file_count=$(ls -1 "$AUDIO_DIR"/*.m4a 2>/dev/null | wc -l | xargs)
echo "📊 총 ${file_count}개 파일"

# AIFF 임시 파일 정리
rm -f "$AUDIO_DIR"/*.aiff