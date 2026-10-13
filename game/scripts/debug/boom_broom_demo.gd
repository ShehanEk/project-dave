extends Node2D
## M3 capture demo (tools/capture.sh): Level 2 with Dave at A01's swap pad. He takes the
## Boom Broom off the pad through the real SwapConfirm dialog (his Scrapjack is left lying
## there), turns through every C50 aim step with it, blasts the practice yard's targets
## (the pellet fan, the flash, the pump stroke, the shells flying), lets the tube feed,
## then takes the Scrapjack back. The placeholder art is tools/art/paint_boom_broom.py.
##   tools/capture.sh res://scenes/debug/boom_broom_demo.tscn OUT 330 30
## `steps_at` / `blasts_at` (seconds) are when the aim-step hold and the blasts happen,
## for picking frames. Saves and logs go to user://debug_demo_throwaway/boom_broom.

const THROWAWAY := "user://debug_demo_throwaway/boom_broom"
const LEVEL_SCENE := "res://scenes/levels/level.tscn"
const PAD_ID := "L02-A01-PAD01"

var level: LevelDirector
var hero: Hero
var t := 0.0
var log_lines: PackedStringArray = []


func _enter_tree() -> void:
	CheckpointService.set_save_dir(THROWAWAY + "/saves")
	var tel := get_node_or_null("/root/Telemetry")
	if tel and tel.has_method("set_playtest_dir"):
		tel.set_playtest_dir(THROWAWAY + "/playtests")


func _ready() -> void:
	Session.new_run("L02")
	level = load(LEVEL_SCENE).instantiate()
	level.level_def = LevelDefs.get_def("L02")
	add_child(level)
	hero = level.hero
	hero.debug_invulnerable = true
	hero.use_aim_override = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	_run()


func _process(delta: float) -> void:
	t += delta


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


## Logs `what` with the time and Dave's position on screen (for cropping capture frames).
func _note(what: String) -> void:
	var screen := hero.get_global_transform_with_canvas().origin if hero else Vector2.ZERO
	var line := "%.2f frame %d screen %d,%d %s" % [t, Engine.get_frames_drawn(), int(screen.x), int(screen.y), what]
	log_lines.append(line)
	print("[boom_broom_demo] " + line)


func _aim(dir: Vector2) -> void:
	hero.aim_override = hero.aim_pivot.global_position + dir.normalized() * 400.0


func _run() -> void:
	var pad: WeaponPad = level.areas[0].get_node("Entities/WeaponPad")
	hero.respawn_at(Vector2(pad.global_position.x - 70.0, pad.global_position.y - 1.0))
	level.camera.reset_position()
	_aim(Vector2(1, 0))
	_note("at the pad with the Scrapjack")
	await _wait(0.8)
	hero.respawn_at(Vector2(pad.global_position.x, pad.global_position.y - 1.0))
	await _wait(0.4)
	pad.interact(hero)
	_note("swap dialog")
	await _wait(1.0)
	pad._dialog._on_confirm()
	_note("swapped: Broom in hand, Scrapjack on the pad")
	await _wait(0.4)
	hero.respawn_at(Vector2(pad.global_position.x + 90.0, pad.global_position.y - 1.0))
	await _wait(0.8)
	# Every aim step, facing right, then a few facing left.
	for step in range(-4, 5):
		var a := float(step) * Hero.AIM_STEP
		_aim(Vector2(cos(a), sin(a)))
		await _wait(0.2)
		_note("aim step %d facing right" % step)
		await _wait(0.15)
	for step in [-2, 0, 2]:
		var a := float(step) * Hero.AIM_STEP
		_aim(Vector2(-cos(a), sin(a)))
		await _wait(0.2)
		_note("aim step %d facing left" % step)
		await _wait(0.15)
	# Blasts at the practice yard: walk up, aim at each target, fire.
	hero.respawn_at(Vector2(1660.0, -1.0))
	_aim(Vector2(1, 0))
	await _wait(0.5)
	var targets := level.areas[0].get_node("Entities").get_children().filter(func(n): return n is PracticeTarget)
	var gun := hero.held_weapon() as BoomBroom
	for i in 3:
		var target: Node2D = targets[mini(i, targets.size() - 1)]
		hero.aim_override = target.global_position + Vector2(0.0, 0.0)
		await _wait(0.3)
		gun.try_blast()
		_note("blast %d at %s" % [i + 1, target.name])
		await _wait(0.75)
	# A level blast at nothing (the whole fan on screen), then let the tube feed.
	_aim(Vector2(1, -0.05))
	await _wait(0.2)
	gun.try_blast()
	_note("level blast (spread)")
	await _wait(0.12)
	_note("pump back")
	await _wait(1.2)
	_note("feeding a shell")
	await _wait(1.8)
	_note("reloaded %s" % str(Session.held_ammo()))
	# Back to the pad: take the Scrapjack back (the safe trial).
	hero.respawn_at(Vector2(pad.global_position.x, pad.global_position.y - 1.0))
	await _wait(0.3)
	Session.swap_weapon(PAD_ID)
	_note("swapped back: Scrapjack in hand, Broom on the pad")
	await _wait(1.0)
	_note("done")
