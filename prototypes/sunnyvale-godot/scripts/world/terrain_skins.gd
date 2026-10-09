extends RefCounted
## The painted pixel-art terrain (C39): the user's generated terrain sheet
## (concept-art/env-sunnyvale/sunnyvale-terrain-v1.webp), cut into pieces by
## tools/art/import_pixel_sheet.py terrain, drawn by Block (and the roof
## supports by Scenery) at 1.5 world px per art pixel, the same pixel size
## as the painted background layers. No `class_name` (M6 art-pass
## import-cache rule): Block and Scenery preload it by path.
##
## Each skin stretches its piece to a block of any size without scaling a
## pixel: the end caps stay, the middle columns repeat sideways (in phase
## with the block's global x, so two blocks that meet continue one pattern
## and skip their caps there), and vertically the piece's walkable lit edge
## (`edge`) sits on the block's top, with anything above it (hedges, grass)
## hanging over. A block taller than the piece repeats its `body` rows
## (keeping the bottom rows at the bottom), or, for a skin without a body,
## continues with the wall face (`below`) and then plain shadow. A block
## thinner than the piece crops it, keeping its bottom rows.
##
## The walkway and the wall face under it come from the wet-paving sheet
## (concept-art/env-sunnyvale/sunnyvale-paving-v1.webp, tools/art/import_pixel_sheet.py
## paving): two long strips whose whole width is the repeating period, kept
## between 1-pixel outline caps that only a lone block's ends show.
##
## Rows and columns are in art pixels of the imported PNG. A missing PNG
## (an export without the art) makes `has_skin()` false and the caller
## falls back to its code-drawn look.

const ART := 1.5
const ROOT := "res://assets/environment/sunnyvale/"
## Where a piece named without a folder lives (the terrain sheet).
const DIR := ROOT + "terrain/"
## The plain shadow under a wall face (Block.DEEP).
const DEEP := Color("#0A0F18")
## How far a `below` wall face runs before the shadow takes over (art px): the
## wall piece once, three brick courses, so it ends on a mortar line.
const FACE_DEPTH := 54

## tex: piece name ("sheet/piece" when it is not from the terrain sheet);
## edge: the walkable top row; from: first row drawn (rows above it are left
## out); to: the row a wall face stops at before it repeats (default: 3 rows
## short of the piece, leaving out its bottom outline); cols: the repeating
## middle columns [c0, c1);
## body: the rows that repeat to fill a taller block [b0, b1) (optional);
## tint: a colour the piece is multiplied by (optional); below: the skin
## that continues under a block taller than the piece
## (optional); tall: the skin that continues under a block more than twice
## the piece's height, in place of repeating the body (optional); whole: draw
## the piece as it is, no slicing.
const SKINS := {
	# GROUND / PORCH: wet paving, a thin lit edge (its own top row, under the
	# strip's outline row) over slab joints and orange and teal puddle streaks.
	"walkway": {"tex": "paving/paving", "edge": 1, "from": 1, "cols": Vector2i(1, 345), "below": "wall_face"},
	# The brick wall under the walkway (its top outline row left out, so the
	# first row is the lit brick top), dimmed so it falls back into shadow
	# under the lit walking surface (C24 "a large near-black shadow mass") and
	# never competes with the characters. It repeats downward as well.
	"wall_face": {"tex": "paving/wall", "edge": 1, "from": 1, "to": 55, "cols": Vector2i(1, 336),
			"tint": Color(0.42, 0.45, 0.55)},
	# PLATFORM: a concrete planter ledge with a clipped hedge behind the edge.
	"planter_ledge": {"tex": "planter_ledge", "edge": 22, "cols": Vector2i(3, 191), "body": Vector2i(24, 40),
			"tall": "wall_face", "tint": Color(0.84, 0.86, 0.92)},
	# ROOF: a green-roof slab with uplights.
	"green_roof": {"tex": "green_roof", "edge": 13, "cols": Vector2i(2, 220), "body": Vector2i(25, 29)},
	# BACKSTOP: a heavy stone planter block, left without its hedge so it
	# never looks taller than the wall Dave has to clear.
	"stone_planter": {"tex": "stone_planter", "edge": 29, "from": 27, "cols": Vector2i(4, 56),
			"body": Vector2i(44, 75)},
	# BACKSTOP on the roofs: the rooftop AC unit, drawn whole (its block is
	# sized to it).
	"ac_unit": {"tex": "ac_unit", "edge": 2, "whole": true},
	# WALL: the garden wall, a planter box with hedge and hanging vines.
	"retaining_wall": {"tex": "retaining_wall", "edge": 19, "cols": Vector2i(3, 217),
			"tint": Color(0.7, 0.73, 0.82)},
}

## The roof support column (Scenery SUPPORT): cap rows, then a lattice
## period that repeats, then the foot.
const COLUMN := "support_column"
const COLUMN_BODY := Vector2i(22, 49)
const COLUMN_FOOT := 121

static var _textures := {}


static func texture(piece: String) -> Texture2D:
	if not _textures.has(piece):
		var path: String = (ROOT if piece.contains("/") else DIR) + piece + ".png"
		_textures[piece] = load(path) if ResourceLoader.exists(path) else null
	return _textures[piece]


static func has_skin(skin: String) -> bool:
	return SKINS.has(skin) and texture(SKINS[skin]["tex"]) != null


## Draws `skin` over a block of `size` (world px) whose top-left is at the
## canvas origin. `gx` is the block's global x (keeps the sideways pattern in
## phase); `join` says whether a same-skinned block continues on the left
## (x) / right (y), so that side skips its end cap.
static func draw_block(c: CanvasItem, skin: String, size: Vector2, gx: float, join: Vector2i) -> void:
	var s: Dictionary = SKINS[skin]
	var tex := texture(s["tex"])
	if s.has("tall") and size.y > (tex.get_height() - int(s["edge"])) * ART * 2.0:
		# A tall planter bed reaching the ground: the piece at its own height,
		# then the wall face, instead of one long repeated ledge.
		s = s.duplicate()
		s.erase("body")
		s["below"] = s["tall"]
	var w: float = size.x / ART
	var h: float = size.y / ART
	var th: int = tex.get_height()
	var edge: int = s["edge"]
	var from: int = s.get("from", 0)
	if s.get("whole", false):
		_blit(c, tex, Rect2(0.0, 0.0, tex.get_width(), th), Vector2(0.0, -edge))
		return
	if s.has("body"):
		var body: Vector2i = s["body"]
		var top_end: float = body.x - edge      # art rows below the block top where the top band ends
		var bottom_y: float = h - (th - body.y)  # where the bottom rows start
		if bottom_y >= top_end:
			_band(c, s, tex, from, body.x, from - edge, w, gx, join)
			var y: float = top_end
			while y < bottom_y - 0.01:
				var n: float = minf(body.y - body.x, bottom_y - y)
				_band(c, s, tex, body.x, body.x + n, y, w, gx, join)
				y += n
			_band(c, s, tex, body.y, th, bottom_y, w, gx, join)
		else:
			# Thinner than the piece: crop it, keeping the bottom rows.
			_band(c, s, tex, from, edge + maxf(bottom_y, 0.0), from - edge, w, gx, join)
			var f0: float = maxf(float(body.y), th - h)
			_band(c, s, tex, f0, th, h - (th - f0), w, gx, join)
		return
	# No body: the piece at its own height (cropped to a thinner block),
	# then the wall face below it, then shadow.
	var art_h: float = minf(th - edge, h)
	_band(c, s, tex, from, edge + art_h, from - edge, w, gx, join)
	var y0: float = art_h
	if y0 < h and s.has("below") and has_skin(s["below"]):   # no wall piece: plain shadow
		var f: Dictionary = SKINS[s["below"]]
		var ftex := texture(f["tex"])
		var r0: int = f.get("from", 0)
		var r1: int = f.get("to", ftex.get_height() - 3)   # leave out the face's own bottom outline
		var face_end: float = minf(h, y0 + FACE_DEPTH)
		var y: float = y0
		while y < face_end - 0.01:
			var n: float = minf(r1 - r0, face_end - y)
			_band(c, f, ftex, r0, r0 + n, y, w, gx, join)
			y += n
		y0 = face_end
	if y0 < h:
		c.draw_rect(Rect2(Vector2(0.0, y0 * ART), Vector2(size.x, (h - y0) * ART)), DEEP)


## One horizontal band: texture rows [r0, r1) drawn `w` art px wide at art
## row `y` (relative to the block top): left cap, the middle columns
## repeating in phase with the global x, right cap.
static func _band(c: CanvasItem, s: Dictionary, tex: Texture2D, r0: float, r1: float, y: float, w: float,
		gx: float, join: Vector2i) -> void:
	var tint: Color = s.get("tint", Color.WHITE)
	for p in band_pieces(s, tex.get_width(), r0, r1, y, w, gx, join):
		_blit(c, tex, p[0], p[1], tint)


## The pieces of a band, as [source Rect2 in the texture, destination in art
## px]: the left cap, the right cap, then the middle's tiles in order (a
## tile's source starts where the previous one stopped, wrapping at the
## period, so two blocks that meet continue one pattern).
static func band_pieces(s: Dictionary, tw: int, r0: float, r1: float, y: float, w: float,
		gx: float, join: Vector2i) -> Array:
	var out := []
	if r1 <= r0:
		return out
	var cols: Vector2i = s.get("cols", Vector2i(0, tw))
	var lcap: float = 0.0 if join.x != 0 else float(cols.x)
	var rcap: float = 0.0 if join.y != 0 else float(tw - cols.y)
	if lcap + rcap > w:
		var k: float = w / (lcap + rcap)
		lcap = floorf(lcap * k)
		rcap = w - lcap
	var rh: float = r1 - r0
	if lcap > 0.0:
		out.append([Rect2(0.0, r0, lcap, rh), Vector2(0.0, y)])
	if rcap > 0.0:
		out.append([Rect2(tw - rcap, r0, rcap, rh), Vector2(w - rcap, y)])
	var period: float = float(cols.y - cols.x)
	var x: float = lcap
	var x_end: float = w - rcap
	while x < x_end - 0.01:
		var phase: float = fposmod(gx / ART + x, period)
		if period - phase < 0.01:
			phase = 0.0   # a hair under a whole period: start a fresh tile (else n ~ 0 never advances x)
		var n: float = minf(period - phase, x_end - x)
		out.append([Rect2(cols.x + phase, r0, n, rh), Vector2(x, y)])
		x += n
	return out


static func _blit(c: CanvasItem, tex: Texture2D, src: Rect2, at: Vector2, tint: Color = Color.WHITE) -> void:
	c.draw_texture_rect_region(tex, Rect2(at * ART, src.size * ART), src, tint)


## The roof support column, `h` world px tall, standing on the canvas origin
## (bottom-centre pivot, like every Scenery prop).
static func draw_column(c: CanvasItem, h: float) -> bool:
	var tex := texture(COLUMN)
	if tex == null:
		return false
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var ha: float = h / ART
	var x: float = -tw * 0.5
	var head: int = COLUMN_BODY.x
	var foot: int = th - COLUMN_FOOT
	if ha <= head + foot:
		_blit(c, tex, Rect2(0.0, th - ha, tw, ha), Vector2(x, -ha))
		return true
	_blit(c, tex, Rect2(0.0, 0.0, tw, head), Vector2(x, -ha))
	var y: float = -ha + head
	var stop: float = -foot
	var period: int = COLUMN_BODY.y - COLUMN_BODY.x
	while y < stop - 0.01:
		var n: float = minf(period, stop - y)
		_blit(c, tex, Rect2(0.0, COLUMN_BODY.x, tw, n), Vector2(x, y))
		y += n
	_blit(c, tex, Rect2(0.0, COLUMN_FOOT, tw, foot), Vector2(x, -foot))
	return true
