class_name Interactable
extends Area2D
## Base for anything the hero activates with the `interact` action
## (collision layer 6). The hero's interaction sensor highlights exactly one
## eligible Interactable — the nearest — and calls interact() on press.

signal interacted(hero: Node)

@export var prompt: String = "Interact"
## Stable entity id (e.g. "L01-A02-CP01"); empty for purely local props.
@export var entity_id: String = ""

var highlighted: bool = false


func _init() -> void:
	collision_layer = 1 << 5  # layer 6: interactable
	collision_mask = 0
	monitoring = false
	monitorable = true


## Override to refuse (e.g. bench locked before SC01). Ineligible objects are
## never highlighted.
func can_interact(_hero: Node) -> bool:
	return true


func get_prompt() -> String:
	return prompt


## True while this object's own "Toast" child (see toast_label.gd) is on
## screen. Toasts sit in the same band above the hero's head as the hero's
## PromptLabel, so the hero hides its prompt meanwhile rather than stack two
## labels on top of each other.
func is_showing_toast() -> bool:
	var toast := get_node_or_null("Toast") as CanvasItem
	return toast != null and toast.visible


func interact(hero: Node) -> void:
	interacted.emit(hero)


func set_highlighted(on: bool) -> void:
	highlighted = on
	queue_redraw()
