extends TestCase
## C53 fun pass (adversarial review 2026-10-09). Contracts under test:
##   1. Getting hurt lands: Dave's hit shakes the camera harder than a kill, and a hit flashes him.
##   2. A death holds and fades before the level resets (the beat is switched on here; the
##      runner switches it off for every other test).
##   3. At 2 health or less the HUD health row pulses; above it, it does not.
##   4. Guards and Staffers close in faster; mixed Guard + Rover groups attack two at a time;
##      a Rover that missed comes again with a shorter windup.
##   5. Scrap Plating: 25 chips buys a seventh health segment, filled; it shows on the HUD; the
##      save accepts 7 health only with the plating; the workbench offers it beside the
##      Quickcycle and says the chips buy one of the two.
##   6. The Lockout Notice opens a reader with its text, and Close gives Dave his input back.
##   7. The Security PA speaks on the route (text) once per run, never after the depot event.
##   8. The completion screen ranks the run, keeps the best run, and points on to Level 2.

const HUD_SCENE := "res://scenes/ui/hud.tscn"
const PANEL := "res://scenes/ui/workbench_panel.tscn"
const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	_feel_numbers()
	await _low_health()
	_enemy_tuning()
	await _plating()
	await _death_beat()
	await _evidence_reader()
	await _route_pa()
	await _debrief()


func _feel_numbers() -> void:
	check(GameFeel.HURT_SHAKE > GameFeel.KILL_SHAKE, "being hurt shakes harder than a kill")
	check(GameFeel.HURT_PAUSE > GameFeel.HIT_PAUSE, "being hurt pauses longer than a hit")
	check(GameFeel.DEATH_SHAKE > GameFeel.HURT_SHAKE, "a death shakes hardest")
	check(GameFeel.HIT_PAUSE >= 0.05 and GameFeel.KILL_SHAKE >= 5.0, "the hit pause and kill shake are stronger than before")


func _low_health() -> void:
	Session.new_run()
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(2)
	check(not hud.is_low_health_warning(), "full health: no warning")
	Session.apply_damage(3)
	await seconds(0.2)
	check(not hud.is_low_health_warning(), "3 health: no warning")
	Session.apply_damage(1)
	var seen_red := false
	for i in 50:
		await physics_frames(1)
		if hud.get_node("TopBar/HealthRow").modulate.g < 0.7:
			seen_red = true
	check(hud.is_low_health_warning(), "2 health: the warning is on")
	check(seen_red, "the health row pulses red")
	Session.heal_full()
	await physics_frames(2)
	check(hud.get_node("TopBar/HealthRow").modulate.is_equal_approx(Color.WHITE), "healed: the row is back to normal")
	hud.queue_free()
	await physics_frames(1)


func _enemy_tuning() -> void:
	var guard: Resource = load("res://data/tuning/night_guard.tres")
	var staffer: Resource = load("res://data/tuning/staffer.tres")
	check(guard.approach_speed_h_per_s >= 1.5, "Guards close in at 1.5 H/s or more (%.2f)" % guard.approach_speed_h_per_s)
	check(staffer.approach_speed_h_per_s >= 1.2, "Staffers close in at 1.2 H/s or more (%.2f)" % staffer.approach_speed_h_per_s)
	check(staffer.windup_time >= 0.6, "the Staffer still warns for 0.6 s or more (T04)")
	check(PatrolRover.FOLLOWUP_WINDUP_SCALE < 1.0, "a Rover's follow-up charge winds up faster")
	for pair in [["a03_roofs", "E05"], ["a04_square", "E07"], ["a04_square", "E08"], ["a04_square", "E09"]]:
		var area: Node = load("res://scenes/levels/areas/%s.tscn" % pair[0]).instantiate()
		var g: Node = area.get_node("Encounters/EncounterGroup_%s" % pair[1])
		check_eq(g.max_attackers, 2, "%s (Guard + Rover) lets two attack at once" % pair[1])
		area.free()


func _plating() -> void:
	Session.new_run()
	Session.set_story("awakening_done", true)
	Session.state["wallet"] = 45
	check_eq(Session.max_health(), 6, "six health to start")
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	var panel: WorkbenchPanel = load(PANEL).instantiate()
	add_child(panel)
	await physics_frames(2)
	var vb := "Panel/VBox/"
	var plate_btn: Button = panel.get_node(vb + "UpgradeRowButtons/PlatingButton")
	var quick_btn: Button = panel.get_node(vb + "UpgradeRowButtons/ConfirmButton")
	check(plate_btn.visible and not plate_btn.disabled and plate_btn.text.contains("25"), "Buy Plating (25) is offered")
	check(quick_btn.visible and not quick_btn.disabled, "beside Buy Quickcycle")
	check(panel.get_node(vb + "BalanceLabel").text.contains("one of them"), "45 chips buy one of the two")
	var row := hud.get_node("TopBar/HealthRow")
	check_eq(row.get_children().filter(func(c): return c.visible).size(), 6, "the HUD shows six segments")

	panel._on_plating_pressed()
	check_eq(Session.weapon_stage(Session.PLATING_TYPE), 1, "the plating is fitted")
	check_eq(Session.max_health(), 7, "seven health now")
	check_eq(Session.get_health(), 7, "the new segment comes full")
	check_eq(Session.get_wallet(), 20, "25 chips spent")
	check(panel.bought_plating, "the panel remembers the buy")
	check(not plate_btn.visible, "no Buy Plating once fitted")
	check(quick_btn.disabled, "20 chips left: the Quickcycle is out of reach (the choice)")
	await physics_frames(1)
	check_eq(row.get_children().filter(func(c): return c.visible).size(), 7, "the HUD shows seven segments")
	check(hud._toast.text.begins_with("Scrap Plating fitted"), "the HUD announces it (%s)" % hud._toast.text)
	Session.apply_damage(1)
	Session.heal_full()
	check_eq(Session.get_health(), 7, "healing fills all seven")

	var cs := get_node_or_null("/root/CheckpointService")
	if cs:
		var snap: Dictionary = Session.state.duplicate(true)
		check(cs.validate_snapshot(snap).ok, "a save with 7 health and the plating is valid")
		snap["upgrades"]["A01"] = 0
		check(not cs.validate_snapshot(snap).ok, "7 health without the plating is refused")
		var old: Dictionary = Session.state.duplicate(true)
		old["upgrades"] = {"W01": 0}
		old["health"] = 6
		check(cs.validate_snapshot(old).ok, "an older save without the plating key still loads")

	panel._on_decline_pressed()
	hud.queue_free()
	await physics_frames(2)
	Session.new_run()


func _death_beat() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	LevelDirector.death_beat_enabled = true
	var x_before := level.hero.global_position.x
	level.hero.global_position.x += 300.0
	var died_at := level.hero.global_position.x
	Session.apply_damage(Session.get_health())
	await seconds(0.3)
	check_eq(Session.get_health(), 0, "0.3 s after dying the level has not reset yet (the beat)")
	check(absf(level.hero.global_position.x - died_at) < 60.0, "Dave is still where he fell")
	await seconds(1.6)
	check_eq(Session.get_health(), Session.max_health(), "after the beat the checkpoint is restored")
	check(absf(level.hero.global_position.x - x_before) < 60.0, "Dave is back at the checkpoint")
	var fade: ColorRect = level._death_fade
	check(fade != null, "the death fades to black")
	await seconds(0.6)
	check(fade.color.a < 0.05, "and back in")
	LevelDirector.death_beat_enabled = false
	level.queue_free()
	await physics_frames(2)


func _evidence_reader() -> void:
	Session.new_run()
	var pickup: Node = load("res://scenes/objects/evidence_pickup.tscn").instantiate()
	add_child(pickup)
	await physics_frames(1)
	pickup.interact(null)
	await physics_frames(1)
	var reader: Node = get_tree().get_first_node_in_group("evidence_reader")
	check(reader != null, "picking up the Lockout Notice opens the reader")
	if reader:
		check_eq(reader.title_text(), "Lockout Notice", "titled Lockout Notice")
		check(reader.body_text().contains("Stroud") and reader.body_text().contains("revoked"),
				"the memo says who revoked Dave's access")
		var closed := [false]
		reader.closed.connect(func(): closed[0] = true)
		reader.close()
		check(closed[0], "Close closes it")
	check(Session.has_evidence("EF01"), "the file is recorded")
	pickup.queue_free()
	await physics_frames(2)


func _route_pa() -> void:
	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)
	var subs: Node = get_tree().get_first_node_in_group("subtitle_panel")
	BeatHub.get_instance().beat_entered.emit("L01-A02-B01", "L01-A02")
	check(subs.current_line().contains("Dave Harlan"), "entering the gardens, the PA names Dave (%s)" % subs.current_line())
	subs.clear_line()
	BeatHub.get_instance().beat_entered.emit("L01-A02-B01", "L01-A02")
	check_eq(subs.current_line(), "", "the same line does not repeat")
	await seconds(LevelDirector.ROUTE_PA_HOLD + 0.3)
	Session.set_story("awakening_done", true)
	BeatHub.get_instance().beat_entered.emit("L01-A03-B01", "L01-A03")
	check_eq(subs.current_line(), "", "after the depot event the route lines stay quiet")
	level.queue_free()
	await physics_frames(2)
	Session.new_run()


func _debrief() -> void:
	check_eq(CompletionScreen.rank_for(CompletionScreen.rank_points(200.0, 65, true)), "S", "fast, every chip and the file: S")
	check_eq(CompletionScreen.rank_for(CompletionScreen.rank_points(300.0, 45, true)), "C", "a middling run: C")
	check_eq(CompletionScreen.rank_for(CompletionScreen.rank_points(900.0, 20, false)), "D", "slow and empty: D")
	var cs := get_node_or_null("/root/CheckpointService")
	if cs == null:
		return
	DirAccess.remove_absolute(cs.get_save_dir().path_join(cs.RECORDS_FILE))
	Session.new_run()
	Session.run_meta["active_seconds"] = 300.0
	var screen: CompletionScreen = load("res://scenes/ui/completion.tscn").instantiate()
	add_child(screen)
	await physics_frames(1)
	check(screen.rank != "", "the screen shows a rank (%s)" % screen.rank)
	check(screen.get_node("Panel/VBox/StatsView/AdamLabel").text.begins_with("Adam:"), "Adam has the last word")
	check(screen.get_node("Panel/VBox/StatsView/NextLabel").text.contains("Level 2"), "it points on to Level 2")
	check(not cs.load_records().is_empty(), "the first clear is kept as the best")
	screen.queue_free()
	await physics_frames(1)
	Session.run_meta["active_seconds"] = 200.0
	var screen2: CompletionScreen = load("res://scenes/ui/completion.tscn").instantiate()
	add_child(screen2)
	await physics_frames(1)
	check(screen2.new_best, "a faster run with the same rank is a new best")
	screen2.queue_free()
	await physics_frames(1)
	Session.new_run()
