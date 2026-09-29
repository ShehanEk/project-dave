class_name SceneryDraw
extends RefCounted
## Tiny shared drawing helpers so paired objects (e.g. route_switch and
## service_walkway) can draw the exact same matching symbol without one
## depending on the other's script. Call from inside the caller's own
## _draw() with `self` as `node`.
##
## Revamp (C24) night pass: also home to the shared night palette tokens
## (art-design/style-guide.md "Palette tokens"; level-design/l01 "Palette and
## lighting") and the smooth light textures every world PointLight2D uses.
## Lit cutouts (C35): the world lights are smooth, realistic falloffs (the
## old flat three-band pools are gone), each sitting at its REAL position
## with a `height`, because a normal-mapped character takes its lighting
## direction from where the light is. The textures are generated once at
## runtime (white, with the falloff in alpha), so there is no PNG to keep in
## sync.

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

## Smooth light textures are square and white, with the falloff in alpha.
## The cone's apex is at the texture CENTRE (so the light node sits AT the
## lamp head and turns about it) and it points straight down; only the lower
## half carries the beam, the upper half holds a small round halo. Both reach
## the texture's edge (half the size) at `texture_scale` 1.
const CONE_TEX_SIZE := 512
const DISC_TEX_SIZE := 256
## The beam is at full strength within CONE_CORE_DEG of the axis and feathers
## to nothing at CONE_HALF_DEG.
const CONE_HALF_DEG := 48.0
const CONE_CORE_DEG := 27.0

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


## A smooth downward light cone (see the constants above): a beam that is
## brightest near the apex and fades along its length and toward its edges,
## plus a soft halo round the apex. Place a PointLight2D using it AT the lamp
## head; `radius_px` in `make_light()` is how far the beam reaches.
static func smooth_cone_texture() -> Texture2D:
	if _cone_texture == null:
		_cone_texture = _build_cone()
	return _cone_texture


## A smooth round light: a bright core with a long, gentle falloff to nothing
## at the texture's edge.
static func smooth_disc_texture() -> Texture2D:
	if _disc_texture == null:
		_disc_texture = _build_disc()
	return _disc_texture


## One additive PointLight2D (the Compatibility renderer's default 2D light
## blend), placed at `pos` (the real source: a lamp head, a beacon dome, the
## muzzle). `radius_px` is how far it reaches from `pos` (a cone's length
## down its axis, a disc's radius). `height_px` is the light's height above
## the scene in pixels: characters shaded through normal maps take their
## lighting direction from it. Lights only reach canvas layer 0 (the world),
## never a UI CanvasLayer, and cast no shadows.
static func make_light(parent: Node, tex: Texture2D, pos: Vector2, radius_px: float,
		color: Color, energy: float, height_px: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = tex
	light.texture_scale = radius_px / (float(tex.get_width()) * 0.5)
	light.position = pos
	light.color = color
	light.energy = energy
	light.height = height_px
	light.blend_mode = Light2D.BLEND_MODE_ADD
	light.shadow_enabled = false
	parent.add_child(light)
	return light


## Both builders fill an RGBA8 byte array (white, alpha = falloff) and mirror
## it, since each shape is left-right symmetric.
static func _build_cone() -> Texture2D:
	var n := CONE_TEX_SIZE
	var data := PackedByteArray()
	data.resize(n * n * 4)
	data.fill(255)
	var c := float(n) * 0.5
	var mid := n >> 1
	var half_rad := deg_to_rad(CONE_HALF_DEG)
	var core_rad := deg_to_rad(CONE_CORE_DEG)
	var feather := half_rad - core_rad
	for y in n:
		var dy := (float(y) + 0.5 - c) / c
		for x in range(mid, n):
			var dx := (float(x) + 0.5 - c) / c
			var dist := sqrt(dx * dx + dy * dy)
			var a := 0.0
			if dist < 1.0:
				var beam := 0.0
				if dy > 0.0:
					var inside := clampf((half_rad - atan2(dx, dy)) / feather, 0.0, 1.0)
					beam = smoothstep(0.0, 1.0, inside) * pow(1.0 - dist, 0.9)
				# A soft halo round the apex, so the lamp head itself glows.
				var spill := pow(clampf(1.0 - dist * 3.0, 0.0, 1.0), 1.5) * 0.7
				var glow := 0.25 * pow(clampf(1.0 - dist * 1.6, 0.0, 1.0), 2.0)
				a = clampf(maxf(beam, spill) + glow, 0.0, 1.0)
			var byte := int(a * 255.0 + 0.5)
			data[(y * n + x) * 4 + 3] = byte
			data[(y * n + (n - 1 - x)) * 4 + 3] = byte
	return _texture_from(n, data)


static func _build_disc() -> Texture2D:
	var n := DISC_TEX_SIZE
	var data := PackedByteArray()
	data.resize(n * n * 4)
	data.fill(255)
	var c := float(n) * 0.5
	var mid := n >> 1
	for y in range(mid, n):
		var dy := (float(y) + 0.5 - c) / c
		for x in range(mid, n):
			var dx := (float(x) + 0.5 - c) / c
			var r2 := dx * dx + dy * dy
			var a := 0.0
			if r2 < 1.0:
				# Soft, roughly inverse-square falloff: a hot core, a long tail.
				a = pow(1.0 - sqrt(r2), 2.2) * (0.35 + 0.65 / (1.0 + 9.0 * r2))
			var byte := int(a * 255.0 + 0.5)
			var mx := n - 1 - x
			var my := n - 1 - y
			data[(y * n + x) * 4 + 3] = byte
			data[(y * n + mx) * 4 + 3] = byte
			data[(my * n + x) * 4 + 3] = byte
			data[(my * n + mx) * 4 + 3] = byte
	return _texture_from(n, data)


static func _texture_from(n: int, data: PackedByteArray) -> Texture2D:
	return ImageTexture.create_from_image(Image.create_from_data(n, n, false, Image.FORMAT_RGBA8, data))
