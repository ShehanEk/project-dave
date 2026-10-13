class_name RoutePoint
extends Marker2D
## One step of an authored debug route through an AreaRoot's Route node
## (per CONVENTIONS.md "Areas and route bot"). Pure data; RouteBot drives the
## Hero through named-action input to reach/execute each point in order.

enum Action { MOVE, JUMP, WAIT_PLATFORM, INTERACT, WAIT_SECONDS }

@export var action: Action = Action.MOVE
## "" = main route (always included); otherwise an optional-branch id such
## as "OPT01" — included only when the harness/bot enables that branch.
@export var branch: String = ""
## Horizontal distance (px) considered "reached" for this point's x.
@export var tolerance: float = 12.0
## JUMP only: how long (s) to hold the jump action after pressing it.
@export var hold_jump: float = 0.12
## WAIT_PLATFORM only: the MovingPlatform to wait on.
@export var platform: NodePath
## WAIT_PLATFORM only: AreaRoot-LOCAL position the platform must be within
## `tolerance` of before the bot continues past this point (RouteBot
## converts it through the point's owning AreaRoot, so it reads correctly
## whether that area is tested alone at the origin or placed at a nonzero x
## offset inside the assembled level).
@export var platform_target: Vector2 = Vector2.ZERO
## WAIT_SECONDS only: how long (s) to idle here.
@export var seconds: float = 0.5


func get_platform_node() -> Node:
	if platform.is_empty():
		return null
	return get_node_or_null(platform)
