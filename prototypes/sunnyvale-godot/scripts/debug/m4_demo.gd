extends Node2D
## M4 capture demo (tools/capture.sh visual evidence): instances the depot
## (a05_depot.tscn) alone with a Hero/GameCamera exactly like the other
## debug demos, then drives a small bespoke autopilot (not RouteBot — it
## needs to operate real UI, which RouteBot deliberately never does) through
## the console awakening, a full workbench Quickcycle purchase (confirming the
## real WorkbenchPanel), and a full depot pad swap (confirming the real
## SwapConfirm dialog), so a capture proves both M4 UI flows against the
## live scenes, not a scripted stand-in.
##
## Demo-only bootstrap: grants the hero 60 chips directly on Session so the
## purchase step has something to spend (an isolated depot scene has no
## main-route chips of its own to collect first) — never a gameplay/test
## exploit, just how this ONE debug scene sets its starting condition.

const AREA_SCENE := "res://scenes/levels/areas/a05_depot.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"

const CONSOLE_X := 600.0
const WORKBENCH_X := 1450.0
const PAD_X := 1780.0
const TARGET_X := 2050.0

var hero: Hero
var area: AreaRoot


func _ready() -> void:
	# debug-demos-touch-real-save: redirect BEFORE any Session/CheckpointService
	# call — this is a manual capture demo, never a test, so nothing else
	# redirects CheckpointService away from the real player's save directory
	# for it (tests/run_tests.gd only redirects for the automated suite).
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m4_demo")
	Session.new_run()
	Session.state["wallet"] = 60

	area = load(AREA_SCENE).instantiate()
	add_child(area)

	hero = load(HERO_SCENE).instantiate()
	var spawn := area.get_marker("Spawn_CP00")
	hero.global_position = spawn.global_position if spawn else Vector2(96.0, -4.0)
	hero.debug_invulnerable = true
	add_child(hero)

	var camera: GameCamera = load(CAMERA_SCENE).instantiate()
	camera.target = hero
	add_child(camera)
	camera.world_limits = area.get_camera_limits()

	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	hud.setup(hero)

	await get_tree().physics_frame
	await get_tree().physics_frame

	_run_sequence()


func _run_sequence() -> void:
	# 1) Console: awakens Adam, unlocks the workbench, commits CP04. M5 replaced
	# the old M3 instant-flip stub with a real ~19s skippable SC01 scene
	# (core_node.gd) that disables hero.input_enabled the whole time it
	# plays, so this demo — like m5_demo.gd/m5b_demo.gd — presses `skip`
	# right after interacting rather than just waiting a beat (m4-demo-stale-
	# vs-sc01: without this the hero stays frozen at the console forever and
	# never reaches the workbench/pad below).
	await _move_to(CONSOLE_X)
	await _tap_interact()
	await _wait(0.3)
	Input.action_press("skip")
	await get_tree().physics_frame
	Input.action_release("skip")
	while not hero.input_enabled:
		await get_tree().physics_frame
	await _wait(0.5)

	# 2) Workbench: open the real WorkbenchPanel, watch it, confirm the Quickcycle
	# purchase, watch the result, then close it.
	await _move_to(WORKBENCH_X)
	await _tap_interact()
	await _wait(0.7)
	var workbench: Workbench = area.get_node("Entities/Workbench")
	if workbench._panel:
		await _wait(0.5)
		workbench._panel._on_confirm_pressed()
		await _wait(1.0)
		workbench._panel._on_decline_pressed()
	await _wait(0.4)

	# 3) Pad: open the real SwapConfirm dialog, watch it, confirm the swap,
	# watch the new held/resting tags.
	await _move_to(PAD_X)
	await _tap_interact()
	await _wait(0.7)
	var pad: WeaponPad = area.get_node("Entities/WeaponPad")
	if pad._dialog:
		pad._dialog._on_confirm()
		await _wait(0.8)

	# 4) Walk on to the practice target and fire a couple of shots so the
	# faster Quickcycle cadence is visible on the newly-held instance too.
	await _move_to(TARGET_X)
	Input.action_press("fire")
	await _wait(1.0)
	Input.action_release("fire")
	await _wait(0.6)


# --- small bespoke input helpers (not RouteBot: this demo must operate real
# UI buttons, which RouteBot deliberately never does) --------------------------

func _move_to(target_x: float) -> void:
	while absf(hero.global_position.x - target_x) > 6.0:
		if hero.global_position.x < target_x:
			Input.action_release("move_left")
			Input.action_press("move_right")
		else:
			Input.action_release("move_right")
			Input.action_press("move_left")
		await get_tree().physics_frame
	Input.action_release("move_left")
	Input.action_release("move_right")


func _tap_interact() -> void:
	Input.action_press("interact")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("interact")
	await get_tree().physics_frame


func _wait(seconds: float) -> void:
	var frames := int(ceil(seconds * Engine.physics_ticks_per_second))
	for i in frames:
		await get_tree().physics_frame
