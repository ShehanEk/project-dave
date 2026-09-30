class_name ImpactSpark
extends Node2D
## Tiny, short-lived visual burst used for bolt hit/blocked feedback and the
## muzzle-clamp "blocked" indicator. Purely cosmetic; frees itself.
##
## `shape` gives HIT and BLOCKED distinct silhouettes, not just distinct
## colors (05-content-and-assets.md / interface-and-accessibility.md "pair
## cues with geometry... so they do not depend on color alone"): HIT draws a
## round starburst (the original look); BLOCKED draws a flat square plate
## with an angular X mark, reading as "stopped here" even in grayscale.
##
## Respects Settings.reduced_motion (M6): a reduced-motion viewer gets the
## same shapes/colors at a smaller amplitude and shorter hold, never a
## missing or recolored cue.

enum Shape { HIT, BLOCKED }

@export var color: Color = Color.WHITE
@export var life: float = 0.16
@export var shape: Shape = Shape.HIT

var _t: float = 0.0
var _scale: float = 1.0
const OUTLINE := Color("#332a20")  # warm charcoal (C11 hand-drawn contour)


func _ready() -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings and settings.get_reduced_motion():
		_scale = 0.55
		life *= 0.7


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= life:
		queue_free()


func _draw() -> void:
	var k: float = clampf(_t / life, 0.0, 1.0)
	if shape == Shape.BLOCKED:
		_draw_blocked(k)
	else:
		_draw_hit(k)


func _draw_hit(k: float) -> void:
	var r: float = lerpf(12.0, 2.0, k) * _scale
	draw_circle(Vector2.ZERO, r, color)
	draw_circle(Vector2.ZERO, r, OUTLINE, false, 2.0)
	for i in 4:
		var a := (TAU / 4.0) * i + TAU * 0.125
		var len_ := lerpf(16.0, 4.0, k) * _scale
		var tip := Vector2.RIGHT.rotated(a) * len_
		# AD-17 fix: these rays used to be a bare colored line (measured
		# ~1:1 contrast against sky) with no outline, unlike the circle/plate
		# shapes in this same effect. A slightly thicker outline stroke
		# underneath gives every ray the same dark-contour treatment.
		draw_line(Vector2.ZERO, tip, OUTLINE, 3.6)
		draw_line(Vector2.ZERO, tip, color, 2.0)


## BLOCKED: a flat square plate with an angular X mark — distinct silhouette
## from HIT's round starburst so the outcome reads correctly even without
## color (grayscale/colorblind-safe per interface-and-accessibility.md).
func _draw_blocked(k: float) -> void:
	var half: float = lerpf(9.0, 5.0, k) * _scale
	var plate := Rect2(Vector2(-half, -half), Vector2(half, half) * 2.0)
	draw_rect(plate, color)
	draw_rect(plate, OUTLINE, false, 2.0)
	var arm: float = half * 0.65
	draw_line(Vector2(-arm, -arm), Vector2(arm, arm), OUTLINE, 2.5)
	draw_line(Vector2(-arm, arm), Vector2(arm, -arm), OUTLINE, 2.5)
