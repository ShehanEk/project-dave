extends TestCase
## The painted ground details (Sheet 8, 2026-10-06): the details sheet's
## puddles, cracks, drain grate, leaves, cable, floor vent, hose and box,
## laid over the paving by `scripts/world/decal.gd` to break up its repeat.
## The script draws each piece crisp at 1.5 world px per art pixel, bottom-
## centre on its origin, mirrored by `flip`, and draws nothing when its PNG is
## missing. Every area scene places its own decals under a `Decals` node that
## follows `Geometry`: purely visual (no collision, no group), standing on a
## walkway block's top and its paving face, clear of every pickup, station,
## lever, wicket, hatch, core node, workbench, pad, pit, enemy start and
## marker, and only the pieces that belong in each area.

const DecalScript := preload("res://scripts/world/decal.gd")
const ART := 1.5
## Everything must stay this far from a decal's footprint (world px).
const CLEAR := 70.0
## How far under a walkway's top a decal's anchor may sit: the paving face
## (27 world px) and the depot floor's lit plate (30).
const FACE := 30.0
const OUTDOOR_ONLY := ["puddle_a", "puddle_b", "puddle_c", "leaves"]
const PLAZA_AND_DEPOT_ONLY := ["grate", "cable", "vent"]

func run() -> void:
	_script_draws_pieces()
	await _missing_art()
	await _areas()


## Each piece loads, comes out at the sizes the details sheet is meant for
## (1.5 world px per art pixel), stands bottom-centre on its origin, and `flip`
## mirrors it about that origin.
func _script_draws_pieces() -> void:
	check_eq(DecalScript.PIECES.size(), 11, "the sheet gives eleven pieces")
	for p in DecalScript.PIECES:
		check(DecalScript.texture_for(p) != null, "%s has its art" % p)
	var d = DecalScript.new()
	add_child(d)
	check_eq(d.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "a decal is drawn crisp, pixel for pixel")
	for p in ["puddle_a", "puddle_b", "puddle_c"]:
		d.piece = p
		var w: float = d.local_rect().size.x
		check(w >= 40.0 and w <= 90.0, "%s is a puddle's width (%.0f world px)" % [p, w])
		check(d.local_rect().size.y <= 12.0, "and a thin strip (%.0f px)" % d.local_rect().size.y)
	d.piece = "box"
	check(d.local_rect().size.y >= 30.0 and d.local_rect().size.y <= 40.0, "the box is 30 to 40 px tall (%.0f)" % d.local_rect().size.y)
	d.piece = "hose"
	check(d.local_rect().size.y >= 18.0 and d.local_rect().size.y <= 22.0, "the hose is about 20 px tall (%.0f)" % d.local_rect().size.y)
	d.piece = "puddle_a"
	var tex: Texture2D = DecalScript.texture_for("puddle_a")
	var r: Rect2 = d.local_rect()
	check(is_equal_approx(r.size.x, tex.get_width() * ART) and is_equal_approx(r.size.y, tex.get_height() * ART),
			"it is painted at 1.5 world px per art pixel, unscaled")
	check(is_equal_approx(r.end.y, 0.0), "it stands on its origin (its bottom edge is at y = 0)")
	check(absf(r.position.x + r.size.x * 0.5) <= ART, "centred on it (within one art pixel)")
	d.flip = true
	var f: Rect2 = d.local_rect()
	check(is_equal_approx(f.size.x, r.size.x) and is_equal_approx(f.end.y, 0.0), "a flipped decal keeps its size and stands on its origin")
	check(is_equal_approx(f.position.x, -r.end.x), "and is mirrored about that origin")
	check(d.global_rect().size == f.size, "global_rect has the same size")
	d.queue_free()


## An export without the art: the node says so and draws nothing.
func _missing_art() -> void:
	var d = DecalScript.new()
	d.piece = "no_such_piece"
	add_child(d)
	await physics_frames(2)
	check(not d.has_piece(), "a decal whose PNG is missing says so")
	check_eq(d.local_rect(), Rect2(), "has no area")
	d.piece = ""
	check(not d.has_piece(), "so does a decal with no piece")
	d.piece = "puddle_b"
	check(d.has_piece(), "and naming a real piece brings it back")
	d.queue_free()
	await physics_frames(1)


## Every area's own decals.
func _areas() -> void:
	Session.new_run()
	var level: Node2D = load("res://scenes/levels/level_01.tscn").instantiate()
	add_child(level)
	await physics_frames(3)
	var counts := {}
	var total := 0
	for a in level.areas:
		var area: AreaRoot = a
		var decals: Node2D = area.get_node_or_null("Decals")
		check(decals != null, "%s has a Decals node" % area.area_id)
		if decals == null:
			continue
		var kids: Array = decals.get_children()
		total += kids.size()
		check(kids.size() >= 8 and kids.size() <= 14, "%s places 8 to 14 decals (%d)" % [area.area_id, kids.size()])
		_order(area, decals)
		var keep: Array = _keep_clear(area)
		for k in kids:
			_decal(area, k, keep, counts)
		_no_collision(decals)
		var puddles := 0
		for k in kids:
			if (k.piece as String).begins_with("puddle"):
				puddles += 1
		check(puddles <= 3, "%s keeps puddles rare (%d)" % [area.area_id, puddles])
	check(total >= 55, "the level places the details (%d decals)" % total)
	check(counts.get("box", 0) <= 2, "at most two boxes in the whole level (%d)" % counts.get("box", 0))
	check(counts.get("hose", 0) <= 2, "at most two hoses in the whole level (%d)" % counts.get("hose", 0))
	check(counts.get("box", 0) >= 1 and counts.get("hose", 0) >= 1, "but there is some clutter")
	for p in DecalScript.PIECES:
		check(counts.get(p, 0) >= 1, "%s is used somewhere" % p)
	level.queue_free()
	await physics_frames(2)


## The Decals node follows Geometry (so it draws over the walkway blocks, at
## the same z) and comes before Entities and Encounters (so pickups, enemies
## and Dave draw over it); Scenery sits further back.
func _order(area: AreaRoot, decals: Node2D) -> void:
	var geometry: Node = area.get_node("Geometry")
	check(decals.get_index() > geometry.get_index(), "%s: Decals draws after Geometry (over the walkway)" % area.area_id)
	for later in ["Entities", "Encounters"]:
		var n: Node = area.get_node_or_null(later)
		if n:
			check(decals.get_index() < n.get_index(), "%s: Decals draws before %s (under pickups and enemies)" % [area.area_id, later])
	check_eq(decals.z_index, 0, "%s: Decals shares the blocks' z, so tree order puts it over them" % area.area_id)
	for b in geometry.get_children():
		if b is Block:
			check_eq((b as Block).z_index, 0, "%s: the blocks are at z 0 too" % area.area_id)
			break
	var scenery: Node2D = area.get_node("Scenery")
	for s in scenery.get_children():
		if s is Node2D:
			check((s as Node2D).z_index < decals.z_index, "%s: Scenery stays behind the decals" % area.area_id)
			break


## One decal: its script, its art, its place on a walkway, clear of every
## keep-clear point, and only in the areas its piece belongs in.
func _decal(area: AreaRoot, d, keep: Array, counts: Dictionary) -> void:
	var where := "%s/%s" % [area.area_id, d.name]
	check(d.get_script() == DecalScript, "%s uses decal.gd" % where)
	if d.get_script() != DecalScript:
		return
	check(d.has_piece(), "%s has its art (%s)" % [where, d.piece])
	check_eq(d.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "%s is crisp" % where)
	check_eq(d.z_index, 0, "%s is at z 0" % where)
	counts[d.piece] = counts.get(d.piece, 0) + 1
	var rect: Rect2 = d.global_rect()
	# on a walkway: both ends and the middle of the footprint stand over a
	# GROUND or PORCH block whose top the anchor is within the paving face of
	for x in [rect.position.x + 1.0, rect.get_center().x, rect.end.x - 1.0]:
		var floor_block := _floor_at(area, x, d.global_position.y)
		check(floor_block != null, "%s stands on a walkway top (x %.0f, y %.1f)" % [where, x, d.global_position.y])
		if floor_block:
			# nothing higher than that walkway cuts into the footprint
			for o in area.get_node("Geometry").get_children():
				var ob := o as Block
				if ob == null or ob == floor_block:
					continue
				if ob.global_position.y < floor_block.global_position.y - 0.01 and rect.intersects(ob.get_rect_global().grow(-0.01)):
					check(false, "%s overlaps the higher block %s" % [where, ob.name])
	# the places its piece belongs
	if d.piece in OUTDOOR_ONLY:
		check(area.area_id != "L01-A05", "%s: %s is outdoors only" % [where, d.piece])
	if (d.piece as String).begins_with("crack"):
		check(area.area_id != "L01-A05", "%s: the depot's steel floor has no stone cracks" % where)
	if d.piece in PLAZA_AND_DEPOT_ONLY:
		check(area.area_id in ["L01-A04", "L01-A05"], "%s: %s belongs in the plaza or the depot" % [where, d.piece])
	# clear of everything that matters
	for k in keep:
		var dist := _dist(rect, k["rect"])
		check(dist >= CLEAR - 0.5, "%s is %.0f px from %s (needs %.0f)" % [where, dist, k["name"], CLEAR])


## The walkway block (GROUND or PORCH, tall enough to be a floor) under world
## x whose top the anchor is within the paving face below, or null.
func _floor_at(area: AreaRoot, x: float, anchor_y: float) -> Block:
	for b in area.get_node("Geometry").get_children():
		var blk := b as Block
		if blk == null or not (blk.kind == Block.Kind.GROUND or blk.kind == Block.Kind.PORCH) or blk.size.y < 100.0:
			continue
		var r := blk.get_rect_global()
		var dy := anchor_y - r.position.y
		if x >= r.position.x and x <= r.end.x and dy >= -0.01 and dy <= FACE:
			return blk
	return null


## Everything a decal must keep clear of: pickups and objects (Entities, the
## kill planes aside), enemy starts, markers, and the hatch, pit cover and
## platforms in Geometry that are not plain blocks.
func _keep_clear(area: AreaRoot) -> Array:
	var out: Array = []
	for e in area.get_node("Entities").get_children():
		if e is Node2D and not String(e.name).begins_with("KillPlane"):
			out.append({"name": "%s" % e.name, "rect": Rect2((e as Node2D).global_position, Vector2.ZERO)})
	for e in get_tree().get_nodes_in_group("enemy"):
		if area.is_ancestor_of(e):
			out.append({"name": "enemy %s" % e.name, "rect": Rect2((e as Node2D).global_position, Vector2.ZERO)})
	for m in area.get_node("Markers").get_children():
		if m is Node2D:
			out.append({"name": "marker %s" % m.name, "rect": Rect2((m as Node2D).global_position, Vector2.ZERO)})
	for g in area.get_node("Geometry").get_children():
		if g is Block or not (g is Node2D):
			continue
		var r := Rect2((g as Node2D).global_position, Vector2.ZERO)
		for c in g.get_children():
			var cs := c as CollisionShape2D
			if cs and cs.shape is RectangleShape2D:
				var s: Vector2 = (cs.shape as RectangleShape2D).size
				r = r.merge(Rect2(cs.global_position - s * 0.5, s))
		out.append({"name": "geometry %s" % g.name, "rect": r})
	check(out.size() >= 3, "%s: the keep-clear list is not empty (%d)" % [area.area_id, out.size()])
	return out


func _dist(a: Rect2, b: Rect2) -> float:
	var dx := maxf(maxf(a.position.x - b.end.x, b.position.x - a.end.x), 0.0)
	var dy := maxf(maxf(a.position.y - b.end.y, b.position.y - a.end.y), 0.0)
	return sqrt(dx * dx + dy * dy)


## Purely visual: nothing under Decals collides, senses or belongs to a group.
func _no_collision(decals: Node) -> void:
	var stack: Array = [decals]
	var visited := 0
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		stack.append_array(n.get_children())
		visited += 1
		check(not (n is CollisionObject2D) and not (n is CollisionShape2D) and not (n is CollisionPolygon2D),
				"%s adds no collision" % n.name)
		for g in n.get_groups():
			check(String(g).begins_with("_"), "%s is in no group (%s)" % [n.name, g])
		if n != decals:
			check_eq(n.get_child_count(), 0, "%s has no children" % n.name)
	check(visited > 1, "the Decals node is not empty")
