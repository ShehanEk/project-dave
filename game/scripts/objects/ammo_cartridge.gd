extends Area2D
## A universal feed cartridge (S02 "Supplies and fiction"): the bright blue square cartridge
## with two sockets that Arcadia's maintenance crews feed their tools with and Dave's weapons
## are rigged to accept. Touching one while holding a finite-ammunition weapon (the Boom
## Broom) adds up to `shells` shells to its RESERVE, capped at the reserve capacity; what does
## not fit is discarded (a partly useful cartridge is consumed once, no hidden inventory).
## While the held weapon takes none (the Scrapjack, or a reserve already full) it stays put
## and says so once in a while, so a later pass can use it. Once taken it is gone for the run
## (`Session.collect`, value 0: it adds no microchips; a death before a checkpoint puts it
## back with the shells, like every pickup). Enemies drop none; only placed cartridges,
## recovery stations and the arena dispensers resupply (S02).
##
## Code-drawn for now (a painted piece waits for an art batch). No `class_name`
## (import-cache rule): tests and the HUD reach it by path and by its group "ammo_cartridge".

signal collected(shells: int)

const OUTLINE := Color("#07090F")
const BODY := Color("#1F6FD8")
const BODY_LIGHT := Color("#4DB0FF")
const BODY_DARK := Color("#123F8A")
const WINDOW := Color("#0A1A33")
const LABEL := Color("#E8F1FF")
const SOCKET := Color("#0B1220")
const CONTACT := Color("#3FE0D0")
const GLOW := Color(0.25, 0.6, 1.0, 0.2)
## Drawn this big (world px); Dave is 96 px tall, a chip about 20.
const SIZE := Vector2(24.0, 28.0)
## The idle bob (px, Hz); none under Reduced motion.
const BOB := 2.5
const BOB_HZ := 0.6
## Seconds between two "doesn't fit" lines while Dave stands on it.
const NOTE_COOLDOWN := 4.0

@export var entity_id: String = ""
## Shells it holds (S02: up to 8).
@export var shells: int = 8

var _t: float = 0.0
var _reduced := false
var _note_left: float = 0.0
var _taken := false


func _init() -> void:
	collision_layer = 1 << 6  # layer 7: pickup
	collision_mask = 1 << 1   # layer 2: hero_body
	monitoring = true
	monitorable = false


func _ready() -> void:
	if entity_id != "" and Session and Session.is_collected(entity_id):
		queue_free()
		return
	add_to_group("ammo_cartridge")
	var settings := get_node_or_null("/root/Settings")
	_reduced = settings != null and settings.get_reduced_motion()
	z_index = 1
	queue_redraw()


## What a cartridge would give the held weapon right now: 0 when it takes none.
static func shells_that_fit(requested: int) -> int:
	if Session == null:
		return 0
	var held := Session.held_weapon_type()
	if not WeaponTypes.uses_ammo(held):
		return 0
	var ammo := Session.held_ammo()
	var room := WeaponTypes.reserve_capacity(held) - int(ammo.get("reserve", 0))
	return clampi(room, 0, maxi(requested, 0))


func _physics_process(delta: float) -> void:
	_note_left = maxf(0.0, _note_left - delta)
	if not _reduced:
		_t += delta
		queue_redraw()
	if _taken:
		return
	# Standing on it when the gun changes or a shell is spent also counts.
	for body in get_overlapping_bodies():
		if body.is_in_group("hero"):
			_try_take()
			break


func _try_take() -> void:
	if _taken or Session == null:
		return
	var gain := shells_that_fit(shells)
	if gain <= 0:
		_say_no_fit()
		return
	if entity_id != "" and not Session.collect(entity_id, 0):
		return
	_taken = true
	var held := Session.equipped_weapon()
	var ammo := Session.held_ammo()
	Session.set_weapon_ammo(held, int(ammo["loaded"]), int(ammo["reserve"]) + gain)
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.play_sfx(&"chip_cluster", global_position)
	_toast("+%d shells" % gain)
	collected.emit(gain)
	queue_free()


func _say_no_fit() -> void:
	if _note_left > 0.0 or Session == null:
		return
	_note_left = NOTE_COOLDOWN
	var held := Session.held_weapon_type()
	if not WeaponTypes.uses_ammo(held):
		_toast("Feed cartridge: no use for the %s" % WeaponTypes.display_name(held))
	else:
		_toast("Shell reserve full")


func _toast(text: String) -> void:
	if not is_inside_tree():
		return
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("toast_message"):
		hud.toast_message(text)


func _draw() -> void:
	var bob := 0.0 if _reduced else sin(TAU * BOB_HZ * _t) * BOB
	var w := SIZE.x
	var h := SIZE.y
	var c := Vector2(0.0, -h * 0.5 - 4.0 + bob)   # hovers just above the floor
	draw_circle(c, 26.0, GLOW)
	# A soft contact shadow on the floor.
	draw_set_transform(Vector2(0.0, 2.0), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, w * 0.6, Color(0.0, 0.0, 0.0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var body := Rect2(c - Vector2(w, h) * 0.5, Vector2(w, h))
	draw_rect(body.grow(2.0), OUTLINE)
	draw_rect(body, BODY)
	# Lit top edge and dark lower edge: a squared cell with a bevel.
	draw_rect(Rect2(body.position, Vector2(w, 4.0)), BODY_LIGHT)
	draw_rect(Rect2(body.position + Vector2(0.0, h - 5.0), Vector2(w, 5.0)), BODY_DARK)
	# The charge window and a white label band.
	var win := Rect2(body.position + Vector2(5.0, 7.0), Vector2(w - 10.0, 8.0))
	draw_rect(win, WINDOW)
	draw_rect(Rect2(win.position + Vector2(1.5, 1.5), Vector2((win.size.x - 3.0) * 0.8, win.size.y - 3.0)), Color(CONTACT, 0.9))
	draw_rect(Rect2(body.position + Vector2(5.0, 17.0), Vector2(w - 10.0, 3.0)), LABEL)
	# The two sockets on the underside.
	for sx in [-w * 0.25, w * 0.25]:
		var s := Rect2(Vector2(c.x + sx - 3.0, body.end.y - 1.0), Vector2(6.0, 4.0))
		draw_rect(s, SOCKET)
		draw_rect(Rect2(s.position + Vector2(2.0, 1.0), Vector2(2.0, 2.0)), CONTACT)
