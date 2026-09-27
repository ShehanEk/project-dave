class_name Scenery
extends Node2D
## Non-colliding blockout prop, drawn from an exported `kind` + `size`, using
## the Sunnyvale palette (level brief: cream/peach/lawn/sky/teal). Pivot is
## bottom-center (local origin sits on the ground/floor line) for every kind
## except CLOUD_PROJECTOR and PANEL, which hang/sit at the node's own
## position. Always behind actors (negative z_index) so it never hides feet,
## enemies, or landing edges.
##
## M6 presentation pass (art-design/style-guide.md C11: confident dark
## outlines, heavier outer silhouettes, broad flat colors, one or two crisp
## cel-shadow shapes, sparse highlights): every `_draw_*` below was
## redrawn for that look. `kind`'s enum VALUES are never reordered — only
## appended to (GATE) — because area scene files store `kind` as a plain
## integer; changing an existing value's number would silently reskin an
## unrelated prop everywhere it's placed.

enum Kind {
	HOUSE, FENCE, SHRUB, FLOWER, CLOCK, FOUNTAIN, LAMP, PLANTER, MAILBOX,
	PORTRAIT, BREAKFAST, SIGN, CLOUD_PROJECTOR, DEPOT_DOOR, WORKBENCH, RAIL, PANEL,
	GATE, BEACON, SUPPORT,
}

const CREAM := Color("#EFE0BE")
const PEACH := Color("#DF9E80")
const LAWN := Color("#87B45E")
const SKY := Color("#A9D6DD")
const TEAL := Color("#365D62")
const OUTLINE := Color("#332a20")
const WHITE := Color("#FFFFFF")
const GOLD := Color("#f4d35e")
const RUST := Color("#c9663f")
const CYAN := Color("#8fe0c9")

@export var kind: Kind = Kind.SHRUB
@export var size: Vector2 = Vector2(64.0, 64.0)
## SIGN only.
@export var text: String = ""


func _ready() -> void:
	z_index = -10
	z_as_relative = true
	queue_redraw()


func _draw() -> void:
	match kind:
		Kind.HOUSE: _draw_house()
		Kind.FENCE: _draw_fence()
		Kind.SHRUB: _draw_shrub()
		Kind.FLOWER: _draw_flower()
		Kind.CLOCK: _draw_clock()
		Kind.FOUNTAIN: _draw_fountain()
		Kind.LAMP: _draw_lamp()
		Kind.PLANTER: _draw_planter()
		Kind.MAILBOX: _draw_mailbox()
		Kind.PORTRAIT: _draw_portrait()
		Kind.BREAKFAST: _draw_breakfast()
		Kind.SIGN: _draw_sign()
		Kind.CLOUD_PROJECTOR: _draw_cloud_projector()
		Kind.DEPOT_DOOR: _draw_depot_door()
		Kind.WORKBENCH: _draw_workbench()
		Kind.RAIL: _draw_rail()
		Kind.PANEL: _draw_panel()
		Kind.GATE: _draw_gate()
		Kind.BEACON: _draw_beacon()
		Kind.SUPPORT: _draw_support()


func _rect_up(w: float, h: float) -> Rect2:
	return Rect2(Vector2(-w * 0.5, -h), Vector2(w, h))


## Rounded roofline, a fat ceramic gutter line with drawn scallop marks, and
## a small scalloped porch awning over a rounded door — the level brief's
## "Pastel cream houses have rounded rooflines, fat ceramic gutters,
## scalloped porch awnings."
func _draw_house() -> void:
	var w: float = size.x
	var h: float = size.y
	var body_h: float = h * 0.68
	var body := Rect2(Vector2(-w * 0.5, -body_h), Vector2(w, body_h))
	draw_rect(body, CREAM)
	# rounded roofline: a shallow domed cap instead of a sharp peak.
	var roof_pts := PackedVector2Array()
	var seg := 10
	var roof_r: float = w * 0.58
	var roof_peak: float = h - body_h
	for i in seg + 1:
		var t: float = float(i) / float(seg)
		var a: float = PI - t * PI
		roof_pts.append(Vector2(cos(a) * roof_r, -body_h - sin(a) * roof_peak))
	draw_colored_polygon(roof_pts, PEACH)
	draw_polyline(roof_pts, OUTLINE, 3.0, true)
	draw_line(roof_pts[0], roof_pts[roof_pts.size() - 1], OUTLINE, 3.0)
	# a soft cel-shadow under the roof's far side.
	var shadow_pts := PackedVector2Array()
	for i in seg / 2 + 1:
		var t2: float = float(i) / float(seg)
		var a2: float = PI - t2 * PI
		shadow_pts.append(Vector2(cos(a2) * roof_r, -body_h - sin(a2) * roof_peak))
	shadow_pts.append(Vector2(0.0, -body_h))
	draw_colored_polygon(shadow_pts, PEACH.darkened(0.18))
	# fat ceramic gutter with scallop marks along the eave.
	var gutter_y: float = -body_h
	draw_line(Vector2(-w * 0.58, gutter_y), Vector2(w * 0.58, gutter_y), OUTLINE, 4.0)
	var scallop_r: float = w * 0.045
	var cx: float = -w * 0.5 + scallop_r
	while cx < w * 0.5:
		draw_arc(Vector2(cx, gutter_y), scallop_r, 0.0, PI, 6, CREAM.darkened(0.08), 2.5)
		cx += scallop_r * 1.8
	# door with a rounded top and a small scalloped awning above it.
	var door_w: float = w * 0.26
	var door_h: float = body_h * 0.62
	var door_x: float = -door_w * 0.5
	var door_y: float = -door_h
	draw_rect(Rect2(Vector2(door_x, door_y), Vector2(door_w, door_h)), TEAL)
	draw_arc(Vector2(0.0, door_y), door_w * 0.5, PI, TAU, 8, TEAL, door_w * 0.02 + 1.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(door_x, door_y), Vector2(0.0, door_y - door_w * 0.5), Vector2(-door_x, door_y),
	]), TEAL)
	var awning_y: float = door_y - door_w * 0.5 - 4.0
	draw_rect(Rect2(Vector2(door_x - 6.0, awning_y - 6.0), Vector2(door_w + 12.0, 6.0)), PEACH)
	var ax: float = door_x - 6.0 + scallop_r
	while ax < door_x - 6.0 + door_w + 12.0:
		draw_arc(Vector2(ax, awning_y), scallop_r * 0.8, 0.0, PI, 5, PEACH, 2.0)
		ax += scallop_r * 1.5
	draw_rect(body, OUTLINE, false, 3.0)


func _draw_fence() -> void:
	var w: float = size.x
	var h: float = size.y
	var posts: int = maxi(2, int(w / 24.0))
	draw_line(Vector2(-w * 0.5, -h * 0.6), Vector2(w * 0.5, -h * 0.6), CREAM, 4.0)
	for i in posts:
		var x: float = -w * 0.5 + (w / float(posts - 1)) * float(i) if posts > 1 else 0.0
		draw_rect(Rect2(Vector2(x - 3.0, -h), Vector2(6.0, h)), CREAM)
		# a small rounded finial cap so a fence post reads as a designed
		# civic fixture, not a raw stake.
		draw_circle(Vector2(x, -h), 4.0, CREAM)
		draw_circle(Vector2(x, -h), 4.0, OUTLINE, false, 1.5)
		draw_rect(Rect2(Vector2(x - 3.0, -h), Vector2(6.0, h)), OUTLINE, false, 2.0)


## A clipped, bulbous double-lobe shrub with a crisp cel-shadow on its lower
## side — style guide "one or two crisp cel-shadow shapes."
func _draw_shrub() -> void:
	var r: float = minf(size.x, size.y) * 0.5
	var c := Vector2(0.0, -r)
	draw_circle(c + Vector2(-r * 0.32, r * 0.12), r * 0.72, LAWN)
	draw_circle(c + Vector2(r * 0.32, r * 0.12), r * 0.72, LAWN)
	draw_circle(c, r, LAWN)
	# lower cel-shadow crescent
	draw_circle(c + Vector2(0.0, r * 0.3), r * 0.85, LAWN.darkened(0.16))
	draw_circle(c, r * 0.62, LAWN)
	draw_circle(c + Vector2(-r * 0.32, r * 0.12), r * 0.72, OUTLINE, false, 2.5)
	draw_circle(c + Vector2(r * 0.32, r * 0.12), r * 0.72, OUTLINE, false, 2.5)
	draw_circle(c, r, OUTLINE, false, 3.0)


## An oversized flower with rounded petal lobes and a bright graphic
## highlight, matching "Oversized flowers grow in neat mechanical planters."
func _draw_flower() -> void:
	var stem_h: float = size.y
	draw_line(Vector2.ZERO, Vector2(0.0, -stem_h), LAWN, 4.0)
	var leaf := PackedVector2Array([
		Vector2(0.0, -stem_h * 0.4), Vector2(size.x * 0.35, -stem_h * 0.5), Vector2(0.0, -stem_h * 0.58),
	])
	draw_colored_polygon(leaf, LAWN)
	draw_polyline(leaf, OUTLINE, 1.5, true)
	var center := Vector2(0.0, -stem_h)
	var petal_r: float = size.x * 0.24
	for i in 5:
		var a: float = TAU * float(i) / 5.0 - PI * 0.5
		var p: Vector2 = center + Vector2(cos(a), sin(a)) * (size.x * 0.3)
		draw_circle(p, petal_r, PEACH)
		draw_circle(p, petal_r, OUTLINE, false, 2.0)
	draw_circle(center, size.x * 0.17, GOLD)
	draw_circle(center, size.x * 0.17, OUTLINE, false, 2.0)
	draw_circle(center + Vector2(-size.x * 0.05, -size.x * 0.05), size.x * 0.05, Color(1.0, 1.0, 1.0, 0.7))


## The smiling sun-shaped neighborhood clock — a recurring navigation
## landmark (level brief). A soft two-tone face gives it one crisp
## cel-shadow without losing the friendly read from a distance.
func _draw_clock() -> void:
	var r: float = minf(size.x, size.y) * 0.5
	var c := Vector2(0.0, -r)
	draw_circle(c, r * 1.08, GOLD.darkened(0.12))
	draw_circle(c, r, GOLD)
	draw_circle(c + Vector2(r * 0.28, r * 0.1), r * 0.78, GOLD.darkened(0.1))
	draw_circle(c, r * 0.9, GOLD)
	draw_circle(c, r, OUTLINE, false, 3.0)
	# smiling sun face
	draw_circle(c + Vector2(-r * 0.35, -r * 0.15), r * 0.1, OUTLINE)
	draw_circle(c + Vector2(r * 0.35, -r * 0.15), r * 0.1, OUTLINE)
	var pts := PackedVector2Array()
	for i in 9:
		var t: float = float(i) / 8.0
		var a: float = PI * 0.15 + t * (PI * 0.7)
		pts.append(c + Vector2(cos(a), sin(a)) * r * 0.45)
	draw_polyline(pts, OUTLINE, 3.0, true)
	for i in 8:
		var a2: float = TAU * float(i) / 8.0
		draw_line(c + Vector2(cos(a2), sin(a2)) * r * 0.85, c + Vector2(cos(a2), sin(a2)) * r * 1.05, GOLD, 3.0)
	# small mounting bracket beneath, so the landmark reads as fixed to a
	# structure rather than floating.
	draw_rect(Rect2(Vector2(-r * 0.12, 0.0), Vector2(r * 0.24, r * 0.22)), OUTLINE.lightened(0.1))


## Two-tier basin with a scalloped rim and a few graphic sparkle marks — the
## level brief's nonblocking A04 midground fountain.
func _draw_fountain() -> void:
	var w: float = size.x
	var h: float = size.y
	var base := Rect2(Vector2(-w * 0.5, -h * 0.3), Vector2(w, h * 0.3))
	draw_rect(base, CREAM)
	draw_rect(Rect2(base.position, Vector2(w, minf(6.0, base.size.y))), CREAM.lightened(0.15))
	var scallop_r: float = w * 0.06
	var cx: float = -w * 0.5 + scallop_r
	while cx < w * 0.5:
		draw_arc(Vector2(cx, -h * 0.3), scallop_r, PI, TAU, 6, CREAM, 2.5)
		cx += scallop_r * 1.7
	draw_rect(base, OUTLINE, false, 3.0)
	draw_circle(Vector2(0.0, -h * 0.3), w * 0.32, SKY)
	draw_circle(Vector2(0.0, -h * 0.3), w * 0.32, OUTLINE, false, 2.5)
	draw_circle(Vector2(0.0, -h), w * 0.10, SKY)
	draw_circle(Vector2(0.0, -h), w * 0.10, OUTLINE, false, 2.0)
	draw_line(Vector2(0.0, -h * 0.3), Vector2(0.0, -h), CREAM, 8.0)
	draw_line(Vector2(0.0, -h * 0.3), Vector2(0.0, -h), OUTLINE, 8.0 + 2.0)
	draw_line(Vector2(0.0, -h * 0.3), Vector2(0.0, -h), CREAM, 6.0)
	# a few graphic water-sparkle marks over the basin.
	for i in 3:
		var t: float = (float(i) + 0.5) / 3.0
		draw_line(Vector2(lerp(-w * 0.22, w * 0.22, t), -h * 0.42), Vector2(lerp(-w * 0.22, w * 0.22, t), -h * 0.5),
				Color(1.0, 1.0, 1.0, 0.8), 2.0)


## A flower-shaped garden lamp normally; the exact same fixture reads as a
## clinical examination light once EnvironmentState tints it cyan on
## awakening (per its own doc comment: retint, never swap). The bloom-shaped
## shade and small swivel bracket make that later tint read as a lamp head
## turning to point at the route, not a different prop appearing.
func _draw_lamp() -> void:
	var h: float = size.y
	var w: float = size.x
	draw_line(Vector2(0.0, -h * 0.08), Vector2(0.0, -h * 0.75), TEAL, 5.0)
	# swivel bracket
	draw_circle(Vector2(0.0, -h * 0.75), w * 0.12, OUTLINE.lightened(0.15))
	draw_line(Vector2(0.0, -h * 0.75), Vector2(w * 0.18, -h * 0.86), TEAL, 4.0)
	var head := Vector2(w * 0.18, -h * 0.86)
	for i in 5:
		var a: float = TAU * float(i) / 5.0
		draw_circle(head + Vector2(cos(a), sin(a)) * (w * 0.16), w * 0.15, PEACH)
	draw_circle(head, w * 0.16, GOLD)
	# outline pass after fill so petal seams stay crisp
	for i in 5:
		var a: float = TAU * float(i) / 5.0
		draw_circle(head + Vector2(cos(a), sin(a)) * (w * 0.16), w * 0.15, OUTLINE, false, 1.5)
	draw_circle(head, w * 0.16, OUTLINE, false, 2.0)


## A neat mechanical planter box (rivets, cream service band) with an
## oversized bloom, matching "Oversized flowers grow in neat mechanical
## planters."
func _draw_planter() -> void:
	var w: float = size.x
	var h: float = size.y
	var box := Rect2(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h * 0.5))
	draw_rect(box, TEAL)
	draw_rect(Rect2(box.position, Vector2(w, minf(6.0, box.size.y))), CREAM)
	draw_rect(box, OUTLINE, false, 2.5)
	for i in 3:
		var t: float = (float(i) + 0.5) / 3.0
		draw_circle(Vector2(lerp(box.position.x + 4.0, box.end.x - 4.0, t), box.position.y + box.size.y * 0.7), 2.5, CREAM.darkened(0.1))
	var bloom_c := Vector2(0.0, -h * 0.5)
	for i in 5:
		var a: float = TAU * float(i) / 5.0 - PI * 0.5
		draw_circle(bloom_c + Vector2(cos(a), sin(a)) * (w * 0.22), w * 0.2, PEACH)
	for i in 5:
		var a: float = TAU * float(i) / 5.0 - PI * 0.5
		draw_circle(bloom_c + Vector2(cos(a), sin(a)) * (w * 0.22), w * 0.2, OUTLINE, false, 1.5)
	draw_circle(bloom_c, w * 0.15, GOLD)
	draw_circle(bloom_c, w * 0.15, OUTLINE, false, 1.5)


func _draw_mailbox() -> void:
	var h: float = size.y
	var w: float = size.x
	draw_line(Vector2.ZERO, Vector2(0.0, -h * 0.7), CREAM, 4.0)
	var box := Rect2(Vector2(-w * 0.5, -h), Vector2(w, h * 0.3))
	draw_rect(box, PEACH)
	draw_arc(box.position + Vector2(w * 0.5, 0.0), w * 0.5, PI, TAU, 8, PEACH, w * 0.02 + 1.0)
	draw_rect(box, OUTLINE, false, 2.0)
	# small raised flag
	draw_rect(Rect2(Vector2(w * 0.42, -h - h * 0.12), Vector2(w * 0.1, h * 0.12)), RUST)
	draw_rect(Rect2(Vector2(w * 0.42, -h - h * 0.12), Vector2(w * 0.1, h * 0.12)), OUTLINE, false, 1.5)


## A readable family portrait: a simple two-figure silhouette inside a
## cream mat and peach frame — the level brief's quiet A02 story detail.
func _draw_portrait() -> void:
	var rect := _rect_up(size.x, size.y)
	draw_rect(rect, PEACH)
	var inner := rect.grow(-6.0)
	draw_rect(inner, CREAM)
	var base_y: float = inner.end.y - 4.0
	draw_circle(Vector2(inner.get_center().x - inner.size.x * 0.16, base_y - inner.size.y * 0.32), inner.size.x * 0.12, TEAL.lightened(0.1))
	draw_rect(Rect2(Vector2(inner.get_center().x - inner.size.x * 0.28, base_y - inner.size.y * 0.22), Vector2(inner.size.x * 0.24, inner.size.y * 0.22)), TEAL.lightened(0.1))
	draw_circle(Vector2(inner.get_center().x + inner.size.x * 0.14, base_y - inner.size.y * 0.28), inner.size.x * 0.1, RUST.lightened(0.1))
	draw_rect(Rect2(Vector2(inner.get_center().x + inner.size.x * 0.03, base_y - inner.size.y * 0.18), Vector2(inner.size.x * 0.22, inner.size.y * 0.18)), RUST.lightened(0.1))
	draw_rect(inner, OUTLINE, false, 1.5)
	draw_rect(rect, OUTLINE, false, 3.0)


## The same meal delivered to the same unresponsive resident — untouched, a
## little steam still drawn rising, per the level brief's quiet horror beat.
func _draw_breakfast() -> void:
	var plate_y: float = -size.y * 0.2
	draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y * 0.15), Vector2(size.x, size.y * 0.15)), CREAM)
	draw_circle(Vector2(0.0, plate_y), size.y * 0.35, WHITE)
	draw_circle(Vector2(0.0, plate_y), size.y * 0.35, OUTLINE, false, 2.0)
	draw_circle(Vector2(0.0, plate_y), size.y * 0.24, CREAM.lightened(0.1))
	draw_circle(Vector2(0.0, plate_y), size.y * 0.14, GOLD)
	draw_circle(Vector2(0.0, plate_y), size.y * 0.14, OUTLINE, false, 1.5)
	# a small mug beside the plate
	var mug := Rect2(Vector2(size.y * 0.34, plate_y - size.y * 0.14), Vector2(size.y * 0.18, size.y * 0.18))
	draw_rect(mug, TEAL)
	draw_rect(mug, OUTLINE, false, 1.5)
	# faint drawn steam — never a motion effect, just a still graphic mark.
	for i in 2:
		var sx: float = -size.x * 0.06 + float(i) * size.x * 0.1
		draw_polyline(PackedVector2Array([
			Vector2(sx, plate_y - size.y * 0.32), Vector2(sx + 3.0, plate_y - size.y * 0.42),
			Vector2(sx - 2.0, plate_y - size.y * 0.5),
		]), Color(1.0, 1.0, 1.0, 0.5), 2.0)


func _draw_sign() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_line(Vector2.ZERO, Vector2(0.0, -h * 0.6), TEAL, 5.0)
	var board := Rect2(Vector2(-w * 0.5, -h), Vector2(w, h * 0.4))
	draw_rect(board, CREAM)
	draw_rect(board, OUTLINE, false, 2.0)
	if text != "":
		var font := ThemeDB.fallback_font
		var available: float = board.size.x - 8.0
		# depot-sign-text-cropped: a fixed 14px font silently clipped a long
		# all-caps label (e.g. "MAINTENANCE DEPOT") before it reached the
		# panel edge. Shrink the font — never below a still-legible floor —
		# until the whole authored word actually fits, instead of cropping it.
		var fsize := 14
		while fsize > 9 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x > available:
			fsize -= 1
		draw_string(font, board.position + Vector2(4.0, board.size.y * 0.65), text,
				HORIZONTAL_ALIGNMENT_LEFT, available, fsize, OUTLINE)


## The habitat ceiling's cloud projector: a small housing beaming a soft
## cloud pattern — placed as a landmark prop (e.g. A06's post-awakening
## ceiling), distinct from the far background sky's own faint cloud grid.
func _draw_cloud_projector() -> void:
	var r: float = size.x * 0.5
	# projector housing
	var housing := Rect2(Vector2(-r * 0.3, -r * 0.35), Vector2(r * 0.6, r * 0.35))
	draw_rect(housing, TEAL)
	draw_rect(housing, OUTLINE, false, 2.0)
	draw_circle(Vector2(0.0, 0.0), r * 0.1, CYAN)
	# AD-10 fix: projected clouds used to fill with SKY on a sky-colored
	# backdrop — invisible except for the outline hairline, reading as stray
	# debug circles rather than clouds. CREAM gives them a real, visible C11
	# fill against the sky (and still reads as "projected light", not a
	# solid prop, since it's a soft warm tint rather than the lawn/wall
	# palette used by solid scenery).
	draw_circle(Vector2(-r * 0.6, 0.15 * r), r * 0.6, CREAM)
	draw_circle(Vector2(r * 0.5, -r * 0.05), r * 0.7, CREAM)
	draw_circle(Vector2(0.0, r * 0.35), r * 0.55, CREAM)
	draw_circle(Vector2(-r * 0.6, 0.15 * r), r * 0.6, OUTLINE, false, 1.5)
	draw_circle(Vector2(r * 0.5, -r * 0.05), r * 0.7, OUTLINE, false, 1.5)
	draw_line(Vector2(0.0, 0.0), Vector2(0.0, r * 0.3), Color(1.0, 1.0, 1.0, 0.4), 3.0)


## A rounded depot doorway with a recessed teal frame and a warning
## threshold stripe — the maintenance depot's own entrance.
func _draw_depot_door() -> void:
	var rect := _rect_up(size.x, size.y)
	draw_rect(rect, TEAL)
	var arch_r: float = size.x * 0.5
	draw_arc(Vector2(rect.get_center().x, rect.position.y + arch_r), arch_r, PI, TAU, 10, TEAL, 3.0)
	draw_colored_polygon(PackedVector2Array([
		rect.position, Vector2(rect.position.x, rect.position.y + arch_r),
		Vector2(rect.end.x, rect.position.y + arch_r), Vector2(rect.end.x, rect.position.y),
	]), TEAL)
	draw_rect(rect, OUTLINE, false, 3.0)
	draw_line(rect.position + Vector2(0.0, size.y * 0.33), rect.position + Vector2(size.x, size.y * 0.33), OUTLINE, 2.0)
	draw_line(rect.position + Vector2(0.0, size.y * 0.66), rect.position + Vector2(size.x, size.y * 0.66), OUTLINE, 2.0)
	# yellow-black threshold stripe (shape cue, not color-only).
	var stripe := Rect2(Vector2(rect.position.x, -6.0), Vector2(size.x, 6.0))
	draw_rect(stripe, GOLD)
	var sx: float = stripe.position.x
	var flip := false
	while sx < stripe.end.x:
		if flip:
			draw_rect(Rect2(Vector2(sx, stripe.position.y), Vector2(minf(10.0, stripe.end.x - sx), stripe.size.y)), OUTLINE)
		sx += 10.0
		flip = not flip


func _draw_workbench() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2(-w * 0.5, -h), Vector2(w, h * 0.2)), CREAM)
	draw_rect(Rect2(Vector2(-w * 0.44, -h * 0.8), Vector2(0.12 * w, h * 0.8)), PEACH)
	draw_rect(Rect2(Vector2(w * 0.32, -h * 0.8), Vector2(0.12 * w, h * 0.8)), PEACH)
	# a couple of sorted spare parts on top (level brief: "neatly sorted
	# spare parts"), drawn small and low so they never read as pickups.
	draw_circle(Vector2(-w * 0.18, -h - 6.0), 6.0, RUST)
	draw_circle(Vector2(-w * 0.18, -h - 6.0), 6.0, OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(w * 0.04, -h - 12.0), Vector2(16.0, 10.0)), TEAL)
	draw_rect(Rect2(Vector2(w * 0.04, -h - 12.0), Vector2(16.0, 10.0)), OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(-w * 0.5, -h), Vector2(w, h * 0.2)), OUTLINE, false, 2.0)


## A quarantine guide rail: two posts, a top rail, and a warning chevron
## stripe on the mid-rail so it reads as "guide here" by shape alone.
func _draw_rail() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_line(Vector2(-w * 0.5, -h), Vector2(w * 0.5, -h), TEAL, 4.0)
	draw_line(Vector2(-w * 0.5, 0.0), Vector2(-w * 0.5, -h), TEAL, 4.0)
	draw_line(Vector2(w * 0.5, 0.0), Vector2(w * 0.5, -h), TEAL, 4.0)
	draw_line(Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5), TEAL, 3.0)
	var chevron := PackedVector2Array([
		Vector2(-w * 0.12, -h * 0.5 - 6.0), Vector2(0.0, -h * 0.5), Vector2(w * 0.12, -h * 0.5 - 6.0),
	])
	draw_polyline(chevron, GOLD, 2.5, false)


## A diagnostic ceiling panel with a small readout light — the quarantine
## exit's "readable diagnostic panels" and "artificial ceiling projection."
## AD-10 fix: this used to fill with plain SKY plus a lightened top-edge
## strip — the exact same "bright top band on a rect" cue block.gd's own
## GROUND/PLATFORM/depot-floor draws use for a walkable surface top, on a
## prop that floats at hero height and isn't walkable. Desaturated toward a
## cooler ceiling-metal tone (never the walkable-lawn/porch/depot-floor
## palette) with no top-edge band, so it can't be mistaken for a platform.
func _draw_panel() -> void:
	var rect := Rect2(-size * 0.5, size)
	var ceiling_fill: Color = SKY.darkened(0.22).lerp(Color("#8a8f92"), 0.35)
	draw_rect(rect, ceiling_fill)
	var readout := Rect2(rect.position + rect.size * 0.2, rect.size * 0.35)
	draw_rect(readout, TEAL)
	draw_rect(readout, OUTLINE, false, 1.5)
	draw_circle(readout.get_center(), minf(readout.size.x, readout.size.y) * 0.22, CYAN)
	draw_rect(rect, OUTLINE, false, 2.0)


## The broken perimeter service gate the hero climbs through to enter
## Sunnyvale: bent bars and a sagging hinge, framed by otherwise-intact
## posts, so the one damaged fixture reads clearly against a maintained
## neighborhood (level brief: "Nothing is abandoned-looking at first
## glance... a broken perimeter service gate").
func _draw_gate() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2(-w * 0.5 - 4.0, -h), Vector2(8.0, h)), CREAM)
	draw_rect(Rect2(Vector2(-w * 0.5 - 4.0, -h), Vector2(8.0, h)), OUTLINE, false, 2.0)
	draw_rect(Rect2(Vector2(w * 0.5 - 4.0, -h), Vector2(8.0, h)), CREAM)
	draw_rect(Rect2(Vector2(w * 0.5 - 4.0, -h), Vector2(8.0, h)), OUTLINE, false, 2.0)
	var bars: int = maxi(3, int(w / 20.0))
	for i in bars:
		var t: float = float(i) / float(bars - 1) if bars > 1 else 0.0
		var x0: float = lerp(-w * 0.42, w * 0.42, t)
		# the middle bars sag/bend outward — a clearly broken gate, not just
		# a plain fence; readable as damage by shape alone.
		var bend: float = sin(t * PI) * w * 0.16
		draw_line(Vector2(x0, -h), Vector2(x0 + bend, -h * 0.35), CREAM.darkened(0.05), 5.0)
		draw_line(Vector2(x0 + bend, -h * 0.35), Vector2(x0 + bend * 1.4, 0.0), CREAM.darkened(0.05), 5.0)
		draw_line(Vector2(x0, -h), Vector2(x0 + bend, -h * 0.35), OUTLINE, 1.5)
		draw_line(Vector2(x0 + bend, -h * 0.35), Vector2(x0 + bend * 1.4, 0.0), OUTLINE, 1.5)
	draw_line(Vector2(-w * 0.5, -h), Vector2(w * 0.5, -h), OUTLINE, 3.0)


## AD-12: a small ceiling-mounted alarm beacon (dome + mount), only ever
## placed by EnvironmentState's post-awakening `quarantine_visuals_path`
## group — it never toggles its own look, it's simply absent/present per
## story state, like every other quarantine-only prop.
func _draw_beacon() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2(-w * 0.18, -h), Vector2(w * 0.36, h * 0.3)), TEAL)
	draw_rect(Rect2(Vector2(-w * 0.18, -h), Vector2(w * 0.36, h * 0.3)), OUTLINE, false, 1.5)
	var dome_c := Vector2(0.0, -h * 0.7)
	var dome_r: float = w * 0.32
	draw_circle(dome_c, dome_r, RUST)
	draw_circle(dome_c, dome_r * 0.62, GOLD)
	draw_circle(dome_c, dome_r, OUTLINE, false, 2.0)
	# alternating warning wedges around the dome — a shape cue (not
	# color-only) so the beacon reads as "alarm" even without cyan/rust hue.
	for i in 6:
		var a0: float = TAU * float(i) / 6.0
		var a1: float = a0 + TAU / 12.0
		draw_arc(dome_c, dome_r + 3.0, a0, a1, 4, CYAN, 3.0)


## AD-12/A03 roof supports: a plain scaffold pillar (two vertical beams,
## cross braces, a footing) standing on the ground and rising to meet a
## floating platform's underside — "usable surfaces have visible supports."
## Non-colliding (Scenery is never on the world layer); the platform's own
## Block collision is untouched.
func _draw_support() -> void:
	var w: float = size.x
	var h: float = size.y
	if h <= 0.0:
		return
	var bw: float = clampf(w * 0.16, 5.0, 14.0)
	var beams := [-w * 0.5 + bw * 0.5, w * 0.5 - bw * 0.5]
	for bx in beams:
		draw_rect(Rect2(Vector2(bx - bw * 0.5, -h), Vector2(bw, h)), CREAM.darkened(0.08))
		draw_rect(Rect2(Vector2(bx - bw * 0.5, -h), Vector2(bw, h)), OUTLINE, false, 2.0)
	# horizontal cross braces at a roughly even spacing.
	var braces: int = maxi(1, int(h / 90.0))
	for i in braces:
		var t: float = (float(i) + 1.0) / float(braces + 1)
		var y: float = -h * t
		draw_line(Vector2(beams[0], y), Vector2(beams[1], y), TEAL, 3.0)
		# a light diagonal brace per segment reads as a built scaffold, not
		# a ladder.
		var y0: float = -h * (float(i) / float(braces + 1))
		draw_line(Vector2(beams[0], y0), Vector2(beams[1], y), TEAL.darkened(0.1), 2.0)
	# small footing so the base reads as planted, not just cut off.
	draw_rect(Rect2(Vector2(-w * 0.5, -10.0), Vector2(w, 10.0)), OUTLINE.lightened(0.1))
