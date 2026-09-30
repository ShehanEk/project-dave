extends TestCase
## M7 / 07-acceptance-and-playtesting.md T21 ("Pause / subtitles / resize:
## Gameplay stops while paused; text and warnings remain readable; input
## resumes correctly").
##
## test_m5_flow.gd's own pause test already proves the HERO and the active-
## time clock freeze/resume; test_m5_regress_sc01_pause_not_skip.gd proves
## SC01's own hold timer freezes too. Neither ever checks an ENEMY, and
## nothing in the suite exercises a live window resize against the HUD's own
## anchored Controls. This case closes both gaps:
##   1. Pause freezes a Staffer's and a Patrol Rover's own state machine (the
##      engine's default PROCESS_MODE_PAUSABLE — CONVENTIONS.md: "every other
##      node in a level ... uses the engine's default pausable process
##      mode" — is what CONVENTIONS documents, but nothing before this case
##      proved it for an enemy specifically) and resumes it correctly.
##   2. A live viewport resize (DisplayServer/root Window size change) keeps
##      the HUD's left-anchored, right-anchored, and centered Controls
##      correctly repositioned relative to the NEW size, not left at their
##      old pixel positions.

const HUD_SCENE := "res://scenes/ui/hud.tscn"


func run() -> void:
	await _test_pause_freezes_staffer()
	await _test_pause_freezes_rover()
	await _test_resize_keeps_hud_anchored()


func _make_hero(pos: Vector2) -> Hero:
	var hero: Hero = load("res://scenes/actors/hero.tscn").instantiate()
	add_child(hero)
	hero.debug_invulnerable = true
	hero.global_position = pos
	return hero


func _test_pause_freezes_staffer() -> void:
	Session.new_run()
	var staffer: Brawler = load("res://scenes/actors/staffer.tscn").instantiate()
	add_child(staffer)
	staffer.global_position = Vector2(0, 96)
	# No EncounterGroup ancestor: attacks freely (CONVENTIONS.md), so the
	# dormant Staffer wakes on its first tick and a hero within engage_range
	# triggers WINDUP on the next.
	var hero := _make_hero(Vector2(40, 96))
	await physics_frames(3)
	check(staffer.state == Brawler.State.WINDUP,
			"setup: an isolated Staffer within engage_range enters WINDUP on its own (got state %d)" % staffer.state)

	get_tree().paused = true
	await physics_frames(1)
	check(get_tree().paused, "setup: the tree is actually paused")
	var frozen_state := staffer.state
	for i in 90:  # 1.5s at 60Hz — comfortably longer than the whole windup+lunge+recovery cycle
		await get_tree().physics_frame
	check(staffer.state == frozen_state,
			"pause: a Staffer's state machine does not advance while paused (was %d, still %d after 1.5s paused)" % [frozen_state, staffer.state])

	get_tree().paused = false
	await physics_frames(1)
	check(not get_tree().paused, "cleanup: unpaused")
	var advanced := false
	for i in 180:
		await get_tree().physics_frame
		if staffer.state != frozen_state:
			advanced = true
			break
	check(advanced, "pause: the Staffer's state machine resumes advancing once unpaused")

	staffer.queue_free()
	hero.queue_free()
	get_tree().paused = false
	await physics_frames(2)


func _test_pause_freezes_rover() -> void:
	Session.new_run()
	var rover: PatrolRover = load("res://scenes/actors/patrol_rover.tscn").instantiate()
	add_child(rover)
	rover.global_position = Vector2(0, 96)
	var hero := _make_hero(Vector2(120, 96))
	await physics_frames(3)
	check(rover.state == PatrolRover.State.WINDUP,
			"setup: an isolated Rover within acquire_range/line-of-sight enters WINDUP on its own (got state %d)" % rover.state)

	get_tree().paused = true
	await physics_frames(1)
	var frozen_state := rover.state
	var frozen_pos := rover.global_position
	for i in 90:
		await get_tree().physics_frame
	check(rover.state == frozen_state,
			"pause: a Rover's state machine does not advance while paused (was %d, still %d after 1.5s paused)" % [frozen_state, rover.state])
	check(rover.global_position.distance_to(frozen_pos) < 1.0,
			"pause: a Rover does not move (e.g. mid-charge) while paused")

	get_tree().paused = false
	await physics_frames(1)
	var advanced := false
	for i in 180:
		await get_tree().physics_frame
		if rover.state != frozen_state:
			advanced = true
			break
	check(advanced, "pause: the Rover's state machine resumes advancing once unpaused")

	rover.queue_free()
	hero.queue_free()
	get_tree().paused = false
	await physics_frames(2)


## Headless note: the real display server's own root Window does not
## actually resize when this test sets `.size` on it directly (no true
## backing display), so a Hud added straight under it would silently see the
## same 1280x720 stretch-base "visible rect" no matter what — a change to
## this test could then look green while testing nothing. A SubViewport's
## own `size`, by contrast, is a real render-target property that DOES take
## effect headless (it is what tools/capture.sh's own windowed runs and
## engine internals rely on): putting the Hud inside one and changing ITS
## size is a genuine, deterministic "DisplayServer/viewport size change" per
## 07's own T21 wording, and Controls anchor against it exactly as they would
## against a resized game window.
func _test_resize_keeps_hud_anchored() -> void:
	Session.new_run()
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.disable_3d = true
	add_child(vp)
	var hud: Hud = load(HUD_SCENE).instantiate()
	vp.add_child(hud)
	await physics_frames(2)

	var top_bar: Control = hud.get_node("TopBar")
	var objective: Label = hud._objective_label
	var toast: ToastLabel = hud._toast

	var checked_any := false
	for target in [Vector2i(1600, 900), Vector2i(960, 600), Vector2i(1280, 720)]:
		vp.size = target
		await get_tree().process_frame
		await get_tree().process_frame
		var w: float = float(vp.size.x)
		print("[test_m7_pause_and_resize] SubViewport size=%dx%d: TopBar.x=%.1f objective.x=%.1f (want %.1f) toast.x=%.1f (want %.1f)" % [
				target.x, target.y, top_bar.global_position.x, objective.global_position.x, w - 460.0, toast.global_position.x, w * 0.5 - 280.0])
		check(absf(top_bar.global_position.x - 16.0) < 1.0,
				"resize to %dx%d: the top-left HUD bar stays flush at x=16 regardless of viewport width (got %.1f)" % [target.x, target.y, top_bar.global_position.x])
		check(absf(objective.global_position.x - (w - 460.0)) < 2.0,
				"resize to %dx%d: the right-anchored objective label tracks the new viewport width (want x=%.1f, got %.1f)" % [target.x, target.y, w - 460.0, objective.global_position.x])
		check(absf(toast.global_position.x - (w * 0.5 - 280.0)) < 2.0,
				"resize to %dx%d: the centered toast label stays centered on the new viewport width (want x=%.1f, got %.1f)" % [target.x, target.y, w * 0.5 - 280.0, toast.global_position.x])
		checked_any = true
	check(checked_any, "at least one resize was actually exercised")

	vp.queue_free()
	await physics_frames(2)
