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

const OUTLINE := Color("#332a20")
const FILL := Color("#8a7f6a")
const TOP_EDGE := Color("#e9dfc9")
const TRACK := Color("#5b5548")

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
	queue_redraw()


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
	draw_line(local_a, local_b, TRACK, 4.0)
	draw_circle(local_a, 5.0, TRACK)
	draw_circle(local_b, 5.0, TRACK)

	var rect := Rect2(Vector2(-width * 0.5, -thickness * 0.5), Vector2(width, thickness))
	draw_rect(rect, FILL)
	draw_rect(Rect2(rect.position, Vector2(width, minf(5.0, thickness))), TOP_EDGE)
	draw_rect(rect, OUTLINE, false, 3.0)
	# support struts hint the platform is a solid deck, not floating debris.
	draw_line(Vector2(-width * 0.28, thickness * 0.5), Vector2(-width * 0.28, thickness * 0.5 + 14.0), OUTLINE, 4.0)
	draw_line(Vector2(width * 0.28, thickness * 0.5), Vector2(width * 0.28, thickness * 0.5 + 14.0), OUTLINE, 4.0)
