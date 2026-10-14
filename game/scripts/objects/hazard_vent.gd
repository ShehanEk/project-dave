extends Area2D
## Level 2's floor hazards H1 and H2 (level-design/l02-alignment.md "Set pieces, hazards and
## breakables"): a steam vent (H1, `kind` STEAM: a floor grate that vents a white column about
## 1.5 H tall) and a live cable (H2, `kind` CABLE: a loose floor cable that arcs along a floor
## strip). One script, one cycle, two looks.
##
## THE CYCLE, and the tell rule (design-guide "Darkness and readability": amber warns, red is
## an attack now). IDLE (`idle_time`) -> WARN (`warn_time`: the lamp glows amber, the grate hisses
## or the cable sparks, and for the LAST `RED_TIME` (0.25 s) the lamp and glow turn red) ->
## ACTIVE (`get_active_time()`: 1.2 s steam, 1.0 s arc; the lamp stays red) -> IDLE. Damage is
## dealt ONLY in ACTIVE and a warning ALWAYS comes first: `warn_duration()` is never shorter than
## `MIN_WARN`, and a vent whose `phase` offset would start it inside ACTIVE starts at the top of
## its WARN instead, so a vent that loads (or is fired) never springs on Dave.
##
## DAMAGE: while ACTIVE, every physics tick `hero.take_damage(damage, global_position)` is called
## for a hero overlapping the damage area (`damage_rect()`); the hero's own immunity window
## (`damage_immunity_time`, 1 s) is what stops repeat hits, and its normal knockback is all the
## push there is (no launch, no impulse of the vent's own). The area is on the hazard layer
## (layer 8), mask hero_body (2), like PitHazard.
##
## ORIGIN: the floor line under the vent's centre (a steam column rises from it, a cable strip
## is centred on it), so a level places a vent at the floor's top y, like a Scenery prop.
## STEAM's area is `size` (default 72 x 144 = 1.5 H) standing on the origin; CABLE's is `length`
## wide and `CABLE_ARC_HEIGHT` (30 px) tall, so a held jump clears it and a run through it takes
## one hit at most.
##
## DRIVEN OR SELF-CYCLING: `autostart` (default true) cycles by itself, starting `phase` seconds
## into the cycle (so a row of vents is desynchronised). A vent under a VentSequencer
## (vent_sequencer.gd) is "driven": it calls `set_driven()`, the vent stops cycling and runs ONE
## burst (WARN -> ACTIVE -> IDLE) each time `fire()` is called. A driven vent can also be fired
## by anything else (a beat, a test).
##
## ART: `piece` names a painted lab piece (scripts/world/lab_skins.gd; Batch 8) drawn standing on
## the origin as the grate or the cable housing when its art exists; until then it is a stand-in:
## a steel grate with an amber lamp and a soft animated steam column of overlapping translucent
## puffs; a dark cable with end clamps, a small amber spark while it warns and a bright zigzag arc
## while it is live. The lamp is a real light.
##
## REDUCED MOTION (Settings.get_reduced_motion()): the warning glow is steady, the arc holds one
## shape and the steam rises at a third of the speed (it still moves, slowly). Normal motion:
## the glow breathes smoothly at `GLOW_HZ` (1.5 Hz, under the 2 Hz flash limit; it never blinks
## on and off), and the arc re-forms its zigzag at `ARC_HZ` at a constant brightness.
##
## No `class_name` (the project's import-cache rule): scenes and tests reach it by path.

## The state changed (`State` value), emitted after `state` is set.
signal state_changed(new_state: int)
## A hit landed on the hero (take_damage returned true; not while it is immune).
signal hit(hero: Node)

enum Kind { STEAM, CABLE }
enum State { IDLE, WARN, ACTIVE }

## The last part of the warning that shows red (the game's tell rule).
const RED_TIME := 0.25
## A warning is never shorter than this (red 0.25 s, so at least 0.25 s of amber first).
const MIN_WARN := 0.5
const STEAM_ACTIVE_DEFAULT := 1.2
const CABLE_ACTIVE_DEFAULT := 1.0
const CABLE_ARC_HEIGHT := 30.0
## The warning glow's breathing rate (Hz): under the 2 Hz limit on flashing.
const GLOW_HZ := 1.5
## How often the arc re-forms its zigzag (Hz); its brightness never changes.
const ARC_HZ := 8.0

const AMBER := Color("#FFB02E")
const RED := Color("#FF3B30")
const LAMP_OFF := Color(1.0, 0.69, 0.18, 0.28)
const STEAM_TINT := Color(0.86, 0.94, 1.0)
const ARC_CORE := Color(0.96, 0.99, 1.0)
const ARC_GLOW := Color(0.45, 0.85, 1.0)
const STEEL := Color("#3A4A60")
const STEEL_LIGHT := Color("#7C92AB")
const OUTLINE := Color("#05070B")
const CABLE_DARK := Color("#10151E")
const CABLE_RIM := Color("#3A4660")
const RUST := Color("#B5571E")   # matte rust-orange safety paint: warm, but not a tell colour

## Only cues already in AudioDirector. Stand-ins until the vent and arc sounds are made
## (the level doc lists steam hiss, vent and cable arc under Audio): the warning is a soft tick
## (valve latch / uplink tick), the burst a hatch or a link chirp.
const WARN_CUE := {Kind.STEAM: &"latch", Kind.CABLE: &"uplink"}
const ACTIVE_CUE := {Kind.STEAM: &"hatch_open", Kind.CABLE: &"link_chirp"}

const SceneryDrawScript := preload("res://scripts/world/scenery_draw.gd")
const LabSkins := preload("res://scripts/world/lab_skins.gd")

@export var kind: Kind = Kind.STEAM:
	set(v):
		kind = v
		_apply_shape()
		queue_redraw()
## Seconds of warning (amber, then red for the last RED_TIME). Never below MIN_WARN.
@export var warn_time: float = 0.8
## Seconds the hazard is live; negative = the kind's default (steam 1.2 s, cable 1.0 s).
@export var active_time: float = -1.0
## Seconds between bursts (the quiet part of the cycle).
@export var idle_time: float = 2.0
## Seconds into the cycle the vent starts at (desynchronises a row; autostart only).
@export var phase: float = 0.0
## STEAM: the column's width and height (a column stands on the origin, 1.5 H tall).
@export var size: Vector2 = Vector2(72.0, 144.0):
	set(v):
		size = v
		_apply_shape()
		queue_redraw()
## CABLE: the length of the arcing strip, centred on the origin.
@export var length: float = 192.0:
	set(v):
		length = v
		_apply_shape()
		queue_redraw()
@export var damage: int = 1
## Cycles by itself (true), or only when fired / driven by a sequencer (false).
@export var autostart: bool = true
## A painted lab piece (Batch 8) for the grate / cable housing; "" or a missing piece = the
## code-drawn stand-in.
@export var piece: String = ""

var state: int = State.IDLE
## True once a sequencer (or set_driven()) took the vent over: it never cycles by itself.
var driven: bool = false

var _t: float = 0.0           ## seconds into the cycle while `_running`
var _running: bool = false
var _cycling: bool = false
var _clock: float = 0.0       ## visual time (seconds), advanced in _process
var _amount: float = 0.0      ## the steam column's smoothed fullness (0..1), visual only
var _light: PointLight2D = null
var _glow_layer: Node2D = null


func _init() -> void:
	collision_layer = 1 << 7  # layer 8: hazard
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false
	z_index = -1              # behind Dave (steam never hides him), in front of the scenery


func _ready() -> void:
	_apply_shape()
	_light = SceneryDrawScript.make_light(self, SceneryDrawScript.smooth_disc_texture(),
			lamp_position(), 96.0 if kind == Kind.STEAM else 120.0, AMBER, 0.0, 36.0)
	_light.name = "Lamp"
	# The halos draw on an additive child so a light stays bright over the pale lab backdrop.
	_glow_layer = Node2D.new()
	_glow_layer.name = "Glow"
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow_layer.material = add
	add_child(_glow_layer)
	_glow_layer.draw.connect(_draw_glow)
	if autostart and not driven:
		start_cycling()
	queue_redraw()


# --- the cycle ------------------------------------------------------------------

func get_active_time() -> float:
	if active_time >= 0.0:
		return active_time
	return STEAM_ACTIVE_DEFAULT if kind == Kind.STEAM else CABLE_ACTIVE_DEFAULT


## The warning's real length: `warn_time`, never below MIN_WARN.
func warn_duration() -> float:
	return maxf(warn_time, MIN_WARN)


func cycle_time() -> float:
	return maxf(idle_time, 0.0) + warn_duration() + get_active_time()


## The state `t` seconds into the cycle.
func _state_for(t: float) -> int:
	if t < maxf(idle_time, 0.0):
		return State.IDLE
	if t < maxf(idle_time, 0.0) + warn_duration():
		return State.WARN
	return State.ACTIVE


## Starts cycling by itself, `phase` seconds in. A phase that lands in ACTIVE starts at the top of
## the WARN instead (a vent never begins live).
func start_cycling() -> void:
	_cycling = true
	_running = true
	_t = fposmod(phase, cycle_time())
	if _state_for(_t) == State.ACTIVE:
		_t = maxf(idle_time, 0.0)
	_set_state(_state_for(_t))


## Hands the vent to a driver: it stops cycling and idles until `fire()`.
func set_driven() -> void:
	driven = true
	stop()


## Ends any burst or cycle at once and idles.
func stop() -> void:
	_cycling = false
	_running = false
	_t = 0.0
	_set_state(State.IDLE)


## One burst: WARN -> ACTIVE -> IDLE (the warning always plays first). Ignored (false) while a
## burst is already under way; on a self-cycling vent it pulls the next burst forward.
func fire() -> bool:
	if state != State.IDLE:
		return false
	_running = true
	_t = maxf(idle_time, 0.0)
	_set_state(State.WARN)
	return true


func is_cycling() -> bool:
	return _cycling


func is_damaging() -> bool:
	return state == State.ACTIVE


## Seconds of warning left (0 outside WARN).
func warn_remaining() -> float:
	if state != State.WARN:
		return 0.0
	return maxf(maxf(idle_time, 0.0) + warn_duration() - _t, 0.0)


## True in the last RED_TIME of the warning: the lamp and the glow are red.
func is_red_tell() -> bool:
	return state == State.WARN and warn_remaining() <= RED_TIME


## The lamp / glow colour now: dim amber idle, amber warning, red in the last RED_TIME and
## while live.
func lamp_color() -> Color:
	match state:
		State.WARN:
			return RED if is_red_tell() else AMBER
		State.ACTIVE:
			return RED
	return LAMP_OFF


func _physics_process(delta: float) -> void:
	if _running:
		_advance(delta)
	if state == State.ACTIVE:
		_damage_overlapping()


func _advance(delta: float) -> void:
	_t += delta
	var cyc := cycle_time()
	if _t >= cyc:
		if _cycling:
			_t = fposmod(_t, cyc)
		else:
			_running = false
			_t = 0.0
			_set_state(State.IDLE)
			return
	_set_state(_state_for(_t))


func _set_state(s: int) -> void:
	if s == state:
		return
	state = s
	var audio := get_node_or_null("/root/Audio")
	if audio and is_inside_tree():
		if s == State.WARN:
			audio.play_sfx(WARN_CUE[kind], global_position)
		elif s == State.ACTIVE:
			audio.play_sfx(ACTIVE_CUE[kind], global_position)
	state_changed.emit(s)
	queue_redraw()


func _damage_overlapping() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("hero") and body.has_method("take_damage"):
			if body.take_damage(damage, global_position):
				hit.emit(body)


# --- shape -----------------------------------------------------------------------

## The damage area in local space: the steam column standing on the origin, or the cable strip
## (centred, CABLE_ARC_HEIGHT tall) lying on it.
func damage_rect() -> Rect2:
	if kind == Kind.STEAM:
		return Rect2(Vector2(-size.x * 0.5, -size.y), size)
	return Rect2(Vector2(-length * 0.5, -CABLE_ARC_HEIGHT), Vector2(length, CABLE_ARC_HEIGHT))


func _apply_shape() -> void:
	if not is_inside_tree():
		return
	var cs := get_node_or_null("Shape") as CollisionShape2D
	if cs == null:
		cs = CollisionShape2D.new()
		cs.name = "Shape"
		add_child(cs)  # generated, not saved
	var r := damage_rect()
	var rect := RectangleShape2D.new()
	rect.size = r.size
	cs.shape = rect
	cs.position = r.get_center()


## Where the warning lamp sits (local): beside the steam grate, on the cable's right clamp.
func lamp_position() -> Vector2:
	if kind == Kind.STEAM:
		return Vector2(size.x * 0.5 * 0.9 + 10.0, -7.0)
	return Vector2(length * 0.5 - 8.0, -8.0)


# --- visuals ---------------------------------------------------------------------

func _reduced() -> bool:
	var settings := get_node_or_null("/root/Settings")
	return settings != null and settings.get_reduced_motion()


## The lamp glow's brightness now (0..1). 0 idle; steady while ACTIVE; in WARN a smooth
## breathing at GLOW_HZ (never a blink), or steady under reduced motion.
func glow_level() -> float:
	match state:
		State.IDLE:
			return 0.0
		State.ACTIVE:
			return 1.0
	if _reduced():
		return 0.85
	return 0.78 + 0.22 * sin(_clock * TAU * GLOW_HZ)


## Which zigzag the arc is showing (it re-forms ARC_HZ times a second; always 0 under reduced
## motion, so it holds one shape).
func arc_step() -> int:
	return 0 if _reduced() else int(floor(_clock * ARC_HZ))


func _process(delta: float) -> void:
	_clock += delta
	var target := 1.0 if state == State.ACTIVE else 0.0
	_amount = move_toward(_amount, target, delta * (7.0 if target > _amount else 3.5))
	if _light:
		var c := lamp_color()
		_light.color = Color(c.r, c.g, c.b, 1.0)
		_light.energy = 0.0 if state == State.IDLE else 0.5 * glow_level()
	if state != State.IDLE or _amount > 0.0005:
		queue_redraw()


static var _puff: GradientTexture2D = null


## One soft white blob (opaque centre fading to nothing) every puff and glow is drawn from.
static func puff_texture() -> GradientTexture2D:
	if _puff == null:
		var g := Gradient.new()
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0)])
		g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		_puff = GradientTexture2D.new()
		_puff.gradient = g
		_puff.fill = GradientTexture2D.FILL_RADIAL
		_puff.fill_from = Vector2(0.5, 0.5)
		_puff.fill_to = Vector2(1.0, 0.5)
		_puff.width = 64
		_puff.height = 64
	return _puff


func _blob(canvas: CanvasItem, centre: Vector2, radius: float, color: Color) -> void:
	canvas.draw_texture_rect(puff_texture(), Rect2(centre - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, color)


## A repeatable pseudo-random 0..1 from two ints.
static func _rnd(a: int, b: int) -> float:
	return fposmod(sin(float(a) * 12.9898 + float(b) * 78.233) * 43758.5453, 1.0)


func _draw() -> void:
	if kind == Kind.STEAM:
		_draw_steam()
	else:
		_draw_cable()
	if _glow_layer:
		_glow_layer.queue_redraw()


## The warning footprint on the floor: a hazard strip across the area the hazard covers, amber,
## red for the last RED_TIME and while live, with end ticks, so the danger zone reads by shape and
## position as well as by colour.
func _draw_footprint(half_w: float) -> void:
	if state == State.IDLE:
		return
	var c := lamp_color()
	var a := 0.55 if state == State.ACTIVE else 0.35 + 0.25 * glow_level()
	draw_rect(Rect2(Vector2(-half_w, -3.0), Vector2(half_w * 2.0, 3.0)), Color(c.r, c.g, c.b, a))
	for x in [-half_w, half_w]:
		draw_rect(Rect2(Vector2(x - 1.5, -9.0), Vector2(3.0, 9.0)), Color(c.r, c.g, c.b, minf(a + 0.3, 1.0)))


func _draw_steam() -> void:
	var w := size.x
	var h := size.y
	var gw := w * 0.9
	var warn := state == State.WARN
	# The hiss while it warns: a few small wisps off the grate.
	if warn:
		var rise := 0.35 if _reduced() else 1.0
		for i in 6:
			var u := fposmod(_clock * 0.6 * rise + float(i) / 6.0, 1.0)
			var x := (_rnd(i, 3) - 0.5) * gw * 0.5
			var r := 8.0 + 11.0 * u
			var a := 0.55 * (1.0 - u)
			_blob(self, Vector2(x, -10.0 - u * h * 0.24), r * 1.15, Color(0.66, 0.74, 0.84, a * 0.35))
			_blob(self, Vector2(x, -10.0 - u * h * 0.24), r, Color(STEAM_TINT.r, STEAM_TINT.g, STEAM_TINT.b, a))
	# The column: overlapping translucent puffs rising and widening, each with a cool grey
	# shadow under it so the white reads against the pale lab, denser at the base.
	if _amount > 0.002:
		var rise_speed := (0.35 if _reduced() else 1.0) * 0.8
		var column_h := h * _amount
		var puffs := 16
		for i in puffs:
			var u := fposmod(_clock * rise_speed + float(i) / float(puffs), 1.0)
			var x := (_rnd(i, 7) - 0.5) * w * (0.35 + 0.65 * u) + sin(_clock * 1.7 + float(i) * 2.3) * 5.0 * u
			var y := -8.0 - u * (column_h - 8.0)
			var r := lerpf(w * 0.30, w * 0.60, u) * (0.8 + 0.4 * _rnd(i, 21))
			var env := _amount * smoothstep(0.0, 0.07, u) * pow(1.0 - u, 0.55)
			_blob(self, Vector2(x + 3.0, y + 5.0), r * 1.05, Color(0.58, 0.68, 0.80, 0.26 * env))
			_blob(self, Vector2(x, y), r, Color(STEAM_TINT.r, STEAM_TINT.g, STEAM_TINT.b, 0.62 * env))
		# the dense jet at the base
		_blob(self, Vector2(0.0, -16.0), w * 0.55, Color(1.0, 1.0, 1.0, 0.6 * _amount))
	# The footprint, then the grate and its lamp over the steam's foot.
	_draw_footprint(gw * 0.5)
	if piece != "" and LabSkins.has(piece):
		LabSkins.draw(self, piece)
	else:
		_draw_grate(gw)
	_draw_lamp_body(lamp_position())


func _draw_grate(gw: float) -> void:
	var body := Rect2(Vector2(-gw * 0.5, -9.0), Vector2(gw, 9.0))
	draw_rect(body, STEEL)
	draw_rect(Rect2(body.position, Vector2(gw, 2.0)), STEEL_LIGHT)
	var slots := 5
	for i in slots:
		var x := body.position.x + gw * (float(i) + 0.5) / float(slots)
		draw_rect(Rect2(Vector2(x - 4.5, -6.5), Vector2(9.0, 4.0)), CABLE_DARK)
	# a rust-orange hazard band along the grate's foot (matte, not a tell colour)
	draw_rect(Rect2(Vector2(-gw * 0.5, -2.0), Vector2(gw, 2.0)), RUST)
	draw_rect(body, OUTLINE, false, 2.0)


func _draw_lamp_body(at: Vector2) -> void:
	var c := lamp_color()
	draw_circle(at, 6.5, OUTLINE)
	draw_circle(at, 4.6, c)
	if state != State.IDLE:
		draw_circle(at, 1.8, Color(1, 1, 1, 0.85))


func _draw_cable() -> void:
	var half := length * 0.5
	if piece != "" and LabSkins.has(piece):
		LabSkins.draw(self, piece)
	else:
		# The cable: a thick dark rubber line lying along the floor with a gentle wander.
		var pts := PackedVector2Array()
		var n := maxi(int(length / 12.0), 4)
		for i in n + 1:
			var x := -half + length * float(i) / float(n)
			pts.append(Vector2(x, -5.5 - 2.2 * sin(x * 0.045 + 1.3) - 1.2 * sin(x * 0.11)))
		_draw_footprint(half)
		draw_polyline(pts, OUTLINE, 10.0, true)
		draw_polyline(pts, CABLE_DARK, 7.0, true)
		var rim := PackedVector2Array()
		for p in pts:
			rim.append(p + Vector2(0.0, -2.0))
		draw_polyline(rim, CABLE_RIM, 1.6, true)
		for r in [Rect2(Vector2(-half, -17.0), Vector2(18.0, 17.0)), Rect2(Vector2(half - 18.0, -17.0), Vector2(18.0, 17.0))]:
			draw_rect(r, STEEL)
			draw_rect(Rect2(r.position, Vector2(r.size.x, 2.0)), STEEL_LIGHT)
			draw_rect(Rect2(r.position + Vector2(0.0, r.size.y - 3.0), Vector2(r.size.x, 3.0)), RUST)
			draw_rect(r, OUTLINE, false, 2.0)
	# The warning's spark: a bright point wandering slowly along the cable (not a strobe).
	if state == State.WARN:
		var sx := 0.0 if _reduced() else -half + 0.12 * length + fposmod(_clock * 0.4, 1.0) * length * 0.76
		draw_circle(Vector2(sx, -8.0), 3.2, Color(1.0, 0.96, 0.82))
		draw_circle(Vector2(sx, -8.0), 1.6, Color(1, 1, 1))
	# The live arc: a bright zigzag along the strip at a constant brightness.
	if state == State.ACTIVE:
		var pts2 := _arc_points()
		draw_polyline(pts2, Color(ARC_GLOW.r, ARC_GLOW.g, ARC_GLOW.b, 0.45), 8.0, true)
		draw_polyline(pts2, ARC_CORE, 3.0, true)
		var step := arc_step()
		for i in range(1, pts2.size() - 1, 3):
			var base: Vector2 = pts2[i]
			var up := -(7.0 + 11.0 * _rnd(i, step + 11))
			var side := (_rnd(i, step + 5) - 0.5) * 30.0
			draw_polyline(PackedVector2Array([base, base + Vector2(side * 0.5, up * 0.5), base + Vector2(side, up)]),
					Color(ARC_CORE.r, ARC_CORE.g, ARC_CORE.b, 0.9), 1.8, true)
	_draw_lamp_body(Vector2(-lamp_position().x, lamp_position().y))
	_draw_lamp_body(lamp_position())


## The zigzag the arc draws now (arc_step() picks the shape; the ends sit on the clamps).
func _arc_points() -> PackedVector2Array:
	var half := length * 0.5
	var step := arc_step()
	var pts := PackedVector2Array()
	var m := maxi(int(length / 14.0), 2)
	for i in m + 1:
		var x := -half + length * float(i) / float(m)
		var amp := (CABLE_ARC_HEIGHT - 6.0) * (0.35 + 0.65 * _rnd(i, step))
		var y := -4.0 - (amp if i % 2 == 0 else amp * 0.18)
		if i == 0 or i == m:
			y = -9.0
		pts.append(Vector2(x, y))
	return pts


## The additive layer: lamp halos, the warning pool and the arc's glow (a child on ADD blend, so
## a light is bright on the pale lab as on the dark floor).
func _draw_glow() -> void:
	if state == State.IDLE:
		return
	var c := lamp_color()
	# amber and red tuned for ADD over the blue lab (plain amber adds up to a lime yellow there)
	var g := Color(1.0, 0.36, 0.04) if c == AMBER else (Color(1.0, 0.16, 0.12) if c == RED else c)
	var glow := glow_level()
	var lamps: Array = [lamp_position()]
	if kind == Kind.CABLE:
		lamps.append(Vector2(-lamp_position().x, lamp_position().y))
	for at in lamps:
		_blob(_glow_layer, at, 28.0, Color(g.r, g.g, g.b, 0.4 * glow))
	if kind == Kind.STEAM:
		var gw := size.x * 0.9
		_blob(_glow_layer, Vector2(0.0, -8.0), gw * 0.9, Color(g.r, g.g, g.b, 0.3 * glow))
	else:
		_blob(_glow_layer, Vector2(0.0, -6.0), length * 0.55, Color(g.r, g.g, g.b, 0.14 * glow))
		if state == State.WARN:
			var sx := 0.0 if _reduced() else -length * 0.5 + 0.12 * length + fposmod(_clock * 0.4, 1.0) * length * 0.76
			_blob(_glow_layer, Vector2(sx, -8.0), 24.0, Color(g.r, g.g, g.b, 0.8 * glow))
		else:
			var pts := _arc_points()
			_glow_layer.draw_polyline(pts, Color(ARC_GLOW.r, ARC_GLOW.g, ARC_GLOW.b, 0.35), 14.0, true)
			_blob(_glow_layer, Vector2(0.0, -12.0), length * 0.5, Color(ARC_GLOW.r, ARC_GLOW.g, ARC_GLOW.b, 0.22))
