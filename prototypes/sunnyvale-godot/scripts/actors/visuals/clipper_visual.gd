extends Node2D
## M6 presentation: R01 Clipper body rendering, derived from the approved
## concept art (assets/characters/clipper_body_2x.png, background removed
## and cropped from the old Clipper concept image, with the eye-stalk and
## shear-blade regions erased). The Clipper is removed from the game (C32);
## its derivation tool and reference images were deleted on 2026-09-30, and
## this visual goes with the Clipper in the Level 1 rebuild (C33). Pure presentation: clipper.gd pushes plain
## values once per physics tick via update_pose() and keeps drawing the
## (unchanged) warning triangle itself; nothing here reads Session/physics
## or feeds anything back.
##
## No class_name (see hero_visual.gd's note); clipper.tscn attaches this to
## a child "Visual" node and clipper.gd holds it as an untyped ref.
##
## Night pass (revamp, C24; art-design/robots/r01-clipper.md "Night
## rendering"): the selected design and enamel colours stay, re-lit for
## night. The body cutout is drawn through NIGHT_SHADER (built in code, no
## resource file): its enamel colours become the lit colours, darkened and
## cooled; its drawn cel shadows and outlines sink toward navy/near-black
## instead of a darker green; and a thin cold rim picks out the top and
## back edges (shell, handle arch). The vector parts match that treatment.
##
## Lens light (readability cue only, never a detection state, C16), paired
## with the physical tell so it never depends on colour alone:
##   amber + a small flat glow   hunting (patrol, stall, recovery)
##   alarm red + a bigger glow   from the charge wind-up until the charge
##                               ends (stalks retracted, shears spread);
##                               pulses at 2.5 Hz in the wind-up, steady in
##                               the charge, steady throughout under
##                               reduced motion
##   dull dark amber, no glow    disabled
## The state is read from the values update_pose() already carries (the
## wind-up/charge are the only states with eye_retract or shear_open > 0).
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
##
## Z-ORDER (M7 readability bugfix): `Photo` is a CHILD of this node, and a
## CanvasItem child draws AFTER (on top of) its parent's own `_draw()` by
## default — the opposite of "overlay ON TOP of the photo" above. clipper.tscn
## sets `show_behind_parent = true` on BOTH `Photo` (so it draws before this
## node's own `_draw()`, i.e. underneath the shear/eye/motor overlay) AND on
## this `Visual` node itself (so the whole Visual+Photo subtree draws before
## Clipper root's own `_draw()` — the frontal blocked-spark/warning-triangle
## in clipper.gd — keeping those topmost too). Without both flags the photo
## silently hid every STALL cue (glow/hatch/ring/stars) and the frontal spark,
## since the motor site and typical impact points sit on OPAQUE photo pixels
## (only the eye-stalk/shear regions are erased/transparent in the texture,
## which is why those two cues happened to read fine either way). The lens
## "Glow" child added in _ready() is the one child NOT behind this node: it
## draws additively on top of the lenses.

const NATURAL_FACING := -1

const OUTLINE := Color("#07090f")
const RUBBER := Color("#1f2628")
## The ivory shared eye mount and motor cover, matched to the night-graded
## ivory band in the photo (still the brightest large shape, never white).
const IVORY := Color("#b2b1a9")
const MOTOR_EXPOSED := Color("#d97a4a")
const MOTOR_GLOW := Color("#ffb547")
const HIT_FLASH := Color("#f2f0e8")
## AD-04: the shears used to be drawn as thick RUBBER lines (read as black
## rods, not steel blades) and the eye stalks had no housing. STEEL gives the
## blades r01-clipper.md's "clean metallic cutting bevel" as a filled,
## outlined polygon with one cel-shadow facet instead of a stroked line;
## night pass: darker, cooler steel with a cold rim on the bevel.
const STEEL := Color("#8e9aab")
const STEEL_SHADOW := Color("#4a5567")
## Cold moonlight rim (shared with the Staffer).
const RIM := Color("#a9c8f0")
const LENS_AMBER := Color("#ffb547")
const LENS_RED := Color("#ff3b4e")
const LENS_OFF := Color("#4a3522")

enum Lens { HUNTING, TELL, DARK }

## Night grade for the body cutout. The modulate captured in vertex() keeps
## the photo's hit-flash tint and disabled fade working.
const NIGHT_SHADER := """
shader_type canvas_item;
uniform vec4 lit_tint = vec4(0.74, 0.79, 0.9, 1.0);
uniform vec4 shadow_col = vec4(0.055, 0.09, 0.149, 1.0);
uniform float shade_mix = 0.8;
uniform vec4 rim_col = vec4(0.66, 0.78, 0.94, 0.85);
uniform vec2 rim_dir = vec2(0.34, -0.94);
uniform float rim_px = 3.0;
varying vec4 v_mod;

void vertex() {
	v_mod = COLOR;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 col = tex.rgb * lit_tint.rgb;
	float sink = clamp((0.62 - lum) / 0.45, 0.0, 1.0) * shade_mix;
	col = mix(col, shadow_col.rgb * (0.5 + lum), sink);
	float toward = texture(TEXTURE, UV + rim_dir * TEXTURE_PIXEL_SIZE * rim_px).a;
	float rim = step(0.5, tex.a) * (1.0 - smoothstep(0.2, 0.6, toward));
	col = mix(col, rim_col.rgb, rim * rim_col.a);
	COLOR = vec4(col, tex.a) * v_mod;
}
"""

## M7 Kenney part B: STALL venting (task brief: "Kenney steam/smoke puffs
## venting from the exposed rear motor and small dazed stars/puffs above
## it... loop while stalled, stop cleanly on recovery/defeat"). No class_name
## on kenney_puff.gd applies to these textures too (see its own doc comment);
## these two are the STAGED "clipper_later" files this pass wires up.
const TEX_STALL_STEAM := preload("res://assets/kenney/particles/clipper_later/whitePuff00_stall_steam.png")
const TEX_DAZED_STAR := preload("res://assets/kenney/particles/clipper_later/star_02_dazed_star.png")
const STEAM_TINT := Color("#c9d3de")  # cool night steam
const DAZED_STAR_TINT := Color("#e6edf5")  # pale, distinct from the amber motor glow

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
@onready var _stall_steam: CPUParticles2D = $StallSteam
@onready var _stall_stars: CPUParticles2D = $StallStars
@onready var _stall_steam_static: Sprite2D = $StallSteamStatic

var facing: int = -1
var lean_amount: float = 0.0
var eye_retract: float = 0.0
var shear_open: float = 0.0
var stalled: bool = false
var shell_hit_flash: bool = false
var motor_hit_flash: bool = false
var defeat_progress: float = -1.0
## Fraction of the stall still remaining (1.0 just after stalling -> 0.0 the
## instant it ends), -1.0 while not stalled. Drives the shrinking stall-timer
## ring (M7 readability, 02 "a stall timer cue (ring shrinking)").
var stall_remaining: float = -1.0
## Wall-clock accumulator for the stall's pulsing ring / spinning stunned
## indicator — purely cosmetic (never read by clipper.gd/physics), so basing
## it on real time rather than the fixed-step `delta` is safe and keeps the
## animation smooth even under `tools/test.sh FPS=30`.
var _anim_t: float = 0.0
## Wall clock since the wind-up began (paces the red lens pulse).
var _tell_t: float = 0.0

## M7 Kenney part B (task brief: "stall starts/stops the steam loop with the
## state"). Plain data, mirroring the SAME "the DATA these visuals are driven
## by is what the headless suite proves, not the pixels" idiom `stall_remaining`
## already follows (see test_clipper_teaching.gd's own doc comment) — a test
## reads these instead of reaching into the CPUParticles2D nodes themselves.
## True only while genuinely STALLed (never during/after DEFEATED) AND
## Settings.reduced_motion is false; `stall_static_visible` is its exact
## opposite for a STALL (both false whenever not stalled at all).
var stall_effects_active: bool = false
var stall_static_visible: bool = false

var _glow: Node2D
## Lens centres in this node's local space, kept by _draw() for the glow.
var _lens_pts: Array = []


func _ready() -> void:
	if photo:
		photo.material = _make_night_material()
	# Night: a lighter touch on the steam, so the bright puff never buries
	# the exposed-motor glyph and ring against the dark.
	_configure_stall_particles(_stall_steam, TEX_STALL_STEAM, STEAM_TINT, 0.45)
	_configure_stall_particles(_stall_stars, TEX_DAZED_STAR, DAZED_STAR_TINT)
	if _stall_stars:
		# Orbit rather than fly outward — reads as "circling the head", the
		# same idiom _draw_stunned_indicator() below already uses by hand.
		_stall_stars.initial_velocity_min = 0.0
		_stall_stars.initial_velocity_max = 0.0
		_stall_stars.orbit_velocity_min = 0.35
		_stall_stars.orbit_velocity_max = 0.35
		_stall_stars.amount = 2
		_stall_stars.lifetime = 1.2
		_stall_stars.scale_amount_min = 0.10
		_stall_stars.scale_amount_max = 0.14
	if _stall_steam:
		_stall_steam.amount = 4
		_stall_steam.lifetime = 0.7
		_stall_steam.spread = 40.0
		_stall_steam.initial_velocity_min = 8.0
		_stall_steam.initial_velocity_max = 22.0
		_stall_steam.gravity = Vector2(0.0, -34.0)
		_stall_steam.scale_amount_min = 0.14
		_stall_steam.scale_amount_max = 0.22
	if _stall_steam_static:
		_stall_steam_static.texture = TEX_STALL_STEAM
		_stall_steam_static.modulate = Color(STEAM_TINT, 0.45)
		_stall_steam_static.scale = Vector2(0.16, 0.16)
		_stall_steam_static.visible = false
	_glow = Node2D.new()
	_glow.name = "Glow"
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = add
	add_child(_glow)
	_glow.draw.connect(_draw_glow)


## The night-grade material (its uniforms never change; the hit flash and
## the disabled fade ride on the photo's modulate).
func _make_night_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = NIGHT_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	return mat


## Shared one-shot setup for both looping stall particle systems: never
## `one_shot` (they loop continuously for as long as `emitting` stays true —
## clipper.gd/update_pose is what turns that on/off), explosiveness 0 so they
## trickle out continuously rather than bursting all at once.
func _configure_stall_particles(p: CPUParticles2D, texture: Texture2D, tint: Color,
		alpha: float = 0.8) -> void:
	if p == null:
		return
	p.texture = texture
	p.emitting = false
	p.one_shot = false
	p.explosiveness = 0.0
	p.randomness = 0.4
	var c := tint
	c.a = alpha
	p.color = c


func _process(delta: float) -> void:
	_anim_t += delta
	if lens_state() == Lens.TELL:
		_tell_t += delta
	else:
		_tell_t = 0.0
	queue_redraw()
	if _glow:
		_glow.queue_redraw()


func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


func update_pose(p_facing: int, p_lean_amount: float, p_eye_retract: float, p_shear_open: float,
		p_stalled: bool, p_shell_hit_flash: bool, p_motor_hit_flash: bool,
		p_defeat_progress: float, p_stall_remaining: float = -1.0) -> void:
	facing = p_facing
	lean_amount = p_lean_amount
	eye_retract = p_eye_retract
	shear_open = p_shear_open
	stalled = p_stalled
	shell_hit_flash = p_shell_hit_flash
	motor_hit_flash = p_motor_hit_flash
	defeat_progress = p_defeat_progress
	stall_remaining = p_stall_remaining
	_apply_photo_transform()
	_update_stall_effects()


## Readability cue only (see the header): which light the lenses show.
func lens_state() -> Lens:
	if defeat_progress >= 0.0:
		return Lens.DARK
	if eye_retract > 0.0 or shear_open > 0.0:
		return Lens.TELL
	return Lens.HUNTING


## Lens colour and glow level (0 = no glow).
func _lens_light() -> Array:
	match lens_state():
		Lens.DARK:
			return [LENS_OFF, 0.0]
		Lens.TELL:
			# Wind-up: 2.5 Hz pulse (never above 3 flashes/s) that never goes
			# dark; the charge itself (stalks fully back) holds steady.
			var winding: bool = eye_retract < 1.0
			var level: float = 1.0
			if winding and not _reduced_motion():
				level = 0.62 if fmod(_tell_t, 0.4) >= 0.25 else 1.0
			return [LENS_RED, level]
		_:
			return [LENS_AMBER, 0.75]


## M7 Kenney part B: positions/enables the STALL venting effects at the
## exposed motor (same MOTOR_LOCAL anchor `_draw_motor()` uses below), and
## turns them off the instant `stalled` goes false (RECOVERY) or a defeat
## starts — "stop cleanly on recovery/defeat" per the task brief. Settings.
## reduced_motion swaps the looping CPUParticles2D for a single static puff
## sprite instead of hiding the cue outright (the same "never fully hidden"
## idiom kenney_puff.gd's own reduced-motion handling already follows).
func _update_stall_effects() -> void:
	var effective_stalled: bool = stalled and defeat_progress < 0.0
	var reduced: bool = _reduced_motion()
	stall_effects_active = effective_stalled and not reduced
	stall_static_visible = effective_stalled and reduced
	var motor_pos := _motor_pos(_flip())
	if _stall_steam:
		_stall_steam.position = motor_pos
		_stall_steam.emitting = stall_effects_active
	if _stall_stars:
		_stall_stars.position = motor_pos + Vector2(0.0, -22.0)
		_stall_stars.emitting = stall_effects_active
	if _stall_steam_static:
		_stall_steam_static.position = motor_pos
		_stall_steam_static.visible = stall_static_visible


func _motor_pos(flip: float) -> Vector2:
	return Vector2(MOTOR_LOCAL.x * flip, MOTOR_LOCAL.y)


func _flip() -> float:
	return 1.0 if facing == NATURAL_FACING else -1.0


func _apply_photo_transform() -> void:
	if photo == null:
		return
	var flip := _flip()
	var base_pos := _base_position()

	# The overlay (blades, eyes) fades with the photo while disabled.
	self_modulate.a = 1.0 if defeat_progress < 0.0 else 1.0 - clampf(defeat_progress, 0.0, 1.0)
	if defeat_progress >= 0.0:
		var k: float = clampf(defeat_progress, 0.0, 1.0)
		photo.modulate = Color(1, 1, 1, 1.0 - k)
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
	var flip := _flip()
	# AD-04 fix: the blades/eyes used to always draw in Visual's un-rotated
	# local space while the Photo (the body shell) rotates by
	# `-flip*lean_amount*0.10` during WINDUP/CHARGE lean — the vector parts
	# visibly detached/floated off the shell. Sharing the exact same pivot
	# (_base_position()) and rotation here keeps them glued to the body.
	# Night pass: the same holds through the disabled settle (the photo's
	# collapse tilt/squash/sink), so the dark lenses stay on the body while
	# it fades.
	var pivot := _base_position()
	var origin := pivot
	var rot: float = -flip * lean_amount * 0.10
	var squash := Vector2.ONE
	if defeat_progress >= 0.0:
		var k: float = clampf(defeat_progress, 0.0, 1.0)
		origin += Vector2(0.0, lerpf(0.0, 6.0, k))
		rot = flip * lerpf(0.0, 0.5, k)
		squash = Vector2(1.0, lerpf(1.0, 0.6, k))
	var xf := Transform2D(rot, squash, 0.0, origin)
	draw_set_transform_matrix(xf)
	_draw_shear(flip, pivot)
	_draw_eyes(flip, pivot, xf)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if defeat_progress >= 0.0:
		return  # disabled: no motor cover/stall cues, just the settling body
	_draw_motor(flip)
	if shell_hit_flash:
		_draw_shell_shield_flash()


## M7 readability (02: frontal hits must read "armored" through SHAPE, not
## just the existing color flash) — a brief shield-outline overlay centered
## on the shell, independent of clipper.gd's own spark/chevron at the exact
## impact point (this one reads at a glance even from off to the side).
func _draw_shell_shield_flash() -> void:
	var c := HIT_FLASH
	c.a = 0.85
	var top := Vector2(0.0, -HEIGHT * 0.55 - 16.0)
	var pts := PackedVector2Array([
		top + Vector2(-11.0, 0.0), top + Vector2(11.0, 0.0),
		top + Vector2(9.0, 14.0), top + Vector2(0.0, 20.0), top + Vector2(-9.0, 14.0),
	])
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[0]]), c, 2.4, true)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[0]]), OUTLINE, 1.0, true)


## Two blades pivoting from the real hinge bolt still visible in the photo
## (SHEAR_HINGE_LOCAL). shear_open 0 approximates the source's closed pose;
## 1 is the full anticipation/charge spread — both eye stalks retract at the
## same time (see _draw_eyes), a paired shape cue per r01-clipper.md rather
## than color alone. AD-04: each blade is now a filled, outlined, tapered
## steel polygon (clean metallic cutting bevel) with one cel-shadow facet,
## instead of a thick RUBBER stroked line reading as a black rod. Night
## pass: a thin cold rim along each blade's outer bevel.
func _draw_shear(flip: float, pivot: Vector2) -> void:
	var hinge := Vector2(SHEAR_HINGE_LOCAL.x * flip, SHEAR_HINGE_LOCAL.y) - pivot
	var spread: float = lerpf(0.06, 0.50, shear_open)
	var tip_len := 34.0
	var dir := Vector2(-flip, 0.0)  # blades point toward the front (facing) side
	var perp := Vector2(0.0, 1.0)
	var rim := RIM
	rim.a = 0.8
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
		if side < 0.0:
			# The upper blade's top bevel catches the rim light.
			var inset := Vector2(0.0, 1.0)
			draw_line(base_outer + inset + dir * 1.5, tip.lerp(base_outer, 0.08) + inset, rim, 1.0, true)
	draw_circle(hinge, 3.2, RUBBER)
	draw_circle(hinge, 3.2, OUTLINE, false, 1.0)


## Ribbed stalk + a shared ivory housing ring at the mount per r01-clipper.md
## ("short ribbed stalk... shared ivory upper panel"); AD-04 was a bare
## straight line with no housing. Night pass: the lens discs carry the lens
## light (see the header); their glow is drawn by the "Glow" child.
func _draw_eyes(flip: float, pivot: Vector2, xf: Transform2D) -> void:
	var base := Vector2(EYE_BASE_LOCAL.x * flip, EYE_BASE_LOCAL.y) - pivot
	draw_circle(base, 6.0, IVORY)
	draw_arc(base, 6.0, PI * 1.05, PI * 1.6, 8, RIM, 1.0, true)
	draw_circle(base, 6.0, OUTLINE, false, 1.2)
	var stalk_len: float = lerpf(9.0, 3.0, eye_retract)
	var light: Array = _lens_light()
	var lens_col: Color = light[0]
	var level: float = light[1]
	if level > 0.0:
		lens_col = lens_col.lerp(Color.WHITE, 0.12 * level)
	_lens_pts.clear()
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
		draw_circle(tip, 3.4, lens_col)
		draw_circle(tip, 3.4, OUTLINE, false, 1.0)
		if level > 0.0:
			draw_circle(tip + Vector2(-0.9, -0.9), 0.9, lens_col.lerp(Color.WHITE, 0.6))
		_lens_pts.append(xf * tip)


## The rear motor is normal (a small flush cover) until STALL, when it must
## read as unmistakably exposed: an opened hatch flap plus a bright glow
## ring and a small warning glyph, never color alone.
func _draw_motor(flip: float) -> void:
	var pos := _motor_pos(flip)
	if not stalled:
		# Night: a shaded flush hatch plate (ivory in shadow, rim on its top
		# edge, one bolt), not a bright disc stuck on the shell.
		var c := IVORY.darkened(0.3) if not motor_hit_flash else HIT_FLASH
		draw_circle(pos, 6.0, c)
		draw_arc(pos, 4.9, PI * 1.1, PI * 1.9, 8, RIM, 1.0, true)
		draw_circle(pos + Vector2(0.0, 2.2), 0.9, OUTLINE)
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
	_draw_stall_target_ring(pos)
	_draw_stunned_indicator(pos)


## Pulsing target ring/bracket around the exposed motor (M7 readability, 02
## "a pulsing target ring/bracket around the rear motor") plus, when a stall
## duration is known, a shrinking arc tracing how much of the stall window is
## left ("a stall timer cue (ring shrinking)") — both vanish the instant
## `stalled` goes false (STALL ends), since this whole function only runs
## while stalled.
func _draw_stall_target_ring(pos: Vector2) -> void:
	var reduced_motion := _reduced_motion()
	var pulse: float = 0.9 if reduced_motion else 0.8 + 0.2 * sin(_anim_t * TAU * 1.6)
	var ring_r: float = 13.0 * pulse
	var ring_c := MOTOR_GLOW
	ring_c.a = 0.9
	# Four corner brackets (a target-reticle read, not a plain circle).
	for i in 4:
		var ang: float = float(i) * PI * 0.5 + PI * 0.25
		var dir := Vector2(cos(ang), sin(ang))
		var perp := dir.orthogonal()
		var corner: Vector2 = pos + dir * ring_r
		draw_line(corner, corner - dir * 4.0 + perp * 3.0, ring_c, 1.6)
		draw_line(corner, corner - dir * 4.0 - perp * 3.0, ring_c, 1.6)
	if stall_remaining >= 0.0:
		var start := -PI * 0.5
		draw_arc(pos, ring_r + 6.0, start, start + TAU * stall_remaining, 24, HIT_FLASH, 2.2)


## Small stunned indicator (spinning stars) above the exposed motor (M7
## readability, 02 "stunned indicator... above it"). Frozen at a fixed
## arrangement (no spin) under Settings.reduced_motion, matching every other
## animated cue in this project.
func _draw_stunned_indicator(pos: Vector2) -> void:
	var center := pos + Vector2(0.0, -22.0)
	var reduced_motion := _reduced_motion()
	for i in 2:
		var ang: float = (i * PI) if reduced_motion else (_anim_t * TAU * 1.1 + i * PI)
		var p: Vector2 = center + Vector2(cos(ang) * 8.0, sin(ang) * 4.0)
		_draw_tiny_star(p)


func _draw_tiny_star(p: Vector2) -> void:
	draw_line(p + Vector2(-2.6, 0.0), p + Vector2(2.6, 0.0), DAZED_STAR_TINT, 1.3)
	draw_line(p + Vector2(0.0, -2.6), p + Vector2(0.0, 2.6), DAZED_STAR_TINT, 1.3)
	draw_circle(p, 1.0, LENS_AMBER)


## Flat, hard-edged glow shapes behind/around the lenses (style guide: no
## soft airbrushed light), drawn additively by the "Glow" child. None when
## disabled.
func _draw_glow() -> void:
	if _glow == null or defeat_progress >= 0.0:
		return
	var light: Array = _lens_light()
	var level: float = light[1]
	if level <= 0.0:
		return
	var c: Color = light[0]
	var big: float = 1.3 if lens_state() == Lens.TELL else 1.0
	for p in _lens_pts:
		var outer := c
		outer.a = 0.16 * level
		_glow.draw_circle(p, 5.6 * big, outer)
		var inner := c
		inner.a = 0.3 * level
		_glow.draw_circle(p, 4.2 * big, inner)
