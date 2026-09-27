class_name ExitWicket
extends Area2D
## Level-end trigger. Always a member of group "exit_wicket" so a harness/
## level director can find it; emits `wicket_reached` once when the hero
## first enters. This node only detects and announces the moment — CP05,
## `Session.level_completed`, and the completion screen are all owned by
## `LevelDirector._on_wicket_reached()` (04-godot-architecture.md's table
## assigns "completion" to LevelDirector), which permanently disables
## `hero.input_enabled` right after, ending the run for good (no re-enable,
## unlike a dismissible modal).

signal wicket_reached

var _reached: bool = false


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 1  # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	add_to_group("exit_wicket")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _reached or not body.is_in_group("hero"):
		return
	_reached = true
	wicket_reached.emit()


func _draw() -> void:
	var c := Color("#8fe0c9")
	draw_line(Vector2(0.0, -96.0), Vector2(0.0, 0.0), c, 3.0)
	draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 16, c, 2.0)
