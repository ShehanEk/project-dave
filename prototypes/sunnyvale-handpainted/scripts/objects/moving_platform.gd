class_name MovingPlatform
extends AnimatableBody2D
## Travels between two points with pauses at each end. `sync_to_physics`
## lets Godot report a correct platform velocity to riders each physics
## step, so a CharacterBody2D on top (Hero) is carried automatically;
## Hero sets platform_on_leave = DO_NOTHING so a stop/reversal never
## launches it. point_a/point_b are in this node's PARENT's coordinate
## space (same space as `position`).

@export var point_a: Vector2 = Vector2.ZERO
@export var point_b: Vector2 = Vector2(320, 0)
@export var speed: float = 90.0       ## px/s
@export var pause_time: float = 0.6   ## seconds paused at each end
@export var width: float = 160.0
@export var thickness: float = 20.0

## Revamp (C24) night look: a steel maintenance platform with the same
## cold-white lit top edge as every walkable Block, teal running lights on
## its face, and a dim track line with end stops so the route it travels
## reads before the player commits.
const OUTLINE := Color("#05070B")
const FILL := Color("#26364B")
const FACE := Color("#1A2636")
const TOP_EDGE := Color("#D8E6F0")
const TOP_BEVEL := Color("#5A718C")
const TRACK := Color(0.36, 0.45, 0.56, 0.55)
const RUNNING_LIGHT := Color("#3FE0D0")

## The painted pixel-art look (objects2 sheet), drawn through PickupSkins: the
## steel plate with three teal lights under it, stretched to `width` without
## scaling a pixel (plain plate repeats around the middle light). The plate is
## about as thick as the collision, with the lights hanging below it. The
## sheet's plate has a dark top edge, so the cold-white lit edge (the
## walkable cue) is drawn over its top rows, and the lights get a soft glow.
## The track and end stops stay code-drawn; the code-drawn deck, struts and
## drive housing stay as the fallback. Columns in art px of the piece.
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "moving_platform"
const LIGHT_COLS := [14, 48, 82]
const LIGHT_ROW := 15.5

var _progress: float = 0.0  # 0 at point_a, 1 at point_b
var _dir: int = 1
var _pause_timer: float = 0.0
var _shape_node: CollisionShape2D


func _ready() -> void:
	sync_to_physics = true
	collision_layer = 1  # world
	collision_mask = 0
	position = point_a
	_shape_node = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(width, thickness)
	_shape_node.shape = rect
	add_child(_shape_node)  # generated, not saved
	if painted_piece() != "":
		PickupSkins.make_crisp(self)
	queue_redraw()


## The PickupSkins piece this platform draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


func _physics_process(delta: float) -> void:
	var span := point_a.distance_to(point_b)
	if span <= 0.001:
		return

	if _pause_timer > 0.0:
		_pause_timer = maxf(0.0, _pause_timer - delta)
		queue_redraw()
		return

	if _is_blocked_ahead():
		_dir = -_dir
		_pause_timer = 0.15
		return

	_progress += (float(_dir) * speed * delta) / span
	if _progress >= 1.0:
		_progress = 1.0
		_dir = -1
		_pause_timer = pause_time
	elif _progress <= 0.0:
		_progress = 0.0
		_dir = 1
		_pause_timer = pause_time
	position = point_a.lerp(point_b, _progress)
	queue_redraw()


func _is_blocked_ahead() -> bool:
	var dir_vec := (point_b - point_a).normalized() * float(_dir)
	if dir_vec.length() < 0.001:
		return false
	# Never look past the platform's OWN endpoint: a level is expected to
	# dock these right next to solid ledges, and that intended geometry
	# must not be mistaken for a mid-span obstacle.
	var target: Vector2 = point_b if _dir > 0 else point_a
	var remaining := position.distance_to(target)
	if remaining < 1.0:
		return false
	var reach: float = absf(dir_vec.x) * (width * 0.5) + absf(dir_vec.y) * (thickness * 0.5)
	var lookahead: float = minf(speed * 0.15 + 10.0, remaining)
	var from := position + dir_vec * reach
	var to := from + dir_vec * lookahead
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(from, to)
	# World geometry (1) AND the hero body (2): a platform that is about to
	# sweep into the hero (e.g. one standing on adjoining geometry as the
	# platform arrives) pauses/reverses the same as it would for a wall,
	# instead of shoving them (02: "moving geometry ... pauses/returns if it
	# would crush the hero").
	params.collision_mask = 1 | 2
	params.exclude = [get_rid()]
	var result := space_state.intersect_ray(params)
	return not result.is_empty()


func _draw() -> void:
	var local_a := point_a - position
	var local_b := point_b - position
	draw_line(local_a, local_b, TRACK, 2.0)
	for p in [local_a, local_b]:
		draw_rect(Rect2(p - Vector2(4.0, 4.0), Vector2(8.0, 8.0)), FACE)
		draw_rect(Rect2(p - Vector2(4.0, 4.0), Vector2(8.0, 8.0)), TRACK, false, 1.5)
	if painted_piece() != "":
		_draw_painted()
		return

	# support struts and a small drive housing under the deck: a solid,
	# driven platform, not floating debris.
	draw_line(Vector2(-width * 0.28, thickness * 0.5), Vector2(-width * 0.28, thickness * 0.5 + 14.0), OUTLINE, 4.0)
	draw_line(Vector2(width * 0.28, thickness * 0.5), Vector2(width * 0.28, thickness * 0.5 + 14.0), OUTLINE, 4.0)
	draw_rect(Rect2(Vector2(-14.0, thickness * 0.5), Vector2(28.0, 8.0)), FACE)
	draw_rect(Rect2(Vector2(-14.0, thickness * 0.5), Vector2(28.0, 8.0)), OUTLINE, false, 1.5)
	var rect := Rect2(Vector2(-width * 0.5, -thickness * 0.5), Vector2(width, thickness))
	draw_rect(rect, FACE)
	draw_rect(Rect2(rect.position, Vector2(width, minf(8.0, thickness))), FILL)
	var n := maxi(2, int(width / 40.0))
	for i in n:
		var x: float = rect.position.x + width * (float(i) + 0.5) / float(n)
		var y: float = rect.position.y + thickness * 0.68
		draw_rect(Rect2(Vector2(x - 4.0, y - 1.5), Vector2(8.0, 3.0)), RUNNING_LIGHT)
		draw_rect(Rect2(Vector2(x - 7.0, y - 3.5), Vector2(14.0, 7.0)), Color(RUNNING_LIGHT, 0.15))
	draw_rect(rect, OUTLINE, false, 3.0)
	# the walkable edge goes on last, over the outline's inner half.
	draw_rect(Rect2(rect.position + Vector2(0.0, 2.0), Vector2(width, minf(3.0, thickness - 2.0))), TOP_BEVEL)
	draw_rect(Rect2(rect.position, Vector2(width, minf(2.0, thickness))), TOP_EDGE)


func _draw_painted() -> void:
	var a := PickupSkins.ART
	var top_left := Vector2(-width * 0.5, -thickness * 0.5)
	var left := PickupSkins.draw_sized(self, PIECE, top_left, Vector2(width, PickupSkins.piece_size(PIECE).y))
	var painted_w := 2.0 * roundf(width / (2.0 * a)) * a
	# the walkable edge, over the plate's dark top rows (the corners stay round)
	var edge_x := left + 2.0 * a
	var edge_w := painted_w - 4.0 * a
	draw_rect(Rect2(Vector2(edge_x, top_left.y + a), Vector2(edge_w, a)), TOP_BEVEL)
	draw_rect(Rect2(Vector2(edge_x, top_left.y), Vector2(edge_w, a)), TOP_EDGE)
	for col in LIGHT_COLS:
		var x := PickupSkins.column_x(PIECE, width, col)
		if not is_nan(x):
			draw_circle(Vector2(top_left.x + x, top_left.y + LIGHT_ROW * a), 10.0, Color(RUNNING_LIGHT, 0.15))
