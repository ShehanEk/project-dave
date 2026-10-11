extends TestCase
## M6 (presentation pass) — UI-owned contracts (see CONVENTIONS.md "Autoload
## `Settings`" and "UI scenes"):
##   1. Settings persistence round-trips subtitles/text_size/reduced_motion/
##      volumes through CheckpointService's separate settings.json (never the
##      checkpoint snapshot), same throwaway-dir pattern every other test uses.
##   2. Settings "text size" actually scales the HUD's own labels (not just
##      the one label M5 part 2 already covered), live, on Settings.changed.
##   3. Hud connects to Settings.changed exactly once per instance and
##      disconnects in _exit_tree — a rebuilt Hud (LevelDirector never
##      recreates the real one, but nothing stops an isolated scene from
##      re-instancing it, e.g. a future death/respawn path) must not leak a
##      growing pile of connections that would make one Settings.changed
##      emission re-apply the text size multiple times over.
##
## Never touches a real save: redirects CheckpointService to one fresh
## throwaway user:// dir for the whole run, same as every other test case.

const HUD_SCENE := "res://scenes/ui/hud.tscn"


func run() -> void:
	var base_dir: String = CheckpointService.get_save_dir()
	var test_dir := "user://test_runs/m6_ui_%d" % Time.get_ticks_usec()
	CheckpointService.set_save_dir(test_dir)

	_test_settings_persist_round_trip()
	await _test_hud_text_size_applies_live()
	await _test_hud_settings_signal_connect_once_per_instance()

	# Restore Settings to its own defaults in memory (the throwaway save dir
	# already isolated every write above from any real player settings file)
	# so a later test case in the same run never inherits a stray value.
	Settings.set_subtitles_enabled(true)
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	Settings.set_reduced_motion(false)
	Settings.set_master_volume(0.8)
	Settings.set_music_volume(0.8)
	Settings.set_sfx_volume(0.8)
	CheckpointService.remove_dir_recursive(test_dir)
	# Restore the runner's own throwaway dir (base_dir), never
	# DEFAULT_SAVE_DIR — this run() is one case inside a shared suite run;
	# forcing the real save dir here would leak every later-sorted test
	# case's Session/CheckpointService calls into the player's real save
	# (AUD-01).
	CheckpointService.set_save_dir(base_dir)


# --- 1. settings persistence round-trip -----------------------------------------

func _test_settings_persist_round_trip() -> void:
	Settings.set_subtitles_enabled(false)
	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	Settings.set_reduced_motion(true)
	Settings.set_master_volume(0.4)
	Settings.set_music_volume(0.3)
	Settings.set_sfx_volume(0.6)

	# A fresh load (as if the game had just booted) must recover every value
	# from the settings.json this redirected save dir now holds.
	Settings.load_from_disk()
	check_eq(Settings.get_subtitles_enabled(), false, "subtitles_enabled persists")
	check_eq(Settings.get_text_size(), Settings.TEXT_SIZE_LARGE, "text_size persists")
	check_eq(Settings.get_reduced_motion(), true, "reduced_motion persists")
	check(is_equal_approx(Settings.get_master_volume(), 0.4), "master_volume persists")
	check(is_equal_approx(Settings.get_music_volume(), 0.3), "music_volume persists")
	check(is_equal_approx(Settings.get_sfx_volume(), 0.6), "sfx_volume persists")

	# A load with a partially-missing/corrupt file (simulated by clearing the
	# in-memory settings then loading raw saved data with one key dropped)
	# falls back to DEFAULTS for exactly that key, per settings.gd's own
	# contract, rather than failing the whole load.
	var raw: Dictionary = CheckpointService.load_settings()
	raw.erase("text_size")
	CheckpointService.save_settings(raw)
	Settings.load_from_disk()
	check_eq(Settings.get_text_size(), Settings.TEXT_SIZE_NORMAL,
			"a settings.json missing one key falls back to that key's default, not a hard failure")
	check_eq(Settings.get_subtitles_enabled(), false,
			"...while every OTHER key already on disk still loads correctly")


# --- 2. text size applies live to every Hud label, not just one ------------------

func _test_hud_text_size_applies_live() -> void:
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	Session.new_run()
	var hud: Hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	await physics_frames(2)

	var base_objective: int = hud._objective_label.get_theme_font_size("font_size")
	var base_wallet: int = hud._wallet_label.get_theme_font_size("font_size")
	var base_tag: int = hud._weapon_tag_label.get_theme_font_size("font_size")

	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(1)

	check_eq(hud._objective_label.get_theme_font_size("font_size"),
			Settings.scaled_font_size(base_objective),
			"Hud objective label scales up live on Settings.changed (large text)")
	check_eq(hud._wallet_label.get_theme_font_size("font_size"),
			Settings.scaled_font_size(base_wallet),
			"Hud wallet label scales up live on Settings.changed (large text)")
	check_eq(hud._weapon_tag_label.get_theme_font_size("font_size"),
			Settings.scaled_font_size(base_tag),
			"Hud weapon tag label scales up live on Settings.changed (large text)")

	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	await physics_frames(1)
	check_eq(hud._objective_label.get_theme_font_size("font_size"), base_objective,
			"Hud objective label scales back down live when text size returns to normal")

	hud.queue_free()
	await physics_frames(2)


# --- 3. Hud connects to Settings.changed exactly once per instance ---------------

func _test_hud_settings_signal_connect_once_per_instance() -> void:
	Session.new_run()
	var base_connections: int = Settings.changed.get_connections().size()

	var huds: Array[Hud] = []
	for i in 3:
		var hud: Hud = load(HUD_SCENE).instantiate()
		add_child(hud)
		await physics_frames(2)
		check(Settings.changed.is_connected(hud._apply_text_size),
				"Hud instance %d connects to Settings.changed in _ready" % i)
		huds.append(hud)

	check_eq(Settings.changed.get_connections().size(), base_connections + 3,
			"3 live Hud instances hold exactly 3 new Settings.changed connections (one each, no double-connect)")

	for hud in huds:
		hud.queue_free()
	await physics_frames(2)

	check_eq(Settings.changed.get_connections().size(), base_connections,
			"every Hud disconnects from Settings.changed in _exit_tree — no leak across rebuilds")

	# With the leak contract proven above, also prove the practical
	# consequence directly: rebuilding a fresh Hud after N earlier ones have
	# come and gone still reacts to exactly one text-size application per
	# Settings.changed emission (not N stacked calls re-applying the same
	# value redundantly, which the connection-count check already forbids,
	# but this exercises the real signal path end to end once more).
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	var hud_final: Hud = load(HUD_SCENE).instantiate()
	add_child(hud_final)
	await physics_frames(2)
	var base_size: int = hud_final._objective_label.get_theme_font_size("font_size")
	Settings.set_text_size(Settings.TEXT_SIZE_LARGE)
	await physics_frames(1)
	check_eq(hud_final._objective_label.get_theme_font_size("font_size"),
			Settings.scaled_font_size(base_size),
			"the surviving Hud after 3 earlier rebuilds still reacts exactly once (correct scaled size, not compounded)")
	Settings.set_text_size(Settings.TEXT_SIZE_NORMAL)
	hud_final.queue_free()
	await physics_frames(2)
