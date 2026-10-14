extends Node2D
## Capture demo (tools/capture.sh): Level 2's breakables, one of each kind on a lab floor. Dave
## shoots them in turn: the Scrapjack breaks a monitor, a gauge on a pipe, a vent panel and a
## display case (each cracks first where it has a cracked stage); then he swaps to the Boom
## Broom (in code) and blasts a server cabinet and a crate; last he shoots out the cracked glass
## SECRET WALL (a solid breakable) and walks through it for the chip tray and feed cartridge
## hidden behind it. About 11 s, so capture 360 frames:
##   tools/capture.sh res://scenes/debug/breakables_demo.tscn OUT 360 30
## `[breakables_demo]` lines in the log give the time and frame of each step, for picking frames.
## Throwaway save (the run is a Level 2 one so the Broom swap and the chip ids are real).

const THROWAWAY := "user://debug_demo_throwaway/breakables_demo"
const HeroScene := preload("res://scenes/actors/hero.tscn")
const CameraScene := preload("res://scenes/actors/game_camera.tscn")
const BreakableScene := preload("res://scenes/objects/breakable.tscn")
const ChipScene := preload("res://scenes/objects/chip.tscn")
const CartridgeScene := preload("res://scenes/objects/ammo_cartridge.tscn")
const BlockScript := preload("res://scripts/world/block.gd")
const Breakable := preload("res://scripts/objects/breakable.gd")
const OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
const LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"
const PAD_ID := "L02-A01-PAD01"
const ARENA_X0 := -300.0
const ARENA_W := 1900.0
const WALL := Color("#17263A")
const WALL_LIGHT := Color("#22364D")

var hero: Hero
var camera: Camera2D
var props := Node2D.new()
var t := 0.0
var log_lines: PackedStringArray = []


func _enter_tree() -> void:
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#0B121C"))
	Session.new_run("L02")
	_build_world()
	if ResourceLoader.exists(LIGHTING_SCENE):
		add_child(load(LIGHTING_SCENE).instantiate())
	if ResourceLoader.exists(OVERLAY_SCENE):
		add_child(load(OVERLAY_SCENE).instantiate())
	hero = HeroScene.instantiate()
	hero.position = Vector2(60.0, -1.0)
	add_child(hero)
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	hero.ground_aim_limit_enabled = false
	camera = CameraScene.instantiate()
	camera.set("target", hero)
	camera.set("world_limits", Rect2(ARENA_X0, -520.0, ARENA_W, 620.0))
	add_child(camera)
	await get_tree().physics_frame
	await get_tree().physics_frame
	camera.reset_position()
	_run()


func _process(delta: float) -> void:
	t += delta


func _note(what: String) -> void:
	var line := "%.2f frame %d %s" % [t, Engine.get_frames_drawn(), what]
	log_lines.append(line)
	print("[breakables_demo] " + line)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


# --- world -------------------------------------------------------------------------------------

func _rect(parent: Node, r: Rect2, color: Color, z: int) -> ColorRect:
	var c := ColorRect.new()
	c.position = r.position
	c.size = r.size
	c.color = color
	c.z_index = z
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


func _build_world() -> void:
	var back := Node2D.new()
	back.name = "Back"
	add_child(back)
	# A lab wall with panel seams, a darker room behind the secret wall, a pipe under the gauge.
	_rect(back, Rect2(ARENA_X0, -420.0, ARENA_W, 420.0), WALL, -50)
	for x in range(int(ARENA_X0), int(ARENA_X0 + ARENA_W), 210):
		_rect(back, Rect2(x, -420.0, 3.0, 420.0), WALL_LIGHT, -49)
	_rect(back, Rect2(ARENA_X0, -14.0, ARENA_W, 14.0), Color("#101B2A"), -48)
	_rect(back, Rect2(1215.0, -250.0, 360.0, 250.0), Color("#070C14"), -45)
	_rect(back, Rect2(1215.0, -252.0, 360.0, 3.0), Color("#3FE0D0", 0.5), -44)
	_rect(back, Rect2(446.0, -150.0, 7.0, 150.0), Color("#2A3A50"), -40)
	_rect(back, Rect2(520.0, -150.0, 130.0, 150.0), Color("#1C2C42"), -40)
	var geo := Node2D.new()
	add_child(geo)
	var floor_b: StaticBody2D = BlockScript.new()
	floor_b.position = Vector2(ARENA_X0, 0.0)
	floor_b.set("size", Vector2(ARENA_W, 300.0))
	floor_b.set("kind", BlockScript.Kind.GROUND)
	geo.add_child(floor_b)
	props.name = "Props"
	add_child(props)


## `contents` must be set before the breakable enters the tree (it hides them in `_ready()`).
func _place(k: int, x: float, y: float = 0.0, id: String = "", solid: bool = false, parent: Node = null,
		contents: Array[NodePath] = [], size: Vector2 = Vector2.ZERO) -> StaticBody2D:
	var b: StaticBody2D = BreakableScene.instantiate()
	b.kind = k
	b.entity_id = id
	b.solid = solid
	b.contents = contents
	b.size = size
	b.position = Vector2(x, y)
	(parent if parent != null else props).add_child(b)
	return b


# --- the show ----------------------------------------------------------------------------------

## Dave stands at `from_x`, aims at `target`'s middle and holds fire until it breaks (or `limit`
## seconds pass); the Boom Broom is pumped by hand instead.
func _shoot(target: StaticBody2D, from_x: float, label: String, limit: float = 2.4) -> void:
	hero.respawn_at(Vector2(from_x, -1.0))
	hero.facing = 1
	var mid: Vector2 = target.global_position + Vector2(0.0, -target.effective_size().y * 0.5)
	hero.aim_override = mid
	await _wait(0.25)
	_note("aim at " + label)
	var gun := hero.held_weapon()
	if gun is BoomBroom:
		(gun as BoomBroom).action = BoomBroom.Action.READY
		(gun as BoomBroom).try_blast()
		await _wait(0.2)
	else:
		Input.action_press(&"fire")
		var waited := 0.0
		var shown_crack := false
		while not target.is_broken() and waited < limit:
			await get_tree().physics_frame
			waited += get_physics_process_delta_time()
			if not shown_crack and target.stage() == Breakable.Stage.CRACKED:
				shown_crack = true
				_note(label + " cracked")
		Input.action_release(&"fire")
	_note(label + (" broke" if target.is_broken() else " still standing"))
	await _wait(0.6)


func _run() -> void:
	var monitor := _place(Breakable.Kind.MONITOR, 250.0)
	var gauge := _place(Breakable.Kind.GAUGE, 450.0, -118.0)
	var vent := _place(Breakable.Kind.VENT_PANEL, 585.0, -72.0)
	var case := _place(Breakable.Kind.DISPLAY_CASE, 760.0)
	var cabinet := _place(Breakable.Kind.SERVER_CABINET, 950.0)
	var crate := _place(Breakable.Kind.CRATE, 1090.0)
	# The secret wall, with its reward in the room behind it (hidden until it breaks).
	var room := Node2D.new()
	room.name = "SecretRoom"
	add_child(room)
	var chip: Area2D = ChipScene.instantiate()
	chip.name = "Chip"
	chip.set("entity_id", "L02-DEMO-BR01-C1")
	chip.set("value", 5)
	chip.position = Vector2(1330.0, -22.0)
	room.add_child(chip)
	var cart: Area2D = CartridgeScene.instantiate()
	cart.name = "Cartridge"
	cart.set("entity_id", "L02-DEMO-BR01-AM")
	cart.position = Vector2(1420.0, 0.0)
	room.add_child(cart)
	var hidden: Array[NodePath] = [NodePath("../Chip"), NodePath("../Cartridge")]
	var wall := _place(Breakable.Kind.GLASS_PANEL, 1240.0, 0.0, "L02-DEMO-BR01", true, room, hidden, Vector2(24.0, 250.0))
	await _wait(0.5)

	hero.respawn_at(Vector2(60.0, -1.0))
	camera.reset_position()
	await _wait(0.6)
	_note("start")
	# Scrapjack: the small ones.
	await _shoot(monitor, 120.0, "monitor")
	await _shoot(gauge, 330.0, "gauge")
	await _shoot(vent, 450.0, "vent panel")
	await _shoot(case, 640.0, "display case")
	# The Boom Broom for the big ones.
	Session.swap_weapon(PAD_ID)
	await _wait(0.2)
	await _shoot(cabinet, 850.0, "server cabinet")
	await _shoot(crate, 1000.0, "crate")
	# The secret wall: Scrapjack again (swap back), until it breaks.
	Session.swap_weapon(PAD_ID)
	await _wait(0.2)
	await _shoot(wall, 1110.0, "secret wall", 3.0)
	# Walk through the gap for the reward.
	hero.input_enabled = true
	Input.action_press(&"move_right")
	_note("walking through")
	await _wait(1.3)
	Input.action_release(&"move_right")
	_note("done: chips %d" % Session.get_wallet())
	await _wait(0.5)
	get_tree().quit()
