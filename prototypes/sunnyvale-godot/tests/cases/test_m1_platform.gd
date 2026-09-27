extends TestCase
## M1 T02: safe moving-platform carry — no drift while stationary, no
## launch on stop/reversal, stays aboard through a full cycle.

const BlockScript := preload("res://scripts/world/block.gd")


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.input_enabled = false  # this test only cares about passive riding
	return hero


func run() -> void:
	await _test_no_drift_when_stationary()
	await _test_carried_through_full_cycle_and_reversal()


func _test_no_drift_when_stationary() -> void:
	var plat_scene: PackedScene = load("res://scenes/objects/moving_platform.tscn")
	var plat: Node2D = plat_scene.instantiate()
	plat.point_a = Vector2(200, 260)
	plat.point_b = Vector2(200, 260)  # zero-length: stays put
	plat.speed = 90.0
	plat.pause_time = 0.5
	add_child(plat)  # _ready() reads point_a for the initial `position`
	await physics_frames(2)

	var hero := _make_hero(Vector2(220, 260))
	await physics_frames(3)
	check(hero.is_on_floor(), "hero lands on the stationary platform")
	var start_x := hero.global_position.x
	for i in 90:  # 1.5s
		await physics_frames(1)
	var drift := absf(hero.global_position.x - start_x)
	check(drift < 2.0, "hero standing still on a stationary platform does not drift (drift=%.3f px)" % drift)

	hero.queue_free()
	plat.queue_free()
	await physics_frames(1)


func _test_carried_through_full_cycle_and_reversal() -> void:
	var plat_scene: PackedScene = load("res://scenes/objects/moving_platform.tscn")
	var plat: Node2D = plat_scene.instantiate()
	var a := Vector2(300, 260)
	var b := Vector2(560, 260)
	plat.point_a = a
	plat.point_b = b
	plat.speed = 100.0
	plat.pause_time = 0.3
	add_child(plat)
	await physics_frames(2)

	var hero := _make_hero(Vector2(a.x + 10.0, 260))
	await physics_frames(3)
	check(hero.is_on_floor(), "hero lands on the moving platform")
	var initial_offset := hero.global_position.x - plat.position.x

	# One-way time + pause, run for well over a full back-and-forth cycle
	# (covers at least one reversal at each end).
	var span: float = a.distance_to(b)
	var one_way: float = span / 100.0
	var cycle_ticks: int = int(ceil((one_way + 0.3) * 2.0 * 60.0))
	var max_offset_drift := 0.0
	var ever_off := false
	for i in cycle_ticks + 60:
		await physics_frames(1)
		if not hero.is_on_floor():
			ever_off = true
		var offset := hero.global_position.x - plat.position.x
		max_offset_drift = maxf(max_offset_drift, absf(offset - initial_offset))

	check(not ever_off, "hero never leaves the platform's floor through a full cycle incl. reversal")
	check(max_offset_drift < 6.0,
			"hero's offset relative to the platform stays ~constant through reversal (max drift=%.2f px)" % max_offset_drift)

	hero.queue_free()
	plat.queue_free()
	await physics_frames(1)
