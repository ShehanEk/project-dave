class_name TestCase
extends Node
## Base for headless test cases in tests/cases/test_*.gd.
## Override run() (it may await). Use check()/check_eq(); never print PASS
## yourself. Helpers simulate input through named actions and step physics.

var failures: PackedStringArray = []
var checks_run: int = 0


func run() -> void:
	pass


func check(condition: bool, message: String) -> void:
	checks_run += 1
	if not condition:
		failures.append(message)
		push_error("CHECK FAILED: " + message)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	check(actual == expected, "%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func physics_frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


func seconds(duration: float) -> void:
	await physics_frames(int(ceil(duration * Engine.physics_ticks_per_second)))


## Instance a scene under this test node and wait for it to settle.
func spawn(scene_path: String) -> Node:
	var node: Node = load(scene_path).instantiate()
	add_child(node)
	await physics_frames(2)
	return node


func press(action: StringName) -> void:
	Input.action_press(action)


func release(action: StringName) -> void:
	Input.action_release(action)


func hold(action: StringName, duration: float) -> void:
	Input.action_press(action)
	await seconds(duration)
	Input.action_release(action)


func release_all() -> void:
	for action in InputMap.get_actions():
		if not String(action).begins_with("ui_"):
			Input.action_release(action)
