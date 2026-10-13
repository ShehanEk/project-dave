class_name WeaponPad
extends Interactable
## Depot swap pad (L01-A05-PAD01). Draws the resting weapon instance's own
## workshop tag when Session says an instance rests here. Interact opens a
## SwapConfirm dialog naming both instances by tag; Confirm performs
## Session.swap_weapon(pad_id) exactly once, Cancel/Escape changes nothing.
## Never services/heals/resets anything (weapon-swaps.md).
##
## M3 (Level 2's A01 pad, L02-A01-PAD01, resting the Boom Broom L02-W02-P01): the pad
## shows the resting copy as that weapon's own gun (its scene with `held = false`, a
## child named "Display", rebuilt whenever Session's pad occupant changes), so after a
## swap Dave sees his Scrapjack lying where the Broom was (the safe trial: swap back any
## time). Between two types the prompt names the resting weapon ("Swap: Boom Broom").

## Revamp (C24) night look: a dark steel swap pad with a teal-lit top edge
## and status LEDs; a resting weapon shows as a steel-grey silhouette with
## its workshop tag in cold white.
const OUTLINE := Color("#05070B")
const PAD := Color("#1C2A3A")
const PAD_EDGE := Color("#3FE0D0")
const GUN := Color("#6A7A8C")
const TAG := Color("#D8E6F0")
const CONFIRM_SCENE := "res://scenes/ui/swap_confirm.tscn"
## The painted pixel-art look (objects sheet), drawn through ObjectSkins; the
## code-drawn pad below stays as the fallback. A resting weapon sits on the
## painted plate's top face, PAINTED_TOP world px above the pad's foot (the
## code-drawn plate is 10 px tall).
const ObjectSkins := preload("res://scripts/world/object_skins.gd")
const PIECE := "weapon_pad"
const PAINTED_TOP := 14.0

@export var pad_id: String = "L01-A05-PAD01"

@onready var _toast: ToastLabel = get_node_or_null("Toast")

var _dialog: CanvasLayer = null
## The resting copy's gun, drawn on the pad (null when the pad is empty).
var _display: Node2D = null
var _display_id: String = ""
## Where the display gun's node sits above the pad's foot (its grip; the gun lies on the plate).
const DISPLAY_OFFSET := Vector2(-8.0, -11.0)


func _init() -> void:
	super()
	prompt = "Swap"


func _ready() -> void:
	# The HUD shows the held gun's workshop tag only in a level with a swap pad
	# (LevelDirector looks for this group after building the areas).
	add_to_group("weapon_pad")
	if painted_piece() != "":
		ObjectSkins.make_crisp(self)
	if Session:
		Session.weapon_swapped.connect(_on_occupant_changed)
		Session.snapshot_restored.connect(_on_occupant_changed.bind(""))
		Session.run_reset.connect(_on_occupant_changed.bind("", ""))
	_refresh_display()


func _exit_tree() -> void:
	if Session == null:
		return
	for sig in [Session.weapon_swapped, Session.snapshot_restored, Session.run_reset]:
		for c in sig.get_connections():
			if c["callable"].get_object() == self:
				sig.disconnect(c["callable"])


func _on_occupant_changed(_a: String, _b: String) -> void:
	_refresh_display()
	queue_redraw()


## The weapon instance resting here now ("" when empty).
func resting_instance() -> String:
	return Session.weapon_on_pad(pad_id) if Session else ""


## The resting copy's gun node (tests and captures), or null.
func display_gun() -> Node2D:
	return _display


## Rebuilds the display gun when the resting copy changed.
func _refresh_display() -> void:
	var id := resting_instance()
	if id == _display_id and (_display != null or id == ""):
		return
	_display_id = id
	if _display != null:
		_display.queue_free()
		_display = null
	var weapon_type := Session.weapon_type_of(id) if id != "" else ""
	if not WeaponTypes.has_type(weapon_type):
		return
	var scene := load(WeaponTypes.scene_path(weapon_type)) as PackedScene
	if scene == null:
		return
	var gun := scene.instantiate() as Node2D
	gun.name = "Display"
	gun.set("held", false)
	if "show_tag" in gun:
		gun.set("show_tag", false)
	var top := PAINTED_TOP if painted_piece() != "" else 10.0
	gun.position = Vector2(DISPLAY_OFFSET.x, -top + DISPLAY_OFFSET.y)
	add_child(gun)
	var gun_rig: Node2D = gun.get("rig")
	if gun_rig != null:
		gun_rig.z_index = 1   # on the plate, not behind it
	_display = gun


func get_prompt() -> String:
	# Between two types the prompt names what is on the pad; a second copy of the held
	# type keeps the plain "Swap" (Level 1's pad).
	var resting := resting_instance()
	if Session and resting != "" and Session.weapon_type_of(resting) != Session.held_weapon_type():
		return "%s: %s" % [prompt, WeaponTypes.display_name(Session.weapon_type_of(resting))]
	return prompt


## The ObjectSkins piece this pad draws, or "" for the code-drawn look.
func painted_piece() -> String:
	return PIECE if ObjectSkins.has_piece(PIECE) else ""


func can_interact(_hero: Node) -> bool:
	return Session != null and Session.weapon_on_pad(pad_id) != ""


func interact(hero: Node) -> void:
	super(hero)
	if _dialog != null or not can_interact(hero):
		return
	_dialog = load(CONFIRM_SCENE).instantiate()
	var host := get_tree().current_scene if get_tree().current_scene else get_tree().root
	host.add_child(_dialog)
	_dialog.open(pad_id)
	if hero and "input_enabled" in hero:
		hero.input_enabled = false
	_dialog.closed.connect(_on_dialog_closed.bind(hero))


## ADV-04: only announce a swap when one actually happened — Decline/Escape
## (and a Confirm Session itself refused) must leave the player believing
## nothing changed, not tell them the opposite.
## NOTE: `swapped` comes from the `closed(swapped)` signal itself; `hero` is
## the EXTRA argument `.bind(hero)` appends after it (Callable.bind() args
## land after the emitted ones), not the other way around.
func _on_dialog_closed(swapped: bool, hero: Node) -> void:
	_dialog = null
	if hero and "input_enabled" in hero:
		hero.input_enabled = true
	if swapped and _toast:
		_toast.show_message("Weapon swapped")
	queue_redraw()


func _resting_tag() -> String:
	var instance_id: String = Session.weapon_on_pad(pad_id) if Session else ""
	if instance_id == "":
		return ""
	var parts := instance_id.split("-")
	return parts[-1] if parts.size() > 0 else instance_id


func _draw() -> void:
	var top := 10.0
	if painted_piece() != "":
		ObjectSkins.draw(self, PIECE)
		top = PAINTED_TOP
	else:
		var pad := Rect2(Vector2(-28.0, -10.0), Vector2(56.0, 10.0))
		draw_rect(Rect2(pad.position + Vector2(-2.0, -3.0), pad.size + Vector2(4.0, 3.0)), Color(PAD_EDGE, 0.1))
		draw_rect(pad, PAD)
		for i in 3:
			draw_circle(Vector2(-16.0 + float(i) * 16.0, -4.0), 1.6, Color(PAD_EDGE, 0.8))
		draw_rect(pad, OUTLINE, false, 2.0)
		draw_line(pad.position + Vector2(1.0, 1.0), Vector2(pad.end.x - 1.0, pad.position.y + 1.0), PAD_EDGE, 2.0)
	var tag := _resting_tag()
	if tag == "":
		return
	if _display != null:
		# The gun itself lies on the pad; only its workshop tag is drawn here, above it.
		draw_string(ThemeDB.fallback_font, Vector2(-16.0, -top - 24.0), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TAG)
		return
	draw_rect(Rect2(Vector2(-16.0, -top - 10.0), Vector2(24.0, 10.0)), GUN)
	draw_rect(Rect2(Vector2(2.0, -top - 6.0), Vector2(12.0, 5.0)), GUN)
	draw_line(Vector2(-15.0, -top - 9.0), Vector2(7.0, -top - 9.0), Color(1.0, 1.0, 1.0, 0.35), 1.0)
	draw_rect(Rect2(Vector2(-16.0, -top - 10.0), Vector2(24.0, 10.0)), OUTLINE, false, 2.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-16.0, -top - 16.0), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TAG)
