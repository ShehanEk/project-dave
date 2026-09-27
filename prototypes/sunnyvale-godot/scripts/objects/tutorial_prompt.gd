class_name TutorialPrompt
extends Node2D
## Non-blocking one-shot hint: shows `text` near a spot until `action` is
## performed once, then fades. Never pauses or gates gameplay.

@export var text: String = ""
@export var action: StringName = &"jump"

var _shown_once: bool = false

@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = text
	_label.modulate = Color(1, 1, 1, 1)
	_label.visible = true


func _process(_delta: float) -> void:
	if _shown_once:
		return
	if Input.is_action_just_pressed(action):
		_shown_once = true
		var tween := create_tween()
		tween.tween_property(_label, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): _label.visible = false)
