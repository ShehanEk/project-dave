extends Node2D
## Capture-only demo for L01-A03 (scenes/levels/areas/a03_roofs.tscn): drives
## the debug RouteBot through the area's main route (OPT02 branch included,
## so the capture also shows the optional cache detour) with a live
## GameCamera, for tools/capture.sh visual evidence. Not a test; no
## class_name (per CONVENTIONS.md debug-script convention).

const AREA := "res://scenes/levels/areas/a03_roofs.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"

var _area: AreaRoot
var _hero: Hero
var _camera: GameCamera
var _bot: RouteBot


func _ready() -> void:
	# debug-demos-touch-real-save: redirect BEFORE any Session/CheckpointService
	# call — this is a manual capture demo, never a test, so nothing else
	# redirects CheckpointService away from the real player's save directory
	# for it (tests/run_tests.gd only redirects for the automated suite).
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m3_a03_demo")
	Session.new_run()

	_area = load(AREA).instantiate()
	add_child(_area)

	_hero = load(HERO_SCENE).instantiate()
	var spawn := _area.get_marker("Spawn_CP00")
	_hero.global_position = spawn.global_position if spawn else Vector2(96.0, -4.0)
	_hero.debug_invulnerable = true
	add_child(_hero)

	_camera = load(CAMERA_SCENE).instantiate()
	add_child(_camera)
	_camera.target = _hero
	_camera.world_limits = _area.get_camera_limits()

	await get_tree().physics_frame
	await get_tree().physics_frame

	_bot = RouteBot.new()
	add_child(_bot)
	_bot.build_points(_area, ["OPT02"])
	_bot.start(_hero)
