class_name RouteSwitch
extends Interactable
## Visible hand lever (L01-SW01). Interact sets Session's switch true;
## idempotent (Session.set_switch no-ops and emits nothing if already set).
## Draws the matching symbol that service_walkway also draws, so the player
## can tell which walkway a given lever controls.

const OUTLINE := Color("#332a20")
const POST := Color("#8a7f6a")
const LEVER_OFF := Color("#c9663f")
const LEVER_ON := Color("#87b45e")

@export var switch_id: String = "L01-SW01"


func _init() -> void:
	super()
	prompt = "Pull lever"


func interact(hero: Node) -> void:
	super(hero)
	var was_on := _is_on()
	if Session:
		Session.set_switch(switch_id, true)
	# M6/Audio cue table: "latch" plays here. Only on the actual actuation
	# (never on a repeat interact with the switch already on) — the latch is
	# a one-way action per CONVENTIONS.md, so its sound only fires once too.
	if not was_on:
		var audio := get_node_or_null("/root/Audio")
		if audio:
			audio.play_sfx(&"latch", global_position)
	queue_redraw()


func _is_on() -> bool:
	return Session != null and Session.get_switch(switch_id)


func _draw() -> void:
	draw_rect(Rect2(Vector2(-5.0, -46.0), Vector2(10.0, 46.0)), POST)
	draw_rect(Rect2(Vector2(-5.0, -46.0), Vector2(10.0, 46.0)), OUTLINE, false, 2.0)
	var on := _is_on()
	var lever_end := Vector2(18.0, -60.0) if on else Vector2(-18.0, -60.0)
	draw_line(Vector2(0.0, -46.0), lever_end, LEVER_ON if on else LEVER_OFF, 6.0)
	draw_circle(lever_end, 5.0, OUTLINE)
	# Matching symbol (a small triangle), shared with service_walkway.
	SceneryDraw.draw_switch_symbol(self, Vector2(0.0, -78.0), on)
