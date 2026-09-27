extends Node2D
## Capture-evidence demo for L01-A04 "Neighborhood square": places the Hero
## at the area's entry seam and drives the shared debug RouteBot through the
## whole main route (per CONVENTIONS.md "Areas and route bot"), so
## tools/capture.sh can film the full traversal for visual review. No
## class_name (per CONVENTIONS.md debug scripts).

@onready var area: AreaRoot = $Area
@onready var hero: Hero = $Hero
@onready var camera: GameCamera = $GameCamera


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
