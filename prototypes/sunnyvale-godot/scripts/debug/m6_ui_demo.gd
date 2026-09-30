extends Node2D
## M6 (presentation pass) capture demo (tools/capture.sh visual evidence):
## instances the full `level_01.tscn` (LevelDirector) and drives the real
## WorkbenchPanel/SwapConfirm modals through their real owners' `interact()` (not
## a scripted stand-in), holding on: ordinary gameplay HUD (partial health,
## a nonzero wallet, Quickcycle not yet owned), the Maintenance Workbench panel,
## and the depot's WeaponPad swap confirmation — the two M6-owned UI screens
## the other capture demos (m5_demo.gd, m5b_demo.gd) don't reach. Never
## confirms/declines a purchase or swap on the player's behalf; it only opens
## and closes each modal the same way RouteBot backs out of one (Decline),
## so this demo never mutates gameplay state beyond the deliberate setup
## below.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const DEPOT_AREA_INDEX := 4

var level: LevelDirector


func _ready() -> void:
	# debug-demos-touch-real-save (critical): redirect BEFORE any Session/
	# CheckpointService call — this is a manual capture demo, never a test.
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m6_ui_demo")
	Session.new_run()

	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	await get_tree().physics_frame

	level.hero.debug_invulnerable = true

	_run_sequence()


func _run_sequence() -> void:
	var depot: AreaRoot = level.areas[DEPOT_AREA_INDEX]
	var workbench: Workbench = depot.get_node("Entities/Workbench")
	var pad: WeaponPad = depot.get_node("Entities/WeaponPad")

	# Ordinary gameplay HUD: partial health, a nonzero wallet, Quickcycle not
	# yet owned (readable partial-loss/chip/fire-readiness state, not just the
	# full/empty extremes other captures already show).
	Session.apply_damage(2)
	Session.collect("L01-A05-G001", 45)  # whitelisted id (CheckpointService validation)
	await _wait(1.0)

	# Maintenance Workbench: gated on awakening_done, per CONVENTIONS ("isolated
	# tests that never run SC01 set the flag directly on Session instead").
	Session.set_story("awakening_done", true)
	workbench.interact(level.hero)
	await _wait(1.2)
	# Buy the Quickcycle (wallet 45 >= price 40) so the follow-up gameplay
	# hold below can show its held-weapon attachment and HUD pip actually
	# owned, not just the pre-purchase workbench screen.
	for child in get_tree().current_scene.get_children():
		if child is WorkbenchPanel:
			child._on_confirm_pressed()
	await _wait(0.8)
	for child in get_tree().current_scene.get_children():
		if child is WorkbenchPanel:
			child._on_decline_pressed()  # "Close" once owned
	await get_tree().physics_frame

	# Hold on ordinary gameplay again with the Quickcycle now visibly
	# attached (flywheel cover on the held weapon; HUD pip + icon dot lit).
	await _wait(1.0)

	# WeaponPad swap confirmation (names both instances by workshop tag).
	pad.interact(level.hero)
	await _wait(1.2)
	for child in get_tree().current_scene.get_children():
		if child is SwapConfirm:
			child._on_decline()
	await _wait(0.4)


func _wait(seconds: float) -> void:
	var frames := int(ceil(seconds * Engine.physics_ticks_per_second))
	for i in frames:
		await get_tree().physics_frame
