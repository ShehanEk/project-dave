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

@export var evidence_id: String = "EF01"
@export var toast_text: String = "Evidence file: Lockout Notice"

var _collected: bool = false

@onready var _toast: ToastLabel = get_node_or_null("Toast")


func _ready() -> void:
	if Session and Session.has_evidence(evidence_id):
		_collected = true
	queue_redraw()


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


## EF01, the Lockout Notice: a one-page memo in a clear sleeve with a paper
## clip and a black "revoked" band (design/03-progression/evidence-files.md).
## Reads as a document, not another pickup, at gameplay size and in grayscale.
func _draw() -> void:
	if _collected:
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
