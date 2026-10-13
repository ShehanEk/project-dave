extends Node2D
## Capture demo (tools/capture.sh): how Dave holds a gun. Standing still in A02's range lane, he
## turns through every aim step (up, 67.5, 45, 22.5, level, down ...) facing right, with the
## Scrapjack and then the Boom Broom (swapped in code), 0.35 s a step: for judging the hold.
## `--weapon=W01` or `--weapon=W02` (user args) runs only that gun. Throwaway save.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const PAD_ID := "L02-A01-PAD01"
const DEGS := [-90.0, -67.5, -45.0, -22.5, 0.0, 22.5, 45.0, 67.5, 89.0]

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/hold_demo")
	Session.new_run("L02")
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	await get_tree().physics_frame
	var hero: Hero = level.hero
	hero.debug_invulnerable = true
	hero.input_enabled = false
	hero.use_aim_override = true
	var a02 := level.areas[1].global_position.x
	hero.respawn_at(Vector2(a02 + 400.0, -4.0))
	level.camera.reset_position()
	await get_tree().create_timer(0.6).timeout
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--weapon="):
			only = a.substr(9)
	for w in ["W01", "W02"]:
		if only != "" and only != w:
			continue
		if w == "W02":
			Session.swap_weapon(PAD_ID)
			await get_tree().create_timer(0.5).timeout
		for d in DEGS:
			var a := deg_to_rad(d)
			hero.aim_override = hero.aim_pivot.global_position + Vector2(cos(a), sin(a)) * 400.0
			await get_tree().create_timer(0.35).timeout
	get_tree().quit()
