extends RefCounted
## Level 2's hand-painted lab pieces (batch 7, tools/art/import_hd_env.py --batch7): the props and
## doors under assets/environment/hd/lab/ and their manifest lab.json. Per piece: `file`, `scale`
## (world px per texel), `anchor_x` (the texel column standing on the origin; the bottom row
## stands on it), `size` in texels and named `points` in texels (the rail lamps' lenses, a pad's
## slot and screen, the dummy's chest ring and stand rows, a door's frame and reader).
##
## Sizes are Level 1's (Dave, 96 px, is 1.75 m): each prop keeps the size the prompt gave it in
## person heights. Pieces are drawn smooth and mipmapped, lit through their normal maps.
##
## `in_lab(node)`: true when `node` stands under the roof of an area whose `interior_look` is
## "lab" (AreaRoot, Level 2); Level 1's depot keeps its own look. A missing PNG or manifest makes
## `has()` false and every caller keeps its old look. No class_name (preload it by path).

const DIR := "res://assets/environment/hd/lab/"
## The pieces' default tint: their white composite and glass would clip to white under the
## lamps (they are lit through their normal maps), like the dimmed planters and desks of C57.
const DIM := Color(0.7, 0.74, 0.84)
const JSON_PATH := DIR + "lab.json"

static var enabled := true
static var _manifest: Dictionary = {}
static var _loaded := false
static var _textures := {}


static func manifest() -> Dictionary:
	if not _loaded:
		_loaded = true
		if FileAccess.file_exists(JSON_PATH):
			var d = JSON.parse_string(FileAccess.get_file_as_string(JSON_PATH))
			if typeof(d) == TYPE_DICTIONARY:
				_manifest = d
	return _manifest


## The manifest entry of `piece`, {} when it (or its PNG) is missing.
static func entry(piece: String) -> Dictionary:
	if not enabled:
		return {}
	var m := manifest()
	if not m.has(piece):
		return {}
	var e: Dictionary = m[piece]
	if not ResourceLoader.exists(DIR + str(e.get("file", ""))):
		return {}
	return e


static func has(piece: String) -> bool:
	return not entry(piece).is_empty()


## The piece as a smooth, mipmapped CanvasTexture with its normal map (lamps light it).
static func texture(piece: String, repeat: bool = false) -> CanvasTexture:
	var key := piece + (":r" if repeat else "")
	if not _textures.has(key):
		var e := entry(piece)
		if e.is_empty():
			return null
		var path: String = DIR + str(e["file"])
		var ct := CanvasTexture.new()
		ct.diffuse_texture = load(path)
		var nrm := path.get_basename() + "_n.png"
		if ResourceLoader.exists(nrm):
			ct.normal_texture = load(nrm)
		ct.specular_color = Color(0.3, 0.32, 0.38)
		ct.specular_shininess = 0.3
		ct.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		if repeat:
			ct.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		_textures[key] = ct
	return _textures[key]


## World px per texel (0 when missing).
static func scale(piece: String) -> float:
	return float(entry(piece).get("scale", 0.0))


## The piece's world size at its own scale.
static func world_size(piece: String) -> Vector2:
	var e := entry(piece)
	if e.is_empty():
		return Vector2.ZERO
	return Vector2(float(e["size"][0]), float(e["size"][1])) * float(e["scale"])


## A named point of the piece (texels) relative to its foot (the anchor column, bottom row), in
## world px at scale `sc` (the piece's own when 0); mirrored when `flip`.
static func point(piece: String, name: String, sc: float = 0.0, flip: bool = false) -> Vector2:
	var e := entry(piece)
	if e.is_empty() or not e.get("points", {}).has(name):
		return Vector2.ZERO
	var p: Array = e["points"][name]
	var s: float = sc if sc > 0.0 else float(e["scale"])
	var v := Vector2(float(p[0]) - float(e["anchor_x"]), float(p[1]) - float(e["size"][1])) * s
	if flip:
		v.x = -v.x
	return v


## A raw value from the piece's points (rows, counts), or `default`.
static func value(piece: String, name: String, default: Variant = null) -> Variant:
	return entry(piece).get("points", {}).get(name, default)


## Draws texel rows [r0, r1) of the piece with their top at world y `y`, the anchor column on x
## `x`, at scale `sc` (its own when 0), tinted; `flip` mirrors it about the anchor.
static func draw_rows(c: CanvasItem, piece: String, r0: float, r1: float, y: float, sc: float = 0.0,
		tint: Color = DIM, flip: bool = false, x: float = 0.0, sx: float = 1.0) -> void:
	var e := entry(piece)
	if e.is_empty():
		return
	var tex := texture(piece)
	var s: float = sc if sc > 0.0 else float(e["scale"])
	var w: float = float(e["size"][0])
	var ax: float = float(e["anchor_x"])
	var left: float = (-(w - ax) if flip else -ax) * s * sx
	var dst := Rect2(Vector2(x + left, y), Vector2(w * s * sx, (r1 - r0) * s))
	if flip:
		dst = Rect2(Vector2(dst.end.x, dst.position.y), Vector2(-dst.size.x, dst.size.y))
	c.draw_texture_rect_region(tex, dst, Rect2(0.0, r0, w, r1 - r0), tint)


## The whole piece standing on (x, 0) (bottom centre on its anchor column).
static func draw(c: CanvasItem, piece: String, sc: float = 0.0, tint: Color = DIM,
		flip: bool = false, x: float = 0.0, sx: float = 1.0) -> void:
	var e := entry(piece)
	if e.is_empty():
		return
	var s: float = sc if sc > 0.0 else float(e["scale"])
	var h: float = float(e["size"][1])
	draw_rows(c, piece, 0.0, h, -h * s, s, tint, flip, x, sx)


## True when `node` stands under the roof of an AreaRoot whose interior look is the lab.
static func in_lab(node: Node) -> bool:
	if not enabled or node == null:
		return false
	var n: Node = node.get_parent()
	while n:
		if "indoors" in n and "area_id" in n:
			if not bool(n.get("indoors")) or str(n.get("interior_look")) != "lab":
				return false
			var wet = n.get("wet_until_x")
			var local_x: float = (node as Node2D).global_position.x - (n as Node2D).global_position.x \
					if node is Node2D else 0.0
			return local_x >= (float(wet) if wet != null else 0.0) - 0.5
		n = n.get_parent()
	return false
