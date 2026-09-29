extends TestCase
## REGRESSION (playtest report 2026-09-27: "objects disappear when I go forward,
## then appear when I come back"). Area backdrops used to draw 60% past their
## own area on each side and hide themselves when the camera was >500 px
## outside their area, so near every seam two different house rows overlapped
## and one popped out of view while still on screen. Now each backdrop draws
## exactly its own area span and never toggles visibility, so every screen
## column is covered by exactly one sky layer and one homes/depot layer, and
## what is drawn never depends on the camera position or travel direction.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const HALF_SCREEN := 640.0


func run() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var layers: Array = []
	for n in level.find_children("*", "Parallax2D", true, false):
		var script: Script = n.get_script()
		if script and script.resource_path.ends_with("area_backdrop.gd"):
			layers.append(n)
	check_eq(layers.size(), 11, "backdrop layers found (5 outdoor areas x sky+homes, depot interior)")

	var level_end := 0.0
	for a in level.areas:
		level_end = maxf(level_end, a.global_position.x + a.width)

	var cam: Camera2D = get_viewport().get_camera_2d()
	var bad := 0
	# Sweep forward then back across the whole level; results must match.
	var sweeps := [range(0, int(level_end), 200), range(int(level_end), 0, -200)]
	var seen := {}
	for sweep in sweeps:
		for cx in sweep:
			cam.global_position.x = float(cx)
			await physics_frames(1)
			for col in [-HALF_SCREEN, -320.0, 0.0, 320.0, HALF_SCREEN - 1.0]:
				var wx: float = float(cx) + col
				if wx < 0.0 or wx >= level_end:
					continue
				var sky := 0
				var back := 0
				var owners := []
				for l in layers:
					if not l.is_visible_in_tree():
						continue
					var span: Vector2 = l._span()
					var x0: float = l.global_position.x + span.x
					if wx >= x0 and wx < x0 + span.y:
						if l.mode == 0:
							sky += 1
						else:
							back += 1
						owners.append(l.get_path())
				if back != 1 or sky > 1:
					bad += 1
					if bad <= 5:
						check(false, "world x %.0f (camera %d): %d sky, %d homes/depot layers" % [wx, cx, sky, back])
				var key := int(wx)
				if seen.has(key) and seen[key] != owners:
					bad += 1
					if bad <= 5:
						check(false, "world x %d shows different backdrop layers depending on camera/direction" % key)
				seen[key] = owners
	check_eq(bad, 0, "every sampled screen column has exactly one backdrop layer, independent of camera direction")
