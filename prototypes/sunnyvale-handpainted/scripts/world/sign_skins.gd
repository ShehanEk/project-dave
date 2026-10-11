extends RefCounted
## The painted sign panels and hologram projector (Sheet 3's blank sign panels
## and billboard projector, plus Sheet 10's pixel font): sets a sign's text in
## the pixel font on one of the three buildings-sheet panels, and draws the
## projector housing under a hologram. Drawn by Scenery (SIGN and
## CLOUD_PROJECTOR) at 1.5 world px per art pixel. No `class_name` (M6 art-pass
## import-cache rule): Scenery preloads it by path.
##
## The panels were imported with 2 x 2 art pixels per generated pixel (like the
## rest of the buildings sheet), so every cut below is on a 2-pixel boundary.
## A sign of any size is made without scaling a pixel: the panel's end caps and
## its decorated left side stay, one plain column (`cols`) is repeated sideways
## to the board's width, and one row (`rows`) is repeated downwards to its
## height. The frame is the panel's teal; a hue shift (`tinted()`) turns it
## green for an exit sign and amber or red in the lockdown, like the code-drawn
## board did.
##
## The projector hangs under a ledge in the sheet (lens pointing down); the
## hologram sits above its projector, so it is drawn upside down (a flipped
## texture rect is still the same pixels), its lens at the cone's apex.

const ART := 1.5
const DIR := "res://assets/environment/sunnyvale/buildings/"
const PixelFont := preload("res://scripts/world/pixel_font.gd")

## Each panel: its size in art px, the column pair and the row pair (art px,
## [from, to)) that repeat. Every repeated column is identical across all rows
## (and the rows below the sheen differ little), so repeating them leaves no
## seam.
const PANELS := {
	"sign_s": {"size": Vector2i(50, 18), "cols": Vector2i(32, 34), "rows": Vector2i(6, 8)},
	"sign_m": {"size": Vector2i(78, 22), "cols": Vector2i(40, 42), "rows": Vector2i(8, 10)},
	"sign_l": {"size": Vector2i(112, 24), "cols": Vector2i(88, 90), "rows": Vector2i(8, 10)},
}
## The teal of the panel's frame: the hue a tint is shifted from.
const FRAME_TEAL := Color("#16abb5")
## Art px from the board's edge to its interior (a one-pixel dark margin and a
## one-pixel frame, both 2 x 2 art pixels).
const CAP := 4
## Blank art px between the text and the interior's side.
const PAD_X := 2
## A board is at most this fraction of the sign's height (the legs show below).
const BOARD_MAX := [0.62, 0.8]
## A board shrinks to fit a short text, but never below this fraction of the
## sign's width.
const SNUG_MIN := 0.7

## The projector in the sheet: 96 x 36 art px, its lens centre 4 art rows (6
## world px) under the top of the housing once it is flipped upside down.
const PROJECTOR := "projector"
const PROJECTOR_SIZE := Vector2i(96, 36)
const PROJECTOR_LENS_Y := 4.0

static var _textures := {}
static var _tinted := {}


static func texture(piece: String) -> Texture2D:
	var path: String = DIR + piece + ".png"
	if not _textures.has(path):
		_textures[path] = load(path) if ResourceLoader.exists(path) else null
	return _textures[path]


static func has_panels() -> bool:
	for p in PANELS:
		if texture(p) == null:
			return false
	return true


static func has_projector() -> bool:
	return texture(PROJECTOR) != null


## `piece` recoloured to `tint`: every pixel keeps its saturation and value but
## takes the tint's hue instead of the frame's teal. The teal itself draws the
## panel as it is.
static func tinted(piece: String, tint: Color) -> Texture2D:
	var tex := texture(piece)
	if tex == null or absf(tint.h - FRAME_TEAL.h) < 0.04:
		return tex
	var key := "%s|%s" % [piece, tint.to_html(false)]
	if not _tinted.has(key):
		# a copy: the headless renderer hands out the texture's own image
		var img: Image = tex.get_image().duplicate()
		if img.is_compressed():
			img.decompress()
		var dh: float = tint.h - FRAME_TEAL.h
		for y in img.get_height():
			for x in img.get_width():
				var c: Color = img.get_pixel(x, y)
				img.set_pixel(x, y, Color.from_hsv(fposmod(c.h + dh, 1.0), c.s, c.v, c.a))
		_tinted[key] = ImageTexture.create_from_image(img)
	return _tinted[key]


## The panel for a board `cols` art px wide: the largest whose narrowest form
## (its repeated column dropped) is no wider.
static func pick(cols: int) -> String:
	var best := "sign_s"
	for p in ["sign_s", "sign_m", "sign_l"]:
		if _fixed(p).x <= cols + 2:
			best = p
	return best


static func _even_up(n: float) -> int:
	return int(ceilf(n * 0.5)) * 2


## How a SIGN of `size` (world px) with `text` is built, or {} when the text
## cannot be set in the pixel font on a panel (no panels, no font, a character
## the font lacks, or no size that fits). Everything is in art px, from the
## board's top-left corner:
##   piece   "sign_s" / "sign_m" / "sign_l"
##   cols, rows   the board's size (its width and height are whole repeats)
##   lines, scale, block   the text (PixelFont.fit()) and its world px size
##   text_at   the top-left of the text block, art px
static func plan(text: String, size: Vector2) -> Dictionary:
	if not has_panels() or not PixelFont.has_font() or not PixelFont.covers(text):
		return {}
	var avail: int = int(floorf(size.x / ART * 0.5)) * 2
	var piece: String = pick(avail)
	var fixed: Vector2i = _fixed(piece)
	var cols_max: int = maxi(avail, fixed.x)
	var fitted := {}
	if text.strip_edges() == "":
		fitted = {"lines": PackedStringArray(), "scale": 1, "size": Vector2.ZERO}
	for frac in BOARD_MAX:
		if not fitted.is_empty():
			break
		var rows_max: int = int(size.y * float(frac) / ART)
		for s in [2, 1]:
			fitted = PixelFont.fit(text, float(cols_max - 2 * CAP - 2 * PAD_X) * ART,
					float(rows_max - 2 * CAP - 2 * _pad_y(s)) * ART, 3, [s])
			if not fitted.is_empty():
				break
	if fitted.is_empty():
		return {}
	var scale: int = fitted["scale"]
	var block: Vector2 = fitted["size"]
	var block_cols: int = roundi(block.x / ART)
	var block_rows: int = roundi(block.y / ART)
	var cols: int = clampi(_even_up(float(block_cols + 2 * CAP + 4 * PAD_X)), _even_up(float(cols_max) * SNUG_MIN), cols_max)
	cols = maxi(cols, fixed.x)
	var rows: int = maxi(fixed.y, _even_up(float(block_rows + 2 * CAP + 2 * _pad_y(scale))))
	var tx: int = CAP + ((cols - 2 * CAP - block_cols) >> 1)
	var ty: int = CAP + ((rows - 2 * CAP - block_rows) >> 1)
	if scale == 2:
		tx -= tx % 2
		ty -= ty % 2
	return {"piece": piece, "cols": cols, "rows": rows, "lines": fitted["lines"], "scale": scale,
			"block": block, "text_at": Vector2i(tx, ty)}


## Blank art px above and below the text: a little more for larger text.
static func _pad_y(scale: int) -> int:
	return 2 * scale + 1


## The narrowest and shortest board of `piece` (its repeated column and row
## dropped), in art px.
static func _fixed(piece: String) -> Vector2i:
	var p: Dictionary = PANELS[piece]
	var size: Vector2i = p["size"]
	var uc: Vector2i = p["cols"]
	var ur: Vector2i = p["rows"]
	return Vector2i(size.x - (uc.y - uc.x), size.y - (ur.y - ur.x))


## The board's top-left corner in the sign's local world px when its top edge
## sits at `top` (world px, negative above the origin): centred sideways, on the
## art grid.
static func board_origin(cols: int, top: float) -> Vector2:
	return Vector2(floorf(-float(cols) * 0.5) * ART, roundf(top / ART) * ART)


## The blits that make a `piece` board of `cols` x `rows` art px: each is
## [source rect in the piece, destination rect on the board], both in art px.
## The repeated column and row stretch by a whole number of their own width,
## which draws the same pixels as repeating them; the pieces tile the board
## exactly.
static func slices(piece: String, cols: int, rows: int) -> Array:
	var p: Dictionary = PANELS[piece]
	var size: Vector2i = p["size"]
	var uc: Vector2i = p["cols"]
	var ur: Vector2i = p["rows"]
	var xs := [Vector2i(0, uc.x), Vector2i(uc.x, uc.y), Vector2i(uc.y, size.x)]
	var ys := [Vector2i(0, ur.x), Vector2i(ur.x, ur.y), Vector2i(ur.y, size.y)]
	var dw: Array = [uc.x, cols - (size.x - (uc.y - uc.x)), size.x - uc.y]
	var dh: Array = [ur.x, rows - (size.y - (ur.y - ur.x)), size.y - ur.y]
	var out := []
	var y := 0
	for j in 3:
		var x := 0
		if dh[j] > 0:
			for i in 3:
				if dw[i] > 0:
					out.append([Rect2(xs[i].x, ys[j].x, xs[i].y - xs[i].x, ys[j].y - ys[j].x),
							Rect2(x, y, dw[i], dh[j])])
				x += dw[i]
		y += dh[j]
	return out


## Draws the `piece` board of `cols` x `rows` art px with its top-left corner at
## `at` (world px), the frame recoloured to `tint`.
static func draw_panel(c: CanvasItem, piece: String, cols: int, rows: int, at: Vector2, tint: Color) -> void:
	var tex := tinted(piece, tint)
	if tex == null:
		return
	for sl in slices(piece, cols, rows):
		var dst: Rect2 = sl[1]
		c.draw_texture_rect_region(tex, Rect2(at + dst.position * ART, dst.size * ART), sl[0])


## The projector housing, upside down under a hologram, its lens centre at `lens`
## (the cone's apex, in the prop's local world px).
static func draw_projector(c: CanvasItem, lens: Vector2) -> void:
	var tex := texture(PROJECTOR)
	if tex == null:
		return
	var w: float = float(PROJECTOR_SIZE.x) * ART
	var h: float = float(PROJECTOR_SIZE.y) * ART
	var top := Vector2(roundf((lens.x - w * 0.5) / ART) * ART, roundf((lens.y - PROJECTOR_LENS_Y * ART) / ART) * ART)
	c.draw_texture_rect_region(tex, Rect2(top + Vector2(0.0, h), Vector2(w, -h)),
			Rect2(0.0, 0.0, float(PROJECTOR_SIZE.x), float(PROJECTOR_SIZE.y)))
