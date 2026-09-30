extends TestCase
## M4 state-contract harness (04-godot-architecture.md "Save design" /
## 06-build-milestones.md M4 / 07-acceptance-and-playtesting.md's functional
## matrix). Covers:
##   (a) snapshot restoration: save at a station, collect a chip, take
##       damage, defeat an enemy, flip a swap, then die -> one consistent
##       snapshot restored, no duplicate IDs, chip collectible again, wallet
##       matches, enemy back at idle placement with full health.
##   (b) the upgrade transaction, including a forced persistence failure,
##       refusal (locked), insufficient funds, and repeat purchase.
##   (c) CheckpointService file-level contracts: malformed JSON, wrong
##       schema, a tampered/non-whitelisted id or scene-path, primary
##       corrupt + valid backup, and a save/load round trip.
## Plus focused functional-matrix checks: T09 (45 main-route chip value,
## collected at runtime through Session), T12 (capsule/station reuse), T13
## (same-type swap confirm/cancel/swap-back), T14 (upgrade via the real
## Session API), T15 (post-upgrade swap inherits the type-wide stage), T19
## (save failure / invalid save never half-loads).
##
## No player-facing dev toggle exists for the workbench's `awakening_done` gate
## (per 06's M4 note, a toggle may only simulate it FOR TESTS) — every test
## below that needs the workbench unlocked sets the story flag directly on
## Session, exactly as 06 prescribes.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const WORKBENCH_PANEL_SCENE := "res://scenes/ui/workbench_panel.tscn"
const WEAPON_PAD_SCENE := "res://scenes/objects/weapon_pad.tscn"
const PAD_ID := "L01-A05-PAD01"


func run() -> void:
	_test_chip_economy_runtime_t09()
	await _test_snapshot_restoration()
	await _test_care_and_station_reuse_t12()
	_test_weapon_pad_swap_t13_t15()
	_test_upgrade_transaction_t14()
	_test_checkpoint_service_validation_t19()


# --- T09: 45 main-route chip value, collected at runtime -----------------------

func _test_chip_economy_runtime_t09() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)

	var total := 0
	var count := 0
	for i in range(0, 4):  # A01..A04 only: main route, before the depot (A05)
		var entities := level.areas[i].get_node_or_null("Entities")
		if entities == null:
			continue
		for child in entities.get_children():
			if child is Chip:
				check(Session.collect(child.entity_id, child.value),
						"runtime collect succeeds for %s (first time)" % child.entity_id)
				total += child.value
				count += 1
	check(total == 45, "collecting every main-route (A01-A04) chip through Session totals 45 chips (got %d from %d pickups)" % [total, count])
	check(Session.get_wallet() == 45, "Session wallet reflects the same 45 (got %d)" % Session.get_wallet())
	check(Session.chips_found() == 45, "chips_found() (collection total) also reads 45 (got %d)" % Session.chips_found())

	level.queue_free()


# --- (a) snapshot restoration ---------------------------------------------------

func _test_snapshot_restoration() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var a02: AreaRoot = level.areas[1]
	var station: RecoveryStation = a02.get_node("Entities/RecoveryStation_CP01")
	level.hero.global_position = station.global_position
	station.interact(level.hero)
	await physics_frames(2)
	check(Session.state["checkpoint_id"] == "CP01", "setup: CP01 committed before any of this test's changes")
	check(Session.get_wallet() == 0, "setup: wallet is 0 at the CP01 commit")

	# Now change everything the snapshot contract covers, all AFTER the
	# commit, so every one of these must roll back on death.
	var chip: Chip = a02.get_node("Entities/Chip_G001")
	var chip_id: String = chip.entity_id
	var chip_value: int = chip.value
	check(Session.collect(chip_id, chip_value), "collect a chip after the commit")

	Session.apply_damage(2)
	check(Session.get_health() == Session.MAX_HEALTH - 2, "take damage after the commit")

	var guard: Brawler = a02.get_node("Encounters/EncounterGroup_E01/NightGuard")
	var enemy_id: String = guard.entity_id
	Session.mark_defeated(enemy_id)
	check(Session.is_defeated(enemy_id), "defeat an enemy after the commit")

	var swap_result: Dictionary = Session.swap_weapon(PAD_ID)
	check(swap_result.get("ok", false), "flip the depot swap after the commit")
	check(Session.equipped_weapon() == "L01-W01-P02", "setup: swap actually changed the equipped instance")

	# Die: LevelDirector restores the committed snapshot and rebuilds.
	level.hero.take_damage(999, level.hero.global_position)
	await physics_frames(4)

	check(Session.state["checkpoint_id"] == "CP01", "rollback restores checkpoint_id to CP01 (got %s)" % Session.state["checkpoint_id"])
	check(Session.get_health() == Session.MAX_HEALTH, "rollback restores full health from the CP01 commit (got %d)" % Session.get_health())
	check(Session.get_wallet() == 0, "rollback restores the pre-chip wallet (got %d)" % Session.get_wallet())
	check(not Session.is_collected(chip_id), "rollback un-collects the post-commit chip")
	check(not Session.is_defeated(enemy_id), "rollback un-defeats the post-commit enemy")
	check(Session.equipped_weapon() == "L01-W01-P01", "rollback restores the pre-swap equipped weapon (got %s)" % Session.equipped_weapon())
	check(Session.weapon_on_pad(PAD_ID) == "L01-W01-P02", "rollback restores the pre-swap pad occupant")

	# World actually rebuilt (no duplicate ids, fresh objects), not just Session.
	check(level.areas.size() == 6, "rebuild still has exactly 6 areas (no duplicates)")
	check(level.get_node_or_null("AreasOld") == null, "the pre-rebuild Areas container was freed, not left as a duplicate")
	var fresh_a02: AreaRoot = level.areas[1]
	var fresh_chip: Chip = fresh_a02.get_node_or_null("Entities/Chip_G001")
	check(is_instance_valid(fresh_chip), "a fresh, uncollected Chip_G001 exists in the rebuilt A02")
	var fresh_guard: Brawler = fresh_a02.get_node_or_null("Encounters/EncounterGroup_E01/NightGuard")
	check(is_instance_valid(fresh_guard), "the rebuilt A02 has a fresh Night Guard at E01's authored (idle) placement")
	if is_instance_valid(fresh_guard):
		check(fresh_guard.health == fresh_guard.tuning.health,
				"the rebuilt Night Guard is back at full health (got %d want %d)" % [fresh_guard.health, fresh_guard.tuning.health])

	# Chip collectible again: walking onto the fresh chip collects it fresh.
	level.hero.global_position = fresh_chip.global_position
	await physics_frames(3)
	check(Session.is_collected(chip_id), "the rolled-back chip is collectible again after rebuild")
	check(Session.get_wallet() == chip_value, "collecting it again grants its value exactly once (got %d want %d)" % [Session.get_wallet(), chip_value])

	level.queue_free()
	await physics_frames(2)


# --- T12: med-patch / station reuse -----------------------------------------

func _test_care_and_station_reuse_t12() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	var a02: AreaRoot = level.areas[1]
	var capsule: MedPatch = a02.get_node("Entities/MedPatch_HS01")
	level.hero.global_position = capsule.global_position
	await physics_frames(3)
	check(not Session.is_collected(capsule.entity_id),
			"a full-health hero leaves the med-patch uncollected and in place")
	check(is_instance_valid(capsule), "the capsule node itself still exists (not freed) while full health")

	var chip: Chip = a02.get_node("Entities/Chip_G001")
	check(Session.collect(chip.entity_id, chip.value), "setup: collect a chip before the station commit")
	var enemy_id := "L01-E01-SE01-01"
	Session.mark_defeated(enemy_id)

	var station: RecoveryStation = a02.get_node("Entities/RecoveryStation_CP01")
	station.interact(level.hero)
	await physics_frames(2)
	check(Session.state["checkpoint_id"] == "CP01", "first station use commits CP01")
	var wallet_after_first := Session.get_wallet()

	# Reuse: heals/saves again, but never respawns the chip or revives the enemy.
	station.interact(level.hero)
	await physics_frames(2)
	check(Session.get_wallet() == wallet_after_first,
			"reusing the station does not respawn the already-collected chip (wallet %d -> %d)" % [wallet_after_first, Session.get_wallet()])
	check(Session.is_defeated(enemy_id), "reusing the station does not revive the defeated enemy")
	check(Session.get_health() == Session.MAX_HEALTH, "reusing the station heals to full again")
	check(Session.state["checkpoint_id"] == "CP01", "reusing the station commits again (still CP01)")

	level.queue_free()
	await physics_frames(2)


# --- T13 / T15: pad swap confirm / cancel / swap-back, post-upgrade stage -----

func _test_weapon_pad_swap_t13_t15() -> void:
	Session.new_run()
	var pad: WeaponPad = load(WEAPON_PAD_SCENE).instantiate()
	add_child(pad)
	var fake_hero := Node.new()
	add_child(fake_hero)

	check(Session.equipped_weapon() == "L01-W01-P01", "setup: P01 held, P02 resting on the pad")
	check(Session.weapon_on_pad(pad.pad_id) == "L01-W01-P02", "setup: pad occupant is P02")

	# Cancel: no change, no dialog left dangling.
	pad.interact(fake_hero)
	check(pad._dialog != null, "interacting opens a confirm dialog")
	pad._dialog._on_decline()
	check(pad._dialog == null, "declining closes the dialog")
	check(Session.equipped_weapon() == "L01-W01-P01", "cancel leaves the equipped weapon unchanged")
	check(Session.weapon_on_pad(pad.pad_id) == "L01-W01-P02", "cancel leaves the pad occupant unchanged")
	check(Session.state["world_weapons"].size() == 1, "cancel: still exactly one instance resting anywhere (no third instance)")

	# Confirm: atomic exchange.
	pad.interact(fake_hero)
	pad._dialog._on_confirm()
	check(Session.equipped_weapon() == "L01-W01-P02", "confirm equips the pad's instance (P02)")
	check(Session.weapon_on_pad(pad.pad_id) == "L01-W01-P01", "confirm drops the previously-held instance (P01) on the pad")
	check(Session.state["world_weapons"].size() == 1, "confirm: still exactly one instance resting anywhere (no third instance)")

	# T15: a purchased type-wide stage applies to whichever instance is held,
	# without a second purchase, immediately after this swap.
	Session.set_story("awakening_done", true)
	Session.state["wallet"] = 40
	var purchase: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(purchase.get("ok", false), "setup: stage-1 purchase succeeds while P02 is held")
	check(Session.weapon_stage("W01") == 1, "setup: W01 is now stage 1 (type-wide record)")

	# Swap back: same two IDs, no third instance, and the incoming pistol
	# (P01) is already fitted with the earned stage (no second purchase).
	pad.interact(fake_hero)
	pad._dialog._on_confirm()
	check(Session.equipped_weapon() == "L01-W01-P01", "swap-back re-equips the original instance (P01)")
	check(Session.weapon_on_pad(pad.pad_id) == "L01-W01-P02", "swap-back returns P02 to the pad")
	check(Session.state["world_weapons"].size() == 1, "swap-back: still exactly one instance resting anywhere (no third instance)")
	check(Session.weapon_stage(Session.weapon_type_of(Session.equipped_weapon())) == 1,
			"T15: the newly-held P01 reads the earned type-wide stage (1) without any second purchase")

	pad.queue_free()
	fake_hero.queue_free()


# --- T14: the upgrade transaction, via the real Session API -------------------

func _test_upgrade_transaction_t14() -> void:
	Session.new_run()
	var base_dir: String = CheckpointService.get_save_dir()
	var test_dir := base_dir.path_join("upgrade_t14")
	CheckpointService.set_save_dir(test_dir)
	CheckpointService.clear()

	# Locked: workbench offline before the story flag (M5's SC01; simulated here
	# per 06's M4 note, directly on Session, never via a player-facing toggle).
	var locked: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(not locked.get("ok", false) and locked.get("reason", "") == "locked",
			"purchase is refused before awakening_done (got %s)" % str(locked))

	Session.set_story("awakening_done", true)

	# Insufficient funds: no change.
	Session.state["wallet"] = 10
	var poor: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(not poor.get("ok", false) and poor.get("reason", "") == "insufficient_funds",
			"purchase is refused for insufficient funds (got %s)" % str(poor))
	check(Session.get_wallet() == 10, "insufficient-funds refusal changes nothing (wallet still 10)")
	check(Session.weapon_stage("W01") == 0, "insufficient-funds refusal changes nothing (stage still 0)")

	# Forced persistence failure: exactly no partial purchase.
	Session.state["wallet"] = 60
	CheckpointService.debug_force_write_failure(true)
	# GDScript lambdas capture outer locals BY VALUE, not by reference, so a
	# plain `bool` assigned inside the lambda would never be visible out
	# here; a one-element Array is captured by reference to the same Array
	# object, so mutating its contents does propagate.
	var save_failed_seen := [false]
	var on_save_failed := func(_reason, _cp): save_failed_seen[0] = true
	Session.save_failed.connect(on_save_failed)
	var failed_save: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	Session.save_failed.disconnect(on_save_failed)
	check(not failed_save.get("ok", false) and failed_save.get("reason", "") == "save_failed",
			"a forced persistence failure refuses the purchase (got %s)" % str(failed_save))
	check(Session.get_wallet() == 60, "a failed save leaves the wallet exactly as it was (no paid-but-missing upgrade)")
	check(Session.weapon_stage("W01") == 0, "a failed save leaves the upgrade stage exactly as it was (no free upgrade)")
	check(Session.state["checkpoint_id"] != "UPG01", "a failed save never adopts the attempted checkpoint id")
	check(save_failed_seen[0], "Session.save_failed fired for the forced failure")
	check(not CheckpointService.has_valid_save(), "a forced failure never wrote a save at all")

	# Successful purchase: atomic, complete, and persisted.
	var success: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(success.get("ok", false), "purchase succeeds once the save can go through (got %s)" % str(success))
	check(Session.get_wallet() == 20, "successful purchase deducts exactly the price (60 -> 20)")
	check(Session.weapon_stage("W01") == 1, "successful purchase records stage 1")
	check(Session.state["checkpoint_id"] == "UPG01", "successful purchase commits checkpoint UPG01")
	check(CheckpointService.has_valid_save(), "successful purchase actually persisted a save")
	var loaded := CheckpointService.load_latest()
	check(loaded.ok and int(loaded.snapshot.get("wallet", -1)) == 20,
			"the persisted save reflects the post-purchase wallet (got %s)" % str(loaded))

	# Repeat purchase: no change.
	var repeat: Dictionary = Session.purchase_upgrade("W01", 1, 40)
	check(not repeat.get("ok", false) and repeat.get("reason", "") == "already_owned",
			"repeat purchase of an already-owned stage is refused (got %s)" % str(repeat))
	check(Session.get_wallet() == 20, "repeat-purchase refusal changes nothing (wallet still 20)")

	CheckpointService.set_save_dir(base_dir)
	CheckpointService.remove_dir_recursive(test_dir)


# --- T19 / (c): CheckpointService file-level contracts -------------------------

func _test_checkpoint_service_validation_t19() -> void:
	var base_dir: String = CheckpointService.get_save_dir()
	var test_dir := base_dir.path_join("file_level_t19")
	CheckpointService.set_save_dir(test_dir)
	CheckpointService.clear()

	# Malformed JSON.
	DirAccess.make_dir_recursive_absolute(test_dir)
	var bad := FileAccess.open(test_dir.path_join("checkpoint.json"), FileAccess.WRITE)
	bad.store_string("{ not valid json ][")
	bad.close()
	var malformed := CheckpointService.load_latest()
	check(not malformed.ok, "malformed JSON is rejected, not half-loaded")
	CheckpointService.clear()

	# Wrong schema_version.
	var wrong_schema: Dictionary = Session.default_state()
	wrong_schema["schema_version"] = 999
	_write_raw(test_dir, wrong_schema)
	var schema_result := CheckpointService.load_latest()
	check(not schema_result.ok, "a save with the wrong schema_version is rejected")
	CheckpointService.clear()

	# Wrong level.
	var wrong_level: Dictionary = Session.default_state()
	wrong_level["level"] = "L02"
	_write_raw(test_dir, wrong_level)
	check(not CheckpointService.load_latest().ok, "a save for the wrong level is rejected")
	CheckpointService.clear()

	# Tampered id (a scene path where a whitelisted id belongs).
	var tampered_id: Dictionary = Session.default_state()
	tampered_id["collected"] = {"res://scenes/levels/level_01.tscn": 5}
	_write_raw(test_dir, tampered_id)
	check(not CheckpointService.load_latest().ok, "a non-whitelisted (scene-path-shaped) collected id is rejected")
	CheckpointService.clear()

	# Tampered scene-path as the equipped weapon.
	var tampered_weapon: Dictionary = Session.default_state()
	tampered_weapon["equipped_weapon"] = "res://scenes/actors/hero.tscn"
	_write_raw(test_dir, tampered_weapon)
	check(not CheckpointService.load_latest().ok, "a scene path as the equipped weapon id is rejected")
	CheckpointService.clear()

	# Primary corrupt + valid backup falls back cleanly.
	var first: Dictionary = Session.default_state()
	first["checkpoint_id"] = "CP00"
	check(CheckpointService.save_snapshot(first), "setup: first legitimate save succeeds")
	var second: Dictionary = Session.default_state()
	second["checkpoint_id"] = "CP01"
	check(CheckpointService.save_snapshot(second), "setup: second legitimate save succeeds (first becomes the backup)")
	var corrupt := FileAccess.open(test_dir.path_join("checkpoint.json"), FileAccess.WRITE)
	corrupt.store_string("{{{not json at all")
	corrupt.close()
	var fallback := CheckpointService.load_latest()
	check(fallback.ok and fallback.source == "backup",
			"a corrupt primary falls back to the valid backup (got %s)" % str(fallback))
	check(fallback.ok and String(fallback.snapshot.get("checkpoint_id", "")) == "CP00",
			"the backup is the PREVIOUS good save, not the corrupted one (got %s)" % str(fallback.snapshot.get("checkpoint_id", "")))
	CheckpointService.clear()

	# Save/load round trip equality.
	var rich: Dictionary = Session.default_state()
	rich["wallet"] = 37
	rich["health"] = 4
	rich["checkpoint_id"] = "CP02"
	rich["collected"] = {"L01-A02-G001": 1, "L01-A02-GC01": 5}
	rich["evidence"] = ["EF01"]
	rich["upgrades"] = {"W01": 1}
	rich["equipped_weapon"] = "L01-W01-P02"
	rich["world_weapons"] = {"L01-W01-P01": "L01-A05-PAD01"}
	rich["defeated"] = {"L01-E01-SE01-01": true}
	rich["switches"] = {"L01-SW01": true}
	check(CheckpointService.save_snapshot(rich), "a fully-populated snapshot saves successfully")
	var round_trip := CheckpointService.load_latest()
	check(round_trip.ok, "the fully-populated snapshot loads back successfully")
	# Dictionary/Array `==` in GDScript is a reliable deep-equality check for
	# every field EXCEPT numeric type (JSON round-trips an int as a float
	# when Godot's parser can't tell; the field-by-field checks below cover
	# the numeric fields with a value comparison instead of relying on that).
	if round_trip.ok:
		var rt: Dictionary = round_trip.snapshot
		check(int(rt.get("wallet", -1)) == 37, "round trip: wallet (got %s)" % str(rt.get("wallet")))
		check(int(rt.get("health", -1)) == 4, "round trip: health (got %s)" % str(rt.get("health")))
		check(String(rt.get("checkpoint_id", "")) == "CP02", "round trip: checkpoint_id")
		check(_int_dicts_equal(rt.get("collected", {}), rich["collected"]),
				"round trip: collected (JSON round-trips ints as floats; compared by value, not Variant type)")
		check(rt.get("evidence", []) == rich["evidence"], "round trip: evidence")
		check(_int_dicts_equal(rt.get("upgrades", {}), rich["upgrades"]), "round trip: upgrades")
		check(String(rt.get("equipped_weapon", "")) == "L01-W01-P02", "round trip: equipped_weapon")
		check(rt.get("world_weapons", {}) == rich["world_weapons"], "round trip: world_weapons")
		check(rt.get("defeated", {}) == rich["defeated"], "round trip: defeated")
		check(rt.get("switches", {}) == rich["switches"], "round trip: switches")
	CheckpointService.clear()

	CheckpointService.set_save_dir(base_dir)
	CheckpointService.remove_dir_recursive(test_dir)


## Dictionary `==` in GDScript compares VALUES by exact Variant type (int 1
## and float 1.0 are NOT equal there, unlike a bare `1 == 1.0`), and JSON
## round-trips every number as a float — so this compares int-cast values
## instead, exactly like Session._normalize_snapshot() does for a real load.
func _int_dicts_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.keys().size() != b.keys().size():
		return false
	for k in b.keys():
		if not a.has(k) or int(a[k]) != int(b[k]):
			return false
	return true


func _write_raw(dir: String, data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(dir.path_join("checkpoint.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
