extends Node
## Session (autoload) — the authoritative value state for one run plus the
## latest committed checkpoint snapshot.
##
## Scenes read values here and request changes through the mutation methods.
## Nothing else writes into `state`. World scenes never hold saved values of
## their own: on _ready they ask Session whether they were collected/defeated.
## Rollback = LevelDirector rebuilds the fixed level after restore_committed().
##
## M4: `commit()` and `purchase_upgrade()` persist through the
## `CheckpointService` autoload (scripts/checkpoint_service.gd). Both build
## the COMPLETE new state first and only adopt it into `state`/`committed`
## after a successful save — a persistence failure never leaves a paid-but-
## missing upgrade or a checkpoint id that doesn't match what's on disk.
## `load_from_snapshot()` is Continue's counterpart to `new_run()`.
##
## Campaign (M1, C61): `state["level"]` names the level the run is in (a
## `LevelDefs` id). Every per-level field starts from that level's LevelDef
## (data/levels/*.tres); `advance_to_level()` carries the campaign state
## (held weapon type, upgrades, wallet, evidence, completed levels, the
## story flags in LevelDefs.CARRIED_STORY_FLAGS) into the next level.
##
## M3 (the Boom Broom): `state["weapon_ammo"]` holds each finite-ammunition weapon
## instance's shells, `{instance_id: {"loaded", "reserve"}}` (the Scrapjack has none). A
## physical weapon keeps its own count wherever it is (G03, S02): a swap moves nothing and
## refills nothing, a checkpoint saves it, a death rolls it back with everything else, and
## the held weapon carries its count into the next level with its type.

signal health_changed(current: int, maximum: int)
signal wallet_changed(wallet: int)
signal enemy_defeated(entity_id: String)
signal pickup_collected(entity_id: String)
signal evidence_recorded(evidence_id: String)
## Revamp (C24): a level exit door needs that level's clearance keycard.
signal keycard_taken(keycard_id: String)
signal weapon_swapped(old_id: String, new_id: String)
## M3: a finite-ammunition weapon's shells changed (the Boom Broom: `loaded` in its tube,
## `reserve`). Per instance, like its world position: see `weapon_ammo()`.
signal weapon_ammo_changed(instance_id: String, loaded: int, reserve: int)
signal upgrade_purchased(weapon_type: String, stage: int)
signal checkpoint_committed(checkpoint_id: String)
signal story_state_changed(flag: String, value: Variant)
signal switch_changed(switch_id: String, value: bool)
signal objective_changed(text: String)
signal snapshot_restored(checkpoint_id: String)
signal level_completed
## ADV-03: emitted at the end of `new_run()` (a brand-new run's "Play again"
## from the completion screen is the one case where a HUD already exists and
## is never recreated — LevelDirector rebuilds only the Areas — so nothing
## else told it the held weapon/Quickcycle pip need to go back to their
## defaults). `_emit_all()`'s health/wallet/objective signals already cover
## everything else the HUD reflects.
signal run_reset
## Emitted whenever a commit/purchase's persistence step fails (the state
## change itself is not applied — see `commit()`/`purchase_upgrade()`
## comments). `reason` is a short machine-checkable tag, not display text;
## UI composes its own "Save failed — progress since the last checkpoint is
## kept in memory only" message from this.
signal save_failed(reason: String, attempted_checkpoint_id: String)

## 3: the C33 Level 1 rebuild renamed every enemy's entity ID, so an older
## save's defeated list would name enemies that no longer exist.
## 4: the M1 campaign framework (C61): the save names any registered level,
## carries `completed_levels`, and is checked against its level's LevelDef.
const SCHEMA_VERSION := 4
const BUILD := "sunnyvale-proto-revamp"
const MAX_HEALTH := 6
## C53: Scrap Plating, the workbench's second upgrade, adds one health segment. It is kept in
## `upgrades` under its own type id beside the weapons ("A01", stage 0 or 1).
const PLATING_TYPE := "A01"
## Level 1's objective progression (05-content-and-assets.md / 03-gameplay-systems.md
## "Story states and UI"). Exactly one of these is ever `state["objective"]` in
## Level 1; its story objects (CoreNode) set them. l01.tres mirrors START and
## COMPLETE as its `objective_start`/`objective_complete` (test_campaign_flow
## checks they match); other levels take theirs from their own LevelDef.
const OBJECTIVE_START := "Reach the server depot."
const OBJECTIVE_DEPOT := "Plug into Adam's core node."
const OBJECTIVE_POST_SC01 := "Escape through the service wicket."
const OBJECTIVE_COMPLETE := "Eon City complete."

## Live run state. Read freely; mutate only through methods.
var state: Dictionary = {}
## Deep copy of the last complete commit. Never aliased with `state`.
var committed: Dictionary = {}
## Run bookkeeping that is deliberately NOT rolled back (timers, death count).
var run_meta: Dictionary = {}
## True while a noninteractive story scene (currently only SC01) is playing.
## Live-only, never persisted/rolled back — CoreNode sets this around its
## own `_run_sc01()` coroutine. PauseMenu reads it so `pause` can still open
## the menu and suspend a cutscene's own playback even though the cutscene
## has `hero.input_enabled` false the whole time it runs (ADV-01:
## story-scenes.md "Pause suspends scene playback" is distinct from `skip`,
## which is the ONLY action that ends a noninteractive scene early).
var cutscene_active: bool = false
## Live-only, never-persisted one-shot UI flags (e.g. "has this run already
## shown the E02 first-Rover tutorial prompt"), same idiom as
## `cutscene_active` above: a death/respawn rebuild mid-run must not re-show
## something already shown this run, but it must show again on a genuinely
## new run/Continue. Reset only by `new_run()`/`load_from_snapshot()`.
var runtime_flags: Dictionary = {}


func _ready() -> void:
	new_run()


func get_runtime_flag(key: String) -> bool:
	return bool(runtime_flags.get(key, false))


## Idempotent: marks `key` shown. Callers that must show something exactly
## once per run call this the moment they show it (not before), so a failed/
## aborted show can still be retried.
func set_runtime_flag(key: String) -> void:
	runtime_flags[key] = true


## A fresh start of `level_id` (default: the first level) with the default
## campaign state: no chips, no evidence, no upgrades, the starting weapon, and
## the levels before it counted as completed. New Game is `default_state()`;
## the `--level` debug flag (Main.start_level_direct()) is `default_state(id)`.
static func default_state(level_id: String = "") -> Dictionary:
	if level_id == "":
		level_id = LevelDefs.FIRST_LEVEL
	var def := LevelDefs.get_def(level_id)
	if def == null:
		push_error("Session.default_state: unknown level '%s', using %s" % [level_id, LevelDefs.FIRST_LEVEL])
		def = LevelDefs.get_def(LevelDefs.FIRST_LEVEL)
	return _level_start_state(def, {
		"wallet": 0,
		"evidence": [],
		"upgrades": {"W01": 0, PLATING_TYPE: 0},
		"weapon_type": "",
		"story": {},
		"completed_levels": LevelDefs.levels_before(def.id),
	})


## The state at the start of `next_level_id` entered from the finished state
## `from` (M1 handover). Carried: the held weapon's TYPE (the next level's
## hand instance of that type), every upgrade stage, the wallet, the evidence
## files, the completed levels plus `from`'s own level, and the story flags in
## LevelDefs.CARRIED_STORY_FLAGS. Everything else (checkpoint, health, collected
## pickups, defeated enemies, keycards, switches, world weapons, the other story
## flags, the objective, active time) starts fresh from the next LevelDef.
## Pure: touches neither `state` nor disk. {} for an unregistered level.
static func next_level_state(from: Dictionary, next_level_id: String) -> Dictionary:
	var def := LevelDefs.get_def(next_level_id)
	if def == null:
		return {}
	var completed: Array = Array(from.get("completed_levels", [])).duplicate()
	var from_level := String(from.get("level", ""))
	if LevelDefs.has_level(from_level) and not completed.has(from_level):
		completed.append(from_level)
	var upgrades := {}
	var from_upgrades: Dictionary = from.get("upgrades", {})
	for weapon_type in from_upgrades:
		upgrades[weapon_type] = int(from_upgrades[weapon_type])
	var held := String(from.get("equipped_weapon", ""))
	var from_ammo: Dictionary = from.get("weapon_ammo", {})
	return _level_start_state(def, {
		"wallet": int(from.get("wallet", 0)),
		"evidence": Array(from.get("evidence", [])),
		"upgrades": upgrades,
		"weapon_type": weapon_type_of(held),
		# M3: the held gun is the same physical gun in the next level: its shells come too.
		"hand_ammo": Dictionary(from_ammo.get(held, {})).duplicate(),
		"story": from.get("story", {}),
		"completed_levels": completed,
	})


## The one place a level's starting state is built: the campaign fields from
## `campaign`, every per-level field from `def`. Never aliases `def`'s data.
static func _level_start_state(def: LevelDef, campaign: Dictionary) -> Dictionary:
	var weapon_type := String(campaign.get("weapon_type", ""))
	if not LevelDefs.WEAPON_TYPES.has(weapon_type):
		weapon_type = weapon_type_of(def.starting_weapon)
	var upgrades: Dictionary = Dictionary(campaign.get("upgrades", {})).duplicate(true)
	var hand := def.hand_instance(weapon_type)
	# M3: shells for every finite-ammunition instance: the world weapons' authored counts
	# (LevelDef.weapon_ammo), and the hand instance's carried-in count (or a full gun).
	var ammo := start_weapon_ammo(def, upgrades)
	if WeaponTypes.uses_ammo(weapon_type):
		var stage := int(upgrades.get(weapon_type, 0))
		var full := WeaponTypes.full_ammo(weapon_type, stage)
		var carried: Dictionary = campaign.get("hand_ammo", {})
		if carried.is_empty():
			ammo[hand] = full
		else:
			ammo[hand] = {
				"loaded": clampi(int(carried.get("loaded", 0)), 0, int(full["loaded"])),
				"reserve": clampi(int(carried.get("reserve", 0)), 0, int(full["reserve"])),
			}
	var story: Dictionary = def.story_defaults.duplicate(true)
	var carried_story: Dictionary = campaign.get("story", {})
	for flag in LevelDefs.CARRIED_STORY_FLAGS:
		if story.has(flag) and carried_story.has(flag):
			story[flag] = bool(carried_story[flag])
	return {
		"schema_version": SCHEMA_VERSION,
		"build": BUILD,
		"level": def.id,
		"checkpoint_id": def.first_checkpoint,
		# Full, with Scrap Plating's extra segment when it was carried in.
		"health": MAX_HEALTH + clampi(int(upgrades.get(PLATING_TYPE, 0)), 0, 1),
		"wallet": int(campaign.get("wallet", 0)),
		# entity_id -> chip value (0 for evidence / med-patchs / caches' shells)
		"collected": {},
		"evidence": Array(campaign.get("evidence", [])).duplicate(),
		# Clearance keycards taken this level (exit locks, never inventory items).
		"keycards": [],
		# weapon type -> earned type-wide stage
		"upgrades": upgrades,
		"equipped_weapon": hand,
		# world weapon instance id -> pad id it rests on
		"world_weapons": def.world_weapons.duplicate(true),
		# M3: finite-ammunition instance id -> {"loaded", "reserve"} (the Boom Broom's shells)
		"weapon_ammo": ammo,
		"defeated": {},
		"switches": def.switches.duplicate(true),
		"story": story,
		"objective": def.objective_start,
		# The levels finished before this one, in campaign order.
		"completed_levels": Array(campaign.get("completed_levels", [])).duplicate(),
		# Mirrors `run_meta["active_seconds"]` at the moment of each commit
		# (ADV-09) so a completed save's Continue can show the real "active
		# play time" on the completion screen — `run_meta` itself is never
		# persisted/rolled back (see its own doc comment); this is only a
		# point-in-time snapshot of it taken by `commit()`/`purchase_upgrade()`.
		# Per level: it starts at 0 in every level.
		"active_seconds": 0.0,
	}


## The shells of `def`'s finite-ammunition world weapons at a fresh start of the level:
## each one's authored count (`LevelDef.weapon_ammo`), else a full gun at the earned stage.
static func start_weapon_ammo(def: LevelDef, upgrades: Dictionary) -> Dictionary:
	var ammo := {}
	for instance_id in def.world_weapons:
		var t := weapon_type_of(String(instance_id))
		if not WeaponTypes.uses_ammo(t):
			continue
		var full := WeaponTypes.full_ammo(t, int(upgrades.get(t, 0)))
		var authored: Array = def.weapon_ammo.get(instance_id, [])
		if authored.size() >= 2:
			ammo[String(instance_id)] = {
				"loaded": clampi(int(authored[0]), 0, WeaponTypes.max_capacity(t)),
				"reserve": clampi(int(authored[1]), 0, int(full["reserve"])),
			}
		else:
			ammo[String(instance_id)] = full
	return ammo


## The level the run is in now ("L01").
func current_level_id() -> String:
	return String(state.get("level", LevelDefs.FIRST_LEVEL))


## The LevelDef of the level the run is in now.
func current_level_def() -> LevelDef:
	var def := LevelDefs.get_def(current_level_id())
	return def if def else LevelDefs.get_def(LevelDefs.FIRST_LEVEL)


# --- run lifecycle ---------------------------------------------------------

## New Game (and "Play again"): a brand-new run at the first level, or at
## `level_id` with the default campaign state (the `--level` debug flag).
func new_run(level_id: String = "") -> void:
	state = default_state(level_id)
	committed = state.duplicate(true)
	run_meta = {"active_seconds": 0.0, "deaths": 0}
	cutscene_active = false
	runtime_flags = {}
	_emit_all()
	run_reset.emit()


## Adds `delta` to the run's active-play-time counter (completion screen's
## "active play time", 03-gameplay-systems.md / M5). `run_meta` is never
## rolled back by `restore_committed()` (death doesn't cost play time), and is
## reset only by `new_run()`/`load_from_snapshot()`. The CALLER decides what
## counts as "active" — LevelDirector only calls this while
## `hero.input_enabled` is true, which already excludes every modal
## (WorkbenchPanel, SwapConfirm, SC01's cutscene, the completion screen itself);
## a future pause menu (M5 part 2) should either also gate on
## `hero.input_enabled` or stop calling this while it is open.
func tick_active_time(delta: float) -> void:
	run_meta["active_seconds"] = float(run_meta.get("active_seconds", 0.0)) + delta


## Commit the complete current state as the new rollback boundary and
## persist it via CheckpointService. Only on a successful save does the
## checkpoint id actually change and `checkpoint_committed` fire; on failure
## the live `state["checkpoint_id"]` is restored to what it was before this
## call (the only field `commit()` itself changes) and `false` is returned.
## Everything else the caller already changed this run (health, wallet, ...)
## is deliberately left alone — it stays live, uncommitted, "kept in memory
## only" until a save succeeds, per health-and-checkpoints.md.
func commit(checkpoint_id: String) -> bool:
	var previous_checkpoint_id: String = state.get("checkpoint_id", "")
	var previous_active_seconds = state.get("active_seconds", 0.0)
	state["checkpoint_id"] = checkpoint_id
	# ADV-09: mirror the live run-time counter into the persisted state so a
	# completed save's Continue can show the real total (see default_state()'s
	# comment on this field). `run_meta` itself stays out of `state` normally.
	state["active_seconds"] = float(run_meta.get("active_seconds", 0.0))
	var snapshot: Dictionary = state.duplicate(true)

	var persisted := _persist(snapshot)
	if not persisted:
		state["checkpoint_id"] = previous_checkpoint_id
		state["active_seconds"] = previous_active_seconds
		save_failed.emit("save_failed", checkpoint_id)
		return false

	committed = snapshot
	checkpoint_committed.emit(checkpoint_id)
	return true


## Level handover (M1): adopt `next_level_state(state, next_level_id)` as the
## live state AND the rollback boundary, reset the run bookkeeping like a new
## run, and save it as the next level's first checkpoint. Unlike `commit()`,
## the next level is adopted even when the save fails, so the level can still
## start (kept in memory only; the save on disk stays the finished level's
## completed one, whose completion screen leads on again). Returns whether the
## save succeeded; the CALLER reports a failure (Main emits `save_failed` once
## the new level's HUD exists). An unregistered level changes nothing.
func advance_to_level(next_level_id: String) -> bool:
	var next := next_level_state(state, next_level_id)
	if next.is_empty():
		push_error("Session.advance_to_level: unknown level '%s'" % next_level_id)
		return false
	state = next
	committed = state.duplicate(true)
	run_meta = {"active_seconds": 0.0, "deaths": 0}
	cutscene_active = false
	runtime_flags = {}
	var saved := _persist(committed)
	_emit_all()
	return saved


## Replace live state with the committed snapshot. The caller (LevelDirector)
## must rebuild the level so world objects re-read Session.
func restore_committed() -> void:
	state = committed.duplicate(true)
	_emit_all()
	snapshot_restored.emit(state["checkpoint_id"])


## Continue's counterpart to `new_run()`: adopt a snapshot loaded from disk
## (e.g. `CheckpointService.load_latest().snapshot`) as both the live state
## and the new rollback boundary, and re-emit every UI-facing signal so a
## freshly built HUD/level reflects it. Does not touch the filesystem.
func load_from_snapshot(snapshot: Dictionary) -> void:
	state = _normalize_snapshot(snapshot)
	committed = state.duplicate(true)
	# ADV-09: a save made AFTER the run already finished carries its own
	# honest "active_seconds" total (mirrored in by `commit()`), which a
	# Continue on it should surface again on the completion screen
	# (LevelDirector._ready() shows it right away for `level_complete`).
	# A normal mid-run Continue starts this run's own counter fresh, same as
	# before.
	var carried_seconds := 0.0
	var story: Dictionary = state.get("story", {})
	if bool(story.get("level_complete", false)):
		carried_seconds = float(state.get("active_seconds", 0.0))
	run_meta = {"active_seconds": carried_seconds, "deaths": 0}
	runtime_flags = {}
	_emit_all()


## JSON round-trips every number as a float (Godot's JSON parser cannot
## always tell "1" was meant as an int), so a snapshot freshly loaded from
## CheckpointService can carry e.g. `health` or a chip value as `4.0` rather
## than `4`. Coerce every numeric field back to the int type the rest of
## Session assumes (`maxi()`/`mini()` and friends are typed for int) before
## adopting it as live state.
func _normalize_snapshot(raw: Dictionary) -> Dictionary:
	var out: Dictionary = raw.duplicate(true)
	out["schema_version"] = int(out.get("schema_version", SCHEMA_VERSION))
	out["health"] = int(out.get("health", MAX_HEALTH))
	out["wallet"] = int(out.get("wallet", 0))
	var collected: Dictionary = out.get("collected", {})
	for k in collected.keys():
		collected[k] = int(collected[k])
	out["collected"] = collected
	var upgrades: Dictionary = out.get("upgrades", {})
	for k in upgrades.keys():
		upgrades[k] = int(upgrades[k])
	out["upgrades"] = upgrades
	out["active_seconds"] = float(out.get("active_seconds", 0.0))
	out["keycards"] = out.get("keycards", [])
	out["completed_levels"] = out.get("completed_levels", [])
	# M3: shells as ints; a save from before M3 has none, so its finite weapons start full.
	var ammo := {}
	var raw_ammo = out.get("weapon_ammo", null)
	if typeof(raw_ammo) == TYPE_DICTIONARY:
		for k in raw_ammo:
			var e: Dictionary = raw_ammo[k]
			ammo[String(k)] = {"loaded": int(e.get("loaded", 0)), "reserve": int(e.get("reserve", 0))}
	var upgrades_now: Dictionary = out.get("upgrades", {})
	var instances: Array = [String(out.get("equipped_weapon", ""))]
	for k in Dictionary(out.get("world_weapons", {})).keys():
		instances.append(String(k))
	for instance_id in instances:
		var t := weapon_type_of(instance_id)
		if WeaponTypes.uses_ammo(t) and not ammo.has(instance_id):
			ammo[instance_id] = WeaponTypes.full_ammo(t, int(upgrades_now.get(t, 0)))
	out["weapon_ammo"] = ammo
	return out


## Routed through here (rather than calling CheckpointService directly at
## every call site) so isolated unit tests of the pure state math never need
## an autoload wired up: when CheckpointService isn't present, persistence
## trivially "succeeds" and callers behave exactly like pre-M4 in-memory-only
## Session. Every real scene has the autoload, so this only matters for a
## deliberately minimal test harness.
func _persist(snapshot: Dictionary) -> bool:
	var service := get_node_or_null("/root/CheckpointService")
	if service == null:
		return true
	return service.save_snapshot(snapshot)


func _emit_all() -> void:
	health_changed.emit(state["health"], max_health())
	wallet_changed.emit(state["wallet"])
	objective_changed.emit(state["objective"])


# --- health ------------------------------------------------------------------

func get_health() -> int:
	return state["health"]


## MAX_HEALTH, plus one with Scrap Plating fitted.
func max_health() -> int:
	return MAX_HEALTH + weapon_stage(PLATING_TYPE)


func apply_damage(amount: int) -> int:
	state["health"] = maxi(0, state["health"] - amount)
	health_changed.emit(state["health"], max_health())
	return state["health"]


## Returns the amount actually restored.
func heal(amount: int) -> int:
	var before: int = state["health"]
	state["health"] = mini(max_health(), before + amount)
	health_changed.emit(state["health"], max_health())
	return state["health"] - before


func heal_full() -> void:
	heal(max_health())


func is_full_health() -> bool:
	return state["health"] >= max_health()


# --- treasure / pickups --------------------------------------------------------

func is_collected(entity_id: String) -> bool:
	return state["collected"].has(entity_id)


## Records a one-time pickup. Returns false (and changes nothing) on repeats.
func collect(entity_id: String, chip_value: int = 0) -> bool:
	if is_collected(entity_id):
		return false
	state["collected"][entity_id] = chip_value
	pickup_collected.emit(entity_id)
	if chip_value != 0:
		state["wallet"] += chip_value
		wallet_changed.emit(state["wallet"])
	return true


func get_wallet() -> int:
	return state["wallet"]


## Unique chips found this run (independent of spending).
func chips_found() -> int:
	var total := 0
	for v in state["collected"].values():
		total += int(v)
	return total


func has_evidence(evidence_id: String) -> bool:
	return evidence_id in state["evidence"]


func record_evidence(evidence_id: String, pickup_entity_id: String) -> bool:
	if has_evidence(evidence_id):
		return false
	collect(pickup_entity_id, 0)
	state["evidence"].append(evidence_id)
	evidence_recorded.emit(evidence_id)
	return true


# --- keycards (revamp C24; level-design L01 "keycard") -------------------------

func has_keycard(keycard_id: String) -> bool:
	return keycard_id in state.get("keycards", [])


## Records the level's clearance card (and its pickup entity as collected,
## worth 0 chips). Returns false on repeats.
func take_keycard(keycard_id: String, pickup_entity_id: String) -> bool:
	if has_keycard(keycard_id):
		return false
	collect(pickup_entity_id, 0)
	if not state.has("keycards"):
		state["keycards"] = []
	state["keycards"].append(keycard_id)
	keycard_taken.emit(keycard_id)
	return true


# --- enemies -----------------------------------------------------------------

func is_defeated(entity_id: String) -> bool:
	return state["defeated"].has(entity_id)


func mark_defeated(entity_id: String) -> void:
	if is_defeated(entity_id):
		return
	state["defeated"][entity_id] = true
	enemy_defeated.emit(entity_id)


# --- switches / story / objective -------------------------------------------------

func get_switch(switch_id: String) -> bool:
	return state["switches"].get(switch_id, false)


func set_switch(switch_id: String, value: bool) -> void:
	if get_switch(switch_id) == value:
		return
	state["switches"][switch_id] = value
	switch_changed.emit(switch_id, value)


func get_story(flag: String) -> Variant:
	return state["story"].get(flag)


func set_story(flag: String, value: Variant) -> void:
	if state["story"].get(flag) == value:
		return
	state["story"][flag] = value
	story_state_changed.emit(flag, value)


func get_objective() -> String:
	return state["objective"]


func set_objective(text: String) -> void:
	if state["objective"] == text:
		return
	state["objective"] = text
	objective_changed.emit(text)


# --- weapons -----------------------------------------------------------------

func equipped_weapon() -> String:
	return state["equipped_weapon"]


## Weapon type from an instance id such as "L01-W01-P02" -> "W01".
static func weapon_type_of(instance_id: String) -> String:
	var parts := instance_id.split("-")
	return parts[1] if parts.size() >= 3 else ""


## Earned type-wide stage; any instance of that type is fitted to it.
func weapon_stage(weapon_type: String) -> int:
	return int(state["upgrades"].get(weapon_type, 0))


## The held weapon's type ("W01", "W02").
func held_weapon_type() -> String:
	return weapon_type_of(equipped_weapon())


# --- ammunition (M3: finite weapons only, per instance) --------------------------------

## True when `instance_id` is a finite-ammunition instance with a shell count here.
func has_ammo(instance_id: String) -> bool:
	return Dictionary(state.get("weapon_ammo", {})).has(instance_id)


## `{"loaded", "reserve"}` of a finite-ammunition instance (a copy), or {} for an
## unlimited one (the Scrapjack).
func weapon_ammo(instance_id: String) -> Dictionary:
	var e: Dictionary = Dictionary(state.get("weapon_ammo", {})).get(instance_id, {})
	return {"loaded": int(e["loaded"]), "reserve": int(e["reserve"])} if not e.is_empty() else {}


## The held weapon's shells ({} for an unlimited weapon).
func held_ammo() -> Dictionary:
	return weapon_ammo(equipped_weapon())


## Sets a finite-ammunition instance's shells (the gun spends and feeds them), clamped to
## its tube at the earned stage and to the reserve's size. A live change like a swap: it
## is saved with the next checkpoint and rolls back with a death. Ignored for an instance
## that has no count (an unlimited weapon).
func set_weapon_ammo(instance_id: String, loaded: int, reserve: int) -> void:
	if not has_ammo(instance_id):
		return
	var t := weapon_type_of(instance_id)
	var e := {
		"loaded": clampi(loaded, 0, maxi(WeaponTypes.capacity(t, weapon_stage(t)), int(state["weapon_ammo"][instance_id]["loaded"]))),
		"reserve": clampi(reserve, 0, WeaponTypes.reserve_capacity(t)),
	}
	if e == state["weapon_ammo"][instance_id]:
		return
	var ammo: Dictionary = Dictionary(state["weapon_ammo"]).duplicate(true)
	ammo[instance_id] = e
	state["weapon_ammo"] = ammo
	weapon_ammo_changed.emit(instance_id, int(e["loaded"]), int(e["reserve"]))


## Station service (S02: a recovery station or the workbench fills the carried shotgun's
## tube and reserve): the held weapon full at its earned stage. True when it changed
## anything (never for an unlimited weapon).
func refill_held_weapon() -> bool:
	var held := equipped_weapon()
	var t := weapon_type_of(held)
	if not has_ammo(held):
		return false
	var full := WeaponTypes.full_ammo(t, weapon_stage(t))
	var before := weapon_ammo(held)
	set_weapon_ammo(held, int(full["loaded"]), int(full["reserve"]))
	return weapon_ammo(held) != before


func weapon_on_pad(pad_id: String) -> String:
	for instance_id in state["world_weapons"]:
		if state["world_weapons"][instance_id] == pad_id:
			return instance_id
	return ""


## Atomic exchange (weapon-swaps.md "atomic exchange"): the currently
## equipped instance and the instance resting on `pad_id` trade places.
## Never creates a third instance and never touches ammo/heat/health: each
## instance keeps its own shells in `weapon_ammo` (M3), so the Boom Broom left
## on the pad still has what it had, and swapping back refills nothing. Works
## across types (the Scrapjack for the Boom Broom in Level 2's A01).
## `{ok, reason, old_id, new_id}`. This is a live-state change only — it is
## NOT committed/persisted here; it rolls back with the next
## `restore_committed()` like any other uncommitted change, per
## weapon-swaps.md "Checkpoints and one-way exits".
func swap_weapon(pad_id: String) -> Dictionary:
	var resting_id := weapon_on_pad(pad_id)
	if resting_id == "":
		return {"ok": false, "reason": "empty_pad", "old_id": "", "new_id": ""}

	var held_id: String = state["equipped_weapon"]
	var world_weapons: Dictionary = state["world_weapons"].duplicate(true)
	world_weapons.erase(resting_id)
	world_weapons[held_id] = pad_id
	state["world_weapons"] = world_weapons
	state["equipped_weapon"] = resting_id

	weapon_swapped.emit(held_id, resting_id)
	return {"ok": true, "reason": "", "old_id": held_id, "new_id": resting_id}


## Workbench purchase transaction (upgrades-and-ownership.md "Transaction flow",
## 03-gameplay-systems.md "Workbench flow"). Preconditions checked against the
## LIVE state; on any refusal `state` is untouched and `{ok:false, reason}`
## explains why (`"locked"`, `"insufficient_funds"`, `"already_owned"`,
## `"invalid_stage"`). On success this ALSO commits a complete snapshot
## (checkpoint id `"UPG01"`, respawn at the workbench) through the same
## persist-then-adopt path as `commit()` — everything paid for, fitted, and
## saved together, or (on a save failure) none of it: `state` is only ever
## mutated after `CheckpointService.save_snapshot()` returns true, so a
## failed save leaves the wallet, upgrades and checkpoint id byte-for-byte
## as they were before this call (`{ok:false, reason:"save_failed"}`).
func purchase_upgrade(weapon_type: String, target_stage: int, price: int) -> Dictionary:
	if get_story("awakening_done") != true:
		return {"ok": false, "reason": "locked"}

	var current_stage := weapon_stage(weapon_type)
	if target_stage <= current_stage:
		return {"ok": false, "reason": "already_owned"}
	if target_stage != current_stage + 1:
		return {"ok": false, "reason": "invalid_stage"}
	if state["wallet"] < price:
		return {"ok": false, "reason": "insufficient_funds"}

	var candidate: Dictionary = state.duplicate(true)
	candidate["wallet"] = int(candidate["wallet"]) - price
	var upgrades: Dictionary = candidate["upgrades"].duplicate(true)
	upgrades[weapon_type] = target_stage
	candidate["upgrades"] = upgrades
	# Scrap Plating comes fitted with its new segment full.
	if weapon_type == PLATING_TYPE:
		candidate["health"] = int(candidate["health"]) + (target_stage - current_stage)
	candidate["checkpoint_id"] = "UPG01"
	candidate["active_seconds"] = float(run_meta.get("active_seconds", 0.0))

	if not _persist(candidate):
		save_failed.emit("save_failed", "UPG01")
		return {"ok": false, "reason": "save_failed"}

	state = candidate
	committed = candidate.duplicate(true)
	wallet_changed.emit(state["wallet"])
	upgrade_purchased.emit(weapon_type, target_stage)
	if weapon_type == PLATING_TYPE:
		health_changed.emit(state["health"], max_health())
	checkpoint_committed.emit("UPG01")
	return {"ok": true, "reason": ""}
