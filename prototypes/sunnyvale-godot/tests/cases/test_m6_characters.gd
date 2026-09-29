extends TestCase
## Revamp (C24) presentation contracts for the two Level 1 enemies' light
## cues, proven on the DATA the visuals are driven by (the same idiom
## test_clipper_teaching.gd uses for the stall ring), never on pixels:
##   - Staffer (staffer_visual.gd `link_state()`): IDLE (teal) while its
##     encounter is dormant; DRIVEN (amber) once it activates and through the
##     approach, lunge and stumble recovery; TELL (flashing red) for exactly
##     the wind-up; DARK once disabled. The body is fully procedural now, so
##     the old zombie cutout (a "Photo" sprite) must be gone.
##   - Clipper (clipper_visual.gd `lens_state()`): HUNTING (amber) on patrol
##     and through the stall; TELL (alarm red) from the wind-up until the
##     charge ends; DARK once disabled.
## Readability cues only (C16): nothing here feeds back into gameplay, which
## the M2 cases keep proving on their own.

const BlockScript := preload("res://scripts/world/block.gd")
const StafferVisual := preload("res://scripts/actors/visuals/staffer_visual.gd")
const ClipperVisual := preload("res://scripts/actors/visuals/clipper_visual.gd")


func _make_block(x: float, y: float, w: float, h: float, kind: int = 0) -> StaticBody2D:
	var b: StaticBody2D = BlockScript.new()
	b.position = Vector2(x, y)
	b.size = Vector2(w, h)
	b.kind = kind
	add_child(b)
	return b


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.global_position = pos
	hero.velocity = Vector2.ZERO
	hero.use_aim_override = true
	return hero


func run() -> void:
	await _test_staffer_link_states()
	await _test_clipper_lens_states()


func _test_staffer_link_states() -> void:
	Session.new_run()
	var floor_b := _make_block(0, 560, 2000, 200)
	var hero := _make_hero(Vector2(200, 560))
	var group: EncounterGroup = EncounterGroup.new()
	add_child(group)
	group.is_active = false
	var staffer: Staffer = load("res://scenes/actors/staffer.tscn").instantiate()
	group.add_child(staffer)
	staffer.global_position = Vector2(700, 560)
	await physics_frames(3)

	var visual = staffer.visual
	check(visual.get_node_or_null("Photo") == null, "the Staffer has no image cutout any more (fully procedural)")
	check(not visual.driven, "a Staffer in an inactive encounter is not driven")
	check_eq(visual.link_state(), StafferVisual.Link.IDLE, "dormant Staffer shows the idle (teal) Link")

	group.is_active = true
	await physics_frames(2)
	check(visual.driven, "the Staffer is driven once its encounter activates")
	check_eq(visual.link_state(), StafferVisual.Link.DRIVEN, "an approaching Staffer shows the driven (amber) Link")

	var windup_frames := 0
	var windup_wrong := 0
	var lunge_frames := 0
	var lunge_wrong := 0
	var recovery_frames := 0
	var recovery_wrong := 0
	var recovery_max := -1.0
	for i in 600:
		await physics_frames(1)
		if not is_instance_valid(staffer):
			break
		match staffer.state:
			Staffer.State.WINDUP:
				windup_frames += 1
				if visual.link_state() != StafferVisual.Link.TELL:
					windup_wrong += 1
			Staffer.State.LUNGE:
				lunge_frames += 1
				if visual.link_state() != StafferVisual.Link.DRIVEN:
					lunge_wrong += 1
			Staffer.State.RECOVERY:
				recovery_frames += 1
				if visual.link_state() != StafferVisual.Link.DRIVEN or visual.recovery < 0.0:
					recovery_wrong += 1
				recovery_max = maxf(recovery_max, visual.recovery)
		if recovery_frames > 0 and staffer.state == Staffer.State.APPROACH:
			break
	check(windup_frames > 0, "setup: the Staffer wound up (%d frames)" % windup_frames)
	check_eq(windup_wrong, 0, "every wind-up frame shows the red tell")
	check(lunge_frames > 0, "setup: the Staffer lunged (%d frames)" % lunge_frames)
	check_eq(lunge_wrong, 0, "every lunge frame shows the driven (amber) Link")
	check(recovery_frames > 0, "setup: the Staffer recovered (%d frames)" % recovery_frames)
	check_eq(recovery_wrong, 0, "every recovery frame is driven, with the stumble progress handed over")
	check(recovery_max > 0.8, "the stumble progress runs through the recovery (max %.2f)" % recovery_max)

	for i in staffer.tuning.health:
		staffer.hit_zone.take_hit(1, staffer.global_position, Vector2.LEFT)
		await physics_frames(1)
	check(is_instance_valid(staffer) and staffer.state == Staffer.State.DEFEATED, "setup: the Staffer is disabled")
	if is_instance_valid(staffer):
		check_eq(visual.link_state(), StafferVisual.Link.DARK, "a disabled Staffer's Link goes dark")
	await physics_frames(int(Staffer.DEFEAT_FADE_TIME * 60.0) + 5)
	check(not is_instance_valid(staffer), "the disabled Staffer still removes itself on the old timing")

	hero.queue_free()
	group.queue_free()
	floor_b.queue_free()
	await physics_frames(1)


func _test_clipper_lens_states() -> void:
	Session.new_run()
	var floor_b := _make_block(-400, 560, 3000, 200)
	var backstop := _make_block(100, 460, 48, 100, BlockScript.Kind.BACKSTOP)
	# Out of acquire range (640 px) first, so the Clipper just patrols.
	var hero := _make_hero(Vector2(1800, 560))
	var clipper: Clipper = load("res://scenes/actors/clipper.tscn").instantiate()
	add_child(clipper)
	# Close enough to the backstop that the first charge stalls against it
	# (charge_max_distance is 4H = 384 px).
	clipper.global_position = Vector2(440, 560)
	await physics_frames(3)
	var visual = clipper.visual
	check(clipper.state == Clipper.State.PATROL, "setup: the Clipper patrols with no hero in range")
	check_eq(visual.lens_state(), ClipperVisual.Lens.HUNTING, "a patrolling Clipper shows amber lenses")

	hero.global_position = Vector2(260, 560)
	var prev_state: int = clipper.state
	var windup_frames := 0
	var windup_wrong := 0
	var charge_frames := 0
	var charge_wrong := 0
	var stall_frames := 0
	var stall_wrong := 0
	for i in 600:
		await physics_frames(1)
		match clipper.state:
			Clipper.State.WINDUP:
				windup_frames += 1
				# The entry tick carries no retract/spread yet (t = 0), so the
				# red may start one tick into each wind-up; never later.
				if prev_state == Clipper.State.WINDUP and visual.lens_state() != ClipperVisual.Lens.TELL:
					windup_wrong += 1
			Clipper.State.CHARGE:
				charge_frames += 1
				if visual.lens_state() != ClipperVisual.Lens.TELL:
					charge_wrong += 1
			Clipper.State.STALL:
				stall_frames += 1
				if visual.lens_state() != ClipperVisual.Lens.HUNTING:
					stall_wrong += 1
		prev_state = clipper.state
		if stall_frames >= 10:
			break
	check(windup_frames > 1, "setup: the Clipper wound up (%d frames)" % windup_frames)
	check_eq(windup_wrong, 0, "the lenses are red through the wind-up")
	check(charge_frames > 0, "setup: the Clipper charged (%d frames)" % charge_frames)
	check_eq(charge_wrong, 0, "the lenses stay red until the charge ends")
	check(stall_frames > 0, "setup: the Clipper stalled against the backstop")
	check_eq(stall_wrong, 0, "the lenses return to amber for the stall opening")

	for i in clipper.tuning.motor_health:
		clipper.rear_hit_zone.take_hit(1, clipper.global_position, Vector2.RIGHT)
		await physics_frames(1)
	check(is_instance_valid(clipper) and clipper.state == Clipper.State.DEFEATED, "setup: the Clipper is disabled")
	if is_instance_valid(clipper):
		check_eq(visual.lens_state(), ClipperVisual.Lens.DARK, "a disabled Clipper's lenses go dark")

	await physics_frames(int(Clipper.DEFEAT_FADE_TIME * 60.0) + 5)
	hero.queue_free()
	backstop.queue_free()
	floor_b.queue_free()
	await physics_frames(1)
