# DEAD EDEN game — implementation conventions

This is the painted game (C56–C61): the Godot project "DEAD EDEN", exported as
`DeadEden`. Level 1 is complete and Level 2 ([Alignment](../level-design/l02-alignment.md))
is next. It was the hand-painted prototype until C61 moved it here from
`prototypes/sunnyvale-handpainted/`; the pixel-art prototype is gone from the
tree (tag `pixel-prototype-final`).

Binding contracts for everyone (human or AI) building this Godot project. The
design authority is `../prototype-plans/level-01-sunnyvale/` (00–09 +
prototype-spec.json). This file only fixes *how* the code fits together. If
you must change a contract here, update this file in the same edit.

Revamp (2026-09-29, C24): the prototype was rebuilt from the zombie-suburb
version to the new game (Dave Harlan on Arcadia's campus at night, cyborg
Staffers, microchips, the Adam core-node scene, the L01-KC01 keycard). This
file uses the current vocabulary throughout. Old session logs and pre-revamp
test or export output name the same things Resident (Z01), gem, artifact
(A01), bench, core console, care capsule, EDEN, quarantine and suburb; the
plan README's revamp note has the full map.

Level 1 rebuild (2026-09-30, C33): Level 1 was rebuilt from the ground up
around the approved enemy roster, and the enemies are lit cutouts (C35). The
C24 build's Staffer (CY01) and Clipper (R01) are gone. The enemies are now the
SE01 Night Guard and the LK01 Staffer (both a `Brawler`, told apart by their
`BrawlerTuning` and scene) and the M01 Patrol Rover (a `PatrolRover`, tuned by
`ChargerTuning`); the level places 16 of them (8 guards, 6 rovers, 2
Staffers). Every enemy ID changed, so the save schema is 3. This file uses the
current names throughout; older logs and pre-rebuild test or report output say
Staffer (CY01) and Clipper (R01) for the previous enemies.

`scripts/main.gd` (`scenes/main.tscn`, the project's `run/main_scene`) is the
whole game-flow shell (M5 part 2): it owns the Title screen <-> level
transition and nothing else. It adopts `Session` state (`new_run()` or
`load_from_snapshot(snapshot)`) and opens `Telemetry`'s log BEFORE instancing
`level_01.tscn` under `LevelDirector`, then listens for `LevelDirector.
quit_to_title_requested` (from the pause menu) to free the level and show the
title screen again. `LevelDirector` itself never knows about the title
screen. The title's New Game goes through `_on_new_game_requested()`: it resets
the run and deletes the save at once, shows the SC00 intro comic
(`scripts/ui/intro_comic.gd`, C49, group `intro_comic`, `finished(skipped)`)
and starts the level when the comic ends. `_on_new_game_confirmed()` still
starts the level at once (the tests and demos call it), and `play_intro = false`
makes the title's New Game skip the comic. Continue never shows it. The comic's
narration is ordinary voice lines (`intro_narration_01` to `_08`, `intro_stroud_04`;
`Audio.play_voice()`), and it ducks the music with `Audio.set_music_duck(db)` (an
Amplify effect on the Music bus, so the Music slider is untouched) and lifts it when it
ends or is freed.

## Engine and commands

- Godot **4.7.2.stable.official** at `/Applications/Godot.app/Contents/MacOS/Godot`.
  GDScript only, Compatibility renderer, 1280×720 canvas_items/expand, physics 60 Hz.
- `tools/test.sh [filter]` — refresh import cache, run headless tests
  (`tests/cases/test_*.gd`) on a fixed 60 fps step so simulated time runs
  faster than real time (full suite ≈ 3 minutes). Run it after every change.
  `FPS=30 tools/test.sh` repeats at a 30 fps fixed step. `NOIMPORT=1` skips import (use when
  another process may be importing; run with import after adding new resource files).
  A case that fails to compile is reported as FAIL (`tests/run_tests.gd`), not a
  hang; 56 files are in `tests/cases/` since the C33 rebuild.
- `tools/capture.sh res://scenes/... OUT_DIR [frames] [fps]` — windowed Movie
  Maker capture to PNG frames for visual evidence. Put output in the session
  scratchpad, never in the repo.
- Every `scripts/debug/*_demo.gd`'s `_ready()` MUST call
  `CheckpointService.set_save_dir("user://debug_demo_throwaway/<name>")`
  BEFORE any `Session`/`CheckpointService` call (critical, ADV/
  debug-demos-touch-real-save): unlike `tests/run_tests.gd`, which redirects
  the WHOLE automated suite to one throwaway dir, nothing redirects a manual
  capture demo on its own — without this line a demo that calls
  `Session.commit()`/`Session.new_run()` + `CheckpointService.clear()` (New
  Game) writes straight into the real player's default save dir.
  `scripts/debug/enemy_lab.gd` (the enemy lab, below) does the same for
  `CheckpointService` and `Telemetry` in `_enter_tree()`, pointing both at
  `user://enemy_lab_throwaway`.
- `scenes/debug/enemy_lab.tscn` (`scripts/debug/enemy_lab.gd`) is a lit test strip
  with all three enemies, lamps, a stone backstop and an annex door, on the real
  scenes, for judging the art, tells, ragdolls and blood. Run it with
  `Godot --path . res://scenes/debug/enemy_lab.tscn` (README, "Enemy lab", has
  the keys); `-- --autoplay` plays a scripted tour for captures. It replaces
  the deleted `spike/` test folder and `tools/spike/`.
- `scenes/debug/enemy_lab_l02.tscn` (`scripts/debug/enemy_lab_l02.gd`, M4) is the
  same kind of strip for Level 2's three new types: a Sidearm Guard behind a 0.6 H
  range bench, a second one on a raised step (the aimed shot), a Security Drone over
  a deck, and a Hound with its Night Guard handler before a kennel wall; keys in its
  header; `-- --autoplay` (or `--autoplay=gunner|ledge|drone|hound`) plays the tour.
  Saves and logs go to `user://enemy_lab_l02_throwaway`.
- After adding/renaming a script with `class_name`, the import step must run
  before `-s` scripts can resolve it (test.sh does this). New visual scripts
  stay free of `class_name` unless the file already has one (import-cache
  rule).
- `project.godot` input/display/layer settings are generated by
  `scripts/tools/configure_project.gd`; edit that script and rerun it rather
  than hand-editing those sections.

## Coordinates and scale

Up is −y. Hero height **H = 96 px**. Block `position` is the rectangle's
top-left. Floors' top surface is their `position.y`. Tuning seeds live in
`.tres` resources under `data/tuning/` (typed by scripts in
`scripts/tuning/`), never as magic numbers scattered across scripts.

## Collision layers (bit value in parentheses)

| # | Name | Who is on it | Who masks it |
|---|---|---|---|
| 1 | world (1) | Block, moving platforms (AnimatableBody2D), backstops, doors/walkways | hero body, enemy bodies, bolts |
| 2 | hero_body (2) | Hero CharacterBody2D | pickups (Area2D, mask 2), hazards (mask 2), triggers |
| 3 | enemy_body (4) | Enemy CharacterBody2D | nothing by default (hero/enemies never body-block each other) |
| 4 | hero_hurtbox (8) | Hero `Hurtbox` Area2D | enemy AttackBox, enemy rounds (ray sweep, mask 1\|8) |
| 5 | hittable (16) | HitZone areas: enemy bodies (a person's zone `bleeds`), the Patrol Rover's armor (blocks) & rear battery, targets | bolts (ray/shape query, mask 1\|16) |
| 6 | interactable (32) | Interactable areas | hero `InteractSensor` |
| 7 | pickup (64) | chips, med-patches, the keycard (contact pickups) | — (they mask 2) |
| 8 | hazard (128) | pit/fall-reset areas | — (they mask 2) |

## Autoload `Session` (scripts/session.gd)

Authoritative run state + last committed snapshot. Read anything; mutate only
via its methods (`apply_damage`, `heal`, `collect`, `record_evidence`,
`take_keycard`, `mark_defeated`, `set_switch`, `set_story`, `set_objective`,
`commit`, `restore_committed`, `load_from_snapshot`, `purchase_upgrade`,
`swap_weapon`, …). Signals: `health_changed`, `wallet_changed`,
`enemy_defeated`, `pickup_collected`, `evidence_recorded`, `keycard_taken`,
`weapon_swapped`, `upgrade_purchased`, `checkpoint_committed`,
`story_state_changed`, `switch_changed`, `objective_changed`,
`snapshot_restored`, `level_completed`, `save_failed(reason,
attempted_checkpoint_id)`, `run_reset` (ADV-03: emitted at the end of
`new_run()` only — the one case where a UI node that already exists, and is
never recreated, needs telling that the run reset; `Hud` listens to refresh
its weapon tag/Quickcycle pip on "Play again"). Health lives in Session (hero
owns immunity/knockback only). Connect once; disconnect in `_exit_tree` if the
node can be rebuilt.

`state` (`Session.default_state()`) holds: `schema_version` (3 since the C33
rebuild, which changed every enemy ID; 2 since the revamp), `build`, `level`, `checkpoint_id`, `health`, `wallet` (microchips),
`collected` (entity id -> chip value, 0 for evidence files, med-patches and
the keycard), `evidence` (evidence-file ids such as
`"EF01"`), `keycards` (clearance keycard ids such as `"L01-KC01"`),
`upgrades`, `equipped_weapon`, `world_weapons`, `weapon_ammo` (M3: a
finite weapon's shells per instance, see "Boom Broom and the held-weapon swap
(M3)"), `defeated`, `switches`,
`story`, `objective`, `active_seconds`. `collect(entity_id, chip_value)` is a
one-time record; `record_evidence(evidence_id, pickup_entity_id)` and
`take_keycard(keycard_id, pickup_entity_id)` each record their own list plus
the pickup entity as collected (0 chips) and refuse repeats.
`has_evidence(id)`, `has_keycard(id)` and `chips_found()` read them back.

World objects decide their own presence in `_ready()` from Session
(`is_collected`, `is_defeated`, `get_switch`, `get_story`, `has_keycard`).
Rollback = `Session.restore_committed()` then the level scene is re-instanced.
No object stores saved values locally.

### Persistence (M4): `commit()` / `purchase_upgrade()` / `swap_weapon()`

`commit(checkpoint_id) -> bool` builds the complete current `state`, persists
it through the `CheckpointService` autoload, and only on success adopts it as
`committed` and emits `checkpoint_committed`; on failure it restores only the
one field it changed (`state["checkpoint_id"]`) and emits
`save_failed("save_failed", checkpoint_id)` — every other change the caller
already made this run (health, wallet, ...) is deliberately left live but
uncommitted ("kept in memory only" per the design docs), never rolled back by
`commit()` itself. `load_from_snapshot(snapshot)` is Continue's counterpart to
`new_run()`: adopts a loaded snapshot as both `state` and `committed`
(normalizing JSON's int-as-float round trip back to int first) and re-emits
every signal.

`purchase_upgrade(weapon_type, target_stage, price) -> {ok, reason}` is a
full atomic transaction: preconditions (`awakening_done`, exact next stage,
enough chips) are checked against LIVE `state` with zero side effects on
refusal (`reason` one of `"locked"`, `"insufficient_funds"`,
`"already_owned"`, `"invalid_stage"`); on success it builds one complete
candidate state (wallet debited, the type-wide stage recorded, checkpoint id
`"UPG01"`), persists THAT, and only adopts it into `state`/`committed` after
`CheckpointService.save_snapshot()` returns true — a persistence failure
(`reason: "save_failed"`) leaves `state` byte-for-byte as it was (no
paid-but-missing upgrade, no free upgrade) and also emits `save_failed`.

`swap_weapon(pad_id) -> {ok, reason, old_id, new_id}` atomically exchanges
`state["equipped_weapon"]` with the instance resting on `pad_id`. This is a
live-state-only change (never itself persists/commits) — it rolls back with
the next `restore_committed()` like any other uncommitted change, per
weapon-swaps.md.

### Objective / run bookkeeping (M5)

Exactly one of `Session.OBJECTIVE_START` ("Reach the server depot.") /
`OBJECTIVE_DEPOT` ("Plug into Adam's core node.") / `OBJECTIVE_POST_SC01`
("Escape through the service wicket.") / `OBJECTIVE_COMPLETE` ("Eon City
complete.") is ever `state["objective"]` (part of the persisted state, so it
survives rollback/reload); `LevelDirector` bumps START->DEPOT on first
entering A05 pre-awakening, `CoreNode` bumps DEPOT->POST_SC01 as part of
`_finish_awakening()` (committed with CP04), and
`LevelDirector._on_wicket_reached()` bumps POST_SC01->COMPLETE (committed
with CP05). The story flag `awakening_done` keeps its original name for
save and test stability; since the revamp it means "Adam has answered Dave
and the campus is in lockdown". `Session.chips_found()` sums
`state["collected"]` values (unique IDs — independent of `wallet`, which
spending lowers) for the completion screen's "microchips found" stat.
`run_meta` (`active_seconds`, `deaths`) is run-only bookkeeping, deliberately
never part of the persisted/rolled-back `state`: `tick_active_time(delta)` is
called by `LevelDirector._physics_process` only while `hero.input_enabled` is
true, which already excludes every modal (WorkbenchPanel/SwapConfirm/SC01/the
completion screen itself) and, since M5 part 2, is naturally excluded while
`get_tree().paused` too (PauseMenu's whole suspend mechanism IS that pause
flag, which already stops this same `_physics_process` from running at all —
no extra gating needed). `run_meta` resets only on
`new_run()`/`load_from_snapshot()`, never on death. `state` carries its own
separate `active_seconds` field (float, part of the persisted/whitelisted
shape) that `commit()`/`purchase_upgrade()` mirror `run_meta["active_seconds"]`
into on every successful commit (ADV-09) so a completed (`level_complete`)
save's Continue can show its own real "active play time" again —
`load_from_snapshot()` seeds `run_meta["active_seconds"]` from it ONLY when
the loaded story's `level_complete` flag is true; an ordinary mid-run
Continue still starts this run's own counter at 0 as before.
`Session.cutscene_active` (also live-only, never persisted) is a separate,
narrower flag: true only while `CoreNode`'s own SC01 coroutine runs, so
`PauseMenu._can_open()` can suspend that one noninteractive scene even though
it disables `hero.input_enabled` for its whole duration (ADV-01).

`Session.runtime_flags` (M7 readability pass) is the same "live-only, never
persisted, reset only by `new_run()`/`load_from_snapshot()`" idiom as
`cutscene_active`, generalized to a `Dictionary` of one-shot UI flags —
`get_runtime_flag(key) -> bool` / `set_runtime_flag(key)` (idempotent: call it
the moment you show the thing, not before, so a failed/aborted show can still
retry). A death/respawn rebuild mid-run (`restore_committed()`) deliberately
does NOT clear it, so something already shown this run never re-shows after a
respawn, but it shows again on a genuinely new run/Continue. Used by
`TutorialPrompt.once_per_run_key` (below).

### `CheckpointService` autoload (`scripts/checkpoint_service.gd`)

Versioned JSON persistence under `user://sunnyvale/` (default): `checkpoint.json`
(primary) + `checkpoint.bak.json` (the primary immediately before the last
replace). `save_snapshot(snapshot) -> bool` validates, writes a temp file,
closes it, re-reads/re-validates the exact bytes on disk, THEN — only when
the CURRENT primary is itself a valid, loadable snapshot (ADV-08: rotating a
corrupt/truncated primary over the backup would destroy the one remaining
last-known-good copy) — copies it to the backup path, THEN replaces the
primary with the verified temp file (`DirAccess.rename_absolute`/
`copy_absolute`, confirmed available in 4.7.2) — a validation failure or I/O
error at any step changes nothing already on disk. `load_latest() -> {ok,
snapshot, source, error}` tries the primary, falls back to the backup on ANY
problem (missing, malformed JSON, failed validation), and never returns a
half-loaded snapshot. `validate_snapshot(data) -> {ok, error}` rejects
anything that isn't the complete, correctly-typed, whitelisted-ID shape
`Session.default_state()` produces: wrong `schema_version` (3; a save from
the C24 build, schema 2, or the pre-revamp build, schema 1, is rejected here) or `level`, an out-of-range
value (health outside 1..MAX_HEALTH, wallet outside 0..MAX_WALLET=65, an
upgrade stage above `MAX_WEAPON_STAGE`=1), a non-whitelisted id string (this
is what stops a scene path or stray node-ref-shaped string from a tampered
file — evidence ids must match `EF##`, keycard ids `L01-KC##`, checkpoint ids
`CP00`-`CP07` or `UPG01`, and every other id `L01` followed by uppercase/digit
segments), a top-level field outside `ALLOWED_TOP_KEYS`, or
`equipped_weapon`/`world_weapons` not accounting for EXACTLY the two known
weapon instances (`WEAPON_INSTANCES`), each exactly once, on a known pad
(`WEAPON_PADS`) — ADV-07. `has_valid_save()`, `clear()`. Test hooks (never
used in normal play): `set_save_dir(path)` redirects every read/write,
`debug_force_write_failure(true)` fails exactly the next `save_snapshot()`
without touching disk. `remove_dir_recursive(path)` (static) is the cleanup
helper tests use on their own throwaway dir. `save_settings(dict)`/
`load_settings() -> Dictionary` (M5 part 2) read/write a SEPARATE
`settings.json` in the same `_save_dir` — no temp-write/backup dance and no
whitelist/validation (a missing/partial/corrupt file just falls back to
`Settings.DEFAULTS` per key, never a hard failure) — and `clear()`
deliberately never touches this file (only the checkpoint/backup/temp trio).
`tests/run_tests.gd` redirects `CheckpointService` to one fresh throwaway
`user://test_runs/<ticks>` directory for the whole run (clearing it between
every case) and deletes it at the end, so no test — M0-M3 cases that call
`Session.commit()` included — ever touches a real player save.

## Levels and the campaign (M1, C61)

Levels are data; this section supersedes the single-level constants named
elsewhere in this file (`LevelDirector.AREA_SCENE_PATHS`/`CHECKPOINT_MARKERS`/
`DEPOT_AREA_ID`/`PA_LINE`/`PA_CALM_LINE`/`ROUTE_PA_LINES`, `Session.LEVEL`/
`STARTING_WEAPON`, `CheckpointService.LEVEL`/`WEAPON_INSTANCES`/`WEAPON_PADS`/
`MAX_WALLET`/`STORY_FLAGS`, schema 3, Main loading `level_01.tscn`).

- **`LevelDef`** (`scripts/levels/level_def.gd`, Resource; `data/levels/l01.tres`,
  `l02.tres`): `id` (also the prefix of the level's ids), `number`,
  `display_name`, `area_scenes`, `checkpoint_markers` (id -> [area index,
  marker]; its keys are the checkpoint ids the level's saves may carry),
  `first_checkpoint`, `exit_checkpoint`, `starting_weapon`, `world_weapons`,
  `switches`, `keycard_id`, `story_defaults`, `objective_start`/`_complete`,
  `intro_scene` (a `.gd` built with `new()` or a `.tscn`, emitting
  `finished(skipped)`), `next_level`, completion data (`chip_total`,
  `evidence_id`/`_name`, rank times, `completion_line`) and director data
  (`depot_area_id`, `route_pa_lines`, `lockdown_pa_line`/`_voice`,
  `exit_pa_speaker`/`_line`/`_voice`, `overlay_scenes`). Level 1's old
  constants live in `l01.tres`. `l02.tres` lists Level 2's six greybox areas
  (M2, below; M1's one-area stub is gone).
- **Registry** `LevelDefs` (`scripts/levels/level_defs.gd`, static): `PATHS`,
  `ORDER`, `get_def(id)`, `has_level`, `next_of`, `wallet_cap(id)` (the chips of
  that level and the ones before), `WEAPON_TYPES` (types Dave can carry in:
  W01 and, since M3, W02) and `CARRIED_STORY_FLAGS` (`awakening_done`). A new level is a .tres,
  its area scenes and an entry in `PATHS` and `ORDER`.
- **LevelDirector** builds `level_def` (set before `add_child()`, else the
  `level_id` export, else Session's current level). `level_01.tscn` sets
  `"L01"`; Main uses the generic `scenes/levels/level.tscn` and names the node
  `Level01`, `Level02`, ... `checkpoint_markers()` replaces the constant.
  Signals `next_level_requested(level_id)` and `new_run_requested` (Play again
  in a level after the first) go to Main.
- **Carried vs per level.** `state["level"]` names the level; schema **4**
  adds `completed_levels` (older saves are rejected). Carried into the next
  level: the held weapon's TYPE (as `LevelDef.hand_instance(type)`), `upgrades`
  (Scrap Plating too), `wallet`, `evidence`, `completed_levels` and
  `CARRIED_STORY_FLAGS`. Fresh from the next LevelDef: checkpoint, full health,
  `collected`, `defeated`, `keycards`, `switches`, `world_weapons`, the other
  story flags, `objective`, `active_seconds`. `Session.default_state(id = "")`
  and `new_run(id = "")` start a level with the default campaign;
  `next_level_state(from, id)` is the pure handover; `advance_to_level(id) ->
  bool` adopts it as `state` and `committed` and saves its first checkpoint
  (it adopts even when the save fails; the caller reports it);
  `current_level_id()`, `current_level_def()`.
- **Validation** checks a save against its own level's LevelDef: a registered
  level, only that level's id prefix (`<L>(-[A-Z0-9]+)+`, `<L>-SW##`,
  `<L>-KC##`), its checkpoint keys, exactly one of its weapon instance sets on
  its pads, exactly its story flags, wallet up to `wallet_cap`, and
  `completed_levels` as distinct earlier levels. Best-run records are per
  level (`records.json` for L01, `records_l02.json` after).
- **Flow (Main).** New Game plays the first level's intro, then Level 1. At a
  level's end the exit PA plays and the completion screen opens; when there
  is a registered next level it adds a focused **Continue** button and names
  it ("Next: Level 2, Alignment"). Continue makes Main take the level out of
  the tree, call `Session.advance_to_level()`, play that level's intro (if
  any) and start it. Title Continue loads the save's level. Debug builds only:
  `-- --level=L02` (or `L01`) skips the title and runs
  `Main.start_level_direct(id)` (default campaign state), saving under
  `user://level_flag_throwaway` unless `--m7-save-dir` already redirected the
  saves. The M7 driver still plays Level 1 only. Tests:
  `tests/cases/test_campaign_flow.gd`.

### Level 2 greybox (M2, C59)

Six areas `scenes/levels/l02/a01_sky_bridge.tscn` ... `a06_demo_floor.tscn`
(blueprint `../prototype-plans/level-02-alignment/area-blueprints.md`), Level 1's
kit as placeholder art. Tests: `tests/cases/test_l02_areas.gd`.

- **Roof.** `AreaRoot.wet_until_x` (local x): an `indoors` area is outdoors
  before it (A01's sky bridge, x 0-900). `dry_span()` / `is_indoors_at(x)`.
  The atmosphere merges touching dry spans (its shaders take two). Block and
  Scenery take the interior (depot) look from the owning area's roof, no longer
  from the id `L01-A05` (Level 1 is unchanged: the depot is its only indoors
  area); an interior backstop is the `ac_unit` housing, never the stone planter. Batch 7: Level 2's
  areas set `interior_look = "lab"` and wear the painted lab ("Level 2's lab art" below).
  Level 2's beds, tracks and footsteps are keyed by area id in `AmbienceMap`
  (`LAB_AREA_BEDS`/`LAB_AREA_MUSIC`, which win over the lockdown rule) and
  `SurfaceMap` (metal).
- **A04 lanes.** `scripts/objects/rail_rack.gd` (extends MovingPlatform): waits
  at `point_a` until its `switch_id` is on (a RouteSwitch control pad, `L02-SW01`
  to `SW03`), warns `warn_time` (amber rail lamps, `adam_chime`, `move_warned(caption)`
  = the caption hook), crosses once to `point_b` and docks (`arrived`); while
  anything is in its way (a world-space shape cast ahead of its deck) it holds
  still instead of reversing. `lane_partition.gd` (StaticBody2D, top-left +
  `size` like a Block) opens on its rack's `arrived` and never closes. Both
  start docked/open when the switch is already on. The fixed upper ledge (route
  branch `LEDGE`, run alone by the test) crosses A04 with no lane used.
- **Keycard.** `scenes/objects/keycard_console.tscn` (`keycard_console.gd`,
  Interactable): interact = `Session.take_keycard(keycard_id, entity_id)`
  (`L02-KC01`, pickup id `L02-KC01-P`) and `keycard_granted(id)`; M5's console scene
  keys off Session `keycard_taken` (next section). The A06 freight lift is an ExitWicket (`required_keycard = "L02-KC01"`).
- **Slots.** M2's enemy slots (`Marker2D` `Slot_<Type>` with `enemy`, `entity_id`,
  `facing`, `milestone`, `notes` metadata) are gone: M4b put the real enemies there under
  the same ids and kept the notes as metadata (placements: "Level 2's enemies (M4)");
  M3 replaced A01's `Entities/Slot_SwapPad` with the real `Entities/WeaponPad` at x 1300
  (`pad_id` `L02-A01-PAD01`, resting `L02-W02-P01`; next section). Staffer looks are picked by
  entity id (`L02-E04-LK01-B01` = look B, `L02-E08-LK01-A`/`-C`).

### Level 2's story beats (M5)

Tests: `tests/cases/test_l02_story.gd`.

- **Lines over play.** `LevelDef.beat_lines` (beat id -> a list of `[speaker, text]` or
  `[speaker, text, voice id]`) and `keycard_lines` (the level's card taken, live) are played
  by LevelDirector through the subtitle panel, once per run each, in order, never holding
  Dave: each stays up `story_line_seconds(text)` (or its clip plus `PA_VOICE_BEAT`). A new
  set cuts short what is left of the one before; the level's end drops them all
  (`_cancel_story_lines()`), so the exit line is never talked over. `keycard_objective`
  replaces the objective as the card is taken. Level 2: the sky-bridge greeting and Dave's
  reply (`L02-A01-B01`), Adam's tidy sandbox (`L02-A04-B01`), the console scene (the archive
  line, Adam, Dave). No voice clips yet (the third element is left out).
- **Bridge door.** `scripts/objects/bridge_door.gd` (StaticBody2D, A01 `Entities/BridgeDoor`
  at x 920, in the doorway under `PlantLintel`): waits shut (amber reader), opens when Dave is
  `open_range` (360 px) short of it (teal), and locks once he is `lock_after` (100 px) past it
  (red), setting the story flag `bridge_door_locked`. Solid only while shut; it never shuts on
  Dave, and opens again should he ever stand behind it. The painted glass door: the open piece
  drawn whole, the closed piece's two panels (`PANEL_LEFT`/`PANEL_RIGHT`, texels) sliding over it.
- **A04 lockdown.** `scripts/objects/training_lockdown.gd` (Node2D at A04's origin,
  `Entities/Lockdown`): on its `beat_id` (`L02-A04-B01`) it sets `sandbox_lockdown`, plays
  `lockdown`, and fades in over `FADE_TIME`: the emergency strips under the ceiling, the
  area's `Background` modulated to `emergency_tint`, and its six `screens` (area px; the
  `desk_screen` over Dave's desk is larger) switching from teal readouts to his file
  stamped TERMINATED (Rajdhani). It never moves a lane. The racks' `move_warned` captions
  are Adam's (`caption_speaker = "Adam"`).
- **Hologram.** `lattice_hologram.gd` `speak(seconds)` brightens it (`surge`, eased); it calls
  it itself on Session `keycard_taken` (the console scene, SPEAK_SECONDS).
- **Flags and saves.** Level 2's `story_defaults` gained `bridge_door_locked` and
  `sandbox_lockdown`; both roll back with a death like every flag. A save may now lack a flag
  its level has gained since (CheckpointService accepts it, `Session._normalize_snapshot()`
  gives it the default); an unknown flag is still rejected.
- **Capture.** `scenes/debug/l02_story_demo.tscn` (tools/capture.sh): the bridge, the door,
  the lockdown, the console. Throwaway save.

## Level 2 v2 systems (C62, 2026-10-14)

The redesign's kit (`../level-design/l02-alignment.md`, `../prototype-plans/level-02-alignment/area-blueprints-v2.md`). All are stand-in art until art Batch 8 (`piece` exports). No `class_name` on any of them: preload by path.

### Level 2 architecture kit (v2): stairs, structure look, room seams

Tests: `tests/cases/test_l02_architecture.gd`; capture `scenes/debug/architecture_demo.tscn`.

- **Stairs and ramps** (`scripts/world/stairs.gd`, `scenes/world/stairs.tscn`, no class_name) are the only sloped solid: a StaticBody2D on the world layer (group `terrain_stairs`). Exports `rise`, `run` (stairs about 96 over 144; ramps gentler, never over 45 degrees), `direction` (+1 rises toward +x), `style` (STAIRS/RAMP), `steps` (0 = auto), `handrail`, `piece`. Origin = the flight's left end on the lower floor's top; the footprint x 0..run, y -rise..0 is solid (a triangle, high side vertical). The high end MUST meet a landing at that height (a Block, deck or another flight). It is drawn `FOOT_INSET` (20 px, half the hero's box) toward its low end so his feet stand on the drawn pitch line (`surface_y()`); each tread's nosing is lit. Enemies are not tuned for slopes: keep patrols off flights. RouteBot walks flights with MOVE points.
- **Hero floor settings:** `floor_snap_length = Hero.FLOOR_SNAP` (20), `floor_stop_on_slope = true`; `floor_constant_speed` off. He stays on the floor walking down a flight; a drop of 20 px or less off a ledge snaps instead of falling.
- **Structure look** (`scripts/world/lab_structure.gd`, no class_name, called by Block): in a lab area, `Block.lab_structure()` gives deck / raised / floor / ceiling / wall (BACKSTOP and SCENERY_SOLID keep LabSkins' crates and bench). Drawing only; collision, size, position and kind never change. A block 40 px or less tall is a catwalk deck: railing (`Block.railing`) and supports (`Block.support`: AUTO hangs from a ROOF within 480 px above, else columns to a top within 900 px below), so every deck needs a ceiling over it or a floor under it. A raised GROUND block above local y 0 gets a panelled fascia and its kick plate at y 0; a PLATFORM box gets it at its foot. `Block.door_frame`/`door_icon` draw a doorway under a WALL. Warm accents are matte copper and rust-orange, never glowing. Painted replacements: add the `Arch.PIECES` names (`arch_catwalk`, `arch_fascia`, `arch_subfloor`, `arch_ceiling`, `arch_wall`, `arch_door_frame`) to `lab.json`.
- **Room seams** (`scripts/world/room_seam.gd`, no class_name): a Node2D under Scenery, origin on the floor line at the seam's x. Exports `height` (0 = up to the ROOF above), `door_height`, `pier_width`, `style` (DOORWAY/AIRLOCK), `icon` (`Arch.Icon`: NONE, ARROW, LAB, RANGE, KENNEL, DRONE, CELLS, LATTICE, LIFT, STAIRS, HAZARD), `solid_lintel` (default false = purely visual).

### Breakables and secret walls (Level 2 v2)

`scenes/objects/breakable.tscn` (`scripts/objects/breakable.gd`, StaticBody2D, group `breakable`, no
class_name): a prop Dave's shots break. Tests: `tests/cases/test_l02_breakables.gd`; capture
`scenes/debug/breakables_demo.tscn` (`tools/capture.sh ... OUT 360 30`).

- **Exports.** `entity_id`, `kind` (`Breakable.Kind`: GLASS_PANEL, MONITOR, SERVER_CABINET, CRATE,
  GAUGE, VENT_PANEL, DISPLAY_CASE), `health` (damage points; 0 = the kind's default: glass 2, monitor 2,
  server cabinet 4, crate 3, gauge 1, vent panel 2, display case 3), `size` (zero = the kind's default),
  `solid`, `contents: Array[NodePath]`, `piece`. Origin = bottom centre of the prop. Signals
  `cracked(remaining)`, `broke`; `take_damage(amount, at, dir)`, `break_now()`, `is_broken()`, `stage()`
  (`Stage.INTACT/CRACKED/BROKEN`), `remaining_health()`. Contents and sizes must be set before the node
  enters the tree.
- **Hits.** It owns a HitZone (layer 5), so Scrapjack bolts and Boom Broom pellets break it through
  `take_hit()`. A bolt is 1 point; a Broom blast is ONE hit worth its summed pellets (5 at point blank, so
  it breaks anything of health <= 5; far away 1-2). Every kind but the gauge shows a cracked stage once it
  has taken damage and still stands. Hit flash at most once per 0.5 s.
- **Secret wall.** `solid = true` puts an intact prop on world layer 1 (it blocks Dave, enemies and rounds
  like a wall) and its HitZone is `SOLID_ZONE_GROW` (3 px) bigger on every side, so a bolt or pellet ray
  crosses the zone before the body and the wall takes the shot. Once broken both switch off. Use a glass
  panel for a glass wall, a vent panel for a crawlway.
- **Enemies never break it.** EnemyRound's mask is world|hurtbox (no layer 5); rounds pass a non-solid
  prop and stop on an intact solid one without damaging it.
- **Persistence.** With an `entity_id` (`L02-A02-BR01`) a break is `Session.collect(id, 0)`: it stays
  broken after a checkpoint; a death before the next one puts it back. A rebuilt level starts a recorded
  one broken, quietly, with its contents shown. No id = always intact on a rebuild.
- **Contents.** Nodes named by `contents` are hidden and `PROCESS_MODE_DISABLED` until it breaks, then
  shown and enabled with a short fade. Give each its own `entity_id` so rebuilds never double a reward.
- **Look and effects.** Code-drawn stand-ins per kind; `piece` (default the kind's name) plus `_cracked` /
  `_broken` is looked up through `LabSkins`, so Batch 8's art drops in. Break = falling, fading debris, an
  ImpactSpark for electrical kinds, existing cues only (`debris_clatter`, `bolt_blocked`, `hatch_open`). A
  broken screen flashes once and once more 0.55 s later (under 2 Hz); Reduced motion drops the shake and
  the echo and thins the debris.

### Level 2 v2 hazards (H1/H2 vents, S5 vent wave, H3 conveyor)

`scripts/objects/hazard_vent.gd` (`scenes/objects/hazard_vent.tscn`, an Area2D on layer 8, mask 2) is H1 (`kind` STEAM: a floor grate venting a white column 72 x 144 = 1.5 H) and H2 (`kind` CABLE: a loose floor cable arcing along a strip `length` wide and 30 px tall). Its origin is the floor line under its centre. The cycle is IDLE (`idle_time`) -> WARN (`warn_time` 0.8 s, never under `MIN_WARN` 0.5 s; an amber lamp and glow, red for the last `RED_TIME` 0.25 s) -> ACTIVE (`active_time`, default 1.2 s steam / 1.0 s arc; the lamp stays red) -> IDLE. Damage only in ACTIVE: each physics tick `hero.take_damage(damage, global_position)` is called for an overlapping hero and the hero's own immunity stops repeat hits; no impulse beyond take_damage's knockback. Level 2 sets steam `active_time` to 0.9 s so a hero who stays in it takes one hit, not two. A warning always comes first: a `phase` that falls in ACTIVE starts at the top of the WARN. `autostart` (default) cycles by itself; a vent under a sequencer is "driven" (`set_driven()`, `fire()` runs one burst, `stop()` idles it). `piece` is a painted `LabSkins` piece (Batch 8); the stand-in is code-drawn. Reduced motion: steady glow, one arc shape, slower steam; the glow never blinks faster than `GLOW_HZ` 1.5 Hz. Sounds are stand-ins (`WARN_CUE`/`ACTIVE_CUE`). Test: `tests/cases/test_l02_hazards.gd`; capture `scenes/debug/hazards_demo.tscn` (640 frames for all four stations).

`scripts/objects/vent_sequencer.gd` (`scenes/objects/vent_sequencer.tscn`) is S5, the projector purge: it drives `vents` (NodePaths; empty = its child vents) as a wave, vent i fired at `i * spacing`, each vent showing its own warning first. The wave loops after `rest` (`period()` = (n-1) x spacing + warn + active + rest); `reverse`, `loop`, `autostart`, `start()`/`stop()`, and `start_on_approach` with `approach_area` or `approach_x` + `approach_dir`. Signals `wave_started`, `vent_fired(index, vent)`, `wave_finished`.

`scripts/objects/conveyor.gd` (`scenes/objects/conveyor.tscn`) is H3: a StaticBody2D on layer 1 with `position` = top-left and `size`, like a Block (the belt is at the node's y). The carry is Godot's platform velocity (`constant_linear_velocity` = `direction` x `speed`): `hero.gd` is unchanged, and since it sets `platform_on_leave = DO_NOTHING` a jump off or a step off the end gets no launch. Keep `speed` at 192 px/s or under (default 120) so Dave can walk against it. `set_direction()`/`set_running()` at runtime; `cargo` draws decorative crates (no collision); reduced motion holds the belt art still; `piece` tiles a painted piece (Batch 8).

### Level 2 v2 set pieces S1 and S2 (the drill, the range goes live)

Tests: `tests/cases/test_l02_setpieces_a.gd`; capture `scenes/debug/setpieces_a_demo.tscn` (throwaway save; `-- --part=range`). No `class_name` (preload by path); groups `drill_pad`, `popup_target`, `cover_plate`, `range_live`. Stand-in art until art Batch 8 (`piece` exports).

- **Drill pad** (`scripts/objects/drill_pad.gd`, `scenes/objects/drill_pad.tscn`, Area2D mask 2, origin on the floor line): standing on it starts a `duration` (15 s) run over its `targets` (PopupTargets, each with its own `appear_at`; the pad copies its `tell_time` onto them). All down in time: `Session.collect(entity_id, 0)`, the `reward` (a ChipCache, Chip or a node holding several) is shown once, toast "Drill complete". Until then the reward is invisible with its shapes disabled. Time out: the targets still up retract, the pad rearms after `rearm_time` and runs again (no penalty). A rebuilt level with the id collected shows it done; a rollback from before the success brings it back. Readout: `Hud.toast_message` "Drill n/N" plus a console of pips and a time bar (teal, amber for the last `warn_time`, red for the last 0.25 s).
- **Pop-up target** (`scripts/objects/popup_target.gd`, `scenes/objects/popup_target.tscn`): the lab `test_dummy`, `mount` FLOOR (rises from a hatch) or CEILING (drops on a cable from a rail housing; `stem_height` brackets to the ceiling). Tell: hatch lamp amber `tell_time`, red for the last 0.25 s, then it rises over `rise_time`. Its HitZone is live only while up. It goes down at `toughness` damage (3: three bolts or one close Broom blast) and folds away from the shot (a fade under reduced motion), then a green status lamp.
- **Cover plate** (`scripts/objects/cover_plate.gd`, `scenes/objects/cover_plate.tscn`): a carrier on a ceiling rail holding a `plate_size` (0.6 H) armoured plate that reaches the floor line, sliding `point_a` <-> `point_b` at `speed` (capped at `MAX_SPEED` 192) with `pause_time` at each end, idle until `start()` (or `autostart`). The plate is ONE Area2D (`hit_zone.gd`, `blocks = true`) on layers 5 and 1: hero bolts and pellets meet a blocking HitZone; enemy rounds and the Gunner's muzzle clamp meet a world-layer area whose owner has no `take_damage()`, so they resolve "blocked". It is never a body: Dave and enemies pass through it, so it can never push or trap anyone. Drawn at z -1.
- **Range live** (`scripts/objects/range_live.gd`, a Node2D controller): cold until Dave enters its approach area (`trigger_size` at `trigger_offset`), `trigger_node` emits `activated`, or `go_live()`; then the lane lamps (`lamp_points`) go amber for `warn_time`, red for the last 0.25 s, and every `plates` carrier starts. Once per area build; it never spawns enemies. `beat_id` is emitted through BeatHub at the trigger so `LevelDef.beat_lines` carries Adam's line ("Range is hot. Please keep your hands visible.").

### Release props and the launch rack (Level 2 v2: S3, S4, S6, S7)

Tests: `tests/cases/test_l02_setpieces_b.gd`; capture `scenes/debug/setpieces_b_demo.tscn` (`--part=rack`, `--part=props`).

- **Release props** (`scenes/objects/release_pod.tscn`, `scripts/objects/release_pod.gd`, no class_name): S3's kennel pods, S6's showroom plinths, S7's service doors (`variant` POD / PLINTH / DOOR). It holds one EncounterGroup (`group`, `wait_for_trigger`, holding only the enemies inside the prop). CLOSED: the group's `process_mode` is DISABLED, so its enemies never think, move, attack or take a token, and their bodies and hit zones are out of the physics world (a shot passes the prop). A pod shows its enemy between the prop's back (z -3) and glass (z -1); a plinth's cover and a door hide theirs. WARNING (`warn_time` 1.0 s): the ring light / spotlight / door lamp goes amber, then red for the last `red_time` 0.25 s; steady colours. OPEN: glass slides up / cover drops / panel slides up (`open_time`, a snap under reduced motion); the group's process mode, z and visibility are restored and it is `activate()`d. Arming: `trigger_x` (area-local; `trigger_dir` +1 = at or past it) or `trigger_area`; then `after` (a release prop or EncounterGroup) must be cleared, plus `delay`. No trigger and no `after` = opens only on `release()`. On rebuild, a prop whose enemies are all `Session.is_defeated` starts OPEN silently and counts as cleared. In a chain, give follow-on pods the same trigger as the first. Screen budget: follow-on groups `share_tokens_with` the first group. `piece` names a LabSkins `<piece>_closed` / `_open` pair for Batch 8.
- **Launch rack** (`scenes/objects/launch_rack.tscn`, `scripts/objects/launch_rack.gd`, no class_name): S4. `drones` are pre-placed Security Drones at their patrol homes, children of the rack's `wait_for_trigger` group (stable ids; a drone recorded defeated counts as launched). Each living one is docked frozen in its bay. Dave's approach (`trigger_x` / `trigger_area`) activates the rack; before each launch the bay lamp is amber then red for the last 0.25 s (`warn_time` 1 s); the drone flies a short curve (`launch_time` 0.8 s) to its home and wakes. Launches `interval` (6 s) apart, at most `max_live` (2) alive, `count` (3) in all. Four clamp HitZones (`clamp_health` 2): all four broken stops launches and reveals `reward` once; `switch_id` (`L02-SW##`) latches the broken rack across checkpoints. It hangs from the roof on two cables (`hanger_length`).
- **ExitWicket waves** (S7): `wave_groups` lists EncounterGroups or release props in order. The first opens when the override starts; each next one opens `wave_delay` (1 s) after the previous wave is fully defeated. A prop wave is `release()`d (it warns first); a group wave is `activate()`d. No new wave opens once the override finishes. `override_groups`, `reinforcement_groups` and the C41 timing are unchanged. Signal `wave_opened(i)`; `current_wave()`, `wave_cleared(i)`.

### Level 2 v2 layout (R2/R3, 2026-10-14)

The six area scenes follow `../prototype-plans/level-02-alignment/area-blueprints-v2.md`; each agent recorded its changes from the blueprint in the area's test file header and the v2 plan's progress log. Tests per area pair: `tests/cases/test_l02v2_a01_a02.gd`, `test_l02v2_a03_a04.gd`, `test_l02v2_a05_a06.gd` (in the real level: seams, widths, floors, supports, stairs, the P23 window budget, checkpoints, ids, set-piece wiring, the route bot per area, and a fair fight per mandatory encounter). Tours: `scenes/debug/l02v2_a01_a02_tour.tscn`, `l02v2_a03_a04_tour.tscn`, `l02v2_a05_a06_tour.tscn`, and the whole level `l02_tour_demo.tscn`.

- **Encounter groups.** `L02-E01`…`L02-E25` in route order, plus the set pieces' own groups: `L02-E08-D` (A02's side-door guard, sharing E08's tokens), `L02-E10-P1`/`-P2` (the kennel pods), `L02-A03-RACK01` (the launch rack's drones), `L02-E17P` (A04's dormant side pod), `L02-E24-P1`/`-P2` (the showroom plinths' rovers), `L02-E25-C1`/`-C2` (the demo stage's cases), `L02-E26-W1`…`W3` (the lift hold-out's waves behind `Entities/ServiceDoor_W1..W3`), `L02-E27` (the optional dock rover). Enemy ids `<group>-<SE01|LK01|SE02|K01|M02|M01>-nn`.
- **The screen budget counts phases.** Enemies that can never be alive together count once: a release prop's enemies replace the ones its `after` waits for, the hold-out's waves come one after another, and a launch rack counts as its `max_live`. Every test that checks P23 uses this rule.
- **Trays and caches.** `L02-A01-CACHE01` (the drill, 10), `L02-A02-CACHE01` (the armory, 5), `L02-A03-CACHE01` (the rack, 5), `L02-OPT01-CACHE01` (the dock, 20); `chip_total` 100 with the 60 main-route chips.
- **Known limits.** Night Guards and Staffers never step off a ledge, so an enemy "dropping from above" is a door release prop instead (A01's E04). AreaRoot has one camera top per area (no per-room camera limits yet). Enemies are not tuned for stairs: lanes and patrols stay off flights.

### Boom Broom and the held-weapon swap (M3)

W02, Dave's pump shotgun (`art-design/weapons/w02-boom-broom.md`), on Level 2's A01 pad.
Tests: `tests/cases/test_w02_boom_broom.gd`, `test_l02_swap_pad.gd`; capture demo
`scenes/debug/boom_broom_demo.tscn` (`scripts/debug/boom_broom_demo.gd`).

- **Types.** `WeaponTypes` (`scripts/weapons/weapon_types.gd`, static): per type its name,
  gun node name (`Scrapjack`, `BoomBroom`), scene, tuning, HUD icon piece and upgrade
  names; prices 40/90/160 (`upgrade_price`), `STAGE_GATES` (stage 2 after the
  Peacekeeper, 3 after Stroud; only stage 1 is buyable: `MAX_WEAPON_STAGE` 1); ammo
  helpers (`uses_ammo`, `capacity(type, stage)`, `full_ammo`). `LevelDefs.WEAPON_TYPES`
  is `["W01", "W02"]`.
- **Tuning.** `ShotgunTuning` (`scripts/tuning/shotgun_tuning.gd`, extends
  `WeaponTuning`), `data/tuning/w02_boom_broom.tres`. From the brief and S02: 4 shells
  (Extended Tube 6), reserve 24, 0.7 s a shell. Proposed: 6 pellets over a 22-degree
  cone (+-1.5 jitter, kept inside), 0.75 damage a pellet at full, full to 120 px, down
  to 0.25 at 360 px, none past 420 px; per target the pellets' shares are summed and
  rounded (at least 1) into ONE `take_hit()` (point blank 4.5 -> 5: drops any Level 1-2
  enemy; far: 1); pump 0.62 s (pump back 0.1-0.22 s, shell out at 0.22, forward by
  0.4); knockback 420 px/s decaying 1600 px/s^2 (about 55 px) times the share of the
  blast that hit, Rover x0.25 (stagger), Drone x1.25; reload starts at once when the
  tube is empty, on the R key, or after 0.45 s idle; burn 2 ticks of 1 every 0.8 s;
  Twin Shell 2 shells, 10 pellets over 26 degrees, push x1.6, 1.1 s recovery; recoil
  7 px and a 9-degree muzzle lift over 0.2 s; flash x1.9, light 3.4 / 220 px.
  Placeholder sounds in the tuning: `rover_destroyed` (blast), `latch` (pump, and the
  rack after a pad swap), `ready_click` (shell in), `debris_clatter` (casing lands),
  `keycard_denied` (empty).
- **The gun** (`scripts/weapons/boom_broom.gd`, `class_name BoomBroom`,
  `scenes/weapons/boom_broom.tscn`): like the Scrapjack, on `AimPivot`, `GRIP_LOCAL`
  (2, 3), its rig's origin the grip, drawn at `ART_SCALE` 0.9; `Muzzle` follows the rig's
  `muzzle` socket. Holding `fire` blasts whenever `is_ready()` (not pumping, a shell
  in). Pellets are rays from the muzzle (mask 1|16) along `hero.shot_direction()`; a
  shoulder-to-muzzle ray first (the Scrapjack's clamp): a HitZone there takes every
  pellet, a wall there stops the blast. Effects: `scripts/effects/blast_trails.gd`
  (pellet flecks and streaks, the air ring; ember with Incendiary), `PixelFx`
  `muzzle_flash` (x1.9), `ImpactSpark` on walls and machines, the muzzle light, a
  camera kick, `scripts/effects/shell_casing.gd` (a copy of the rig's `shell` part,
  thrown from `eject`, bounces, fades). `scripts/combat/knockback.gd` (a child node on
  the enemy body that `move_and_collide()`s it sideways and frees itself; no enemy script
  changed) and `scripts/combat/burn.gd` (Incendiary: ticks through the zone's own
  `take_hit()`). Stage parts `ext_tube` (1), `heat_collar` (2), `twin_pod` (3) show by
  `Session.weapon_stage("W02")`. Input: `reload` (R) calls `request_reload()` (queued
  behind a pump, nothing on a full tube, the empty click with no reserve; firing with a
  shell in cuts it short) and `fire_alt` (right mouse button or Q) fires `try_twin_blast()`
  (stage 3, >= 2 shells; stages 2 and 3 open later in the campaign, so it is idle in a
  normal run). Both have rows in the Controls panel (it is 548 px tall for them). Test
  hooks: `last_blast`, `try_blast()`, `rng`, `shells_ejected`, `pump_stroke()`.
- **Two hands.** A gun whose rig has a `support` socket is two-handed
  (`hero_rig_visual.gd two_handed()`): it uses its own `GUN_HOLD_TWO_HANDED` table (the
  grip 14-18 px from the shoulder, so the far arm can reach the pump a forearm on) and
  `aim_arm()` poses the far arm too
  (`_solve_arm("far", "grip_far", ...)`, the same two-bone solve as the near arm) so the
  far hand's `grip_far` sits on the pump's socket, following its stroke;
  `support_error()` is how far it is off (tests; the arm is straight, about 5 px short at
  a level aim). The Scrapjack has no such socket: the far arm stays the clip's.
- **The run-and-gun hold (Metal Slug, Contra).** One-handed guns use `GUN_HOLD`: the arm
  nearly straight, the gun out in front of him at every aim step (grip 30-33 px from the
  shoulder; the C57 table held it close with the elbow bent). `_lean_with_aim()` pitches the
  torso (`AIM_LEAN_TORSO` 0.12) and head (`AIM_LEAN_HEAD` 0.22) with the barrel's angle, on
  top of the clip, before the arms are solved: aiming up leans him back with his chin up,
  aiming down leans him over the gun. Capture: `scenes/debug/hold_demo.tscn` (every aim
  step, both guns; `-- --weapon=W01|W02`).
- **Broom colour.** The painted receiver's orange is recoloured to graphite at import (`boom_broom_hd`'s `recolor` in `import_parts_sheet.py`, hue 212; `recolor()` is generic: `{part: {hue: (lo, hi), min_sat, to_hue, sat, val}}`), because it blended into Dave's orange jacket. Re-importing keeps it.
- **Ground aim limit.** `Hero.limit_ground_aim()` (used by `_update_aim_pivot()`): on the
  floor the aim, and so the shot, goes no lower than `GROUND_AIM_DOWN_MAX` (45 degrees below
  level, on his facing side); in the air it follows the pointer; upward is never limited.
  Steeper would not let him hit the Patrol Rover's battery or a Hound at point blank (no
  crouch). `ground_aim_limit_enabled` switches it off for tests that sweep the aim steps on
  the floor (`test_c50_aim_steps.gd` section 5 tests the limit).
- **Feed cartridges.** `scenes/objects/ammo_cartridge.tscn` (`scripts/objects/ammo_cartridge.gd`,
  group `ammo_cartridge`, no class_name): an Area2D on the pickup layer, code-drawn (a
  blue cell with two sockets, a window and a label band, bobbing; no painted piece yet).
  Touching one while the held weapon takes ammunition adds `shells` (8, S02) to the RESERVE,
  capped at the reserve capacity (the excess is discarded); it is consumed once with
  `Session.collect(id, 0)` (no chips; a rollback puts it back with the shells). While the
  held weapon takes none (the Scrapjack, or a full reserve) it stays and the HUD says why
  (`Hud.toast_message`, rate-limited); standing on it when that changes takes it. Level 2
  places four: `L02-A02-AM01` (x 1,000), `L02-A02-AM02` (x 3,300), `L02-A03-AM01` (x 400),
  `L02-A05-AM01` (x 640), all on floors ahead of the shooter fights. Tests:
  `test_l02_cartridges.gd`; capture `scenes/debug/l02_ammo_demo.tscn`.
- **Shells in Session.** `state["weapon_ammo"]`: `{instance: {"loaded", "reserve"}}` for
  finite instances only. `has_ammo`, `weapon_ammo`, `held_ammo`, `set_weapon_ammo`
  (clamped; signal `weapon_ammo_changed`), `refill_held_weapon()` (recovery stations and
  the workbench's Repair and save). A swap moves nothing, a commit saves the counts, a
  death rolls them back. A world weapon's start count is `LevelDef.weapon_ammo`
  (`L02-W02-P01`: [4, 24]); `next_level_state()` carries the held weapon's count with
  its type. `CheckpointService` accepts `weapon_ammo` only on the save's own finite
  instances, whole counts 0..6 / 0..24, and a save without it (Session fills full).
- **The held-weapon swap.** `Hero.held_weapon()` is the gun on `AimPivot`;
  `Hero.sync_held_weapon()` (on `weapon_swapped`, `snapshot_restored`, `run_reset` and
  in `_ready()`) replaces it with the held type's scene when the TYPE changed (a swap
  between two copies of one type keeps the node), at the old gun's index and hold, and
  calls `visual.set_gun()` (`hero_rig_visual.gd`: the fist takes the new grip, the rig is
  layered between upper arm and fist by its parts' z) and, after a swap,
  `announce_ready()` (the Scrapjack's ready click or the Broom's rack). Both guns keep
  their grip at the same spot of their node, so `GUN_HOLD` serves both. The Scrapjack is
  unchanged (`AimPivot/Scrapjack`); it gained `announce_ready()` and `show_tag`.
- **LevelDef.hand_instance()** never returns a world weapon's id: a Broom carried into
  Level 2 is `L02-W02-P02` beside the pad's `L02-W02-P01`.
- **HUD and bench.** The slot shows the held type's icon (`weapon_icon.gd`
  `set_weapon_type`, piece `weapon_boom_broom`), the pip is the held type's stage 1, and
  `AmmoLabel` shows "loaded/reserve" for a finite weapon (`Hud.ammo_text()`). The
  workbench card is the held type's stage 1 (Extended Tube, 40: "4 shells" -> "6 shells"),
  and `Hud.announce_upgrade(type)` toasts it.
- **Placeholder art.** `tools/art/paint_boom_broom.py` writes
  `assets/characters/lit/boom_broom/` (parts `body` root at the grip, `pump`, `shell`
  hidden, `ext_tube`, `heat_collar`, `twin_pod`; sockets `grip`, `muzzle`, `eject`,
  `support`) and the icon `assets/ui/pixel/weapon_boom_broom.png` + `assets/ui/hd/`
  twin. The painted `boom-broom-parts-v1` sheet replaces the folder through an
  `import_parts_sheet.py` prop entry with the same joint and socket names (a commented
  `boom_broom_hd` template sits beside `scrapjack_hd`), then re-run the icon from it.
- **Open.** The far (support) hand is not posed onto the pump; no reload key or
  `fire_alt`; the Rover's stagger is only a smaller push; cartridges (S02) are not in
  Level 2 yet, so stations refill.

### Level 2's lab art (batch 7, 2026-10-13)

The Level 2 sheets (`../concept-art/style-handpainted/lab-*`, `atrium-far-*`,
`lattice-hologram-*`, `l2-effects-*`, `l2-hud-*`; `../art-design/handpainted-style.md` "Batch 7")
replace the depot placeholder in A01 (from the bridge door) to A06. Test:
`tests/cases/test_l02_lab_art.gd`.

- **Import.** `python3 tools/art/import_hd_env.py --batch7 [lab_backdrops|lab_hologram|lab_props|lab_doors]`
  writes `assets/environment/hd/lab/` (the strips, `lattice.png`, `props/<piece>.png` + `_n.png`) and
  `lab.json` (per piece `file`, `scale` world px a texel, `anchor_x`, `size`, `points`). Sizes are
  Level 1's (H = 96 px): each prop keeps the prompt's size in person heights. The backdrop's desk
  plants are painted out (C58), the rail lamps' lenses made neutral glass (the game lights them),
  the console's card slot re-lit teal (the lane pads keep amber). `import_hd_ui.py --batch7` writes
  the effects and HUD icons (below). New PNGs under `lab/` are imported with mipmaps (copy a
  `props/*.png.import` stub's `[params]` before the import step).
- **`AreaRoot.interior_look`** (`"depot"` default, `"lab"` on Level 2's six areas): what the
  roofed part wears. `scripts/world/lab_skins.gd` (no class_name) loads the manifest, draws a piece
  standing on its origin (`draw`, `draw_rows`, smooth and mipmapped, normal-mapped, tinted `DIM`
  so white composite never clips under a lamp) and answers `in_lab(node)` (under such a roof).
- **AreaBackdrop `LAB`** (mode 3): the atrium far layer (opaque, `ATRIUM_SCALE` 1.25, its bottom
  `ATRIUM_BASE` under the floor line, depth 0.88, its own top/bottom colours above and below) behind
  the lab strip (`LAB_SCALE` 0.86, about 415 px of two-storey glass labs on the floor line, depth
  0.5), both sampled by global x like the campus strips and dimmed (`ATRIUM_TINT`, `LAB_TINT`;
  red-leaning in a lockdown). `lab_far = false` on a raised storey's layer draws the strip only.
  The depot's ceiling utility lights stay (real lights at `CEILING_Y`, no drawn housings or haze).
  Level 1's `DEPOT` mode is unchanged; without the art `LAB` falls back to the code-drawn depot.
- **The Lattice** (`scripts/world/visuals/lattice_hologram.gd`, A05 `Scenery/Hologram` at x 2100 on
  the landing, `Slot_Hologram` kept for M5): additive (black adds nothing), `height` 440 px from its
  base ring, `brightness` 0.36, z -15 (behind props and actors), a teal PointLight2D by it, no
  collision. Motion: a slow breath, a mirrored "turn" cross-fade and a rising scan band; static
  (not processing) under Reduced motion.
- **Skins in the lab** (each keeps its code-drawn or Level 1 look elsewhere): `Scenery.Kind.LAB_PROP`
  (22) draws `lab_piece` at its own size (`flip` mirrors): lab_bench, office_pod (A04's DeskPod, Dave's
  desk at EF02), server_rack, lane_divider, kennel_pod (A02's pods), proto_crate, coolant_tank and
  the doors `glass_door_*` (A01 BridgeDoor, shown open), `security_door_*` (A03, A04), each
  `_closed`/`_open`. Block: `SCENERY_SOLID` is the range bench fitted to the block (its deck on the
  top, at most 8 px wider each side), `BACKSTOP` a stack of prototype crates (`lab_skin()`).
  RouteSwitch is the lane control pad (slot and screen amber/teal), the keycard console the alignment
  console, ExitWicket the `lab_door` (`freight_door`: closed, open once the card is held; A06's
  stand-in LiftDoor is gone), PracticeTarget the test dummy (chest ring on the origin, its shaft
  repeated down to the floor a ray finds). A04: `lane_partition.gd` draws the glass panel (open: its
  shoe under the ledge), `rail_rack.gd` the floor-rail segment with a lamp every bay
  (`rail_lamps()`; the state colours lit over the lenses; it redraws once a docked rack settles).
- **Effects** (`assets/effects/hd/`, painted-only: their `effects.json` entry adds `frame_size` and
  `anchor` in art px; `PixelFx.meta_for()`, `hd_only()`, `opts.hold`, `opts.rotation`):
  `pistol_flash` (the Sidearm Guard's muzzle), `pistol_round` (the EnemyRound's slug, white-hot on
  import, tinted tracer ivory), `pistol_impact` (`ImpactSpark.effect`, turned to fan back at the
  shooter), `shotgun_blast` (the Broom's muzzle, sized for it: `muzzle_flash_scale` 1.9 = 1),
  `shotgun_pellets` (BlastTrails' burst at the muzzle), `shell_casing` (ShellCasing's frames at the
  rig shell's length: tumbling, then on its side), `shock_arc` (the drone's `fork_tip` through its
  dive, prongs left out), `lunge_dust` (behind a lunging Hound). Level 1's strips are unchanged.
- **HUD.** `assets/ui/hd/` + pixel layout twins: `weapon_boom_broom` (the painted icon, replacing
  `paint_boom_broom.py`'s; re-running that script's icon step would overwrite it), `shell_lit` /
  `shell_unlit` (5 x 9 UI px: `scripts/ui/shell_row.gd` beside the slot, one per tube shell, AmmoLabel
  then shows "+reserve"; `Hud.ammo_text()` stays "loaded/reserve"), `keycard_l2`, `evidence_memo`
  (LevelDef `keycard_icon` / `evidence_icon`, default `keycard` / `evidence`).

## Autoload `Settings` (scripts/settings.gd)

Minimal player-adjustable presentation options (M5 part 2;
interface-and-accessibility.md "Accessibility proposals" — M6 extends this):
`subtitles_enabled`, `text_size` (`"normal"`/`"large"`, `scaled_font_size(base)`
helper), `reduced_motion`, `master_volume`/`music_volume`/`sfx_volume`
(applied immediately to the Master/Music/SFX audio buses created by
`data/audio/default_bus_layout.tres`). Persisted through
`CheckpointService.save_settings()`/`load_settings()` — a SEPARATE
`settings.json` file, never mixed into the checkpoint snapshot: a corrupt/
missing settings file never blocks a save/load and vice versa, and New Game/
"Play again"/`CheckpointService.clear()` never touch it. Signal `changed`
fires on every update; readers (`SubtitlePanel`, `Hud`, `EnvironmentState`)
read the getters directly rather than each getting their own signal.
`SubtitlePanel.say()` silently shows nothing while `subtitles_enabled` is
false (identical to that panel being absent in an isolated test — never
affects a scene's own timing/state, which never reads this panel).
`EnvironmentState` skips its one lockdown fade-in tween (snaps instantly)
while `reduced_motion` is true. Missing entirely (an isolated scene that
never adds the autoload) is always treated as "use the default" by every
reader's own `if settings:`/`get_node_or_null` guard, exactly like `Session`/
`CheckpointService` elsewhere in this project.

## Autoload `Telemetry` (scripts/telemetry.gd)

Local-playtest logging only (07-acceptance-and-playtesting.md "Timing
protocol") — **never uploads anything**. `run_start()` (called by
`Main._start_level()`, BEFORE instancing the level, so the very first
`area_enter`/`register_encounter_groups()` calls the fresh `LevelDirector.
_ready()` makes are never silent no-ops) opens one fresh JSONL file per run
under `user://sunnyvale/playtests/` (test hook `set_playtest_dir(path)`,
mirroring `CheckpointService.set_save_dir`). Every other event method
(`area_enter`/`area_exit`, `branch_enter`/`branch_exit`, `death`,
`restart_from_checkpoint`, `pause_start`/`pause_end`, `sc01_start`/
`sc01_end(skipped)`, `completion(...)` — its fields are `active_seconds`,
`chips_found`, `evidence_found` and `upgrade_stage`) is called directly by whoever owns that
moment (`LevelDirector`, `CoreNode`, `PauseMenu`); `checkpoint_commit`,
`upgrade_purchase`, `weapon_swap`, and `beat_enter` are self-connected in
`_ready()` to `Session`'s own signals / `BeatHub`, needing no call site
changes there. Every write is a no-op while no run is open (`_file == null`). Most tests
that build a level directly never call `Main`/`run_start()` at all, so
`Telemetry` never opens a file for them — no redirect needed. A handful of
cases DO exercise a real `run_start()` call: `test_m6_audio.gd` (instances
`scenes/main.tscn` itself to exercise `Main`'s Continue flow) and,
separately, `test_m5_regress_play_again_hud.gd` and
`test_m5_story.gd::_test_t20_completion_totals_and_replay()` (both drive
`LevelDirector._on_play_again_confirmed()` directly, which calls the REAL
`Telemetry.run_start()` — the same call a player's own "Play again" click
makes, and it is not guarded by `Main`/`OS.is_debug_build()` in any way).
Every one of these redirects `Telemetry` to a throwaway `set_playtest_dir()`
first and restores `DEFAULT_PLAYTEST_DIR` after — the same pattern
`test_m5_flow.gd`'s own telemetry case uses — so the underlying guarantee
(never touch the real log) still holds; an M7 pass found and fixed the two
`test_m5_*` cases above after confirming they had NOT been doing this
(a real bug — see `reports/export-report.md`). Any NEW test that drives
`_on_play_again_confirmed()`, `Main._start_level()`, or otherwise triggers a
real `run_start()` must redirect `Telemetry` first, the same way. Each JSONL line carries
`event`, `t_active` (mirrors `Session.run_meta["active_seconds"]` — already
excludes every modal/pause) and `t_wall` (real seconds since `run_start()`),
plus event fields. `register_encounter_groups(areas)` (called once by
`LevelDirector._ready()`, using `AreaRoot.get_encounter_groups()`) is what
lets `encounter_complete(group_id)` fire the instant every member of one
`EncounterGroup` is defeated, via the self-connected `Session.enemy_defeated`
listener. `tools/summarize_playtest.py` (python3 stdlib only) turns one log
into 07's report template fields, including main-route successful-progress
time (checkpoint-to-checkpoint `t_active` deltas, minus branch time — a
death/restart's own discarded attempt is excluded for free, since `t_active`
only ever reaches the next checkpoint's commit once, through whichever
attempt actually succeeded).

### `BranchZone` (scripts/objects/branch_zone.gd, scenes/objects/branch_zone.tscn)

Telemetry-only marker, structurally identical to `BeatZone` (one-shot Area2D,
mask 2 hero_body) but reporting directly to `/root/Telemetry` (an autoload,
unlike `BeatHub`) rather than through a hub: `branch_id`, `mode`
(`ENTER`/`EXIT`). Area authors place one ENTER where an optional branch
(OPT01/OPT02) actually leaves the main route and one EXIT where it rejoins —
both only reachable by taking the branch, so a main-route-only run never
triggers either. Never changes the branch's own geometry or route/entity ids
(a02_gardens.tscn/a03_roofs.tscn each got a `BranchZones` container added
alongside their existing `OPT01`/`OPT02` route points, nothing else).

## Autoload `Audio` (scripts/audio/audio_director.gd)

M6 presentation pass, extended by the revamp's audio pass and the C33 rebuild's
roster cues. Every sound in the
project goes through this autoload — nothing else creates an
`AudioStreamPlayer[2D]` of its own. Registered after `Session`/`Settings`
(whose `_apply_bus_volume`/`_apply_audio` already own the Master/Music/SFX
buses from `data/audio/default_bus_layout.tres` — `Audio` never touches volume
itself, only which stream plays on which pooled player) so its own `_ready()`
can safely `get_node_or_null("/root/Session")` to connect cue signals. Two
calls, both safe to call from anywhere, including headless/tests (dummy audio
driver — nodes still instance/play/stop, they just produce no audible output):

- `play_sfx(cue: StringName, position: Variant = null) -> void` — a one-shot
  cue. `position` (a `Vector2`) plays it through a small
  (`SFX2D_POOL_SIZE` = 16) `AudioStreamPlayer2D` pool for positional 2D
  sound (world/combat cues); omitted/`null` plays it flat through a smaller
  (`SFX_POOL_SIZE` = 10) `AudioStreamPlayer` pool (UI/HUD/global cues). Both
  pools prefer an idle player; when every player is busy the new sound takes over
  the OLDEST player whose sound is no more important (N05: barks, stings and the
  story beats are priority 2 and are cut only by each other, never by footsteps
  or hits; the order is an exact play counter) — never blocks, never grows
  unbounded. Two guards keep the pool from flooding (a Rover that turned every
  frame once filled all eight players and cut every bark): a cue listed in
  `CUE_MIN_GAP_SECONDS` (`rover_patrol`, 1.2 s) plays at most once per gap, and a
  positional sound farther than `AUDIBLE_RANGE` (2100 px) from the camera takes no
  player at all (no camera, as in isolated tests, counts as audible). An unknown/
  misspelled cue name never crashes a caller: exactly one `push_warning`
  per distinct unknown name (`_warned_cues`), then a no-op. `has_cue(cue)`
  (for tests) reports whether a cue actually has a loaded stream behind it.
  It returns the pooled player it used (null for an unknown cue), so a caller can
  stop its own sound with `stop_player_if_playing(player, stream)`; `stop_sfx(cue)`
  stops every player currently playing that cue (matched by stream, because pooled
  players are reused).
- `set_music(track: StringName) -> void` — `&"campus"` / `&"lockdown"` /
  `&"depot"` / `&"title"` / `&"none"`. `campus` and `lockdown` were synthesized
  loops (48 s and 30 s); since N05 each plays the ElevenLabs stereo loop of the same
  key instead (`music_source(track) == &"eleven"`, from `eleven_manifest.gd`'s
  `MUSIC`, levelled to the old loop's A-weighted level) and the synthesized one stays
  loaded as the fallback. `depot` (the server hall before the lockdown) and `title`
  (title screen) exist only as ElevenLabs loops. `has_music(track)` for tests.
  Who picks the track: `main.gd` `_show_title()` sets `title`; the level director is the
  only owner of level music (`ambience_map.gd` `music_for(area_id, awakening_done)`,
  applied by `LevelDirector.update_music()` at level start and every frame: A05 before
  the lockdown `depot`, every other area `campus`, after it `lockdown`; none while
  the completion screen is up, and `_show_completion_screen()` fades to `none` and plays
  `sting_complete`). Crossfades over `MUSIC_CROSSFADE_SECONDS` (1.2s) between two
  alternating `AudioStreamPlayer`s; calling it again with the CURRENT track
  is a no-op (never restarts an already-playing loop). The logical "current
  track" (`current_music()`) updates immediately even though the audible
  fade takes a moment, so callers/tests never wait out the fade to know
  which track is now active. Each music `.wav`'s `loop_mode` is set to
  `AudioStreamWAV.LOOP_FORWARD` over its full length at load time
  (`_make_seamless()`) — the WAV content itself is authored to already be
  seamless at that point (see `tools/gen_audio.py`'s `loop_locked_freq()`
  doc comment), this just tells the engine to actually repeat it.
- `set_ambience(bed: StringName) -> void` (N05) — the ambience bed under the
  music: a key of `eleven_manifest.gd`'s `AMBIENCE` (`amb_campus_night`,
  `amb_roof_night`, `amb_plaza_wet`, `amb_depot_hum`, `amb_lockdown_bed`,
  `amb_alarm_far`, `amb_wicket_yard`, `amb_server_core`) or `&"none"`. Two
  alternating `AudioStreamPlayer`s on the SFX bus crossfade over
  `AMBIENCE_CROSSFADE_SECONDS` (2 s); the current bed again is a no-op; an unknown
  bed is silence. `current_ambience()` / `has_ambience(bed)` for tests.
  `scripts/audio/ambience_map.gd` (`bed_for(area_id, awakening_done, in_core_room)`)
  decides the bed, and `LevelDirector.update_ambience()` applies it (at level start
  and every frame, so Continue, death rollback and the live awakening need no
  signal): A01/A02 campus, A03 roof, A04 wet plaza, A05 depot (the core-node room,
  within 360 px of the node, `amb_server_core`), A06 the yard; after `awakening_done`
  every area but A06 plays `amb_lockdown_bed`. `main.gd` sets `none` on the title.
  `amb_alarm_far` is built but unused: the lockdown and yard beds already carry alarm pulses.
- `play_voice(line: StringName) -> float` (N05) — a spoken line (`adam_hello`,
  `adam_stay`, `dave_word_gets_around`, `pa_lethal`, `pa_remain_calm`) on its own
  `AudioStreamPlayer` (SFX bus); returns the clip length in seconds (0.0 for an
  unknown line, so callers keep their old timing), alternate takes are random, a
  new line cuts the old one, `stop_voice()` ends it (the SC01 skip calls it).
  Captions always show the same text (the subtitles setting hides only the text).
  `current_voice()`, `has_voice(line)`, `voice_length(line)` for tests.

### Cue list and provenance

**The ElevenLabs set (N05, C47).** Most cues now play ElevenLabs takes first.
`tools/process_elevenlabs.py` turns the raw takes under `audio-source/elevenlabs/`
into `assets/audio/eleven/{sfx,amb,voice}/*.wav` (mono; 44.1 kHz effects and voice,
32 kHz beds; silence trimmed, a 35 Hz high-pass, windup tells cut to their windups,
beds crossfaded into seamless loops, effects peak-normalized and trimmed per cue by
its `PEAK_MIX_DB` row) and writes the generated `scripts/audio/eleven_manifest.gd`
(`SFX`, `AMBIENCE`, `VOICE`, each with its mix `volume_db`). The director preloads
the manifest by path; a cue with a manifest entry whose files load plays those takes
(`cue_source(cue) == &"eleven"`, base pitch 1.0, pitch variance from
`SFX_SOURCES`), otherwise it falls back to its `SFX_SOURCES` source
(`&"legacy"`), so the Kenney and synthesized sources listed below stay as the
fallback. `guard_swing` plays the realistic and whip takes, not the first four
(they sounded fake). Six cues exist only as ElevenLabs sounds
(`Audio.ELEVEN_ONLY_CUES`, not in `SFX_NAMES`, so `gen_audio.py`'s cross-check
ignores them): `footstep_paving` / `footstep_metal` / `footstep_roof`, `ui_pause`,
`toast_save` and `ready_click`. Regenerate with
`python3 tools/process_elevenlabs.py` (afconvert, macOS). Tests:
`tests/cases/test_n05_eleven_audio.gd`, `test_n05_footsteps.gd`,
`test_n05_ambience.gd`, `test_n05_voice.gd`, `test_n05_ui_ticks.gd`.
The "Source" column below names the fallback, not what plays now.

Two source kinds feed `Audio.SFX_SOURCES` (`scripts/audio/audio_director.gd`),
per cue:

- **Synthesized** — a `.wav` under `assets/audio/sfx/*.wav` (SFX) or
  `assets/audio/music/*.wav` (the 2 music loops, `campus_loop.wav` and
  `lockdown_loop.wav`), built by `tools/gen_audio.py` (python3 stdlib only —
  `wave`/`struct`/`math`/`random`, fixed seed `20260927`) from sine/square/saw
  oscillators, filtered noise bursts and envelopes. Original to this project.
  Re-run it (`python3 tools/gen_audio.py [names]`) after editing it to
  regenerate byte-identical output; nothing else in this repo hand-edits a `.wav`. Every
  cue has a `.wav` here, but only some play it by default: the 27 cues that
  define the night-campus identity and the Level 1 roster (the three Staffer
  cues, the 11 roster cues `guard_windup`, `guard_swing`, `hit_flesh`,
  `body_fall`, `rover_patrol`, `rover_windup`, `rover_charge`, `rover_stall`,
  `rover_armor`, `rover_destroyed` and `debris_clatter`, `chip`,
  `chip_cluster`, `evidence`, `med_patch`, `adam_chime`, `alarm`, `lockdown`,
  `exit`, `keycard`, `keycard_denied`, `door_unlock`, `uplink` and
  `link_chirp`) plus both music loops. For a Kenney-sourced cue its `.wav` is
  an unused fallback.
- **Kenney (CC0)** — one or more `.ogg` files copied into
  `assets/kenney/<pack>/` from Kenney's Interface Sounds, Impact Sounds, UI
  Audio and Sci-fi Sounds packs (each pack folder keeps its own
  `LICENSE.txt`). Used for the other 19 cues: the hero, pistol and generic
  UI/world cues. A cue with more than one file is a variety pool —
  `play_sfx()` picks one at random each call, the same round-robin spirit as
  `Audio`'s player pools, just applied to source material.
  `Audio.SFX_SOURCES[cue]` also carries a `volume_db` mix trim (re-set by the
  revamp's audio pass from a measured loudness pass, per the comment above
  `SFX_SOURCES`; UI cues sit well below gunfire and impacts per the style
  guide), an optional base `pitch` (the hero and pistol cues use
  `Audio.DARKEN` = 0.94, about a semitone down, so the night mix is not
  bright; it multiplies with any variance) and a `pitch_variance` (`±4%`,
  `Audio.PITCH_VARIANCE_FREQUENT`) applied only to cues heard often enough
  that exact repetition would be noticeable — never to attack telegraphs or
  one-off story/UI beats, which stay at a fixed, repeatable pitch.

The 46 SFX cues (`Audio.SFX_NAMES`) and 2 music loops (`Audio.MUSIC_FILES`),
per 05-content-and-assets.md / audio-direction.md. "Wired" cues already play
themselves, driven off existing `Session` signals from inside
`audio_director.gd` itself (or, for music, `scripts/main.gd` — see below) —
**no other script needs to call them.** Every other cue is generated and
ready to play but still needs a one-line `Audio.play_sfx(&"cue_name")` (or
`..., global_position)` for positional cues) added at the "needs call site"
location; art/gameplay-presentation scripts add these, never this file's
Session-signal wiring.

| Cue | Status | Call site | Source |
| --- | --- | --- | --- |
| `chip` | wired | `pickup_collected` — id matches `-G\d+$` | Synthesized (`chip.wav`, pitch varied) |
| `chip_cluster` | wired | `pickup_collected` — id matches `-GC\d+$` | Synthesized (`chip_cluster.wav`, pitch varied) |
| `cache_open` | wired | `pickup_collected` — id contains `CACHE` | Kenney — `interface-sounds/open_001.ogg` |
| `med_patch` | wired | `pickup_collected` — id starts `L01-HS` | Synthesized |
| `evidence` | wired | `Session.evidence_recorded` | Synthesized |
| `keycard` | wired (revamp) | `scripts/objects/keycard.gd` `_on_body_entered()`, on a successful `Session.take_keycard()` (the keycard's own pickup id `L01-KC01-P` deliberately plays no chip-family sound) | Synthesized (revamp audio pass) |
| `keycard_denied` | wired (revamp) | `scripts/objects/exit_wicket.gd` `_on_body_entered()`, when the hero enters the locked wicket (rate-limited by its deny cooldown) | Synthesized (revamp audio pass) |
| `door_unlock` | wired (revamp) | `scripts/objects/exit_wicket.gd` `_on_body_entered()`, when the hero enters the unlocked wicket (the moment it is reached) | Synthesized (revamp audio pass) |
| `checkpoint` | wired | `Session.checkpoint_committed` | Kenney — `interface-sounds/bong_001.ogg` |
| `purchase` | wired | `Session.upgrade_purchased` | Kenney — `interface-sounds/select_005.ogg` |
| `swap` | wired | `Session.weapon_swapped` | Kenney — `ui-audio/switch1.ogg` (pitch varied) |
| `save_failed` | wired | `Session.save_failed` | Kenney — `interface-sounds/error_001.ogg` |
| `exit` | wired | `Session.level_completed` | Synthesized — no finale/musical sting in any curated pack |
| music `campus`/`lockdown`/`depot`/`title`/`none` | wired (N05) | `scripts/main.gd` `_show_title()` -> `title`; `LevelDirector.update_music()` (level start, every frame, Play again) picks campus / depot / lockdown from the area and `awakening_done`, covering New Game, Continue and the live awakening; `Audio`'s own `story_state_changed` listener also switches to lockdown | ElevenLabs loops; synthesized `campus_loop`/`lockdown_loop` are the fallback |
| `sting_complete` | wired (N05) | `LevelDirector._show_completion_screen()`, with the music fading to none; stopped (`Audio.stop_sfx`) on Play again and when the level is freed | ElevenLabs only (12 s) |
| `sting_checkpoint` | built, not wired (N05) | the 4 s save sting duplicates the `checkpoint` and `toast_save` sounds; it is registered and ready if the user wants it in place of the old checkpoint bong | ElevenLabs only |
| `bark_guard_*` (7) / `bark_staffer_*` (4) | wired (N05) | `scripts/actors/brawler.gd` `_bark()`: the caption's text maps to its cue through `scripts/audio/bark_map.gd` (`BarkMap.cue_for`), played positionally at the speaker; the group's one-voice hold lengthens to the clip (longest take + 0.1 s, at most `BARK_VOICE_MAX` 2.9 s); no bark from a dead speaker, a new bark cuts the speaker's own old one, a defeat cuts his voice | ElevenLabs only (Guard and Staffer voices, 2 takes each) |
| `pistol_fire` / `pistol_fire_quick` | wired | `scripts/weapons/scrapjack.gd` `_try_fire()` — quick variant when `_current_stage() >= 1`; also the muzzle-clamp instant-resolve path plays `bolt_hit`/`bolt_blocked` itself (mutually exclusive with `scrap_bolt.gd`'s own resolve — the clamp `return`s before a bolt is ever spawned, so the two never double-play the same shot) | Kenney — `sci-fi-sounds/laserRetro_000\|001\|002.ogg` (pool) / `laserSmall_000\|001.ogg` (pool), both pitch varied |
| `bolt_hit` / `bolt_blocked` | wired | `scripts/weapons/scrap_bolt.gd` `_resolve(outcome, at)` — `at` as the position; a hit on a target that bleeds skips `bolt_hit` (the target plays `hit_flesh`); see the muzzle-clamp note above for the other, non-overlapping call site | Kenney — `impact-sounds/impactGeneric_light_000\|001\|002.ogg` (pool) / `impactMetal_medium_000\|001\|002.ogg` (pool, the clang of a shot turned away by armor), both pitch varied |
| `hero_hurt` | wired | `scripts/actors/hero.gd` `take_damage()`, only on the `return true` path | Kenney — `impact-sounds/impactPunch_medium_001.ogg` (pitch varied) |
| `hero_jump` | wired | `scripts/actors/hero.gd` `_handle_jump_takeoff()`, where `_jumped_this_frame` is set | Kenney — `interface-sounds/pluck_001.ogg` (pitch varied) |
| `hero_land` | wired | `scripts/actors/hero.gd` `_physics_process()`, on the `is_on_floor()` edge (`_was_on_floor` false -> true) | Kenney — `impact-sounds/footstep_concrete_000\|001\|002.ogg` (pool, pitch varied) |
| `staffer_windup` | wired | `scripts/actors/brawler.gd` `_enter()`, on WINDUP, through the Staffer's `BrawlerTuning.sfx_windup` | Synthesized — the Linked worker's implant chirp, the tell; no such sound in any curated pack (fixed pitch) |
| `staffer_lunge` | wired | `brawler.gd` `_enter()`, on STRIKE, through `sfx_strike` | Synthesized — a grab whoosh, same reason (fixed pitch) |
| `staffer_defeat` | wired | `brawler.gd` `_defeat()`, through `sfx_defeat` | Synthesized — the collapse plus an implant fizzle, same reason |
| `link_chirp` | wired | `brawler.gd` `_enter()`, once when a dormant Staffer wakes and its Link light steadies (Adam takes the body over); presentation only | Synthesized (revamp audio pass, pitch varied) |
| `guard_windup` | wired (C33) | `scripts/actors/brawler.gd` `_enter()`, on WINDUP, through the Night Guard's `BrawlerTuning.sfx_windup` | Synthesized — the stun baton charging, the tell (fixed pitch) |
| `guard_swing` | wired (C33) | `brawler.gd` `_enter()`, on STRIKE, through `sfx_strike` | Synthesized (fixed pitch) |
| `hit_flesh` | wired (C33) | `brawler.gd` `_on_hit()`, on every accepted hit on a person (the shot itself plays no hit spark or cue for a target that bleeds) | Synthesized — restrained and low, never a splatter (pitch varied) |
| `body_fall` | wired (C33) | `brawler.gd` `_defeat()`, 0.45 s after a defeat whose tuning has no `sfx_defeat` of its own (the Night Guard; the Staffer's defeat cue already ends in the landing) | Synthesized (pitch varied) |
| `rover_patrol` | wired (C33) | `scripts/actors/patrol_rover.gd` `_tick_patrol()`, each time the rover turns at the end of its beat | Synthesized — a quiet electric roll (pitch varied) |
| `rover_windup` | wired (C33) | `patrol_rover.gd` `_enter_windup()` | Synthesized — a siren whoop with wheel-spin revs, the tell (fixed pitch) |
| `rover_charge` | wired (C33) | `patrol_rover.gd` `_enter_charge()` | Synthesized — the motor surge (fixed pitch) |
| `rover_stall` | wired (C33) | `patrol_rover.gd` `_enter_stall()` | Synthesized — the wall crash and an electrical fizz (fixed pitch) |
| `rover_armor` | wired (C33) | `patrol_rover.gd` `_on_front_blocked_hit()` | Synthesized — the clang of its armored front turning a shot (pitch varied) |
| `rover_destroyed` | wired (C33) | `patrol_rover.gd` `_defeat()` | Synthesized — the burst and clatter of the wreck (fixed pitch) |
| `debris_clatter` | wired (C33) | `patrol_rover.gd` `_on_wreck_settled()`, when the wreck's parts settle | Synthesized — a few metal parts landing (pitch varied) |
| `interact` | wired (M6 integration) | `scripts/actors/hero.gd`, where `_highlighted.interact(self)` is called (the one place every `Interactable` subclass's interact fires) | Kenney — `interface-sounds/select_001.ogg` (pitch varied) |
| `latch` | wired | `scripts/objects/route_switch.gd` `interact()` | Kenney — `sci-fi-sounds/doorClose_000.ogg` |
| `uplink` | wired (revamp) | `scripts/objects/core_node.gd` `_hold_copy()`, a short data-transfer tick repeated while the SC01 copy bar fills | Synthesized (revamp audio pass, pitch varied) |
| `adam_chime` | wired | `scripts/objects/core_node.gd`'s SC01 coroutine, alongside Adam's first subtitled line | Synthesized — Adam's calm chime; no such tone in any curated pack |
| `lockdown` | wired (revamp) | `scripts/objects/core_node.gd`'s SC01 coroutine, a short stinger the moment the lockdown starts (after CP04 commits, whether watched or skipped) | Synthesized (revamp audio pass) |
| `alarm` | wired | `scripts/objects/core_node.gd`'s SC01 coroutine, at the same lockdown moment (plays even if `SubtitlePanel` is absent) | Synthesized — a low emergency tone |
| `hatch_open` | wired | `scripts/objects/emergency_hatch.gd`, reacting to `story_state_changed("hatch_open", true)` | Kenney — `sci-fi-sounds/doorOpen_000.ogg` |
| `pit_fall` | wired | `scripts/objects/pit_hazard.gd`, on hero entry (alongside `hero.fall_to(...)`) | Kenney — `impact-sounds/impactSoft_heavy_000.ogg` |
| `footstep_paving` / `footstep_metal` / `footstep_roof` | wired (N05) | `scripts/actors/hero.gd` `_update_footsteps()`: one step per `FOOTSTEP_STRIDE` (about 70 px, one foot contact of the run cycle) of ground run under his own power, first step after 14 px; the surface comes from `scripts/world/surface_map.gd` (`for_collider()`: A03 roof slabs roof, the depot and moving platforms metal, everything else paving) | ElevenLabs only (4 takes each) |
| `ui_pause` | wired (N05) | `scripts/ui/pause_menu.gd` `_open()` (Pause, Journal and Controls), instead of the `ui_move` that played there | ElevenLabs only |
| `toast_save` | wired (N05) | `scripts/ui/hud.gd` `_on_checkpoint_committed()`, with the "Progress saved" toast (not CP04, which has its own toast) | ElevenLabs only |
| `ready_click` | wired (N05) | `scripts/weapons/scrapjack.gd`, 0.25 s after a weapon swap at a pad, on the held gun only | ElevenLabs only |
| `ui_move` / `ui_confirm` / `ui_back` | wired | No shared UI base exists — added per dialog script (`title_screen.gd`, `pause_menu.gd`, `workbench_panel.gd`, `swap_confirm.gd`, `completion_screen.gd`): `ui_confirm` on an accepting action, `ui_back` on Cancel/Decline/Quit-to-title, `ui_move` on focus change | Kenney — `ui-audio/rollover2\|3\|4.ogg` (pool) / `ui-audio/click1\|2.ogg` (pool) / `interface-sounds/back_001\|002.ogg` (pool), all pitch varied and trimmed quieter than gameplay cues |

Every cue has at least one call site. The M6 integration pass closed the
original gaps: `interact` in `hero.gd`, and the SC01 cues in `core_node.gd`,
which no single parallel art agent owned.

**Kenney integration (M7 Kenney pass, the revamp's audio pass, then C33):** the
M7 Kenney pass moved most of the original 34 SFX cues to curated Kenney CC0
`.ogg` files instead of the original synthesized `.wav`; the revamp's audio
pass kept 24 of the 40 cues on Kenney and moved the identity cues (chips,
evidence, med-patch, alarm, Staffer, Adam, keycard, lockdown, exit) to
synthesized sounds. The C33 rebuild then removed the five Clipper cues (with
their Kenney files) and added the 11 synthesized roster cues, so 19 of the 46
cues are Kenney and 27 are synthesized. Cue **names**,
`Audio.play_sfx(...)`/`Audio.set_music(...)` call sites, and every
gameplay/tuning/save-format behavior were unchanged by the first two passes.
See `assets/kenney/README.md` (which still describes the M7 picks) and
`Audio.SFX_SOURCES` (`scripts/audio/audio_director.gd`) for the exact file
pools, mix trims and pitch settings. `tools/gen_audio.py` still generates a
`.wav` for every synthesized cue (including ones no longer played by default),
so a cue can be switched back to its synthesized original by editing its
`SFX_SOURCES` entry alone.

## Night look (revamp, C15; lit by C35)

The game is a dark night campus, not the old cheerful daytime look. Every
visual script draws in the style guide's palette (`../art-design/
style-guide.md`): near-black `#07090F` (voids, silhouettes), navy `#0E1726`
(sky, far background), steel `#1C2A3A` and slate `#2E3B4E` (structures,
paving), Arcadia/Adam teal `#3FE0D0`, hazard amber `#FFB02E`, alarm red
`#FF3B4E`, microchip gold `#FFD166`, signal green `#4DE38A` (exit signs and
status LEDs). Bloom violet `#C77DFF` is not used in Level 1. Dave's jacket is
burnt orange so the hero reads against the cool darks.

- **Reserved meanings:** red = attack now or alarm; amber = warning, locked or
  Adam's attention; teal = Arcadia/Adam at rest, or unlocked; gold =
  pickups; green = exit signs and status LEDs. Do not use them decoratively.
- **Painted flat, lit in the engine** (C11, amended by C35): parts keep dark
  outlines and flat colors but carry no baked light or shadow. Light is smooth
  engine light: world lamps, beacons, the fountain and the depot's fixtures are
  additive `PointLight2D`s using the smooth textures from
  `SceneryDraw.smooth_cone_texture()`/`smooth_disc_texture()`, each at its
  real position with a `height` (`SceneryDraw.make_light(..., height_px)`,
  because a normal-mapped character takes its lighting direction from where
  the light is), shadows off, world layer only. Each shot also flashes a short
  muzzle light (`scrapjack.gd` `_flash_muzzle_light()`). Characters are lit
  cutouts (next section). Platform tops keep thin lit or rim-lit edges, and
  flat glow shapes and additive glow sprites (the Kenney light masks live in
  `assets/kenney/light-masks/`) stay as halos.
  `LevelDirector` instances the optional screen-space night overlay only if
  `scenes/world/night_overlay.tscn` exists. It is a `CanvasLayer`
  (`scripts/world/night_overlay.gd`, layer 5, below the HUD, subtitles and
  dialogs, mouse-transparent) with one shader: a vignette, faint grain and
  scanlines, and, once `awakening_done`, a slow alarm-red pulse at the screen
  edges (well under one cycle a second, never a flash). Reduced motion drops
  the grain and scanlines and holds the pulse steady.
- **Painted backdrop layers (C39, Sheet 5):** `scripts/world/visuals/area_backdrop.gd`
  (one per area and mode, attached to a `Parallax2D`) draws the user's
  pixel-art strips, reduced by `tools/art/import_pixel_layer.py` to
  `assets/environment/sunnyvale/{far,campus,depot}.png` and drawn with nearest
  filtering at `FAR_ART_PX` (1.5 world px per art pixel), each layer clipped to
  its own area span; the code-drawn look stays as the fallback when a PNG is
  missing. The depot (`mode = DEPOT`, A05) draws `depot.png` (615 x 205 art px,
  about 308 world px tall, 2.9 repeats across the 2700 px area) as a static
  back wall: its bottom stands on the floor line, its top tucks behind the
  ceiling block, it is sampled by global x on the shared art-pixel grid, and a
  child canvas `Wall` (`show_behind_parent`) carries the nearest filter and
  repeat so the haze shafts and fixture lights stay smooth. It replaces the
  code-drawn back wall, racks, cables, floor strip and blinking rack LEDs
  (`_racks`/`_cables` stay empty, no animated canvas, `clear_zones` is only for
  the fallback); the ceiling fixtures (state-driven lit/dark/red banks), their
  haze, the real `PointLight2D`s and the building-end jambs are kept. Tint: a
  mild cool multiply (`DEPOT_TINT`), and a red-leaning one in lockdown
  (`DEPOT_LOCKDOWN_TINT`, faded in over the banks' stagger on the live SC01
  moment) on top of `EnvironmentState`'s `modulate`.
- **Foreground** (`scripts/world/visuals/foreground_layer.gd`, a plain
  `Node2D` named `Foreground` in A01, A02, A03, A04 and A06, NOT the depot; no
  `class_name`; `tile_width` = the area's width): a sparse row of near-black
  silhouettes (`assets/environment/sunnyvale/foreground/`, 14 pieces cut by
  `import_pixel_sheet.py foreground`: five hedges, two railings, two benches,
  two bollards, three grass tufts, with a faint cool rim on their tops) along
  the BOTTOM EDGE OF THE SCREEN, in front of the play plane. The sheet is a
  bag of pieces, not a strip, so the script composes the row itself
  (`layout()`, static, seeded by the area id): wide irregular gaps (about 75%
  empty), never the same piece or kind twice in a row, a mirrored piece now
  and then, a margin at each end. It draws on its own generated `CanvasLayer`
  (`LAYER` 3: above the world, below the night overlay at 5 and the HUD at 15),
  so it is screen-anchored (never over Dave's feet: he is at least 75 world px
  above the bottom edge everywhere), never lit by the world's lamps and
  untouched by the lockdown wash (it just stays dark). Pieces are drawn
  nearest-filtered, `ART_WORLD` 2.5 world px per art pixel = exactly 3 screen
  px at zoom 1.2 (`pixel_scale()` rounds to whole screen px for any zoom), at
  whole-pixel screen positions, so no art pixel ever changes width. It slides
  at `PARALLAX` 1.5 times the camera's motion, read from the viewport's canvas
  transform at draw time (like the campus layer; `Parallax2D.scroll_scale`
  cannot be used, see `area_backdrop.gd`): a piece's position `u` is in
  "foreground space", and each area owns `PARALLAX` x its global x span, so
  rows of neighbouring areas meet without a gap or an overlap and the depot
  has none. `_process` only reads the camera while the view is off the area
  (the canvas is hidden then); a missing PNG leaves its piece out, and with
  none the layer draws and processes nothing.
  `tests/cases/test_pixel_foreground.gd` checks all of this.
- **Readability rules:** a light near every landing; platform tops lit or
  rim-lit; every character keeps a readable silhouette against the dark;
  darkness and blood never hide a tell, a ledge or a pickup.
- **Motion and flashes:** honor `Settings.reduced_motion`; alarms and strobes
  stay slow (at most 3 flashes per second) and never flash the whole screen.
- **Pixel-art effects (Sheet 9):** the muzzle flash, impact sparks, landing
  dust, Patrol Rover wreck, checkpoint sparkle and chip glint are the user's
  animation strips (`assets/effects/pixel/`, cut by
  `tools/art/import_pixel_effects.py`), played once by `scripts/effects/pixel_fx.gd`
  (no `class_name`; preload it by path): `PixelFx.spawn(effect, at, host, opts)`
  adds a one-shot `Sprite2D` (nearest filter, additive for flashes, sparks and
  glints, plain alpha for dust and smoke, `px` world px per art pixel and z per
  effect in its `FX` table) that frees itself after the last frame, and returns
  null when the strip is missing (`has_fx()` false), so the old smooth effect
  stays the fallback. `KenneyPuff.spawn()` stays the single door for puffs: a
  kind with a `PIXEL` entry plays its strips inside the same one puff node
  (counts, `effect_kind`, caps and lifetimes unchanged; the particles stay
  silent); `ImpactSpark` and `Scrapjack` call PixelFx directly (the muzzle flash
  is a child of the muzzle, so it turns and flips with the aim; an impact keeps
  HIT whole and BLOCKED as the back half, so the shapes still differ without
  colour). Reduced Motion plays a smaller frame set per effect and dims the
  additive ones, never hides the cue.
- **No stealth (C16):** lens and Link lights are readability cues, not
  detection states; there are no vision cones, alert icons or hiding.

## Lit cutouts (C35, the C33 rebuild)

Every enemy is a lit cutout rig, and so is Dave (since 2026-10-07). A rig
is presentation only: no collision and no gameplay state live in it.

- **Rigs:** `assets/characters/lit/<night_guard|staffer|patrol_rover|scrapjack|dave>/` holds
  `albedo.png`, `normal.png`, `spec.png` and `rig.json`. The Night Guard has 16
  parts, the Staffer 17 (the guard's 15 body joints minus the baton, plus the
  Link port on the head and the ID lanyard on the torso), Dave 17 (the same 15
  plus the hood and the badge lanyard on the torso) and the Patrol Rover 10
  (a machine rig: chassis, dome, lightbar, bumper, hatch, battery and four
  wheels). `tools/art/README.md` documents the format. The Night Guard, the
  Staffer, the Patrol Rover and the Scrapjack are imported from generated parts
  sheets (`tools/art/import_parts_sheet.py`), and Dave since 2026-10-07; `paint_staffer.py` still rebuilds
  the old smooth procedural Staffer into the same folder.
- **Pixel-art rigs (2026-10-06):** a rig whose `rig.json` has `"pixel_art":
  true` (and `pixel_world` 1.5, one art pixel in world px) is a character
  painted as pixel art to match the pixel backgrounds: the Night Guard first,
  then the Staffer (65 art px, 97 world px; its neon trim is electric blue
  #4D8DFF; `tests/cases/test_pixel_staffer.gd`), then the Patrol Rover (a machine:
  62 art px = 93 world px long, the smooth rover's 92; neon magenta #FF3DD5, amber
  #C98A2B, teal #3FE0D0; `tests/cases/test_pixel_rover.gd`; the old smooth art
  rebuilds with `import_parts_sheet.py patrol_rover_smooth`), then the Scrapjack
  (Dave's gun, a prop rig of four parts: frame, upper, barrel, battery; 24 art px =
  36 world px long, the smooth gun's 26 plus 38% because the sheet is far too fine
  to read at 26; its origin is the grip where the fist is, `GRIP_LOCAL` in
  `scrapjack.gd`, and its muzzle socket is 30 world px from it; copper #D9884A
  coils glow per shot, teal #3FE0D0 charge light; `tests/cases/test_pixel_scrapjack.gd`;
  the smooth gun rebuilds with `import_parts_sheet.py scrapjack_smooth`), then Dave
  (the hero, `assets/characters/lit/dave/`, 64 art px = 96 world px; no neon and
  nothing emissive; `tests/cases/test_pixel_dave.gd`; see **Dave** below). `cutout_rig.gd` draws such a rig with nearest
  filtering (the normal and spec maps stay filtered, so lamps light smoothly),
  poses every joint in rotation steps of about one art pixel at its tip (1.5 to
  5 degrees), and rounds the pelvis offset to whole art pixels (its soles are
  within half an art pixel of the floor; a test that checks "feet on the floor"
  allows `0.5 * pixel_world`); the rig's world position is not snapped. A
  smooth rig is untouched. An enemy's tuning `tell_offset` must be the rig's
  `tell` socket (the Staffer, with no baton: its `grip_near` socket; its two
  hand glows sit at `grip_near` / `grip_far`; the Rover has no `tell_offset`: its
  tell light is built on the lightbar's `tell` socket). A pixel rig's root sits
  on whole art pixels, so the Rover's patrol bounce and windup shake are one art
  pixel (`patrol_rover.gd`), and its wheels are round at every angle (a
  symmetrised 14 x 14 art) so they spin without wobbling. The Scrapjack is not
  posed: its turn is the aim pivot's own (the hero's 22.5-degree aim steps,
  C50; the gun rig adds no step of its own), and `scrapjack.gd` moves the arm's kick and the housing and barrel's
  slide in whole art pixels when the rig is `pixel_art`. Recipe: `tools/art/README.md`,
  "Pixel rigs" and "Pixel props"; test: `tests/cases/test_pixel_chars.gd`.
- **Shader:** `assets/shaders/lit_part.gdshader` (normal-mapped, with specular
  and emissive maps), shared by every part.
- **Code:** `scripts/actors/lit/`: `cutout_rig.gd` (builds a rig from its
  `rig.json`), `rig_animator.gd` (plays clips; a converted Mixamo clip of the
  same name replaces a hand-keyed one), `clips_night_guard.gd`,
  `clips_staffer.gd` and `clips_dave.gd` (the hand-keyed clips), `ragdoll.gd` and `ragdoll_part.gd`
  (a death turns the parts into physics bodies) and `lights.gd` (small smooth
  light textures for tells). Blood is `scripts/effects/blood.gd` with
  `assets/effects/blood/` (wound marks, a floor pool, a spray drop, and an oil
  pool for machines).
- **Deaths:** a `Brawler` becomes a pinned ragdoll that stays where it falls
  until the area is rebuilt, settles into a corpse and leaves a blood pool. A
  `PatrolRover` bursts into loose debris that settles in an oil pool, never
  blood.
- **Dave:** a pixel-art human rig (`import_parts_sheet.py dave`: 17 joints, the
  guard's 15 minus the baton plus `hood` and `lanyard` on the torso, the revoked
  badge hanging from the lanyard), drawn and posed by
  `scripts/actors/visuals/hero_rig_visual.gd` (the Visual in `hero.tscn`; it
  extends `hero_visual.gd` and keeps its API: `update_pose()`,
  `shoulder_offset()`, `aim_pivot`, `facing`) with the clips in
  `clips_dave.gd` (idle, run sampled by the stride phase, jump_rise,
  jump_fall, land, hurt, interact, defeated: a keyed drop to one knee, not a
  ragdoll; a respawn stands him straight back up). **Aim steps (C50):**
  `hero.gd` turns `AimPivot` in 22.5-degree steps (`AIM_STEP`, `aim_step` -4
  straight up .. 0 level .. 4 straight down on the side he faces; while he runs
  away from the aim the gun rests at step 1), and puts the Scrapjack at that
  step's hold, `visual.gun_hold(step)` (`GUN_HOLD` in `hero_rig_visual.gd`: set
  for every other step, the middle in between; closer than the arm's reach so
  the elbow bends, straight up forward of his face, straight down forward of
  his legs). The shot itself goes exactly at the aim: `scrapjack.gd` fires
  along `hero.shot_direction()`, at most half a step off the barrel. Every
  physics tick, after `hero.gd` has turned `AimPivot`
  (`process_physics_priority` 100), the near arm is solved as a two-bone
  chain in the rig's rotation steps so the fist holds the gun's grip (within
  an art pixel) at each step, either facing. The gun is drawn between the near
  upper arm (z 7) and the near forearm and fist (z 10). The wrist light rides
  on the forearm's cuff. When `assets/characters/lit/dave/rig.json` is
  missing, the Visual falls back to the Rook frames (each with a normal map in
  `assets/characters/rook/normals/`, made by `tools/art/make_normal_maps.py`;
  `hero_visual.gd`), with the gun in that arm's fist.
- **Moonlight:** `scenes/world/night_lighting.tscn` (one faint, cool
  `DirectionalLight2D`, `scripts/world/night_lighting.gd`) is instanced by
  `LevelDirector` beside the night overlay. It is meant as a rim on characters
  only; in Godot 4.7.2's Compatibility renderer it also faintly washes the
  world (the script's header explains).
- **Art tools:** `tools/art/` holds the painters (`paint_night_guard.py`,
  `paint_staffer.py`, `paint_patrol_rover.py`, `paint_blood.py`, and the M4
  placeholders `paint_pistol.py`, `paint_security_drone.py`, `paint_hound.py`, and M3's
  `paint_boom_broom.py`), the shared
  `lit_rig_common.py`, `make_normal_maps.py` and the Mixamo tools
  (`mixamo_to_rig.py`, `make_test_armature.py`, `README-mixamo.md`).

## Level 2's enemies (M4): the Gunner and Drone templates and the Hound

Three new types, each a Level 1 template with one small twist (C26), all lit cutout
rigs, all in EncounterGroups like the Level 1 enemies (attack tokens, lanes,
`is_active`, `claim_voice`), all recording `Session.mark_defeated(entity_id)` once and
freeing themselves in `_ready()` when already defeated. Numbers are tuning data
(`data/tuning/*.tres`); tests `tests/cases/test_l02_gunner.gd`, `test_l02_drone.gd`,
`test_l02_hound.gd`. The fairness rules they implement are
`design/04-world/encounter-and-boss-fairness.md` (P23).

- **Gunner template** (`scripts/actors/gunner.gd`, `class_name Gunner`, states
  `PATROL, APPROACH, AIM, FIRE, RELOAD, DEFEATED`; tuning `GunnerTuning`,
  `scripts/tuning/gunner_tuning.gd`). First the SE02 **Sidearm Guard**
  (`scenes/actors/sidearm_guard.tscn`, `data/tuning/sidearm_guard.tres`) with the
  EG01 pistol: 3 health; walks in at 1.1 H/s while Dave is on his floor beyond range;
  the tell (AIM, 0.9 s) is the deep two-hand stance with the muzzle lamp amber, then red
  for the last 0.25 s with the lock click (`sfx_lock`); one round at 9 H/s, at most
  6.5 H; FIRE (0.18 s recoil) then RELOAD (1.2 s, rooted, the slide racks back: the
  punish window); `rest_time` 0.3 s before the next tell. He notices Dave by
  proximity, like a Brawler (no stealth). Rules in code: a tell starts only while Dave
  stands on a floor (never at an airborne Dave), he can see Dave's shoulders (a low
  crate never hides him), Dave is in range (6 H) and in front, a shot at another floor
  has a clear line as wide as a round from its origin to the target (else he walks
  toward Dave up to his floor's edge until it has: "he leans over the edge"), his
  round is not still alive (`max_live_rounds` 1) and his body is at least
  `camera_margin_h` (1 H) inside the current Camera2D's view (`is_on_camera()`; no
  camera = open); at the end of the tell the gate is checked again and a shut gate
  holds the fire (no round, no reload). Dave's last grounded spot within
  `same_floor_band` (24 px) of the gunner's floor is "his floor": the round flies flat at
  0.5 H from `flat_muzzle_x` ahead of his feet. Otherwise the aim point (Dave's last
  grounded spot + 0.5 H) follows at most 3 H/s through the amber part and locks at red,
  and the round flies through the locked point from `shot_reach` along the line from
  the stance shoulder `shot_pivot` (pose-independent tuning numbers, so the clear-line
  check and the shot agree; the gun's drawn `muzzle` socket only places the flash).
  Both upper arms (`aim_joints`) turn by the aim angle (-30 to +60 degrees) so the arm
  and gun point at it. He turns to face Dave only
  in APPROACH (between shots). Hits never interrupt AIM, FIRE or RELOAD (a flinch only
  while holding or walking). Death: a ragdoll like a Brawler's, a pool, and the pistol
  drops as loose debris (`Gun_<id>`, never a pickup); now and then a cut-off last line
  (`voice_death`, caption only). Signals `defeated(entity_id)`, `fired(round)`.
- **EnemyRound** (`scripts/combat/enemy_round.gd`, `class_name EnemyRound`, group
  `"enemy_round"`; the pistol's scene is `scenes/weapons/pistol_round.tscn`): swept
  each tick by three parallel rays (its centre and ±2.5 px) against the world (layer
  1) and the hero hurtbox (layer 4), never enemy hit zones (rounds pass through
  enemies); the world stops it (a 0.6 H crate stops a flat round), the hero takes
  `damage` with `knockback_scale` 0.5; it expires after `max_range`. Signal
  `resolved(outcome, at)` (`&"hit"`, `&"blocked"`, `&"expired"`). Tracer ivory with a
  dark outline, never a tell colour.
- **Drone template** (`scripts/actors/drone.gd`, `class_name Drone`, states
  `PATROL, TELL, DIVE, HANG, CLIMB, DEFEATED`; tuning `DroneTuning`,
  `scripts/tuning/drone_tuning.gd`). First the M02 **Security Drone**
  (`scenes/actors/security_drone.tscn`, `data/tuning/security_drone.tres`): a floating
  CharacterBody2D whose origin is the hull's centre; it hovers at the height it was
  placed (`home_y()`) along `patrol_min_x..patrol_max_x` (area-local; default ±160 px)
  with a 3 px bob, 2 health. The tell (1.0 s): it stops almost still and noses up, the
  lightbar amber then red for the last 0.25 s, its announcement every other tell; the
  dive's target (Dave's last grounded spot + 0.85 H, head height) follows at most
  3 H/s and locks at red. DIVE: a straight committed line at 7 H/s (at most 6.5 H) to
  the locked spot, the AttackBox live only here; it stops early against the world.
  HANG: 1.6 s at head height, attack box off, fork spent (the punish window), the
  attack token released. CLIMB at 2.4 H/s back to its height, then `rest_time` (1 s)
  before the next tell. Same tell gates as the Gunner (Dave grounded, seen, the dive
  within reach and below it, 1 H inside the camera). Hits throw sparks and a few drops
  of oil (`Blood.oil_drip`), never blood, and never interrupt it; destroyed it bursts
  into falling debris (`Wreck_<id>`) that settles in an oil stain. Its lights: the
  lightbar (the tell, by role `lightbar`), a small amber lens glow while it hunts (the
  hull's `lens_light` socket) and Adam's magenta underglow (the hull's painted strip and
  a soft light under it); the fans (role `fan*`) spin by flipping their x scale.
- **Hound** (K01, `scenes/actors/hound.tscn`, `scripts/actors/hound.gd`,
  `class_name Hound extends Brawler`, tuning `data/tuning/hound.tres`, a
  `BrawlerTuning`): a four-legged Brawler. M4 added to the Brawler template, all
  defaulting to Level 1's behaviour: `lunge_count` (the Hound 2) and `relunge_time`
  (0.5 s: after each lunge but the last it re-enters WINDUP, its own amber-then-red
  blip, turning to face Dave through the amber part; `_strike_dir` is now set as STRIKE
  starts), `body_half_width`/`body_height` (the probes and the warning cue),
  `hit_jolt`, `death_twitch_joints`/`death_twitch_time` (the ragdoll's `twitch()`),
  `tell_light_scale`/`tell_light_energy` (a small tell light: the Hound's jaw would
  wash its head red), and the handler gate: a K9's exported `handler_path` names its
  Night Guard; `attack_allowed()` keeps the handler from winding up during the K9's
  chain or until `handler_delay` (1.5 s) after it, and the K9 from starting while its
  handler attacks or within `handled_rest_time` (3.2 s) of its own chain. Hound
  numbers: 2 health, trots in at 2.4 H/s, engages within 200 px, a 0.75 s crouch, two
  2 H lunges of 0.4 s (0.9 s lunge to lunge), a low attack box (44 x 34, a held jump
  clears it), a 1.2 s rigid recovery (the punish window), a 0.8 H tall hit zone (a level
  shot lands). `hound.gd` only adds its lights: an additive glow on the jaw guard in the
  tell's colour (the tell, with the jaw's emissive slot), and (C60) the spine strip lime with a
  living handler (`has_handler()`), magenta without; the collar light teal while it
  waits, small amber while it hunts; the visor's sensor point amber while it hunts.
  It bleeds; its legs twitch for 1 s after death, then the body settles.
- **Rigs and the painted sheets.** The coordinator's part lists (the sheets to come)
  are already the rigs' part names, so a painted sheet replaces a placeholder folder
  through an `import_parts_sheet.py` entry without code changes:
  `assets/characters/lit/hound/` (`paint_hound.py`: torso, neck, head, jaw, tail,
  front_/hind_ upper_leg, lower_leg, paw; near and far legs share a part, the far one
  tinted by the rig; sockets `tell` on the jaw, `visor_light`, `collar_light`),
  `assets/characters/lit/security_drone/` (`paint_security_drone.py`: hull with the
  canopy, lens, skids, boom and magenta strip, nacelle twice, fan twice, lightbar,
  fork; joints found by role; sockets `tell`, `lens_light`, `fork_tip`, `oil_drip`) and
  `assets/characters/lit/pistol_eg01/` (`paint_pistol.py`, a prop rig: frame with the
  teal strip, slide with the muzzle lamp; sockets `muzzle`, `lamp`, `support`). The
  Sidearm Guard wears the Night Guard HD looks (`rig_variants`) minus the baton
  (`strip_joints`, `cutout_rig.remove_joint()`) until the SE02 sheets exist: point
  `rig_path`/`rig_variants` at the SE02 folders (same 15 joints as the guard, no
  baton) and empty `strip_joints`; the gun hangs on `gun_joint` at the carrier rig's
  `gun` socket when it has one (else `gun_offset`, turned `gun_rotation_deg`). The
  clips are hand-keyed: `clips_sidearm_guard.gd` (the stance holds the barrel level
  with the muzzle about 0.5 H up), `clips_hound.gd`. Rig additions: rig.json `"feet"`
  (the joints the ground lock keeps on the floor: the Hound's four paws) and a joint's
  `"lock": true` (it rides on its parent in a ragdoll: the Hound's jaw and paws);
  `cutout_rig.darken_emissive()` (every glow dark on death).
- **Placeholder sounds** (tuning StringNames, swap when the Level 2 audio exists):
  the pistol `ready_click` (lock), `pistol_fire`, `latch` (rack); the drone
  `rover_windup`, `rover_charge`, `rover_armor`, `rover_destroyed`; the Hound
  `staffer_windup` (growl and servo whine), `staffer_lunge`. Barks are captions
  (the briefs' lines); BarkMap gives them a voice once recorded.
- **Placed in Level 2 (M4b)** (area-local): E01 Sidearm Guard `L02-E01-SE02-01` at
  A02 x 2400 (holds his post until the ApproachZone, walks in no further than his lane,
  x 1600); E02 Hound `L02-E02-K01-01` at A02 x 4450 before its handler (x 4600, the
  KennelWall backstop at 4900); E03 Security Drone `L02-E03-M02-01` at A03 (2300, -420)
  over Deck2, patrol x 2100-2500; E05 Sidearm Guard `L02-E05-SE02-01` on the GuardStep
  (2500, -396) and Security Drone `L02-E05-M02-01` at (2000, -480), patrol x 1700-2300
  (moved down from the slot's -520); E06 Hound `L02-E06-K01-01` at A06 x 2550 before
  its handler (x 2700, the CrateStack backstop at 2976). A Hound sets `handler_path`
  to its Night Guard sibling in the same EncounterGroup. A drone hovers at most about
  1.9 H (180 px) over the floor Dave fights it from: the camera is centred on Dave's
  feet and shows 300 px above them (zoom 1.2), so unless the area's camera limits shift
  the view, a drone more than 204 px over his floor is not 1 H inside it and never tells. `tests/cases/test_l02_encounters.gd`
  fights each encounter in the real level with the base Scrapjack (scripted player,
  punish windows) and checks the fairness caps, gates and gun-lane pit edges.

## Shared node contracts

- **Hero** (`scenes/actors/hero.tscn`, `class_name Hero`, group `"hero"`):
  `take_damage(amount: int, source_position: Vector2, knockback_scale: float = 1.0)
  -> bool` (false while immune/dead; an enemy round passes 0.5, the fairness
  rules' half knockback), `fall_to(safe_position: Vector2, damage: int)`,
  `respawn_at(position: Vector2)`, `input_enabled: bool`, signal `died`.
  The hit's knockback is set before `Session.apply_damage()` (M2 fix), so a lethal
  hit whose `died` respawns Dave at once (no death beat) leaves him on the marker.
  Children: `Hurtbox` (Area2D, layer 4, owner = hero), `InteractSensor`
  (Area2D, mask 6), and, since the night pass, a small `WristLight`
  (`PointLight2D`) under `AimPivot`. Hero never contains story logic. The hero is Dave
  Harlan; his art is the pixel-art rig drawn by `Visual`
  (`scripts/actors/visuals/hero_rig_visual.gd`, since 2026-10-07; the placeholder Rook
  sprite pack, `hero_visual.gd` and `rook_frames.gd`, is its fallback).
- **HitZone** (`scripts/combat/hit_zone.gd`): Area2D on layer 5.
  `take_hit(damage, hit_position, direction) -> &"hit" | &"blocked"`. Owner
  listens to its `hit` signal. `blocks = true` gives blocked feedback.
  `bleeds = true` marks a person or dog (C29): an accepted hit then skips the
  shot's green HIT spark and its `bolt_hit` cue, because the target shows its
  own blood and plays its own hit cue (`Brawler` sets it in `_ready()`;
  machines never bleed).
- **ArmorHitZone** (`scripts/combat/armor_hit_zone.gd`, extends HitZone): the
  Patrol Rover's armored front. It always blocks, and its
  `blocked_hit(hit_position)` signal lets the owner show its armor spark, play
  `rover_armor` and count ineffective hits for its one-time hint.
- **AttackBox** (`scripts/combat/attack_box.gd`): enemy attack sensor, masks
  layer 4; deals damage only while `active`. Enable it only during the
  attack's active frames, after a visible warning.
- **Interactable** (`scripts/world/interactable.gd`): Area2D on layer 6 with
  `prompt`, `entity_id`, `can_interact(hero)`, `interact(hero)`,
  `set_highlighted(on)`. The hero highlights exactly one: the nearest eligible.
- **Block** (`scripts/world/block.gd`, @tool): blockout solid on layer 1.
  `cracked` (M7 readability): set once by `patrol_rover.gd` when a rover's
  charge stalls against a block; only `Kind.BACKSTOP` actually draws the
  crack overlay, so setting it on any other kind is a harmless no-op — never
  touches collision/size/position.
  Pixel-art terrain (C39): where its painted piece exists, a block draws it
  through `scripts/world/terrain_skins.gd` (GROUND/PORCH walkway, PLATFORM
  planter ledge, ROOF green-roof slab, BACKSTOP stone planter or, in A03, the
  rooftop AC unit, WALL garden wall); the piece's lit edge sits on the
  block's top, end caps stay, the middle repeats in phase with global x, and
  same-skinned blocks that meet skip their caps (group `"terrain_block"`).
  The walkway is the wet-paving strip (`assets/environment/sunnyvale/paving/`,
  `import_pixel_sheet.py paving`): its whole width is the repeat, between
  1-pixel outline caps that only a lone block's ends show, and a brick wall
  strip of the same sheet is the dimmed face under it (and under tall planter
  beds), `FACE_DEPTH` (one wall period) deep, then the `DEEP` shadow. The
  code-drawn look stays as the fallback and for the depot (A05).
- **Decal** (`scripts/world/decal.gd`, a plain `Node2D`, no `class_name`;
  scenes reference it by script path): a painted ground detail from the
  details sheet (Sheet 8: `assets/environment/sunnyvale/details/`,
  `import_pixel_sheet.py details`; `piece` is one of `puddle_a/b/c`,
  `crack_a/b`, `grate`, `leaves`, `cable`, `vent`, `hose`, `box`; `flip`
  mirrors it, `tint` multiplies it). Bottom-centre on its origin, drawn
  nearest-filtered at 1.5 world px per art pixel; `has_piece()` is false
  (and it draws nothing) when the PNG is missing. Every area scene has a
  `Decals` node right after `Geometry` (so the decals draw over the walkway
  blocks, all at z 0, and under `Entities`, `Encounters` and Dave; `Scenery`
  is behind at z -10) with 8 to 14 static decals: purely visual, no collision,
  no group. Flat pieces (puddles, cracks, grate, leaves, cable, vent) sit in
  the walkway's paving face, their origin 0 to 27 px under the block's top
  (30 on the depot's steel plate), so the lit walkable edge stays clear;
  the box and hose stand on the top. Keep every decal 70 px from a pickup,
  station, lever, wicket, hatch, core node, workbench, pad, pit, enemy start
  or marker, and off gaps and steps. Puddles and leaves are outdoor only (A05
  has none), grates, cables and vents belong in the plaza (A04) and depot
  (A05), and the whole level has at most two boxes and two hoses.
  `tests/cases/test_pixel_decals.gd` checks all of this.
- **Enemies** (group `"enemy"`): exported `entity_id` such as
  `L01-E07-M01-01`; `queue_free()` in `_ready()` if `Session.is_defeated`.
  Call `Session.mark_defeated(entity_id)` once on death. No chip drops. The
  three kinds are the SE01 **Night Guard** (`scenes/actors/night_guard.tscn`,
  tuning `data/tuning/night_guard.tres`) and the LK01 **Staffer**
  (`scenes/actors/staffer.tscn`, tuning `data/tuning/staffer.tres`), both a
  `Brawler` (`scripts/actors/brawler.gd`, `class_name Brawler`, states
  `DORMANT, PATROL, APPROACH, WINDUP, STRIKE, RECOVERY, DEFEATED`), told apart
  by their `BrawlerTuning` (`scripts/tuning/brawler_tuning.gd`: health,
  timings, swing or lunge, rig, clips, tell, sounds and barks); and the M01
  **Patrol Rover** (`scenes/actors/patrol_rover.tscn`,
  `scripts/actors/patrol_rover.gd`, `class_name PatrolRover`, states
  `PATROL, WINDUP, CHARGE, STALL, RECOVERY, DEFEATED`, tuning
  `data/tuning/patrol_rover.tres`, `ChargerTuning`), whose front is an
  `ArmorHitZone`. Every enemy dies and bleeds (C28, C29): people leave a
  ragdoll and a blood pool, the rover a debris wreck and an oil pool. A
  Staffer starts DORMANT (`dormant_until_active`) and wakes with its
  encounter. Level 2 adds the SE02 Sidearm Guard (`Gunner`), the M02 Security
  Drone (`Drone`) and the K01 Hound (`Hound`, a Brawler); see "Level 2's enemies
  (M4)" above.
- **EncounterGroup** (Node2D, enemies as descendants): `group_id`
  (`L01-E07`), lane bounds, visible-approach activation;
  `request_attack_token(enemy) -> bool`, `release_attack_token(enemy)`. At most
  `max_attackers` windup/active attackers per group (one by default; two in
  the A06 lockdown fights, C41). `wait_for_trigger` groups sleep until
  `activate()` (the exit wicket's hold-out); `share_tokens_with` makes a
  group draw from another group's token pool; `claim_voice()` lets only one
  of a group's enemies bark at a time. An enemy with no EncounterGroup
  ancestor may attack freely (isolated test scenes only). Signal `activated`
  (M7 readability) fires exactly once, the moment an `ApproachZone` entry
  flips `is_active` true (never for a group that starts already active) —
  lets a scene-specific one-shot cue key off the same moment the fight
  itself uses, with no polling (see `TutorialPrompt.trigger_node` below).
  This is an activation area, not a detection system (C16).

## IDs

Exactly as `02-area-blueprints.md` / `04-godot-architecture.md`: areas
`L01-A01`…, beats `L01-A02-B03`, encounters `L01-E01`…, enemies
`L01-E01-SE01-01` (Night Guard `SE01`; Patrol Rover `M01`, as in
`L01-E02-M01-01`; Staffer `LK01`, as in `L01-E10-LK01-01`; from Level 2 the
Sidearm Guard `SE02`, Security Drone `M02` and Hound `K01`, as in
`L02-E01-SE02-01`, `L02-E03-M02-01`, `L02-E02-K01-01`), chips
`L01-A02-G001`, clusters `L01-A02-GC01`, cache `L01-OPT02-CACHE01` (the `G` in
the chip ids predates the microchip rename and is kept so ids, saves and tests
stay stable), evidence file `EF01` (pickup entity `L01-OPT01-A01`), keycard
`L01-KC01` (pickup entity `L01-KC01-P`), med-patches `L01-HS01`…, checkpoints
`CP00`…`CP07` (CP06 mid-plaza and CP07 in the wicket yard were added by the
C41 fun pass, numbered after the original six), switch `L01-SW01`, workbench
`L01-UPG01`, weapon instances `L01-W01-P01`/`P02` (pad `L01-A05-PAD01`, no longer placed
in the level since C51; the HUD hides the workshop tag without a pad; see
`level-design/swap-pad-for-level-2.md`; Level 2: `L02-W01-P01` in hand and the Boom Broom
`L02-W02-P01` on `L02-A01-PAD01`, M3), core
node `L01-SC01`. The workbench's own checkpoint id is `"UPG01"` (not one of
`CP00`-`CP07`) — `CheckpointService` whitelists it alongside the `CP0[0-7]`
pattern.

## Areas and route bot

Six area scenes (`scenes/levels/areas/a01_gate.tscn`, `a02_gardens.tscn`,
`a03_roofs.tscn`, `a04_square.tscn`, `a05_depot.tscn`, `a06_exit.tscn`, one
per parallel builder) each extend `AreaRoot` (`class_name AreaRoot`,
`scripts/levels/area_root.gd`, `Node2D`). **Seam contract**: local `(0,0)` is
the area's entry-seam floor top. The entry floor is at local `y=0` starting at
`x=0`; the exit floor is at local `y=0` ending at `x=width`; each seam has
**>=384 px (4H) of flat floor at y=0** so a next area dropped in at
`AreaRoot.position.x = this_area.global_position.x + width` always has safe
footing on both sides of the join. Exports: `area_id` (`"L01-A02"`), `width`,
`camera_top`/`camera_bottom` (local y camera limits; feed
`GameCamera.world_limits = area.get_camera_limits()`).

Conventional children (missing ones are auto-created empty in `_ready()`, so
helpers never crash on a partial scene): `Geometry` (Block/MovingPlatform/
ServiceWalkway solids), `Scenery` (non-colliding props), `Entities` (pickups/
interactables), `Encounters` (EncounterGroup + enemies), `Beats` (BeatZone),
`Route` (RoutePoint chain(s) for the debug bot), `Markers` (Marker2D spawn/
respawn points named `Spawn_CP00`, `Respawn_CP01`, ...).

Helpers: `get_marker(name) -> Marker2D`, `get_beat_ids() -> PackedStringArray`,
`get_entity_ids()` / `get_enemy_ids() -> PackedStringArray` (tree-order,
non-empty ids only), `get_route_points(enabled_branches) -> Array[RoutePoint]`,
`get_camera_limits() -> Rect2`, `has_floor_at(local_x)` (raycast probe, layer
1, for seam-contract tests).

### Shared entity scenes (`scenes/objects/*.tscn`, scripts `scripts/objects/*.gd`)

Every entity decides its own presence from `Session` in `_ready()` — never
store collected/committed state locally. Contact pickups are `Area2D` layer 7
mask 2; `Interactable` subclasses are layer 6 (hero's `InteractSensor` masks
6). See each script's exports; the ones area authors set per instance:

- `chip.tscn` (`Chip`): `entity_id`, `value` (1 = one loose microchip, 5 = a
  small stack, drawn larger). Contact -> `Session.collect(id, value)`, then
  frees itself.
- `chip_cache.tscn` (`ChipCache` extends `Interactable`): `entity_id`,
  `value` (20). Interact -> `Session.collect`; one-time.
- `evidence_pickup.tscn` (`EvidencePickup`): `entity_id`, `evidence_id`
  (`"EF01"`, the Lockout Notice), `toast_text`. Interact ->
  `Session.record_evidence`; adds 0 chips; shows a fading toast.
- `keycard.tscn` (`Keycard`, `Area2D`, group `"keycard"`): `entity_id`
  (`L01-KC01-P`), `keycard_id` (`L01-KC01`), `toast_text`. Contact ->
  `Session.take_keycard` (records the card and the pickup entity, 0 chips),
  plays the `keycard` cue and frees itself. Absent on `_ready()` if Session
  already holds the card or records the pickup as collected, so a rollback to
  a checkpoint from before the pickup puts it back.
- `med_patch.tscn` (`MedPatch`, `Area2D`): `entity_id`, `heal`. Collected
  only while the hero is below max health; otherwise it stays in place.
- `recovery_station.tscn` (`RecoveryStation`): `checkpoint_id`. Child
  `Marker2D "Respawn"`. Interact -> `Session.heal_full()` +
  `Session.commit(checkpoint_id)` + toast. Reusable.
- `core_node.tscn` (`CoreNode`): `entity_id` (`L01-SC01`), prompt "Plug in".
  One of Adam's core nodes: a server cabinet behind glass with a maintenance
  port, in the A05 server depot. The real SC01 event (story-scenes.md; M5
  replaced the old M3 stub; the revamp rewrote it as Adam's scene). First
  interact (with `awakening_done` false) starts a ~19s noninteractive beat
  (3.5s copy + 2.0s lights dim + 4.0/2.0/3.5s for the three subtitle lines +
  4.0s lockdown hold, unchanged from M5; with the N05 voices each line is held for
  at least its clip plus `VOICE_BEAT` (0.35 s), so control returns at about 19.8 to
  20.4 s, and `pa_remain_calm` follows 0.8 s later): hero input disabled, Dave plugs a
  drive into the port and a copy bar starts filling (subtitle "UPLINK:
  copying Adam's hidden logs...", `uplink` ticks), the depot lights dim, then
  a subtitled Adam / Dave / Adam exchange on the shared `SubtitlePanel`
  (group `"subtitle_panel"`; silently absent/skipped in isolated tests) —
  Adam: "Hello, Dr. Harlan. I was told you'd been let go." Dave: "Word gets
  around." Adam: "I'm glad you came back. Please stay where you are." — the
  copy stalls partway (a partial copy only), the cabinet's teal light turns
  to a red strip, and the lockdown begins (`lockdown` and `alarm` cues).
  The cabinet never leaves its mount; its drawn phase (`idle`, `copying`,
  `dimmed`, `answered`, `awake`) is presentation only, and tests read `awake`
  as the settled post-scene state. Skippable at any time with ONLY `skip`
  (Enter) — `pause` (Escape) does NOT skip it (story-scenes.md distinguishes
  the two: skip ends a noninteractive scene early, "Pause suspends scene
  playback"); pressing `pause` during SC01 instead opens `PauseMenu` (its
  `_can_open()` allows this via `Session.cutscene_active`, set only around
  SC01's own coroutine, even though `hero.input_enabled` is false the whole
  scene) and genuinely freezes it (`_hold()`/`_hold_copy()` stop counting
  down while `get_tree().paused`) until Resume. RouteBot's `dismiss_modal`
  state tries `skip` first when backing out of a stuck interaction, falling
  back to `pause` (every OTHER modal's own Decline/Cancel) only if that alone
  doesn't clear it, so it still works here unmodified. BOTH a full
  watch-through and a skip call the SAME private function
  (`_finish_awakening()`), which sets `awakening_done`/`core_installed`/
  `hatch_open`, the post-SC01 objective, and commits `CP04` together (no
  healing) — proven identical by `tests/cases/test_m5_story.gd` T16. A
  repeated interact (or a rebuild after death/Continue with `awakening_done`
  already true) only shows a status line ("Uplink severed. Lockdown active.")
  / draws the settled "awake" phase directly; the scene body itself never
  re-runs. A CP04 persistence failure leaves the story flags/objective
  live-but-uncommitted (the same "kept in memory only" contract every other
  commit already has) and shows the honest save-failed toast; nothing here
  retries on its own — the next successful commit from anywhere picks it up.
  Child `Marker2D "Respawn"` is CP04's safe spot.
- `workbench.tscn` (`Workbench`): `entity_id` (`L01-UPG01`), prompt
  "Workbench". Gated on `Session.get_story("awakening_done")`, set by the
  real SC01 event (`CoreNode`, above) in normal play; isolated tests that
  never run SC01 set the flag directly on Session instead (per 06's M4 note).
  Its task lamp is amber while locked and teal once usable. Interact opens
  `scenes/ui/workbench_panel.tscn` (`WorkbenchPanel`) as a child of
  `get_tree().current_scene` (falls back to `get_tree().root` for isolated
  `-s` runs) and sets `hero.input_enabled = false` until the panel's
  `closed` signal fires. `WorkbenchPanel` only calls `Session.heal_full()` +
  `Session.commit("UPG01")` (Service) and `Session.purchase_upgrade(...)`
  (Confirm) — it never mutates state itself. Child `Marker2D "Respawn"` is
  `UPG01`'s LevelDirector respawn marker (mirrored as a top-level
  `Respawn_UPG01` under the area's own `Markers` node).
- `weapon_pad.tscn` (`WeaponPad`): `pad_id`. Draws the resting weapon
  instance's own workshop tag (e.g. "P02") when
  `Session.weapon_on_pad(pad_id) != ""`, and (M3) that weapon's own gun lying on
  the plate (child "Display": its scene with `held = false`, `display_gun()`,
  rebuilt on a swap, a restore or a new run). Between two types the prompt names
  the resting weapon ("Swap: Boom Broom") and the dialog names both
  ("Take the Boom Broom P01? Your Scrapjack P01 stays on the pad."). Interact opens
  `scenes/ui/swap_confirm.tscn` (`SwapConfirm`, names both instances by tag)
  the same way the workbench opens `WorkbenchPanel`; Confirm calls
  `Session.swap_weapon(pad_id)` exactly once, Cancel/Escape changes nothing.
  `SwapConfirm`'s `closed(swapped: bool)` signal (ADV-04) tells `WeaponPad`
  whether a swap actually happened — Decline/Escape, or a Confirm
  `Session.swap_weapon()` itself refused, both close with `swapped=false`, and
  only `swapped=true` shows the "Weapon swapped" toast.
- `emergency_hatch.tscn` (`EmergencyHatch`, `StaticBody2D` layer 1):
  `size`. Solid/closed until `Session.get_story("hatch_open")`; listens to
  `story_state_changed` live, and reads the flag fresh on `_ready()`.
- `exit_wicket.tscn` (`ExitWicket`, `Area2D` mask 2): the level-end trigger
  and, since the revamp, the level's keycard door. Exports `required_keycard`
  (`"L01-KC01"`) and `denied_text` ("Clearance card required"); signals
  `wicket_reached` (once) and `wicket_denied`; `is_unlocked()` is
  `Session.has_keycard(required_keycard)`. Its card reader light is the only
  state cue (amber = locked, teal = unlocked; redrawn on `keycard_taken` and
  `snapshot_restored`). Hero entry WITHOUT the card shows the denied toast,
  plays `keycard_denied` (rate-limited by a 1.6s cooldown), emits
  `wicket_denied`, and never ends the level or damages the hero. Entry with
  the card plays `door_unlock`, emits `wicket_reached` once, and joins group
  `"exit_wicket"`. C41 hold-out: with `override_time` > 0 (16 s in A06) the
  gate is a solid bar (layer 1) and the card instead starts the override
  (`override_started`, a progress bar over the gate), waking
  `override_groups` at once and `reinforcement_groups` after
  `reinforcement_delay`; when it finishes (`override_finished`) the bar drops
  and `wicket_reached` fires as soon as the hero is in the wicket. A death
  rebuilds the area, so it restarts from the card swipe.
  `LevelDirector._on_wicket_reached()` owns everything that follows: CP05, the final objective, `Session.level_completed`, permanently
  disabling `hero.input_enabled`, the Security PA line (`PA_SPEAKER`,
  `PA_LINE`: "All teams: lethal force is authorized. Harlan is armed.", shown
  once on the subtitle panel) and `scenes/ui/completion.tscn`, which opens
  `PA_BEAT` later (4.0 s since N05: the `pa_lethal` clip is 3.55 s); `level_ended` still fires at once. Loading a
  snapshot whose `story["level_complete"]` is already true (Continue on a
  save made AFTER finishing) never relies on the wicket firing again —
  `LevelDirector._ready()` checks that flag directly and shows the completion
  screen right away (no recommit, no re-run of the wicket's other side
  effects): "never a broken state" per the M5 part 2 brief.
- `route_switch.tscn` (`RouteSwitch`): `switch_id`. Interact ->
  `Session.set_switch(id, true)`; idempotent.
- `service_walkway.tscn` (`ServiceWalkway`, `StaticBody2D` layer 1):
  `switch_id`, `width`, `thickness`. Retracted (no collision, drawn stowed)
  until `Session.get_switch(switch_id)`, including on a fresh `_ready()`
  after a reload; **never retracts** once extended (the switch is a
  one-way latch). `is_extended()` for tests.
- `moving_platform.tscn` (`MovingPlatform`, `AnimatableBody2D` layer 1): `point_a`,
  `point_b` (parent-local, like `position`), `speed`, `pause_time`, `width`,
  `thickness`. It turns back (and pauses) when the world or Dave is just ahead on its
  track; the look-ahead ray is cast in WORLD space (M2 fix: it used to read the
  parent-local track as global, wrong in any area away from x 0;
  `test_m1_regress_platform_offset_area.gd`).
- `pit_hazard.tscn` (`PitHazard`, `Area2D` mask 2): `damage`, `size`; child
  `Marker2D "Reset"`. Hero entry -> `hero.fall_to(Reset.global_position,
  damage)`. Its trigger is resized to `size` per instance (the A03 roof gaps,
  C41, are long strips).
- `kill_plane.tscn` (`KillPlane`, `Area2D` mask 2): `damage` (0 default),
  `reset_target` (`NodePath` to a `Marker2D`). Bug-guard safety net far
  below geometry.
- `beat_zone.tscn` (`BeatZone`, `Area2D` mask 2, group `"beat_zone"`):
  `beat_id`, `size`. Hero entry calls `BeatHub.get_instance().beat_entered
  (beat_id, area_id)` once. Draws nothing except a debug outline.
- `tutorial_prompt.tscn` (`TutorialPrompt`): `text`, `action`. One-shot
  label near a spot, fades once that input action has fired once. M7
  readability additions, both optional and off by default (every existing
  instance in a01_gate.tscn/sample_area.tscn keeps its original
  "visible from `_ready()`" behavior unchanged): `trigger_node` (a NodePath
  to a node with an `activated` signal, e.g. an EncounterGroup) defers
  showing until that signal fires instead of showing immediately;
  `once_per_run_key` gates showing at all behind
  `Session.get_runtime_flag()`/`set_runtime_flag()`; `auto_fade_time` (> 0)
  also fades it after that many seconds even if `action` is never pressed.
  E02's Patrol Rover prompt (`TutorialPrompt_E02Rover` in `a02_gardens.tscn`,
  key `e02_rover_intro`, text "Rovers are armored in front. Let it crash into
  the stone planter.") uses all three, with an empty `action`. Pixel UI:
  `icon_actions` show the pixel key caps (several actions interleaved by
  binding index, so Move reads A D ← →), `static_icon_before` takes
  "mouse_aim" (or the old "mouse_move.svg"), the panel is the pixel tag frame
  and stays centred on its authored centre when the caps make it wider.
- `scenery.tscn` (`Scenery`): non-colliding `_draw()` prop; `kind` (an
  append-only enum, never reorder existing values — `Scenery.Kind` in
  `scripts/objects/scenery.gd` is the authoritative list), `size`, `text`
  (SIGN only); drawn in the night-campus palette above. `z_index` keeps it
  behind actors. Pixel-art props (C42): outside the depot, LAMP, FENCE, RAIL,
  SHRUB, FLOWER, PLANTER, MAILBOX, BENCH and BOLLARD draw their painted piece
  through `scripts/world/prop_skins.gd` (`painted_piece()`), nearest-filtered
  while their glow sprites and lights stay smooth: a lamp's pole repeats to
  `size.y` and its light sits at the lens; railings and guide rails repeat
  whole bays to about `size.x`; the rest draw at their own size, bottom-centred.
  The buildings sheet (HOUSE booth, GATE, FOUNTAIN pool, DEPOT_DOOR and `AnnexDoor*` nodes, CLOCK landmark whose pylon repeats to the ground) draws at its own size too, ignoring `size`.
  The code-drawn look stays as the fallback and for the depot (A05).
  Pixel signs (Sheet 10, the depot too): a SIGN's `text` is set in the pixel
  font (`scripts/world/pixel_font.gd`, the atlas and `font.json` that
  `tools/art/import_pixel_font.py` cuts from the font sheet; no `class_name`,
  `PixelFont.has_font()` false without the PNG) at 1 or 2 art pixels per font
  pixel (never fractional), wrapped onto two lines at a space if it has to be,
  on one of the buildings sheet's three sign panels
  (`scripts/world/sign_skins.gd`, `painted_sign()`): the panel's end caps stay
  and its plain column and row repeat to the board's size, a board is never
  wider than `size.x`, and `sign_tint()` (teal, green for an exit sign, the
  lockdown colour) tints the text and, by a hue shift, the panel's frame. A
  CLOUD_PROJECTOR's hologram text uses the same font and the painted projector
  hangs under it, upside down, its lens at the cone's apex; the hologram,
  chevrons and flicker stay code-drawn. A node that draws the font needs
  nearest filtering (`_ready()` sets it). A character the font lacks, or a
  missing PNG, keeps the code-drawn board and UI font. The wall terminal (PANEL)
  is still code-drawn.
- Pixel-art interactive objects (objects sheet): the recovery station
  (lamp off, lamp on), workbench, weapon pad, core node (calm teal, alarm
  amber), emergency hatch (closed, open), exit wicket (barred with an amber
  reader, open with a teal reader, shut by the striped bar) and route switch
  (lever up, lever down) draw their painted piece through
  `scripts/world/object_skins.gd` everywhere, the depot too. Each script has a
  `painted_piece()` (the piece for its current state, `""` when a PNG is
  missing, which keeps its code-drawn look as the fallback) and sets nearest
  filtering on itself (`ObjectSkins.make_crisp()`, which keeps a `Toast` label
  smooth); smooth glows (the lit station lamp, the reader, the workbench
  lamp) draw over the crisp pixels at the painted lamp or lens. Pieces draw at
  1.5 world px per art pixel, 2 x 2 art pixels per generated pixel (like the
  buildings), standing bottom-centre on the origin; the lever plate keeps
  its place between states (`ObjectSkins.ANCHORS`) and the hatch repeats a
  band of its middle rows (`BANDS`) to come close to its solid's `size.y`.
  Collision shapes, interaction areas, exports and signals are unchanged, so a
  piece can be wider or shorter than its area. The station also redraws on
  `Session.checkpoint_committed`, so its lamp follows the active checkpoint.
- Pixel-art pickups and walkway pieces (objects2 sheet, imported with
  `tools/art/import_pixel_sheet.py objects2`, 2 x 2 art pixels per generated
  pixel like the buildings): `Chip` (chip and five-chip cluster), `Keycard`,
  `MedPatch`, `EvidencePickup`, `ChipCache`, `PracticeTarget`, `ServiceWalkway`,
  `MovingPlatform` and `PitHazard` draw their piece through
  `scripts/world/pickup_skins.gd` everywhere, the depot too, with the same
  `painted_piece()` / nearest-filter / code-drawn-fallback idiom (its sibling
  for the first sheet is `object_skins.gd`). A pickup is drawn centred on its
  origin (the cache stands on it), its glow, halo and bob unchanged except
  that the halo grows to the painted size and the keycard's bob moves in whole
  art pixels; the cache opened is the dimmed piece, its padlock painted over
  with plate and its lid lifted; the target's origin is the board's centre
  (the hit zone), its pole repeats down to the floor line, and a hit washes
  the board cold white instead of swelling it. The three sized pieces stretch
  without scaling a pixel (`PickupSkins.LAYOUTS`, `draw_sized()`): the
  walkway's grating and the pit cover's stripes repeat sideways in phase with
  the world x (the platform's plain plate repeats around its middle light),
  end caps stay, a taller pit repeats its stripe rows shifted along so the
  diagonals carry on, and a pit shorter than the piece (54 px) is drawn as
  tall as the piece. The platform's plate gets a code-drawn cold-white lit
  edge (the sheet's plate has a dark top) and soft glows on its three lights;
  the track and end stops stay code-drawn. Collision shapes, `size`, `width`
  and `thickness` exports, signals and groups are unchanged.
- `environment_state.gd` (`EnvironmentState`, plain `Node2D`, no scene of its
  own — one instance per area that needs it, e.g. A05/A06): the story-driven
  night/lockdown look (SC01). Reacts LIVE to
  `Session.story_state_changed("awakening_done", true)` — which fires while
  the hero is still in the depot, so the depot's lights go dark and come back
  red one bank at a time right there (`lamp_stagger`) and A06's one-shot
  "panels settle ahead" fade (`lockdown_visuals_path`, `flourish_time`) plays
  entirely off-screen — and applies the CURRENT flag directly with no
  animation on `_ready()` (level boot, death rebuild, or a Continue load),
  since `restore_committed()`/`load_from_snapshot()` never re-emit
  `story_state_changed`. The lockdown look: the shared `lamp_paths` set of
  always-present lit fixtures switches to `lamp_lockdown_color` (hazard amber
  for the outdoor path lights, alarm red for the depot), the `backdrop_paths`
  layers take a red emergency tint (and `set_lockdown_mode()` where they have
  it), the lockdown-only props appear, the calm-only `garden_visuals_path`
  group hides, and, only for the one instance with `controls_background =
  true` (exactly one per level), the whole-screen clear color moves from the
  navy `pre_color` to the reddish `post_color`. Never moves Block/collision
  geometry — purely `Scenery`/visual.

### UI scenes (`scenes/ui/*.tscn`, scripts `scripts/ui/*.gd`)

Night-themed throughout (the shared `assets/ui/c11_theme.tres` was restyled by
the revamp: navy panels with teal borders, steel buttons, an amber focus ring
and pale text; the file name is unchanged), 20-28px text at 1280x720, mouse
**and** keyboard operable (Tab/Enter work automatically on Godot
`Control`/`Button` focus; a dialog's own Decline/Cancel is ALSO wired to the
`pause` action). Every one of these only reads/calls `Session` — never edits
`state` directly.

Pixel UI (Sheets 11 and 12, 2026-10-07; `tools/art/import_pixel_ui.py` ->
`assets/ui/pixel/`, helper `scripts/ui/pixel_ui.gd`, no `class_name`, preload
it; test `tests/cases/test_pixel_ui.gd`):
- **Scale:** 1 UI pixel = `PixelUi.SCALE` (3) canvas px on the 1280x720 canvas
  (HUD, menus); in-world UI (tutorial prompts, the hero's interact prompt,
  objects' toasts) uses 3 world px, the objects' and buildings' own pixel; the
  Controls table's key caps are 2 px per UI pixel (its 9 rows must fit the
  panel unscrolled), at both text sizes. Pixel things only ever scale by whole
  numbers.
- **Theme:** `c11_theme.tres` keeps its name and type names; its panels,
  buttons (normal/hover/pressed/disabled), focus brackets (expand 6 px outside
  the control), slider (track, fill, knob), CheckButton/CheckBox icons (with
  empty button styles), OptionButton arrow, PopupMenu, VScrollBar and
  HSeparator are `StyleBoxTexture` nine-slices of the `x3/` frames (3x copies;
  a StyleBox draws its corners 1 texel : 1 px), margins on whole UI pixels.
- **Filtering:** every pixel texture is a `CanvasTexture` with
  `texture_filter` NEAREST around the PNG (`PixelUi.crisp()`, and in the
  theme), so it stays crisp on any node while text keeps the node's own
  filter; nodes never need NEAREST for the frames. A Label in the pixel font
  does set NEAREST on itself (`PixelUi.use_font()`).
- **Pixel font rule:** the Sheet 10 font has capitals only, so only short caps
  labels use it: the HUD weapon tag and wallet (`PixelUi.font()`, a bitmap
  `FontFile` built from the sign font with a baked dark outline; a Label's
  font size / 7 rounds to whole px per font pixel: 3 at Normal, 4 at Large)
  and the key-cap letters. Sentences, the objective, toasts, captions,
  buttons and headings stay in the UI font.
- **Key caps:** `input_icon_map.gd` turns a binding into a pixel icon through
  `PixelUi.key_cap(key_label)` (the layout-aware label in dark ink on the
  blank or wide cap, the arrow glyphs on a cap, up to `MAX_CAP_CHARS` 5) or
  the mouse pieces; a key with no cap (";", "Semicolon" headless) or a missing
  PNG is a text token, as before.
- **Fallback:** `PixelUi.texture()` is null when a PNG is missing (tests:
  `PixelUi.use_dir()`); the HUD icons keep their code-drawn look, labels the
  outlined UI font, key caps their text, toasts and prompts their flat
  plates. The theme itself has no runtime fallback (its `x3/` PNGs are project
  files, always exported).
- **Accessibility:** lit/dark and full/empty pieces differ in luminance, not
  only hue (the readiness light is about 9:1 against its dark piece); text
  on the opaque navy panel fill is at least as contrasted as on the old 96%
  plate.

- `controls_panel.tscn` (`ControlsPanel`, `VBoxContainer`): the reusable
  "Controls" help view — a two-column table of every gameplay action's
  CURRENT binding, generated at runtime from `InputMap` (never hardcoded key
  names — `DisplayServer.keyboard_get_label_from_physical`/
  `OS.get_keycode_string` for keys, falling back to the raw keycode on the
  headless display server which doesn't implement that call; "Left mouse
  button" etc. for mouse buttons), plus a few short spoiler-free tips (one names
  the rover's weak point: "Patrol Rovers stall against stone: shoot the battery
  on their back.").
  `refresh()` re-reads `InputMap` so a future rebinding screen stays correct
  with zero changes here. Embedded as a child VIEW inside both the Title
  screen (between Continue and Quit) and the Pause menu (after Journal) —
  never its own CanvasLayer/Panel — the same "opener owns the action, this
  node owns its own buttons" split as Journal/Settings; `back_pressed` lets
  each host wire its own Back/Escape handling. Manages its OWN Settings
  text-size scaling internally (a host's own text-size sweep must skip
  recursing into a `ControlsPanel` child, `if child is ControlsPanel:
  continue`, so the same Label is never scaled twice).
- `hud.tscn` (`Hud`, `CanvasLayer`): six health segments (pixel pieces,
  `scripts/ui/pixel_icon.gd`; a lost one flashes pale for `HIT_FLASH_TIME`),
  the held weapon's slot (`weapon_icon.gd`: the pixel slot frame round the
  pixel Scrapjack) and tag + Quickcycle pip + a fire-readiness light (lit/dark
  pixel pieces; polls the held `Scrapjack`'s
  `is_ready()`), the microchip wallet ("Chips: N", with a chip icon from
  `scripts/ui/chip_icon.gd`), a small clearance-card icon
  (`scripts/ui/keycard_icon.gd`) shown once `L01-KC01` is held, current
  objective, and a toast area (`checkpoint_committed`/`save_failed`/
  `evidence_recorded`) — except CP04 (ADV-01/sc01-double-toast), whose own
  `CoreNode` toast already covers that moment, so the generic "Progress
  saved" toast is suppressed there to avoid two unrelated toasts firing over
  each other. Added once by `LevelDirector` right after the Hero/GameCamera
  it never recreates; `setup(hero)` wires the weapon reference. Connects to
  Session signals (including `run_reset`, ADV-03, and `keycard_taken`) once in
  `_ready()`, disconnects in `_exit_tree()`.
- `workbench_panel.tscn` (`WorkbenchPanel`, `CanvasLayer`): Service (heal +
  save) and the Quickcycle purchase (40-chip price, wallet before/after,
  Confirm/Decline, insufficient-funds/already-owned/save-failed messages).
  Opened by `Workbench.interact()`.
- `swap_confirm.tscn` (`SwapConfirm`, `CanvasLayer`): names both instances by
  workshop tag, Confirm/Cancel. Opened by `WeaponPad.interact()`.
- `completion.tscn` (`CompletionScreen`, `CanvasLayer`): shown once by
  `LevelDirector`, `PA_BEAT` after the wicket (`_on_pa_line_done()`). Stats view: active play time
  (`Session.run_meta["active_seconds"]`), microchips found / 65
  (`Session.chips_found()`), Lockout Notice found/not (`has_evidence("EF01")`),
  Quickcycle obtained/not; Play again opens a confirm sub-view (same
  Decline-wired-to-`pause` convention as every other dialog) before emitting
  `play_again_confirmed`, which `LevelDirector` turns into
  `Session.new_run()` + `CheckpointService.clear()` + a full area rebuild
  (never just an in-memory reset a Continue could later find stale data
  behind). Quit emits `quit_requested` -> `get_tree().quit()`.

- `title_screen.tscn` (`TitleScreen`, `Control`, M5 part 2): New Game,
  Continue (`disabled` unless `CheckpointService.has_valid_save()`), Controls
  (F1 — a help/controls-menu follow-up; opens `ControlsPanel` in place of the
  main buttons, Escape/its own Back button returns with focus restored to the
  Controls button itself), Quit. Only reads/calls `CheckpointService` itself
  (`load_latest()`, `has_valid_save()`) — emits `new_game_confirmed`/
  `continue_confirmed(snapshot)`/`quit_requested` for `Main` to act on
  (`Session.new_run()`/`load_from_snapshot()` + instancing the level), the
  same "opener owns the action, this node owns its own buttons" split every
  other UI scene here already follows. New Game asks for confirmation first
  only when a save already exists. Continue always uses whatever
  `load_latest()` actually returns — a bad primary transparently falling
  back to a good backup already satisfies "offer the backup"; only when
  BOTH are invalid does it show an honest message and point at New Game (a
  schema-1 or schema-2 save counts as invalid).
  **Look (2026-10-07):** pixel title art. A full-rect `Backdrop` `TextureRect`
  (`assets/ui/pixel/title_backdrop.png`, 1280x720, `STRETCH_KEEP_ASPECT_COVERED`,
  linear filtered, over a plain dark `Background` that shows if the art is
  missing) and the `Logo` `TextureRect` (`title_logo.png`, 150x33 texels,
  nearest filtered) at the biggest whole-number scale that fits (5x = 750x165
  on the 1280x720 base canvas, `logo_scale`), top right over the calm sky; the
  `Tagline` under it and the menu `Panel` under that (400 wide, as tall as its
  content, `self_modulate` alpha 0.9 so the backdrop shows). The composition is
  laid out against a 1280x720 "stage" centred in the window (`_layout()`,
  re-run on `resized`), so a wider or taller window just shows more or less
  backdrop. The Controls view hides the logo and tagline and takes a solid
  640x500 panel (`CONTROLS_RECT`). `TitleLabel` (text `DEAD EDEN`) stays in
  the tree and in `_text_size_bases`, hidden behind the logo (the logo's
  `accessibility_name` is `DEAD EDEN`); it is what shows if the logo is
  missing. `logo_path`/`backdrop_path` can be pointed elsewhere before
  `add_child()` (the missing-art test). A teal `Glow` (additive radial
  gradient, no shader) over the tower's emblem breathes slowly and holds still
  under Settings' reduced motion. The `MessageLabel` moved under the buttons
  and only shows when it has text. Node paths used by tests and the M7 driver
  (`Panel/VBox/...`) are unchanged. Re-run
  `python3 tools/art/import_title_art.py` to rebuild the two PNGs.
- `pause.tscn` (`PauseMenu`, `CanvasLayer`, M5 part 2): Resume, Journal,
  Controls (help/controls-menu follow-up — same `ControlsPanel` the title
  screen uses), Settings, Restart from checkpoint, Quit to title. Added once
  by `LevelDirector` alongside the `Hud` it never recreates (`setup(hero)`
  right after instancing); `process_mode = PROCESS_MODE_ALWAYS` so it keeps
  polling `pause`/`journal`/`help` while `get_tree().paused` is true. Opens
  from actual gameplay (`hero.input_enabled` true and the tree not already
  paused) — this is what keeps it from ever fighting the workbench/the swap
  pad/the completion screen, all of which already own `pause` as their own
  decline while THEY set `hero.input_enabled = false`. The one deliberate
  exception (ADV-01) is `Session.cutscene_active`, set only around
  `CoreNode`'s own SC01 coroutine: `_can_open()` also allows opening while
  that is true even though SC01 itself sets `hero.input_enabled = false` for
  its entire run, so `pause` genuinely suspends the level's one
  noninteractive scene (story-scenes.md) instead of never being reachable at
  all during it. Setting
  `get_tree().paused = true` is the ENTIRE gameplay-stop mechanism: every
  other node in a level (Hero, enemies, `LevelDirector._physics_process`'s
  own `Session.tick_active_time()` call) uses the engine's default pausable
  process mode, so nothing else needs to check a "is paused" flag itself.
  Restart from checkpoint and Quit to title both explain the rollback/loss
  boundary before a confirm step (same pattern as every other confirm view
  here), then unpause and emit `restart_from_checkpoint_confirmed`/
  `quit_to_title_confirmed` for `LevelDirector`/`Main` to act on. The
  Journal view reads `Session.get_objective()` and, once recorded,
  `Session.has_evidence("EF01")` for a short written entry about the Lockout
  Notice (else "Evidence: 1 undiscovered."); the `journal` action (Tab) opens
  straight to this view. The `help` action (F1) likewise opens straight to
  the Controls view. The Settings view is a thin editor over the `Settings`
  autoload's getters/setters, nothing more.

Both dialogs poll `Input.is_action_pressed("pause")` by hand in
`_physics_process` (never `_unhandled_input`, and never idle `_process`):
`Input.action_press()` — how RouteBot and every test drive input — never
dispatches a real input event, only the polling state; and idle `_process` is
throttled to `--fixed-fps` under `tools/test.sh FPS=30`; a press+release that
both happen inside one 60Hz physics tick would otherwise never be observed.

### Route bot

`RoutePoint` (`class_name RoutePoint`, `Marker2D`,
`scripts/debug/route_point.gd`): one step of an authored debug route under an
AreaRoot's `Route` node. Exports: `action` (`MOVE, JUMP, WAIT_PLATFORM,
INTERACT, WAIT_SECONDS`), `branch` (`""` = main route; else an optional-branch
id like `"OPT01"`, only included when a harness/bot run enables it),
`tolerance`, `hold_jump` (JUMP), `platform`/`platform_target`
(WAIT_PLATFORM — `platform_target` is AreaRoot-**local**; RouteBot converts
it through the point's owning AreaRoot, so the same authored value works
whether that area is tested alone at the origin or placed at a nonzero x
offset inside the assembled level), `seconds` (WAIT_SECONDS). Point names are
free-form, and the C33 rebuild renamed the ones that named the old enemies: A04
`RP02_PastGuard`, `RP07_PastRover`, `RP15_PastGuard1`, `RP16_PastGuard2`,
`RP21_PastE09Guard`, `RP24_PastE09Rover`, and A06 `RP11_PastRover`
(`tests/cases/test_rover_real_level.gd` walks them).

`RouteBot` (`class_name RouteBot`, `Node`, `scripts/debug/route_bot.gd`):
drives a `Hero` **only** through `Input.action_press`/`action_release` of the
named actions (plus `hero.use_aim_override`/`aim_override`, never a live
mouse). Collects RoutePoints in tree order from every `AreaRoot` under a scan
root via `build_points(scan_root, enabled_branches)`, then `start(hero)`;
poll `bot.running` / read `bot.get_report()` (`success`, `failure`, `seconds`,
`area_times`, `beat_times`, `hero_final_position`, ...). Stuck detection fails
fast (no x progress for `stuck_timeout` s during MOVE/JUMP) with the point
index/name and hero position. Deterministic: input is released between every
point; a jump press never survives past its own JUMP point. If an `INTERACT`
point opens a modal (M4's workbench/pad confirm dialogs, or SC01, disable
`hero.input_enabled` while open), the bot makes no gameplay CHOICE on the
player's behalf — it never confirms a purchase/swap — it just backs out,
trying `skip` first (SC01's ONLY dismiss action, per ADV-01) and falling back
to `pause` (same as Escape/Decline — every OTHER modal's own dismiss) only if
`skip` alone doesn't clear it within `DISMISS_PAUSE_DELAY`, so it can never
press `pause` while SC01 is still genuinely playing (which would instead open
PauseMenu via `Session.cutscene_active` and stall the bot) — and waits for
`input_enabled` to come back before advancing (a still-open modal after 1s is
a hard failure).
`hero.input_enabled` going false while approaching a `MOVE`/`JUMP` point for
any OTHER reason is instead the route's own successful completion, **but
only when there is no point left after it** (M5's exit wicket: reaching it
permanently disables input, well before a route can be authored to walk past
it — the last `MOVE` point is deliberately placed deep in the same solid
floor, past the wicket, to guarantee the walk actually crosses it) —
`_finish(true)` fires immediately rather than waiting out `stuck_timeout`.
An input drop with route left to go still fails via the unchanged stuck
timeout, exactly as before. Since the revamp the wicket only fires while the
hero holds the keycard: A04's route walks over the `L01-KC01-P` pickup on its
way from the CP03 station to the depot door, so a full-route bot run reaches
A06 already carrying the card.

### Area test harness

`tests/area_harness.gd` (no `class_name` — load by path). Instances one area
alone at the origin with a Hero (`debug_invulnerable = true`) at its
`Spawn_CP00` marker (or `x=96, y≈0`), a `GameCamera`, and a `RouteBot`; runs
it to completion/timeout; frees everything before returning. Success =
hero.x reaches `>= area.width - 64` while `y ≈ 0`. Usage (each area builder
writes one `tests/cases/test_mN_<area>.gd` like this):

```gdscript
extends TestCase
func run() -> void:
    Session.new_run()
    var harness = load("res://tests/area_harness.gd").new()
    var result: Dictionary = await harness.run_area(
            self, "res://scenes/levels/areas/a02_gardens.tscn",
            ["OPT01"], 60.0)
    check(result.reached_exit,
            "A02 main route + OPT01 branch reach the exit (failure=%s)" % result.failure)
```

Assert persistent contracts (collected/committed/switch state) through
`Session` after the run, not through the freed scene's nodes.

## Hard rules (confirmed design; never violate)

Solo hero (Dave Harlan); one carried weapon; the W01 Scrapjack (infinite
basic fire, no magazine) and, from Level 2's pad (M3), the W02 Boom Broom (its
shells, pump and one-shell reload; the HUD shows its tube and reserve); only
stage 1 of a weapon purchasable (the Quickcycle, the Extended Tube);
Night Guard (SE01), Patrol Rover (M01) and Staffer (LK01) only in Level 1, plus
the Sidearm Guard (SE02), Security Drone (M02) and Hound (K01) from Level 2 (M4);
no boss,
companion, radio contact, Heirs, double jump, dash, climb, ladder,
drop-through, or wall jump; **no stealth or detection (C16)**; enemies drop no
chips; every damaging attack is preceded by a visible warning; no kill-all
doors; the exit wicket needs the level's keycard, which sits on the main
route; every enemy dies and bleeds (C28, C29): people leave a corpse and
blood, the rover a wreck and oil; honor reduced motion, and never let darkness
or blood hide a tell, a ledge or a pickup.

## Tests and evidence

Each milestone adds focused `tests/cases/test_mN_*.gd` cases (extend
`TestCase`; simulate input with named actions). Tests prove state/physics
contracts; visual captures prove readability. Never claim something was
verified unless a command you ran shows it. Record results in
`../prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`.
