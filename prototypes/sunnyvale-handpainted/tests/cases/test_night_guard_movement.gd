extends TestCase
## Adversarial movement checks for the SE01 Night Guard. A scripted target
## (a bare node in the "hero" group, moved by hand every frame) tries to
## break his walking: backing away across his whole lane, jumping back and
## forth over him, standing on a ledge right above him, hiding across a pit
## and behind a wall, and dancing either side of him at close range. Every
## frame the guard must stay on his floor, out of the walls and inside his
## lane; he must never walk in place (a walk clip with no movement), never
## twitch his facing back and forth, and whenever he can reach the target he
## must actually get there and swing.

const BlockScript := preload("res://scripts/world/block.gd")
const FLOOR_Y := 560.0
const FRAME := 1.0 / 60.0

var _target: Node2D
var _stats: Dictionary


func _block(x: float, y: float, w: float, h: float) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _make_target(x: float, y: float = FLOOR_Y) -> Node2D:
	var t := Node2D.new()
	t.add_to_group("hero")
	add_child(t)
	t.global_position = Vector2(x, y)
	return t


func _make_guard(x: float, lane: Rect2 = Rect2()) -> Brawler:
	var parent: Node = self
	if lane.size != Vector2.ZERO:
		var group := EncounterGroup.new()
		group.lane_rect = lane
		add_child(group)
		parent = group
	var g: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
	parent.add_child(g)
	g.global_position = Vector2(x, FLOOR_Y)
	await physics_frames(2)
	return g


func _reset_stats() -> void:
	_stats = {"frames": 0, "off_floor": 0, "walk_in_place": 0, "run": 0, "flips": 0, "max_flips_per_s": 0,
			"out_of_lane": 0, "windups": 0, "min_gap": INF, "last_facing": 0, "flip_window": [], "prev_x": NAN,
			"floor_y": NAN}


## One frame of bookkeeping on the guard (call after each physics frame).
func _observe(g: Brawler, lane: Rect2 = Rect2()) -> void:
	_stats.frames += 1
	if g.state == Brawler.State.DEFEATED:
		return
	if is_nan(_stats.floor_y):
		_stats.floor_y = g.global_position.y
	if not g.is_on_floor() or absf(g.global_position.y - _stats.floor_y) > 1.5:
		_stats.off_floor += 1
	var moving_clip: bool = g.anim != null and (g.anim.clip == g.tuning.clip_walk or g.anim.clip == g.tuning.clip_stalk)
	# A walk clip on a frame he doesn't move; one frame while a state
	# hands over is fine, a run of them is walking in place.
	if not is_nan(_stats.prev_x) and moving_clip and absf(g.global_position.x - _stats.prev_x) < 0.05:
		_stats.run += 1
		_stats.walk_in_place = maxi(_stats.walk_in_place, _stats.run)
	else:
		_stats.run = 0
	_stats.prev_x = g.global_position.x
	if _stats.last_facing != 0 and g.facing != _stats.last_facing:
		_stats.flips += 1
		_stats.flip_window.append(_stats.frames)
	_stats.last_facing = g.facing
	while not _stats.flip_window.is_empty() and _stats.frames - _stats.flip_window[0] > 60:
		_stats.flip_window.pop_front()
	_stats.max_flips_per_s = maxi(_stats.max_flips_per_s, _stats.flip_window.size())
	if lane.size != Vector2.ZERO and not lane.has_point(g.global_position):
		_stats.out_of_lane += 1
	if g.state == Brawler.State.WINDUP and g._state_timer <= FRAME * 1.5:
		_stats.windups += 1
	_stats.min_gap = minf(_stats.min_gap, absf(g.global_position.x - _target.global_position.x))


func _check_basics(label: String, lane_checked: bool = false) -> void:
	check(_stats.off_floor == 0, "%s: he stays on his floor (%d frames off it)" % [label, _stats.off_floor])
	check(_stats.walk_in_place <= 3, "%s: he never walks in place (longest run %d frames)" % [label, _stats.walk_in_place])
	check(_stats.max_flips_per_s <= 3, "%s: his facing never twitches (%d turns in one second)" % [label, _stats.max_flips_per_s])
	if lane_checked:
		check(_stats.out_of_lane == 0, "%s: he stays inside his lane (%d frames out)" % [label, _stats.out_of_lane])


func run() -> void:
	await _test_chase_across_the_real_lane()
	await _test_jump_back_and_forth_over_him()
	await _test_target_on_a_ledge_above()
	await _test_pit_between()
	await _test_wall_between()
	await _test_dance_either_side()
	await _test_back_and_forth_across_the_lane_edge()
	await _test_two_guards_take_turns()


## The real L01-E01 layout: Dave starts the fight at the approach zone and
## backs off to the very start of the Front Gardens. The guard must follow
## all the way and swing, never stall on the way.
func _test_chase_across_the_real_lane() -> void:
	Session.new_run()
	var area: AreaRoot = load("res://scenes/levels/areas/a02_gardens.tscn").instantiate()
	add_child(area)
	await physics_frames(2)
	var g: Brawler = null
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.get("entity_id") == "L01-E01-SE01-01":
			g = e
	check(g != null, "setup: the real first guard exists")
	if g == null:
		area.queue_free()
		return
	var group: EncounterGroup = g.get_parent()
	var lane := Rect2(group.to_global(group.lane_rect.position), group.lane_rect.size)
	group.is_active = true   # the scripted target has no body to trip the approach zone
	_target = _make_target(area.to_global(Vector2(660, 0)).x, g.global_position.y)
	_reset_stats()
	var t := 0
	var reached := false
	# Back off slowly (like a player shooting as he retreats) to x = 60.
	while t < 60 * 20:
		await physics_frames(1)
		t += 1
		var goal: float = area.to_global(Vector2(60, 0)).x
		if _target.global_position.x > goal:
			_target.global_position.x -= 1.2
		_observe(g, lane)
		if _target.global_position.x <= goal + 0.5 and absf(g.global_position.x - _target.global_position.x) <= g.tuning.engage_range + 2.0:
			reached = true
		if reached and _stats.windups >= 3:
			break
	_check_basics("chase across the lane", true)
	check(reached, "he follows Dave all the way back to the start of the gardens (gap %.0f px)" % absf(g.global_position.x - _target.global_position.x))
	check(_stats.windups >= 2, "he keeps winding up and swinging as Dave backs off (%d windups)" % _stats.windups)
	_target.queue_free()
	area.queue_free()
	await physics_frames(2)


## The target hops over him from side to side (one hop every 0.9 s).
func _test_jump_back_and_forth_over_him() -> void:
	var floor_b := _block(0, FLOOR_Y, 2000, 200)
	var g := await _make_guard(1000.0)
	_target = _make_target(760.0)
	_reset_stats()
	var side := -1
	for hop in 8:
		var from_x: float = _target.global_position.x
		var to_x: float = g.global_position.x - side * 220.0
		for i in 54:
			var k := float(i + 1) / 54.0
			_target.global_position = Vector2(lerpf(from_x, to_x, k), FLOOR_Y - sin(k * PI) * 170.0)
			await physics_frames(1)
			_observe(g)
		side = -side
	_check_basics("hopping over him")
	check(_stats.flips >= 4, "setup: he turned to follow the hops (%d turns)" % _stats.flips)
	_target.queue_free()
	g.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## The target stands on a ledge right above him, then walks along it.
func _test_target_on_a_ledge_above() -> void:
	var floor_b := _block(0, FLOOR_Y, 2000, 200)
	var ledge := _block(700, FLOOR_Y - 180, 500, 16)
	var g := await _make_guard(900.0)
	_target = _make_target(950.0, FLOOR_Y - 180)
	_reset_stats()
	for i in 240:
		_target.global_position.x = 900.0 + sin(float(i) / 12.0) * 6.0   # hovering right over his head
		await physics_frames(1)
		_observe(g)
	for i in 240:
		_target.global_position.x = 900.0 + float(i) * 1.0               # then walking off along the ledge
		await physics_frames(1)
		_observe(g)
	_check_basics("Dave on a ledge above")
	check(_stats.windups == 0, "he never swings at Dave on another floor (%d windups)" % _stats.windups)
	_target.queue_free()
	g.queue_free()
	ledge.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## A pit between them: he walks to its edge and holds, never falls in.
func _test_pit_between() -> void:
	var left := _block(0, FLOOR_Y, 800, 200)
	var right := _block(960, FLOOR_Y, 1000, 200)
	var g := await _make_guard(600.0)
	_target = _make_target(1100.0)
	_reset_stats()
	for i in 360:
		await physics_frames(1)
		_observe(g)
	_check_basics("a pit between them")
	check(g.global_position.x < 800.0 and g.global_position.x > 700.0, "he walks up to the pit's edge and stops there (x %.0f)" % g.global_position.x)
	_target.queue_free()
	g.queue_free()
	left.queue_free()
	right.queue_free()
	await physics_frames(2)


## A wall between them: he walks up to it and holds, never pushes through.
func _test_wall_between() -> void:
	var floor_b := _block(0, FLOOR_Y, 2000, 200)
	var wall := _block(900, FLOOR_Y - 220, 40, 220)
	var g := await _make_guard(700.0)
	_target = _make_target(1100.0)
	_reset_stats()
	for i in 360:
		await physics_frames(1)
		_observe(g)
	_check_basics("a wall between them")
	check(g.global_position.x < 900.0 and g.global_position.x > 820.0, "he walks up to the wall and stops there (x %.0f)" % g.global_position.x)
	_target.queue_free()
	g.queue_free()
	wall.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## The target dances from one side of him to the other at close range.
func _test_dance_either_side() -> void:
	var floor_b := _block(0, FLOOR_Y, 2000, 200)
	var g := await _make_guard(1000.0)
	_target = _make_target(1000.0)
	_reset_stats()
	for i in 480:
		_target.global_position.x = g.global_position.x + (70.0 if (i / 25) % 2 == 0 else -70.0)
		await physics_frames(1)
		_observe(g)
	_check_basics("dancing either side of him")
	check(_stats.windups >= 1, "he still gets his swings off (%d windups)" % _stats.windups)
	_target.queue_free()
	g.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## The target steps in and out across the edge of his lane: he holds at the
## edge while it is out of reach and comes on again when it steps back in.
func _test_back_and_forth_across_the_lane_edge() -> void:
	var floor_b := _block(0, FLOOR_Y, 2000, 200)
	var lane := Rect2(600, FLOOR_Y - 400, 600, 800)
	var g := await _make_guard(900.0, lane)
	var group: EncounterGroup = g.get_parent()
	group.is_active = true
	_target = _make_target(700.0)
	_reset_stats()
	var windups_in := 0
	for leg in 4:
		var x: float = 420.0 if leg % 2 == 0 else 690.0
		for i in 150:
			_target.global_position.x = move_toward(_target.global_position.x, x, 3.0)
			await physics_frames(1)
			_observe(g, lane)
		if leg % 2 == 1:
			windups_in = _stats.windups
	_check_basics("in and out across his lane edge", true)
	check(windups_in >= 1, "he swings whenever Dave steps back into reach (%d windups)" % windups_in)
	_target.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


## Two guards in one encounter with Dave between them, in reach of both: the
## group lets one swing at a time, and the one waiting his turn stands in
## his idle pose rather than running in place (playtest 2026-10-04), then
## gets his own swing.
func _test_two_guards_take_turns() -> void:
	var floor_b := _block(0, FLOOR_Y, 2000, 200)
	var group := EncounterGroup.new()
	group.lane_rect = Rect2(600, FLOOR_Y - 400, 800, 800)
	add_child(group)
	var guards: Array[Brawler] = []
	for x in [900.0, 1060.0]:
		var g: Brawler = load("res://scenes/actors/night_guard.tscn").instantiate()
		group.add_child(g)
		g.global_position = Vector2(x, FLOOR_Y)
		guards.append(g)
	await physics_frames(2)
	group.is_active = true
	_target = _make_target(980.0)
	var prev_x := [guards[0].global_position.x, guards[1].global_position.x]
	var run := [0, 0]
	var longest := [0, 0]
	var windups := [0, 0]
	for i in 600:
		await physics_frames(1)
		for k in 2:
			var g: Brawler = guards[k]
			var moving_clip: bool = g.anim.clip == g.tuning.clip_walk or g.anim.clip == g.tuning.clip_stalk
			if moving_clip and absf(g.global_position.x - prev_x[k]) < 0.05:
				run[k] += 1
				longest[k] = maxi(longest[k], run[k])
			else:
				run[k] = 0
			prev_x[k] = g.global_position.x
			if g.state == Brawler.State.WINDUP and g._state_timer <= FRAME * 1.5:
				windups[k] += 1
	for k in 2:
		check(longest[k] <= 3, "guard %d never runs in place while he waits his turn (longest run %d frames)" % [k + 1, longest[k]])
	check(windups[0] >= 1 and windups[1] >= 1, "both guards get their swings in turn (%d and %d windups)" % [windups[0], windups[1]])
	_target.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
