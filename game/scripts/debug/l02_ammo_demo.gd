extends Node2D
## Capture demo (tools/capture.sh): Level 2's feed cartridge. Dave takes the Boom Broom off the
## A01 pad (swapped in code), is put just before the first cartridge in A02 with a half
## reserve, steps onto it (the "+8 shells" toast, the shells row), then fires and reloads with
## the R key's request. Throwaway save.
##   tools/capture.sh res://scenes/debug/l02_ammo_demo.tscn OUT 150 30

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const PAD_ID := "L02-A01-PAD01"
const BROOM := "L02-W02-P01"

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/l02_ammo_demo")
	Session.new_run("L02")
	Session.swap_weapon(PAD_ID)
	Session.set_weapon_ammo(BROOM, 2, 8)
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	_run()


func _run() -> void:
	var a02 := level.areas[1].global_position.x
	level.hero.respawn_at(Vector2(a02 + 880.0, -4.0))
	level.camera.reset_position()
	await get_tree().create_timer(1.2).timeout
	level.hero.respawn_at(Vector2(a02 + 1000.0, -4.0))   # onto the cartridge
	await get_tree().create_timer(1.6).timeout
	level.hero.input_enabled = true
	level.hero.use_aim_override = true
	level.hero.aim_override = level.hero.global_position + Vector2(400.0, -30.0)
	var gun = level.hero.held_weapon()
	gun.try_blast()
	await get_tree().create_timer(0.9).timeout
	gun.request_reload()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
