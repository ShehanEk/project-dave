extends Node2D
## M6 art-pass evidence capture (tools/capture.sh res://scenes/debug/
## m6_characters_demo.tscn OUT_DIR frames fps): drives the Hero through
## idle/run/jump/land/interact/hit, the Resident through approach/windup/
## lunge/recovery/hit/defeated, and the Clipper through patrol/windup/
## charge/stall(exposed motor)/hit/defeated, all with real state-machine
## timing (no code under test is touched — this only presses named input
## actions like RouteBot, and calls the SAME public HitZone.take_hit() API
## a Scrapjack bolt already uses to land damage deterministically for the
## capture instead of aiming a live shot).
##
## New scene/script (not a shared debug fixture another agent owns); does
## not call Session.commit()/CheckpointService, so no save-dir redirect is
## needed here (matches scenes/debug/m2_resident_solo.gd's own precedent).

@onready var hero: Hero = $Hero
@onready var camera: Camera2D = $Camera
@onready var resident: Resident = $Resident
@onready var clipper: Clipper = $Clipper

const RESIDENT_FOCUS := Vector2(300.0, 460.0)
const CLIPPER_FOCUS := Vector2(1850.0, 460.0)


func _ready() -> void:
	# M6 evidence only: M6_REDUCED_MOTION=1 tools/capture.sh ... captures the
	# same sequence with Settings.reduced_motion on (visual-only toggle).
	if OS.get_environment("M6_REDUCED_MOTION") == "1":
		Settings.set_reduced_motion(true)
	hero.use_aim_override = true
	hero.aim_override = hero.global_position + Vector2(200.0, 0.0)
	camera.position = RESIDENT_FOCUS
	_run()


func _run() -> void:
	await get_tree().physics_frame
	await _resident_sequence()
	await _hero_showcase_and_walk_to_clipper()
	await _clipper_sequence()
	for i in range(60):
		await get_tree().physics_frame


func _resident_sequence() -> void:
	# Approach + at least two windup/lunge cycles happen on their own.
	var lunges := 0
	var was_lunge := false
	var guard := 0
	while lunges < 2 and guard < 900:
		await get_tree().physics_frame
		guard += 1
		var is_lunge: bool = resident.state == Resident.State.LUNGE
		if is_lunge and not was_lunge:
			lunges += 1
		was_lunge = is_lunge
	for i in range(15):
		await get_tree().physics_frame
	# Land 3 hits (Resident.health = 3) the same way a bolt would, spaced out
	# to see the hit-flash shape change each time, then hold the defeat pose.
	for hit in range(3):
		resident.hit_zone.take_hit(1, resident.global_position + Vector2(0.0, -40.0), Vector2(1.0, 0.0))
		for i in range(12):
			await get_tree().physics_frame
	for i in range(20):
		await get_tree().physics_frame


## Walks the Hero across to the Clipper section (run-cycle showcase),
## interacting with the lever on the way (interact pose) and jumping the
## Backstop wall just ahead of it (jump rise/apex/fall/land squash showcase
## — and the only way past: the Backstop is solid on layer 1 like any other
## world geometry, so the Hero must clear it the same way it would clear
## any low obstacle, exactly like the wall the Clipper itself charges into
## moments later).
func _hero_showcase_and_walk_to_clipper() -> void:
	camera.position = (RESIDENT_FOCUS + CLIPPER_FOCUS) * 0.5
	Input.action_press("move_right")
	var guard := 0
	while hero.global_position.x < 900.0 and guard < 900:
		await get_tree().physics_frame
		guard += 1
	Input.action_press("interact")
	for i in range(6):
		await get_tree().physics_frame
	Input.action_release("interact")
	guard = 0
	while hero.global_position.x < 1480.0 and guard < 900:
		await get_tree().physics_frame
		guard += 1
	Input.action_press("jump")
	# Hold well past the tuned time-to-apex (0.42s = 25 ticks at 60Hz) so the
	# jump isn't cut short — a quick tap would (correctly) only produce a
	# short hop, per hero.gd's own jump-cut behavior, too low to clear the
	# Backstop's 100px height.
	for i in range(30):
		await get_tree().physics_frame
	Input.action_release("jump")
	guard = 0
	while hero.global_position.x < 1780.0 and guard < 900:
		await get_tree().physics_frame
		guard += 1
	Input.action_release("move_right")


func _clipper_sequence() -> void:
	camera.position = CLIPPER_FOCUS
	var guard := 0
	while not clipper.is_stalled() and guard < 900:
		await get_tree().physics_frame
		guard += 1
	for i in range(20):
		await get_tree().physics_frame
	# Land 3 hits (Clipper.motor_health = 3) on the now-exposed rear motor.
	for hit in range(3):
		clipper.rear_hit_zone.take_hit(1, clipper.global_position, Vector2(1.0, 0.0))
		for i in range(12):
			await get_tree().physics_frame
