class_name BranchZone
extends Area2D
## Telemetry-only marker (mask 2 hero_body) for one optional branch's own
## departure/rejoin point (07-acceptance-and-playtesting.md "time spent in
## each area and optional branch"). Placed in pairs by the area author around
## an existing OPT01/OPT02 route (never changes geometry or ids) — one
## `mode = ENTER` where the branch leaves the main route, one `mode = EXIT`
## where it rejoins. Reports directly to the `Telemetry` autoload (present in
## every real scene; silently a no-op — same as every other object's
## `if Session:`-style guard — in an isolated scene/test that never adds it).
## One-shot per instance, like BeatZone; draws nothing in normal play.

enum Mode { ENTER, EXIT }

@export var branch_id: String = ""
@export var mode: Mode = Mode.ENTER
@export var size: Vector2 = Vector2(120.0, 200.0)

var _fired: bool = false
var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = 0
	collision_mask = 1 << 1  # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape.shape = rect
	add_child(_shape)  # generated, not saved
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _fired or not body.is_in_group("hero"):
		return
	_fired = true
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry == null:
		return
	if mode == Mode.ENTER:
		telemetry.branch_enter(branch_id)
	else:
		telemetry.branch_exit(branch_id)
