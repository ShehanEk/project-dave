extends TestCase
## Level 2 v2's set pieces S1 and S2 (level-design/l02-alignment.md): the drill
## (scripts/objects/drill_pad.gd + popup_target.gd) and the range going live
## (scripts/objects/cover_plate.gd + range_live.gd). The drill starts when Dave stands on its pad,
## calls its targets on their schedule (amber tell, red for the last 0.25 s, then up), drops a
## target on enough damage (bolts, a Broom blast), pays its hidden tray once on success, resets on
## a time-out and can be run again, and keeps its success through a rebuild and loses it to a
## rollback from before. The plates stop a bolt, a pellet and an enemy round, never stop Dave's
## walk (nor push him), slide between their ends at their speed with a pause at each, and the
## controller starts them, after its amber-then-red lamps, on its trigger.

const HERO_SCENE := "res://scenes/actors/hero.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const PAD_SCENE := "res://scenes/objects/drill_pad.tscn"
const TARGET_SCENE := "res://scenes/objects/popup_target.tscn"
const PLATE_SCENE := "res://scenes/objects/cover_plate.tscn"
const CACHE_SCENE := "res://scenes/objects/chip_cache.tscn"
const BOLT_SCENE := "res://scenes/weapons/scrap_bolt.tscn"
const RangeLive := preload("res://scripts/objects/range_live.gd")
const PopupT := preload("res://scripts/objects/popup_target.gd")
const DrillPadS := preload("res://scripts/objects/drill_pad.gd")
const CoverPlateS := preload("res://scripts/objects/cover_plate.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const W01_TUNING := "res://data/tuning/w01_scrapjack.tres"
const PAD_ID := "L02-A01-PAD01"
const DRILL_ID := "L02-A01-DRILL01"
const TRAY_ID := "L02-A01-CACHE01"
const FLOOR_Y := 560.0
const H := 96.0


func run() -> void:
	await _test_drill_run_and_reward()
	await _test_drill_timeout_and_replay()
	await _test_drill_persistence()
	await _test_plates_block_shots()
	await _test_plates_never_block_dave()
	await _test_plate_motion()
	await _test_range_controller()
	release_all()
	CheckpointService.clear()
	Session.new_run()


# --- helpers ----------------------------------------------------------------------------------

func _floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(-1500, FLOOR_Y)
	b.size = Vector2(4000, 200)
	add_child(b)
	return b


func _hero(pos: Vector2) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = pos
	return hero


func _hud(hero: Hero) -> Hud:
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(2)
	hud.setup(hero)
	return hud


func _toast_text(hud: Hud) -> String:
	var t: Label = hud.get_node("Toast")
	return t.text if t.visible else ""


## A drill bench: a pad at x 0, three targets (a floor dummy at 300, a ceiling dummy at 520, a tall
## floor dummy at 760) and a hidden tray at x -260. Returns {root, pad, targets, tray}.
func _bench(duration: float = 8.0, with_id: bool = true) -> Dictionary:
	var root := Node2D.new()
	root.name = "Bench"
	add_child(root)
	var specs := [
		[Vector2(300, FLOOR_Y), 0, 1.0, 62.0],
		[Vector2(520, FLOOR_Y - 230), 1, 2.0, 80.0],
		[Vector2(760, FLOOR_Y), 0, 3.0, 110.0],
	]
	var targets: Array = []
	var paths: Array[NodePath] = []
	for i in specs.size():
		var s: Array = specs[i]
		var t: Node2D = load(TARGET_SCENE).instantiate()
		t.name = "T%d" % (i + 1)
		t.mount = s[1]
		t.appear_at = s[2]
		t.chest_height = s[3]
		t.position = s[0]
		root.add_child(t)
		targets.append(t)
		paths.append(NodePath("../T%d" % (i + 1)))
	var tray: Area2D = load(CACHE_SCENE).instantiate()
	tray.name = "Tray"
	tray.entity_id = TRAY_ID
	tray.value = 10
	tray.position = Vector2(-260, FLOOR_Y)
	root.add_child(tray)
	var pad: Area2D = load(PAD_SCENE).instantiate()
	pad.name = "Pad"
	pad.entity_id = DRILL_ID if with_id else ""
	pad.duration = duration
	pad.targets = paths
	pad.reward = NodePath("../Tray")
	pad.position = Vector2(0, FLOOR_Y)
	root.add_child(pad)
	return {"root": root, "pad": pad, "targets": targets, "tray": tray}


func _tray_hidden(tray: Area2D) -> bool:
	var cs: CollisionShape2D = tray.get_node("CollisionShape2D")
	return not tray.visible and cs.disabled


## Waits until the pad's run clock reaches `t` (or `limit` seconds pass).
func _until_elapsed(pad: Node, t: float, limit: float = 20.0) -> void:
	var frames := 0
	while pad.elapsed < t and frames < int(limit * 60.0):
		await physics_frames(1)
		frames += 1


func _bolt(from: Vector2, dir: Vector2) -> Node2D:
	var b: Node2D = load(BOLT_SCENE).instantiate()
	add_child(b)
	b.setup(from, dir, load(W01_TUNING))
	return b


## Flies a bolt until it resolves; returns where it was last seen.
func _fly_bolt(from: Vector2, dir: Vector2) -> Vector2:
	var b := _bolt(from, dir)
	var last := from
	for i in 90:
		if not is_instance_valid(b) or b.is_queued_for_deletion():
			break
		last = b.global_position
		await physics_frames(1)
	return last


## Drops `t` with real bolts from 120 px to its left, aimed at its chest.
func _shoot_down_with_bolts(t: Node2D) -> int:
	var shots := 0
	while not t.is_down() and shots < 6:
		var chest: Vector2 = t.to_global(t.chest_local())
		await _fly_bolt(chest + Vector2(-120, 0), Vector2.RIGHT)
		shots += 1
		await physics_frames(1)
	return shots


# --- 1. the drill: start, schedule, success and its reward, once ----------------------------------

func _test_drill_run_and_reward() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var floor_b := _floor()
	var hero := _hero(Vector2(-500, FLOOR_Y - 1.0))
	var hud := await _hud(hero)
	var b := _bench(8.0)
	var pad: Area2D = b["pad"]
	var targets: Array = b["targets"]
	var tray: Area2D = b["tray"]
	await physics_frames(3)
	check(not pad.is_running() and not pad.is_done(), "the drill waits, ready, while Dave is off its pad")
	check(_tray_hidden(tray), "its chip tray is hidden (invisible, its shape off) before success")
	for t in targets:
		check(t.state == PopupT.State.HIDDEN and not t.is_up(), "%s waits in its hatch" % t.name)
		check_eq(t.hit_zone.collision_layer, 0, "%s cannot be hit while hidden" % t.name)

	hero.global_position = Vector2(0, FLOOR_Y - 1.0)
	await physics_frames(3)
	check(pad.is_running(), "standing on the pad starts the run")
	check_eq(_toast_text(hud), "Drill 0/3", "...and the HUD toast says Drill 0/3")
	hero.global_position = Vector2(-500, FLOOR_Y - 1.0)

	# The schedule: T1 (appear_at 1.0) tells from 0.4, red from 0.75, rises at 1.0.
	var t1: Node2D = targets[0]
	var t2: Node2D = targets[1]
	await _until_elapsed(pad, 0.5)
	check_eq(t1.state, PopupT.State.TELL, "T1's tell starts tell_time (0.6 s) before its appear_at")
	check_eq(t1.lamp_color(), PopupT.AMBER, "...its hatch lamp is amber")
	check_eq(t2.state, PopupT.State.HIDDEN, "...while T2 (appear_at 2.0) still waits")
	await _until_elapsed(pad, 0.85)
	check_eq(t1.lamp_color(), PopupT.RED, "T1's lamp is red for the tell's last 0.25 s")
	await _until_elapsed(pad, 1.0 + t1.rise_time + 0.05)
	check(t1.is_up() and t1.state == PopupT.State.UP, "T1 is up once its rise is over")
	check_eq(t1.hit_zone.collision_layer, 1 << 4, "...and hittable (layer 5)")
	var chest: Vector2 = t1.to_global(t1.chest_local())
	check(absf(chest.y - (FLOOR_Y - 62.0)) < 0.5, "T1's chest stands at its chest_height above the floor")

	# Three bolts drop it (toughness 3); the first two only mark it.
	var shots := await _shoot_down_with_bolts(t1)
	check_eq(shots, 3, "three bolts drop a dummy (toughness 3)")
	check(t1.is_down(), "...it goes down")
	check_eq(_toast_text(hud), "Drill 1/3", "...and the toast counts it: Drill 1/3")

	# The ceiling dummy drops from its rail: a Broom blast from close range downs it in one.
	await _until_elapsed(pad, 2.0 + t2.rise_time + 0.05)
	check(t2.is_up(), "T2 has dropped from its rail housing")
	var t2_chest: Vector2 = t2.to_global(t2.chest_local())
	check(t2_chest.y > t2.global_position.y + 70.0, "...its chest hangs below the rail (chest_height 80)")
	Session.swap_weapon(PAD_ID)
	await physics_frames(3)
	hero.global_position = Vector2(t2.global_position.x - 140.0, FLOOR_Y - 1.0)
	await physics_frames(3)
	hero.use_aim_override = true
	hero.aim_override = t2_chest
	await physics_frames(2)
	var gun = hero.held_weapon()
	check(gun is BoomBroom and gun.try_blast(), "setup: the Boom Broom blasts")
	await physics_frames(2)
	check(t2.is_down(), "one close Boom Broom blast drops a dummy")
	hero.use_aim_override = false
	hero.global_position = Vector2(-500, FLOOR_Y - 1.0)

	# The tall one (chest 110), then success.
	var t3: Node2D = targets[2]
	await _until_elapsed(pad, 3.0 + t3.rise_time + 0.05)
	check(t3.is_up(), "T3 is up")
	check(absf(t3.to_global(t3.chest_local()).y - (FLOOR_Y - 110.0)) < 0.5, "...on its telescoped pole (chest 110)")
	var wallet := Session.get_wallet()
	await _shoot_down_with_bolts(t3)
	await physics_frames(2)
	check(pad.is_done(), "every target down before time: the drill succeeds")
	check(Session.is_collected(DRILL_ID), "...recorded with Session.collect(entity_id, 0)")
	check_eq(Session.get_wallet(), wallet, "...the record itself pays nothing")
	check(tray.visible and not (tray.get_node("CollisionShape2D") as CollisionShape2D).disabled, "...and the tray is revealed")
	check(_toast_text(hud).begins_with("Drill complete"), "...with a HUD toast (%s)" % _toast_text(hud))
	tray.interact(hero)
	check_eq(Session.get_wallet(), wallet + 10, "the tray pays its 10 chips")
	tray.interact(hero)
	check_eq(Session.get_wallet(), wallet + 10, "...once")

	# Done stays done: standing on the pad again starts nothing.
	check(not pad.start_run(), "a done drill never starts again")
	hero.global_position = Vector2(0, FLOOR_Y - 1.0)
	await physics_frames(5)
	check(pad.is_done() and not pad.is_running(), "...not even with Dave standing on it")
	for t in targets:
		check(t.is_down(), "%s stays down" % t.name)
	hud.queue_free()
	hero.queue_free()
	(b["root"] as Node).queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 2. a time-out resets the drill; it can be run again ---------------------------------------------

func _test_drill_timeout_and_replay() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var floor_b := _floor()
	var hero := _hero(Vector2(0, FLOOR_Y - 1.0))
	var hud := await _hud(hero)
	var b := _bench(4.5)
	var pad: Area2D = b["pad"]
	var targets: Array = b["targets"]
	await physics_frames(3)
	check(pad.is_running(), "setup: a 4.5 s run has started")
	hero.global_position = Vector2(-500, FLOOR_Y - 1.0)
	await _until_elapsed(pad, 1.5)
	await _shoot_down_with_bolts(targets[0])
	await _until_elapsed(pad, 4.1)
	check(targets[1].is_up() and targets[2].is_up(), "setup: two targets left up near the end")
	check_eq(pad.bar_color(), DrillPadS.AMBER, "the time bar is amber in the run's last seconds")
	await _until_elapsed(pad, 4.3)
	check_eq(pad.bar_color(), DrillPadS.RED, "...and red for its last 0.25 s")
	await seconds(0.3)
	check(not pad.is_running() and not pad.is_done(), "the time runs out: no success")
	check(targets[1].state == PopupT.State.LOWERING or targets[1].state == PopupT.State.HIDDEN,
			"the targets still up go back into their hatches")
	check(_toast_text(hud).begins_with("Time. Drill 1/3"), "the toast gives the score and says to go again (%s)" % _toast_text(hud))
	check(not Session.is_collected(DRILL_ID), "a time-out records nothing")
	check(_tray_hidden(b["tray"]), "...and the tray stays hidden (no penalty, no reward)")
	await seconds(0.5)
	for t in [targets[1], targets[2]]:
		check_eq(t.state, PopupT.State.HIDDEN, "%s is back in its hatch" % t.name)

	# Replay: step back on after the rearm.
	await seconds(pad.rearm_time)
	hero.global_position = Vector2(0, FLOOR_Y - 1.0)
	await physics_frames(3)
	check(pad.is_running() and pad.elapsed < 0.2, "stepping on the pad again starts a fresh run")
	for t in targets:
		check(t.state == PopupT.State.HIDDEN and t.damage_taken == 0, "%s is whole and hidden again" % t.name)
	hero.global_position = Vector2(-500, FLOOR_Y - 1.0)
	for t in targets:
		await _until_elapsed(pad, float(t.appear_at) + t.rise_time + 0.05)
		await _shoot_down_with_bolts(t)
	await physics_frames(2)
	check(pad.is_done() and Session.is_collected(DRILL_ID), "the second run, all down in time, succeeds")
	hud.queue_free()
	hero.queue_free()
	(b["root"] as Node).queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 3. persistence and rollback -------------------------------------------------------------------

func _succeed_now(b: Dictionary) -> void:
	var pad: Area2D = b["pad"]
	pad.start_run()
	for t in b["targets"]:
		t.raise_target()
	await seconds(0.5)
	for t in b["targets"]:
		t.hit_zone.take_hit(5, t.global_position, Vector2.RIGHT)
	await physics_frames(2)


func _test_drill_persistence() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	check(Session.commit("CP00"), "setup: a checkpoint before the drill")
	var floor_b := _floor()
	var hero := _hero(Vector2(-900, FLOOR_Y - 1.0))
	var b := _bench()
	await physics_frames(3)
	await _succeed_now(b)
	check(Session.is_collected(DRILL_ID), "setup: the drill succeeded after the checkpoint")
	var v: Dictionary = CheckpointService.validate_snapshot(JSON.parse_string(JSON.stringify(Session.state)))
	check(v.get("ok", false), "a Level 2 save holding the drill's record validates (%s)" % str(v.get("error", "")))

	# A death rolls the success back: the rebuilt drill is ready and its tray hidden again.
	Session.restore_committed()
	(b["root"] as Node).free()
	b = _bench()
	await physics_frames(3)
	check(not Session.is_collected(DRILL_ID), "a rollback from before the success forgets it")
	check(not b["pad"].is_done() and not b["pad"].is_running(), "...the rebuilt drill is ready to run")
	check(_tray_hidden(b["tray"]), "...and its tray is hidden again")

	# Success, saved: a rebuild shows it done, the targets down and the tray open.
	await _succeed_now(b)
	b["tray"].interact(hero)
	var wallet := Session.get_wallet()
	check(Session.commit("CP00"), "setup: the success and the looted tray are saved")
	Session.restore_committed()
	(b["root"] as Node).free()
	b = _bench()
	await physics_frames(3)
	check(b["pad"].is_done(), "after a rebuild a saved success shows the drill done")
	for t in b["targets"]:
		check(t.is_down() and not t.is_up(), "%s stays down" % t.name)
	check(b["tray"].visible and not _tray_hidden(b["tray"]), "...the tray is revealed")
	b["tray"].interact(hero)
	check_eq(Session.get_wallet(), wallet, "...and, already looted, pays nothing again")
	check(not b["pad"].start_run(), "...and the drill cannot be run again")
	hero.queue_free()
	(b["root"] as Node).queue_free()
	floor_b.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


# --- 4. the plates stop a bolt, a pellet and an enemy round ---------------------------------------

func _plate(x: float, a: float = 0.0, b: float = 0.0) -> Node2D:
	var p: Node2D = load(PLATE_SCENE).instantiate()
	p.point_a = Vector2(x + a, FLOOR_Y)
	p.point_b = Vector2(x + b, FLOOR_Y)
	add_child(p)
	return p


func _test_plates_block_shots() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	var plate := _plate(400.0)
	var dummy: Node2D = load("res://scenes/objects/practice_target.tscn").instantiate()
	dummy.position = Vector2(600, FLOOR_Y - 30)
	add_child(dummy)
	var dummy_hits := [0]
	dummy.hit_zone.hit.connect(func(_d, _p, _dir): dummy_hits[0] += 1)
	await physics_frames(3)
	var r: Rect2 = plate.plate_rect()
	check(absf(r.size.y - 0.6 * H) < 1.0 and absf(r.end.y - FLOOR_Y) < 0.5, "a plate is 0.6 H tall and reaches the floor line")
	check_eq(plate.plate.collision_layer, (1 << 4) | 1, "its plate is on layers 5 (hittable) and 1 (world)")

	# A bolt at 0.3 H: stopped at the plate's near face; the dummy behind is untouched.
	var at := await _fly_bolt(Vector2(150, FLOOR_Y - 30), Vector2.RIGHT)
	check(at.x <= r.position.x + 2.0 and at.x > r.position.x - 24.0, "a bolt stops on the plate (x %.0f, face %.0f)" % [at.x, r.position.x])
	check_eq(dummy_hits[0], 0, "...and never reaches the dummy behind it")
	# Control: a bolt over the plate (at 0.78 H) flies on.
	at = await _fly_bolt(Vector2(150, FLOOR_Y - 75), Vector2.RIGHT)
	check(at.x > r.end.x + 20.0, "a bolt above the plate's top flies over it (Dave shoots over low cover)")

	# A Boom Broom blast aimed down into it: the plate takes the pellets and answers "blocked".
	Session.swap_weapon(PAD_ID)
	var hero := _hero(Vector2(250, FLOOR_Y - 1.0))
	await physics_frames(4)
	hero.use_aim_override = true
	hero.aim_override = Vector2(400, FLOOR_Y - 20)
	await physics_frames(2)
	var gun = hero.held_weapon()
	check(gun is BoomBroom and gun.try_blast(), "setup: a blast into the plate")
	var report: Dictionary = gun.last_blast.get("targets", {})
	check(report.has(plate.plate), "the blast's pellets meet the plate")
	if report.has(plate.plate):
		check_eq(report[plate.plate]["outcome"], &"blocked", "...which blocks them")
		check(int(report[plate.plate]["pellets"]) >= 1, "...(%d pellets stopped)" % int(report[plate.plate]["pellets"]))
	for p in gun.last_blast.get("paths", []):
		var end: Vector2 = p[1]
		if bool(p[2]) and end.y > r.position.y + 1.0:
			check(end.x <= r.position.x + 2.0, "a pellet low enough to meet the plate ends on its face (x %.0f)" % end.x)
	check_eq(dummy_hits[0], 0, "...and none reaches the dummy behind it")
	hero.use_aim_override = false

	# An enemy round, flat at 0.5 H from the right: blocked on the plate's far face, Dave unhurt.
	hero.debug_invulnerable = false
	var health: int = int(Session.state["health"])
	var outcome := [&"", Vector2.ZERO]
	var round := EnemyRound.new()
	add_child(round)
	round.setup(Vector2(800, FLOOR_Y - 48), Vector2.LEFT, 864.0, 624.0)
	round.resolved.connect(func(o, p):
		outcome[0] = o
		outcome[1] = p)
	await physics_frames(40)
	check_eq(outcome[0], &"blocked", "an enemy round at 0.5 H is blocked by the plate")
	check(absf((outcome[1] as Vector2).x - r.end.x) < 16.0, "...on its face (x %.0f, face %.0f)" % [(outcome[1] as Vector2).x, r.end.x])
	check_eq(Session.state["health"], health, "...and Dave behind it is unhurt")
	# Control: with the plate slid away the same round reaches Dave.
	plate.position = Vector2(1400, FLOOR_Y)
	plate.point_a = plate.position
	plate.point_b = plate.position
	await physics_frames(2)
	outcome = [&"", Vector2.ZERO]
	var round2 := EnemyRound.new()
	add_child(round2)
	round2.setup(Vector2(800, FLOOR_Y - 48), Vector2.LEFT, 864.0, 624.0)
	round2.resolved.connect(func(o, p):
		outcome[0] = o
		outcome[1] = p)
	await physics_frames(40)
	check_eq(outcome[0], &"hit", "control: without the plate the round hits Dave")
	hero.queue_free()
	plate.queue_free()
	dummy.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 5. a plate never stops, pushes or traps Dave -------------------------------------------------

func _test_plates_never_block_dave() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	var plate := _plate(400.0)
	var hero := _hero(Vector2(250, FLOOR_Y - 1.0))
	await physics_frames(6)
	await hold(&"move_right", 0.8)
	await physics_frames(2)
	check(hero.global_position.x > plate.plate_rect().end.x + 20.0, "Dave walks straight through a plate (x %.0f)" % hero.global_position.x)
	await hold(&"move_left", 0.8)
	check(hero.global_position.x < plate.plate_rect().position.x - 20.0, "...both ways (x %.0f)" % hero.global_position.x)

	# A moving plate slides through a standing Dave without moving him.
	var stand_x := 600.0
	hero.global_position = Vector2(stand_x, FLOOR_Y - 1.0)
	plate.queue_free()
	var moving := _plate(stand_x, -120.0, 120.0)
	moving.speed = 150.0
	moving.pause_time = 0.2
	moving.start()
	await physics_frames(10)
	var x0 := hero.global_position.x
	var crossed := false
	for i in 150:
		await physics_frames(1)
		if moving.plate_rect().has_point(hero.global_position + Vector2(0, -20)):
			crossed = true
	check(crossed, "setup: the plate slid across where Dave stands")
	check(absf(hero.global_position.x - x0) < 0.5, "...and never moved him (x %.1f -> %.1f)" % [x0, hero.global_position.x])
	check(hero.is_on_floor(), "...nor lifted him off the floor")
	hero.queue_free()
	moving.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 6. it slides between its ends at its speed, pausing at each --------------------------------------

func _test_plate_motion() -> void:
	var plate := _plate(0.0, 0.0, 320.0)
	plate.speed = 64.0
	plate.pause_time = 0.5
	await physics_frames(2)
	check(not plate.running and absf(plate.position.x) < 0.01, "a plate waits at point_a until started")
	await seconds(0.5)
	check(absf(plate.position.x) < 0.01, "...and does not move on its own")
	plate.start()
	await seconds(1.0)
	check(absf(plate.position.x - 64.0) < 3.0, "started, it slides at its speed (64 px/s: x %.1f after 1 s)" % plate.position.x)
	var lo := INF
	var hi := -INF
	var paused_at_b := 0
	for i in 60 * 13:
		await physics_frames(1)
		lo = minf(lo, plate.position.x)
		hi = maxf(hi, plate.position.x)
		if absf(plate.position.x - 320.0) < 0.01:
			paused_at_b += 1
	check(lo >= -0.01 and hi <= 320.01, "it stays within its ends (%.1f..%.1f)" % [lo, hi])
	check(hi > 319.0 and lo < 1.0, "...reaching both")
	check(paused_at_b >= int(0.5 * 60.0) - 1, "...and holds at an end for its pause (%d frames)" % paused_at_b)
	plate.speed = 1000.0
	check_eq(plate.effective_speed(), CoverPlateS.MAX_SPEED, "its speed is capped below Dave's run (MAX_SPEED)")
	check(CoverPlateS.MAX_SPEED < 4.0 * H, "...which is under Dave's 4 H/s")
	plate.queue_free()
	await physics_frames(2)


# --- 7. the controller starts them on its trigger ---------------------------------------------------

func _test_range_controller() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	var hero := _hero(Vector2(-400, FLOOR_Y - 1.0))
	var enemies_before := get_tree().get_nodes_in_group("enemy").size()
	var root := Node2D.new()
	add_child(root)
	var p1: Node2D = load(PLATE_SCENE).instantiate()
	p1.name = "P1"
	p1.point_a = Vector2(400, FLOOR_Y)
	p1.point_b = Vector2(640, FLOOR_Y)
	root.add_child(p1)
	var p2: Node2D = load(PLATE_SCENE).instantiate()
	p2.name = "P2"
	p2.point_a = Vector2(800, FLOOR_Y)
	p2.point_b = Vector2(1000, FLOOR_Y)
	p2.start_progress = 1.0
	p2.start_dir = -1
	root.add_child(p2)
	var ctl := Node2D.new()
	ctl.set_script(RangeLive)
	ctl.name = "Range"
	ctl.position = Vector2(200, FLOOR_Y)
	ctl.plates = Array([NodePath("../P1"), NodePath("../P2")], TYPE_NODE_PATH, &"", null)
	ctl.lamp_points = PackedVector2Array([Vector2(200, -320), Vector2(600, -320)])
	ctl.beat_id = "L02-A02-B04"
	root.add_child(ctl)
	var beats: Array = []
	var on_beat := func(id: String, _area: String): beats.append(id)
	BeatHub.get_instance().beat_entered.connect(on_beat)
	await physics_frames(4)
	check(not ctl.is_live() and not p1.running and not p2.running, "the range is cold, its carriers idle, before the trigger")
	check_eq(ctl.lamp_color(), RangeLive.COLD, "...its lane lamps cold white")
	check(absf(p2.position.x - 1000.0) < 0.01, "a plate can start at its far end (start_progress 1)")

	hero.global_position = Vector2(200, FLOOR_Y - 1.0)
	await physics_frames(3)
	check_eq(ctl.state, RangeLive.State.WARN, "Dave entering its approach area sets it off")
	check_eq(ctl.lamp_color(), RangeLive.AMBER, "...the lane lamps go amber")
	check(not p1.running, "...the carriers wait through the warning")
	check_eq(beats, ["L02-A02-B04"], "...and it reports its beat (Adam's line) through BeatHub once")
	await seconds(ctl.warn_time - 0.15)
	check_eq(ctl.lamp_color(), RangeLive.RED, "the lamps are red for the warning's last 0.25 s")
	await seconds(0.25)
	check(ctl.is_live() and p1.running and p2.running, "then the range is live and both carriers run")
	check_eq(ctl.lamp_color(), RangeLive.AMBER, "...the lamps hold a steady amber")
	var x1 := p1.position.x
	var x2 := p2.position.x
	await seconds(0.5)
	check(p1.position.x > x1 and p2.position.x < x2, "...and the plates slide (one each way)")
	check_eq(get_tree().get_nodes_in_group("enemy").size(), enemies_before, "it spawns no enemy")
	hero.global_position = Vector2(-400, FLOOR_Y - 1.0)
	await physics_frames(3)
	hero.global_position = Vector2(200, FLOOR_Y - 1.0)
	await physics_frames(3)
	check_eq(beats.size(), 1, "it goes live once")

	# A trigger_node's `activated` (an EncounterGroup's moment) also sets it off.
	var group := EncounterGroup.new()
	group.name = "Group"
	group.wait_for_trigger = true
	root.add_child(group)
	var ctl2 := Node2D.new()
	ctl2.set_script(RangeLive)
	ctl2.position = Vector2(3000, FLOOR_Y)
	ctl2.trigger_size = Vector2.ZERO
	ctl2.trigger_node = NodePath("../Group")
	root.add_child(ctl2)
	await physics_frames(2)
	check(not ctl2.is_live() and ctl2.state == RangeLive.State.COLD, "a controller without an approach area waits for its trigger node")
	group.activated.emit()
	await physics_frames(1)
	check_eq(ctl2.state, RangeLive.State.WARN, "...whose `activated` sets it off")
	BeatHub.get_instance().beat_entered.disconnect(on_beat)
	hero.queue_free()
	root.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
