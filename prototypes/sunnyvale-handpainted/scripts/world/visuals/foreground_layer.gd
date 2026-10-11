extends Node2D
## The near-camera foreground (Sheet 7, 2026-10-07): a sparse row of almost
## black silhouettes (clipped hedges with their grass tufts, railings, benches,
## bollards, loose grass) along the BOTTOM EDGE OF THE SCREEN, in front of the
## play plane and its actors. They are close to the camera, so they are drawn
## larger than the play plane and slide past faster than the camera (PARALLAX),
## which adds depth for almost nothing. Purely decorative: no collision, no
## gameplay state, nothing in the world ever reads it. Each outdoor area scene
## (A01 gate, A02 gardens, A03 roofs, A04 plaza, A06 exit; not the depot, an
## interior) has one `Foreground` node with this script and its own `tile_width`
## (the area's width), like the backdrop layers. No `class_name` (M6 art-pass
## import-cache rule): scenes reference the script by path, tests load it.
##
## The art is the user's generated foreground sheet, which is NOT a strip but
## fourteen separate pieces on a transparent sheet
## (concept-art/env-sunnyvale/sunnyvale-foreground-v2.webp), cut apart by
## tools/art/import_pixel_sheet.py foreground into
## assets/environment/sunnyvale/foreground/<piece>.png. This script composes the
## row itself, from a deterministic seed per area (its area_id), so the repeat is
## never visible: irregular spacing with wide gaps (about three quarters of the
## width stays empty so the action stays visible), never the same kind of piece
## twice in a row (and never the same piece as two back), an occasional mirrored
## piece, and a margin kept clear at each end of the span so two neighbouring
## areas' rows never touch. `layout()` is that composition (static, so a test can
## run it on its own).
##
## Drawn on its own CanvasLayer (LAYER 3: above the world and its toasts, below
## the night overlay's vignette and grain at 5, the HUD at 15 and the barks at
## 18), in screen space, so the pieces sit on the bottom edge whatever the camera
## does vertically (the climbing roof camera, the low plaza), are never lit by
## the world's lamps and never take the areas' lockdown wash: they just stay dark.
## They are drawn nearest-filtered at a whole number of screen pixels per art
## pixel (ART_WORLD world px at the camera's zoom, rounded: 3 at zoom 1.2 on the
## 1280 x 720 base) and placed on whole screen pixels, so every art pixel keeps
## the same width however the camera moves and nothing shimmers (the campus
## layer steps its sampling in art pixels for the same reason).
##
## Parallax without Parallax2D (see area_backdrop.gd's KNOWN DEVIATION): a piece
## has a position `u` in "foreground space", where one unit is a world px at
## PARALLAX times the camera's motion. It appears at screen x = centre + (u -
## PARALLAX * camera_x) * zoom. An area owns the u span [PARALLAX * its global x,
## PARALLAX * (its global x + width)], so the camera, which stays inside its area
## (plus a seam crossing), only ever sees its own area's row there, the rows of
## neighbouring areas meet without a gap or an overlap, and the depot (no
## Foreground node) has none.
##
## `_process` only reads the camera (a few multiplications) while the view is off
## its span; it hides the canvas then, and redraws only when the camera moved.
## A missing piece PNG (an export without the art) leaves it out of the row; with
## no art at all nothing is drawn and nothing processes. Parallax is not a shake,
## so Reduced Motion leaves it alone.

const DIR := "res://assets/environment/sunnyvale/foreground/"
## Every piece the sheet gives, with what kind of thing it is.
const PIECES := {
	"hedge_a": "hedge", "hedge_b": "hedge", "hedge_c": "hedge", "hedge_d": "hedge", "hedge_long": "hedge",
	"railing": "rail", "railing_short": "rail",
	"bench_a": "bench", "bench_b": "bench",
	"bollard_a": "bollard", "bollard_b": "bollard",
	"grass_a": "grass", "grass_b": "grass", "grass_c": "grass",
}
## How often each kind is picked (a hedge is the staple, a bench the rarity).
const KIND_WEIGHT := {"hedge": 0.38, "rail": 0.18, "bench": 0.14, "bollard": 0.1, "grass": 0.2}

## World px per art pixel at the camera's zoom (the play plane is 1.5): 2.5 is
## exactly 3 screen pixels at the game's zoom 1.2, so a pixel is never uneven.
const ART_WORLD := 2.5
## How much faster than the camera the row slides past (1 would be a world
## object). About 1.5 reads as roughly half again as close as the play plane.
const PARALLAX := 1.5
## Above the world, below the night overlay (5) and the HUD (15).
const LAYER := 3
## Space kept clear at both ends of an area's span, in foreground units.
const MARGIN := 60.0
## Gaps between pieces: now and then a short one (a hedge with a bench beside it),
## most often a wide one.
const GAP_NEAR := Vector2(24.0, 90.0)
const GAP_FAR := Vector2(150.0, 400.0)
const NEAR_CHANCE := 0.22
const FLIP_CHANCE := 0.35

@export var tile_width: float = 3000.0
## A colour the pieces are multiplied by (white draws them as painted: they are
## already near black, #050910).
@export var tint: Color = Color.WHITE

static var _textures := {}

var _seed: int = 0
var _u0: float = 0.0
var _u1: float = 0.0
var _tex := {}
var _items: Array = []
var _layer: CanvasLayer
var _canvas: Node2D
var _cam_x: float = 0.0
var _zoom: float = 1.0
var _view_size := Vector2(1280.0, 720.0)
var _key := Vector4.ZERO


func _ready() -> void:
	process_priority = 100   # after the camera has moved, so the first read is this frame's
	var gx0: float = global_position.x
	var owner_area := get_parent()
	var area_id := ""
	if owner_area != null and "area_id" in owner_area:
		area_id = String(owner_area.get("area_id"))
	_seed = area_seed(area_id, gx0)
	_u0 = PARALLAX * gx0
	_u1 = PARALLAX * (gx0 + tile_width)
	_layer = CanvasLayer.new()
	_layer.name = "Screen"
	_layer.layer = LAYER
	add_child(_layer)   # generated, never saved
	_canvas = Node2D.new()
	_canvas.name = "Strip"
	_canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_canvas.visible = false
	_layer.add_child(_canvas)
	_canvas.draw.connect(_draw_strip)
	reload()


## (Re)loads the pieces' art and rebuilds the row from it.
func reload() -> void:
	_tex.clear()
	for piece_name in PIECES:
		var t := texture_for(piece_name)
		if t != null:
			_tex[piece_name] = t
	var sizes := {}
	for piece_name in _tex:
		var t: Texture2D = _tex[piece_name]
		sizes[piece_name] = Vector2i(t.get_width(), t.get_height())
	_items = layout(_seed, _u0, _u1, sizes)
	_key = Vector4.ZERO
	if _canvas != null:
		_canvas.visible = false
	set_process(not _items.is_empty())


## The painted texture for a piece name, or null when its PNG is missing.
static func texture_for(piece_name: String) -> Texture2D:
	var path: String = DIR + piece_name + ".png"
	if not _textures.has(path):
		_textures[path] = load(path) if ResourceLoader.exists(path) else null
	return _textures[path]


## Whether any piece has its art (false: the layer draws nothing).
func has_art() -> bool:
	return not _tex.is_empty()


## A stable per-area seed: an FNV-1a hash of the area's id (its global x when the
## node has no id).
static func area_seed(area_id: String, gx0: float) -> int:
	var h: int = 0x811c9dc5
	var bytes: PackedByteArray = (area_id if area_id != "" else "x%d" % int(gx0)).to_utf8_buffer()
	for b in bytes:
		h = ((h ^ int(b)) * 0x01000193) & 0xffffffff
	return h


## The row for the foreground-space span [u0, u1]: an Array of {piece, u (the
## left edge), w (the width, in foreground units), flip}, left to right. `sizes`
## maps each available piece to its art size in pixels. Deterministic in `seed_v`.
static func layout(seed_v: int, u0: float, u1: float, sizes: Dictionary) -> Array:
	var items: Array = []
	var by_kind := {}
	for piece_name in PIECES:
		if sizes.has(piece_name):
			var kind: String = PIECES[piece_name]
			if not by_kind.has(kind):
				by_kind[kind] = []
			by_kind[kind].append(piece_name)
	if by_kind.is_empty():
		return items
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var u: float = u0 + MARGIN + rng.randf_range(0.0, GAP_FAR.y)
	var prev := ""
	var prev2 := ""
	while true:
		var pick := _pick(rng, by_kind, prev, prev2)
		var w: float = float((sizes[pick] as Vector2i).x) * ART_WORLD
		if u + w > u1 - MARGIN:
			break
		items.append({"piece": pick, "u": u, "w": w, "flip": rng.randf() < FLIP_CHANCE})
		prev2 = prev
		prev = pick
		var gap: float
		if rng.randf() < NEAR_CHANCE:
			gap = rng.randf_range(GAP_NEAR.x, GAP_NEAR.y)
		else:
			gap = rng.randf_range(GAP_FAR.x, GAP_FAR.y)
		u += w + gap
	return items


## A weighted piece that is not the previous one's kind and not the piece before
## it (relaxed when the art left too little to choose from).
static func _pick(rng: RandomNumberGenerator, by_kind: Dictionary, prev: String, prev2: String) -> String:
	var prev_kind: String = PIECES.get(prev, "")
	var kinds: Array = []
	var weights: Array = []
	var total := 0.0
	for kind in by_kind:
		if kind == prev_kind and by_kind.size() > 1:
			continue
		kinds.append(kind)
		weights.append(float(KIND_WEIGHT.get(kind, 0.1)))
		total += float(KIND_WEIGHT.get(kind, 0.1))
	var roll: float = rng.randf() * total
	var chosen: String = kinds[kinds.size() - 1]
	for i in kinds.size():
		roll -= float(weights[i])
		if roll <= 0.0:
			chosen = kinds[i]
			break
	var options: Array = (by_kind[chosen] as Array).filter(func(n): return n != prev and n != prev2)
	if options.is_empty():
		options = (by_kind[chosen] as Array).filter(func(n): return n != prev)
	if options.is_empty():
		options = by_kind[chosen]
	return options[rng.randi() % options.size()]


## The foreground-space span this area owns.
func span() -> Vector2:
	return Vector2(_u0, _u1)


## The composed row (see layout()).
func items() -> Array:
	return _items


## Whole screen pixels per art pixel at a camera zoom.
static func pixel_scale(zoom: float) -> int:
	return maxi(1, roundi(ART_WORLD * zoom))


## Whether the view (camera x, zoom, screen size) reaches this area's span.
func view_reaches(cam_x: float, zoom: float, size: Vector2) -> bool:
	var half: float = size.x * 0.5 / maxf(zoom, 0.01)
	return PARALLAX * cam_x + half >= _u0 and PARALLAX * cam_x - half <= _u1


## The pieces on screen for a view (camera x, zoom, screen size): an Array of
## {piece, rect (screen px, the piece standing on the bottom edge), flip}. This
## is exactly what the canvas draws.
func visible_rects(cam_x: float, zoom: float, size: Vector2) -> Array:
	var out: Array = []
	var px: int = pixel_scale(zoom)
	var centre: float = size.x * 0.5
	for it in _items:
		var t: Texture2D = _tex.get(it["piece"])
		if t == null:
			continue
		var w: float = float(t.get_width() * px)
		var h: float = float(t.get_height() * px)
		var left: float = roundf(centre + (float(it["u"]) - PARALLAX * cam_x) * zoom)
		if left >= size.x or left + w <= 0.0:
			continue
		out.append({"piece": it["piece"], "rect": Rect2(left, size.y - h, w, h), "flip": it["flip"]})
	return out


## Reads the camera: the world x at the middle of the view and its zoom.
func _read_view() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var ct := vp.get_canvas_transform()
	_zoom = maxf(ct.get_scale().x, 0.01)
	_view_size = vp.get_visible_rect().size
	_cam_x = (ct.affine_inverse() * (_view_size * 0.5)).x


func _process(_delta: float) -> void:
	_read_view()
	if not view_reaches(_cam_x, _zoom, _view_size):
		if _canvas.visible:
			_canvas.visible = false
		return
	var key := Vector4(_cam_x, _zoom, _view_size.x, _view_size.y)
	if not _canvas.visible:
		_canvas.visible = true
		_key = Vector4.ZERO
	if key != _key:
		_key = key
		_canvas.queue_redraw()


func _draw_strip() -> void:
	_read_view()   # the camera's transform right now, whatever moved since _process
	for r in visible_rects(_cam_x, _zoom, _view_size):
		var tex: Texture2D = _tex[r["piece"]]
		var rect: Rect2 = r["rect"]
		if r["flip"]:
			_canvas.draw_set_transform(Vector2(rect.end.x, rect.position.y), 0.0, Vector2(-1.0, 1.0))
			_canvas.draw_texture_rect(tex, Rect2(Vector2.ZERO, rect.size), false, tint)
			_canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			_canvas.draw_texture_rect(tex, rect, false, tint)
