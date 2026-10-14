extends RefCounted
## Level 2's structure look (v2 architecture kit, level-design/l02-alignment.md "Rules against the
## artificial look": "Everything is supported ... raised floors are boxed with fascia panels and
## vents (never a bare dark slab), ceilings and beams close every room"). Code-drawn stand-in until
## art Batch 8's painted architecture kits arrive. No class_name (import-cache rule): Block,
## Stairs and RoomSeam preload it by path.
##
## Block (scripts/world/block.gd) calls `role()` and `draw_block()` for its lab look; collision,
## size, position and kind are never touched, only drawing. Roles, for a block under the roof of
## an area whose `interior_look` is "lab" (LabSkins.in_lab), without a `fill_override`:
##   deck     a PLATFORM or GROUND block at most DECK_MAX_H tall: a catwalk deck with a glass or
##            steel railing along its back and visible supports (hanger rods up to the ceiling, or
##            slim columns down to the floor; Block.support picks, AUTO looks for what is there)
##   raised   a taller PLATFORM, or a GROUND block whose top is above its area's floor (local y 0):
##            the painted floor edge on top, then a panelled fascia (seams, vents, end trims) down
##            to a rust-orange hazard kick plate where it meets the area's floor
##   floor    a GROUND block at or below the area's floor: the painted floor edge, then a dim
##            sub-floor plenum (panels, a copper conduit) instead of a flat shadow
##   ceiling  a ROOF block: a slab with I-beams dropping under it, light troughs and a copper pipe
##   wall     a WALL block: a panelled wall face; Block.door_frame adds a doorway under it
## BACKSTOP and SCENERY_SOLID keep LabSkins' crates and range bench.
##
## Palette (C58 lab style frame): graphite, white composite, brushed steel, teal seams, the cold
## white walkable edge, plus the warm accents the user asked for (2026-10-14): matte copper trim
## and rust-orange hazard paint, mid or dark in value and never glowing (glowing amber stays for
## lamps and tells). Every walkable top keeps a full-width lit edge (Block's contract).
##
## Painted replacement hook: when LabSkins has the piece named in PIECES (e.g. "arch_catwalk"),
## that role draws the painted piece tiled across the block instead (the supports stay code-drawn
## until the kit brings its own), so Batch 8 only has to add the PNGs and manifest entries.

const LabSkins := preload("res://scripts/world/lab_skins.gd")
const Skins := preload("res://scripts/world/terrain_skins.gd")

const OUTLINE := Color("#05070B")
const EDGE := Color("#D8E6F0")
const BEVEL := Color("#5A718C")
const DEEP := Color("#0A0F18")
const GRAPHITE := Color("#18212C")
const GRAPHITE_DARK := Color("#0F151D")
const GRAPHITE_LIGHT := Color("#243040")
const PLENUM := Color("#0D131B")
## White composite, dimmed like LabSkins.DIM so it never clips under the lamps.
const COMPOSITE := Color("#7F8B9A")
const STEEL := Color("#8794A3")
const STEEL_DARK := Color("#46525F")
const SEAM_DARK := Color(0.0, 0.0, 0.0, 0.38)
const TEAL := Color("#3FE0D0")
const GLASS := Color(0.55, 0.8, 0.9, 0.09)
## Warm matte accents (never glowing).
const COPPER := Color("#8A5634")
const COPPER_DARK := Color("#5C3A25")
const RUST := Color("#6B3721")
const RUST_DARK := Color("#1F140E")

## Tallest block drawn as a catwalk deck (px).
const DECK_MAX_H := 40.0
## Railing height over a deck (0.48 H) and the spacing of its posts.
const RAIL_H := 46.0
const RAIL_POST := 110.0
## Supports: rods hang from a ceiling at most HANG_REACH above the deck (AUTO prefers them, they
## keep the lane under a deck clear), columns stand on a floor at most COLUMN_REACH below.
const HANG_REACH := 480.0
const COLUMN_REACH := 900.0
const SUPPORT_SPACING := 300.0
## Depth of the truss under a long supported deck.
const TRUSS_H := 12.0
## Kick plate height where a raised floor meets the floor.
const KICK_H := 18.0
## Fascia panel size targets.
const PANEL_W := 128.0
const PANEL_H := 112.0
## Ceiling beam spacing (in phase with global x, so neighbouring ceilings continue one rhythm).
const BEAM_SPACING := 320.0

## Role -> the painted LabSkins piece that replaces the code-drawn look when it exists.
const PIECES := {
	"deck": "arch_catwalk",
	"raised": "arch_fascia",
	"floor": "arch_subfloor",
	"ceiling": "arch_ceiling",
	"wall": "arch_wall",
	"door": "arch_door_frame",
}

## Block.Kind values (block.gd's enum; read here by number so this file never needs the class).
const K_GROUND := 0
const K_PLATFORM := 1
const K_WALL := 2
const K_ROOF := 3
## Block.Support values.
const S_AUTO := 0
const S_HANG := 1
const S_COLUMNS := 2
const S_NONE := 3
## Block.Railing values.
const R_AUTO := 0
const R_GLASS := 1
const R_STEEL := 2
const R_NONE := 3


# --- roles and lookups ------------------------------------------------------------------------

## The structure role of Block `b` ("" = keep its other look). See the header.
static func role(b: Node2D) -> String:
	if not LabSkins.in_lab(b):
		return ""
	var kind: int = int(b.get("kind"))
	var size: Vector2 = b.get("size")
	match kind:
		K_PLATFORM:
			return "deck" if size.y <= DECK_MAX_H else "raised"
		K_GROUND:
			if size.y <= DECK_MAX_H:
				return "deck"
			return "raised" if b.global_position.y < area_floor_y(b) - 0.5 else "floor"
		K_ROOF:
			return "ceiling"
		K_WALL:
			return "wall"
	return ""


## Global y of the owning AreaRoot's floor (its local y 0), or the block's own top without one.
static func area_floor_y(n: Node2D) -> float:
	var p: Node = n.get_parent()
	while p:
		if "area_id" in p and p is Node2D:
			return (p as Node2D).global_position.y
		p = p.get_parent()
	return n.global_position.y


## Every other terrain block's global rect and kind, as [Rect2, kind].
static func _others(b: Node2D) -> Array:
	var out: Array = []
	if not b.is_inside_tree():
		return out
	for n in b.get_tree().get_nodes_in_group("terrain_block"):
		if n == b or not n.has_method("get_rect_global"):
			continue
		out.append([n.get_rect_global(), int(n.get("kind"))])
	return out


## Global y of the nearest ceiling (a ROOF block's underside) above global point `p` within
## `reach`, or NAN.
static func ceiling_above(others: Array, p: Vector2, reach: float) -> float:
	var best: float = NAN
	for o in others:
		var r: Rect2 = o[0]
		if int(o[1]) != K_ROOF or p.x < r.position.x or p.x > r.end.x or r.end.y > p.y + 0.5:
			continue
		if p.y - r.end.y <= reach and (is_nan(best) or r.end.y > best):
			best = r.end.y
	return best


## Global y of the nearest top under global point `p` within `reach` (any block but a ROOF), or NAN.
static func floor_below(others: Array, p: Vector2, reach: float) -> float:
	var best: float = NAN
	for o in others:
		var r: Rect2 = o[0]
		if int(o[1]) == K_ROOF or p.x < r.position.x or p.x > r.end.x or r.position.y < p.y - 0.5:
			continue
		if r.position.y - p.y <= reach and (is_nan(best) or r.position.y < best):
			best = r.position.y
	return best


## The supports a deck block gets: {"mode": S_HANG/S_COLUMNS/S_NONE, "xs": local xs,
## "ends": local y each support reaches (the ceiling's underside, or the floor's top)}.
static func deck_supports(b: Node2D) -> Dictionary:
	var size: Vector2 = b.get("size")
	var mode: int = int(b.get("support")) if "support" in b else S_AUTO
	var out := {"mode": S_NONE, "xs": [], "ends": []}
	if mode == S_NONE:
		return out
	var others := _others(b)
	var xs: Array = []
	var inset: float = minf(28.0, size.x * 0.2)
	var n: int = maxi(1, roundi((size.x - 2.0 * inset) / SUPPORT_SPACING))
	for i in n + 1:
		xs.append(lerpf(inset, size.x - inset, float(i) / float(n)) if size.x > 2.0 * inset + 1.0 else size.x * 0.5)
		if size.x <= 2.0 * inset + 1.0:
			break
	var top: float = b.global_position.y
	var bottom: float = top + size.y
	var hang: Array = []
	var cols: Array = []
	for x in xs:
		var gx: float = b.global_position.x + float(x)
		hang.append(ceiling_above(others, Vector2(gx, top), HANG_REACH))
		cols.append(floor_below(others, Vector2(gx, bottom), COLUMN_REACH))
	var hang_ok: bool = hang.any(func(v): return not is_nan(v))
	var cols_ok: bool = cols.any(func(v): return not is_nan(v))
	if mode == S_AUTO:
		mode = S_HANG if hang_ok else (S_COLUMNS if cols_ok else S_NONE)
	var ends: Array = hang if mode == S_HANG else cols
	var keep_x: Array = []
	var keep_y: Array = []
	for i in xs.size():
		if not is_nan(ends[i]):
			keep_x.append(xs[i])
			keep_y.append(float(ends[i]) - top)
	if keep_x.is_empty():
		return out
	out["mode"] = mode
	out["xs"] = keep_x
	out["ends"] = keep_y
	return out


# --- the painted hook ---------------------------------------------------------------------------

## True when the painted piece for `role_name` exists (and LabSkins is enabled).
static func has_piece(role_name: String) -> bool:
	return PIECES.has(role_name) and LabSkins.has(PIECES[role_name])


## The painted piece tiled across `rect` at its own scale, its top row on rect's top, cropped to
## rect's height. In phase with global x `gx`.
static func draw_piece_tiled(c: CanvasItem, role_name: String, rect: Rect2, gx: float) -> void:
	var piece: String = PIECES[role_name]
	var e := LabSkins.entry(piece)
	var tex := LabSkins.texture(piece)
	var sc: float = float(e["scale"])
	var tw: float = float(e["size"][0])
	var th: float = minf(float(e["size"][1]), rect.size.y / sc)
	var x: float = rect.position.x
	var phase: float = fposmod(gx + rect.position.x, tw * sc)
	while x < rect.end.x - 0.01:
		var src_x: float = phase / sc
		var w: float = minf(tw - src_x, (rect.end.x - x) / sc)
		c.draw_texture_rect_region(tex, Rect2(Vector2(x, rect.position.y), Vector2(w * sc, th * sc)),
				Rect2(src_x, 0.0, w, th), LabSkins.DIM)
		x += w * sc
		phase = 0.0


# --- drawing --------------------------------------------------------------------------------------

## Draws block `b` (its canvas, top-left at the origin) in `role_name`.
static func draw_block(b: Node2D, role_name: String) -> void:
	var c := b as CanvasItem
	var size: Vector2 = b.get("size")
	var gx: float = b.global_position.x
	match role_name:
		"deck":
			_draw_deck(c, b, size, gx)
		"raised":
			var kick: float = clampf(area_floor_y(b) - b.global_position.y, 0.0, size.y)
			if int(b.get("kind")) == K_PLATFORM:
				kick = size.y   # a box sits on whatever is under it: the kick plate at its foot
			_draw_raised(c, size, gx, kick)
		"floor":
			_draw_floor(c, size, gx)
		"ceiling":
			_draw_ceiling(c, size, gx)
		"wall":
			_draw_wall(c, b, size, gx)


## The painted floor edge (terrain skin "depot_floor") over `size`, or a code-drawn steel edge.
## Returns the height of the band it drew.
static func _floor_band(c: CanvasItem, size: Vector2, gx: float) -> float:
	if Skins.has_skin("depot_floor"):
		var tex := Skins.texture(Skins.SKINS["depot_floor"]["tex"])
		var band_h: float = minf(size.y, (tex.get_height() - int(Skins.SKINS["depot_floor"]["edge"])) * Skins.ART)
		Skins.draw_block(c, "depot_floor", Vector2(size.x, band_h), gx, Vector2i.ZERO)
		return band_h
	var h: float = minf(size.y, 26.0)
	c.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, h)), GRAPHITE_LIGHT)
	lit_edge(c, size.x)
	return h


## The walkable top edge contract: a crisp full-width cold-white line with a lit bevel under it.
static func lit_edge(c: CanvasItem, w: float, y: float = 0.0) -> void:
	c.draw_rect(Rect2(Vector2(0.0, y + 2.0), Vector2(w, 3.0)), BEVEL)
	c.draw_rect(Rect2(Vector2(0.0, y), Vector2(w, 2.0)), EDGE)


## A catwalk deck: supports behind, then the railing, the slab with its copper-trimmed fascia,
## the truss under it, and the lit edge on top.
static func _draw_deck(c: CanvasItem, b: Node2D, size: Vector2, gx: float) -> void:
	var sup := deck_supports(b)
	var mode: int = sup["mode"]
	if mode == S_HANG:
		for i in sup["xs"].size():
			_hanger(c, float(sup["xs"][i]), float(sup["ends"][i]))
	elif mode == S_COLUMNS:
		for i in sup["xs"].size():
			_column(c, float(sup["xs"][i]), size.y + (TRUSS_H if size.x >= 200.0 else 0.0), float(sup["ends"][i]))
	var rail: int = int(b.get("railing")) if "railing" in b else R_AUTO
	if rail == R_AUTO:
		rail = R_GLASS if size.x >= 150.0 else R_NONE
	if rail != R_NONE:
		_railing(c, size.x, rail == R_GLASS)
	if size.x >= 200.0 and mode != S_NONE:
		_truss(c, size)
	if has_piece("deck"):
		draw_piece_tiled(c, "deck", Rect2(Vector2.ZERO, size), gx)
		lit_edge(c, size.x)
		return
	c.draw_rect(Rect2(Vector2.ZERO, size), GRAPHITE)
	var plate_h: float = minf(5.0, size.y)
	c.draw_rect(Rect2(Vector2(0.0, 0.0), Vector2(size.x, plate_h)), STEEL_DARK)
	if size.y >= 12.0:
		var fy: float = plate_h
		var fh: float = size.y - plate_h - 2.0
		c.draw_rect(Rect2(Vector2(0.0, fy), Vector2(size.x, fh)), GRAPHITE_LIGHT)
		c.draw_line(Vector2(0.0, fy + fh * 0.5 + 0.5), Vector2(size.x, fy + fh * 0.5 + 0.5), COPPER, 2.0)
		var x: float = fposmod(-gx, 48.0) + 24.0
		while x < size.x - 6.0:
			c.draw_circle(Vector2(x, fy + fh * 0.5 + 0.5), 1.6, COPPER_DARK)
			x += 48.0
	c.draw_rect(Rect2(Vector2(0.0, size.y - 2.0), Vector2(size.x, 2.0)), OUTLINE)
	for ex in [0.0, size.x - 3.0]:
		c.draw_rect(Rect2(Vector2(ex, 0.0), Vector2(3.0, size.y)), STEEL_DARK)
	lit_edge(c, size.x)


## A hanger rod from the deck at local x up to local y `top_y` (< 0): clevis, turnbuckle, anchor.
static func _hanger(c: CanvasItem, x: float, top_y: float) -> void:
	c.draw_line(Vector2(x + 1.5, 4.0), Vector2(x + 1.5, top_y), OUTLINE, 1.5)
	c.draw_line(Vector2(x, 4.0), Vector2(x, top_y), STEEL_DARK, 3.0)
	c.draw_line(Vector2(x - 1.0, 4.0), Vector2(x - 1.0, top_y), Color(STEEL, 0.4), 1.0)
	var tb: float = top_y * 0.35
	c.draw_rect(Rect2(Vector2(x - 3.0, tb - 7.0), Vector2(6.0, 14.0)), GRAPHITE_LIGHT)
	c.draw_rect(Rect2(Vector2(x - 3.0, tb - 7.0), Vector2(6.0, 14.0)), STEEL_DARK, false, 1.0)
	c.draw_rect(Rect2(Vector2(x - 8.0, top_y), Vector2(16.0, 5.0)), STEEL_DARK)
	c.draw_rect(Rect2(Vector2(x - 5.0, -3.0), Vector2(10.0, 7.0)), STEEL_DARK)


## A slim column from local y `from_y` (under the deck) down to local y `to_y` (the floor's top),
## with knee braces under the deck and a bolted base plate.
static func _column(c: CanvasItem, x: float, from_y: float, to_y: float) -> void:
	if to_y - from_y < 6.0:
		return
	c.draw_rect(Rect2(Vector2(x - 5.0, from_y), Vector2(10.0, to_y - from_y)), GRAPHITE_LIGHT)
	c.draw_line(Vector2(x - 4.0, from_y), Vector2(x - 4.0, to_y - 4.0), Color(STEEL, 0.35), 1.0)
	c.draw_line(Vector2(x + 5.0, from_y), Vector2(x + 5.0, to_y), OUTLINE, 1.5)
	c.draw_line(Vector2(x - 5.0, from_y), Vector2(x - 5.0, to_y), OUTLINE, 1.0)
	var k: float = minf(16.0, (to_y - from_y) * 0.4)
	for s in [-1.0, 1.0]:
		c.draw_line(Vector2(x + s * 5.0, from_y + k), Vector2(x + s * (5.0 + k), from_y), STEEL_DARK, 2.0)
	c.draw_rect(Rect2(Vector2(x - 11.0, to_y - 5.0), Vector2(22.0, 5.0)), STEEL_DARK)
	c.draw_circle(Vector2(x - 7.0, to_y - 2.5), 1.5, COPPER)
	c.draw_circle(Vector2(x + 7.0, to_y - 2.5), 1.5, COPPER)


## The truss under a long deck: a bottom chord TRUSS_H below and zigzag diagonals.
static func _truss(c: CanvasItem, size: Vector2) -> void:
	var y0: float = size.y
	var y1: float = size.y + TRUSS_H
	c.draw_line(Vector2(6.0, y1), Vector2(size.x - 6.0, y1), STEEL_DARK, 2.0)
	var x: float = 6.0
	var up := true
	while x < size.x - 6.0:
		var nx: float = minf(x + 24.0, size.x - 6.0)
		c.draw_line(Vector2(x, y1 if up else y0), Vector2(nx, y0 if up else y1), Color(STEEL_DARK, 0.9), 1.5)
		x = nx
		up = not up


## A railing along the deck's back: posts, a top rail, glass panels (or a steel mid rail).
static func _railing(c: CanvasItem, w: float, glass: bool) -> void:
	var n: int = maxi(1, roundi((w - 12.0) / RAIL_POST))
	var x0: float = 6.0
	var x1: float = w - 6.0
	var top: float = -RAIL_H
	for i in n:
		var a: float = lerpf(x0, x1, float(i) / float(n))
		var bx: float = lerpf(x0, x1, float(i + 1) / float(n))
		if glass:
			c.draw_rect(Rect2(Vector2(a + 3.0, top + 5.0), Vector2(bx - a - 6.0, RAIL_H - 8.0)), GLASS)
			c.draw_line(Vector2(a + 3.0, top + 5.0), Vector2(bx - 3.0, top + 5.0), Color(EDGE, 0.22), 1.0)
			c.draw_line(Vector2(a + 6.0, top + 9.0), Vector2(a + 18.0, -6.0), Color(EDGE, 0.08), 3.0)
		else:
			c.draw_line(Vector2(a, top * 0.5), Vector2(bx, top * 0.5), STEEL_DARK, 2.0)
	for i in n + 1:
		var px: float = lerpf(x0, x1, float(i) / float(n))
		c.draw_line(Vector2(px, 0.0), Vector2(px, top), STEEL_DARK, 3.0)
		c.draw_line(Vector2(px - 1.0, 0.0), Vector2(px - 1.0, top), Color(STEEL, 0.4), 1.0)
	c.draw_line(Vector2(x0 - 2.0, top), Vector2(x1 + 2.0, top), OUTLINE, 5.0)
	c.draw_line(Vector2(x0 - 2.0, top), Vector2(x1 + 2.0, top), STEEL_DARK, 3.0)
	c.draw_line(Vector2(x0 - 2.0, top - 1.0), Vector2(x1 + 2.0, top - 1.0), Color(STEEL, 0.5), 1.0)


## A raised floor or box: the painted floor edge, the fascia down to `kick` (local y), the kick
## plate there, and (when the block reaches below the floor) the floor continuing under it.
static func _draw_raised(c: CanvasItem, size: Vector2, gx: float, kick: float) -> void:
	c.draw_rect(Rect2(Vector2.ZERO, size), DEEP)
	var band: float = _floor_band(c, size, gx)
	var face := Rect2(Vector2(0.0, band), Vector2(size.x, maxf(kick - band, 0.0)))
	if face.size.y > 2.0:
		if has_piece("raised"):
			draw_piece_tiled(c, "raised", face, gx)
		else:
			fascia(c, face, gx)
	if kick < size.y - 0.5:
		# The floor it stands on runs on under it (its lit edge dimmed: nobody walks there).
		c.draw_set_transform(Vector2(0.0, kick))
		_draw_floor(c, Vector2(size.x, size.y - kick), gx)
		c.draw_set_transform(Vector2.ZERO)
		c.draw_rect(Rect2(Vector2(0.0, kick), Vector2(size.x, 5.0)), Color(GRAPHITE_DARK, 0.7))
	c.draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, minf(kick, size.y))), OUTLINE, false, 2.0)
	lit_edge(c, size.x)


## A panelled fascia over `r`: graphite panels with seams and bolts, vents and small fittings,
## brushed-steel end trims, a teal reveal under the top, and (when `kick_plate`) a rust-orange
## hazard kick plate along its bottom.
static func fascia(c: CanvasItem, r: Rect2, gx: float, kick_plate: bool = true) -> void:
	c.draw_rect(r, GRAPHITE)
	var kp: bool = kick_plate and r.size.y >= KICK_H + 20.0
	var body := Rect2(r.position, Vector2(r.size.x, r.size.y - (KICK_H if kp else 0.0)))
	# The teal reveal under the floor edge, then its shadow.
	c.draw_rect(Rect2(r.position, Vector2(r.size.x, 3.0)), SEAM_DARK)
	if r.size.y > 10.0:
		c.draw_line(r.position + Vector2(0.0, 4.0), r.position + Vector2(r.size.x, 4.0), Color(TEAL, 0.28), 1.5)
	var cols: int = maxi(1, roundi(body.size.x / PANEL_W))
	var rows: int = maxi(1, roundi((body.size.y - 6.0) / PANEL_H))
	var pw: float = body.size.x / float(cols)
	var ph: float = (body.size.y - 6.0) / float(rows)
	for j in rows:
		for i in cols:
			var p := Rect2(body.position + Vector2(float(i) * pw, 6.0 + float(j) * ph), Vector2(pw, ph))
			_panel(c, p, int(floorf((gx + p.position.x) / 37.0)) + j * 7)
	# Brushed-steel end trims.
	if r.size.x >= 16.0:
		for ex in [r.position.x, r.end.x - 4.0]:
			c.draw_rect(Rect2(Vector2(ex, r.position.y), Vector2(4.0, r.size.y)), STEEL_DARK)
			c.draw_line(Vector2(ex + 1.0, r.position.y), Vector2(ex + 1.0, r.end.y), Color(STEEL, 0.45), 1.0)
	if kp:
		kick_plate(c, Rect2(Vector2(r.position.x, r.end.y - KICK_H), Vector2(r.size.x, KICK_H)), gx)


## One fascia panel: an inset frame, corner bolts, and (by `variant`) a louvred vent, a composite
## label plate or a dim teal status light.
static func _panel(c: CanvasItem, p: Rect2, variant: int) -> void:
	var inner := p.grow(-3.0)
	if inner.size.x < 6.0 or inner.size.y < 6.0:
		return
	c.draw_line(Vector2(p.position.x, p.position.y), Vector2(p.position.x, p.end.y), SEAM_DARK, 2.0)
	c.draw_line(inner.position, Vector2(inner.end.x, inner.position.y), Color(STEEL, 0.14), 1.0)
	c.draw_line(inner.position, Vector2(inner.position.x, inner.end.y), Color(STEEL, 0.10), 1.0)
	c.draw_line(Vector2(inner.position.x, inner.end.y), inner.end, SEAM_DARK, 1.0)
	c.draw_line(Vector2(p.position.x, p.end.y), p.end, SEAM_DARK, 2.0)
	if inner.size.x >= 24.0 and inner.size.y >= 24.0:
		for q in [inner.position + Vector2(4.0, 4.0), Vector2(inner.end.x - 4.0, inner.position.y + 4.0),
				Vector2(inner.position.x + 4.0, inner.end.y - 4.0), inner.end - Vector2(4.0, 4.0)]:
			c.draw_circle(q, 1.4, STEEL_DARK)
	var pick: int = posmod(variant * 2654435761, 7)
	if pick <= 1 and inner.size.x >= 40.0 and inner.size.y >= 36.0:
		# Louvred vent, low in the panel.
		var vw: float = minf(inner.size.x * 0.6, 72.0)
		var vh: float = minf(inner.size.y * 0.4, 30.0)
		var v := Rect2(Vector2(inner.get_center().x - vw * 0.5, inner.end.y - vh - 8.0), Vector2(vw, vh))
		c.draw_rect(v, GRAPHITE_DARK)
		var y: float = v.position.y + 3.0
		while y < v.end.y - 2.0:
			c.draw_line(Vector2(v.position.x + 2.0, y), Vector2(v.end.x - 2.0, y), STEEL_DARK, 1.5)
			y += 5.0
		c.draw_rect(v, OUTLINE, false, 1.0)
	elif pick == 2 and inner.size.x >= 40.0 and inner.size.y >= 30.0:
		# A white-composite label plate with a dark text bar.
		var lp := Rect2(inner.position + Vector2(10.0, 10.0), Vector2(minf(30.0, inner.size.x - 20.0), 9.0))
		c.draw_rect(lp, COMPOSITE)
		c.draw_rect(Rect2(lp.position + Vector2(3.0, 3.0), Vector2(lp.size.x * 0.6, 2.0)), GRAPHITE_DARK)
	elif pick == 3 and inner.size.x >= 30.0 and inner.size.y >= 30.0:
		c.draw_circle(Vector2(inner.end.x - 10.0, inner.position.y + 10.0), 2.0, Color(TEAL, 0.55))


## Rust-orange hazard paint (matte) with dark diagonal stripes, a copper trim on top.
static func kick_plate(c: CanvasItem, r: Rect2, gx: float) -> void:
	c.draw_rect(r, RUST)
	var period: float = 18.0
	var x: float = r.position.x - fposmod(gx + r.position.x, period) - r.size.y
	while x < r.end.x:
		var a: float = maxf(x, r.position.x)
		var poly := PackedVector2Array()
		# A stripe from (x, bottom) leaning right to (x + h, top), 7 px wide, clipped to r.
		var pts := [Vector2(x, r.end.y), Vector2(x + 7.0, r.end.y), Vector2(x + 7.0 + r.size.y, r.position.y),
				Vector2(x + r.size.y, r.position.y)]
		for pt in pts:
			poly.append(Vector2(clampf(pt.x, r.position.x, r.end.x), pt.y))
		if a < r.end.x:
			c.draw_colored_polygon(poly, RUST_DARK)
		x += period
	c.draw_rect(Rect2(r.position, Vector2(r.size.x, 2.0)), COPPER)
	c.draw_rect(Rect2(Vector2(r.position.x, r.end.y - 2.0), Vector2(r.size.x, 2.0)), OUTLINE)


## A floor at the area's level: the painted edge, then a dim sub-floor plenum with seams, a copper
## conduit and grilles, fading into the shadow.
static func _draw_floor(c: CanvasItem, size: Vector2, gx: float) -> void:
	c.draw_rect(Rect2(Vector2.ZERO, size), DEEP)
	var band: float = _floor_band(c, size, gx)
	if size.y - band < 10.0:
		return
	var depth: float = minf(size.y - band, 150.0)
	var r := Rect2(Vector2(0.0, band), Vector2(size.x, depth))
	if has_piece("floor"):
		draw_piece_tiled(c, "floor", r, gx)
		return
	c.draw_rect(r, PLENUM)
	c.draw_rect(Rect2(r.position, Vector2(r.size.x, 3.0)), SEAM_DARK)
	# A copper conduit with clips, then panel seams in phase with global x.
	var cy: float = r.position.y + 14.0
	if depth > 24.0:
		c.draw_line(Vector2(0.0, cy), Vector2(size.x, cy), COPPER_DARK, 4.0)
		c.draw_line(Vector2(0.0, cy - 1.5), Vector2(size.x, cy - 1.5), Color(COPPER, 0.6), 1.0)
	var x: float = fposmod(-gx, 160.0)
	var i: int = int(floorf(gx / 160.0))
	while x < size.x:
		if x > 2.0:
			c.draw_line(Vector2(x, r.position.y + 4.0), Vector2(x, r.end.y), SEAM_DARK, 2.0)
		if depth > 24.0:
			c.draw_rect(Rect2(Vector2(x + 76.0, cy - 3.0), Vector2(5.0, 6.0)), STEEL_DARK)
		if posmod(i, 3) == 1 and depth > 60.0 and x + 120.0 < size.x:
			var g := Rect2(Vector2(x + 40.0, r.position.y + 30.0), Vector2(80.0, 18.0))
			c.draw_rect(g, GRAPHITE_DARK)
			var gy: float = g.position.y + 3.0
			while gy < g.end.y - 1.0:
				c.draw_line(Vector2(g.position.x + 2.0, gy), Vector2(g.end.x - 2.0, gy), Color(STEEL_DARK, 0.7), 1.0)
				gy += 4.0
		x += 160.0
		i += 1
	# Fade into the shadow mass below.
	for k in 4:
		var fy: float = r.end.y - 40.0 + float(k) * 10.0
		c.draw_rect(Rect2(Vector2(0.0, fy), Vector2(size.x, 10.0)), Color(DEEP, 0.25 * float(k + 1)))


## A ceiling: the slab, a copper pipe run under it, I-beams dropping below, and recessed light
## troughs with a soft downward spill between the beams (everything in phase with global x).
static func _draw_ceiling(c: CanvasItem, size: Vector2, gx: float) -> void:
	c.draw_rect(Rect2(Vector2.ZERO, size), Color("#0B1118"))
	if has_piece("ceiling"):
		draw_piece_tiled(c, "ceiling", Rect2(Vector2.ZERO, size), gx)
		return
	var bot: float = size.y
	c.draw_rect(Rect2(Vector2(0.0, bot - 8.0), Vector2(size.x, 8.0)), GRAPHITE_LIGHT)
	c.draw_line(Vector2(0.0, bot - 0.5), Vector2(size.x, bot - 0.5), Color(STEEL, 0.25), 1.0)
	# Copper pipe under the slab, with hanger brackets.
	var py: float = bot + 9.0
	c.draw_line(Vector2(0.0, py), Vector2(size.x, py), COPPER_DARK, 6.0)
	c.draw_line(Vector2(0.0, py - 2.0), Vector2(size.x, py - 2.0), Color(COPPER, 0.7), 1.5)
	var x: float = fposmod(-gx, 160.0)
	while x < size.x:
		c.draw_rect(Rect2(Vector2(x - 2.0, bot), Vector2(4.0, 13.0)), STEEL_DARK)
		x += 160.0
	# Light troughs halfway between beams.
	x = fposmod(-gx - BEAM_SPACING * 0.5, BEAM_SPACING)
	while x < size.x + 60.0:
		var t := Rect2(Vector2(x - 46.0, bot - 2.0), Vector2(92.0, 7.0))
		c.draw_rect(t, GRAPHITE_DARK)
		c.draw_rect(Rect2(t.position + Vector2(6.0, 3.0), Vector2(t.size.x - 12.0, 3.0)), EDGE)
		for k in 3:
			var gw: float = 80.0 + float(k) * 50.0
			var gh: float = 16.0 + float(k) * 22.0
			c.draw_rect(Rect2(Vector2(x - gw * 0.5, bot + 5.0), Vector2(gw, gh)), Color(EDGE, 0.05 - float(k) * 0.012))
		x += BEAM_SPACING
	# I-beams dropping under the slab.
	x = fposmod(-gx, BEAM_SPACING)
	while x < size.x + 20.0:
		var drop: float = 30.0
		c.draw_rect(Rect2(Vector2(x - 6.0, bot - 8.0), Vector2(12.0, drop + 8.0)), GRAPHITE_LIGHT)
		c.draw_rect(Rect2(Vector2(x - 14.0, bot + drop - 5.0), Vector2(28.0, 5.0)), STEEL_DARK)
		c.draw_line(Vector2(x - 14.0, bot + drop - 5.0), Vector2(x + 14.0, bot + drop - 5.0), Color(STEEL, 0.45), 1.0)
		c.draw_line(Vector2(x + 6.0, bot - 8.0), Vector2(x + 6.0, bot + drop - 5.0), OUTLINE, 1.5)
		c.draw_circle(Vector2(x, bot + 4.0), 1.5, COPPER)
		x += BEAM_SPACING


## A wall: panelled face with seams, end trims and a teal seam light; a lit edge on its top unless
## a ceiling closes it; `door_frame` adds a doorway under it (RoomSeam's drawing).
static func _draw_wall(c: CanvasItem, b: Node2D, size: Vector2, gx: float) -> void:
	if has_piece("wall"):
		draw_piece_tiled(c, "wall", Rect2(Vector2.ZERO, size), gx)
	else:
		wall_face(c, Rect2(Vector2.ZERO, size), gx)
	var others := _others(b)
	var top := b.global_position
	var closed := false
	for o in others:
		# A block sitting on its top, or a ceiling beside it at its top's height (a pier hanging
		# from the ceiling): nobody stands there, so no lit edge.
		var r: Rect2 = o[0]
		var beside: bool = r.position.x <= top.x + size.x + 1.0 and r.end.x >= top.x - 1.0
		if beside and (absf(r.end.y - top.y) < 1.0
				or (int(o[1]) == K_ROOF and r.position.y <= top.y + 1.0 and r.end.y > top.y)):
			closed = true
			break
	if not closed:
		lit_edge(c, size.x)
	if "door_frame" in b and bool(b.get("door_frame")):
		var fl: float = floor_below(others, Vector2(top.x + size.x * 0.5, top.y + size.y), 2000.0)
		if not is_nan(fl):
			doorway(c, size.x * 0.5, size.y, fl - top.y, size.x, int(b.get("door_icon")) if "door_icon" in b else 0)


## A panelled wall face over `r`.
static func wall_face(c: CanvasItem, r: Rect2, gx: float) -> void:
	c.draw_rect(r, GRAPHITE)
	var y: float = r.position.y + 96.0
	while y < r.end.y - 4.0:
		c.draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), SEAM_DARK, 2.0)
		c.draw_line(Vector2(r.position.x, y + 1.5), Vector2(r.end.x, y + 1.5), Color(STEEL, 0.08), 1.0)
		y += 96.0
	var x: float = r.position.x + fposmod(-(gx + r.position.x), 64.0)
	while x < r.end.x - 4.0:
		if x > r.position.x + 4.0:
			c.draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), SEAM_DARK, 1.5)
		x += 64.0
	if r.size.x >= 30.0:
		c.draw_line(Vector2(r.get_center().x, r.position.y + 12.0), Vector2(r.get_center().x, r.end.y - 12.0),
				Color(TEAL, 0.22), 1.5)
	for ex in [r.position.x, r.end.x - 3.0]:
		c.draw_rect(Rect2(Vector2(ex, r.position.y), Vector2(3.0, r.size.y)), STEEL_DARK)
	c.draw_rect(r, OUTLINE, false, 2.0)


# --- doorways (RoomSeam and Block.door_frame) ------------------------------------------------

## Icons for a doorway's lit sign panel (RoomSeam.icon, Block.door_icon).
enum Icon { NONE, ARROW, LAB, RANGE, KENNEL, DRONE, CELLS, LATTICE, LIFT, STAIRS, HAZARD }

## A doorway under a pier: the door leaf slid up into the lintel (hazard-striped bottom edge),
## the head light, two slim jambs down to the floor, a threshold plate and, when `icon` is set, a
## lit sign panel on the pier. `cx`: the opening's centre x; `lintel_y`: the pier's underside;
## `floor_y`: the floor's top; `pier_w`: the wall's thickness. Local coordinates of `c`.
static func doorway(c: CanvasItem, cx: float, lintel_y: float, floor_y: float, pier_w: float, icon: int = 0) -> void:
	var hw: float = pier_w * 0.5
	if has_piece("door"):
		var e := LabSkins.entry(PIECES["door"])
		var sc: float = (floor_y - lintel_y) / float(e["size"][1])
		LabSkins.draw_rows(c, PIECES["door"], 0.0, float(e["size"][1]), lintel_y, sc, LabSkins.DIM, false, cx)
		return
	# The retracted door leaf under the lintel.
	var leaf := Rect2(Vector2(cx - hw, lintel_y), Vector2(pier_w, 18.0))
	c.draw_rect(leaf, GRAPHITE_LIGHT)
	kick_plate(c, Rect2(Vector2(leaf.position.x, leaf.end.y - 7.0), Vector2(leaf.size.x, 7.0)), cx)
	c.draw_rect(leaf, OUTLINE, false, 1.5)
	# The opening's depth: the wall's thickness darkens the room seen through it (behind Dave),
	# lightest under the head light.
	var op := Rect2(Vector2(cx - hw, leaf.end.y), Vector2(pier_w, floor_y - leaf.end.y))
	c.draw_rect(op, Color(GRAPHITE_DARK, 0.45))
	c.draw_rect(Rect2(op.position, Vector2(op.size.x, minf(60.0, op.size.y))), Color(EDGE, 0.04))
	c.draw_rect(Rect2(Vector2(cx - hw + 4.0, leaf.end.y), Vector2(pier_w - 8.0, 2.0)), Color(EDGE, 0.75))
	# Jambs: the frame's two posts, graphite with a steel face and a few dim teal guide lights.
	for s in [-1.0, 1.0]:
		var jx: float = cx + s * (hw + 6.0)
		var jr := Rect2(Vector2(jx - 6.0, leaf.position.y), Vector2(12.0, floor_y - leaf.position.y))
		c.draw_rect(jr, GRAPHITE_LIGHT)
		c.draw_rect(Rect2(jr.position + Vector2(0.0 if s < 0.0 else 8.0, 0.0), Vector2(4.0, jr.size.y)), STEEL_DARK)
		c.draw_line(jr.position + Vector2(2.0 if s < 0.0 else 9.0, 0.0), Vector2(jr.position.x + (2.0 if s < 0.0 else 9.0), jr.end.y),
				Color(STEEL, 0.45), 1.0)
		c.draw_rect(jr, OUTLINE, false, 1.5)
		var gy: float = floor_y - 30.0
		while gy > leaf.end.y + 20.0:
			c.draw_circle(Vector2(jx, gy), 1.5, Color(TEAL, 0.55))
			gy -= 44.0
	# Threshold plate.
	c.draw_rect(Rect2(Vector2(cx - hw - 12.0, floor_y - 4.0), Vector2(pier_w + 24.0, 4.0)), STEEL_DARK)
	if icon != Icon.NONE:
		sign_panel(c, Vector2(cx, lintel_y - 26.0), icon)


## A lit sign panel centred on `at` (36 x 26 px) with an abstract icon in teal and white.
static func sign_panel(c: CanvasItem, at: Vector2, icon: int) -> void:
	var r := Rect2(at - Vector2(18.0, 13.0), Vector2(36.0, 26.0))
	c.draw_rect(r.grow(2.0), OUTLINE)
	c.draw_rect(r, Color("#0E2A30"))
	c.draw_rect(r, Color(TEAL, 0.55), false, 1.0)
	var col := Color(TEAL.lightened(0.35), 0.95)
	var w := Color(EDGE, 0.9)
	var o := at
	match icon:
		Icon.ARROW:
			c.draw_polyline(PackedVector2Array([o + Vector2(-6, -7), o + Vector2(3, 0), o + Vector2(-6, 7)]), col, 2.5)
			c.draw_line(o + Vector2(-10, 0), o + Vector2(3, 0), w, 1.5)
		Icon.LAB:
			c.draw_polyline(PackedVector2Array([o + Vector2(-3, -9), o + Vector2(-3, -2), o + Vector2(-8, 8),
					o + Vector2(8, 8), o + Vector2(3, -2), o + Vector2(3, -9)]), col, 2.0)
			c.draw_line(o + Vector2(-6, 4), o + Vector2(6, 4), w, 1.5)
		Icon.RANGE:
			c.draw_arc(o, 8.0, 0.0, TAU, 20, col, 2.0)
			c.draw_line(o + Vector2(-11, 0), o + Vector2(11, 0), w, 1.0)
			c.draw_line(o + Vector2(0, -11), o + Vector2(0, 11), w, 1.0)
		Icon.KENNEL:
			c.draw_circle(o + Vector2(0, 4), 4.5, col)
			for p in [Vector2(-7, -2), Vector2(-3, -7), Vector2(3, -7), Vector2(7, -2)]:
				c.draw_circle(o + p, 2.0, col)
		Icon.DRONE:
			c.draw_rect(Rect2(o - Vector2(4, 3), Vector2(8, 6)), col)
			for p in [Vector2(-9, -5), Vector2(9, -5)]:
				c.draw_line(o + p + Vector2(-5, 0), o + p + Vector2(5, 0), w, 1.5)
				c.draw_line(o + Vector2(0, -1), o + p, col, 1.0)
		Icon.CELLS:
			for i in 3:
				for j in 2:
					c.draw_rect(Rect2(o + Vector2(-11 + i * 8, -8 + j * 9), Vector2(6, 7)), col, false, 1.5)
		Icon.LATTICE:
			var pts := [o + Vector2(0, -8), o + Vector2(-9, 6), o + Vector2(9, 6), o + Vector2(0, 1)]
			for a in pts.size():
				for b2 in range(a + 1, pts.size()):
					c.draw_line(pts[a], pts[b2], Color(col, 0.6), 1.0)
			for p in pts:
				c.draw_circle(p, 2.2, w)
		Icon.LIFT:
			c.draw_colored_polygon(PackedVector2Array([o + Vector2(-5, -2), o + Vector2(0, -9), o + Vector2(5, -2)]), col)
			c.draw_colored_polygon(PackedVector2Array([o + Vector2(-5, 2), o + Vector2(0, 9), o + Vector2(5, 2)]), w)
		Icon.STAIRS:
			c.draw_polyline(PackedVector2Array([o + Vector2(-10, 8), o + Vector2(-4, 8), o + Vector2(-4, 2),
					o + Vector2(2, 2), o + Vector2(2, -4), o + Vector2(8, -4), o + Vector2(8, -9)]), col, 2.0)
		Icon.HAZARD:
			c.draw_polyline(PackedVector2Array([o + Vector2(0, -9), o + Vector2(10, 8), o + Vector2(-10, 8),
					o + Vector2(0, -9)]), col, 2.0)
			c.draw_line(o + Vector2(0, -3), o + Vector2(0, 3), w, 2.0)
			c.draw_circle(o + Vector2(0, 6), 1.2, w)
