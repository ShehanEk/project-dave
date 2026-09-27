extends Node2D
## M6 (presentation pass) capture demo, resolution variant: identical setup
## to m6_ui_demo.gd (ordinary gameplay HUD, then the Maintenance Bench, then
## the WeaponPad swap confirm) but takes its OWN `Viewport.get_texture()`
## screenshots at each hold point instead of relying on `--write-movie`
## (Movie Maker mode always records at the project's configured base
## viewport size regardless of a `--resolution` CLI override, so it cannot
## prove readability at a smaller/wider window — this probe can, since a
## plain runtime screenshot captures whatever the window is actually showing).
## Run windowed (not `--headless`) with `--resolution WxH tools/godot.tscn`-
## style CLI args; writes `user://m6_res_probe/*.png` and quits.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"
const DEPOT_AREA_INDEX := 4
const OUT_DIR := "user://m6_res_probe"

var level: LevelDirector


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m6_resolution_probe")
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	Session.new_run()

	level = load(LEVEL_01).instantiate()
	add_child(level)
	await get_tree().physics_frame
	await get_tree().physics_frame
	level.hero.debug_invulnerable = true

	_run_sequence()


func _run_sequence() -> void:
	var depot: AreaRoot = level.areas[DEPOT_AREA_INDEX]
	var bench: MaintenanceBench = depot.get_node("Entities/MaintenanceBench")
	var pad: WeaponPad = depot.get_node("Entities/WeaponPad")

	Session.apply_damage(2)
	Session.collect("L01-A05-G001", 45)
	await _wait(0.6)
	_screenshot("hud")

	Session.set_story("awakening_done", true)
	bench.interact(level.hero)
	await _wait(0.8)
	_screenshot("bench")
	for child in get_tree().current_scene.get_children():
		if child is BenchPanel:
			child._on_decline_pressed()
	await get_tree().physics_frame

	pad.interact(level.hero)
	await _wait(0.8)
	_screenshot("swap")
	for child in get_tree().current_scene.get_children():
		if child is SwapConfirm:
			child._on_decline()
	await get_tree().physics_frame

	get_tree().quit()


func _screenshot(name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var size := DisplayServer.window_get_size()
	var path := "%s/%s_%dx%d.png" % [OUT_DIR, name, size.x, size.y]
	img.save_png(path)
	print("saved: ", ProjectSettings.globalize_path(path))


func _wait(seconds: float) -> void:
	var frames := int(ceil(seconds * Engine.physics_ticks_per_second))
	for i in frames:
		await get_tree().physics_frame
