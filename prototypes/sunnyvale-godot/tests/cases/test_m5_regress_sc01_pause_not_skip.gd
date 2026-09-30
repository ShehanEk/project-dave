extends TestCase
## REGRESSION (ADV-01): pressing pause (Escape) during SC01 used to skip the
## scene and commit CP04 outright (CoreNode._hold() treated `pause` as a
## second skip action), so a player who reached for Escape to pause the
## game's only story scene lost it for good. story-scenes.md "Pause suspends
## scene playback"; interface-and-accessibility.md "Pause during dialogue;
## skip noninteractive scenes" are two different actions — fixed so `skip`
## (Enter) is SC01's only dismiss action and `pause` instead opens PauseMenu
## (via `Session.cutscene_active`) and genuinely freezes the scene's own
## timers.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	var console: CoreNode = level.areas[4].get_node("Entities/CoreNode")
	level.hero.global_position = console.global_position
	await physics_frames(2)
	console.interact(level.hero)
	await seconds(1.0)
	check(not Session.get_story("awakening_done"), "setup: SC01 still playing at 1s")
	await hold(&"pause", 1.0 / 60.0)
	await physics_frames(6)
	var paused: bool = get_tree().paused
	var skipped: bool = Session.get_story("awakening_done") == true
	check(not skipped, "pause during SC01 must not skip/finish the scene (awakening_done=%s, CP=%s)"
			% [skipped, Session.state["checkpoint_id"]])
	check(paused or level.pause_menu.visible, "pause during SC01 should suspend playback (tree paused=%s, menu visible=%s)"
			% [paused, level.pause_menu.visible])
	get_tree().paused = false
	await seconds(22.0)
	level.queue_free()
	await physics_frames(2)
