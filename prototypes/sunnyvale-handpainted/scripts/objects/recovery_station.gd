class_name RecoveryStation
extends Interactable
## CP01/02/03 station: heals to full and commits the checkpoint. Repeatable
## (per CONVENTIONS.md: "Reusing a station can heal and commit again but
## never respawns chips or defeated enemies" — Session.commit already only
## snapshots current state, so nothing extra is needed here). Child
## Marker2D "Respawn" is the safe spot a later reload/respawn uses.

## Revamp (C24) night look: a dark steel maintenance cabinet with a small
## status screen and a lamp on a short post — dim slate with a faint teal
## ring while waiting, lit Arcadia teal with drawn rays and a halo once it
## is the active checkpoint (shape as well as color).
const OUTLINE := Color("#05070B")
const POST := Color("#2E3B4E")
const CABINET := Color("#1C2A3A")
const CABINET_BAND := Color("#2E3B4E")
const SCREEN := Color("#061018")
const LAMP_OFF := Color("#26364A")
const LAMP_ON := Color("#3FE0D0")
const RAY_ON := Color(0.25, 0.88, 0.82, 0.8)
const RIM := Color(0.36, 0.45, 0.56, 0.55)

## M6.5 Kenney integration pass: no class_name on the puff script (see its
## own doc comment) — reached through this plain preload + its static
## `spawn()`.
const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
## The painted pixel-art look (objects sheet): lamp off / lamp on, drawn
## through ObjectSkins; the code-drawn look below stays as the fallback.
const ObjectSkins := preload("res://scripts/world/object_skins.gd")
## The painted lamp's centre, art px from the piece's top-left corner.
const LAMP_ART := Vector2(24.0, 7.5)
## Where the code-drawn lamp sits (the checkpoint sparkle and glow).
const LAMP_CODE := Vector2(0.0, -72.0)

@export var checkpoint_id: String = "CP01"

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _init() -> void:
	super()
	prompt = "Save"


func _ready() -> void:
	if painted_piece() != "":
		ObjectSkins.make_crisp(self)
	if Session:
		Session.checkpoint_committed.connect(_on_checkpoint_committed)


func _exit_tree() -> void:
	if Session and Session.checkpoint_committed.is_connected(_on_checkpoint_committed):
		Session.checkpoint_committed.disconnect(_on_checkpoint_committed)


## The lamp turns on or off as the active checkpoint changes.
func _on_checkpoint_committed(_id: String) -> void:
	queue_redraw()


## True while this is the active checkpoint (its lamp is lit).
func is_lit() -> bool:
	return Session != null and Session.state.get("checkpoint_id", "") == checkpoint_id


## The ObjectSkins piece this station draws now (lamp lit or not), or "" for
## the code-drawn look.
func painted_piece() -> String:
	if not ObjectSkins.has_pieces(["recovery_station_off", "recovery_station_on"]):
		return ""
	return "recovery_station_on" if is_lit() else "recovery_station_off"


## Where the lamp is, relative to the station's foot.
func lamp_position() -> Vector2:
	var piece := painted_piece()
	return ObjectSkins.at(piece, LAMP_ART) if piece != "" else LAMP_CODE


func get_prompt() -> String:
	return "Save"


func interact(hero: Node) -> void:
	super(hero)
	if Session == null:
		return
	Session.heal_full()
	var ok := Session.commit(checkpoint_id)
	if _toast:
		_toast.show_message("Progress saved" if ok else
				"Save failed — progress since the last checkpoint is kept in memory only")
	if ok:
		var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
		KenneyPuff.spawn(&"checkpoint_sparkle", to_global(lamp_position()), host)
	queue_redraw()


## A safe maintenance station: a squat steel cabinet with a status screen
## and a lamp on a short post — distinct from an ordinary lamp fixture, and
## readable as "lit = this is the active checkpoint" through both a
## brighter fill AND drawn rays (never color alone).
func _draw() -> void:
	var lit := is_lit()
	var piece := painted_piece()
	if piece != "":
		ObjectSkins.draw(self, piece)
		if lit:
			# The glow stays smooth over the crisp pixels.
			var lamp := lamp_position()
			draw_circle(lamp, 28.0, Color(LAMP_ON, 0.1))
			draw_circle(lamp, 20.0, Color(LAMP_ON, 0.12))
		return
	var cabinet := Rect2(Vector2(-16.0, -40.0), Vector2(32.0, 40.0))
	if lit:
		draw_circle(Vector2(0.0, -72.0), 28.0, Color(LAMP_ON, 0.1))
		draw_circle(Vector2(0.0, -72.0), 20.0, Color(LAMP_ON, 0.12))
	draw_rect(cabinet, CABINET)
	draw_rect(Rect2(cabinet.position + Vector2(0.0, 26.0), Vector2(32.0, 6.0)), CABINET_BAND)
	var screen := Rect2(cabinet.position + Vector2(5.0, 6.0), Vector2(22.0, 14.0))
	draw_rect(screen, SCREEN)
	var trace_col := Color(LAMP_ON, 0.9 if lit else 0.35)
	draw_polyline(PackedVector2Array([
		screen.position + Vector2(2.0, 8.0), screen.position + Vector2(8.0, 8.0),
		screen.position + Vector2(10.0, 3.0), screen.position + Vector2(13.0, 11.0),
		screen.position + Vector2(15.0, 8.0), screen.position + Vector2(20.0, 8.0),
	]), trace_col, 1.5)
	draw_line(cabinet.position + Vector2(1.5, 2.0), Vector2(cabinet.position.x + 1.5, cabinet.end.y), RIM, 1.5)
	draw_rect(cabinet, OUTLINE, false, 2.5)
	draw_rect(Rect2(Vector2(-4.0, -64.0), Vector2(8.0, 24.0)), POST)
	draw_rect(Rect2(Vector2(-4.0, -64.0), Vector2(8.0, 24.0)), OUTLINE, false, 2.0)
	if lit:
		for i in 6:
			var a: float = TAU * float(i) / 6.0
			draw_line(Vector2(0.0, -72.0) + Vector2(cos(a), sin(a)) * 15.0,
					Vector2(0.0, -72.0) + Vector2(cos(a), sin(a)) * 21.0, RAY_ON, 2.0)
	draw_circle(Vector2(0.0, -72.0), 14.0, LAMP_ON if lit else LAMP_OFF)
	if not lit:
		draw_arc(Vector2(0.0, -72.0), 10.0, 0.0, TAU, 16, Color(LAMP_ON, 0.35), 1.5)
	else:
		draw_circle(Vector2(-4.0, -76.0), 4.0, Color(1.0, 1.0, 1.0, 0.55))
	draw_circle(Vector2(0.0, -72.0), 14.0, OUTLINE, false, 3.0)
