extends TestCase
## N05 (ElevenLabs audio pass): which music plays where. The decision is
## AmbienceMap.music_for() (scripts/audio/ambience_map.gd), applied by
## LevelDirector.update_music() at level start and every frame; main.gd plays the title
## theme on the title screen and leaves the level music to the director; the completion
## screen fades the music out and plays the completion sting.
## Contracts under test:
##   1. The decision table, every area before and after the lockdown: the depot has its
##      own track before the lockdown, every other area the campus track, and the
##      lockdown track everywhere afterwards; every answer is a loaded track.
##   2. The four ElevenLabs tracks (campus, lockdown, depot, title) are loaded from
##      their stereo files and loop forward over the whole file.
##   3. A level started at any checkpoint, before or after the lockdown, plays the right
##      track before its first frame (so nothing crosses over from another track) and
##      keeps it a moment later: main.gd and the director never fight.
##   4. Walking between areas changes the track by itself (campus -> depot -> campus),
##      the awakening in the depot switches depot -> lockdown at once and the per-frame
##      poll agrees, and a rollback of the flag goes back to the depot track.
##   5. The completion screen: the level music keeps playing through the wicket's PA
##      line, then fades out (`none`) as the screen opens, with the sting played once and
##      flat; the poll never restarts a level track over it; Play again brings the
##      campus track back and a New Game after that plays the level music too.
##   6. Main: the title plays the title theme at boot and after Quit to title; New Game,
##      Continue at the depot (before and after the lockdown) and Continue on a finished
##      save each end up on the right track; a Continue on a finished save shows the
##      completion screen with no level music under it; a level that Quit to title has
##      just freed cannot replace the title music (or the silent bed) in its last frame.
##
## Like the other audio cases it reads `Audio.current_music()` rather than waiting out
## the 1.2 s crossfade, and observes the sting by emptying Audio's pooled one-shot
## players and counting the ones holding the sting's stream afterwards (the way
## test_n05_ui_ticks.gd does). Saves and the playtest log go to a throwaway directory
## first; the real ones are never touched.

const AmbienceMap := preload("res://scripts/audio/ambience_map.gd")
const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const MAIN_SCENE := "res://scenes/main.tscn"

const NONE := &"none"
const CAMPUS := &"campus"
const DEPOT := &"depot"
const LOCKDOWN := &"lockdown"
const TITLE := &"title"
const STING := &"sting_complete"

const ELEVEN_TRACKS: Array[StringName] = [CAMPUS, LOCKDOWN, DEPOT, TITLE]

const AREA_IDS: Array[String] = ["L01-A01", "L01-A02", "L01-A03", "L01-A04", "L01-A05", "L01-A06"]

## Area id -> its track before the lockdown (after it, every area plays LOCKDOWN).
const TABLE := {
	"L01-A01": CAMPUS,
	"L01-A02": CAMPUS,
	"L01-A03": CAMPUS,
	"L01-A04": CAMPUS,
	"L01-A05": DEPOT,
	"L01-A06": CAMPUS,
}

## Checkpoint -> its track before the lockdown (after it: LOCKDOWN at every checkpoint).
## CP04 (beside the core node) and UPG01 (the workbench) are in the depot.
const CHECKPOINT_MUSIC := {
	"CP00": CAMPUS,
	"CP01": CAMPUS,
	"CP02": CAMPUS,
	"CP03": CAMPUS,
	"CP06": CAMPUS,
	"CP04": DEPOT,
	"UPG01": DEPOT,
	"CP07": CAMPUS,
	"CP05": CAMPUS,
}


func run() -> void:
	var base_save_dir: String = CheckpointService.get_save_dir()
	var base_playtest: String = Telemetry.get_playtest_dir()
	var scratch := "user://test_runs/n05_music_%d" % Time.get_ticks_usec()
	CheckpointService.set_save_dir(scratch + "/save")
	Telemetry.set_playtest_dir(scratch + "/playtests")

	_test_decision_table()
	_test_eleven_tracks_loop_the_whole_file()
	await _test_level_start_sets_the_track()
	await _test_walking_and_awakening()
	await _test_completion_screen()
	await _test_main_flow()

	Audio.set_music(NONE)
	Audio.set_ambience(NONE)
	Session.new_run()
	Telemetry.end_run()
	Telemetry.set_playtest_dir(base_playtest)
	CheckpointService.set_save_dir(base_save_dir)
	CheckpointService.remove_dir_recursive(scratch)


# --- 1. the decision table ----------------------------------------------------------

func _test_decision_table() -> void:
	for area_id in AREA_IDS:
		var before: StringName = TABLE[area_id]
		check_eq(AmbienceMap.music_for(area_id, false), before, "%s before the lockdown" % area_id)
		check_eq(AmbienceMap.music_for(area_id, true), LOCKDOWN, "%s after the lockdown" % area_id)
		check(Audio.has_music(before) and Audio.has_music(LOCKDOWN),
				"%s: both of its tracks are loaded" % area_id)

	check_eq(AmbienceMap.music_for("L01-A05", false), DEPOT, "the server depot has its own track before the lockdown")
	check_eq(AmbienceMap.music_for("L01-A05", true), LOCKDOWN, "...and the lockdown track after it")
	check_eq(AmbienceMap.music_for("L01-A06", false), CAMPUS, "the exit yard is still the campus track before the lockdown")
	check_eq(AmbienceMap.music_for("L01-A06", true), LOCKDOWN, "...and the lockdown track after it (unlike its bed, which stays)")
	# Music is never silent inside a level, whatever the area id says.
	check_eq(AmbienceMap.music_for("", false), CAMPUS, "no area id before the lockdown plays the campus track")
	check_eq(AmbienceMap.music_for("L99-A01", false), CAMPUS, "an unknown area before the lockdown plays the campus track")
	check_eq(AmbienceMap.music_for("", true), LOCKDOWN, "no area id after the lockdown plays the lockdown track")
	# The depot track is for the depot only.
	for area_id in AREA_IDS:
		if area_id != "L01-A05":
			check(AmbienceMap.music_for(area_id, false) != DEPOT, "%s never plays the depot track" % area_id)
	# The tracks the table can ever answer are a closed set of loaded tracks.
	var every_id: Array = AREA_IDS.duplicate()
	every_id.append_array(["", "L99-A01"])
	for awake in [false, true]:
		for area_id in every_id:
			var track: StringName = AmbienceMap.music_for(area_id, awake)
			check(track in [CAMPUS, DEPOT, LOCKDOWN] and Audio.has_music(track),
					"'%s' (lockdown %s): %s is a loaded level track" % [area_id, str(awake), String(track)])


# --- 2. the ElevenLabs tracks ---------------------------------------------------------

func _test_eleven_tracks_loop_the_whole_file() -> void:
	for track in ELEVEN_TRACKS:
		check(Audio.has_music(track), "the director loaded the track: %s" % String(track))
		check_eq(Audio.music_source(track), &"eleven", "the track plays from its ElevenLabs file: %s" % String(track))
		var stream = Audio._music_streams.get(track)
		check(stream is AudioStreamWAV, "the track is an AudioStreamWAV: %s" % String(track))
		if not (stream is AudioStreamWAV):
			continue
		check(stream.stereo, "the track is stereo: %s" % String(track))
		# The frame count comes from the length (an imported WAV may be compressed, so the
		# byte size of its data is not the frame count).
		var frames := int(round(stream.get_length() * float(stream.mix_rate)))
		check(frames > 0, "the track is not empty: %s" % String(track))
		check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_begin == 0 and stream.loop_end == frames,
				"the track loops forward over the whole file (loop %d..%d of %d): %s" %
				[stream.loop_begin, stream.loop_end, frames, String(track)])
	# The synthesized loops are still the fallback for the two keys they share; the new
	# tracks have no synthesized loop to fall back on.
	check(Audio.MUSIC_FILES.has(CAMPUS) and Audio.MUSIC_FILES.has(LOCKDOWN), "the synthesized campus and lockdown loops remain")
	check(not Audio.MUSIC_FILES.has(DEPOT) and not Audio.MUSIC_FILES.has(TITLE), "depot and title exist only as ElevenLabs tracks")


# --- 3. starting a level ---------------------------------------------------------------

func _test_level_start_sets_the_track() -> void:
	for checkpoint in CHECKPOINT_MUSIC:
		for awake in [false, true]:
			Session.new_run()
			Session.state["checkpoint_id"] = checkpoint
			Session.set_story("awakening_done", awake)
			Audio.set_music(TITLE)  # the title theme is playing when a level starts
			var level: LevelDirector = load(LEVEL_01).instantiate()
			add_child(level)
			var expected: StringName = LOCKDOWN if awake else CHECKPOINT_MUSIC[checkpoint]
			var where := "level started at %s %s the lockdown" % [checkpoint, "after" if awake else "before"]
			# Set by _ready() itself, with no frame needed.
			check_eq(Audio.current_music(), expected, where + ": track set before the first frame")
			await physics_frames(2)
			check_eq(Audio.current_music(), expected, where + ": track unchanged a frame later")
			level.queue_free()
			await physics_frames(2)
	Session.new_run()
	Audio.set_music(NONE)


# --- 4. walking, the awakening and a rollback ---------------------------------------------

func _test_walking_and_awakening() -> void:
	Session.new_run()
	Audio.set_music(NONE)
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	level.hero.debug_invulnerable = true
	check_eq(Audio.current_music(), CAMPUS, "a new run starts on the campus track")

	for i in level.areas.size():
		var area: AreaRoot = level.areas[i]
		await _put_hero(level, area.global_position.x + 40.0)
		check_eq(Audio.current_music(), TABLE[area.area_id],
				"walking into %s before the lockdown plays %s" % [area.area_id, String(TABLE[area.area_id])])
		check_eq(level.music_track(), TABLE[area.area_id], "the director's own track for %s" % area.area_id)

	# The depot and back out of it, both ways.
	await _put_hero(level, level.areas[3].global_position.x + 40.0)
	check_eq(Audio.current_music(), CAMPUS, "setup: in the plaza")
	await _put_hero(level, level.areas[4].global_position.x + 40.0)
	check_eq(Audio.current_music(), DEPOT, "entering the depot switches campus -> depot")
	await _put_hero(level, level.areas[3].global_position.x + 40.0)
	check_eq(Audio.current_music(), CAMPUS, "leaving the depot back to the plaza switches depot -> campus")
	await _put_hero(level, level.areas[4].global_position.x + 40.0)
	check_eq(Audio.current_music(), DEPOT, "setup: back in the depot")

	# The awakening happens in the depot: the lockdown track takes over at that moment,
	# and the director's poll agrees with it (nothing flips back to the depot track).
	Session.set_story("awakening_done", true)
	check_eq(Audio.current_music(), LOCKDOWN, "the awakening switches depot -> lockdown at once")
	await physics_frames(3)
	check_eq(Audio.current_music(), LOCKDOWN, "...and the per-frame poll leaves it there")
	await _put_hero(level, level.areas[3].global_position.x + 40.0)
	check_eq(Audio.current_music(), LOCKDOWN, "after the lockdown the plaza plays the lockdown track")
	await _put_hero(level, level.areas[4].global_position.x + 40.0)
	check_eq(Audio.current_music(), LOCKDOWN, "after the lockdown the depot plays the lockdown track too")
	await _put_hero(level, level.areas[5].global_position.x + 40.0)
	check_eq(Audio.current_music(), LOCKDOWN, "after the lockdown the exit yard plays the lockdown track")

	# A rollback to before the awakening (death or Restart from checkpoint) goes back.
	await _put_hero(level, level.areas[4].global_position.x + 40.0)
	Session.set_story("awakening_done", false)
	await physics_frames(2)
	check_eq(Audio.current_music(), DEPOT, "with the flag cleared again the depot plays the depot track")
	await _put_hero(level, level.areas[1].global_position.x + 40.0)
	check_eq(Audio.current_music(), CAMPUS, "...and the gardens the campus track")

	level.queue_free()
	await physics_frames(2)
	Session.new_run()
	Audio.set_music(NONE)


## Moves the hero to global x (just above the floor line) and lets the director's
## _process() see it.
func _put_hero(level: LevelDirector, global_x: float) -> void:
	level.hero.global_position = Vector2(global_x, -60.0)
	level.hero.velocity = Vector2.ZERO
	await physics_frames(3)


# --- 5. the completion screen -------------------------------------------------------------

func _test_completion_screen() -> void:
	Session.new_run()
	Session.set_story("awakening_done", true)
	Audio.set_music(NONE)
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	level.hero.debug_invulnerable = true
	await _put_hero(level, level.areas[5].global_position.x + 40.0)
	check_eq(Audio.current_music(), LOCKDOWN, "setup: the exit yard after the lockdown plays the lockdown track")

	_reset_pools()
	level._on_wicket_reached()
	await physics_frames(2)
	# The Security PA's line is spoken over the level music, which keeps playing.
	check(level._completion_screen == null, "setup: the completion screen waits for the PA line")
	check_eq(Audio.current_music(), LOCKDOWN, "the level music keeps playing through the wicket's PA line")
	check_eq(_flat_plays(STING), 0, "the sting does not play before the completion screen opens")

	await seconds(LevelDirector.PA_BEAT + 0.5)
	check(level._completion_screen != null, "the completion screen is open")
	check_eq(Audio.current_music(), NONE, "the completion screen fades the level music out")
	check_eq(_flat_plays(STING), 1, "the completion sting plays once, flat")
	check_eq(_positional_plays(STING), 0, "the completion sting is not positional")

	# Left alone with the screen up, nothing starts a level track or plays the sting again.
	await seconds(2.0)
	check_eq(Audio.current_music(), NONE, "the poll does not restart level music over the completion screen")
	level.update_music()
	check_eq(Audio.current_music(), NONE, "asking the director for music while the screen is up does nothing")
	check_eq(_flat_plays(STING), 1, "the sting is not played again")
	# Even a hero who somehow moved to the depot (or a flag rolled back) leaves it quiet.
	await _put_hero(level, level.areas[4].global_position.x + 40.0)
	check_eq(Audio.current_music(), NONE, "the poll stays quiet in any area while the screen is up")

	# Play again: a fresh run on the campus track.
	level._completion_screen._on_confirm_pressed()
	await physics_frames(4)
	check(level._completion_screen == null, "setup: Play again closed the completion screen")
	check_eq(Audio.current_music(), CAMPUS, "Play again brings the campus track back")
	await seconds(1.0)
	check_eq(Audio.current_music(), CAMPUS, "...and the poll keeps it")
	# The run can finish again: music out and a new sting.
	Session.set_story("awakening_done", true)
	check_eq(Audio.current_music(), LOCKDOWN, "the second run's awakening plays the lockdown track")
	_reset_pools()
	level._on_wicket_reached()
	await seconds(LevelDirector.PA_BEAT + 0.5)
	check_eq(Audio.current_music(), NONE, "the second completion fades the music out again")
	check_eq(_flat_plays(STING), 1, "...and plays its own sting once")

	level.queue_free()
	await physics_frames(2)
	Session.new_run()
	Audio.set_music(NONE)


# --- 6. Main: title, New Game, Continue, Quit to title -------------------------------------

func _test_main_flow() -> void:
	Session.new_run()
	Audio.set_music(CAMPUS)  # something left playing from before

	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(2)
	check_eq(Audio.current_music(), TITLE, "Main boot: the title screen plays the title theme")

	main._on_new_game_confirmed()
	await physics_frames(3)
	check_eq(Audio.current_music(), CAMPUS, "New Game: the title crossfades to the campus track")
	await physics_frames(10)
	check_eq(Audio.current_music(), CAMPUS, "New Game: the director keeps the campus track")

	var old_level: Node = main._level
	main._on_quit_to_title()
	check_eq(Audio.current_music(), TITLE, "Quit to title: the title theme")
	# The freed level has one more frame to run; it must not replace the title music or
	# bring a bed back under the title screen.
	check(old_level.is_queued_for_deletion(), "setup: the level is queued for deletion")
	old_level.update_music()
	old_level.update_ambience()
	check_eq(Audio.current_music(), TITLE, "the level's last frame cannot replace the title theme")
	check_eq(Audio.current_ambience(), NONE, "the level's last frame cannot bring its bed back under the title")
	await physics_frames(2)
	check_eq(Audio.current_music(), TITLE, "the title theme is still playing after the level is gone")

	# Continue at the depot, before the lockdown: the depot track from the start.
	main._on_continue_confirmed(_snapshot_at("CP04", false))
	check_eq(Audio.current_music(), DEPOT, "Continue at the depot before the lockdown: the depot track at once")
	await physics_frames(3)
	check_eq(Audio.current_music(), DEPOT, "...and it stays")
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_music(), TITLE, "Quit to title after a Continue: the title theme")

	# Continue at the same place after the lockdown.
	main._on_continue_confirmed(_snapshot_at("CP04", true))
	await physics_frames(3)
	check_eq(Audio.current_music(), LOCKDOWN, "Continue at the depot after the lockdown: the lockdown track")
	main._on_quit_to_title()
	await physics_frames(2)

	# Continue at the first checkpoint before the lockdown, then New Game.
	main._on_continue_confirmed(_snapshot_at("CP01", false))
	await physics_frames(3)
	check_eq(Audio.current_music(), CAMPUS, "Continue at the gardens before the lockdown: the campus track")
	main._on_quit_to_title()
	await physics_frames(2)

	# Continue on a finished save: the completion screen opens straight away, with no
	# level music under it and its sting played once.
	_reset_pools()
	main._on_continue_confirmed(_snapshot_complete())
	await physics_frames(3)
	var level: LevelDirector = main._level
	check(level._completion_screen != null, "setup: Continue on a finished save opens the completion screen")
	check_eq(Audio.current_music(), NONE, "Continue on a finished save: the title theme fades out, no level music")
	check_eq(_flat_plays(STING), 1, "Continue on a finished save: the completion sting plays once")
	await seconds(1.5)
	check_eq(Audio.current_music(), NONE, "...and the poll does not start the level music")
	check_eq(_flat_plays(STING), 1, "...nor play the sting again")

	# Quit to title from the completion screen: the title theme.
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_music(), TITLE, "Quit to title from the completion screen: the title theme")

	# Continue on the finished save again and Play again: a fresh run on the campus track.
	main._on_continue_confirmed(_snapshot_complete())
	await physics_frames(3)
	level = main._level
	check_eq(Audio.current_music(), NONE, "setup: the finished save is quiet again")
	level._completion_screen._on_confirm_pressed()
	await physics_frames(4)
	check_eq(Audio.current_music(), CAMPUS, "Play again after a Continue on a finished save: the campus track")
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_music(), TITLE, "Quit to title: the title theme")

	# New Game after all of that starts on the campus track.
	main._on_new_game_confirmed()
	await physics_frames(3)
	check_eq(Audio.current_music(), CAMPUS, "New Game after all of that: the campus track")
	main._on_quit_to_title()
	await physics_frames(2)
	check_eq(Audio.current_music(), TITLE, "Quit to title again: the title theme")

	main.queue_free()
	await physics_frames(2)
	CheckpointService.clear()
	Session.new_run()


## A snapshot of a fresh run placed at `checkpoint`, with the awakening flag as given,
## adopted by Main's Continue path in memory (nothing is written to disk).
func _snapshot_at(checkpoint: String, awakened: bool) -> Dictionary:
	Session.new_run()
	Session.state["checkpoint_id"] = checkpoint
	Session.set_story("awakening_done", awakened)
	return Session.state.duplicate(true)


## A snapshot of a finished run (CP05, the lockdown on, `level_complete` set).
func _snapshot_complete() -> Dictionary:
	Session.new_run()
	Session.state["checkpoint_id"] = "CP05"
	Session.set_story("awakening_done", true)
	Session.set_story("level_complete", true)
	return Session.state.duplicate(true)


# --- the sting probe -----------------------------------------------------------------------

## Stops and empties every pooled one-shot player, so what holds a stream after this
## was played since.
func _reset_pools() -> void:
	for p in Audio._sfx_pool:
		p.stop()
		p.stream = null
	for p in Audio._sfx2d_pool:
		p.stop()
		p.stream = null


## How many flat pool players hold one of `cue`'s streams.
func _flat_plays(cue: StringName) -> int:
	var streams: Array = Audio._sfx_pools.get(cue, {}).get("streams", [])
	var n := 0
	for p in Audio._sfx_pool:
		if p.stream != null and streams.has(p.stream):
			n += 1
	return n


## How many positional pool players hold one of `cue`'s streams.
func _positional_plays(cue: StringName) -> int:
	var streams: Array = Audio._sfx_pools.get(cue, {}).get("streams", [])
	var n := 0
	for p in Audio._sfx2d_pool:
		if p.stream != null and streams.has(p.stream):
			n += 1
	return n
