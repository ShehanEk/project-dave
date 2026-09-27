class_name RecoveryStation
extends Interactable
## CP01/02/03 station: heals to full and commits the checkpoint. Repeatable
## (per CONVENTIONS.md: "Reusing a station can heal and commit again but
## never respawns gems or defeated enemies" — Session.commit already only
## snapshots current state, so nothing extra is needed here). Child
## Marker2D "Respawn" is the safe spot a later reload/respawn uses.

const OUTLINE := Color("#332a20")
const POST := Color("#8a7f6a")
const CABINET := Color("#EFE0BE")
const CABINET_BAND := Color("#365D62")
const LAMP_OFF := Color("#c9b38a")
const LAMP_ON := Color("#8fe0c9")
const RAY_ON := Color(0.56, 0.88, 0.79, 0.8)

@export var checkpoint_id: String = "CP01"

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _init() -> void:
	super()
	prompt = "Save"


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


## A safe maintenance station: a squat cream cabinet with a teal service
## band and a status lamp on a short post — distinct from an ordinary lamp
## fixture, and readable as "lit = this is the active checkpoint" through
## both a brighter fill AND drawn rays (never color alone).
func _draw() -> void:
	var lit: bool = Session != null and Session.state.get("checkpoint_id", "") == checkpoint_id
	var cabinet := Rect2(Vector2(-16.0, -40.0), Vector2(32.0, 40.0))
	draw_rect(cabinet, CABINET)
	draw_rect(Rect2(cabinet.position + Vector2(0.0, 10.0), Vector2(32.0, 8.0)), CABINET_BAND)
	draw_rect(Rect2(cabinet.position + Vector2(4.0, 22.0), Vector2(24.0, 4.0)), CABINET_BAND.lightened(0.15))
	draw_rect(cabinet, OUTLINE, false, 2.5)
	draw_rect(Rect2(Vector2(-4.0, -64.0), Vector2(8.0, 24.0)), POST)
	draw_rect(Rect2(Vector2(-4.0, -64.0), Vector2(8.0, 24.0)), OUTLINE, false, 2.0)
	if lit:
		for i in 6:
			var a: float = TAU * float(i) / 6.0
			draw_line(Vector2(0.0, -72.0) + Vector2(cos(a), sin(a)) * 15.0,
					Vector2(0.0, -72.0) + Vector2(cos(a), sin(a)) * 21.0, RAY_ON, 2.0)
	draw_circle(Vector2(0.0, -72.0), 14.0, LAMP_ON if lit else LAMP_OFF)
	draw_circle(Vector2(0.0, -72.0), 14.0, OUTLINE, false, 3.0)
