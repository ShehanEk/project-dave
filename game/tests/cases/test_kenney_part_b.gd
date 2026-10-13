extends TestCase
## M7 Kenney part B: the Patrol Rover's frontal-armor spark, its STALL smoke
## puff (and reduced-motion behaviour), its defeat smoke/spark and wreck, and
## the readable-prompt icon/text-size pass (tutorial_prompt.gd, the Rover's
## HintLabel). Like test_rover_teaching.gd, this proves the underlying
## DATA/STATE these visuals are driven by (concurrency caps, self-freeing,
## which effect is spawned in which state, resolved icon paths, font sizes)
## — not pixels, which the capture in reports/asset-inventory.md's session log
## and 09-progress-and-handoff.md speak to instead.
##
## Ported from the Clipper's version: the Clipper's looping STALL steam /
## dazed-star vent (a `visual.stall_effects_active` flag, with a static
## reduced-motion stand-in) does not exist on the Rover. The Rover vents ONE
## `machine_smoke` puff when the stall starts and nothing while it lasts, so
## tests 2 and 4 now prove that one-shot instead.

const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
const InputIconMapScript := preload("res://scripts/ui/input_icon_map.gd")
const BlockScript := preload("res://scripts/world/block.gd")


func _make_floor(x: float, y: float, w: float, h: float = 200.0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	add_child(b)
	return b


func _make_backstop(x: float, y: float, w: float, h: float) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	b.kind = BlockScript.Kind.BACKSTOP
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	return hero


func _make_rover(pos: Vector2, entity_id: String = "") -> PatrolRover:
	var r: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	r.entity_id = entity_id
	add_child(r)
	r.global_position = pos
	await physics_frames(1)
	return r


## The same host patrol_rover.gd's own `_effect_host()` resolves to in an
## isolated test scene (no AreaRoot ancestor; no current_scene under the test
## runner, so the Rover's parent), so this test observes exactly what a real
## hit/stall/defeat would spawn into (kept duplicated here, not reached via
## patrol_rover.gd's private helper, the same way every other test file here
## hand-rolls its own small setup helpers rather than reaching into the
## script under test's internals). Read it BEFORE a defeat: the Rover is gone
## afterwards.
func _effect_host(rover: PatrolRover) -> Node:
	var scene := get_tree().current_scene
	return scene if scene != null else rover.get_parent()


## KenneyPuff effect nodes of ONE OR MORE `kinds` directly under `host`
## (matched by `effect_kind`, set by every spawn() call — see kenney_puff.gd's
## own doc comment). Matching the EXACT kind(s) under test is what keeps this
## robust against unrelated effects (this file's own Hero instances trigger a
## `landing_dust` puff on their very first floor contact, for one).
func _puffs(host: Node, kinds: Array) -> Array:
	var found: Array = []
	for child in host.get_children():
		if child.get_script() == KenneyPuff and kinds.has(child.effect_kind):
			found.append(child)
	return found


func _count_kenney_puffs(host: Node, kinds: Array) -> int:
	return _puffs(host, kinds).size()


## How many puffs of `kind` in `nodes` (an `_puffs()` result).
func _of_kind(nodes: Array, kind: StringName) -> int:
	var n := 0
	for p in nodes:
		if p.effect_kind == kind:
			n += 1
	return n


## Runs a fresh rover into the backstop until it STALLs (the hero stands on
## the open side of the backstop, as in the real E02/E04 layout), returning
## once the state is STALL (or the frame budget ran out).
func _run_until_stall(rover: PatrolRover) -> void:
	var frame := 0
	while rover.state != PatrolRover.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1


func run() -> void:
	await _test_frontal_blocked_hit_spawns_capped_spark_and_never_damages()
	await _test_stall_vents_one_shot_smoke_and_frees_it()
	await _test_defeat_spawns_effects_and_wreck_and_frees_them()
	await _test_reduced_motion_still_vents_a_smaller_puff()
	await _test_tutorial_prompt_resolves_icon_and_falls_back_after_rebind()
	await _test_prompt_and_hint_text_size_scales_with_setting()


## --- 1: frontal clang is capped and never a damage path ---------------------

func _test_frontal_blocked_hit_spawns_capped_spark_and_never_damages() -> void:
	var rover := await _make_rover(Vector2(500, 560))
	var host := _effect_host(rover)
	var kinds: Array = [&"armor_spark"]
	var baseline: int = _count_kenney_puffs(host, kinds)

	for i in 6:
		var outcome: StringName = rover.front_hit_zone.take_hit(1, rover.global_position, Vector2.LEFT)
		check(outcome == &"blocked", "frontal hit %d is blocked, i.e. never resolves as damage" % (i + 1))
	check(rover.state != PatrolRover.State.DEFEATED, "6 rapid frontal hits never defeat the Rover (front never damages)")

	var live: int = _count_kenney_puffs(host, kinds) - baseline
	check(live > 0, "at least one armor_spark effect spawned from the 6 rapid blocked hits (got %d)" % live)
	check(live <= 3, "armor_spark concurrency is capped so rapid fire cannot flood the screen (got %d live)" % live)

	# Longest armor_spark life is lifetime(0.18s)*1.4 + 0.15s margin.
	await seconds(0.6)
	check_eq(_count_kenney_puffs(host, kinds), baseline,
			"every capped spark effect self-frees — none linger past their configured life")

	rover.queue_free()
	await physics_frames(1)


## --- 2: the STALL smoke is a one-shot at the state's start, not a loop -----

func _test_stall_vents_one_shot_smoke_and_frees_it() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)

	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var rover := await _make_rover(Vector2(500, 560))
	var host := _effect_host(rover)
	var kinds: Array = [&"machine_smoke"]
	var baseline: int = _count_kenney_puffs(host, kinds)
	check_eq(baseline, 0, "no machine_smoke puff exists before any charge")

	await _run_until_stall(rover)
	check(rover.state == PatrolRover.State.STALL, "the Rover reaches STALL")
	check_eq(_count_kenney_puffs(host, kinds) - baseline, 1,
			"exactly one machine_smoke puff vents the instant STALL starts")

	# The puff lives lifetime(0.4s)*1.4 + 0.15s = 0.71s; STALL lasts 1.6s. A
	# looping vent would still be spawning; a one-shot is gone by now.
	await seconds(0.9)
	check(rover.state == PatrolRover.State.STALL, "still stalled 0.9 s in")
	check_eq(_count_kenney_puffs(host, kinds), baseline,
			"the smoke puff freed itself while the Rover is still stalled — a one-shot, never a loop")

	var frame := 0
	while rover.state == PatrolRover.State.STALL and frame < 180:
		await physics_frames(1)
		frame += 1
	check(rover.state == PatrolRover.State.RECOVERY, "the Rover leaves STALL for RECOVERY")
	check_eq(_count_kenney_puffs(host, kinds), baseline, "no smoke is left behind when STALL ends")

	hero.queue_free()
	if is_instance_valid(rover):
		rover.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
	Settings.set_reduced_motion(base_reduced)


## --- 3: defeat fires its own one-shot effects and leaves a wreck -----------

func _test_defeat_spawns_effects_and_wreck_and_frees_them() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var entity_id := "L01-TEST-M01-02"
	var rover := await _make_rover(Vector2(500, 560), entity_id)
	var had_rig: bool = rover.rig != null

	await _run_until_stall(rover)
	check(rover.state == PatrolRover.State.STALL, "the Rover stalls against the backstop")

	var host := _effect_host(rover)
	var kinds: Array = [&"machine_smoke", &"machine_spark"]
	# The stall's own smoke puff may still be alive; only puffs that appear
	# AFTER the killing blow count as the defeat's.
	var before: Array = _puffs(host, kinds)
	var defeat_count := [0]
	rover.defeated.connect(func(_id): defeat_count[0] += 1)
	for i in rover.tuning.motor_health:
		rover.rear_hit_zone.take_hit(1, rover.rear_hit_zone.global_position, Vector2.RIGHT)
	check_eq(defeat_count[0], 1, "the killing blow defeats the Rover exactly once")

	var fresh: Array = _puffs(host, kinds).filter(func(p): return not before.has(p))
	check(_of_kind(fresh, &"machine_smoke") >= 1 and _of_kind(fresh, &"machine_spark") >= 1,
			"defeat spawns its own one-shot smoke + spark bits (task brief), got %d smoke / %d spark new effect node(s)" % [
					_of_kind(fresh, &"machine_smoke"), _of_kind(fresh, &"machine_spark")])

	# The old 0.35 s defeat fade is gone: the Rover frees itself at once and
	# its parts fly apart as a wreck (only built when the rig loaded).
	await physics_frames(3)
	check(not is_instance_valid(rover), "the defeated Rover is gone at once, with no fade timer")
	if had_rig:
		check(host.get_node_or_null("Wreck_" + entity_id) != null, "a Wreck_<entity_id> node takes the Rover's place")
	await seconds(0.9)
	check_eq(_count_kenney_puffs(host, kinds), 0, "the defeat effects (and the stall smoke) self-free too — no leftover nodes")

	backstop.queue_free()
	floor_b.queue_free()
	if is_instance_valid(hero):
		hero.queue_free()
	await physics_frames(1)


## --- 4: reduced_motion keeps the stall smoke, with fewer particles ----------

func _test_reduced_motion_still_vents_a_smaller_puff() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()

	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var kinds: Array = [&"machine_smoke"]

	# Normal motion first, for the particle count to compare against.
	Settings.set_reduced_motion(false)
	var normal_rover := await _make_rover(Vector2(500, 560))
	var host := _effect_host(normal_rover)
	await _run_until_stall(normal_rover)
	var normal_puffs: Array = _puffs(host, kinds)
	check_eq(normal_puffs.size(), 1, "normal motion: the stall vents one smoke puff")
	var normal_amount: int = (normal_puffs[0].get_node("Particles") as CPUParticles2D).amount if normal_puffs.size() == 1 else -1
	normal_rover.queue_free()
	await seconds(0.9)
	check_eq(_count_kenney_puffs(host, kinds), 0, "setup: the normal-motion puff freed itself")

	Settings.set_reduced_motion(true)
	Session.new_run()
	var rover := await _make_rover(Vector2(500, 560))
	await _run_until_stall(rover)
	check(rover.state == PatrolRover.State.STALL, "the Rover stalls with reduced_motion on")
	var calm_puffs: Array = _puffs(host, kinds)
	check_eq(calm_puffs.size(), 1, "reduced_motion: the stall still vents its smoke puff — never fully hidden")
	if calm_puffs.size() == 1 and normal_amount > 0:
		var calm_amount: int = (calm_puffs[0].get_node("Particles") as CPUParticles2D).amount
		check(calm_amount < normal_amount,
				"reduced_motion: the puff has fewer particles than normal motion (%d vs %d)" % [calm_amount, normal_amount])

	await seconds(0.9)
	check_eq(_count_kenney_puffs(host, kinds), 0, "reduced_motion: the puff frees itself too")

	hero.queue_free()
	if is_instance_valid(rover):
		rover.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
	Settings.set_reduced_motion(base_reduced)


## --- 5: tutorial prompt icons follow InputMap, with a text fallback --------

func _test_tutorial_prompt_resolves_icon_and_falls_back_after_rebind() -> void:
	var original_events := InputMap.action_get_events(&"jump")

	var prompt: TutorialPrompt = load("res://scenes/objects/tutorial_prompt.tscn").instantiate()
	prompt.text = "Jump"
	prompt.icon_actions = [&"jump"]
	add_child(prompt)
	await physics_frames(1)

	var icons_box: HBoxContainer = prompt.get_node("Panel/Row/Icons")
	var has_icon := false
	for child in icons_box.get_children():
		if child is TextureRect:
			has_icon = true
	check(has_icon, "the default Space binding for 'jump' resolves to a real key-cap icon")

	prompt.queue_free()
	await physics_frames(1)

	# Rebind "jump" to a key with no icon. Since the pixel UI pass every key
	# whose label the pixel font can letter gets a key cap (Q included), so the
	# no-icon key is one whose label it cannot: ";" on a real keyboard layout,
	# "Semicolon" (longer than a cap holds) on the headless display server.
	InputMap.action_erase_events(&"jump")
	var rebind := InputEventKey.new()
	rebind.physical_keycode = KEY_SEMICOLON
	InputMap.action_add_event(&"jump", rebind)
	var expected_token := "[%s]" % InputIconMapScript.key_label(KEY_SEMICOLON)

	var prompt2: TutorialPrompt = load("res://scenes/objects/tutorial_prompt.tscn").instantiate()
	prompt2.text = "Jump"
	prompt2.icon_actions = [&"jump"]
	add_child(prompt2)
	await physics_frames(1)

	var icons_box2: HBoxContainer = prompt2.get_node("Panel/Row/Icons")
	var has_icon2 := false
	var fallback_text := ""
	for child in icons_box2.get_children():
		if child is TextureRect:
			has_icon2 = true
		elif child is Label:
			fallback_text = child.text
	check(not has_icon2, "no key cap exists for the rebound key, so no TextureRect renders for it")
	check(fallback_text == expected_token, "a text fallback token names the CURRENT bound key instead (want '%s', got '%s')" % [expected_token, fallback_text])

	prompt2.queue_free()
	await physics_frames(1)

	InputMap.action_erase_events(&"jump")
	for e in original_events:
		InputMap.action_add_event(&"jump", e)


## --- 6: prompt/hint text scales with Settings' text-size setting -----------

func _test_prompt_and_hint_text_size_scales_with_setting() -> void:
	var original_size: String = Settings.get_text_size()

	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var prompt: TutorialPrompt = load("res://scenes/objects/tutorial_prompt.tscn").instantiate()
	prompt.text = "Jump"
	add_child(prompt)
	await physics_frames(1)
	var text_label: Label = prompt.get_node("Panel/Row/TextLabel")
	var normal_size: int = text_label.get_theme_font_size("font_size")
	check(normal_size >= 22, "the tutorial prompt's text is >= 22px at Normal text size (got %d)" % normal_size)

	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(1)
	var large_size: int = text_label.get_theme_font_size("font_size")
	check(large_size > normal_size,
			"the tutorial prompt's text grows at Large text size (normal=%d, large=%d)" % [normal_size, large_size])

	prompt.queue_free()
	await physics_frames(1)

	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var rover := await _make_rover(Vector2(500, 560))
	await physics_frames(1)
	var hint_normal: int = rover.hint_label.get_theme_font_size("font_size")
	check(hint_normal >= 22, "the Rover's 2-hit hint text is >= 22px at Normal text size (got %d)" % hint_normal)

	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(1)
	var hint_large: int = rover.hint_label.get_theme_font_size("font_size")
	check(hint_large > hint_normal,
			"the hint text also grows at Large text size (normal=%d, large=%d)" % [hint_normal, hint_large])

	rover.queue_free()
	await physics_frames(1)
	Settings.set_text_size(original_size)
