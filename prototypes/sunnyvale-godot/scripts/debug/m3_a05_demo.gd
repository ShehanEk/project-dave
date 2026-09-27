extends Node2D
## Demo autopilot for tools/capture.sh visual evidence over L01-A05
## (scenes/levels/areas/a05_depot.tscn): instances the area alone with a
## Hero/GameCamera/RouteBot exactly like tests/area_harness.gd, then lets the
## RouteBot drive the full main route (console -> bench -> pad -> practice
## target -> hatch -> exit seam) for the capture window. No timeout/free
## logic here (unlike the test harness) since this scene just needs to run
## for the fixed-frame capture.

const AREA_SCENE := "res://scenes/levels/areas/a05_depot.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"


func _ready() -> void:
	# debug-demos-touch-real-save: redirect BEFORE any Session/CheckpointService
	# call — this is a manual capture demo, never a test, so nothing else
	# redirects CheckpointService away from the real player's save directory
	# for it (tests/run_tests.gd only redirects for the automated suite).
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m3_a05_demo")
	Session.new_run()

	var area: AreaRoot = load(AREA_SCENE).instantiate()
	add_child(area)

	var hero: Hero = load(HERO_SCENE).instantiate()
	var spawn := area.get_marker("Spawn_CP00")
	hero.global_position = spawn.global_position if spawn else Vector2(96.0, -4.0)
	hero.debug_invulnerable = true
	add_child(hero)

	var camera: GameCamera = load(CAMERA_SCENE).instantiate()
	camera.target = hero
	add_child(camera)
	camera.world_limits = area.get_camera_limits()

	# Let every _ready() (area containers, world-object Session reads, group
	# membership) run before the bot starts driving input.
	await get_tree().physics_frame
	await get_tree().physics_frame

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(area, [])
	bot.start(hero)
