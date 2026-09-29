extends TestCase
## M7 / 07-acceptance-and-playtesting.md T10 ("Optional routes: Lockout Notice
## and separate 20-value cache reachable without new abilities").
##
## test_m3_level.gd's own `_test_optional_branches()` already proves OPT01 and
## OPT02 complete and rejoin the main route (bot.success + level_ended_flag),
## using RouteBot's named-action input only, i.e. "without new abilities" —
## but it never checks that the actual REWARD at the end of each branch was
## collected, only that the branch's own route finishes. A branch that
## silently walked past its own reward (e.g. a moved/mis-tagged pickup) would
## still pass that test. This case reuses the same normal-movement RouteBot
## traversal and adds the missing assertion: after OPT01, the Lockout Notice
## (evidence A01) is actually recorded; after OPT02, the 20-value cache is
## actually collected.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const CACHE_ID := "L01-OPT02-CACHE01"
const CACHE_VALUE := 20


func run() -> void:
	await _run_branch("OPT01")
	await _run_branch("OPT02")


func _run_branch(branch_id: String) -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	level.hero.debug_invulnerable = true

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [branch_id])
	bot.start(level.hero)

	var timeout_s := 160.0
	var max_ticks := int(timeout_s * Engine.physics_ticks_per_second)
	var ticks := 0
	while bot.running and ticks < max_ticks:
		await get_tree().physics_frame
		ticks += 1
	if bot.running:
		bot.failure_message = "test timeout after %.1fs" % timeout_s
		bot.running = false
	var report := bot.get_report()

	check(bot.success, "%s branch (normal movement only, no new abilities) completes and rejoins the main route (failure=%s)" % [branch_id, report.failure])

	if branch_id == "OPT01":
		print("[test_m7_optional_rewards] OPT01: has_evidence(A01)=%s wallet=%d chips_found=%d" % [
				Session.has_evidence("EF01"), Session.get_wallet(), Session.chips_found()])
		check(Session.has_evidence("EF01"),
				"OPT01: the Lockout Notice (evidence A01) is actually recorded after the branch, not just reachable in theory")
	elif branch_id == "OPT02":
		print("[test_m7_optional_rewards] OPT02: is_collected(%s)=%s wallet=%d chips_found=%d" % [
				CACHE_ID, Session.is_collected(CACHE_ID), Session.get_wallet(), Session.chips_found()])
		check(Session.is_collected(CACHE_ID),
				"OPT02: the separate cache (%s) is actually collected after the branch" % CACHE_ID)
		check(Session.chips_found() >= CACHE_VALUE,
				"OPT02: chips_found includes at least the cache's own %d value (got %d)" % [CACHE_VALUE, Session.chips_found()])

	bot.queue_free()
	level.queue_free()
	await physics_frames(2)
