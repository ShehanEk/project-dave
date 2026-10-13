extends TestCase
## Regression (found in M2): MovingPlatform._is_blocked_ahead() cast its look-ahead ray
## from `position` (the platform's PARENT-local coordinates, where point_a/point_b live)
## as if it were global. In an area placed away from world x 0 (every Level 1 area after
## A01, and Level 2's) it looked at the wrong spot: a real blocker on its track was never
## seen (the platform swept through it), and an unrelated solid at the same numbers in
## world space made it turn back for nothing. The ray is now cast in world space.

const BlockScript := preload("res://scripts/world/block.gd")
const PLATFORM_SCENE := "res://scenes/objects/moving_platform.tscn"
## Where the "area" sits in the world, like Level 1's A03 (far from x 0).
const AREA_X := 7000.0
const A := Vector2(200.0, -100.0)
const B := Vector2(800.0, -100.0)
const WIDTH := 160.0


func run() -> void:
	await _test_real_blocker_in_offset_area()
	await _test_phantom_blocker_ignored()
	await _test_level_1_gap_platform()


func _area() -> Node2D:
	var area := Node2D.new()
	area.name = "OffsetArea"
	area.position = Vector2(AREA_X, 0.0)
	add_child(area)
	return area


func _block(parent: Node, pos: Vector2, size: Vector2) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = pos
	b.size = size
	parent.add_child(b)
	return b


func _platform(parent: Node) -> Node2D:
	var plat: Node2D = load(PLATFORM_SCENE).instantiate()
	plat.point_a = A
	plat.point_b = B
	plat.speed = 150.0
	plat.pause_time = 0.3
	plat.width = WIDTH
	parent.add_child(plat)
	return plat


## Runs the platform for `secs` and returns the furthest x (parent-local) it reached.
func _max_x(plat: Node2D, secs: float) -> float:
	var furthest: float = plat.position.x
	for i in int(secs * 60.0):
		await physics_frames(1)
		furthest = maxf(furthest, plat.position.x)
	return furthest


func _test_real_blocker_in_offset_area() -> void:
	var area := _area()
	# A post standing in the middle of the track (area-local x 500), level with the deck.
	var post := _block(area, Vector2(500.0, -160.0), Vector2(30.0, 120.0))
	var plat := _platform(area)
	await physics_frames(2)
	var furthest: float = await _max_x(plat, 5.0)
	var front: float = furthest + WIDTH * 0.5
	check(front <= post.position.x + 1.0,
			"a platform in an area at world x %d turns back at a post on its track (front reached area x %.0f, post at %.0f)"
			% [int(AREA_X), front, post.position.x])
	check(furthest < B.x - 1.0, "...and never reaches its far end through the post (furthest %.0f)" % furthest)
	area.queue_free()
	await physics_frames(2)


func _test_phantom_blocker_ignored() -> void:
	var area := _area()
	# Nothing on the track; a solid at the track's numbers in WORLD space (x 500, y -100),
	# where the old ray looked, far from this area.
	_block(self, Vector2(470.0, -160.0), Vector2(60.0, 120.0))
	var plat := _platform(area)
	await physics_frames(2)
	var furthest: float = await _max_x(plat, 5.0)
	check(furthest >= B.x - 0.5,
			"a solid elsewhere in the world (at the track's local numbers) does not stop it (furthest %.0f of %.0f)" % [furthest, B.x])
	area.queue_free()
	for c in get_children():
		c.queue_free()
	await physics_frames(2)


## Level 1's only moving platform (A03's GapPlatform, its area far from x 0) still
## crosses its whole gap both ways.
func _test_level_1_gap_platform() -> void:
	Session.new_run()
	var lvl: Node = load("res://scenes/levels/level_01.tscn").instantiate()
	add_child(lvl)
	await physics_frames(3)
	var a03: Node2D = lvl.areas[2]
	check(a03.global_position.x > 1000.0, "setup: Level 1's A03 is far from world x 0 (%.0f)" % a03.global_position.x)
	var plat: Node2D = a03.get_node("Geometry/GapPlatform")
	var lo: float = plat.position.x
	var hi: float = plat.position.x
	for i in int(9.0 * 60.0):
		await physics_frames(1)
		lo = minf(lo, plat.position.x)
		hi = maxf(hi, plat.position.x)
	check(lo <= plat.point_a.x + 0.5 and hi >= plat.point_b.x - 0.5,
			"A03's GapPlatform crosses its whole gap (%.0f..%.0f of %.0f..%.0f)" % [lo, hi, plat.point_a.x, plat.point_b.x])
	lvl.queue_free()
	await physics_frames(2)
