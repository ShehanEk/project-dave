@tool
extends StaticBody2D
## A steel stair flight or a ramp (Level 2 v2 architecture kit, "Rules against the artificial
## look": "Steps are stairs, ramps, crate stacks or machine tops, not floating bars"). The only
## sloped solid in the game: every other surface is an axis-aligned Block. On the world layer
## (1), like a Block. No class_name (import-cache rule): preload it by path, or instance
## scenes/world/stairs.tscn.
##
## Placement: the node's origin is the flight's LEFT end at the lower floor's top. The flight
## fills x 0..`run` and y -`rise`..0 (up is -y), rising to the right when `direction` is +1 and to
## the left when it is -1. Its high end must meet a landing (a Block, a catwalk deck or another
## flight) at that height, and its low end a floor at y 0: a flight never stands alone.
##
## Why the drawing is not the collision: the hero's body is a 40 px box. On a slope a box rests on
## its uphill corner, so his feet (the box's bottom centre, where he is drawn) ride half his width
## (FOOT_INSET) downhill of the contact, 13 px over the solid slope on a 1:1.5 flight. The solid
## triangle fills the footprint exactly (so the landing meets it flush and the climb ends level with
## the landing's top), and the flight is DRAWN FOOT_INSET toward its low end: its pitch line is
## where the feet actually go, its low end sticks FOOT_INSET out over the floor, and a flat top tread
## FOOT_INSET wide meets the landing. Enemies are not tuned for slopes.
##
## The hero walks it with CharacterBody2D's floor settings (hero.gd `_ready()`: snap, constant
## speed, stop on slope), so he stays on the floor walking down and never slides standing.
##
## Look (until art Batch 8's painted architecture kit): graphite stringer and closed underside,
## brushed-steel treads, each tread's nosing lit cold white (the lit-walkable-edge contract of
## Block and design-guide "Darkness and readability"), a steel handrail on the open side with a
## matte copper top rail (the warm accent; never glowing). `piece` names a painted LabSkins piece
## to draw instead when it exists.

const Arch := preload("res://scripts/world/lab_structure.gd")
const LabSkins := preload("res://scripts/world/lab_skins.gd")

enum Style { STAIRS, RAMP }

## Half the hero's body width (scenes/actors/hero.tscn, 40 px box).
const FOOT_INSET := 20.0
## A step's rise when `steps` is 0 (px; 9-10 px is a real 17 cm step at H = 96 px).
const AUTO_STEP_RISE := 12.0
## The handrail's height over the pitch line (0.85 H).
const RAIL_H := 82.0

## Height climbed (px). Stairs about 1.0 H (96) over 1.5 H (144) of run; ramps gentler.
@export var rise: float = 96.0:
	set(v):
		rise = maxf(v, 4.0)
		_rebuild()
## Horizontal length (px).
@export var run: float = 144.0:
	set(v):
		run = maxf(v, 8.0)
		_rebuild()
## +1: rises toward +x (high end at x = run); -1: rises toward -x (high end at x = 0).
@export_enum("rises left:-1", "rises right:1") var direction: int = 1:
	set(v):
		direction = -1 if v < 0 else 1
		_rebuild()
@export var style: Style = Style.STAIRS:
	set(v):
		style = v
		queue_redraw()
## Treads (0: about one per AUTO_STEP_RISE px of rise).
@export var steps: int = 0:
	set(v):
		steps = maxi(v, 0)
		queue_redraw()
@export var handrail: bool = true:
	set(v):
		handrail = v
		queue_redraw()
## A painted LabSkins piece drawn over the flight's box in place of the code-drawn look ("" or a
## missing piece: the code-drawn look).
@export var piece: String = "":
	set(v):
		piece = v
		queue_redraw()

var _shape_node: CollisionPolygon2D


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	add_to_group("terrain_stairs")
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if _shape_node == null:
		_shape_node = CollisionPolygon2D.new()
		_shape_node.name = "Shape"
		add_child(_shape_node)  # no owner: generated, never saved into scenes
	_shape_node.polygon = collision_polygon()
	queue_redraw()


## The solid triangle (local px): the footprint, high side vertical.
func collision_polygon() -> PackedVector2Array:
	if direction > 0:
		return PackedVector2Array([Vector2(0.0, 0.0), Vector2(run, -rise), Vector2(run, 0.0)])
	return PackedVector2Array([Vector2(0.0, -rise), Vector2(run, 0.0), Vector2(0.0, 0.0)])


## The drawn walking line's height (local y, <= 0) at local x: where the hero's feet stand there
## (the solid slope FOOT_INSET uphill of x, or the landing height on the top tread).
func surface_y(local_x: float) -> float:
	var t: float = clampf((local_x + FOOT_INSET * float(direction)) / run, 0.0, 1.0)
	return -rise * (t if direction > 0 else 1.0 - t)


## Global x of the low and high ends (the floor's and the landing's side).
func low_end_x() -> float:
	return global_position.x + (0.0 if direction > 0 else run)


func high_end_x() -> float:
	return global_position.x + (run if direction > 0 else 0.0)


func top_y() -> float:
	return global_position.y - rise


func step_count() -> int:
	return steps if steps > 0 else maxi(2, roundi(rise / AUTO_STEP_RISE))


## Local point on the drawn pitch line at fraction `t` of its climb (0 low end, 1 high end): the
## footprint's diagonal moved FOOT_INSET toward the low end.
func _at(t: float) -> Vector2:
	var x: float = run * t - FOOT_INSET if direction > 0 else run * (1.0 - t) + FOOT_INSET
	return Vector2(x, -rise * t)


## The high end of the footprint (where the landing starts), at the landing height.
func _top_end() -> Vector2:
	return Vector2(run if direction > 0 else 0.0, -rise)


func _draw() -> void:
	if piece != "" and LabSkins.has(piece):
		# A painted flight, stretched over the drawn box (its low end to the landing), its
		# walking line drawn rising to the right (mirrored for a flight rising left).
		var x0: float = -FOOT_INSET if direction > 0 else 0.0
		var box := Rect2(Vector2(x0, -rise), Vector2(run + FOOT_INSET, rise))
		if direction < 0:
			box = Rect2(Vector2(box.end.x, box.position.y), Vector2(-box.size.x, box.size.y))
		draw_texture_rect(LabSkins.texture(piece), box, false, LabSkins.DIM)
		return
	_draw_underside()
	if style == Style.RAMP:
		_draw_ramp()
	else:
		_draw_stairs()
	if handrail:
		_draw_handrail()


## The closed underside (the stair tower's side panel) under the flight: graphite, with faint
## cross-bracing and a brushed-steel post at the high end.
func _draw_underside() -> void:
	var lo := _at(0.0)
	var hi := _at(1.0)
	var top := _top_end()
	var foot := Vector2(top.x, 0.0)
	draw_colored_polygon(PackedVector2Array([lo, hi, top, foot]), Arch.GRAPHITE_DARK)
	var n: int = maxi(1, int(run / 64.0))
	for i in n:
		var a := _at(float(i) / float(n)) + Vector2(0.0, 20.0)
		var b := Vector2(_at(float(i + 1) / float(n)).x, -3.0)
		if a.y < -6.0:
			draw_line(a, b, Arch.SEAM_DARK, 2.0)
			draw_line(Vector2(a.x, -3.0), Vector2(b.x, a.y - (rise / float(n))), Color(Arch.SEAM_DARK, 0.2), 1.0)
	draw_line(top + Vector2(0.0, 2.0), foot, Arch.STEEL_DARK, 4.0)
	draw_line(Vector2(0.0, -1.0) + lo, Vector2(foot.x, -1.0), Arch.OUTLINE, 2.0)


func _draw_stairs() -> void:
	var n := step_count()
	var sr: float = rise / float(n)
	var srun: float = run / float(n)
	var dx: float = float(direction)
	var top := _top_end()
	# Tread k (1..n) stands at height k*sr, centred on the pitch line, so the feet ride within half
	# a step of every tread instead of over the nosings; the top one runs on to the landing.
	for k in range(1, n + 1):
		var c := _at(float(k) / float(n))
		var x_front: float = c.x - dx * srun * 0.5   # the nosing (the tread's low side)
		var x_back: float = c.x + dx * srun * 0.5 if k < n else top.x
		var y: float = -float(k) * sr
		var x0: float = minf(x_front, x_back)
		var w: float = absf(x_back - x_front)
		draw_rect(Rect2(Vector2(x0, y), Vector2(w, sr)), Arch.GRAPHITE)
		draw_rect(Rect2(Vector2(x0, y), Vector2(w, 4.0)), Arch.STEEL_DARK)
		draw_line(Vector2(x0, y + sr - 0.5), Vector2(x0 + w, y + sr - 0.5), Arch.SEAM_DARK, 1.0)
		draw_line(Vector2(x_front, y), Vector2(x_front, y + sr), Arch.OUTLINE, 1.5)
		# The lit nosing: a bright strip at the tread's front and a lit line along the tread.
		var nose_w: float = minf(9.0, w)
		var nx: float = x_front if direction > 0 else x_front - nose_w
		draw_line(Vector2(x0, y + 0.5), Vector2(x0 + w, y + 0.5), Color(Arch.EDGE, 0.5), 1.0)
		draw_rect(Rect2(Vector2(nx, y), Vector2(nose_w, 2.0)), Arch.EDGE)
	# Stringer: a graphite side beam under the treads, parallel to the pitch, with copper bolts.
	var lo := _at(0.0)
	var hi := _at(1.0)
	var d := Vector2(0.0, sr * 0.5 + 2.0)
	var depth := Vector2(0.0, 16.0)
	var p0 := lo + Vector2(dx * srun * 0.5, 0.0)
	var poly := PackedVector2Array([p0 + d - Vector2(0.0, 2.0), hi + d, hi + d + depth, p0 + Vector2(dx * 18.0, -1.0)])
	draw_colored_polygon(poly, Arch.GRAPHITE_LIGHT)
	draw_line(hi + d + depth, p0 + Vector2(dx * 18.0, -1.0), Arch.OUTLINE, 2.0)
	draw_line(p0 + d - Vector2(0.0, 2.0), hi + d, Color(Arch.STEEL, 0.4), 1.0)
	for i in range(1, n):
		draw_circle((p0 + d).lerp(hi + d, float(i) / float(n)) + Vector2(0.0, 7.0), 1.8, Arch.COPPER)


func _draw_ramp() -> void:
	var lo := _at(0.0)
	var hi := _at(1.0)
	var top := _top_end()
	# Deck plate along the slope and on to the landing, a fascia under it with a copper trim.
	var fh := Vector2(0.0, 16.0)
	draw_colored_polygon(PackedVector2Array([lo, hi, top, top + fh, hi + fh, lo + Vector2(float(direction) * 24.0, 0.0)]),
			Arch.GRAPHITE_LIGHT)
	draw_line(lo + Vector2(float(direction) * 24.0, 0.0), hi + fh, Arch.OUTLINE, 1.5)
	draw_line(hi + fh, top + fh, Arch.OUTLINE, 1.5)
	draw_line(lo + Vector2(float(direction) * 10.0, -1.0), hi + Vector2(0.0, 10.0), Arch.COPPER, 2.0)
	draw_line(hi + Vector2(0.0, 10.0), top + Vector2(0.0, 10.0), Arch.COPPER, 2.0)
	var n: int = maxi(2, int(run / 20.0))
	for i in range(1, n):
		var p := lo.lerp(hi, float(i) / float(n))
		draw_line(p + Vector2(0.0, 2.0), p + Vector2(0.0, 6.0), Arch.SEAM_DARK, 2.0)
	# The lit walking edge (the contract): a continuous cold-white line over a bevel.
	draw_line(lo + Vector2(0.0, 2.5), hi + Vector2(0.0, 2.5), Arch.BEVEL, 3.0)
	draw_line(hi + Vector2(0.0, 2.5), top + Vector2(0.0, 2.5), Arch.BEVEL, 3.0)
	draw_line(lo, hi, Arch.EDGE, 2.0)
	draw_line(hi, top, Arch.EDGE, 2.0)


## The handrail on the open side: steel posts, a mid rail and a matte copper top rail parallel to
## the pitch, returning level over the top tread.
func _draw_handrail() -> void:
	var up := Vector2(0.0, -RAIL_H)
	var n: int = maxi(1, roundi(run / 72.0))
	var hi := _at(1.0)
	var top := _top_end()
	for i in n + 1:
		var p := _at(lerpf(0.08, 1.0, float(i) / float(n)))
		draw_line(p + Vector2(0.0, -2.0), p + up, Arch.STEEL_DARK, 3.0)
		draw_line(p + Vector2(-1.0, -2.0), p + up + Vector2(-1.0, 0.0), Color(Arch.STEEL, 0.5), 1.0)
	draw_line(top + Vector2(0.0, -2.0), top + up, Arch.STEEL_DARK, 3.0)
	var a := _at(0.08) + up
	var b := hi + up
	var m := Vector2(0.0, RAIL_H * 0.5)
	draw_line(a + m, b + m, Arch.STEEL_DARK, 2.0)
	draw_line(b + m, top + up + m, Arch.STEEL_DARK, 2.0)
	for seg in [[a, b], [b, top + up]]:
		draw_line(seg[0], seg[1], Arch.OUTLINE, 5.0)
		draw_line(seg[0], seg[1], Arch.COPPER, 3.0)
		draw_line(seg[0] + Vector2(0.0, -1.0), seg[1] + Vector2(0.0, -1.0), Color(Arch.EDGE, 0.22), 1.0)
