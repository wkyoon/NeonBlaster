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
	_sfx_cache["shoot"] = _gen_sfx_shoot()
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


func _gen_sfx_shoot() -> AudioStreamWAV:
	var duration := 0.08
	var samples := int(duration * SAMPLE_RATE)
	var data := PackedVector2Array()
	data.resize(samples)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var freq := 800.0 * (1.0 - t / duration) + 200.0
		var env := exp(-t * 40.0)
		var s := sin(t * freq * TAU) * env * 0.3
		data[i] = Vector2(s, s)
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


## 단어를 문장 컨텍스트로 감싸서 TTS가 단어로 발음하도록 합니다.
## macOS AVSpeechSynthesizer는 짧은 단어(arm, bat, cat 등)를 약어로 인식해
## 스펠링(A-R-M)으로 읽는 문제가 있습니다. 문장 안에 넣으면 단어로 발음합니다.
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
	var phrase := "The word is " + word + "."
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
