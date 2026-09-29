extends TestCase
## M7 Kenney part B: the Clipper's frontal-clang spark, its STALL steam/dazed-
## star venting (and reduced-motion fallback), its defeat puff/spark, and the
## readable-prompt icon/text-size pass (tutorial_prompt.gd, clipper.gd's
## HintLabel). Like test_clipper_teaching.gd, this proves the underlying
## DATA/STATE these visuals are driven by (concurrency caps, self-freeing,
## which effect is active in which state, resolved icon paths, font sizes) —
## not pixels, which the capture in reports/asset-inventory.md's session log
## and 09-progress-and-handoff.md speak to instead.

const KenneyPuff := preload("res://scripts/effects/kenney/kenney_puff.gd")
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


func _make_clipper(pos: Vector2, entity_id: String = "") -> Clipper:
	var c: Clipper = load("res://scenes/actors/clipper.tscn").instantiate()
	c.entity_id = entity_id
	add_child(c)
	c.global_position = pos
	await physics_frames(1)
	return c


## The same current-scene-or-root fallback clipper.gd's own `_effect_host()`
## uses, so this test observes exactly what a real hit/defeat would spawn
## into (kept duplicated here, not reached via clipper.gd's private helper,
## the same way every other test file here hand-rolls its own small setup
## helpers rather than reaching into the script under test's internals).
func _effect_host() -> Node:
	var scene := get_tree().current_scene
	return scene if scene != null else get_tree().root


## Counts only KenneyPuff effect nodes of ONE `kind` under `host` (matched by
## `effect_kind`, set by every spawn() call — see kenney_puff.gd's own doc
## comment). `host` here is `get_tree().root` (the whole test suite's shared
## scene root, since no test sets `current_scene`) — other nodes (this file's
## own Hero instances trigger a `landing_dust` puff on their very first floor
## contact, for one) churn through it constantly, so a raw child-count delta
## or an "is this any KenneyPuff" filter would both be flaky; matching the
## EXACT kind(s) under test is what makes this robust.
func _count_kenney_puffs(host: Node, kinds: Array) -> int:
	var n := 0
	for child in host.get_children():
		if child.get_script() == KenneyPuff and kinds.has(child.effect_kind):
			n += 1
	return n


func run() -> void:
	await _test_frontal_blocked_hit_spawns_capped_spark_and_never_damages()
	await _test_stall_effects_start_and_stop_with_state()
	await _test_stall_effects_stop_cleanly_on_defeat_and_defeat_spawns_effects()
	await _test_reduced_motion_swaps_steam_loop_for_static_puff()
	await _test_tutorial_prompt_resolves_icon_and_falls_back_after_rebind()
	await _test_prompt_and_hint_text_size_scales_with_setting()


## --- 1: frontal clang is capped and never a damage path ---------------------

func _test_frontal_blocked_hit_spawns_capped_spark_and_never_damages() -> void:
	var clipper := await _make_clipper(Vector2(500, 560))
	var host := _effect_host()
	var kinds: Array = [&"clipper_spark"]
	var baseline: int = _count_kenney_puffs(host, kinds)

	for i in 6:
		var outcome: StringName = clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
		check(outcome == &"blocked", "frontal hit %d is blocked, i.e. never resolves as damage" % (i + 1))
	check(clipper.state != Clipper.State.DEFEATED, "6 rapid frontal hits never defeat the Clipper (front never damages)")

	var live: int = _count_kenney_puffs(host, kinds) - baseline
	check(live > 0, "at least one clipper_spark effect spawned from the 6 rapid blocked hits (got %d)" % live)
	check(live <= 3, "clipper_spark concurrency is capped so rapid fire cannot flood the screen (got %d live)" % live)

	# Longest clipper_spark life is lifetime(0.18s)*1.4 + 0.15s margin.
	await seconds(0.6)
	check_eq(_count_kenney_puffs(host, kinds), baseline,
			"every capped spark effect self-frees — none linger past their configured life")

	clipper.queue_free()
	await physics_frames(1)


## --- 2: the STALL steam/dazed-star loop tracks the state exactly -----------

func _test_stall_effects_start_and_stop_with_state() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(false)

	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var clipper := await _make_clipper(Vector2(500, 560))

	check(not clipper.visual.stall_effects_active, "the steam/dazed-star loop is off before any charge")
	check(not clipper.visual.stall_static_visible, "the reduced-motion static puff is off before any charge")

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.STALL, "the Clipper reaches STALL")
	check(clipper.visual.stall_effects_active, "the looping steam/dazed-star effects turn on the instant STALL starts")
	check(not clipper.visual.stall_static_visible, "the static fallback puff stays off while reduced_motion is false")

	frame = 0
	while clipper.state == Clipper.State.STALL and frame < 180:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.RECOVERY, "the Clipper leaves STALL for RECOVERY")
	check(not clipper.visual.stall_effects_active, "the looping effects stop the instant STALL ends (recovery) — 'stop cleanly'")
	check(not clipper.visual.stall_static_visible, "the static fallback also clears once STALL ends")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
	Settings.set_reduced_motion(base_reduced)


## --- 3: defeat stops the loop cleanly and fires its own one-shot effects ---

func _test_stall_effects_stop_cleanly_on_defeat_and_defeat_spawns_effects() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var clipper := await _make_clipper(Vector2(500, 560))

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.STALL, "the Clipper stalls against the backstop")
	check(clipper.visual.stall_effects_active, "the stall loop is active going into the killing blow")

	var host := _effect_host()
	var kinds: Array = [&"clipper_defeat_smoke", &"clipper_defeat_spark"]
	var baseline: int = _count_kenney_puffs(host, kinds)
	var defeat_count := [0]
	clipper.defeated.connect(func(_id): defeat_count[0] += 1)
	for i in clipper.tuning.motor_health:
		clipper.rear_hit_zone.take_hit(1, clipper.rear_hit_zone.global_position, Vector2.RIGHT)
	check_eq(defeat_count[0], 1, "the killing blow defeats the Clipper exactly once")

	# clipper.gd's own _defeat()/_physics_process() only pushes the new
	# DEFEATED pose to Visual on the Clipper's NEXT physics tick (M6's
	# "presentation-only... reads state other code already computed" split) —
	# `take_hit()` above ran synchronously outside that tick, so give it one
	# frame before reading the pose-driven `stall_effects_active` back.
	await physics_frames(1)
	check(not clipper.visual.stall_effects_active,
			"the looping stall effects stop the instant defeat starts, even though the motor was still exposed")

	var spawned: int = _count_kenney_puffs(host, kinds) - baseline
	check(spawned >= 2, "defeat spawns its own one-shot smoke + spark bits (task brief), got %d new effect node(s)" % spawned)

	await physics_frames(int(Clipper.DEFEAT_FADE_TIME * 60.0) + 5)
	check(not is_instance_valid(clipper), "the defeated Clipper is gone after its fade")
	await seconds(0.7)
	check_eq(_count_kenney_puffs(host, kinds), baseline, "the defeat effects self-free too — no leftover nodes")

	backstop.queue_free()
	floor_b.queue_free()
	if is_instance_valid(hero):
		hero.queue_free()
	await physics_frames(1)


## --- 4: reduced_motion swaps the looping steam for one static puff ---------

func _test_reduced_motion_swaps_steam_loop_for_static_puff() -> void:
	var base_reduced: bool = Settings.get_reduced_motion()
	Settings.set_reduced_motion(true)

	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var clipper := await _make_clipper(Vector2(500, 560))

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.STALL, "the Clipper stalls with reduced_motion on")
	check(not clipper.visual.stall_effects_active,
			"reduced_motion: no looping steam/dazed-star effect while stalled")
	check(clipper.visual.stall_static_visible,
			"reduced_motion: a single static puff shows instead — never fully hidden")

	frame = 0
	while clipper.state == Clipper.State.STALL and frame < 180:
		await physics_frames(1)
		frame += 1
	check(not clipper.visual.stall_static_visible, "the static puff also clears once STALL ends")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
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
	check(has_icon, "the default Space binding for 'jump' resolves to a real Kenney icon")

	prompt.queue_free()
	await physics_frames(1)

	# Rebind "jump" to a key this pack has no icon file for.
	InputMap.action_erase_events(&"jump")
	var rebind := InputEventKey.new()
	rebind.physical_keycode = KEY_Q
	InputMap.action_add_event(&"jump", rebind)

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
	check(not has_icon2, "no icon file exists for Q, so no TextureRect renders for the rebound key")
	check(fallback_text == "[Q]", "a text fallback token names the CURRENT bound key instead (got '%s')" % fallback_text)

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
	var clipper := await _make_clipper(Vector2(500, 560))
	await physics_frames(1)
	var hint_normal: int = clipper.hint_label.get_theme_font_size("font_size")
	check(hint_normal >= 22, "the Clipper's 2-hit hint text is >= 22px at Normal text size (got %d)" % hint_normal)

	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(1)
	var hint_large: int = clipper.hint_label.get_theme_font_size("font_size")
	check(hint_large > hint_normal,
			"the hint text also grows at Large text size (normal=%d, large=%d)" % [hint_normal, hint_large])

	clipper.queue_free()
	await physics_frames(1)
	Settings.set_text_size(original_size)
