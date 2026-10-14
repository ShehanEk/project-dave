extends Node2D
## Capture demo (tools/capture.sh): a tour of Level 2. Dave (invulnerable, enemies left as they
## are) is put at three route points in each area, 0.5 s each: for judging the look and layout.
## Throwaway save.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/l02_tour_demo")
	Session.new_run("L02")
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true
	level.hero.input_enabled = false
	for a in level.areas:
		var pts: Array = []
		var route := a.get_node_or_null("Route")
		if route:
			pts = route.get_children()
		var n := pts.size()
		for k in [0.05, 0.22, 0.4, 0.58, 0.76, 0.93]:
			if n == 0:
				continue
			var p: Node2D = pts[clampi(int(k * n), 0, n - 1)]
			level.hero.respawn_at(p.global_position + Vector2(0, -4))
			level.camera.reset_position()
			await get_tree().create_timer(0.5).timeout
	get_tree().quit()
