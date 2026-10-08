extends RefCounted
## Which ambience bed (Audio.set_ambience) plays where the hero is (N05): the pure
## decision table LevelDirector feeds, with no node or autoload access so a test
## can check every case. No `class_name` (the project's import-cache rule): the
## level director and the tests preload it by path.
##
## Before the lockdown each area has a bed of its own: the front gate and the
## gardens share the campus night garden, the rooftop garden has wind, the wet
## plaza drips, the depot hums, and the room around Adam's core node has its own
## deep tone. Once `awakening_done` is set every area except the exit yard uses
## the lockdown bed; the yard keeps its own bed, which is already a lockdown sound.
## `amb_alarm_far` is deliberately unused: the lockdown bed and the yard bed
## already carry an alarm, and a fourth layer would crowd them.
##
## The same table also decides the level MUSIC (`music_for()`), so the one place that
## knows "where the hero is" for the sound mix is this file: the server depot has a
## track of its own before the lockdown, every other area plays the campus track, and
## once `awakening_done` is set the lockdown track plays everywhere.

const NONE := &"none"

## Level music tracks (Audio.set_music keys).
const MUSIC_CAMPUS := &"campus"
const MUSIC_DEPOT := &"depot"
const MUSIC_LOCKDOWN := &"lockdown"
const CAMPUS := &"amb_campus_night"
const ROOF := &"amb_roof_night"
const PLAZA := &"amb_plaza_wet"
const DEPOT := &"amb_depot_hum"
const CORE := &"amb_server_core"
const LOCKDOWN := &"amb_lockdown_bed"
const YARD := &"amb_wicket_yard"

const AREA_GATE := "L01-A01"
const AREA_GARDENS := "L01-A02"
const AREA_ROOFS := "L01-A03"
const AREA_SQUARE := "L01-A04"
const AREA_DEPOT := "L01-A05"
const AREA_EXIT := "L01-A06"

## Area id -> its bed before the lockdown (the depot's core room is handled in bed_for).
const AREA_BEDS := {
	AREA_GATE: CAMPUS,
	AREA_GARDENS: CAMPUS,
	AREA_ROOFS: ROOF,
	AREA_SQUARE: PLAZA,
	AREA_DEPOT: DEPOT,
	AREA_EXIT: YARD,
}

## The depot's core node stands here in its area's own space (a05_depot.tscn puts
## CoreNode at x = 600); the director reads the real node and only falls back to this.
const CORE_NODE_X := 600.0
## The core room is the stretch of the depot around the node. The hero enters it
## within CORE_ROOM_ENTER px and leaves it past CORE_ROOM_EXIT px, so pacing on
## the edge does not flip the bed back and forth.
const CORE_ROOM_ENTER := 360.0
const CORE_ROOM_EXIT := 480.0


## The bed for a hero standing in `area_id` (an AreaRoot id such as "L01-A03").
## `in_core_room` only matters in the depot before the lockdown. An unknown or
## empty area id gets the lockdown bed once the lockdown is on, and silence before it.
static func bed_for(area_id: String, awakening_done: bool, in_core_room: bool = false) -> StringName:
	if area_id == AREA_EXIT:
		return YARD
	if awakening_done:
		return LOCKDOWN
	if area_id == AREA_DEPOT and in_core_room:
		return CORE
	return AREA_BEDS.get(area_id, NONE)


## The level music for a hero standing in `area_id`: the lockdown track once the
## lockdown is on (every area, the exit yard included), otherwise the depot track in
## the server depot (A05) and the campus track everywhere else. Unlike a bed, music is
## never `none` inside a level: an unknown or empty area id plays the campus track.
static func music_for(area_id: String, awakening_done: bool) -> StringName:
	if awakening_done:
		return MUSIC_LOCKDOWN
	if area_id == AREA_DEPOT:
		return MUSIC_DEPOT
	return MUSIC_CAMPUS


## Whether the hero is in the core room, given its x in the depot's own space and
## whether it was inside a moment ago (the hysteresis above).
static func in_core_room(local_x: float, core_x: float, was_inside: bool) -> bool:
	var limit := CORE_ROOM_EXIT if was_inside else CORE_ROOM_ENTER
	return absf(local_x - core_x) <= limit
