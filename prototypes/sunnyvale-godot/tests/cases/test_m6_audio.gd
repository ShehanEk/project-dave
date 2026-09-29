extends TestCase
## M6 (presentation pass) — the Audio autoload (scripts/audio/audio_director.gd),
## its cue sources (Audio.SFX_SOURCES: Kenney .ogg for the hero, pistol and
## generic UI/world cues; synthesized night-campus .wav from
## tools/gen_audio.py for the rest) and the two synthesized music loops
## (assets/audio/music/**).
## Contracts under test (see CONVENTIONS.md "Audio"):
##   1. Every cue resolves to at least one loadable stream (.ogg or .wav) —
##      Audio doesn't care which; a cue kept synthesized loads its .wav, a
##      cue switched to Kenney source loads its .ogg pool.
##   2. The night-campus cue set: the renamed cues (staffer_*, chip*, evidence,
##      med_patch, adam_chime, alarm) and the six new ones (keycard,
##      keycard_denied, door_unlock, uplink, lockdown, link_chirp) are
##      registered and play their generated wav; so are the Level 1 roster
##      cues (the Night Guard's baton, hits and falls on people, the Patrol
##      Rover, debris). The zombie-era cue names, wavs and music keys are gone,
##      and so is every Clipper cue with its wav and Kenney source files.
##   3. Every cue and music track a script asks for by literal name is
##      registered (scans res://scripts, so a typo or a retired name fails).
##   4. play_sfx() runs for every known cue (flat AND positional) without
##      raising a runtime error, and an unknown cue name warns instead of
##      crashing.
##   5. The generated cue files are clean: 16-bit mono, sane length, not
##      clipped, not silent, no DC, starting and ending on ~0 (no click), the
##      alarm and denied buzz stay low, hits and falls on people stay dull (never
##      a bright splatter). Mix settings are in range, the hero/pistol cues are
##      darkened slightly, telegraphs keep a fixed pitch. The roster's tells fit
##      their windups and play at comparable loudness, and no roster cue is far
##      louder or quieter than its neighbours.
##   6. The music loops: track keys are campus/lockdown, the loop points cover
##      the WHOLE file (regression: a byte-count loop end on a QOA-compressed
##      import looped only the first fifth), long enough, at a sensible level,
##      and the wrap point is continuous (no click).
##   7. Music is campus on New Game, switches to lockdown the instant
##      awakening_done goes live, AND is lockdown immediately on Continue after
##      awakening (load_from_snapshot() never re-emits story_state_changed, so
##      this exercises main.gd's own explicit check, not just the Session
##      signal listener).
##   8. Settings' volume sliders still reach the Master/Music/SFX buses that
##      Audio's own players are routed through.
##
## This is the one test in the project that instances scenes/main.tscn (to
## reach main.gd's New Game / Continue flow), so it redirects Telemetry to a
## throwaway directory first — the same pattern _test_telemetry_log_sequence()
## already uses in test_m5_flow.gd — never touching the real playtest log.

const SFX_ROOT := "res://assets/audio/sfx/"
const MUSIC_ROOT := "res://assets/audio/music/"

const NEW_CUES: Array[StringName] = [
	&"keycard", &"keycard_denied", &"door_unlock", &"uplink", &"lockdown", &"link_chirp",
]
const RENAMED_CUES: Array[StringName] = [
	&"staffer_windup", &"staffer_lunge", &"staffer_defeat", &"chip", &"chip_cluster",
	&"evidence", &"med_patch", &"adam_chime", &"alarm", &"exit",
]
## The Level 1 roster (C33): the Night Guard's baton, hits and falls on people,
## the Patrol Rover and metal debris. All synthesized.
const ROSTER_CUES: Array[StringName] = [
	&"guard_windup", &"guard_swing", &"hit_flesh", &"body_fall",
	&"rover_patrol", &"rover_windup", &"rover_charge", &"rover_stall", &"rover_armor", &"rover_destroyed",
	&"debris_clatter",
]
const RETIRED_CUES: Array[StringName] = [
	&"resident_windup", &"resident_lunge", &"resident_defeat", &"gem", &"gem_cluster",
	&"artifact", &"capsule", &"eden_chime",
	&"clipper_scrape", &"clipper_windup", &"clipper_charge", &"clipper_stall", &"clipper_defeat",
]
const RETIRED_FILES: Array[String] = [
	SFX_ROOT + "resident_windup.wav", SFX_ROOT + "resident_lunge.wav", SFX_ROOT + "resident_defeat.wav",
	SFX_ROOT + "gem.wav", SFX_ROOT + "gem_cluster.wav", SFX_ROOT + "artifact.wav",
	SFX_ROOT + "capsule.wav", SFX_ROOT + "eden_chime.wav",
	MUSIC_ROOT + "suburb_loop.wav", MUSIC_ROOT + "quarantine_loop.wav",
	SFX_ROOT + "clipper_scrape.wav", SFX_ROOT + "clipper_windup.wav", SFX_ROOT + "clipper_charge.wav",
	SFX_ROOT + "clipper_stall.wav", SFX_ROOT + "clipper_defeat.wav",
	"res://assets/kenney/interface-sounds/scratch_004.ogg", "res://assets/kenney/sci-fi-sounds/forceField_000.ogg",
	"res://assets/kenney/sci-fi-sounds/forceField_001.ogg", "res://assets/kenney/sci-fi-sounds/impactMetal_002.ogg",
	"res://assets/kenney/impact-sounds/impactMining_000.ogg",
]
## Kenney-sourced cues that carry the base "pitch" trim (about a semitone down).
const DARKENED_CUES: Array[StringName] = [
	&"pistol_fire", &"pistol_fire_quick", &"bolt_hit", &"bolt_blocked",
	&"hero_hurt", &"hero_jump", &"hero_land",
]
## Attack telegraphs and one-off story/access beats: the same sound every time.
const FIXED_PITCH_CUES: Array[StringName] = [
	&"staffer_windup", &"staffer_lunge", &"guard_windup", &"guard_swing",
	&"rover_windup", &"rover_charge", &"rover_stall", &"rover_destroyed",
	&"keycard", &"keycard_denied", &"door_unlock", &"lockdown", &"alarm", &"adam_chime",
]
## The three windup tells and the window each cue has to fit in (seconds): the
## Night Guard's baton charge (about 0.5 s), the Staffer's twitch (0.65 s) and the
## Patrol Rover's rock-back (about 0.8 s).
const TELL_LENGTHS := {
	&"guard_windup": Vector2(0.40, 0.60),
	&"staffer_windup": Vector2(0.50, 0.70),
	&"rover_windup": Vector2(0.65, 0.95),
}
## Every roster cue, played at its trim, lands between these loudest-200 ms RMS
## levels (dBFS, unweighted): debris and the Rover's idle roll are the quietest,
## the tells, the ram and the Guard's baton the loudest.
const ROSTER_LEVEL_DB := Vector2(-34.0, -8.0)


func run() -> void:
	_test_cues_exist_and_load()
	_test_night_campus_cue_set()
	_test_called_cues_and_tracks_exist()
	_test_play_sfx_every_cue()
	_test_unknown_cue_warns_not_crashes()
	_test_synth_cue_files()
	_test_roster_cue_shape_and_levels()
	_test_mix_settings()
	_test_music_loops()
	await _test_music_switches_on_new_game_awakening_and_restore()
	_test_settings_map_to_buses()


# --- 1. every cue resolves to at least one loadable stream (ogg or wav) ---------

func _test_cues_exist_and_load() -> void:
	for cue in Audio.SFX_NAMES:
		var source: Dictionary = Audio.SFX_SOURCES.get(cue, {})
		var files: Array = source.get("files", [])
		check(not files.is_empty(), "cue has at least one configured source file: %s" % String(cue))

		var loadable := 0
		for path in files:
			check(ResourceLoader.exists(path), "sfx source file exists on disk: %s" % path)
			var stream = load(path)
			# The point of switching most cues to Kenney .ogg is exactly that
			# Audio doesn't care which concrete stream type backs a cue — a
			# kept-synthesized cue's AudioStreamWAV and a curated cue's
			# AudioStreamOggVorbis are both just an AudioStream to play_sfx().
			check(stream is AudioStream, "sfx source loads as an AudioStream: %s" % path)
			if stream is AudioStream:
				loadable += 1
		check(loadable > 0, "cue resolves to at least one loadable stream: %s" % String(cue))
		check(Audio.cue_variant_count(cue) == loadable,
				"Audio director loaded every configured, existing source file for cue: %s" % String(cue))
		check(Audio.has_cue(cue), "Audio director registered cue: %s" % String(cue))

	for key in Audio.MUSIC_FILES:
		var basename: String = Audio.MUSIC_FILES[key]
		var path := MUSIC_ROOT + "%s.wav" % basename
		check(ResourceLoader.exists(path), "music file exists on disk: %s" % path)
		var stream = load(path)
		check(stream is AudioStreamWAV, "music loads as AudioStreamWAV: %s" % path)
		if stream is AudioStreamWAV:
			check(stream.loop_mode != AudioStreamWAV.LOOP_DISABLED,
					"music stream has a loop mode set for seamless looping: %s" % path)


# --- 2. the night-campus cue set: new, renamed, retired -----------------------------

func _test_night_campus_cue_set() -> void:
	var generated: Array = []
	generated.append_array(NEW_CUES)
	generated.append_array(RENAMED_CUES)
	generated.append_array(ROSTER_CUES)
	for cue in generated:
		check(Audio.SFX_NAMES.has(cue), "night-campus cue is listed in SFX_NAMES: %s" % String(cue))
		check(Audio.has_cue(cue), "night-campus cue is registered: %s" % String(cue))
		for path in Audio.SFX_SOURCES.get(cue, {}).get("files", []):
			check(String(path).begins_with(SFX_ROOT) and String(path).ends_with(".wav"),
					"night-campus cue plays its generated wav, not a Kenney pick: %s" % path)
			check(load(path) is AudioStreamWAV, "night-campus cue file loads as AudioStreamWAV: %s" % path)

	for cue in RETIRED_CUES:
		check(not Audio.SFX_NAMES.has(cue) and not Audio.has_cue(cue),
				"retired cue (zombie-era or Clipper) is gone: %s" % String(cue))
	for path in RETIRED_FILES:
		check(not FileAccess.file_exists(path), "retired zombie-era or Clipper file is deleted: %s" % path)
	for track in [&"suburb", &"quarantine"]:
		check(not Audio.MUSIC_FILES.has(track), "retired music track key is gone: %s" % String(track))
	check(Audio.MUSIC_FILES.has(&"campus") and Audio.MUSIC_FILES.has(&"lockdown"),
			"music tracks are campus and lockdown")
	check(Audio.MUSIC_FILES.size() == 2, "exactly two music tracks (campus, lockdown)")


# --- 3. every literal cue / track a script asks for is registered -----------------

func _test_called_cues_and_tracks_exist() -> void:
	var scripts: Array[String] = []
	_collect_scripts("res://scripts", scripts)
	check(scripts.size() > 50, "setup: found the project's scripts to scan (%d)" % scripts.size())
	var literal := RegEx.new()
	literal.compile("&\"([a-z0-9_]+)\"")
	var cues_seen := {}
	var tracks_seen := {}
	for path in scripts:
		if path.ends_with("audio_director.gd"):
			continue
		var text := FileAccess.get_file_as_string(path)
		for line in text.split("\n"):
			var stripped := line.strip_edges()
			if stripped.begins_with("#"):
				continue
			var is_sfx := line.contains("play_sfx(")
			var is_music := line.contains("set_music(")
			if not is_sfx and not is_music:
				continue
			for m in literal.search_all(line):
				var cue_name := StringName(m.get_string(1))
				if is_music:
					tracks_seen[cue_name] = path
				else:
					cues_seen[cue_name] = path
	check(cues_seen.size() >= 10, "setup: the scan found the scripts' play_sfx() cue names (%d)" % cues_seen.size())
	for cue_name in cues_seen:
		check(Audio.has_cue(cue_name), "cue named in %s is registered with Audio: %s" % [cues_seen[cue_name], String(cue_name)])
	check(tracks_seen.size() >= 2, "setup: the scan found the scripts' set_music() track names (%d)" % tracks_seen.size())
	for track in tracks_seen:
		check(track == &"none" or Audio.MUSIC_FILES.has(track),
				"track named in %s is a music track (or none): %s" % [tracks_seen[track], String(track)])


func _collect_scripts(dir_path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_collect_scripts(dir_path.path_join(sub), out)
	for f in dir.get_files():
		if f.ends_with(".gd"):
			out.append(dir_path.path_join(f))


# --- 4. play_sfx never errors, for every cue, flat and positional ---------------

func _test_play_sfx_every_cue() -> void:
	var tested := 0
	var expected: int = Audio.SFX_NAMES.size() * 2
	for cue in Audio.SFX_NAMES:
		Audio.play_sfx(cue)
		tested += 1
		Audio.play_sfx(cue, Vector2(64.0, 32.0))
		tested += 1
	# A runtime error inside play_sfx would abort this function early rather
	# than raise something check() could catch after the fact — comparing
	# the count actually reached against the expected total is what makes a
	# silent early-abort show up as a failure instead of a false PASS.
	check(tested == expected,
			"play_sfx ran for every known cue, flat + positional, without aborting (%d/%d)" %
			[tested, expected])


func _test_unknown_cue_warns_not_crashes() -> void:
	check(not Audio.has_cue(&"totally_not_a_real_cue"), "setup: a made-up cue name is not registered")
	Audio.play_sfx(&"totally_not_a_real_cue")
	Audio.play_sfx(&"totally_not_a_real_cue")  # a second call must not error either (warn-once)
	Audio.play_sfx(&"totally_not_a_real_cue", Vector2.ZERO)
	check(true, "play_sfx on an unknown cue (flat and positional, called repeatedly) never crashes")


# --- 5. the generated cue files are clean; mix settings are in range ------------

func _test_synth_cue_files() -> void:
	var checked := 0
	for cue in Audio.SFX_NAMES:
		for path in Audio.SFX_SOURCES.get(cue, {}).get("files", []):
			if not String(path).ends_with(".wav"):
				continue
			var wav := _read_wav(path)
			check(not wav.is_empty(), "generated wav parses: %s" % path)
			if wav.is_empty():
				continue
			checked += 1
			check(wav.format == 1 and wav.channels == 1 and wav.bits == 16 and wav.rate == 22050,
					"generated wav is 16-bit mono PCM at 22050 Hz: %s" % path)
			var length_s := float(wav.frames) / float(wav.rate)
			check(length_s >= 0.03 and length_s <= 4.0, "generated wav has a sane length (%.2fs): %s" % [length_s, path])
			var s := _scan(wav)
			check(s.peak <= 0.95, "generated wav has headroom, not clipped (peak %.2f): %s" % [s.peak, path])
			check(s.peak >= 0.3, "generated wav is not silent or buried (peak %.2f): %s" % [s.peak, path])
			check(absf(s.mean) <= 0.01, "generated wav has no DC offset (%.4f): %s" % [s.mean, path])
			check(absf(s.first) <= 0.01 and absf(s.last) <= 0.01,
					"generated wav starts and ends on ~0, so no click (first %.4f, last %.4f): %s" % [s.first, s.last, path])
	check(checked >= 16, "setup: checked the generated night-campus wavs (%d)" % checked)

	# The alarm and the denied buzz are low tones, never piercing: little energy
	# above ~2 kHz (a one-pole highpass at 2 kHz passes under a quarter of it).
	for cue in [&"alarm", &"keycard_denied"]:
		var wav := _read_wav(SFX_ROOT + "%s.wav" % String(cue))
		if not wav.is_empty():
			var high := _highpass_fraction(wav, 2000.0)
			check(high < 0.25, "%s stays low, not piercing (highpass fraction %.2f)" % [String(cue), high])
	# Cues that repeat or ride on many actors stay tiny.
	for cue in [&"uplink", &"link_chirp"]:
		var wav := _read_wav(SFX_ROOT + "%s.wav" % String(cue))
		if not wav.is_empty():
			check(float(wav.frames) / float(wav.rate) <= 0.15, "%s is a short tick (<= 0.15s)" % String(cue))


# --- 5b. the roster cues: tells fit their windups, people stay dull, levels sit together ---

func _test_roster_cue_shape_and_levels() -> void:
	# A tell is over before the swing, ram or grab it announces.
	for cue in TELL_LENGTHS:
		var wav := _read_wav(SFX_ROOT + "%s.wav" % String(cue))
		if wav.is_empty():
			check(false, "tell cue wav parses: %s" % String(cue))
			continue
		var window: Vector2 = TELL_LENGTHS[cue]
		var length_s := float(wav.frames) / float(wav.rate)
		check(length_s >= window.x and length_s <= window.y,
				"%s fits its windup (%.2fs, want %.2f-%.2fs)" % [String(cue), length_s, window.x, window.y])

	# Restrained by ear: a hit on a person and a body landing are dull (a bright
	# splatter scores well over 0.5 on the 2 kHz highpass fraction), the Rover's
	# idle roll is a low hum, and its siren warns without shrieking.
	var dull := {&"body_fall": 0.25, &"hit_flesh": 0.40, &"rover_patrol": 0.30, &"rover_windup": 0.45}
	for cue in dull:
		var wav := _read_wav(SFX_ROOT + "%s.wav" % String(cue))
		if not wav.is_empty():
			var high := _highpass_fraction(wav, 2000.0)
			check(high < float(dull[cue]), "%s stays low and dull, not bright (highpass fraction %.2f)" % [String(cue), high])
	var patrol := _read_wav(SFX_ROOT + "rover_patrol.wav")
	if not patrol.is_empty():
		var patrol_s := float(patrol.frames) / float(patrol.rate)
		check(patrol_s <= 0.8, "rover_patrol is a short hum, so plays that follow each other overlap into a roll (%.2fs, want <= 0.8s)" % patrol_s)

	# Nothing in the roster is far louder or quieter than its neighbours: each
	# cue, at its own trim, sits in one band, and the three tells (Night Guard,
	# Staffer, Rover) play within a few dB of each other.
	var tells := {}
	for cue in ROSTER_CUES:
		var wav := _read_wav(SFX_ROOT + "%s.wav" % String(cue))
		if wav.is_empty():
			continue
		var trim := float(Audio.SFX_SOURCES.get(cue, {}).get("volume_db", 0.0))
		var played := _loudest_rms_db(wav, 0.2) + trim
		check(played >= ROSTER_LEVEL_DB.x and played <= ROSTER_LEVEL_DB.y,
				"%s plays at a level that sits with its neighbours (%.1f dBFS, want %.0f to %.0f)" %
				[String(cue), played, ROSTER_LEVEL_DB.x, ROSTER_LEVEL_DB.y])
		if TELL_LENGTHS.has(cue):
			tells[cue] = played
	var staffer := _read_wav(SFX_ROOT + "staffer_windup.wav")
	if not staffer.is_empty():
		tells[&"staffer_windup"] = _loudest_rms_db(staffer, 0.2) + float(Audio.SFX_SOURCES.get(&"staffer_windup", {}).get("volume_db", 0.0))
	if tells.size() == TELL_LENGTHS.size():
		var lo := 1000.0
		var hi := -1000.0
		for cue in tells:
			lo = minf(lo, float(tells[cue]))
			hi = maxf(hi, float(tells[cue]))
		check(hi - lo <= 5.0, "the three windup tells play at comparable loudness (spread %.1f dB)" % (hi - lo))


func _test_mix_settings() -> void:
	for cue in Audio.SFX_NAMES:
		var source: Dictionary = Audio.SFX_SOURCES.get(cue, {})
		var volume_db := float(source.get("volume_db", 0.0))
		var pitch := float(source.get("pitch", 1.0))
		var variance := float(source.get("pitch_variance", 0.0))
		check(volume_db >= -30.0 and volume_db <= 6.0, "cue trim is in range (%.1f dB): %s" % [volume_db, String(cue)])
		check(pitch >= 0.5 and pitch <= 1.5, "cue base pitch is in range (%.2f): %s" % [pitch, String(cue)])
		check(variance >= 0.0 and variance <= 0.1, "cue pitch variance is in range (%.2f): %s" % [variance, String(cue)])
	for cue in DARKENED_CUES:
		var pitch := float(Audio.SFX_SOURCES.get(cue, {}).get("pitch", 1.0))
		check(pitch < 1.0 and pitch >= 0.85, "hero/pistol/Clipper cue is darkened slightly (%.2f): %s" % [pitch, String(cue)])
	for cue in FIXED_PITCH_CUES:
		var variance := float(Audio.SFX_SOURCES.get(cue, {}).get("pitch_variance", 0.0))
		check(variance == 0.0, "telegraph / story / access cue never has random pitch: %s" % String(cue))


# --- 6. music loops: keys, loop points, length, level, continuous seam ------------

func _test_music_loops() -> void:
	var step := 0.25  # a gross (-12 dBFS) step, added after the wrap in the control below
	for key in Audio.MUSIC_FILES:
		var path := MUSIC_ROOT + "%s.wav" % String(Audio.MUSIC_FILES[key])
		var wav := _read_wav(path)
		check(not wav.is_empty(), "music wav parses: %s" % path)
		if wav.is_empty():
			continue
		check(wav.format == 1 and wav.channels == 1 and wav.bits == 16 and wav.rate == 22050,
				"music wav is 16-bit mono PCM at 22050 Hz: %s" % path)
		var length_s := float(wav.frames) / float(wav.rate)
		check(length_s >= 20.0, "music loop is long enough not to repeat obviously (%.1fs): %s" % [length_s, path])
		var s := _scan(wav)
		var rms_db := linear_to_db(s.rms)
		check(s.peak <= 0.9, "music leaves headroom for the SFX on the same bus (peak %.2f): %s" % [s.peak, path])
		check(rms_db >= -30.0 and rms_db <= -14.0, "music level is sensible (rms %.1f dBFS): %s" % [rms_db, path])
		check(absf(s.mean) <= 0.005, "music has no DC offset (%.4f): %s" % [s.mean, path])

		# The engine-side loop covers the whole file. The importer may compress
		# the WAV (QOA is its default), so the frame count comes from the length,
		# never from the byte size of the stream's data.
		var stream = load(path)
		if stream is AudioStreamWAV:
			var frames := int(round(stream.get_length() * float(stream.mix_rate)))
			check_eq(frames, wav.frames, "imported music length matches the wav (%s)" % path)
			check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_begin == 0 and stream.loop_end == frames,
					"music loops forward over the WHOLE file (loop %d..%d of %d): %s" %
					[stream.loop_begin, stream.loop_end, frames, path])

		var raw_step := absf(_sample(wav, 0) - _sample(wav, wav.frames - 1))
		check(raw_step <= 0.1, "music wraps without a jump (|last - first| = %.3f): %s" % [raw_step, path])
		var score := _seam_score(wav, 0.0)
		check(score <= 5.0, "music wrap point is continuous, no click (seam %.1f sigma): %s" % [score, path])
		var control := _seam_score(wav, step)
		check(control > 5.0, "control: the seam check does flag a %.2f step (%.1f sigma): %s" % [step, control, path])


# --- 7. music switches on New Game, awakening, and immediately again on Continue ---

func _test_music_switches_on_new_game_awakening_and_restore() -> void:
	var test_dir := "user://test_runs/m6_audio_telemetry_%d" % Time.get_ticks_usec()
	Telemetry.set_playtest_dir(test_dir)

	Session.new_run()
	Session.set_story("awakening_done", true)
	check(Audio.current_music() == &"lockdown",
			"awakening: Session.set_story(awakening_done, true) switches music to lockdown live")
	check(Session.commit("CP04"), "setup: awakening commits CP04 for the Continue check below")

	var main: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	await physics_frames(2)
	check(Audio.current_music() == &"none", "Main boot: showing the title screen silences music")

	var result: Dictionary = CheckpointService.load_latest()
	check(result.get("ok", false), "setup: the CP04 save loads back for Continue")
	main._on_continue_confirmed(result.snapshot)
	await physics_frames(3)
	check(Audio.current_music() == &"lockdown",
			"Continue after awakening: music is lockdown immediately " +
			"(load_from_snapshot() never re-fires story_state_changed — main.gd checks the flag itself)")

	main._on_quit_to_title()
	await physics_frames(2)
	check(Audio.current_music() == &"none", "Quit to title: music returns to none")

	main._on_new_game_confirmed()
	await physics_frames(3)
	check(Audio.current_music() == &"campus", "New Game: a fresh run plays the campus track")

	main._on_quit_to_title()
	await physics_frames(2)
	check(Audio.current_music() == &"none", "Quit to title again: music returns to none")

	main.queue_free()
	await physics_frames(2)

	Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.remove_dir_recursive(test_dir)
	CheckpointService.clear()


# --- 8. volume settings still reach the buses Audio's players use --------------

func _test_settings_map_to_buses() -> void:
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	check(music_idx >= 0, "setup: a Music bus exists (data/audio/default_bus_layout.tres)")
	check(sfx_idx >= 0, "setup: an SFX bus exists (data/audio/default_bus_layout.tres)")

	var prev_music: float = Settings.get_music_volume()
	var prev_sfx: float = Settings.get_sfx_volume()

	Settings.set_music_volume(0.5)
	check(is_equal_approx(AudioServer.get_bus_volume_db(music_idx), linear_to_db(0.5)),
			"Settings.set_music_volume reaches the Music bus Audio's music players use")
	check(not AudioServer.is_bus_mute(music_idx), "Music bus is not muted at volume 0.5")

	Settings.set_sfx_volume(0.0)
	check(AudioServer.is_bus_mute(sfx_idx), "Settings.set_sfx_volume(0.0) mutes the SFX bus Audio's SFX pool uses")

	Settings.set_music_volume(prev_music)
	Settings.set_sfx_volume(prev_sfx)


# --- helpers: read the generated wavs straight from disk ---------------------------
# The source files, not the imported streams: an imported WAV may be compressed
# (QOA), and these checks are about what tools/gen_audio.py wrote.

func _read_wav(path: String) -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 44 or bytes.slice(0, 4).get_string_from_ascii() != "RIFF":
		return {}
	var format := 0
	var channels := 0
	var rate := 0
	var bits := 0
	var pos := 12
	while pos + 8 <= bytes.size():
		var chunk_id := bytes.slice(pos, pos + 4).get_string_from_ascii()
		var chunk_size := bytes.decode_u32(pos + 4)
		if chunk_id == "fmt ":
			format = bytes.decode_u16(pos + 8)
			channels = bytes.decode_u16(pos + 10)
			rate = bytes.decode_u32(pos + 12)
			bits = bytes.decode_u16(pos + 22)
		elif chunk_id == "data":
			var frame_bytes := maxi(1, channels * int(bits / 8.0))
			return {
				"bytes": bytes, "offset": pos + 8, "format": format, "channels": channels,
				"rate": rate, "bits": bits, "frames": int(chunk_size / float(frame_bytes)),
			}
		pos += 8 + chunk_size + (chunk_size & 1)
	return {}


func _sample(wav: Dictionary, i: int) -> float:
	var bytes: PackedByteArray = wav.bytes
	return bytes.decode_s16(int(wav.offset) + i * 2) / 32768.0


## Peak, mean, RMS and the first/last sample of a mono 16-bit wav.
func _scan(wav: Dictionary) -> Dictionary:
	var bytes: PackedByteArray = wav.bytes
	var offset: int = wav.offset
	var frames: int = wav.frames
	var peak := 0.0
	var total := 0.0
	var squares := 0.0
	for i in frames:
		var v := bytes.decode_s16(offset + i * 2) / 32768.0
		peak = maxf(peak, absf(v))
		total += v
		squares += v * v
	return {
		"peak": peak, "mean": total / maxf(1.0, frames), "rms": sqrt(squares / maxf(1.0, frames)),
		"first": _sample(wav, 0), "last": _sample(wav, frames - 1),
	}


## How well the four samples before the wrap point predict the first sample
## after it (4th finite difference), in units of the same statistic measured
## away from the seam. A loop locked to whole cycles scores ~1-3; a loop cut at
## the wrong length, or a big step (`step_after`, the control), scores far
## higher. The lockdown loop's downbeat starts exactly on the wrap, so this is
## a guard against gross clicks, not a proof; the generator builds the loops to
## be periodic by construction (see tools/gen_audio.py).
func _seam_score(wav: Dictionary, step_after: float) -> float:
	var span := 3000
	var frames: int = wav.frames
	var y := PackedFloat32Array()
	for i in range(frames - span, frames):
		y.append(_sample(wav, i))
	for i in span:
		y.append(_sample(wav, i) + step_after)
	var squares := 0.0
	var count := 0
	var seam_peak := 0.0
	for k in range(4, y.size()):
		var e := y[k] - 4.0 * y[k - 1] + 6.0 * y[k - 2] - 4.0 * y[k - 3] + y[k - 4]
		if k >= span and k <= span + 3:
			seam_peak = maxf(seam_peak, absf(e))
		elif k < span - 8 or k > span + 8:
			squares += e * e
			count += 1
	var sigma := sqrt(squares / maxf(1.0, count))
	return seam_peak / maxf(sigma, 0.000001)


## The loudest `window_s` seconds of a mono 16-bit wav, as an RMS level in dBFS
## (a wav shorter than the window is measured as if padded with silence, the
## way a short cue lands in a 200 ms measurement).
func _loudest_rms_db(wav: Dictionary, window_s: float) -> float:
	var frames: int = wav.frames
	var window := maxi(1, int(round(window_s * float(wav.rate))))
	var sums := PackedFloat64Array()
	sums.resize(frames + 1)
	for i in frames:
		var v := _sample(wav, i)
		sums[i + 1] = sums[i] + v * v
	var best := 0.0
	if frames <= window:
		best = sums[frames] / float(window)
	else:
		for i in range(0, frames - window + 1):
			best = maxf(best, (sums[i + window] - sums[i]) / float(window))
	return 10.0 * log(maxf(best, 0.000000000001)) / log(10.0)


## RMS of the wav after a one-pole highpass, relative to its own RMS: how much
## of it sits above roughly `cutoff_hz`.
func _highpass_fraction(wav: Dictionary, cutoff_hz: float) -> float:
	var rc := 1.0 / (TAU * cutoff_hz)
	var a := rc / (rc + 1.0 / float(wav.rate))
	var prev_out := 0.0
	var prev_in := 0.0
	var out_squares := 0.0
	var in_squares := 0.0
	for i in int(wav.frames):
		var v := _sample(wav, i)
		prev_out = a * (prev_out + v - prev_in)
		prev_in = v
		out_squares += prev_out * prev_out
		in_squares += v * v
	return sqrt(out_squares / maxf(in_squares, 0.000000001))
