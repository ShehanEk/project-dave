extends TestCase
## N05 (ElevenLabs audio), the spoken lines in play: SC01's dialogue
## (scripts/objects/core_node.gd), the Security PA's two announcements
## (scripts/levels/level_director.gd) and how they sit on the subtitle panel
## (scripts/ui/subtitle_panel.gd). The voice clips themselves and the Audio
## director's voice API are covered by test_n05_eleven_audio.gd.
##
## Contracts under test:
##   1. A full watch-through of SC01 speaks adam_hello, dave_word_gets_around and
##      adam_stay in that order, each with its own caption (speaker and text), and
##      holds each caption at least as long as its clip plus CoreNode.VOICE_BEAT
##      without shortening the authored hold. Control still returns after the
##      scene's own timeline (19.0 s authored, 19.8 to 20.4 s with the clips).
##   2. The lockdown announcement (pa_remain_calm, "Security PA", PA_CALM_LINE)
##      starts PA_CALM_DELAY after control is back, after the last Adam caption is
##      gone (no overlap), never takes control away, holds its caption at least as
##      long as the clip, and plays once: not again after a death rebuild.
##   3. Skipping the dialogue stops the voice at once (from any line), and the
##      announcement still follows the lockdown.
##   4. Reaching the exit wicket plays pa_lethal with the existing PA caption, held
##      at least as long as the clip, and takes over from an announcement still
##      running (its voice is cut and its caption timer cannot clear the new one).
##   5. Continue after the awakening (a loaded save) never plays the announcement.
##   6. The subtitles setting only hides captions: every voice still plays.
##   7. Without a subtitle panel (an isolated test, or one that removed it) nothing
##      is spoken, and SC01 and the lockdown keep their state and timing.
##   8. Nothing outlives the level: freeing it mid-line stops the voice.
##
## Time is simulated (--fixed-fps), so the voice player's own "still playing" state
## follows wall-clock time; these checks read `Audio._voice_current` (the line the
## director started last, cleared by stop_voice()) plus `current_voice()` only at the
## frame a line starts. Redirects the save and playtest directories to a throwaway
## folder first, so nothing here touches the real save or playtest logs.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const DEPOT_AREA_INDEX := 4
const CORE_NODE_SCENE := "res://scenes/objects/core_node.tscn"

const ADAM_HELLO := &"adam_hello"
const DAVE_WORD := &"dave_word_gets_around"
const ADAM_STAY := &"adam_stay"
const PA_LETHAL := &"pa_lethal"
const PA_CALM := &"pa_remain_calm"

const DIALOGUE := [
	{"line": &"adam_hello", "speaker": "Adam", "text": "Hello, Dr. Harlan. I was told you'd been let go.", "hold": 4.0},
	{"line": &"dave_word_gets_around", "speaker": "Dave", "text": "Word gets around.", "hold": 2.0},
	{"line": &"adam_stay", "speaker": "Adam", "text": "I'm glad you came back. Please stay where you are.", "hold": 3.5},
]

## Frame-count slack when comparing a measured time to the one it should match.
const SLACK := 3.0 / 60.0

var _fps: float = 60.0


func run() -> void:
	_fps = float(Engine.physics_ticks_per_second)
	var scratch := "user://test_runs/n05_voice_%d" % Time.get_ticks_usec()
	var prev_save_dir: String = CheckpointService.get_save_dir()
	CheckpointService.set_save_dir(scratch + "/save")
	Telemetry.set_playtest_dir(scratch + "/playtests")
	var prev_subtitles: bool = Settings.get_subtitles_enabled()
	Settings.set_subtitles_enabled(true)

	_test_the_voice_lines_are_loaded()
	_test_constants_match_the_authored_timeline()
	await _test_full_watch_speaks_dialogue_then_announcement()
	await _test_skip_stops_the_voice()
	await _test_pa_lethal_plays_with_the_caption()
	await _test_wicket_takes_over_a_running_announcement()
	await _test_continue_never_announces()
	await _test_subtitles_off_still_speaks()
	await _test_no_subtitle_panel_stays_silent()
	await _test_nothing_outlives_the_level()

	Settings.set_subtitles_enabled(prev_subtitles)
	Audio.stop_voice()
	Telemetry.end_run()
	Telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.set_save_dir(prev_save_dir)
	CheckpointService.remove_dir_recursive(scratch)


# --- helpers ------------------------------------------------------------------

func _new_level() -> LevelDirector:
	Session.new_run()
	Audio.stop_voice()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	return level


func _core(level: LevelDirector) -> CoreNode:
	return level.areas[DEPOT_AREA_INDEX].get_node("Entities/CoreNode")


## Walks the hero to the core node and starts SC01 (the same frame as the first
## sample a following _sample() takes).
func _start_scene(level: LevelDirector) -> void:
	var core := _core(level)
	level.hero.global_position = core.global_position
	await physics_frames(2)
	core.interact(level.hero)


func _finish(level: LevelDirector) -> void:
	level.queue_free()
	await physics_frames(2)
	Audio.stop_voice()


## One snapshot of what is spoken and captioned right now.
func _snap(level: LevelDirector, frame: int) -> Dictionary:
	var d := {"frame": frame, "v": Audio._voice_current, "vis": false, "spk": "", "txt": "",
			"ctl": is_instance_valid(level) and level.hero != null and level.hero.input_enabled}
	var panel := get_tree().get_first_node_in_group("subtitle_panel")
	if panel:
		d["vis"] = panel.get_node("Panel").visible
		d["spk"] = panel.get_node("Panel/VBox/SpeakerLabel").text
		d["txt"] = panel.get_node("Panel/VBox/TextLabel").text
	return d


## Samples every physics frame for up to `seconds_to_run` (or until `until` returns
## true). A snapshot where a line starts is marked "started" and carries the clip
## length of the take that plays and whether the player is playing it.
func _sample(level: LevelDirector, seconds_to_run: float, until: Callable = Callable()) -> Array:
	var snaps: Array = []
	var last_v: StringName = &""
	for _i in int(ceil(seconds_to_run * _fps)):
		var d := _snap(level, snaps.size())
		if d.v != last_v and d.v != &"":
			d["started"] = true
			var stream: AudioStream = Audio._voice_player.stream
			d["clip"] = stream.get_length() if stream else 0.0
			d["playing"] = Audio.current_voice() == d.v
		last_v = d.v
		snaps.append(d)
		if until.is_valid() and until.call():
			break
		await get_tree().physics_frame
	return snaps


## The lines that started, in order.
func _sequence(snaps: Array) -> Array:
	var seq: Array = []
	for d in snaps:
		if d.has("started"):
			seq.append(d.v)
	return seq


## Index of the snapshot where `line` started, or -1.
func _start_of(snaps: Array, line: StringName) -> int:
	for i in snaps.size():
		if snaps[i].has("started") and snaps[i].v == line:
			return i
	return -1


## Index of the first snapshot after `start` where the caption shown at `start` is
## replaced or hidden, or -1 while it is still up at the end of the samples.
func _caption_end(snaps: Array, start: int) -> int:
	var text: String = snaps[start].txt
	for i in range(start + 1, snaps.size()):
		if not snaps[i].vis or snaps[i].txt != text:
			return i
	return -1


## Seconds the caption that came up with `line` stayed up (-1.0 if it never left).
func _caption_hold(snaps: Array, line: StringName) -> float:
	var start := _start_of(snaps, line)
	if start < 0:
		return -1.0
	var end := _caption_end(snaps, start)
	return -1.0 if end < 0 else float(end - start) / _fps


func _ever_captioned(snaps: Array) -> bool:
	for d in snaps:
		if d.vis:
			return true
	return false


# --- setup ----------------------------------------------------------------------

func _test_the_voice_lines_are_loaded() -> void:
	for line in [ADAM_HELLO, DAVE_WORD, ADAM_STAY, PA_LETHAL, PA_CALM]:
		check(Audio.has_voice(line), "setup: the voice line is loaded: %s" % String(line))


func _test_constants_match_the_authored_timeline() -> void:
	check_eq(CoreNode.T_LINE_1, 4.0, "the first line's authored hold is unchanged")
	check_eq(CoreNode.T_LINE_2, 2.0, "the second line's authored hold is unchanged")
	check_eq(CoreNode.T_LINE_3, 3.5, "the third line's authored hold is unchanged")
	check_eq(CoreNode.T_CONTAINMENT, 4.0, "the lockdown hold is unchanged")
	check(LevelDirector.PA_BEAT >= Audio.voice_length(PA_LETHAL) + LevelDirector.PA_VOICE_BEAT,
			"the PA caption's base hold (%.1fs) already covers the pa_lethal clip (%.2fs) plus a beat"
			% [LevelDirector.PA_BEAT, Audio.voice_length(PA_LETHAL)])
	check(LevelDirector.PA_CALM_LINE == "Attention, staff. For your comfort, all exits are now closed. Please remain calm.",
			"the lockdown announcement's caption is the spoken line")
	check(LevelDirector.PA_SPEAKER in SubtitlePanel.SPEAKER_COLORS,
			"the PA speaker has its caption colour, so both PA lines share it")


# --- 1 + 2: a full watch-through, then the announcement -----------------------------

func _test_full_watch_speaks_dialogue_then_announcement() -> void:
	var level := await _new_level()
	await _start_scene(level)
	check(not level.hero.input_enabled, "setup: SC01 takes control")
	var snaps := await _sample(level, 34.0)

	check_eq(_sequence(snaps), [ADAM_HELLO, DAVE_WORD, ADAM_STAY, PA_CALM],
			"SC01 speaks Adam, Dave, Adam in order, then the PA announces the lockdown")

	# Each line: caption and voice come up together, and the caption is held for
	# the authored hold, or the clip plus a beat when that is longer.
	var control_back := -1
	for i in snaps.size():
		if i > 0 and snaps[i].ctl:
			control_back = i
			break
	var expected_timeline := CoreNode.T_COPY + CoreNode.T_DIM + CoreNode.T_CONTAINMENT
	var last_caption_gone := -1
	for entry in DIALOGUE:
		var line: StringName = entry.line
		var start := _start_of(snaps, line)
		check(start >= 0, "the line is spoken: %s" % String(line))
		if start < 0:
			continue
		var d: Dictionary = snaps[start]
		check(d.playing, "the voice is playing when its caption appears: %s" % String(line))
		check(d.vis and d.spk == entry.speaker and d.txt == entry.text,
				"the caption comes up with its voice (%s: %s)" % [d.spk, d.txt])
		var clip: float = d.clip
		var want := maxf(float(entry.hold), clip + CoreNode.VOICE_BEAT)
		var held := _caption_hold(snaps, line)
		check(held >= float(entry.hold) - SLACK,
				"%s: the caption is not shorter than its authored %.1fs (held %.2fs)" % [String(line), entry.hold, held])
		check(held >= clip + CoreNode.VOICE_BEAT - SLACK,
				"%s: the caption outlasts the %.2fs clip by a beat (held %.2fs)" % [String(line), clip, held])
		check(absf(held - want) <= SLACK,
				"%s: the hold is the authored time or the clip plus a beat, nothing longer (%.2fs vs %.2fs)"
				% [String(line), held, want])
		expected_timeline += want
		last_caption_gone = _caption_end(snaps, start)

	# The scene's own timeline, with the clips, still hands control back on time.
	check(control_back > 0, "control returns to the player")
	var control_at := float(control_back) / _fps
	check(control_at >= 19.0 - SLACK and control_at <= 21.0,
			"control returns after the sane 19.0-21.0s scene (at %.2fs)" % control_at)
	check(absf(control_at - expected_timeline) <= 0.25,
			"control returns when the timeline says (%.2fs vs %.2fs)" % [control_at, expected_timeline])
	check(Session.get_story("awakening_done") == true, "the scene still ends in the lockdown state")
	check_eq(Session.state["checkpoint_id"], "CP04", "the scene still commits CP04")

	# The announcement: after control is back, after Adam's last caption, same PA look.
	var calm := _start_of(snaps, PA_CALM)
	if calm >= 0:
		var c: Dictionary = snaps[calm]
		check(c.playing, "the announcement's voice is playing when its caption appears")
		check(c.vis and c.spk == LevelDirector.PA_SPEAKER and c.txt == LevelDirector.PA_CALM_LINE,
				"the announcement is captioned as the Security PA (%s: %s)" % [c.spk, c.txt])
		check(c.ctl, "the player has control while the announcement speaks")
		check(calm > control_back, "the announcement comes after control is back")
		check(calm > last_caption_gone, "the announcement does not overlap Adam's captions")
		var wait := float(calm - control_back) / _fps
		check(wait >= LevelDirector.PA_CALM_DELAY - SLACK and wait <= LevelDirector.PA_CALM_DELAY + 0.15,
				"the announcement starts about %.1fs after control returns (%.2fs)" % [LevelDirector.PA_CALM_DELAY, wait])
		var clip: float = c.clip
		var held := _caption_hold(snaps, PA_CALM)
		check(held >= clip + LevelDirector.PA_VOICE_BEAT - SLACK and held >= LevelDirector.PA_CALM_HOLD - SLACK,
				"the announcement's caption outlasts its %.2fs clip (held %.2fs)" % [clip, held])
		var keeps_control := true
		for i in range(calm, snaps.size()):
			keeps_control = keeps_control and snaps[i].ctl
		check(keeps_control, "the announcement never takes control away")
	else:
		check(false, "the lockdown announcement is spoken")

	# Once per lockdown: it does not come back after it ends, nor after a death
	# rebuild (which restores CP04 and rebuilds every area).
	Audio.stop_voice()
	level.hero.take_damage(999, level.hero.global_position)
	var after := await _sample(level, 3.0)
	check_eq(_sequence(after), [], "nothing is spoken again after a death rebuild")
	check(not _ever_captioned(after), "no caption comes back after a death rebuild")
	await _finish(level)


# --- 3: skip -----------------------------------------------------------------------

func _test_skip_stops_the_voice() -> void:
	# Skipping during each of the three lines cuts that line's voice and caption.
	for entry in DIALOGUE:
		var level := await _new_level()
		await _start_scene(level)
		var line: StringName = entry.line
		var lead := await _sample(level, 20.0, func() -> bool: return Audio._voice_current == line)
		check(Audio.current_voice() == line, "setup: %s is speaking before the skip" % String(line))
		var seq_before := _sequence(lead)
		await hold(&"skip", 1.0 / 60.0)
		await physics_frames(3)
		check_eq(Audio.current_voice(), &"", "skip stops the voice mid-line (%s)" % String(line))
		check_eq(Audio._voice_current, &"", "skip clears the current line (%s)" % String(line))
		check(Session.get_story("awakening_done") == true, "skip still lands in the lockdown state (%s)" % String(line))
		check(level.hero.input_enabled, "skip hands control back at once (%s)" % String(line))
		# Before the announcement's delay, nothing speaks: the rest of the dialogue
		# stays unsaid.
		var quiet := await _sample(level, LevelDirector.PA_CALM_DELAY - 0.2)
		check_eq(_sequence(quiet), [], "nothing speaks after the skip, before the announcement (%s)" % String(line))
		check(not _ever_captioned(quiet), "the dialogue captions are gone after the skip (%s)" % String(line))
		check(seq_before.back() == line, "setup: the skip came during the line it should (%s)" % String(line))
		# The lockdown is still announced once the player has control.
		await _sample(level, 1.0, func() -> bool: return Audio._voice_current == PA_CALM)
		check(Audio._voice_current == PA_CALM, "the lockdown is still announced after a skip (%s)" % String(line))
		await _finish(level)

	# Skipped before anyone speaks (the copy phase): no dialogue voice at all.
	var early := await _new_level()
	await _start_scene(early)
	await seconds(0.5)
	await hold(&"skip", 1.0 / 60.0)
	var snaps := await _sample(early, 1.5)
	check_eq(_sequence(snaps), [PA_CALM], "skipping the copy phase speaks only the announcement")
	await _finish(early)


# --- 4: the wicket's PA line --------------------------------------------------------

func _test_pa_lethal_plays_with_the_caption() -> void:
	var level := await _new_level()
	level._on_wicket_reached()
	var snaps := await _sample(level, LevelDirector.PA_BEAT + 1.5)
	check_eq(_sequence(snaps), [PA_LETHAL], "reaching the wicket speaks pa_lethal")
	var start := _start_of(snaps, PA_LETHAL)
	if start >= 0:
		var d: Dictionary = snaps[start]
		check(d.playing, "the pa_lethal voice is playing")
		check(d.vis and d.spk == LevelDirector.PA_SPEAKER and d.txt == LevelDirector.PA_LINE,
				"the existing PA caption comes up with it (%s: %s)" % [d.spk, d.txt])
		var clip: float = d.clip
		var held := _caption_hold(snaps, PA_LETHAL)
		check(held >= clip + LevelDirector.PA_VOICE_BEAT - SLACK,
				"the PA caption outlasts the %.2fs clip (held %.2fs)" % [clip, held])
		check(held >= LevelDirector.PA_BEAT - SLACK, "the PA caption is not shorter than PA_BEAT (held %.2fs)" % held)
		check(is_instance_valid(level._completion_screen), "the completion screen opens after the PA line")
	await _finish(level)


func _test_wicket_takes_over_a_running_announcement() -> void:
	var level := await _new_level()
	await _start_scene(level)
	await seconds(0.2)
	await hold(&"skip", 1.0 / 60.0)
	await _sample(level, 5.0, func() -> bool: return Audio._voice_current == PA_CALM)
	check_eq(Audio._voice_current, PA_CALM, "setup: the announcement is speaking")
	await seconds(1.0)
	level._on_wicket_reached()
	var snaps := await _sample(level, LevelDirector.PA_BEAT + 1.5)
	check_eq(Audio._voice_current, PA_LETHAL, "the wicket's line takes the voice over from the announcement")
	check_eq(_sequence(snaps), [PA_LETHAL], "only the wicket's line speaks after the wicket")
	var held := _caption_hold(snaps, PA_LETHAL)
	check(snaps[0].vis and snaps[0].txt == LevelDirector.PA_LINE, "the wicket's caption replaces the announcement's")
	check(held >= Audio.voice_length(PA_LETHAL) + LevelDirector.PA_VOICE_BEAT - SLACK,
			"the announcement's caption timer does not clear the wicket's line early (held %.2fs)" % held)
	await _finish(level)


# --- 5: Continue ---------------------------------------------------------------------

func _test_continue_never_announces() -> void:
	# A loaded save that is already in lockdown: load_from_snapshot() never emits
	# story_state_changed, so the level is built silent.
	Session.new_run()
	Session.set_story("awakening_done", true)
	Session.set_story("core_installed", true)
	Session.set_story("hatch_open", true)
	var snapshot: Dictionary = Session.state.duplicate(true)
	Session.new_run()
	Session.load_from_snapshot(snapshot)
	Audio.stop_voice()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	check(Session.get_story("awakening_done") == true, "setup: the loaded run is already in lockdown")
	var snaps := await _sample(level, LevelDirector.PA_CALM_DELAY + LevelDirector.PA_CALM_HOLD + 2.0)
	check_eq(_sequence(snaps), [], "Continue after the awakening speaks nothing")
	check_eq(Audio._voice_current, &"", "Continue after the awakening starts no voice")
	check(not _ever_captioned(snaps), "Continue after the awakening shows no PA caption")

	# A death on that run restores the same save: still silent.
	level.hero.take_damage(999, level.hero.global_position)
	var after := await _sample(level, 3.0)
	check_eq(_sequence(after), [], "a death after Continue speaks nothing either")
	await _finish(level)


# --- 6: subtitles off ------------------------------------------------------------------

func _test_subtitles_off_still_speaks() -> void:
	Settings.set_subtitles_enabled(false)
	var level := await _new_level()
	await _start_scene(level)
	var lead := await _sample(level, 20.0, func() -> bool: return Audio._voice_current == ADAM_HELLO)
	check_eq(Audio._voice_current, ADAM_HELLO, "with subtitles off, Adam's line is still spoken")
	check(Audio.current_voice() == ADAM_HELLO, "with subtitles off, the voice is playing")
	check(not _ever_captioned(lead), "with subtitles off, no caption shows")

	await hold(&"skip", 1.0 / 60.0)
	var tail := await _sample(level, 3.0, func() -> bool: return Audio._voice_current == PA_CALM)
	check_eq(Audio._voice_current, PA_CALM, "with subtitles off, the lockdown announcement is still spoken")
	check(not _ever_captioned(tail), "with subtitles off, the announcement shows no caption")
	level._on_wicket_reached()
	await physics_frames(2)
	check_eq(Audio._voice_current, PA_LETHAL, "with subtitles off, the wicket's PA line is still spoken")
	check(Audio.current_voice() == PA_LETHAL, "with subtitles off, the wicket's voice is playing")
	check(not _ever_captioned([_snap(level, 0)]), "with subtitles off, the wicket's line shows no caption")
	await _finish(level)
	Settings.set_subtitles_enabled(true)


# --- 7: no subtitle panel -----------------------------------------------------------------

func _test_no_subtitle_panel_stays_silent() -> void:
	# A level whose subtitle panel is gone: dialogue is skipped as before, the scene
	# still runs its timeline and ends in the lockdown, and nothing is announced.
	var level := await _new_level()
	var panel := get_tree().get_first_node_in_group("subtitle_panel")
	check(panel != null, "setup: the level has a subtitle panel")
	panel.queue_free()
	await physics_frames(2)
	check(get_tree().get_first_node_in_group("subtitle_panel") == null, "setup: the panel is gone")
	await _start_scene(level)
	var snaps := await _sample(level, 14.0)
	check_eq(_sequence(snaps), [], "without a subtitle panel nothing is spoken")
	check(Session.get_story("awakening_done") == true, "without a subtitle panel SC01 still ends in the lockdown")
	check(level.hero.input_enabled, "without a subtitle panel control still returns")
	await _finish(level)

	# A core node on its own (no level, no panel): same.
	Session.new_run()
	Audio.stop_voice()
	var core: CoreNode = load(CORE_NODE_SCENE).instantiate()
	add_child(core)
	await physics_frames(2)
	var fake_hero := Node2D.new()
	core.interact(fake_hero)
	var isolated := await _sample_plain(14.0)
	check_eq(isolated, &"", "an isolated core node speaks nothing")
	check(Session.get_story("awakening_done") == true, "an isolated core node still ends in the lockdown state")
	core.queue_free()
	fake_hero.queue_free()
	await physics_frames(2)


## Samples only the director's current line for `seconds_to_run`; returns the last
## line seen starting (&"" if none ever did).
func _sample_plain(seconds_to_run: float) -> StringName:
	var seen: StringName = &""
	for _i in int(ceil(seconds_to_run * _fps)):
		if Audio._voice_current != &"":
			seen = Audio._voice_current
		await get_tree().physics_frame
	return seen


# --- 8: nothing outlives the level ------------------------------------------------------------

func _test_nothing_outlives_the_level() -> void:
	# Mid-dialogue.
	var level := await _new_level()
	await _start_scene(level)
	await _sample(level, 20.0, func() -> bool: return Audio._voice_current == ADAM_HELLO)
	check(Audio.current_voice() == ADAM_HELLO, "setup: Adam is speaking")
	level.queue_free()
	await physics_frames(2)
	check_eq(Audio._voice_current, &"", "leaving the level mid-dialogue stops the voice")
	check_eq(Audio.current_voice(), &"", "leaving the level mid-dialogue silences the player")

	# Mid-announcement.
	var level2 := await _new_level()
	await _start_scene(level2)
	await seconds(0.2)
	await hold(&"skip", 1.0 / 60.0)
	await _sample(level2, 5.0, func() -> bool: return Audio._voice_current == PA_CALM)
	check(Audio.current_voice() == PA_CALM, "setup: the announcement is speaking")
	level2.queue_free()
	await physics_frames(2)
	check_eq(Audio._voice_current, &"", "leaving the level mid-announcement stops the voice")
	check_eq(Audio.current_voice(), &"", "leaving the level mid-announcement silences the player")
	await seconds(1.0)
	check_eq(Audio._voice_current, &"", "nothing speaks after the level is gone (announcement)")

	# Mid-PA line at the wicket (its caption timer is a scene-tree timer: it must
	# not fire into the freed level).
	var level3 := await _new_level()
	level3._on_wicket_reached()
	await seconds(1.0)
	check_eq(Audio._voice_current, PA_LETHAL, "setup: the wicket's line is speaking")
	level3.queue_free()
	await physics_frames(2)
	check_eq(Audio._voice_current, &"", "leaving the level mid-PA stops the voice")
	check_eq(Audio.current_voice(), &"", "leaving the level mid-PA silences the player")
	await seconds(LevelDirector.PA_BEAT)
	check_eq(Audio._voice_current, &"", "nothing speaks after the level is gone (wicket)")
