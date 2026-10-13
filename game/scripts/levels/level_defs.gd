class_name LevelDefs
extends RefCounted
## The campaign's level registry (M1, C61): every playable level's LevelDef
## (scripts/levels/level_def.gd, data in data/levels/*.tres), in campaign
## order, and the rules for what carries from one level into the next.
## Static only; Session, CheckpointService, LevelDirector, Main and the tests
## all read it, so it never depends on autoload order.
##
## Carried between levels (campaign state): the held weapon's TYPE, every
## upgrade stage (`upgrades`, Scrap Plating included), the microchip wallet,
## the evidence files found, the levels completed and the story flags in
## CARRIED_STORY_FLAGS. Everything else is per level and starts fresh from
## the next level's LevelDef (Session.level_start_state()).

const FIRST_LEVEL := "L01"
## Level id -> its LevelDef resource. A level is registered here and in ORDER.
const PATHS := {
	"L01": "res://data/levels/l01.tres",
	"L02": "res://data/levels/l02.tres",
}
## Campaign order (each LevelDef's `next_level` follows it).
const ORDER: Array[String] = ["L01", "L02"]
## Weapon types Dave can carry into a level: W01 Scrapjack and, since M3, W02 Boom
## Broom (scripts/weapons/weapon_types.gd has what each one is). A save in a level may
## hold the hand instance of any of them (LevelDef.weapon_instance_sets()).
const WEAPON_TYPES: Array[String] = ["W01", "W02"]
## Story flags that matter after their level: a finished level's value is
## carried into the next level when that level's `story_defaults` has the flag.
## `awakening_done` is "Adam is awake and the campus is in lockdown".
const CARRIED_STORY_FLAGS: Array[String] = ["awakening_done"]


static func has_level(level_id: String) -> bool:
	return PATHS.has(level_id)


## The level's LevelDef, or null for an unregistered id.
static func get_def(level_id: String) -> LevelDef:
	if not PATHS.has(level_id):
		return null
	return load(PATHS[level_id]) as LevelDef


static func ids() -> Array[String]:
	return ORDER.duplicate()


## 0-based campaign position, or -1 for an unregistered id.
static func index_of(level_id: String) -> int:
	return ORDER.find(level_id)


## The level after `level_id`, or "" when there is none (or it is not registered).
static func next_of(level_id: String) -> String:
	var def := get_def(level_id)
	if def == null or not has_level(def.next_level):
		return ""
	return def.next_level


## The most microchips a wallet can hold while in `level_id`: every chip of
## that level and of the levels before it (the wallet carries over).
static func wallet_cap(level_id: String) -> int:
	var at := index_of(level_id)
	if at < 0:
		return 0
	var total := 0
	for i in at + 1:
		var def := get_def(ORDER[i])
		if def:
			total += def.chip_total
	return total


## The levels before `level_id` in campaign order.
static func levels_before(level_id: String) -> Array[String]:
	var out: Array[String] = []
	var at := index_of(level_id)
	for i in maxi(at, 0):
		out.append(ORDER[i])
	return out
