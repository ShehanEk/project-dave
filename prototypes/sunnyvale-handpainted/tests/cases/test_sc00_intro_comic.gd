extends TestCase
## SC00, the intro comic (C49): scripts/ui/intro_comic.gd, shown by main.gd on New Game.
## Contracts under test:
##   1. The art: eight 2048x1152 panels in assets/story/intro/ that load as textures.
##   2. The script: eight third-person captions, the city named Eon City, Stroud's one
##      spoken line on panel 4 and the DEAD EDEN logo on the last panel.
##   3. Playing it: the narrator reads each panel (the ElevenLabs intro lines, with the
##      music ducked under him) while the caption types in at the voice's pace;
##      advance() finishes the typing, then moves to the next panel and cuts the voice; a
##      panel waits for its voice, then moves on by itself; on panel 4 Stroud speaks
##      after the narration (a press jumps to him); the last panel shows the logo;
##      advancing past it ends the comic (`finished(false)`), stops the voice, lifts the
##      duck and frees the comic.
##   4. Skipping: skip() from any panel ends it at once (`finished(true)`); the
##      accept and cancel actions advance and skip like the calls do.
##   5. Reduced motion: no drift (the panel never scales); otherwise the panel slowly
##      zooms.
##   6. Main: the title's New Game shows the comic instead of the level, deletes the
##      old save at once (as the confirm text promises) and keeps the title music; the
##      end of the comic starts a fresh level; Continue never shows it; with
##      `play_intro` off New Game goes straight to the level.
## Saves, settings and the playtest log go to a throwaway directory; the real ones are
## never touched.

const IntroComic := preload("res://scripts/ui/intro_comic.gd")
const MAIN_SCENE := "res://scenes/main.tscn"

var _done_box := [0, false]  # finished count, last skipped flag


func run() -> void:
	var base_save_dir: String = CheckpointService.get_save_dir()
	var base_playtest: String = Telemetry.get_playtest_dir()
	var scratch := "user://test_runs/sc00_intro_%d" % Time.get_ticks_usec()
	CheckpointService.set_save_dir(scratch + "/save")
	Telemetry.set_playtest_dir(scratch + "/playtests")
	var orig_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)

	_test_art()
	_test_script()
	await _test_playing()
	await _test_skipping_and_input()
	await _test_reduced_motion()
	await _test_main_flow()

	Settings.set_reduced_motion(orig_reduced)
	Audio.set_music(&"none")
	Audio.set_ambience(&"none")
	Session.new_run()
	Telemetry.end_run()
	Telemetry.set_playtest_dir(base_playtest)
	CheckpointService.set_save_dir(base_save_dir)
	CheckpointService.remove_dir_recursive(scratch)


func _spawn_intro() -> Node:
	_done_box[0] = 0
	_done_box[1] = false
	var intro: Node = IntroComic.new()
	add_child(intro)
	intro.finished.connect(func(skipped: bool) -> void:
		_done_box[0] += 1
		_done_box[1] = skipped)
	return intro


# --- 1. the art ------------------------------------------------------------------------

func _test_art() -> void:
	check_eq(IntroComic.PANELS.size(), 8, "the comic has eight panels")
	for i in IntroComic.PANELS.size():
		var path: String = IntroComic.PANELS[i]["texture"]
		check(ResourceLoader.exists(path), "panel %d art exists (%s)" % [i + 1, path])
		var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
		check(tex != null, "panel %d loads as a texture" % [i + 1])
		if tex:
			check_eq(tex.get_size(), Vector2(2048, 1152), "panel %d is 2048x1152 (16:9)" % [i + 1])
	check(ResourceLoader.exists(IntroComic.LOGO_PATH), "the DEAD EDEN logo exists for the last panel")
	# The narration: one ElevenLabs line per panel and Stroud's, each shorter than a
	# long breath past its caption's reading time.
	for i in IntroComic.PANELS.size():
		var line: StringName = IntroComic.PANELS[i].get("voice", &"")
		check_eq(line, StringName("intro_narration_%02d" % [i + 1]), "panel %d has its narration line" % [i + 1])
		check(Audio.has_voice(line), "panel %d's narration is loaded (%s)" % [i + 1, line])
		var length: float = Audio.voice_length(line)
		check(length > 0.8 and length < 14.0, "panel %d's narration is %.1f s" % [i + 1, length])
	check(Audio.has_voice(&"intro_stroud_04"), "Stroud's line is loaded")
	check_eq(IntroComic.PANELS[3].get("line_voice", &""), &"intro_stroud_04", "panel 4 plays Stroud's voice")


# --- 2. the script ---------------------------------------------------------------------

func _test_script() -> void:
	var all := ""
	for i in IntroComic.PANELS.size():
		var p: Dictionary = IntroComic.PANELS[i]
		var caption: String = p["caption"]
		check(caption.length() > 10, "panel %d has a caption" % [i + 1])
		check(caption.length() <= 200, "panel %d's caption fits the box (%d chars)" % [i + 1, caption.length()])
		# Third person: the narrator never speaks as "I" or "we".
		for word in [" I ", "I'm", " my ", " we ", " our "]:
			check(not (" " + caption + " ").contains(word), "panel %d is third person (no '%s')" % [i + 1, word.strip_edges()])
		all += caption + " "
	check(all.contains("Eon City"), "the comic names the city Eon City")
	check(not all.contains("Sunnyvale"), "the comic never says Sunnyvale")
	check(all.contains("Dave Harlan") and all.contains("Adam") and all.contains("Arcadia"), "the comic introduces Dave Harlan, Adam and Arcadia")
	var with_lines := IntroComic.PANELS.filter(func(p: Dictionary) -> bool: return p.has("line"))
	check_eq(with_lines.size(), 1, "exactly one panel has a spoken line")
	check_eq(IntroComic.PANELS[3].get("speaker", ""), "Stroud", "panel 4's line is Stroud's")
	check(IntroComic.PANELS[7].get("logo", false), "the last panel shows the logo")


# --- 3. playing it --------------------------------------------------------------------

func _test_playing() -> void:
	var intro := _spawn_intro()
	await physics_frames(2)
	check_eq(intro.panel_index(), 0, "the comic opens on panel 1")
	check(intro.current_texture() != null, "panel 1's art is shown")
	check(not intro.caption_fully_shown(), "the first caption is still typing two frames in")
	check_eq(Audio.current_voice(), &"intro_narration_01", "the narrator reads panel 1")
	check_eq(Audio.music_duck(), IntroComic.MUSIC_DUCK_DB, "the music is ducked under the narration")
	await seconds(0.5)
	var label: Label = intro.find_child("Caption", true, false)
	check(label.visible_characters > 0 and label.visible_characters < label.get_total_character_count(),
			"half a second in, part of the caption is shown (%d of %d)" % [label.visible_characters, label.get_total_character_count()])
	intro.advance()
	check(intro.caption_fully_shown(), "advance() finishes the typing")
	check_eq(intro.panel_index(), 0, "and stays on the panel")
	intro.advance()
	check_eq(intro.panel_index(), 1, "the next advance() goes to panel 2")
	check_eq(intro.caption_text(), IntroComic.PANELS[1]["caption"], "panel 2's caption")

	# The narrator reads panel 2; once the typing is done the panel waits for the voice,
	# then moves on by itself a moment later.
	check_eq(Audio.current_voice(), &"intro_narration_02", "the narrator reads panel 2")
	intro.advance()
	var left: float = intro.voice_seconds_left()
	check(left > 1.0, "the typing is done but the voice still has %.1f s to go" % left)
	await seconds(left * 0.5)
	check_eq(intro.panel_index(), 1, "panel 2 waits while its voice is speaking")
	await seconds(left * 0.5 + IntroComic.AUTO_ADVANCE_SECONDS + 0.3)
	check_eq(intro.panel_index(), 2, "then moves on by itself after its hold")
	check_eq(Audio.current_voice(), &"intro_narration_03", "and the narrator reads panel 3")

	# Panel 4: Stroud speaks after the narration, in his own voice.
	intro.advance()
	intro.advance()
	check_eq(intro.panel_index(), 3, "panel 4")
	check_eq(Audio.current_voice(), &"intro_narration_04", "turning the page cut panel 3's voice for panel 4's")
	intro.advance()
	check_eq(intro.speaker_line(), "", "Stroud's line waits for the narration")
	await seconds(intro.voice_seconds_left() + 0.1)
	check(intro.speaker_line().begins_with("Stroud:") and intro.speaker_line().contains("pay grade"),
			"Stroud's line shows when the narration ends (got: %s)" % intro.speaker_line())
	check_eq(Audio.current_voice(), &"intro_stroud_04", "and Stroud says it in his own voice")
	intro.advance()
	check_eq(intro.panel_index(), 4, "a press during Stroud's line turns the page")
	check_eq(intro.speaker_line(), "", "panel 5 has no spoken line")

	# A press during the narration on panel 4 jumps straight to Stroud's line.
	intro.skip()
	await physics_frames(2)
	intro = _spawn_intro()
	await physics_frames(2)
	while intro.panel_index() < 3:
		intro.advance()
	intro.advance()  # finish the typing
	intro.advance()  # cut the narration: Stroud now
	check(intro.speaker_line().begins_with("Stroud:"), "a press cuts to Stroud's line")
	check_eq(Audio.current_voice(), &"intro_stroud_04", "and his voice")
	intro.advance()
	check_eq(intro.panel_index(), 4, "the next press turns the page")

	while intro.panel_index() < 7:
		intro.advance()
	check(not intro.logo_visible(), "the logo waits for the last caption")
	intro.advance()
	check(intro.logo_visible(), "the last panel shows the DEAD EDEN logo")
	check_eq(_done_box[0], 0, "the comic has not ended before the last advance")
	intro.advance()
	check_eq(_done_box[0], 1, "advancing past the last panel ends the comic once")
	check_eq(_done_box[1], false, "a comic watched to the end is not 'skipped'")
	check_eq(Audio.current_voice(), &"", "the end of the comic stops the narrator")
	check_eq(Audio.music_duck(), 0.0, "and lifts the music back up")
	await physics_frames(2)
	check(not is_instance_valid(intro), "the comic frees itself when it ends")


# --- 4. skipping and input ------------------------------------------------------------

func _test_skipping_and_input() -> void:
	var intro := _spawn_intro()
	await physics_frames(2)
	intro.advance()
	intro.advance()
	intro.advance()
	intro.advance()
	check_eq(intro.panel_index(), 2, "setup: on panel 3")
	intro.skip()
	check_eq(_done_box[0], 1, "skip() ends the comic at once")
	check_eq(_done_box[1], true, "and reports it as skipped")
	check_eq(Audio.current_voice(), &"", "skipping stops the narrator")
	check_eq(Audio.music_duck(), 0.0, "and lifts the music back up")
	intro.skip()
	intro.advance()
	check_eq(_done_box[0], 1, "nothing fires twice after the end")
	await physics_frames(2)
	check(not is_instance_valid(intro), "a skipped comic frees itself")

	intro = _spawn_intro()
	await physics_frames(2)
	_send_action(&"ui_accept")
	check(intro.caption_fully_shown(), "the accept action finishes the typing")
	_send_action(&"ui_accept")
	check_eq(intro.panel_index(), 1, "and then turns the page")
	_send_action(&"ui_cancel")
	check_eq(_done_box[0], 1, "the cancel action skips the comic")
	check_eq(_done_box[1], true, "as a skip")
	await physics_frames(2)


func _send_action(action: StringName) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	Input.flush_buffered_events()


# --- 5. reduced motion -----------------------------------------------------------------

func _test_reduced_motion() -> void:
	var intro := _spawn_intro()
	await seconds(1.5)
	var panel: Control = intro.find_child("Panel", true, false)
	check(intro.drifts(), "with motion on, the panels drift")
	check(panel.scale.x > 1.0, "the panel has started its slow zoom (scale %.3f)" % panel.scale.x)
	intro.skip()
	await physics_frames(2)

	Settings.set_reduced_motion(true)
	intro = _spawn_intro()
	await seconds(1.5)
	panel = intro.find_child("Panel", true, false)
	check(not intro.drifts(), "Reduced motion: no drift")
	check_eq(panel.scale, Vector2.ONE, "Reduced motion: the panel never zooms")
	intro.skip()
	await physics_frames(2)
	Settings.set_reduced_motion(false)


# --- 6. Main --------------------------------------------------------------------------

func _test_main_flow() -> void:
	Session.new_run()
	Session.collect("L01-A01-G001", 1)
	check(Session.commit("CP02"), "setup: a valid CP02 save exists")

	var main: Node = load(MAIN_SCENE).instantiate()
	add_child(main)
	await physics_frames(3)
	var title = main._title
	check(title != null, "the title screen is up")
	check_eq(Audio.current_music(), &"title", "the title theme plays")
	title._on_new_game_pressed()
	await physics_frames(1)
	title._on_new_game_confirm()
	await physics_frames(2)
	var intro: Node = get_tree().get_first_node_in_group("intro_comic")
	check(intro != null, "New Game shows the intro comic")
	check(main._level == null, "the level waits for the comic")
	check(not is_instance_valid(title), "the title screen is gone")
	check(not CheckpointService.has_valid_save(), "the old save is deleted at once, as the confirm text says")
	check_eq(Session.chips_found(), 0, "the run is already fresh")
	check_eq(Audio.current_music(), &"title", "the title theme keeps playing under the comic")
	if intro:
		intro.skip()
	await physics_frames(3)
	check(main._level != null, "the end of the comic starts the level")
	check(get_tree().get_first_node_in_group("intro_comic") == null, "the comic is gone")
	check_eq(Audio.current_music(), &"campus", "the level's own music takes over")

	# Continue never shows the comic.
	check(Session.commit("CP02"), "setup: save a checkpoint again")
	var loaded: Dictionary = CheckpointService.load_latest()
	check(loaded.get("ok", false), "setup: the checkpoint loads")
	main._on_quit_to_title()
	await physics_frames(2)
	main._on_continue_confirmed(loaded.get("snapshot", {}))
	await physics_frames(2)
	check(get_tree().get_first_node_in_group("intro_comic") == null, "Continue never shows the intro comic")
	check(main._level != null, "Continue goes straight to the level")

	# With play_intro off, New Game goes straight to the level.
	main._on_quit_to_title()
	await physics_frames(2)
	main.play_intro = false
	main._title.new_game_confirmed.emit()
	await physics_frames(2)
	check(get_tree().get_first_node_in_group("intro_comic") == null, "play_intro off: no comic")
	check(main._level != null, "play_intro off: New Game starts the level at once")

	main.queue_free()
	await physics_frames(2)
