extends Node2D
## Capture demo (tools/capture.sh), Level 2's M5 story beats: Dave on the sky bridge as Adam
## greets him and the door opens, the door locking behind him, the training cells' lockdown
## (emergency strips, the TERMINATED screens) and the console scene by the Lattice hologram.
## Throwaway save; Dave is moved, never steered.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/l02_story_demo")
	Session.new_run("L02")
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	_run()


func _at(x: float, y: float, seconds: float) -> void:
	level.hero.respawn_at(Vector2(x, y))
	level.camera.reset_position()
	await get_tree().create_timer(seconds).timeout


func _run() -> void:
	var a01 := level.areas[0].global_position.x
	await _at(a01 + 380.0, -4.0, 1.2)     # Adam's greeting, the door waiting (amber)
	await _at(a01 + 640.0, -4.0, 1.2)     # the door opening (teal)
	await _at(a01 + 1080.0, -4.0, 1.5)    # locked behind him (red)
	var a04 := level.areas[3].global_position.x
	await _at(a04 + 300.0, -4.0, 2.2)     # the lockdown fading in
	await _at(a04 + 760.0, -204.0, 1.0)   # a screen from the upper ledge
	await _at(a04 + 2000.0, -204.0, 1.2)  # Dave's old desk screen
	var a05 := level.areas[4]
	await _at(a05.global_position.x + 2400.0, -304.0, 0.6)
	a05.get_node("Entities/AlignmentConsole").interact(level.hero)
	await get_tree().create_timer(6.5).timeout   # the archive line, then Adam through the hologram
	get_tree().quit()
