extends Node2D
## S2 "the range goes live" (level-design/l02-alignment.md, A02's live-fire lanes): the
## controller. Cold until its trigger: Dave entering its approach area (`trigger_size` at
## `trigger_offset`, an Area2D it builds, mask 2), or `trigger_node`'s `activated` signal (an
## EncounterGroup's ApproachZone moment), or a direct `go_live()`. Then the lane lamps (drawn at
## `lamp_points`, each with its own light) turn amber for `warn_time`, red for the last RED_TIME
## (0.25 s), and the range is live: every carrier in `plates` (scripts/objects/cover_plate.gd)
## starts sliding and the lamps stay a steady amber. Once, per build of the area: a death rebuilds
## it cold, and Dave (respawned at the control booth, before the lanes) sets it off again on his
## way back in.
##
## It never spawns or wakes an enemy (the encounter group's own ApproachZone does). Adam's line
## is data: with a `beat_id` the trigger moment is reported through BeatHub, exactly like a
## BeatZone, so LevelDirector plays that beat's `LevelDef.beat_lines` entry (once per run). Only
## existing cues: `adam_chime` (the lamps go amber), `latch` (the carriers engage). No flashing:
## each lamp changes colour twice and then holds. No `class_name` (import-cache rule): preload it
## by path; group "range_live".

signal warned
signal went_live

enum State { COLD, WARN, LIVE }

const Lights := preload("res://scripts/actors/lit/lights.gd")
const AMBER := Color("#FFB02E")
const RED := Color("#FF3B4E")
const COLD := Color("#C9D6E2")
const OUTLINE := Color("#05070B")
const STEEL := Color("#1C2A3A")
const SLATE := Color("#2E3B4E")
const RED_TIME := 0.25

## The carriers it starts (CoverPlate nodes).
@export var plates: Array[NodePath] = []
## The lane lamps, local: each is a lamp housing hanging from the ceiling at that point.
@export var lamp_points: PackedVector2Array = PackedVector2Array()
@export var warn_time: float = 1.2
## The approach area (local, centred on `trigger_offset`); a zero size builds none.
@export var trigger_size: Vector2 = Vector2(160.0, 400.0)
@export var trigger_offset: Vector2 = Vector2(0.0, -200.0)
## Optional: a node with an `activated` signal (an EncounterGroup) that also sets it off.
@export var trigger_node: NodePath
## Optional: the beat reported through BeatHub at the trigger (Adam's "Range is hot" line).
@export var beat_id: String = ""

var state: State = State.COLD
var _t: float = 0.0
var _plates: Array = []
var _lights: Array[PointLight2D] = []
var _area: Area2D = null


func _ready() -> void:
	add_to_group("range_live")
	for p in plates:
		var n := get_node_or_null(p)
		if n != null and n.has_method("start"):
			_plates.append(n)
	for lp in lamp_points:
		var l := PointLight2D.new()
		l.texture = Lights.soft_disc()
		l.texture_scale = 2.6
		l.height = 40.0
		l.position = lp + Vector2(0.0, 10.0)
		l.blend_mode = Light2D.BLEND_MODE_ADD
		add_child(l)
		_lights.append(l)
	if trigger_size.x > 0.0 and trigger_size.y > 0.0:
		_area = Area2D.new()
		_area.name = "Trigger"
		_area.collision_layer = 0
		_area.collision_mask = 1 << 1   # layer 2: hero_body
		_area.monitorable = false
		_area.position = trigger_offset
		var cs := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = trigger_size
		cs.shape = rect
		_area.add_child(cs)
		add_child(_area)  # generated, not saved
		_area.body_entered.connect(_on_body_entered)
	if not trigger_node.is_empty():
		var tn := get_node_or_null(trigger_node)
		if tn != null and tn.has_signal("activated"):
			tn.activated.connect(go_live)
	_update_lights()
	queue_redraw()


func is_live() -> bool:
	return state == State.LIVE


## Sets the range off (the lamps' warning, then the carriers). No-op once triggered.
func go_live() -> void:
	if state != State.COLD:
		return
	state = State.WARN
	_t = 0.0
	if beat_id != "":
		BeatHub.get_instance().beat_entered.emit(beat_id, _find_area_id())
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"adam_chime")
	warned.emit()
	_update_lights()
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("hero"):
		go_live()


func _physics_process(delta: float) -> void:
	if state != State.WARN:
		return
	var was_red := _t >= warn_time - RED_TIME
	_t += delta
	if _t >= warn_time:
		state = State.LIVE
		for p in _plates:
			if is_instance_valid(p):
				p.start()
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"latch", global_position)
		went_live.emit()
		_update_lights()
		queue_redraw()
	elif was_red != (_t >= warn_time - RED_TIME):
		_update_lights()
		queue_redraw()


## The lane lamps' colour now: cold white, amber (red for the last RED_TIME of the warning), then
## a steady amber while live.
func lamp_color() -> Color:
	match state:
		State.WARN:
			return RED if _t >= warn_time - RED_TIME else AMBER
		State.LIVE:
			return AMBER
	return COLD


func _update_lights() -> void:
	var c := lamp_color()
	for l in _lights:
		l.color = c
		l.energy = 0.35 if state == State.COLD else 0.7


func _find_area_id() -> String:
	var p := get_parent()
	while p:
		if p is AreaRoot:
			return p.area_id
		p = p.get_parent()
	return ""


func _draw() -> void:
	var c := lamp_color()
	for lp in lamp_points:
		# A lamp housing on a short stem from the ceiling, its lens facing down the lane.
		draw_rect(Rect2(lp + Vector2(-2.0, -26.0), Vector2(4.0, 18.0)), SLATE)
		var box := Rect2(lp + Vector2(-16.0, -10.0), Vector2(32.0, 14.0))
		draw_rect(box, STEEL)
		draw_rect(box, OUTLINE, false, 2.0)
		var lens := Rect2(lp + Vector2(-11.0, 2.0), Vector2(22.0, 5.0))
		draw_rect(lens, c if state != State.COLD else Color(COLD, 0.55))
		draw_rect(Rect2(lens.position - Vector2(4.0, 3.0), lens.size + Vector2(8.0, 9.0)), Color(c, 0.14))
