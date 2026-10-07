extends RefCounted
## The painted pixel-art interactive objects: the user's generated objects
## sheet (concept-art/env-sunnyvale/sunnyvale-objects-v1.webp), cut into pieces
## by tools/art/import_pixel_sheet.py objects and drawn by the object scripts
## (recovery station, workbench, weapon pad, core node, emergency hatch, exit
## wicket, route switch) at 1.5 world px per art pixel, like the terrain, props
## and buildings. No `class_name` (M6 art-pass import-cache rule): the objects
## preload it by path.
##
## This sheet's generated pixels came out at the campus layer's size (about
## 5.3 px), so every piece was imported with 2 x 2 art pixels per generated
## pixel, like the buildings: a recovery station stands 135 world px tall next
## to Dave's 94.
##
## A piece is drawn as it is, native pixels, bottom-centre on the object's
## origin (a piece listed in ANCHORS stands on its own ground point instead).
## The depot draws them too. A missing PNG makes `has_piece()` false and the
## object falls back to its code-drawn look.

const ART := 1.5
const DIR := "res://assets/environment/sunnyvale/objects/"

## Pieces whose ground point is not the bottom-centre: the point of the piece
## that stands on the object's origin, in art px from its top-left corner. A
## lever's two states are the same plate, so both put the plate's
## bottom-centre 4 art px (6 world px) above the origin: the plate never
## moves between states and the lowered lever's tip rests on the ground.
const ANCHORS := {
	"lever_up": Vector2(14.0, 42.0),
	"lever_down": Vector2(13.0, 34.0),
}

## A taller piece repeats a band of its rows [from, to) (art px) to reach the
## height of the thing it stands for, so no pixel is scaled. The hatch's band
## is one stripe period of its hazard posts, between the header and the handle.
const BANDS := {
	"hatch_closed": Vector2i(20, 34),
	"hatch_open": Vector2i(18, 32),
}

static var _textures := {}


static func texture(piece: String) -> Texture2D:
	if not _textures.has(piece):
		var path: String = DIR + piece + ".png"
		_textures[piece] = load(path) if ResourceLoader.exists(path) else null
	return _textures[piece]


static func has_piece(piece: String) -> bool:
	return texture(piece) != null


## True when every one of `pieces` has its PNG: an object with several states
## draws painted only when it has them all.
static func has_pieces(pieces: Array) -> bool:
	for p in pieces:
		if not has_piece(p):
			return false
	return true


## The piece's size in world px.
static func piece_size(piece: String) -> Vector2:
	var tex := texture(piece)
	return Vector2(tex.get_width(), tex.get_height()) * ART


## Where the piece's art-px point `art` (from its top-left corner) lands,
## relative to the object's origin, in world px.
static func at(piece: String, art: Vector2) -> Vector2:
	return (_top_left(piece) + art) * ART


## Draws the piece standing on the canvas origin.
static func draw(c: CanvasItem, piece: String, tint: Color = Color.WHITE) -> void:
	var tex := texture(piece)
	c.draw_texture_rect(tex, Rect2(_top_left(piece) * ART, Vector2(tex.get_width(), tex.get_height()) * ART), false, tint)


## How many more copies of the piece's BANDS rows it takes to come close to a
## thing `height` world px tall.
static func repeats(piece: String, height: float) -> int:
	var band: Vector2i = BANDS[piece]
	return maxi(0, roundi((height / ART - texture(piece).get_height()) / (band.y - band.x)))


## Draws the piece standing on the origin with its band repeated `n` more times.
static func draw_tall(c: CanvasItem, piece: String, n: int, tint: Color = Color.WHITE) -> void:
	var tex := texture(piece)
	var band: Vector2i = BANDS[piece]
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var period: int = band.y - band.x
	var x: float = floorf(-tw * 0.5)
	var y: float = -(th + n * period)
	_blit(c, tex, Rect2(0.0, 0.0, tw, band.y), Vector2(x, y), tint)
	y += band.y
	for i in n:
		_blit(c, tex, Rect2(0.0, band.x, tw, period), Vector2(x, y), tint)
		y += period
	_blit(c, tex, Rect2(0.0, band.y, tw, th - band.y), Vector2(x, y), tint)


## Makes `node` draw crisp pixels while its own text children (a toast) stay
## smooth: the filter is inherited by every child.
static func make_crisp(node: CanvasItem) -> void:
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for child in node.get_children():
		if child is Label:
			(child as Label).texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


static func _top_left(piece: String) -> Vector2:
	var tex := texture(piece)
	var a: Vector2 = ANCHORS.get(piece, Vector2(tex.get_width() * 0.5, tex.get_height()))
	return Vector2(floorf(-a.x), -a.y)


static func _blit(c: CanvasItem, tex: Texture2D, src: Rect2, at_art: Vector2, tint: Color = Color.WHITE) -> void:
	c.draw_texture_rect_region(tex, Rect2(at_art * ART, src.size * ART), src, tint)
