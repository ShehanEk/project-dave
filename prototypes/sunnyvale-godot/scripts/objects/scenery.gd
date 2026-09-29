class_name Scenery
extends Node2D
## Non-colliding blockout prop, drawn from an exported `kind` + `size`. Pivot
## is bottom-center (local origin sits on the ground/floor line) for every
## kind except CLOUD_PROJECTOR and PANEL, which hang/sit at the node's own
## position. Always behind actors (negative z_index) so it never hides feet,
## enemies, or landing edges.
##
## Revamp (C24) night pass: every kind is redrawn as its Arcadia-campus-at-
## night equivalent (art-design/style-guide.md "Sunnyvale campus at night";
## level brief "What the level looks like") in the same C11 rendering —
## confident dark outlines, flat colors, one or two crisp cel-shadow shapes,
## light drawn as flat glow shapes and rim light. Props never get the
## bright cold-white top edge that marks a walkable Block, so a roof slab or
## railing is never mistaken for a ledge.
##
##   HOUSE           office pavilion: glass facade, a few lit windows
##   FENCE           steel security railing
##   SHRUB           dark sculpted hedge with a cool rim light
##   FLOWER          low bioluminescent garden plant with teal glowing pods
##   CLOCK           the tall Arcadia emblem tower sign — the navigation
##                   landmark (replaces the smiling sun clock)
##   FOUNTAIN        dark reflecting pool with teal underlights (real light)
##   LAMP            cold-white path lamp with a real, smooth light pool
##   PLANTER         concrete planter with a clipped hedge
##   MAILBOX         card-reader / intercom post
##   PORTRAIT        framed family photo on the guard's desk
##   BREAKFAST       an abandoned coffee cup and tray
##   SIGN            teal-lit corporate signage (`text`; exit signs green)
##   CLOUD_PROJECTOR holographic billboard projector (`text`), amber
##   DEPOT_DOOR      server-depot security door (open)
##   WORKBENCH       spare-parts workbench
##   RAIL            steel guide rail with amber chevrons
##   PANEL           wall terminal panel
##   GATE            the broken perimeter security gate
##   BEACON          alarm-red warning beacon (real, slowly pulsing light)
##   SUPPORT         steel column
##
## `kind`'s enum VALUES are never reordered — only appended to — because
## area scene files store `kind` as a plain integer; changing an existing
## value's number would silently reskin an unrelated prop everywhere it's
## placed.
##
## Lit cutouts (C35): the LAMP, BEACON and FOUNTAIN lights are smooth
## (SceneryDraw.smooth_cone_texture()/smooth_disc_texture()) and each sits at
## its REAL source (a lamp's light is AT the lamp head, a beacon's at its
## dome) with a `height`, because Dave and the enemies are shaded through
## normal maps and take their lighting direction from where the light is.
##
## Lockdown: `set_lamp_examination_mode()` (kept by name; EnvironmentState
## calls it for its own `lamp_paths` only) now switches a prop to the
## post-awakening lockdown look. A LAMP's lens, glow and light go amber or
## alarm red (EnvironmentState's `lamp_lockdown_color`), its head swivels
## toward the exit, and its light joins a slow chase pattern that travels
## toward the exit (about 0.4 Hz; held steady under reduced motion). Other
## lit fixtures (signs, terminals, card readers) swap their teal for the
## lockdown color. A garden lamp outside any EnvironmentState group is never
## called and keeps its cold-white look forever.

enum Kind {
	HOUSE, FENCE, SHRUB, FLOWER, CLOCK, FOUNTAIN, LAMP, PLANTER, MAILBOX,
	PORTRAIT, BREAKFAST, SIGN, CLOUD_PROJECTOR, DEPOT_DOOR, WORKBENCH, RAIL, PANEL,
	GATE, BEACON, SUPPORT,
}

const OUTLINE := SceneryDraw.OUTLINE
const NIGHT := SceneryDraw.NIGHT
const NAVY := SceneryDraw.NAVY
const STEEL := SceneryDraw.STEEL
const SLATE := SceneryDraw.SLATE
const TEAL := SceneryDraw.TEAL
const AMBER := SceneryDraw.AMBER
const ALARM := SceneryDraw.ALARM
const SIGNAL_GREEN := SceneryDraw.SIGNAL_GREEN
const PATH_WHITE := SceneryDraw.PATH_WHITE
const STEEL_HI := Color("#3E5068")
## A dim rim for prop tops — deliberately far below a walkable Block's
## cold-white edge.
const PROP_RIM := Color("#4A607C")
const CONCRETE := Color("#243145")
const CONCRETE_HI := Color("#34455E")
const CONCRETE_DARK := Color("#141D2A")
const GLASS := Color("#10263A")
const GLASS_HI := Color("#2A5170")
const WIN_WARM := Color(0.95, 0.89, 0.76, 0.85)
const HEDGE := Color("#0E2521")
const HEDGE_DARK := Color("#081714")
const HEDGE_RIM := Color(0.44, 0.72, 0.68, 0.75)
const STEM := Color("#0D211E")
const WATER := Color("#051118")
const CERAMIC := Color("#B8C6D3")
const PHOTO := Color("#7B8C9E")
const LAMP_WHITE := Color(0.86, 0.91, 0.95)

## Kenney `light-masks` (Transparent variant; see assets/kenney/README.md
## section 4) used ONLY by the glow child sprites below — never drawn in
## `_draw()` itself, additive-blended so they light up against the backdrop
## instead of sitting as a flat sprite. LAMP swaps its circle/beam pair
## between the plain utility look and the lockdown look — the SAME glow
## sprites, never a separate hidden/shown pair.
const GLOW_CIRCLE_UTILITY := preload("res://assets/kenney/light-masks/circle_b.png")
const GLOW_CONE_UTILITY := preload("res://assets/kenney/light-masks/cone_a.png")
const GLOW_CIRCLE_LOCKDOWN := preload("res://assets/kenney/light-masks/circle_c.png")
const GLOW_CONE_LOCKDOWN := preload("res://assets/kenney/light-masks/cone_composed_c.png")
const GLOW_CIRCLE_BEACON := preload("res://assets/kenney/light-masks/circle_a.png")
const GLOW_RING_BEACON := preload("res://assets/kenney/light-masks/ring_a.png")

## Every light-mask source texture used by this script is a 512x512 Kenney
## PNG (assets/kenney/README.md sections 4-5) — glow scale factors below
## are all "desired on-screen pixel size / this".
const LIGHT_MASK_PX := 512.0
## Smooth light energies: tuned so a lamp's pool reads clearly on the paving
## and lights whoever stands in it. The lockdown tints (amber, alarm red) are
## darker than cold white, so their energy is higher.
const LAMP_ENERGY := 1.6
const LAMP_LOCKDOWN_ENERGY := 1.85
## Height of each light above the scene, in px (SceneryDraw.make_light()).
const LAMP_LIGHT_HEIGHT := 70.0
const BEACON_LIGHT_HEIGHT := 30.0
const FOUNTAIN_LIGHT_HEIGHT := 20.0
## A lamp's beam reaches this many times its head's height (so the pool on
## the paving stays about as bright under a low lamp as a tall one), within
## these limits in px.
const LAMP_REACH_RATIO := 2.35
const LAMP_REACH_MIN := 230.0
const LAMP_REACH_MAX := 420.0
## The alarm beacon's light pulses between these (held at the midpoint under
## reduced motion).
const BEACON_ENERGY_MIN := 0.7
const BEACON_ENERGY_MAX := 1.6
const FOUNTAIN_ENERGY := 1.8
## The lockdown swivel: the head (and its light) turns toward +x, the exit.
const LOCKDOWN_TILT := -0.2
## Lockdown chase: a slow wave of brightness travelling toward the exit.
const CHASE_HZ := 0.4
const CHASE_K := TAU / 900.0
## Beacon pulse, well under the 1-2 Hz ceiling for alarm lights.
const BEACON_HZ := 0.8

@export var kind: Kind = Kind.SHRUB
@export var size: Vector2 = Vector2(64.0, 64.0)
## SIGN and CLOUD_PROJECTOR only.
@export var text: String = ""

var _lamp_pivot: Node2D
var _lamp_glow_circle: Sprite2D
var _lamp_glow_beam: Sprite2D
var _lamp_light: PointLight2D
var _beacon_glow: Sprite2D
var _beacon_ring: Sprite2D
var _beacon_light: PointLight2D
var _beacon_ring_base_scale: float = 1.0
var _clock_glow: Sprite2D
var _fountain_light: PointLight2D
var _pulse_t: float = 0.0
var _reduced_motion: bool = false
var _lockdown: bool = false
var _lockdown_tint: Color = AMBER
var _tilt: float = 0.0
var _tilt_tween: Tween
var _seed: int = 0


func _ready() -> void:
	# The landmark tower sign stands behind every other prop (its pylon runs
	# down behind doors and planters to the ground line).
	z_index = -12 if kind == Kind.CLOCK else -10
	z_as_relative = true
	_seed = int(absf(position.x) * 7.0 + absf(position.y) * 13.0)
	var settings := get_node_or_null("/root/Settings")
	_reduced_motion = settings != null and settings.get_reduced_motion()
	match kind:
		Kind.LAMP:
			_setup_lamp()
		Kind.BEACON:
			_setup_beacon_glow()
		Kind.FOUNTAIN:
			_setup_fountain_light()
		Kind.CLOCK:
			_setup_clock_glow()
	# Light emitters are never lit by their own light.
	if kind in [Kind.LAMP, Kind.BEACON, Kind.FOUNTAIN, Kind.CLOCK]:
		light_mask = 0
	_update_processing()
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


func _hash01(n: int) -> float:
	var h: int = (n * 0x27d4eb2d) & 0xffffffff
	h = (h ^ (h >> 15)) & 0xffffffff
	h = (h * 0x165667b1) & 0xffffffff
	h = h ^ (h >> 13)
	return float(h & 0xffff) / 65535.0


func _update_processing() -> void:
	var wants := false
	if not _reduced_motion:
		match kind:
			Kind.BEACON, Kind.CLOUD_PROJECTOR:
				wants = true
			Kind.LAMP:
				wants = _lockdown
	set_process(wants)


func _process(delta: float) -> void:
	_pulse_t += delta
	match kind:
		Kind.BEACON:
			_pulse_beacon()
		Kind.LAMP:
			_pulse_lamp()
		Kind.CLOUD_PROJECTOR:
			queue_redraw()


# --- glow sprites and lights -------------------------------------------------------

## Kenney light-mask glow (M6.5 Kenney integration pass; assets/kenney/
## README.md section 4). A small, low-alpha, additive-blended Sprite2D that
## sits behind the prop (relative z -9 under the prop's own -10) so it reads
## as ambient light spill, never a solid shape that could hide
## feet/edges/chips/warnings (style guide C11 "effects stay subtle").
func _make_glow(tex: Texture2D, pos: Vector2, scale_v: Vector2, alpha: float, parent: Node = null) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = true
	s.position = pos
	s.scale = scale_v
	s.modulate = Color(1.0, 1.0, 1.0, alpha)
	s.z_index = -9
	s.z_as_relative = true
	s.light_mask = 0
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	s.material = mat
	(parent if parent else self).add_child(s)
	return s


func _lamp_head() -> Vector2:
	return Vector2(0.0, -size.y * 0.9)


## How far the lamp's glow beam reaches from its head: to the ground line and
## 30 px into the floor's lit face.
func _lamp_reach() -> float:
	return size.y * 0.9 + 30.0


## How far the lamp's smooth light reaches from its head (see
## LAMP_REACH_RATIO): past the ground line, fading out as it goes.
func _lamp_light_radius() -> float:
	return clampf((size.y * 0.9 + 4.0) * LAMP_REACH_RATIO, LAMP_REACH_MIN, LAMP_REACH_MAX)


## A cold-white path lamp: a Kenney glow halo at the head, a faint beam, and
## a real PointLight2D at the head whose smooth cone paints the light pool on
## the ground, on props and on anyone passing under it. Beam and light hang
## off one pivot at the head (the cone's apex is the light's origin), so the
## lockdown swivel turns them together about the head.
func _setup_lamp() -> void:
	var head := _lamp_head()
	var circle_px: float = clampf(size.x * 1.9, 44.0, 86.0)
	_lamp_glow_circle = _make_glow(GLOW_CIRCLE_UTILITY, head, Vector2.ONE * (circle_px / LIGHT_MASK_PX), 0.24)
	_lamp_pivot = Node2D.new()
	_lamp_pivot.name = "LampPivot"
	_lamp_pivot.position = head + Vector2(0.0, 4.0)
	add_child(_lamp_pivot)
	_lamp_glow_beam = _make_glow(GLOW_CONE_UTILITY, Vector2.ZERO, Vector2.ONE, 0.1, _lamp_pivot)
	_lamp_glow_beam.flip_v = true
	_lamp_light = SceneryDraw.make_light(_lamp_pivot, SceneryDraw.smooth_cone_texture(),
			Vector2.ZERO, _lamp_light_radius(), LAMP_WHITE, LAMP_ENERGY, LAMP_LIGHT_HEIGHT)
	_apply_lamp_state(false)


## AD-12 alarm beacon: an alarm-red glow, a pulsing red ring and a real red
## light that pulses with it — post-awakening only (BEACON is only ever
## instanced under a `lockdown_visuals_path` group, per `_draw_beacon()`),
## pulsing slowly unless `Settings.reduced_motion` (style guide: keep a live
## warning readable but never force motion on a reduced-motion viewer — the
## ring and light still show, just held steady).
func _setup_beacon_glow() -> void:
	var w: float = size.x
	var h: float = size.y
	var dome_c := Vector2(0.0, -h * 0.62)
	var glow_px: float = clampf(w * 2.4, 30.0, 100.0)
	var ring_px: float = clampf(w * 1.7, 24.0, 76.0)
	var glow_scale: float = glow_px / LIGHT_MASK_PX
	var ring_scale: float = ring_px / LIGHT_MASK_PX
	_beacon_glow = _make_glow(GLOW_CIRCLE_BEACON, dome_c, Vector2.ONE * glow_scale, 0.4)
	_beacon_glow.modulate = Color(ALARM.r, ALARM.g, ALARM.b, 0.4)
	_beacon_ring = _make_glow(GLOW_RING_BEACON, dome_c, Vector2.ONE * ring_scale, 0.5)
	_beacon_ring.modulate = Color(ALARM.r, ALARM.g, ALARM.b, 0.5)
	_beacon_ring_base_scale = ring_scale
	_beacon_light = SceneryDraw.make_light(self, SceneryDraw.smooth_disc_texture(), dome_c,
			clampf(w * 8.0, 160.0, 340.0), ALARM, (BEACON_ENERGY_MIN + BEACON_ENERGY_MAX) * 0.5,
			BEACON_LIGHT_HEIGHT)
	if _reduced_motion:
		_beacon_ring.modulate.a = 0.35


func _pulse_beacon() -> void:
	if _beacon_ring == null:
		return
	var p: float = 0.5 + 0.5 * sin(_pulse_t * TAU * BEACON_HZ)
	_beacon_ring.modulate.a = lerpf(0.2, 0.6, p)
	_beacon_ring.scale = Vector2.ONE * (_beacon_ring_base_scale * (1.0 + 0.14 * p))
	_beacon_glow.modulate.a = lerpf(0.25, 0.5, p)
	if _beacon_light:
		_beacon_light.energy = lerpf(BEACON_ENERGY_MIN, BEACON_ENERGY_MAX, p)


## The reflecting pool's teal underlight also lights whoever walks past it.
func _setup_fountain_light() -> void:
	var rim_h: float = maxf(16.0, size.y * 0.22)
	_fountain_light = SceneryDraw.make_light(self, SceneryDraw.smooth_disc_texture(),
			Vector2(0.0, -rim_h - 10.0), size.x * 1.5, Color(0.5, 0.95, 0.9), FOUNTAIN_ENERGY,
			FOUNTAIN_LIGHT_HEIGHT)


func _setup_clock_glow() -> void:
	var s: float = minf(size.x, size.y)
	var px: float = clampf(s * 2.6, 120.0, 420.0)
	_clock_glow = _make_glow(GLOW_CIRCLE_BEACON, _clock_emblem_center(), Vector2.ONE * (px / LIGHT_MASK_PX), 0.3)
	_clock_glow.modulate = Color(TEAL.r, TEAL.g, TEAL.b, 0.3)


## Called by EnvironmentState (never read directly by anything else) for
## each of ITS OWN `lamp_paths` entries, with the story state. `animate` is
## true only for the live SC01 moment; `tint` is that EnvironmentState's
## `lamp_lockdown_color` (amber path lights outdoors, alarm red in the
## depot). A garden LAMP outside any EnvironmentState group is never called.
func set_lamp_examination_mode(active: bool, animate: bool = false, tint: Color = AMBER) -> void:
	_lockdown = active
	_lockdown_tint = tint
	match kind:
		Kind.LAMP:
			_apply_lamp_state(animate)
		Kind.CLOCK:
			if _clock_glow:
				var c: Color = tint if active else TEAL
				_clock_glow.modulate = Color(c.r, c.g, c.b, 0.3)
			queue_redraw()
		_:
			queue_redraw()
	_update_processing()


func _apply_lamp_state(animate: bool) -> void:
	if _lamp_glow_circle == null or _lamp_glow_beam == null:
		return
	var tint: Color = _lockdown_tint if _lockdown else LAMP_WHITE
	var reach := _lamp_reach()
	_lamp_glow_circle.texture = GLOW_CIRCLE_LOCKDOWN if _lockdown else GLOW_CIRCLE_UTILITY
	_lamp_glow_circle.modulate = Color(tint.r, tint.g, tint.b, 0.42 if _lockdown else 0.24)
	_lamp_glow_beam.texture = GLOW_CONE_LOCKDOWN if _lockdown else GLOW_CONE_UTILITY
	_lamp_glow_beam.modulate = Color(tint.r, tint.g, tint.b, 0.16 if _lockdown else 0.1)
	# cone_a is a narrow vertical shaft (a quarter of its texture wide);
	# cone_composed_c is a full-width spotlight cone. Both flipped so the
	# bright end sits at the lamp head.
	var beam_w: float = reach if _lockdown else size.x * 3.6
	_lamp_glow_beam.scale = Vector2(beam_w, reach) / LIGHT_MASK_PX
	_lamp_glow_beam.position = Vector2(0.0, reach * 0.5)
	if _lamp_light:
		_lamp_light.color = tint
		_lamp_light.energy = LAMP_LOCKDOWN_ENERGY if _lockdown else LAMP_ENERGY
	var target: float = LOCKDOWN_TILT if _lockdown else 0.0
	if _tilt_tween:
		_tilt_tween.kill()
		_tilt_tween = null
	if animate and not _reduced_motion and is_inside_tree():
		_tilt_tween = create_tween()
		_tilt_tween.tween_method(_set_tilt, _tilt, target, 0.6).set_trans(Tween.TRANS_SINE)
	else:
		_set_tilt(target)
	queue_redraw()


func _set_tilt(v: float) -> void:
	_tilt = v
	if _lamp_pivot:
		_lamp_pivot.rotation = v
	queue_redraw()


## The lockdown chase: brightness rides a slow wave toward the exit. A
## shared wall clock keeps every lamp on the same wave however they were
## switched on.
func _pulse_lamp() -> void:
	if _lamp_light == null:
		return
	var t: float = float(Time.get_ticks_msec()) * 0.001
	var p: float = 0.5 + 0.5 * sin(TAU * CHASE_HZ * t - global_position.x * CHASE_K)
	var k: float = lerpf(0.55, 1.0, p)
	_lamp_light.energy = LAMP_LOCKDOWN_ENERGY * k
	_lamp_glow_circle.modulate.a = 0.42 * k
	_lamp_glow_beam.modulate.a = 0.16 * k


# --- shared shapes -----------------------------------------------------------------

## A box with rounded top corners, bottom-centred on `base_y`: clipped hedges.
func _rounded_top_poly(w: float, h: float, r: float, base_y: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var left: float = -w * 0.5
	var right: float = w * 0.5
	var top: float = base_y - h
	var rr: float = minf(r, minf(w * 0.5, h))
	pts.append(Vector2(left, base_y))
	for i in 7:
		var a: float = PI + (PI * 0.5) * float(i) / 6.0
		pts.append(Vector2(left + rr, top + rr) + Vector2(cos(a), sin(a)) * rr)
	for i in 7:
		var a2: float = PI * 1.5 + (PI * 0.5) * float(i) / 6.0
		pts.append(Vector2(right - rr, top + rr) + Vector2(cos(a2), sin(a2)) * rr)
	pts.append(Vector2(right, base_y))
	return pts


func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array(pts)
	out.append(pts[0])
	return out


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a: float = TAU * float(i) / 20.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)


## Arcadia's arch-and-leaf mark (style guide "an original teal emblem, for
## example an abstract arch or leaf-in-arch mark").
func _draw_emblem(center: Vector2, r: float, col: Color) -> void:
	var t: float = maxf(2.5, r * 0.2)
	draw_arc(center, r, PI, TAU, 20, col, t)
	draw_line(center + Vector2(-r, 0.0), center + Vector2(-r, r * 0.9), col, t)
	draw_line(center + Vector2(r, 0.0), center + Vector2(r, r * 0.9), col, t)
	var leaf := PackedVector2Array()
	for i in 9:
		var a: float = PI * float(i) / 8.0
		leaf.append(center + Vector2(-sin(a) * r * 0.32, r * 0.72 - (1.0 - cos(a)) * r * 0.64))
	for i in range(7, 0, -1):
		var a2: float = PI * float(i) / 8.0
		leaf.append(center + Vector2(sin(a2) * r * 0.32, r * 0.72 - (1.0 - cos(a2)) * r * 0.64))
	draw_colored_polygon(leaf, col)
	draw_line(center + Vector2(0.0, r * 0.66), center + Vector2(0.0, -r * 0.3), Color(NAVY, 0.8), maxf(1.0, t * 0.35))


## Shrinks a label until it fits `available` px (never below a still-legible
## floor) instead of cropping it (depot-sign-text-cropped fix).
func _fit_font_size(text_v: String, available: float, start: int) -> int:
	var font := ThemeDB.fallback_font
	var fsize := start
	while fsize > 9 and font.get_string_size(text_v, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x > available:
		fsize -= 1
	return fsize


func _draw_centered_text(text_v: String, rect: Rect2, color: Color, start_size: int) -> void:
	var font := ThemeDB.fallback_font
	var available: float = rect.size.x - 8.0
	var fsize := _fit_font_size(text_v, available, start_size)
	var tw: float = font.get_string_size(text_v, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x
	var baseline: float = rect.position.y + rect.size.y * 0.5 + float(fsize) * 0.36
	draw_string(font, Vector2(rect.get_center().x - minf(tw, available) * 0.5, baseline), text_v,
			HORIZONTAL_ALIGNMENT_LEFT, available, fsize, color)


## Hazard stripes (amber on near-black) inside `rect` — a shape cue, not
## color alone.
func _draw_hazard_stripes(rect: Rect2, stripe: float = 8.0) -> void:
	draw_rect(rect, OUTLINE)
	var x: float = rect.position.x - rect.size.y
	var rect_poly := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end,
			Vector2(rect.position.x, rect.end.y)])
	while x < rect.end.x:
		var band := PackedVector2Array([
			Vector2(x + rect.size.y, rect.position.y), Vector2(x + rect.size.y + stripe, rect.position.y),
			Vector2(x + stripe, rect.end.y), Vector2(x, rect.end.y),
		])
		for piece in Geometry2D.intersect_polygons(band, rect_poly):
			if piece.size() >= 3:
				draw_colored_polygon(piece, AMBER)
		x += stripe * 2.0


# --- kinds -------------------------------------------------------------------------

## A low glass-and-steel office pavilion: a curtain wall with a few lit panes
## (warm white, the odd teal), a recessed entrance with a card reader, and a
## cantilevered roof slab with a thin teal Arcadia fascia strip.
func _draw_house() -> void:
	var w: float = size.x
	var h: float = size.y
	var slab_y: float = -h * 0.8
	var body := Rect2(Vector2(-w * 0.5, slab_y), Vector2(w, -slab_y))
	draw_rect(body, STEEL)
	var glass := Rect2(Vector2(-w * 0.5 + 7.0, slab_y + 8.0), Vector2(w - 14.0, -slab_y - 30.0))
	draw_rect(glass, GLASS)
	var cols: int = maxi(3, int(glass.size.x / 20.0))
	var pane_w: float = glass.size.x / float(cols)
	var rows := 2
	var pane_h: float = glass.size.y / float(rows)
	var teal_lit: Color = ALARM if _lockdown else TEAL
	for r in rows:
		for c in cols:
			var hv := _hash01(_seed + r * 31 + c * 7)
			if hv < 0.24:
				var pr := Rect2(glass.position + Vector2(float(c) * pane_w + 2.0, float(r) * pane_h + 2.0),
						Vector2(pane_w - 4.0, pane_h - 4.0))
				draw_rect(pr, WIN_WARM if hv > 0.07 else Color(teal_lit, 0.6))
	# crisp cel shadow over the far third, and a reflection streak.
	draw_rect(Rect2(glass.position + Vector2(glass.size.x * 0.66, 0.0), Vector2(glass.size.x * 0.34, glass.size.y)),
			Color(0.0, 0.0, 0.0, 0.28))
	draw_line(glass.position + Vector2(glass.size.x * 0.1, glass.size.y), glass.position + Vector2(glass.size.x * 0.3, 0.0),
			Color(GLASS_HI, 0.45), 3.0)
	for c in range(1, cols):
		var mx: float = glass.position.x + float(c) * pane_w
		draw_line(Vector2(mx, glass.position.y), Vector2(mx, glass.end.y), STEEL, 2.0)
	draw_line(Vector2(glass.position.x, glass.position.y + pane_h), Vector2(glass.end.x, glass.position.y + pane_h), STEEL, 2.0)
	# recessed ground floor: glass door, card reader, columns.
	var floor_y: float = glass.end.y
	draw_rect(Rect2(Vector2(-w * 0.5 + 7.0, floor_y), Vector2(w - 14.0, -floor_y)), NIGHT)
	var door := Rect2(Vector2(-w * 0.12, floor_y + 3.0), Vector2(w * 0.24, -floor_y - 3.0))
	draw_rect(door, GLASS.darkened(0.3))
	draw_rect(door, STEEL, false, 2.0)
	draw_circle(Vector2(w * 0.12 + 7.0, floor_y + 9.0), 2.0, AMBER if _lockdown else TEAL)
	for cx in [-w * 0.5 + 10.0, w * 0.5 - 10.0]:
		draw_rect(Rect2(Vector2(cx - 3.0, floor_y), Vector2(6.0, -floor_y)), SLATE)
	# rooftop unit, then the cantilevered slab with a dim rim.
	draw_rect(Rect2(Vector2(w * 0.14, slab_y - 22.0), Vector2(w * 0.22, 12.0)), STEEL)
	draw_rect(Rect2(Vector2(w * 0.14, slab_y - 22.0), Vector2(w * 0.22, 12.0)), OUTLINE, false, 1.5)
	var slab := Rect2(Vector2(-w * 0.58, slab_y - 10.0), Vector2(w * 1.16, 10.0))
	draw_rect(slab, SLATE)
	draw_line(slab.position, Vector2(slab.end.x, slab.position.y), PROP_RIM, 1.5)
	draw_rect(body, OUTLINE, false, 2.5)
	draw_rect(slab, OUTLINE, false, 2.0)
	draw_line(Vector2(-w * 0.52, slab.end.y - 3.0), Vector2(w * 0.52, slab.end.y - 3.0), Color(TEAL, 0.5), 1.5)


## A steel security railing: posts, three rails and a fine mesh.
func _draw_fence() -> void:
	var w: float = size.x
	var h: float = size.y
	var mx: float = -w * 0.5 + 6.0
	while mx < w * 0.5 - 2.0:
		draw_line(Vector2(mx, -h + 4.0), Vector2(mx, -8.0), Color(STEEL_HI, 0.35), 1.0)
		mx += 6.0
	for ry in [-h * 0.5, -8.0]:
		draw_rect(Rect2(Vector2(-w * 0.5, ry - 1.5), Vector2(w, 3.0)), STEEL_HI)
	var top := Rect2(Vector2(-w * 0.5, -h), Vector2(w, 4.0))
	draw_rect(top, STEEL_HI)
	draw_rect(top, OUTLINE, false, 1.5)
	draw_line(top.position, Vector2(top.end.x, top.position.y), PROP_RIM, 1.0)
	var posts: int = maxi(2, int(w / 36.0) + 1)
	for i in posts:
		var x: float = lerpf(-w * 0.5 + 3.0, w * 0.5 - 3.0, float(i) / float(posts - 1))
		var post := Rect2(Vector2(x - 2.5, -h - 3.0), Vector2(5.0, h + 3.0))
		draw_rect(post, SLATE)
		draw_rect(post, OUTLINE, false, 1.5)


## A dark, clipped box hedge with a crisp lower cel shadow and a cool rim
## light along its top.
func _draw_shrub() -> void:
	var w: float = size.x
	var h: float = size.y
	var r: float = minf(w, h) * 0.3
	var pts := _rounded_top_poly(w, h, r)
	draw_colored_polygon(pts, HEDGE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-w * 0.1, 0.0), Vector2(w * 0.5, 0.0), Vector2(w * 0.5, -h * 0.6),
	]), HEDGE_DARK)
	for i in 5:
		var c := Vector2((_hash01(_seed + i * 11) - 0.5) * w * 0.7, -h * (0.25 + _hash01(_seed + i * 5) * 0.5))
		draw_arc(c, 4.0, PI * 1.1, PI * 1.9, 5, HEDGE_DARK, 1.5)
	# cool rim along the top edge and the upper-left corner.
	var rim := PackedVector2Array()
	for i in range(2, pts.size() - 4):
		rim.append(pts[i] + Vector2(0.0, 1.5))
	draw_polyline(rim, HEDGE_RIM, 2.0)
	draw_polyline(_closed(pts), OUTLINE, 2.5)


## A low bioluminescent garden plant: dark stalks tipped with glowing teal
## seed pods and a faint teal pool at its base.
func _draw_flower() -> void:
	var w: float = size.x
	var h: float = size.y
	_draw_ellipse(Vector2(0.0, -2.0), Vector2(w * 0.7, 5.0), Color(TEAL, 0.08))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-2.0, 0.0), Vector2(-w * 0.42, -h * 0.28), Vector2(-w * 0.1, -h * 0.08),
	]), STEM)
	draw_colored_polygon(PackedVector2Array([
		Vector2(2.0, 0.0), Vector2(w * 0.4, -h * 0.22), Vector2(w * 0.1, -h * 0.06),
	]), STEM)
	var r: float = clampf(w * 0.15, 4.0, 8.0)
	var stalks := [Vector2(-w * 0.24, -h), Vector2(w * 0.04, -h * 0.8), Vector2(w * 0.26, -h * 0.62)]
	for tip in stalks:
		draw_line(Vector2(tip.x * 0.3, 0.0), tip, STEM, 2.5)
	for tip in stalks:
		draw_circle(tip, r * 2.3, Color(TEAL, 0.09))
		draw_circle(tip, r * 1.5, Color(TEAL, 0.12))
		draw_circle(tip, r, TEAL.darkened(0.2))
		draw_circle(tip + Vector2(-r * 0.25, -r * 0.3), r * 0.5, Color("#C9FFF8"))
		draw_circle(tip, r, OUTLINE, false, 1.5)


func _clock_emblem_center() -> Vector2:
	var s: float = minf(size.x, size.y)
	return Vector2(0.0, -s * 0.54)


## The Arcadia emblem tower sign — the level's navigation landmark: a tall
## dark sign slab on a slim pylon, carrying the glowing teal arch-and-leaf
## mark. The pylon runs down to the owning area's ground line (hidden
## behind the ground blocks) so the sign never floats.
func _draw_clock() -> void:
	var s: float = minf(size.x, size.y)
	var col: Color = _lockdown_tint if _lockdown else TEAL
	var ground: float = maxf(-position.y, 0.0) + 40.0
	var pw: float = maxf(10.0, s * 0.12)
	draw_rect(Rect2(Vector2(-pw * 0.5, 0.0), Vector2(pw, ground)), STEEL)
	draw_line(Vector2(-pw * 0.5 + 1.5, 0.0), Vector2(-pw * 0.5 + 1.5, ground), PROP_RIM, 1.5)
	var by: float = 50.0
	while by < ground:
		draw_line(Vector2(-pw * 0.5, by), Vector2(pw * 0.5, by), OUTLINE, 1.5)
		by += 50.0
	draw_rect(Rect2(Vector2(-pw * 0.5, 0.0), Vector2(pw, ground)), OUTLINE, false, 2.0)
	var panel := Rect2(Vector2(-s * 0.42, -s), Vector2(s * 0.84, s))
	draw_rect(panel, NAVY)
	draw_rect(panel.grow(-5.0), Color(col, 0.07))
	draw_rect(panel.grow(-5.0), Color(col, 0.6), false, 1.5)
	var c := _clock_emblem_center()
	draw_circle(c, s * 0.34, Color(col, 0.08))
	_draw_emblem(c, s * 0.22, col)
	draw_line(Vector2(-s * 0.26, -s * 0.16), Vector2(s * 0.26, -s * 0.16), Color(col, 0.5), 2.0)
	draw_rect(Rect2(panel.position + Vector2(-4.0, -6.0), Vector2(panel.size.x + 8.0, 6.0)), STEEL)
	draw_rect(Rect2(panel.position + Vector2(-4.0, -6.0), Vector2(panel.size.x + 8.0, 6.0)), OUTLINE, false, 1.5)
	draw_line(panel.position + Vector2(-4.0, -6.0), panel.position + Vector2(panel.size.x + 4.0, -6.0), PROP_RIM, 1.0)
	draw_rect(panel, OUTLINE, false, 2.5)


## A dark reflecting pool lit from within in teal (level brief "a low
## fountain lit from within in teal"), with a small arch sculpture rising
## from the water. Its PointLight2D lights passers-by from below.
func _draw_fountain() -> void:
	var w: float = size.x
	var h: float = size.y
	var rim_h: float = maxf(16.0, h * 0.22)
	_draw_ellipse(Vector2(0.0, -rim_h), Vector2(w * 0.55, h * 0.55), Color(TEAL, 0.045))
	_draw_ellipse(Vector2(0.0, -rim_h), Vector2(w * 0.36, h * 0.36), Color(TEAL, 0.06))
	var ar: float = w * 0.16
	var ac := Vector2(0.0, -rim_h - ar * 0.3)
	draw_arc(ac, ar, PI, TAU, 16, STEEL, 7.0)
	draw_line(ac + Vector2(-ar, 0.0), Vector2(-ar, -rim_h), STEEL, 7.0)
	draw_line(ac + Vector2(ar, 0.0), Vector2(ar, -rim_h), STEEL, 7.0)
	draw_arc(ac, ar - 4.0, PI, TAU, 16, Color(TEAL, 0.6), 2.0)
	var basin := Rect2(Vector2(-w * 0.5, -rim_h), Vector2(w, rim_h))
	draw_rect(basin, CONCRETE)
	draw_rect(Rect2(basin.position + Vector2(w * 0.66, 0.0), Vector2(w * 0.34, rim_h)), Color(0.0, 0.0, 0.0, 0.25))
	draw_rect(Rect2(Vector2(-w * 0.5 + 5.0, -rim_h - 3.0), Vector2(w - 10.0, 4.0)), WATER)
	for i in 3:
		var x: float = lerpf(-w * 0.3, w * 0.3, float(i) / 2.0)
		draw_line(Vector2(x - 8.0, -rim_h - 1.5), Vector2(x + 8.0, -rim_h - 1.5), Color(TEAL, 0.7), 1.5)
	draw_rect(Rect2(basin.position + Vector2(-3.0, 0.0), Vector2(w + 6.0, 4.0)), CONCRETE_HI)
	for i in 3:
		var lx: float = lerpf(-w * 0.32, w * 0.32, float(i) / 2.0)
		draw_circle(Vector2(lx, -rim_h * 0.45), 6.0, Color(TEAL, 0.15))
		draw_rect(Rect2(Vector2(lx - 4.0, -rim_h * 0.45 - 2.0), Vector2(8.0, 4.0)), TEAL)
	draw_rect(basin, OUTLINE, false, 2.5)


## A cold-white path lamp: a slim steel post and an angular hood with a lit
## lens strip. The glow sprites and the real light are set up in
## `_setup_lamp()`; in lockdown the lens takes the lockdown color and the
## head swivels toward the exit.
func _draw_lamp() -> void:
	var w: float = size.x
	var h: float = size.y
	var head := _lamp_head()
	draw_rect(Rect2(Vector2(-w * 0.32, -8.0), Vector2(w * 0.64, 8.0)), STEEL)
	draw_rect(Rect2(Vector2(-w * 0.32, -8.0), Vector2(w * 0.64, 8.0)), OUTLINE, false, 1.5)
	var post := Rect2(Vector2(-2.5, head.y + 4.0), Vector2(5.0, -head.y - 12.0))
	draw_rect(post, SLATE)
	draw_line(Vector2(-1.5, head.y + 6.0), Vector2(-1.5, -8.0), PROP_RIM, 1.0)
	draw_rect(post, OUTLINE, false, 1.5)
	var lens: Color = _lockdown_tint if _lockdown else PATH_WHITE
	draw_set_transform(head + Vector2(0.0, 4.0), _tilt, Vector2.ONE)
	var hw: float = maxf(w * 0.55, 12.0)
	var hood := PackedVector2Array([
		Vector2(-hw, -8.0), Vector2(hw, -8.0), Vector2(hw * 0.8, 1.0), Vector2(-hw * 0.8, 1.0),
	])
	draw_colored_polygon(hood, STEEL)
	draw_line(Vector2(-hw, -8.0), Vector2(hw, -8.0), PROP_RIM, 1.0)
	draw_polyline(_closed(hood), OUTLINE, 1.5)
	draw_circle(Vector2(0.0, 1.0), hw * 1.1, Color(lens, 0.1))
	draw_rect(Rect2(Vector2(-hw * 0.72, 1.0), Vector2(hw * 1.44, 3.0)), lens)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## A concrete planter box with a thin teal inlay, topped with a clipped
## hedge.
func _draw_planter() -> void:
	var w: float = size.x
	var h: float = size.y
	var box_h: float = h * 0.52
	var mound := _rounded_top_poly(w * 0.84, h - box_h + 4.0, w * 0.26, -box_h + 4.0)
	draw_colored_polygon(mound, HEDGE)
	var rim := PackedVector2Array()
	for i in range(2, mound.size() - 4):
		rim.append(mound[i] + Vector2(0.0, 1.5))
	draw_polyline(rim, HEDGE_RIM, 2.0)
	draw_polyline(_closed(mound), OUTLINE, 2.0)
	var box := Rect2(Vector2(-w * 0.5, -box_h), Vector2(w, box_h))
	draw_rect(box, CONCRETE)
	draw_rect(Rect2(box.position + Vector2(w * 0.68, 0.0), Vector2(w * 0.32, box_h)), Color(0.0, 0.0, 0.0, 0.25))
	draw_rect(Rect2(box.position + Vector2(-2.0, 0.0), Vector2(w + 4.0, 5.0)), CONCRETE_HI)
	draw_line(Vector2(-w * 0.5 + 4.0, -box_h * 0.42), Vector2(w * 0.5 - 4.0, -box_h * 0.42), Color(TEAL, 0.35), 1.5)
	draw_rect(box, OUTLINE, false, 2.5)


## A card-reader / intercom post: a slim post and a head with a lit screen,
## keypad and status LED.
func _draw_mailbox() -> void:
	var w: float = size.x
	var h: float = size.y
	var acc: Color = _lockdown_tint if _lockdown else TEAL
	var head_h: float = h * 0.38
	var post := Rect2(Vector2(-w * 0.14, -h + head_h), Vector2(w * 0.28, h - head_h))
	draw_rect(post, SLATE)
	draw_rect(post, OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(-w * 0.3, -5.0), Vector2(w * 0.6, 5.0)), STEEL)
	var head := Rect2(Vector2(-w * 0.5, -h), Vector2(w, head_h))
	var screen := Rect2(head.position + Vector2(4.0, 4.0), Vector2(w - 8.0, head_h * 0.4))
	draw_circle(screen.get_center(), w * 0.8, Color(acc, 0.07))
	draw_rect(head, STEEL)
	draw_rect(screen, Color(acc, 0.75))
	draw_line(screen.position + Vector2(3.0, screen.size.y * 0.5), screen.end - Vector2(3.0, screen.size.y * 0.5),
			Color(NAVY, 0.6), 1.5)
	for i in 3:
		for j in 2:
			draw_circle(Vector2(head.position.x + w * 0.28 + float(i) * w * 0.22, screen.end.y + 6.0 + float(j) * 6.0), 1.4, STEEL_HI)
	draw_circle(head.end - Vector2(5.0, 5.0), 1.8, acc)
	draw_rect(head, OUTLINE, false, 2.0)


## The guard's desk with a framed family photo on it — the quiet story
## detail from the level brief — and a small cold desk lamp.
func _draw_portrait() -> void:
	var w: float = size.x
	var h: float = size.y
	var desk_top: float = -h * 0.46
	draw_rect(Rect2(Vector2(-w * 0.5 + 4.0, desk_top + 5.0), Vector2(w - 8.0, -desk_top - 5.0)), STEEL)
	draw_rect(Rect2(Vector2(-w * 0.5 + 4.0, desk_top + 5.0), Vector2(w - 8.0, -desk_top - 5.0)), OUTLINE, false, 1.5)
	var fr := Rect2(Vector2(-w * 0.3, desk_top - h * 0.42), Vector2(w * 0.48, h * 0.42))
	draw_rect(fr, Color("#151A22"))
	var photo := fr.grow(-3.0)
	draw_rect(photo, PHOTO)
	var base_y: float = photo.end.y
	var figure := Color("#2B3645")
	draw_circle(Vector2(photo.position.x + photo.size.x * 0.32, base_y - photo.size.y * 0.62), photo.size.x * 0.13, figure)
	draw_rect(Rect2(Vector2(photo.position.x + photo.size.x * 0.16, base_y - photo.size.y * 0.46), Vector2(photo.size.x * 0.32, photo.size.y * 0.46)), figure)
	draw_circle(Vector2(photo.position.x + photo.size.x * 0.7, base_y - photo.size.y * 0.44), photo.size.x * 0.1, figure)
	draw_rect(Rect2(Vector2(photo.position.x + photo.size.x * 0.58, base_y - photo.size.y * 0.3), Vector2(photo.size.x * 0.24, photo.size.y * 0.3)), figure)
	draw_line(photo.position + Vector2(photo.size.x * 0.6, 0.0), photo.position + Vector2(photo.size.x, photo.size.y * 0.4),
			Color(1.0, 1.0, 1.0, 0.3), 2.0)
	draw_rect(fr, OUTLINE, false, 2.0)
	var lamp_base := Vector2(w * 0.32, desk_top)
	var lamp_head := lamp_base + Vector2(-6.0, -h * 0.3)
	draw_circle(lamp_head + Vector2(-2.0, 6.0), 14.0, Color(PATH_WHITE, 0.1))
	draw_line(lamp_base, lamp_head, STEEL_HI, 2.0)
	draw_colored_polygon(PackedVector2Array([
		lamp_head + Vector2(-8.0, 2.0), lamp_head + Vector2(4.0, -4.0), lamp_head + Vector2(6.0, 2.0),
	]), STEEL_HI)
	draw_line(lamp_head + Vector2(-7.0, 3.0), lamp_head + Vector2(6.0, 3.0), PATH_WHITE, 2.0)
	var top := Rect2(Vector2(-w * 0.5, desk_top), Vector2(w, 5.0))
	draw_rect(top, SLATE)
	draw_line(top.position, Vector2(top.end.x, top.position.y), PROP_RIM, 1.0)
	draw_rect(top, OUTLINE, false, 1.5)


## The same meal tray delivered to the same dark desk, untouched: a cup of
## coffee long gone cold (no steam) and a wrapped sandwich on a side table.
func _draw_breakfast() -> void:
	var w: float = size.x
	var h: float = size.y
	var top_y: float = -h * 0.55
	draw_rect(Rect2(Vector2(-3.0, top_y + 4.0), Vector2(6.0, -top_y - 8.0)), STEEL)
	draw_rect(Rect2(Vector2(-w * 0.2, -4.0), Vector2(w * 0.4, 4.0)), STEEL)
	var table := Rect2(Vector2(-w * 0.42, top_y), Vector2(w * 0.84, 4.0))
	draw_rect(table, SLATE)
	draw_rect(table, OUTLINE, false, 1.5)
	var tray := Rect2(Vector2(-w * 0.34, top_y - 4.0), Vector2(w * 0.68, 4.0))
	draw_rect(tray, STEEL_HI)
	draw_rect(tray, OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(-w * 0.28, top_y - 7.0), Vector2(w * 0.3, 3.0)), CERAMIC)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-w * 0.24, top_y - 7.0), Vector2(-w * 0.02, top_y - 7.0), Vector2(-w * 0.13, top_y - 16.0),
	]), Color("#5A5048"))
	draw_line(Vector2(-w * 0.24, top_y - 7.0), Vector2(-w * 0.13, top_y - 16.0), Color(1.0, 1.0, 1.0, 0.25), 1.0)
	var cup := Rect2(Vector2(w * 0.1, top_y - 18.0), Vector2(10.0, 14.0))
	draw_arc(cup.position + Vector2(10.0, 7.0), 4.0, -PI * 0.5, PI * 0.5, 6, CERAMIC, 2.0)
	draw_rect(cup, CERAMIC)
	draw_rect(Rect2(cup.position + Vector2(1.5, 1.0), Vector2(7.0, 2.0)), Color("#1A120C"))
	draw_rect(Rect2(cup.position + Vector2(6.0, 0.0), Vector2(4.0, 14.0)), Color(0.0, 0.0, 0.0, 0.2))
	draw_rect(cup, OUTLINE, false, 1.5)


func _is_exit_sign() -> bool:
	return text.to_upper().contains("EXIT")


## Teal-lit corporate signage on two slim legs (amber in lockdown when this
## sign is one of its EnvironmentState's `lamp_paths`). Exit signs are
## always signal green (style guide: green is for exit signs).
func _draw_sign() -> void:
	var w: float = size.x
	var h: float = size.y
	var acc: Color = SIGNAL_GREEN if _is_exit_sign() else (_lockdown_tint if _lockdown else TEAL)
	for lx in [-w * 0.32, w * 0.32]:
		draw_rect(Rect2(Vector2(lx - 2.0, -h * 0.56), Vector2(4.0, h * 0.56)), SLATE)
		draw_rect(Rect2(Vector2(lx - 2.0, -h * 0.56), Vector2(4.0, h * 0.56)), OUTLINE, false, 1.0)
	var board := Rect2(Vector2(-w * 0.5, -h), Vector2(w, h * 0.46))
	draw_rect(board.grow(5.0), Color(acc, 0.07))
	draw_rect(board, NAVY)
	draw_rect(board.grow(-3.0), Color(acc, 0.7), false, 1.5)
	if text != "":
		_draw_centered_text(text, board, acc, 14)
	draw_rect(board, OUTLINE, false, 2.0)


## Slow, irregular hologram flicker (never more than ~0.5 changes a second);
## steady under reduced motion.
func _flicker_value() -> float:
	if _reduced_motion:
		return 0.85
	var t: float = _pulse_t + float(_seed % 97) * 0.13
	var f: float = 0.8 + 0.1 * sin(t * 1.3) + 0.06 * sin(t * 3.1)
	if fmod(t * 0.23, 1.0) < 0.035:
		f *= 0.45
	return clampf(f, 0.0, 1.0)


## A holographic billboard: a hovering projector beaming an amber (Adam's
## attention) hologram with scanlines, its `text` (or a lock icon) and a row
## of chevrons pointing toward the exit. Placed only in lockdown groups.
func _draw_cloud_projector() -> void:
	var r := Rect2(-size * 0.5, size)
	var col := AMBER
	var f := _flicker_value()
	var em := Vector2(0.0, r.end.y + 22.0)
	draw_colored_polygon(PackedVector2Array([
		em + Vector2(-5.0, -6.0), em + Vector2(5.0, -6.0),
		Vector2(r.end.x - 12.0, r.end.y), Vector2(r.position.x + 12.0, r.end.y),
	]), Color(col, 0.07 * f))
	draw_rect(Rect2(em + Vector2(-14.0, -4.0), Vector2(28.0, 9.0)), STEEL)
	draw_rect(Rect2(em + Vector2(-14.0, -4.0), Vector2(28.0, 9.0)), OUTLINE, false, 1.5)
	draw_circle(em + Vector2(0.0, -5.0), 3.0, col)
	draw_rect(r, Color(col, 0.1 * f))
	var y: float = r.position.y + 2.0
	while y < r.end.y:
		draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color(col, 0.08 * f), 1.0)
		y += 4.0
	draw_rect(r, Color(col, 0.6 * f), false, 1.5)
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		draw_circle(corner, 2.5, Color(col, 0.9 * f))
	var ink := Color(col, 0.9 * f)
	var chev_y: float = r.end.y - minf(12.0, r.size.y * 0.22)
	if text != "":
		var text_rect := Rect2(r.position, Vector2(r.size.x, r.size.y * 0.72))
		_draw_centered_text(text, text_rect, ink, 18)
	else:
		var ic := r.get_center() + Vector2(0.0, -4.0)
		var s: float = minf(r.size.x, r.size.y) * 0.22
		draw_arc(ic + Vector2(0.0, -s * 0.2), s * 0.5, PI, TAU, 12, ink, 3.0)
		draw_rect(Rect2(ic + Vector2(-s * 0.7, -s * 0.2), Vector2(s * 1.4, s)), ink)
	for i in 3:
		var cx: float = float(i - 1) * 16.0
		draw_polyline(PackedVector2Array([
			Vector2(cx - 4.0, chev_y - 5.0), Vector2(cx + 3.0, chev_y), Vector2(cx - 4.0, chev_y + 5.0),
		]), Color(col, 0.75 * f), 2.5)


## The server depot's security door, standing open: a heavy steel frame, the
## door leaves retracted into the jambs, a teal header strip and card
## reader (unlocked), a faint teal glow from inside and a hazard threshold.
func _draw_depot_door() -> void:
	var rect := _rect_up(size.x, size.y)
	var fw: float = maxf(8.0, size.x * 0.1)
	var opening := Rect2(rect.position + Vector2(fw, fw + 6.0), rect.size - Vector2(fw * 2.0, fw + 6.0))
	draw_rect(rect, STEEL)
	draw_rect(opening, Color("#03050A"))
	draw_rect(Rect2(opening.position + Vector2(0.0, opening.size.y * 0.55), Vector2(opening.size.x, opening.size.y * 0.45)), Color(TEAL, 0.05))
	draw_rect(Rect2(opening.position + Vector2(0.0, opening.size.y * 0.8), Vector2(opening.size.x, opening.size.y * 0.2)), Color(TEAL, 0.06))
	for lx in [opening.position.x, opening.end.x - 7.0]:
		draw_rect(Rect2(Vector2(lx, opening.position.y), Vector2(7.0, opening.size.y)), SLATE)
		draw_line(Vector2(lx + 3.5, opening.position.y + 6.0), Vector2(lx + 3.5, opening.end.y - 6.0), OUTLINE, 1.0)
	var header := Rect2(Vector2(rect.position.x + fw, rect.position.y + 4.0), Vector2(size.x - fw * 2.0, 4.0))
	draw_rect(header.grow(3.0), Color(TEAL, 0.12))
	draw_rect(header, TEAL)
	var reader := Rect2(Vector2(rect.end.x - fw + 1.0, rect.position.y + size.y * 0.45), Vector2(fw - 2.0, 14.0))
	draw_rect(reader, NAVY)
	draw_circle(reader.get_center() + Vector2(0.0, -3.0), 1.8, TEAL)
	draw_line(rect.position + Vector2(1.5, 2.0), Vector2(rect.position.x + 1.5, rect.end.y), PROP_RIM, 1.5)
	draw_rect(opening, OUTLINE, false, 2.0)
	draw_rect(rect, OUTLINE, false, 3.0)
	_draw_hazard_stripes(Rect2(Vector2(rect.position.x, -6.0), Vector2(size.x, 6.0)), 7.0)


## A spare-parts workbench (level brief "neatly sorted spare parts and cable
## spools"): a pegboard of tool silhouettes, labelled parts bins, spools on
## the lower shelf and a small clamp lamp.
func _draw_workbench() -> void:
	var w: float = size.x
	var h: float = size.y
	var top_y: float = -h * 0.5
	var peg := Rect2(Vector2(-w * 0.46, -h), Vector2(w * 0.92, h * 0.44))
	draw_rect(peg, Color("#101925"))
	var dy: float = peg.position.y + 5.0
	while dy < peg.end.y - 2.0:
		var dx: float = peg.position.x + 5.0
		while dx < peg.end.x - 2.0:
			draw_circle(Vector2(dx, dy), 0.9, Color(STEEL_HI, 0.5))
			dx += 8.0
		dy += 8.0
	var tool := Color("#56697F")
	draw_line(peg.position + Vector2(w * 0.12, 8.0), peg.position + Vector2(w * 0.12, peg.size.y - 6.0), tool, 3.0)
	draw_arc(peg.position + Vector2(w * 0.12, 8.0), 5.0, PI * 0.2, PI * 1.8, 8, tool, 2.5)
	draw_line(peg.position + Vector2(w * 0.3, 8.0), peg.position + Vector2(w * 0.26, peg.size.y - 6.0), tool, 2.5)
	draw_line(peg.position + Vector2(w * 0.3, 8.0), peg.position + Vector2(w * 0.34, peg.size.y - 6.0), tool, 2.5)
	draw_arc(peg.position + Vector2(w * 0.62, peg.size.y * 0.5), 9.0, 0.0, TAU, 14, tool, 3.0)
	draw_rect(peg, OUTLINE, false, 1.5)
	var lamp_c := Vector2(w * 0.4, -h + 6.0)
	draw_circle(lamp_c + Vector2(-4.0, 10.0), 16.0, Color(PATH_WHITE, 0.08))
	draw_colored_polygon(PackedVector2Array([
		lamp_c + Vector2(-9.0, 4.0), lamp_c + Vector2(0.0, -4.0), lamp_c + Vector2(4.0, 4.0),
	]), STEEL_HI)
	draw_line(lamp_c + Vector2(-8.0, 5.0), lamp_c + Vector2(4.0, 5.0), PATH_WHITE, 2.0)
	for lx in [-w * 0.46, w * 0.46 - 6.0]:
		draw_rect(Rect2(Vector2(lx, top_y + 6.0), Vector2(6.0, -top_y - 6.0)), STEEL)
		draw_rect(Rect2(Vector2(lx, top_y + 6.0), Vector2(6.0, -top_y - 6.0)), OUTLINE, false, 1.0)
	draw_rect(Rect2(Vector2(-w * 0.44, -12.0), Vector2(w * 0.88, 4.0)), STEEL)
	for i in 2:
		var sc := Vector2(w * 0.08 + float(i) * 24.0, -21.0)
		draw_circle(sc, 9.0, STEEL)
		draw_arc(sc, 7.0, 0.0, TAU, 12, SLATE, 2.0)
		draw_circle(sc, 2.5, OUTLINE)
		draw_arc(sc, 9.0, 0.0, TAU, 14, OUTLINE, 1.5)
	for i in 3:
		var bin := Rect2(Vector2(-w * 0.4 + float(i) * w * 0.15, top_y - 10.0), Vector2(w * 0.12, 10.0))
		draw_rect(bin, STEEL)
		draw_line(bin.position + Vector2(3.0, 4.0), bin.position + Vector2(bin.size.x - 3.0, 4.0), Color(TEAL, 0.7), 1.5)
		draw_rect(bin, OUTLINE, false, 1.0)
	var top := Rect2(Vector2(-w * 0.5, top_y), Vector2(w, 6.0))
	draw_rect(top, SLATE)
	draw_line(top.position, Vector2(top.end.x, top.position.y), PROP_RIM, 1.0)
	draw_rect(top, OUTLINE, false, 2.0)


## A steel guide rail: posts, top and mid rails, and an amber chevron plate
## pointing toward the exit — reads as "guide here" by shape alone.
func _draw_rail() -> void:
	var w: float = size.x
	var h: float = size.y
	var mid := Rect2(Vector2(-w * 0.5, -h * 0.5 - 1.5), Vector2(w, 3.0))
	draw_rect(mid, STEEL_HI)
	var posts: int = maxi(2, int(w / 60.0) + 1)
	for i in posts:
		var x: float = lerpf(-w * 0.5 + 3.0, w * 0.5 - 3.0, float(i) / float(posts - 1))
		var post := Rect2(Vector2(x - 2.5, -h - 2.0), Vector2(5.0, h + 2.0))
		draw_rect(post, SLATE)
		draw_rect(post, OUTLINE, false, 1.5)
		draw_rect(Rect2(Vector2(x - 6.0, -3.0), Vector2(12.0, 3.0)), STEEL)
	var top := Rect2(Vector2(-w * 0.5, -h), Vector2(w, 4.0))
	draw_rect(top, STEEL_HI)
	draw_rect(top, OUTLINE, false, 1.5)
	draw_line(top.position, Vector2(top.end.x, top.position.y), PROP_RIM, 1.0)
	var plate := Rect2(Vector2(-minf(w * 0.16, 26.0), -h * 0.5 - 8.0), Vector2(minf(w * 0.32, 52.0), 16.0))
	draw_rect(plate, NAVY)
	for i in 2:
		var cx: float = plate.get_center().x + (float(i) - 0.5) * 12.0
		draw_polyline(PackedVector2Array([
			Vector2(cx - 3.0, plate.position.y + 4.0), Vector2(cx + 3.0, plate.get_center().y),
			Vector2(cx - 3.0, plate.end.y - 4.0),
		]), AMBER, 2.5)
	draw_rect(plate, OUTLINE, false, 1.5)


## A wall terminal panel: a live facilities screen with readout bars, a trace
## and status LEDs; its teal turns alarm red in lockdown (when it is one of
## its EnvironmentState's `lamp_paths`). No top-edge band — it is not a
## ledge.
func _draw_panel() -> void:
	var rect := Rect2(-size * 0.5, size)
	var acc: Color = _lockdown_tint if _lockdown else TEAL
	draw_rect(rect, STEEL)
	var screen := Rect2(rect.position + Vector2(6.0, 6.0), Vector2(rect.size.x - 12.0, rect.size.y * 0.55))
	draw_rect(screen.grow(3.0), Color(acc, 0.07))
	draw_rect(screen, Color("#061018"))
	for i in 3:
		var bw: float = (screen.size.x - 12.0) * (0.35 + _hash01(_seed + i * 17) * 0.55)
		draw_rect(Rect2(screen.position + Vector2(6.0, 6.0 + float(i) * 9.0), Vector2(bw, 4.0)), Color(acc, 0.75))
	var trace := PackedVector2Array()
	var steps := 8
	for i in steps + 1:
		var tx: float = screen.position.x + 6.0 + (screen.size.x - 12.0) * float(i) / float(steps)
		var ty: float = screen.end.y - 8.0 - _hash01(_seed + i * 29) * minf(18.0, screen.size.y * 0.3)
		trace.append(Vector2(tx, ty))
	draw_polyline(trace, Color(acc, 0.6), 1.5)
	for i in 4:
		var led_c: Color = SIGNAL_GREEN
		if _lockdown:
			led_c = _lockdown_tint
		elif i == 3:
			led_c = TEAL
		draw_circle(Vector2(rect.position.x + 10.0 + float(i) * 10.0, screen.end.y + 10.0), 2.2, led_c)
	for i in 3:
		draw_rect(Rect2(Vector2(rect.end.x - 34.0 + float(i) * 9.0, screen.end.y + 6.0), Vector2(6.0, 6.0)), STEEL_HI)
	draw_line(rect.position + Vector2(1.5, 2.0), Vector2(rect.position.x + 1.5, rect.end.y - 2.0), PROP_RIM, 1.0)
	draw_rect(rect, OUTLINE, false, 2.0)


## The broken perimeter security gate the hero climbs through to enter the
## campus: heavy posts, razor wire, a dead card reader, and bent bars that
## open a gap — the one damaged fixture on an otherwise flawless campus
## (level brief: "Nothing is wrecked at first glance").
func _draw_gate() -> void:
	var w: float = size.x
	var h: float = size.y
	var zig := PackedVector2Array()
	var zx: float = -w * 0.5
	var up := true
	while zx <= w * 0.5:
		zig.append(Vector2(zx, -h - (10.0 if up else 3.0)))
		zx += 8.0
		up = not up
	draw_polyline(zig, Color(STEEL_HI, 0.8), 1.5)
	draw_rect(Rect2(Vector2(-w * 0.5, -h), Vector2(w, 5.0)), STEEL_HI)
	draw_rect(Rect2(Vector2(-w * 0.5, -h), Vector2(w, 5.0)), OUTLINE, false, 1.5)
	draw_rect(Rect2(Vector2(-w * 0.5, -10.0), Vector2(w, 4.0)), STEEL_HI)
	var bars: int = maxi(4, int(w / 16.0))
	for i in bars:
		var t: float = float(i) / float(bars - 1)
		var x0: float = lerpf(-w * 0.42, w * 0.42, t)
		var bend: float = sin(t * PI) * w * 0.16
		var a := Vector2(x0, -h + 4.0)
		var b := Vector2(x0 + bend, -h * 0.35)
		var c := Vector2(x0 + bend * 1.4, -6.0)
		draw_line(a, b, OUTLINE, 6.0)
		draw_line(b, c, OUTLINE, 6.0)
		draw_line(a, b, SLATE, 4.0)
		draw_line(b, c, SLATE, 4.0)
	for px in [-w * 0.5, w * 0.5]:
		var post := Rect2(Vector2(px - 6.0, -h - 8.0), Vector2(12.0, h + 8.0))
		draw_rect(post, STEEL)
		draw_line(post.position + Vector2(1.5, 2.0), Vector2(post.position.x + 1.5, post.end.y), PROP_RIM, 1.5)
		draw_rect(post, OUTLINE, false, 2.0)
	var reader := Rect2(Vector2(w * 0.5 - 5.0, -h * 0.62), Vector2(10.0, 16.0))
	draw_rect(reader, NAVY)
	draw_circle(reader.get_center() + Vector2(0.0, -3.0), 1.8, Color("#2A1A1E"))
	draw_rect(reader, OUTLINE, false, 1.0)
	_draw_hazard_stripes(Rect2(Vector2(-w * 0.5 + 10.0, -h * 0.58), Vector2(22.0, 10.0)), 5.0)


## AD-12: a small ceiling-mounted alarm beacon (mount + caged dome), only
## ever placed by EnvironmentState's post-awakening `lockdown_visuals_path`
## group — it never toggles its own look, it's simply absent/present per
## story state, like every other lockdown-only prop.
func _draw_beacon() -> void:
	var w: float = size.x
	var h: float = size.y
	var mount := Rect2(Vector2(-w * 0.2, -h), Vector2(w * 0.4, h * 0.26))
	draw_rect(mount, STEEL)
	draw_rect(mount, OUTLINE, false, 1.5)
	var dome_c := Vector2(0.0, -h * 0.62)
	var dome_r: float = w * 0.3
	draw_circle(dome_c, dome_r, ALARM.darkened(0.25))
	draw_circle(dome_c + Vector2(-dome_r * 0.2, -dome_r * 0.2), dome_r * 0.55, ALARM)
	draw_circle(dome_c + Vector2(-dome_r * 0.3, -dome_r * 0.3), dome_r * 0.2, Color("#FFD2D6"))
	# cage bars — a shape cue (not color-only) that reads as "alarm".
	for i in 3:
		var a: float = PI * (0.25 + 0.25 * float(i))
		draw_line(dome_c, dome_c + Vector2(cos(a), sin(a)) * (dome_r + 2.0), STEEL_HI, 1.5)
	draw_arc(dome_c, dome_r + 2.0, 0.0, PI, 10, STEEL_HI, 1.5)
	draw_circle(dome_c, dome_r, OUTLINE, false, 2.0)


## AD-12/A03 roof supports: steel columns (two I-beams, cross braces, a
## concrete footing) standing on the ground and rising to meet a floating
## platform's underside — "usable surfaces have visible supports."
## Non-colliding (Scenery is never on the world layer); the platform's own
## Block collision is untouched.
func _draw_support() -> void:
	var w: float = size.x
	var h: float = size.y
	if h <= 0.0:
		return
	var bw: float = clampf(w * 0.16, 5.0, 14.0)
	var beams := [-w * 0.5 + bw * 0.5, w * 0.5 - bw * 0.5]
	var braces: int = maxi(1, int(h / 90.0))
	for i in braces:
		var t: float = (float(i) + 1.0) / float(braces + 1)
		var y: float = -h * t
		var y0: float = -h * (float(i) / float(braces + 1))
		draw_line(Vector2(beams[0], y0), Vector2(beams[1], y), STEEL, 2.5)
		draw_line(Vector2(beams[0], y), Vector2(beams[1], y), STEEL_HI, 3.0)
	for bx in beams:
		var beam := Rect2(Vector2(bx - bw * 0.5, -h), Vector2(bw, h))
		draw_rect(beam, SLATE)
		draw_rect(Rect2(beam.position + Vector2(bw * 0.3, 0.0), Vector2(bw * 0.4, h)), STEEL)
		draw_line(beam.position + Vector2(1.0, 0.0), Vector2(beam.position.x + 1.0, 0.0), PROP_RIM, 1.5)
		draw_rect(beam, OUTLINE, false, 1.5)
	var footing := Rect2(Vector2(-w * 0.5 - 4.0, -10.0), Vector2(w + 8.0, 10.0))
	draw_rect(footing, CONCRETE_DARK)
	draw_rect(footing, OUTLINE, false, 1.5)
