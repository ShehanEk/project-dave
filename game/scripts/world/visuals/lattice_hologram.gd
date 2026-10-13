extends Node2D
## The Lattice (batch 7, Level 2's A05 landmark; level-design/l02-alignment.md): the hologram of
## Adam's mind, an arch-shaped lattice of teal light points over a ring projector, standing on
## the main landing. The painting (assets/environment/hd/lab/lattice.png, on black) is drawn
## additively, so black adds nothing and the play behind it still reads. Its origin is the floor
## the base ring stands on; `height` is its lit height in world px.
##
## Motion (slow, never a flash): a gentle breath of its brightness (PULSE_HZ), a "turn" shimmer
## (a mirrored copy cross-fading in and out, so the lattice's points seem to swing round as it
## turns, with a slight sideways squeeze) and a soft scan band rising through it. Under Reduced
## motion it is static (no processing, a steady glow). A teal PointLight2D near its middle lights
## the landing and whoever stands by it (normal-mapped characters take its direction). Purely
## visual: no collision, no gameplay state. No class_name (scenes reference it by path).

const LabSkins := preload("res://scripts/world/lab_skins.gd")
const TEAL := Color("#3FE0D0")
const PULSE_HZ := 0.16
const TURN_HZ := 0.06
const SCAN_PERIOD := 7.0
## The scan band's height, as a share of the lattice's.
const SCAN_BAND := 0.16

## Lit height in world px (the base ring's floor to the halo's top).
@export var height: float = 440.0
## How strongly it adds its light (0..1).
@export var brightness: float = 0.36
## The teal light's reach (world px) and strength.
@export var light_radius: float = 340.0
@export var light_energy: float = 0.75

var _tex: Texture2D
var _lit := Rect2(0.0, 0.0, 768.0, 768.0)
var _t: float = 0.0
var _reduced := false
var _light: PointLight2D


func _ready() -> void:
	z_index = -15          # in front of the backdrop, behind the props (-10) and every actor
	z_as_relative = true
	light_mask = 0         # a light, never lit
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var settings := get_node_or_null("/root/Settings")
	_reduced = settings != null and settings.get_reduced_motion()
	if LabSkins.has("lattice"):
		_tex = LabSkins.texture("lattice")
		var l: Array = LabSkins.entry("lattice").get("lit", [0, 0, 768, 768])
		_lit = Rect2(float(l[0]), float(l[1]), float(l[2]) - float(l[0]), float(l[3]) - float(l[1]))
	_light = PointLight2D.new()
	_light.name = "HologramLight"
	_light.texture = SceneryDraw.smooth_disc_texture()
	_light.color = TEAL
	_light.energy = light_energy
	_light.height = 60.0
	_light.texture_scale = light_radius * 2.0 / float(_light.texture.get_width())
	_light.position = Vector2(0.0, -height * 0.42)
	_light.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(_light)  # generated, never saved
	set_process(not _reduced)
	queue_redraw()


## True while it animates (false under Reduced motion: it is drawn once, steady).
func is_animated() -> bool:
	return is_processing()


func has_art() -> bool:
	return _tex != null


func _process(delta: float) -> void:
	_t += delta
	_light.energy = light_energy * (0.92 + 0.08 * sin(TAU * PULSE_HZ * _t))
	queue_redraw()


## World px per texel.
func _scale() -> float:
	return height / maxf(_lit.size.y, 1.0)


func _draw() -> void:
	if _tex == null:
		_draw_fallback()
		return
	var sc := _scale()
	var pulse: float = 1.0 if _reduced else 0.86 + 0.14 * sin(TAU * PULSE_HZ * _t)
	var turn: float = 0.0 if _reduced else 0.5 - 0.5 * cos(TAU * TURN_HZ * _t)
	var squeeze: float = 1.0 - 0.05 * sin(PI * turn)
	var w: float = float(_tex.get_width()) * sc
	var h: float = float(_tex.get_height()) * sc
	# The texture's lit centre column on x 0, its lowest lit row on the floor (y 0).
	var cx: float = (_lit.position.x + _lit.size.x * 0.5) * sc
	var top: float = -_lit.end.y * sc
	var a: float = brightness * pulse
	var main := Rect2(Vector2(-cx * squeeze, top), Vector2(w * squeeze, h))
	draw_texture_rect(_tex, main, false, Color(1.0, 1.0, 1.0, a * (1.0 - 0.45 * turn)))
	if turn > 0.0:
		# The other side of the lattice swinging round: its mirror image cross-fading in.
		var mirrored := Rect2(Vector2(cx * squeeze, top), Vector2(-w * squeeze, h))
		draw_texture_rect(_tex, mirrored, false, Color(1.0, 1.0, 1.0, a * 0.45 * turn))
		# The scan band rising through it.
		var k: float = fmod(_t / SCAN_PERIOD, 1.0)
		var band_h: float = _lit.size.y * SCAN_BAND
		var by: float = _lit.end.y - (_lit.size.y + band_h) * k
		var r0: float = clampf(by, _lit.position.y, _lit.end.y)
		var r1: float = clampf(by + band_h, _lit.position.y, _lit.end.y)
		if r1 > r0:
			var src := Rect2(0.0, r0, float(_tex.get_width()), r1 - r0)
			var dst := Rect2(Vector2(-cx * squeeze, top + r0 * sc), Vector2(w * squeeze, (r1 - r0) * sc))
			draw_texture_rect_region(_tex, dst, src, Color(1.0, 1.0, 1.0, a * 0.35))


## Without the painting: a faint drawn arch of light points.
func _draw_fallback() -> void:
	var c := Color(TEAL, 0.35 * brightness)
	for i in 3:
		var r: float = height * (0.32 + 0.1 * i)
		draw_arc(Vector2(0.0, -height * 0.12), r, PI, TAU, 32, c, 2.0)
	draw_arc(Vector2(0.0, -6.0), height * 0.45, 0.0, TAU, 40, Color(TEAL, 0.25 * brightness), 2.0)
