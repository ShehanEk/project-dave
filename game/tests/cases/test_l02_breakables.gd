extends TestCase
## Level 2's breakables and secret walls (l02-alignment.md "Things break";
## scripts/objects/breakable.gd): a prop Dave's bolts and Boom Broom pellets break through the
## HitZone every target has. Contracts under test:
##   1. Hit points per kind (glass 2, monitor 2, server cabinet 4, crate 3, gauge 1, vent panel
##      2, display case 3): one damage point a bolt, it stands until the last, a broken one's
##      zone refuses further hits, the signals fire once each; glass (and every kind but the
##      gauge) shows a cracked stage before it breaks; `health` and `size` override the
##      defaults and one big hit breaks it.
##   2. Real shots: a Scrapjack bolt (spawned, and fired by Dave), and one Boom Broom blast
##      at close range breaking a cabinet while a far one only cracks it.
##   3. The secret wall: an intact `solid` breakable stops Dave and takes every shot (from
##      either side, at any height) instead of just blocking it, and once broken Dave and
##      shots go through; a non-solid one never blocks.
##   4. Enemy rounds never break anything (they pass a prop and stop on a solid wall).
##   5. Contents stay hidden and inactive until it breaks, then appear and can be collected.
##   6. Persistence: the break is recorded under its id, rolls back with a death before a
##      checkpoint, survives one after it, a save holding it validates, a rebuilt level starts
##      it broken without debris and never doubles a reward.
##   7. Motion: a hit flash at most every 0.5 s, a screen's break flicker is one flash and one
##      echo (two peaks, 0.55 s apart; one soft dip under Reduced motion), the debris cleans
##      itself up, and every sound is an existing cue.

const HERO_SCENE := "res://scenes/actors/hero.tscn"
const BREAKABLE_SCENE := "res://scenes/objects/breakable.tscn"
const CHIP_SCENE := "res://scenes/objects/chip.tscn"
const CARTRIDGE_SCENE := "res://scenes/objects/ammo_cartridge.tscn"
const BOLT_SCENE := "res://scenes/weapons/scrap_bolt.tscn"
const ROUND_SCENE := "res://scenes/weapons/pistol_round.tscn"
const BOLT_TUNING := "res://data/tuning/w01_scrapjack.tres"
const Breakable := preload("res://scripts/objects/breakable.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const PAD := "L02-A01-PAD01"
const FLOOR_Y := 560.0
const Kind := Breakable.Kind
const Stage := Breakable.Stage

## kind -> [default health, has a cracked stage].
const EXPECTED := {
	Kind.GLASS_PANEL: [2, true], Kind.MONITOR: [2, true], Kind.SERVER_CABINET: [4, true],
	Kind.CRATE: [3, true], Kind.GAUGE: [1, false], Kind.VENT_PANEL: [2, true], Kind.DISPLAY_CASE: [3, true],
}


func run() -> void:
	await _test_hit_points()
	await _test_overrides()
	await _test_real_shots()
	await _test_secret_wall()
	await _test_enemy_rounds()
	await _test_contents()
	await _test_persistence()
	await _test_motion_and_cleanup()
	release_all()
	CheckpointService.clear()
	Session.new_run()


# --- helpers -----------------------------------------------------------------------------------

func _floor() -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(-1500, FLOOR_Y)
	b.size = Vector2(4000, 200)
	add_child(b)
	return b


func _hero(pos: Vector2 = Vector2(0, FLOOR_Y - 1.0)) -> Hero:
	var hero: Hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = pos
	hero.use_aim_override = true
	hero.aim_override = pos + Vector2(400.0, -48.0)
	return hero


func _breakable(k: int, at: Vector2, id: String = "", solid: bool = false, health: int = 0, parent: Node = null) -> StaticBody2D:
	var b: StaticBody2D = load(BREAKABLE_SCENE).instantiate()
	b.kind = k
	b.entity_id = id
	b.solid = solid
	b.health = health
	b.position = at
	(parent if parent != null else self).add_child(b)
	return b


## One hit through the HitZone, the way a bolt or a blast delivers it.
func _hit(b: StaticBody2D, damage: int = 1) -> StringName:
	return b.hit_zone().take_hit(damage, b.global_position + Vector2(0.0, -b.effective_size().y * 0.5), Vector2.RIGHT)


func _bolt(from: Vector2, dir: Vector2) -> Node2D:
	var bolt: Node2D = load(BOLT_SCENE).instantiate()
	add_child(bolt)
	bolt.setup(from, dir, load(BOLT_TUNING))
	return bolt


func _debris_count(b: Node) -> int:
	var n := 0
	for c in b.get_children():
		if c is Breakable.Debris:
			n += 1
	return n


# --- 1. hit points per kind ---------------------------------------------------------------------

func _test_hit_points() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	for k in EXPECTED:
		var health: int = EXPECTED[k][0]
		var cracks: bool = EXPECTED[k][1]
		var b := _breakable(k, Vector2(0, FLOOR_Y))
		var name: String = b.kind_name()
		var seen := {"cracked": 0, "broke": 0}
		b.cracked.connect(func(_left: int): seen["cracked"] += 1)
		b.broke.connect(func(): seen["broke"] += 1)
		await physics_frames(2)
		check_eq(b.max_health(), health, "%s: default health %d" % [name, health])
		check_eq(b.stage(), Stage.INTACT, "%s starts intact" % name)
		check(b.hit_zone().collision_layer == 16 and b.hit_zone().monitorable, "%s has a live HitZone on the hittable layer" % name)
		for i in health - 1:
			check_eq(_hit(b), &"hit", "%s: hit %d is accepted" % [name, i + 1])
			check(not b.is_broken(), "%s still stands after %d hit(s)" % [name, i + 1])
		if health >= 2:
			check_eq(b.stage(), Stage.CRACKED if cracks else Stage.INTACT,
					"%s %s before it breaks" % [name, "is cracked" if cracks else "shows no cracks"])
		check_eq(_hit(b), &"hit", "%s: the last hit is accepted" % name)
		check(b.is_broken() and b.remaining_health() == 0, "%s breaks on hit %d" % [name, health])
		check_eq(b.stage(), Stage.BROKEN, "%s is in its broken stage" % name)
		check_eq(seen["broke"], 1, "%s emits `broke` once" % name)
		check_eq(seen["cracked"], health - 1, "%s emits `cracked` for each hit that did not break it" % name)
		check_eq(_hit(b), &"blocked", "%s: a broken prop's zone refuses further hits (shots fly through)" % name)
		check_eq(b.collision_layer, 0, "%s: a broken prop has no collision" % name)
		await physics_frames(2)
		check(_debris_count(b) >= 1, "%s throws debris when it breaks" % name)
		b.queue_free()
	# Each spec's sounds are cues the audio director already has.
	for k in Breakable.SPECS:
		for cue in Breakable.SPECS[k]["sounds"]:
			check(Audio.SFX_NAMES.has(cue), "%s: break sound %s is an existing cue" % [Breakable.SPECS[k]["name"], cue])
	# Kinds by name, for level scripts.
	check_eq(Breakable.kind_from_name("server_cabinet"), Kind.SERVER_CABINET, "kind_from_name finds a kind")
	check_eq(Breakable.kind_from_name("nope"), -1, "...and says -1 for an unknown one")
	floor_b.queue_free()
	await physics_frames(2)


func _test_overrides() -> void:
	var b := _breakable(Kind.CRATE, Vector2(0, FLOOR_Y), "", false, 5)
	b.size = Vector2.ZERO
	await physics_frames(2)
	check_eq(b.max_health(), 5, "`health` overrides the kind's default")
	for i in 4:
		_hit(b)
	check(not b.is_broken() and b.stage() == Stage.CRACKED, "a crate of health 5 stands after four hits, cracked")
	_hit(b)
	check(b.is_broken(), "...and breaks on the fifth")
	b.queue_free()
	# One big hit (a Boom Broom blast at point blank) breaks anything of health <= 5.
	var cab := _breakable(Kind.SERVER_CABINET, Vector2(0, FLOOR_Y))
	await physics_frames(2)
	_hit(cab, 5)
	check(cab.is_broken(), "one hit worth 5 breaks a server cabinet (health 4)")
	cab.queue_free()
	# `size` overrides the default and sizes both shapes.
	var big: StaticBody2D = load(BREAKABLE_SCENE).instantiate()
	big.kind = Kind.GLASS_PANEL
	big.size = Vector2(30.0, 200.0)
	big.solid = true
	add_child(big)
	await physics_frames(2)
	var body_shape := (big.get_node("Solid") as CollisionShape2D).shape as RectangleShape2D
	var zone_shape := (big.hit_zone().get_node("Shape") as CollisionShape2D).shape as RectangleShape2D
	check_eq(body_shape.size, Vector2(30.0, 200.0), "`size` sizes the solid body")
	check(zone_shape.size.x >= body_shape.size.x + 2.0 * Breakable.SOLID_ZONE_GROW - 0.01
			and zone_shape.size.y >= body_shape.size.y + 2.0 * Breakable.SOLID_ZONE_GROW - 0.01,
			"a solid prop's HitZone is bigger than its body on every side, so a ray meets it first")
	big.queue_free()
	await physics_frames(2)


# --- 2. real shots ------------------------------------------------------------------------------

func _test_real_shots() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	# A spawned Scrapjack bolt.
	var crate := _breakable(Kind.CRATE, Vector2(200, FLOOR_Y))
	await physics_frames(2)
	_bolt(Vector2(60, FLOOR_Y - 25.0), Vector2.RIGHT)
	await physics_frames(20)
	check_eq(crate.remaining_health(), 2, "a Scrapjack bolt takes one point off a crate (3 -> 2)")
	crate.queue_free()
	await physics_frames(2)

	# Dave fires the Scrapjack at a monitor on the floor.
	var hero := _hero()
	await physics_frames(4)
	var monitor := _breakable(Kind.MONITOR, Vector2(220, FLOOR_Y))
	hero.aim_override = Vector2(220, FLOOR_Y - 18.0)
	await physics_frames(3)
	await hold(&"fire", 1.2)
	check(monitor.is_broken(), "Dave's Scrapjack breaks a monitor (2 health) in a second or so of fire")
	monitor.queue_free()
	hero.queue_free()
	await physics_frames(2)

	# The Boom Broom: one close blast breaks a cabinet (4), a far one only cracks it.
	Session.new_run("L02")
	Session.swap_weapon(PAD)
	hero = _hero()
	hero.ground_aim_limit_enabled = false
	await physics_frames(4)
	var gun := hero.held_weapon() as BoomBroom
	check(gun != null, "setup: Dave holds the Boom Broom")
	var near := _breakable(Kind.SERVER_CABINET, Vector2(110, FLOOR_Y))
	await physics_frames(2)
	hero.aim_override = hero.aim_pivot.global_position + Vector2(600.0, 0.0)
	await physics_frames(3)
	gun.action = BoomBroom.Action.READY
	check(gun.try_blast(), "setup: the blast goes off")
	await physics_frames(2)
	var near_report: Dictionary = gun.last_blast["targets"].get(near.hit_zone(), {})
	check(near_report.get("outcome", &"") == &"hit", "the blast reports a hit on the cabinet's HitZone")
	check(near.is_broken(), "one close Boom Broom blast breaks a server cabinet (damage %s of 4)" % str(near_report.get("damage", "?")))
	near.queue_free()
	await physics_frames(2)

	var far := _breakable(Kind.SERVER_CABINET, Vector2(380, FLOOR_Y))
	await physics_frames(2)
	gun.action = BoomBroom.Action.READY
	hero.aim_override = hero.aim_pivot.global_position + Vector2(600.0, 0.0)
	await physics_frames(3)
	check(gun.try_blast(), "setup: a second blast goes off")
	await physics_frames(2)
	var far_report: Dictionary = gun.last_blast["targets"].get(far.hit_zone(), {})
	check(far_report.get("outcome", &"") == &"hit" and int(far_report.get("damage", 99)) < int(near_report.get("damage", 0)),
			"a far blast deals less than a close one (%s vs %s)" % [str(far_report.get("damage", "?")), str(near_report.get("damage", "?"))])
	check(not far.is_broken() and far.stage() == Stage.CRACKED, "...and only cracks the cabinet")
	far.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 3. the secret wall ------------------------------------------------------------------------

func _test_secret_wall() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	# Every shot meets the zone before the body: from either side, at the top, middle and foot.
	for side in [1.0, -1.0]:
		for h in [-140.0, -75.0, -8.0]:
			var wall := _breakable(Kind.GLASS_PANEL, Vector2(500, FLOOR_Y), "", true, 5)
			await physics_frames(2)
			_bolt(Vector2(500.0 - 160.0 * side, FLOOR_Y + h), Vector2(side, 0.0))
			await physics_frames(25)
			check_eq(wall.remaining_health(), 4, "a bolt from the %s at %d px takes a point off the secret wall instead of just being blocked" % ["left" if side > 0.0 else "right", int(-h)])
			wall.queue_free()
			await physics_frames(2)
	# Top and bottom: a bolt falling onto the head of the wall and one hitting its end.
	var wall2 := _breakable(Kind.GLASS_PANEL, Vector2(500, FLOOR_Y), "", true, 5)
	await physics_frames(2)
	_bolt(Vector2(500, FLOOR_Y - 300.0), Vector2.DOWN)
	await physics_frames(25)
	check_eq(wall2.remaining_health(), 4, "a bolt dropping onto the top of the wall hits it too")
	wall2.queue_free()
	await physics_frames(2)

	# Dave: stopped by the intact wall, through it once it is broken.
	var hero := _hero()
	await physics_frames(4)
	var wall := _breakable(Kind.GLASS_PANEL, Vector2(300, FLOOR_Y), "", true)
	await physics_frames(3)
	check_eq(wall.collision_layer, 1, "an intact solid prop is on the world layer")
	await hold(&"move_right", 1.6)
	check(hero.global_position.x < 300.0 - 12.0 + 1.0 and hero.global_position.x > 200.0,
			"Dave walks up to the intact wall and stops at it (x %.0f)" % hero.global_position.x)
	hero.aim_override = Vector2(300, FLOOR_Y - 75.0)
	await physics_frames(3)
	await hold(&"fire", 1.4)
	check(wall.is_broken(), "Dave's shots break the secret wall (2 health)")
	check_eq(wall.collision_layer, 0, "...which drops off the world layer")
	await physics_frames(3)
	await hold(&"move_right", 1.6)
	check(hero.global_position.x > 340.0, "...and Dave walks through the gap (x %.0f)" % hero.global_position.x)
	# A shot goes through where the glass was.
	var bolt := _bolt(Vector2(150, FLOOR_Y - 75.0), Vector2.RIGHT)
	var reached := 0.0
	for i in 20:
		await physics_frames(1)
		if is_instance_valid(bolt):
			reached = maxf(reached, bolt.global_position.x)
	check(reached > 340.0, "a bolt flies through the broken wall (reached x %.0f)" % reached)
	wall.queue_free()

	# A non-solid prop never blocks.
	var crate := _breakable(Kind.CRATE, Vector2(700, FLOOR_Y))
	await physics_frames(2)
	check_eq(crate.collision_layer, 0, "a non-solid breakable is not on the world layer")
	hero.global_position = Vector2(600, FLOOR_Y - 1.0)
	await physics_frames(2)
	await hold(&"move_right", 1.2)
	check(hero.global_position.x > 740.0, "Dave walks straight through a non-solid crate (x %.0f)" % hero.global_position.x)
	crate.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 4. enemy rounds never break anything ------------------------------------------------------

func _test_enemy_rounds() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	var crate := _breakable(Kind.CRATE, Vector2(200, FLOOR_Y))
	var wall := _breakable(Kind.GLASS_PANEL, Vector2(600, FLOOR_Y), "", true)
	await physics_frames(3)
	var shot: Node2D = load(ROUND_SCENE).instantiate()
	add_child(shot)
	shot.setup(Vector2(0, FLOOR_Y - 22.0), Vector2.RIGHT, 864.0, 900.0)
	var reached := 0.0
	for i in 60:
		await physics_frames(1)
		if is_instance_valid(shot):
			reached = maxf(reached, shot.global_position.x)
	check_eq(crate.remaining_health(), 3, "an enemy round does not damage a prop it passes")
	check(reached > 250.0, "...and passes through a non-solid prop (reached x %.0f)" % reached)
	check_eq(wall.remaining_health(), 2, "an enemy round that reaches an intact solid wall does not damage it")
	check(reached < 612.0, "...but the wall stops it (reached x %.0f)" % reached)
	crate.queue_free()
	wall.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 5. contents -------------------------------------------------------------------------------

func _test_contents() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	var room := Node2D.new()
	add_child(room)
	var chip: Area2D = load(CHIP_SCENE).instantiate()
	chip.name = "Chip"
	chip.entity_id = "L02-A02-BR01-C1"
	chip.value = 5
	chip.position = Vector2(0, FLOOR_Y - 20.0)   # right where Dave stands
	room.add_child(chip)
	var cart: Area2D = load(CARTRIDGE_SCENE).instantiate()
	cart.name = "Cartridge"
	cart.entity_id = "L02-A02-BR01-AM"
	cart.position = Vector2(60, FLOOR_Y)
	room.add_child(cart)
	var b: StaticBody2D = load(BREAKABLE_SCENE).instantiate()
	b.kind = Kind.DISPLAY_CASE
	b.entity_id = "L02-A02-BR01"
	b.position = Vector2(150, FLOOR_Y)
	var paths: Array[NodePath] = [NodePath("../Chip"), NodePath("../Cartridge")]
	b.contents = paths
	room.add_child(b)
	await physics_frames(8)
	check_eq(b.content_nodes().size(), 2, "the breakable finds both of its contents")
	check(not chip.visible and not cart.visible, "contents are hidden while it is intact")
	check(chip.process_mode == Node.PROCESS_MODE_DISABLED and cart.process_mode == Node.PROCESS_MODE_DISABLED,
			"...and inactive")
	check(not Session.is_collected("L02-A02-BR01-C1") and Session.get_wallet() == 0,
			"...so Dave standing on the hidden chip does not collect it")
	for i in 3:
		_hit(b)
	check(b.is_broken(), "setup: the display case breaks")
	check(chip.visible and cart.visible, "contents appear when it breaks")
	check(chip.process_mode == Node.PROCESS_MODE_INHERIT and cart.process_mode == Node.PROCESS_MODE_INHERIT, "...and switch on")
	await physics_frames(8)
	check(Session.is_collected("L02-A02-BR01-C1") and Session.get_wallet() == 5,
			"...and the chip under Dave is collected (5 chips)")
	check(not is_instance_valid(chip) or chip.is_queued_for_deletion(), "...and is consumed")
	check(is_instance_valid(cart) and not cart.is_queued_for_deletion() and not Session.is_collected("L02-A02-BR01-AM"),
			"the Scrapjack takes no feed cartridge, so it waits where it appeared")
	room.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 6. persistence ----------------------------------------------------------------------------

## A little room: a chip (own id) and a solid glass wall holding it.
func _room(break_id: String, chip_id: String) -> Dictionary:
	var room := Node2D.new()
	add_child(room)
	var chip: Area2D = load(CHIP_SCENE).instantiate()
	chip.name = "Chip"
	chip.entity_id = chip_id
	chip.value = 5
	chip.position = Vector2(900, FLOOR_Y - 20.0)   # away from Dave
	room.add_child(chip)
	var b: StaticBody2D = load(BREAKABLE_SCENE).instantiate()
	b.kind = Kind.GLASS_PANEL
	b.solid = true
	b.entity_id = break_id
	b.position = Vector2(850, FLOOR_Y)
	var paths: Array[NodePath] = [NodePath("../Chip")]
	b.contents = paths
	room.add_child(b)
	return {"room": room, "chip": chip, "b": b}


func _test_persistence() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	var floor_b := _floor()
	var hero := _hero(Vector2(0, FLOOR_Y - 1.0))
	await physics_frames(4)
	check(Session.commit("CP00"), "setup: CP00 committed")
	var r := _room("L02-A02-BR01", "L02-A02-BR01-C1")
	await physics_frames(3)
	var b: StaticBody2D = r["b"]
	check(not b.is_broken() and not Session.is_collected("L02-A02-BR01"), "setup: intact and unrecorded")
	b.break_now()
	check(Session.is_collected("L02-A02-BR01"), "breaking it records its id with Session.collect")
	check_eq(Session.chips_found(), 0, "...worth no microchips")
	# A save holding the broken id validates, after a JSON round trip.
	var round_trip: Dictionary = JSON.parse_string(JSON.stringify(Session.state.duplicate(true)))
	var v: Dictionary = CheckpointService.validate_snapshot(round_trip)
	check(v.get("ok", false), "a Level 2 save holding a broken prop validates (%s)" % str(v.get("error", "")))
	# A death before the next checkpoint puts it back, with its contents hidden again.
	(r["room"] as Node).queue_free()
	await physics_frames(2)
	Session.restore_committed()
	check(not Session.is_collected("L02-A02-BR01"), "a rollback to the checkpoint un-breaks it")
	r = _room("L02-A02-BR01", "L02-A02-BR01-C1")
	await physics_frames(3)
	b = r["b"]
	var chip: Variant = r["chip"]
	check(not b.is_broken() and b.collision_layer == 1, "...the rebuilt wall is intact and solid again")
	check(not chip.visible and chip.process_mode == Node.PROCESS_MODE_DISABLED, "...with its reward hidden again")

	# Break it, take the chip, and commit: both stay after a later death.
	b.break_now()
	await physics_frames(3)
	chip.global_position = Vector2(0, FLOOR_Y - 20.0)   # onto Dave
	await physics_frames(6)
	check(Session.is_collected("L02-A02-BR01-C1") and Session.get_wallet() == 5, "setup: the chip is taken (5 chips)")
	check(Session.commit("CP01"), "setup: CP01 committed")
	(r["room"] as Node).queue_free()
	await physics_frames(2)
	Session.restore_committed()
	r = _room("L02-A02-BR01", "L02-A02-BR01-C1")
	await physics_frames(3)
	b = r["b"]
	chip = r["chip"]
	check(b.is_broken() and b.collision_layer == 0, "after a checkpoint a rebuilt wall is still broken, and open")
	check_eq(_debris_count(b), 0, "...with no fresh debris, and no sound")
	check(not is_instance_valid(chip) or chip.is_queued_for_deletion(), "...and the collected chip is not rebuilt")
	check_eq(Session.get_wallet(), 5, "...so rebuilding never doubles a reward (still 5 chips)")
	check(not b.hit_zone().monitorable, "...and its zone is off")
	(r["room"] as Node).queue_free()
	await physics_frames(2)

	# A second wall broken after CP01 and its chip taken: both roll back together.
	r = _room("L02-A02-BR02", "L02-A02-BR02-C1")
	await physics_frames(3)
	b = r["b"]
	chip = r["chip"]
	b.break_now()
	chip.global_position = Vector2(0, FLOOR_Y - 20.0)
	await physics_frames(6)
	check(Session.get_wallet() == 10 and Session.is_collected("L02-A02-BR02"), "setup: a second wall broken and its chip taken")
	(r["room"] as Node).queue_free()
	await physics_frames(2)
	Session.restore_committed()
	check(not Session.is_collected("L02-A02-BR02") and not Session.is_collected("L02-A02-BR02-C1") and Session.get_wallet() == 5,
			"a death before the next checkpoint puts the wall and its chip back (wallet 5)")
	# A prop with no id is always intact on a rebuild.
	var anon := _breakable(Kind.CRATE, Vector2(300, FLOOR_Y))
	anon.break_now()
	check(anon.is_broken(), "a prop without an id still breaks")
	anon.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


# --- 7. motion safety and cleanup -----------------------------------------------------------------

## Samples a breakable's glow every physics frame for `time` seconds and counts its flashes
## (rises from near dark), returning [count, times of the rises].
func _glow_peaks(b: StaticBody2D, time: float) -> Array:
	var rises: Array = []
	var prev := 0.0
	var falling := true
	var t := 0.0
	for i in int(time * 60.0):
		await physics_frames(1)
		t += 1.0 / 60.0
		var g: float = b.glow_level()
		if g > prev + 0.02 and falling:
			rises.append(t)
			falling = false
		elif g < prev - 0.02:
			falling = true
		prev = g
	return [rises.size(), rises]


func _test_motion_and_cleanup() -> void:
	Session.new_run("L02")
	var floor_b := _floor()
	Settings.set_reduced_motion(false)
	# The hit flash: a second hit 0.2 s after the first does not restart it.
	var glass := _breakable(Kind.GLASS_PANEL, Vector2(0, FLOOR_Y), "", false, 5)
	await physics_frames(2)
	_hit(glass)
	check(glass._flash > 0.99, "a hit flashes the prop")
	await seconds(0.2)
	_hit(glass)
	check(glass._flash < 0.5, "...but a second hit 0.2 s later does not flash it again (2 Hz at most)")
	await seconds(0.4)
	_hit(glass)
	check(glass._flash > 0.99, "...a hit 0.6 s after the first does")
	glass.queue_free()

	# A screen's break: one flash and one echo, 0.55 s apart (under 2 Hz).
	var mon := _breakable(Kind.MONITOR, Vector2(0, FLOOR_Y))
	await physics_frames(2)
	mon.break_now()
	var out: Array = await _glow_peaks(mon, 1.4)
	check_eq(out[0], 2, "a broken screen flashes twice: its break and one echo")
	if out[0] == 2:
		var gap: float = float(out[1][1]) - float(out[1][0])
		check(gap >= 0.5 - 0.03, "...at least 0.5 s apart (%.2f s), under 2 Hz" % gap)
	mon.queue_free()

	# Reduced motion: no jolt, no echo, fewer pieces.
	Settings.set_reduced_motion(true)
	var mon2 := _breakable(Kind.MONITOR, Vector2(100, FLOOR_Y))
	var crate_full := _breakable(Kind.CRATE, Vector2(200, FLOOR_Y))
	await physics_frames(2)
	mon2.break_now()
	out = await _glow_peaks(mon2, 1.4)
	check_eq(out[0], 1, "under Reduced motion a broken screen flashes once, with no echo")
	check(mon2._jolt <= 0.0, "...and does not shake")
	mon2.queue_free()
	crate_full.queue_free()
	Settings.set_reduced_motion(false)

	# Debris cleans itself up.
	var crate := _breakable(Kind.CRATE, Vector2(300, FLOOR_Y))
	await physics_frames(2)
	crate.break_now()
	await physics_frames(5)
	check(_debris_count(crate) >= 1, "setup: a crate throws debris")
	await seconds(4.0)
	check_eq(_debris_count(crate), 0, "...which frees itself within a few seconds")
	crate.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
