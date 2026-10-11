extends TestCase
## REGRESSION (ADV-05, was test_probe_adv_title_newgame.gd): the title's New
## Game confirmation used to read "This will replace your current run once
## you save again", but Main._on_new_game_confirmed() actually calls
## CheckpointService.clear() immediately, on confirm — before any save. A
## player who trusted the old text and quit before reaching a station lost
## their Continue with no warning. Fixed by making the text honest ("Your
## saved run will be deleted") to match the real, already-immediate delete
## (04-godot-architecture.md's Save design already allows confirmation to
## replace the run). This test locks BOTH halves together: the label's
## wording and the actual moment the save disappears.

func run() -> void:
	var telemetry: Node = get_node("/root/Telemetry")
	var test_dir := "user://test_runs/regress_title_newgame_%d" % Time.get_ticks_usec()
	telemetry.set_playtest_dir(test_dir)
	var cs: Node = get_node("/root/CheckpointService")

	Session.new_run()
	Session.collect("L01-A01-G001", 1)
	check(Session.commit("CP02"), "setup: a valid CP02 save exists")

	var main: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	await physics_frames(3)
	var title = main._title
	check(title != null, "title shown")
	title._on_new_game_pressed()
	await physics_frames(1)
	check(title._confirm_view.visible, "confirmation shown because a save exists")
	var label: Label = title.get_node("Panel/VBox/ConfirmView").find_children("*", "Label", true, false)[0]
	var label_text: String = label.text
	check(label_text.find("deleted") != -1,
			"New Game confirmation text is honest about the delete (got: %s)" % label_text)
	check(label_text.find("once you save again") == -1,
			"New Game confirmation no longer makes the old (false) 'survives until your next save' promise (got: %s)" % label_text)

	title._on_new_game_confirm()
	await physics_frames(4)
	check(not cs.has_valid_save(),
			"the save is actually gone immediately on confirm, matching the honest label text")

	main.queue_free()
	await physics_frames(2)
	telemetry.end_run()
	telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
	CheckpointService.remove_dir_recursive(test_dir)
