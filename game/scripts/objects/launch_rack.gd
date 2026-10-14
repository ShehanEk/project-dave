extends Node2D
## S4, the drone launch rack (Level 2 v2, A03's cage climb): a rack on the cage wall that
## launches a Security Drone every `interval` (6 s) while it is active, `count` (3) in all,
## never more than `max_live` (2) of its drones alive at once.
##
## The drones are PRE-PLACED: each `drones` entry is a Security Drone placed where it should
## patrol (its home and patrol span are its authored ones), a child of the rack's
## EncounterGroup (`group`, `wait_for_trigger`), so attack tokens, lanes and the screen budget
## work as for any drone and every entity id is stable for saves. On `_ready` the rack docks
## each living one in its bay: frozen (`process_mode` DISABLED: no thinking, no physics body,
## no hit zone, so a docked drone can be neither shot nor hurt) and drawn between the rack's
## back and its cradle arms. A drone already recorded defeated counts as launched.
## Dave's approach activates it (`trigger_x`, area-local, `trigger_dir`; or `trigger_area`):
## the group is activated, then after `first_delay` and before every launch the bay's lamp
## turns amber, then red for the last `red_time` (`warn_time` 1.0 s in all, `ready_click`),
## and the drone leaves the rack along a short arc (`launch_time`) up and out to its home, a
## puff and `rover_charge`; there it wakes into its patrol. Launches are `interval` apart;
## with `max_live` drones alive the next one waits (without warning) for a free slot.
##
## Four breakable clamps (HitZones, `clamp_health` hits each, at the rack's corners) hold it
## to the wall: all four broken stops any further launch (a warning is cancelled; a drone in
## flight finishes its arc), darkens the rack and reveals `reward` once (a hidden ChipCache or
## any Node2D, hidden and disabled until then; its own Session record guards a second
## collection). `switch_id` (an `L02-SW##` switch) latches "rack broken" in Session so a
## rebuild after a checkpoint keeps the clamps broken, the docked drones docked and the reward
## shown; without it a rebuild restores the clamps (the reward's record still guards it).
## Stand-in look until Batch 8 (`piece`: a LabSkins piece drawn as the frame when it exists).
## No class_name (import-cache rule): preload it by path.

signal activated
signal launch_warning(index: int)
signal launched(drone: Node, index: int)
signal clamp_broken(index: int)
signal disabled
signal reward_revealed

enum State { IDLE, ACTIVE, SPENT, DISABLED }

const LabSkins := preload("res://scripts/world/lab_skins.gd")
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

const OUTLINE := Color("#07090F")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
const VOID := Color("#0B1220")
const TEAL := Color("#3FE0D0")
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
const NEON := Color("#FF3DD5")
const RUST := Color("#9A5530")
const RUST_DARK := Color("#5A3020")
const BOLT := Color("#B8C2CC")
## Draw order (relative to the parent): the rack's back at -3, docked drones at -2, the
## cradle arms and clamps at -1: the whole rack stays behind Dave (z 0).
const BACK_Z := -3
const FRONT_REL_Z := 2
const DOCKED_Z := -2
const CLAMP_SIZE := Vector2(26.0, 26.0)
const HIT_FLASH := 0.12

@export var drones: Array[NodePath] = []
## The drones' EncounterGroup (`wait_for_trigger`); activated when the rack activates.
@export var group: NodePath
@export var interval: float = 6.0
## Seconds from activation to the first launch's warning.
@export var first_delay: float = 0.5
@export var count: int = 3
@export var max_live: int = 2
@export var warn_time: float = 1.0
@export var red_time: float = 0.25
@export var launch_time: float = 0.8
## Area-local x Dave must pass to activate it (INF = none).
@export var trigger_x: float = INF
@export var trigger_dir: int = 1
@export var trigger_area: NodePath
@export var clamp_health: int = 2
## A hidden reward (a ChipCache), revealed once when all four clamps break.
@export var reward: NodePath
## An `L02-SW##` switch latching "rack broken" in Session ("" = not saved).
@export var switch_id: String = ""
## The frame: width x height, origin at its bottom centre; one bay per drone, side by side.
@export var size: Vector2 = Vector2(330, 120)
@export var piece: String = ""
## How far the stand-in's hanger cables reach up (to the cage roof).
@export var hanger_length: float = 600.0

var state: State = State.IDLE
## The drones in launch order (null where none is docked any more).
var _drones: Array = []
var _homes: Array = []
var _saved_modes: Array = []
var _saved_z: Array = []
var _launched: int = 0
## Per bay: its drone has left the rack (or was already down at load).
var _out: Array = []
var _live: Array = []
## [{i, from, to, t}] drones on their launch arc.
var _flights: Array = []
var _cool: float = 0.0
var _warning: bool = false
var _warn_t: float = 0.0
var _warn_bay: int = -1
## [{zone, health, flash}]
var _clamps: Array = []
var _revealed: bool = false
var _reward: Node = null
var _reward_mode: ProcessMode = PROCESS_MODE_INHERIT
var _group: Node = null
var _area_root: Node2D = null
var _front: Node2D
var _lamp: PointLight2D


func _ready() -> void:
	z_index = BACK_Z
	_group = get_node_or_null(group) if not group.is_empty() else null
	_area_root = _find_area_root()
	for p in drones:
		var d = get_node_or_null(p) as Node2D
		var down: bool = d == null or (String(d.get("entity_id")) != "" and Session != null and Session.is_defeated(String(d.get("entity_id"))))
		if down:
			_drones.append(null)
			_homes.append(Vector2.ZERO)
			_saved_modes.append(PROCESS_MODE_INHERIT)
			_saved_z.append(0)
			_out.append(true)
			_launched += 1
			continue
		_drones.append(d)
		_homes.append(d.global_position)
		_saved_modes.append(d.process_mode)
		_saved_z.append(d.z_index)
		_out.append(false)
		d.process_mode = Node.PROCESS_MODE_DISABLED
		d.z_index = DOCKED_Z
	# Dock after every drone's own _ready has read its authored home.
	_dock_all.call_deferred()
	_front = Node2D.new()
	_front.name = "Front"
	_front.z_index = FRONT_REL_Z
	_front.draw.connect(_draw_front)
	add_child(_front)
	for i in 4:
		_clamps.append(_make_clamp(i))
	_lamp = SceneryDraw.make_light(self, SceneryDraw.smooth_disc_texture(), Vector2(0.0, -size.y - 10.0), 120.0, TEAL, 0.35, 60.0)
	var area := get_node_or_null(trigger_area) as Area2D if not trigger_area.is_empty() else null
	if area:
		area.body_entered.connect(_on_area_body_entered)
	_reward = get_node_or_null(reward) if not reward.is_empty() else null
	if _reward:
		_reward_mode = _reward.process_mode
		_reward.process_mode = Node.PROCESS_MODE_DISABLED
		if _reward is CanvasItem:
			(_reward as CanvasItem).visible = false
	if switch_id != "" and Session != null and Session.get_switch(switch_id):
		_disable(true)
	elif _launched >= _cap():
		state = State.SPENT


func _find_area_root() -> Node2D:
	var p := get_parent()
	while p:
		if p is AreaRoot:
			return p
		p = p.get_parent()
	return null


func _make_clamp(i: int) -> Dictionary:
	var zone := HitZone.new()
	zone.name = "Clamp%d" % i
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = CLAMP_SIZE
	shape.shape = rect
	zone.add_child(shape)
	zone.position = clamp_position(i)
	add_child(zone)
	zone.hit.connect(_on_clamp_hit.bind(i))
	return {"zone": zone, "health": clamp_health, "flash": 0.0}


# --- public ----------------------------------------------------------------------------

## The bay centre of drone `i` (rack-local).
func bay_position(i: int) -> Vector2:
	var n := maxi(_drones.size(), 1)
	var w := size.x / float(n)
	return Vector2(-size.x * 0.5 + w * (float(i) + 0.5), -size.y * 0.5)


## A clamp's centre (rack-local): 0 top left, 1 top right, 2 bottom left, 3 bottom right.
func clamp_position(i: int) -> Vector2:
	var x := (size.x * 0.5 + 4.0) * (-1.0 if i % 2 == 0 else 1.0)
	var y := -size.y + 10.0 if i < 2 else -10.0
	return Vector2(x, y)


func clamp_zone(i: int) -> HitZone:
	return _clamps[i]["zone"]


func clamps_left() -> int:
	return _clamps.filter(func(c): return c["health"] > 0).size()


## Launches so far (drones already recorded defeated at load count).
func launched_count() -> int:
	return _launched


## Launched drones still alive (in flight included).
func live_count() -> int:
	_live = _live.filter(_alive)
	return _live.size()


func is_docked(d: Node) -> bool:
	var i := _drones.find(d)
	return d != null and i >= 0 and not _out[i]


func is_warning() -> bool:
	return _warning


func is_revealed() -> bool:
	return _revealed


## The rack's warning lamp: teal while ready, amber in a launch warning, red for its last
## `red_time`, dark once spent or broken.
func lamp_color() -> Color:
	if state == State.DISABLED or state == State.SPENT:
		return Color(SLATE, 1.0)
	if _warning:
		return ALARM if _warn_t >= warn_time - red_time else AMBER
	return TEAL


## Starts it now (what Dave's approach does).
func activate() -> void:
	if state != State.IDLE:
		return
	state = State.ACTIVE
	_cool = first_delay
	if _group and _group.has_method("activate"):
		_group.activate()
	activated.emit()
	if _launched >= _cap():
		state = State.SPENT


# --- behaviour -------------------------------------------------------------------------

func _cap() -> int:
	return mini(count, _drones.size())


static func _alive(d) -> bool:
	return d != null and is_instance_valid(d) and not d.is_queued_for_deletion() and int(d.health) > 0


func _dock_all() -> void:
	for i in _drones.size():
		if _out[i] or not is_instance_valid(_drones[i]):
			continue
		var d: Node2D = _drones[i]
		d.global_position = to_global(bay_position(i))
		d.reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	_tick_flights(delta)
	for c in _clamps:
		if c["flash"] > 0.0:
			c["flash"] = maxf(0.0, c["flash"] - delta)
			_front.queue_redraw()
	match state:
		State.IDLE:
			if trigger_x != INF and _hero_past_x():
				activate()
		State.ACTIVE:
			_tick_launches(delta)
	_lamp.color = lamp_color()
	_lamp.energy = 1.0 if _warning else (0.35 if state == State.IDLE or state == State.ACTIVE else 0.0)
	if _warning and _warn_bay >= 0:
		_lamp.position = bay_position(_warn_bay) + Vector2(0.0, -size.y * 0.5 + 6.0)


func _tick_launches(delta: float) -> void:
	if _launched >= _cap():
		state = State.SPENT
		queue_redraw()
		return
	if _warning:
		_warn_t += delta
		if _warn_t >= warn_time:
			_launch()
		queue_redraw()
		_front.queue_redraw()
		return
	_cool -= delta
	if _cool <= 0.0 and live_count() < max_live and _next_docked() >= 0:
		_warning = true
		_warn_t = 0.0
		_warn_bay = _next_docked()
		Audio.play_sfx(&"ready_click", to_global(bay_position(_warn_bay)))
		launch_warning.emit(_warn_bay)
		queue_redraw()


func _next_docked() -> int:
	for i in _drones.size():
		if not _out[i] and _alive(_drones[i]):
			return i
	return -1


func _launch() -> void:
	_warning = false
	var i := _warn_bay
	_warn_bay = -1
	_lamp.position = Vector2(0.0, -size.y - 10.0)
	if i < 0 or not _alive(_drones[i]):
		return
	var d: Node2D = _drones[i]
	_out[i] = true
	_launched += 1
	_cool = maxf(0.0, interval - warn_time)
	_live.append(d)
	d.z_index = _saved_z[i]
	var from := d.global_position
	_flights.append({"i": i, "from": from, "to": _homes[i], "t": 0.0})
	Audio.play_sfx(&"rover_charge", from)
	KenneyPuff.spawn(&"machine_smoke", from + Vector2(0.0, 14.0), get_parent())
	launched.emit(d, i)
	queue_redraw()
	_front.queue_redraw()


## The arc: up out of the bay, then over to the drone's home (a quadratic curve whose
## control point rises above both ends), eased.
func _tick_flights(delta: float) -> void:
	if _flights.is_empty():
		return
	var done: Array = []
	for f in _flights:
		if not is_instance_valid(_drones[f["i"]]):
			done.append(f)
			continue
		var d: Node2D = _drones[f["i"]]
		f["t"] = minf(1.0, f["t"] + delta / maxf(launch_time, 0.01))
		d.global_position = arc_point(f["from"], f["to"], f["t"])
		if f["t"] >= 1.0:
			d.global_position = f["to"]
			d.process_mode = _saved_modes[f["i"]]
			d.reset_physics_interpolation()
			done.append(f)
	for f in done:
		_flights.erase(f)


static func arc_point(from: Vector2, to: Vector2, t: float) -> Vector2:
	var s := t * t * (3.0 - 2.0 * t)
	var ctrl := Vector2(from.x + (to.x - from.x) * 0.35, minf(from.y, to.y) - 90.0)
	return from.lerp(ctrl, s).lerp(ctrl.lerp(to, s), s)


func _hero_past_x() -> bool:
	var hero := get_tree().get_first_node_in_group("hero") as Node2D
	if hero == null:
		return false
	var space: Node2D = _area_root if _area_root else (get_parent() as Node2D)
	var x: float = space.to_local(hero.global_position).x if space else hero.global_position.x
	return x >= trigger_x if trigger_dir >= 0 else x <= trigger_x


func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		activate()


# --- clamps and the reward --------------------------------------------------------------

func _on_clamp_hit(damage: int, hit_position: Vector2, _direction: Vector2, i: int) -> void:
	var c: Dictionary = _clamps[i]
	if c["health"] <= 0:
		return
	c["health"] = maxi(0, int(c["health"]) - damage)
	c["flash"] = HIT_FLASH
	KenneyPuff.spawn(&"machine_spark", hit_position, get_parent())
	_front.queue_redraw()
	if c["health"] > 0:
		return
	var zone: HitZone = c["zone"]
	zone.set_deferred("monitorable", false)
	zone.set_deferred("collision_layer", 0)
	KenneyPuff.spawn(&"machine_smoke", zone.global_position, get_parent())
	Audio.play_sfx(&"debris_clatter", zone.global_position)
	clamp_broken.emit(i)
	if clamps_left() == 0:
		_disable(false)


## All four clamps broken: no more launches, the rack goes dark, the reward shows.
## `instant` (a rebuild with the switch latched) skips the effects and signals.
func _disable(instant: bool) -> void:
	if state == State.DISABLED:
		return
	state = State.DISABLED
	_warning = false
	_warn_bay = -1
	if instant:
		for c in _clamps:
			c["health"] = 0
			var zone: HitZone = c["zone"]
			zone.monitorable = false
			zone.collision_layer = 0
	if switch_id != "" and Session != null:
		Session.set_switch(switch_id, true)
	if not instant:
		Audio.play_sfx(&"rover_destroyed", global_position + Vector2(0.0, -size.y * 0.5))
		disabled.emit()
	_reveal(instant)
	queue_redraw()
	_front.queue_redraw()


func _reveal(instant: bool) -> void:
	if _revealed or _reward == null:
		return
	_revealed = true
	_reward.process_mode = _reward_mode
	if _reward is CanvasItem:
		(_reward as CanvasItem).visible = true
	if not instant:
		Audio.play_sfx(&"latch", (_reward as Node2D).global_position if _reward is Node2D else global_position)
		if _reward is Node2D:
			KenneyPuff.spawn(&"chip_sparkle_cluster", (_reward as Node2D).global_position + Vector2(0.0, -40.0), get_parent())
	reward_revealed.emit()


# --- drawing -----------------------------------------------------------------------------

func _frame() -> Rect2:
	return Rect2(Vector2(-size.x * 0.5, -size.y), size)


func _box(c: CanvasItem, r: Rect2, fill: Color, line: float = 2.0) -> void:
	c.draw_rect(r, fill)
	c.draw_rect(r, OUTLINE, false, line)


func _bay_lamp(i: int) -> Color:
	if state == State.DISABLED:
		return Color(SLATE, 1.0)
	if _warning and i == _warn_bay:
		return lamp_color()
	if i < _drones.size() and not _out[i] and _alive(_drones[i]):
		return TEAL
	return Color(SLATE, 1.0)


func _draw() -> void:
	var f := _frame()
	if piece != "" and LabSkins.has(piece):
		LabSkins.draw(self, piece)
	else:
		# Hung from the cage's roof on two cables (everything is supported), then the
		# rack's wall plate and frame, a rust-orange safety band along the top.
		for sx in [-1.0, 1.0]:
			var top := Vector2(sx * (size.x * 0.5 - 30.0), f.position.y - 6.0)
			draw_line(top, top + Vector2(0.0, -hanger_length), OUTLINE, 5.0)
			draw_line(top, top + Vector2(0.0, -hanger_length), SLATE, 2.0)
			_box(self, Rect2(top + Vector2(-7.0, -10.0), Vector2(14.0, 10.0)), SLATE, 1.5)
		_box(self, f.grow(6.0), STEEL)
		draw_rect(Rect2(f.position + Vector2(-6.0, -6.0), Vector2(f.size.x + 12.0, 8.0)), RUST)
		var n := maxi(_drones.size(), 1)
		var w := f.size.x / float(n)
		for i in n:
			var bay := Rect2(Vector2(f.position.x + w * i + 8.0, f.position.y + 14.0), Vector2(w - 16.0, f.size.y - 24.0))
			draw_rect(bay, VOID)
			draw_rect(bay, Color(SLATE, 0.8), false, 1.5)
			# The charging cradle: a bar along the bay's foot with a magenta charge strip.
			draw_rect(Rect2(Vector2(bay.position.x + 6.0, bay.end.y - 10.0), Vector2(bay.size.x - 12.0, 6.0)), SLATE)
			draw_rect(Rect2(Vector2(bay.position.x + 16.0, bay.end.y - 9.0), Vector2(bay.size.x - 32.0, 2.0)),
					Color(NEON, 0.55 if state != State.DISABLED else 0.12))
			if i < n - 1:
				draw_rect(Rect2(Vector2(f.position.x + w * (i + 1) - 4.0, f.position.y + 6.0), Vector2(8.0, f.size.y - 6.0)), SLATE)
	# The rack's status lamp over the frame.
	var col := lamp_color()
	var at := Vector2(0.0, -size.y - 10.0)
	draw_circle(at, 12.0, Color(col, 0.18))
	draw_circle(at, 6.0, OUTLINE)
	draw_circle(at, 4.0, col)


func _draw_front() -> void:
	var f := _frame()
	var n := maxi(_drones.size(), 1)
	var w := f.size.x / float(n)
	for i in n:
		# Each bay's cradle arms over the docked drone's skids and its own small lamp.
		var bx := f.position.x + w * (i + 0.5)
		var by := f.position.y + f.size.y * 0.5
		for s in [-1.0, 1.0]:
			var arm := PackedVector2Array([Vector2(bx + s * (w * 0.5 - 10.0), by + 26.0), Vector2(bx + s * 30.0, by + 26.0),
					Vector2(bx + s * 24.0, by + 16.0), Vector2(bx + s * 18.0, by + 16.0), Vector2(bx + s * 22.0, by + 32.0),
					Vector2(bx + s * (w * 0.5 - 10.0), by + 32.0)])
			_front.draw_colored_polygon(arm, SLATE)
			_front.draw_polyline(arm + PackedVector2Array([arm[0]]), OUTLINE, 1.5)
		var lc := _bay_lamp(i)
		var lp := Vector2(bx, f.position.y + 8.0)
		_front.draw_circle(lp, 9.0, Color(lc, 0.2 if lc != Color(SLATE, 1.0) else 0.0))
		_front.draw_circle(lp, 4.0, OUTLINE)
		_front.draw_circle(lp, 2.8, lc)
	for i in _clamps.size():
		_draw_clamp(i)


## A clamp: a rust-orange bracket bolted to the wall over the frame's corner; struck it
## flashes cold white once; broken it hangs from one bolt, dark.
func _draw_clamp(i: int) -> void:
	var c: Dictionary = _clamps[i]
	var at := clamp_position(i)
	var half := CLAMP_SIZE * 0.5
	if c["health"] <= 0:
		var stub := PackedVector2Array([at + Vector2(-half.x, -half.y), at + Vector2(-half.x + 8.0, -half.y),
				at + Vector2(half.x * 0.2, half.y), at + Vector2(-half.x * 0.6, half.y + 4.0)])
		_front.draw_colored_polygon(stub, RUST_DARK)
		_front.draw_polyline(stub + PackedVector2Array([stub[0]]), OUTLINE, 1.5)
		_front.draw_circle(at + Vector2(-half.x + 4.0, -half.y + 4.0), 3.0, Color(BOLT, 0.5))
		return
	var r := Rect2(at - half, CLAMP_SIZE)
	_box(_front, r, RUST)
	# Wear: a darker lower half and two bolt heads.
	_front.draw_rect(Rect2(r.position + Vector2(2.0, r.size.y * 0.55), Vector2(r.size.x - 4.0, r.size.y * 0.4)), Color(RUST_DARK, 0.6))
	for b in [Vector2(-6.0, -6.0), Vector2(6.0, 6.0)]:
		_front.draw_circle(at + b, 3.2, OUTLINE)
		_front.draw_circle(at + b, 2.2, BOLT)
	# Damage shows: a crack per lost hit.
	var lost: int = clamp_health - int(c["health"])
	for k in lost:
		_front.draw_line(at + Vector2(-half.x + 3.0, -2.0 + k * 6.0), at + Vector2(half.x - 4.0, 4.0 + k * 6.0), OUTLINE, 2.0)
	if c["flash"] > 0.0:
		_front.draw_rect(r, Color(1, 1, 1, 0.75 * c["flash"] / HIT_FLASH))
