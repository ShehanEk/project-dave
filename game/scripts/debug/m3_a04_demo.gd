extends Node2D
## Capture-evidence demo for L01-A04 "Neighborhood square": places the Hero
## at the area's entry seam and drives the shared debug RouteBot through the
## whole main route (per CONVENTIONS.md "Areas and route bot"), so
## tools/capture.sh can film the full traversal for visual review. No
## class_name (per CONVENTIONS.md debug scripts).

@onready var area: AreaRoot = $Area
@onready var hero: Hero = $Hero
@onready var camera: GameCamera = $GameCamera


## debug-demos-touch-real-save: redirect BEFORE any child (the area's
## recovery station commits CP03 when the route bot uses it) can touch
## CheckpointService — `_enter_tree()` runs parent-first, ahead of every
## child's `_ready()`. This is a manual capture demo, never a test, so
## nothing else redirects it away from the real player's save directory.
func _enter_tree() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m3_a04_demo")
	Session.new_run()


func _ready() -> void:
	hero.debug_invulnerable = true
	var spawn := area.get_marker("Spawn_CP00")
	hero.global_position = spawn.global_position if spawn else Vector2(96.0, -4.0)
	camera.target = hero
	camera.world_limits = area.get_camera_limits()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(area, [])
	bot.start(hero)
