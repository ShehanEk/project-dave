extends Node2D
## M6 presentation: procedural vector Rook (H01/hero.md — no approved sprite
## exists for the hero, so this is an original drawn rig, not a derived
## cutout). Pure presentation: reads pose values pushed by hero.gd once per
## physics tick (update_pose) and a few node refs resolved once in
## setup(); it never reads Session/Input/physics itself and never feeds
## anything back — hero.gd's collision/physics are untouched.
##
## No class_name (M6 art passes run with the import cache not refreshed);
## hero.tscn attaches this by path and hero.gd calls it with an untyped
## `visual` reference so the dynamic method calls below don't need a
## resolvable static type.
##
## Rig, ~H=96 px tall (05-content-and-assets.md's "draw at 2x, display at
## 1x" — this is authored directly at display scale since it is vector, not
## a raster asset): separate jacket/shirt torso, cream trousers with a
## charcoal knee patch on the leading leg, boots, a cream neck cloth, a
## belt pouch, cropped dark hair with one forelock, and empty hands — the
## Scrapjack instance already sitting on AimPivot (scenes/actors/hero.tscn)
## is the only held weapon; the gun arm reaches to meet its grip, the off
## arm swings free. No second/spare weapon is drawn anywhere.

const H := 96.0

const OUTLINE := Color("#332a20")
const SKIN := Color("#a9714a")
const HAIR := Color("#241d1a")
const JACKET := Color("#b6592f")
const JACKET_SHADOW := Color("#98461f")
const SHIRT := Color("#365d62")
const TROUSERS := Color("#efe0be")
const TROUSERS_SHADOW := Color("#dcc99a")
const KNEE_PATCH := Color("#3a332e")
const BOOT := Color("#5c4433")
const NECKCLOTH := Color("#f4ead0")
const POUCH := Color("#6f4e35")
const HIT_TINT := Color("#f4d78a")

const LAND_SQUASH_TIME := 0.12
const HIT_POSE_TIME := 0.2
const INTERACT_POSE_TIME := 0.35

var aim_pivot: Node2D = null

var facing: int = 1
var moving: bool = false
var grounded: bool = true
var vertical_velocity: float = 0.0
var stride_phase: float = 0.0
var is_firing: bool = false
var immune: bool = false
var defeated: bool = false
var land_squash_timer: float = 0.0
var hit_pose_timer: float = 0.0
var interact_pose_timer: float = 0.0


func setup(pivot: Node2D) -> void:
	aim_pivot = pivot


## Interface-and-accessibility.md / M6: reduced-motion suppresses shake-type
## feedback (never the shape-based cue itself — the hit tint/pose still
## shows, just without the wiggle). Missing Settings entirely (isolated
## scenes) is always "use the default" (motion on), matching every other
## reader's own defensive guard in this project.
func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


func _process(_delta: float) -> void:
	queue_redraw()


## Called once per physics tick from hero.gd with plain values only (no
## Node/Session refs) so this stays a pure presentation leaf.
func update_pose(p_facing: int, p_moving: bool, p_grounded: bool, p_vertical_velocity: float,
		p_stride_phase: float, p_is_firing: bool, p_immune: bool, p_defeated: bool,
		p_land_squash_timer: float, p_hit_pose_timer: float, p_interact_pose_timer: float) -> void:
	facing = p_facing
	moving = p_moving
	grounded = p_grounded
	vertical_velocity = p_vertical_velocity
	stride_phase = p_stride_phase
	is_firing = p_is_firing
	immune = p_immune
	defeated = p_defeated
	land_squash_timer = p_land_squash_timer
	hit_pose_timer = p_hit_pose_timer
	interact_pose_timer = p_interact_pose_timer


func _draw() -> void:
	var f: float = float(facing)

	if defeated:
		_draw_defeated(f)
		return

	var squash_x := 1.0
	var squash_y := 1.0
	if land_squash_timer > 0.0:
		var t: float = land_squash_timer / LAND_SQUASH_TIME
		squash_x = 1.0 + 0.18 * t
		squash_y = 1.0 - 0.18 * t

	var lean := 0.0
	var knee_lift := 0.0
	var stride := 0.0
	if not grounded:
		# Rise: legs tuck under the body. Fall: legs stretch toward landing.
		lean = clampf(-vertical_velocity / 700.0, -0.35, 0.6)
		knee_lift = clampf(-vertical_velocity / 900.0, -0.4, 0.5)
	elif moving:
		stride = sin(stride_phase)

	var hit_shake := 0.0
	var interact_bend := 0.0
	if hit_pose_timer > 0.0 and not _reduced_motion():
		hit_shake = sin(hit_pose_timer * 60.0) * (hit_pose_timer / HIT_POSE_TIME)
	if interact_pose_timer > 0.0:
		interact_bend = interact_pose_timer / INTERACT_POSE_TIME

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(squash_x, squash_y))

	var skin := SKIN if not immune else HIT_TINT
	var jacket := JACKET if not immune else HIT_TINT

	# --- legs + boots (drawn first, behind torso) ---------------------------
	_draw_leg(-10.0 + f * stride * 8.0, stride, 1)
	_draw_leg(10.0 - f * stride * 8.0, -stride, -1)

	# --- off arm (swings opposite the stride; simple two-point limb) --------
	_draw_off_arm(f, stride, skin)

	# --- torso: rust jacket over the teal shirt ------------------------------
	var shoulder_y := -H * 0.72 + knee_lift * 4.0
	var torso_h := H * 0.42
	var torso_w := 42.0
	var lean_x := f * lean * 6.0 + hit_shake * -f * 6.0
	var torso_rect := Rect2(Vector2(-torso_w * 0.5 + lean_x, shoulder_y), Vector2(torso_w, torso_h))
	draw_rect(torso_rect, jacket)
	# Shirt visible at the open collar.
	draw_rect(Rect2(torso_rect.position + Vector2(torso_w * 0.30, 0.0), Vector2(torso_w * 0.40, torso_h * 0.5)), SHIRT)
	# One crisp cel-shadow shape (C11: one or two shadow shapes, not a gradient).
	draw_rect(Rect2(torso_rect.position + Vector2(torso_w * 0.62, torso_h * 0.15), Vector2(torso_w * 0.30, torso_h * 0.75)), JACKET_SHADOW)
	draw_rect(torso_rect, OUTLINE, false, 3.0)

	# AD-08 fix: this used to draw BEFORE the torso, at a position fully
	# inside the torso rect's own bounds, so the jacket painted over it
	# completely — hero.md's belt pouch never actually showed. Drawn now
	# after the torso/outline, at the hip (the torso's bottom edge), so it
	# reads as a pouch worn at the hip instead of vanishing.
	var pouch_rect := Rect2(torso_rect.position + Vector2(torso_w * 0.08, torso_h - 4.0), Vector2(12.0, 11.0))
	draw_rect(pouch_rect, POUCH)
	draw_rect(pouch_rect, OUTLINE, false, 2.0)

	# Neck cloth: small cream wedge at the throat.
	var neck_pos := torso_rect.position + Vector2(torso_w * 0.5, -4.0)
	var neck_pts := PackedVector2Array([
		neck_pos + Vector2(-9.0, 0.0), neck_pos + Vector2(9.0, 0.0), neck_pos + Vector2(0.0, 14.0),
	])
	draw_colored_polygon(neck_pts, NECKCLOTH)
	draw_polyline(PackedVector2Array([neck_pts[0], neck_pts[2], neck_pts[1]]), OUTLINE, 2.0, true)

	# --- head: skin + cropped hair + one forelock ----------------------------
	var head_center := torso_rect.position + Vector2(torso_w * 0.5, -H * 0.16 + hit_shake * 3.0)
	var head_r := H * 0.155
	draw_circle(head_center, head_r, skin)
	draw_circle(head_center, head_r, OUTLINE, false, 3.0)
	# AD-08 fix: the hair used to be a single flat, short rect that read as a
	# cap rather than cropped hair with volume. This stays entirely above the
	# head circle's own top rim (never spills onto the lower face, so no
	# extra "re-clip" redraw is needed) — a wider band plus one centered
	# rounded crown bump for volume (an earlier version used two side-by-side
	# corner circles here and it read as a pair of mouse ears, not hair).
	var hair_top: float = -head_r * 1.2
	var hair_rect := Rect2(head_center + Vector2(-head_r * 0.95, hair_top), Vector2(head_r * 1.9, head_r * 0.75))
	draw_rect(hair_rect, HAIR)
	draw_circle(head_center + Vector2(0.0, hair_top + head_r * 0.15), head_r * 0.85, HAIR)
	draw_circle(head_center, head_r, OUTLINE, false, 3.0)
	var forelock: PackedVector2Array = PackedVector2Array([
		head_center + Vector2(f * head_r * 0.15, -head_r * 0.75),
		head_center + Vector2(f * head_r * 1.15, -head_r * 0.95),
		head_center + Vector2(f * head_r * 0.55, -head_r * 0.05),
		head_center + Vector2(f * head_r * 0.15, -head_r * 0.35),
	])
	draw_colored_polygon(forelock, HAIR)
	draw_polyline(PackedVector2Array([forelock[0], forelock[1], forelock[2], forelock[3], forelock[0]]), OUTLINE, 1.5, true)

	# --- gun arm: reaches to meet the Scrapjack's own grip on AimPivot ------
	_draw_gun_arm(skin)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_leg(offset_x: float, stride_amt: float, _side: int) -> void:
	var top := -H * 0.30
	var bottom := 0.0
	var bend: float = absf(stride_amt) * 8.0
	var knee := Vector2(offset_x + stride_amt * 6.0, top + (bottom - top) * 0.55)
	var foot := Vector2(offset_x + stride_amt * 14.0, bottom - 2.0)
	var hip := Vector2(offset_x * 0.4, top)
	var w := 11.0
	var poly := PackedVector2Array([
		hip + Vector2(-w * 0.5, 0.0), hip + Vector2(w * 0.5, 0.0),
		knee + Vector2(w * 0.5 - bend * 0.1, 0.0), foot + Vector2(w * 0.45, 0.0),
		foot + Vector2(-w * 0.45, 0.0), knee + Vector2(-w * 0.5 + bend * 0.1, 0.0),
	])
	draw_colored_polygon(poly, TROUSERS)
	# AD-08 fix: shrunk from the leg's full width (w x 8) so the patch reads
	# as a knee patch and not most of the leg's own silhouette.
	draw_rect(Rect2(knee + Vector2(-w * 0.32, -3.0), Vector2(w * 0.64, 6.0)), KNEE_PATCH)
	draw_polyline(PackedVector2Array([poly[0], poly[5], poly[4], poly[3], poly[2], poly[1], poly[0]]), OUTLINE, 2.5, true)
	# Boot.
	var boot_rect := Rect2(foot + Vector2(-w * 0.6, -6.0), Vector2(w * 1.5, 8.0))
	draw_rect(boot_rect, BOOT)
	draw_rect(boot_rect, OUTLINE, false, 2.0)


func _draw_off_arm(f: float, stride: float, skin: Color) -> void:
	var shoulder := Vector2(-f * 16.0, -H * 0.62)
	var swing := -stride * 10.0
	var elbow := shoulder + Vector2(-f * 4.0, 12.0 + absf(swing) * 0.2)
	var hand := elbow + Vector2(swing, 12.0)
	draw_line(shoulder, elbow, JACKET_SHADOW, 9.0)
	draw_line(elbow, hand, skin, 8.0)
	draw_circle(hand, 5.0, skin)
	draw_circle(hand, 5.0, OUTLINE, false, 1.5)


## The arm reaching toward AimPivot's own origin (the Scrapjack's grip),
## rotated to match its current aim exactly like the previous blockout draw
## (R1-01) — kept here unchanged in spirit, just redrawn with a hand instead
## of a bare wedge, and the hand stops at the grip rather than overlapping
## the weapon body so no second silhouette reads as a spare gun.
func _draw_gun_arm(skin: Color) -> void:
	if aim_pivot == null:
		return
	var pivot_pos: Vector2 = aim_pivot.position
	var rot: float = aim_pivot.rotation
	var dir := Vector2(cos(rot), sin(rot))
	var shoulder := pivot_pos - dir * 26.0 + Vector2(0.0, -4.0)
	var grip := pivot_pos - dir * 4.0
	draw_line(shoulder, grip, JACKET, 10.0)
	draw_line(shoulder, grip, OUTLINE, 13.0)
	draw_line(shoulder, grip, JACKET, 10.0)
	draw_circle(grip, 5.5, skin)
	draw_circle(grip, 5.5, OUTLINE, false, 1.5)


func _draw_defeated(f: float) -> void:
	# Collapsed on the ground: rotated onto one side and squashed flat,
	# distinct in silhouette (not just tinted) from every standing pose.
	draw_set_transform(Vector2(0.0, -6.0), f * -1.35, Vector2(1.15, 0.55))
	draw_rect(Rect2(Vector2(-24.0, -H * 0.6), Vector2(48.0, H * 0.42)), JACKET)
	draw_circle(Vector2(24.0, -H * 0.5), H * 0.15, SKIN)
	draw_rect(Rect2(Vector2(-30.0, -H * 0.22), Vector2(60.0, H * 0.22)), TROUSERS)
	draw_rect(Rect2(Vector2(-24.0, -H * 0.6), Vector2(48.0, H * 0.42)), OUTLINE, false, 3.0)
	draw_circle(Vector2(24.0, -H * 0.5), H * 0.15, OUTLINE, false, 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
