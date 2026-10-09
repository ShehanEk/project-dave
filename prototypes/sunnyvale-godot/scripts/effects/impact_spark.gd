class_name ImpactSpark
extends Node2D
## Short-lived impact burst for a shot that lands on something that doesn't
## bleed (armor, machines, walls) and for the muzzle-clamp "blocked" case.
## Purely cosmetic; frees itself. Flesh shows the target's own blood instead.
##
## Look (C37): white sparks and a few dark scrap chips, with a brief light.
## `shape` gives HIT and BLOCKED distinct silhouettes, not just distinct
## colors (interface-and-accessibility.md "pair cues with geometry... so they
## do not depend on color alone"): HIT is a filled white-hot flash with a
## round burst of sparks flying every way; BLOCKED is a glancing fan of
## sparks thrown back toward the shooter around a hollow ring that opens out
## ("clank, stopped here"), reading apart even in grayscale.
##
## Respects Settings.reduced_motion: the same shapes and colors, smaller,
## fewer and shorter, never a missing or recolored cue.
##
## Pixel art (Sheet 9): when the bullet-impact strip exists, the burst is that
## animation (scripts/effects/pixel_fx.gd) tinted with `color`, in place of the
## drawn disc, ring, sparks and chips, and the two shapes stay apart by
## geometry: HIT is the whole radial burst, BLOCKED only the half of it that
## glances back toward the shooter. The sparks and chips below are still
## worked out (the fallback and what the tests read) but not simulated or drawn.

enum Shape { HIT, BLOCKED }

const Lights := preload("res://scripts/actors/lit/lights.gd")
const PixelFx := preload("res://scripts/effects/pixel_fx.gd")
const OUTLINE := Color("#0B0D10")
const CHIP := Color("#3A3F45")
const SPARK_TIME := 0.22
const GRAVITY := 520.0
const CHIP_GRAVITY := 760.0

@export var color: Color = Color.WHITE
@export var life: float = 0.45
@export var shape: Shape = Shape.HIT
## The shot's travel direction (BLOCKED throws its sparks back against it).
var dir: Vector2 = Vector2.RIGHT

var _t: float = 0.0
var _scale: float = 1.0
var _sparks: Array = []   # [pos, vel]
var _chips: Array = []    # [pos, vel, angle, spin, size]
var _light: PointLight2D
var _pixel: Sprite2D   # the pixel-art burst, when its strip exists


func _ready() -> void:
	var settings := get_node_or_null("/root/Settings")
	var reduced: bool = settings != null and settings.get_reduced_motion()
	if reduced:
		_scale = 0.55
		life *= 0.7
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(global_position))
	var back := (-dir).normalized() if dir.length() > 0.01 else Vector2.LEFT
	var n_sparks := (9 if shape == Shape.HIT else 6) - (3 if reduced else 0)
	for i in n_sparks:
		var v: Vector2
		if shape == Shape.HIT:
			v = Vector2.RIGHT.rotated(rng.randf() * TAU) * rng.randf_range(110.0, 260.0)
		else:
			v = back.rotated(rng.randf_range(-0.9, 0.9)) * rng.randf_range(140.0, 280.0)
		_sparks.append([Vector2.ZERO, v * _scale])
	for i in (3 if shape == Shape.HIT else 2) - (1 if reduced else 0):
		var v := (back * 0.6 + Vector2(rng.randf_range(-0.7, 0.7), -1.0)).normalized() * rng.randf_range(70.0, 150.0)
		_chips.append([Vector2.ZERO, v * _scale, rng.randf() * TAU, rng.randf_range(-14.0, 14.0), rng.randf_range(1.6, 2.6)])
	_light = PointLight2D.new()
	_light.texture = Lights.soft_disc()
	_light.texture_scale = 0.5 if shape == Shape.HIT else 0.35
	_light.color = color
	_light.energy = 1.2 if shape == Shape.HIT else 0.7
	_light.height = 14.0
	_light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(_light)
	var half := Vector2i.ZERO
	if shape == Shape.BLOCKED:
		half = Vector2i(int(signf(back.x)), 0) if absf(back.x) >= absf(back.y) else Vector2i(0, int(signf(back.y)))
	_pixel = PixelFx.spawn("bullet_impact", global_position, self, {"tint": color, "half": half})
	if _pixel != null:
		life = _pixel.total_time() + 0.03


func _process(delta: float) -> void:
	_t += delta
	if _pixel != null:
		_light.energy = maxf(0.0, _light.energy - delta * 10.0)
		if _t >= life:
			queue_free()
		return
	for s in _sparks:
		s[1].y += GRAVITY * delta
		s[0] += s[1] * delta
	for c in _chips:
		c[1].y += CHIP_GRAVITY * delta
		c[0] += c[1] * delta
		c[2] += c[3] * delta
	_light.energy = maxf(0.0, _light.energy - delta * 10.0)
	queue_redraw()
	if _t >= life:
		queue_free()


func _draw() -> void:
	if _pixel != null:
		return
	var k: float = clampf(_t / SPARK_TIME, 0.0, 1.0)
	if shape == Shape.HIT:
		# The white-hot flash: a filled disc that shrinks away fast.
		var r: float = lerpf(7.0, 0.0, clampf(_t / 0.07, 0.0, 1.0)) * _scale
		if r > 0.2:
			draw_circle(Vector2.ZERO, r + 1.5, Color(OUTLINE, 0.6))
			draw_circle(Vector2.ZERO, r, color)
	else:
		# The clank: a hollow ring that opens out and fades.
		var rr: float = lerpf(3.0, 11.0, k) * _scale
		var a := 1.0 - k
		if a > 0.02:
			draw_arc(Vector2.ZERO, rr, 0.0, TAU, 20, Color(OUTLINE, 0.7 * a), 3.2)
			draw_arc(Vector2.ZERO, rr, 0.0, TAU, 20, Color(color, a), 1.6)
	if k < 1.0:
		var fade := 1.0 - k
		for s in _sparks:
			var tail: Vector2 = s[0] - s[1] * 0.022
			draw_line(tail, s[0], Color(OUTLINE, 0.5 * fade), 2.6)
			draw_line(tail, s[0], Color(color, fade), 1.3)
	for c in _chips:
		var a2: float = clampf((life - _t) / 0.15, 0.0, 1.0)
		var sz: float = c[4] * _scale
		draw_set_transform(c[0], c[2], Vector2.ONE)
		draw_rect(Rect2(-sz * 0.5, -sz * 0.5, sz, sz), Color(CHIP, a2))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
