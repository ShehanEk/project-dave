class_name WeaponTypes
extends RefCounted
## The weapon types Dave can carry (M3): what the hero, the HUD, the swap pad, the
## workbench and the save checks need to know about each one. Static only, like
## LevelDefs, so nothing here depends on autoload order. Which types a save may
## carry into a level is LevelDefs.WEAPON_TYPES; this is the data behind them.
##
##   W01 Scrapjack   unlimited bolts, no magazine (scrapjack.gd, w01_scrapjack.tres)
##   W02 Boom Broom  pump shotgun: a tube of shells plus a reserve (boom_broom.gd,
##                   w02_boom_broom.tres, a ShotgunTuning)
##
## Upgrades belong to the type (Session.weapon_stage(type)): three cumulative stages,
## 40 / 90 / 160 microchips (upgrades-and-ownership.md, S04). Only stage 1 can be bought
## so far (CheckpointService.MAX_WEAPON_STAGE): stage 2 opens after the Peacekeeper
## (Level 3), stage 3 after Howard Stroud (Level 6).

const INFO := {
	"W01": {
		"name": "Scrapjack",
		"node": "Scrapjack",
		"scene": "res://scenes/weapons/scrapjack.tscn",
		"tuning": "res://data/tuning/w01_scrapjack.tres",
		"icon": "weapon_scrapjack",
		"upgrades": ["Quickcycle", "Punch-Through", "Power Shot"],
	},
	"W02": {
		"name": "Boom Broom",
		"node": "BoomBroom",
		"scene": "res://scenes/weapons/boom_broom.tscn",
		"tuning": "res://data/tuning/w02_boom_broom.tres",
		"icon": "weapon_boom_broom",
		"upgrades": ["Extended Tube", "Incendiary Shells", "Twin Shell"],
	},
}
## Microchips for stages 1, 2 and 3 (S04's table, the same for every weapon).
const UPGRADE_PRICES: Array[int] = [40, 90, 160]
## The campaign milestone each later stage waits for (S04 "Where and when to buy").
const STAGE_GATES := {2: "after the Peacekeeper (Level 3)", 3: "after Howard Stroud (Level 6)"}


static func has_type(weapon_type: String) -> bool:
	return INFO.has(weapon_type)


static func display_name(weapon_type: String) -> String:
	return String(INFO.get(weapon_type, {}).get("name", weapon_type))


## The node name of the type's gun under the hero's AimPivot ("Scrapjack", "BoomBroom").
static func node_name(weapon_type: String) -> String:
	return String(INFO.get(weapon_type, {}).get("node", ""))


static func scene_path(weapon_type: String) -> String:
	return String(INFO.get(weapon_type, {}).get("scene", ""))


## The HUD's pixel piece for the type (assets/ui/pixel/, with its painted twin in assets/ui/hd/).
static func icon_piece(weapon_type: String) -> String:
	return String(INFO.get(weapon_type, {}).get("icon", "weapon_scrapjack"))


static func tuning(weapon_type: String) -> WeaponTuning:
	var path := String(INFO.get(weapon_type, {}).get("tuning", ""))
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as WeaponTuning


## The node names of every type's gun (the hero looks for its held gun by these).
static func node_names() -> Array[String]:
	var out: Array[String] = []
	for t in INFO:
		out.append(String(INFO[t]["node"]))
	return out


## The type whose gun node is called `name`, or "".
static func type_of_node(name: String) -> String:
	for t in INFO:
		if String(INFO[t]["node"]) == name:
			return t
	return ""


## The name of the type's upgrade at `stage` (1..3), or "".
static func upgrade_name(weapon_type: String, stage: int) -> String:
	var names: Array = INFO.get(weapon_type, {}).get("upgrades", [])
	return String(names[stage - 1]) if stage >= 1 and stage <= names.size() else ""


static func upgrade_price(stage: int) -> int:
	return UPGRADE_PRICES[stage - 1] if stage >= 1 and stage <= UPGRADE_PRICES.size() else 0


# --- ammunition (finite types only: the Boom Broom) ---------------------------------------

## True for a type that loads and spends ammunition (a ShotgunTuning).
static func uses_ammo(weapon_type: String) -> bool:
	return tuning(weapon_type) is ShotgunTuning


## Shells the tube holds at upgrade `stage` (Extended Tube raises it); 0 for an unlimited type.
static func capacity(weapon_type: String, stage: int) -> int:
	var t := tuning(weapon_type) as ShotgunTuning
	return t.capacity_for_stage(stage) if t else 0


## The most shells the tube can ever hold (any stage): the save check's ceiling.
static func max_capacity(weapon_type: String) -> int:
	var t := tuning(weapon_type) as ShotgunTuning
	return maxi(t.tube_capacity, t.extended_tube_capacity) if t else 0


static func reserve_capacity(weapon_type: String) -> int:
	var t := tuning(weapon_type) as ShotgunTuning
	return t.reserve_capacity if t else 0


## A full weapon at upgrade `stage`: {"loaded", "reserve"} ({} for an unlimited type).
static func full_ammo(weapon_type: String, stage: int) -> Dictionary:
	if not uses_ammo(weapon_type):
		return {}
	return {"loaded": capacity(weapon_type, stage), "reserve": reserve_capacity(weapon_type)}
