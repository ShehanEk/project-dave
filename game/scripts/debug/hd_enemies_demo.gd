extends Node2D
## Capture demo (tools/capture.sh), the hand-painted HD prototype, batch 2: the Staffer's three
## looks and the Patrol Rover's two liveries under A01's street lamp, frozen after their first
## pose, then an A03 roof pit (its cover's stripes repeat downward). Throwaway save.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const LAMP_X := 2150.0

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/hd_enemies_demo")
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	level.hero.respawn_at(Vector2(LAMP_X - 330.0, -2.0))
	level.camera.reset_position()
	var x := LAMP_X - 220.0
	for i in 3:
		_place("res://scenes/actors/staffer.tscn", _id(i, 3, "HDS"), x)
		x += 70.0
	for i in 2:
		_place("res://scenes/actors/patrol_rover.tscn", _id(i, 2, "HDR"), x + 30.0)
		x += 130.0
	await get_tree().create_timer(1.6).timeout
	level.hero.respawn_at(Vector2(10000.0 + 2400.0, -400.0))
	level.camera.reset_position()


func _id(i: int, n: int, prefix: String) -> String:
	for k in 300:
		var id := "%s%d" % [prefix, k]
		if posmod(hash(id), n) == i:
			return id
	return prefix


func _place(path: String, id: String, x: float) -> void:
	var e: Node2D = load(path).instantiate()
	e.entity_id = id
	add_child(e)
	e.global_position = Vector2(x, -2.0)
	get_tree().create_timer(0.2).timeout.connect(func():
		if is_instance_valid(e):
			e.process_mode = Node.PROCESS_MODE_DISABLED)
