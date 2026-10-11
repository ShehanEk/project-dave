extends Node2D
## Debug demo for tools/capture.sh visual evidence: runs the RouteBot through
## L01-A02 "Front gardens" (main route + the OPT01 loft branch) with a
## following GameCamera, exactly like tests/area_harness.gd but left running
## so a windowed Movie Maker capture can record it. No class_name (debug
## scene, per CONVENTIONS.md).

const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"

@onready var area: AreaRoot = $Area

var hero: Hero
var camera: GameCamera
var bot: RouteBot


func _ready() -> void:
	# debug-demos-touch-real-save: redirect BEFORE any Session/CheckpointService
	# call — this is a manual capture demo, never a test, so nothing else
	# redirects CheckpointService away from the real player's save directory
	# for it (tests/run_tests.gd only redirects for the automated suite).
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m3_a02_demo")
	Session.new_run()

	hero = load(HERO_SCENE).instantiate()
	var spawn := area.get_marker("Spawn_CP00")
	hero.global_position = spawn.global_position if spawn else Vector2(96.0, -4.0)
	hero.debug_invulnerable = true
	add_child(hero)

	camera = load(CAMERA_SCENE).instantiate()
	camera.target = hero
	add_child(camera)
	camera.world_limits = area.get_camera_limits()

	for i in 2:
		await get_tree().physics_frame

	bot = RouteBot.new()
	add_child(bot)
	bot.build_points(area, ["OPT01"])
	bot.start(hero)
