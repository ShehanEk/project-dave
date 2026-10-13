class_name LevelDef
extends Resource
## One level of the campaign as data (M1, C61): `data/levels/l01.tres`,
## `l02.tres`, ... listed by the `LevelDefs` registry
## (scripts/levels/level_defs.gd). Everything LevelDirector, Session and
## CheckpointService used to hard-code for Level 1 lives here, so a new level
## is a .tres plus its area scenes. Read-only at run time: Session copies the
## dictionaries it needs into `state` (never aliases them).

## "L01". Also the prefix of every per-level id the level uses
## ("L01-A02-G001", "L01-SW01", "L01-KC01"); CheckpointService only accepts
## this prefix in a save made in this level.
@export var id: String = ""
## Position in the campaign, from 1 ("Level 2" on the completion screen).
@export var number: int = 1
@export var display_name: String = ""

@export_group("Areas and checkpoints")
## Area scenes in x order. LevelDirector places each at the summed width of
## the ones before it (CONVENTIONS.md, AreaRoot seam contract).
@export var area_scenes: Array[String] = []
## Session checkpoint id -> [index into `area_scenes`, marker name under that
## area's Markers node]. Its keys are also the only checkpoint ids a save made
## in this level may carry.
@export var checkpoint_markers: Dictionary = {}
## Where a fresh start of the level puts Dave (New Game, the next level, --level).
@export var first_checkpoint: String = "CP00"
## Committed as the level ends (the exit's safe landing; Level 1's wicket yard).
@export var exit_checkpoint: String = "CP05"

@export_group("Starting state")
## The weapon instance Dave holds at a fresh start ("L01-W01-P01"). A level
## entered from the one before keeps the carried weapon TYPE: the same id with
## that type swapped in (`hand_instance()`).
@export var starting_weapon: String = ""
## Weapon instance id -> the pad id it rests on at the start. Its values are
## the only pads a save made in this level may name.
@export var world_weapons: Dictionary = {}
## M3: a finite-ammunition world weapon's authored shells at the start, instance id ->
## [loaded, reserve] (S02: "New authored weapon pickups start with useful ammunition
## specified by the level designer"). A finite weapon not listed starts full.
@export var weapon_ammo: Dictionary = {}
## Switch id -> its value at the start.
@export var switches: Dictionary = {}
## The clearance keycard this level's exit needs ("" = none); the HUD shows
## the card icon while Session holds it.
@export var keycard_id: String = ""
## The HUD's icon for this level's card (a pixel UI piece; batch 7: Level 2's "keycard_l2").
@export var keycard_icon: String = "keycard"
## Every story flag a save made in this level carries, with its fresh-start
## value. A flag also listed in `LevelDefs.CARRIED_STORY_FLAGS` takes the
## finished level's value instead when this level is entered from it.
@export var story_defaults: Dictionary = {}
@export var objective_start: String = ""
@export var objective_complete: String = ""

@export_group("Flow")
## The story scene played before the level starts from New Game or from the
## previous level ("" = none). A `.gd` is built with new(), a `.tscn`
## instantiated; either must emit `finished(skipped: bool)` (SC00, C49).
@export var intro_scene: String = ""
## The level that follows ("" = the campaign ends here for now).
@export var next_level: String = ""

@export_group("Completion")
## Microchips placed in the level: the completion screen's "found / total"
## and, summed over the campaign so far, the most a saved wallet may hold.
@export var chip_total: int = 0
## The level's evidence file ("EF01") and its name on the completion screen.
@export var evidence_id: String = ""
@export var evidence_name: String = ""
## The icon its "Evidence file saved" toast carries (batch 7: Level 2's memo, "evidence_memo").
@export var evidence_icon: String = "evidence"
## CompletionScreen.rank_points(): a clear this fast earns the time points.
@export var rank_fast_seconds: float = 240.0
@export var rank_ok_seconds: float = 360.0
## The last word on the completion screen (Adam's).
@export_multiline var completion_line: String = ""

@export_group("Director")
## The area whose first entry before the awakening moves the objective on to
## Session.OBJECTIVE_DEPOT (Level 1's server depot). "" = none.
@export var depot_area_id: String = ""
## The Security PA's route lines before the awakening: beat id -> caption.
@export var route_pa_lines: Dictionary = {}
## The lockdown announcement after the awakening (caption and voice line).
@export var lockdown_pa_line: String = ""
@export var lockdown_pa_voice: StringName = &""
## The line spoken as the level ends, before the completion screen opens.
@export var exit_pa_speaker: String = "Security PA"
@export var exit_pa_line: String = ""
@export var exit_pa_voice: StringName = &""
## M5 (Level 2): story lines spoken once per run, over play (they never hold Dave).
## Beat id -> a list of lines; each line is [speaker, text] or [speaker, text, voice id].
## Unlike `route_pa_lines` they play in any story state. LevelDirector plays them in
## order through the subtitle panel, one after another; a new set cuts short what is
## left of the one before.
@export var beat_lines: Dictionary = {}
## Lines played once per run when Dave takes this level's keycard (Level 2's console).
@export var keycard_lines: Array = []
## The objective once the keycard is held ("" = unchanged).
@export var keycard_objective: String = ""
## Screen-wide looks LevelDirector adds when the scene exists: the night
## overlay, the character moonlight and the rain and glow (rain stops over
## `indoors` areas on its own).
@export var overlay_scenes: Array[String] = []


## The instance Dave holds at a fresh start of this level when he carries
## `weapon_type` in: `starting_weapon` with its type segment replaced
## ("L01-W01-P01" -> "L01-W02-P01" for W02). "" keeps `starting_weapon`. Never the
## id of one of the level's world weapons (M3): a Boom Broom carried into Level 2,
## whose pad rests L02-W02-P01, is the next copy, L02-W02-P02.
func hand_instance(weapon_type: String = "") -> String:
	var parts := starting_weapon.split("-")
	if weapon_type == "" or parts.size() < 3:
		return starting_weapon
	parts[1] = weapon_type
	var id := "-".join(parts)
	var copy := 1
	while world_weapons.has(id) and copy < 99:
		copy += 1
		parts[parts.size() - 1] = "P%02d" % copy
		id = "-".join(parts)
	return id


## The pads this level's weapons may rest on.
func weapon_pads() -> Array[String]:
	var pads: Array[String] = []
	for pad in world_weapons.values():
		if not pads.has(String(pad)):
			pads.append(String(pad))
	return pads


## Every weapon instance that can exist in this level, one list per weapon
## type Dave can carry in (`weapon_types`): the hand instance for that type
## plus the world weapons. A save in this level must hold exactly one of
## these lists (CheckpointService, ADV-07).
func weapon_instance_sets(weapon_types: Array) -> Array:
	var sets: Array = []
	for weapon_type in weapon_types:
		var hand := hand_instance(String(weapon_type))
		if hand == "" or world_weapons.has(hand):
			continue
		var instances: Array[String] = [hand]
		for instance_id in world_weapons.keys():
			instances.append(String(instance_id))
		sets.append(instances)
	return sets
