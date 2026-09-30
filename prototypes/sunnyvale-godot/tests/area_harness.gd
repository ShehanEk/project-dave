extends RefCounted
## Debug/test harness that instances ONE area scene alone at the origin with
## a Hero, a GameCamera and a RouteBot, drives the bot to completion (or
## failure/timeout), then frees everything it created. No class_name (per
## CONVENTIONS.md) — load by path:
##
##   var harness := load("res://tests/area_harness.gd").new()
##   var result: Dictionary = await harness.run_area(
##       self, "res://scenes/debug/sample_area.tscn", [], 30.0)
##   check(result.reached_exit, "sample area main route reaches the exit")
##
## `test_case` is the calling TestCase (a Node already in the tree); the area
## is instanced as its child so `await` on the tree's physics_frame works.
## `branches` enables optional RoutePoint branches (e.g. ["OPT01"]).
## Returns a Dictionary: {reached_exit, seconds, failure, hero_final_position,
## area_times, beat_times, point_index_reached, points_total}. The area/hero/
## camera/bot are all freed before this returns (their state is gone) —
## assert on persistent-state contracts through Session instead (it outlives
## the freed scene, per CONVENTIONS.md's "world objects decide their own
## presence in _ready() from Session").

const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"

const EXIT_MARGIN_X := 64.0
const EXIT_MARGIN_Y := 48.0


func run_area(test_case: Node, area_scene_path: String, branches: Array = [], timeout_s: float = 30.0) -> Dictionary:
	var area_scene: PackedScene = load(area_scene_path)
	var area: AreaRoot = area_scene.instantiate()
	test_case.add_child(area)

	var hero: Hero = load(HERO_SCENE).instantiate()
	var spawn := area.get_marker("Spawn_CP00")
	var spawn_pos: Vector2 = spawn.global_position if spawn else Vector2(96.0, -4.0)
	hero.global_position = spawn_pos
	hero.debug_invulnerable = true
	test_case.add_child(hero)

	var camera: GameCamera = load(CAMERA_SCENE).instantiate()
	camera.target = hero
	test_case.add_child(camera)
	camera.world_limits = area.get_camera_limits()

	# Let every _ready() (area containers, world-object Session reads, group
	# membership) actually run before the bot starts driving input.
	for i in 2:
		await test_case.get_tree().physics_frame

	var bot := RouteBot.new()
	test_case.add_child(bot)
	bot.build_points(area, branches)
	bot.start(hero)

	var max_ticks: int = int(timeout_s * Engine.physics_ticks_per_second)
	var ticks := 0
	while bot.running and ticks < max_ticks:
		await test_case.get_tree().physics_frame
		ticks += 1
		if OS.is_stdout_verbose() and ticks % 30 == 0:
			print("[harness debug] t=%.2f idx=%d state=%s hero=%.1f" % [ticks / 60.0, bot._index, bot._state, hero.global_position.x])
	if bot.running:
		bot.failure_message = "harness timeout after %.1fs" % timeout_s
		bot.running = false

	var local_final: Vector2 = area.to_local(hero.global_position)
	var reached_exit: bool = (hero.global_position.x >= area.global_position.x + area.width - EXIT_MARGIN_X
			and absf(local_final.y) <= EXIT_MARGIN_Y)

	var report: Dictionary = bot.get_report()
	var result := {
		"reached_exit": reached_exit,
		"seconds": report["seconds"],
		"failure": report["failure"],
		"hero_final_position": hero.global_position,
		"area_times": report["area_times"],
		"beat_times": report["beat_times"],
		"point_index_reached": report["point_index_reached"],
		"points_total": report["points_total"],
	}

	bot.queue_free()
	camera.queue_free()
	hero.queue_free()
	area.queue_free()
	for i in 2:
		await test_case.get_tree().physics_frame

	return result
