extends Node2D
## S1 "the drill" (level-design/l02-alignment.md, A01's practice yard): one pop-up test dummy
## that a DrillPad (scripts/objects/drill_pad.gd) raises on its schedule. The white robotics test
## dummy of PracticeTarget (batch 7's `test_dummy` lab piece, its chest ring on the hit zone),
## but hidden until called: a FLOOR dummy rises out of a hatch in the floor, a CEILING dummy drops
## on its cable from a rail housing. Before it shows, its hatch lamp is the tell: amber for
## `tell_time`, red for the last RED_TIME (0.25 s), then it rises over `rise_time`. It goes down
## once it has taken `toughness` damage (one close Boom Broom blast, or three bolts): the chest
## washes cold white, it folds flat away from the shot and fades, and its lamp shows a steady
## status green. `retract()` lowers a dummy that is still up (the drill timed out) and `reset_target()`
## puts it back in its hatch, whole, for the next run.
##
## The origin is the MOUNT: the floor line at the hatch (FLOOR) or the underside of the rail
## housing (CEILING). `chest_height` is how far the chest ring (the hit zone's centre) stands above
## the floor (FLOOR, at least MIN_FLOOR_CHEST: the pole telescopes for taller ones) or hangs below
## the rail (CEILING). The part still inside the hatch or housing is not drawn.
##
## Stand-in art until art Batch 8: `piece` names the lab piece drawn for the dummy (code-drawn
## without it) and `hatch_piece` a painted hatch or rail housing (code-drawn while "").
## Reduced motion: no fold (it fades where it stands). No `class_name` (import-cache rule): preload
## it by path; it is in group "popup_target".

signal raised
signal knocked_down
signal lowered

enum Mount { FLOOR, CEILING }
enum State { HIDDEN, TELL, RISING, UP, FOLDING, DOWN, LOWERING }

const LabSkins := preload("res://scripts/world/lab_skins.gd")
const Lights := preload("res://scripts/actors/lit/lights.gd")

const AMBER := Color("#FFB02E")
const RED := Color("#FF3B4E")
const STATUS := Color("#4DE38A")
const OUTLINE := Color("#05070B")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
const EDGE := Color("#8FA3B8")
const HIT_FLASH := Color("#EAF6FF")
## The code-drawn dummy (used without the lab piece): white composite and a dark joint grey.
const SHELL := Color("#C9D3DC")
const JOINT := Color("#3A4658")
const RED_TIME := 0.25
const FLASH_TIME := 0.18
const FOLD_TIME := 0.4
const FOLD_ANGLE := deg_to_rad(82.0)
## A FLOOR dummy's chest can sit no lower than this (its torso then meets its base).
const MIN_FLOOR_CHEST := 54.0
## The hit zone (a circle on the chest ring, as PracticeTarget's).
const HIT_RADIUS := 28.0
const HATCH_HALF := 30.0
## The code-drawn dummy's measures (world px), close to the painted piece's (96 px tall).
const FB_TOP := 35.0      # from the chest ring up to the top of the head
const FB_TORSO := 31.0    # from the chest ring down to the torso's bottom
const FB_BASE := 21.0

@export var mount: Mount = Mount.FLOOR
## Seconds into the drill's run at which it is fully called (its tell starts `tell_time` before).
@export var appear_at: float = 0.0
@export var chest_height: float = 62.0
## Damage it takes to go down (a bolt is 1, a Boom Broom blast 1-5 by range).
@export var toughness: int = 3
@export var tell_time: float = 0.6
@export var rise_time: float = 0.35
## The lab piece drawn for the dummy ("" or a missing piece: code-drawn).
@export var piece: String = "test_dummy"
## A painted hatch or rail housing (art Batch 8); code-drawn while "".
@export var hatch_piece: String = ""
## CEILING: how far the rail stub's two brackets reach up to the ceiling (0: none drawn).
@export var stem_height: float = 0.0

var state: State = State.HIDDEN
var damage_taken: int = 0
## 0 inside its hatch, 1 fully up.
var raise: float = 0.0
var _t: float = 0.0
var _flash: float = 0.0
var _fold_sign: float = 1.0
var _reduced := false
var _lamp: PointLight2D
@onready var hit_zone: HitZone = $HitZone


func _ready() -> void:
	add_to_group("popup_target")
	var settings := get_node_or_null("/root/Settings")
	_reduced = settings != null and settings.get_reduced_motion()
	hit_zone.hit.connect(_on_hit)
	_lamp = PointLight2D.new()
	_lamp.texture = Lights.soft_disc()
	_lamp.texture_scale = 0.7
	_lamp.energy = 0.0
	_lamp.height = 24.0
	_lamp.blend_mode = Light2D.BLEND_MODE_ADD
	_lamp.position = _lamp_pos()
	add_child(_lamp)
	_apply_zone()
	queue_redraw()


# --- the drill's calls ---------------------------------------------------------------------

## Starts the tell (amber, then red for the last RED_TIME), then it rises. No-op unless hidden.
func begin_tell() -> void:
	if state != State.HIDDEN:
		return
	_enter(State.TELL)


## Rises now (skipping what is left of the tell). No-op once up or down.
func raise_target() -> void:
	if state == State.HIDDEN or state == State.TELL:
		_enter(State.RISING)


## The drill timed out: a dummy still up (or rising, or telling) goes back into its hatch.
func retract() -> void:
	if state in [State.TELL, State.RISING, State.UP]:
		_enter(State.LOWERING)


## Back in its hatch, whole, at once (a new run).
func reset_target() -> void:
	damage_taken = 0
	raise = 0.0
	_enter(State.HIDDEN)


## Down for good (the drill already done on a rebuilt level): hidden, its lamp green.
func set_done() -> void:
	damage_taken = toughness
	raise = 0.0
	_enter(State.DOWN)


func is_up() -> bool:
	return state == State.UP or (state == State.RISING and raise >= 0.5)


func is_down() -> bool:
	return state == State.FOLDING or state == State.DOWN


## Where the chest ring (the hit zone's centre) is, local, at the current rise.
func chest_local() -> Vector2:
	return Vector2(0.0, _chest_y() + _rise_offset())


# --- state ---------------------------------------------------------------------------------

func _enter(s: State) -> void:
	state = s
	_t = 0.0
	if s == State.RISING:
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"hatch_open", global_position)
	_apply_zone()
	queue_redraw()


func _physics_process(delta: float) -> void:
	_t += delta
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta)
	match state:
		State.TELL:
			if _t >= tell_time:
				_enter(State.RISING)
		State.RISING:
			raise = minf(1.0, raise + delta / maxf(rise_time, 0.01))
			if raise >= 1.0:
				_enter(State.UP)
				raised.emit()
			else:
				_apply_zone()
		State.FOLDING:
			if _t >= FOLD_TIME:
				raise = 0.0
				_enter(State.DOWN)
		State.LOWERING:
			raise = maxf(0.0, raise - delta / maxf(rise_time, 0.01))
			_apply_zone()
			if raise <= 0.0:
				_enter(State.HIDDEN)
				lowered.emit()
	_update_lamp()
	if state != State.HIDDEN and state != State.DOWN or _flash > 0.0:
		queue_redraw()


func _on_hit(damage: int, _hit_position: Vector2, direction: Vector2) -> void:
	if not is_up():
		return
	_flash = FLASH_TIME
	damage_taken += maxi(damage, 1)
	if damage_taken >= toughness:
		_fold_sign = 1.0 if direction.x >= 0.0 else -1.0
		_enter(State.FOLDING)
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"debris_clatter", global_position)
		knocked_down.emit()
	queue_redraw()


## The hit zone follows the chest and takes shots only while the dummy is up.
func _apply_zone() -> void:
	if hit_zone == null:
		return
	hit_zone.position = chest_local()
	var live := is_up()
	hit_zone.collision_layer = (1 << 4) if live else 0
	hit_zone.monitorable = live


func _chest_y() -> float:
	if mount == Mount.FLOOR:
		return -maxf(chest_height, MIN_FLOOR_CHEST)
	return maxf(chest_height, FB_TORSO + 8.0)


## How far the dummy is still sunk into its hatch (FLOOR: down, CEILING: up into the housing).
func _rise_offset() -> float:
	var travel := _travel()
	return (1.0 - raise) * travel * (1.0 if mount == Mount.FLOOR else -1.0)


func _travel() -> float:
	if mount == Mount.FLOOR:
		return maxf(chest_height, MIN_FLOOR_CHEST) + _top_above_chest()
	return _chest_y() + _torso_below_chest()


func _lamp_pos() -> Vector2:
	return Vector2(HATCH_HALF + 8.0, -6.0) if mount == Mount.FLOOR else Vector2(HATCH_HALF + 6.0, -8.0)


## The tell's colour now, or a transparent colour when no lamp is lit.
func lamp_color() -> Color:
	match state:
		State.TELL:
			return RED if _t >= tell_time - RED_TIME else AMBER
		State.DOWN, State.FOLDING:
			return Color(STATUS, 0.75)
	return Color(0, 0, 0, 0)


func _update_lamp() -> void:
	if _lamp == null:
		return
	var c := lamp_color()
	_lamp.color = Color(c, 1.0)
	_lamp.energy = 0.0 if c.a <= 0.0 else (1.1 if state == State.TELL else 0.25)


# --- drawing -------------------------------------------------------------------------------

func _has_piece() -> bool:
	return piece != "" and LabSkins.has(piece)


func _top_above_chest() -> float:
	if _has_piece():
		var e := LabSkins.entry(piece)
		return float(e["points"]["ring"][1]) * float(e["scale"])
	return FB_TOP


func _torso_below_chest() -> float:
	if _has_piece():
		var e := LabSkins.entry(piece)
		return (float(e["points"]["pole"][0]) - float(e["points"]["ring"][1])) * float(e["scale"])
	return FB_TORSO


func _draw() -> void:
	if state != State.HIDDEN and state != State.DOWN:
		var angle := 0.0
		var alpha := 1.0
		if state == State.FOLDING:
			var k := clampf(_t / FOLD_TIME, 0.0, 1.0)
			if not _reduced:
				angle = _fold_sign * FOLD_ANGLE * ease(k, 0.5) * (1.0 if mount == Mount.FLOOR else -1.0)
			alpha = 1.0 - smoothstep(0.45, 1.0, k)
		draw_set_transform(Vector2.ZERO, angle, Vector2.ONE)
		if mount == Mount.CEILING:
			# The drop cable from the housing to the head.
			var head_y := chest_local().y - _top_above_chest()
			if head_y > 0.0:
				draw_line(Vector2(0.0, 0.0), Vector2(0.0, head_y + 4.0), Color(OUTLINE, alpha), 3.0)
				draw_line(Vector2(0.0, 0.0), Vector2(0.0, head_y + 4.0), Color(EDGE, 0.6 * alpha), 1.0)
		var clip := state != State.FOLDING
		if _has_piece():
			_draw_dummy(alpha, clip)
		else:
			_draw_fallback(alpha, clip)
		if _flash > 0.0:
			var f := _flash / FLASH_TIME
			draw_circle(chest_local(), 16.0 + 6.0 * f, Color(HIT_FLASH, (0.2 + 0.35 * f) * alpha))
			draw_circle(chest_local(), 9.0, Color(HIT_FLASH, 0.5 * f * alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_mount()


## Rows [r0, r1) of the piece with their top at y, clipped to the open side of the mount
## (FLOOR: above y 0; CEILING: below y 0) when `clip`.
func _rows(r0: float, r1: float, y: float, sc: float, x: float, tint: Color, clip: bool) -> void:
	var y1 := y + (r1 - r0) * sc
	if clip:
		if mount == Mount.FLOOR:
			if y >= 0.0:
				return
			if y1 > 0.0:
				r1 = r0 + (0.0 - y) / sc
		else:
			if y1 <= 0.0:
				return
			if y < 0.0:
				r0 = r0 + (0.0 - y) / sc
				y = 0.0
	if r1 - r0 < 0.01:
		return
	LabSkins.draw_rows(self, piece, r0, r1, y, sc, tint, false, x)


func _draw_dummy(alpha: float, clip: bool) -> void:
	var e := LabSkins.entry(piece)
	var sc: float = float(e["scale"])
	var th: float = float(e["size"][1])
	var ring: Array = e["points"]["ring"]
	var pole: Array = e["points"]["pole"]
	var p0: float = float(pole[0])
	var p1: float = float(pole[1])
	var ry: float = float(ring[1])
	var x: float = (float(e["anchor_x"]) - float(ring[0])) * sc
	var tint := Color(LabSkins.DIM, alpha)
	var chest := chest_local().y
	var top := chest - ry * sc
	_rows(0.0, p0, top, sc, x, tint, clip)
	if mount == Mount.CEILING:
		return
	# The pole telescopes down to the base, which stands on the floor (sunk with the dummy).
	var off := _rise_offset()
	var base_h := (th - p1) * sc
	var base_top := -base_h + off
	var y := top + p0 * sc
	while y < base_top - 0.01:
		var rows: float = minf(p1 - p0, (base_top - y) / sc)
		_rows(p0, p0 + rows, y, sc, x, tint, clip)
		y += rows * sc
	_rows(p1, th, base_top, sc, x, tint, clip)


## The stand-in dummy without the lab piece: a white composite head, torso and chest ring.
func _draw_fallback(alpha: float, clip: bool) -> void:
	var chest := chest_local().y
	var parts: Array = []   # [Rect2, colour]
	parts.append([Rect2(-8.0, chest - FB_TOP, 16.0, 16.0), SHELL])
	parts.append([Rect2(-3.0, chest - FB_TOP + 15.0, 6.0, 5.0), JOINT])
	parts.append([Rect2(-17.0, chest - FB_TOP + 19.0, 34.0, FB_TOP - 19.0 + FB_TORSO), SHELL])
	if mount == Mount.FLOOR:
		var off := _rise_offset()
		parts.append([Rect2(-3.0, chest + FB_TORSO, 6.0, maxf(0.0, -FB_BASE + off - chest - FB_TORSO)), JOINT])
		parts.append([Rect2(-14.0, -FB_BASE * 0.4 + off, 28.0, FB_BASE * 0.4), SLATE])
	for p in parts:
		var r: Rect2 = p[0]
		if clip:
			var open := Rect2(-200.0, -2000.0, 400.0, 2000.0) if mount == Mount.FLOOR else Rect2(-200.0, 0.0, 400.0, 2000.0)
			r = r.intersection(open)
		if r.size.y <= 0.0:
			continue
		draw_rect(r, Color(p[1], alpha))
		draw_rect(r, Color(OUTLINE, alpha), false, 1.5)
	var ring := Vector2(0.0, chest)
	if not clip or (mount == Mount.FLOOR and chest < -6.0) or (mount == Mount.CEILING and chest > 6.0):
		draw_arc(ring, 9.0, 0.0, TAU, 18, Color(JOINT, alpha), 2.0)
		draw_arc(ring, 4.0, 0.0, TAU, 12, Color(JOINT, alpha), 2.0)


## The hatch in the floor (FLOOR) or the housing under its rail (CEILING), and its lamp.
func _draw_mount() -> void:
	var open := state in [State.RISING, State.UP, State.LOWERING] or (state == State.FOLDING and raise > 0.0)
	if mount == Mount.FLOOR:
		# A flush hatch: two leaves that stand open while the dummy is out.
		var slot := Rect2(-HATCH_HALF, -3.0, HATCH_HALF * 2.0, 6.0)
		draw_rect(slot, OUTLINE)
		if open:
			draw_rect(Rect2(-HATCH_HALF - 6.0, -10.0, 6.0, 10.0), STEEL)
			draw_rect(Rect2(HATCH_HALF, -10.0, 6.0, 10.0), STEEL)
		else:
			draw_rect(Rect2(-HATCH_HALF + 1.0, -2.0, HATCH_HALF * 2.0 - 2.0, 3.0), STEEL)
			draw_line(Vector2(0.0, -2.0), Vector2(0.0, 1.0), OUTLINE, 1.5)
		# Hazard corners so the hatch reads on the floor before anything rises.
		for sx in [-1.0, 1.0]:
			draw_line(Vector2(sx * HATCH_HALF, -3.0), Vector2(sx * (HATCH_HALF - 8.0), -3.0), Color(EDGE, 0.9), 2.0)
		draw_line(Vector2(-HATCH_HALF, -2.5), Vector2(HATCH_HALF, -2.5), Color(EDGE, 0.45), 1.0)
		# the lamp post beside it
		draw_rect(Rect2(HATCH_HALF + 3.0, -12.0, 10.0, 12.0), SLATE)
		draw_rect(Rect2(HATCH_HALF + 3.0, -12.0, 10.0, 12.0), OUTLINE, false, 1.5)
	else:
		# A stub of ceiling rail the housing runs on, on brackets up to the ceiling.
		if stem_height > 0.0:
			for bx in [-HATCH_HALF - 10.0, HATCH_HALF + 10.0]:
				draw_rect(Rect2(bx - 3.0, -22.0 - stem_height, 6.0, stem_height), SLATE)
				draw_rect(Rect2(bx - 3.0, -22.0 - stem_height, 6.0, stem_height), OUTLINE, false, 1.0)
		var rail := Rect2(-HATCH_HALF - 24.0, -24.0, HATCH_HALF * 2.0 + 48.0, 8.0)
		draw_rect(rail, STEEL)
		draw_rect(rail, OUTLINE, false, 1.5)
		var box := Rect2(-HATCH_HALF, -16.0, HATCH_HALF * 2.0, 16.0)
		draw_rect(box, STEEL)
		draw_rect(Rect2(-HATCH_HALF + 6.0, -2.0, HATCH_HALF * 2.0 - 12.0, 2.0), OUTLINE if open else SLATE)
		draw_rect(box, OUTLINE, false, 2.0)
		draw_line(Vector2(-HATCH_HALF + 2.0, -1.0), Vector2(HATCH_HALF - 2.0, -1.0), Color(EDGE, 0.5), 1.0)
	var c := lamp_color()
	var lp := _lamp_pos()
	draw_circle(lp, 5.5, OUTLINE)
	if c.a > 0.0:
		draw_circle(lp, 15.0, Color(c, 0.22 * c.a))
		draw_circle(lp, 4.2, c)
	else:
		draw_circle(lp, 4.2, Color(SLATE, 1.0))
