extends Node2D
## Demo/capture scene for the FULL L01 main route: instances level_01.tscn
## (LevelDirector spawns the Hero, GameCamera, KillPlane and all 6 areas end
## to end) then drives the debug RouteBot through the whole level, for
## tools/capture.sh visual evidence. No TestCase/area_harness dependency —
## a plain scene meant to run under `--write-movie` (see tools/capture.sh),
## not the headless test runner.

const LEVEL_01 := "res://scenes/levels/level_01.tscn"


func _ready() -> void:
	# debug-demos-touch-real-save: redirect BEFORE any Session/CheckpointService
	# call — this is a manual capture demo, never a test, so nothing else
	# redirects CheckpointService away from the real player's save directory
	# for it (tests/run_tests.gd only redirects for the automated suite).
	CheckpointService.set_save_dir("user://debug_demo_throwaway/m3_route_demo")
	Session.new_run()
	# M6 evidence only: M6_REDUCED_MOTION=1 tools/capture.sh ... captures the
	# same route with Settings.reduced_motion on (visual-only toggle already
	# read by hero_visual.gd/resident.gd/clipper.gd/scrapjack.gd/
	# area_backdrop.gd; never touched by RouteBot/physics/state machines).
	if OS.get_environment("M6_REDUCED_MOTION") == "1":
		Settings.set_reduced_motion(true)
	# M6 evidence only: M6_MUTED=1 tools/capture.sh ... mutes the Master bus
	# (Settings.set_master_volume, the same slider path Settings' own UI
	# uses) so the capture can be reviewed to confirm no warning/threat/
	# readability cue depends on audio alone.
	if OS.get_environment("M6_MUTED") == "1":
		Settings.set_master_volume(0.0)

	var level: LevelDirector = load(LEVEL_01).instantiate()
	add_child(level)

	# Let every _ready() (LevelDirector's own area/hero/camera setup, plus
	# every area's containers/Session reads/group membership) run before the
	# bot starts driving input, same as tests/area_harness.gd.
	await get_tree().physics_frame
	await get_tree().physics_frame

	# The RouteBot never dodges; keep combat from killing the hero mid-route
	# so the capture shows the whole route, not an early death/rebuild.
	level.hero.debug_invulnerable = true

	var bot := RouteBot.new()
	add_child(bot)
	bot.build_points(level, [])
	bot.start(level.hero)


## M6 perf evidence only (06-proof-and-milestones.md M6, 07's performance
## note): M6_PERF_LOG=1 run windowed WITHOUT --write-movie (Movie Maker
## fixes the frame step, so it can't measure real frame time) prints one
## real-time FPS/frame-ms sample per second to stdout for
## `tools/summarize_perf.py` to average. No effect unless the env var is set.
var _perf_accum: float = 0.0
var _perf_enabled: bool = false


func _process(delta: float) -> void:
	if not _perf_enabled:
		_perf_enabled = OS.get_environment("M6_PERF_LOG") == "1"
		if not _perf_enabled:
			return
	_perf_accum += delta
	if _perf_accum >= 1.0:
		_perf_accum = 0.0
		var fps := Engine.get_frames_per_second()
		print("PERF fps=%.2f frame_ms=%.3f" % [fps, (1000.0 / fps) if fps > 0.0 else -1.0])
