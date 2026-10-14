extends Node2D
## S2 "the range goes live" (level-design/l02-alignment.md, A02's live-fire lanes): one target
## carrier on a ceiling rail holding an armoured target plate down at the floor, sliding slowly
## back and forth across the lanes: MOVING LOW COVER for both sides. The plate is `plate_size`
## (0.6 H tall by default, the cover kit's low crate) and reaches down to the floor line, so it
## stops the flat same-floor round at 0.5 H, and Dave (whose level shot leaves at about 0.78 H)
## can shoot over it, as over a crate.
##
## What it stops, and how. The plate is ONE Area2D ("Plate", scripts/combat/hit_zone.gd with
## `blocks = true`) on two layers:
##   - layer 5 hittable (16): a hero bolt (ScrapBolt, mask 1|16, areas on) and every Boom Broom
##     pellet (mask 1|16, areas on) meet a HitZone that answers "blocked": the cool steel spark and
##     the `bolt_blocked` clang, and nothing behind it is hit;
##   - layer 1 world (1): an enemy round (EnemyRound, mask 1|8, areas on) meets an Area2D whose owner
##     (this node) has no `take_damage()`, so it resolves "blocked" with its pistol impact; the
##     Gunner's muzzle clamp (mask 1|8, areas on) also sees it.
## Being an AREA, not a body, it is never solid to anything: Dave (a CharacterBody2D masking 1)
## and the enemies walk through it, so a moving plate can never push, carry or trap anyone. The
## choice, and why: low cover has to come down to the floor line to stop a 0.5 H round, and a solid
## plate that slides would shove Dave (or stall and reverse on him, like a MovingPlatform), so the
## plate is cover you stand behind, never a wall. Every other world query (floor rays, a
## MovingPlatform's look-ahead, the bots) uses bodies only and never sees it. It is drawn behind
## the actors (z -1), so Dave passing through reads as passing in front of it.
##
## Motion: `point_a`/`point_b` (parent-local, like `position`, on the floor line) are the plate's
## centre at each end. Idle until `start()` (RangeLive calls it; `autostart` for a test bench), it
## then slides at `speed` (capped at MAX_SPEED, half Dave's run), pausing `pause_time` at each end.
## `start_progress` (0 at a, 1 at b) and `start_dir` let neighbouring plates run out of step. While
## it moves, the carrier shows one small, dim, steady amber lamp (a driven body's point, never a
## tell); paused or idle, it is off. Reduced motion has nothing to change (the plate is the game).
##
## Stand-in art until art Batch 8 (`piece`: a painted carrier and plate, code-drawn while "").
## The rail is drawn from end to end with its ceiling brackets, the carrier on it, two hangers down
## to the plate. No `class_name` (import-cache rule): preload it by path; group "cover_plate".

signal reached_end(at_b: bool)

const H := 96.0
## Half of Dave's run (4 H/s): a plate never chases him down.
const MAX_SPEED := 192.0
const RAIL_OVERHANG := 40.0
const BRACKET_STEP := 180.0
const OUTLINE := Color("#05070B")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
const PLATE := Color("#3A4A5E")
const PLATE_DARK := Color("#26323F")
const EDGE := Color("#C9D6E2")
const RING := Color("#DDE6EE")
const RUST := Color("#7A3E22")      # matte safety paint on the kick strip (a warm accent, C62)
const AMBER := Color("#FFB02E")

@export var point_a: Vector2 = Vector2.ZERO
@export var point_b: Vector2 = Vector2(320.0, 0.0)
@export var speed: float = 64.0
@export var pause_time: float = 0.9
@export var plate_size: Vector2 = Vector2(52.0, 58.0)
## How far above the floor line the ceiling rail runs.
@export var rail_height: float = 300.0
## How far the rail's brackets reach up from it (set it to meet the room's ceiling).
@export var bracket_height: float = 40.0
@export var start_progress: float = 0.0
@export var start_dir: int = 1
@export var autostart: bool = false
## Painted carrier and plate (art Batch 8); code-drawn while "".
@export var piece: String = ""

var running: bool = false
## 0 at point_a, 1 at point_b.
var progress: float = 0.0
var _dir: int = 1
var _pause_left: float = 0.0
@onready var plate: Area2D = $Plate


func _ready() -> void:
	add_to_group("cover_plate")
	z_index = -1
	progress = clampf(start_progress, 0.0, 1.0)
	_dir = 1 if start_dir >= 0 else -1
	position = point_a.lerp(point_b, progress)
	# Hittable (hero shots) and world (enemy rounds); never a body, so never solid.
	plate.collision_layer = (1 << 4) | 1
	plate.collision_mask = 0
	plate.set("blocks", true)
	var cs := plate.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs == null:
		cs = CollisionShape2D.new()
		cs.name = "CollisionShape2D"
		plate.add_child(cs)
	var rect := RectangleShape2D.new()
	rect.size = plate_size
	cs.shape = rect
	cs.position = Vector2(0.0, -plate_size.y * 0.5)
	if autostart:
		start()
	queue_redraw()


func start() -> void:
	running = true
	queue_redraw()


func stop() -> void:
	running = false
	queue_redraw()


func effective_speed() -> float:
	return minf(speed, MAX_SPEED)


func is_moving() -> bool:
	return running and _pause_left <= 0.0


## The plate's rectangle in world space.
func plate_rect() -> Rect2:
	return Rect2(global_position + Vector2(-plate_size.x * 0.5, -plate_size.y), plate_size)


func _physics_process(delta: float) -> void:
	if not running:
		return
	var span := point_a.distance_to(point_b)
	if span <= 0.001:
		return
	if _pause_left > 0.0:
		_pause_left = maxf(0.0, _pause_left - delta)
		if _pause_left <= 0.0:
			queue_redraw()
		return
	progress += float(_dir) * effective_speed() * delta / span
	if progress >= 1.0:
		progress = 1.0
		_dir = -1
		_pause_left = pause_time
		reached_end.emit(true)
	elif progress <= 0.0:
		progress = 0.0
		_dir = 1
		_pause_left = pause_time
		reached_end.emit(false)
	position = point_a.lerp(point_b, progress)
	queue_redraw()


func _draw() -> void:
	var w := plate_size.x
	var h := plate_size.y
	var rail_y := -rail_height
	# The rail, end to end in parent space, with its brackets up to the ceiling.
	var a := point_a - position
	var b := point_b - position
	var x0 := minf(a.x, b.x) - RAIL_OVERHANG - w * 0.5
	var x1 := maxf(a.x, b.x) + RAIL_OVERHANG + w * 0.5
	var bx := x0 + 14.0
	while bx < x1:
		draw_rect(Rect2(bx - 3.0, rail_y - 4.0 - bracket_height, 6.0, bracket_height), SLATE)
		draw_rect(Rect2(bx - 3.0, rail_y - 4.0 - bracket_height, 6.0, bracket_height), OUTLINE, false, 1.0)
		bx += BRACKET_STEP
	draw_rect(Rect2(Vector2(x0, rail_y - 6.0), Vector2(x1 - x0, 10.0)), STEEL)
	draw_line(Vector2(x0, rail_y + 4.0), Vector2(x1, rail_y + 4.0), Color(EDGE, 0.45), 1.0)
	draw_rect(Rect2(Vector2(x0, rail_y - 6.0), Vector2(x1 - x0, 10.0)), OUTLINE, false, 1.5)
	for ex in [x0, x1 - 8.0]:
		draw_rect(Rect2(ex, rail_y - 10.0, 8.0, 20.0), SLATE)
		draw_rect(Rect2(ex, rail_y - 10.0, 8.0, 20.0), OUTLINE, false, 1.5)
	# The carrier: a trolley on two wheels, its lamp lit only while it drives.
	var car := Rect2(-24.0, rail_y + 4.0, 48.0, 18.0)
	for wx in [-14.0, 14.0]:
		draw_circle(Vector2(wx, rail_y - 1.0), 5.0, OUTLINE)
		draw_circle(Vector2(wx, rail_y - 1.0), 3.0, SLATE)
	draw_rect(car, SLATE)
	draw_rect(car, OUTLINE, false, 2.0)
	var lamp := Vector2(0.0, car.position.y + 9.0)
	draw_circle(lamp, 3.2, OUTLINE)
	if is_moving():
		draw_circle(lamp, 6.0, Color(AMBER, 0.12))
		draw_circle(lamp, 2.2, Color(AMBER, 0.55))
	else:
		draw_circle(lamp, 2.2, PLATE_DARK)
	# The hangers down to the plate.
	for hx in [-w * 0.3, w * 0.3]:
		draw_line(Vector2(hx, car.end.y), Vector2(hx, -h), OUTLINE, 4.0)
		draw_line(Vector2(hx, car.end.y), Vector2(hx, -h), Color(EDGE, 0.35), 1.0)
	# The armoured plate: steel, a lit top edge, corner bolts, a pale target ring, a kick strip.
	var pr := Rect2(-w * 0.5, -h, w, h)
	draw_rect(pr.grow(2.0), OUTLINE)
	draw_rect(pr, PLATE)
	draw_rect(Rect2(pr.position + Vector2(0.0, h * 0.55), Vector2(w, h * 0.45)), PLATE_DARK)
	draw_rect(Rect2(pr.position + Vector2(0.0, h - 7.0), Vector2(w, 7.0)), RUST)
	draw_line(pr.position + Vector2(1.0, 1.0), Vector2(pr.end.x - 1.0, pr.position.y + 1.0), EDGE, 2.0)
	for c in [Vector2(5.0, 5.0), Vector2(w - 5.0, 5.0), Vector2(5.0, h - 12.0), Vector2(w - 5.0, h - 12.0)]:
		draw_circle(pr.position + c, 1.8, OUTLINE)
	var ring_c := Vector2(0.0, -h * 0.55)
	draw_arc(ring_c, 12.0, 0.0, TAU, 20, Color(RING, 0.8), 2.0)
	draw_arc(ring_c, 5.0, 0.0, TAU, 12, Color(RING, 0.8), 2.0)
	draw_rect(pr, OUTLINE, false, 2.0)
