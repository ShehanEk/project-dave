extends Node2D
## Capture demo (tools/capture.sh), the hand-painted HD prototype (C56): Dave under A01's street
## lamp (Lamp1, x 2150) and the three Night Guard looks; the first walks in, winds up and swings,
## then Dave (invulnerable) shoots him down: the walk, the windup tell, the swing, the flinch,
## Dave's aim and the ragdoll. Throwaway save.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const LAMP_X := 2150.0

var level: LevelDirector
var guard: Node2D


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/hd_fight_demo")
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.respawn_at(Vector2(LAMP_X - 60.0, -2.0))
	level.hero.use_aim_override = true
	level.camera.reset_position()
	for i in 3:
		var g: Node2D = load("res://scenes/actors/night_guard.tscn").instantiate()
		g.entity_id = _id_for_look(i)
		add_child(g)
		g.global_position = Vector2(LAMP_X + 260.0 + i * 70.0, -2.0)
		if i == 0:
			guard = g
		else:
			g.process_mode = Node.PROCESS_MODE_DISABLED
	_run()


## An entity id that picks look `i` (Brawler.rig_path_for_look hashes the id).
func _id_for_look(i: int) -> String:
	for n in 200:
		var id := "HDDEMO%d" % n
		if posmod(hash(id), 3) == i:
			return id
	return "HDDEMO"


func _physics_process(_delta: float) -> void:
	if level and level.hero and is_instance_valid(guard):
		level.hero.aim_override = guard.global_position + Vector2(0.0, -60.0)


func _run() -> void:
	await get_tree().create_timer(2.6).timeout
	for i in 4:
		Input.action_press("fire")
		await get_tree().create_timer(0.12).timeout
		Input.action_release("fire")
		await get_tree().create_timer(0.55).timeout
	level.hero.aim_override = level.hero.global_position + Vector2(300.0, -200.0)
