extends TestCase
## M1 calibration measurements (not pass/fail level design, just numbers the
## level layout should respect): apex height, max horizontal gap clearable
## at equal height on a full-hold running jump, and max vertical rise
## reachable ahead while moving forward. Printed for 09-progress-and-handoff.

const BlockScript := preload("res://scripts/world/block.gd")
const START_Y := 560.0
const RUN_UP := 220.0  # distance before the edge to reach full run speed


func _make_floor(x: float, y: float, w: float, h: float = 200.0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	return hero


func run() -> void:
	await _measure_apex()
	await _measure_max_gap()
	await _measure_max_rise()


func _measure_apex() -> void:
	var floor_b := _make_floor(0, START_Y, 2000)
	var hero := _make_hero(Vector2(100, START_Y))
	await physics_frames(3)
	hero.global_position = Vector2(100, START_Y)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	var start_y := hero.global_position.y
	var max_h := 0.0
	press("jump")
	for i in 30:
		await physics_frames(1)
		max_h = maxf(max_h, start_y - hero.global_position.y)
	release("jump")
	await physics_frames(20)
	max_h = maxf(max_h, start_y - hero.global_position.y)

	print("MEASUREMENT apex_height_px=%.2f (analytic=%.2f, H=%.0f)" % [max_h, hero.tuning.jump_apex_h * hero.tuning.height_px, hero.tuning.height_px])
	check(max_h > 0.0, "apex height measured")

	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


## Runs the hero at a gap of the given width (equal-height landing) and
## reports whether it clears (lands on the far floor without ever falling
## more than a small margin below the start height).
func _try_gap(width: float) -> bool:
	var near := _make_floor(0.0, START_Y, RUN_UP + 40.0)
	var far := _make_floor(RUN_UP + 40.0 + width, START_Y, 400.0)
	var hero := _make_hero(Vector2(40.0, START_Y))
	await physics_frames(3)
	hero.global_position = Vector2(40.0, START_Y)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	press("move_right")
	var cleared := false
	var fell := false
	var jumped := false
	for i in 360:  # up to 6s of sim time
		await physics_frames(1)
		var edge_x: float = RUN_UP + 40.0
		if not jumped and hero.global_position.x >= edge_x - 4.0:
			press("jump")
			jumped = true
			# Held (never released) so the arc is never jump-cut — a full-hold
			# jump, matching the "full-hold apex" tuning used elsewhere.
		if hero.global_position.y > START_Y + 40.0:
			fell = true
			break
		if hero.is_on_floor() and hero.global_position.x > edge_x + width * 0.5:
			cleared = true
			break
	release("move_right")
	release("jump")

	hero.queue_free()
	near.queue_free()
	far.queue_free()
	await physics_frames(2)
	return cleared and not fell


func _measure_max_gap() -> void:
	# Coarse-to-fine linear search: step by 16px until a failure, then the
	# max clearable width is the last success.
	var width := 32.0
	var last_ok := 0.0
	while width <= 400.0:
		var ok: bool = await _try_gap(width)
		if ok:
			last_ok = width
			width += 16.0
		else:
			break
	print("MEASUREMENT max_gap_clearable_equal_height_px=%.1f (%.2fH)" % [last_ok, last_ok / 96.0])
	check(last_ok > 0.0, "max clearable gap measured")


## Places a raised ledge close ahead and finds the tallest one the hero can
## land on top of via a full-hold running jump.
func _try_rise(height: float) -> bool:
	# Ledge starts exactly where the run-up floor ends (contiguous, like the
	# course's steps) so this measures pure vertical rise while moving
	# forward, not a combined gap+rise. The takeoff point is placed far
	# enough back that a full-hold jump has actually risen `height` by the
	# time the hero reaches the ledge's face (otherwise it just bonks into
	# the wall below the ledge top, which is a real and correct outcome for
	# a step taken with too little run-up, not a measurement of reachability).
	var tuning: HeroTuning = load("res://data/tuning/hero.tres")
	var g: float = tuning.gravity()
	var v0: float = tuning.jump_velocity()
	var disc: float = v0 * v0 - 2.0 * g * height
	if disc < 0.0:
		return false  # unreachable at all: above the vertical apex
	var t_reach: float = (v0 - sqrt(disc)) / g  # time rising through `height`
	var lead_distance: float = tuning.run_speed * t_reach + 24.0  # margin

	var ledge_x: float = maxf(260.0, lead_distance + 40.0)
	var near := _make_floor(0.0, START_Y, ledge_x)
	var ledge_w := 300.0
	var ledge := _make_floor(ledge_x, START_Y - height, ledge_w)
	var hero := _make_hero(Vector2(40.0, START_Y))
	await physics_frames(3)
	hero.global_position = Vector2(40.0, START_Y)
	hero.velocity = Vector2.ZERO
	await physics_frames(1)

	var jump_x: float = ledge_x - lead_distance
	press("move_right")
	var landed_on_ledge := false
	# 0 = running toward takeoff, 1 = jumped but hasn't left the floor yet
	# (is_on_floor() is still true for one more tick right after the press),
	# 2 = confirmed airborne — only NOW does a floor contact count as landing.
	var phase := 0
	for i in 300:
		await physics_frames(1)
		if phase == 0 and hero.global_position.x >= jump_x:
			press("jump")
			phase = 1
		elif phase == 1 and not hero.is_on_floor():
			phase = 2
		elif phase == 2 and hero.is_on_floor():
			var top_y := hero.global_position.y
			if top_y <= START_Y - height + 2.0 and hero.global_position.x >= ledge_x:
				landed_on_ledge = true
			break
	release("move_right")
	release("jump")

	hero.queue_free()
	near.queue_free()
	ledge.queue_free()
	await physics_frames(2)
	return landed_on_ledge


func _measure_max_rise() -> void:
	var height := 32.0
	var last_ok := 0.0
	while height <= 200.0:
		var ok: bool = await _try_rise(height)
		if ok:
			last_ok = height
			height += 16.0
		else:
			break
	print("MEASUREMENT max_rise_reachable_px=%.1f (%.2fH)" % [last_ok, last_ok / 96.0])
	check(last_ok > 0.0, "max reachable rise measured")
