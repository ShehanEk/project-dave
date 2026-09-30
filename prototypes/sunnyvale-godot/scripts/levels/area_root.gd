class_name AreaRoot
extends Node2D
## Shared base for every L01 area scene (per CONVENTIONS.md "Areas and route
## bot"). CONTRACT: local origin (0,0) is the ENTRY SEAM floor top — the
## area's entry floor is at y=0 starting at x=0, and its exit floor is at
## y=0 ending at x=width, each with >=384px (4H) of flat floor so areas can
## be placed side by side at x offsets (next area's AreaRoot.position.x =
## this one's global x + width) and the seam always has safe footing.
##
## Conventional children (area authors add these; missing ones are created
## empty so helpers/tests never crash on a partial scene):
##   Geometry   — Block / MovingPlatform / service_walkway solids
##   Scenery    — non-colliding props (scenery.tscn etc.)
##   Entities   — pickups/interactables (chip, capsule, station, console, ...)
##   Encounters — EncounterGroup nodes with their enemies
##   Beats      — BeatZone nodes (debug/telemetry beat markers)
##   Route      — RoutePoint chain(s) for the debug RouteBot
##   Markers    — Marker2D spawn/respawn points, named Respawn_CP01,
##                Spawn_CP00, etc.

@export var area_id: String = ""
@export var width: float = 1280.0
## Camera Y limits (LOCAL to this AreaRoot) while the hero is in this area,
## fed to GameCamera.world_limits as a world-space Rect2 via get_camera_limits().
@export var camera_top: float = -640.0
@export var camera_bottom: float = 96.0

const CONTAINER_NAMES: Array[String] = [
	"Geometry", "Scenery", "Entities", "Encounters", "Beats", "Route", "Markers",
]


func _ready() -> void:
	for n in CONTAINER_NAMES:
		_ensure_container(n)


func _ensure_container(container_name: String) -> Node:
	var existing := get_node_or_null(container_name)
	if existing:
		return existing
	var c := Node2D.new()
	c.name = container_name
	add_child(c)
	return c


## World-space Rect2 for GameCamera.world_limits while the hero is here.
func get_camera_limits() -> Rect2:
	return Rect2(global_position.x, global_position.y + camera_top,
			width, camera_bottom - camera_top)


## A Marker2D under Markers by exact name (e.g. "Respawn_CP01"), or null.
func get_marker(marker_name: String) -> Marker2D:
	var markers := get_node_or_null("Markers")
	if markers == null:
		return null
	return markers.get_node_or_null(marker_name) as Marker2D


## Every non-empty `beat_id` found under Beats (BeatZone nodes), tree order.
func get_beat_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	var beats := get_node_or_null("Beats")
	if beats:
		_collect_ids(beats, "beat_id", ids)
	return ids


## Every non-empty `entity_id` found under Entities (pickups/interactables),
## tree order. Used by tests to assert presence/absence against Session.
func get_entity_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	var entities := get_node_or_null("Entities")
	if entities:
		_collect_ids(entities, "entity_id", ids)
	return ids


## Every non-empty `entity_id` on a group "enemy" node found under Encounters.
func get_enemy_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	var encounters := get_node_or_null("Encounters")
	if encounters:
		for enemy in _find_in_group(encounters, "enemy"):
			if "entity_id" in enemy and String(enemy.entity_id) != "":
				ids.append(enemy.entity_id)
	return ids


## group_id -> PackedStringArray of that EncounterGroup's own enemy
## entity_ids (tree order), for Telemetry's "encounter_complete" event (which
## needs to know when EVERY member of one group is defeated, not just one
## enemy). Only direct EncounterGroup descendants of Encounters are counted as
## groups; an enemy with no EncounterGroup ancestor (isolated test scenes
## only, per CONVENTIONS.md) contributes to no group here.
func get_encounter_groups() -> Dictionary:
	var groups: Dictionary = {}
	var encounters := get_node_or_null("Encounters")
	if encounters == null:
		return groups
	for child in encounters.get_children():
		if child is EncounterGroup and String(child.group_id) != "":
			var ids: PackedStringArray = []
			for enemy in _find_in_group(child, "enemy"):
				if "entity_id" in enemy and String(enemy.entity_id) != "":
					ids.append(enemy.entity_id)
			groups[child.group_id] = ids
	return groups


## RoutePoints from Route, in tree order (recursing into any grouping
## sub-nodes), keeping only main-route points (branch == "") plus points
## whose branch is present in `enabled_branches`.
func get_route_points(enabled_branches: Array = []) -> Array:
	var pts: Array = []
	var route := get_node_or_null("Route")
	if route:
		_collect_route_points(route, enabled_branches, pts)
	return pts


func _collect_route_points(node: Node, enabled_branches: Array, pts: Array) -> void:
	for child in node.get_children():
		if child is RoutePoint:
			if child.branch == "" or enabled_branches.has(child.branch):
				pts.append(child)
		else:
			_collect_route_points(child, enabled_branches, pts)


func _collect_ids(node: Node, property: String, ids: PackedStringArray) -> void:
	for child in node.get_children():
		if property in child and String(child.get(property)) != "":
			ids.append(child.get(property))
		_collect_ids(child, property, ids)


func _find_in_group(node: Node, group: StringName) -> Array:
	var found: Array = []
	for child in node.get_children():
		if child.is_in_group(group):
			found.append(child)
		found.append_array(_find_in_group(child, group))
	return found


## Convenience for area authors/tests proving the seam contract: true if
## solid world geometry (layer 1) is found directly under y=0 at local x.
func has_floor_at(local_x: float, probe_depth: float = 40.0) -> bool:
	if not is_inside_tree():
		return false
	var from := to_global(Vector2(local_x, -8.0))
	var to := to_global(Vector2(local_x, probe_depth))
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(from, to)
	params.collision_mask = 1
	return not space_state.intersect_ray(params).is_empty()
