extends TestCase
## REGRESSION (post-M7 review of the Clipper hint): the screen-anchored
## "Armored!" hint box sat at y 260–428 of the 720 px screen, which is where
## the hero's head passes at the top of a normal jump (feet ≈ 560, head ≈ 464
## standing, ≈ 300 at a full-jump apex), so any jump during its 4 s showing
## went behind the box. It must sit in the band between the HUD's top-centre
## toast (ends at y 120, scenes/ui/hud.tscn) and the jump apex.

const CLIPPER := "res://scenes/actors/clipper.tscn"
const HUD_TOAST_BOTTOM := 120.0
const HERO_JUMP_APEX_HEAD := 300.0


func run() -> void:
	var clipper: Node = load(CLIPPER).instantiate()
	var hint: Control = clipper.get_node("HintLayer/HintLabel")
	check(hint.get_parent() is CanvasLayer, "hint is screen-anchored (CanvasLayer)")
	check(hint.offset_top >= HUD_TOAST_BOTTOM,
			"hint top %.0f is below the HUD toast (ends at %.0f)" % [hint.offset_top, HUD_TOAST_BOTTOM])
	check(hint.offset_bottom <= HERO_JUMP_APEX_HEAD - 40.0,
			"hint bottom %.0f stays well above a full-jump head apex (~%.0f)" % [hint.offset_bottom, HERO_JUMP_APEX_HEAD])
	clipper.free()
	await _test_hint_supersedes_prompt()
	await _test_e02_prompt_survives_firing()


## The hint and the E02 tutorial prompt carry nearly the same message; when the
## hint appears, a prompt still on screen must fade instead of overlapping it.
func _test_hint_supersedes_prompt() -> void:
	var prompt: Node = load("res://scenes/objects/tutorial_prompt.tscn").instantiate()
	prompt.text = "Clippers are armored in front — let it crash into the stone planter."
	prompt.action = &"journal"  # an action this test never presses
	add_child(prompt)
	var clipper: Node = load(CLIPPER).instantiate()
	add_child(clipper)
	clipper.global_position = Vector2(4000, 4000)  # far from anything
	await physics_frames(2)
	var panel: CanvasItem = prompt.get_node("Panel")
	check(panel.visible, "setup: the prompt is showing")
	for i in clipper.tuning.frontal_hint_threshold:
		clipper._on_front_blocked_hit(clipper.global_position)
	await seconds(0.8)
	check(clipper.hint_label.visible, "the hint is showing")
	check(not panel.visible, "the prompt faded out when the hint appeared")
	clipper.queue_free()
	prompt.queue_free()


## The E02 prompt is informational: firing at the Clipper (the first thing most
## players do) must not dismiss it; it fades on its timer or when the hint
## replaces it. It also sits left of the stone so the jump over it never passes
## through the box.
func _test_e02_prompt_survives_firing() -> void:
	var area: Node = load("res://scenes/levels/areas/a02_gardens.tscn").instantiate()
	var prompt: Node = area.get_node("Entities/TutorialPrompt_E02Clipper")
	check_eq(prompt.action, &"", "E02 prompt has no dismiss action")
	var stone: Node2D = area.get_node("Geometry/Backstop1")
	var half_w: float = 210.0
	check(prompt.position.x + half_w < stone.position.x - 40.0,
			"E02 prompt box ends left of the stone planter's jump zone")
	area.free()
	var p: Node = load("res://scenes/objects/tutorial_prompt.tscn").instantiate()
	p.text = "info"
	p.action = &""
	p.auto_fade_time = 5.0
	add_child(p)
	await physics_frames(2)
	press(&"fire")
	await physics_frames(3)
	release(&"fire")
	await seconds(0.8)
	check(p.get_node("Panel").visible, "firing does not dismiss an informational prompt")
	p.queue_free()
