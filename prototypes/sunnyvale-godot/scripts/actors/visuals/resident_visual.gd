extends Node2D
## M6 presentation: Z01 Resident body rendering, derived from the approved
## concept art (tools/derive_character_sprites.py ->
## assets/characters/resident_full_*.png, background removed/cropped from
## concept-art/z01-resident/z01-resident-2d-v1.png). Pure presentation:
## resident.gd pushes plain values once per physics tick via update_pose()
## and keeps drawing the (unchanged) warning triangle/lunge-hurtbox overlay
## itself; nothing here reads Session/physics or feeds anything back.
##
## No class_name (see hero_visual.gd's note); resident.tscn attaches this to
## a child "Visual" node and resident.gd holds it as an untyped ref.
##
## The concept art shows one relaxed-arms slouch/walk pose — the ONLY pose
## approved for this asset. style-guide.md is explicit that a concept PNG
## is a flat reference, not a layered source or animation sheet, so rather
## than fake a second baked pose we do exactly what 05-content-and-assets.md
## /the M6 brief call for: show the derived photo cutout for idle/approach/
## recovery, driven purely by procedural transforms (bob, walk sway, hit
## squash, defeat collapse), and swap to a small procedural vector redraw
## — in the SAME documented palette (z01-resident.md) — only for
## WINDUP/LUNGE, whose "strong lean + raised hands" pose the source image
## does not show at all.
##
## Facing: the source art faces screen-LEFT (NATURAL_FACING). Flipping the
## sprite for the (equally common) rightward approach also mirrors the
## rolled-cardigan-sleeve asymmetry the brief calls out — noted here
## deliberately rather than silently: a true fix needs a separately drawn
## mirrored asset, out of scope for this pass (see M6 known_gaps).

const NATURAL_FACING := -1

const OUTLINE := Color("#332a20")
const SKIN := Color("#9aaa88")
const CARDIGAN := Color("#c98979")
const SHIRT := Color("#dcd1b9")
const TROUSERS := Color("#658f8a")
const HIT_FLASH := Color("#f4d78a")
## AD-03: added so the WINDUP/LUNGE vector redraw carries the same hair and
## house-slipper silhouette as the derived photo cutout instead of ending at
## a bare head/leg rectangle — z01-resident.md's own palette target list
## doesn't give these two an exact hex (only the four cloth/skin tones
## above), so these are picked to match the approved concept art by eye.
const HAIR := Color("#c7c2ba")
const SLIPPER := Color("#7d6a86")

const WIDTH := 48.0
const HEIGHT := 84.0
const HIT_FLASH_TIME := 0.15

@onready var photo: Sprite2D = $Photo

var facing: int = -1
var moving: bool = false
var walk_phase: float = 0.0
var lean: float = 0.0          # 0 = neutral, 1 = full windup/lunge
var use_procedural: bool = false
var hit_flash_timer: float = 0.0
var defeat_progress: float = -1.0  # -1 = alive; 0..1 counts up to fully gone


func _process(_delta: float) -> void:
	queue_redraw()


func update_pose(p_facing: int, p_moving: bool, p_walk_phase: float, p_lean: float,
		p_use_procedural: bool, p_hit_flash_timer: float, p_defeat_progress: float) -> void:
	facing = p_facing
	moving = p_moving
	walk_phase = p_walk_phase
	lean = p_lean
	use_procedural = p_use_procedural
	hit_flash_timer = p_hit_flash_timer
	defeat_progress = p_defeat_progress
	_apply_photo_transform()


func _apply_photo_transform() -> void:
	if photo == null:
		return
	var f: float = float(facing)
	var flip: float = 1.0 if facing == NATURAL_FACING else -1.0

	if defeat_progress >= 0.0:
		photo.visible = true
		var k: float = clampf(defeat_progress, 0.0, 1.0)
		photo.modulate.a = 1.0 - k
		photo.rotation = -f * flip * lerpf(0.0, 1.3, k)
		photo.scale = Vector2(flip * lerpf(1.0, 1.25, k), lerpf(1.0, 0.55, k)) * _base_scale()
		photo.position = _base_position() + Vector2(0.0, -HEIGHT * 0.5 * lerpf(0.0, 0.4, k))
		return

	photo.visible = not use_procedural
	if use_procedural:
		return

	var bob: float = 0.0
	var sway: float = 0.0
	if moving:
		bob = absf(sin(walk_phase)) * -4.0
		sway = sin(walk_phase) * 0.05
	var squash := Vector2.ONE
	if hit_flash_timer > 0.0:
		var t: float = hit_flash_timer / HIT_FLASH_TIME
		squash = Vector2(1.0 + 0.12 * t, 1.0 - 0.12 * t)

	photo.modulate = Color(1, 1, 1, 1) if hit_flash_timer <= 0.0 else Color(1.6, 1.45, 1.0, 1.0)
	photo.rotation = sway
	photo.scale = Vector2(flip, 1.0) * squash * _base_scale()
	photo.position = _base_position() + Vector2(0.0, bob)


func _base_scale() -> Vector2:
	return Vector2(0.5, 0.5)  # texture authored at 2x (05-content-and-assets.md)


func _base_position() -> Vector2:
	if photo == null or photo.texture == null:
		return Vector2.ZERO
	return Vector2(0.0, -photo.texture.get_height() * _base_scale().y * 0.5)


func _draw() -> void:
	if use_procedural and defeat_progress < 0.0:
		_draw_procedural_body()
	if hit_flash_timer > 0.0:
		_draw_hit_burst()


## Refined vector redraw for WINDUP/LUNGE only (see header) — same documented
## z01-resident.md palette as the derived photo, strong lean toward facing,
## and hands raised as their own drawn pieces (not mirrored automatically:
## drawn per-facing from the same asymmetric intent — the rolled sleeve
## sits on the trailing arm both ways, matching the concept's own trailing-
## arm rolled cuff).
func _draw_procedural_body() -> void:
	var f: float = float(facing)
	var skin: Color = SKIN if hit_flash_timer <= 0.0 else HIT_FLASH
	var lean_x: float = f * lean * 12.0

	# legs, cuffed trousers + a slipper each (AD-03: was a bare rect with no
	# footwear, an off-model silhouette against the derived-photo cutout).
	for leg_x in [-WIDTH * 0.28, WIDTH * 0.04]:
		var leg_rect := Rect2(Vector2(leg_x, -HEIGHT * 0.34), Vector2(WIDTH * 0.24, HEIGHT * 0.30))
		draw_rect(leg_rect, TROUSERS)
		draw_rect(leg_rect, OUTLINE, false, 2.0)
		var slipper := Rect2(Vector2(leg_x - 2.0, -4.0), Vector2(WIDTH * 0.24 + 6.0, 6.0))
		draw_rect(slipper, SLIPPER)
		draw_rect(slipper, OUTLINE, false, 1.5)
	# torso, leaning toward facing
	var torso_rect := Rect2(Vector2(-WIDTH * 0.44 + lean_x, -HEIGHT * 0.78), Vector2(WIDTH * 0.88, HEIGHT * 0.5))
	draw_rect(torso_rect, CARDIGAN)
	draw_rect(Rect2(torso_rect.position + Vector2(WIDTH * 0.30, 0.0), Vector2(WIDTH * 0.28, HEIGHT * 0.22)), SHIRT)
	# head: hair cap + a small face read (heavy-lidded eye, slack mouth per
	# z01-resident.md) so the warning key still reads as the same character,
	# not a blank sage circle.
	var head_pos := Vector2(lean_x * 1.3, -HEIGHT + HEIGHT * 0.12)
	var head_r: float = HEIGHT * 0.14
	draw_circle(head_pos, head_r, skin)
	var hair_rect := Rect2(head_pos + Vector2(-head_r, -head_r * 1.05), Vector2(head_r * 2.0, head_r * 0.85))
	draw_rect(hair_rect, HAIR)
	draw_circle(head_pos + Vector2(f * head_r * 0.35, -head_r * 0.05), 1.6, OUTLINE)
	draw_line(head_pos + Vector2(f * head_r * 0.1, head_r * 0.55), head_pos + Vector2(f * head_r * 0.55, head_r * 0.5), OUTLINE, 1.5)

	# Raised hands: the LEADING arm (toward facing) reaches high and forward
	# — the "strong lean + raised hands" the source pose doesn't show. The
	# TRAILING arm keeps the rolled-sleeve cuff visible a little higher up
	# (matching the concept's own asymmetric sleeve, on whichever arm is
	# trailing for the current facing rather than a fixed screen side).
	var lead_x: float = f * (WIDTH * 0.40) + lean_x
	var hand_h: float = lerpf(HEIGHT * 0.12, HEIGHT * 0.40, lean)
	var lead_arm := Rect2(Vector2(lead_x - 4.0, -HEIGHT * 0.68 - hand_h), Vector2(8.0, hand_h))
	draw_rect(lead_arm, skin)
	draw_rect(lead_arm, OUTLINE, false, 1.5)
	draw_circle(Vector2(lead_x, -HEIGHT * 0.68 - hand_h), 5.0, skin)
	draw_circle(Vector2(lead_x, -HEIGHT * 0.68 - hand_h), 5.0, OUTLINE, false, 1.5)
	var trail_x: float = -f * (WIDTH * 0.34) + lean_x
	var trail_h: float = lerpf(HEIGHT * 0.10, HEIGHT * 0.22, lean)
	var trail_arm := Rect2(Vector2(trail_x - 4.0, -HEIGHT * 0.60 - trail_h), Vector2(8.0, trail_h))
	draw_rect(trail_arm, skin)
	draw_rect(trail_arm, OUTLINE, false, 1.5)
	var cuff := Rect2(Vector2(trail_x - 6.0, -HEIGHT * 0.62 - trail_h), Vector2(12.0, 6.0))
	draw_rect(cuff, CARDIGAN)  # rolled cuff
	draw_rect(cuff, OUTLINE, false, 1.5)

	draw_rect(torso_rect, OUTLINE, false, 3.0)
	draw_rect(hair_rect, OUTLINE, false, 1.5)
	draw_circle(head_pos, head_r, OUTLINE, false, 3.0)


## Hit feedback is a shape change (a small jagged impact burst), never
## color alone (07-acceptance/interface-and-accessibility.md).
func _draw_hit_burst() -> void:
	var t: float = hit_flash_timer / HIT_FLASH_TIME
	var center := Vector2(0.0, -HEIGHT * 0.6)
	var pts := PackedVector2Array()
	var spikes := 8
	for i in range(spikes * 2):
		var ang: float = TAU * i / float(spikes * 2)
		var r: float = (HEIGHT * 0.34 if i % 2 == 0 else HEIGHT * 0.16) * t
		pts.append(center + Vector2(cos(ang), sin(ang)) * r)
	var c := HIT_FLASH
	c.a = 0.75 * t
	draw_colored_polygon(pts, c)
