class_name EvidencePickup
extends Interactable
## One-time evidence file (e.g. EF01 / L01-OPT01-A01). Interact records the
## evidence via Session.record_evidence (adds 0 chips) and shows a short
## toast. `entity_id` is the pickup's own stable id; `evidence_id` is the
## whitelisted collectible id stored in the save.

const OUTLINE := Color("#07090F")
const PAPER := Color("#D8E2EC")
const SLEEVE := Color(0.62, 0.78, 0.86, 0.35)
const BAND := Color("#07090F")
const TEXT_LINE := Color("#2E3B4E")
const GLOW := Color(0.25, 0.88, 0.82, 0.16)
## The painted pixel-art look (objects2 sheet), drawn through PickupSkins; the
## code-drawn memo below stays as the fallback. The glow grows to the painted
## folder's size (39 x 51 world px).
const PickupSkins := preload("res://scripts/world/pickup_skins.gd")
const PIECE := "evidence_folder"
const PAINTED_GLOW := 34.0

@export var evidence_id: String = "EF01"
@export var toast_text: String = "Evidence file: Lockout Notice"
## C53: what the file says, shown in the evidence reader on pickup (EF01's text follows
## design/03-progression/evidence-files.md). Empty text keeps the toast only.
@export var reader_title: String = "Lockout Notice"
@export_multiline var reader_body: String = "ARCADIA DYNAMICS  |  SEPARATION NOTICE\n\nTo: Dr. Dave Harlan, Adam Safety Team\nEffective: immediately\n\nYour access to Arcadia systems and to Adam is revoked. Your badge is void on every campus door.\n\nYou are flagged as a security threat. Staff must not speak with you or let you on site.\n\nRequested by: H. Stroud, Safety Team Lead"

const READER := preload("res://scripts/ui/evidence_reader.gd")

var _collected: bool = false

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _ready() -> void:
	if Session and Session.has_evidence(evidence_id):
		_collected = true
	if painted_piece() != "":
		PickupSkins.make_crisp(self)
	queue_redraw()


## The PickupSkins piece this file draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if PickupSkins.has_piece(PIECE) else ""


func can_interact(_hero: Node) -> bool:
	return not _collected


func get_prompt() -> String:
	return "Interact" if not _collected else ""


func interact(hero: Node) -> void:
	super(hero)
	if _collected:
		return
	if Session and Session.record_evidence(evidence_id, entity_id):
		_collected = true
		if _toast:
			_toast.show_message(toast_text)
		queue_redraw()
		_open_reader(hero)


func _open_reader(hero: Node) -> void:
	if reader_body == "" or not is_inside_tree():
		return
	var reader: CanvasLayer = READER.new()
	var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
	host.add_child(reader)
	reader.open(reader_title, reader_body)
	if hero and "input_enabled" in hero:
		hero.input_enabled = false
		reader.closed.connect(func():
			if is_instance_valid(hero):
				hero.input_enabled = true)


## EF01, the Lockout Notice: a one-page memo in a clear sleeve with a paper
## clip and a black "revoked" band (design/03-progression/evidence-files.md).
## Reads as a document, not another pickup, at gameplay size and in grayscale.
func _draw() -> void:
	if _collected:
		return
	if painted_piece() != "":
		draw_circle(Vector2.ZERO, PAINTED_GLOW, GLOW)
		PickupSkins.draw_centred(self, PIECE)
		return
	draw_circle(Vector2.ZERO, 22.0, GLOW)
	var page := Rect2(Vector2(-11.0, -15.0), Vector2(22.0, 30.0))
	draw_rect(page, PAPER)
	for i in 4:
		draw_line(page.position + Vector2(4.0, 6.0 + i * 5.0), page.position + Vector2(18.0 - (i % 2) * 5.0, 6.0 + i * 5.0), TEXT_LINE, 1.5)
	draw_rect(Rect2(page.position + Vector2(0.0, 23.0), Vector2(22.0, 4.0)), BAND)
	draw_rect(Rect2(page.position - Vector2(2.0, 2.0), page.size + Vector2(4.0, 4.0)), SLEEVE)
	draw_line(page.position + Vector2(15.0, -3.0), page.position + Vector2(15.0, 5.0), Color("#8FA1B0"), 2.0)
	draw_rect(page, OUTLINE, false, 2.0)
