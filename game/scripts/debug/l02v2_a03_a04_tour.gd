extends Node2D
## Capture demo (tools/capture.sh) for Level 2 v2's A03 Flight cage and A04 Training cells: the
## two areas built alone by a LevelDirector (a copy of L02's LevelDef holding only them, so the
## other areas' rebuilds never get in the way), Dave invulnerable, put down at a spot about every
## 900 px and on each storey of the cage, 0.5 s each, for judging layout, density and light.
## Throwaway save.
##   tools/capture.sh res://scenes/debug/l02v2_a03_a04_tour.tscn OUT 840 30
## `[l02v2_tour]` lines give each spot's frame.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const A03 := "res://scenes/levels/l02/a03_flight_cage.tscn"
const A04 := "res://scenes/levels/l02/a04_training_cells.tscn"
const HOLD := 0.5
## [area index, local x, local y (the floor there), label]
const SPOTS := [
	[0, 300, 0, "A03 drone bay entry"], [0, 1000, 0, "A03 drone bay (E12)"],
	[0, 1600, -40, "A03 cage stair"], [0, 1850, -140, "A03 Deck 1"], [0, 2500, -280, "A03 Deck 2 (rack)"],
	[0, 3150, -420, "A03 Deck 3"], [0, 3700, -560, "A03 Deck 4"], [0, 2600, 0, "A03 catch floor"],
	[0, 4250, -560, "A03 observation room"], [0, 4780, -560, "A03 CP02"], [0, 5250, -680, "A03 duct shelf"],
	[0, 5450, -300, "A03 gantry"], [0, 6200, 0, "A03 hangar floor"],
	[1, 300, 0, "A04 cell block"], [1, 1000, 0, "A04 open cell (E15)"], [1, 1500, 0, "A04 lane 1 rack"],
	[1, 2200, 0, "A04 cell room A (E16)"], [1, 2000, -200, "A04 upper ledge"], [1, 2900, 0, "A04 lane 2 rack"],
	[1, 3250, 0, "A04 Dave's desk"], [1, 3590, -320, "A04 side pod"], [1, 4400, 0, "A04 lane 3 rack"],
	[1, 4900, 0, "A04 server hall (E17)"], [1, 5800, 0, "A04 sandbox control"], [1, 6550, 0, "A04 screens"],
	[1, 6930, 0, "A04 CP03"],
]

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/l02v2_a03_a04_tour")
	Session.new_run("L02")
	var def: LevelDef = LevelDefs.get_def("L02").duplicate(true)
	def.area_scenes = [A03, A04]
	def.checkpoint_markers = {"CP00": [0, "Spawn_CP00"], "CP02": [0, "Respawn_CP02"],
			"UPG01": [0, "Respawn_UPG01"], "CP03": [1, "Respawn_CP03"]}
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = def
	add_child(level)
	await get_tree().physics_frame
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	for spot in SPOTS:
		var area: AreaRoot = level.areas[spot[0]]
		var at: Vector2 = area.to_global(Vector2(spot[1], spot[2] - 4.0))
		level.hero.respawn_at(at)
		var r: Rect2 = level._camera_target_rect_for_area(area)
		level._camera_top = r.position.y
		level._camera_bottom = r.position.y + r.size.y
		level.camera.world_limits = Rect2(0.0, r.position.y, level.level_width, r.size.y)
		await get_tree().physics_frame
		level.camera.reset_position()
		print("[l02v2_tour] frame %d: %s" % [Engine.get_frames_drawn(), spot[3]])
		await get_tree().create_timer(HOLD).timeout
	get_tree().quit()
