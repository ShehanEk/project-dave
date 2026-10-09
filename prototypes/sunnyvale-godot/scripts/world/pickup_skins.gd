extends RefCounted
## The painted pixel-art pickups, practice target and walkway pieces: the
## user's second generated objects sheet
## (concept-art/env-sunnyvale/sunnyvale-objects2-v1.webp), cut into pieces by
## tools/art/import_pixel_sheet.py objects2 and drawn by the chip, chip
## cache, keycard, med-patch, evidence file, practice target, service walkway,
## moving platform and pit hazard at 1.5 world px per art pixel, like the
## terrain, props and buildings. No `class_name` (M6 art-pass import-cache
## rule): the objects preload it by path. (Its sibling for the first objects
## sheet is object_skins.gd.)
##
## This sheet's generated pixels came out about 7 px, so every piece was
## imported with 2 x 2 art pixels per generated pixel (3 world px): a chip
## stands 30 world px, the walkway is 18 px thick (its collision is 20) and the
## pit cover 54 px tall.
##
## A pickup is drawn as it is, native pixels, centred on the object's origin
## (`draw_centred`) or standing on it (`draw_standing`). The three sized
## pieces stretch to any size without scaling a pixel (`draw_sized`): LAYOUTS
## says which columns and rows stay and which repeat. A missing PNG makes
## `has_piece()` false and the object falls back to its code-drawn look.

const ART := 1.5
const DIR := "res://assets/environment/sunnyvale/objects2/"

## How a sized piece stretches, in art px of the imported PNG. `cols` and `rows`
## list segments (from, to, repeats): a fixed one is drawn once, a repeating
## one takes the slack (shared equally) by repeating its slice; source
## ranges between segments are left out. `shift` (rows only): each further
## repeat of the rows moves its columns this many art px along, so diagonal
## stripes carry on through the seam.
## - Walkway: the grating repeats between two end caps (its lit rim is the top).
## - Platform: three lights under a plate; plain plate repeats on either side
##   of the middle light, so the lights stay put in the caps and the middle.
## - Pit cover: two uprights, stripes that repeat in whole periods (two
##   stripes, 46) between them, rails above and below; the rows between the
##   rails repeat when it is taller, and are cropped from the bottom when it
##   is shorter (the lower rail hides the cut).
const LAYOUTS := {
	"service_walkway": {
		"cols": [Vector3i(0, 6, 0), Vector3i(6, 70, 1), Vector3i(134, 140, 0)],
		"rows": [Vector3i(0, 8, 0), Vector3i(8, 10, 1), Vector3i(10, 12, 0)],
	},
	"moving_platform": {
		"cols": [Vector3i(0, 26, 0), Vector3i(26, 36, 1), Vector3i(36, 60, 0), Vector3i(60, 70, 1), Vector3i(70, 98, 0)],
		"rows": [Vector3i(0, 20, 0)],
	},
	"pit_cover": {
		"cols": [Vector3i(0, 6, 0), Vector3i(6, 52, 1), Vector3i(120, 124, 0)],
		"rows": [Vector3i(0, 10, 0), Vector3i(10, 26, 1), Vector3i(26, 36, 0)],
		"shift": 14,
	},
}

static var _textures := {}


static func texture(piece: String) -> Texture2D:
	if not _textures.has(piece):
		var path: String = DIR + piece + ".png"
		_textures[piece] = load(path) if ResourceLoader.exists(path) else null
	return _textures[piece]


static func has_piece(piece: String) -> bool:
	return texture(piece) != null


## The piece's size in world px.
static func piece_size(piece: String) -> Vector2:
	var tex := texture(piece)
	return Vector2(tex.get_width(), tex.get_height()) * ART


## Draws the piece centred on `at` (world px, default the canvas origin).
static func draw_centred(c: CanvasItem, piece: String, at: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void:
	var tex := texture(piece)
	c.draw_texture_rect(tex, Rect2(at - piece_size(piece) * 0.5, piece_size(piece)), false, tint)


## Draws the piece standing on `at`: bottom-centre on it.
static func draw_standing(c: CanvasItem, piece: String, at: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void:
	var tex := texture(piece)
	var s := piece_size(piece)
	c.draw_texture_rect(tex, Rect2(at - Vector2(s.x * 0.5, s.y), s), false, tint)


## Where the piece's art-px point `art` (from its top-left corner) lands,
## relative to the origin, for a piece drawn standing on it.
static func standing_at(piece: String, art: Vector2) -> Vector2:
	var s := piece_size(piece)
	return Vector2(-s.x * 0.5, -s.y) + art * ART


## Draws the art-px rectangle `src` of the piece with its top-left corner at
## `at` (world px).
static func blit(c: CanvasItem, piece: String, src: Rect2, at: Vector2, tint: Color = Color.WHITE) -> void:
	if src.size.x <= 0.0 or src.size.y <= 0.0:
		return
	c.draw_texture_rect_region(texture(piece), Rect2(at, src.size * ART), src, tint)


## Makes `node` draw crisp pixels while its own text children (a toast) stay
## smooth: the filter is inherited by every child.
static func make_crisp(node: CanvasItem) -> void:
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for child in node.get_children():
		if child is Label:
			(child as Label).texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


## The sized piece, stretched over `size` (world px) with its top-left corner at
## `at` (world px): whole art pixels (a leftover under 1.5 px is split to both
## sides), the lit top on `at.y`. A static piece passes the canvas origin's
## global x as `global_x`, so the repeating columns stay in phase with the
## world and neighbours continue one pattern; a moving one leaves it NAN and
## its repeats start at their slice's first column. Returns the painted left
## edge's x on the canvas.
static func draw_sized(c: CanvasItem, piece: String, at: Vector2, size: Vector2, global_x: float = NAN,
		tint: Color = Color.WHITE) -> float:
	var layout: Dictionary = LAYOUTS[piece]
	var w: int = 2 * roundi(size.x / (2.0 * ART))   # even, so a generated pixel stays whole
	var h: int = roundi(size.y / ART)
	var left: float = at.x + (size.x - w * ART) * 0.5
	var base: int = 0 if is_nan(global_x) else floori((global_x + left) / ART)
	for row in _row_runs(layout, h):
		for run in _col_runs(layout["cols"], w, base + int(row.w), not is_nan(global_x)):
			blit(c, piece, Rect2(run.x, row.x, run.y - run.x, row.y - row.x),
					Vector2(left + float(run.z) * ART, at.y + float(row.z) * ART), tint)
	return left


## Where the source column `col` of a fixed segment of the sized piece lands:
## the world x offset from `at.x` of `draw_sized` for a piece `width` px wide,
## or NAN when a piece that narrow leaves that column out.
static func column_x(piece: String, width: float, col: int) -> float:
	var w: int = 2 * roundi(width / (2.0 * ART))
	var left: float = (width - w * ART) * 0.5
	for run in _col_runs(LAYOUTS[piece]["cols"], w, 0, false):
		if col >= run.x and col < run.y:
			return left + float(run.z + col - run.x) * ART
	return NAN


## The column runs (Vector3i source from, source to, destination col) that
## fill `w` art px. Under the fixed segments' width it keeps the left half and
## the right half of the piece's caps instead. A repeat starts `base` art px
## into its slice, plus its own destination col when `global_phase` is set.
static func _col_runs(segs: Array, w: int, base: int, global_phase: bool) -> Array:
	var fixed := 0
	var repeating := 0
	for s: Vector3i in segs:
		if s.z == 0:
			fixed += s.y - s.x
		else:
			repeating += 1
	var runs := []
	if w < fixed:
		var take: int = w / 2
		var x := 0
		for s: Vector3i in segs:
			if s.z != 0 or x >= take:
				continue
			var n: int = mini(s.y - s.x, take - x)
			runs.append(Vector3i(s.x, s.x + n, x))
			x += n
		x = w
		for i in range(segs.size() - 1, -1, -1):
			var s: Vector3i = segs[i]
			if s.z != 0 or x <= take:
				continue
			var n: int = mini(s.y - s.x, x - take)
			runs.append(Vector3i(s.y - n, s.y, x - n))
			x -= n
		return runs
	var slack: int = w - fixed
	var x := 0
	var seen := 0
	for s: Vector3i in segs:
		var span: int = s.y - s.x
		if s.z == 0:
			runs.append(Vector3i(s.x, s.y, x))
			x += span
			continue
		seen += 1
		var share: int = slack / repeating + (slack % repeating if seen == repeating else 0)
		var done := 0
		while done < share:
			var off: int = posmod(base + (x if global_phase else 0) + done, span)
			var n: int = mini(span - off, share - done)
			runs.append(Vector3i(s.x + off, s.x + off + n, x + done))
			done += n
		x += share
	return runs


## The row runs (Vector4i source from, source to, destination row, extra
## column phase) that fill `h` art rows: the repeating rows take the slack,
## cropped from the bottom when short and repeated, each copy moved along by
## the layout's `shift`, when long. Under the fixed rows' height the last
## fixed rows are cut off.
static func _row_runs(layout: Dictionary, h: int) -> Array:
	var segs: Array = layout["rows"]
	var shift: int = layout.get("shift", 0)
	var fixed := 0
	var repeating := 0
	for s: Vector3i in segs:
		if s.z == 0:
			fixed += s.y - s.x
		else:
			repeating += 1
	var runs := []
	var slack: int = maxi(h - fixed, 0)
	var y := 0
	var seen := 0
	for s: Vector3i in segs:
		var span: int = s.y - s.x
		if s.z == 0:
			var n: int = mini(span, h - y)
			if n > 0:
				runs.append(Vector4i(s.x, s.x + n, y, 0))
				y += n
			continue
		seen += 1
		var share: int = slack / repeating + (slack % repeating if seen == repeating else 0)
		var done := 0
		var k := 0
		while done < share:
			var n: int = mini(span, share - done)
			runs.append(Vector4i(s.x, s.x + n, y, shift * k))
			y += n
			done += n
			k += 1
	return runs
