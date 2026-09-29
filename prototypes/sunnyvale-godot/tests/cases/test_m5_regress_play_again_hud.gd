extends TestCase
## REGRESSION (ADV-03): "Play again" used to leave the always-on HUD (never
## recreated — LevelDirector only rebuilds the Areas) showing whatever weapon
## tag/Quickcycle pip the just-ended run had, because Hud only refreshed on
## weapon_swapped/upgrade_purchased/snapshot_restored, none of which
## Session.new_run() emitted. Fixed with a new Session.run_reset signal Hud
## also listens to.
##
## REGRESSION (M7): this test drives `LevelDirector._on_play_again_confirmed()`
## directly (no `Main` in the tree), and that method unconditionally calls
## `Telemetry.run_start()` (scripts/levels/level_director.gd) — a REAL
## Telemetry call, same as a player's own "Play again" click, NOT guarded by
## anything this test used to set up. Discovered by running the exported
## macOS build and the full headless suite back to back (M7 export-report.md):
## the full-suite run left real `run_*.jsonl` files (a fresh "Play again"
## `run_start` + `area_enter`, immediately followed by the NEXT test's own
## live SC01/pause/checkpoint session, since the opened file is never closed
## until another `run_start()`) sitting in the actual player's default
## `user://sunnyvale/playtests/` directory — CONVENTIONS.md's Telemetry
## contract ("no test... ever writes a playtest log") and `telemetry.gd`'s own
## doc comment both promise this never happens. Fixed here (not in
## `LevelDirector`, which is correctly logging a REAL player's REAL "Play
## again") by redirecting `Telemetry` to a throwaway directory for this test,
## the same pattern `test_m5_flow.gd`/`test_m5_regress_title_newgame_honesty.gd`
## already use, and asserting the redirect actually took effect.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func run() -> void:
	var telemetry: Node = get_node_or_null("/root/Telemetry")
	var test_dir := "user://test_runs/play_again_hud_%d" % Time.get_ticks_usec()
	if telemetry:
		telemetry.set_playtest_dir(test_dir)

	Session.new_run()
	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)
	await physics_frames(3)

	# Mid-run: awaken, swap to P02, buy Quickcycle.
	Session.set_story("awakening_done", true)
	Session.collect("L01-A03-G001", 40)
	Session.mark_defeated("L01-E10-R01-01")
	Session.set_switch("L01-SW01", true)
	check(Session.swap_weapon("L01-A05-PAD01").ok, "setup: swap to P02")
	check(Session.purchase_upgrade("W01", 1, 40).ok, "setup: buy Quickcycle")
	await physics_frames(2)
	check_eq(level.hud._weapon_tag_label.text, "P02", "setup: HUD shows P02")
	check(level.hud._weapon_pip.visible, "setup: HUD shows Quickcycle pip")

	level._on_wicket_reached()
	# The completion screen opens after the Security PA line (C28).
	await physics_frames(int(LevelDirector.PA_BEAT * 60.0) + 2)
	check(level._completion_screen != null, "completion screen shown")
	level._completion_screen._on_confirm_pressed()  # Play again confirmed
	await physics_frames(4)

	if telemetry:
		var log_path: String = telemetry.current_log_path()
		check(log_path != "" and log_path.contains(test_dir.trim_prefix("user://")),
				"Play again's real Telemetry.run_start() landed in this test's own throwaway dir, not the real save (got: %s)" % log_path)

	check_eq(Session.equipped_weapon(), "L01-W01-P01", "Play again: Session holds P01")
	check_eq(Session.weapon_stage("W01"), 0, "Play again: stage reset")
	check(Session.state["defeated"].is_empty(), "Play again: defeated reset")
	check(not Session.get_switch("L01-SW01"), "Play again: switch reset")
	check(not Session.get_story("awakening_done"), "Play again: story reset")
	check(not get_node("/root/CheckpointService").has_valid_save(), "Play again: save cleared")
	# The HUD is never recreated and only refreshes its weapon box on
	# weapon_swapped / upgrade_purchased / snapshot_restored — none of which
	# Session.new_run() emits.
	check_eq(level.hud._weapon_tag_label.text, "P01", "Play again: HUD weapon tag shows P01")
	check(not level.hud._weapon_pip.visible, "Play again: HUD Quickcycle pip hidden on a fresh run")

	level.queue_free()
	await physics_frames(2)
	if telemetry:
		telemetry.end_run()
		telemetry.set_playtest_dir(Telemetry.DEFAULT_PLAYTEST_DIR)
		get_node("/root/CheckpointService").remove_dir_recursive(test_dir)
