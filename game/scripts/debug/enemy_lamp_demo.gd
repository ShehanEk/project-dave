extends Node2D
## Capture demo (tools/capture.sh): each lit enemy (Night Guard, Staffer, Patrol Rover) standing
## frozen under A01's street lamp (Lamp1, x 2150) and a copy away from it, one second each, for
## checking how a lamp lights them. Dave waits off to the left. Throwaway save.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const LAMP_X := 2150.0
const ENEMIES := ["res://scenes/actors/night_guard.tscn", "res://scenes/actors/staffer.tscn",
		"res://scenes/actors/patrol_rover.tscn"]

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/enemy_lamp_demo")
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.respawn_at(Vector2(LAMP_X - 900.0, -2.0))
	level.hero.input_enabled = false
	_run()


func _run() -> void:
	for path in ENEMIES:
		var near: Node2D = _place(path, LAMP_X - 40.0)
		var far: Node2D = _place(path, LAMP_X + 260.0)
		level.camera.target = near
		level.camera.global_position = Vector2(LAMP_X + 100.0, -120.0)
		await get_tree().create_timer(1.0).timeout
		near.queue_free()
		far.queue_free()


func _place(path: String, x: float) -> Node2D:
	var e: Node2D = load(path).instantiate()
	add_child(e)
	e.global_position = Vector2(x, 0.0)
	# Frozen after its first pose: no AI, no walking; the lights still draw.
	get_tree().create_timer(0.15).timeout.connect(func():
		if is_instance_valid(e):
			e.process_mode = Node.PROCESS_MODE_DISABLED)
	return e
