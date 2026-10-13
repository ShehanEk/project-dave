extends TestCase
## N05 (ElevenLabs audio): the processed takes under assets/audio/eleven/ and how the
## Audio director uses them (scripts/audio/audio_director.gd, the generated
## scripts/audio/eleven_manifest.gd, tools/process_elevenlabs.py).
##
## What this guards: every manifest entry points at a file that exists and loads, is
## mono 16-bit at the rate the tool writes, peaks below full scale and starts and
## ends quietly (no clicks); each cue the manifest covers plays those takes while the
## old Kenney or synthesized source stays registered behind it; the three windup tells
## fit their animations (the clips were cut to length); the ambience beds are
## seamless loops; the voice lines play, report their length and stop on request.
## It reads the WAV bytes directly (the imported streams may be QOA-compressed).

const Eleven := preload("res://scripts/audio/eleven_manifest.gd")

const SFX_RATE := 44100
const AMB_RATE := 32000
## Windup tells: the animation lasts this long (data/tuning/*.tres windup_time), and
## a tell may run a little past it but must not be cut to nothing.
const TELLS := {
	&"guard_windup": 0.5,
	&"staffer_windup": 0.65,
	&"rover_windup": 0.8,
}
const BEDS: Array[StringName] = [
	&"amb_campus_night", &"amb_roof_night", &"amb_plaza_wet", &"amb_depot_hum",
	&"amb_lockdown_bed", &"amb_alarm_far", &"amb_wicket_yard", &"amb_server_core",
]
const BARKS: Array[StringName] = [
	&"bark_guard_ground", &"bark_guard_security", &"bark_guard_there_he_is",
	&"bark_guard_dont_make_me", &"bark_guard_last_warning", &"bark_guard_hes_shooting",
	&"bark_guard_shots_fired",
	&"bark_staffer_stay", &"bark_staffer_workstation", &"bark_staffer_hold_still",
	&"bark_staffer_dave",
]
const STINGS: Array[StringName] = [&"sting_complete", &"sting_checkpoint"]
## The music loops: the key, its length range in seconds (after the loop crossfade).
const MUSIC_TRACKS := {
	&"campus": Vector2(40.0, 70.0),
	&"lockdown": Vector2(30.0, 55.0),
	&"depot": Vector2(40.0, 70.0),
	&"title": Vector2(50.0, 85.0),
}
const MUSIC_RATE := 32000
const VOICE_LINES: Array[StringName] = [
	&"adam_hello", &"adam_stay", &"dave_word_gets_around", &"pa_lethal", &"pa_remain_calm",
]


func run() -> void:
	_test_manifest_covers_known_cues()
	_test_sfx_files_are_clean()
	_test_cues_play_eleven_with_legacy_fallback()
	_test_tells_fit_their_windups()
	_test_guard_swing_uses_the_realistic_takes()
	_test_ambience_beds_are_seamless_loops()
	_test_ambience_switching()
	_test_voice_lines()
	_test_barks()
	_test_stings()
	_test_music_loops()
	_test_stopping_sounds()
	await _test_busy_pool_keeps_the_voices()
	await _test_far_sounds_take_no_player()
	_test_missing_manifest_entry_falls_back()


# --- 1. the manifest names real cues ----------------------------------------------

func _test_manifest_covers_known_cues() -> void:
	var known := {}
	for cue in Audio.SFX_NAMES:
		known[cue] = true
	for cue in Audio.ELEVEN_ONLY_CUES:
		known[cue] = true
	for cue in Eleven.SFX:
		check(known.has(cue), "manifest cue is a registered cue: %s" % String(cue))
	for cue in Audio.ELEVEN_ONLY_CUES:
		check(Eleven.SFX.has(cue), "ElevenLabs-only cue has its takes in the manifest: %s" % String(cue))
	# Every cue except the few the user kept old sources for plays ElevenLabs takes.
	var covered := 0
	for cue in Audio.SFX_NAMES:
		if Eleven.SFX.has(cue):
			covered += 1
	check(covered >= 45, "the ElevenLabs set covers the sound effects (%d of %d cues)" % [covered, Audio.SFX_NAMES.size()])


# --- 2. every processed file is clean ----------------------------------------------

func _test_sfx_files_are_clean() -> void:
	var files := 0
	for cue in Eleven.SFX:
		var entry: Dictionary = Eleven.SFX[cue]
		var trim: float = entry.get("volume_db", 0.0)
		check(trim >= -30.0 and trim <= 6.0, "manifest trim is in range (%.1f dB): %s" % [trim, String(cue)])
		var paths: Array = entry.get("files", [])
		check(paths.size() >= 1, "manifest cue has takes: %s" % String(cue))
		for path in paths:
			files += 1
			if STINGS.has(cue):
				_check_clean_wav(path, SFX_RATE, 1.0, 13.0, 2)
			elif BARKS.has(cue):
				_check_clean_wav(path, SFX_RATE, 0.3, 3.5)
			else:
				_check_clean_wav(path, SFX_RATE, 0.03, 4.0)
	check(files >= 120, "setup: checked the processed sound-effect files (%d)" % files)


func _check_clean_wav(path: String, rate: int, min_s: float, max_s: float, channels: int = 1) -> void:
	check(ResourceLoader.exists(path), "processed file exists: %s" % path)
	check(load(path) is AudioStreamWAV, "processed file loads as AudioStreamWAV: %s" % path)
	var wav := _read_wav(path)
	if wav.is_empty():
		check(false, "processed file parses as a wav: %s" % path)
		return
	check(int(wav.channels) == channels and int(wav.bits) == 16 and int(wav.rate) == rate,
			"%d-channel 16-bit %d Hz (got %d ch, %d bit, %d Hz): %s" % [channels, rate, wav.channels, wav.bits, wav.rate, path])
	var seconds_long := float(wav.frames) / float(wav.rate)
	check(seconds_long >= min_s and seconds_long <= max_s,
			"length %.2fs is within %.2f to %.2fs: %s" % [seconds_long, min_s, max_s, path])
	var peak := 0.0
	for i in int(wav.frames):
		for c in channels:
			peak = maxf(peak, absf(_sample(wav, i, c)))
	check(peak <= 0.95 and peak >= 0.05, "peak %.3f is below full scale and not silent: %s" % [peak, path])
	for c in channels:
		check(absf(_sample(wav, 0, c)) <= 0.03 and absf(_sample(wav, int(wav.frames) - 1, c)) <= 0.03,
				"starts and ends quietly, so it does not click: %s" % path)


# --- 3. ElevenLabs first, old source behind it -----------------------------------------

func _test_cues_play_eleven_with_legacy_fallback() -> void:
	for cue in Eleven.SFX:
		check(Audio.cue_source(cue) == &"eleven", "cue plays its ElevenLabs takes: %s" % String(cue))
		check(Audio.cue_variant_count(cue) == (Eleven.SFX[cue].files as Array).size(),
				"every manifest take of the cue loaded: %s" % String(cue))
		# the old Kenney / synthesized source is still configured and on disk
		for path in Audio.SFX_SOURCES.get(cue, {}).get("files", []):
			check(ResourceLoader.exists(path), "the cue's old source is still there as its fallback: %s" % path)
		Audio.play_sfx(cue)
		Audio.play_sfx(cue, Vector2(10.0, 10.0))
	check(true, "play_sfx ran for every ElevenLabs cue, flat and positional")


func _test_missing_manifest_entry_falls_back() -> void:
	# cue_source says where a cue plays from; a cue with no manifest entry would be
	# &"legacy" (none exist today, so check the rule on the data itself).
	for cue in Audio.SFX_NAMES:
		var has_entry: bool = Eleven.SFX.has(cue)
		var expected: StringName = &"eleven" if has_entry else &"legacy"
		check(Audio.cue_source(cue) == expected, "cue source follows the manifest: %s" % String(cue))
	check(Audio.cue_source(&"totally_not_a_real_cue") == &"", "an unknown cue has no source")


# --- 4. tells fit their windups --------------------------------------------------------

func _test_tells_fit_their_windups() -> void:
	for cue in TELLS:
		var windup: float = TELLS[cue]
		for path in Eleven.SFX.get(cue, {}).get("files", []):
			var wav := _read_wav(path)
			if wav.is_empty():
				continue
			var length_s := float(wav.frames) / float(wav.rate)
			check(length_s >= windup * 0.5 and length_s <= windup + 0.15,
					"%s fits its %.2fs windup (%.2fs): %s" % [String(cue), windup, length_s, path])
	var patrol: Array = Eleven.SFX.get(&"rover_patrol", {}).get("files", [])
	for path in patrol:
		var wav := _read_wav(path)
		if not wav.is_empty():
			check(float(wav.frames) / float(wav.rate) <= 1.3, "the Rover's turn roll stays short: %s" % path)


func _test_guard_swing_uses_the_realistic_takes() -> void:
	var paths: Array = Eleven.SFX.get(&"guard_swing", {}).get("files", [])
	check(paths.size() == 4, "guard swing pools the realistic whoosh and the whip takes (%d)" % paths.size())


# --- 5. ambience -----------------------------------------------------------------------

func _test_ambience_beds_are_seamless_loops() -> void:
	for bed in BEDS:
		check(Eleven.AMBIENCE.has(bed), "manifest has the bed: %s" % String(bed))
		check(Audio.has_ambience(bed), "the director loaded the bed: %s" % String(bed))
		var entry: Dictionary = Eleven.AMBIENCE.get(bed, {})
		var path: String = entry.get("file", "")
		var trim: float = entry.get("volume_db", 0.0)
		check(trim >= -40.0 and trim <= 0.0, "bed trim sits under the music (%.1f dB): %s" % [trim, String(bed)])
		_check_clean_wav_loop(path)
		var stream = load(path)
		if stream is AudioStreamWAV:
			check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "bed loops forward: %s" % String(bed))


func _check_clean_wav_loop(path: String) -> void:
	var wav := _read_wav(path)
	if wav.is_empty():
		check(false, "bed parses as a wav: %s" % path)
		return
	check(int(wav.channels) == 1 and int(wav.rate) == AMB_RATE, "bed is mono %d Hz: %s" % [AMB_RATE, path])
	var seconds_long := float(wav.frames) / float(wav.rate)
	check(seconds_long >= 10.0 and seconds_long <= 30.0, "bed is %.1fs long: %s" % [seconds_long, path])
	# The wrap point: the step from the last sample to the first against the typical
	# step between neighbours. The tool crossfades the end into the start.
	var frames := int(wav.frames)
	var total_step := 0.0
	var peak := 0.0
	for i in range(1, frames):
		total_step += absf(_sample(wav, i) - _sample(wav, i - 1))
		peak = maxf(peak, absf(_sample(wav, i)))
	var typical := total_step / float(frames - 1)
	var jump := absf(_sample(wav, 0) - _sample(wav, frames - 1))
	check(jump <= maxf(typical * 6.0, 0.002), "bed wraps without a click (wrap step %.4f, typical %.4f): %s" % [jump, typical, path])
	check(peak <= 0.95, "bed peaks below full scale: %s" % path)


func _test_ambience_switching() -> void:
	Audio.set_ambience(&"amb_campus_night")
	check(Audio.current_ambience() == &"amb_campus_night", "set_ambience selects a bed")
	Audio.set_ambience(&"amb_campus_night")
	check(Audio.current_ambience() == &"amb_campus_night", "asking for the bed that is playing is a no-op")
	Audio.set_ambience(&"amb_lockdown_bed")
	check(Audio.current_ambience() == &"amb_lockdown_bed", "set_ambience crossfades to another bed")
	Audio.set_ambience(&"not_a_bed")
	check(Audio.current_ambience() == &"not_a_bed", "an unknown bed is silence, not an error")
	Audio.set_ambience(Audio.AMBIENCE_NONE)
	check(Audio.current_ambience() == Audio.AMBIENCE_NONE, "none fades the ambience out")


# --- 6. voice ----------------------------------------------------------------------------

func _test_voice_lines() -> void:
	for line in VOICE_LINES:
		check(Eleven.VOICE.has(line), "manifest has the voice line: %s" % String(line))
		check(Audio.has_voice(line), "the director loaded the voice line: %s" % String(line))
		var length_s := Audio.voice_length(line)
		check(length_s >= 1.0 and length_s <= 8.0, "voice line is %.1fs long: %s" % [length_s, String(line)])
		for path in Eleven.VOICE.get(line, {}).get("files", []):
			_check_clean_wav(path, SFX_RATE, 1.0, 8.0)
		var played := Audio.play_voice(line)
		check(played > 0.5, "play_voice returns the clip length (%.2fs): %s" % [played, String(line)])
		check(Audio.current_voice() == line, "the line is current while it speaks: %s" % String(line))
	Audio.stop_voice()
	check(Audio.current_voice() == &"", "stop_voice ends the line")
	check(Audio.play_voice(&"not_a_line") == 0.0, "an unknown voice line plays nothing and returns 0")
	check(not Audio.has_voice(&"not_a_line"), "an unknown voice line is not registered")
	# a new line cuts the old one
	Audio.play_voice(&"adam_hello")
	Audio.play_voice(&"pa_lethal")
	check(Audio.current_voice() == &"pa_lethal", "a new line takes over from the one speaking")
	Audio.stop_voice()


# --- 7. barks, stings and music ------------------------------------------------------------

func _test_barks() -> void:
	for cue in BARKS:
		check(Eleven.SFX.has(cue), "manifest has the bark: %s" % String(cue))
		check(Audio.cue_source(cue) == &"eleven" and Audio.cue_variant_count(cue) >= 2,
				"the bark plays its recorded takes (2 alternates): %s" % String(cue))
		Audio.play_sfx(cue, Vector2(100.0, 0.0))
	# every caption in the tuning files has its recording
	const BarkMap := preload("res://scripts/audio/bark_map.gd")
	var spoken := 0
	for tuning_path in ["res://data/tuning/night_guard.tres", "res://data/tuning/staffer.tres"]:
		var tuning = load(tuning_path)
		for field in ["voice_notice", "voice_windup", "voice_hurt"]:
			for text in tuning.get(field):
				spoken += 1
				check(BarkMap.cue_for(text) != &"" and Audio.has_cue(BarkMap.cue_for(text)),
						"bark caption has a recording (%s.%s): %s" % [tuning_path.get_file(), field, text])
	check(spoken >= 12, "setup: checked the bark captions (%d)" % spoken)


func _test_stings() -> void:
	for cue in STINGS:
		check(Audio.cue_source(cue) == &"eleven" and Audio.cue_variant_count(cue) == 1,
				"the sting plays its ElevenLabs file: %s" % String(cue))
		Audio.play_sfx(cue)
	var complete := _read_wav(Eleven.SFX[&"sting_complete"].files[0])
	var checkpoint := _read_wav(Eleven.SFX[&"sting_checkpoint"].files[0])
	if not complete.is_empty() and not checkpoint.is_empty():
		check(float(complete.frames) / float(complete.rate) >= 8.0, "the level-complete sting is a phrase, not a blip")
		check(float(checkpoint.frames) / float(checkpoint.rate) <= 6.0, "the checkpoint sting is short")


func _test_music_loops() -> void:
	for track in MUSIC_TRACKS:
		check(Eleven.MUSIC.has(track), "manifest has the music loop: %s" % String(track))
		check(Audio.has_music(track), "the director loaded the music loop: %s" % String(track))
		check(Audio.music_source(track) == &"eleven", "the loop plays the ElevenLabs track: %s" % String(track))
		var path: String = Eleven.MUSIC.get(track, {}).get("file", "")
		var wav := _read_wav(path)
		if wav.is_empty():
			check(false, "music loop parses as a wav: %s" % path)
			continue
		check(int(wav.channels) == 2 and int(wav.rate) == MUSIC_RATE and int(wav.bits) == 16,
				"music is stereo 16-bit %d Hz: %s" % [MUSIC_RATE, path])
		var length_s := float(wav.frames) / float(wav.rate)
		var window: Vector2 = MUSIC_TRACKS[track]
		check(length_s >= window.x and length_s <= window.y,
				"music loop is %.1fs, want %.0f to %.0fs: %s" % [length_s, window.x, window.y, path])
		var frames := int(wav.frames)
		var peak := 0.0
		var steps := 0.0
		for i in range(1, frames, 7):
			for c in 2:
				peak = maxf(peak, absf(_sample(wav, i, c)))
				steps += absf(_sample(wav, i, c) - _sample(wav, i - 1, c))
		var typical := steps / float(frames / 7 * 2)
		for c in 2:
			var jump := absf(_sample(wav, 0, c) - _sample(wav, frames - 1, c))
			check(jump <= maxf(typical * 8.0, 0.003), "music wraps without a click on channel %d (step %.4f, typical %.4f): %s" % [c, jump, typical, path])
		check(peak <= 0.95 and peak >= 0.1, "music peaks below full scale (%.2f): %s" % [peak, path])
		var stream = load(path)
		check(stream is AudioStreamWAV and stream.stereo, "music loads as a stereo AudioStreamWAV: %s" % path)
		if stream is AudioStreamWAV:
			check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "music loops forward: %s" % String(track))
	# the synthesized loops are still the fallback for the two they replace
	check(Audio.MUSIC_FILES.has(&"campus") and Audio.MUSIC_FILES.has(&"lockdown"), "the synthesized campus and lockdown loops remain")


# --- 8. a sound can be stopped without cutting an unrelated one ---------------------------

func _test_stopping_sounds() -> void:
	var player = Audio.play_sfx(&"sting_complete")
	check(player is AudioStreamPlayer and player.playing, "play_sfx returns the pooled player it used")
	Audio.stop_sfx(&"sting_complete")
	check(not player.playing, "stop_sfx ends the cue that is playing")
	check(Audio.play_sfx(&"totally_not_a_real_cue") == null, "an unknown cue returns no player")
	# a speaker's own stop: only while the pooled player still holds his clip
	var bark = Audio.play_sfx(&"bark_guard_ground", Vector2(5.0, 5.0))
	var clip: AudioStream = bark.stream
	Audio.stop_player_if_playing(bark, clip)
	check(not bark.playing, "a speaker can cut his own clip")
	bark.stream = load(Eleven.SFX[&"chip"].files[0])
	bark.play()
	Audio.stop_player_if_playing(bark, clip)
	check(bark.playing, "a pooled player that moved on to another cue is not cut")
	bark.stop()
	Audio.stop_player_if_playing(null, clip)
	check(true, "stopping a freed or missing player is harmless")


# --- 9. a busy pool never costs the player its voices ---------------------------------------

func _stop_every_player() -> void:
	for p in Audio._sfx_pool:
		p.stop()
	for p in Audio._sfx2d_pool:
		p.stop()


func _test_busy_pool_keeps_the_voices() -> void:
	_stop_every_player()
	await physics_frames(90)  # past the 1.2 s gap of any rover_patrol an earlier check played
	check(Audio.SFX2D_POOL_SIZE >= 16 and Audio.SFX_POOL_SIZE >= 10, "the player pools are big enough for steps, shots and voices together")
	# A cue asked for every frame (the Rover turning while it is blocked) plays once
	# per gap, not sixty times a second.
	var played := 0
	for i in 200:
		if Audio.play_sfx(&"rover_patrol", Vector2(1.0, 1.0)) != null:
			played += 1
	check(played == 1, "a cue asked for every frame plays once per gap (%d plays out of 200 asks)" % played)
	_stop_every_player()
	# Fill the whole positional pool with footsteps, speak a bark, then flood the pool
	# with more footsteps: the bark is never the player that gets taken over.
	for i in Audio.SFX2D_POOL_SIZE + 4:
		Audio.play_sfx(&"footstep_paving", Vector2(2.0, 2.0))
	var bark = Audio.play_sfx(&"bark_guard_ground", Vector2(3.0, 3.0))
	var clip: AudioStream = bark.stream
	check(bark.playing, "a bark takes a player even when the pool is full")
	for i in Audio.SFX2D_POOL_SIZE * 3:
		Audio.play_sfx(&"footstep_metal", Vector2(4.0, 4.0))
		Audio.play_sfx(&"bolt_hit", Vector2(4.0, 4.0))
	check(bark.playing and bark.stream == clip, "footsteps and hits never cut a bark in a full pool")
	# Another voice may take over from it only when nothing less important is left
	for i in Audio.SFX2D_POOL_SIZE:
		Audio.play_sfx(&"bark_staffer_stay", Vector2(5.0, 5.0))
	var holders := 0
	for p in Audio._sfx2d_pool:
		if p.playing and String(p.stream.resource_path).contains("bark_"):
			holders += 1
	check(holders == Audio.SFX2D_POOL_SIZE, "a pool full of voices still lets a voice in (%d of %d players)" % [holders, Audio.SFX2D_POOL_SIZE])
	_stop_every_player()


func _test_far_sounds_take_no_player() -> void:
	_stop_every_player()
	var camera := Camera2D.new()
	camera.position = Vector2(100.0, 0.0)
	add_child(camera)
	camera.make_current()
	await physics_frames(2)
	check(Audio.play_sfx(&"footstep_paving", Vector2(100.0 + 600.0, 0.0)) != null, "a sound near the camera plays")
	check(Audio.play_sfx(&"footstep_paving", Vector2(100.0 + 5000.0, 0.0)) == null,
			"a positional sound too far from the camera to hear takes no player")
	check(Audio.play_sfx(&"ui_confirm") != null, "a flat sound has no position, so distance does not matter")
	camera.queue_free()
	_stop_every_player()


# --- wav reading (the imported streams may be compressed; these are the source bytes) -----

func _read_wav(path: String) -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 44 or bytes.slice(0, 4).get_string_from_ascii() != "RIFF":
		return {}
	var channels := 0
	var rate := 0
	var bits := 0
	var pos := 12
	while pos + 8 <= bytes.size():
		var chunk_id := bytes.slice(pos, pos + 4).get_string_from_ascii()
		var chunk_size := bytes.decode_u32(pos + 4)
		if chunk_id == "fmt ":
			channels = bytes.decode_u16(pos + 10)
			rate = bytes.decode_u32(pos + 12)
			bits = bytes.decode_u16(pos + 22)
		elif chunk_id == "data":
			var frame_bytes := maxi(1, channels * int(bits / 8.0))
			return {
				"bytes": bytes, "offset": pos + 8, "channels": channels, "rate": rate,
				"bits": bits, "frames": int(chunk_size / float(frame_bytes)),
			}
		pos += 8 + chunk_size + (chunk_size & 1)
	return {}


func _sample(wav: Dictionary, i: int, channel: int = 0) -> float:
	var bytes: PackedByteArray = wav.bytes
	return bytes.decode_s16(int(wav.offset) + (i * int(wav.channels) + channel) * 2) / 32768.0
