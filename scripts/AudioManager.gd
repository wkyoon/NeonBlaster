extends Node
## AudioManager (Autoload)
## Procedural SFX generation using AudioStreamGenerator.
## No external sound files required - all SFX are synthesized at runtime.

const SAMPLE_RATE := 44100.0

var _bus_master := "Master"
var _bus_sfx := "SFX"
var _bus_music := "Music"

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _bgm_stream: AudioStreamWAV = null
var _next_player_index: int = 0
const MAX_SFX_PLAYERS := 8

var _sfx_volume: float = 1.0
var _music_volume: float = 0.7
var _is_initialized: bool = false

# Individual toggles for SFX, BGM, TTS
var sfx_enabled: bool = true
var music_enabled: bool = true
var tts_enabled: bool = true
const SAVE_PATH := "user://audio_settings.cfg"


func _ready() -> void:
	_load_settings()
	_setup_buses()
	_setup_players()
	_generate_sfx_cache()
	_apply_toggles()
	_is_initialized = true
	print("[AudioManager] Initialized. SFX=%s BGM=%s TTS=%s" % [sfx_enabled, music_enabled, tts_enabled])
	print("[AudioManager] Buses: Master=%d SFX=%d Music=%d" % [
		AudioServer.get_bus_index(_bus_master),
		AudioServer.get_bus_index(_bus_sfx),
		AudioServer.get_bus_index(_bus_music)
	])
	# Auto-start the procedural background music (loops for the whole session).
	call_deferred("play_bgm")


func _ensure_bus(bus_name: String) -> int:
	# Returns the bus index, creating the bus if it doesn't exist.
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")
	return idx


func _setup_buses() -> void:
	# Ensure SFX and Music buses exist
	var sfx_idx := _ensure_bus(_bus_sfx)
	var music_idx := _ensure_bus(_bus_music)
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(_sfx_volume))
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(_music_volume))


func _setup_players() -> void:
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = _bus_sfx
		add_child(player)
		_sfx_players.append(player)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = _bus_music
	add_child(_music_player)


# SFX definitions cache
var _sfx_cache: Dictionary = {}


func _apply_toggles() -> void:
	var sfx_idx := AudioServer.get_bus_index(_bus_sfx)
	var music_idx := AudioServer.get_bus_index(_bus_music)
	if sfx_idx != -1:
		AudioServer.set_bus_mute(sfx_idx, not sfx_enabled)
	if music_idx != -1:
		AudioServer.set_bus_mute(music_idx, not music_enabled)


func _generate_sfx_cache() -> void:
	# Generate procedural SFX as AudioStreamWAV
	_sfx_cache["shoot_light"] = _gen_sfx_shoot(920.0, 260.0, 0.065, 0.24, 0.0)
	_sfx_cache["shoot_pulse"] = _gen_sfx_shoot(720.0, 170.0, 0.09, 0.30, 0.45)
	_sfx_cache["shoot_heavy"] = _gen_sfx_shoot(540.0, 105.0, 0.12, 0.36, 0.8)
	_sfx_cache["enemy_shoot"] = _gen_sfx_enemy_shoot()
	_sfx_cache["hit"] = _gen_sfx_hit()
	_sfx_cache["explosion"] = _gen_sfx_explosion()
	_sfx_cache["enemy_die"] = _gen_sfx_enemy_die()
	_sfx_cache["powerup"] = _gen_sfx_powerup()
	_sfx_cache["button"] = _gen_sfx_button()
	_sfx_cache["game_over"] = _gen_sfx_game_over()


# ---------------- SFX Generators ----------------

func _create_wav(data: PackedVector2Array, mix_rate: int = 44100) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = true
	var bytes := PackedByteArray()
	bytes.resize(data.size() * 4)
	for i in data.size():
		var s := clampf(data[i].x, -1.0, 1.0)
		var sample := int(s * 32767)
		bytes.encode_s16(i * 4, sample)
		var s2 := clampf(data[i].y, -1.0, 1.0)
		var sample2 := int(s2 * 32767)
		bytes.encode_s16(i * 4 + 2, sample2)
	wav.data = bytes
	return wav


func _gen_sfx_shoot(start_freq: float, end_freq: float, duration: float, amplitude: float, grit: float) -> AudioStreamWAV:
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := t / duration
		var freq := lerpf(start_freq, end_freq, progress)
		var env := exp(-t * 38.0)
		var tone := sin(t * freq * TAU)
		var harmonic := sin(t * freq * 2.03 * TAU) * 0.24
		var noise := (randf() * 2.0 - 1.0) * grit
		var s := (tone + harmonic + noise) * env * amplitude
		data[i] = Vector2(s, s)
	return _create_wav(data)


func _gen_sfx_enemy_shoot() -> AudioStreamWAV:
	var duration := 0.14
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var freq := lerpf(180.0, 520.0, t / duration)
		var env := exp(-t * 24.0)
		var square := 1.0 if sin(t * freq * TAU) >= 0.0 else -1.0
		var s := (square * 0.65 + sin(t * freq * 0.5 * TAU) * 0.35) * env * 0.18
		data[i] = Vector2(s * 0.9, s)
	return _create_wav(data)


func _gen_sfx_hit() -> AudioStreamWAV:
	var duration := 0.15
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 15.0)
		var noise := (randf() * 2.0 - 1.0) * 0.5
		var tone := sin(t * 150.0 * TAU) * 0.5
		var s := (noise + tone) * env * 0.4
		data[i] = Vector2(s, s)
	return _create_wav(data)


func _gen_sfx_explosion() -> AudioStreamWAV:
	var duration := 0.6
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 4.0)
		var noise := (randf() * 2.0 - 1.0)
		var rumble := sin(t * 60.0 * TAU) * 0.5
		var s := (noise * 0.6 + rumble * 0.4) * env * 0.6
		data[i] = Vector2(s, s)
	return _create_wav(data)


func _gen_sfx_enemy_die() -> AudioStreamWAV:
	var duration := 0.2
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var freq := 400.0 * (1.0 - t / duration)
		var env := exp(-t * 10.0)
		var s := sin(t * freq * TAU) * env * 0.35
		data[i] = Vector2(s, s)
	return _create_wav(data)


func _gen_sfx_powerup() -> AudioStreamWAV:
	var duration := 0.3
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var freq := 300.0 + 800.0 * (t / duration)
		var env := sin(t * PI / duration)
		var s := sin(t * freq * TAU) * env * 0.3
		data[i] = Vector2(s, s)
	return _create_wav(data)


func _gen_sfx_button() -> AudioStreamWAV:
	var duration := 0.06
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var env := exp(-t * 30.0)
		var s := sin(t * 600.0 * TAU) * env * 0.25
		data[i] = Vector2(s, s)
	return _create_wav(data)


func _gen_sfx_game_over() -> AudioStreamWAV:
	var duration := 0.8
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var freq := 200.0 * (1.0 - t / duration * 0.6)
		var env := exp(-t * 2.5)
		var s := sin(t * freq * TAU) * env * 0.4
		data[i] = Vector2(s, s)
	return _create_wav(data)


# ---------------- Playback ----------------

func play_sfx(name: String) -> void:
	if not _is_initialized:
		return
	if not sfx_enabled:
		return
	if not _sfx_cache.has(name):
		return
	var player := _sfx_players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % MAX_SFX_PLAYERS
	player.stream = _sfx_cache[name]
	player.play()


## 무기 단계에 맞는 발사음 중 하나를 골라 연사 반복감을 줄입니다.
func play_shoot(weapon_level: int) -> void:
	var variants: Array[String] = ["shoot_light", "shoot_pulse"]
	if weapon_level >= 3:
		variants.append("shoot_heavy")
	play_sfx(variants[randi() % variants.size()])


func play_music(stream: AudioStream) -> void:
	if _music_player:
		_music_player.stream = stream
		_music_player.volume_db = linear_to_db(_music_volume)
		if music_enabled:
			_music_player.play()
		else:
			_music_player.stop()


func stop_music() -> void:
	if _music_player:
		_music_player.stop()


## BGM 이 실제로 재생 중인지 (SFX Lab 등 외부 화면에서 토글 표시용).
func is_music_playing() -> bool:
	return _music_player != null and _music_player.playing


## Convenience helper: generate (once, cached) and play the procedural BGM.
func play_bgm() -> void:
	if _bgm_stream == null:
		_bgm_stream = _generate_bgm()
	play_music(_bgm_stream)


## 빠른 드럼과 16비트 베이스가 중심인 전투용 네온 신스 BGM입니다.
func _generate_bgm() -> AudioStreamWAV:
	const BGM_DURATION := 12.8
	var n := int(SAMPLE_RATE * BGM_DURATION)
	var data := PackedVector2Array()
	data.resize(n)

	# 4-chord progression over 8s (2s per chord), D natural minor: Dm - Bb - F - C.
	# Each entry: [bass_freq, pad_root, pad_third, pad_fifth].
	var chords: Array[PackedFloat64Array] = [
		PackedFloat64Array([73.42, 146.83, 174.61, 220.0]),   # Dm  (D2 / D3 F3 A3)
		PackedFloat64Array([58.27, 116.54, 146.83, 174.61]),  # Bb  (Bb1 / Bb2 D3 F3)
		PackedFloat64Array([87.31, 174.61, 220.0, 261.63]),   # F   (F2 / F3 A3 C4)
		PackedFloat64Array([65.41, 130.81, 164.81, 196.0]),   # C   (C2 / C3 E3 G3)
	]
	# Arpeggio notes (lead, top octave) cycling per chord.
	var arps: Array[PackedFloat64Array] = [
		PackedFloat64Array([293.66, 349.23, 440.0, 523.25]),  # D4 F4 A4 C5
		PackedFloat64Array([233.08, 293.66, 349.23, 440.0]),  # Bb3 D4 F4 A4
		PackedFloat64Array([349.23, 440.0, 523.25, 698.46]),  # F4 A4 C5 F5
		PackedFloat64Array([261.63, 329.63, 392.0, 523.25]),  # C4 E4 G4 C5
	]

	var bpm := 150.0
	var beat := 60.0 / bpm
	var chord_dur := beat * 4.0
	var arp_step := beat / 4.0

	var bass_amp := 0.32
	var pad_amp := 0.035
	var arp_amp := 0.11

	for i in n:
		var t := float(i) / SAMPLE_RATE
		var chord_idx := int(t / chord_dur) % chords.size()
		var chord_t := fmod(t, chord_dur)
		var ch := chords[chord_idx]
		var arp := arps[chord_idx]

		# 16비트 베이스 펄스. 홀수 스텝을 약하게 해 앞으로 달리는 리듬을 만듭니다.
		var beat_phase := fmod(t, beat)
		var bass_step := beat / 4.0
		var bass_phase := fmod(t, bass_step)
		var bass_step_idx := int(t / bass_step) % 4
		var bass_accent := 1.0 if bass_step_idx == 0 or bass_step_idx == 2 else 0.62
		var bass_env := exp(-bass_phase * 22.0) * bass_accent
		var bass_fundamental := sin(t * TAU * ch[0])
		var bass_harmonic := sin(t * TAU * ch[0] * 2.0) * 0.35
		var bass := (bass_fundamental + bass_harmonic) * bass_amp * bass_env

		# Pad: sustained triad that swells in/out across the chord.
		var pad_env := sin(chord_t / chord_dur * PI)
		var pad := (sin(t * TAU * ch[1]) + sin(t * TAU * ch[2]) + sin(t * TAU * ch[3])) * pad_amp * pad_env

		# 빠른 16비트 아르페지오와 옥타브 쉬머.
		var arp_idx := int(fmod(t, arp_step * float(arp.size())) / arp_step) % arp.size()
		var arp_phase := fmod(t, arp_step)
		var arp_env := exp(-arp_phase * 15.0)
		var arp_note := sin(t * TAU * arp[arp_idx]) * arp_amp * arp_env
		var arp_oct := sin(t * TAU * arp[arp_idx] * 2.0) * arp_amp * 0.3 * arp_env

		# 강한 4-on-the-floor 킥, 2·4박 스네어, 8비트 하이햇.
		var beat_number := int(t / beat) % 4
		var kick_freq := lerpf(145.0, 52.0, minf(beat_phase / 0.12, 1.0))
		var kick := sin(beat_phase * TAU * kick_freq) * exp(-beat_phase * 28.0) * 0.27
		var half_beat_phase := fmod(t, beat / 2.0)
		var hat_env := exp(-half_beat_phase * 75.0)
		var hat_accent := 1.35 if int(t / (beat / 2.0)) % 2 == 1 else 0.75
		var hat := (randf() * 2.0 - 1.0) * hat_env * 0.045 * hat_accent
		var snare := 0.0
		if beat_number == 1 or beat_number == 3:
			var snare_tone := sin(beat_phase * TAU * 190.0) * 0.35
			var snare_noise := (randf() * 2.0 - 1.0) * 0.65
			snare = (snare_tone + snare_noise) * exp(-beat_phase * 24.0) * 0.18

		# 두 번째 진행에서는 톱니파 계열 리드와 오픈 하이햇으로 고조시킵니다.
		var lead := 0.0
		if t >= BGM_DURATION * 0.5:
			var lead_freq := arp[(arp_idx + 2) % arp.size()] * 2.0
			var lead_env := exp(-arp_phase * 11.0)
			var lead_saw := sin(t * TAU * lead_freq)
			lead_saw += sin(t * TAU * lead_freq * 2.0) * 0.5
			lead_saw += sin(t * TAU * lead_freq * 3.0) * 0.25
			lead = lead_saw * lead_env * 0.065
			if int(t / (beat / 2.0)) % 2 == 1:
				hat += (randf() * 2.0 - 1.0) * exp(-half_beat_phase * 24.0) * 0.025

		# 킥 순간에 신스 층을 살짝 눌러 타격감을 분명하게 합니다.
		var sidechain := lerpf(0.5, 1.0, minf(beat_phase / 0.11, 1.0))
		var synths := (bass + pad + arp_note + arp_oct + lead) * sidechain
		var mono := synths + kick + hat + snare
		# Soft clip to keep levels clean and avoid harsh distortion.
		mono = tanh(mono * 1.2) * 0.8
		# Slight stereo width for a wider feel.
		var width := 0.08
		data[i] = Vector2(mono * (1.0 + width), mono * (1.0 - width))

	var wav := _create_wav(data)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = n - 1
	return wav


func set_sfx_volume(vol: float) -> void:
	_sfx_volume = clamp(vol, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(_bus_sfx), linear_to_db(_sfx_volume))


func set_music_volume(vol: float) -> void:
	_music_volume = clamp(vol, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(_bus_music), linear_to_db(_music_volume))


func toggle_mute() -> void:
	var master_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_idx, not AudioServer.is_bus_mute(master_idx))


# ---------------- Individual Toggles ----------------

func toggle_sfx() -> void:
	sfx_enabled = not sfx_enabled
	_apply_toggles()
	_save_settings()


func toggle_music() -> void:
	music_enabled = not music_enabled
	_apply_toggles()
	if not music_enabled:
		stop_music()
	else:
		play_bgm()
	_save_settings()


func toggle_tts() -> void:
	tts_enabled = not tts_enabled
	if not tts_enabled:
		DisplayServer.tts_stop()
	_save_settings()


# ---------------- TTS Helper ----------------

var _tts_voice_id: String = ""


func _get_tts_voice() -> String:
	if _tts_voice_id == "":
		if not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
			push_warning("[AudioManager] TTS not supported on this platform")
			return ""
		var voices := DisplayServer.tts_get_voices_for_language("en")
		if voices.is_empty():
			# 폴백: 어떤 영어 음성이든 시도
			voices = DisplayServer.tts_get_voices()
		if voices.size() > 0:
			# en-US Samantha 같은 고품질 음성 우선 선택
			for v in voices:
				if "en-US" in v or "en_US" in v:
					_tts_voice_id = v
					break
			if _tts_voice_id == "":
				_tts_voice_id = voices[0]
			print("[AudioManager] TTS voice selected: ", _tts_voice_id)
		else:
			push_warning("[AudioManager] No TTS voices available")
	return _tts_voice_id


## 단어를 문장 컨텍스트로 감싸고 **소문자로** 바꿔서 TTS가 단어로 발음하도록 합니다.
##
## ⚠️ 문장으로 감싸는 것만으로는 부족하다. 단어가 전부 대문자면 TTS 가 약어로 인식해
##    스펠링으로 읽는다. 짧은 단어에서만 발생하며 실측으로 확인했다(voice=Samantha):
##      "The word is BAT."  1.161초  ← B-A-T 로 스펠링
##      "The word is bat."  0.883초  ← 단어로 발음
##      "The word is ARM."  1.057초 / "arm." 0.883초
##      "The word is YELLOW." 0.941초 = "yellow." 0.941초  (긴 단어는 영향 없음)
##    단어 데이터는 대문자로 저장되므로(WordDictionary) 발화 직전에 소문자로 변환한다.
func speak_word(word: String) -> void:
	if not tts_enabled:
		return
	if not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		return
	var voice := _get_tts_voice()
	if voice == "":
		return
	# 진행 중인 TTS 정지 후 새 발화
	DisplayServer.tts_stop()
	# 문장 컨텍스트 추가 + 단어가 단어로 발음되도록 유도
	# 볼륨 100 (최대), 피치 1.0, 속도 0.9 (자연스러운 속도)
	var phrase := "The word is " + word.to_lower() + "."
	DisplayServer.tts_speak(phrase, voice, 100.0, 1.0, 0.9, false)
	print("[AudioManager] TTS speaking: ", phrase)


# ---------------- Persistence ----------------

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx_enabled", sfx_enabled)
	cfg.set_value("audio", "music_enabled", music_enabled)
	cfg.set_value("audio", "tts_enabled", tts_enabled)
	cfg.set_value("audio", "sfx_volume", _sfx_volume)
	cfg.set_value("audio", "music_volume", _music_volume)
	cfg.save(SAVE_PATH)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	sfx_enabled = cfg.get_value("audio", "sfx_enabled", true)
	music_enabled = cfg.get_value("audio", "music_enabled", true)
	tts_enabled = cfg.get_value("audio", "tts_enabled", true)
	_sfx_volume = cfg.get_value("audio", "sfx_volume", 1.0)
	_music_volume = cfg.get_value("audio", "music_volume", 0.7)
