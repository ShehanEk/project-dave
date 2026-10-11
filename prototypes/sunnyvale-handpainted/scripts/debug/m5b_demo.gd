extends Node
## M5 part 2 capture demo (tools/capture.sh visual evidence): drives the real
## Main flow — title screen -> New Game -> a moment of real gameplay -> the
## real pause menu (Journal view) -> Settings view -> Resume — through actual
## button presses / signals (not a scripted stand-in), so a single capture
## proves the new title/pause/settings shell against the live scenes.

const MAIN_SCENE := "res://scenes/main.tscn"

var main: Node


func _ready() -> void:
	# debug-demos-touch-real-save (critical): this demo drives Main's REAL New
	# Game path, which calls CheckpointService.clear() on whatever save dir is
	# active — redirect it BEFORE instancing Main so a capture run can never
	# delete or overwrite the real player's save under the default dir.
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m5b_demo")
	# AD-13 fix: Main._start_level() also calls Telemetry.run_start(), which
	# this demo (the only debug demo that instances the real Main) previously
	# left pointed at the default user://sunnyvale/playtests dir — every
	# capture run of this scene wrote a real playtest log next to the actual
	# player's. Redirect it the same way, before Main is instanced.
	Telemetry.set_playtest_dir("user://debug_demo_throwaway/m5b_demo/playtests")
	main = load(MAIN_SCENE).instantiate()
	add_child(main)
	await get_tree().physics_frame
	_run_sequence()


func _run_sequence() -> void:
	await _wait(0.6)  # hold on the title screen

	var title = main.get_node("TitleScreen")
	main.play_intro = false  # this demo films the level, not the SC00 intro comic
	title._on_new_game_pressed()
	await get_tree().physics_frame
	# A stale save under THIS demo's own redirected throwaway dir (see
	# debug-demos-touch-real-save) may already exist from an earlier capture
	# run -> New Game shows its confirmation view first; confirm it so this
	# demo always reaches a fresh run regardless of prior save state. When no
	# save exists, `_on_new_game_pressed()` above already emitted
	# `new_game_confirmed` synchronously and Main has already freed `title`
	# by now — guard with `is_instance_valid` so that (the common, fresh-dir)
	# case doesn't try to read `_view` off an already-freed node.
	if is_instance_valid(title) and title._view == TitleScreen.View.NEW_GAME_CONFIRM:
		title._on_new_game_confirm()
	await get_tree().physics_frame
	await get_tree().physics_frame

	var level: LevelDirector = main._level
	await _wait(0.6)  # a moment of real gameplay (HUD visible)

	# Open the real pause menu straight to the Journal view (the "journal"
	# action opens it directly).
	Input.action_press("journal")
	await get_tree().physics_frame
	Input.action_release("journal")
	await _wait(1.0)

	# Settings view.
	level.pause_menu._on_settings_pressed()
	await _wait(1.0)

	# Back to the main pause view, then resume.
	level.pause_menu._back_to_main()
	await _wait(0.4)
	level.pause_menu._resume()
	await _wait(0.5)


func _wait(seconds: float) -> void:
	var frames := int(ceil(seconds * Engine.physics_ticks_per_second))
	for i in frames:
		await get_tree().physics_frame
