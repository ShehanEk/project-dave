extends StaticBody2D
## A prop Dave's shots can break (Level 2 v2: about 40 of them; l02-alignment.md "Things
## break"): a glass panel, monitor, server cabinet, crate, pressure gauge, vent panel or display
## case. Scrapjack bolts and Boom Broom pellets break it through the same HitZone every target
## has; it takes `damage` points a hit, may crack first, then breaks: debris falls and fades, a
## sound plays, it switches to its broken look and its `contents` (a chip, a chip tray, a feed
## cartridge) appear. Enemy fire never touches it (see "Who can break it").
##
## Origin: bottom centre of the prop, on the surface it stands on (a wall-mounted gauge: where
## its bottom sits). `size` is the prop's extent in px (0 = the kind's own default).
##
## How shots find it. A bolt's ray and a pellet's ray both look at world (layer 1) and hittable
## (layer 5) and resolve on the FIRST thing they cross: a HitZone is "hit", anything else is
## "blocked" and does nothing. So a `solid` breakable has both a body on the world layer and a
## HitZone, and the HitZone is `SOLID_ZONE_GROW` px bigger on every side: a shot always crosses
## the zone before the body, so a secret wall takes the shot instead of just stopping it. A
## broken one switches both off, and shots fly through the gap.
##
## Hit points. `health` counts damage points, not shots: a Scrapjack bolt is 1, a Boom Broom
## blast is one hit worth its pellets' summed damage (5 at point blank, so one blast breaks
## anything of health 5 or less; 1 from far away). Every kind except the gauge shows a cracked
## stage once it has taken damage but still stands (intact -> cracked -> broken); the cracks
## spread from each place it was hit.
##
## Who can break it. Only the hero's shots: an EnemyRound's rays do not look at layer 5, an
## enemy's melee box only looks for the hero's hurtbox, and nothing here listens to enemy
## damage. An intact `solid` breakable still stops an enemy round like any wall (and the
## round does nothing to it). Hazards and the rest of the level never call `take_damage()`.
##
## Persistence. With an `entity_id` (a Level 2 id such as "L02-A02-BR01", the save's
## `^L02(-[A-Z0-9]+)+$` pattern) the break is recorded with `Session.collect(entity_id, 0)`:
## it stays broken after a checkpoint, a death before the next checkpoint puts it back (the
## level is rebuilt from the rolled-back state), exactly like a pickup. A rebuilt one that is
## already recorded starts broken, with no debris or sound, and shows its contents. Without
## an id it is always intact on a rebuild.
##
## Contents. `contents` are nodes (siblings in the scene, or children of the same parent added
## before it) that stay hidden and switched off (`PROCESS_MODE_DISABLED`, which also stops an
## Area2D's collision and an Interactable's prompt) until it breaks, then appear. Their own
## `entity_id` still guards duplication: a chip already collected frees itself in its own
## `_ready()`, so a rebuilt level never doubles a reward. Give every content its own id.
##
## Art. Until Batch 8's painted pieces exist every kind draws a code-drawn stand-in. A painted
## piece is looked up through LabSkins by `piece` (default: the kind's name, e.g. "crate") with
## "_cracked" and "_broken" added for the later stages; each stage uses the painted piece when
## it exists and the stand-in when it does not. Sounds are the existing cues only
## (AudioDirector: `debris_clatter`, `bolt_blocked`, `hatch_open`).
##
## Motion safety. Nothing flashes faster than 2 Hz: a hit flash is rate-limited to once per
## `FLASH_GAP` (0.5 s) and a screen's break flicker is one flash and one echo 0.55 s later.
## Under Settings.get_reduced_motion() there is no jolt and no echo, and fewer, shorter bits of
## debris. No `class_name` (import-cache rule): tests and scenes preload it by path.

signal cracked(remaining: int)
signal broke

enum Kind { GLASS_PANEL, MONITOR, SERVER_CABINET, CRATE, GAUGE, VENT_PANEL, DISPLAY_CASE }
enum Stage { INTACT, CRACKED, BROKEN }

const LabSkins := preload("res://scripts/world/lab_skins.gd")

## Per kind: `name` (also the painted piece), default `health` and `size`, whether it has a
## `cracks` stage, the sounds of its `break`, and the colour of its break `spark` (or none).
const SPECS := {
	Kind.GLASS_PANEL: {"name": "glass_panel", "health": 2, "size": Vector2(24.0, 150.0), "cracks": true,
			"sounds": [&"debris_clatter"]},
	Kind.MONITOR: {"name": "monitor", "health": 2, "size": Vector2(44.0, 36.0), "cracks": true,
			"sounds": [&"bolt_blocked", &"debris_clatter"], "spark": Color("#BDF4FF")},
	Kind.SERVER_CABINET: {"name": "server_cabinet", "health": 4, "size": Vector2(56.0, 100.0), "cracks": true,
			"sounds": [&"bolt_blocked", &"debris_clatter"], "spark": Color("#FFD27A")},
	Kind.CRATE: {"name": "crate", "health": 3, "size": Vector2(56.0, 46.0), "cracks": true,
			"sounds": [&"debris_clatter"]},
	Kind.GAUGE: {"name": "gauge", "health": 1, "size": Vector2(30.0, 30.0), "cracks": false,
			"sounds": [&"hatch_open"], "spark": Color("#F2F6FA")},
	Kind.VENT_PANEL: {"name": "vent_panel", "health": 2, "size": Vector2(54.0, 40.0), "cracks": true,
			"sounds": [&"hatch_open", &"debris_clatter"]},
	Kind.DISPLAY_CASE: {"name": "display_case", "health": 3, "size": Vector2(64.0, 60.0), "cracks": true,
			"sounds": [&"debris_clatter"]},
}

const OUTLINE := Color("#05070B")
const STEEL_DARK := Color("#161F2D")
const STEEL := Color("#2A3A50")
const STEEL_LIGHT := Color("#4A6280")
const INNER_DARK := Color("#080C14")
const TEAL := Color("#3FE0D0")
const AMBER := Color("#FFB02E")
const GLASS_FILL := Color(0.62, 0.88, 0.98, 0.17)
const GLASS_EDGE := Color(0.82, 0.96, 1.0, 0.6)
const GLASS_SHARD := Color(0.78, 0.94, 1.0, 0.72)
const CRACK_LIGHT := Color(0.93, 0.98, 1.0, 0.9)
const CRACK_DARK := Color(0.02, 0.05, 0.09, 0.55)
const WOOD := Color("#7A4A2C")
const WOOD_DARK := Color("#4A2B1A")
const WOOD_LIGHT := Color("#A8693F")
const BRASS := Color("#B07A3A")
const BRASS_DARK := Color("#6E4A22")
const DIAL := Color("#E4ECF2")

## A solid breakable's HitZone reaches this far past its body on every side, so a ray always
## crosses the zone first (see the header).
const SOLID_ZONE_GROW := 3.0
const ZONE_GROW := 2.0
## Between two hit flashes (2 Hz at most).
const FLASH_GAP := 0.5
const FLASH_TIME := 0.16
const JOLT_TIME := 0.14
const JOLT_PX := 2.5
## A broken screen: its flash, and the echo that follows (0.55 s apart is under 2 Hz).
const GLOW_TIME := 0.3
const GLOW_ECHO_AT := 0.55
const GLOW_ECHO_TIME := 0.3
const BASE_Z := -6

## The ids a Level 2 breakable may carry in a save (CheckpointService: `^L02(-[A-Z0-9]+)+$`).
@export var entity_id: String = ""
@export var kind: Kind = Kind.CRATE
## Damage points it takes to break; 0 = the kind's own default (glass 2, monitor 2, server
## cabinet 4, crate 3, gauge 1, vent panel 2, display case 3).
@export var health: int = 0
## Extent in px; (0, 0) = the kind's own default.
@export var size: Vector2 = Vector2.ZERO
## True: an intact prop blocks the hero, enemies and shots like a wall on world layer 1 and stops
## blocking once broken. That is the SECRET WALL (a glass wall or vent panel in front of a hidden
## room).
@export var solid: bool = false
## Nodes hidden and inactive until it breaks (see the header).
@export var contents: Array[NodePath] = []
## The painted piece's name for Batch 8's art; "" = the kind's name.
@export var piece: String = ""

var _hp: int = 0
var _max_hp: int = 0
var _broken: bool = false
var _zone: HitZone
var _solid_shape: CollisionShape2D
var _content_nodes: Array[Node] = []
var _crack_points: Array[Vector2] = []
var _ground_y: float = 0.0
var _jolt: float = 0.0
var _jolt_dir: float = 1.0
var _flash: float = 0.0
var _flash_gap: float = 0.0
var _glow_t: float = -1.0
var _glow_reduced: bool = false


func _ready() -> void:
	add_to_group("breakable")
	z_index = BASE_Z
	_max_hp = maxi(health if health > 0 else int(_spec()["health"]), 1)
	_hp = _max_hp
	collision_layer = 1 if solid else 0
	collision_mask = 0
	_build_shapes()
	_zone.hit.connect(_on_zone_hit)
	_resolve_contents()
	if entity_id != "" and Session and Session.is_collected(entity_id):
		# Broken in an earlier life of this level: stay broken, quietly, contents shown.
		_broken = true
		_hp = 0
		_apply_broken_collision()
		for node in _content_nodes:
			_set_content_active(node, true)
	else:
		for node in _content_nodes:
			_set_content_active(node, false)
	set_process(false)
	queue_redraw()


# --- queries -----------------------------------------------------------------------------------

func kind_name() -> String:
	return String(_spec()["name"])


## The Kind with this name ("glass_panel", "crate", ...), or -1.
static func kind_from_name(kind_name_str: String) -> int:
	for k in SPECS:
		if String(SPECS[k]["name"]) == kind_name_str:
			return int(k)
	return -1


func is_broken() -> bool:
	return _broken


func max_health() -> int:
	return _max_hp if _max_hp > 0 else maxi(health if health > 0 else int(_spec()["health"]), 1)


## Damage points it can still take (0 once broken).
func remaining_health() -> int:
	return _hp


func stage() -> int:
	if _broken:
		return Stage.BROKEN
	if bool(_spec()["cracks"]) and _hp < _max_hp:
		return Stage.CRACKED
	return Stage.INTACT


func effective_size() -> Vector2:
	return size if size.x > 0.0 and size.y > 0.0 else Vector2(_spec()["size"])


## The HitZone shots strike (tests).
func hit_zone() -> HitZone:
	return _zone


## The nodes named by `contents`, as found when it entered the tree.
func content_nodes() -> Array[Node]:
	return _content_nodes


func _spec() -> Dictionary:
	return SPECS[kind]


# --- damage ------------------------------------------------------------------------------------

func _on_zone_hit(damage: int, at: Vector2, dir: Vector2) -> void:
	take_damage(damage, at, dir)


## Takes `amount` damage points (at least 1) from a hit at world position `at`, travelling in
## `dir`. Returns true when this hit broke it. The HitZone calls it for every accepted shot; a
## script (a launch rack's clamps, a sequencer) may call it too.
func take_damage(amount: int, at: Vector2 = Vector2.ZERO, dir: Vector2 = Vector2.RIGHT) -> bool:
	if _broken:
		return false
	_hp = maxi(_hp - maxi(amount, 1), 0)
	var local_at := _local_hit(at)
	if _hp <= 0:
		_break(local_at, dir)
		return true
	_note_crack(local_at)
	_on_cracked(local_at, dir)
	return false


## Breaks it outright (a script, or a test), with the effects of a normal break.
func break_now(at: Vector2 = Vector2.ZERO, dir: Vector2 = Vector2.RIGHT) -> void:
	if _broken:
		return
	_hp = 0
	_break(_local_hit(at), dir)


func _local_hit(at: Vector2) -> Vector2:
	var r := _rect()
	var local := to_local(at) if at != Vector2.ZERO else r.get_center()
	return Vector2(clampf(local.x, r.position.x + 3.0, r.end.x - 3.0), clampf(local.y, r.position.y + 3.0, r.end.y - 3.0))


func _note_crack(local_at: Vector2) -> void:
	if not bool(_spec()["cracks"]):
		return
	_crack_points.append(local_at)
	if _crack_points.size() > 3:
		_crack_points.remove_at(0)


func _on_cracked(local_at: Vector2, dir: Vector2) -> void:
	var reduced := _reduced()
	if not reduced:
		_jolt = JOLT_PX
		_jolt_dir = signf(dir.x) if dir.x != 0.0 else 1.0
	if _flash_gap <= 0.0:
		_flash = 1.0
		_flash_gap = FLASH_GAP
	var debris := _make_debris()
	var rng := _rng(_hp * 31 + _crack_points.size())
	var n := 3 if reduced else 5
	match kind:
		Kind.GLASS_PANEL, Kind.DISPLAY_CASE:
			for i in n:
				_add_glass(debris, local_at, dir, rng, 0.6)
		Kind.CRATE:
			for i in n - 1:
				_add_wood_bit(debris, local_at, dir, rng, true)
		Kind.GAUGE:
			pass
		_:
			for i in n - 1:
				_add_metal_bit(debris, local_at, dir, rng)
			if kind == Kind.MONITOR or kind == Kind.SERVER_CABINET:
				_add_sparks(debris, local_at, rng, 3 if reduced else 6, Color(_spec()["spark"]))
	set_process(true)
	cracked.emit(_hp)
	queue_redraw()


func _break(local_at: Vector2, dir: Vector2) -> void:
	_broken = true
	_hp = 0
	_apply_broken_collision()
	_note_crack(local_at)
	var reduced := _reduced()
	var rng := _rng(7)
	var debris := _make_debris()
	match kind:
		Kind.GLASS_PANEL:
			_glass_burst(debris, rng, dir, 20, true)
		Kind.DISPLAY_CASE:
			_glass_burst(debris, rng, dir, 22, true)
		Kind.MONITOR:
			_glass_burst(debris, rng, dir, 7, false)
			for i in 5:
				_add_metal_bit(debris, local_at, dir, rng)
			_add_sparks(debris, local_at, rng, 6 if reduced else 12, Color(_spec()["spark"]))
		Kind.SERVER_CABINET:
			for i in 8:
				_add_metal_bit(debris, local_at, dir, rng)
			_add_sparks(debris, local_at, rng, 6 if reduced else 14, Color(_spec()["spark"]))
			_add_puff(debris, Vector2(0.0, -effective_size().y * 0.7), rng, Color(0.35, 0.37, 0.42, 0.45), 20.0)
		Kind.CRATE:
			for i in 10:
				_add_wood_bit(debris, local_at, dir, rng, i < 5)
			_add_puff(debris, local_at, rng, Color(0.62, 0.52, 0.42, 0.35), 18.0)
		Kind.GAUGE:
			for i in 6:
				_add_glass(debris, Vector2(0.0, -effective_size().y * 0.55), dir, rng, 0.45)
			for i in 3:
				_add_metal_bit(debris, local_at, dir, rng, BRASS)
			_add_steam(debris, rng, reduced)
		Kind.VENT_PANEL:
			for i in 8:
				_add_metal_bit(debris, local_at, dir, rng)
			_add_puff(debris, local_at, rng, Color(0.5, 0.52, 0.56, 0.4), 18.0)
	_spark_burst(local_at, dir)
	_play_sounds()
	if kind == Kind.MONITOR:
		_glow_t = 0.0
		_glow_reduced = reduced
	_flash = 0.0
	if not reduced:
		_jolt = JOLT_PX * 1.4
		_jolt_dir = signf(dir.x) if dir.x != 0.0 else 1.0
	set_process(true)
	for node in _content_nodes:
		_set_content_active(node, true, true)
	if entity_id != "" and Session:
		Session.collect(entity_id, 0)
	broke.emit()
	queue_redraw()


func _apply_broken_collision() -> void:
	collision_layer = 0
	if _solid_shape:
		_solid_shape.set_deferred("disabled", true)
	if _zone:
		_zone.monitorable = false
		for child in _zone.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).set_deferred("disabled", true)


func _build_shapes() -> void:
	var sz := effective_size()
	_solid_shape = get_node_or_null("Solid") as CollisionShape2D
	if _solid_shape == null:
		_solid_shape = CollisionShape2D.new()
		_solid_shape.name = "Solid"
		add_child(_solid_shape)
	var body_rect := RectangleShape2D.new()
	body_rect.size = sz
	_solid_shape.shape = body_rect
	_solid_shape.position = Vector2(0.0, -sz.y * 0.5)
	_solid_shape.disabled = not solid
	_zone = get_node_or_null("HitZone") as HitZone
	if _zone == null:
		_zone = HitZone.new()
		_zone.name = "HitZone"
		add_child(_zone)
	var zone_shape := _zone.get_node_or_null("Shape") as CollisionShape2D
	if zone_shape == null:
		zone_shape = CollisionShape2D.new()
		zone_shape.name = "Shape"
		_zone.add_child(zone_shape)
	var grow := SOLID_ZONE_GROW if solid else ZONE_GROW
	var zone_rect := RectangleShape2D.new()
	zone_rect.size = sz + Vector2(grow, grow) * 2.0
	zone_shape.shape = zone_rect
	zone_shape.position = Vector2(0.0, -sz.y * 0.5)


# --- contents ----------------------------------------------------------------------------------

func _resolve_contents() -> void:
	_content_nodes.clear()
	for path in contents:
		var node := get_node_or_null(path)
		if node != null and node != self and not node.is_queued_for_deletion():
			_content_nodes.append(node)


## Hides and switches off (or shows and switches on) one content node. The node's own process
## mode is remembered so a content that had a custom one gets it back.
func _set_content_active(node: Node, active: bool, fade: bool = false) -> void:
	if not is_instance_valid(node) or node.is_queued_for_deletion():
		return
	if active:
		var original: int = int(node.get_meta("_breakable_process_mode", Node.PROCESS_MODE_INHERIT))
		node.process_mode = original as Node.ProcessMode
	else:
		if not node.has_meta("_breakable_process_mode"):
			node.set_meta("_breakable_process_mode", int(node.process_mode))
		node.process_mode = Node.PROCESS_MODE_DISABLED
	if node is CanvasItem:
		(node as CanvasItem).visible = active
		if active and fade and node.is_inside_tree():
			(node as CanvasItem).modulate.a = 0.0
			node.create_tween().tween_property(node, "modulate:a", 1.0, 0.25)


# --- the reaction ------------------------------------------------------------------------------

func _process(delta: float) -> void:
	_flash_gap = maxf(0.0, _flash_gap - delta)
	_flash = maxf(0.0, _flash - delta / FLASH_TIME)
	_jolt = maxf(0.0, _jolt - JOLT_PX * 1.4 * delta / JOLT_TIME)
	if _glow_t >= 0.0:
		_glow_t += delta
		if _glow_t > GLOW_ECHO_AT + GLOW_ECHO_TIME:
			_glow_t = -1.0
	queue_redraw()
	if _flash <= 0.0 and _flash_gap <= 0.0 and _jolt <= 0.0 and _glow_t < 0.0:
		set_process(false)


## 0..1: how brightly a screen is flashing (its break flash, then one echo).
func glow_level() -> float:
	if _glow_t < 0.0:
		return 0.0
	var first := clampf(1.0 - _glow_t / GLOW_TIME, 0.0, 1.0)
	if _glow_reduced:
		return first * 0.6
	var echo_k := (_glow_t - GLOW_ECHO_AT) / GLOW_ECHO_TIME
	var echo := clampf(1.0 - echo_k, 0.0, 1.0) * 0.55 if echo_k >= 0.0 else 0.0
	return maxf(first, echo)


func _reduced() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


func _play_sounds() -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio == null:
		return
	for cue in _spec()["sounds"]:
		audio.play_sfx(cue, global_position + Vector2(0.0, -effective_size().y * 0.5))


func _spark_burst(local_at: Vector2, dir: Vector2) -> void:
	if not _spec().has("spark") or get_parent() == null:
		return
	var spark := ImpactSpark.new()
	spark.color = Color(_spec()["spark"])
	spark.dir = dir
	spark.global_position = to_global(local_at)
	get_parent().add_child(spark)


## Where the pieces land: straight down to the first world surface under the prop (its own
## surface for anything standing on a floor; the real floor for a wall-mounted gauge or vent).
func _find_ground() -> float:
	if not is_inside_tree():
		return 0.0
	var from := global_position + Vector2(0.0, -6.0)
	var q := PhysicsRayQueryParameters2D.create(from, from + Vector2(0.0, 900.0), 1)
	q.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return 0.0
	return maxf((hit["position"] as Vector2).y - global_position.y, 0.0)


func _rng(salt: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(entity_id) if entity_id != "" else hash(Vector2i(position))
	rng.seed += salt * 7919 + int(kind)
	return rng


func _rect() -> Rect2:
	var s := effective_size()
	return Rect2(Vector2(-s.x * 0.5, -s.y), s)


# --- debris ------------------------------------------------------------------------------------

## A falling, fading shower of pieces in the prop's own space (a child, so it goes with the
## level). Pieces fall under gravity, bounce once or twice and rest at `ground`, then fade.
class Debris extends Node2D:
	enum Shape { SHARD, SLAT, SPECK, SPARK, PUFF }
	const GRAVITY := 980.0
	const FADE := 0.5

	var pieces: Array[Dictionary] = []
	var ground: float = 0.0

	func add(shape: int, pos: Vector2, vel: Vector2, size: Vector2, color: Color, life: float, spin: float = 0.0) -> void:
		pieces.append({"shape": shape, "pos": pos, "vel": vel, "size": size, "color": color, "life": life,
				"ang": 0.0, "spin": spin, "t": 0.0, "rest": false, "bounces": 0})

	func _process(delta: float) -> void:
		var alive := false
		for p in pieces:
			p["t"] = float(p["t"]) + delta
			if float(p["t"]) >= float(p["life"]):
				continue
			alive = true
			var shape: int = p["shape"]
			var pos: Vector2 = p["pos"]
			var vel: Vector2 = p["vel"]
			if shape == Shape.PUFF:
				p["pos"] = pos + vel * delta
				p["vel"] = vel * maxf(0.0, 1.0 - 1.6 * delta)
				continue
			if bool(p["rest"]):
				continue
			vel.y += GRAVITY * (0.3 if shape == Shape.SPARK else 1.0) * delta
			pos += vel * delta
			p["ang"] = float(p["ang"]) + float(p["spin"]) * delta
			if shape != Shape.SPARK and pos.y >= ground:
				pos.y = ground
				if absf(vel.y) > 150.0 and int(p["bounces"]) < 2:
					vel = Vector2(vel.x * 0.55, -vel.y * 0.3)
					p["spin"] = float(p["spin"]) * 0.5
					p["bounces"] = int(p["bounces"]) + 1
				else:
					vel = Vector2.ZERO
					p["rest"] = true
					p["ang"] = snappedf(float(p["ang"]), PI) + sin(pos.x) * 0.2
			p["pos"] = pos
			p["vel"] = vel
		queue_redraw()
		if not alive:
			queue_free()

	func _draw() -> void:
		for p in pieces:
			var t: float = p["t"]
			var life: float = p["life"]
			if t >= life:
				continue
			var shape: int = p["shape"]
			var color: Color = p["color"]
			var pos: Vector2 = p["pos"]
			var size: Vector2 = p["size"]
			var k := t / life
			match shape:
				Shape.PUFF:
					# Soft edged: four nested discs, each faint, so the middle is the densest.
					var a := color.a * pow(1.0 - k, 1.3)
					var radius := size.x * (0.5 + 1.1 * k)
					for ring in 4:
						draw_circle(pos, radius * (1.0 - ring * 0.22), Color(color.r, color.g, color.b, a * 0.3))
				Shape.SPARK:
					var vel: Vector2 = p["vel"]
					var tail := pos - vel * 0.035
					draw_line(tail, pos, Color(0.02, 0.03, 0.05, 0.5 * (1.0 - k)), 2.8)
					draw_line(tail, pos, Color(color.r, color.g, color.b, 1.0 - k), 1.5)
				_:
					var fade := clampf((life - t) / FADE, 0.0, 1.0)
					var c := Color(color.r, color.g, color.b, color.a * fade)
					draw_set_transform(pos, float(p["ang"]), Vector2.ONE)
					if shape == Shape.SHARD:
						var tri := PackedVector2Array([Vector2(-size.x, size.y * 0.5), Vector2(size.x, 0.0),
								Vector2(-size.x * 0.3, -size.y)])
						draw_colored_polygon(tri, c)
						draw_polyline(PackedVector2Array([tri[0], tri[1], tri[2], tri[0]]),
								Color(1.0, 1.0, 1.0, 0.5 * fade), 1.0)
					elif shape == Shape.SLAT:
						draw_rect(Rect2(-size * 0.5, size), c)
						draw_rect(Rect2(-size * 0.5, size), Color(0.02, 0.01, 0.0, 0.6 * fade), false, 1.0)
					else:
						draw_rect(Rect2(-size * 0.5, size), c)
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _make_debris() -> Debris:
	var d := Debris.new()
	_ground_y = _find_ground()
	d.ground = _ground_y
	d.z_index = 2
	add_child(d)
	return d


func _fly(rng: RandomNumberGenerator, dir: Vector2, power: float = 1.0) -> Vector2:
	var side := signf(dir.x) if dir.x != 0.0 else 1.0
	return Vector2(side * rng.randf_range(20.0, 150.0) * power + rng.randf_range(-70.0, 70.0),
			-rng.randf_range(60.0, 260.0) * power)


func _add_glass(d: Debris, at: Vector2, dir: Vector2, rng: RandomNumberGenerator, power: float) -> void:
	var s := rng.randf_range(2.5, 6.0)
	d.add(Debris.Shape.SHARD, at + Vector2(rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0)),
			_fly(rng, dir, power), Vector2(s, s * 0.8), GLASS_SHARD, rng.randf_range(1.8, 2.6),
			rng.randf_range(-12.0, 12.0))


func _add_metal_bit(d: Debris, at: Vector2, dir: Vector2, rng: RandomNumberGenerator, color: Color = STEEL_LIGHT) -> void:
	var s := rng.randf_range(2.0, 4.5)
	var c := color.darkened(rng.randf_range(0.0, 0.45))
	d.add(Debris.Shape.SPECK if rng.randf() < 0.6 else Debris.Shape.SHARD,
			at + Vector2(rng.randf_range(-8.0, 8.0), rng.randf_range(-8.0, 8.0)),
			_fly(rng, dir, 0.9), Vector2(s, s), c, rng.randf_range(1.6, 2.4), rng.randf_range(-14.0, 14.0))


func _add_wood_bit(d: Debris, at: Vector2, dir: Vector2, rng: RandomNumberGenerator, plank: bool) -> void:
	var dims := Vector2(rng.randf_range(11.0, 19.0), rng.randf_range(3.5, 5.0)) if plank \
			else Vector2(rng.randf_range(2.0, 4.0), rng.randf_range(2.0, 4.0))
	var c := [WOOD, WOOD_DARK, WOOD_LIGHT][rng.randi() % 3] as Color
	d.add(Debris.Shape.SLAT if plank else Debris.Shape.SPECK,
			at + Vector2(rng.randf_range(-12.0, 12.0), rng.randf_range(-8.0, 8.0)),
			_fly(rng, dir, 0.8), dims, c, rng.randf_range(2.0, 2.8), rng.randf_range(-9.0, 9.0))


func _add_sparks(d: Debris, at: Vector2, rng: RandomNumberGenerator, count: int, color: Color) -> void:
	for i in count:
		var ang := rng.randf_range(-PI, 0.0)
		d.add(Debris.Shape.SPARK, at, Vector2.from_angle(ang) * rng.randf_range(60.0, 210.0),
				Vector2.ONE, color, rng.randf_range(0.22, 0.45))


func _add_puff(d: Debris, at: Vector2, rng: RandomNumberGenerator, color: Color, radius: float) -> void:
	for i in 2:
		d.add(Debris.Shape.PUFF, at + Vector2(rng.randf_range(-6.0, 6.0), 0.0),
				Vector2(rng.randf_range(-14.0, 14.0), -rng.randf_range(10.0, 28.0)),
				Vector2(radius * rng.randf_range(0.7, 1.1), 0.0), color, rng.randf_range(0.7, 1.0))


## A gauge's burst: a column of steam that rises and thins out.
func _add_steam(d: Debris, rng: RandomNumberGenerator, reduced: bool) -> void:
	var at := Vector2(0.0, -effective_size().y * 0.55)
	for i in (3 if reduced else 6):
		d.add(Debris.Shape.PUFF, at + Vector2(rng.randf_range(-3.0, 3.0), -i * 3.0),
				Vector2(rng.randf_range(-18.0, 18.0), -rng.randf_range(30.0, 62.0)),
				Vector2(rng.randf_range(7.0, 11.0), 0.0), Color(0.93, 0.96, 1.0, 0.55),
				rng.randf_range(0.7, 1.1 if not reduced else 0.8))


func _glass_burst(d: Debris, rng: RandomNumberGenerator, dir: Vector2, count: int, whole: bool) -> void:
	var r := _rect()
	for i in (int(count * 0.6) if _reduced() else count):
		var at := Vector2(rng.randf_range(r.position.x, r.end.x), rng.randf_range(r.position.y, r.end.y)) \
				if whole else r.get_center()
		_add_glass(d, at, dir, rng, 1.0)


# --- drawing -----------------------------------------------------------------------------------

## The painted piece for this stage, or "" (the stand-in draws).
func painted_piece() -> String:
	var base := piece if piece != "" else kind_name()
	var candidate := base
	match stage():
		Stage.CRACKED:
			candidate = base + "_cracked"
		Stage.BROKEN:
			candidate = base + "_broken"
	return candidate if LabSkins.has(candidate) else ""


func _draw() -> void:
	if not is_inside_tree():
		return
	var r := _rect()
	var current := stage()
	draw_set_transform(Vector2(_jolt * _jolt_dir, 0.0), 0.0, Vector2.ONE)
	var painted := painted_piece()
	if painted != "":
		LabSkins.draw(self, painted)
	else:
		match kind:
			Kind.GLASS_PANEL:
				_draw_glass_panel(current, r)
			Kind.MONITOR:
				_draw_monitor(current, r)
			Kind.SERVER_CABINET:
				_draw_cabinet(current, r)
			Kind.CRATE:
				_draw_crate(current, r)
			Kind.GAUGE:
				_draw_gauge(current, r)
			Kind.VENT_PANEL:
				_draw_vent(current, r)
			Kind.DISPLAY_CASE:
				_draw_case(current, r)
	if _flash > 0.0 and current != Stage.BROKEN:
		draw_rect(r, Color(0.9, 0.97, 1.0, 0.3 * _flash * (0.5 if _reduced() else 1.0)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _ellipse(c: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)


func _shadow(r: Rect2) -> void:
	_ellipse(Vector2(0.0, 1.0), r.size.x * 0.58, 3.5, Color(0.0, 0.0, 0.0, 0.3))


## Cracks spreading from each place the prop was hit: radial lines with a kink, and two
## partial rings, clamped to `r`.
func _draw_cracks(r: Rect2, light: Color = CRACK_LIGHT, reach: float = 1.0) -> void:
	for i in _crack_points.size():
		var c := _crack_points[i]
		var rng := _rng(100 + i)
		var rays := 7
		for j in rays:
			var ang := TAU * j / rays + rng.randf_range(-0.3, 0.3)
			var length := rng.randf_range(14.0, 34.0) * reach
			var mid := c + Vector2.from_angle(ang) * length * 0.5
			var end := c + Vector2.from_angle(ang + rng.randf_range(-0.35, 0.35)) * length
			mid = _clamp_to(r, mid)
			end = _clamp_to(r, end)
			draw_polyline(PackedVector2Array([c, mid, end]), CRACK_DARK, 2.6)
			draw_polyline(PackedVector2Array([c, mid, end]), light, 1.1)
		for ring in 2:
			var rr := 6.0 + ring * 7.0
			var start := rng.randf_range(0.0, TAU)
			var pts := PackedVector2Array()
			for k in 6:
				pts.append(_clamp_to(r, c + Vector2.from_angle(start + k * 0.55) * rr * rng.randf_range(0.9, 1.1)))
			draw_polyline(pts, Color(light.r, light.g, light.b, light.a * 0.6), 1.0)


func _clamp_to(r: Rect2, p: Vector2) -> Vector2:
	return Vector2(clampf(p.x, r.position.x + 1.0, r.end.x - 1.0), clampf(p.y, r.position.y + 1.0, r.end.y - 1.0))


## Shards lying along the base, the same every time this prop is drawn.
func _draw_pile(r: Rect2, count: int, spread: float = 0.9, color: Color = GLASS_SHARD) -> void:
	var rng := _rng(300)
	for i in count:
		var x := rng.randf_range(-r.size.x * spread, r.size.x * spread)
		var s := rng.randf_range(2.5, 6.5)
		var tri := PackedVector2Array([Vector2(x, 0.5), Vector2(x + s * 1.4, 0.5), Vector2(x + s * rng.randf_range(0.2, 1.0), -s)])
		draw_colored_polygon(tri, color)
		draw_polyline(PackedVector2Array([tri[0], tri[2], tri[1]]), Color(1.0, 1.0, 1.0, 0.55), 1.0)


func _draw_glass_panel(stage_now: int, r: Rect2) -> void:
	var jamb := 3.0
	var rail := 5.0
	if stage_now != Stage.BROKEN:
		draw_rect(r, GLASS_FILL)
		draw_rect(Rect2(r.position, Vector2(r.size.x, r.size.y * 0.35)), Color(1.0, 1.0, 1.0, 0.05))
		# The glints sliding across a pane.
		for i in 3:
			var y0 := r.position.y + r.size.y * (0.14 + 0.27 * i)
			var band := PackedVector2Array([Vector2(r.position.x, y0 + r.size.x * 0.8), Vector2(r.end.x, y0),
					Vector2(r.end.x, y0 + 7.0), Vector2(r.position.x, y0 + r.size.x * 0.8 + 7.0)])
			draw_colored_polygon(band, Color(1.0, 1.0, 1.0, 0.16 if i == 1 else 0.1))
		draw_rect(r, GLASS_EDGE, false, 1.5)
	else:
		# The teeth left in the frame.
		var rng := _rng(200)
		for side in [-1.0, 1.0]:
			var x: float = (r.position.x + jamb) if side < 0.0 else (r.end.x - jamb)
			var y := r.position.y + rail + 4.0
			while y < -rail - 6.0:
				var h := rng.randf_range(5.0, 12.0)
				var w := rng.randf_range(2.0, 5.0)
				draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x - side * w, y + h * 0.5), Vector2(x, y + h)]), GLASS_SHARD)
				y += h + rng.randf_range(4.0, 14.0)
	# The frame: rails top and bottom, a jamb each side.
	var steel := STEEL_LIGHT if stage_now != Stage.BROKEN else STEEL
	for rr in [Rect2(r.position.x - 1.0, r.position.y - 2.0, r.size.x + 2.0, rail),
			Rect2(r.position.x - 1.0, -rail, r.size.x + 2.0, rail)]:
		draw_rect(rr, steel)
		draw_rect(rr, OUTLINE, false, 1.5)
	for jx in [r.position.x - 1.0, r.end.x - jamb + 1.0]:
		draw_rect(Rect2(jx, r.position.y, jamb, r.size.y), steel)
		draw_rect(Rect2(jx, r.position.y, jamb, r.size.y), OUTLINE, false, 1.0)
	if stage_now == Stage.CRACKED:
		_draw_cracks(r)
	elif stage_now == Stage.BROKEN:
		_draw_pile(r, 14, 1.0)


func _draw_monitor(stage_now: int, r: Rect2) -> void:
	_shadow(r)
	var screen := Rect2(r.position, Vector2(r.size.x, r.size.y - 8.0))
	# Neck and foot.
	draw_rect(Rect2(-4.0, -8.0, 8.0, 5.0), STEEL)
	draw_rect(Rect2(-r.size.x * 0.3, -3.5, r.size.x * 0.6, 3.5), STEEL_LIGHT)
	draw_rect(Rect2(-r.size.x * 0.3, -3.5, r.size.x * 0.6, 3.5), OUTLINE, false, 1.0)
	draw_rect(screen.grow(1.5), OUTLINE)
	draw_rect(screen, STEEL_DARK)
	var glass := screen.grow(-3.0)
	match stage_now:
		Stage.INTACT:
			draw_rect(glass, Color("#0C3A44"))
			for i in 4:
				var bw := glass.size.x * (0.35 + 0.12 * ((i * 5) % 4))
				draw_rect(Rect2(glass.position + Vector2(3.0, 3.0 + i * 5.0), Vector2(bw, 2.0)), Color(TEAL, 0.85))
			draw_polyline(PackedVector2Array([glass.position + Vector2(glass.size.x * 0.55, glass.size.y - 4.0),
					glass.position + Vector2(glass.size.x * 0.68, glass.size.y - 9.0),
					glass.position + Vector2(glass.size.x * 0.8, glass.size.y - 6.0),
					glass.position + Vector2(glass.size.x - 3.0, glass.size.y - 12.0)]), Color(AMBER, 0.9), 1.2)
			for y in range(int(glass.position.y), int(glass.end.y), 3):
				draw_line(Vector2(glass.position.x, y), Vector2(glass.end.x, y), Color(0.0, 0.0, 0.0, 0.18), 1.0)
			draw_rect(glass, Color(1.0, 1.0, 1.0, 0.07), false, 1.0)
		Stage.CRACKED:
			draw_rect(glass, Color("#0A2E38"))
			# Static: dropped rows and a torn band.
			var rng := _rng(400)
			for i in 6:
				var y := glass.position.y + rng.randf_range(0.0, glass.size.y - 2.0)
				draw_rect(Rect2(glass.position.x, y, glass.size.x * rng.randf_range(0.3, 1.0), rng.randf_range(1.0, 2.5)),
						Color(0.7, 0.95, 1.0, 0.5))
			draw_rect(Rect2(glass.position.x + 3.0, glass.position.y + 3.0, glass.size.x * 0.4, 2.0), Color(TEAL, 0.55))
			_draw_cracks(glass, CRACK_LIGHT, 0.8)
		_:
			draw_rect(glass, INNER_DARK)
			_ellipse(glass.get_center() + Vector2(3.0, 2.0), glass.size.x * 0.3, glass.size.y * 0.3, Color(0.0, 0.0, 0.0, 0.5))
			_draw_cracks(glass, Color(CRACK_LIGHT, 0.55), 0.9)
			var g := glow_level()
			if g > 0.0:
				draw_rect(glass, Color(0.75, 0.97, 1.0, 0.8 * g))


func _draw_cabinet(stage_now: int, r: Rect2) -> void:
	_shadow(r)
	draw_rect(r.grow(2.0), OUTLINE)
	draw_rect(r, STEEL_DARK)
	var door := r.grow(-4.0)
	if stage_now == Stage.BROKEN:
		draw_rect(door, INNER_DARK)
		# Empty bays and dead lights.
		for i in 5:
			var y := door.position.y + 8.0 + i * 17.0
			draw_rect(Rect2(door.position.x + 3.0, y, door.size.x - 6.0, 9.0), Color("#101826"))
			draw_rect(Rect2(door.end.x - 10.0, y + 3.0, 3.0, 3.0), Color("#1E2736"))
		draw_rect(Rect2(door.position, Vector2(door.size.x, door.size.y * 0.45)), Color(0.0, 0.0, 0.0, 0.3))
		# Scorch above.
		_ellipse(Vector2(0.0, door.position.y + 8.0), door.size.x * 0.4, 8.0, Color(0.0, 0.0, 0.0, 0.3))
		# The door, hanging off its hinge and sagging.
		var l := r.position.x
		var t := r.position.y
		var panel := PackedVector2Array([Vector2(l + 2.0, t + 4.0), Vector2(l + 2.0, -8.0),
				Vector2(l - 17.0, -3.0), Vector2(l - 14.0, t + 14.0)])
		draw_colored_polygon(panel, STEEL)
		draw_polyline(PackedVector2Array([panel[0], panel[1], panel[2], panel[3], panel[0]]), OUTLINE, 1.5)
		draw_line(Vector2(l - 11.0, t + 22.0), Vector2(l - 11.0, -14.0), STEEL_LIGHT, 1.0)
		return
	draw_rect(door, STEEL)
	draw_rect(door, OUTLINE, false, 1.0)
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 4.0), STEEL_LIGHT)
	# Vent slits and rows of status lights.
	for i in 7:
		var y := door.position.y + 6.0 + i * 3.5
		draw_line(Vector2(door.position.x + 5.0, y), Vector2(door.end.x - 14.0, y), Color(0.0, 0.0, 0.0, 0.6), 1.5)
	var dead := stage_now == Stage.CRACKED
	for row in 6:
		for col in 2:
			var lit := Color(TEAL, 0.95) if (row + col * 2) % 3 != 0 else Color(AMBER, 0.95)
			if dead and (row * 2 + col) % 3 == 1:
				lit = Color("#1E2736")
			draw_rect(Rect2(door.end.x - 12.0 + col * 5.0, door.position.y + 34.0 + row * 8.0, 3.0, 3.0), lit)
	draw_rect(Rect2(door.position.x + 5.0, door.position.y + 36.0, 14.0, 18.0), Color(0.0, 0.0, 0.0, 0.25))
	draw_rect(Rect2(door.position.x + 4.0, door.end.y - 18.0, 3.0, 12.0), STEEL_LIGHT)
	if dead:
		# A dent running across the door, and a seam burst open.
		var dent := PackedVector2Array([Vector2(door.position.x, door.position.y + 44.0), Vector2(door.end.x, door.position.y + 30.0),
				Vector2(door.end.x, door.position.y + 38.0), Vector2(door.position.x, door.position.y + 54.0)])
		draw_colored_polygon(dent, Color(0.0, 0.0, 0.0, 0.32))
		draw_line(dent[0], dent[1], Color(STEEL_LIGHT, 0.9), 1.5)
		draw_line(Vector2(door.end.x - 8.0, door.position.y + 28.0), Vector2(door.end.x - 5.0, door.position.y + 40.0), INNER_DARK, 2.0)


func _draw_crate(stage_now: int, r: Rect2) -> void:
	_shadow(r)
	if stage_now == Stage.BROKEN:
		var rng := _rng(500)
		# What is left standing: a ragged low box, planks fallen across it and along the floor.
		var low := Rect2(r.position.x + 4.0, -15.0, r.size.x - 8.0, 15.0)
		draw_rect(low, WOOD_DARK)
		for i in 3:
			var x := low.position.x + i * low.size.x / 3.0
			var top := -15.0 - rng.randf_range(2.0, 10.0)
			draw_colored_polygon(PackedVector2Array([Vector2(x, -15.0), Vector2(x + 3.0, top), Vector2(x + 7.0, -15.0 - rng.randf_range(0.0, 4.0)),
					Vector2(x + low.size.x / 3.0, -15.0)]), WOOD)
		draw_rect(Rect2(low.position, Vector2(low.size.x, 4.0)), WOOD)
		draw_rect(low, OUTLINE, false, 1.5)
		for i in 4:
			var cx := rng.randf_range(r.position.x + 6.0, r.end.x - 6.0)
			var ang := rng.randf_range(-0.6, 0.6) + (PI * 0.5 if i == 0 else 0.0)
			var cy := -15.0 - rng.randf_range(2.0, 8.0) if i < 2 else -2.0
			var half := Vector2(rng.randf_range(10.0, 16.0), 2.2)
			draw_set_transform(Vector2(cx + _jolt * _jolt_dir, cy), ang, Vector2.ONE)
			draw_rect(Rect2(-half, half * 2.0), [WOOD_LIGHT, WOOD, WOOD_DARK][i % 3])
			draw_rect(Rect2(-half, half * 2.0), OUTLINE, false, 1.0)
			draw_set_transform(Vector2(_jolt * _jolt_dir, 0.0), 0.0, Vector2.ONE)
		return
	draw_rect(r.grow(1.5), OUTLINE)
	var planks := 3
	var ph := r.size.y / planks
	for i in planks:
		var pr := Rect2(r.position.x, r.position.y + i * ph, r.size.x, ph)
		if stage_now == Stage.CRACKED and i == 0:
			pr.position += Vector2(2.5, -1.0)   # the top plank has slipped
		draw_rect(pr, [WOOD, WOOD_LIGHT, WOOD][i % 3].darkened(0.1 * (i % 2)))
		draw_line(pr.position, Vector2(pr.end.x, pr.position.y), Color(0.0, 0.0, 0.0, 0.6), 1.5)
		draw_line(pr.position + Vector2(0.0, 1.5), Vector2(pr.end.x, pr.position.y + 1.5), Color(1.0, 0.85, 0.65, 0.18), 1.0)
	# Corner posts and a brace.
	for px in [r.position.x, r.end.x - 7.0]:
		draw_rect(Rect2(px, r.position.y, 7.0, r.size.y), WOOD_DARK)
		for ny in [r.position.y + 5.0, r.end.y - 6.0]:
			draw_circle(Vector2(px + 3.5, ny), 1.2, Color(0.8, 0.75, 0.65, 0.8))
	draw_line(r.position + Vector2(7.0, r.size.y - 4.0), Vector2(r.end.x - 7.0, r.position.y + 4.0), Color(WOOD_DARK, 0.9), 3.0)
	# A stencilled arch mark.
	var c := r.get_center() + Vector2(0.0, 1.0)
	draw_arc(c + Vector2(0.0, 4.0), 7.0, PI, TAU, 10, Color(1.0, 0.7, 0.4, 0.55), 2.0)
	if stage_now == Stage.CRACKED:
		var rng := _rng(501)
		var pts := PackedVector2Array()
		var x := r.position.x + 9.0
		var y := r.position.y + 2.0
		while y < -2.0:
			pts.append(Vector2(x, y))
			x += rng.randf_range(-6.0, 6.0)
			y += rng.randf_range(6.0, 10.0)
		pts.append(Vector2(x, -2.0))
		draw_polyline(pts, Color(0.02, 0.01, 0.0, 0.85), 2.4)
		draw_polyline(pts, Color(1.0, 0.82, 0.6, 0.45), 1.0)


func _draw_gauge(stage_now: int, r: Rect2) -> void:
	var c := Vector2(0.0, -r.size.y * 0.55)
	var rad := r.size.x * 0.43
	# The pipe stub it sits on.
	draw_rect(Rect2(-4.5, c.y + rad - 2.0, 9.0, -c.y - rad + 2.0), STEEL)
	draw_rect(Rect2(-4.5, c.y + rad - 2.0, 9.0, -c.y - rad + 2.0), OUTLINE, false, 1.0)
	draw_rect(Rect2(-8.0, -4.0, 16.0, 4.0), STEEL_LIGHT)
	draw_circle(c, rad + 2.0, OUTLINE)
	draw_circle(c, rad, BRASS)
	draw_arc(c, rad - 1.0, PI * 1.1, PI * 1.9, 10, Color(1.0, 0.9, 0.6, 0.5), 1.5)
	if stage_now != Stage.BROKEN:
		draw_circle(c, rad - 3.5, DIAL)
		# Ticks round the dial, the last two in amber, and the needle.
		for i in 9:
			var a := PI * 0.8 + i * (PI * 1.4 / 8.0)
			draw_line(c + Vector2.from_angle(a) * (rad - 5.5), c + Vector2.from_angle(a) * (rad - 8.5),
					AMBER if i >= 7 else Color("#2A3A50"), 1.4)
		var na := PI * 0.8 + 6.2 * (PI * 1.4 / 8.0)
		draw_line(c, c + Vector2.from_angle(na) * (rad - 6.0), Color("#C9461F"), 1.8)
		draw_circle(c, 1.8, OUTLINE)
		draw_arc(c, rad - 5.0, PI * 1.15, PI * 1.5, 8, Color(1.0, 1.0, 1.0, 0.55), 1.4)
	else:
		draw_circle(c, rad - 3.5, INNER_DARK)
		# Teeth of glass left in the bezel, and the bent needle.
		for i in 7:
			var a := TAU * i / 7.0 + 0.2
			var p0 := c + Vector2.from_angle(a) * (rad - 3.5)
			draw_colored_polygon(PackedVector2Array([p0 + Vector2.from_angle(a + 1.5) * 2.0, p0 + Vector2.from_angle(a - 1.5) * 2.0,
					c + Vector2.from_angle(a) * (rad - 7.5)]), Color(GLASS_SHARD, 0.8))
		draw_polyline(PackedVector2Array([c + Vector2(-1.0, -1.0), c + Vector2(4.0, 3.0), c + Vector2(2.0, 8.0)]), Color("#C9461F"), 1.6)
		# A wet streak below, and glass on the ledge.
		draw_rect(Rect2(-1.5, c.y + rad, 3.0, 6.0), Color(0.6, 0.75, 0.85, 0.25))
		_draw_pile(Rect2(r.position.x, -4.0, r.size.x, 4.0), 5, 0.5)


func _draw_vent(stage_now: int, r: Rect2) -> void:
	draw_rect(r.grow(2.0), OUTLINE)
	draw_rect(r, STEEL)
	var inner := r.grow(-4.0)
	draw_rect(inner, INNER_DARK)
	if stage_now == Stage.BROKEN:
		# The grille is gone: a dark opening, bent louver stubs and one corner still screwed on.
		draw_rect(Rect2(inner.position, Vector2(inner.size.x, inner.size.y * 0.5)), Color(0.0, 0.0, 0.0, 0.35))
		for i in 3:
			var y := inner.position.y + 3.0 + i * 5.5
			draw_polyline(PackedVector2Array([Vector2(inner.position.x, y), Vector2(inner.position.x + 8.0 + i * 3.0, y + 3.0 + i)]),
					STEEL_LIGHT, 2.0)
		var corner := PackedVector2Array([Vector2(r.end.x - 2.0, r.position.y + 2.0), Vector2(r.end.x - 15.0, r.position.y + 2.0),
				Vector2(r.end.x - 2.0, r.position.y + 15.0)])
		draw_colored_polygon(corner, STEEL_LIGHT)
		draw_polyline(PackedVector2Array([corner[0], corner[1], corner[2], corner[0]]), OUTLINE, 1.0)
		draw_circle(Vector2(r.end.x - 5.0, r.position.y + 5.0), 1.5, OUTLINE)
		return
	var cracked_now := stage_now == Stage.CRACKED
	for i in 5:
		var y := inner.position.y + 3.0 + i * ((inner.size.y - 6.0) / 4.0)
		var droop := 0.0
		var x1 := inner.end.x
		if cracked_now and i == 1:
			droop = 3.5   # a louver bent down at one end
		if cracked_now and i == 3:
			x1 = inner.end.x - 12.0
		draw_line(Vector2(inner.position.x, y), Vector2(x1, y + 3.0 + droop), Color(0.0, 0.0, 0.0, 0.7), 4.0)
		draw_line(Vector2(inner.position.x, y - 1.0), Vector2(x1, y + 2.0 + droop), STEEL_LIGHT, 2.0)
	# Screws; one is gone and its corner lifts.
	for corner_pos in [r.position + Vector2(4.0, 4.0), Vector2(r.end.x - 4.0, r.position.y + 4.0),
			Vector2(r.position.x + 4.0, -4.0), Vector2(r.end.x - 4.0, -4.0)]:
		if cracked_now and corner_pos.x > 0.0 and corner_pos.y < r.position.y + 8.0:
			draw_circle(corner_pos, 1.8, INNER_DARK)
		else:
			draw_circle(corner_pos, 1.6, STEEL_LIGHT)
	if cracked_now:
		draw_line(Vector2(r.end.x - 3.0, r.position.y + 6.0), Vector2(r.end.x - 14.0, r.position.y + 8.0), INNER_DARK, 2.0)


func _draw_case(stage_now: int, r: Rect2) -> void:
	_shadow(r)
	var ped := Rect2(r.position.x, -16.0, r.size.x, 16.0)
	var box := Rect2(r.position.x + 2.0, r.position.y, r.size.x - 4.0, r.size.y - 16.0)
	draw_rect(ped.grow(1.5), OUTLINE)
	draw_rect(ped, STEEL)
	draw_rect(Rect2(ped.position, Vector2(ped.size.x, 3.0)), STEEL_LIGHT)
	draw_rect(Rect2(ped.position.x + 4.0, ped.end.y - 5.0, ped.size.x - 8.0, 2.0), Color(TEAL, 0.8))
	# What is displayed: two pistols on a dark velvet bed.
	draw_rect(Rect2(box.position.x + 3.0, box.end.y - 8.0, box.size.x - 6.0, 8.0), Color("#1B2540"))
	for i in 2:
		var px := box.position.x + 8.0 + i * (box.size.x * 0.45)
		draw_rect(Rect2(px, box.end.y - 15.0, 16.0, 5.0), Color("#0E1118"))
		draw_rect(Rect2(px, box.end.y - 11.0, 6.0, 9.0), Color("#0E1118"))
		draw_line(Vector2(px + 1.0, box.end.y - 14.0), Vector2(px + 15.0, box.end.y - 14.0), Color(0.7, 0.78, 0.86, 0.6), 1.0)
	if stage_now != Stage.BROKEN:
		draw_rect(box, GLASS_FILL)
		for i in 2:
			var y0 := box.position.y + 4.0 + i * 18.0
			draw_colored_polygon(PackedVector2Array([Vector2(box.position.x, y0 + 14.0), Vector2(box.end.x, y0),
					Vector2(box.end.x, y0 + 6.0), Vector2(box.position.x, y0 + 20.0)]), Color(1.0, 1.0, 1.0, 0.1))
		draw_rect(box, GLASS_EDGE, false, 1.5)
	# The frame's corner posts and top.
	var frame := STEEL_LIGHT if stage_now != Stage.BROKEN else STEEL
	draw_rect(Rect2(box.position.x - 1.0, box.position.y - 2.0, box.size.x + 2.0, 3.0), frame)
	for px in [box.position.x - 1.0, box.end.x - 2.0]:
		draw_rect(Rect2(px, box.position.y, 3.0, box.size.y), frame)
	if stage_now == Stage.CRACKED:
		_draw_cracks(box)
	elif stage_now == Stage.BROKEN:
		# Teeth in the corners, shards on the velvet and the pedestal top.
		var rng := _rng(600)
		for side in [-1.0, 1.0]:
			var x: float = (box.position.x + 2.0) if side < 0.0 else (box.end.x - 2.0)
			for k in 3:
				var y := box.position.y + 5.0 + k * 12.0
				draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x - side * rng.randf_range(2.0, 4.0), y + 4.0),
						Vector2(x, y + 8.0)]), GLASS_SHARD)
		_draw_pile(Rect2(r.position.x, 0.0, r.size.x, 1.0), 10, 1.0)
		for i in 5:
			var sx := rng.randf_range(box.position.x + 4.0, box.end.x - 6.0)
			var s := rng.randf_range(2.5, 5.0)
			draw_colored_polygon(PackedVector2Array([Vector2(sx, box.end.y), Vector2(sx + s * 1.4, box.end.y), Vector2(sx + s * 0.6, box.end.y - s)]), GLASS_SHARD)
