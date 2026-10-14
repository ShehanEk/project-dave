extends Node2D
## A release prop (Level 2 v2): S3's kennel pods, S6's showroom plinths and S7's service
## doors. It holds one EncounterGroup's enemies (`group`, a `wait_for_trigger` group that
## holds only the enemies inside this prop) until it opens:
##   CLOSED  -> the enemies wait inside, frozen: their group's `process_mode` is DISABLED,
##              so they never think, move, attack or take a token, and their bodies and hit
##              zones are out of the physics world (a shot passes the pod as it passes any
##              back-wall prop). A pod shows its dog behind tinted glass; a plinth's cover
##              and a door's panel hide theirs (the group is hidden).
##   WARNING -> `warn_time` (1.0 s): the pod's ring light / the plinth's spotlight / the
##              door's lamp turns amber, then red for the last `red_time` (0.25 s), with one
##              `sfx_warn` (steady colours, nothing flashes).
##   OPEN    -> the glass slides up / the cover drops / the panel slides up (`open_time`, a
##              snap with reduced motion), `sfx_open`, and at once the group is unfrozen,
##              shown and `activate()`d: the enemies notice Dave and step out.
## Triggers: `trigger_x` (Dave passes an x in the owning AreaRoot's local space, or the
## parent's in an isolated scene; `trigger_dir` +1 = at or past it going right, -1 = at or
## before it) or `trigger_area` (Dave's body enters an Area2D) arms it; `after` (another
## release prop, or an EncounterGroup) must then be cleared (every enemy defeated), and
## `delay` more seconds pass, before the warning starts. With no trigger it is armed from
## the start (so `after` alone chains it); with no trigger and no `after` it opens only on
## `release()` (the exit wicket's waves, S7).
## Rebuild: a prop whose group's enemies are all recorded defeated (`Session.is_defeated`)
## starts OPEN, silently, and counts as cleared; otherwise it starts CLOSED with its enemies
## back inside (a death rolls them back). No state of its own is saved.
## The screen budget is the groups' job: give follow-on pods `share_tokens_with` a common
## group so a pod row and its handler never field more than that group's `max_attackers`.
## Stand-in looks (code-drawn) until Batch 8: `piece` names a LabSkins piece pair
## (`<piece>_closed` / `<piece>_open`) that replaces the drawn body when it exists.
## No class_name (import-cache rule): preload it by path.

signal warning_started
signal opened

enum State { CLOSED, WARNING, OPEN }
enum Kind { POD, PLINTH, DOOR }

const LabSkins := preload("res://scripts/world/lab_skins.gd")
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")

const OUTLINE := Color("#07090F")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
const VOID := Color("#0B1220")
const TEAL := Color("#3FE0D0")
const AMBER := Color("#FFB02E")
const ALARM := Color("#FF3B4E")
## Matte warm accents (C62: copper and rust-orange safety paint, never glowing).
const RUST := Color("#8A4A2A")
const CLOTH := Color("#3A4558")
const GLASS := Color(0.55, 0.92, 0.95, 0.16)
## Draw order (relative to the prop's parent, where the enemies' groups also live): the
## prop's back at -3, the waiting enemies at -2 (their group is moved to -3; they sit at +1
## in it), the glass / cover / panel at -1, so the whole prop stays behind Dave (z 0).
const BACK_Z := -3
const FRONT_REL_Z := 2
const INSIDE_GROUP_Z := -3
const DEFAULT_SIZE := {Kind.POD: Vector2(150, 118), Kind.PLINTH: Vector2(180, 250), Kind.DOOR: Vector2(116, 168)}
const DEFAULT_OPEN_SFX := {Kind.POD: &"hatch_open", Kind.PLINTH: &"latch", Kind.DOOR: &"door_unlock"}

@export var variant: Kind = Kind.POD
## The EncounterGroup this prop holds (its enemies stand inside the prop).
@export var group: NodePath
## Area-local x Dave must pass to arm it (INF = no x trigger).
@export var trigger_x: float = INF
## +1: Dave at or right of `trigger_x`; -1: at or left of it.
@export var trigger_dir: int = 1
## An Area2D whose hero entry arms it (empty = none).
@export var trigger_area: NodePath
## A release prop or EncounterGroup that must be cleared first ("one after the other").
@export var after: NodePath
## Seconds between the conditions being met and the warning.
@export var delay: float = 0.0
@export var warn_time: float = 1.0
@export var red_time: float = 0.25
@export var open_time: float = 0.45
## The prop's size: a pod's or door's opening, a plinth's width and spotlight height.
## Zero = the variant's default.
@export var size: Vector2 = Vector2.ZERO
## Batch 8's painted piece (LabSkins `<piece>_closed` / `<piece>_open`), "" = drawn.
@export var piece: String = ""
@export var sfx_warn: StringName = &"ready_click"
## "" = the variant's own (pod `hatch_open`, plinth `latch`, door `door_unlock`).
@export var sfx_open: StringName = &""

var state: State = State.CLOSED
var _armed: bool = false
var _manual_only: bool = false
var _wait: float = -1.0
var _t: float = 0.0
## 0 closed .. 1 fully open (the slide / drop).
var _anim: float = 0.0
var _group: Node = null
var _after: Node = null
var _area_root: Node2D = null
var _saved_mode: ProcessMode = PROCESS_MODE_INHERIT
var _saved_z: int = 0
var _held: bool = false
var _front: Node2D
var _lamp: PointLight2D


func _ready() -> void:
	if size == Vector2.ZERO:
		size = DEFAULT_SIZE[variant]
	if sfx_open == &"":
		sfx_open = DEFAULT_OPEN_SFX[variant]
	z_index = BACK_Z
	_group = get_node_or_null(group) if not group.is_empty() else null
	_after = get_node_or_null(after) if not after.is_empty() else null
	_area_root = _find_area_root()
	var area := get_node_or_null(trigger_area) as Area2D if not trigger_area.is_empty() else null
	if area:
		area.body_entered.connect(_on_area_body_entered)
	var has_trigger := trigger_x != INF or area != null
	_armed = not has_trigger
	_manual_only = not has_trigger and _after == null
	_front = Node2D.new()
	_front.name = "Front"
	_front.z_index = FRONT_REL_Z
	_front.draw.connect(_draw_front)
	add_child(_front)
	_lamp = SceneryDraw.make_light(self, SceneryDraw.smooth_cone_texture() if variant == Kind.PLINTH else SceneryDraw.smooth_disc_texture(),
			_lamp_pos(), 260.0 if variant == Kind.PLINTH else 110.0, TEAL, 0.0, 60.0)
	if _group == null:
		push_warning("release prop %s has no group" % name)
	elif _group.get("wait_for_trigger") == false:
		push_warning("release prop %s: group %s should set wait_for_trigger" % [name, _group.name])
	if _recorded_defeated():
		_open(true)
	else:
		_hold()
	_update_lamp()


func _find_area_root() -> Node2D:
	var p := get_parent()
	while p:
		if p is AreaRoot:
			return p
		p = p.get_parent()
	return null


# --- public ----------------------------------------------------------------------------

## Starts the warning now (from CLOSED only): the exit wicket's waves, or a script.
func release() -> void:
	if state == State.CLOSED:
		_start_warning()


func is_open() -> bool:
	return state == State.OPEN


## Open and every enemy it held defeated (what `after` and the wicket's waves wait for).
func is_cleared() -> bool:
	return state == State.OPEN and group_cleared(_group)


## The enemies this prop holds (its group's).
func held_enemies() -> Array:
	return group_enemies(_group)


## The lamp's colour now: teal while it waits, amber in the warning, red for the last
## `red_time`, a dim teal once open.
func lamp_color() -> Color:
	match state:
		State.WARNING:
			return ALARM if _t >= warn_time - red_time else AMBER
		State.OPEN:
			return Color(TEAL, 0.35)
	return TEAL


## Every enemy under `g` (a node with an `entity_id` and a `defeated` signal).
static func group_enemies(g: Node) -> Array:
	var out: Array = []
	if g == null or not is_instance_valid(g):
		return out
	for c in g.get_children():
		if "entity_id" in c and c.has_signal("defeated"):
			out.append(c)
		out.append_array(group_enemies(c))
	return out


## True when every enemy of `g` is gone, dying or recorded defeated (an empty group is).
static func group_cleared(g: Node) -> bool:
	for e in group_enemies(g):
		if not enemy_down(e):
			return false
	return true


static func enemy_down(e: Node) -> bool:
	if e == null or not is_instance_valid(e) or e.is_queued_for_deletion():
		return true
	var id: String = e.entity_id
	if id != "" and Session != null and Session.is_defeated(id):
		return true
	# Its own DEFEATED state (every enemy template has one; the rover has no `health`).
	var states: Dictionary = e.get_script().get_script_constant_map().get("State", {}) if e.get_script() else {}
	if states.has("DEFEATED") and e.get("state") == states["DEFEATED"]:
		return true
	return "health" in e and int(e.health) <= 0


## A release prop's `is_cleared()`, else a group's `group_cleared()`.
static func node_cleared(n: Node) -> bool:
	if n == null or not is_instance_valid(n):
		return true
	if n.has_method("is_cleared"):
		return n.is_cleared()
	return group_cleared(n)


# --- state -----------------------------------------------------------------------------

func _recorded_defeated() -> bool:
	if _group == null or Session == null:
		return false
	var ids := 0
	for e in group_enemies(_group):
		var id: String = e.entity_id
		if id == "":
			return false
		if not Session.is_defeated(id):
			return false
		ids += 1
	return ids > 0


## The enemies wait inside: frozen, drawn between the prop's back and front (a pod), or
## hidden (a plinth's cover, a door).
func _hold() -> void:
	if _group == null or _held:
		return
	_held = true
	_saved_mode = _group.process_mode
	_group.process_mode = Node.PROCESS_MODE_DISABLED
	if _group is CanvasItem:
		_saved_z = (_group as CanvasItem).z_index
		(_group as CanvasItem).z_index = INSIDE_GROUP_Z
		if variant != Kind.POD:
			(_group as CanvasItem).visible = false


func _let_out() -> void:
	if _group == null:
		return
	if _held:
		_held = false
		_group.process_mode = _saved_mode
		if _group is CanvasItem:
			(_group as CanvasItem).z_index = _saved_z
			(_group as CanvasItem).visible = true
	if _group.has_method("activate"):
		_group.activate()


func _physics_process(delta: float) -> void:
	_t += delta
	match state:
		State.CLOSED:
			_tick_closed(delta)
		State.WARNING:
			if _t >= warn_time:
				_open(false)
		State.OPEN:
			if _anim < 1.0:
				_anim = 1.0 if _reduced_motion() or open_time <= 0.0 else minf(1.0, _anim + delta / open_time)
				queue_redraw()
				_front.queue_redraw()
	_update_lamp()


func _tick_closed(delta: float) -> void:
	if _manual_only:
		return
	if not _armed:
		if trigger_x != INF and _hero_past_x():
			_armed = true
		else:
			return
	if _after != null and not node_cleared(_after):
		_wait = -1.0
		return
	if _wait < 0.0:
		_wait = delay
	_wait -= delta
	if _wait <= 0.0:
		_start_warning()


func _hero_past_x() -> bool:
	var hero := get_tree().get_first_node_in_group("hero") as Node2D
	if hero == null:
		return false
	var space: Node2D = _area_root if _area_root else (get_parent() as Node2D)
	var x: float = space.to_local(hero.global_position).x if space else hero.global_position.x
	return x >= trigger_x if trigger_dir >= 0 else x <= trigger_x


func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		_armed = true


func _start_warning() -> void:
	state = State.WARNING
	_t = 0.0
	if sfx_warn != &"":
		Audio.play_sfx(sfx_warn, global_position + _lamp_pos())
	warning_started.emit()
	queue_redraw()
	_front.queue_redraw()


## OPEN: `instant` (a rebuild of a cleared prop) skips the slide, the sound and the puff.
func _open(instant: bool) -> void:
	state = State.OPEN
	_t = 0.0
	_anim = 1.0 if instant else 0.0
	if not instant:
		if sfx_open != &"":
			Audio.play_sfx(sfx_open, global_position)
		if variant == Kind.PLINTH:
			KenneyPuff.spawn(&"landing_dust", global_position + Vector2(0.0, -4.0), get_parent())
	_let_out()
	opened.emit()
	queue_redraw()
	_front.queue_redraw()


func _update_lamp() -> void:
	if _lamp == null:
		return
	var c := lamp_color()
	_lamp.color = Color(c, 1.0)
	match state:
		State.WARNING:
			_lamp.energy = 1.6 if variant == Kind.PLINTH else 1.1
		State.OPEN:
			_lamp.energy = 0.35 if variant == Kind.PLINTH else 0.15
		_:
			_lamp.energy = 0.9 if variant == Kind.PLINTH else 0.4
	if state == State.WARNING:
		queue_redraw()
		_front.queue_redraw()


func _reduced_motion() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


# --- drawing ---------------------------------------------------------------------------

## The lamp's position: over a pod's opening, at the head of the plinth's spotlight, over the
## door's frame.
func _lamp_pos() -> Vector2:
	match variant:
		Kind.PLINTH:
			return Vector2(0.0, -size.y)
		Kind.DOOR:
			return Vector2(0.0, -size.y - 18.0)
	return Vector2(0.0, -size.y - 14.0)


func _painted(open: bool) -> String:
	if piece == "":
		return ""
	var p := piece + ("_open" if open else "_closed")
	return p if LabSkins.has(p) else ""


func _draw() -> void:
	var p := _painted(state == State.OPEN and _anim >= 1.0)
	if p != "" and (state == State.OPEN and _anim >= 1.0 or variant == Kind.POD):
		LabSkins.draw(self, p)
	elif p == "":
		match variant:
			Kind.POD:
				_draw_pod_back()
			Kind.PLINTH:
				_draw_plinth_back()
			Kind.DOOR:
				_draw_door_back()
	if variant == Kind.PLINTH or p != "":
		_draw_lamp(self)


func _draw_front() -> void:
	if _painted(false) != "" and not (state == State.OPEN and _anim >= 1.0) and variant != Kind.POD:
		LabSkins.draw(_front, _painted(false))
		return
	if _painted(false) != "":
		return
	match variant:
		Kind.POD:
			_draw_pod_front()
		Kind.PLINTH:
			_draw_plinth_front()
		Kind.DOOR:
			_draw_door_front()


func _draw_lamp(c: CanvasItem) -> void:
	var col := lamp_color()
	var at := _lamp_pos()
	if variant == Kind.PLINTH:
		# The spotlight's housing on a short rod from above.
		c.draw_rect(Rect2(at + Vector2(-2.0, -40.0), Vector2(4.0, 30.0)), SLATE)
		c.draw_rect(Rect2(at + Vector2(-13.0, -12.0), Vector2(26.0, 14.0)), STEEL)
		c.draw_rect(Rect2(at + Vector2(-13.0, -12.0), Vector2(26.0, 14.0)), OUTLINE, false, 2.0)
		c.draw_rect(Rect2(at + Vector2(-9.0, 1.0), Vector2(18.0, 3.0)), Color(col, 1.0))
		c.draw_circle(at + Vector2(0.0, 3.0), 14.0, Color(col, 0.18 * col.a))
		return
	c.draw_circle(at, 13.0, Color(col, 0.16 * col.a))
	c.draw_circle(at, 7.0, OUTLINE)
	if variant == Kind.POD:
		# The pod's ring light: a lit ring round a dark lens.
		c.draw_arc(at, 5.0, 0.0, TAU, 20, Color(col, maxf(col.a, 0.35)), 2.5)
	else:
		c.draw_circle(at, 4.5, Color(col, maxf(col.a, 0.35)))


func _box(c: CanvasItem, r: Rect2, fill: Color, line: float = 2.0) -> void:
	c.draw_rect(r, fill)
	c.draw_rect(r, OUTLINE, false, line)


## The pod's opening (above the floor line, origin bottom centre).
func _opening() -> Rect2:
	return Rect2(Vector2(-size.x * 0.5, -size.y), size)


func _draw_pod_back() -> void:
	var o := _opening()
	# The housing round the opening, then the dark interior with a grated floor.
	_box(self, o.grow_individual(10.0, 22.0, 10.0, 0.0), STEEL)
	draw_rect(o, VOID)
	for k in 5:
		var x := o.position.x + 12.0 + k * (o.size.x - 24.0) / 4.0
		draw_line(Vector2(x, o.position.y + 6.0), Vector2(x, o.end.y - 6.0), Color(SLATE, 0.45), 1.0)
	draw_rect(Rect2(Vector2(o.position.x, o.end.y - 6.0), Vector2(o.size.x, 6.0)), SLATE)
	# A rust-orange safety stripe on the plinth under the pod and its number plate.
	draw_rect(Rect2(Vector2(o.position.x - 10.0, o.position.y - 22.0), Vector2(o.size.x + 20.0, 5.0)), RUST)
	_box(self, Rect2(Vector2(o.end.x - 30.0, o.position.y - 16.0), Vector2(20.0, 10.0)), SLATE, 1.0)


func _draw_pod_front() -> void:
	var o := _opening()
	# The glass slides up into the header.
	var shift := o.size.y * _ease(_anim)
	var top := o.position.y
	var glass := Rect2(Vector2(o.position.x, top - shift), o.size)
	var vis := glass.intersection(o)
	if vis.size.y > 0.5:
		_front.draw_rect(vis, GLASS)
		_front.draw_rect(vis, Color(TEAL, 0.35), false, 1.5)
		# Two cold sheen lines across the glass.
		for k in 2:
			var x0 := o.position.x + 18.0 + k * 34.0
			var a := Vector2(x0, vis.end.y)
			var b := Vector2(x0 + 30.0, vis.end.y - minf(vis.size.y, 60.0))
			_front.draw_line(a, b, Color(1, 1, 1, 0.12), 3.0)
	# The header and side posts stay in front of the glass.
	_box(_front, Rect2(Vector2(o.position.x - 10.0, top - 22.0), Vector2(o.size.x + 20.0, 16.0)), SLATE)
	_box(_front, Rect2(Vector2(o.position.x - 10.0, top - 6.0), Vector2(10.0, o.size.y + 6.0)), SLATE)
	_box(_front, Rect2(Vector2(o.end.x, top - 6.0), Vector2(10.0, o.size.y + 6.0)), SLATE)
	_draw_lamp(_front)


func _draw_plinth_back() -> void:
	var w := size.x
	# A low turntable dais: base, a lit rim, a darker top.
	_box(self, Rect2(Vector2(-w * 0.5, -16.0), Vector2(w, 16.0)), STEEL)
	draw_rect(Rect2(Vector2(-w * 0.5 + 6.0, -16.0), Vector2(w - 12.0, 3.0)), Color(TEAL, 0.25))
	draw_rect(Rect2(Vector2(-w * 0.5, -6.0), Vector2(w, 4.0)), RUST)


func _draw_plinth_front() -> void:
	if state == State.OPEN and _anim >= 1.0:
		# The dropped cover lies crumpled at the dais's foot.
		var pile := PackedVector2Array([Vector2(size.x * 0.5 - 6.0, 0.0), Vector2(size.x * 0.5 + 40.0, 0.0),
				Vector2(size.x * 0.5 + 30.0, -12.0), Vector2(size.x * 0.5 + 6.0, -16.0)])
		_front.draw_colored_polygon(pile, CLOTH)
		_front.draw_polyline(pile + PackedVector2Array([pile[0]]), OUTLINE, 2.0)
		return
	# The dust cover draped over the exhibit; it drops (slides down and fades) on OPEN.
	var drop := _ease(_anim)
	var w := size.x * 0.78
	var h := 104.0
	var y0 := -16.0 + drop * (h - 8.0)
	var alpha := 1.0 - drop
	var pts := PackedVector2Array()
	pts.append(Vector2(-w * 0.5, y0))
	pts.append(Vector2(-w * 0.46, y0 - h * 0.62))
	pts.append(Vector2(-w * 0.28, y0 - h * 0.92))
	pts.append(Vector2(0.0, y0 - h))
	pts.append(Vector2(w * 0.28, y0 - h * 0.92))
	pts.append(Vector2(w * 0.46, y0 - h * 0.62))
	pts.append(Vector2(w * 0.5, y0))
	var vis := PackedVector2Array()
	for p in pts:
		vis.append(Vector2(p.x, minf(p.y, -16.0)))
	_front.draw_colored_polygon(vis, Color(CLOTH, alpha))
	# Folds.
	for k in 3:
		var x := -w * 0.3 + k * w * 0.3
		_front.draw_line(Vector2(x, minf(y0 - h * 0.7, -16.0)), Vector2(x + 6.0, minf(y0, -16.0)), Color(OUTLINE, 0.45 * alpha), 2.0)
	_front.draw_polyline(vis + PackedVector2Array([vis[0]]), Color(OUTLINE, alpha), 2.0)
	# The showroom's abstract arch on the cover's hem.
	var c := Vector2(0.0, minf(y0 - 28.0, -30.0))
	_front.draw_arc(c, 11.0, PI, TAU, 12, Color(TEAL, 0.35 * alpha), 2.0)


func _draw_door_back() -> void:
	var o := _opening()
	_box(self, o.grow_individual(12.0, 26.0, 12.0, 0.0), STEEL)
	draw_rect(o, VOID)
	# The room beyond: a faint far wall and floor line.
	draw_rect(Rect2(Vector2(o.position.x, o.end.y - 8.0), Vector2(o.size.x, 8.0)), SLATE)


func _draw_door_front() -> void:
	var o := _opening()
	var shift := o.size.y * _ease(_anim)
	var panel := Rect2(Vector2(o.position.x, o.position.y - shift), o.size)
	var vis := panel.intersection(o)
	if vis.size.y > 0.5:
		_box(_front, vis, SLATE)
		# Rust-orange hazard chevrons along the panel's foot and a vision slit.
		var foot := vis.end.y - 18.0
		if foot > vis.position.y:
			var x := vis.position.x + 4.0
			while x < vis.end.x - 10.0:
				var band := PackedVector2Array([Vector2(x, vis.end.y - 2.0), Vector2(x + 10.0, vis.end.y - 2.0),
						Vector2(x + 18.0, foot), Vector2(x + 8.0, foot)])
				_front.draw_colored_polygon(band, RUST)
				x += 20.0
		var slit := Rect2(Vector2(-18.0, panel.position.y + 34.0), Vector2(36.0, 8.0)).intersection(vis)
		if slit.size.y > 0.5:
			_front.draw_rect(slit, OUTLINE)
		_front.draw_line(Vector2(o.position.x + 6.0, vis.position.y + o.size.y * 0.5), Vector2(o.end.x - 6.0, vis.position.y + o.size.y * 0.5), Color(OUTLINE, 0.5), 1.5)
	# The header the panel slides into, and the posts.
	_box(_front, Rect2(Vector2(o.position.x - 12.0, o.position.y - 26.0), Vector2(o.size.x + 24.0, 26.0)), STEEL)
	_box(_front, Rect2(Vector2(o.position.x - 12.0, o.position.y), Vector2(12.0, o.size.y)), STEEL)
	_box(_front, Rect2(Vector2(o.end.x, o.position.y), Vector2(12.0, o.size.y)), STEEL)
	_draw_lamp(_front)


static func _ease(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)
