extends TestCase
## The painted foreground (Sheet 7, 2026-10-07): the user's foreground sheet is
## fourteen near-black silhouettes (hedges with their grass tufts, railings,
## benches, bollards, loose grass), cut apart by `import_pixel_sheet.py
## foreground`. `scripts/world/visuals/foreground_layer.gd` composes them into a
## sparse row along the bottom edge of the screen of each outdoor area (A01,
## A02, A03, A04 and A06; not the depot), from a deterministic seed per area:
## wide gaps, never the same kind of piece twice in a row, an occasional mirrored
## piece. The row slides past faster than the camera (PARALLAX), on its own
## CanvasLayer above the world and below the night overlay and the HUD, drawn
## nearest-filtered at whole screen pixels per art pixel, and draws nothing when
## its PNGs are missing.

const FG := preload("res://scripts/world/visuals/foreground_layer.gd")
const NightOverlay := preload("res://scripts/world/night_overlay.gd")
const ZOOM := 1.2
const VIEW := Vector2(1280.0, 720.0)
## The tallest a piece may be: the bottom 12% of a 720p view.
const BAND := 0.12
const OUTDOOR := [0, 1, 2, 3, 5]


func run() -> void:
	_pieces()
	_composition()
	await _missing_art()
	await _areas()


## Every piece has its art as a true pixel grid: a hard 1-bit alpha, almost black
## (a faint cool rim along the tops is the only lighter pixel), a hedge about
## 70 to 110 world px wide and nothing taller than the bottom 12% of the view.
func _pieces() -> void:
	check_eq(FG.PIECES.size(), 14, "the sheet gives fourteen pieces")
	var tallest := 0.0
	for p in FG.PIECES:
		var tex: Texture2D = FG.texture_for(p)
		check(tex != null, "%s has its art" % p)
		if tex == null:
			continue
		var img: Image = tex.get_image()
		var soft := 0
		var lit := 0
		var opaque := 0
		var peak := 0.0
		for y in img.get_height():
			for x in img.get_width():
				var c: Color = img.get_pixel(x, y)
				if c.a > 0.0 and c.a < 1.0:
					soft += 1
				if c.a >= 1.0:
					opaque += 1
					peak = maxf(peak, maxf(c.r, maxf(c.g, c.b)))
					if c.b > 0.15:
						lit += 1
		check_eq(soft, 0, "%s is a true pixel grid (no soft alpha)" % p)
		check(peak <= 0.4, "%s stays almost black (brightest channel %.2f)" % [p, peak])
		check(lit > 0 and lit * 2 < opaque, "%s has only a faint rim lit on its upward edges, a dark body (%d of %d pixels)" % [p, lit, opaque])
		var h_world: float = tex.get_height() * FG.ART_WORLD
		tallest = maxf(tallest, h_world)
		check(h_world <= 90.0, "%s is no taller than 90 world px (%.0f)" % [p, h_world])
		var h_screen: float = float(tex.get_height() * FG.pixel_scale(ZOOM))
		check(h_screen <= VIEW.y * BAND, "%s stays in the bottom 12%% of the view (%.0f of %.0f px)" % [p, h_screen, VIEW.y * BAND])
	check(tallest >= 30.0, "and the tallest is still a real foreground object (%.0f world px)" % tallest)
	for p in ["hedge_a", "hedge_b", "hedge_c"]:
		var w: float = (FG.texture_for(p) as Texture2D).get_width() * FG.ART_WORLD
		check(w >= 70.0 and w <= 130.0, "%s is a hedge's width (%.0f world px)" % [p, w])
	check_eq(FG.pixel_scale(ZOOM), 3, "an art pixel is 3 whole screen pixels at the game's zoom 1.2")
	check(FG.ART_WORLD > 1.5, "the foreground is drawn larger than the play plane's 1.5 world px per art pixel")
	check(FG.PARALLAX > 1.0, "and slides past faster than the camera")
	check(FG.LAYER > 0 and FG.LAYER < NightOverlay.LAYER and NightOverlay.LAYER < 15,
			"on a layer above the world and below the night overlay (5) and the HUD (15)")


func _sizes() -> Dictionary:
	var sizes := {}
	for p in FG.PIECES:
		var tex: Texture2D = FG.texture_for(p)
		if tex != null:
			sizes[p] = Vector2i(tex.get_width(), tex.get_height())
	return sizes


## The composition itself: deterministic, per-area, mostly empty, never the same
## piece or kind twice in a row, mirrored now and then, margins at both ends.
func _composition() -> void:
	var sizes := _sizes()
	var ids := ["L01-A01", "L01-A02", "L01-A03", "L01-A04", "L01-A06"]
	var seeds := {}
	for id in ids:
		seeds[FG.area_seed(id, 0.0)] = id
	check_eq(seeds.size(), ids.size(), "every outdoor area has its own seed")
	check_eq(FG.area_seed("L01-A02", 0.0), FG.area_seed("L01-A02", 3400.0), "a seed follows the area's id, not where it stands")
	var widths := [3400.0, 6600.0, 7050.0, 7800.0, 6200.0]
	var starts := [0.0, 3400.0, 10000.0, 17050.0, 27550.0]
	var all_pieces := {}
	var flips := 0
	var count := 0
	for i in ids.size():
		var u0: float = FG.PARALLAX * starts[i]
		var u1: float = FG.PARALLAX * (starts[i] + widths[i])
		var row: Array = FG.layout(FG.area_seed(ids[i], starts[i]), u0, u1, sizes)
		check_eq(row, FG.layout(FG.area_seed(ids[i], starts[i]), u0, u1, sizes), "%s: the same seed gives the same row" % ids[i])
		check(row.size() >= int((u1 - u0) / 700.0), "%s: the row has pieces along its whole width (%d)" % [ids[i], row.size()])
		var filled := 0.0
		var prev := ""
		var prev2 := ""
		var prev_end := -INF
		var min_gap := INF
		var seen := {}
		for it in row:
			var name: String = it["piece"]
			seen[name] = true
			all_pieces[name] = true
			count += 1
			if it["flip"]:
				flips += 1
			filled += float(it["w"])
			check(name != prev, "%s: never the same piece twice in a row (%s)" % [ids[i], name])
			check(name != prev2, "%s: nor the same piece as two back (%s)" % [ids[i], name])
			check(prev == "" or FG.PIECES[name] != FG.PIECES[prev], "%s: nor the same kind twice in a row (%s after %s)" % [ids[i], name, prev])
			check(float(it["u"]) >= u0 + FG.MARGIN and float(it["u"]) + float(it["w"]) <= u1 - FG.MARGIN,
					"%s: every piece keeps clear of the ends of its span" % ids[i])
			check(float(it["u"]) >= prev_end, "%s: pieces never overlap" % ids[i])
			if prev != "":
				min_gap = minf(min_gap, float(it["u"]) - prev_end)
			prev_end = float(it["u"]) + float(it["w"])
			prev2 = prev
			prev = name
		var empty: float = 1.0 - filled / (u1 - u0)
		check(empty >= 0.55, "%s: at least 55%% of the width is empty (%.0f%%)" % [ids[i], empty * 100.0])
		check(empty <= 0.9, "%s: but it is not bare (%.0f%% empty)" % [ids[i], empty * 100.0])
		check(seen.size() >= 8, "%s: it uses a good mix of pieces (%d of 14)" % [ids[i], seen.size()])
		check(min_gap >= FG.GAP_NEAR.x - 0.01, "%s: the closest two pieces still have a gap (%.0f)" % [ids[i], min_gap])
	check(all_pieces.size() == 14, "across the level every piece is used (%d of 14)" % all_pieces.size())
	check(flips > 0 and flips < count, "some pieces are mirrored, not all (%d of %d)" % [flips, count])
	var other: Array = FG.layout(FG.area_seed("L01-A02", 0.0), 0.0, 9900.0, sizes)
	var again: Array = FG.layout(FG.area_seed("L01-A03", 0.0), 0.0, 9900.0, sizes)
	check(other != again, "two areas do not share a row")
	# the art left out: the pieces that remain still make a row, with none of the missing ones
	var fewer := sizes.duplicate()
	fewer.erase("hedge_a")
	fewer.erase("bench_a")
	var row2: Array = FG.layout(1, 0.0, 6000.0, fewer)
	check(not row2.is_empty(), "a row is still composed when two pieces' art is missing")
	for it in row2:
		check(it["piece"] != "hedge_a" and it["piece"] != "bench_a", "and it leaves them out (%s)" % it["piece"])
	check(FG.layout(1, 0.0, 6000.0, {}).is_empty(), "no art at all composes nothing")
	var tiny: Array = FG.layout(1, 0.0, 100.0, sizes)
	check(tiny.is_empty(), "a span too short for a piece composes nothing, without hanging")


## Without the PNGs (an export missing the art) the layer draws and processes
## nothing; a single missing piece is only left out.
func _missing_art() -> void:
	var paths: Array = []
	for p in FG.PIECES:
		paths.append(FG.DIR + p + ".png")
	for path in paths:
		FG._textures[path] = null   # as if the file were not there
	var layer = FG.new()
	layer.tile_width = 3000.0
	add_child(layer)
	await physics_frames(2)
	check(not layer.has_art(), "a layer whose PNGs are missing knows it has no art")
	check(layer.items().is_empty(), "so it composes nothing")
	check(layer.visible_rects(1000.0, ZOOM, VIEW).is_empty(), "draws nothing")
	check(not layer.is_processing(), "and does not process at all")
	check(not (layer.get_node("Screen/Strip") as Node2D).visible, "its canvas stays hidden")
	layer.queue_free()
	await physics_frames(1)
	for path in paths:
		FG._textures.erase(path)   # back to loading from disk
	var back = FG.new()
	back.tile_width = 3000.0
	add_child(back)
	await physics_frames(2)
	check(back.has_art() and not back.items().is_empty(), "with the art back the same layer composes its row")
	back.queue_free()
	await physics_frames(1)


func _areas() -> void:
	Session.new_run()
	var level: Node2D = load("res://scenes/levels/level_01.tscn").instantiate()
	add_child(level)
	await physics_frames(6)
	check(level.areas[4].get_node_or_null("Foreground") == null, "the depot (an interior) has no foreground")
	var layers := {}
	for i in OUTDOOR:
		var area: AreaRoot = level.areas[i]
		var fg: Node2D = area.get_node_or_null("Foreground")
		check(fg != null and fg.get_script() == FG, "%s has a Foreground node" % area.area_id)
		if fg == null:
			continue
		layers[i] = fg
		check(is_equal_approx(fg.tile_width, area.width), "%s: its layer spans the area's width" % area.area_id)
		check(fg.has_art() and not fg.items().is_empty(), "%s: it composed a row" % area.area_id)
		check_eq(fg.span(), Vector2(FG.PARALLAX * area.global_position.x, FG.PARALLAX * (area.global_position.x + area.width)),
				"%s: it owns its area's span of foreground space" % area.area_id)
		var screen: CanvasLayer = fg.get_node("Screen")
		check_eq(screen.layer, FG.LAYER, "%s: it draws on its own canvas layer" % area.area_id)
		var strip: Node2D = fg.get_node("Screen/Strip")
		check_eq(strip.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "%s: crisp, pixel for pixel" % area.area_id)
		check(fg.process_priority > 0, "%s: it reads the camera after the camera has moved" % area.area_id)
		_camera_sweep(fg, area)
	_seams(level, layers)
	await _culling(level, layers)
	level.queue_free()
	await physics_frames(2)


## Across every camera position an area allows (the view's middle from half a
## screen in from either end) every piece on screen stands on the bottom edge,
## inside the bottom 12%, on whole screen pixels, whole art pixels wide; only
## this area's row is ever in view; and the row slides faster than the camera.
func _camera_sweep(fg: Node2D, area: AreaRoot) -> void:
	var x0: float = area.global_position.x
	for size in [VIEW, Vector2(1680.0, 720.0)]:
		var half: float = size.x * 0.5 / ZOOM
		var cam: float = x0 + half
		var shown := 0
		var worst := 0
		var steps := 0
		var tallest := 0.0
		var off_grid := 0
		var wrong_width := 0
		var off_bottom := 0
		while cam <= x0 + area.width - half:
			var rects: Array = fg.visible_rects(cam, ZOOM, size)
			steps += 1
			if not rects.is_empty():
				shown += 1
			worst = maxi(worst, rects.size())
			for r in rects:
				var rect: Rect2 = r["rect"]
				var tex: Texture2D = FG.texture_for(r["piece"])
				tallest = maxf(tallest, rect.size.y)
				if not is_equal_approx(rect.end.y, size.y):
					off_bottom += 1
				if rect.position.x != roundf(rect.position.x):
					off_grid += 1
				if rect.size.x != float(tex.get_width() * 3):
					wrong_width += 1
			cam += 37.0
		check_eq(off_bottom, 0, "%s (view %d wide): every piece stands on the screen's bottom edge" % [area.area_id, int(size.x)])
		check_eq(off_grid, 0, "%s (view %d wide): and on whole screen pixels" % [area.area_id, int(size.x)])
		check_eq(wrong_width, 0, "%s (view %d wide): and is a whole 3 screen pixels per art pixel wide" % [area.area_id, int(size.x)])
		check(tallest <= size.y * BAND, "%s (view %d wide): nothing rises above the bottom 12%% (%.0f px)" % [area.area_id, int(size.x), tallest])
		check(shown >= int(steps * 0.7), "%s (view %d wide): most views have a piece on screen (%d of %d)" % [area.area_id, int(size.x), shown, steps])
		check(worst <= int(size.x / 180.0), "%s (view %d wide): and the row is never crowded (%d at once)" % [area.area_id, int(size.x), worst])
		# neither end of the camera's range reaches a neighbouring row
		var lo: float = x0 + half
		var hi: float = x0 + area.width - half
		check(fg.view_reaches(lo, ZOOM, size) and fg.view_reaches(hi, ZOOM, size), "%s: its own row is in view at both ends" % area.area_id)
		var u_lo: float = FG.PARALLAX * lo - half
		var u_hi: float = FG.PARALLAX * hi + half
		check(u_lo >= fg.span().x and u_hi <= fg.span().y, "%s: the view stays inside the span the area owns" % area.area_id)
	# the row moves faster than a world-fixed object: 100 world px of camera moves
	# a piece by PARALLAX x ZOOM x 100 screen px (within a pixel of rounding)
	var mid: Dictionary = fg.items()[fg.items().size() / 2]
	var cam_a: float = (float(mid["u"]) + float(mid["w"]) * 0.5) / FG.PARALLAX
	var left_a := -1.0
	var left_b := -1.0
	for r in fg.visible_rects(cam_a, ZOOM, VIEW):
		if r["piece"] == mid["piece"] and absf((r["rect"] as Rect2).get_center().x - VIEW.x * 0.5) < 80.0:
			left_a = (r["rect"] as Rect2).position.x
	for r in fg.visible_rects(cam_a + 100.0, ZOOM, VIEW):
		if r["piece"] == mid["piece"] and absf((r["rect"] as Rect2).get_center().x - (VIEW.x * 0.5 - FG.PARALLAX * ZOOM * 100.0)) < 80.0:
			left_b = (r["rect"] as Rect2).position.x
	check(left_a > -1.0 and left_b > -1.0, "%s: a piece in the middle of the view is found before and after the camera moves" % area.area_id)
	var moved: float = left_a - left_b
	check(absf(moved - FG.PARALLAX * ZOOM * 100.0) <= 1.0, "%s: 100 px of camera moves it %.0f screen px (%.0f expected)" % [area.area_id, moved, FG.PARALLAX * ZOOM * 100.0])
	check(moved > ZOOM * 100.0 + 20.0, "%s: faster than a world object would (%.0f vs %.0f)" % [area.area_id, moved, ZOOM * 100.0])


## Where two outdoor areas meet the rows meet too: a clear gap, never an
## overlap, whatever the camera shows of both.
func _seams(level: Node2D, layers: Dictionary) -> void:
	for i in [0, 1, 2]:
		var a: Node2D = layers[i]
		var b: Node2D = layers[i + 1]
		var last: Dictionary = a.items()[-1]
		var first: Dictionary = b.items()[0]
		var gap: float = float(first["u"]) - (float(last["u"]) + float(last["w"]))
		check(gap >= 2.0 * FG.MARGIN - 0.01, "A0%d and A0%d: their rows meet with a gap (%.0f units)" % [i + 1, i + 2, gap])
		check(is_equal_approx(a.span().y, b.span().x), "and their spans meet exactly")


## A layer whose span is off screen is hidden and draws nothing; the one the
## camera is in is shown.
func _culling(level: Node2D, layers: Dictionary) -> void:
	await physics_frames(10)
	var cam := level.get_viewport().get_camera_2d()
	check(cam != null, "the level has its camera")
	var visible_count := 0
	for i in layers:
		var fg: Node2D = layers[i]
		var strip: Node2D = fg.get_node("Screen/Strip")
		if strip.visible:
			visible_count += 1
	check(layers[0].get_node("Screen/Strip").visible, "the first area's row is shown at the start of the level")
	check(not layers[3].get_node("Screen/Strip").visible and not layers[5].get_node("Screen/Strip").visible,
			"the far areas' rows are hidden and draw nothing")
	check(visible_count <= 2, "at most two rows are shown at once (%d)" % visible_count)
