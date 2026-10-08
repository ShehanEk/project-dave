extends Node2D
## C52 capture demo (tools/capture.sh): the redesigned workbench panel in its three states, one
## second each: enough chips, not enough chips, Quickcycle installed. Throwaway save dir, never a
## test and never the real save.

const PANEL := "res://scenes/ui/workbench_panel.tscn"


func _ready() -> void:
	CheckpointService.set_save_dir("user://debug_demo_throwaway/workbench_panel_demo")
	Session.new_run()
	Session.set_story("awakening_done", true)
	var bg := ColorRect.new()
	bg.color = Color("#1b2a3a")
	bg.size = Vector2(1280, 720)
	add_child(bg)
	_run()


func _run() -> void:
	Session.apply_damage(2)
	Session.collect("L01-A05-G001", 45)
	var panel: WorkbenchPanel = load(PANEL).instantiate()
	add_child(panel)
	await get_tree().create_timer(1.0).timeout
	Session.state["wallet"] = 12
	Session.wallet_changed.emit(12)
	await get_tree().create_timer(1.0).timeout
	Session.state["wallet"] = 45
	Session.wallet_changed.emit(45)
	panel._on_confirm_pressed()
	await get_tree().create_timer(1.0).timeout
