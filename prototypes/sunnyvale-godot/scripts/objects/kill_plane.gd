class_name KillPlane
extends Area2D
## Safety net far below an area's real geometry (bug guard only, never
## intended to trigger in normal play): resets the hero to `reset_target`
## with `damage` (0 by default — this is not the design's one-health pit).

const OUTLINE := Color("#332a20", 0.5)

@export var damage: int = 0
## Path to a Marker2D (usually the area's own Spawn/Respawn marker).
@export var reset_target: NodePath

## Debug-only: draws a faint outline in-editor/tests when true.
static var show_debug_outline: bool = false


func _init() -> void:
	collision_layer = 1 << 7  # layer 8: hazard
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("hero") or not body.has_method("fall_to"):
		return
	var target := get_node_or_null(reset_target)
	var reset_pos: Vector2 = target.global_position if target else Vector2.ZERO
	if target == null:
		push_warning("KillPlane %s has no valid reset_target" % name)
	body.fall_to(reset_pos, damage)


func _draw() -> void:
	if show_debug_outline:
		draw_rect(Rect2(Vector2(-1000.0, -20.0), Vector2(2000.0, 40.0)), OUTLINE, false, 2.0)
