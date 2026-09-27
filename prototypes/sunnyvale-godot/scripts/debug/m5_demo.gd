extends Node2D
## M5 capture demo (tools/capture.sh visual evidence): instances the full
## `level_01.tscn` (LevelDirector) and drives a small bespoke autopilot (not
## RouteBot — this needs to trigger the real SC01 event and the real exit
## wicket, not just walk an authored route) through: the console's SC01
## warning/interlock visuals, a skip straight to the settled "awake" phase,
## A06's already-quarantined look, and the real exit-wicket completion
## screen — so a single capture proves all of M5's new visuals against the
## live scenes, not a scripted stand-in. Teleports the hero between beats
## (`hero.global_position =`, the same "hero owns nothing local, Session/
## LevelDirector own presentation" contract other debug demos rely on)
## rather than walking the whole level, to keep the capture short.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const DEPOT_AREA_INDEX := 4
const EXIT_AREA_INDEX := 5

var level: LevelDirector


func _ready() -> void:
	# debug-demos-touch-real-save: redirect BEFORE any Session/CheckpointService
	# call — this is a manual capture demo, never a test, so nothing else
	# redirects CheckpointService away from the real player's save directory
	# for it (tests/run_tests.gd only redirects for the automated suite).
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m5_demo")
	Session.new_run()

	level = load(LEVEL_01).instantiate()
	add_child(level)

	await get_tree().physics_frame
	await get_tree().physics_frame

	level.hero.debug_invulnerable = true

	_run_sequence()


func _run_sequence() -> void:
	var depot: AreaRoot = level.areas[DEPOT_AREA_INDEX]
	var console: CoreConsole = depot.get_node("Entities/CoreConsole")

	# 1) Approach the console and start SC01: hold on the warning phase
	# (ward-circuits tint + subtitle) long enough to read it.
	level.hero.global_position = console.global_position + Vector2(-40.0, 0.0)
	await _wait(0.3)
	console.interact(level.hero)
	await _wait(0.9)

	# 2) Skip straight through the interlock/dialogue to the settled "awake"
	# phase (proven identical to a full watch-through by test_m5_story.gd's
	# own T16) and hold on it.
	Input.action_press("skip")
	await get_tree().physics_frame
	Input.action_release("skip")
	while not level.hero.input_enabled:
		await get_tree().physics_frame
	await _wait(0.8)

	# 3) A06 is already showing the settled quarantine look the instant the
	# hero could see it (EnvironmentState reacted live while still in the
	# depot) — teleport in near the entrance rail/cloud-projector and hold.
	var exit_area: AreaRoot = level.areas[EXIT_AREA_INDEX]
	level.hero.global_position = exit_area.to_global(Vector2(260.0, -4.0))
	await _wait(1.0)

	# 4) Teleport onto the exit wicket itself to trigger the real ending:
	# CP05, the final objective, and the completion screen.
	var wicket: Area2D = exit_area.get_node("Entities/ExitWicket")
	level.hero.global_position = wicket.global_position
	await _wait(1.2)


func _wait(seconds: float) -> void:
	var frames := int(ceil(seconds * Engine.physics_ticks_per_second))
	for i in frames:
		await get_tree().physics_frame
