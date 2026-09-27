extends Node2D
## M6 presentation background layer (art-design/style-guide.md "Compose
## scenery as separate foreground, playable, background and effect layers;
## ... lower background contrast and optional parallax suggest depth"; the
## level brief's "Background depth: Two layers of homes, orderly lawns,
## looping robot-bird silhouettes, and the cloud ceiling").
##
## Attached directly to a `Parallax2D` node (Node2D is an ancestor of
## Parallax2D, so this script also works as that node's own drawing script —
## no extra child needed). Purely decorative: never collides, never reads or
## changes Session/Block/Scenery gameplay state, always drawn well behind
## the play plane (negative z_index, below Scenery's own -10). No
## `class_name` (M6 art-pass import-cache rule) — every area loads this by
## path by attaching the same script to its own Parallax2D node(s).
##
## `mode`: SKY draws the pale habitat-ceiling sky plus a faint projected-
## cloud/panel grid (optionally one visibly broken projector seam, for A01's
## "first visible through one broken cloud projector"); HOMES draws two
## rows of cream/peach rounded-roof homes with clipped shrubs over an
## orderly lawn band, plus a couple of small, slow-bobbing robot-bird
## silhouettes; DEPOT draws the maintenance depot's own dark teal interior
## recesses under a soft cyan utility-light glow, replacing the sky/homes
## look for an indoor area. Content is drawn wider than one area's own
## `tile_width` (see MARGIN_FRAC) as harmless extra headroom.
##
## KNOWN DEVIATION from "use scroll_scale for parallax depth" (recorded here
## because the reason is easy to rediscover the hard way otherwise):
## `Parallax2D.scroll_scale` computes its extra offset from the CAMERA'S
## ABSOLUTE global position, not from the camera's position relative to this
## node's own area. `level_01.tscn` instances all six areas at once, side by
## side at large, distinct world-x offsets (04-godot-architecture.md) —
## confirmed by a debug capture: with `scroll_scale` under (1,1), a layer
## belonging to an area near world-x ~25000 rendered itself some 10,000+ px
## away from the camera the instant the camera's own (large) global-x fed
## into that formula, while an EARLIER area's layer was left onscreen in its
## place. Every Parallax2D node these area scenes create is therefore left
## at the engine default `scroll_scale = (1, 1)` (no property override in
## the .tscn), which makes the offset term exactly zero — the layer simply
## sits at its own authored position, with no depth-through-speed effect,
## but never drifts. The depth cue here comes from layer ORDER (z_index) and
## contrast/scale alone, per the style guide's "overlap, lower background
## contrast and optional parallax suggest depth" — parallax is optional.
##
## Cross-area visibility gate: even with the drift fixed, every area's
## background Parallax2D nodes are simultaneously live in the tree (the
## level is never streamed), so `_process()` below still hides this layer
## whenever the active Camera2D sits well outside this layer's OWN owning
## AreaRoot's world-x span — the same guard also protects against a future
## edit reintroducing a non-default `scroll_scale`. Purely a `visible`
## toggle — never touches collision, camera limits, or any Session/gameplay
## state.

enum Mode { SKY, HOMES, DEPOT }

const SKY_COLOR := Color("#A9D6DD")
const SKY_PANEL_LINE := Color(0.14, 0.18, 0.22, 0.12)
const CLOUD := Color(1.0, 1.0, 1.0, 0.55)
const BROKEN_EDGE := Color("#332a20")
const BROKEN_GAP := Color(0.08, 0.08, 0.1, 0.35)
const CREAM := Color("#EFE0BE")
const PEACH := Color("#DF9E80")
const LAWN_FAR := Color("#9CC177")
const LAWN_NEAR := Color("#87B45E")
const OUTLINE_SOFT := Color(0.169, 0.133, 0.2, 0.55)
const TEAL := Color("#365D62")
const TEAL_DEEP := Color("#2A4A4E")
const CYAN_GLOW := Color(0.56, 0.88, 0.79, 0.16)
const BIRD_COLOR := Color(0.169, 0.133, 0.2, 0.35)

## Extra art drawn past each side of `tile_width`, as a fraction of it — a
## `Parallax2D` with `scroll_scale.x` as low as ~0.6 stays fully covered
## across the whole camera pan with this much margin.
const MARGIN_FRAC := 0.6

@export var mode: Mode = Mode.SKY
## The owning area's own `width` (AreaRoot export) — this layer's content is
## centered on the same span, just drawn MARGIN_FRAC wider on each side.
@export var tile_width: float = 3000.0
## Local y of the area's own ground/floor reference line (most areas: 0.0;
## see each area's own Geometry — this only positions decoration, it never
## reads or moves collision).
@export var horizon_y: float = 0.0
## SKY only: one visibly cracked ceiling-projector seam near the first third
## of the layer (A01's "first visible through one broken cloud projector").
@export var broken_projector: bool = false
## Varies the far/near house-row layout between areas without a shared look.
@export var row_seed: int = 0

## How far past this layer's own area span the active camera may sit before
## the layer hides — generous enough that it never pops away while still
## plausibly onscreen through a doorway/hatch, small enough that another
## area's backdrop is never left showing at the same time.
const VISIBILITY_MARGIN := 500.0

var _time: float = 0.0
var _reduced_motion: bool = false
var _area_x0: float = -INF
var _area_x1: float = INF
var _has_area_bounds: bool = false


func _ready() -> void:
	z_index = -80 if mode == Mode.SKY else -60
	z_as_relative = true
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	_cache_area_bounds()
	set_process(true)
	_update_visibility()
	queue_redraw()


## Read-only lookup of the owning AreaRoot (exports `area_id` + `width` —
## scripts/levels/area_root.gd), the same "walk up until a node has this
## property" pattern block.gd uses for its own depot-floor read. An isolated
## test/demo scene with no AreaRoot ancestor simply finds none, and this
## layer stays visible always (matching its old, un-gated behavior there).
func _cache_area_bounds() -> void:
	var n: Node = get_parent()
	while n:
		if "area_id" in n and "width" in n:
			_area_x0 = n.global_position.x
			_area_x1 = _area_x0 + float(n.width)
			_has_area_bounds = true
			return
		n = n.get_parent()


func _update_visibility() -> void:
	if not _has_area_bounds:
		return
	var cam := get_viewport().get_camera_2d() if is_inside_tree() else null
	if cam == null:
		return
	var cx: float = cam.global_position.x
	visible = cx >= _area_x0 - VISIBILITY_MARGIN and cx <= _area_x1 + VISIBILITY_MARGIN


func _process(delta: float) -> void:
	_update_visibility()
	if mode != Mode.HOMES or _reduced_motion:
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	match mode:
		Mode.SKY:
			_draw_sky()
		Mode.HOMES:
			_draw_homes()
		Mode.DEPOT:
			_draw_depot()


func _span() -> Vector2:
	# x, width — the full drawn canvas, wider than tile_width per MARGIN_FRAC.
	var margin: float = tile_width * MARGIN_FRAC
	return Vector2(-margin, tile_width + margin * 2.0)


func _draw_sky() -> void:
	var span := _span()
	var x0: float = span.x
	var w: float = span.y
	var top: float = horizon_y - 900.0
	draw_rect(Rect2(Vector2(x0, top), Vector2(w, 900.0)), SKY_COLOR)
	# faint projected-cloud/panel seams: the habitat ceiling's own grid.
	var seams: int = maxi(3, int(w / 900.0))
	for i in seams:
		var x: float = x0 + w * (float(i) + 0.5) / float(seams)
		draw_line(Vector2(x, top), Vector2(x, horizon_y), SKY_PANEL_LINE, 2.0)
	var cloud_groups: int = maxi(4, int(w / 700.0))
	for i in cloud_groups:
		var cx: float = x0 + w * (float(i) + 0.5) / float(cloud_groups)
		var cy: float = top + 160.0 + 40.0 * float(i % 2)
		draw_circle(Vector2(cx - 26.0, cy), 30.0, CLOUD)
		draw_circle(Vector2(cx + 22.0, cy - 12.0), 34.0, CLOUD)
		draw_circle(Vector2(cx, cy + 10.0), 26.0, CLOUD)
	if broken_projector:
		# One visibly cracked ceiling panel seam near the first tile — the
		# level brief's "pale blue sky is an illuminated habitat ceiling,
		# first visible through one broken cloud projector."
		var bx: float = tile_width * 0.22
		var by: float = top + 90.0
		var gap := Rect2(Vector2(bx - 34.0, by - 22.0), Vector2(68.0, 44.0))
		draw_rect(gap, BROKEN_GAP)
		draw_rect(gap, BROKEN_EDGE, false, 2.0)
		var crack := PackedVector2Array([
			Vector2(bx - 20.0, by - 20.0), Vector2(bx - 4.0, by - 2.0),
			Vector2(bx - 14.0, by + 6.0), Vector2(bx + 18.0, by + 20.0),
		])
		draw_polyline(crack, BROKEN_EDGE, 2.0, true)


func _draw_homes() -> void:
	var span := _span()
	var x0: float = span.x
	var w: float = span.y
	# orderly lawn band beneath the far house row
	draw_rect(Rect2(Vector2(x0, horizon_y - 26.0), Vector2(w, 26.0)), LAWN_FAR)
	var far_count: int = maxi(3, int(w / 420.0))
	var near_count: int = maxi(2, int(w / 640.0))
	_draw_house_row(x0, w, 0.55, CREAM.lerp(SKY_COLOR, 0.22), PEACH.lerp(SKY_COLOR, 0.22), far_count, 0)
	_draw_house_row(x0, w, 0.85, CREAM, PEACH, near_count, 7)
	_draw_birds(x0, w)


func _draw_house_row(x0: float, w: float, scale: float, wall: Color, roof: Color, count: int, seed_bump: int) -> void:
	var body_h: float = 130.0 * scale
	var roof_h: float = 60.0 * scale
	for i in count:
		var t: float = (float(i) + 0.5) / float(count)
		var jitter: float = (_hash01(row_seed + seed_bump * 17 + i) - 0.5) * 60.0
		var cx: float = x0 + w * t + jitter
		var half_w: float = (110.0 + _hash01(row_seed + seed_bump * 5 + i * 3) * 30.0) * scale
		var top: float = horizon_y - body_h
		draw_rect(Rect2(Vector2(cx - half_w, top), Vector2(half_w * 2.0, body_h)), wall)
		var roof_pts := PackedVector2Array([
			Vector2(cx - half_w * 1.08, top), Vector2(cx, top - roof_h), Vector2(cx + half_w * 1.08, top),
		])
		draw_colored_polygon(roof_pts, roof)
		draw_polyline(roof_pts, OUTLINE_SOFT, 2.0, true)
		draw_rect(Rect2(Vector2(cx - half_w, top), Vector2(half_w * 2.0, body_h)), OUTLINE_SOFT, false, 2.0)
		# a clipped round shrub beside the house, planted on the lawn line
		var shrub_r: float = 16.0 * scale
		var shrub_x: float = cx + half_w * 1.3
		draw_circle(Vector2(shrub_x, horizon_y - shrub_r), shrub_r, LAWN_NEAR.lerp(wall, 0.1))
		draw_circle(Vector2(shrub_x, horizon_y - shrub_r), shrub_r, OUTLINE_SOFT, false, 1.5)


func _draw_birds(x0: float, w: float) -> void:
	# Two small, slow-bobbing silhouettes — Settings.reduced_motion (checked
	# once in _ready via set_process) simply stops the bob; the birds stay
	# visible in a fixed pose rather than disappearing.
	var bob: float = 0.0 if _reduced_motion else sin(_time * 0.6) * 6.0
	for i in 2:
		var bx: float = x0 + w * (0.28 + float(i) * 0.4)
		var by: float = horizon_y - 210.0 - float(i) * 30.0 + bob * (1.0 if i == 0 else -1.0)
		var pts := PackedVector2Array([
			Vector2(bx - 14.0, by), Vector2(bx, by - 6.0), Vector2(bx + 14.0, by),
		])
		draw_polyline(pts, BIRD_COLOR, 2.0, false)


func _draw_depot() -> void:
	var span := _span()
	var x0: float = span.x
	var w: float = span.y
	draw_rect(Rect2(Vector2(x0, horizon_y - 400.0), Vector2(w, 400.0)), TEAL)
	var bays: int = maxi(3, int(w / 420.0))
	for i in bays:
		var x: float = x0 + w * (float(i) + 0.5) / float(bays)
		var bay := Rect2(Vector2(x - 60.0, horizon_y - 320.0), Vector2(120.0, 260.0))
		draw_rect(bay, TEAL_DEEP)
		draw_rect(bay, OUTLINE_SOFT, false, 2.0)
		draw_circle(Vector2(x, horizon_y - 200.0), 70.0, CYAN_GLOW)


func _hash01(n: int) -> float:
	var h: int = (n * 2654435761) & 0x7fffffff
	return float(h % 1000) / 1000.0
