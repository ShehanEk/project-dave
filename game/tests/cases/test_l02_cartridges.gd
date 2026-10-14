extends TestCase
## Level 2's feed cartridges (S02 "Supplies and fiction"; scripts/objects/ammo_cartridge.gd):
## the blue cartridge that adds up to 8 shells to the held Boom Broom's RESERVE (capped at
## 24, the excess discarded), stays put while the held weapon takes none (the Scrapjack, or
## a full reserve) and says so, is gone for the run once taken (a death before a checkpoint
## puts it back), saves under a whitelisted id, and stands on a floor in the seven places
## the v2 level puts them (C62), three of them hidden inside a breakable until it is shot open.

const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const HERO_SCENE := "res://scenes/actors/hero.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const CARTRIDGE_SCENE := "res://scenes/objects/ammo_cartridge.tscn"
const AmmoCartridge := preload("res://scripts/objects/ammo_cartridge.gd")
const BlockScript := preload("res://scripts/world/block.gd")
const PAD := "L02-A01-PAD01"
const BROOM := "L02-W02-P01"
const FLOOR_Y := 560.0
## Level 2's cartridges (v2): id -> [area index, local x, local y].
const PLACED := {
	"L02-A01-AM01": [0, 5770.0, -180.0], "L02-A02-AM01": [1, 1250.0, 0.0], "L02-A02-AM02": [1, 3720.0, 0.0],
	"L02-A03-AM01": [2, 1380.0, 0.0], "L02-A03-AM02": [2, 5265.0, -680.0], "L02-A05-AM01": [4, 640.0, 0.0],
	"L02-A06-AM01": [5, 5720.0, 0.0],
}
## The ones a breakable hides until it breaks: cartridge -> the breakable's id (the service
## landing's crate, the armory's glass wall, the A03 duct's vent panel).
const HIDDEN := {
	"L02-A01-AM01": "L02-A01-BR02", "L02-A02-AM02": "L02-A02-BR01", "L02-A03-AM02": "L02-A03-BR01",
}


func run() -> void:
	await _test_pickup_rules()
	await _test_held_weapon_gates()
	await _test_rollback_and_save()
	await _test_level_placement()
	await _clear_leftovers()
	CheckpointService.clear()
	Session.new_run()


## Frees whatever an earlier sub-test left under this case (a script error aborts a sub-test
## before its own clean-up): no stray floor, hero, HUD or level carries into the next one.
func _clear_leftovers() -> void:
	release_all()
	var left := get_children()
	for c in left:
		c.queue_free()
	if not left.is_empty():
		await physics_frames(2)


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
	return hero


func _cartridge(at: Vector2, id: String, shells: int = 8) -> Area2D:
	var c: Area2D = load(CARTRIDGE_SCENE).instantiate()
	c.entity_id = id
	c.shells = shells
	add_child(c)
	c.global_position = at
	return c


## A Level 2 run with the Boom Broom in hand (swapped off the A01 pad).
func _broom_run() -> void:
	Session.new_run("L02")
	Session.swap_weapon(PAD)


func _toast_text(hud: Hud) -> String:
	var t: Label = hud.get_node("Toast")
	return t.text if t.visible else ""


# --- 1. what a cartridge gives ----------------------------------------------------------------

func _test_pickup_rules() -> void:
	await _clear_leftovers()
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(4)
	hud.setup(hero)
	Session.set_weapon_ammo(BROOM, 4, 10)
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 10}, "setup: 4 loaded, 10 in reserve")
	var c := _cartridge(Vector2(300, FLOOR_Y), "L02-A02-AM01")
	await physics_frames(3)
	check(is_instance_valid(c) and not c.is_queued_for_deletion(), "a cartridge off to the side waits")
	hero.global_position = Vector2(300, FLOOR_Y - 1.0)
	await physics_frames(4)
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 18}, "taking it adds 8 shells to the reserve (4 + 18)")
	check(Session.is_collected("L02-A02-AM01"), "...and it is recorded as taken")
	check_eq(Session.chips_found(), 0, "...adding no microchips")
	check(not is_instance_valid(c) or c.is_queued_for_deletion(), "...and it is gone")
	check_eq(_toast_text(hud), "+8 shells", "the HUD says how many shells it gave")

	# A partly useful cartridge is consumed once; the excess is discarded.
	Session.set_weapon_ammo(BROOM, 4, 20)
	var c2 := _cartridge(Vector2(300, FLOOR_Y), "L02-A02-AM02")
	await physics_frames(4)
	check_eq(Session.held_ammo(), {"loaded": 4, "reserve": 24}, "20 + 8 caps at the 24 reserve")
	check(Session.is_collected("L02-A02-AM02") and (not is_instance_valid(c2) or c2.is_queued_for_deletion()),
			"...the cartridge is consumed, the 4 that did not fit discarded")
	check_eq(_toast_text(hud), "+4 shells", "...the toast says what actually went in")

	# The gun's shells change when the tube is fed from the new reserve, never beyond.
	check(AmmoCartridge.shells_that_fit(8) == 0, "with a full reserve a cartridge fits nothing")
	hud.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 2. it waits while the held weapon takes none ------------------------------------------------

func _test_held_weapon_gates() -> void:
	await _clear_leftovers()
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(4)
	hud.setup(hero)
	# A full reserve: it stays, and says so.
	check_eq(Session.held_ammo()["reserve"], 24, "setup: a full reserve")
	var c := _cartridge(Vector2(0, FLOOR_Y), "L02-A02-AM01")
	await physics_frames(4)
	check(is_instance_valid(c) and not c.is_queued_for_deletion() and not Session.is_collected("L02-A02-AM01"),
			"a full reserve leaves the cartridge where it is")
	check_eq(_toast_text(hud), "Shell reserve full", "...and says why")
	# Spending shells while standing on it takes it (it re-checks each tick).
	Session.set_weapon_ammo(BROOM, 4, 20)
	await physics_frames(3)
	check(Session.is_collected("L02-A02-AM01") and Session.held_ammo()["reserve"] == 24,
			"once there is room, standing on it takes it (20 + 4 = 24)")

	# The Scrapjack: it takes none and the cartridge stays for a later pass.
	Session.swap_weapon(PAD)
	await physics_frames(3)
	check_eq(Session.held_weapon_type(), "W01", "setup: back to the Scrapjack")
	var c2 := _cartridge(Vector2(0, FLOOR_Y), "L02-A02-AM02")
	await physics_frames(4)
	check(is_instance_valid(c2) and not c2.is_queued_for_deletion() and not Session.is_collected("L02-A02-AM02"),
			"the Scrapjack takes no cartridge, so it stays")
	check_eq(_toast_text(hud), "Feed cartridge: no use for the Scrapjack", "...and says so")
	check_eq(AmmoCartridge.shells_that_fit(8), 0, "shells_that_fit is 0 for an unlimited weapon")
	# Swapping to the Broom while standing on it takes it.
	Session.set_weapon_ammo(BROOM, 2, 10)
	Session.swap_weapon(PAD)
	await physics_frames(4)
	check(Session.is_collected("L02-A02-AM02") and Session.weapon_ammo(BROOM)["reserve"] == 18,
			"swapping to the Broom on top of it takes it (10 + 8)")
	hud.queue_free()
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)


# --- 3. a death puts it back; the save accepts its id -----------------------------------------------

func _test_rollback_and_save() -> void:
	await _clear_leftovers()
	CheckpointService.clear()
	_broom_run()
	var floor_b := _floor()
	var hero := _hero()
	await physics_frames(4)
	Session.set_weapon_ammo(BROOM, 4, 10)
	Session.commit("CP00")
	var c := _cartridge(Vector2(0, FLOOR_Y), "L02-A02-AM01")
	await physics_frames(4)
	check_eq(Session.weapon_ammo(BROOM)["reserve"], 18, "setup: taken after the checkpoint (10 + 8)")
	var snap := Session.state.duplicate(true)
	var round_trip: Dictionary = JSON.parse_string(JSON.stringify(snap))
	var v: Dictionary = CheckpointService.validate_snapshot(round_trip)
	check(v.get("ok", false), "a Level 2 save holding a taken cartridge validates (%s)" % str(v.get("error", "")))
	Session.restore_committed()
	check(not Session.is_collected("L02-A02-AM01"), "a rollback to the checkpoint puts the cartridge back")
	check_eq(Session.weapon_ammo(BROOM)["reserve"], 10, "...with the shells it had given")
	var again := _cartridge(Vector2(500, FLOOR_Y), "L02-A02-AM01")
	await physics_frames(3)
	check(is_instance_valid(again) and not again.is_queued_for_deletion(), "...and a rebuilt cartridge is there to take")
	# A taken one is gone in a rebuilt level.
	Session.collect("L02-A02-AM02", 0)
	var gone := _cartridge(Vector2(500, FLOOR_Y), "L02-A02-AM02")
	await physics_frames(3)
	check(not is_instance_valid(gone) or gone.is_queued_for_deletion(), "a cartridge already taken this run is not rebuilt")
	hero.queue_free()
	floor_b.queue_free()
	await physics_frames(2)
	CheckpointService.clear()


# --- 4. where Level 2 puts them ---------------------------------------------------------------------

func _test_level_placement() -> void:
	CheckpointService.clear()
	Session.new_run("L02")
	await _clear_leftovers()
	var lvl: LevelDirector = load(LEVEL_SCENE).instantiate()
	lvl.level_def = LevelDefs.get_def("L02")
	add_child(lvl)
	await physics_frames(3)
	var found := {}
	for node in lvl.get_tree().get_nodes_in_group("ammo_cartridge"):
		found[node.entity_id] = node
	check_eq(found.size(), PLACED.size(), "Level 2 places %d cartridges" % PLACED.size())
	var holders := {}   # cartridge -> the breakable whose contents hold it
	for br in lvl.get_tree().get_nodes_in_group("breakable"):
		for p in br.contents:
			var n: Node = br.get_node_or_null(p)
			if n != null and n.is_in_group("ammo_cartridge"):
				holders[n.entity_id] = br
	for id in PLACED:
		check(found.has(id), "%s is placed" % id)
		if not found.has(id):
			continue
		var c: Area2D = found[id]
		var a: AreaRoot = lvl.areas[int(PLACED[id][0])]
		var want := a.to_global(Vector2(float(PLACED[id][1]), float(PLACED[id][2])))
		check(c.global_position.distance_to(want) < 1.0, "%s stands at %s of %s (at %s)" % [id,
				str(Vector2(PLACED[id][1], PLACED[id][2])), a.area_id, str(a.to_local(c.global_position))])
		check(c.entity_id.begins_with(a.area_id + "-AM"), "%s's id is under its area" % id)
		check_eq(c.shells, 8, "%s holds S02's 8 shells" % id)
		# On a floor: solid ground within a pixel or two under its origin, nothing blocking it.
		var params := PhysicsRayQueryParameters2D.create(c.global_position + Vector2(0, -40), c.global_position + Vector2(0, 30))
		params.collision_mask = 1
		var hit: Dictionary = lvl.get_world_2d().direct_space_state.intersect_ray(params)
		check(not hit.is_empty() and absf(float(hit["position"].y) - c.global_position.y) < 2.0,
				"%s stands on the floor" % id)
		# Hidden in a breakable, or out in the open.
		if HIDDEN.has(id):
			var br: Node = holders.get(id)
			check(br != null and br.entity_id == HIDDEN[id], "%s waits inside the breakable %s" % [id, HIDDEN[id]])
			check(not c.visible and c.process_mode == Node.PROCESS_MODE_DISABLED, "...hidden and switched off until it breaks")
		else:
			check(not holders.has(id) and c.visible and c.process_mode != Node.PROCESS_MODE_DISABLED, "%s is out in the open" % id)
	# The shooter fights that need them: the coolant plant's landing before the range, the range
	# itself, the flight cage, the Lattice and the demo floor (none in the training cells).
	var areas_with: Dictionary = {}
	for id in PLACED:
		areas_with[PLACED[id][0]] = true
	var keys := areas_with.keys()
	keys.sort()
	check_eq(keys, [0, 1, 2, 4, 5], "cartridges wait in the coolant plant, the range, the cage, the Lattice and the demo floor")
	# Each one comes before a Sidearm Guard further along the route.
	var gunners: Array = []
	for e in lvl.get_tree().get_nodes_in_group("enemy"):
		if e is Gunner:
			gunners.append(e.global_position.x)
	for id in PLACED:
		if found.has(id):
			var x: float = found[id].global_position.x
			check(gunners.any(func(gx): return gx > x), "%s comes before a Sidearm Guard on the route" % id)
	lvl.queue_free()
	await physics_frames(2)
	CheckpointService.clear()
