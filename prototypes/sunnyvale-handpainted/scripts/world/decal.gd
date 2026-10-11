extends Node2D
## A painted ground detail (Sheet 8, 2026-10-06): one piece of the user's
## generated details sheet (concept-art/env-sunnyvale/sunnyvale-details-v1.webp,
## cut into pieces by tools/art/import_pixel_sheet.py details): a puddle, a
## crack, a drain grate, fallen leaves, a cable, a floor vent, a hose or a box,
## laid over the paving to break up its repeat. Purely visual: no collision,
## no group, no gameplay. The area scenes place them under a `Decals` node
## that follows `Geometry` (so they draw over the walkway blocks) and comes
## before `Entities` and `Encounters` (so pickups, enemies and Dave draw over
## them).
##
## The piece stands on the node's origin, bottom-centre like every Scenery
## prop, drawn nearest-filtered at 1.5 world px per art pixel (the sheet came
## back at the campus's pixel size, so one art pixel per generated pixel).
## `flip` mirrors it sideways. A missing PNG (an export without the art) makes
## `has_piece()` false and the node draws nothing. No `class_name` (M6 art-pass
## import-cache rule): scenes reference this script by path, tests preload it.

const ART := 1.5
const DIR := "res://assets/environment/sunnyvale/details/"

## Every piece the sheet gives, in reading order.
const PIECES: PackedStringArray = [
	"puddle_a", "puddle_b", "puddle_c", "crack_a", "crack_b", "grate",
	"leaves", "cable", "vent", "hose", "box",
]

@export var piece: String = "":
	set(v):
		piece = v
		queue_redraw()
@export var flip: bool = false:
	set(v):
		flip = v
		queue_redraw()
## A colour the piece is multiplied by (white draws it as painted).
@export var tint: Color = Color.WHITE:
	set(v):
		tint = v
		queue_redraw()

static var _textures := {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## The painted texture for a piece name, or null when its PNG is missing.
static func texture_for(piece_name: String) -> Texture2D:
	if piece_name == "":
		return null
	var path: String = DIR + piece_name + ".png"
	if not _textures.has(path):
		_textures[path] = load(path) if ResourceLoader.exists(path) else null
	return _textures[path]


## Whether this decal's piece has its art (false: it draws nothing).
func has_piece() -> bool:
	return texture_for(piece) != null


## The area the piece covers, in this node's own coordinates (empty when there
## is no art).
func local_rect() -> Rect2:
	var tex := texture_for(piece)
	if tex == null:
		return Rect2()
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var x0: float = floorf(-tw * 0.5)
	if flip:
		x0 = -(x0 + tw)
	return Rect2(x0 * ART, -th * ART, tw * ART, th * ART)


func global_rect() -> Rect2:
	var r := local_rect()
	r.position += global_position
	return r


func _draw() -> void:
	var tex := texture_for(piece)
	if tex == null:
		return
	var tw: int = tex.get_width()
	var th: int = tex.get_height()
	var x0: float = floorf(-tw * 0.5)
	var rect := Rect2(x0 * ART, -th * ART, tw * ART, th * ART)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect(tex, rect, false, tint)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
