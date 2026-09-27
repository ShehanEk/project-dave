@tool
class_name Block
extends StaticBody2D
## Blockout geometry: a solid axis-aligned rectangle on the world layer.
## `position` is the rectangle's TOP-LEFT corner; `size` its extent in px.
## Hero height H = 96 px. Collision/size/position are never touched here
## (M6 hard constraint) — only `_draw()` below changed, to read as the
## approved hand-drawn C11 Sunnyvale look (art-design/style-guide.md: broad
## flat colors, one or two crisp cel-shadow shapes, a confident outline,
## continuous visible top edges) while keeping every top surface at least as
## readable as the old flat-fill blockout: full-width crisp light top edge,
## solid outline, and each kind now also draws a small, non-covering support/
## texture detail that never encroaches on the top edge or the corners.

enum Kind { GROUND, PLATFORM, WALL, ROOF, BACKSTOP, PORCH, SCENERY_SOLID }

## Base local color per kind (Sunnyvale palette:
## level-design/l01-welcome-to-sunnyvale.md cream #EFE0BE, peach #DF9E80,
## lawn #87B45E, sky #A9D6DD, teal #365D62). Kept as a dict (not per-kind
## consts) so `fill_override` can still substitute cleanly.
const FILL := {
	Kind.GROUND: Color("#87B45E"),      # lawn top
	Kind.PLATFORM: Color("#c9a35a"),    # sun-worn porch/catch plank
	Kind.WALL: Color("#c7b393"),        # cream garden wall render
	Kind.ROOF: Color("#DF9E80"),        # peach terracotta roof tile
	Kind.BACKSTOP: Color("#9a9a95"),    # indestructible stone
	Kind.PORCH: Color("#EFE0BE"),       # cream porch decking
	Kind.SCENERY_SOLID: Color("#9c8f7a"),
}
const OUTLINE := Color("#332a20")
const TOP_EDGE := Color("#fff4d6")
const SHADOW_A := Color(0.0, 0.0, 0.0, 0.10)
const SHADOW_B := Color(0.0, 0.0, 0.0, 0.16)
const HIGHLIGHT := Color(1.0, 1.0, 1.0, 0.28)
## Depot metal floor (A05 interior) — the level brief's "depot metal floor"
## look for L01-A05's own GROUND-kind blocks. Block never gains a per-
## instance "surface" export (that would touch Geometry, out of M6 art
## ownership) — instead it looks up its owning AreaRoot's `area_id`, a
## read-only lookup that changes no collision/size/position/kind anywhere.
const DEPOT_AREA_ID := "L01-A05"
const DEPOT_METAL := Color("#7d8b8c")
const DEPOT_METAL_EDGE := Color("#cfdcdc")

@export var size: Vector2 = Vector2(192, 48):
	set(v):
		size = v
		_rebuild()
@export var kind: Kind = Kind.GROUND:
	set(v):
		kind = v
		queue_redraw()
@export var fill_override: Color = Color(0, 0, 0, 0):
	set(v):
		fill_override = v
		queue_redraw()

var _shape_node: CollisionShape2D


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if _shape_node == null:
		_shape_node = CollisionShape2D.new()
		_shape_node.name = "Shape"
		add_child(_shape_node)  # no owner: generated, never saved into scenes
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape_node.shape = rect
	_shape_node.position = size * 0.5
	queue_redraw()


func get_rect_global() -> Rect2:
	return Rect2(global_position, size)


## Read-only lookup of the owning AreaRoot's `area_id` (exported by every
## area scene — scripts/levels/area_root.gd). Never caches across a kind/
## size change and never touches the tree otherwise; an isolated test scene
## with no AreaRoot ancestor (e.g. tests/area_harness.gd's bare area) simply
## finds none and falls back to the ordinary look.
func _owner_area_id() -> String:
	var n: Node = get_parent()
	while n:
		if "area_id" in n:
			return str(n.area_id)
		n = n.get_parent()
	return ""


func _draw() -> void:
	var fill: Color = fill_override if fill_override.a > 0.0 else FILL[kind]
	var top_h: float = minf(6.0, size.y)
	match kind:
		Kind.GROUND:
			if fill_override.a <= 0.0 and _owner_area_id() == DEPOT_AREA_ID:
				_draw_depot_floor()
			else:
				_draw_lawn_top(fill, top_h)
		Kind.PLATFORM:
			_draw_plank(fill, top_h, false)
		Kind.WALL:
			_draw_garden_wall(fill, top_h)
		Kind.ROOF:
			_draw_roof_tiles(fill, top_h)
		Kind.BACKSTOP:
			_draw_stone_backstop(fill, top_h)
		Kind.PORCH:
			_draw_plank(fill, top_h, true)
		Kind.SCENERY_SOLID:
			_draw_plain(fill, top_h)
	# A stone backstop/planter gets a heavier outer silhouette (style guide:
	# "heavier outer silhouettes") so it always reads as clearly
	# indestructible next to ordinary ground/plank kinds.
	draw_rect(Rect2(Vector2.ZERO, size), OUTLINE, false, 4.0 if kind == Kind.BACKSTOP else 3.0)


func _draw_plain(fill: Color, top_h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, top_h)), TOP_EDGE)


## Lawn top: crisp light top edge (unchanged readability contract), a
## slightly darker turf band just under it for a drawn cel-shadow, and small
## drawn grass-tuft marks along the edge — never taller than the top edge
## band itself, so they read as texture, not as something standing on the
## surface a hero could trip on.
func _draw_lawn_top(fill: Color, top_h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill)
	var turf_h: float = minf(16.0, size.y * 0.35)
	if turf_h > 0.0:
		draw_rect(Rect2(Vector2(0.0, top_h), Vector2(size.x, turf_h)), fill.darkened(0.14))
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, top_h)), TOP_EDGE)
	if size.x >= 24.0:
		var spacing: float = 26.0
		var n: int = maxi(1, int(size.x / spacing))
		var tuft := fill.darkened(0.32)
		for i in n:
			var x: float = (float(i) + 0.5) * size.x / float(n)
			if x < 6.0 or x > size.x - 6.0:
				continue
			draw_line(Vector2(x - 3.5, 1.0), Vector2(x - 5.0, -6.0), tuft, 2.0)
			draw_line(Vector2(x, 1.0), Vector2(x, -8.0), tuft, 2.0)
			draw_line(Vector2(x + 3.5, 1.0), Vector2(x + 5.0, -6.0), tuft, 2.0)


## Depot interior floor (A05 only, GROUND-kind blocks): brushed metal deck
## with riveted panel seams and a cool highlighted top edge, matching the
## level brief's "depot metal floor" and its cyan utility light.
func _draw_depot_floor(_unused_fill: Color = Color.WHITE) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), DEPOT_METAL)
	draw_rect(Rect2(Vector2(0.0, minf(10.0, size.y * 0.3)), Vector2(size.x, minf(10.0, size.y * 0.3))), SHADOW_A)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, minf(5.0, size.y))), DEPOT_METAL_EDGE)
	var panel: float = 110.0
	var x: float = panel
	while x < size.x - 4.0:
		draw_line(Vector2(x, 2.0), Vector2(x, size.y), Color(0.0, 0.0, 0.0, 0.22), 2.0)
		draw_circle(Vector2(x - panel * 0.5, 10.0), 3.0, Color(0.0, 0.0, 0.0, 0.35))
		x += panel


## Porch/catch plank (PLATFORM) or wide porch decking (PORCH): horizontal
## board seams plus a crisp light top edge; PORCH boards are wider and add a
## thin baseboard skirt along the bottom so a tall porch reads as a built
## deck, not a floating slab.
func _draw_plank(fill: Color, top_h: float, wide_boards: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, top_h)), TOP_EDGE)
	var board_h: float = 22.0 if wide_boards else 14.0
	var seam := fill.darkened(0.22)
	var y: float = top_h + board_h
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), seam, 1.5)
		y += board_h
	if wide_boards and size.y >= 10.0:
		draw_rect(Rect2(Vector2(0.0, size.y - 6.0), Vector2(size.x, 6.0)), fill.darkened(0.3))
	# visible end supports hint the plank/porch is held up, never floating.
	if size.y >= 24.0:
		var strut_w: float = minf(10.0, size.x * 0.08)
		for sx in [strut_w * 0.6, size.x - strut_w * 0.6]:
			draw_line(Vector2(sx, size.y * 0.55), Vector2(sx, size.y), OUTLINE, 3.0)


## Garden wall (WALL): staggered stone/brick coursing under a light cream
## cap, matching the level brief's "low garden walls."
func _draw_garden_wall(fill: Color, top_h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, top_h)), TOP_EDGE)
	var course_h: float = 26.0
	var brick_w: float = 46.0
	var mortar := fill.darkened(0.28)
	var row: int = 0
	var y: float = top_h + 4.0
	while y < size.y:
		var offset: float = (brick_w * 0.5) if (row % 2 == 1) else 0.0
		draw_line(Vector2(0.0, y), Vector2(size.x, y), mortar, 1.5)
		var x: float = -offset
		while x < size.x:
			if x > 0.0:
				draw_line(Vector2(x, y), Vector2(x, minf(y + course_h, size.y)), mortar, 1.5)
			x += brick_w
		y += course_h
		row += 1


## Roof terrace deck (ROOF): terracotta tile scoring on the walkable top
## plus a scalloped gutter lip along the front (bottom) edge — the level
## brief's "fat ceramic gutters, scalloped porch awnings."
func _draw_roof_tiles(fill: Color, top_h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill)
	var tile_w: float = 30.0
	var shadow := fill.darkened(0.18)
	var x: float = tile_w
	while x < size.x:
		draw_line(Vector2(x, top_h), Vector2(x - 10.0, size.y), shadow, 1.5)
		x += tile_w
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, top_h)), TOP_EDGE)
	if size.y >= 10.0:
		var scallop_r: float = 9.0
		var cx: float = scallop_r
		var gutter_y: float = size.y
		while cx < size.x:
			draw_arc(Vector2(cx, gutter_y), scallop_r, 0.0, PI, 8, OUTLINE, 2.0)
			cx += scallop_r * 1.7


## Backstop/planter stone (BACKSTOP): chunky beveled stone blocks with a
## heavier outline and mortar lines — reads as clearly indestructible, never
## confused with a breakable prop.
func _draw_stone_backstop(fill: Color, top_h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, top_h)), TOP_EDGE)
	draw_rect(Rect2(Vector2(2.0, top_h + 2.0), Vector2(maxf(size.x - 4.0, 0.0), 4.0)), HIGHLIGHT)
	var block_h: float = 22.0
	var mortar := fill.darkened(0.34)
	var y: float = top_h + block_h
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), mortar, 2.0)
		y += block_h
	if size.x >= 10.0:
		draw_line(Vector2(2.0, size.y - 2.0), Vector2(size.x - 2.0, size.y - 2.0), SHADOW_B, 3.0)
