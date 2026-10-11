extends Node2D
## Capture demo (tools/capture.sh), the hand-painted HD prototype (C56): Dave stands at a row of
## spots through A01 (the gate, the guard booth, the landmark, the lamps, the bench, the exit)
## and into A02, 0.6 s each. Throwaway save.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const SPOTS := [160.0, 640.0, 1150.0, 1700.0, 2150.0, 2750.0, 3250.0, 3700.0, 4300.0]

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/hd_tour_demo")
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	_run()


func _run() -> void:
	for x in SPOTS:
		level.hero.respawn_at(Vector2(x, -300.0))
		level.camera.reset_position()
		await get_tree().create_timer(0.6).timeout
