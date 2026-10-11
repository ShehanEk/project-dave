extends Node2D
## Capture demo (tools/capture.sh): Dave standing still under A01's street lamp (Lamp1, x 2150),
## facing it and away from it, for checking how a lamp lights his face and hair. Throwaway save.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const LAMP_X := 2150.0

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/lamp_light_demo")
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.use_aim_override = true
	_run()


func _run() -> void:
	for spot in [[LAMP_X - 40.0, 1], [LAMP_X + 30.0, -1], [LAMP_X - 120.0, 1]]:
		level.hero.respawn_at(Vector2(spot[0], -2.0))
		level.hero.aim_override = level.hero.global_position + Vector2(400.0 * spot[1], -10.0)
		level.camera.reset_position()
		await get_tree().create_timer(1.0).timeout
