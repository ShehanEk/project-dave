extends Node2D
## Capture demo (tools/capture.sh): Dave beside the painted story props (Sheet 14): the A02
## breakfast table and guard's desk, the A04 pair, and the evidence folder. Throwaway save.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/story_props_demo")
	Session.new_run()
	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	_run()


func _run() -> void:
	var spots: Array = []
	for n in ["Breakfast", "Portrait"]:
		for node in level.find_children(n, "Scenery", true, false):
			spots.append(node.global_position)
	var folder: Node = level.find_child("EvidencePickup_A01", true, false)
	if folder:
		spots.append(folder.global_position)
	for p in spots:
		level.hero.respawn_at(p + Vector2(-90.0, -2.0))
		level.camera.reset_position()
		await get_tree().create_timer(0.8).timeout
