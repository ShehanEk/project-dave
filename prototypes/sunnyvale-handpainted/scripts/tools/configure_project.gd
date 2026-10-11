extends SceneTree
## One-shot M0 tool: writes named input actions and display/physics defaults
## into project.godot through ProjectSettings so the file stays canonical.
## Run: Godot --headless --path . -s res://scripts/tools/configure_project.gd

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.device = -1
	return e

func _mouse(button: MouseButton) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = button
	e.device = -1
	return e

func _action(name: String, events: Array) -> void:
	ProjectSettings.set_setting("input/" + name, {"deadzone": 0.2, "events": events})

func _init() -> void:
	_action("move_left", [_key(KEY_A), _key(KEY_LEFT)])
	_action("move_right", [_key(KEY_D), _key(KEY_RIGHT)])
	_action("jump", [_key(KEY_SPACE), _key(KEY_W), _key(KEY_UP)])
	_action("fire", [_mouse(MOUSE_BUTTON_LEFT)])
	_action("interact", [_key(KEY_E)])
	_action("pause", [_key(KEY_ESCAPE)])
	_action("journal", [_key(KEY_TAB)])
	_action("skip", [_key(KEY_ENTER), _key(KEY_KP_ENTER)])
	_action("help", [_key(KEY_F1)])

	ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
	ProjectSettings.set_setting("display/window/size/viewport_height", 720)
	ProjectSettings.set_setting("display/window/size/resizable", true)
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")
	ProjectSettings.set_setting("rendering/renderer/rendering_method", "gl_compatibility")
	ProjectSettings.set_setting("rendering/renderer/rendering_method.mobile", "gl_compatibility")
	ProjectSettings.set_setting("rendering/environment/defaults/default_clear_color", Color("#0e1726"))
	ProjectSettings.set_setting("physics/common/physics_ticks_per_second", 60)
	ProjectSettings.set_setting("physics/2d/default_gravity", 0.0)

	var layers := {
		1: "world", 2: "hero_body", 3: "enemy_body", 4: "hero_hurtbox",
		5: "hittable", 6: "interactable", 7: "pickup", 8: "hazard",
	}
	for i in layers:
		ProjectSettings.set_setting("layer_names/2d_physics/layer_%d" % i, layers[i])

	ProjectSettings.set_setting("autoload/Session", "*res://scripts/session.gd")
	ProjectSettings.set_setting("autoload/CheckpointService", "*res://scripts/checkpoint_service.gd")
	ProjectSettings.set_setting("autoload/Settings", "*res://scripts/settings.gd")
	ProjectSettings.set_setting("autoload/Telemetry", "*res://scripts/telemetry.gd")
	# M6: registered AFTER Session/Settings so its own _ready() can safely
	# get_node_or_null("/root/Session") to connect cue signals.
	ProjectSettings.set_setting("autoload/Audio", "*res://scripts/audio/audio_director.gd")

	ProjectSettings.set_setting("audio/buses/default_bus_layout", "res://data/audio/default_bus_layout.tres")

	var err := ProjectSettings.save()
	print("configure_project: save -> ", error_string(err))
	quit(0 if err == OK else 1)
