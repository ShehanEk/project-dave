class_name SceneryDraw
extends RefCounted
## Tiny shared drawing helpers so paired objects (e.g. route_switch and
## service_walkway) can draw the exact same matching symbol without one
## depending on the other's script. Call from inside the caller's own
## _draw() with `self` as `node`.
##
## Revamp (C24) night pass: also home to the shared night palette tokens
## (art-design/style-guide.md "Palette tokens"; level-design/l01 "Palette and
## lighting") and the hard-edged light textures every world PointLight2D
## uses, so lamps, beacons and the depot's ceiling lights all paint the same
## flat, three-band cel light pool instead of an airbrushed falloff (style
## guide "Light pools: flat, hard-edged shapes of lighter color").

const NIGHT := Color("#07090F")
const NAVY := Color("#0E1726")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
## Arcadia/Adam at rest, unlocked.
const TEAL := Color("#3FE0D0")
## Warning, Adam's attention (lockdown path lights).
const AMBER := Color("#FFB02E")
## Danger now, locked (lockdown lamps and beacons in the depot).
const ALARM := Color("#FF3B4E")
## Exit signs and status LEDs only.
const SIGNAL_GREEN := Color("#4DE38A")
## Cold path-light white (level brief) — every walkable top edge.
const PATH_WHITE := Color("#D8E6F0")
const OUTLINE := Color("#05070B")

const ON_COLOR := TEAL
const OFF_COLOR := AMBER

## Light textures are square, white, with a stepped alpha: (outer extent as
## a fraction of the texture, band level), outermost first.
const LIGHT_TEX_SIZE := 256
const LIGHT_BANDS := [[1.0, 0.3], [0.72, 0.62], [0.44, 1.0]]
## Cone half-width per pixel of depth (the outer band's slope): the widest
## band just fits the texture at its bottom row.
const CONE_SLOPE := 0.5

static var _cone_texture: Texture2D = null
static var _disc_texture: Texture2D = null


static func draw_switch_symbol(node: CanvasItem, pos: Vector2, on: bool) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-7.0, 6.0), pos + Vector2(7.0, 6.0), pos + Vector2(0.0, -7.0),
	])
	var c: Color = ON_COLOR if on else OFF_COLOR
	node.draw_circle(pos, 12.0, Color(c, 0.14))
	node.draw_colored_polygon(pts, c)
	node.draw_polyline(pts, OUTLINE, 2.0, true)
	node.draw_line(pts[2], pts[0], OUTLINE, 2.0)


## A downward light cone: apex at the texture's top centre, three nested
## hard-edged bands (brightest down the middle). Place a PointLight2D using
## it at the cone's CENTRE (apex + half the scaled height straight down).
static func light_cone_texture() -> Texture2D:
	if _cone_texture == null:
		_cone_texture = _build_light_texture(true)
	return _cone_texture


## A round light pool with three hard-edged concentric bands.
static func light_disc_texture() -> Texture2D:
	if _disc_texture == null:
		_disc_texture = _build_light_texture(false)
	return _disc_texture


## One additive PointLight2D (the Compatibility renderer's default 2D light
## blend). Lights only reach canvas layer 0 (the world), never a UI
## CanvasLayer. `extent_px` is the texture's on-screen size (a cone's
## height, a disc's diameter).
static func make_light(parent: Node, tex: Texture2D, pos: Vector2, extent_px: float,
		color: Color, energy: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = tex
	light.texture_scale = extent_px / float(LIGHT_TEX_SIZE)
	light.position = pos
	light.color = color
	light.energy = energy
	light.blend_mode = Light2D.BLEND_MODE_ADD
	light.shadow_enabled = false
	parent.add_child(light)
	return light


static func _build_light_texture(cone: bool) -> Texture2D:
	var n := LIGHT_TEX_SIZE
	var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 1.0, 0.0))
	var c := float(n) * 0.5
	for y in n:
		var fy := float(y) + 0.5
		for band in LIGHT_BANDS:
			var frac: float = band[0]
			var hw := 0.0
			if cone:
				hw = fy * CONE_SLOPE * frac
			else:
				var r := c * frac
				var dy := fy - c
				if absf(dy) >= r:
					continue
				hw = sqrt(r * r - dy * dy)
			var x0 := clampi(int(round(c - hw)), 0, n)
			var x1 := clampi(int(round(c + hw)), 0, n)
			if x1 > x0:
				img.fill_rect(Rect2i(x0, y, x1 - x0, 1), Color(1.0, 1.0, 1.0, band[1]))
	return ImageTexture.create_from_image(img)
