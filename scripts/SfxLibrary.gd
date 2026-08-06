class_name SfxLibrary
extends RefCounted
## SFX 후보 변형 라이브러리 (SFX Lab 미리듣기 전용).
##
## AudioManager 의 실사용 SFX 와는 분리되어 있습니다. 여기서 후보를 여러 개 만들어
## A/B 비교한 뒤, 마음에 드는 변형의 생성 코드를 AudioManager 로 옮기는 흐름입니다.
##
## 사용:
##   var lib := SfxLibrary.new()
##   var wav := lib.generate("shoot_zap")

const SAMPLE_RATE := 44100.0


## 게임 이벤트 카테고리. SFX Lab 의 탭 순서와 동일합니다.
static func categories() -> Array[Dictionary]:
	return [
		{ "key": "shoot", "label": "플레이어 발사" },
		{ "key": "enemy_shoot", "label": "적 발사" },
		{ "key": "hit", "label": "플레이어 피격" },
		{ "key": "explosion", "label": "폭발" },
		{ "key": "enemy_die", "label": "적 파괴" },
		{ "key": "powerup", "label": "파워업" },
		{ "key": "button", "label": "버튼" },
		{ "key": "game_over", "label": "게임 오버" },
	]


## 전체 변형 목록. `cur` 로 끝나는 항목이 현재 게임에 들어간 사운드(기준점)입니다.
static func variants() -> Array[Dictionary]:
	return [
		# ---- 플레이어 발사 ----
		{ "cat": "shoot", "id": "shoot_cur", "label": "현재 (light)", "desc": "920→260Hz 사인 하강" },
		{ "cat": "shoot", "id": "shoot_zap", "label": "레이저 ZAP", "desc": "2.4k→400Hz 급강하 + 링모듈레이션" },
		{ "cat": "shoot", "id": "shoot_plasma", "label": "플라즈마", "desc": "FM 벨 + 노이즈 어택" },
		{ "cat": "shoot", "id": "shoot_pew", "label": "클래식 PEW", "desc": "톱니 하강 + 로우패스 스윕" },
		# ---- 적 발사 ----
		{ "cat": "enemy_shoot", "id": "eshoot_cur", "label": "현재", "desc": "180→520Hz 사각파 상승" },
		{ "cat": "enemy_shoot", "id": "eshoot_growl", "label": "그르렁", "desc": "저역 사각파 + 비브라토 + 드라이브" },
		{ "cat": "enemy_shoot", "id": "eshoot_dart", "label": "더블 틱", "desc": "짧은 블립 2연발" },
		{ "cat": "enemy_shoot", "id": "eshoot_hiss", "label": "히스 스윕", "desc": "필터 노이즈 400→3kHz" },
		# ---- 플레이어 피격 ----
		{ "cat": "hit", "id": "hit_cur", "label": "현재", "desc": "노이즈 + 150Hz 사인" },
		{ "cat": "hit", "id": "hit_thud", "label": "둔탁한 THUD", "desc": "220→55Hz 드롭 + 트랜지언트" },
		{ "cat": "hit", "id": "hit_crack", "label": "크랙", "desc": "노이즈 버스트 + 1.4kHz 링잉" },
		{ "cat": "hit", "id": "hit_shield", "label": "실드 튕김", "desc": "디튠 금속성 3톤" },
		# ---- 폭발 ----
		{ "cat": "explosion", "id": "boom_cur", "label": "현재", "desc": "노이즈 + 60Hz 럼블" },
		{ "cat": "explosion", "id": "boom_deep", "label": "딥 서브붐", "desc": "90→28Hz 서브 + 필터 테일" },
		{ "cat": "explosion", "id": "boom_crunch", "label": "파편 크런치", "desc": "노이즈 + 랜덤 파편 클릭" },
		{ "cat": "explosion", "id": "boom_neon", "label": "네온 시머", "desc": "붐 + 고역 시머 잔향" },
		# ---- 적 파괴 ----
		{ "cat": "enemy_die", "id": "die_cur", "label": "현재", "desc": "400Hz 선형 하강" },
		{ "cat": "enemy_die", "id": "die_pop", "label": "팝", "desc": "700→180Hz 사각파 + 클릭" },
		{ "cat": "enemy_die", "id": "die_digital", "label": "디지털", "desc": "비트크러시 하강 아르페지오" },
		{ "cat": "enemy_die", "id": "die_shatter", "label": "유리 파쇄", "desc": "고역 노이즈 + 톤 클러스터" },
		# ---- 파워업 ----
		{ "cat": "powerup", "id": "power_cur", "label": "현재", "desc": "300→1100Hz 스윕" },
		{ "cat": "powerup", "id": "power_arp", "label": "상승 아르페지오", "desc": "C-E-G-C 4음" },
		{ "cat": "powerup", "id": "power_shimmer", "label": "시머 + 에코", "desc": "스윕 + 딜레이 탭 2개" },
		{ "cat": "powerup", "id": "power_chime", "label": "FM 차임", "desc": "벨 FM 3화음" },
		# ---- 버튼 ----
		{ "cat": "button", "id": "btn_cur", "label": "현재", "desc": "600Hz 짧은 블립" },
		{ "cat": "button", "id": "btn_click", "label": "클릭", "desc": "노이즈 틱 + 900Hz 핑" },
		{ "cat": "button", "id": "btn_soft", "label": "소프트", "desc": "어택 램프 520Hz" },
		{ "cat": "button", "id": "btn_neon", "label": "네온 틱", "desc": "700→1050Hz 2단 틱" },
		# ---- 게임 오버 ----
		{ "cat": "game_over", "id": "over_cur", "label": "현재", "desc": "200Hz 완만한 하강" },
		{ "cat": "game_over", "id": "over_powerdown", "label": "전원 다운", "desc": "300→40Hz + 느려지는 트레몰로" },
		{ "cat": "game_over", "id": "over_sad", "label": "마이너 하강", "desc": "A-F-D 아르페지오 + 저역 서스테인" },
		{ "cat": "game_over", "id": "over_glitch", "label": "글리치", "desc": "비트크러시 스터터 하강" },
	]


## 카테고리에 속한 변형만 필터링.
static func variants_in(cat: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for v in variants():
		if v["cat"] == cat:
			out.append(v)
	return out


## id 로 변형 하나를 합성합니다. 알 수 없는 id 면 null.
func generate(id: String) -> AudioStreamWAV:
	var fn := "_gen_" + id
	if not has_method(fn):
		push_error("[SfxLibrary] 알 수 없는 변형 id: %s" % id)
		return null
	return call(fn) as AudioStreamWAV


# ---------------- 공통 헬퍼 ----------------

func _wav(data: PackedVector2Array) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = true
	var bytes := PackedByteArray()
	bytes.resize(data.size() * 4)
	for i in data.size():
		bytes.encode_s16(i * 4, int(clampf(data[i].x, -1.0, 1.0) * 32767))
		bytes.encode_s16(i * 4 + 2, int(clampf(data[i].y, -1.0, 1.0) * 32767))
	wav.data = bytes
	return wav


func _samples(duration: float) -> int:
	return int(duration * SAMPLE_RATE)


func _noise() -> float:
	return randf() * 2.0 - 1.0


## 위상 누적 방식 파형 (스윕 시 주파수가 정확함).
func _saw(phase: float) -> float:
	return fmod(phase, 1.0) * 2.0 - 1.0


func _square(phase: float) -> float:
	return 1.0 if fmod(phase, 1.0) < 0.5 else -1.0


func _sine(phase: float) -> float:
	return sin(phase * TAU)


## 짧은 어택 램프(클릭 제거) + 지수 감쇠.
func _env_ad(t: float, attack: float, decay: float) -> float:
	var a := 1.0 if attack <= 0.0 else minf(t / attack, 1.0)
	return a * exp(-t * decay)


## 부드러운 새츄레이션 (과입력 시 하드 클립 대신).
func _drive(s: float, amount: float) -> float:
	return tanh(s * (1.0 + amount)) / tanh(1.0 + amount)


## 지수 보간 (주파수 스윕은 선형보다 지수가 자연스럽다).
func _expf(from_v: float, to_v: float, w: float) -> float:
	return from_v * pow(to_v / from_v, clampf(w, 0.0, 1.0))


# ---------------- 플레이어 발사 ----------------

func _gen_shoot_cur() -> AudioStreamWAV:
	var duration := 0.065
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := lerpf(920.0, 260.0, t / duration)
		var env := exp(-t * 38.0)
		var s := (sin(t * freq * TAU) + sin(t * freq * 2.03 * TAU) * 0.24) * env * 0.24
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_shoot_zap() -> AudioStreamWAV:
	var duration := 0.055
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	var ring_phase := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		var freq := _expf(2400.0, 400.0, pow(w, 0.55))
		phase += freq / SAMPLE_RATE
		ring_phase += 190.0 / SAMPLE_RATE
		var env := _env_ad(t, 0.0008, 62.0)
		# 링모듈레이션으로 금속성 레이저 질감
		var core := _sine(phase) * (0.65 + 0.35 * _sine(ring_phase))
		var s := (core + _noise() * 0.12) * env * 0.39
		data[i] = Vector2(s, s * 0.94)
	return _wav(data)


func _gen_shoot_plasma() -> AudioStreamWAV:
	var duration := 0.11
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var carrier := 0.0
	var modulator := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var env := _env_ad(t, 0.002, 26.0)
		modulator += 320.0 / SAMPLE_RATE
		var index := 6.0 * exp(-t * 45.0)
		carrier += (480.0 + _sine(modulator) * 320.0 * index) / SAMPLE_RATE
		var burst := _noise() * exp(-t * 320.0) * 0.5
		var s := (_sine(carrier) + burst) * env * 0.26
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_shoot_pew() -> AudioStreamWAV:
	var duration := 0.09
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	var lp := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		var freq := _expf(1200.0, 180.0, pow(w, 0.7))
		phase += freq / SAMPLE_RATE
		# 컷오프도 같이 내려가서 "뾰옹" 하는 느낌
		var cutoff := _expf(6000.0, 700.0, w)
		var k := clampf(cutoff / (SAMPLE_RATE * 0.5), 0.02, 0.9)
		lp = lerpf(lp, _saw(phase), k)
		var env := _env_ad(t, 0.001, 30.0)
		var s := _drive(lp * env * 0.9, 0.6) * 0.26
		data[i] = Vector2(s, s)
	return _wav(data)


# ---------------- 적 발사 ----------------

func _gen_eshoot_cur() -> AudioStreamWAV:
	var duration := 0.14
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := lerpf(180.0, 520.0, t / duration)
		var env := exp(-t * 24.0)
		var square := 1.0 if sin(t * freq * TAU) >= 0.0 else -1.0
		var s := (square * 0.65 + sin(t * freq * 0.5 * TAU) * 0.35) * env * 0.18
		data[i] = Vector2(s * 0.9, s)
	return _wav(data)


func _gen_eshoot_growl() -> AudioStreamWAV:
	var duration := 0.17
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	var vib := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		vib += 30.0 / SAMPLE_RATE
		var freq := lerpf(90.0, 190.0, w) + _sine(vib) * 14.0
		phase += freq / SAMPLE_RATE
		var env := _env_ad(t, 0.01, 14.0)
		var s := _drive(_square(phase) * 0.5 + _sine(phase * 0.5) * 0.5, 1.4) * env * 0.19
		data[i] = Vector2(s, s * 0.88)
	return _wav(data)


func _gen_eshoot_dart() -> AudioStreamWAV:
	var duration := 0.1
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	# 25ms 블립 2발, 사이 간격 30ms
	var blips: Array[PackedFloat64Array] = [
		PackedFloat64Array([0.0, 900.0]),
		PackedFloat64Array([0.045, 700.0]),
	]
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := 0.0
		for b in blips:
			var lt := t - b[0]
			if lt >= 0.0 and lt < 0.03:
				var env := _env_ad(lt, 0.001, 110.0)
				s += (_sine(lt * b[1]) * 0.7 + _square(lt * b[1] * 2.0) * 0.3) * env
		s *= 0.27
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_eshoot_hiss() -> AudioStreamWAV:
	var duration := 0.18
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var lp := 0.0
	var lp2 := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		var cutoff := _expf(400.0, 3000.0, w)
		var k := clampf(cutoff / (SAMPLE_RATE * 0.5), 0.01, 0.9)
		lp = lerpf(lp, _noise(), k)
		lp2 = lerpf(lp2, lp, k)
		var env := sin(w * PI)
		var s := lp2 * env * 1.0
		data[i] = Vector2(s, s * 0.9)
	return _wav(data)


# ---------------- 플레이어 피격 ----------------

func _gen_hit_cur() -> AudioStreamWAV:
	var duration := 0.15
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 15.0)
		var s := (_noise() * 0.5 + sin(t * 150.0 * TAU) * 0.5) * env * 0.4
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_hit_thud() -> AudioStreamWAV:
	var duration := 0.22
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := _expf(220.0, 55.0, minf(t / 0.12, 1.0))
		phase += freq / SAMPLE_RATE
		var body := _sine(phase) * exp(-t * 16.0)
		var transient := _noise() * exp(-t * 260.0) * 0.7
		var s := _drive(body + transient, 0.8) * 0.34
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_hit_crack() -> AudioStreamWAV:
	var duration := 0.16
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var bp := 0.0
	var bp_prev := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var n := _noise()
		# 1.4kHz 부근 링잉 (2차 공진 근사)
		var target := n * exp(-t * 45.0)
		bp_prev = bp
		bp = lerpf(bp, target, 0.35) + sin(t * 1400.0 * TAU) * exp(-t * 30.0) * 0.35
		var s := (bp * 0.8 + bp_prev * 0.2) * 0.42
		data[i] = Vector2(s, s * 0.92)
	return _wav(data)


func _gen_hit_shield() -> AudioStreamWAV:
	var duration := 0.36
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var partials: Array[PackedFloat64Array] = [
		PackedFloat64Array([1180.0, 1.0, 9.0]),
		PackedFloat64Array([1493.0, 0.6, 11.0]),
		PackedFloat64Array([2361.0, 0.35, 14.0]),
	]
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := 0.0
		for p in partials:
			s += sin(t * p[0] * TAU) * p[1] * exp(-t * p[2])
		s += _noise() * exp(-t * 200.0) * 0.4
		s *= 0.3
		data[i] = Vector2(s, s * 0.85)
	return _wav(data)


# ---------------- 폭발 ----------------

func _gen_boom_cur() -> AudioStreamWAV:
	var duration := 0.6
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 4.0)
		var s := (_noise() * 0.6 + sin(t * 60.0 * TAU) * 0.5 * 0.4) * env * 0.6
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_boom_deep() -> AudioStreamWAV:
	var duration := 0.9
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	var lp := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		var freq := _expf(90.0, 28.0, pow(w, 0.4))
		phase += freq / SAMPLE_RATE
		var cutoff := _expf(3200.0, 180.0, pow(w, 0.5))
		var k := clampf(cutoff / (SAMPLE_RATE * 0.5), 0.005, 0.9)
		lp = lerpf(lp, _noise(), k)
		var sub := _sine(phase) * exp(-t * 2.6)
		var s := _drive(sub * 0.75 + lp * exp(-t * 4.5) * 0.6, 0.5) * 0.45
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_boom_crunch() -> AudioStreamWAV:
	var duration := 0.75
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var lp := 0.0
	# 0.12s 이후 흩날리는 파편 클릭
	var debris: Array[PackedFloat64Array] = []
	for d in 14:
		debris.append(PackedFloat64Array([0.12 + randf() * 0.5, 1200.0 + randf() * 2600.0, 0.25 + randf() * 0.6]))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var k := clampf(_expf(6000.0, 500.0, t / duration) / (SAMPLE_RATE * 0.5), 0.005, 0.9)
		lp = lerpf(lp, _noise(), k)
		var s := lp * exp(-t * 5.0) * 0.9 + sin(t * 70.0 * TAU) * exp(-t * 8.0) * 0.4
		for d in debris:
			var lt := t - d[0]
			if lt >= 0.0 and lt < 0.02:
				s += sin(lt * d[1] * TAU) * exp(-lt * 420.0) * d[2] * 0.35
		s *= 0.55
		data[i] = Vector2(_drive(s, 0.4), _drive(s * 0.93, 0.4))
	return _wav(data)


func _gen_boom_neon() -> AudioStreamWAV:
	var duration := 0.95
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var lp := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var k := clampf(_expf(5000.0, 900.0, minf(t / 0.3, 1.0)) / (SAMPLE_RATE * 0.5), 0.01, 0.9)
		lp = lerpf(lp, _noise(), k)
		var boom := (lp * 0.8 + sin(t * 65.0 * TAU) * 0.5) * exp(-t * 9.0)
		# 네온 감성 고역 시머 잔향 (디튠 3톤 + 트레몰로)
		var trem := 0.6 + 0.4 * sin(t * 11.0 * TAU)
		var shimmer := (sin(t * 1568.0 * TAU) + sin(t * 1572.0 * TAU) * 0.8 + sin(t * 2093.0 * TAU) * 0.5)
		shimmer *= exp(-t * 2.4) * trem * 0.12
		var s := (boom * 0.85 + shimmer) * 0.77
		data[i] = Vector2(s, s * 0.9 + shimmer * 0.1)
	return _wav(data)


# ---------------- 적 파괴 ----------------

func _gen_die_cur() -> AudioStreamWAV:
	var duration := 0.2
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := 400.0 * (1.0 - t / duration)
		var s := sin(t * freq * TAU) * exp(-t * 10.0) * 0.35
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_die_pop() -> AudioStreamWAV:
	var duration := 0.14
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := _expf(700.0, 180.0, pow(t / duration, 0.6))
		phase += freq / SAMPLE_RATE
		var env := _env_ad(t, 0.0015, 22.0)
		var s := (_square(phase) * 0.45 + _sine(phase) * 0.55) * env
		s += _noise() * exp(-t * 300.0) * 0.35
		s *= 0.35
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_die_digital() -> AudioStreamWAV:
	var duration := 0.26
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var steps := PackedFloat64Array([880.0, 660.0, 440.0, 294.0])
	var step_len := duration / float(steps.size())
	var phase := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var idx := clampi(int(t / step_len), 0, steps.size() - 1)
		phase += steps[idx] / SAMPLE_RATE
		var lt := t - float(idx) * step_len
		var env := _env_ad(lt, 0.001, 26.0)
		var raw := _square(phase) * 0.6 + _saw(phase) * 0.4
		# 4비트 비트크러시
		var s := roundf(raw * 8.0) / 8.0 * env * 0.5
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_die_shatter() -> AudioStreamWAV:
	var duration := 0.32
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var shards: Array[PackedFloat64Array] = []
	for s_i in 6:
		shards.append(PackedFloat64Array([randf() * 0.12, 1800.0 + randf() * 3200.0, 0.4 + randf() * 0.6]))
	var hp_prev := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var n := _noise()
		# 1차 하이패스(직전 샘플 차분)로 고역만 남김
		var high := n - hp_prev
		hp_prev = n
		var s := high * exp(-t * 16.0) * 0.5
		for sh in shards:
			var lt := t - sh[0]
			if lt >= 0.0:
				s += sin(lt * sh[1] * TAU) * exp(-lt * 26.0) * sh[2] * 0.18
		s *= 0.6
		data[i] = Vector2(s, s * 0.9)
	return _wav(data)


# ---------------- 파워업 ----------------

func _gen_power_cur() -> AudioStreamWAV:
	var duration := 0.3
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := 300.0 + 800.0 * (t / duration)
		var s := sin(t * freq * TAU) * sin(t * PI / duration) * 0.3
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_power_arp() -> AudioStreamWAV:
	var duration := 0.34
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var notes := PackedFloat64Array([523.25, 659.25, 783.99, 1046.5])
	var step := 0.07
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := 0.0
		for n_i in notes.size():
			var lt := t - float(n_i) * step
			if lt >= 0.0:
				var env := _env_ad(lt, 0.004, 11.0)
				s += (sin(lt * notes[n_i] * TAU) + sin(lt * notes[n_i] * 2.0 * TAU) * 0.3) * env
		s *= 0.22
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_power_shimmer() -> AudioStreamWAV:
	var duration := 0.5
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var dry := PackedFloat64Array()
	dry.resize(data.size())
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := minf(t / 0.24, 1.0)
		var freq := _expf(300.0, 1600.0, w)
		dry[i] = sin(t * freq * TAU) * _env_ad(t, 0.01, 9.0)
	# 딜레이 탭 2개 (0.09s / 0.18s)
	var d1 := int(0.09 * SAMPLE_RATE)
	var d2 := int(0.18 * SAMPLE_RATE)
	for i in data.size():
		var tap1 := dry[i - d1] if i >= d1 else 0.0
		var tap2 := dry[i - d2] if i >= d2 else 0.0
		# 좌우 탭 비중을 달리해 넓게 퍼지는 느낌
		var l := (dry[i] + tap1 * 0.45 + tap2 * 0.20) * 0.47
		var r := (dry[i] + tap1 * 0.22 + tap2 * 0.40) * 0.47
		data[i] = Vector2(l, r)
	return _wav(data)


func _gen_power_chime() -> AudioStreamWAV:
	var duration := 0.6
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var chord := PackedFloat64Array([523.25, 659.25, 783.99])
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := 0.0
		for f in chord:
			# 벨 FM: 모듈레이터 = 3.5배, 인덱스 빠르게 감쇠
			var index := 3.0 * exp(-t * 12.0)
			var mod_v := sin(t * f * 3.5 * TAU) * index
			s += sin(t * f * TAU + mod_v) * exp(-t * 4.5)
		s *= 0.24
		data[i] = Vector2(s, s * 0.95)
	return _wav(data)


# ---------------- 버튼 ----------------

func _gen_btn_cur() -> AudioStreamWAV:
	var duration := 0.06
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := sin(t * 600.0 * TAU) * exp(-t * 30.0) * 0.25
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_btn_click() -> AudioStreamWAV:
	var duration := 0.055
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var tick := _noise() * exp(-t * 500.0) * 0.6
		var ping := sin(t * 900.0 * TAU) * _env_ad(t, 0.0008, 70.0) * 0.7
		var s := (tick + ping) * 0.40
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_btn_soft() -> AudioStreamWAV:
	var duration := 0.1
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var env := _env_ad(t, 0.008, 22.0)
		var s := (sin(t * 520.0 * TAU) + sin(t * 1040.0 * TAU) * 0.18) * env * 0.28
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_btn_neon() -> AudioStreamWAV:
	var duration := 0.075
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := 0.0
		if t < 0.028:
			s = sin(t * 700.0 * TAU) * _env_ad(t, 0.001, 90.0)
		else:
			var lt := t - 0.028
			s = sin(lt * 1050.0 * TAU) * _env_ad(lt, 0.001, 70.0)
		s *= 0.30
		data[i] = Vector2(s, s)
	return _wav(data)


# ---------------- 게임 오버 ----------------

func _gen_over_cur() -> AudioStreamWAV:
	var duration := 0.8
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var freq := 200.0 * (1.0 - t / duration * 0.6)
		var s := sin(t * freq * TAU) * exp(-t * 2.5) * 0.4
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_over_powerdown() -> AudioStreamWAV:
	var duration := 1.1
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	var trem_phase := 0.0
	var lp := 0.0
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		var freq := _expf(300.0, 40.0, pow(w, 0.8))
		phase += freq / SAMPLE_RATE
		# 트레몰로가 점점 느려지며 전원 꺼지는 느낌
		trem_phase += lerpf(18.0, 3.0, w) / SAMPLE_RATE
		var trem := 0.55 + 0.45 * _sine(trem_phase)
		var k := clampf(_expf(2400.0, 200.0, w) / (SAMPLE_RATE * 0.5), 0.005, 0.9)
		lp = lerpf(lp, _noise(), k)
		var s := (_sine(phase) * 0.8 + lp * 0.25) * trem * exp(-t * 1.6) * 0.64
		data[i] = Vector2(s, s)
	return _wav(data)


func _gen_over_sad() -> AudioStreamWAV:
	var duration := 1.2
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var notes := PackedFloat64Array([440.0, 349.23, 293.66])
	var step := 0.22
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var s := 0.0
		for n_i in notes.size():
			var lt := t - float(n_i) * step
			if lt >= 0.0:
				var env := _env_ad(lt, 0.01, 3.4)
				s += (sin(lt * notes[n_i] * TAU) + sin(lt * notes[n_i] * 2.0 * TAU) * 0.22) * env * 0.5
		# 저역 서스테인으로 무게감
		s += sin(t * 73.4 * TAU) * exp(-t * 1.5) * 0.35
		s *= 0.51
		data[i] = Vector2(s, s * 0.94)
	return _wav(data)


func _gen_over_glitch() -> AudioStreamWAV:
	var duration := 0.9
	var data := PackedVector2Array()
	data.resize(_samples(duration))
	var phase := 0.0
	var held := 0.0
	var hold_len := int(SAMPLE_RATE / 5500.0)
	for i in data.size():
		var t := float(i) / SAMPLE_RATE
		var w := t / duration
		var freq := _expf(420.0, 60.0, pow(w, 0.7))
		phase += freq / SAMPLE_RATE
		var raw := _square(phase) * 0.5 + _saw(phase * 1.005) * 0.5
		# 샘플 홀드 + 3비트 양자화
		if i % hold_len == 0:
			held = roundf(raw * 4.0) / 4.0
		# 스터터 게이트 (12Hz)
		var gate := 1.0 if fmod(t * 12.0, 1.0) < 0.6 else 0.15
		var s := held * gate * exp(-t * 1.9) * 0.56
		data[i] = Vector2(s, s * 0.9)
	return _wav(data)
