extends TestCase
## M6 (presentation pass) — the Audio autoload (scripts/audio/audio_director.gd)
## and the generated cue library (tools/gen_audio.py -> assets/audio/**).
## Contracts under test (see CONVENTIONS.md "Audio"):
##   1. Every cue file exists on disk and loads as AudioStreamWAV.
##   2. play_sfx() runs for every known cue (flat AND positional) without
##      raising a runtime error, and an unknown cue name warns instead of
##      crashing.
##   3. Music switches to quarantine the instant awakening_done goes live,
##      AND immediately on Continue after awakening (load_from_snapshot()
##      never re-emits story_state_changed, so this exercises main.gd's own
##      explicit check, not just the Session signal listener).
##   4. Settings' volume sliders still reach the Master/Music/SFX buses that
##      Audio's own players are routed through.
##
## This is the one test in the project that instances scenes/main.tscn (to
## reach main.gd's Continue flow), so it redirects Telemetry to a throwaway
## directory first — the same pattern _test_telemetry_log_sequence() already
## uses in test_m5_flow.gd — never touching the real playtest log.


func run() -> void:
	_test_cues_exist_and_load()
	_test_play_sfx_every_cue()
	_test_unknown_cue_warns_not_crashes()
	await _test_music_switches_on_awakening_and_restore()
	_test_settings_map_to_buses()


# --- 1. every cue file exists and loads as AudioStreamWAV -----------------------

func _test_cues_exist_and_load() -> void:
	for cue in Audio.SFX_NAMES:
		var path := "res://assets/audio/sfx/%s.wav" % String(cue)
		check(ResourceLoader.exists(path), "sfx file exists on disk: %s" % path)
		var stream = load(path)
		check(stream is AudioStreamWAV, "sfx loads as AudioStreamWAV: %s" % path)
		check(Audio.has_cue(cue), "Audio director registered cue: %s" % String(cue))

	for key in Audio.MUSIC_FILES:
		var basename: String = Audio.MUSIC_FILES[key]
		var path := "res://assets/audio/music/%s.wav" % basename
		check(ResourceLoader.exists(path), "music file exists on disk: %s" % path)
		var stream = load(path)
		check(stream is AudioStreamWAV, "music loads as AudioStreamWAV: %s" % path)
		if stream is AudioStreamWAV:
			check(stream.loop_mode != AudioStreamWAV.LOOP_DISABLED,
					"music stream has a loop mode set for seamless looping: %s" % path)


# --- 2. play_sfx never errors, for every cue, flat and positional ---------------

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


# --- 3. music switches on awakening, and immediately again on Continue ---------

func _test_music_switches_on_awakening_and_restore() -> void:
	var test_dir := "user://test_runs/m6_audio_telemetry_%d" % Time.get_ticks_usec()
	Telemetry.set_playtest_dir(test_dir)

	Session.new_run()
	Session.set_story("awakening_done", true)
	check(Audio.current_music() == &"quarantine",
			"awakening: Session.set_story(awakening_done, true) switches music to quarantine live")
	check(Session.commit("CP04"), "setup: awakening commits CP04 for the Continue check below")

	var main: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	await physics_frames(2)
	check(Audio.current_music() == &"none", "Main boot: showing the title screen silences music")

	var result: Dictionary = CheckpointService.load_latest()
	check(result.get("ok", false), "setup: the CP04 save loads back for Continue")
	main._on_continue_confirmed(result.snapshot)
	await physics_frames(3)
	check(Audio.current_music() == &"quarantine",
			"Continue after awakening: music is quarantine immediately " +
			"(load_from_snapshot() never re-fires story_state_changed — main.gd checks the flag itself)")

	main._on_quit_to_title()
	await physics_frames(2)
	check(Audio.current_music() == &"none", "Quit to title: music returns to none")

	main.queue_free()
	await physics_frames(2)

	Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.remove_dir_recursive(test_dir)
	CheckpointService.clear()


# --- 4. volume settings still reach the buses Audio's players use --------------

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
