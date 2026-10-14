extends Node2D
## Capture demo (tools/capture.sh): a tour of Level 2 v2's A05 The Lattice and A06 Showroom and
## freight lift, in the real level (LevelDirector). Dave (invulnerable, input off, enemies left as
## they are) is put at a spot about every 900 px and on each tier, 0.5 s each, for judging layout,
## density and supports. Throwaway save.
##   tools/capture.sh res://scenes/debug/l02v2_a05_a06_tour.tscn OUT 1100 30
## `-- --area=A06` tours only A06; `--area=A05` only A05.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const THROWAWAY := "user://debug_demo_throwaway/l02v2_a05_a06_tour"
const HOLD := 0.5

## Area-local spots: [x, y] (y is the floor top Dave stands on).
const SPOTS := {
	"L02-A05": [
		[300, 0], [900, 0], [1600, -160], [1880, -160], [2300, -320], [2650, -320], [2900, -416],
		[3300, -480], [3600, -480], [3950, -480], [4400, -480], [4800, -480], [5300, -300], [5850, 0],
		[1700, 0], [3500, 0],
	],
	"L02-A06": [
		[300, 0], [900, 0], [1600, 0], [2300, 0], [2950, 0], [3600, -240], [4150, -240], [4700, -100],
		[5500, 0], [6300, 0], [6570, -120], [7100, 0], [1500, 240], [2400, 240],
	],
}

var level: LevelDirector
var _only: String = ""


func _enter_tree() -> void:
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--area="):
			_only = "L02-" + a.trim_prefix("--area=")
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	Session.new_run("L02")
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	for area in level.areas:
		if not SPOTS.has(area.area_id) or (_only != "" and area.area_id != _only):
			continue
		for s in SPOTS[area.area_id]:
			var p: Vector2 = area.to_global(Vector2(s[0], s[1] - 4.0))
			level.hero.respawn_at(p)
			var r: Rect2 = level._camera_target_rect_for_area(area)
			level._camera_top = r.position.y
			level._camera_bottom = r.position.y + r.size.y
			level.camera.world_limits = Rect2(0.0, r.position.y, level.level_width, r.size.y)
			await get_tree().physics_frame
			level.camera.reset_position()
			await get_tree().create_timer(HOLD).timeout
	get_tree().quit()
