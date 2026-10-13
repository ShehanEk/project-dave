extends Node
## CheckpointService (autoload) — versioned JSON persistence for the one
## campaign save slot under user:// (see 04-godot-architecture.md "Save
## design"). Since M1 (C61) a save may be in any level the `LevelDefs`
## registry lists; its ids, checkpoints, weapons, pads and story flags are
## checked against THAT level's LevelDef (data/levels/*.tres).
##
## Layout under `_save_dir` (default "user://sunnyvale"):
##   checkpoint.json      — last known-good primary save
##   checkpoint.bak.json   — the primary immediately before the last replace
##   (settings.json is a SEPARATE file this service does not touch; a later
##   milestone owns it.)
##
## `save_snapshot()` never trusts a write until it has re-read and
## re-validated the bytes it just wrote, and never destroys the previous
## good primary until the new file is confirmed good — so a crash or a
## simulated failure at any point leaves either the old primary+backup pair
## or the new primary+backup pair intact, never a half-written file treated
## as valid. `load_latest()` falls back to the backup on any primary
## problem and never returns a partially-applied snapshot: a rejected file
## is rejected whole.
##
## Test hooks (never used in normal play): `set_save_dir(path)` redirects
## every read/write below a throwaway user:// folder; `debug_force_write_failure(true)`
## makes exactly the next `save_snapshot()` fail without touching disk.

const DEFAULT_SAVE_DIR := "user://sunnyvale"
const CHECKPOINT_FILE := "checkpoint.json"
const BACKUP_FILE := "checkpoint.bak.json"
const TEMP_FILE := "checkpoint.tmp.json"
## Settings (M5 part 2, interface-and-accessibility.md): a SEPARATE file this
## service never mixes into the checkpoint/backup pair above — a corrupt or
## missing settings file never affects save validity and vice versa. No
## versioned schema/whitelist here (unlike the checkpoint): a missing/invalid
## key just falls back to Settings.DEFAULTS, never a hard failure.
const SETTINGS_FILE := "settings.json"
## C53: the player's best completed run (rank points and time), beside the settings.
const RECORDS_FILE := "records.json"

## Kept in sync with Session's own constants (session.gd). Not read directly
## from Session so this file's validation never depends on autoload order
## (the level data comes from the static LevelDefs registry for the same reason).
## 4 since M1 (C61); older saves are rejected (Continue stays off until a new run).
const SCHEMA_VERSION := 4
const MAX_HEALTH := 6
const MAX_OBJECTIVE_LEN := 300

## Every top-level key `Session.default_state()` produces, and no others — an
## extra key (e.g. a stray res:// scene path stashed by a tampered file) is
## rejected outright (ADV-07).
const ALLOWED_TOP_KEYS: Array[String] = ["schema_version", "build", "level",
		"checkpoint_id", "health", "wallet", "collected", "evidence", "keycards",
		"upgrades", "equipped_weapon", "world_weapons", "defeated",
		"switches", "story", "objective", "completed_levels", "active_seconds",
		"weapon_ammo"]
## Per level (from its LevelDef, ADV-07): the checkpoint ids are its
## `checkpoint_markers` keys; the weapon instances are exactly one of
## `LevelDef.weapon_instance_sets(LevelDefs.WEAPON_TYPES)` (the hand instance of
## a carried-in type plus the world weapons), each exactly once, held or on one
## of its pads, never both, never neither, never a third id; the story flags are
## its `story_defaults` keys (M5: a flag added since the save was made may be missing,
## and loads as its default; an unknown flag never); and the wallet can never exceed
## `LevelDefs.wallet_cap(level)` (every chip of this level and the ones before it).
## Only stage 1 of a weapon (the Quickcycle, the Extended Tube) is purchasable so
## far (stage 2 waits for the Peacekeeper in Level 3, WeaponTypes.STAGE_GATES) —
## no upgrade field may ever record more than that (ADV-07).
const MAX_WEAPON_STAGE := 1
## M3: `weapon_ammo` ({instance id: {"loaded", "reserve"}}) may be missing (a save made
## before the Boom Broom; Session fills its finite weapons full on load). When present
## it may only name the level's finite-ammunition instances (WeaponTypes.uses_ammo), with
## whole counts from 0 to the tube's largest size and the reserve's size.
const AMMO_KEYS: Array[String] = ["loaded", "reserve"]

var _save_dir: String = DEFAULT_SAVE_DIR
var _force_next_write_failure: bool = false

var _re_weapon_type: RegEx
var _re_evidence: RegEx
var _re_level_id: RegEx
## Level id -> {"switch", "keycard", "generic"} RegExes for that level's prefix.
var _level_res: Dictionary = {}


func _ready() -> void:
	_ensure_regexes()


func _ensure_regexes() -> void:
	if _re_weapon_type != null:
		return
	_re_weapon_type = _compile("^(W[0-9]{2}|A01)$")  # weapons, and A01 Scrap Plating (C53)
	_re_evidence = _compile("^EF[0-9]{2}$")
	_re_level_id = _compile("^L[0-9]{2}$")


## The id patterns of one registered level, compiled once. Only the level's own
## prefix is accepted: a save in L02 never names an L01 pickup or enemy (every
## per-level field starts fresh in each level), and an unknown prefix never
## validates. {} for an unregistered or malformed level id.
func _level_regexes(level_id: String) -> Dictionary:
	if _level_res.has(level_id):
		return _level_res[level_id]
	_ensure_regexes()
	if not LevelDefs.has_level(level_id) or not _re_level_id.search(level_id):
		return {}
	var res := {
		"switch": _compile("^%s-SW[0-9]{2}$" % level_id),
		"keycard": _compile("^%s-KC[0-9]{2}$" % level_id),
		# Every other whitelisted id (chips, clusters, caches, capsules, enemies,
		# pads, consoles, ...): the level id then one or more "-UPPERCASE0-9"
		# segments. Never matches a scene path (lowercase/"res://"/"/") or a
		# bare node name.
		"generic": _compile("^%s(-[A-Z0-9]+)+$" % level_id),
	}
	_level_res[level_id] = res
	return res


func _compile(pattern: String) -> RegEx:
	var re := RegEx.new()
	var err := re.compile(pattern)
	if err != OK:
		push_error("CheckpointService: bad regex %s" % pattern)
	return re


# --- test hooks --------------------------------------------------------------

func set_save_dir(path: String) -> void:
	_save_dir = path


func get_save_dir() -> String:
	return _save_dir


func debug_force_write_failure(force: bool = true) -> void:
	_force_next_write_failure = force


# --- paths -------------------------------------------------------------------

func _checkpoint_path() -> String:
	return _save_dir.path_join(CHECKPOINT_FILE)


func _backup_path() -> String:
	return _save_dir.path_join(BACKUP_FILE)


func _temp_path() -> String:
	return _save_dir.path_join(TEMP_FILE)


func _settings_path() -> String:
	return _save_dir.path_join(SETTINGS_FILE)


func _ensure_dir() -> bool:
	if DirAccess.dir_exists_absolute(_save_dir):
		return true
	return DirAccess.make_dir_recursive_absolute(_save_dir) == OK


# --- public API ----------------------------------------------------------------

func has_valid_save() -> bool:
	return load_latest().ok


## Removes every file this service owns under `_save_dir` (not the directory
## itself). Used by New Game and by tests cleaning up their throwaway dir.
func clear() -> void:
	for p in [_checkpoint_path(), _backup_path(), _temp_path()]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


## Validates `snapshot`, writes it durably, and only then makes it the new
## primary save. Returns false (and changes nothing on disk beyond a
## discarded temp file) on any validation or I/O problem.
func save_snapshot(snapshot: Dictionary) -> bool:
	var validation := validate_snapshot(snapshot)
	if not validation.ok:
		push_error("CheckpointService.save_snapshot: refusing invalid snapshot (%s)" % validation.error)
		return false

	if _force_next_write_failure:
		_force_next_write_failure = false
		push_error("CheckpointService.save_snapshot: forced failure (test hook)")
		return false

	if not _ensure_dir():
		push_error("CheckpointService.save_snapshot: could not create save dir %s" % _save_dir)
		return false

	var json_text := JSON.stringify(snapshot, "\t")
	var temp_path := _temp_path()

	var writer := FileAccess.open(temp_path, FileAccess.WRITE)
	if writer == null:
		push_error("CheckpointService.save_snapshot: open-for-write failed (%s)" % error_string(FileAccess.get_open_error()))
		return false
	writer.store_string(json_text)
	writer.close()

	# Re-read and re-validate the exact bytes now on disk before trusting them.
	var reader := FileAccess.open(temp_path, FileAccess.READ)
	if reader == null:
		push_error("CheckpointService.save_snapshot: re-open-for-read failed after write")
		return false
	var round_trip_text := reader.get_as_text()
	reader.close()
	var parsed = JSON.parse_string(round_trip_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("CheckpointService.save_snapshot: round-trip parse failed, discarding temp file")
		DirAccess.remove_absolute(temp_path)
		return false
	var round_trip_validation := validate_snapshot(parsed)
	if not round_trip_validation.ok:
		push_error("CheckpointService.save_snapshot: round-trip validation failed (%s)" % round_trip_validation.error)
		DirAccess.remove_absolute(temp_path)
		return false

	var primary_path := _checkpoint_path()
	var backup_path := _backup_path()

	# Preserve the previous good primary as the backup BEFORE replacing it —
	# but only when that primary is ITSELF a valid, loadable snapshot
	# (ADV-08). Rotating a corrupt/truncated primary over the backup would
	# destroy the one remaining last-known-good copy on the very next save,
	# leaving nothing to fall back to; when the primary is bad, the existing
	# backup (already the actual last-known-good file) is left untouched.
	if FileAccess.file_exists(primary_path) and _try_load(primary_path).ok:
		if FileAccess.file_exists(backup_path):
			DirAccess.remove_absolute(backup_path)
		var copy_err := DirAccess.copy_absolute(primary_path, backup_path)
		if copy_err != OK:
			push_error("CheckpointService.save_snapshot: could not preserve backup (%s)" % error_string(copy_err))
			DirAccess.remove_absolute(temp_path)
			return false

	# Only now replace the primary with the verified temp file.
	if FileAccess.file_exists(primary_path):
		DirAccess.remove_absolute(primary_path)
	var rename_err := DirAccess.rename_absolute(temp_path, primary_path)
	if rename_err != OK:
		push_error("CheckpointService.save_snapshot: could not install new primary (%s)" % error_string(rename_err))
		return false
	return true


## {ok, snapshot, source ("primary"/"backup"/""), error}. Never returns a
## half-loaded snapshot: a rejected file falls all the way through to the
## backup, and a rejected backup leaves `ok=false` with `snapshot={}`.
func load_latest() -> Dictionary:
	var primary := _try_load(_checkpoint_path())
	if primary.ok:
		return {"ok": true, "snapshot": primary.snapshot, "source": "primary", "error": ""}
	var backup := _try_load(_backup_path())
	if backup.ok:
		return {"ok": true, "snapshot": backup.snapshot, "source": "backup", "error": ""}
	var error_msg: String = primary.error
	if backup.error != "" and backup.error != "missing":
		error_msg += "; backup: %s" % backup.error
	if error_msg == "":
		error_msg = "no save found"
	return {"ok": false, "snapshot": {}, "source": "", "error": error_msg}


func _try_load(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "snapshot": {}, "error": "missing"}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"ok": false, "snapshot": {}, "error": "open failed (%s)" % error_string(FileAccess.get_open_error())}
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "snapshot": {}, "error": "malformed JSON"}
	var validation := validate_snapshot(parsed)
	if not validation.ok:
		return {"ok": false, "snapshot": {}, "error": validation.error}
	return {"ok": true, "snapshot": parsed, "error": ""}


# --- validation ----------------------------------------------------------------

## {ok, error}. Rejects anything that is not the complete, correctly-typed,
## whitelisted-ID shape Session.default_state() produces: wrong schema
## version, wrong level, an out-of-range value, a non-whitelisted id string
## (this is what stops a scene path or a stray node-ref-shaped string from a
## tampered file), or a missing/extra field.
func validate_snapshot(data: Variant) -> Dictionary:
	_ensure_regexes()
	if typeof(data) != TYPE_DICTIONARY:
		return {"ok": false, "error": "not a dictionary"}

	for k in data.keys():
		if typeof(k) != TYPE_STRING or not ALLOWED_TOP_KEYS.has(String(k)):
			return {"ok": false, "error": "unexpected top-level field '%s'" % str(k)}

	if not _check_int(data, "schema_version"):
		return {"ok": false, "error": "schema_version: wrong type"}
	if int(data["schema_version"]) != SCHEMA_VERSION:
		return {"ok": false, "error": "wrong schema_version"}

	if not _check_string(data, "build"):
		return {"ok": false, "error": "build: wrong type"}

	if not _check_string(data, "level"):
		return {"ok": false, "error": "level: wrong type"}
	var level := String(data["level"])
	var def := LevelDefs.get_def(level)
	var level_res := _level_regexes(level)
	if def == null or level_res.is_empty():
		return {"ok": false, "error": "wrong level"}
	var re_generic: RegEx = level_res["generic"]

	if not _check_string(data, "checkpoint_id"):
		return {"ok": false, "error": "checkpoint_id: wrong type"}
	if not def.checkpoint_markers.has(String(data["checkpoint_id"])):
		return {"ok": false, "error": "checkpoint_id: not whitelisted"}

	if not _check_int(data, "health"):
		return {"ok": false, "error": "health: wrong type"}
	var health := int(data["health"])
	# A committed checkpoint can never be dead (ADV-07): 0 would leave the
	# hero permanently undamageable (Hero.take_damage() treats 0 as "already
	# dying"), so the valid range starts at 1, not 0.
	# Scrap Plating (upgrades "A01", C53) adds one segment.
	var plating := 0
	if typeof(data.get("upgrades")) == TYPE_DICTIONARY and data["upgrades"].has("A01"):
		plating = clampi(int(data["upgrades"]["A01"]), 0, 1)
	if health < 1 or health > MAX_HEALTH + plating:
		return {"ok": false, "error": "health: out of range"}

	if not _check_int(data, "wallet"):
		return {"ok": false, "error": "wallet: wrong type"}
	# Compare as float BEFORE casting to int: a huge tampered value (e.g.
	# 1e300) is well outside int64 range and must be rejected on its own
	# terms, never narrowed/clamped by the cast first (ADV-07).
	var wallet_f := float(data["wallet"])
	if wallet_f < 0.0 or wallet_f > float(LevelDefs.wallet_cap(level)):
		return {"ok": false, "error": "wallet: out of range"}

	var collected_check := _check_id_value_dict(data.get("collected"), re_generic, TYPE_INT)
	if not collected_check.ok:
		return {"ok": false, "error": "collected: %s" % collected_check.error}
	for v in data["collected"].values():
		if int(v) < 0:
			return {"ok": false, "error": "collected: negative value"}

	if typeof(data.get("evidence")) != TYPE_ARRAY:
		return {"ok": false, "error": "evidence: wrong type"}
	for entry in data["evidence"]:
		if typeof(entry) != TYPE_STRING or not _re_evidence.search(String(entry)):
			return {"ok": false, "error": "evidence: non-whitelisted id"}

	if typeof(data.get("keycards")) != TYPE_ARRAY:
		return {"ok": false, "error": "keycards: wrong type"}
	for entry in data["keycards"]:
		if typeof(entry) != TYPE_STRING or not (level_res["keycard"] as RegEx).search(String(entry)):
			return {"ok": false, "error": "keycards: non-whitelisted id"}

	var upgrades_check := _check_id_value_dict(data.get("upgrades"), _re_weapon_type, TYPE_INT)
	if not upgrades_check.ok:
		return {"ok": false, "error": "upgrades: %s" % upgrades_check.error}
	for stage in data["upgrades"].values():
		if int(stage) < 0 or int(stage) > MAX_WEAPON_STAGE:
			return {"ok": false, "error": "upgrades: stage out of range"}

	if not _check_string(data, "equipped_weapon"):
		return {"ok": false, "error": "equipped_weapon: wrong type"}
	var equipped := String(data["equipped_weapon"])
	var instance_sets: Array = def.weapon_instance_sets(LevelDefs.WEAPON_TYPES)
	var known_instances: Array = []
	for instance_set in instance_sets:
		for instance_id in instance_set:
			if not known_instances.has(instance_id):
				known_instances.append(instance_id)
	if not known_instances.has(equipped):
		return {"ok": false, "error": "equipped_weapon: not whitelisted"}

	if typeof(data.get("world_weapons")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "world_weapons: wrong type"}
	var pads := def.weapon_pads()
	var world_instances: Array = []
	for k in data["world_weapons"].keys():
		if typeof(k) != TYPE_STRING or not known_instances.has(String(k)):
			return {"ok": false, "error": "world_weapons: non-whitelisted instance id"}
		world_instances.append(String(k))
		var v = data["world_weapons"][k]
		if typeof(v) != TYPE_STRING or not pads.has(String(v)):
			return {"ok": false, "error": "world_weapons: non-whitelisted pad id"}
	# Exactly one held instance plus world_weapons must together account for
	# every instance of ONE of the level's instance sets exactly once — never a
	# duplicate (the same instance both held and resting on a pad), never one
	# missing (deleted from the world), never a third instance smuggled in
	# (ADV-07).
	var accounted: Array = [equipped]
	accounted.append_array(world_instances)
	var matched := false
	var size_matched := false
	for instance_set in instance_sets:
		if accounted.size() != instance_set.size():
			continue
		size_matched = true
		var all_once := true
		for instance_id in instance_set:
			if accounted.count(instance_id) != 1:
				all_once = false
				break
		if all_once:
			matched = true
			break
	if not size_matched:
		return {"ok": false, "error": "world_weapons: instance count mismatch"}
	if not matched:
		return {"ok": false, "error": "world_weapons: the level's instances are not each accounted for exactly once"}

	if data.has("weapon_ammo"):
		var ammo_check := _check_weapon_ammo(data["weapon_ammo"], accounted)
		if not ammo_check.ok:
			return {"ok": false, "error": "weapon_ammo: %s" % ammo_check.error}

	if typeof(data.get("defeated")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "defeated: wrong type"}
	for k in data["defeated"].keys():
		if typeof(k) != TYPE_STRING or not re_generic.search(String(k)):
			return {"ok": false, "error": "defeated: non-whitelisted id"}
		if typeof(data["defeated"][k]) != TYPE_BOOL:
			return {"ok": false, "error": "defeated: wrong value type"}

	if typeof(data.get("switches")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "switches: wrong type"}
	for k in data["switches"].keys():
		if typeof(k) != TYPE_STRING or not (level_res["switch"] as RegEx).search(String(k)):
			return {"ok": false, "error": "switches: non-whitelisted id"}
		if typeof(data["switches"][k]) != TYPE_BOOL:
			return {"ok": false, "error": "switches: wrong value type"}

	if typeof(data.get("story")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "story: wrong type"}
	var story: Dictionary = data["story"]
	# M5: a save made before the level gained a flag simply lacks it (Session's load
	# gives it the level's default); a flag the level does not know is never accepted.
	for flag in story.keys():
		if typeof(flag) != TYPE_STRING or not def.story_defaults.has(flag):
			return {"ok": false, "error": "story: unexpected flag set"}
		if typeof(story[flag]) != TYPE_BOOL:
			return {"ok": false, "error": "story: missing/invalid flag %s" % flag}

	if not _check_string(data, "objective"):
		return {"ok": false, "error": "objective: wrong type"}
	if String(data["objective"]).length() > MAX_OBJECTIVE_LEN:
		return {"ok": false, "error": "objective: too long"}

	# M1: the levels finished before this one, each a registered level that
	# comes earlier in the campaign, at most once.
	if typeof(data.get("completed_levels")) != TYPE_ARRAY:
		return {"ok": false, "error": "completed_levels: wrong type"}
	var level_index := LevelDefs.index_of(level)
	var seen_levels: Array = []
	for entry in data["completed_levels"]:
		if typeof(entry) != TYPE_STRING or not LevelDefs.has_level(String(entry)):
			return {"ok": false, "error": "completed_levels: non-whitelisted level id"}
		if LevelDefs.index_of(String(entry)) >= level_index or seen_levels.has(String(entry)):
			return {"ok": false, "error": "completed_levels: not a distinct earlier level"}
		seen_levels.append(String(entry))

	# ADV-09: the point-in-time mirror of run_meta["active_seconds"] Session
	# writes in on each commit.
	if not _check_int(data, "active_seconds"):
		return {"ok": false, "error": "active_seconds: wrong type"}
	if float(data["active_seconds"]) < 0.0:
		return {"ok": false, "error": "active_seconds: negative"}

	return {"ok": true, "error": ""}


## M3: every key one of `instances` (this save's held and resting weapons) of a finite-
## ammunition type, every value exactly {"loaded", "reserve"} with whole counts in range.
func _check_weapon_ammo(value: Variant, instances: Array) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "wrong type"}
	for k in value.keys():
		if typeof(k) != TYPE_STRING or not instances.has(String(k)):
			return {"ok": false, "error": "non-whitelisted instance id '%s'" % str(k)}
		var t := String(k).split("-")[1] if String(k).split("-").size() >= 3 else ""
		if not WeaponTypes.uses_ammo(t):
			return {"ok": false, "error": "'%s' carries no ammunition" % str(k)}
		var e = value[k]
		if typeof(e) != TYPE_DICTIONARY or e.size() != AMMO_KEYS.size():
			return {"ok": false, "error": "wrong entry for '%s'" % str(k)}
		for field in AMMO_KEYS:
			if not _check_int(e, field):
				return {"ok": false, "error": "%s.%s: wrong type" % [str(k), field]}
			var f := float(e[field])
			if f != floorf(f) or f < 0.0:
				return {"ok": false, "error": "%s.%s: not a whole count" % [str(k), field]}
		if float(e["loaded"]) > float(WeaponTypes.max_capacity(t)) or float(e["reserve"]) > float(WeaponTypes.reserve_capacity(t)):
			return {"ok": false, "error": "%s: out of range" % str(k)}
	return {"ok": true, "error": ""}


func _check_int(data: Dictionary, key: String) -> bool:
	return data.has(key) and (typeof(data[key]) == TYPE_INT or typeof(data[key]) == TYPE_FLOAT)


func _check_string(data: Dictionary, key: String) -> bool:
	return data.has(key) and typeof(data[key]) == TYPE_STRING


## Every key must match `id_pattern` (a String) and every value must be
## `value_type` (TYPE_INT accepts a JSON float too, since JSON has one
## numeric type and Godot's JSON parser hands ints back as float).
func _check_id_value_dict(value: Variant, id_pattern: RegEx, value_type: int) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {"ok": false, "error": "wrong type"}
	var dict: Dictionary = value
	for k in dict.keys():
		if typeof(k) != TYPE_STRING or not id_pattern.search(String(k)):
			return {"ok": false, "error": "non-whitelisted id '%s'" % str(k)}
		var v = dict[k]
		var ok_type := typeof(v) == value_type
		if value_type == TYPE_INT and typeof(v) == TYPE_FLOAT:
			ok_type = true
		if not ok_type:
			return {"ok": false, "error": "wrong value type for '%s'" % str(k)}
	return {"ok": true, "error": ""}


## Writes `data` (a plain, JSON-safe Dictionary — see Settings.DEFAULTS'
## shape) to the separate settings file. No temp-write/backup dance (unlike
## `save_snapshot`): losing a settings write just falls back to defaults next
## boot, never breaks a checkpoint. Returns false only on an I/O error.
func save_settings(data: Dictionary) -> bool:
	if not _ensure_dir():
		push_error("CheckpointService.save_settings: could not create save dir %s" % _save_dir)
		return false
	var writer := FileAccess.open(_settings_path(), FileAccess.WRITE)
	if writer == null:
		push_error("CheckpointService.save_settings: open-for-write failed (%s)" % error_string(FileAccess.get_open_error()))
		return false
	writer.store_string(JSON.stringify(data, "\t"))
	writer.close()
	return true


## Returns the saved settings Dictionary, or `{}` if none exists / the file
## is unreadable or malformed (the caller — Settings — merges this over its
## own defaults, so a missing/partial file is never an error the player sees).
func load_settings() -> Dictionary:
	var path := _settings_path()
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


## C53: the best-run record ({"points": int, "seconds": float, "rank": String}), or {}.
## One per level (M1): the first level keeps RECORDS_FILE, every later level has
## its own `records_<id>.json` beside it.
func load_records(level_id: String = "") -> Dictionary:
	var path := _records_path(level_id)
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func save_records(data: Dictionary, level_id: String = "") -> bool:
	if not _ensure_dir():
		return false
	var writer := FileAccess.open(_records_path(level_id), FileAccess.WRITE)
	if writer == null:
		return false
	writer.store_string(JSON.stringify(data, "\t"))
	writer.close()
	return true


func _records_path(level_id: String) -> String:
	if level_id == "" or level_id == LevelDefs.FIRST_LEVEL:
		return _save_dir.path_join(RECORDS_FILE)
	return _save_dir.path_join("records_%s.json" % level_id.to_lower().validate_filename())


## Recursively deletes everything under `path`, including `path` itself.
## Used by tests to clean up their throwaway save directories.
static func remove_dir_recursive(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry != "." and entry != "..":
			var full := path.path_join(entry)
			if dir.current_is_dir():
				remove_dir_recursive(full)
			else:
				DirAccess.remove_absolute(full)
		entry = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)
