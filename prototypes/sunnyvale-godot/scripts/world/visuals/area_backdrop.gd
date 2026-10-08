extends Node2D
## M6 presentation background layer, rebuilt for the revamp (C24) night look
## (art-design/style-guide.md "Eon City campus at night"; the level brief's
## "Background depth: Two layers of glass office wings and sculpted lawns,
## distant Arcadia towers with a few lit windows, a looping delivery-drone
## silhouette with one blinking light, and the night sky").
##
## Attached directly to a `Parallax2D` node (Node2D is an ancestor of
## Parallax2D, so this script also works as that node's own drawing script —
## no extra child needed). Purely decorative: never collides, never reads or
## changes Session/Block/Scenery gameplay state, always drawn well behind
## the play plane (negative z_index, below Scenery's own -10). No
## `class_name` (M6 art-pass import-cache rule) — every area loads this by
## path by attaching the same script to its own Parallax2D node(s).
##
## `mode`:
## - SKY: deep navy-to-black night in flat, hard-edged bands (no airbrushed
##   gradient), sparse stars, a thin low cloud band and a faint city glow on
##   the horizon.
## - HOMES: Arcadia's campus skyline. With the painted campus layer (C39):
##   a row of two-storey glass offices with roof gardens, a delivery drone
##   and flat bands of ground fog in front. Without it (the procedural
##   fallback): distant glass towers with a few lit windows, blinking red
##   aviation lights and the odd teal Arcadia arch emblem; a flickering
##   holographic billboard; a delivery drone; low glass office pavilions and
##   sculpted hedges; distant path lights; and the same fog.
## - DEPOT: the server depot interior. With the painted wall (Sheet 5): the
##   I-beam ceiling, hanging cables, a row of server racks with teal and green
##   status lights, three wall monitors and the floor beam, static behind the
##   play plane. Without it (the procedural fallback): rows of dark server
##   racks with blinking teal and signal-green LEDs and hanging cable bundles.
##   Either way, cool teal ceiling utility lights (real, smooth PointLight2Ds
##   sitting AT each fixture with a `height`, lighting the wall, floor and
##   anyone standing under them, characters through their normal maps; C35).
##
## Seamless across areas: SKY and HOMES features are laid out on GLOBAL x
## cells (the owning area's world x plus local x), and every layer clips
## what it draws to its own [0, tile_width] span, so a tower straddling a
## seam is drawn half by each neighbour and meets exactly. Every area uses
## the shared seam floor line (y = 0) as `horizon_y`, so bands line up too.
##
## Lockdown (`set_lockdown_mode()`, called only by the owning area's
## EnvironmentState through its `backdrop_paths`): the horizon glow turns to
## a dark red emergency glow, teal office windows go red, Arcadia emblems and
## the billboard go amber (Adam's attention), and in the depot the ceiling
## lights go dark one bank at a time and come back alarm red. Called live
## (`animate`) only for the one SC01 moment; a reload applies it settled.
##
## Animated details (LEDs, aviation lights, the billboard's slow flicker, the
## drone) live on one generated child canvas that redraws only while this
## layer is on screen. Settings.reduced_motion (read once in _ready) holds
## them in a fixed, steady pose instead; nothing here ever flashes faster
## than about twice a second.
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
## No overlap, no camera gate: each layer draws exactly its owning area's
## own [0, tile_width] span, so the six areas' backdrops tile edge to edge
## with every screen column covered by exactly one sky and one homes/depot
## layer. An earlier version drew 60% extra on each side and hid layers
## whenever the camera was >500 px outside their area; neighbouring houses
## then overlapped near every seam and popped out of view while still
## on-screen (the screen is 1280 px wide), reappearing on walking back.
## tests/cases/test_m7_regress_backdrop_seams.gd guards this.

enum Mode { SKY, HOMES, DEPOT }

const OUTLINE := Color("#05070B")
const TEAL := Color("#3FE0D0")
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const SIGNAL_GREEN := Color("#4DE38A")
const PATH_WHITE := Color("#D8E6F0")

# --- SKY: the painted far layer (C39) --------------------------------------------
## The user's generated pixel-art sky and city skyline, reduced to a true
## pixel grid by tools/art/import_pixel_layer.py. Drawn with nearest
## filtering at FAR_ART_PX world px per art pixel, repeating sideways, its
## base FAR_BASE below the seam floor line (the campus layer covers it).
## Its own parallax (FAR_DEPTH): the built-in Parallax2D scroll_scale can't
## be used here (see KNOWN DEVIATION above), so this layer samples the
## painting by global x minus FAR_DEPTH of the camera's x, which moves it
## at (1 - FAR_DEPTH) of the camera's speed and lines up exactly at area
## seams; it steps in whole art pixels so it never shimmers.
const FAR_TEXTURE := "res://assets/environment/sunnyvale/far.png"
## 1.5 world px per art pixel: about 5 screen px at 4K (zoom 1.2), fine
## enough to stay crisp there (3 world px read as a coarse, noisy mosaic).
const FAR_ART_PX := 1.5
const FAR_DEPTH := 0.9
const FAR_BASE := 20.0
## Dimmed a little so the far city sits behind the play plane.
const FAR_TINT := Color(0.82, 0.84, 0.9)
const FAR_LOCKDOWN_TINT := Color(0.85, 0.52, 0.56)
var _far: Texture2D
var _far_top: Color

# --- HOMES: the painted campus layer (C39) ---------------------------------------
## The user's generated campus offices (transparent background), reduced the
## same way at the same pixel size as the far layer. It replaces the drawn
## pavilions, hedges, path lights and billboard, stands on the seam floor
## line and scrolls faster than the far city (CAMPUS_DEPTH), so it reads as
## nearer.
const CAMPUS_TEXTURE := "res://assets/environment/sunnyvale/campus.png"
const CAMPUS_DEPTH := 0.6
const CAMPUS_BASE := 6.0
## Dimmed so the lit offices sit behind the play plane and its characters.
const CAMPUS_TINT := Color(0.6, 0.64, 0.74)
const CAMPUS_LOCKDOWN_TINT := Color(0.7, 0.42, 0.47)
var _campus: Texture2D

# --- DEPOT: the painted wall (Sheet 5) -------------------------------------------
## The user's painted depot wall (opaque): the I-beam ceiling, hanging cables, a
## row of server racks with status lights, three wall monitors and the floor
## beam, reduced the same way and drawn at the same FAR_ART_PX as the far and
## campus layers, so it is 205 art pixels (about 308 world px) tall: its bottom
## stands on the floor line and its top tucks 8 px behind the ceiling block
## (CEILING_Y). It replaces the code-drawn back wall, panel seams, racks, cables
## and floor strip. It is the back wall of the room, so it does not scroll (no
## parallax, like the racks it replaces); it repeats seamlessly sideways and
## is sampled by global x so it stays on the shared art-pixel grid. It is drawn
## by its own child canvas so its crisp nearest filtering never reaches the
## smooth haze and lights.
const DEPOT_TEXTURE := "res://assets/environment/sunnyvale/depot.png"
## The art is already very dark, so these are mild multiplies: a slightly cool
## one in the calm, a red-leaning one in lockdown (on top of the area's own
## EnvironmentState `modulate`).
const DEPOT_TINT := Color(0.94, 1.0, 1.08)
const DEPOT_LOCKDOWN_TINT := Color(1.0, 0.68, 0.72)
var _depot_wall: Texture2D
var _wall: Node2D

const SKY_TOP := -2400.0
const SKY_BOTTOM := 700.0
## Band boundaries relative to `horizon_y`; SKY_BANDS has one more entry
## (the last band runs from the final edge down to SKY_BOTTOM).
const SKY_BAND_EDGES := [-1150.0, -800.0, -560.0, -390.0, -260.0, -160.0, -90.0, -40.0]
const SKY_BANDS := [
	Color("#04060B"), Color("#060910"), Color("#080C16"), Color("#0A101C"), Color("#0D1524"),
	Color("#101A2C"), Color("#132035"), Color("#17273F"), Color("#1C2E48"),
]
const SKY_BANDS_LOCKDOWN := [
	Color("#04060B"), Color("#060910"), Color("#080C16"), Color("#0B0F1B"), Color("#100F1C"),
	Color("#17101B"), Color("#21111A"), Color("#2D131B"), Color("#3A151D"),
]
const STAR := Color(0.8, 0.86, 0.94)
const STAR_CELL := 70.0
const CLOUD := Color(0.045, 0.07, 0.11, 0.96)
const CLOUD_RIM := Color(0.27, 0.36, 0.5, 0.6)
const CLOUD_RIM_LOCKDOWN := Color(0.6, 0.22, 0.27, 0.55)

# --- HOMES (campus skyline) -----------------------------------------------------
const TOWER_CELL := 430.0
const PAVILION_CELL := 700.0
const HEDGE_CELL := 170.0
const BILLBOARD_CELL := 2300.0
const PATH_LIGHT_CELL := 260.0
const TOWER := Color("#0A111C")
const TOWER_RIM := Color("#1A2940")
const TOWER_MULLION := Color(0.15, 0.22, 0.32, 0.32)
const TOWER_FLOOR := Color(0.03, 0.05, 0.08, 0.6)
const WIN_WARM := Color(0.95, 0.89, 0.76, 0.78)
const WIN_TEAL := Color(0.25, 0.88, 0.82, 0.55)
const WIN_RED := Color(1.0, 0.23, 0.31, 0.55)
const PAVILION := Color("#0F1824")
const PAVILION_GLASS := Color("#12243A")
const PAVILION_MULLION := Color("#08101A")
const PAVILION_SLAB := Color("#1A283A")
const PAVILION_RIM := Color("#2E4058")
const LAWN_FAR := Color("#070E0F")
const UNDERGROUND := Color("#090D15")
const HEDGE_FAR := Color("#0A1716")
const HEDGE_RIM := Color(0.32, 0.5, 0.52, 0.4)
const PYLON := Color("#0C131E")
const DRONE := Color("#04060A")
const FOG_A := Color(0.6, 0.7, 0.82, 0.055)
const FOG_B := Color(0.6, 0.7, 0.82, 0.07)
const FOG_A_LOCKDOWN := Color(0.75, 0.5, 0.55, 0.06)
const FOG_B_LOCKDOWN := Color(0.75, 0.5, 0.55, 0.075)
const AVIATION_HZ := 0.45
const AVIATION_DUTY := 0.28

# --- DEPOT (server depot interior) ----------------------------------------------
const DEPOT_WALL := Color("#090E17")
const DEPOT_ABOVE := Color("#06090F")
const DEPOT_SEAM := Color("#0D1520")
const RACK := Color("#0E1724")
const RACK_FRONT := Color("#111C2B")
const RACK_FRAME := Color("#1E2C3E")
const RACK_VENT := Color("#0A111B")
const LED_OFF := Color("#11262C")
const CABLE := Color("#04070B")
const CABLE_HI := Color(0.16, 0.22, 0.3, 0.8)
const RACK_W := 58.0
const RACK_GAP := 8.0
## The ceiling block's underside in A05 (a05_depot.tscn CeilingMain spans
## y -340..-300); fixtures hang just below it.
const CEILING_Y := -300.0
const FIXTURE_SPACING := 420.0
const UTILITY_LIGHT := Color(0.62, 0.95, 0.92)
## Each fixture's smooth cone reaches this many times the fixture's height
## above the floor, so its pool on the floor is clearly visible; `height` is
## the light's height above the scene for normal-mapped characters.
const FIXTURE_REACH_RATIO := 1.75
const FIXTURE_LIGHT_HEIGHT := 90.0
const UTILITY_ENERGY := 1.0
const LOCKDOWN_ENERGY := 1.3
## Strength of the faint haze shaft drawn under each fixture.
const HAZE_ALPHA := 0.15
const BANK_STEP := 0.32
const BANK_DARK := 0.22
const SETTLED := 1.0e9

@export var mode: Mode = Mode.SKY
## The owning area's own `width` (AreaRoot export) — this layer draws exactly
## that span, so neighbouring areas' layers meet without overlapping.
@export var tile_width: float = 3000.0
## Local y of the shared seam floor line (every area: 0.0). Bands, skyline
## bases and fog all hang off it, so they line up across area seams; it only
## positions decoration and never reads or moves collision.
@export var horizon_y: float = 0.0
## DEPOT only: local x ranges (x = from, y = to) kept free of server racks so
## the depot's interactive props (core node, workbench, hatch) stand clear.
@export var clear_zones: PackedVector2Array = PackedVector2Array()

var _time: float = 0.0
var _reduced_motion: bool = false
var _lockdown: bool = false
var _lockdown_elapsed: float = SETTLED
## World x of this layer's local x = 0 (the owning area's global x).
var _gx0: float = 0.0
var _anim: Node2D
var _view_x0: float = -INF
var _view_x1: float = INF

var _stars: Array = []
var _clouds: Array = []
var _towers: Array = []
var _pavilions: Array = []
var _hedges: Array = []
var _billboards: Array = []
var _aviation: Array = []
var _path_lights: Array = []
var _drone: Dictionary = {}
var _racks: Array = []
var _cables: Array = []
var _fixtures: Array = []
var _fixture_lights: Array = []


func _ready() -> void:
	z_index = -80 if mode == Mode.SKY else -60
	z_as_relative = true
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	var parent_2d := get_parent() as Node2D
	_gx0 = parent_2d.global_position.x if parent_2d else global_position.x
	# Distant scenery is never lit by the play plane's lamps (that would read
	# as volumetric light on far buildings); the depot's own back wall is
	# close enough to catch its utility lights.
	light_mask = 1 if mode == Mode.DEPOT else 0
	if mode != Mode.DEPOT and ResourceLoader.exists(FAR_TEXTURE):
		_far = load(FAR_TEXTURE)
		if mode == Mode.SKY:
			var img := _far.get_image()
			_far_top = img.get_pixel(0, 0) if img else Color("#072249")
	if mode == Mode.HOMES and ResourceLoader.exists(CAMPUS_TEXTURE):
		_campus = load(CAMPUS_TEXTURE)
	if mode == Mode.DEPOT and ResourceLoader.exists(DEPOT_TEXTURE):
		_depot_wall = load(DEPOT_TEXTURE)
		_wall = Node2D.new()
		_wall.name = "Wall"
		_wall.show_behind_parent = true   # under the fill, haze and fixtures drawn here
		_wall.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_wall.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		_wall.light_mask = light_mask
		add_child(_wall)  # generated, never saved
		_wall.draw.connect(_draw_depot_wall)
	if _scrolling():
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	match mode:
		Mode.SKY:
			_build_sky()
		Mode.HOMES:
			_build_homes()
		Mode.DEPOT:
			_build_depot()
	if mode != Mode.SKY and not _painted_depot():   # the painted wall has nothing blinking
		_anim = Node2D.new()
		_anim.name = "Animated"
		_anim.light_mask = light_mask
		add_child(_anim)  # generated, never saved
		_anim.draw.connect(_on_anim_draw)
	_update_processing()
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if _scrolling():
		if _update_view():
			queue_redraw()
			if _anim:
				_anim.queue_redraw()
		return
	if _transition_active():
		_lockdown_elapsed += delta
		_apply_depot_lights()
		queue_redraw()
		if _wall:
			_wall.queue_redraw()
		if not _transition_active():
			_update_processing()
	if _anim and _update_view():
		_anim.queue_redraw()


func _draw() -> void:
	match mode:
		Mode.SKY:
			if _far != null:
				_draw_far()
			else:
				_draw_sky()
		Mode.HOMES:
			_draw_homes()
		Mode.DEPOT:
			_draw_depot()


func _on_anim_draw() -> void:
	match mode:
		Mode.HOMES:
			_draw_homes_anim(_anim)
		Mode.DEPOT:
			_draw_depot_anim(_anim)


func _span() -> Vector2:
	# x, width — exactly the owning area's span.
	return Vector2(0.0, tile_width)


## Called by EnvironmentState (this area's own `backdrop_paths`) with the
## story state; `animate` is true only for the live SC01 moment (never on a
## reload, and never under reduced motion).
func set_lockdown_mode(active: bool, animate: bool = false) -> void:
	_lockdown = active
	_lockdown_elapsed = 0.0 if (active and animate) else SETTLED
	_apply_depot_lights()
	queue_redraw()
	if _wall:
		_wall.queue_redraw()
	if _anim:
		_anim.queue_redraw()
	_update_processing()


func is_lockdown_mode() -> bool:
	return _lockdown


func _transition_active() -> bool:
	return _lockdown and mode == Mode.DEPOT \
			and _lockdown_elapsed < float(_fixtures.size()) * BANK_STEP + BANK_DARK


## True when the depot draws its painted wall (Sheet 5) instead of the
## code-drawn back wall, racks, cables and floor strip.
func _painted_depot() -> bool:
	return mode == Mode.DEPOT and _depot_wall != null


## True when this layer draws a painted strip (C39) with its own parallax,
## which redraws as the camera moves.
func _scrolling() -> bool:
	return (mode == Mode.SKY and _far != null) or (mode == Mode.HOMES and _campus != null)


func _update_processing() -> void:
	if _scrolling():
		set_process(true)
		return
	var animated := mode != Mode.SKY and not _painted_depot() and not _reduced_motion
	set_process(animated or _transition_active())


## Refreshes the camera-visible local x range; true while any of this
## layer's span is on screen (the animated canvas only redraws then).
func _update_view() -> bool:
	var vp := get_viewport()
	if vp == null:
		return false
	var inv := vp.get_canvas_transform().affine_inverse()
	var vr := vp.get_visible_rect()
	var a: Vector2 = inv * vr.position
	var b: Vector2 = inv * vr.end
	_view_x0 = minf(a.x, b.x) - _gx0 - 40.0
	_view_x1 = maxf(a.x, b.x) - _gx0 + 40.0
	return _view_x1 >= 0.0 and _view_x0 <= tile_width


# --- shared helpers --------------------------------------------------------------

## Deterministic 0..1 hash (an integer mix, stable across runs and areas).
func _hash01(n: int) -> float:
	var h: int = (n * 0x27d4eb2d) & 0xffffffff
	h = (h ^ (h >> 15)) & 0xffffffff
	h = (h * 0x165667b1) & 0xffffffff
	h = h ^ (h >> 13)
	return float(h & 0xffff) / 65535.0


func _h(k: int, salt: int) -> float:
	return _hash01(k * 7919 + salt * 104729 + 17)


## Global cell indices whose cell overlaps this layer's span (with a margin
## of one cell each side, for features that straddle a seam).
func _cell_range(cell: float) -> Array:
	var k0 := int(floor((_gx0 - cell) / cell))
	var k1 := int(floor((_gx0 + tile_width + cell) / cell))
	return range(k0, k1 + 1)


func _overlaps_span(x0: float, x1: float) -> bool:
	return x1 > 0.0 and x0 < tile_width


func _inside_span(x0: float, x1: float) -> bool:
	return x0 >= 0.0 and x1 <= tile_width


## Draws `r` clipped to this layer's [0, tile_width] span.
func _rect_c(c: CanvasItem, r: Rect2, color: Color, filled: bool = true, width: float = -1.0) -> void:
	var x0: float = maxf(r.position.x, 0.0)
	var x1: float = minf(r.end.x, tile_width)
	if x1 <= x0:
		return
	var clipped := Rect2(Vector2(x0, r.position.y), Vector2(x1 - x0, r.size.y))
	if filled:
		c.draw_rect(clipped, color)
	else:
		c.draw_rect(clipped, color, false, width)


func _vline_c(c: CanvasItem, x: float, y0: float, y1: float, color: Color, width: float) -> void:
	if x >= 0.0 and x <= tile_width:
		c.draw_line(Vector2(x, y0), Vector2(x, y1), color, width)


func _hline_c(c: CanvasItem, x0: float, x1: float, y: float, color: Color, width: float) -> void:
	var a: float = maxf(x0, 0.0)
	var b: float = minf(x1, tile_width)
	if b > a:
		c.draw_line(Vector2(a, y), Vector2(b, y), color, width)


## A flat band whose top edge follows `top_fn(global_x)`, sampled across the
## span only (so neighbouring areas' bands meet exactly at the seam).
func _draw_wavy_band(top_fn: Callable, bottom: float, color: Color) -> void:
	var pts := PackedVector2Array()
	pts.append(Vector2(0.0, bottom))
	var x: float = 0.0
	while true:
		pts.append(Vector2(x, top_fn.call(_gx0 + x)))
		if x >= tile_width:
			break
		x = minf(x + 48.0, tile_width)
	pts.append(Vector2(tile_width, bottom))
	draw_colored_polygon(pts, color)


# --- SKY -----------------------------------------------------------------------

func _build_sky() -> void:
	_stars.clear()
	for k in _cell_range(STAR_CELL):
		if _h(k, 1) > 0.36:
			continue
		var x: float = float(k) * STAR_CELL + _h(k, 2) * STAR_CELL - _gx0
		if x < 5.0 or x > tile_width - 5.0:
			continue
		var y: float = horizon_y - 250.0 - pow(_h(k, 3), 0.7) * 1050.0
		var r: float = 0.8 + _h(k, 4) * 1.1
		var a: float = 0.3 + _h(k, 5) * 0.6
		_stars.append({"pos": Vector2(x, y), "r": r, "a": a, "cross": _h(k, 6) < 0.07})
	_clouds.clear()
	# One thin low cloud band broken into runs: sampled on global x, a run is
	# every stretch where the band's thickness stays above zero.
	var run := PackedVector2Array()
	var run_bottom := PackedVector2Array()
	var x2: float = 0.0
	while true:
		var gx: float = _gx0 + x2
		var th: float = 7.0 + 9.0 * sin(gx / 290.0) + 6.0 * sin(gx / 113.0 + 1.7)
		var mid: float = horizon_y - 228.0 + 9.0 * sin(gx / 610.0)
		if th > 0.5:
			run.append(Vector2(x2, mid - th * 0.45))
			run_bottom.append(Vector2(x2, mid + th * 0.55))
		elif run.size() > 0:
			_close_cloud_run(run, run_bottom)
			run = PackedVector2Array()
			run_bottom = PackedVector2Array()
		if x2 >= tile_width:
			break
		x2 = minf(x2 + 24.0, tile_width)
	if run.size() > 0:
		_close_cloud_run(run, run_bottom)


func _close_cloud_run(top: PackedVector2Array, bottom: PackedVector2Array) -> void:
	if top.size() < 2:
		return
	var poly := PackedVector2Array(top)
	for i in range(bottom.size() - 1, -1, -1):
		poly.append(bottom[i])
	_clouds.append({"poly": poly, "rim": bottom})


func _draw_sky() -> void:
	var w: float = tile_width
	var bands: Array = SKY_BANDS_LOCKDOWN if _lockdown else SKY_BANDS
	var y: float = horizon_y + SKY_TOP
	for i in bands.size():
		var y1: float = horizon_y + (SKY_BAND_EDGES[i] if i < SKY_BAND_EDGES.size() else SKY_BOTTOM)
		draw_rect(Rect2(Vector2(0.0, y), Vector2(w, y1 - y)), bands[i])
		y = y1
	var star_dim: float = 0.6 if _lockdown else 1.0
	for s in _stars:
		var p: Vector2 = s["pos"]
		var col := Color(STAR, float(s["a"]) * star_dim)
		draw_circle(p, float(s["r"]), col)
		if s["cross"]:
			draw_line(p + Vector2(-4.0, 0.0), p + Vector2(4.0, 0.0), Color(col, col.a * 0.5), 1.0)
			draw_line(p + Vector2(0.0, -4.0), p + Vector2(0.0, 4.0), Color(col, col.a * 0.5), 1.0)
	var rim: Color = CLOUD_RIM_LOCKDOWN if _lockdown else CLOUD_RIM
	for cl in _clouds:
		draw_colored_polygon(cl["poly"], CLOUD)
		draw_polyline(cl["rim"], rim, 1.5)


## The painted far layer over the visible part of this area's span.
func _draw_far() -> void:
	_update_view()
	var x0: float = maxf(0.0, _view_x0)
	var x1: float = minf(tile_width, _view_x1)
	if x1 <= x0:
		return
	var tint: Color = FAR_LOCKDOWN_TINT if _lockdown else FAR_TINT
	var top: float = horizon_y + FAR_BASE - float(_far.get_height()) * FAR_ART_PX
	# Flat sky above the painting, in its own top colour.
	draw_rect(Rect2(Vector2(x0, horizon_y + SKY_TOP), Vector2(x1 - x0, top - (horizon_y + SKY_TOP) + 1.0)), _far_top * tint)
	_draw_strip(_far, FAR_DEPTH, horizon_y + FAR_BASE, tint)


## Draws a painted strip across the visible part of this layer's span, its
## base at `base_y`, repeating sideways and sampled by global x minus `depth`
## of the camera's x (so it moves at 1 - depth of the camera's speed and lines
## up exactly at area seams). It steps in whole art pixels so it never
## shimmers.
func _draw_strip(tex: Texture2D, depth: float, base_y: float, tint: Color) -> void:
	var x0: float = maxf(0.0, _view_x0)
	var x1: float = minf(tile_width, _view_x1)
	if x1 <= x0:
		return
	var tex_w: float = float(tex.get_width())
	var tex_h: float = float(tex.get_height())
	var h: float = tex_h * FAR_ART_PX
	# Texel under local x0, stepped to whole art pixels.
	var cam_x: float = _camera_x()
	var u: float = floorf((_gx0 + x0 - depth * cam_x) / FAR_ART_PX)
	var frac: float = (_gx0 + x0 - depth * cam_x) / FAR_ART_PX - u
	var dx: float = x0 - frac * FAR_ART_PX
	var span_w: float = x1 - dx
	draw_texture_rect_region(tex, Rect2(Vector2(dx, base_y - h), Vector2(span_w, h)),
			Rect2(Vector2(fposmod(u, tex_w), 0.0), Vector2(span_w / FAR_ART_PX, tex_h)), tint)


## World x at the centre of what the viewport shows.
func _camera_x() -> float:
	var vp := get_viewport()
	if vp == null:
		return 0.0
	var inv := vp.get_canvas_transform().affine_inverse()
	return (inv * (vp.get_visible_rect().size * 0.5)).x


# --- HOMES: the campus skyline --------------------------------------------------

func _build_homes() -> void:
	_towers.clear()
	_aviation.clear()
	for k in _cell_range(TOWER_CELL):
		if _h(k, 1) > 0.84:
			continue
		var tw: float = 70.0 + _h(k, 3) * 120.0
		var th: float = 220.0 + _h(k, 4) * 340.0
		var x: float = (float(k) + 0.5) * TOWER_CELL + (_h(k, 2) - 0.5) * 180.0 - _gx0
		if not _overlaps_span(x - tw * 0.5, x + tw * 0.5):
			continue
		var top: float = horizon_y - th
		var crown: float = _h(k, 5)
		var t := {"x": x, "w": tw, "top": top, "crown": crown, "lit": [], "lit_teal": [], "emblem": false}
		# a few lit windows (10 px x 13 px cells), stored once so a redraw
		# never re-hashes the whole grid.
		var fl := 0
		var wy: float = top + 12.0
		while wy < horizon_y - 34.0:
			var col := 0
			var wx: float = x - tw * 0.5 + 5.0
			while wx < x + tw * 0.5 - 9.0:
				var hv := _h(k * 997 + fl * 53 + col, 7)
				if hv < 0.05:
					var r := Rect2(Vector2(wx + 1.0, wy + 2.0), Vector2(6.0, 7.0))
					if hv < 0.014:
						t["lit_teal"].append(r)
					else:
						t["lit"].append(r)
				wx += 10.0
				col += 1
			wy += 13.0
			fl += 1
		var tip := Vector2(x, top)
		if crown < 0.3:
			tip = Vector2(x, top - 26.0)
		elif crown < 0.55:
			tip = Vector2(x + tw * 0.18, top - 34.0 - _h(k, 8) * 30.0)
		if (th > 400.0 or (crown >= 0.3 and crown < 0.55)) and tip.x > 4.0 and tip.x < tile_width - 4.0:
			_aviation.append({"pos": tip, "phase": _h(k, 9)})
		var emblem_r: float = clampf(tw * 0.2, 10.0, 17.0)
		if _h(k, 6) < 0.18 and th > 320.0 and _inside_span(x - emblem_r * 2.0, x + emblem_r * 2.0):
			t["emblem"] = true
			t["emblem_r"] = emblem_r
		_towers.append(t)
	if _far != null:
		# The painted far layer (C39) has the skyline and its roof lights.
		_towers.clear()
		_aviation.clear()
	_pavilions.clear()
	_hedges.clear()
	_path_lights.clear()
	_billboards.clear()
	if _campus == null:
		_build_campus_shapes()
	_drone = {}
	if tile_width >= 900.0:
		var dk := int(floor(_gx0 / 1000.0))
		_drone = {
			"x0": tile_width * 0.12, "x1": tile_width * 0.88,
			"y": horizon_y - 330.0 - _h(dk, 51) * 120.0,
			"phase": _h(dk, 52),
		}


## The drawn pavilions, hedges, path lights and billboard: the fallback when
## the painted campus layer (C39) is missing.
func _build_campus_shapes() -> void:
	for k in _cell_range(PAVILION_CELL):
		if _h(k, 11) > 0.72:
			continue
		var pw: float = 200.0 + _h(k, 12) * 170.0
		var ph: float = 80.0 + _h(k, 13) * 80.0
		var px: float = (float(k) + 0.5) * PAVILION_CELL + (_h(k, 14) - 0.5) * 300.0 - _gx0
		if not _overlaps_span(px - pw * 0.5 - 12.0, px + pw * 0.5 + 12.0):
			continue
		var p := {"x": px, "w": pw, "h": ph, "fascia": _h(k, 15) < 0.5, "panes": []}
		var pane_x: float = px - pw * 0.5 + 8.0
		var i := 0
		while pane_x < px + pw * 0.5 - 8.0:
			var hv := _h(k * 131 + i, 16)
			if hv < 0.16:
				p["panes"].append({"x": pane_x, "teal": hv < 0.05})
			pane_x += 17.0
			i += 1
		_pavilions.append(p)

	for k in _cell_range(HEDGE_CELL):
		if _h(k, 21) > 0.58:
			continue
		var hw: float = 40.0 + _h(k, 22) * 60.0
		var hh: float = 18.0 + _h(k, 23) * 18.0
		var hx: float = (float(k) + 0.5) * HEDGE_CELL + (_h(k, 24) - 0.5) * 80.0 - _gx0
		if not _overlaps_span(hx - hw * 0.5, hx + hw * 0.5):
			continue
		_hedges.append({"x": hx, "w": hw, "h": hh, "round": _h(k, 25) < 0.35})

	for k in _cell_range(PATH_LIGHT_CELL):
		var lx: float = (float(k) + 0.5) * PATH_LIGHT_CELL - _gx0
		if lx > 6.0 and lx < tile_width - 6.0 and _h(k, 31) < 0.7:
			_path_lights.append(Vector2(lx, horizon_y - 22.0))

	for k in _cell_range(BILLBOARD_CELL):
		if _h(k, 41) > 0.6:
			continue
		var bw: float = 150.0 + _h(k, 42) * 60.0
		var bh: float = 80.0 + _h(k, 43) * 24.0
		var bx: float = (float(k) + 0.5) * BILLBOARD_CELL + (_h(k, 44) - 0.5) * 900.0 - _gx0
		if not _inside_span(bx - bw * 0.5 - 4.0, bx + bw * 0.5 + 4.0):
			continue
		var bottom: float = horizon_y - 190.0 - _h(k, 45) * 60.0
		_billboards.append({
			"rect": Rect2(Vector2(bx - bw * 0.5, bottom - bh), Vector2(bw, bh)),
			"seed": _h(k, 46),
		})


func _draw_homes() -> void:
	var w: float = tile_width
	if _far == null:
		_draw_towers()   # the painted far layer (C39) has the skyline
	# the far lawn plane under everything that stands on the seam line, then
	# the same navy-black as the blocks' shadow mass below it (only ever seen
	# through gaps under the play plane).
	draw_rect(Rect2(Vector2(0.0, horizon_y - 4.0), Vector2(w, 144.0)), LAWN_FAR)
	draw_rect(Rect2(Vector2(0.0, horizon_y + 140.0), Vector2(w, 460.0)), UNDERGROUND)
	draw_line(Vector2(0.0, horizon_y - 4.0), Vector2(w, horizon_y - 4.0), Color(0.2, 0.3, 0.36, 0.35), 1.5)
	if _campus != null:
		_update_view()
		_draw_strip(_campus, CAMPUS_DEPTH, horizon_y + CAMPUS_BASE, CAMPUS_LOCKDOWN_TINT if _lockdown else CAMPUS_TINT)
	for p in _pavilions:
		_draw_pavilion(p)
	for b in _billboards:
		_draw_billboard_frame(b)
	for hd in _hedges:
		_draw_far_hedge(hd)
	var pl_col: Color = AMBER if _lockdown else PATH_WHITE
	for lp in _path_lights:
		draw_circle(lp, 5.0, Color(pl_col, 0.1))
		draw_circle(lp, 1.8, Color(pl_col, 0.85))
	# flat, low-contrast ground fog in front of the whole skyline.
	_draw_wavy_band(_fog_a_top, horizon_y + 40.0, FOG_A_LOCKDOWN if _lockdown else FOG_A)
	_draw_wavy_band(_fog_b_top, horizon_y + 40.0, FOG_B_LOCKDOWN if _lockdown else FOG_B)


func _fog_a_top(gx: float) -> float:
	return horizon_y - 82.0 + 10.0 * sin(gx / 370.0) + 6.0 * sin(gx / 143.0 + 1.1)


func _fog_b_top(gx: float) -> float:
	return horizon_y - 40.0 + 7.0 * sin(gx / 260.0 + 2.0) + 4.0 * sin(gx / 97.0)


func _draw_towers() -> void:
	for t in _towers:
		var x: float = t["x"]
		var tw: float = t["w"]
		var top: float = t["top"]
		var crown: float = t["crown"]
		var left: float = x - tw * 0.5
		_rect_c(self, Rect2(Vector2(left, top), Vector2(tw, horizon_y + 400.0 - top)), TOWER)
		# glass: faint mullions and floor lines, then the lit windows.
		var mx: float = left + 5.0
		while mx < left + tw - 4.0:
			_vline_c(self, mx, top + 8.0, horizon_y, TOWER_MULLION, 1.0)
			mx += 10.0
		var fy: float = top + 12.0
		while fy < horizon_y:
			_hline_c(self, left + 2.0, left + tw - 2.0, fy, TOWER_FLOOR, 1.0)
			fy += 13.0
		for r in t["lit"]:
			_rect_c(self, r, WIN_WARM)
		for r2 in t["lit_teal"]:
			_rect_c(self, r2, WIN_RED if _lockdown else WIN_TEAL)
		# crown: a setback box, an antenna mast, or a plain parapet.
		if crown < 0.3:
			_rect_c(self, Rect2(Vector2(x - tw * 0.3, top - 26.0), Vector2(tw * 0.6, 26.0)), TOWER)
			_hline_c(self, x - tw * 0.3, x + tw * 0.3, top - 26.0, TOWER_RIM, 1.5)
		elif crown < 0.55:
			var mast_x: float = x + tw * 0.18
			var mast_top: float = top
			for av in _aviation:
				if absf(av["pos"].x - mast_x) < 0.5:
					mast_top = av["pos"].y
			_vline_c(self, mast_x, mast_top, top, TOWER_RIM, 2.0)
		_hline_c(self, left, left + tw, top, TOWER_RIM, 1.5)
		# city-glow rim down the left edge, so towers separate from the sky.
		_vline_c(self, left + 1.0, top, horizon_y, TOWER_RIM, 2.0)
		if t["emblem"]:
			_draw_emblem(self, Vector2(x, top + 44.0), float(t["emblem_r"]))
	for av2 in _aviation:
		draw_circle(av2["pos"], 2.0, Color(ALARM, 0.3))


## Arcadia's teal arch-and-leaf mark (style guide "an original teal emblem,
## for example an abstract arch or leaf-in-arch mark"); amber in lockdown.
func _draw_emblem(c: CanvasItem, center: Vector2, r: float) -> void:
	var col: Color = AMBER if _lockdown else TEAL
	c.draw_circle(center, r * 2.0, Color(col, 0.06))
	c.draw_circle(center, r * 1.45, Color(col, 0.08))
	var t: float = maxf(2.0, r * 0.22)
	c.draw_arc(center, r, PI, TAU, 18, col, t)
	c.draw_line(center + Vector2(-r, 0.0), center + Vector2(-r, r * 0.9), col, t)
	c.draw_line(center + Vector2(r, 0.0), center + Vector2(r, r * 0.9), col, t)
	var leaf := PackedVector2Array()
	for i in 9:
		var a: float = PI * float(i) / 8.0
		leaf.append(center + Vector2(-sin(a) * r * 0.32, r * 0.7 - (1.0 - cos(a)) * r * 0.62))
	for i in range(7, 0, -1):
		var a2: float = PI * float(i) / 8.0
		leaf.append(center + Vector2(sin(a2) * r * 0.32, r * 0.7 - (1.0 - cos(a2)) * r * 0.62))
	c.draw_colored_polygon(leaf, col)


func _draw_pavilion(p: Dictionary) -> void:
	var x: float = p["x"]
	var pw: float = p["w"]
	var ph: float = p["h"]
	var left: float = x - pw * 0.5
	var top: float = horizon_y - ph
	_rect_c(self, Rect2(Vector2(left, top), Vector2(pw, ph + 4.0)), PAVILION)
	var glass := Rect2(Vector2(left + 5.0, top + 10.0), Vector2(pw - 10.0, ph - 30.0))
	_rect_c(self, glass, PAVILION_GLASS)
	for pane in p["panes"]:
		var pr := Rect2(Vector2(float(pane["x"]) + 1.0, glass.position.y + 2.0), Vector2(15.0, glass.size.y - 4.0))
		var lit: Color = WIN_WARM
		if pane["teal"]:
			lit = WIN_RED if _lockdown else WIN_TEAL
		_rect_c(self, pr, Color(lit, lit.a * 0.75))
	var mx: float = left + 8.0
	while mx < left + pw - 6.0:
		_vline_c(self, mx, glass.position.y, glass.end.y, PAVILION_MULLION, 2.0)
		mx += 17.0
	_hline_c(self, glass.position.x, glass.end.x, glass.position.y + glass.size.y * 0.42, PAVILION_MULLION, 2.0)
	# recessed ground floor with columns, and a cantilevered roof slab.
	_rect_c(self, Rect2(Vector2(left + 5.0, horizon_y - 20.0), Vector2(pw - 10.0, 20.0)), OUTLINE)
	for cx in [left + 12.0, x, left + pw - 12.0]:
		_rect_c(self, Rect2(Vector2(cx - 3.0, horizon_y - 20.0), Vector2(6.0, 20.0)), PAVILION_SLAB)
	_rect_c(self, Rect2(Vector2(left - 12.0, top - 8.0), Vector2(pw + 24.0, 9.0)), PAVILION_SLAB)
	_hline_c(self, left - 12.0, left + pw + 12.0, top - 8.0, PAVILION_RIM, 1.5)
	if p["fascia"]:
		var fc: Color = AMBER if _lockdown else TEAL
		_hline_c(self, left - 8.0, left + pw + 8.0, top - 2.5, Color(fc, 0.45), 1.5)


func _draw_far_hedge(hd: Dictionary) -> void:
	var x: float = hd["x"]
	var hw: float = hd["w"]
	var hh: float = hd["h"]
	if hd["round"]:
		var r: float = hh * 0.6
		var c := Vector2(x, horizon_y - hh + r * 0.4)
		if x - r >= 0.0 and x + r <= tile_width:
			draw_rect(Rect2(Vector2(x - 1.5, c.y), Vector2(3.0, horizon_y - c.y)), HEDGE_FAR)
			draw_circle(c, r, HEDGE_FAR)
			draw_arc(c, r, PI * 1.05, PI * 1.6, 8, HEDGE_RIM, 1.5)
		return
	var cr: float = minf(hh * 0.45, 10.0)
	_rect_c(self, Rect2(Vector2(x - hw * 0.5, horizon_y - hh + cr), Vector2(hw, hh - cr + 2.0)), HEDGE_FAR)
	_rect_c(self, Rect2(Vector2(x - hw * 0.5 + cr, horizon_y - hh), Vector2(hw - cr * 2.0, cr)), HEDGE_FAR)
	for cx in [x - hw * 0.5 + cr, x + hw * 0.5 - cr]:
		if cx - cr >= 0.0 and cx + cr <= tile_width:
			draw_circle(Vector2(cx, horizon_y - hh + cr), cr, HEDGE_FAR)
	_hline_c(self, x - hw * 0.5 + cr, x + hw * 0.5 - cr, horizon_y - hh + 0.75, HEDGE_RIM, 1.5)


## The billboard's fixed parts: a slim pylon, the projector head and a thin
## frame. The flickering hologram itself is on the animated canvas.
func _draw_billboard_frame(b: Dictionary) -> void:
	var r: Rect2 = b["rect"]
	var cx: float = r.get_center().x
	draw_rect(Rect2(Vector2(cx - 5.0, r.end.y + 10.0), Vector2(10.0, horizon_y - r.end.y - 10.0)), PYLON)
	draw_line(Vector2(cx - 5.0, r.end.y + 10.0), Vector2(cx - 5.0, horizon_y), TOWER_RIM, 1.0)
	draw_rect(Rect2(Vector2(cx - 14.0, r.end.y + 2.0), Vector2(28.0, 10.0)), PYLON)
	draw_rect(Rect2(Vector2(cx - 14.0, r.end.y + 2.0), Vector2(28.0, 10.0)), TOWER_RIM, false, 1.0)
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		draw_circle(corner, 2.0, TOWER_RIM)


func _draw_homes_anim(c: CanvasItem) -> void:
	# blinking red aviation lights on the tallest towers (steady when
	# reduced_motion).
	for av in _aviation:
		var p: Vector2 = av["pos"]
		if p.x < _view_x0 or p.x > _view_x1:
			continue
		var on := _reduced_motion or fmod(_time * AVIATION_HZ + float(av["phase"]), 1.0) < AVIATION_DUTY
		if on:
			c.draw_circle(p, 6.0, Color(ALARM, 0.16))
			c.draw_circle(p, 2.4, ALARM)
	for b in _billboards:
		_draw_hologram(c, b)
	if not _drone.is_empty():
		_draw_drone(c)


## Slow, irregular hologram flicker: a gentle waver plus a brief dropout
## every few seconds — never more than ~0.5 changes per second. Held steady
## under reduced motion.
func _flicker(seed_v: float) -> float:
	if _reduced_motion:
		return 0.85
	var t: float = _time + seed_v * 7.0
	var f: float = 0.8 + 0.1 * sin(t * 1.3) + 0.06 * sin(t * 3.1)
	if fmod(t * 0.23, 1.0) < 0.035:
		f *= 0.45
	return clampf(f, 0.0, 1.0)


## The holographic billboard: a translucent teal panel with scanlines showing
## Arcadia's fixed wellness smile — cheerful in a way that feels wrong in the
## dark. In lockdown it turns amber and shows a lock.
func _draw_hologram(c: CanvasItem, b: Dictionary) -> void:
	var r: Rect2 = b["rect"]
	if r.end.x < _view_x0 or r.position.x > _view_x1:
		return
	var f: float = _flicker(float(b["seed"]))
	var col: Color = AMBER if _lockdown else TEAL
	var cx: float = r.get_center().x
	# projector beam from the pylon head up into the panel.
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 6.0, r.end.y + 3.0), Vector2(cx + 6.0, r.end.y + 3.0),
		Vector2(r.end.x - 10.0, r.end.y), Vector2(r.position.x + 10.0, r.end.y),
	]), Color(col, 0.06 * f))
	c.draw_rect(r, Color(col, 0.1 * f))
	var y: float = r.position.y + 2.0
	while y < r.end.y:
		c.draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color(col, 0.08 * f), 1.0)
		y += 4.0
	c.draw_rect(r, Color(col, 0.6 * f), false, 1.5)
	var ic := r.get_center()
	var s: float = minf(r.size.x, r.size.y) * 0.3
	var ink := Color(col, 0.85 * f)
	if _lockdown:
		var body := Rect2(ic + Vector2(-s * 0.7, -s * 0.15), Vector2(s * 1.4, s * 1.05))
		c.draw_arc(ic + Vector2(0.0, -s * 0.15), s * 0.48, PI, TAU, 12, ink, 3.0)
		c.draw_line(ic + Vector2(-s * 0.48, -s * 0.15), ic + Vector2(-s * 0.48, 0.0), ink, 3.0)
		c.draw_line(ic + Vector2(s * 0.48, -s * 0.15), ic + Vector2(s * 0.48, 0.0), ink, 3.0)
		c.draw_rect(body, ink)
		c.draw_circle(body.get_center(), s * 0.14, Color(OUTLINE, 0.8))
	else:
		c.draw_arc(ic, s * 1.1, 0.0, TAU, 24, ink, 2.0)
		c.draw_circle(ic + Vector2(-s * 0.4, -s * 0.28), s * 0.13, ink)
		c.draw_circle(ic + Vector2(s * 0.4, -s * 0.28), s * 0.13, ink)
		c.draw_arc(ic + Vector2(0.0, s * 0.05), s * 0.55, PI * 0.15, PI * 0.85, 12, ink, 3.0)
		c.draw_line(Vector2(r.position.x + 12.0, r.end.y - 10.0), Vector2(r.end.x - 12.0, r.end.y - 10.0), Color(col, 0.4 * f), 2.0)


## A small delivery drone looping slowly across the sky with one blinking
## light (level brief "Background depth"); parked mid-span under reduced
## motion.
func _draw_drone(c: CanvasItem) -> void:
	var x0: float = _drone["x0"]
	var x1: float = _drone["x1"]
	var p := Vector2((x0 + x1) * 0.5, float(_drone["y"]))
	var facing := 1.0
	if not _reduced_motion:
		var span: float = maxf(x1 - x0, 1.0)
		var u: float = fmod(_time * 38.0 / span + float(_drone["phase"]), 2.0)
		facing = 1.0 if u < 1.0 else -1.0
		var tri: float = u if u < 1.0 else 2.0 - u
		p = Vector2(lerpf(x0, x1, tri), float(_drone["y"]) + 4.0 * sin(_time * 0.9))
	if p.x < _view_x0 or p.x > _view_x1:
		return
	c.draw_rect(Rect2(p + Vector2(-9.0, -3.0), Vector2(18.0, 5.0)), DRONE)
	c.draw_line(p + Vector2(-15.0, -4.0), p + Vector2(15.0, -4.0), DRONE, 2.0)
	c.draw_line(p + Vector2(-20.0, -6.0), p + Vector2(-9.0, -6.0), Color(DRONE, 0.9), 1.5)
	c.draw_line(p + Vector2(9.0, -6.0), p + Vector2(20.0, -6.0), Color(DRONE, 0.9), 1.5)
	c.draw_line(p + Vector2(0.0, 2.0), p + Vector2(0.0, 6.0), DRONE, 1.0)
	c.draw_rect(Rect2(p + Vector2(-4.0, 6.0), Vector2(8.0, 6.0)), DRONE)
	var blink := _reduced_motion or fmod(_time * 0.5 + float(_drone["phase"]), 1.0) < 0.22
	if blink:
		var lp: Vector2 = p + Vector2(8.0 * facing, -1.0)
		var lc: Color = AMBER if _lockdown else TEAL
		c.draw_circle(lp, 4.5, Color(lc, 0.18))
		c.draw_circle(lp, 1.8, lc)


# --- DEPOT: the server depot interior -------------------------------------------

func _in_clear_zone(x0: float, x1: float) -> bool:
	for z in clear_zones:
		if x1 > z.x and x0 < z.y:
			return true
	return false


func _build_depot() -> void:
	_racks.clear()
	_cables.clear()
	if not _painted_depot():
		_build_racks_and_cables()   # the painted wall has its own
	_fixtures.clear()
	var fx: float = FIXTURE_SPACING * 0.5
	while fx < tile_width - 60.0:
		_fixtures.append(fx)
		fx += FIXTURE_SPACING
	for l in _fixture_lights:
		if is_instance_valid(l):
			l.queue_free()
	_fixture_lights.clear()
	var tex := SceneryDraw.smooth_cone_texture()
	for f in _fixtures:
		_fixture_lights.append(SceneryDraw.make_light(self, tex, Vector2(float(f), CEILING_Y + 8.0),
				_fixture_reach(), UTILITY_LIGHT, UTILITY_ENERGY, FIXTURE_LIGHT_HEIGHT))
	_apply_depot_lights()


## The code-drawn fallback's server racks and hanging cables.
func _build_racks_and_cables() -> void:
	var x: float = 110.0
	var i := 0
	var group_left := 3 + int(_h(0, 23) * 3.0)
	while x < tile_width - 90.0:
		if _in_clear_zone(x, x + RACK_W):
			x += 16.0
			continue
		var rh: float = 196.0 + _h(i, 21) * 36.0
		var r := Rect2(Vector2(x, horizon_y - rh), Vector2(RACK_W, rh))
		var leds: Array = []
		for col in 2:
			var lx: float = r.position.x + (11.0 if col == 0 else RACK_W - 15.0)
			var ly: float = r.position.y + 18.0
			var row := 0
			while ly < r.end.y - 24.0:
				var n := i * 1000 + col * 100 + row
				var rate: float = 0.0 if _h(n, 26) < 0.3 else 0.3 + _h(n, 27) * 1.1
				leds.append({
					"pos": Vector2(lx, ly), "green": _h(n, 28) < 0.4, "rate": rate,
					"phase": _h(n, 29), "duty": 0.35 + _h(n, 30) * 0.45,
				})
				ly += 11.0
				row += 1
		_racks.append({"rect": r, "leds": leds})
		i += 1
		x += RACK_W + RACK_GAP
		group_left -= 1
		if group_left <= 0:
			x += 60.0 + _h(i, 22) * 70.0
			group_left = 3 + int(_h(i, 23) * 3.0)

	var cx: float = 70.0
	var ci := 0
	while cx < tile_width - 80.0:
		var span: float = 180.0 + _h(ci, 31) * 160.0
		var sag: float = 36.0 + _h(ci, 32) * 60.0
		_cables.append(_sag_curve(Vector2(cx, CEILING_Y + 2.0), Vector2(minf(cx + span, tile_width - 20.0), CEILING_Y + 2.0), sag))
		if _h(ci, 33) < 0.6:
			var drop_x: float = cx + span * (0.3 + _h(ci, 34) * 0.4)
			_cables.append(_sag_curve(Vector2(cx + 20.0, CEILING_Y + 2.0), Vector2(drop_x, horizon_y - 236.0), 24.0))
		cx += span * (0.7 + _h(ci, 35) * 0.5)
		ci += 1


## How far a fixture's smooth light reaches down from the fixture.
func _fixture_reach() -> float:
	return (horizon_y - (CEILING_Y + 8.0)) * FIXTURE_REACH_RATIO


func _sag_curve(a: Vector2, b: Vector2, sag: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var ctrl: Vector2 = (a + b) * 0.5 + Vector2(0.0, sag * 2.0)
	for i in 13:
		var t: float = float(i) / 12.0
		pts.append(a.lerp(ctrl, t).lerp(ctrl.lerp(b, t), t))
	return pts


## 0 = utility (teal), 1 = switching (dark), 2 = lockdown (alarm red). In a
## live lockdown the banks switch one at a time, left to right.
func _fixture_state(i: int) -> int:
	if not _lockdown:
		return 0
	var t0: float = float(i) * BANK_STEP
	if _lockdown_elapsed < t0:
		return 0
	if _lockdown_elapsed < t0 + BANK_DARK:
		return 1
	return 2


func _apply_depot_lights() -> void:
	for i in _fixture_lights.size():
		var l = _fixture_lights[i]
		if not is_instance_valid(l):
			continue
		match _fixture_state(i):
			0:
				l.color = UTILITY_LIGHT
				l.energy = UTILITY_ENERGY
				l.visible = true
			1:
				l.visible = false
			2:
				l.color = ALARM
				l.energy = LOCKDOWN_ENERGY
				l.visible = true


func _draw_depot() -> void:
	var w: float = tile_width
	var painted := _painted_depot()
	# the building above the ceiling, then the depot's back wall. With the
	# painted wall (its own child canvas, drawn under this one) the building
	# stops at the wall's top, which tucks behind the ceiling block.
	var above_end: float = horizon_y + 60.0
	if painted:
		above_end = horizon_y - float(_depot_wall.get_height()) * FAR_ART_PX + 1.0
	draw_rect(Rect2(Vector2(0.0, horizon_y - 1500.0), Vector2(w, above_end - (horizon_y - 1500.0))), DEPOT_ABOVE)
	var sy: float = CEILING_Y - 100.0
	while sy > horizon_y - 1500.0:
		draw_line(Vector2(0.0, sy), Vector2(w, sy), DEPOT_SEAM, 2.0)
		sy -= 90.0
	if not painted:
		var wall := Rect2(Vector2(0.0, CEILING_Y - 40.0), Vector2(w, horizon_y + 60.0 - (CEILING_Y - 40.0)))
		draw_rect(wall, DEPOT_WALL)
		var px: float = 90.0
		while px < w:
			draw_line(Vector2(px, CEILING_Y), Vector2(px, horizon_y), DEPOT_SEAM, 2.0)
			px += 180.0
		draw_rect(Rect2(Vector2(0.0, horizon_y - 16.0), Vector2(w, 16.0)), Color("#070B12"))
		var base: Color = ALARM if _lockdown else TEAL
		var bx: float = 0.0
		while bx < w:
			draw_line(Vector2(bx + 10.0, horizon_y - 8.0), Vector2(minf(bx + 140.0, w), horizon_y - 8.0), Color(base, 0.3), 2.0)
			bx += 180.0
	# A faint haze shaft under each fixture: the same smooth cone as its real
	# light, so the shaft and the pool it makes match and neither has an edge.
	var cone := SceneryDraw.smooth_cone_texture()
	var reach := _fixture_reach()
	for i in _fixtures.size():
		var st := _fixture_state(i)
		if st == 1:
			continue
		var lc: Color = ALARM if st == 2 else TEAL
		var apex := Vector2(float(_fixtures[i]), CEILING_Y + 8.0)
		draw_texture_rect(cone, Rect2(apex - Vector2(reach, reach), Vector2(reach, reach) * 2.0), false,
				Color(lc, HAZE_ALPHA))
	for rk in _racks:
		_draw_rack(rk)
	for cable in _cables:
		draw_polyline(cable, CABLE, 5.0, true)
		draw_polyline(cable, CABLE_HI, 1.0, true)
	for i in _fixtures.size():
		var fx2: float = _fixtures[i]
		var st2 := _fixture_state(i)
		draw_rect(Rect2(Vector2(fx2 - 32.0, CEILING_Y), Vector2(64.0, 8.0)), RACK_FRAME)
		var strip := Rect2(Vector2(fx2 - 26.0, CEILING_Y + 7.0), Vector2(52.0, 3.0))
		match st2:
			0:
				draw_rect(strip, Color("#C4F7F1"))
			1:
				draw_rect(strip, Color("#1A2230"))
			2:
				draw_rect(strip, Color("#FFC2C8"))
				draw_rect(strip.grow(2.0), Color(ALARM, 0.35), false, 2.0)
		draw_rect(Rect2(Vector2(fx2 - 32.0, CEILING_Y), Vector2(64.0, 8.0)), OUTLINE, false, 1.5)
	# building-end jambs: the depot reads as an interior between two walls.
	for jx in [0.0, w - 14.0]:
		draw_rect(Rect2(Vector2(jx, CEILING_Y - 40.0), Vector2(14.0, horizon_y - CEILING_Y + 40.0)), Color("#0B111B"))
		draw_line(Vector2(jx + (13.0 if jx == 0.0 else 1.0), CEILING_Y), Vector2(jx + (13.0 if jx == 0.0 else 1.0), horizon_y),
				Color(0.3, 0.4, 0.52, 0.5), 1.5)


## The painted wall across this area's whole span, static, on the shared
## art-pixel grid (sampled by global x), its bottom on the floor line.
func _draw_depot_wall() -> void:
	if _depot_wall == null:
		return
	var tex_w: float = float(_depot_wall.get_width())
	var tex_h: float = float(_depot_wall.get_height())
	var u0: float = fposmod(_gx0 / FAR_ART_PX, tex_w)
	_wall.draw_texture_rect_region(_depot_wall,
			Rect2(Vector2(0.0, horizon_y - tex_h * FAR_ART_PX), Vector2(tile_width, tex_h * FAR_ART_PX)),
			Rect2(Vector2(u0, 0.0), Vector2(tile_width / FAR_ART_PX, tex_h)),
			_wall_tint())


## The wall's tint: calm and cool, red-leaning in lockdown. A live lockdown
## fades it in over the banks' stagger, so the wall reddens as the lights do.
func _wall_tint() -> Color:
	if not _lockdown:
		return DEPOT_TINT
	var total: float = float(_fixtures.size()) * BANK_STEP + BANK_DARK
	return DEPOT_TINT.lerp(DEPOT_LOCKDOWN_TINT, clampf(_lockdown_elapsed / total, 0.0, 1.0))


func _draw_rack(rk: Dictionary) -> void:
	var r: Rect2 = rk["rect"]
	draw_rect(r, RACK)
	var front := r.grow(-4.0)
	front.size.y -= 8.0
	draw_rect(front, RACK_FRONT)
	var vy: float = front.position.y + 6.0
	while vy < front.end.y - 4.0:
		draw_line(Vector2(front.position.x + 20.0, vy), Vector2(front.end.x - 20.0, vy), RACK_VENT, 2.0)
		vy += 9.0
	for led in rk["leds"]:
		draw_rect(Rect2(led["pos"], Vector2(4.0, 2.0)), LED_OFF)
	draw_rect(Rect2(Vector2(r.position.x, r.end.y - 8.0), Vector2(r.size.x, 8.0)), OUTLINE)
	draw_rect(r, RACK_FRAME, false, 2.0)
	draw_line(r.position + Vector2(2.0, 2.0), Vector2(r.position.x + 2.0, r.end.y - 8.0), Color(0.4, 0.52, 0.64, 0.35), 1.0)


## Blinking rack LEDs: teal and signal green normally; amber and alarm red
## in lockdown. Steady pattern under reduced motion.
func _draw_depot_anim(c: CanvasItem) -> void:
	for rk in _racks:
		var r: Rect2 = rk["rect"]
		if r.end.x < _view_x0 or r.position.x > _view_x1:
			continue
		for led in rk["leds"]:
			var rate: float = led["rate"]
			var phase: float = led["phase"]
			var duty: float = led["duty"]
			var on: bool
			if rate <= 0.0:
				on = true
			elif _reduced_motion:
				on = phase < duty
			else:
				var speed: float = rate * (1.3 if _lockdown else 1.0)
				on = fmod(_time * speed + phase, 1.0) < duty
			if not on:
				continue
			var col: Color
			if _lockdown:
				col = ALARM if led["green"] else AMBER
			else:
				col = SIGNAL_GREEN if led["green"] else TEAL
			var p: Vector2 = led["pos"]
			c.draw_rect(Rect2(p - Vector2(1.0, 1.0), Vector2(6.0, 4.0)), Color(col, 0.18))
			c.draw_rect(Rect2(p, Vector2(4.0, 2.0)), col)
