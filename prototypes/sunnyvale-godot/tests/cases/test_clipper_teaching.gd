extends TestCase
## M7 Clipper-readability regression (post-fix teaching pass): proves the
## NEW first-time-player cues added alongside the E02/E04 backstop-placement
## fix behave correctly, and — just as importantly — that none of them
## changed the underlying rule (front always blocks, rear only damageable
## while STALL). Visual polish itself (spark shapes, ring pixels) is proven
## by capture, not by this headless suite; this file proves the DATA/STATE
## those visuals are driven by, and the one-shot/persistence contracts.

const A02 := "res://scenes/levels/areas/a02_gardens.tscn"
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


func run() -> void:
	await _test_hint_after_exactly_two_blocked_hits()
	await _test_hint_fires_once_per_group_not_per_hit()
	await _test_hint_is_screen_anchored_never_tracks_clipper()
	await _test_stall_ring_data_only_during_stall()
	await _test_crack_marks_wall_once_after_stall()
	await _test_damage_rules_unchanged_by_readability_pass()
	await _test_e02_prompt_shows_once_per_run_and_not_after_rebuild()


## --- 2b: hint after exactly 2 ineffective frontal hits ---------------------

func _test_hint_after_exactly_two_blocked_hits() -> void:
	var clipper := await _make_clipper(Vector2(500, 560))
	check(clipper.tuning.frontal_hint_threshold == 2,
			"clipper.tres now seeds frontal_hint_threshold=2 (got %d)" % clipper.tuning.frontal_hint_threshold)

	var hint_count := [0]
	clipper.hint_requested.connect(func(_t): hint_count[0] += 1)

	var outcome1: StringName = clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	check(outcome1 == &"blocked", "1st frontal hit is blocked")
	check(hint_count[0] == 0, "the hint has not fired after only 1 ineffective hit")

	var outcome2: StringName = clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	check(outcome2 == &"blocked", "2nd frontal hit is blocked")
	check(hint_count[0] == 1, "the hint fires exactly once after the 2nd ineffective hit (got %d)" % hint_count[0])
	check(clipper.hint_label.visible, "the hint is shown on screen")
	check(clipper.hint_label.text == Clipper.HINT_TEXT, "the hint text is the new armored/stone/motor line")

	clipper.queue_free()
	await physics_frames(1)


## --- once per group (here: once per Clipper, the only member of its own
## group in every shipped lane) — repeated ineffective hits never re-fire it,
## and neither does a fresh round of hits well past the threshold.
func _test_hint_fires_once_per_group_not_per_hit() -> void:
	var clipper := await _make_clipper(Vector2(500, 560))
	var hint_count := [0]
	clipper.hint_requested.connect(func(_t): hint_count[0] += 1)

	for i in 6:
		clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	check(hint_count[0] == 1, "6 ineffective frontal hits still only ever fire the hint once (got %d)" % hint_count[0])

	clipper.queue_free()
	await physics_frames(1)


## --- Kenney part B review fix (hint-label-covers-hero): the 2-hit hint is a
## screen-anchored `CanvasLayer` toast, not a world-space child positioned at
## a fixed LOCAL offset from the Clipper. The old world-space label rendered
## at a fixed offset above the Clipper regardless of the hero's position, so
## a hero standing/jumping near that offset (e.g. at Hero.tuning's own max
## jump apex, ~250px above ground, well within the panel's local x-extent —
## a very ordinary "walk up and mash fire into the shield" sequence) rendered
## directly behind it. Proven here at the structural level (a CanvasLayer
## child ignores the Clipper's own transform entirely) rather than by
## measuring an exact overlap against one hero pose: the hint's on-screen
## rect must never move just because the Clipper (or, by the same local-space
## logic the old bug relied on, anything positioned relative to it) moves.
func _test_hint_is_screen_anchored_never_tracks_clipper() -> void:
	var clipper := await _make_clipper(Vector2(500, 560))
	check(clipper.hint_label.get_parent() is CanvasLayer,
			"the hint label is a CanvasLayer child (screen-anchored), not a world-space child of the Clipper")

	var rect_before: Rect2 = clipper.hint_label.get_global_rect()
	clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT)
	check(clipper.hint_label.visible, "setup: the hint is now showing")
	check(clipper.hint_label.get_global_rect() == rect_before,
			"the hint's on-screen rect doesn't move when it's triggered")

	# Move the Clipper far away, as if the hero were standing anywhere near
	# the OLD world-space offset (e.g. up near jump-apex height beside it) —
	# the hint's screen rect must not follow it there.
	clipper.global_position += Vector2(3000, -3000)
	await physics_frames(1)
	check(clipper.hint_label.get_global_rect() == rect_before,
			"the hint's on-screen rect is unaffected by the Clipper's world position, so it can never be dragged over the hero by proximity")

	clipper.queue_free()
	await physics_frames(1)


## --- 2d: the stall-timer ring/bracket data is live only while STALL --------

func _test_stall_ring_data_only_during_stall() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var clipper := await _make_clipper(Vector2(500, 560))

	check(clipper.visual.stall_remaining < 0.0, "stall_remaining is negative (ring hidden) before any charge")

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.STALL, "the Clipper reaches STALL")
	check(clipper.visual.stall_remaining > 0.9, "stall_remaining starts near 1.0 just after stalling (got %.2f)" % clipper.visual.stall_remaining)

	await physics_frames(int(clipper.tuning.wall_stall_time * 60.0 * 0.5))
	check(clipper.state == Clipper.State.STALL, "still stalled halfway through the window")
	check(clipper.visual.stall_remaining > 0.05 and clipper.visual.stall_remaining < 0.9,
			"stall_remaining has visibly shrunk by the halfway point (got %.2f)" % clipper.visual.stall_remaining)

	frame = 0
	while clipper.state == Clipper.State.STALL and frame < 180:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.RECOVERY, "the Clipper leaves STALL for RECOVERY once the window elapses")
	check(clipper.visual.stall_remaining < 0.0, "stall_remaining goes back to negative (ring disappears) once STALL ends")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


## --- 2e: the wall the charge actually hit gets a one-time crack mark -------

func _test_crack_marks_wall_once_after_stall() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	check(not backstop.cracked, "the stone starts uncracked")
	var clipper := await _make_clipper(Vector2(500, 560))

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.STALL, "the Clipper stalls against the backstop")
	check(backstop.cracked, "the backstop it actually hit is marked cracked after the first stall")

	# An ordinary (non-BACKSTOP) solid never gains the flag from anything
	# else in this pass — Block.cracked only ever gets SET by clipper.gd, and
	# only ever DRAWN for Kind.BACKSTOP.
	var plain_wall := _make_floor(1400, 460, 100, 100)
	check(not plain_wall.cracked, "an unrelated Block never picks up a crack mark on its own")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	backstop.queue_free()
	plain_wall.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


## --- 3: none of the above changed the actual damage rule -------------------

func _test_damage_rules_unchanged_by_readability_pass() -> void:
	Session.new_run()
	var floor_b := _make_floor(0, 560, 2000)
	var hero := _make_hero(Vector2(450, 560))
	var backstop := _make_backstop(250, 460, 48, 100)
	var clipper := await _make_clipper(Vector2(500, 560))

	# Frontal shots never damage, whatever state the Clipper is in.
	check(clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.LEFT) == &"blocked",
			"front still always blocks (PATROL)")
	check(clipper.rear_hit_zone.blocks, "rear still blocks outside STALL (PATROL)")

	var frame := 0
	while clipper.state != Clipper.State.STALL and frame < 240:
		await physics_frames(1)
		frame += 1
	check(clipper.state == Clipper.State.STALL, "reaches STALL")
	check(clipper.front_hit_zone.take_hit(1, clipper.global_position, Vector2.RIGHT) == &"blocked",
			"front still always blocks, even while stalled")
	check(not clipper.rear_hit_zone.blocks, "rear only accepts damage while stalled")
	check(clipper.rear_hit_zone.take_hit(1, clipper.rear_hit_zone.global_position, Vector2.RIGHT) == &"hit",
			"rear shot lands while stalled")

	frame = 0
	while clipper.state == Clipper.State.STALL and frame < 180:
		await physics_frames(1)
		frame += 1
	check(clipper.state != Clipper.State.STALL, "stall ends")
	if is_instance_valid(clipper):
		check(clipper.rear_hit_zone.blocks, "rear blocks again once STALL ends (RECOVERY/PATROL)")

	hero.queue_free()
	if is_instance_valid(clipper):
		clipper.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


## --- 2c: the E02 first-Clipper prompt is one-shot per RUN, not per rebuild -

func _test_e02_prompt_shows_once_per_run_and_not_after_rebuild() -> void:
	Session.new_run()
	check(not Session.get_runtime_flag("e02_clipper_intro"), "the flag starts unset on a fresh run")

	var area: AreaRoot = load(A02).instantiate()
	add_child(area)
	await physics_frames(3)

	var group: EncounterGroup = area.get_node("Encounters/EncounterGroup_E02")
	var prompt := area.get_node("Entities/TutorialPrompt_E02Clipper")
	# M7 Kenney part B: the prompt's shown/hidden state is now the backing
	# Panel's own visibility (it wraps the Icons row + TextLabel as one C11
	# unit) rather than a lone top-level Label — see tutorial_prompt.gd.
	var panel: Control = prompt.get_node("Panel")
	check(not panel.visible, "the E02 prompt is not visible before the encounter activates")

	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	var zone: Area2D = group.get_node("ApproachZone")
	hero.global_position = zone.global_position

	var frame := 0
	while not group.is_active and frame < 30:
		await physics_frames(1)
		frame += 1
	check(group.is_active, "E02's ApproachZone activates the group")
	check(panel.visible, "the E02 tutorial prompt shows the moment the encounter activates")
	check(Session.get_runtime_flag("e02_clipper_intro"), "showing it sets the once-per-run flag")

	# Simulate a death/respawn mid-run rebuild: the AREA scene is freed and
	# re-instanced (exactly what LevelDirector does), but the RUN itself is
	# untouched (no new_run()/load_from_snapshot()) — Session.runtime_flags
	# must survive this, so the prompt does not reappear.
	hero.queue_free()
	area.queue_free()
	await physics_frames(2)

	var area2: AreaRoot = load(A02).instantiate()
	add_child(area2)
	await physics_frames(3)
	var group2: EncounterGroup = area2.get_node("Encounters/EncounterGroup_E02")
	var prompt2 := area2.get_node("Entities/TutorialPrompt_E02Clipper")
	var panel2: Control = prompt2.get_node("Panel")
	check(not panel2.visible, "a freshly-instanced prompt does not start visible (once_per_run_key already set)")

	var hero2: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero2)
	hero2.debug_invulnerable = true
	var zone2: Area2D = group2.get_node("ApproachZone")
	hero2.global_position = zone2.global_position

	frame = 0
	while not group2.is_active and frame < 30:
		await physics_frames(1)
		frame += 1
	check(group2.is_active, "E02's ApproachZone still activates the group on the rebuilt area")
	check(not panel2.visible,
			"the prompt does NOT reappear after a same-run rebuild (death/respawn), even though the encounter activates again")

	# A genuinely NEW run resets the flag, so a future run shows it again.
	Session.new_run()
	check(not Session.get_runtime_flag("e02_clipper_intro"), "a brand-new run clears the once-per-run flag")

	hero2.queue_free()
	area2.queue_free()
	await physics_frames(2)
