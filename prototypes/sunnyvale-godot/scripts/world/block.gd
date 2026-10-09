@tool
class_name Block
extends StaticBody2D
## Blockout geometry: a solid axis-aligned rectangle on the world layer.
## `position` is the rectangle's TOP-LEFT corner; `size` its extent in px.
## Hero height H = 96 px. Collision/size/position are never touched here
## (M6 hard constraint) — only `_draw()` below changed.
##
## Revamp (C24) night pass (art-design/style-guide.md "Give playable
## platforms continuous, visible top edges, lit or rim-lit"; level brief
## "Usable surfaces have broad lit or rim-lit top edges"): every kind is dark
## concrete or steel under a thin, full-width cold path-light-white top edge
## (#D8E6F0) with a lit bevel under it, so every standing surface reads at
## night; the depot floor swaps that edge for Arcadia teal (the brief's
## "sharper teal utility light appears inside the depot"). Below the lit
## upper face each block falls into a large near-black shadow mass (style
## guide "Shadow: large, simple, near-black shadow shapes"), and its short
## ends carry a faint slate rim so a ledge's silhouette still reads against
## the night sky. Details never touch the top edge or the corners, and no
## non-walkable prop elsewhere uses this bright edge.
##
## Pixel-art terrain (C39): where the painted terrain piece for a kind exists
## (scripts/world/terrain_skins.gd), the block draws that instead — the
## piece's own lit edge sits on the block's top, so the walkable-edge
## contract holds — and the code-drawn look below stays as the fallback (and
## for the depot, which waits for its own painted layer).

enum Kind { GROUND, PLATFORM, WALL, ROOF, BACKSTOP, PORCH, SCENERY_SOLID }

## Upper-face color per kind. Kept as a dict (not per-kind consts) so
## `fill_override` can still substitute cleanly.
const FILL := {
	Kind.GROUND: Color("#1E2B3D"),      # campus paving
	Kind.PLATFORM: Color("#253449"),    # steel catch plank / ledge
	Kind.WALL: Color("#212E41"),        # cast-concrete garden wall
	Kind.ROOF: Color("#1D2A3B"),        # office-wing roof slab
	Kind.BACKSTOP: Color("#2B384B"),    # indestructible stone planter
	Kind.PORCH: Color("#222F43"),       # entrance-canopy stone floor
	Kind.SCENERY_SOLID: Color("#202C3D"),
}
const OUTLINE := Color("#05070B")
## Cold path-light white (level brief #D8E6F0): the walkable top edge.
const TOP_EDGE := Color("#D8E6F0")
const TOP_BEVEL := Color("#5A718C")
const DEEP := Color("#0A0F18")
const SUBSTRATE := Color("#121A27")
const SIDE_RIM := Color(0.36, 0.45, 0.56, 0.55)
const SEAM := Color(0.0, 0.0, 0.0, 0.32)
const HIGHLIGHT := Color(0.85, 0.92, 1.0, 0.10)
const TEAL := Color("#3FE0D0")
const SEDUM := Color("#12261F")
## Depot metal floor (A05 interior) — the level brief's "depot metal floor"
## look for L01-A05's own GROUND-kind blocks (and its ROOF-kind ceiling).
## Block never gains a per-instance "surface" export (that would touch
## Geometry, out of art ownership) — instead it looks up its owning
## AreaRoot's `area_id`, a read-only lookup that changes no collision/size/
## position/kind anywhere.
const DEPOT_AREA_ID := "L01-A05"
const DEPOT_METAL := Color("#1B2735")
const DEPOT_EDGE := Color("#3FE0D0")
const DEPOT_BEVEL := Color("#2A5A62")
const Skins := preload("res://scripts/world/terrain_skins.gd")
## The roofs' backstop is the rooftop AC unit; every other backstop is the
## stone planter.
const ROOF_AREA_ID := "L01-A03"

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
## M7 readability (02 "a subtle crack/impact mark on the stone after the
## first stall"): set once by patrol_rover.gd when a Rover's charge stalls
## against this block. Only BACKSTOP-kind stone actually draws it; every
## other kind ignores the flag, so a stray `cracked = true` elsewhere (e.g. a
## test helper) never changes ordinary geometry's look.
@export var cracked: bool = false:
	set(v):
		cracked = v
		queue_redraw()

var _shape_node: CollisionShape2D
## Whether a block in the same skin continues on the left (x) / right (y);
## -1 until worked out (on the first draw, once every area is in the tree).
var _join := Vector2i(-1, -1)


func _ready() -> void:
	collision_layer = 1  # world
	collision_mask = 0
	add_to_group("terrain_block")
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
	_join = Vector2i(-1, -1)
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


## The painted terrain skin for this block, or "" for the code-drawn look.
func skin_name() -> String:
	if fill_override.a > 0.0:
		return ""
	var area_id := _owner_area_id()
	if area_id == DEPOT_AREA_ID:
		return ""
	var skin := ""
	match kind:
		Kind.GROUND, Kind.PORCH:
			skin = "walkway"
		Kind.PLATFORM:
			skin = "planter_ledge"
		Kind.ROOF:
			skin = "green_roof"
		Kind.BACKSTOP:
			skin = "ac_unit" if area_id == ROOF_AREA_ID else "stone_planter"
		Kind.WALL:
			skin = "retaining_wall"
	return skin if skin != "" and Skins.has_skin(skin) else ""


## Same-skinned blocks that meet edge to edge at the same top continue one
## pattern, so neither draws an end cap there.
func _joins(skin: String) -> Vector2i:
	if _join.x >= 0 or not is_inside_tree():
		return Vector2i(maxi(_join.x, 0), maxi(_join.y, 0))
	var r := get_rect_global()
	_join = Vector2i.ZERO
	for n in get_tree().get_nodes_in_group("terrain_block"):
		var b := n as Block
		if b == null or b == self or absf(b.global_position.y - r.position.y) > 0.5 or b.skin_name() != skin:
			continue
		var br := b.get_rect_global()
		if absf(br.end.x - r.position.x) < 0.5:
			_join.x = 1
		elif absf(br.position.x - r.end.x) < 0.5:
			_join.y = 1
	return _join


func _draw() -> void:
	var skin := skin_name()
	if skin != "":
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		Skins.draw_block(self, skin, size, global_position.x, _joins(skin))
		if kind == Kind.BACKSTOP and cracked:
			_draw_stone_crack()
		return
	var fill: Color = fill_override if fill_override.a > 0.0 else FILL[kind]
	var in_depot := fill_override.a <= 0.0 and _owner_area_id() == DEPOT_AREA_ID
	var edge := TOP_EDGE
	var bevel := TOP_BEVEL
	match kind:
		Kind.GROUND:
			if in_depot:
				_draw_depot_floor()
				edge = DEPOT_EDGE
				bevel = DEPOT_BEVEL
			else:
				_draw_paving(fill)
		Kind.PLATFORM:
			_draw_steel_ledge(fill)
		Kind.WALL:
			_draw_concrete_wall(fill)
		Kind.ROOF:
			if in_depot:
				_draw_depot_ceiling()
				edge = Color(0.0, 0.0, 0.0, 0.0)
			else:
				_draw_roof_slab(fill)
		Kind.BACKSTOP:
			_draw_stone_backstop(fill)
			if cracked:
				_draw_stone_crack()
		Kind.PORCH:
			_draw_canopy_floor(fill)
		Kind.SCENERY_SOLID:
			_draw_face(fill, 40.0)
	# A stone backstop/planter gets a heavier outer silhouette (style guide:
	# "heavier outer silhouettes") so it always reads as clearly
	# indestructible next to ordinary ground/plank kinds.
	draw_rect(Rect2(Vector2.ZERO, size), OUTLINE, false, 4.0 if kind == Kind.BACKSTOP else 3.0)
	# The lit edge goes on last, over the outline's inner half, so the dark
	# outline just above it only sharpens the line instead of eating it.
	if edge.a > 0.0:
		_draw_lit_edge(edge, bevel)


## The shared body: a lit upper face `face_h` tall, a thin shadow line under
## it, then the near-black mass the rest of the block falls into. Short
## blocks are all face.
func _draw_face(fill: Color, face_h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), DEEP)
	var fh: float = minf(face_h, size.y)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, fh)), fill)
	if size.y > fh + 4.0:
		draw_rect(Rect2(Vector2(0.0, fh), Vector2(size.x, 4.0)), SEAM)
		var sub_h: float = minf(36.0, size.y - fh - 4.0)
		draw_rect(Rect2(Vector2(0.0, fh + 4.0), Vector2(size.x, sub_h)), SUBSTRATE)
	# faint rim light on both short ends so a ledge's silhouette reads
	# against the dark backdrop.
	if size.x >= 12.0:
		var rim_h: float = minf(size.y, fh + 20.0)
		draw_line(Vector2(3.0, 5.0), Vector2(3.0, rim_h), SIDE_RIM, 1.5)
		draw_line(Vector2(size.x - 3.0, 5.0), Vector2(size.x - 3.0, rim_h), SIDE_RIM, 1.5)


## The readability contract: a crisp, full-width lit line on the top edge
## plus a lit bevel just under it.
func _draw_lit_edge(edge: Color, bevel: Color) -> void:
	var bevel_h: float = minf(3.0, maxf(size.y - 2.0, 0.0))
	if bevel_h > 0.0:
		draw_rect(Rect2(Vector2(0.0, 2.0), Vector2(size.x, bevel_h)), bevel)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, minf(2.0, size.y))), edge)


## Campus paving (GROUND): slab joints on the lit face, then deep shadow.
func _draw_paving(fill: Color) -> void:
	_draw_face(fill, 28.0)
	if size.y >= 20.0 and size.x >= 40.0:
		var joint := fill.darkened(0.35)
		var x: float = 64.0
		while x < size.x - 8.0:
			draw_line(Vector2(x, 8.0), Vector2(x, minf(26.0, size.y - 2.0)), joint, 2.0)
			x += 64.0
		draw_line(Vector2(4.0, 7.0), Vector2(size.x - 4.0, 7.0), HIGHLIGHT, 1.0)


## Entrance-canopy stone floor (PORCH): larger polished tiles and a thin
## Arcadia-teal wayfinding inlay under the lit edge.
func _draw_canopy_floor(fill: Color) -> void:
	_draw_face(fill, 34.0)
	if size.y >= 14.0:
		draw_line(Vector2(4.0, 9.0), Vector2(size.x - 4.0, 9.0), Color(TEAL, 0.5), 1.5)
	if size.y >= 24.0 and size.x >= 40.0:
		var joint := fill.darkened(0.35)
		var x: float = 96.0
		while x < size.x - 8.0:
			draw_line(Vector2(x, 12.0), Vector2(x, minf(32.0, size.y - 2.0)), joint, 2.0)
			x += 96.0


## Steel catch plank / ledge (PLATFORM): a grated top band and, on tall
## ones, a steel-clad column with panel seams and bolts under it.
func _draw_steel_ledge(fill: Color) -> void:
	var face_h: float = 14.0 if size.y <= 40.0 else 22.0
	_draw_face(fill, face_h)
	if size.y >= 10.0 and size.x >= 16.0:
		var slot := fill.darkened(0.4)
		var x: float = 8.0
		while x < size.x - 6.0:
			draw_line(Vector2(x, 6.0), Vector2(x, minf(face_h - 3.0, size.y - 2.0)), slot, 2.0)
			x += 9.0
	if size.y > 60.0:
		var col_top: float = face_h + 4.0
		var col := Rect2(Vector2(6.0, col_top), Vector2(size.x - 12.0, minf(140.0, size.y - col_top)))
		draw_rect(col, fill.darkened(0.45))
		var px: float = col.position.x + 40.0
		while px < col.end.x - 6.0:
			draw_line(Vector2(px, col.position.y), Vector2(px, col.end.y), SEAM, 2.0)
			draw_circle(Vector2(px - 20.0, col.position.y + 10.0), 2.0, fill.lightened(0.1))
			px += 40.0
		draw_line(col.position + Vector2(1.0, 0.0), Vector2(col.position.x + 1.0, col.end.y), SIDE_RIM, 1.5)
	elif size.y >= 24.0:
		# visible end supports hint the plank is held up, never floating.
		var strut_w: float = minf(10.0, size.x * 0.08)
		for sx in [strut_w * 0.6 + 2.0, size.x - strut_w * 0.6 - 2.0]:
			draw_line(Vector2(sx, face_h), Vector2(sx, size.y), OUTLINE, 3.0)


## Cast-concrete garden wall (WALL): a lit cap over large form-work panels
## with tie-hole dots.
func _draw_concrete_wall(fill: Color) -> void:
	_draw_face(fill, minf(size.y, 120.0))
	if size.y >= 16.0:
		draw_rect(Rect2(Vector2(0.0, 2.0), Vector2(size.x, minf(8.0, size.y - 2.0))), fill.lightened(0.12))
	var panel_w: float = 64.0
	var tie := fill.darkened(0.45)
	var x: float = 0.0
	while x < size.x:
		if x > 0.0:
			draw_line(Vector2(x, 10.0), Vector2(x, minf(120.0, size.y)), SEAM, 1.5)
		var ty: float = 30.0
		while ty < minf(116.0, size.y - 6.0):
			for tx in [x + panel_w * 0.3, x + panel_w * 0.7]:
				if tx < size.x - 4.0:
					draw_circle(Vector2(tx, ty), 1.8, tie)
			ty += 36.0
		x += panel_w


## Office-wing roof walkway (ROOF): a dark green-roof planting strip seen
## edge-on under the lit edge, a steel fascia, and small soffit downlights
## under the slab — a light near every rooftop landing.
func _draw_roof_slab(fill: Color) -> void:
	_draw_face(fill, size.y)
	if size.y >= 18.0:
		draw_rect(Rect2(Vector2(0.0, 5.0), Vector2(size.x, 6.0)), SEDUM)
		var tuft := SEDUM.lightened(0.12)
		var tx: float = 7.0
		while tx < size.x - 7.0:
			draw_line(Vector2(tx, 6.0), Vector2(tx + 3.0, 9.0), tuft, 1.5)
			tx += 13.0
		draw_line(Vector2(0.0, 12.5), Vector2(size.x, 12.5), fill.lightened(0.14), 1.5)
	if size.y >= 26.0:
		draw_rect(Rect2(Vector2(0.0, size.y - 5.0), Vector2(size.x, 5.0)), OUTLINE)
		var lx: float = 45.0
		while lx < size.x - 20.0:
			draw_rect(Rect2(Vector2(lx - 5.0, size.y - 3.0), Vector2(10.0, 3.0)), Color(TOP_EDGE, 0.85))
			lx += 90.0


## Backstop/planter stone (BACKSTOP): chunky beveled stone blocks with a
## heavier outline and mortar lines — reads as clearly indestructible, never
## confused with a breakable prop.
func _draw_stone_backstop(fill: Color) -> void:
	_draw_face(fill, minf(size.y, 180.0))
	if size.y >= 12.0:
		draw_rect(Rect2(Vector2(3.0, 6.0), Vector2(maxf(size.x - 6.0, 0.0), 4.0)), HIGHLIGHT)
	var block_h: float = 24.0
	var mortar := fill.darkened(0.45)
	var y: float = 5.0 + block_h
	var row := 0
	while y < minf(size.y, 180.0):
		draw_line(Vector2(0.0, y), Vector2(size.x, y), mortar, 2.0)
		var off: float = size.x * 0.5 if row % 2 == 0 else size.x * 0.25
		if y + block_h <= size.y:
			draw_line(Vector2(off, y), Vector2(off, minf(y + block_h, size.y)), mortar, 2.0)
		y += block_h
		row += 1
	if size.x >= 10.0:
		draw_line(Vector2(3.0, 10.0), Vector2(3.0, minf(size.y, 180.0) - 3.0), HIGHLIGHT, 2.0)


## Subtle impact crack (M7 readability, 02): a jagged line plus a small
## radiating chip pattern centered on the block, reading as "this stone has
## been hit" without competing with the block's own mortar-line texture.
## Pale on the dark night stone so it still reads, but thin and unfilled —
## the design calls this "subtle".
func _draw_stone_crack() -> void:
	var c := Color(0.72, 0.8, 0.9, 0.6)
	var mid := Vector2(size.x * 0.5, minf(size.y, 180.0) * 0.5)
	var jag := PackedVector2Array([
		mid + Vector2(-10.0, -14.0), mid + Vector2(-2.0, -4.0), mid + Vector2(4.0, -8.0),
		mid + Vector2(-1.0, 4.0), mid + Vector2(7.0, 14.0),
	])
	draw_polyline(jag, c, 1.4, true)
	for off in [Vector2(-6.0, 2.0), Vector2(5.0, -6.0)]:
		draw_line(mid + off, mid + off + off.normalized() * 6.0, c, 1.0)


## Depot interior floor (A05 only, GROUND-kind blocks): steel deck plates
## with rivets under a teal utility-lit edge.
func _draw_depot_floor() -> void:
	_draw_face(DEPOT_METAL, 30.0)
	var panel: float = 110.0
	var x: float = panel
	while x < size.x - 4.0:
		draw_line(Vector2(x, 5.0), Vector2(x, minf(30.0, size.y)), SEAM, 2.0)
		draw_circle(Vector2(x - panel * 0.5, 16.0), 2.2, DEPOT_METAL.lightened(0.18))
		x += panel


## Depot ceiling (A05 only, ROOF-kind): a steel I-beam ceiling. Not a
## walkable surface, so no bright top edge — just a faint lit underside
## where the utility lights below catch it.
func _draw_depot_ceiling() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#101824"))
	draw_rect(Rect2(Vector2(0.0, size.y - 8.0), Vector2(size.x, 8.0)), DEPOT_METAL)
	var x: float = 60.0
	while x < size.x - 4.0:
		draw_rect(Rect2(Vector2(x - 3.0, 0.0), Vector2(6.0, size.y - 8.0)), Color("#172231"))
		draw_circle(Vector2(x, size.y - 4.0), 1.8, DEPOT_METAL.lightened(0.2))
		x += 120.0
	draw_line(Vector2(0.0, size.y - 1.0), Vector2(size.x, size.y - 1.0), Color(TEAL, 0.35), 2.0)
