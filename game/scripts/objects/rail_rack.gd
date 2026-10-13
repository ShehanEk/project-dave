extends MovingPlatform
## Level 2's A04 lockdown lanes (M2, C59 "Adam's lockdown"): a sliding
## server-rack platform on a floor rail across a cable trench. It waits at
## the near bank (`point_a`) until Dave uses that lane's control pad (a
## RouteSwitch that sets `switch_id` in Session), warns for `warn_time` (amber
## rail lamps chase, the chime plays and `move_warned` carries the caption),
## then crosses ONCE to the far bank (`point_b`) and stays docked there; its
## far-bank glass partition (lane_partition.gd) slides open as it arrives.
##
## It never closes on Dave: where MovingPlatform turns back from anything in
## its way, this holds still while the way is blocked (Dave in the trench at
## the far bank, or anything else) and moves on as soon as it clears. It rides
## below the floor line, so it never sweeps the banks Dave stands on.
##
## Like every world object it decides its state in `_ready()` from Session: a
## level built (or rebuilt after a death) with the switch already on starts
## docked at the far bank. No `class_name` (import-cache rule): tests and the
## partition reach it by path and by its signals.

## The chime/caption hook: emitted as the warning starts (M5 writes the lines
## and decides who says them). `caption` is the lane's own placeholder line.
signal move_warned(caption: String)
signal move_started
signal arrived

enum Phase { WAITING, WARNING, MOVING, DOCKED }

## Batch 7: the painted floor-rail segment with its lamps (scripts/world/lab_skins.gd
## "rail_lamps") runs under the deck from bank to bank, its lamp bays repeated; the lamps' state
## colours are lit over its painted lenses (made a neutral glass on import).
const LabSkins := preload("res://scripts/world/lab_skins.gd")
## The painted rail's foot sits this far under the code-drawn lamps' line.
const RAIL_FOOT := 10.0

const AMBER := Color("#FFB02E")
const TEAL := Color("#3FE0D0")
const LAMP_OFF := Color(1.0, 0.69, 0.18, 0.28)
## Rail lamps sit along the trench under the rack's deck, this far below it.
const LAMP_DROP := 14.0
## How long the caption stays up (when there is a subtitle panel).
const CAPTION_HOLD := 3.0
## The chase: one lamp lit after the other, this many steps a second (under 2 Hz
## per lamp, never a flash).
const CHASE_HZ := 6.0

## Session switch set by this lane's control pad ("L02-SW01").
@export var switch_id: String = ""
## Seconds of warning (lamps and chime) between the pad and the move.
@export var warn_time: float = 1.0
## The caption shown as the move is announced ("" = none); the speaker tag.
@export var caption: String = ""
@export var caption_speaker: String = "Training cells"
## How many amber lamps line the rail (the code-drawn rail; the painted rail has a lamp every
## bay of its own, as many as fit between the banks).
@export var lamp_count: int = 5

var phase: int = Phase.WAITING
## True while something is in the rack's way and it is holding still.
var blocked: bool = false
var _warn_t: float = 0.0
var _clock: float = 0.0
## Where the rack was when the rail was last drawn: the rail is fixed in the world, drawn in the
## rack's space, so a rack that settles after its first draw (a docked one: its physics-synced
## position lands a frame later) draws it again.
var _drawn_at := Vector2(INF, INF)


func _ready() -> void:
	super()
	_dir = 1
	if _switch_on():
		# Already used before this (re)build: docked at the far bank, partition open.
		_progress = 1.0
		position = point_b
		phase = Phase.DOCKED
	queue_redraw()


func _switch_on() -> bool:
	return switch_id != "" and Session != null and Session.get_switch(switch_id)


func is_docked() -> bool:
	return phase == Phase.DOCKED


func _physics_process(delta: float) -> void:
	_clock += delta
	match phase:
		Phase.WAITING:
			if _switch_on():
				_begin_warning()
		Phase.WARNING:
			_warn_t -= delta
			if _warn_t <= 0.0:
				phase = Phase.MOVING
				move_started.emit()
		Phase.MOVING:
			_step(delta)
	if phase != Phase.DOCKED or blocked or position != _drawn_at:
		queue_redraw()


func _begin_warning() -> void:
	phase = Phase.WARNING
	_warn_t = warn_time
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"adam_chime", global_position)
	move_warned.emit(caption)
	_show_caption()


func _show_caption() -> void:
	if caption == "" or not is_inside_tree():
		return
	var subtitles := get_tree().get_first_node_in_group("subtitle_panel")
	if subtitles == null:
		return
	subtitles.say(caption_speaker, caption)
	# A method connection (not an await) so a rack freed by a rebuild meanwhile
	# simply drops it.
	get_tree().create_timer(CAPTION_HOLD, false).timeout.connect(_clear_caption.bind(subtitles))


func _clear_caption(subtitles: Node) -> void:
	if is_instance_valid(subtitles) and subtitles.current_line() == caption:
		subtitles.clear_line()


## True while anything solid or Dave is in the stretch the rack would sweep
## next: the deck's own cross-section, from its leading edge up to (never
## past) its far-bank dock, cast in WORLD space (the area may sit anywhere in
## the level). It ignores what only touches the deck's top or bottom face (Dave
## riding it, the bank above the dock).
func is_way_blocked() -> bool:
	var remaining := position.distance_to(point_b)
	if remaining < 1.0 or not is_inside_tree():
		return false
	var dir_vec := (point_b - point_a).normalized()
	var reach: float = absf(dir_vec.x) * (width * 0.5) + absf(dir_vec.y) * (thickness * 0.5)
	# Stop 1 px short of the dock: the far bank's own side is not "in the way".
	var look: float = minf(speed * 0.25 + 12.0, remaining) - 2.0
	if look <= 0.5:
		return false
	var rect := RectangleShape2D.new()
	rect.size = Vector2(look, maxf(thickness - 4.0, 2.0)) if absf(dir_vec.x) >= absf(dir_vec.y) \
			else Vector2(maxf(width - 4.0, 2.0), look)
	var centre_local := position + dir_vec * (reach + 1.0 + look * 0.5)
	var parent_2d := get_parent() as Node2D
	var centre := parent_2d.to_global(centre_local) if parent_2d else centre_local
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = rect
	params.transform = Transform2D(0.0, centre)
	params.collision_mask = 1 | 2
	params.exclude = [get_rid()]
	return not get_world_2d().direct_space_state.intersect_shape(params, 1).is_empty()


func _step(delta: float) -> void:
	var span := point_a.distance_to(point_b)
	_dir = 1
	blocked = span > 0.001 and is_way_blocked()
	if blocked:
		return
	_progress = 1.0 if span <= 0.001 else minf(1.0, _progress + speed * delta / span)
	position = point_a.lerp(point_b, _progress)
	if _progress >= 1.0:
		phase = Phase.DOCKED
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"latch", global_position)
		arrived.emit()
		queue_redraw()


func _draw() -> void:
	super()
	_drawn_at = position
	# The rail lamps, fixed in the world along the trench under the deck:
	# dim amber while the lane waits, a chasing amber run while it warns and
	# moves, steady amber while it holds for Dave, teal once docked.
	var y := thickness * 0.5 + LAMP_DROP
	var x0 := point_a.x - width * 0.5 + 12.0
	var x1 := point_b.x + width * 0.5 - 12.0
	var origin := Vector2(-position.x, point_a.y - position.y)
	var lamps: Array = rail_lamps(x0, x1, y)
	var painted := LabSkins.has("rail_lamps")
	if painted:
		_draw_painted_rail(x0, x1, y, origin)
	var n := lamps.size()
	var lit := int(floor(_clock * CHASE_HZ)) % maxi(n, 1)
	for i in n:
		var p: Vector2 = lamps[i] + origin
		var c := LAMP_OFF
		match phase:
			Phase.WARNING, Phase.MOVING:
				c = AMBER if (blocked or i == lit or i == (lit + 1) % n) else LAMP_OFF
			Phase.DOCKED:
				c = TEAL
		draw_circle(p, 7.0, Color(c, c.a * 0.22))
		if painted:
			var ls: Array = LabSkins.value("rail_lamps", "lens_size", [20, 12])
			var half := Vector2(float(ls[0]), float(ls[1])) * LabSkins.scale("rail_lamps") * 0.5
			draw_rect(Rect2(p - half, half * 2.0), Color(c, minf(1.0, c.a * 1.6)))
		else:
			draw_circle(p, 3.0, c)


## The rail lamps' positions (parent-local x, y from point_a's line) between x0 and x1: the
## painted rail's lenses when it exists, else `lamp_count` evenly spaced.
func rail_lamps(x0: float, x1: float, y: float) -> Array:
	var out: Array = []
	if LabSkins.has("rail_lamps"):
		var lay := _rail_layout(x0, x1)
		var sc: float = LabSkins.scale("rail_lamps")
		var lamps: Array = LabSkins.value("rail_lamps", "lamps", [])
		var th: float = float(LabSkins.entry("rail_lamps")["size"][1])
		var lens_y: float = y + RAIL_FOOT - (th - float(lamps[0][1])) * sc
		var l1: float = float(lamps[0][0])
		var l2: float = float(lamps[1][0])
		var l3: float = float(lamps[2][0])
		for i in int(lay["bays"]) + 1:
			out.append(Vector2(float(lay["x"]) + (l1 + float(i) * (l2 - l1)) * sc, lens_y))
		out.append(Vector2(float(lay["x"]) + (l1 + float(lay["bays"]) * (l2 - l1) + (l3 - l2)) * sc, lens_y))
		return out
	var n := maxi(lamp_count, 2)
	for i in n:
		out.append(Vector2(lerpf(x0, x1, float(i) / float(n - 1)), y))
	return out


## The painted rail's layout over [x0, x1]: its left end (to the first lamp), `bays` repeats of
## one lamp bay, then the right end (the last two lamps); `x` its left edge.
func _rail_layout(x0: float, x1: float) -> Dictionary:
	var e := LabSkins.entry("rail_lamps")
	var sc: float = float(e["scale"])
	var tw: float = float(e["size"][0])
	var lamps: Array = e["points"]["lamps"]
	var l1: float = float(lamps[0][0])
	var l2: float = float(lamps[1][0])
	var bay: float = l2 - l1
	var ends: float = l1 + (tw - l2)
	var bays: int = maxi(0, roundi(((x1 - x0) / sc - ends) / bay))
	var total: float = (ends + float(bays) * bay) * sc
	return {"x": (x0 + x1) * 0.5 - total * 0.5, "bays": bays, "total": total}


func _draw_painted_rail(x0: float, x1: float, y: float, origin: Vector2) -> void:
	var e := LabSkins.entry("rail_lamps")
	var tex := LabSkins.texture("rail_lamps")
	var sc: float = float(e["scale"])
	var tw: float = float(e["size"][0])
	var th: float = float(e["size"][1])
	var lamps: Array = e["points"]["lamps"]
	var l1: float = float(lamps[0][0])
	var l2: float = float(lamps[1][0])
	var lay := _rail_layout(x0, x1)
	var top: float = origin.y + y + RAIL_FOOT - th * sc
	var x: float = origin.x + float(lay["x"])
	var pieces := [[0.0, l1]]
	for i in int(lay["bays"]):
		pieces.append([l1, l2])
	pieces.append([l2, tw])
	for pc in pieces:
		var w: float = float(pc[1]) - float(pc[0])
		draw_texture_rect_region(tex, Rect2(Vector2(x, top), Vector2(w * sc, th * sc)), Rect2(float(pc[0]), 0.0, w, th))
		x += w * sc
