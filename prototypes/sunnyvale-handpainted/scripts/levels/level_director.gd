class_name LevelDirector
extends Node2D
## Boots L01: instances the six area scenes in x-order under an "Areas"
## container, each offset by the cumulative `width` of the areas placed
## before it (so an area author editing their own `width` never breaks the
## seam with a neighbour — per CONVENTIONS.md's AreaRoot seam contract),
## spawns one Hero and one GameCamera, and adds a level-wide KillPlane
## safety net far below every area's real geometry.
##
## Death: `hero.died` -> `Session.restore_committed()` -> place the hero at
## the respawn marker for the restored `checkpoint_id` -> (one real physics
## frame later, see `_finish_death_rebuild`) free + re-instance every area
## (so every pickup/enemy/switch/story object re-reads Session fresh, per
## CONVENTIONS.md "world objects decide their own presence in _ready() from
## Session") -> re-enable input. The Hero and GameCamera are never
## recreated, so `died` is connected exactly once, in `_ready()`.
##
## Objectives/SC01/completion (04-godot-architecture.md's table assigns
## "Area order, encounter activation, objectives, SC01, lockdown state,
## completion" to LevelDirector): CoreNode (L01-SC01) owns the SC01 scene
## itself and the awakening story flags; this script only bumps the
## objective the moment the hero first enters the depot (A05) pre-awakening,
## and owns the real exit-wicket ending — CP05, `Session.level_completed`,
## and `scenes/ui/completion.tscn` — replacing M3's temporary end overlay.
## `level_ended`/`level_ended_flag` stay public so existing tests can assert
## full-route completion without scraping the completion screen's UI.

signal level_ended
## M5 part 2: PauseMenu's "Quit to title" (confirmed) bubbles up to whoever
## instanced this LevelDirector (Main), which frees it and shows the title
## screen again. LevelDirector never manages the title screen itself.
signal quit_to_title_requested

const AREA_SCENE_PATHS: Array[String] = [
	"res://scenes/levels/areas/a01_gate.tscn",
	"res://scenes/levels/areas/a02_gardens.tscn",
	"res://scenes/levels/areas/a03_roofs.tscn",
	"res://scenes/levels/areas/a04_square.tscn",
	"res://scenes/levels/areas/a05_depot.tscn",
	"res://scenes/levels/areas/a06_exit.tscn",
]

const HERO_SCENE := "res://scenes/actors/hero.tscn"
const CAMERA_SCENE := "res://scenes/actors/game_camera.tscn"
const KILL_PLANE_SCENE := "res://scenes/objects/kill_plane.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const SUBTITLE_SCENE := "res://scenes/ui/subtitle_panel.tscn"
const COMPLETION_SCENE := "res://scenes/ui/completion.tscn"
const PAUSE_MENU_SCENE := "res://scenes/ui/pause.tscn"
const DEPOT_AREA_ID := "L01-A05"
## Revamp (C24): the night-look screen overlay (vignette, grain, lockdown
## wash). Optional: instanced only if the scene exists, owned by the world-
## visuals pass (scenes/world/night_overlay.tscn).
const NIGHT_OVERLAY_SCENE := "res://scenes/world/night_overlay.tscn"
## C35: the character-only moonlight that rims Dave and the lit enemies.
## Optional in the same way as the overlay (scripts/world/night_lighting.gd).
const NIGHT_LIGHTING_SCENE := "res://scenes/world/night_lighting.tscn"
## C28, the turn to lethal force: as Dave badges out, security command's
## flat PA voice (not Adam's) gives its one line; the completion screen
## opens after it. The run is already committed and input is off.
const PA_SPEAKER := "Security PA"
const PA_LINE := "All teams: lethal force is authorized. Harlan is armed."
## How long that caption is held before the completion screen opens. N05: it
## speaks the `pa_lethal` clip (3.55s), so this grew from 3.2s to cover the clip
## plus a beat; a longer clip would extend the hold further (see
## `_on_wicket_reached()`).
const PA_BEAT := 4.0
## C53: between the intro comic and SC01 nobody spoke. The campus Security PA now marks the
## route, text only, once per run, before the depot event (Adam's first words stay for SC01,
## story-scenes.md). Keyed by pacing beat; each line stays up ROUTE_PA_HOLD seconds.
const ROUTE_PA_LINES := {
	"L01-A02-B01": "Night shift, be advised: a flagged former employee is on campus. Dave Harlan. Detain on sight.",
	"L01-A03-B01": "Rooftop cameras have Harlan heading for the server depot. All units, cut him off.",
	"L01-A04-B01": "Reminder to staff: your Link keeps you calm and safe. Please stay at your workstations.",
}
const ROUTE_PA_HOLD := 5.5
## N05, the lockdown announcement: once Adam's scene is over and the player has
## control back, the same Security PA reads this caption with the
## `pa_remain_calm` clip, once per lockdown (never on Continue: it keys off the
## live `awakening_done` signal, which a load does not re-emit). It starts
## PA_CALM_DELAY seconds after control returns (never delaying that hand-back),
## and the caption stays up PA_CALM_HOLD seconds, or the clip plus
## PA_VOICE_BEAT when that is longer. It is ticked from `_physics_process`, so
## it ends with the level and freezes with the pause menu.
const PA_CALM_LINE := "Attention, staff. For your comfort, all exits are now closed. Please remain calm."
const PA_CALM_DELAY := 0.8
const PA_CALM_HOLD := 6.0
## The beat a PA caption is held past the end of its voice clip.
const PA_VOICE_BEAT := 0.35
enum LockdownPa { IDLE, WAIT_CONTROL, DELAY, SPEAKING }

## Session `checkpoint_id` -> [index into `areas`, marker name under that
## area's Markers node]. CP00 is the initial spawn; CP01-CP03 are the
## recovery stations; CP04 is the core node's own safe spot; UPG01 is the
## workbench purchase/service checkpoint (its own "Respawn" marker mirrored here
## per CONVENTIONS.md IDs "checkpoints `CP00`...`CP05`" / "workbench `L01-UPG01`");
## CP05 is the exit wicket's safe landing (M5 wires the actual commit).
## CP06 (mid-plaza, A04) and CP07 (mid-exit, A06) are the fun pass's extra
## recovery stations (C41), numbered after the original six.
const CHECKPOINT_MARKERS := {
	"CP00": [0, "Spawn_CP00"],
	"CP01": [1, "Respawn_CP01"],
	"CP02": [2, "Respawn_CP02"],
	"CP06": [3, "Respawn_CP06"],
	"CP03": [3, "Respawn_CP03"],
	"CP04": [4, "Respawn_CP04"],
	"UPG01": [4, "Respawn_UPG01"],
	"CP07": [5, "Respawn_CP07"],
	"CP05": [5, "Respawn_CP05"],
}

## N05: which ambience bed plays where the hero is (the decision table).
const AmbienceMap := preload("res://scripts/audio/ambience_map.gd")

## C53 death beat: a death used to reset the level in the same frame, before the player
## could see what hit them. Now the killing blow shakes and pauses, Dave stays down for
## DEATH_HOLD seconds, the screen fades to black over DEATH_FADE, the level is restored
## behind the black and fades back in. Off in the headless test runner (frame-counted).
static var death_beat_enabled: bool = true
const DEATH_HOLD := 0.75
const DEATH_FADE := 0.3
const DEATH_FADE_IN := 0.35
const KILL_PLANE_Y := 2000.0
const KILL_PLANE_MARGIN := 2000.0
## px/s the camera's own top/bottom limits are allowed to move when the
## hero crosses into an area with different vertical bounds, so a bound
## change never snaps the view (and never hides a landing mid-air).
const CAMERA_LIMIT_LERP_SPEED := 600.0

var areas: Array[AreaRoot] = []
var level_width: float = 0.0
var hero: Hero
var camera: GameCamera
var hud: Hud
var pause_menu: PauseMenu
var level_ended_flag: bool = false

var _areas_root: Node2D
var _camera_top: float = 0.0
var _camera_bottom: float = 0.0
var _completion_screen: CanvasLayer = null
## Tracks which AreaRoot the hero is currently in for Telemetry's
## area_enter/area_exit events (M5 part 2), separate from the camera's own
## smoothed _area_for_x tracking so a camera-limit lerp never affects when an
## event fires.
var _telemetry_area: AreaRoot = null
var _death_fade: ColorRect = null
var _route_pa_said := {}
## N05: whether the hero is in the depot's core room (sticky near its edge).
var _in_core_room: bool = false
## N05: where the lockdown announcement is (a LockdownPa step) and the seconds
## left in its current DELAY / SPEAKING step; and whether the wicket's PA line
## is speaking (so leaving the level mid-line stops the voice).
var _lockdown_pa: int = LockdownPa.IDLE
var _lockdown_pa_t: float = 0.0
var _pa_lethal_active: bool = false


func _ready() -> void:
	if Session:
		Session.story_state_changed.connect(_on_story_state_changed)
		Session.run_reset.connect(_on_run_reset_route_pa)
	BeatHub.get_instance().beat_entered.connect(_on_beat_entered_route_pa)
	_build_areas()

	hero = load(HERO_SCENE).instantiate()
	add_child(hero)
	hero.died.connect(_on_hero_died)

	camera = load(CAMERA_SCENE).instantiate()
	camera.target = hero
	add_child(camera)

	hud = load(HUD_SCENE).instantiate()
	add_child(hud)
	hud.setup(hero)
	_update_weapon_tag()

	pause_menu = load(PAUSE_MENU_SCENE).instantiate()
	add_child(pause_menu)
	pause_menu.setup(hero)
	pause_menu.restart_from_checkpoint_confirmed.connect(_on_restart_from_checkpoint_confirmed)
	pause_menu.quit_to_title_confirmed.connect(_on_quit_to_title_confirmed)

	if get_tree().get_first_node_in_group("subtitle_panel") == null:
		add_child(load(SUBTITLE_SCENE).instantiate())

	if ResourceLoader.exists(NIGHT_OVERLAY_SCENE):
		add_child(load(NIGHT_OVERLAY_SCENE).instantiate())
	if ResourceLoader.exists(NIGHT_LIGHTING_SCENE):
		add_child(load(NIGHT_LIGHTING_SCENE).instantiate())

	_place_hero_at_checkpoint(String(Session.state.get("checkpoint_id", "CP00")))
	var start_rect := _camera_target_rect_for_area(_area_for_x(hero.global_position.x))
	_camera_top = start_rect.position.y
	_camera_bottom = start_rect.position.y + start_rect.size.y
	camera.world_limits = start_rect
	camera.reset_position()

	_add_kill_plane()

	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.register_encounter_groups(areas)
	_telemetry_area = _area_for_x(hero.global_position.x)
	if telemetry and _telemetry_area:
		telemetry.area_enter(_telemetry_area.area_id)
	update_ambience()
	update_music()

	# Continue loading a save whose run already reached the wicket (a
	# completed CP05 snapshot): "never a broken state" — show the real
	# completion screen right away instead of standing the hero next to a
	# trigger that will never fire again, without recommitting CP05 or
	# re-running any of `_on_wicket_reached()`'s other side effects.
	if Session and Session.get_story("level_complete"):
		level_ended_flag = true
		if hero:
			hero.input_enabled = false
		_show_completion_screen()


func _process(delta: float) -> void:
	_maybe_update_depot_objective()
	if camera == null or hero == null:
		return
	_maybe_report_area_change()
	update_ambience()
	update_music()
	var target_rect := _camera_target_rect_for_area(_area_for_x(hero.global_position.x))
	var target_top: float = target_rect.position.y
	var target_bottom: float = target_rect.position.y + target_rect.size.y
	_camera_top = move_toward(_camera_top, target_top, CAMERA_LIMIT_LERP_SPEED * delta)
	_camera_bottom = move_toward(_camera_bottom, target_bottom, CAMERA_LIMIT_LERP_SPEED * delta)
	camera.world_limits = Rect2(0.0, _camera_top, level_width, _camera_bottom - _camera_top)


## Run-time bookkeeping only (never rolled back on death): the completion
## screen's "active play time" only counts time the hero could actually act,
## which already excludes every modal (WorkbenchPanel/SwapConfirm/SC01's
## cutscene/the completion screen itself, all of which disable
## `hero.input_enabled`) — see Session.tick_active_time()'s doc comment.
func _physics_process(delta: float) -> void:
	_tick_lockdown_pa(delta)
	if hero and hero.input_enabled and not level_ended_flag:
		Session.tick_active_time(delta)


func _exit_tree() -> void:
	if Session and Session.story_state_changed.is_connected(_on_story_state_changed):
		Session.story_state_changed.disconnect(_on_story_state_changed)
	if Session and Session.run_reset.is_connected(_on_run_reset_route_pa):
		Session.run_reset.disconnect(_on_run_reset_route_pa)
	var hub := BeatHub.get_instance()
	if hub.beat_entered.is_connected(_on_beat_entered_route_pa):
		hub.beat_entered.disconnect(_on_beat_entered_route_pa)
	# Leaving the level mid-announcement (Quit to title) must not leave a PA voice
	# talking over the title screen.
	if (_lockdown_pa == LockdownPa.SPEAKING or _pa_lethal_active) and is_instance_valid(Audio):
		Audio.stop_voice()
	# the 12 s level-complete sting must not run on into the title screen
	if is_instance_valid(Audio):
		Audio.stop_sfx(&"sting_complete")


## Objectives (05-content-and-assets.md): "Reach the server depot." (the
## new-run default) becomes "Plug into Adam's core node." the moment the
## hero first steps into the depot (A05), before SC01. Guarded on the
## objective's own current value, so this only ever fires once per run (and
## never overwrites a later objective on a subsequent visit/death).
func _maybe_update_depot_objective() -> void:
	if hero == null or Session == null:
		return
	if Session.get_objective() != Session.OBJECTIVE_START:
		return
	if Session.get_story("awakening_done"):
		return
	var area := _area_for_x(hero.global_position.x)
	if area and area.area_id == DEPOT_AREA_ID:
		Session.set_objective(Session.OBJECTIVE_DEPOT)


## Telemetry area_enter/area_exit (07-acceptance-and-playtesting.md "time
## spent in each area"). Separate from the camera's own smoothed tracking so
## an event fires exactly once per real area crossing.
func _maybe_report_area_change() -> void:
	var area := _area_for_x(hero.global_position.x)
	if area == _telemetry_area:
		return
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		if _telemetry_area:
			telemetry.area_exit(_telemetry_area.area_id)
		if area:
			telemetry.area_enter(area.area_id)
	_telemetry_area = area


## N05 ambience: the bed for where the hero stands now (AmbienceMap's table), with
## the lockdown read from Session each time so a Continue, a death rollback and a
## Play again all land on the right bed with no signal of their own. The core room
## is the depot stretch around the CoreNode (its real position, or the map's
## fallback); `_in_core_room` keeps its edge from flickering.
func ambience_bed() -> StringName:
	if hero == null or areas.is_empty():
		return AmbienceMap.NONE
	var area := _area_for_x(hero.global_position.x)
	var area_id: String = area.area_id if area else ""
	if area and area_id == AmbienceMap.AREA_DEPOT:
		var core := area.get_node_or_null("Entities/CoreNode") as Node2D
		var core_x: float = core.position.x if core else AmbienceMap.CORE_NODE_X
		_in_core_room = AmbienceMap.in_core_room(
				hero.global_position.x - area.global_position.x, core_x, _in_core_room)
	else:
		_in_core_room = false
	return AmbienceMap.bed_for(area_id, Session.get_story("awakening_done") == true, _in_core_room)


## Asks the Audio autoload for `ambience_bed()`; asking for the bed that already
## plays does nothing, so this is cheap enough to run every frame.
func update_ambience() -> void:
	# A level that Quit to title has just freed can still run one more frame; it must not
	# put its bed back under the title screen that already silenced it.
	if is_queued_for_deletion():
		return
	Audio.set_ambience(ambience_bed())


## N05 music: the track for where the hero stands now (AmbienceMap.music_for()). Like
## the bed it reads the lockdown from Session each time, so a Continue at any
## checkpoint, a death rollback and a Play again land on the right track with no
## signal of their own, and main.gd leaves the level music to this director.
func music_track() -> StringName:
	var area: AreaRoot = null
	if hero != null and not areas.is_empty():
		area = _area_for_x(hero.global_position.x)
	return AmbienceMap.music_for(
			area.area_id if area else "", Session.get_story("awakening_done") == true)


## True once the level is over: the wicket is reached, the completion screen is up, or
## a loaded save was already complete. From then on the completion screen owns the
## music (it fades the level music out and plays the completion sting), so the
## per-frame poll below must not start a level track over it.
func music_held() -> bool:
	return level_ended_flag or _completion_screen != null or Session.get_story("level_complete") == true


## Asks the Audio autoload for `music_track()`; asking for the track that already
## plays does nothing, so this is cheap enough to run every frame. Does nothing once
## the level is over (`music_held()`) or the level has been freed (the same
## last-frame guard as `update_ambience()`: Quit to title has already set the title
## music, and a poll must not replace it).
func update_music() -> void:
	if hero == null or areas.is_empty() or is_queued_for_deletion() or music_held():
		return
	Audio.set_music(music_track())


# --- area assembly -----------------------------------------------------------

func _build_areas() -> void:
	_areas_root = Node2D.new()
	_areas_root.name = "Areas"
	add_child(_areas_root)

	areas = []
	var x := 0.0
	for path in AREA_SCENE_PATHS:
		var area: AreaRoot = (load(path) as PackedScene).instantiate()
		area.position.x = x
		_areas_root.add_child(area)
		areas.append(area)
		x += area.width
	level_width = x

	_connect_exit_wicket()
	_update_weapon_tag()


## The HUD names the held gun's copy (its workshop tag) only when this level has a
## swap pad to trade it at (Level 1 has none since 2026-10-08).
func has_swap_pad() -> bool:
	if _areas_root == null:
		return false
	for pad in get_tree().get_nodes_in_group("weapon_pad"):
		if _areas_root.is_ancestor_of(pad):
			return true
	return false


func _update_weapon_tag() -> void:
	if hud:
		hud.set_weapon_tag_shown(has_swap_pad())


## Free every area and rebuild them fresh so each pickup/enemy/switch/story
## object re-reads `Session` in its own `_ready()` (per CONVENTIONS.md).
## Renaming the outgoing node before `queue_free()` avoids a transient
## duplicate-name collision with the replacement "Areas" node added right
## after it.
func _rebuild_areas() -> void:
	var old := _areas_root
	old.name = "AreasOld"
	old.queue_free()
	_build_areas()


func _area_for_x(global_x: float) -> AreaRoot:
	for area in areas:
		if global_x < area.global_position.x + area.width:
			return area
	return areas[-1]


func _camera_target_rect_for_area(area: AreaRoot) -> Rect2:
	var local_limits := area.get_camera_limits()  # world-space already, but x spans only this area
	return Rect2(0.0, local_limits.position.y, level_width, local_limits.size.y)


## `_ready()` only fires once a node's whole subtree has entered the tree, so
## by the time this runs (end of `_build_areas()`), every ExitWicket just
## instanced under `_areas_root` has already run its own `_ready()` and
## joined group "exit_wicket" — no manual subtree walk needed.
func _connect_exit_wicket() -> void:
	for node in _find_exit_wickets(_areas_root):
		if not node.wicket_reached.is_connected(_on_wicket_reached):
			node.wicket_reached.connect(_on_wicket_reached)


func _find_exit_wickets(node: Node) -> Array:
	var found: Array = []
	if node.is_in_group("exit_wicket"):
		found.append(node)
	for child in node.get_children():
		found.append_array(_find_exit_wickets(child))
	return found


# --- checkpoints / respawn ----------------------------------------------------

func _place_hero_at_checkpoint(checkpoint_id: String) -> void:
	var entry: Array = CHECKPOINT_MARKERS.get(checkpoint_id, CHECKPOINT_MARKERS["CP00"])
	var area: AreaRoot = areas[entry[0]]
	var marker := area.get_marker(entry[1])
	var pos: Vector2 = marker.global_position if marker else area.global_position
	hero.respawn_at(pos)


func _on_hero_died() -> void:
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		var area := _area_for_x(hero.global_position.x)
		telemetry.death(hero.global_position, area.area_id if area else "", "health_zero")
	hero.input_enabled = false
	if death_beat_enabled:
		GameFeel.death(hero)
		await get_tree().create_timer(DEATH_HOLD, false).timeout
		await _fade_death(1.0, DEATH_FADE)
		if not is_inside_tree():
			return
	Session.restore_committed()
	await _finish_death_rebuild()
	if death_beat_enabled and is_inside_tree():
		_fade_death(0.0, DEATH_FADE_IN)


func _on_run_reset_route_pa() -> void:
	_route_pa_said.clear()


func _on_beat_entered_route_pa(beat_id: String, _area_id: String) -> void:
	if not ROUTE_PA_LINES.has(beat_id) or _route_pa_said.has(beat_id):
		return
	if Session and Session.get_story("awakening_done") == true:
		return
	var subtitles := get_tree().get_first_node_in_group("subtitle_panel") if is_inside_tree() else null
	if subtitles == null:
		return
	_route_pa_said[beat_id] = true
	var line: String = ROUTE_PA_LINES[beat_id]
	subtitles.say(PA_SPEAKER, line)
	await get_tree().create_timer(ROUTE_PA_HOLD, false).timeout
	if is_instance_valid(subtitles) and subtitles.current_line() == line:
		subtitles.clear_line()


## The black over the level while a death resets it (made on first use).
func _fade_death(to_alpha: float, seconds: float) -> void:
	if _death_fade == null:
		var layer := CanvasLayer.new()
		layer.name = "DeathFade"
		layer.layer = 18
		add_child(layer)
		_death_fade = ColorRect.new()
		_death_fade.color = Color(0.0, 0.0, 0.0, 0.0)
		_death_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_death_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
		layer.add_child(_death_fade)
	var tw := create_tween()
	tw.tween_property(_death_fade, "color:a", to_alpha, seconds)
	await tw.finished


## Pause menu's "Restart from checkpoint" (M5 part 2): same rollback +
## rebuild a death gets, just entered from the paused menu instead of
## `hero.died`, and reported as its own telemetry event (not a "death") so a
## playtest report can tell the two apart.
func _on_restart_from_checkpoint_confirmed() -> void:
	get_tree().paused = false
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.restart_from_checkpoint(String(Session.state.get("checkpoint_id", "CP00")))
	hero.input_enabled = false
	Session.restore_committed()
	_finish_death_rebuild()


func _on_quit_to_title_confirmed() -> void:
	get_tree().paused = false
	quit_to_title_requested.emit()


## Not deferred by name (an `await`-ing method can't be reached through
## `call_deferred`'s string form in a way that lets us await it here anyway;
## calling it directly starts it immediately and it suspends itself at the
## `await` below, which is all the deferral this needs).
func _finish_death_rebuild() -> void:
	# Move the hero away BEFORE rebuilding (using the outgoing areas' marker,
	# which is still perfectly valid — freeing those nodes afterward doesn't
	# change a position already read from them).
	_place_hero_at_checkpoint(String(Session.state.get("checkpoint_id", "CP00")))
	# Let one real physics step land before creating any fresh Area2D entity
	# (chips, capsules, ...). The hero's CharacterBody2D transform updates
	# immediately, but the physics server's own broadphase — what a brand
	# new monitoring Area2D checks against the instant it enters the tree —
	# only catches up on the NEXT physics step. Without this wait, a fresh
	# pickup created this same frame at the hero's old (death) position can
	# still see the stale broadphase state and instantly re-collect itself,
	# even though the hero has already "moved" as far as its own transform
	# is concerned.
	await get_tree().physics_frame
	_rebuild_areas()
	camera.reset_position()
	hero.input_enabled = true
	# The old (now freed) AreaRoot instance can never compare equal to the
	# freshly rebuilt one even when the hero never left that area's bounds —
	# resync silently rather than let the next _process() log a spurious
	# area_exit/area_enter pair for a crossing that didn't happen.
	_telemetry_area = _area_for_x(hero.global_position.x)


# --- kill plane / temporary end -----------------------------------------------

func _add_kill_plane() -> void:
	var kill_plane: KillPlane = (load(KILL_PLANE_SCENE) as PackedScene).instantiate()
	kill_plane.damage = 0
	kill_plane.position = Vector2(level_width * 0.5, KILL_PLANE_Y)
	add_child(kill_plane)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(level_width + KILL_PLANE_MARGIN, 80.0)
	(kill_plane.get_node("CollisionShape2D") as CollisionShape2D).shape = shape
	# This is a bug-guard far below every area's real geometry, so a hit here
	# is already an unintended gap somewhere. Resetting it to the CURRENT
	# area's own safe marker (rather than always CP00/A01) keeps that bug
	# from also sending the player thousands of px back through areas they
	# already cleared. Take over from KillPlane's own fixed-NodePath handler
	# so the reset position is computed fresh at the moment of the hit.
	if kill_plane.body_entered.is_connected(kill_plane._on_body_entered):
		kill_plane.body_entered.disconnect(kill_plane._on_body_entered)
	kill_plane.body_entered.connect(_on_level_kill_plane_entered)


func _on_level_kill_plane_entered(body: Node) -> void:
	if not body.is_in_group("hero") or not body.has_method("fall_to"):
		return
	var area := _area_for_x(body.global_position.x)
	var marker := _nearest_safe_marker(area)
	body.fall_to(marker.global_position if marker else Vector2.ZERO, 0)


## The area's own bug-guard fallback marker: prefer "FailsafeReset" (used by
## that area's own KillPlane where present), else its "Spawn_CP00".
func _nearest_safe_marker(area: AreaRoot) -> Marker2D:
	var m := area.get_marker("FailsafeReset")
	if m:
		return m
	return area.get_marker("Spawn_CP00")


## Real ending (replaces M3's temporary "wicket reached" overlay): commit
## CP05, set the final objective and `level_complete` story flag, emit
## `Session.level_completed`, disable hero input, and show the completion
## screen with this run's totals. Exactly like `commit()`'s own contract, a
## persistence failure here still shows the completion screen (with the same
## honest save-failed toast every other commit uses) rather than losing the
## moment entirely — nothing about reaching the wicket is undone by a failed
## save.
func _on_wicket_reached() -> void:
	if level_ended_flag:
		return
	level_ended_flag = true
	Session.set_story("level_complete", true)
	Session.set_objective(Session.OBJECTIVE_COMPLETE)
	# On a persistence failure `commit()` itself emits `save_failed`, which the
	# HUD is already listening to (its own toast fires the usual honest
	# message) — nothing extra to do here beyond still showing the screen.
	Session.commit("CP05")
	Session.level_completed.emit()
	if hero:
		hero.input_enabled = false
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.completion(
				float(Session.run_meta.get("active_seconds", 0.0)),
				Session.chips_found(),
				Session.has_evidence("EF01"),
				Session.weapon_stage("W01"))
	# The wicket's line takes over the PA from any lockdown announcement still
	# running (its caption and voice are cut; nothing overlaps).
	_cancel_lockdown_pa()
	var subtitles := get_tree().get_first_node_in_group("subtitle_panel")
	if subtitles:
		subtitles.say(PA_SPEAKER, PA_LINE)
	# N05: the line is spoken, and its caption is held past the clip.
	var pa_hold := PA_BEAT
	var clip_seconds: float = Audio.play_voice(&"pa_lethal")
	if clip_seconds > 0.0:
		_pa_lethal_active = true
		pa_hold = maxf(PA_BEAT, clip_seconds + PA_VOICE_BEAT)
	get_tree().create_timer(pa_hold, false).timeout.connect(_on_pa_line_done)
	level_ended.emit()


func _on_pa_line_done() -> void:
	_pa_lethal_active = false
	var subtitles := get_tree().get_first_node_in_group("subtitle_panel")
	if subtitles:
		subtitles.clear_line()
	_show_completion_screen()


# --- N05: the lockdown announcement ------------------------------------------------

## A live `awakening_done` (SC01 finishing, watched or skipped) arms the
## announcement. Continue/restore never emit this signal, so a loaded save that
## is already in lockdown stays silent; a new run's next lockdown arms it again.
func _on_story_state_changed(flag: String, value: Variant) -> void:
	if flag == "awakening_done" and value == true and not level_ended_flag:
		_lockdown_pa = LockdownPa.WAIT_CONTROL


## Steps the announcement: wait for the scene to hand control back, then
## PA_CALM_DELAY, then speak and hold the caption. Never touches the hero's
## input or the scene, only reads them.
func _tick_lockdown_pa(delta: float) -> void:
	match _lockdown_pa:
		LockdownPa.WAIT_CONTROL:
			if hero and hero.input_enabled and not Session.cutscene_active:
				_lockdown_pa = LockdownPa.DELAY
				_lockdown_pa_t = PA_CALM_DELAY
		LockdownPa.DELAY:
			_lockdown_pa_t -= delta
			if _lockdown_pa_t <= 0.0:
				_start_lockdown_pa()
		LockdownPa.SPEAKING:
			_lockdown_pa_t -= delta
			if _lockdown_pa_t <= 0.0:
				_lockdown_pa = LockdownPa.IDLE
				var subtitles := get_tree().get_first_node_in_group("subtitle_panel")
				if subtitles:
					subtitles.clear_line()


func _start_lockdown_pa() -> void:
	_lockdown_pa = LockdownPa.IDLE
	# No subtitle panel (an isolated test that removed it): nothing to announce.
	var subtitles := get_tree().get_first_node_in_group("subtitle_panel")
	if subtitles == null:
		return
	subtitles.say(PA_SPEAKER, PA_CALM_LINE)
	var clip_seconds: float = Audio.play_voice(&"pa_remain_calm")
	_lockdown_pa_t = PA_CALM_HOLD
	if clip_seconds > 0.0:
		_lockdown_pa_t = maxf(PA_CALM_HOLD, clip_seconds + PA_VOICE_BEAT)
	_lockdown_pa = LockdownPa.SPEAKING


## Drops the announcement wherever it is. If it is mid-line, the voice stops too;
## its caption is left for whoever speaks next to replace.
func _cancel_lockdown_pa() -> void:
	if _lockdown_pa == LockdownPa.SPEAKING:
		Audio.stop_voice()
	_lockdown_pa = LockdownPa.IDLE


func _show_completion_screen() -> void:
	if _completion_screen != null:
		return
	_completion_screen = load(COMPLETION_SCENE).instantiate()
	add_child(_completion_screen)
	_completion_screen.play_again_confirmed.connect(_on_play_again_confirmed)
	_completion_screen.quit_requested.connect(_on_quit_requested)
	# N05: the level music fades out and the completion sting (a low pulse resolving
	# into a quiet unresolved chime, flat) takes its place. The poll in update_music()
	# stays off while the screen is up (music_held()); Play again brings the level
	# music back, Quit to title the title music.
	Audio.set_music(&"none")
	Audio.play_sfx(&"sting_complete")


## "Play again" (03-gameplay-systems.md / M5 "fresh replay clears run
## state"): a brand-new run AND a cleared save (never just an in-memory
## reset that a Continue could still find stale data behind), then rebuild
## the level exactly like a death-rebuild does so every object re-reads
## Session fresh.
func _on_play_again_confirmed() -> void:
	if _completion_screen:
		_completion_screen.queue_free()
		_completion_screen = null
	Session.new_run()
	var checkpoint_service := get_node_or_null("/root/CheckpointService")
	if checkpoint_service:
		checkpoint_service.clear()
	Audio.stop_sfx(&"sting_complete")
	level_ended_flag = false
	_place_hero_at_checkpoint(String(Session.state.get("checkpoint_id", "CP00")))
	# The completion screen silenced the music; the new run's opening track fades in now.
	update_music()
	await get_tree().physics_frame
	_rebuild_areas()
	camera.reset_position()
	hero.input_enabled = true
	_telemetry_area = _area_for_x(hero.global_position.x)
	var telemetry := get_node_or_null("/root/Telemetry")
	if telemetry:
		telemetry.run_start()
		if _telemetry_area:
			telemetry.area_enter(_telemetry_area.area_id)


func _on_quit_requested() -> void:
	get_tree().quit()
