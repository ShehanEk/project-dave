extends Node2D
## M6 presentation: R01 Clipper body rendering, derived from the approved
## concept art (tools/derive_character_sprites.py ->
## assets/characters/clipper_body_*.png, background removed/cropped from
## concept-art/r01-clipper/r01-clipper-2d-v1.png, with the eye-stalk and
## shear-blade regions erased). Pure presentation: clipper.gd pushes plain
## values once per physics tick via update_pose() and keeps drawing the
## (unchanged) warning triangle itself; nothing here reads Session/physics
## or feeds anything back.
##
## No class_name (see hero_visual.gd's note); clipper.tscn attaches this to
## a child "Visual" node and clipper.gd holds it as an untyped ref.
##
## Why the body texture has two erased holes rather than being one flat
## cutout: the eye stalks and shear blades genuinely change SHAPE across
## states (retracted vs extended stalks, closed vs open shears — R01's
## whole warning language per r01-clipper.md), which a single static photo
## cannot do. style-guide.md is explicit a concept PNG is "not ... a
## layered source document", so true pixel-accurate part extraction isn't
## attempted; instead the two erased regions are redrawn here as small
## vector pieces in the documented r01-clipper.md palette, pivoting from
## the real hinge/mount points still visible in the photo (the shear
## hinge bracket and the eye-stalk mounting collar are both left baked into
## the body texture — only the pieces that actually move are vector). The
## rear motor is never erased: the concept already draws a distinct rear
## gearbox there, so STALL only adds an unmistakable opened-hatch + glow
## overlay on top of it (shape, not just color).
##
## Facing: the source art faces screen-LEFT (NATURAL_FACING), matching
## front_hit_zone/attack_box sitting on the `facing` side in clipper.gd.

const NATURAL_FACING := -1

const OUTLINE := Color("#332a20")
const RUBBER := Color("#303b39")
const EYE_COLOR := Color("#ffb547")
const SHELL := Color("#6ead48")
const IVORY := Color("#efe5cf")
const MOTOR_EXPOSED := Color("#d97a4a")
const MOTOR_GLOW := Color("#ffb547")
const HIT_FLASH := Color("#f4d78a")
## AD-04: the shears used to be drawn as thick RUBBER lines (read as black
## rods, not steel blades) and the eye stalks had no housing. STEEL gives the
## blades r01-clipper.md's "clean metallic cutting bevel" as a filled,
## outlined polygon with one cel-shadow facet instead of a stroked line.
const STEEL := Color("#c7ccce")
const STEEL_SHADOW := Color("#8f9698")

const HEIGHT := 48.0  # clipper.gd's collision-scale HEIGHT, for the warning/anchors below
# Anchor points from tools/derive_character_sprites.py's printed output,
# converted into this node's local space (body sprite centered at x=0,
# bottom edge at y=0) — see that script's header. All in NATURAL_FACING
# (screen-left) orientation; mirrored at runtime via `flip`.
const EYE_BASE_LOCAL := Vector2(-1.26, -57.49)
const SHEAR_HINGE_LOCAL := Vector2(-23.77, -24.74)
## AD-01 fix: this used to be the painted gearbox's own position in the body
## photo (41.2, -45.7), which sits almost entirely outside clipper.gd's
## RearHitZone (centered at (-f*(HALF_WIDTH-8), -HEIGHT*0.55) = (24, -26.4)
## in this same flip-relative space) — a shot landing where the exposed-motor
## glow/hatch actually is would mostly miss the zone that resolves it.
## Visual-only re-anchor (no collision/hit-zone change) so the STALL overlay
## — the actual gameplay-facing "motor exposed" cue — sits centered on the
## real hit zone instead of the cosmetic painted gearbox a few px away.
const MOTOR_LOCAL := Vector2(24.0, -26.4)

@onready var photo: Sprite2D = $Photo

var facing: int = -1
var lean_amount: float = 0.0
var eye_retract: float = 0.0
var shear_open: float = 0.0
var stalled: bool = false
var shell_hit_flash: bool = false
var motor_hit_flash: bool = false
var defeat_progress: float = -1.0


func _process(_delta: float) -> void:
	queue_redraw()


func update_pose(p_facing: int, p_lean_amount: float, p_eye_retract: float, p_shear_open: float,
		p_stalled: bool, p_shell_hit_flash: bool, p_motor_hit_flash: bool,
		p_defeat_progress: float) -> void:
	facing = p_facing
	lean_amount = p_lean_amount
	eye_retract = p_eye_retract
	shear_open = p_shear_open
	stalled = p_stalled
	shell_hit_flash = p_shell_hit_flash
	motor_hit_flash = p_motor_hit_flash
	defeat_progress = p_defeat_progress
	_apply_photo_transform()


func _flip() -> float:
	return 1.0 if facing == NATURAL_FACING else -1.0


func _apply_photo_transform() -> void:
	if photo == null:
		return
	var flip := _flip()
	var base_pos := _base_position()

	if defeat_progress >= 0.0:
		var k: float = clampf(defeat_progress, 0.0, 1.0)
		photo.modulate.a = 1.0 - k
		photo.rotation = flip * lerpf(0.0, 0.5, k)
		photo.scale = Vector2(flip, 1.0) * Vector2(1.0, lerpf(1.0, 0.6, k)) * _base_scale()
		photo.position = base_pos + Vector2(0.0, lerpf(0.0, 6.0, k))
		return

	photo.modulate = Color(1, 1, 1, 1) if not shell_hit_flash else Color(1.6, 1.45, 1.0, 1.0)
	photo.rotation = -flip * lean_amount * 0.10
	photo.scale = Vector2(flip, 1.0) * _base_scale()
	photo.position = base_pos


func _base_scale() -> Vector2:
	return Vector2(0.5, 0.5)  # texture authored at 2x (05-content-and-assets.md)


func _base_position() -> Vector2:
	if photo == null or photo.texture == null:
		return Vector2.ZERO
	return Vector2(0.0, -photo.texture.get_height() * _base_scale().y * 0.5)


func _draw() -> void:
	if defeat_progress >= 0.0:
		return  # settled/disabled: the photo collapse alone reads as "off"
	var flip := _flip()
	# AD-04 fix: the blades/eyes used to always draw in Visual's un-rotated
	# local space while the Photo (the body shell) rotates by
	# `-flip*lean_amount*0.10` during WINDUP/CHARGE lean — the vector parts
	# visibly detached/floated off the shell. Sharing the exact same pivot
	# (_base_position()) and rotation here keeps them glued to the body.
	var pivot := _base_position()
	var rot: float = -flip * lean_amount * 0.10
	draw_set_transform(pivot, rot, Vector2.ONE)
	_draw_shear(flip, pivot)
	_draw_eyes(flip, pivot)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_motor(flip)


## Two blades pivoting from the real hinge bolt still visible in the photo
## (SHEAR_HINGE_LOCAL). shear_open 0 approximates the source's closed pose;
## 1 is the full anticipation/charge spread — both eye stalks retract at the
## same time (see _draw_eyes), a paired shape cue per r01-clipper.md rather
## than color alone. AD-04: each blade is now a filled, outlined, tapered
## steel polygon (clean metallic cutting bevel) with one cel-shadow facet,
## instead of a thick RUBBER stroked line reading as a black rod.
func _draw_shear(flip: float, pivot: Vector2) -> void:
	var hinge := Vector2(SHEAR_HINGE_LOCAL.x * flip, SHEAR_HINGE_LOCAL.y) - pivot
	var spread: float = lerpf(0.06, 0.50, shear_open)
	var tip_len := 34.0
	var dir := Vector2(-flip, 0.0)  # blades point toward the front (facing) side
	var perp := Vector2(0.0, 1.0)
	for side: float in [-1.0, 1.0]:
		var tip := hinge + dir * tip_len + perp * (tip_len * spread * side)
		# A simple tapered wedge (wide at the hinge, to a point at the tip) —
		# a clean triangle reads unambiguously as a blade profile and can
		# never self-intersect, unlike the previous thick stroked line.
		var base_w := 4.5
		var base_outer := hinge + perp * (base_w * side)
		var base_inner := hinge - perp * (base_w * 0.25 * side)
		draw_colored_polygon(PackedVector2Array([base_outer, base_inner, tip]), STEEL)
		# Cel-shadow facet along the trailing (centerline) edge of the blade.
		var mid := base_inner.lerp(tip, 0.5) + perp * (base_w * 0.12 * side)
		draw_colored_polygon(PackedVector2Array([base_inner, mid, tip]), STEEL_SHADOW)
		draw_polyline(PackedVector2Array([base_outer, base_inner, tip, base_outer]), OUTLINE, 1.6, true)
	draw_circle(hinge, 3.2, RUBBER)
	draw_circle(hinge, 3.2, OUTLINE, false, 1.0)


## Ribbed stalk + a shared ivory housing ring at the mount per r01-clipper.md
## ("short ribbed stalk... shared ivory upper panel"); AD-04 was a bare
## straight line with no housing.
func _draw_eyes(flip: float, pivot: Vector2) -> void:
	var base := Vector2(EYE_BASE_LOCAL.x * flip, EYE_BASE_LOCAL.y) - pivot
	draw_circle(base, 6.0, IVORY)
	draw_circle(base, 6.0, OUTLINE, false, 1.2)
	var stalk_len: float = lerpf(9.0, 3.0, eye_retract)
	for side in [-1.0, 1.0]:
		var root := base + Vector2(side * 4.0, 0.0)
		var tip := root + Vector2(0.0, -stalk_len)
		draw_line(root, tip, RUBBER, 2.4)
		# Ribbing: a couple of cross-ticks along the stalk (skipped when
		# fully retracted and too short to show any).
		if stalk_len > 4.0:
			var ribs := 2
			for i in range(1, ribs + 1):
				var rp: Vector2 = root.lerp(tip, float(i) / float(ribs + 1))
				var perp := Vector2(1.0, 0.0)
				draw_line(rp - perp * 1.6, rp + perp * 1.6, OUTLINE, 1.0)
		draw_circle(tip, 3.4, EYE_COLOR)
		draw_circle(tip, 3.4, OUTLINE, false, 1.0)


## The rear motor is normal (a small flush cover) until STALL, when it must
## read as unmistakably exposed: an opened hatch flap plus a bright glow
## ring and a small warning glyph, never color alone.
func _draw_motor(flip: float) -> void:
	var pos := Vector2(MOTOR_LOCAL.x * flip, MOTOR_LOCAL.y)
	if not stalled:
		var c := IVORY if not motor_hit_flash else HIT_FLASH
		draw_circle(pos, 6.0, c)
		draw_circle(pos, 6.0, OUTLINE, false, 1.4)
		return

	# Radii kept inside RearHitZone's 20x32 half-extents (10x16) around `pos`
	# (AD-01) so the glow that reads as "shoot here" never bulges past the
	# zone that actually accepts the hit.
	var glow := MOTOR_GLOW
	glow.a = 0.55
	draw_circle(pos, 9.0, glow)
	var core := MOTOR_EXPOSED if not motor_hit_flash else HIT_FLASH
	draw_circle(pos, 6.0, core)
	draw_circle(pos, 6.0, OUTLINE, false, 1.4)
	# Opened hatch flap, hinged upward and away from the body — a shape the
	# closed cover above never shows.
	var hatch_dir := Vector2(flip, 0.0)
	var flap := PackedVector2Array([
		pos + Vector2(0.0, -6.0), pos + hatch_dir * 9.0 + Vector2(0.0, -13.0), pos + Vector2(0.0, -9.0),
	])
	draw_colored_polygon(flap, IVORY)
	draw_polyline(PackedVector2Array([flap[0], flap[1], flap[2]]), OUTLINE, 1.2, true)
	# Small warning glyph (exclamation) inside the glow so the cue reads even
	# in grayscale/reduced color vision, not from the orange tone alone.
	draw_rect(Rect2(pos + Vector2(-1.0, -5.0), Vector2(2.0, 5.0)), OUTLINE)
	draw_circle(pos + Vector2(0.0, 2.0), 1.1, OUTLINE)
