extends Interactable
## Level 2's alignment console at the top of the Lattice (M2, C59: "the
## alignment console gives the keycard and the archive"). Interact issues the
## level's clearance keycard through `Session.take_keycard(keycard_id,
## entity_id)` (the same record the Level 1 keycard pickup makes, so the HUD's
## card icon and the exit's reader follow it) and emits `keycard_granted`, the
## hook for M5's console sequence (Adam's hologram line). Once the card is
## held the console has nothing more to give and stops offering a prompt; a
## death rollback to before it puts the card back. No `class_name`
## (import-cache rule): tests preload it by path.

signal keycard_granted(keycard_id: String)

const OUTLINE := Color("#05070B")
const BODY := Color("#1C2A3A")
const BAND := Color("#2E3B4E")
const SCREEN := Color("#061018")
const AMBER := Color("#FFB02E")
const TEAL := Color("#3FE0D0")

## Batch 7: the painted alignment console (LabSkins "alignment_console": a curved console,
## its card slot re-lit teal on import so it reads apart from the lanes' amber-slotted control
## pads). The screen shows the state: amber lines while the card waits, teal once issued; the
## code-drawn console below stays as the fallback.
const LabSkins := preload("res://scripts/world/lab_skins.gd")
const PIECE := "alignment_console"

@export var keycard_id: String = "L02-KC01"
@export var toast_text: String = "Clearance card issued: it opens the freight lift"

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _init() -> void:
	super()
	entity_id = "L02-KC01-P"
	prompt = "Use console"


func _ready() -> void:
	if Session:
		Session.keycard_taken.connect(_on_keycard_taken)
		Session.snapshot_restored.connect(_on_snapshot_restored)
	queue_redraw()


func _exit_tree() -> void:
	if Session:
		if Session.keycard_taken.is_connected(_on_keycard_taken):
			Session.keycard_taken.disconnect(_on_keycard_taken)
		if Session.snapshot_restored.is_connected(_on_snapshot_restored):
			Session.snapshot_restored.disconnect(_on_snapshot_restored)


func is_issued() -> bool:
	return Session != null and Session.has_keycard(keycard_id)


func can_interact(_hero: Node) -> bool:
	return not is_issued()


func interact(hero: Node) -> void:
	super(hero)
	if Session == null or not Session.take_keycard(keycard_id, entity_id):
		return
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"keycard", global_position)
	if _toast:
		_toast.show_message(toast_text)
	keycard_granted.emit(keycard_id)
	queue_redraw()


func _on_keycard_taken(_id: String) -> void:
	queue_redraw()


func _on_snapshot_restored(_checkpoint_id: String) -> void:
	queue_redraw()


## A standing console: a steel pedestal, an angled screen and a card slot. The
## screen and slot read amber while the card waits, teal once it is issued.
func _draw() -> void:
	var lit := TEAL if is_issued() else AMBER
	if LabSkins.has(PIECE):
		_draw_painted(lit)
		return
	var pedestal := Rect2(Vector2(-16.0, -62.0), Vector2(32.0, 62.0))
	draw_rect(pedestal, BODY)
	draw_rect(Rect2(Vector2(-16.0, -62.0), Vector2(32.0, 6.0)), BAND)
	draw_rect(pedestal, OUTLINE, false, 2.0)
	var screen := PackedVector2Array([
		Vector2(-30.0, -66.0), Vector2(30.0, -66.0), Vector2(24.0, -100.0), Vector2(-24.0, -100.0),
	])
	draw_colored_polygon(screen, BAND)
	var inner := PackedVector2Array([
		Vector2(-25.0, -69.0), Vector2(25.0, -69.0), Vector2(20.0, -96.0), Vector2(-20.0, -96.0),
	])
	draw_colored_polygon(inner, SCREEN)
	for i in 3:
		var y := -90.0 + i * 7.0
		draw_line(Vector2(-14.0 + i * 2.0, y), Vector2(10.0 - i * 3.0, y), Color(lit, 0.75), 2.0)
	draw_polyline(PackedVector2Array([screen[0], screen[1], screen[2], screen[3], screen[0]]), OUTLINE, 2.0)
	var slot := Rect2(Vector2(-9.0, -44.0), Vector2(18.0, 4.0))
	draw_circle(slot.get_center(), 10.0, Color(lit, 0.2))
	draw_rect(slot, lit)
	if highlighted:
		draw_rect(pedestal.grow(3.0), Color(lit, 0.5), false, 1.5)


func _draw_painted(lit: Color) -> void:
	LabSkins.draw(self, PIECE)
	var screen := LabSkins.point(PIECE, "screen")
	var slot := LabSkins.point(PIECE, "slot")
	draw_circle(screen, 14.0, Color(lit, 0.12))
	for i in 3:
		var y := screen.y - 5.0 + i * 4.5
		draw_line(Vector2(screen.x - 8.0 + i * 1.5, y), Vector2(screen.x + 6.0 - i * 2.5, y), Color(lit, 0.8), 1.5)
	draw_circle(slot, 7.0, Color(TEAL, 0.2))
	if highlighted:
		var sz := LabSkins.world_size(PIECE)
		draw_rect(Rect2(Vector2(-sz.x * 0.5, -sz.y), sz).grow(3.0), Color(lit, 0.5), false, 1.5)
