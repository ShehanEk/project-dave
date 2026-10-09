extends RefCounted
## The painted pixel-art street furniture (C42): the user's generated props
## sheet (concept-art/env-sunnyvale/sunnyvale-props-v1.webp), cut into pieces
## by tools/art/import_pixel_sheet.py props and drawn by Scenery at 1.5 world
## px per art pixel, like the terrain. No `class_name` (M6 art-pass
## import-cache rule): Scenery preloads it by path.
##
## The generator drew these objects at the requested size but with pixels
## half the requested size, so they keep one art pixel per generated pixel:
## the right size next to Dave, with finer pixels than the background.
##
## A piece is drawn as it is, standing on the canvas origin (bottom-centre,
## like every Scenery prop), except: the lamp's pole repeats to any height
## under its head, and a railing or guide rail repeats whole bays to come
## close to the prop's width. A missing PNG makes `has_piece()` false and
## Scenery falls back to its code-drawn look.

const ART := 1.5
const DIR := "res://assets/environment/sunnyvale/props/"
## The buildings sheet (C42): drawn at the campus's own pixel size, so each of
## its pieces was imported with 2 x 2 art pixels per generated pixel.
const BUILDINGS := "res://assets/environment/sunnyvale/buildings/"

## tex: piece name; units: the columns [u0, u1) of one bay, repeated as many
## times as fit, after the left end [0, u0) and before the right end
## [right, width) (`right` defaults to u1); tint: a colour the piece is
## multiplied by (optional).
const PIECES := {
	"lamp": {"tex": "lamp_post"},
	# Dimmed so its pale top rail never reads as a lit, walkable edge.
	"fence": {"tex": "railing", "units": Vector2i(37, 77), "tint": Color(0.62, 0.66, 0.76)},
	# One chevron per bay; the right end carries the last one.
	"rail": {"tex": "guide_rail", "units": Vector2i(14, 39), "right": 57},
	# Hedges and planters dimmed like the planter ledges, so a lamp over them
	# doesn't light them brighter than the campus behind.
	"shrub": {"tex": "hedge", "tint": Color(0.66, 0.7, 0.8)},
	"flower": {"tex": "glow_plant"},
	"planter": {"tex": "planter", "tint": Color(0.84, 0.86, 0.92)},
	"mailbox": {"tex": "intercom"},
	"bench": {"tex": "bench"},
	"bollard": {"tex": "bollard"},
	# The buildings sheet: drawn as they are, whatever the prop's `size`.
	"booth": {"tex": "booth", "dir": BUILDINGS},
	"gate": {"tex": "gate", "dir": BUILDINGS},
	"pool": {"tex": "pool", "dir": BUILDINGS},
	"depot_door": {"tex": "depot_door", "dir": BUILDINGS},
	"annex_door": {"tex": "annex_door", "dir": BUILDINGS},
	"landmark": {"tex": "landmark", "dir": BUILDINGS},
}

## The landmark tower: the sign head [0, LANDMARK_HEAD) carrying the emblem,
## then the shaft rows LANDMARK_SHAFT repeated down to the ground. Its emblem
## centre sits LANDMARK_EMBLEM art rows above the head's bottom edge.
const LANDMARK_HEAD := 64
const LANDMARK_SHAFT := Vector2i(66, 106)
const LANDMARK_EMBLEM := 27.0

## The lamp: head rows [0, LAMP_POLE.x), pole rows [LAMP_POLE.x, LAMP_POLE.y)
## repeated to fill, base rows below. The lens is the lit bar in the head.
const LAMP_POLE := Vector2i(7, 57)
const LAMP_LENS := Rect2(3.0, 3.0, 9.0, 2.0)

static var _textures := {}


static func texture(piece: String, dir: String = DIR) -> Texture2D:
	var path: String = dir + piece + ".png"
	if not _textures.has(path):
		_textures[path] = load(path) if ResourceLoader.exists(path) else null
	return _textures[path]


static func has_piece(key: String) -> bool:
	return PIECES.has(key) and _tex(PIECES[key]) != null


static func _tex(s: Dictionary) -> Texture2D:
	return texture(s["tex"], s.get("dir", DIR))


## Draws the piece for `key` fitted to a prop of `size` (world px).
static func draw(c: CanvasItem, key: String, size: Vector2) -> void:
	var s: Dictionary = PIECES[key]
	var tex := _tex(s)
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var tint: Color = s.get("tint", Color.WHITE)
	if not s.has("units"):
		_blit(c, tex, Rect2(0.0, 0.0, tw, th), Vector2(floorf(-tw * 0.5), -th), tint)
		return
	var u: Vector2i = s["units"]
	var right: int = s.get("right", u.y)
	var uw: int = u.y - u.x
	var ends: int = u.x + tw - right
	var n: int = maxi(0, roundi((size.x / ART - ends) / uw))
	var x: float = floorf(-(ends + n * uw) * 0.5)
	_blit(c, tex, Rect2(0.0, 0.0, u.x, th), Vector2(x, -th), tint)
	x += u.x
	for i in n:
		_blit(c, tex, Rect2(u.x, 0.0, uw, th), Vector2(x, -th), tint)
		x += uw
	_blit(c, tex, Rect2(right, 0.0, tw - right, th), Vector2(x, -th), tint)


## The landmark tower on a pylon that runs `ground` world px down from the
## sign head's bottom edge (the canvas origin), as the code-drawn sign did.
static func draw_landmark(c: CanvasItem, ground: float) -> void:
	var tex := _tex(PIECES["landmark"])
	var tw: int = tex.get_width()
	var x: float = floorf(-tw * 0.5)
	_blit(c, tex, Rect2(0.0, 0.0, tw, LANDMARK_HEAD), Vector2(x, -LANDMARK_HEAD))
	var y: float = 0.0
	var period: int = LANDMARK_SHAFT.y - LANDMARK_SHAFT.x
	var stop: float = ground / ART
	while y < stop - 0.01:
		var n: float = minf(period, stop - y)
		_blit(c, tex, Rect2(0.0, LANDMARK_SHAFT.x, tw, n), Vector2(x, y))
		y += n


## Where the landmark's emblem is, relative to the sign head's bottom edge.
static func landmark_emblem_y() -> float:
	return -LANDMARK_EMBLEM * ART


## The lens centre of a lamp `h` world px tall, relative to its foot.
static func lamp_lens_y(h: float) -> float:
	return (-_lamp_rows(h) + LAMP_LENS.get_center().y) * ART


## The path lamp, `h` world px tall: its head (turned by `tilt` about the
## lens, its lens lit `lens` — white, or the lockdown colour), the pole
## repeated down to the base.
static func draw_lamp(c: CanvasItem, h: float, tilt: float, lens: Color) -> void:
	var tex := _tex(PIECES["lamp"])
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var rows: int = _lamp_rows(h)
	var x: float = floorf(-tw * 0.5)
	var foot: int = th - LAMP_POLE.y
	_blit(c, tex, Rect2(0.0, LAMP_POLE.y, tw, foot), Vector2(x, -foot))
	var y: float = -rows + LAMP_POLE.x
	while y < -foot:
		var n: float = minf(LAMP_POLE.y - LAMP_POLE.x, -foot - y)
		_blit(c, tex, Rect2(0.0, LAMP_POLE.x, tw, n), Vector2(x, y))
		y += n
	var pivot := Vector2(0.0, lamp_lens_y(h))
	c.draw_set_transform(pivot, tilt, Vector2.ONE)
	var top: Vector2 = Vector2(x, -rows) - pivot / ART
	_blit(c, tex, Rect2(0.0, 0.0, tw, LAMP_POLE.x), top)
	if lens != Color.WHITE:
		_blit(c, tex, LAMP_LENS, top + LAMP_LENS.position, lens)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _lamp_rows(h: float) -> int:
	var tex := _tex(PIECES["lamp"])
	return maxi(roundi(h / ART), tex.get_height() - (LAMP_POLE.y - LAMP_POLE.x))


static func _blit(c: CanvasItem, tex: Texture2D, src: Rect2, at: Vector2, tint: Color = Color.WHITE) -> void:
	c.draw_texture_rect_region(tex, Rect2(at * ART, src.size * ART), src, tint)
