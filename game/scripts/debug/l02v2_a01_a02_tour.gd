extends Node2D
## Capture demo (tools/capture.sh): a tour of Level 2 v2's first two areas, A01 Sky bridge and
## coolant plant and A02 Firing range and K9 kennel, in the real level (LevelDirector). Dave
## (invulnerable, input off, enemies left as they are) is put at a spot about every 900 px, on
## the floor or on the deck that room is about, and held there 0.5 s, for judging the layout,
## density and supports. `[l02v2_tour]` lines name each spot and its frame. Throwaway save.
##   tools/capture.sh res://scenes/debug/l02v2_a01_a02_tour.tscn OUT 330 30

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const HOLD := 0.5
## [area index, local x, local y (feet), label]
const SPOTS := [
	[0, 500.0, 0.0, "A01 bridge"],
	[0, 1300.0, 0.0, "A01 airlock (E01)"],
	[0, 1840.0, -96.0, "A01 pump plinth"],
	[0, 2250.0, -190.0, "A01 pump catwalk (E02)"],
	[0, 2640.0, 0.0, "A01 steam vents and CP00B"],
	[0, 3250.0, 0.0, "A01 Broom bay and drill pad"],
	[0, 3900.0, 0.0, "A01 drill yard"],
	[0, 4380.0, 0.0, "A01 pipe gallery valve block (E03)"],
	[0, 5150.0, 0.0, "A01 pipe gallery far end (E04 door)"],
	[0, 5820.0, -180.0, "A01 service landing (E05)"],
	[1, 450.0, 0.0, "A02 range lobby (E06)"],
	[1, 1400.0, 0.0, "A02 lane 1 entry"],
	[1, 2300.0, 0.0, "A02 lane 1 (E07)"],
	[1, 3800.0, -160.0, "A02 control booth (CP01)"],
	[1, 4100.0, 0.0, "A02 armory glass"],
	[1, 4700.0, 0.0, "A02 live-fire lanes (E08)"],
	[1, 5800.0, 0.0, "A02 kennel row (E09)"],
	[1, 6900.0, 0.0, "A02 exercise yard pods"],
	[1, 7450.0, -120.0, "A02 yard walkway (E10)"],
]

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/l02v2_a01_a02_tour")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir("user://debug_demo_throwaway/l02v2_a01_a02_tour/playtests")
	Session.new_run("L02")
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	# The story lines would cover the floor in every frame: hide the subtitle panel.
	for n in get_tree().get_nodes_in_group("subtitle_panel"):
		if "visible" in n:
			n.visible = false
	var only := OS.get_environment("TOUR_SPOT")
	for i in SPOTS.size():
		if only != "" and int(only) != i:
			continue
		var sp: Array = SPOTS[i]
		var area: AreaRoot = level.areas[int(sp[0])]
		level.hero.respawn_at(area.to_global(Vector2(float(sp[1]), float(sp[2]) - 4.0)))
		level.camera.reset_position()
		print("[l02v2_tour] spot %d %s at frame %d" % [i, sp[3], Engine.get_frames_drawn()])
		await get_tree().create_timer(HOLD).timeout
	get_tree().quit()
