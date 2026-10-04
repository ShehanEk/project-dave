# 09 — Progress and next-agent handoff

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)). Level 1 was rebuilt from the ground up around the C31 roster (C33, built 2026-09-30) after the approved lit-cutout test: Night Guards, Patrol Rovers and Staffers as lit cutouts (see the last session-log entry).

## Current state

**Planning status:** Complete, pending any user refinements.  
**Implementation status:** Level 1 rebuilt from the ground up around the C31 roster (C33, 2026-09-30): SE01 Night Guards, M01 Patrol Rovers and LK01 Staffers (16 enemies) as lit cutouts that die and bleed, new enemy IDs and save schema 3, the Security PA beat at the wicket, the enemy lab — tests 56/56. It sits on the 2026-09-29 revamp (C24): microchips, keycard exit, EF01 evidence file, Adam core-node SC01, night-campus look. M0-M6 verified; M7 implemented, unverified (gate 6 — first-time playtests — and T22-Windows/gate 7's Windows launch both pending; the M7 evidence is for the pre-rebuild builds). Playable, timing unverified.  
**Engine:** Godot 4.7.2.stable.official (ed1daf0bf), /Applications/Godot.app/Contents/MacOS/Godot (macOS host).  
**Build directory:** prototypes/sunnyvale-godot/ (exports under its `exports/`, gitignored — see its README.md for build commands) — see its CONVENTIONS.md for contracts, layers, IDs and commands.  
**Duration:** 750-second (12:30) main-route design budget; no measured playtest — duration unverified (see gate 6 below; `reports/pacing-risk.md` for the only data that exists, which is bot-traversal time, explicitly not pacing evidence).  
**Next action:** run >=3 first-time playtests on the rebuilt build with the kit at `prototypes/sunnyvale-godot/reports/playtests/` (gate 6); none has been run on any Level 1 build. Also still pending, separately: T22-Windows/gate 7's Windows launch on a real Windows PC (no Wine on this host); the exports were removed in the 2026-09-30 cleanup, so rebuild them first, and treat the old export evidence as belonging to the pre-revamp build. Not done: final enemy paintings and real Mixamo clips (the art is procedural placeholder and the clips are hand-keyed) — see the M7 row and the last session-log entry.

| Milestone | Status | Evidence |
| --- | --- | --- |
| M0 Setup | Verified | Headless import + 120-frame launch without errors; windowed Movie Maker capture of placeholder; tools/test.sh → test_m0_session 20/20 checks |
| M1 Hero/pistol | Verified | tools/test.sh and FPS=30 tools/test.sh both → 6/6 cases, 66 checks (test_m1_jump, test_m1_platform, test_m1_weapon, test_m1_damage, test_m1_measurements); 150-frame windowed capture of scenes/debug/m1_demo.tscn inspected, no errors/warnings |
| M2 Enemies | Verified | tools/test.sh and FPS=30 tools/test.sh both → 9/9 cases, 142 checks (adds test_m2_resident 52, test_m2_clipper 27, test_m2_mixed_lane 7); 450-frame/30fps windowed capture of scenes/debug/m2_demo.tscn inspected, no errors/warnings |
| M3 Full blockout | Verified | tools/test.sh and FPS=30 tools/test.sh both → 21/21 cases passed (see session log below for the exact count and per-case breakdown). test_m3_level.gd (91 checks) proves: level_01 instantiates all 6 areas end to end with no seam gaps; exact population counts (32 beats in order, 11 encounter groups with the exact 9 Resident/6 Clipper split, 45 main-route + 20 cache = 65 gem value, 1 artifact, HS01-03, CP01-03 stations, SC01, UPG01, PAD01↔L01-W01-P02, SW01+walkway, exactly 1 exit wicket, no duplicate ids); a RouteBot completes the full main route start-to-finish and reaches the exit wicket; both optional branches (OPT01, OPT02) complete and rejoin; a hero death rolls the world back to the last checkpoint (gem un-collected, fresh world objects) and respawns at that checkpoint's marker (CP00 before any station, then CP01 after using one), with input correctly re-enabled and a second death handled correctly too. 1300-frame/10fps windowed capture of the new scenes/debug/m3_route_demo.tscn (full-level RouteBot run) inspected across 15+ frames spread over all six areas: seams, camera framing, encounters, the depot/hatch sequence, and the "M3 temporary end — wicket reached" overlay all render correctly, no errors/warnings. |
| M4 Progression/save | Verified | tools/test.sh and FPS=30 tools/test.sh both → 25/25 cases passed (see session log below). New CheckpointService autoload (versioned JSON, temp-write/re-read/backup-then-replace) plus Session.commit()/purchase_upgrade()/swap_weapon() persistence/transactions; real BenchPanel (Service + Quickcycle purchase) and SwapConfirm (atomic pad exchange) UI wired into MaintenanceBench/WeaponPad; a HUD (health/weapon-tag/wallet/objective/toast) added by LevelDirector; UPG01/CP05 respawn mapping. tests/cases/test_m4_state_contracts.gd (116 checks) proves: (a) snapshot restoration across a station-save/gem/damage/enemy-defeat/swap/death cycle (one consistent rollback, no duplicate ids, gem collectible again, wallet matches, enemy back at idle placement and full health); (b)/T14 the upgrade transaction including a forced persistence failure (exactly no partial purchase), locked/insufficient-funds/repeat refusals; file-level CheckpointService contracts (malformed JSON, wrong schema_version, wrong level, a tampered/scene-path-shaped id, primary-corrupt-falls-back-to-valid-backup, save/load round trip); T09 (45 main-route gem value collected at runtime through Session, summing exactly to the wallet/gems_found totals); T12 (full-health capsule stays in place; station reuse heals/saves again without respawning the gem or reviving the enemy); T13/T15 (pad confirm/cancel/swap-back — exactly one instance ever resting anywhere, the incoming instance already carries the earned type-wide stage with no second purchase); T19 (save failure never half-loads; has_valid_save() honestly reflects a forced failure). A 170-frame/12fps windowed capture of the new scenes/debug/m4_demo.tscn (bespoke autopilot, not RouteBot — it operates the real BenchPanel/SwapConfirm buttons) inspected: the bench panel's price/wallet-before/after, Confirm -> "Quickcycle installed"/HUD Quickcycle pip/wallet update, and the swap dialog's "Swap held P01 for pad P02?" -> Confirm -> HUD tag flips to P02 and the pad redraws with P01's tag, all render correctly, no errors/warnings. **Adversarial review pass (see session log below, "M4/M5 adversarial review fixes"):** found and fixed 4 real M4-scope bugs — declining the pad swap wrongly showed "Weapon swapped" (ADV-04); `validate_snapshot()` accepted a tampered third weapon instance/duplicate/deleted-instance, an out-of-range upgrade stage, an extra top-level field, a negative gem value, an absurd wallet, and health 0 (ADV-07, plus a Hero.take_damage() defense-in-depth fix); a corrupt primary got copied over the last-known-good backup on the next save (ADV-08); the weapon-pad toast overlapped its own resting-tag text. Re-verified: `tools/test.sh`/`FPS=30 tools/test.sh` both 34/34 cases passed. |
| M5 Story/exit (part 1: story and completion) | Verified | tools/test.sh and FPS=30 tools/test.sh both → 26/26 cases passed (see session log below). Real SC01 (CoreConsole): ~19s skippable warning/interlock/Rook-EDEN-Rook scene, both paths landing in the same `_finish_awakening()` (awakening_done/core_installed/hatch_open, the post-SC01 objective, CP04 commit — proven byte-identical by T16). Objective now progresses START -> DEPOT (first entering A05) -> POST_SC01 (SC01) -> COMPLETE (the wicket), persisted as part of `state`. New `EnvironmentState` (scripts/world/environment_state.gd) drives A05/A06's pre/post-awakening look live off `story_state_changed`, applies the current flag directly (no animation) on any `_ready()` (boot/death-rebuild/Continue), and only fades in A06's settled QuarantineVisuals once, off-screen, the instant the flag actually flips. The real exit wicket now ends the run for good: `LevelDirector._on_wicket_reached()` sets `level_complete`, the final objective, commits CP05, emits `Session.level_completed`, permanently disables hero input, and shows the new `scenes/ui/completion.tscn` (active play time from the new `Session.run_meta`/`tick_active_time()`, gems found / 65 via `Session.gems_found()`, Welcome Key/Quickcycle found, Play again behind a confirm step -> `Session.new_run()` + `CheckpointService.clear()`, Quit). tests/cases/test_m5_story.gd (65 checks) proves T16 (normal vs. skip identical committed snapshots, no duplicate event on re-interact), T17 (resume from CP04 and from UPG01 both land in the settled quarantine state with the hatch open and no replayed latch/extra damage), T18 (a zero-upgrade, zero-artifact, base-pistol RouteBot clears A01->A06 through the REAL SC01, skipped, to real completion), and T20 (gems found stays correct after spending at the bench; Play again resets every field of `state`, including `equipped_weapon`/`world_weapons`, back to `default_state()`, and clears the on-disk save too). A 130-frame/12fps windowed capture of the new scenes/debug/m5_demo.tscn inspected: the console's warning-tint housing with the literal "WARNING: Ward circuits active." subtitle line and "Enter: skip" hint, A06 already showing its dark quarantine sky tint and "Quarantine Exit" sign after a skip (with the "Reach the garden wicket." objective and a "Progress saved" toast from the CP04 commit), and the real completion screen (title, stats, Play again/Quit) all render correctly, no errors/warnings. **Adversarial review pass (see session log below):** found and fixed a critical bug — none of `scripts/debug/m4_demo.gd`/`m5_demo.gd`/`m5b_demo.gd` redirected `CheckpointService` away from the real player's default save directory, so a capture run could delete or overwrite a real save; also fixed two majors — two unrelated toasts (this milestone's own "EDEN awakens" plus the HUD's generic "Progress saved") fired over each other on SC01 completion, and `m4_demo.gd` no longer reached the bench/pad after M5 replaced the M3 instant-flip stub with the real ~19s skippable SC01 scene. Re-verified: `tools/test.sh`/`FPS=30 tools/test.sh` both 34/34 cases passed; recaptured `m4_demo`/`m5_demo` show a single legible toast and the full bench/pad sequence again. |
| M5 Story/exit (part 2: game flow shell + telemetry) | Verified | tools/test.sh and FPS=30 tools/test.sh both → 27/27 cases passed (see session log below). New `scenes/main.tscn`/`scripts/main.gd` game-flow shell: a real Title screen (`scenes/ui/title_screen.tscn`) with New Game (asks confirmation only when a save already exists), Continue (enabled only via `CheckpointService.has_valid_save()`; transparently recovers a valid backup with an honest message, or points at New Game if both copies are invalid — never a crash or a dead end), and Quit; a real Continue on a CP05 (already-complete) save opens straight to the completion screen instead of a dead trigger. New pause menu (`scenes/ui/pause.tscn`, added by `LevelDirector` alongside its `Hud`): Resume/Journal/Settings/Restart from checkpoint/Quit to title, entirely via `get_tree().paused` (every other node's default pausable process mode already stops gameplay/enemies/`Session.tick_active_time()` for free); opens only from real gameplay (a 2-physics-frame "was input already enabled" streak keeps it from ever racing a same-tick modal-close, which was found to freeze RouteBot-driven tests during development and is now a permanent contract note in CONVENTIONS.md); the `journal` action (Tab) opens straight to the Journal view, which shows the current objective and, once discovered, a short written A01 Welcome Key entry. New minimal `Settings` autoload (subtitles/text size/reduced motion/Master-Music-SFX volume via a new `data/audio/default_bus_layout.tres`), persisted through two new `CheckpointService` methods (`save_settings`/`load_settings`) to a SEPARATE `settings.json`, never mixed into the checkpoint. New local-only `Telemetry` autoload (`scripts/telemetry.gd`) writing one JSONL file per run under `user://sunnyvale/playtests/` (never uploaded, never touched by any test unless that test explicitly calls `run_start()` against its own redirected throwaway dir): `run_start`, `area_enter`/`area_exit`, `beat_enter`, new `branch_enter`/`branch_exit` (new `BranchZone` markers added to a02_gardens.tscn/a03_roofs.tscn around the existing OPT01/OPT02 routes, no geometry/id changes), `encounter_complete` (via a new `AreaRoot.get_encounter_groups()` helper), `checkpoint_commit`/`upgrade_purchase`/`weapon_swap` (self-connected to Session's own signals), `death`, `restart_from_checkpoint`, `pause_start`/`pause_end`, `sc01_start`/`sc01_end(skipped)`, `completion`. New `tools/summarize_playtest.py` (python3 stdlib only) computes 07's report template fields from a log, including main-route successful-progress time (checkpoint-to-checkpoint active-time deltas minus branch time — a death/restart's discarded attempt is excluded for free since active time only reaches the next checkpoint's commit once, via whichever attempt actually succeeded) — verified against a hand-computed synthetic fixture (`tests/fixtures/telemetry_sample.jsonl`) both directly and through `tests/cases/test_m5_flow.gd`. New `tests/cases/test_m5_flow.gd` (48-50 checks; the exact count varies slightly with how many telemetry events a run happens to log) proves: Continue from a saved CP02 snapshot rebuilds the world correctly (collected gem and defeated enemy both absent, hero at CP02's own Respawn marker); an invalid primary save transparently recovers a valid backup with an honest message, and both-invalid shows a message pointing at New Game with no crash; pause genuinely stops hero movement and the active-time clock and resumes cleanly (T21 partial); the New Game confirmation path (shown only when a save exists, Cancel/Confirm both behave correctly); and Telemetry writes a parseable, correctly-ordered JSONL log for a short scripted run including a death followed by a pause-menu restart-from-checkpoint. A 110-frame/15fps windowed capture of the new `scenes/debug/m5b_demo.tscn` (a bespoke autopilot driving the REAL `Main`/`TitleScreen`/`PauseMenu` flow through real button calls and the real `journal` input action, not a scripted stand-in) was inspected: the title screen, real gameplay with the HUD after New Game, the pause menu's Journal view (objective + "1 undiscovered" artifact line), and the Settings view (all six controls) all render correctly with zero errors/warnings; three representative frames were sent to the user. A real (non-test) run of that same capture also produced a genuine `user://sunnyvale/playtests/*.jsonl` log with `run_start`/`area_enter`/`pause_start`/`pause_end` events that `tools/summarize_playtest.py` reads without error, confirming the whole pipeline end to end outside the test harness too. A 120-frame headless `--quit-after` launch of the real `res://scenes/main.tscn` (the project's own `run/main_scene`) produced zero errors/warnings. **Adversarial review pass (see session log below):** found and fixed 4 real M5-part-2-scope bugs — pressing pause (Escape) during SC01 skipped the scene and committed CP04 instead of suspending it (ADV-01, story-scenes.md "Pause suspends scene playback" vs. "skip"); Play again left the never-recreated HUD showing the ended run's weapon tag/Quickcycle pip (ADV-03); `summarize_playtest.py`'s main-route successful-progress time counted rolled-back death attempts and dropped the whole first (run-start-to-CP01) segment (ADV-02), and separately always reported 0s of pause time due to a `t_active`-freeze no-op (ADV-06); the title's New Game confirmation text promised the save would survive until the next save while `Main` actually deletes it immediately on confirm (ADV-05, fixed by correcting the text); a completed save's Continue showed "Active play time: 0:00" instead of the real total (ADV-09, needed a new `active_seconds` schema field). Re-verified: `tools/test.sh`/`FPS=30 tools/test.sh` both 34/34 cases passed; a 120-frame headless launch of `res://scenes/main.tscn` still produces zero errors. |
| M6 Presentation | Verified | `tools/test.sh`/`FPS=30 tools/test.sh` both 36/36 cases passed (import + full suite); a 120-frame headless `--quit-after` launch of `res://scenes/main.tscn` produced zero errors; a 60-frame/30fps windowed capture of `res://scenes/main.tscn` produced zero errors/warnings. C11 hand-drawn 2D visuals now cover Hero (original procedural vector rig)/Resident/Clipper (derived from the approved z01/r01 concept PNGs), the Scrapjack pistol, effects, all world geometry/scenery/props, per-area parallax backdrops, and every UI screen (shared `c11_theme.tres`); a new `Audio` autoload plays all 34 synthesized SFX cues + 2 music loops, every one now with a call site. Full-route (`m3_route_demo.tscn`, 800 frames/8fps, ~97s bot run), combat (`m2_demo.tscn`), depot/bench/pad (`m4_demo.tscn`), SC01+completion (`m6_characters_demo.tscn`/`m5_demo.tscn`), resident-solo/clipper-solo, reduced-motion (`M6_REDUCED_MOTION=1`), muted-audio (`M6_MUTED=1`), and three window sizes (960×540/1280×720/2560×1080 via `m6_resolution_probe.tscn`) were all captured and reviewed (grayscale contact sheets + individual frames): silhouettes, warning triangles/health-charge bars, gems, and platform edges all stay readable with reduced motion and with audio muted; no foreground prop hides feet/landing edges/gems/attack cues. Real-time performance sampled during a windowed (non-Movie-Maker) full-route run on this MacBook Pro (Apple M1 Pro, 8 cores, 16GB, Compatibility/Metal renderer): 68 one-second samples, frame time min/avg/max = 4.05/7.05/12.66 ms (≈79-247 fps uncapped), comfortably inside the 60fps/16.6ms target throughout — a target for this one machine, not a universal minimum. See `reports/asset-inventory.md` for the full per-asset provenance table and the honest remaining production-art gap list, and the M6 integration session log entry below for the two real bugs found and fixed while wiring the three parallel passes together. **Adversarial review pass (see session log below, "M6 adversarial review fixes"):** found and fixed 12 real bugs (2 critical, 5 major, 5 minor/cheap) spanning the Clipper's exposed-motor visual/hitbox alignment, background-removal transparency holes in both derived sprites, the Resident's off-model warning pose, Clipper blade/eye readability, both warning triangles' contrast, Clipper/hero z-order, a stray "P01" tag on the held gun, tutorial/hint text contrast, quarantine scenery reading as platform geometry, a negative-wallet display, and a debug demo writing to the real playtest-log directory; rejected 2 findings as already-tracked/false positives; deferred the full audio-priority/ducking system and a from-scratch hero-rig redesign as out of scope for a visual-only pass. Re-verified: `tools/test.sh`/`FPS=30 tools/test.sh` both 36/36 cases passed; recaptured `m6_characters_demo.tscn` (1000 frames/60fps) shows the Clipper's exposed motor now centered on `RearHitZone`, the Clipper drawing over the hero when stalled, and both derived sprites free of background leaks. |
| M7 Validation/export | Implemented; timing gate pending first-time playtests; Windows launch pending a Windows PC. (Playable, timing unverified: gates 1-5 verified, gate 6 and gate 7's Windows launch pending, gate 7's macOS half partially verified — see evidence.) | `tools/test.sh`/`FPS=30 tools/test.sh` both 40/40 cases passed (see session log). Functional matrix T01-T20 verified, T21 mechanically verified (its visual-readability half only partially verified, M6 captures only), and completion gates 1-5 verified — `reports/functional-matrix.md`. Export: `export_presets.cfg` (Windows Desktop x86_64 embedded-PCK; macOS universal, unsigned; both presets now also exclude `tests/*`/`scenes/debug/*` from the package — AUD-05) built via `--export-release`/`--export-debug`. The macOS **release** export (what a player receives) is verified to boot cleanly to the title screen with no errors; save/continue/complete outside the editor is verified only on the macOS **debug** export of the same preset and source, using a debug-build-only, argument-gated automation driver (`scripts/debug/m7_export_driver.gd`, confirmed inert in the release export) — real New Game -> real checkpoint save -> real Continue -> real completion screen, all in a throwaway save location, the real save untouched — the release .app itself was not separately hand-played through save/continue/complete. Windows build produced and file-type-confirmed but not launch-tested (no Wine on the verifying macOS host) — see `reports/export-report.md` for exact commands, sizes, and the Windows-PC steps to finish T22. Gate 6 (>=3 first-time playtests, 07's timing protocol) and T22-Windows/gate 7's Windows launch are both explicitly **pending**: no testers were available this session, this host has no Wine, and this report does not substitute an estimate for a measured result, per the task's own instruction. **Audit-fix pass (see session log below):** an independent audit of this M7 pass found and this session fixed a critical real bug — `tests/cases/test_m6_ui.gd` left `CheckpointService` pointed at the REAL default save dir after its own run, so every full-suite run since M6 silently deleted a real `checkpoint.json`/`checkpoint.bak.json` on this machine via `tests/run_tests.gd`'s own cleanup, contradicting README/CONVENTIONS' "tests never touch a real save" guarantee (AUD-01) — plus two minor verification-tooling/packaging bugs (AUD-05, AUD-06); re-verified with the full suite, a 40-second high-frequency poll of the real save dir showing no leak, and a re-export + re-verification of all three build artifacts. |
| Revamp rebuild (C24) | Implemented and tested; playtests pending | 2026-09-29: rebuilt to the dark sci-fi revamp (C14–C24). `tools/test.sh` → 54/54 cases (new `test_revamp_keycard`, `test_m6_characters`, now `test_enemy_tells`); captured tours of all six areas pre- and post-lockdown inspected. See the 2026-09-29 session-log entry (REVAMP REBUILD). |
| Lit-cutout test (C35) | Built, tested and approved by the user (2026-09-30) | 2026-09-30: `spike/lit_cutout/` — SE01 Night Guard as a lit cutout rig (painted parts + normal maps), smooth lamp/muzzle/baton-tell lighting, hand-keyed motion (Mixamo converter ready), ragdoll death, visible blood; Dave lit the same way at runtime. `tools/test.sh` → 55/55 (new `test_spike_lit_cutout`, now `test_lit_enemies`). No existing file changed. The C33 rebuild then folded the rigs, scripts, shader and tools into the game and deleted the `spike/` folders. |
| Level 1 rebuild (C33) | Built and tested; playtests pending | 2026-09-30: Level 1 rebuilt around the C31 roster as lit cutouts (8 Night Guards, 6 Patrol Rovers, 2 Staffers), schema 3, Security PA beat at the wicket, enemy lab. `tools/test.sh` → 56/56 cases (new `test_lit_enemies`, `test_enemy_tells` and `test_m2_night_guard`; the Clipper's tests renamed for the Patrol Rover); full-level and enemy-lab capture tours reviewed; 120 fps. See the last session-log entry. |

Rows M0–M7 record the evidence of the builds they were verified on. The enemy names, IDs, counts and test names in them (Resident, the CY01 Staffer, the Clipper, 9 + 6 enemies, `test_m2_resident`, `test_m2_clipper`) are those of the pre-rebuild builds, which the C33 rebuild replaced (see the last row). Read them as history.

## Baseline and outstanding prerequisites

This plan includes and depends on the companion-removal revision (C12). Use a checkout containing both this folder and the updated solo narrative. Preserve unrelated local or staged work when starting implementation. Publishing changes is separate from running a local prototype.

Needed at build time: an available Godot 4 stable runtime; matching Windows export templates for M7; actual first-time players for the timing gate. No third-party service or paid asset is required. The selected PNGs exist, but finished hero/weapon sprites, animation sets, and modular scenery are not supplied.

## Planning decisions and proposed defaults

| Topic | Status / choice |
| --- | --- |
| Godot | User selected |
| Duration | User requested 10–15 minutes; proposed central budget 12:30 |
| Rendering / protagonist | Confirmed hand-drawn 2D; solo hero |
| Language / platform / renderer | Proposed GDScript / Windows / Compatibility |
| Engine patch | Unset; record at M0 |
| Input | Proposed keyboard/mouse first; controller deferred |
| Local level expansion | Proposed 32 beats, 15 enemies (16 since the C33 rebuild), 2 optional branches, extra recovery points |
| Build scope | W01 + Quickcycle only; no boss or later weapon |
| Art | Existing selected reference PNGs; placeholder-first implementation |
| Version control | Existing signing settings remain in force; no signing bypass |

## Update after each implementation session

~~~text
Date / agent / milestone:
Exact Godot version / executable:
Starting state and pre-existing changes:
Implemented behavior:
Files changed:
Checks actually run and outcomes:
Timing / machine measurements, if any:
Remaining errors / placeholders / unverified gates:
Design deviations and reasons:
Save/schema compatibility notes:
Next concrete action:
~~~

## Session log

~~~text
Date / agent / milestone: 2026-09-26 / Claude Code (Opus 5.5) / M0
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: clean main at 334e46c; no prototype directory
Implemented behavior: project.godot (Compatibility renderer, 1280x720 canvas_items/expand, named inputs
  move_left/right, jump, fire, interact, pause, journal, skip; physics layer names), Session autoload
  (run state, in-memory commit/restore), HitZone/AttackBox/Interactable/Block contracts, headless
  test runner, capture tool, CONVENTIONS.md
Files changed: prototypes/sunnyvale-godot/* (new), this file
Checks actually run and outcomes: --import OK; --quit-after 120 launch printed boot line, no errors;
  windowed --write-movie produced frames; tools/test.sh PASS 1/1
Timing / machine measurements, if any: none
Remaining errors / placeholders / unverified gates: no Windows export templates installed
  (~/Library/Application Support/Godot/export_templates absent) — blocks M7 export only;
  host is macOS, so the Windows build cannot be launch-tested here
Design deviations and reasons: blockout geometry uses Block (StaticBody2D rectangles) instead of
  TileMapLayer until tile art exists — simpler to author, same collision semantics; jump also bound
  to W/Up; `skip` action (Enter) added for SC01 skip
Save/schema compatibility notes: Session schema_version 1 (in-memory only so far)
Next concrete action: M1
~~~

~~~text
Date / agent / milestone: 2026-09-26 / Claude Code (Sonnet 5) / M1
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M0 verified; scripts/scenes for hero, camera, Scrapjack,
  bolt, practice target, blocked panel, moving platform, m1_course/m1_demo, and tests/cases/
  test_m1_jump.gd + test_m1_platform.gd already present (from an earlier pass this session) and
  passing; this session added the remaining required M1 coverage and evidence rather than
  rebuilding what already matched CONVENTIONS.md and 03/04.
Implemented behavior: verified the existing HeroTuning/WeaponTuning resources, Hero (variable jump,
  coyote/buffer, air steering, ceiling bonk, moving-platform carry via
  platform_on_leave=DO_NOTHING, take_damage/fall_to/respawn_at/died, Hurtbox+InteractSensor,
  aim_override), Scrapjack (stage-driven cadence from Session.weapon_stage("W01"), shoulder->muzzle
  raycast clamp, recoil/flash), ScrapBolt (swept ray mask 17, hit/blocked resolution, max_range
  despawn), PracticeTarget/BlockedPanel (HitZone hit vs blocked), MovingPlatform (sync_to_physics,
  blocked-ahead reversal), GameCamera (independent, smoothed, look-ahead, world_limits), m1_course
  (flat run, 2 low steps, 4 catch-floored gaps at 0.8/1.4/1.8/2.0H, low-ceiling corridor,
  point-blank wall, practice target, blocked panel, moving platform) and m1_demo (reactive
  autopilot) against 03/04/06/07 and CONVENTIONS.md — all matched, no code changes needed there.
  Added new tests/cases/test_m1_weapon.gd (cadence at stage 0/1, point-blank-wall bolt clamp,
  HitZone hit vs blocked), tests/cases/test_m1_damage.gd (immunity caps two hits to 1 health,
  died emitted exactly once at 0 health and never again, fall_to costs 1 health and teleports),
  and tests/cases/test_m1_measurements.gd (prints calibration numbers; see below). Fixed a
  GDScript-lambda pitfall while writing these (a lambda captures an outer scalar by value, so
  `func(): count += 1` never updates the outer `count` — switched counters to a 1-element Array,
  which is captured by reference). Ran a 150-frame/30fps windowed capture of
  scenes/debug/m1_demo.tscn and visually inspected frames 0/10/15/30/45/75/90/149: hero silhouette,
  pistol-in-hand, camera follow/look-ahead, muzzle-clamp spark at the point-blank wall, and the
  blocked-panel spark all render as intended; no errors/warnings from the capture run.
Files changed: prototypes/sunnyvale-godot/tests/cases/test_m1_weapon.gd (new),
  prototypes/sunnyvale-godot/tests/cases/test_m1_damage.gd (new),
  prototypes/sunnyvale-godot/tests/cases/test_m1_measurements.gd (new), this file.
  (scripts/scenes/data listed under "Implemented behavior" above were pre-existing this session,
  not authored in this pass.)
Checks actually run and outcomes: tools/test.sh and FPS=30 tools/test.sh both → RESULT: 6/6 cases
  passed (test_m0_session 20, test_m1_jump 10, test_m1_platform 5, test_m1_weapon 7,
  test_m1_damage 11, test_m1_measurements 3 = 56 checks; identical pass/fail under both fixed-fps
  settings). tools/capture.sh res://scenes/debug/m1_demo.tscn <scratch>/m1 150 30 → "frames
  written: 150", zero lines matched by capture.sh's error/warn/script grep.
Timing / machine measurements, if any (from test_m1_measurements.gd, headless, real hero physics):
  apex_height_px = 159.8 measured vs 153.6 analytic (H=96, jump_apex_h=1.6) — within the existing
  ±10% test tolerance; the small overshoot is discrete-integration rounding at 60Hz, not a tuning
  bug. max_gap_clearable_equal_height_px = 320.0 (3.33H) for a full-hold running jump landing at
  the same height — comfortably above the course's largest authored gap (2.0H = 192px), leaving
  margin for a short-tap or partial-speed jump to still clear it if intended, or for future areas
  to go wider. max_rise_reachable_px = 144.0 (1.50H) for a step taken with a running start and a
  full-hold jump — comfortably above the two authored steps (0.4H/40px, 0.83H/80px) and below the
  vertical apex (as expected, since a step also costs some horizontal lead-in time). Weapon tuning
  recorded in data/tuning/w01_scrapjack.tres: bolt_speed=960 px/s (10H/s), max_range=640 px
  (~6.7H) — chosen to read as a fast, visible but finite bolt at this course's scale (screen width
  ≈13.3H). Camera: zoom 1 at 1280x720 puts H=96 at 1/7.5 screen height (~1/8 target).
Remaining errors / placeholders / unverified gates: no enemies yet (Resident/Clipper are M2), so
  T03's "Resident body hits damage" / "Clipper frontal hits show blocked feedback" halves are only
  approximated here by PracticeTarget (hit) and BlockedPanel (blocked) — full T03 closes at M2.
  Windows export templates still not installed (unchanged from M0, blocks M7 only). Hero/gun
  silhouettes remain placeholder _draw() blockout art per C11, as intended for this stage.
Design deviations and reasons: none beyond what M0 already recorded; M1 followed
  03-gameplay-systems.md / 04-godot-architecture.md / CONVENTIONS.md as written. Bolt speed/range
  above are M1 authoring choices (spec left them open) recorded here per CONVENTIONS.md.
Save/schema compatibility notes: unchanged (Session schema_version 1, in-memory only); this
  milestone reads Session.weapon_stage("W01") but adds no new persisted fields.
Next concrete action: M2 (Resident Z01, Clipper R01 encounters)
~~~

~~~text
Date / agent / milestone: 2026-09-26 / Claude Code (Sonnet 5) / M2
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M1 verified, no code changes needed to hero/pistol; this
  session built M2 from scratch (no pre-existing Resident/Clipper/EncounterGroup code).
Implemented behavior: ResidentTuning/ClipperTuning (+ data/tuning/resident.tres, clipper.tres) with
  the 03/prototype-spec.json seeds (Resident 3 health, 0.8H/s approach, 0.65s windup, 1.2H/0.30s
  lunge, 0.80s recovery, 1 damage; Clipper 0.8s windup, 5H/s charge capped at 4H, 1.6s wall-stall,
  3 motor health, 1 damage) plus recorded M2 authoring choices (engage/acquire ranges, floor bands,
  patrol speed, missed-charge recovery time, grounded-AI gravity — none of these were specified by
  03). scripts/combat/encounter_group.gd (EncounterGroup, Node2D): group_id, lane_rect, optional
  ApproachZone child gating is_active, request_attack_token/release_attack_token with a single
  holder and a short reactivate_cooldown so a released token can't be immediately re-taken by the
  same enemy while another is waiting. scripts/actors/resident.gd + scenes/actors/resident.tscn:
  CharacterBody2D (layer 3, mask 1 — never body-blocks or is body-blocked by the hero), states
  APPROACH -> (token) WINDUP (visible torso lean + raised arm + pulsing warning triangle, AttackBox
  inactive) -> LUNGE (locked direction, AttackBox active only here, floor/wall sensors keep it from
  running off a ledge or through a wall) -> RECOVERY (token released here, per 03's "release after
  the attack" fairness rule, not after the full recovery) -> APPROACH; whole body is one HitZone
  (any point is a valid body shot); queue_free()s in _ready() if Session.is_defeated(entity_id);
  Session.mark_defeated() called exactly once on 0 health, then a short fade before queue_free().
  scripts/actors/clipper.gd + scenes/actors/clipper.tscn: CharacterBody2D (same layer/mask rule),
  states PATROL (bounded by an optional patrol_min_x/patrol_max_x leash for standalone scenes, or
  an EncounterGroup's lane_rect) -> acquire (same floor band + line-of-sight raycast, mask 1 only —
  aimed at both actors' mid-body height, not the ground plane, so a ray ending exactly on the floor
  surface doesn't register the floor itself as an obstruction) -> (token) WINDUP (both eye stalks
  retract, shears open, drawn via a lerp on state_timer) -> CHARGE (locked direction, constant
  speed, AttackBox active; a floor-ahead raycast brakes it at an unmarked ledge before it can walk
  off one) -> on a wall/backstop collision (move_and_slide collision normal opposing the charge
  direction): STALL (rear_hit_zone.blocks = false for wall_stall_time, front shell stays
  blocks=true throughout — distinct feedback either way; token released here, not after recovery,
  so another enemy in the group can act while this one sits stalled) -> RECOVERY -> PATROL; a
  missed charge (distance cap or ledge) brakes into the same RECOVERY without a stall. Rear
  HitZone's `hit` signal reduces motor_health; 0 motor health defeats it exactly like the Resident.
  ClipperFrontHitZone (small HitZone subclass, contract unchanged) counts ineffective frontal
  "blocked" hits and emits `hint_requested` once after frontal_hint_threshold (4) hits, showing a
  short on-screen Label once. Debug scenes: m2_resident_solo.tscn (isolated Resident, no
  EncounterGroup ancestor => attacks freely, per CONVENTIONS.md), m2_clipper_solo.tscn (A02-style:
  stone backstop, an elevated observation-step platform above it, safe jumping space), m2_mixed_lane
  (one EncounterGroup with an ApproachZone gate, a Resident and a Clipper, ~2H of retreat space
  behind the hero's start). m2_course.tscn + m2_demo.gd: a combined course (isolated Resident, then
  a backstop/Clipper lane) with a reactive autopilot (in the style of m1_demo.gd) that shoots the
  Resident down while it warns/lunges, then holds at a safe distance past the backstop, jump-dodges
  the Clipper's charge once it's closing in, and shoots the exposed rear motor once it stalls.
Files changed: prototypes/sunnyvale-godot/scripts/tuning/{resident_tuning.gd,clipper_tuning.gd}
  (new), data/tuning/{resident.tres,clipper.tres} (new), scripts/combat/encounter_group.gd (new),
  scripts/combat/clipper_front_hit_zone.gd (new), scripts/actors/{resident.gd,clipper.gd} (new),
  scenes/actors/{resident.tscn,clipper.tscn} (new), scenes/debug/{m2_resident_solo.tscn,
  m2_resident_solo.gd,m2_clipper_solo.tscn,m2_clipper_solo.gd,m2_mixed_lane.tscn,m2_mixed_lane.gd,
  m2_course.tscn,m2_course.gd,m2_demo.tscn,m2_demo.gd} (new),
  tests/cases/{test_m2_resident.gd,test_m2_clipper.gd,test_m2_mixed_lane.gd} (new), this file. No
  M0/M1 files were modified — no bugs were found in the existing hero/pistol/camera/world code.
Checks actually run and outcomes: tools/test.sh and FPS=30 tools/test.sh both → RESULT: 9/9 cases
  passed, identical under both fixed-fps settings (test_m0_session 20, test_m1_jump 10,
  test_m1_platform 5, test_m1_weapon 7, test_m1_damage 11, test_m1_measurements 3, test_m2_resident
  52, test_m2_clipper 27, test_m2_mixed_lane 7 = 142 checks total). test_m2_resident.gd covers: a
  whole-body shot is accepted and 3 hits defeat it; full body overlap during approach/windup deals
  zero damage (AttackBox stays inactive) right up to just before the windup ends; the AttackBox
  activates only after >=0.6s of continuously-observed windup and one lunge (plus its one possible
  immunity-window re-hit) costs at most 1 health; defeated fires exactly once, Session records it,
  and re-instancing the same entity_id afterward removes it immediately; a stage-0 bot standing
  outside engage_range defeats a Resident before it can close the distance, with the hero taking no
  damage. test_m2_clipper.gd covers: frontal shots are always "blocked" and the motor hint fires
  exactly once after 4 ineffective hits (never again after more); a charge keeps constant y and
  monotonic x; a backstop hit stalls it, exposes the rear motor (front stays blocked even while
  stalled), and three stage-0-paced shots (0.32s apart) fit inside the 1.6s stall and defeat it; a
  scripted bot reactively jump-dodges an active charge and then shoots the exposed motor, defeating
  the Clipper with zero unavoidable damage. test_m2_mixed_lane.gd covers: an EncounterGroup's
  ApproachZone gates is_active off until the hero enters it; and, run for a bit over 20 simulated
  seconds with a Resident and a Clipper both perpetually in range of the hero, never more than one
  of them is windup/active-attacking at any tick, and both actually got at least one attack turn
  (the token wasn't monopolized). tools/capture.sh res://scenes/debug/m2_demo.tscn <scratch>/m2 450
  30 -> "frames written: 450", zero lines matched by capture.sh's error/warn/script grep. Frames
  were inspected around the Resident's windup (clear leaning pose + pulsing warning triangle) and
  its hit/defeat, and around the Clipper's windup (eye-stalk retract + shear-open), its charge, the
  hero's dodge jump, the stall (rear motor recolored to the "exposed" tone), and the motor shots
  through to defeat — all read correctly at actual gameplay zoom (1280x720, H=96px). A separate
  headless per-tick health trace over the same 450-tick run confirmed the hero's health never drops
  below its starting 6 during the whole demo (the dodge is not just visually plausible but actually
  connects in the simulation the capture was taken from).
Timing / machine measurements, if any: none beyond the timings already covered by the test
  assertions above (windup->AttackBox latency, stall-window shot cadence).
Remaining errors / placeholders / unverified gates: full T03/T04/T05/T06 acceptance still needs the
  eventual M3 area geometry (these are isolated/mixed test-scene proofs, per 06's own M2 exit
  check); Windows export templates still not installed (unchanged, blocks M7 only); Resident and
  Clipper are still placeholder _draw()/Polygon-style blockout art in the approved C11 style
  (sage/coral/teal for the Resident, leaf-green/ivory/graphite/amber for the Clipper, per the
  z01-resident.md / r01-clipper.md briefs), as intended at this stage.
Design deviations and reasons: no deviations from 03/04/06/07 or CONVENTIONS.md's hard rules. Two
  behavioral choices worth flagging as authoring decisions rather than spec: (1) an enemy's attack
  token is released as soon as its active attack ends (Resident: end of LUNGE; Clipper: on
  entering STALL or a missed-charge brake), not after its full recovery — read 03's "after that
  attack, release the token fairly" as scoped to windup+active-attack, which also keeps a mixed
  lane from stalling out waiting on one enemy's multi-second stall/recovery; (2) Clipper's
  line-of-sight raycast targets both actors' mid-body height rather than their feet/global_position
  — using the ground-contact point made a ray whose target sits exactly on the floor plane register
  the floor itself as the obstruction, which isn't a real limitation the design asks for (a wall
  should block sight; the ground under the target's own feet should not). Debug/demo scenes also
  add an unspec'd `patrol_min_x`/`patrol_max_x` leash to Clipper (defaults unbounded) purely so an
  isolated demo Clipper with no EncounterGroup doesn't wander arbitrarily far on open floor while
  idle; it doesn't change any tested contract.
Save/schema compatibility notes: unchanged (Session schema_version 1, in-memory only); this
  milestone only calls the existing Session.is_defeated()/mark_defeated() contract with new
  entity_ids, adding no new persisted fields or shapes.
Next concrete action: M3 (assemble the six area scenes and 32 beats from 02-area-blueprints.md,
  placing the real L01-E0x-{Z01,R01}-NN encounters — with real entity_ids and EncounterGroup lanes
  — using the Resident/Clipper/EncounterGroup built here)
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M3 foundation
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M2 verified. AreaRoot, all 17 shared entity scripts/scenes,
  RoutePoint/RouteBot, tests/area_harness.gd, scenes/debug/sample_area.tscn and
  tests/cases/test_m3_foundation.gd were already present and passing at the start of this pass (an
  earlier session this run had already built the M3 shared foundation to spec but had not yet
  updated CONVENTIONS.md or this handoff doc). This pass read every one of those files end to end
  against the task brief and against 02/03/04/06/CONVENTIONS.md, ran the full suite under both
  fixed-fps settings and NOIMPORT=1, took a fresh windowed capture, and found no correctness gaps
  or spec deviations to fix — so it made no changes to the foundation code itself, only closed the
  two remaining deliverables (the CONVENTIONS.md section and this log entry).
Implemented behavior (as verified, all pre-existing this pass): AreaRoot (class_name, Node2D) —
  area_id/width/camera_top/camera_bottom exports, the (0,0)=entry-seam-floor-top / >=384px(4H) seam
  contract, auto-created Geometry/Scenery/Entities/Encounters/Beats/Route/Markers containers,
  get_marker/get_beat_ids/get_entity_ids/get_enemy_ids/get_route_points/get_camera_limits/
  has_floor_at helpers. All 17 shared entity scenes+scripts under scenes|scripts/objects/ (gem,
  gem_cache, artifact_pickup, care_capsule, recovery_station, maintenance_bench, weapon_pad,
  core_console, emergency_hatch, exit_wicket, route_switch, service_walkway, pit_hazard,
  kill_plane, beat_zone, tutorial_prompt, scenery) each deciding presence from Session in _ready()
  per spec, plus BeatHub (autoload-free static signal hub, scripts/world/beat_hub.gd) and
  ToastLabel (scripts/world/toast_label.gd) support classes. Hero.debug_invulnerable (default
  false; take_damage/fall_to no-op when true) added as the only Hero change. RoutePoint (Marker2D,
  action enum MOVE/JUMP/WAIT_PLATFORM/INTERACT/WAIT_SECONDS + branch/tolerance/hold_jump/platform/
  platform_target/seconds) and RouteBot (Node; drives Hero only via Input.action_press/release +
  aim_override; per-point state machine; stuck detection; per-area/per-beat timing report) in
  scripts/debug/. tests/area_harness.gd (no class_name; run_area(test_case, path, branches,
  timeout) -> Dictionary) instances one area alone with a debug_invulnerable Hero at Spawn_CP00,
  a GameCamera, and a RouteBot, and frees everything before returning. scenes/debug/sample_area.tscn
  demonstrates every entity type plus a moving-platform WAIT_PLATFORM crossing, a switch+walkway
  INTERACT gate, an EncounterGroup+ApproachZone+Resident, two BeatZones, Spawn/Respawn markers, and
  a 15-point Route with an OPT01 branch (cache + artifact). tests/cases/test_m3_foundation.gd proves
  the 9 required contracts (full main-route + branch traversal; gem one-time/Session-backed
  collection and re-instancing-after-collect absence; capsule health-gated collection; station
  heal+commit and reusability; walkway switch-gated/persists-across-reinstancing/never-retracts;
  pit hazard 1-health cost + fixed-marker reset; hatch opens live and on fresh _ready() from the
  story flag; core console's temporary M3 stub sets awakening_done/core_installed/hatch_open+
  objective+CP04 exactly once and is status-only after; artifact records A01 with zero gems added).
  This pass added the "Areas and route bot" section to CONVENTIONS.md (seam contract, children
  layout, the full entity scene/export list, RoutePoint/RouteBot usage, and a worked area-test
  harness example) so the six parallel area builders have one binding reference, and this log
  entry.
Files changed this pass: prototypes/sunnyvale-godot/CONVENTIONS.md (new "Areas and route bot"
  section), this file. No .gd/.tscn files were modified — everything under Implemented behavior
  above was already present and correct at the start of this pass.
Checks actually run and outcomes: tools/test.sh → RESULT: 14/14 cases passed, 210 checks total
  (test_m0_session 20, test_m1_jump 11, test_m1_platform 5, test_m1_weapon 8, test_m1_damage 11,
  test_m1_measurements 3, test_m1_regress_buffered_jump_cut 1, test_m1_regress_muzzle_overlap_hitzone 4,
  test_m2_resident 52, test_m2_clipper 27, test_m2_mixed_lane 7, test_m2_regress_clipper_shell_gap 3,
  test_m2_regress_resident_lunge 5, test_m3_foundation 53). NOIMPORT=1 FPS=30 tools/test.sh →
  identical RESULT: 14/14 cases passed, same 210 checks, same PASS lines. tools/capture.sh
  res://scenes/debug/sample_area.tscn <scratch>/m3_sample 150 30 -> "frames written: 150", zero
  lines matched by capture.sh's error/warn/script grep; frames inspected show the blockout geometry
  (lawn-green floor blocks, dark outline, sky-blue background) and the moving platform mid-crossing
  the gap, rendering cleanly with no visual artifacts.
Timing / machine measurements, if any: none new this pass (M1's measured hero-reach numbers are
  unchanged and are the DESIGN LIMITS the six area builders must build within).
Remaining errors / placeholders / unverified gates: the six real area scenes
  (scenes/levels/areas/l01-aXX-*.tscn) from 02-area-blueprints.md are not yet built — this pass is
  foundation only, proven end-to-end against one demonstration area (sample_area.tscn /
  "L01-TEST-SAMPLE"), not the real level. maintenance_bench.tscn and weapon_pad.tscn are
  intentionally M4-stub interactions (status text only) per the task brief. core_console.tscn's
  awakening/CP04 behavior is intentionally temporary and will be replaced by the full scene in M5.
  Windows export templates still not installed (unchanged, blocks M7 only).
Design deviations and reasons: none found against the task brief or 02/03/04/CONVENTIONS.md while
  reviewing this pass; no code changes were made to the foundation, only documentation.
Save/schema compatibility notes: unchanged (Session schema_version 1, in-memory only); the M3
  foundation entities call only existing Session methods (collect, record_artifact, heal_full,
  commit, set_switch, set_story, apply_damage) with new entity/switch/story ids — no new persisted
  shapes.
Next concrete action: build the six real L01 area scenes on AreaRoot per 02-area-blueprints.md,
  each with its own tests/cases/test_m3_<area>.gd calling tests/area_harness.gd (see
  CONVENTIONS.md's "Areas and route bot" section for the exact contract and a worked example).
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M3 assembly and full-level proof
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: six parallel area builders had already built and
  individually verified all six area scenes (scenes/levels/areas/a0{1..6}_*.tscn) plus their own
  tests/cases/test_m3_a0{1..6}.gd, each passing on its own via tests/area_harness.gd (per their own
  session reports: a01 gate, a02 gardens, a03 roofs, a04 square, a05 depot, a06 exit). No
  shared_change_requests were flagged by any area builder. tools/test.sh at the start of this
  session already showed 20/20 cases passed (210+ checks) with all six area tests included, so this
  session's job was assembly (level_01/LevelDirector) and the level-wide proof, not rebuilding any
  area from scratch.
Implemented behavior: scripts/levels/level_director.gd (new, class_name LevelDirector, Node2D) —
  instances the six area scenes in x-order under an "Areas" container, each offset by the
  cumulative `width` of the areas placed before it (so an area author's own width edits never break
  the next seam); spawns one Hero and one GameCamera whose world_limits.x always span the whole
  level while its y (top/bottom) smoothly move_toward's the current area's own camera_top/bottom at
  600 px/s (so crossing into a taller/shorter area never snaps the view mid-air); adds one
  level-wide KillPlane (a single instance with its collision shape resized to level_width + 2000px,
  reset_target computed via get_path_to() to A01's Spawn_CP00) as a bug-guard safety net. Death
  handling: hero.died (connected once, in _ready(), since Hero/GameCamera are never recreated) ->
  Session.restore_committed() -> place the hero at the respawn marker for the restored
  checkpoint_id (CP00 Spawn_CP00, CP01-CP03 station Respawn_CPxx, CP04 console Respawn_CP04) -> one
  real awaited physics_frame -> free + re-instance all six areas (so every pickup/enemy/switch/story
  object re-reads Session fresh) -> re-enable input. Temporary end: any area's ExitWicket signalling
  wicket_reached shows a plain "M3 temporary end — wicket reached" CanvasLayer/Label (input is
  deliberately left alone here — the task brief only asked for the overlay, and gating input turned
  out to actively conflict with a RouteBot's own authored route continuing a little past the wicket
  in some areas; M5 replaces this with real completion). scenes/levels/level_01.tscn (new, minimal
  root + the script) and scripts/main.gd / scenes/main.tscn now boot level_01 instead of the M0
  placeholder floor. Two small SHARED fixes, both needed only once areas were chained together
  (invisible to any single area's own isolated test, which always runs that area alone at world
  origin): (1) scripts/actors/game_camera.gd gained `reset_position()` (snap to target +
  reset_smoothing(), no pan) for use right after a checkpoint teleport. (2) scripts/actors/hero.gd's
  `respawn_at()` now resets the internal `_died_emitted` latch — without this a second death in the
  same run could never re-emit `died` (found and required by the level test's two-death scenario).
Files changed: scripts/levels/level_director.gd (new), scenes/levels/level_01.tscn (new),
  scripts/main.gd (rewritten: boots level_01), scenes/main.tscn (rewritten: minimal root, M0
  placeholder floor removed), scripts/actors/game_camera.gd (+reset_position()),
  scripts/actors/hero.gd (respawn_at() resets _died_emitted), scripts/debug/route_bot.gd (see
  deviation below), scripts/debug/route_point.gd (doc comment only, same deviation),
  CONVENTIONS.md (doc line only, same deviation), scenes/levels/areas/a04_square.tscn (removed one
  erroneous extra ExitWicket + its now-unused ext_resource, load_steps 17->16 — see deviation),
  tests/cases/test_m3_level.gd (new, 91 checks), scenes/debug/m3_route_demo.tscn +
  scripts/debug/m3_route_demo.gd (new, capture-only, mirrors the existing m3_a0X_demo.gd pattern but
  for the whole level), this file. No other area's .tscn or test was touched.
Checks actually run and outcomes: tools/test.sh (with import) -> RESULT: 21/21 cases passed. FPS=30
  tools/test.sh -> identical RESULT: 21/21 cases passed, same PASS lines (the new
  test_m3_level.gd adds 91 checks on top of the pre-existing 20 cases/210+ checks; see M2's/M3
  foundation's entries above for that unchanged baseline). test_m3_level.gd covers, in order: (a)
  level_01 instantiates without error, all 6 areas present in the right order with the right
  area_id, level_width is the exact sum of the six widths (33750px), every adjacent pair has solid
  floor at both sides of its seam with zero gap/overlap, hero starts at A01's Spawn_CP00; (b) exact
  population counts against the M3 slice of prototype-spec.json: 32 beat ids in exact order, 11
  EncounterGroups with the exact per-group Resident/Clipper counts (9 Residents + 6 Clippers total),
  45 main-route + 20 cache = 65 total gem value, no duplicate entity/enemy ids anywhere, and every
  named singleton present exactly once (A01 artifact pickup, HS01-03, SC01, UPG01, PAD01 holding
  L01-W01-P02 per Session, SW01 + its walkway, exactly 1 exit wicket — found the extra one in A04,
  see deviations); (c) a RouteBot walks the full main route across all 6 areas start-to-finish and
  reaches the exit wicket, with all 32 beats reached along the way; (d) OPT01 and OPT02 each
  complete and rejoin the main route to the exit; (e) killing the hero mid-A02 after it collects a
  post-CP00 gem rolls back to CP00 (checkpoint_id, the gem un-collected, a genuinely fresh/uncollected
  world Gem_G001 instance) and respawns at A01's Spawn_CP00 with input re-enabled; using CP01 then
  dying again keeps checkpoint_id at CP01 and respawns at A02's Respawn_CP01. 1300-frame/10fps
  windowed capture of scenes/debug/m3_route_demo.tscn (full main route, no branches) -> "frames
  written: 1300", zero lines matched by capture.sh's error/warn/script grep; inspected 15 frames
  spread across all six areas (apron/steps, garden/wall-jump/porch, rooftop platform crossing +
  clock landmark, square encounters + flowerbeds, depot console/bench/hatch, quarantine rails and
  the final "M3 temporary end — wicket reached" overlay) — camera framing, seams, and encounter
  readability all looked correct with no artifacts.
Timing / machine measurements, if any (bot traversal seconds — NOT pacing evidence, per
  CONVENTIONS.md; these prove the route completes and are reported for reference only, never as a
  measured playtest): main route total 97.05s (L01-A01 9.38s, L01-A02 17.95s, L01-A03 22.18s,
  L01-A04 21.77s, L01-A05 8.02s, L01-A06 17.75s); OPT01 branch total 107.95s; OPT02 branch total
  98.47s. Level width 33750px (3400+6600+7050+7800+2700+6200). Separately measured this session: a
  plain (non---fixed-fps) `tools/test.sh` run paces close to 1x real time per simulated game-second
  in this Godot build (no compute-bound speedup), while `--fixed-fps N` (used by FPS=30 tools/test.sh
  and tools/capture.sh) decouples from real time and runs as fast as the CPU allows — useful to know
  when re-running this specific test, since its ~300 simulated seconds of bot traversal take several
  minutes of real wall-clock time under a plain run but well under a minute under FPS=30.
Remaining errors / placeholders / unverified gates: Windows export templates still not installed
  (unchanged, blocks M7 only). Combat is not exercised by any of this session's checks (the
  RouteBot never fights; it runs `debug_invulnerable = true` for the main-route/branch runs
  specifically so a stray hit can't tear the level's Areas down mid-traversal, matching what every
  individual area's own harness-based test already does) — M2's own isolated/mixed-lane tests are
  still what proves combat fairness, unchanged by this pass. CP05/completion totals are M5 scope and
  untouched. The camera's vertical-limit smoothing rate (600 px/s) is an authoring choice, not a
  measured/tuned value; nothing in 02-04 specifies one.
Design deviations and reasons: (1) RoutePoint.platform_target (WAIT_PLATFORM) is now interpreted as
  AreaRoot-LOCAL and converted through the point's owning AreaRoot in RouteBot, instead of being a
  raw global Vector2 — found because A03's own authored platform_target values (correct for its
  solo, origin-placed test) pointed hundreds of pixels short of the real platform once A03 sat at
  its ~10000px offset inside the full level, so the bot waited forever for a platform position it
  could never see. The change is fully backward compatible: at offset (0,0) (every existing
  per-area test) a local-to-global conversion is the identity, so all six areas' own tests are
  unaffected — verified by the unchanged 20/20 baseline. Docs updated in route_point.gd's export
  comment and CONVENTIONS.md's RoutePoint line. (2) Removed one erroneous extra ExitWicket instance
  from A04 (near its own end, x=7750 local) that had no basis in 02-area-blueprints.md (which gives
  A04 zero wickets) and violated the "exactly one exit wicket, on the final area" hard rule — never
  caught by A04's own isolated test (which doesn't check wicket count or rely on wicket_reached), only
  surfaced by this session's level-wide population-count test. (3) LevelDirector's temporary-end
  handler does not disable hero input (only shows the overlay) — the task brief only asked for the
  overlay; gating input turned out to conflict with a RouteBot finishing its own authored route a
  little past some areas' wicket-adjacent points, and nothing in 03/04/06 asks for a hard input
  freeze at this temporary M3 marker. (4) Death-rebuild ordering: the hero is moved to its
  checkpoint BEFORE the areas are freed/rebuilt, and one real physics_frame is awaited before any
  fresh area (and its Area2D pickups) is created — found by this session's own death-rebuild test:
  without the wait, a brand-new Gem/Area2D instantiated at the hero's exact death position could see
  the physics server's still-stale broadphase state (the hero's CharacterBody2D transform updates
  immediately, but the broadphase used for a newly-added Area2D's overlap detection only catches up
  on the next physics step) and would silently re-collect itself before Session.state ever reflected
  the fresh world, an easy-to-miss Godot physics-timing quirk rather than an ordinary logic bug. (5)
  hero.gd's respawn_at() now clears _died_emitted (previously permanent, one-shot-per-hero-instance)
  — required for the level's real, indefinitely-repeatable death cycle, not just the single scripted
  death every area-level test exercises.
Save/schema compatibility notes: unchanged (Session schema_version 1, in-memory only); LevelDirector
  only calls Session.restore_committed()/state reads that already existed, adding no new persisted
  fields.
Next concrete action: M4 (replace M3's temporary treasure/bench/checkpoint markers with the real
  progression loop — gems already match the exact M4 allocation target of 65 total/45 main-route, so
  M4 is mainly the purchase/persistence transactions and the infinite-pistol/Quickcycle rules, per
  06-build-milestones.md).
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M3 assembly review fixes
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: an 18-item M3 assembly review (LAY-01..LAY-16 + two visual
  findings F1/F2) had already been substantially acted on before this pass started: the six area
  scenes and clipper.gd/hero.gd already contained fixes for LAY-01 (pit-hazard/reset-foothold
  separation), LAY-02 (A04 catch floors + area-local KillPlane fallback), LAY-03/09 (lowered
  backstops), LAY-04 (GapPlatform retune), LAY-06 (service-lane wall), LAY-07 (flowerbed catch
  floors), LAY-08 (A04 E07/E08 landing spacing), LAY-10 (Clipper leash in AreaRoot-local space),
  LAY-11 (near-side Clipper stall backstops), LAY-12 (offset SW01 channel steps), LAY-13/14 (E06/E08
  lane shrink), and LAY-16 (E11 retreat floor), each with a `test_m3_regress_*.gd` file already
  describing the fix. This pass's job was to actually VERIFY every one of the 18 findings against
  the live code (reviewers can be wrong, and a fix's own test can be stale) rather than trust the
  file comments, fix whatever verification turned up, and close out the milestone log/capture.
Implemented behavior / fixes this pass: (1) LAY-01 was only half-fixed: `Hero.fall_to()` set
  `_immune_timer` but never CHECKED it, so a hazard trigger reachable from its own reset foothold
  could still cost more than 1 health per approach if re-entered inside the immunity window (proven
  by the still-failing `test_m3_regress_recovery.gd` probe: "took 2 hits"); added the same
  `_immune_timer <= 0.0` gate `take_damage()` already had, keeping the always-unconditional
  reposition. (2) LAY-05's actual fix (walking back through A03's Terrace1/Terrace2 to redo the
  T1-T3 climb) does not work and had never been run live: Terrace1 (top -64) and Terrace2 (top -136,
  whose underside sits exactly at the hero's own head height) both fully block ground-level travel
  underneath them by construction (a step low enough to be an "ordinary rise" can never also be
  walkable under a full 96px-tall hero) — confirmed by a live run getting permanently stuck at local
  x=1310/1490. Replaced that plan with a new low block, `RecoveryStepA` (a03_roofs.tscn, area-local
  x 1350..1470, top -68), giving a short LOCAL way up entirely clear of the GapPlatform's x-sweep:
  street -> RecoveryStepA (68px hop) -> Terrace2's own top (68px hop) -> the main route's own proven
  Terrace2->Terrace3 jump. Verified success across all 7 tested platform phases. (3) Found (not in
  the original 18) that A03's E06 Resident sits only 171px from the T7->T8 landing (below the 192px
  = 2H minimum); moved `Resident_Z01_01` from area-local x=5050 to x=5090. (4) Fixed a pre-existing
  test-isolation bug in `test_m3_foundation.gd`'s pit-hazard case: the test's Hero entered the tree
  at its default (0,0) — which overlaps a pit hazard also instanced at (0,0) — before being moved to
  (9999,9999); Godot delivers that transient real `body_entered` a few physics frames late, landing
  right on the test's own manual trigger and costing an extra, unaccounted health once LAY-01's gate
  was added (previously masked because the ungated code's extra hit happened to cancel out in the
  particular before/after health values). Fixed by setting `Hero.position` before `add_child()`
  instead of after. (5) LAY-12's/LAY-13's own scene fixes were correct, but their regression-test
  probes were stale: `test_m3_regress_recovery.gd`'s SW01-channel escape still used one near-max
  136px jump landing on `ChannelStep2` (a spec/assertion left over from before the steps were
  offset) instead of the three 68px hops the corrected geometry actually requires — rewrote the
  probe as three hops (pit->Step1->Step2->B04Floor) and fixed the rise assertions to compare each
  adjacent pair, not pit-to-Step2. `test_m3_regress_encounters.gd`'s CP02-vs-E06 exposure probe still
  placed the Resident at the OLD lane edge (local 5305) instead of the shrunk lane's real edge
  (5100), which spuriously failed once the true LAY-13 fix (lane end 5100) was checked against it;
  updated both the E06 and E08 exposure probes to the current lane edges (5100/3900). (6) F2 (a gem
  cluster visually fused with a decoration) reproduces exactly as reported, just with a Shrub, not
  loose gems: A03's `GemCluster_GC01` (4060,-400) and `Shrub01` (4080,-380) are only 20px apart and
  their drawn circles/facets overlap by ~35px (confirmed by a fresh capture's frame00000389, zoomed
  crop saved to the session capture dir as zoom_389.png); moved `Shrub01` to x=4220 (160px clear).
  (7) F1 did NOT reproduce: re-capturing the exact cited frame (00000198, A02's first Resident
  encounter) shows the Resident's `z_index = 1` (already present in resident.tscn, unrelated to this
  review) correctly drawing its body and warning triangle IN FRONT of the Hero, not hidden behind
  it as the finding described — rejected as not reproducible in the current code.
Files changed: scripts/actors/hero.gd (fall_to() immunity gate), scenes/levels/areas/a03_roofs.tscn
  (new RecoveryStepA block; Resident_Z01_01 and Shrub01 repositioned),
  tests/cases/test_m3_regress_recovery.gd (roof-fall recovery + SW01 channel probes/assertions
  rewritten for the geometry above), tests/cases/test_m3_regress_encounters.gd (E06/E08 exposure
  probe positions corrected), tests/cases/test_m3_foundation.gd (pit-hazard test's Hero positioned
  before add_child), this file.
Checks actually run and outcomes: `tools/test.sh` (with import) -> RESULT: 24/24 cases passed.
  `FPS=30 tools/test.sh` -> RESULT: 24/24 cases passed, same PASS lines (test_m3_regress_recovery.gd
  26 checks, test_m3_regress_encounters.gd 263 checks, test_m3_regress_route.gd 297 checks, all
  other M0-M3 cases unchanged). Re-ran `test_m3_foundation` alone 3x to confirm the isolation fix
  isn't flaky. 1300-frame/10fps windowed capture of `scenes/debug/m3_route_demo.tscn` (full main
  route) -> "frames written: 1300", zero error/warn/script lines; inspected frame00000198 (A02 E01,
  confirms F1 does not reproduce), frame00000224 (A02 E02 Clipper, clean spacing),
  frame00000317/389/630 (A03/A02 encounters and the F2 shrub/gem-cluster overlap), and the full
  route's encounter windups (auto-located via the warning-triangle color) with no other occlusion or
  overlap artifacts found.
Timing / machine measurements, if any: A03's GapPlatform missed-cycle wait is now ~5.93s (span
  400px / speed 150px/s / pause 0.6s), measured leave->return waits of 5.9s across 5 cycles (was
  ~9.8s before LAY-04's speed/pause retune, already in place at the start of this pass).
Remaining errors / placeholders / unverified gates: LAY-15 (A03's OPT02 and A02's OPT01 optional
  branches each use one jump within the absolute 144px reach limit rather than an intermediate
  stepped ledge) was left as-is — both jumps are within the measured reach limit and the route bot
  completes them reliably every run; it is a minor stylistic deviation from 02's "ordinary roof
  steps" phrasing on an OPTIONAL branch, not a functional defect, and fixing it needs new geometry
  plus re-tuned branch route points rather than a cheap edit. Same M3 gates as the prior entry
  otherwise (Windows export templates, M4/M5 scope, camera-limit smoothing rate as an authoring
  choice).
Design deviations and reasons: RecoveryStepA (a03_roofs.tscn) is a new, previously-unauthored block;
  it exists solely as a bug-recovery path (only reachable by falling near the GapPlatform, never from
  a normal ground approach — verified Terrace1's own low underside still blocks that), so it adds no
  main-route content and cannot be used to skip anything.
Save/schema compatibility notes: unchanged (Session schema_version 1, in-memory only); no Session
  method signatures or persisted shapes changed this pass.
Next concrete action: M4, unchanged from the prior entry.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M3 assembly review re-verification
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: handed the same 18-item M3 assembly review (LAY-01..LAY-16
  + F1/F2, identical finding text/evidence, including F1/F2's original pre-fix numbers) that the
  prior "M3 assembly review fixes" entry above already closed out. This pass re-verified every one
  of the 18 findings against the live code from scratch (reading every referenced .tscn/.gd file,
  not trusting that entry's prose) rather than assuming it still held, and additionally re-ran and
  re-inspected everything the review asks for (both test configurations, a fresh capture, frame
  inspection) from this session. No test_probe_lay_*.gd files exist in tests/cases/ — the fixes'
  probes already live as tests/cases/test_m3_regress_{recovery,route,encounters}.gd, exactly as the
  prior entry recorded, and no other probe files needed deleting.
Implemented behavior / fixes this pass: none — every finding's fix was already correctly in place
  and re-verified: LAY-01 (PitHazard_B03 rect local x 3224..3356/y -40..0, strictly below and inside
  the PlatformA/PlatformB gap; Reset marker at local (3100,-64), >=1H inside PlatformA;
  Hero.fall_to() gates on `_immune_timer <= 0.0` before applying damage, confirmed by a live
  hold-move_right-for-1.5s-from-Reset run taking exactly 1 hit, not >1), LAY-02 (AscentCatch1/
  AscentCatch2 fill both A04 ascent gaps so a missed jump lands nearby instead of falling through;
  A04's own KillPlane shape widened to 8600px; LevelDirector's level-wide kill-plane handler resets
  to the hero's current area's own FailsafeReset/Spawn marker, not always CP00 — confirmed a missed
  jump at every previously-reported x lands within a few hundred px, never back in A01), LAY-03 (E07
  and E09 Clipper starts sit clear of their landings — dx a route bot actually lands with, not just
  distance-to-lane), LAY-04 (GapPlatform 400px/150px/0.6s pause measures ~5.9s worst-case
  leave->return wait, under the ~6s pacing limit), LAY-05 (RecoveryStepA sits outside GapPlatform's
  x 1870..2430 sweep; all 7 tested platform phases recover successfully; MovingPlatform's
  `_is_blocked_ahead()` masks world|hero (1|2) so it yields instead of shoving), LAY-06
  (StreetLaneWall blocks the A03 service-lane bypass — both the early and mid-roof hold-right-only
  probes fail to reach the exit in 30s), LAY-07 (FlowerbedCatch1-4 sit under every A04 flowerbed gap
  — all 4 tested missed jumps land on a nearby catch, not a bottomless reset), LAY-08 (E07/E08
  Resident starts are >=192px past their landings), LAY-09 (A02 Backstop1/2 and A04
  E07Backstop/E09Backstop are all 72px tall, within the 0.9H ordinary-rise limit), LAY-10 (Clipper's
  leash compares through the owning AreaRoot, not global space — all 6 leashed Clippers show 0
  facing-flips over 2s idle in the assembled level), LAY-11 (BackstopE10Stall/BackstopE11Stall sit
  within 4H of E10/E11's Clipper starts), LAY-12 (ChannelStep1/ChannelStep2 are horizontally offset,
  two ordinary 68px hops, not one 136px near-max leap), LAY-13/14 (E06's lane ends at local 5100 and
  E08's at 3900, both clear of CP02/SW01 — idling at either interaction spot for 6s while the
  neighbouring group is active and its enemy sits at the new lane edge takes zero damage), LAY-16
  (E11's approach zone sits on FloorB04 with 208px of flat retreat behind it, over the 192px
  minimum), F2 (Shrub01 sits at local x=4220, 160px clear of GemCluster_GC01 at x=4060 — confirmed
  visually distinct and non-overlapping in this session's own capture, frame00000391). F1 still does
  not reproduce: Resident's `z_index = 1` (resident.tscn, unrelated to this review) draws its body
  and pulsing warning triangle in front of the Hero even at full sprite overlap — this session's own
  capture frame00000198 (A02's first Resident encounter) shows the salmon Resident body and warning
  triangle clearly rendered over the Hero, not hidden behind it. LAY-15 remains an intentional,
  documented deferral (both OPT01's and OPT02's single jumps are within the measured 144px reach
  limit and the route bot completes both reliably every run; turning them into stepped ledges is new
  geometry + route-point work on an optional branch, not a functional defect).
Files changed: prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md (this entry) only — no
  .gd/.tscn edits were needed.
Checks actually run and outcomes: `tools/test.sh` (with import) -> RESULT: 24/24 cases passed.
  `FPS=30 tools/test.sh` -> RESULT: 24/24 cases passed, identical PASS lines (test_m3_regress_recovery.gd
  26 checks, test_m3_regress_encounters.gd 263 checks, test_m3_regress_route.gd 297 checks, all other
  M0-M3 cases unchanged) — includes, among the 297 route checks, every LAY-03/08/09/16 gap/rise/
  clearance/retreat-floor assertion passing at its exact measured value (e.g. E08 retreat exactly
  192px, E11 retreat 208px, all main-route obstacle clearances <=72px against the 86.4px limit). A
  fresh 1300-frame/10fps windowed capture of scenes/debug/m3_route_demo.tscn -> "frames written:
  1300", zero error/warn/script lines; inspected frame00000198 (A02 E01, F1 re-confirmed not
  reproducible), frame00000344 (A03 GapPlatform crossing + StreetLaneWall visible blocking the
  street below), frame00000391 (A03 OPT02 ledge, F2's gem-cluster/shrub separation confirmed),
  frame00000539 (A04 flowerbed catch floors visible under the gaps), frame00000569 (A04 E08's two
  Residents, clearly separated), frame00000871 (A06 pit hazard correctly sitting in the PlatformA/
  PlatformB gap, below both platform tops), and frame00001295 (the "M3 temporary end — wicket
  reached" overlay at route completion) — all render correctly with no occlusion, overlap, or
  clipping artifacts.
Timing / machine measurements, if any: unchanged from the prior entry — GapPlatform worst-case wait
  ~5.9s (5 measured cycles: 5.9, 5.9, 5.9, 5.9, 5.9s); main route bot 95.7-97.1s across the three
  branch configurations (MAIN/OPT01/OPT02), matching the prior entry within normal run-to-run
  variance.
Remaining errors / placeholders / unverified gates: same as the prior entry — Windows export
  templates not installed (blocks M7 only); LAY-15 deferred (see above); M4/M5 scope untouched;
  camera-limit smoothing rate is still an authoring choice, not a measured value.
Design deviations and reasons: none this pass.
Save/schema compatibility notes: unchanged (Session schema_version 1, in-memory only).
Next concrete action: M4, unchanged from the prior entry.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M4 full progression loop
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M3 complete and verified (24/24 cases both fixed-fps
  configurations per the prior entries); gems/cache/artifact/capsules/stations/bench/pad/console
  already placed in memory with the exact M4 allocation (45 main-route + 20 cache = 65) — this pass
  did not re-place any entity, only replaced the M3 stub BEHAVIOR on top of the existing IDs/counts.
Implemented behavior: (1) New autoload `CheckpointService` (scripts/checkpoint_service.gd),
  registered via scripts/tools/configure_project.gd and rerun: versioned JSON under
  `user://sunnyvale/checkpoint.json` + `checkpoint.bak.json`. `save_snapshot()` validates the
  complete snapshot, writes a temp file, closes it, re-reads/re-parses/re-validates the exact bytes
  on disk, copies the current-good primary to the backup path, THEN replaces the primary with the
  verified temp file (`DirAccess.rename_absolute`/`copy_absolute` — confirmed available in 4.7.2 by
  actually compiling/running against them, not assumed). `load_latest()` tries the primary, falls
  back to the backup on ANY problem, never returns a half-loaded snapshot. `validate_snapshot()`
  whitelists every id by pattern (`^L01(-[A-Z0-9]+)+$` etc. — never a scene path, never lowercase,
  never a node-ref-shaped string) and every value by exact type, rejecting a wrong `schema_version`,
  wrong `level`, an out-of-range value, or an unexpected/missing story flag. Test hooks:
  `set_save_dir(path)`, `debug_force_write_failure(true)`, static `remove_dir_recursive(path)`.
  (2) `Session.commit(checkpoint_id)` now builds the complete snapshot and persists it through
  CheckpointService; only on success does `committed` update and `checkpoint_committed` fire; on
  failure it restores only the one field it changed (`checkpoint_id`) and emits the new
  `save_failed(reason, checkpoint_id)` signal — every other change already made this run (health,
  wallet, ...) is deliberately left live-but-uncommitted, matching health-and-checkpoints.md's "kept
  in memory only". Added `Session.load_from_snapshot()` (Continue's counterpart to `new_run()`,
  normalizing JSON's int-as-float round trip back to int) for M5 to call.
  (3) `Session.purchase_upgrade(weapon_type, target_stage, price) -> {ok, reason}`: preconditions
  (`awakening_done`, exact next stage, enough gems) checked against LIVE state with zero side
  effects on refusal (`"locked"`/`"insufficient_funds"`/`"already_owned"`/`"invalid_stage"`); on
  success builds ONE complete candidate state (wallet debited, stage recorded, checkpoint id
  `"UPG01"`), persists THAT, and only adopts it after `save_snapshot()` returns true — a forced
  persistence failure leaves wallet/upgrades/checkpoint_id byte-for-byte unchanged
  (`reason:"save_failed"`), proven by test_m4_state_contracts.gd's forced-failure case.
  `Session.swap_weapon(pad_id) -> {ok, reason, old_id, new_id}` atomically exchanges the equipped
  instance with the pad's resting instance; live-state-only (never itself persists), so it rolls
  back with the next `restore_committed()` per weapon-swaps.md.
  (4) `scenes/ui/bench_panel.tscn` + `scripts/ui/bench_panel.gd` (`BenchPanel`): Service (heal+save),
  Quickcycle price/wallet-before/after, Confirm/Decline, insufficient-funds/already-owned/save-failed
  messages. `MaintenanceBench.interact()` opens it and disables `hero.input_enabled` until `closed`;
  `can_interact()` still gates on `Session.get_story("awakening_done")` (no player-facing dev
  toggle — isolated tests set the flag directly on Session, per 06's own M4 note).
  (5) `scenes/ui/swap_confirm.tscn` + `scripts/ui/swap_confirm.gd` (`SwapConfirm`): names both
  instances by workshop tag ("Swap held P01 for pad P02?"), Confirm calls `Session.swap_weapon()`
  exactly once, Cancel/Escape changes nothing. `WeaponPad.interact()` opens it the same way the bench
  opens its panel. `Scrapjack` now draws the held instance's own tag (`_current_tag()`, read fresh
  from Session every draw) and exposes `is_ready()` for the HUD's fire-readiness cue; `WeaponPad`
  draws the resting instance's tag the same way. Both dialogs poll `Input.is_action_pressed("pause")`
  by hand in `_physics_process` (never `_unhandled_input` — `Input.action_press()`, how RouteBot and
  every test drive input, never dispatches a real input event; and never idle `_process`, which is
  throttled under `tools/test.sh FPS=30` and can miss a press+release that both happen inside one
  60Hz physics tick — found by FPS=30 tools/test.sh actually failing 4 cases before this fix, see
  below).
  (6) `scenes/ui/hud.tscn` + `scripts/ui/hud.gd` (`Hud`): six health segments, held weapon tag +
  Quickcycle pip + fire-readiness dot, gem wallet, objective, and a toast area
  (`checkpoint_committed`/`save_failed`/`artifact_recorded`). Added once by `LevelDirector` right
  after the Hero/GameCamera it never recreates (`hud.setup(hero)`); connects to Session signals once,
  disconnects in `_exit_tree()`; only reads Session/signals, never edits state.
  (7) `LevelDirector.CHECKPOINT_MARKERS` gained `"UPG01": [4, "Respawn_UPG01"]` (a new top-level
  marker in a05_depot.tscn's `Markers` node, mirroring the bench's own child `Respawn` marker) and
  `"CP05": [5, "Respawn_CP05"]` (a new marker in a06_exit.tscn near the wicket, for M5 to commit to).
  (8) `tests/cases/test_m4_state_contracts.gd` (116 checks): (a) snapshot restoration — save at
  CP01, collect a gem, take damage, defeat an enemy (L01-E01-Z01-01), flip the depot swap, then die:
  one consistent rollback (checkpoint_id/health/wallet all match the CP01 commit, gem un-collected
  and collectible again after rebuild with its exact value, enemy un-defeated and the REBUILT node is
  back at full internal health, equipped weapon and pad occupant both reverted, no duplicate/leftover
  Areas container); (b)/T14 the upgrade transaction (locked -> insufficient funds -> forced
  persistence failure, verified via `CheckpointService.has_valid_save()` staying false and
  `Session.save_failed` firing -> success, verified via a `CheckpointService.load_latest()` round
  trip -> repeat purchase refused); file-level CheckpointService contracts (malformed JSON, wrong
  schema_version, wrong level, a scene-path-shaped tampered id in `collected` and in
  `equipped_weapon`, primary-corrupt-falls-back-to-the-PREVIOUS-good-backup, and a fully-populated
  save/load round trip — discovered along the way that GDScript's `Dictionary ==` does NOT do the
  loose int/float numeric comparison a bare `1 == 1.0` does, so a JSON-round-tripped int (always
  parsed back as float) needs an explicit int-cast comparison, not a raw deep `==`; added
  `Session._normalize_snapshot()` so `load_from_snapshot()` doesn't carry that float-typed drift into
  live gameplay state either); T09 (collecting every A01-A04 `Gem` through `Session.collect()` at
  runtime totals exactly 45, matching wallet and `gems_found()`); T12 (a full-health capsule stays
  uncollected and in place; reusing CP01 heals/commits again without respawning the already-collected
  gem or reviving the defeated enemy); T13/T15 (instantiating the real `weapon_pad.tscn` and driving
  its dialog's own `_on_decline()`/`_on_confirm()` handlers directly: cancel/confirm/swap-back all
  leave exactly one instance resting on the pad, never a third; the freshly-purchased stage-1 record
  applies to whichever instance ends up held, with no second purchase); T19 (covered across (b) and
  the file-level cases above).
  (9) `scenes/debug/m4_demo.tscn` + `scripts/debug/m4_demo.gd`: a bespoke autopilot (not RouteBot —
  it must operate real UI buttons, which RouteBot deliberately never does) walking the depot,
  interacting the console/bench/pad in order, and calling the real `BenchPanel`/`SwapConfirm`
  handlers to drive a full Quickcycle purchase and a full pad swap for capture evidence. Demo-only
  bootstrap grants 60 gems directly on Session (an isolated depot scene has no main-route gems of its
  own to collect first) — documented in the script as demo-only, never a gameplay/test exploit.
  (10) `route_bot.gd` gained a `dismiss_modal` state (see (5) above): when an `INTERACT` point leaves
  `hero.input_enabled == false` after its tap, the bot presses/releases `pause` and waits for
  `input_enabled` to return before advancing, rather than getting stuck forever on the M3-era
  A05 route's bench/pad interact points, which now open real modals. `_release_all()` also releases
  `pause`. Found and fixed by the FULL M3+M4 regression suite (test_m3_level.gd/test_m3_a05.gd)
  actually failing with "stuck: no x progress" at the bench/pad points before this fix — the M3-era
  full-route/A05 tests are UNCHANGED text-wise; only route_bot.gd (a shared debug tool) changed.
Files changed: scripts/checkpoint_service.gd (new), scripts/session.gd, scripts/tools/
  configure_project.gd, scripts/objects/maintenance_bench.gd, scripts/objects/weapon_pad.gd,
  scripts/objects/core_console.gd, scripts/objects/recovery_station.gd, scripts/weapons/scrapjack.gd,
  scripts/levels/level_director.gd, scripts/debug/route_bot.gd, scripts/ui/bench_panel.gd (new),
  scripts/ui/swap_confirm.gd (new), scripts/ui/hud.gd (new), scenes/ui/bench_panel.tscn (new),
  scenes/ui/swap_confirm.tscn (new), scenes/ui/hud.tscn (new), scenes/levels/areas/a05_depot.tscn
  (Respawn_UPG01 marker), scenes/levels/areas/a06_exit.tscn (Respawn_CP05 marker),
  scenes/debug/m4_demo.gd (new), scenes/debug/m4_demo.tscn (new), tests/run_tests.gd (per-run
  throwaway CheckpointService save dir), tests/cases/test_m4_state_contracts.gd (new), CONVENTIONS.md,
  this file.
Checks actually run and outcomes: `tools/test.sh` (with import) -> RESULT: 25/25 cases passed
  (test_m4_state_contracts.gd 116 checks; every M0-M3 case unchanged in check count/content).
  `FPS=30 tools/test.sh` -> RESULT: 25/25 cases passed (identical, after the route_bot.gd
  dismiss_modal fix and switching BenchPanel/SwapConfirm's pause-polling from idle `_process` to
  `_physics_process` — see (5)/(10) above; both fixes were driven by this exact command actually
  failing first: 21/25 with test_m3_a05/test_m3_foundation/test_m3_level/test_m3_regress_encounters
  failing on "modal stayed open after pause"). A 170-frame/12fps windowed capture of
  scenes/debug/m4_demo.tscn -> "frames written: 170", zero error/warn/script lines; inspected the
  bench panel before confirm (price/wallet 60->20 shown), after confirm ("Quickcycle installed",
  "Owned", HUD wallet 20 + Quickcycle pip), the swap dialog ("Swap held P01 for pad P02?"), and after
  confirm (HUD tag P02, "Weapon swapped" toast, pad now shows P01) — all render correctly.
Timing / machine measurements, if any: none new (M4 is mechanics/persistence, not pacing).
Remaining errors / placeholders / unverified gates: Windows export templates not installed (blocks
  M7 only); M5/M6 scope untouched (bench's `awakening_done` gate has no in-game way to flip yet
  outside the M3-stub CoreConsole's temporary first-interact behavior, which M5 replaces); CP05's new
  respawn marker is placed near a06_exit.tscn's ExitWicket but M5 owns the actual CP05 commit-on-exit
  wiring; HUD's fire-readiness dot and Quickcycle pip are blockout-styled placeholders, not final art
  (M6 scope).
Design deviations and reasons: (1) `purchase_upgrade()`'s reason set includes `"invalid_stage"` for a
  skipped-stage request (e.g. buying stage 2 directly) even though this slice's bench only ever
  offers stage 1 — kept for forward-compatibility with the full upgrades-and-ownership.md stage table
  a later slice may reuse this same function for, per that doc's stage-gate rules; it is unreachable
  from any current UI. (2) `WeaponPad.can_interact()` requires a non-empty resting instance, which is
  always true in this slice's default/reachable states (there is always exactly one instance
  somewhere) — kept explicit rather than assumed, since a future weapon type/scene could otherwise
  crash on an empty pad. (3) `Session.state`/direct-field writes for test setup (`Session.state["wallet"]
  = 60`, etc.) follow the existing M1-M3 test precedent (test_m1_damage.gd, test_m1_weapon.gd, ...),
  not a new pattern.
Save/schema compatibility notes: schema_version stays 1 (BUILD bumped to "sunnyvale-proto-m4" only,
  informational). The saved shape is unchanged from what Session.default_state() already documented
  in 04's "Save design" — M4 adds the FILE that holds it, not new fields. CheckpointService's
  whitelist accepts `"UPG01"` alongside `CP0[0-5]` for `checkpoint_id` (already implied by 04/
  CONVENTIONS' existing ID list, made explicit and enforced here for the first time).
Next concrete action: M5 (story and completion — SC01, objectives, core interlock, safe hatch,
  quarantine scenery state, CP04/CP05's real commit-on-exit wiring, completion totals, New Game,
  Continue via Session.load_from_snapshot(), and replay; remove the M3 temporary end trigger/overlay
  for the real wicket).
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M5 part 1 (story and completion)
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M4 verified (25/25 both fixed-fps configurations, prior
  entry). The bulk of M5 part 1's implementation (CoreConsole's real SC01, EnvironmentState,
  LevelDirector's real wicket-completion path, completion.tscn/CompletionScreen, Session's objective
  constants/run_meta/gems_found(), and tests/cases/test_m5_story.gd itself) was already present on
  disk at the start of this session (this workspace's `prototypes/` directory is untracked, so there
  is no git history to attribute it to). This session verified it, found and fixed three real
  defects the existing full-regression run surfaced, added the one genuinely missing piece of the
  design brief (the warning's own label text), and did the documentation/evidence work.
Implemented / fixed behavior:
  (1) BUG: `tools/test.sh` on the as-found tree failed 3/26 cases
  (test_m3_regress_route.gd's MAIN/OPT01/OPT02 sub-tests, and test_m5_story.gd's own T18), all with
  RouteBot "stuck: no x progress" exactly at A06's last route point, `RP15_ToExit`. Root cause:
  `LevelDirector._on_wicket_reached()` permanently sets `hero.input_enabled = false` the instant the
  hero's body overlaps the real ExitWicket (local x~5856, well short of RP15's authored x=6150), so a
  hero walking under RouteBot's own input never has a controlled path left to reach 6150 — it coasts
  a few px on residual velocity/ground_deceleration and then genuinely can't move again, which is
  indistinguishable (correctly) from a stuck bug to the existing stuck-timeout. This is a real
  M3-vs-M5 regression: it did not exist before the real wicket-ending was wired up, and RP15's
  position/tolerance can't be tuned around it (any target close enough to be "reached" post-freeze
  is reached too early, before the hero has actually walked far enough to trigger the wicket at all,
  which broke T18's own `level_ended_flag` assertion when tried). Fixed at the root instead:
  `RouteBot._tick_approach()` (scripts/debug/route_bot.gd) now treats `hero.input_enabled` going
  false while approaching a MOVE/JUMP point as the route's own successful completion, but ONLY when
  it is the route's last point (there is nothing left to walk to once a one-way ending has
  permanently taken control away) — `_finish(true)` fires immediately instead of waiting out
  `stuck_timeout`. An input drop with route left to go is still a real failure via the unchanged
  stuck-timeout. RP15_ToExit's own position/tolerance are UNCHANGED from the pre-M5 value (local
  x=6150, tolerance 12, deep inside the same solid floor past the wicket) — the fix is generic to
  RouteBot, not a geometry tweak, and documented in CONVENTIONS.md's "Route bot" section.
  (2) LESSON (no code change beyond reverting it): a `##`-prefixed explanatory comment placed
  directly between a `[node ...]` header and its first `key = value` property line in a `.tscn` file
  silently breaks that ONE property (Godot's tscn parser drops it, defaulting to the type's own
  default — here Marker2D's position (0,0) — without any load error), while comments that sit where
  no property immediately follows (this project's existing `Lamps`/`GardenVisuals` comment blocks)
  are harmless. Discovered by writing exactly this pattern while investigating (1) above and getting
  a nonsensical RP15 global position back from a throwaway probe script
  (`godot --headless -s ...`); reverted immediately, no such comment exists in any `.tscn` in this
  tree now. Worth keeping in mind for any future hand-edited `.tscn`.
  (3) BUG: two pre-existing M3-era tests directly exercised CoreConsole's OLD M3-stub contract
  ("interact instantly flips the awakening flags"), which no longer holds now that interact starts
  the real ~19s SC01 scene. `tests/cases/test_m3_foundation.gd`'s
  `_test_core_console_sets_flags_once` and `tests/cases/test_m3_regress_encounters.gd`'s
  `_depot_exit` both now press `skip` (via the shared `hold(&"skip", 1.0/60.0)` TestCase helper,
  the same pattern T16's own skip path in test_m5_story.gd already uses) immediately after
  `interact()` and wait a few physics frames before asserting the post-awakening flags/hatch state —
  proving the exact same contract, through the real skip path instead of an obsolete stub
  assumption. No other M3-era test referenced CoreConsole's flag-flip timing.
  (4) GAP vs. story-scenes.md SC01 ("A warning labels the core's ward circuits as active"): the
  as-found "warning" phase only tinted the housing and drew a warning-triangle icon — no actual
  label. Added one subtitle system line (`SubtitlePanel.say("", "WARNING: Ward circuits active.")`,
  empty speaker = a system line per its own doc comment) at the start of the warning hold, cleared
  before the interlock-locks phase begins so it never overlaps the Rook/EDEN/Rook exchange. Purely
  additive (no state/timing change) — confirmed via the capture below and by re-running
  test_m5_story.gd/test_m3_foundation.gd after adding it.
  (5) Minor: completion.tscn's TitleLabel was 30px, outside CONVENTIONS.md's "20-28px text" blockout
  rule (bench_panel.tscn's own title tops out at 28) — reduced to 28.
  (6) Documentation: CONVENTIONS.md gained a "Route bot" note for (1), an "Objective / run
  bookkeeping (M5)" subsection under the Session autoload section (objective constants,
  `gems_found()`, `run_meta`/`tick_active_time()`), an `EnvironmentState` entry under the shared
  entity scenes list, a `completion.tscn`/`CompletionScreen` entry under UI scenes, and refreshed the
  now-stale "TEMPORARY M3 marker"/"no player-facing dev toggle" wording on `exit_wicket.gd`'s
  docstring and the `exit_wicket.tscn`/`maintenance_bench.tscn` CONVENTIONS entries to describe the
  real M5 behavior instead of the M3-era placeholder it used to describe.
  (7) New evidence: scenes/debug/m5_demo.tscn + scripts/debug/m5_demo.gd, a bespoke autopilot (not
  RouteBot — it must trigger the real SC01 event and the real exit wicket, which RouteBot's own
  route can drive but this demo does directly for a short, readable capture) that instances the full
  level_01.tscn, teleports the hero to the console, interacts, holds on the warning phase, skips,
  teleports into the already-quarantined A06, then teleports onto the exit wicket to trigger the real
  completion screen.
Files changed: scripts/debug/route_bot.gd, scripts/objects/core_console.gd,
  scenes/levels/areas/a06_exit.tscn (RP15_ToExit position/tolerance round-tripped back to their
  original value after the failed comment-placement experiment — net no-op vs. the starting file),
  scenes/ui/completion.tscn, tests/cases/test_m3_foundation.gd, tests/cases/test_m3_regress_encounters.gd,
  scenes/debug/m5_demo.tscn (new), scripts/debug/m5_demo.gd (new), CONVENTIONS.md, this file.
Checks actually run and outcomes: `tools/test.sh` (with import) -> as found: RESULT: 21/26 passed
  (test_m3_regress_route.gd MAIN/OPT01/OPT02 and test_m5_story.gd T18 all failing with the same
  RouteBot stuck-at-RP15_ToExit symptom, see (1)); after the route_bot.gd fix and the two M3-era
  test updates (see (3)): RESULT: 26/26 passed. `FPS=30 tools/test.sh` -> RESULT: 26/26 passed
  (identical). A 130-frame/12fps windowed capture of the new scenes/debug/m5_demo.tscn -> "frames
  written: 130", zero error/warn/script lines; inspected frames across the sequence: the warning
  phase (housing tinted, warning triangle, "WARNING: Ward circuits active." subtitle, "Enter: skip"
  hint, objective "Inspect the mounted power core."), the post-skip state in A06 (dark quarantine sky
  tint, "Quarantine Exit" sign, objective "Reach the garden wicket.", a "Progress saved" toast from
  the CP04 commit), and the real completion screen (title "Sunnyvale complete.", Active play time
  0:02, Gems found 0/65, Welcome Key/Quickcycle both honestly "Not found"/"Not obtained" for this
  zero-collection demo run, Play again/Quit) — all render correctly.
Timing / machine measurements, if any: none new (M5 part 1 is mechanics/story, not pacing).
Remaining errors / placeholders / unverified gates: Windows export templates not installed (blocks
  M7 only, pre-existing). M5 part 2 (main menu/pause/continue/telemetry builder) is untouched — see
  api_notes below for the exact hooks it should use. HUD's fire-readiness dot/Quickcycle pip remain
  blockout placeholders (M6 scope, pre-existing note). No dedicated scene/unit test exercises
  completion_screen.gd's own button wiring in isolation (T20 drives it through the real
  LevelDirector/level_01 flow, which already proves the transaction end-to-end; a future M6/polish
  pass could add a narrower UI-only test if the screen grows more states).
Design deviations and reasons: none beyond the additive warning-label subtitle in (4) above, which
  is a straightforward reading of story-scenes.md's own SC01 text ("a warning labels the core's ward
  circuits as active"), not a deviation from it.
Save/schema compatibility notes: schema_version stays 1; BUILD is already "sunnyvale-proto-m5"
  (unchanged this session). No new persisted fields — `objective` was already part of
  `Session.default_state()`'s shape from M0/M4, and `run_meta` (play time, deaths) is explicitly
  NEVER persisted (run-only bookkeeping, reset only by `new_run()`/`load_from_snapshot()`) per its
  own doc comment, so CheckpointService's whitelist needs no change for it.
Next concrete action: M5 part 2 (main menu / pause menu / Continue-from-CheckpointService-on-boot /
  a telemetry builder). api_notes for the next agent: `Session.load_from_snapshot(snapshot)` is
  already Continue's exact counterpart to `new_run()` (M4) — a main menu's "Continue" button should
  call `CheckpointService.load_latest()` then, on `ok`, `Session.load_from_snapshot(result.snapshot)`
  before instancing `level_01.tscn`, and `CheckpointService.has_valid_save()` is the button's own
  enabled/disabled gate. A pause menu should gate `Session.tick_active_time()` the same way every
  other modal already does — stop calling it (or check `hero.input_enabled`) while the pause menu is
  open, per Session.tick_active_time()'s own doc comment, which already flags this as the one thing
  a future pause menu must do. `LevelDirector._on_wicket_reached()`/`_on_play_again_confirmed()` are
  the two existing integration points a main menu's own "New Game"/return-to-menu flow will look
  most like. No autoload, signal, or persisted-field contract needs to change for part 2 as scoped;
  a telemetry builder should read `Session.run_meta`/`Session.state` rather than add new signals
  unless a specific metric truly isn't derivable from what's already there.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude (subagent) / M5 part 2 (game flow shell + local
  telemetry)
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M0-M4 and M5 part 1 already verified per the table above;
  09's own uncommitted edit (this file) was the only pre-existing local change noted by the launching
  session; nothing else pre-existing needed fixing.
Implemented behavior: A real game-flow shell replacing the M3-era "Main just boots level_01
  directly" placeholder. (1) `scenes/ui/title_screen.tscn`/`scripts/ui/title_screen.gd`
  (`TitleScreen`): New Game / Continue / Quit; Continue's `disabled` state and its actual behavior
  both key off `CheckpointService.has_valid_save()`/`load_latest()` — a bad primary with a good
  backup already "just works" through the existing fallback (an honest "restored from backup"
  message is shown), and only a fully-invalid save shows a message pointing at New Game, never a
  dead end; New Game asks for confirmation first only when a save already exists. `scripts/main.gd`
  (`Main`) owns the whole Title<->Level transition: adopts `Session.new_run()`/
  `load_from_snapshot(snapshot)` and opens `Telemetry`'s log BEFORE instancing `level_01.tscn` (so
  the level's own first `area_enter` is never a silent no-op), and returns to the title screen on
  `LevelDirector.quit_to_title_requested`. `LevelDirector._ready()` also now checks a loaded
  snapshot's own `story["level_complete"]` and opens the completion screen immediately if it's
  already true, rather than leaving the hero standing next to a trigger that can never fire again.
  (2) `scenes/ui/pause.tscn`/`scripts/ui/pause_menu.gd` (`PauseMenu`), added by `LevelDirector`
  alongside its `Hud`: Resume/Journal/Settings/Restart from checkpoint/Quit to title, entirely via
  `get_tree().paused = true` — deliberately NO other plumbing, since every other node in a level
  (Hero, enemies, `LevelDirector._physics_process`'s own `Session.tick_active_time()` call) already
  uses the engine's default pausable process mode, so pausing the tree is the whole "gameplay stops"
  mechanism for free, exactly what `Session.tick_active_time()`'s own doc comment already asked a
  future pause menu to do. Opens only when `hero.input_enabled` has been true for >=2 consecutive
  physics frames (`_can_open()`), not just "currently true" — see BUG (1) below for why. The
  `journal` action (Tab) opens straight to the Journal view (current objective + a short ~45-word A01
  Welcome Key entry once discovered, written from artifact-catalog.md's own description/location/
  meaning fields in plain factual journal voice per dialogue-and-writing.md, else "1 undiscovered").
  Restart/Quit both show the rollback/loss boundary before a confirm step, same pattern as every
  other confirm view in this project. (3) New minimal `Settings` autoload (`scripts/settings.gd`):
  `subtitles_enabled`, `text_size` (normal/large, `scaled_font_size()` helper — applied to
  SubtitlePanel/Hud's objective label), `reduced_motion` (skips EnvironmentState's one quarantine
  fade-in tween, snaps instantly), `master_volume`/`music_volume`/`sfx_volume` (applied immediately
  to new Master/Music/SFX buses via a new `data/audio/default_bus_layout.tres`, wired into
  `project.godot`'s `audio/buses/default_bus_layout` through `scripts/tools/configure_project.gd`).
  Persisted through two new `CheckpointService` methods, `save_settings(dict)`/`load_settings()`, to
  a SEPARATE `settings.json` — never mixed into the checkpoint/backup pair, never touched by
  `clear()`. (4) New local-only `Telemetry` autoload (`scripts/telemetry.gd`), added to
  `project.godot`'s `[autoload]`: `run_start()` opens one fresh JSONL file per run under
  `user://sunnyvale/playtests/` (test hook `set_playtest_dir()`/`end_run()`, mirroring
  `CheckpointService.set_save_dir()`); `checkpoint_commit`/`upgrade_purchase`/`weapon_swap`/
  `beat_enter` are self-connected to Session's own signals / the existing `BeatHub` in `_ready()`
  (no call-site changes needed anywhere for those four); `area_enter`/`area_exit` (`LevelDirector`,
  crossing detection separate from the camera's own smoothed area tracking), `death`/
  `restart_from_checkpoint` (`LevelDirector`), `sc01_start`/`sc01_end(skipped)` (`CoreConsole`),
  `pause_start`/`pause_end` (`PauseMenu`), `completion(...)` (`LevelDirector._on_wicket_reached()`)
  are each called directly by whoever owns that moment. `encounter_complete(group_id)` needed one
  small new helper, `AreaRoot.get_encounter_groups() -> Dictionary` (group_id -> its own enemy
  entity_ids), which `LevelDirector._ready()` feeds to a new `Telemetry.register_encounter_groups()`
  once per build; a self-connected `Session.enemy_defeated` listener then fires the event the instant
  every member of one group is defeated. New `BranchZone` (`scripts/objects/branch_zone.gd`/
  `scenes/objects/branch_zone.tscn`, structurally identical to `BeatZone` but reporting straight to
  the `Telemetry` autoload) gives `branch_enter`/`branch_exit`: one ENTER/EXIT pair added to
  a02_gardens.tscn around OPT01's existing loft detour and one pair added to a03_roofs.tscn around
  OPT02's existing ledge detour — placed only where the branch's own geometry is reachable, so a
  main-route-only run never trips either, and no existing geometry/route/entity id was touched. (5)
  New `tools/summarize_playtest.py` (python3 stdlib only): reads a JSONL log and prints 07's report
  template fields, including main-route successful-progress time (checkpoint-to-checkpoint
  `t_active` deltas minus branch time — a death/restart's own discarded attempt is excluded for
  free, since `t_active` only ever reaches the NEXT checkpoint's own commit once, via whichever
  attempt actually got there), raw active first-completion time, per-area times, deaths/restarts,
  and gems/upgrade/artifact. (6) `README.md` (new) documents controls, save/settings/playtest-log
  locations (macOS/Windows `user://` paths), and how to run tests. CONVENTIONS.md gained sections for
  `Settings`, `Telemetry`, `BranchZone`, the two new `CheckpointService` settings methods, the new
  `title_screen.tscn`/`pause.tscn` UI scenes, `Main.gd`'s own role, and the exit-wicket/Continue
  interaction.
Files changed: project.godot, scripts/tools/configure_project.gd, data/audio/default_bus_layout.tres
  (new), scripts/settings.gd (new), scripts/telemetry.gd (new), scripts/checkpoint_service.gd,
  scripts/objects/branch_zone.gd (new), scenes/objects/branch_zone.tscn (new),
  scenes/levels/areas/a02_gardens.tscn, scenes/levels/areas/a03_roofs.tscn,
  scripts/levels/area_root.gd, scripts/levels/level_director.gd, scripts/objects/core_console.gd,
  scripts/ui/subtitle_panel.gd, scripts/ui/hud.gd, scripts/world/environment_state.gd,
  scripts/ui/title_screen.gd (new), scenes/ui/title_screen.tscn (new), scripts/ui/pause_menu.gd
  (new), scenes/ui/pause.tscn (new), scripts/main.gd, scenes/debug/m5b_demo.gd (new),
  scenes/debug/m5b_demo.tscn (new), tools/summarize_playtest.py (new),
  tests/fixtures/telemetry_sample.jsonl (new), tests/cases/test_m5_flow.gd (new), README.md (new),
  CONVENTIONS.md, this file.
Checks actually run and outcomes: `tools/test.sh` (with import) -> as-found (before the RouteBot
  race fix in BUG (1) below) intermittently hung/regressed 3-4 pre-existing cases; after the fix,
  final clean runs: `tools/test.sh` -> RESULT: 27/27 cases passed (test_m5_flow.gd 50 checks,
  test_m5_story.gd 65 checks unchanged, every M0-M4 case unchanged); `FPS=30 tools/test.sh` ->
  RESULT: 27/27 cases passed (test_m5_flow.gd's own check count varies slightly by fps, 48-50, since
  it counts one check per Telemetry event actually logged in a short scripted run — every named
  contract check passed identically). A 120-frame headless `--quit-after 120` launch of the real
  `res://scenes/main.tscn` -> zero errors/warnings (title screen boots cleanly). A 110-frame/15fps
  windowed capture of the new `scenes/debug/m5b_demo.tscn` (drives the REAL Main/TitleScreen/
  PauseMenu flow: New Game -> real gameplay -> the `journal` action opens the real pause menu's
  Journal view -> Settings view -> Back -> Resume) -> zero errors/warnings; inspected frames across
  the sequence: the title screen, real gameplay with the HUD, the Journal view (objective + "1
  undiscovered" artifact line, world visibly dimmed/paused behind it), and the Settings view (all six
  controls) all render correctly. That same capture's real (non-test) run also left a genuine
  `user://sunnyvale/playtests/*.jsonl` log (`run_start`/`area_enter`/`pause_start`/`pause_end`) which
  `tools/summarize_playtest.py` read without error — confirming the pipeline end to end outside the
  test harness, not just inside it. `tools/summarize_playtest.py` was also verified directly against
  a hand-computed synthetic fixture (`tests/fixtures/telemetry_sample.jsonl`): main-route
  successful-progress time 185.0s, optional branch time 15.0s, raw active first-completion 200.0s,
  area times 90/60/40s — all matching a hand calculation before the script was ever run.
Timing / machine measurements, if any: none new (M5 part 2 is a UI/telemetry shell, not pacing) —
  the telemetry pipeline that WILL produce these for a future real playtest is exactly what this
  session built and verified end to end.
Remaining errors / placeholders / unverified gates: Windows export templates not installed (blocks
  M7 only, pre-existing). "Menu time" as its own logged event was deliberately NOT added — pause/
  journal/settings are all sub-views of the one pause modal, so `pause_start`/`pause_end`'s own
  interval already covers it; `summarize_playtest.py` reports it under "Pause/loading/extended
  reading". HUD's fire-readiness dot/Quickcycle pip remain blockout placeholders (M6 scope,
  pre-existing note). Settings' `text_size`/`reduced_motion` are wired to a genuinely small surface
  (SubtitlePanel, Hud's objective label, EnvironmentState's one tween) rather than every HUD element,
  per the task's own "minimal now; M6 extends" framing. No dedicated test exercises PauseMenu's
  Settings-view controls' own button wiring in isolation (the capture above proves the view renders
  and opens/closes correctly; a future M6/polish pass could add a narrower UI-only test if the screen
  grows more states, matching the same pre-existing note already on CompletionScreen).
Design deviations and reasons: none from the M5 part 2 brief. One pre-existing behavior was
  clarified rather than changed: "New Game when a save exists asks for confirmation before replacing
  the run" is implemented as an immediate `CheckpointService.clear()` on confirm (mirroring
  CompletionScreen's own "Play again" precedent exactly), not a passive "it'll get overwritten
  eventually" — this reads truest to "replacing the run" and keeps a later Continue from ever finding
  stale pre-New-Game data.
Save/schema compatibility notes: schema_version stays 1; `Session.default_state()`'s shape and
  `CheckpointService.validate_snapshot()`'s whitelist are BOTH unchanged — settings live in a wholly
  separate file this service also now owns (`save_settings`/`load_settings`, no schema/whitelist,
  just DEFAULTS-merge-on-load) and Telemetry never touches either file.
Next concrete action: M6 (presentation pass — real art/animation over the blockout, HUD's
  fire-readiness dot/Quickcycle pip, PauseMenu Settings-view polish, subtitle/text-size studies per
  interface-and-accessibility.md's "Required later screen studies"). api_notes for the next agent:
  `PauseMenu`/`TitleScreen` are both plain `Control`/`CanvasLayer` blockout scenes ready for a visual
  pass without touching their scripts' public surface (signals/`_view` states are stable). Telemetry
  events are additive-only by design — a new event type is just another `_write()` call, never a
  change to an existing one, so a future analytics need should extend, not restructure, this file.
  BUG found and fixed this session (not present before): `PauseMenu` opening the instant
  `hero.input_enabled` becomes true can race a same-tick modal close — RouteBot's own
  `dismiss_modal` state presses `pause` to back out of BenchPanel/SwapConfirm, and if THAT press's
  edge is also seen by `PauseMenu` on the very frame the modal's own poll already re-enabled
  `hero.input_enabled`, the tree pauses and RouteBot (default process mode) freezes forever, since it
  stops processing while paused and its own `while bot.running: await physics_frame` loop then never
  advances. Fixed generically in `pause_menu.gd`: `_can_open()` now requires `hero.input_enabled` to
  have been true for >= 2 consecutive physics frames (`OPEN_READY_FRAMES`), not just "true right
  now" — this also happens to satisfy "pause is unavailable during the few frames of a respawn
  transition" from the M5 part 2 brief, for free. Confirmed via `tools/test.sh`/`FPS=30 tools/test.sh`
  both returning to 27/27 after the fix (as-found intermittent regressions in test_m3_regress_route.gd/
  test_m4_state_contracts.gd disappeared). LESSON for future GDScript test-writing in this project:
  a lambda captures an outer local variable BY VALUE in this Godot version (confirmed with a
  throwaway repro script) — reassigning it inside the lambda (`func(): count += 1`) never changes
  the enclosing function's own variable. `tests/cases/test_m5_flow.gd` works around this by boxing
  the captured value in a single-element Array (`var box: Array = [0]`, lambda does `box[0] += 1`,
  the enclosing scope reads `box[0]`) — the same trick should be used by any future test that needs
  a signal callback to report back into its own scope.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M4/M5 adversarial review fixes
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M0-M5 (both parts) previously verified. An adversarial
  review of M4/M5 (19 findings: 9 tagged ADV-01..ADV-09 plus F1/F2 and five visual/hygiene findings)
  had already added one failing `tests/cases/test_probe_adv_*.gd` probe per ADV-0x finding, each
  reproducing the bug live against a real LevelDirector/Session/CheckpointService, before this pass
  started. This pass verified every finding against the live code (reviewers can be wrong), fixed
  every real bug found, converted every probe that exposed a real bug into a permanent
  `test_m4_regress_*.gd`/`test_m5_regress_*.gd` case, and rejected/deferred the rest with reasons.
Implemented behavior / fixes this pass:
  ADV-01 (major, real): CoreConsole._hold() treated `pause` as a second skip action for SC01, so
    Escape during the level's one story scene irreversibly committed CP04 instead of pausing it.
    Fixed: `_hold()` now checks ONLY `skip`, and stops counting down while `get_tree().paused` (it
    awaits the tree's own `physics_frame` signal, which fires regardless of pause, so this needed an
    explicit guard). New `Session.cutscene_active` (live-only, set only around `_run_sc01()`) lets
    `PauseMenu._can_open()` open even though SC01 disables `hero.input_enabled` for its whole run, so
    `pause` now genuinely suspends the scene (story-scenes.md "Pause suspends scene playback").
    RouteBot's `dismiss_modal` state now tries `skip` first and only falls back to `pause` after
    `DISMISS_PAUSE_DELAY` (0.25s) — trying both at once was found, by reasoning through frame
    ordering, to risk PauseMenu opening on the very press meant to skip SC01 and permanently stalling
    the bot; skip-first avoids that race entirely rather than relying on timing luck.
  ADV-02 (major, real): tools/summarize_playtest.py's main-route successful-progress time summed
    checkpoint-to-checkpoint `t_active` deltas raw, so a rolled-back death attempt's time was never
    excluded (`t_active` is never rolled back on death) and the very first segment (run start to
    CP01) was silently dropped (the real game never emits a "CP00" checkpoint_commit). Fixed:
    boundaries now start at `run_start`'s own `t_active`, and each segment only counts from the LAST
    death/restart_from_checkpoint inside it (if any) to the checkpoint that closed it. Removed the
    fixture's fake CP00 commit and corrected test_m5_flow.gd's expected fixture total from the wrong
    185.0s to the correct 135.0s (07's own definition).
  ADV-03 (major, real): "Play again" -> `Session.new_run()` never told the always-on `Hud` (never
    recreated — LevelDirector only rebuilds Areas) to refresh, so it kept showing the ended run's
    weapon tag/Quickcycle pip. Fixed with a new `Session.run_reset` signal, emitted at the end of
    `new_run()`, that `Hud` also listens to.
  ADV-04 (major, real): Declining (or Escape-ing) the weapon-pad swap dialog still showed "Weapon
    swapped" — `SwapConfirm.closed` carried no information about whether a swap happened. Fixed:
    `closed(swapped: bool)`, set from `Session.swap_weapon().ok`; `WeaponPad` only toasts when true.
  ADV-05 (major, real): the title's New Game confirmation promised "This will replace your current
    run once you save again", but `Main._on_new_game_confirmed()` calls `CheckpointService.clear()`
    immediately. Fixed the TEXT (04's own Save design already allows confirmation to replace the run
    outright): "Start a New Game? Your saved run will be deleted."
  ADV-06 (minor, real): tools/summarize_playtest.py's pause_time() (and a redundant subtraction
    inside main_route_progress_time()) diffed `t_active` across a pause, which is always exactly 0
    (LevelDirector's own `_physics_process` — the only thing that ticks `t_active` — doesn't run at
    all while `get_tree().paused`). Fixed pause_time() to use `t_wall` instead, and removed the
    always-0 `t_active` subtraction from main_route_progress_time() (redundant: a
    checkpoint-to-checkpoint `t_active` delta already excludes pause time for free, for the same
    reason).
  ADV-07 (minor, real, larger than reported): `CheckpointService.validate_snapshot()` accepted a
    tampered third weapon instance, the same instance both held and on a pad, a deleted world weapon,
    an out-of-range upgrade stage (allowed up to 3; only stage 1 is purchasable), an extra top-level
    field, a negative collected-gem value, an absurd wallet (1e300), and health 0. Fixed with new
    whitelists/checks: `equipped_weapon` + `world_weapons` must together account for EXACTLY the two
    known instances once each; pad ids must be the one real pad; upgrade stage clamped to 0..1;
    top-level keys restricted to `Session.default_state()`'s own set; wallet clamped to 0..65 (the
    level's total collectible gem value, compared as float BEFORE casting to int so an out-of-range
    float like 1e300 can't be narrowed first); health clamped to 1..MAX_HEALTH. Also found (not in
    the original report, via the probe's own follow-up check): even with validation fixed,
    `Hero.take_damage()` used a bare `Session.get_health() <= 0` check as an "already dead" gate,
    which would have permanently blocked all future damage on a hero that somehow started at 0
    health (e.g. a snapshot that bypassed validation via `Session.load_from_snapshot()` directly).
    Fixed to gate on `_died_emitted` (this hero instance actually died and hasn't been respawned)
    instead, which keeps test_m1_damage.gd's existing "already-dead hero refuses further hits until
    respawn" contract intact while no longer confusing a fresh hero's starting health with that state.
  ADV-08 (minor, real): `save_snapshot()` rotated the current primary to backup unconditionally, so
    one corrupt primary followed by one more save destroyed the only remaining last-known-good copy.
    Fixed: rotate to backup only when the current primary is itself a valid, loadable snapshot.
  ADV-09 (minor, real): `Session.run_meta["active_seconds"]` was never persisted, so a completed
    save's Continue always showed "Active play time: 0:00". Fixed with a new `active_seconds` schema
    field (float, part of `Session.default_state()`/`validate_snapshot()`'s whitelisted shape) that
    `commit()`/`purchase_upgrade()` mirror the live counter into on every successful commit;
    `load_from_snapshot()` seeds `run_meta["active_seconds"]` from it only when the loaded story's
    `level_complete` flag is already true (an ordinary mid-run Continue still starts at 0, unchanged).
    test_m5_story.gd's T16 (normal-vs-skip SC01 produce an identical committed snapshot) now excludes
    this one field from that comparison, since it is legitimately different between a ~21s
    watch-through and an near-instant skip and was never part of the STORY state T16 proves.
  sc01-double-toast (major, real): CoreConsole's own SC01-completion toast and the HUD's generic
    "Progress saved" toast (from the same CP04 commit) fired at the same instant, in unrelated
    screen positions, and the CoreConsole toast (a plain white Label) had poor contrast against a
    light sky background. Fixed: Hud suppresses its generic toast specifically for CP04 (CoreConsole
    already shows a more specific one), and `ToastLabel` (shared by every world-object toast) now
    draws a dark backing plate (matching SubtitlePanel's own look) behind its text unconditionally.
  weapon-pad-toast-overlap (major, real): WeaponPad's "Weapon swapped" toast and its own
    resting-instance tag draw call landed almost on top of each other. Fixed by moving the toast
    higher (offset_top -70->-96, offset_bottom -44->-70).
  m4-demo-stale-vs-sc01 (major, real): `m4_demo.gd` only waited 0.5s after the console interact
    before walking to the bench, which was correct for M3's instant-flip stub but M5 replaced it with
    a real ~19s skippable SC01 scene — the hero stayed frozen at the console for the whole capture.
    Fixed by pressing `skip` right after interacting, matching m5_demo.gd's own pattern.
  debug-demos-touch-real-save (CRITICAL, real): none of `m4_demo.gd`/`m5_demo.gd`/`m5b_demo.gd`
    (unlike `tests/run_tests.gd`, which redirects the whole automated suite) redirected
    `CheckpointService` away from the default save dir, so a capture run could delete/overwrite the
    real player's save (`m5b_demo.gd` drives Main's real New Game path, which calls
    `CheckpointService.clear()`). Fixed: every `scripts/debug/*_demo.gd` that touches
    Session/CheckpointService (`m3_a01`/`a02`/`a03`/`a05`/`a06`_demo.gd, `m3_route_demo.gd`,
    `m4_demo.gd`, `m5_demo.gd`, `m5b_demo.gd`) now calls
    `CheckpointService.set_save_dir("user://debug_demo_throwaway/<name>")` as the very first line of
    `_ready()`; new hard rule recorded in CONVENTIONS.md so a future demo author doesn't reintroduce
    this. Fixing this exposed one more real bug in `m5b_demo.gd`: it assumed New Game always shows a
    confirmation view (true when a stale save exists in the demo's own OLD, unredirected default
    dir) and read `title._view` unconditionally afterward; with a guaranteed-empty throwaway dir, New
    Game skips the confirm view and Main frees `title` synchronously, so that read hit an
    already-freed node. Fixed with an `is_instance_valid(title)` guard.
  depot-sign-text-cropped (minor, real, broader than reported): A05's "MAINTENANCE DEPOT" entry sign
    read as "MAINTENA..." because `Scenery._draw_sign()` drew at a fixed 14px font truncated to the
    board's width. Measured `Font.get_string_size()` directly (headless one-off script) and found
    this affects EVERY long sign text at the common 90x60 box size, including A02's own "L01-A02
    Front Gardens" (154px wide, even more than "MAINTENANCE DEPOT"'s 151px, in an 82px-available
    box) — not unique to the depot. Fixed generically: `_draw_sign()` now shrinks its font (down to a
    9px floor) until the text actually fits, and additionally widened A05's EntrySign specifically
    (90->140px) since even a 9px font could not fit "MAINTENANCE DEPOT" in the original box width —
    confirmed by recapture that it now reads in full at a comfortable 12px.
Findings rejected (not real bugs, or already fixed before this pass): F1 (README milestone summary
  was genuinely stale vs. 09's own table — fixed, see README.md/this file). "m4-demo-stale-vs-sc01"'s
  underlying claim about M4's OWN capture (taken before SC01 existed) was not re-litigated; only the
  demo script's CURRENT behavior was fixed.
Findings deferred: F2 (T21's subtitle-readability/window-resize acceptance halves have no automated
  or captured-evidence coverage) — left as an honestly-disclosed gap scoped to M6 (presentation),
  per the finding's own suggested resolution; it is a coverage gap, not a functional defect, and
  adding real resize-based visual-legibility coverage is a presentation-pass task, not a cheap fix.
Files changed: scripts/objects/core_console.gd, scripts/ui/pause_menu.gd, scripts/session.gd,
  scripts/debug/route_bot.gd, scripts/ui/hud.gd, scripts/objects/weapon_pad.gd,
  scripts/ui/swap_confirm.gd, scenes/objects/weapon_pad.tscn, scripts/world/toast_label.gd,
  scripts/checkpoint_service.gd, scripts/actors/hero.gd, tools/summarize_playtest.py,
  tests/fixtures/telemetry_sample.jsonl, tests/cases/test_m5_flow.gd, tests/cases/test_m5_story.gd,
  scenes/ui/title_screen.tscn, scripts/debug/m4_demo.gd, scripts/debug/m5b_demo.gd,
  scripts/debug/m3_a01_demo.gd, scripts/debug/m3_a02_demo.gd, scripts/debug/m3_a03_demo.gd,
  scripts/debug/m3_a05_demo.gd, scripts/debug/m3_a06_demo.gd, scripts/debug/m3_route_demo.gd,
  scripts/debug/m5_demo.gd, scenes/levels/areas/a05_depot.tscn, scripts/objects/scenery.gd,
  CONVENTIONS.md, README.md, this file. Renamed 6 `test_probe_adv_*.gd` files (each a confirmed real
  bug) to `test_m4_regress_*.gd`/`test_m5_regress_*.gd` permanent regression cases; deleted
  `test_probe_adv_title_newgame.gd` (its scenario is now covered, with corrected expectations, by the
  new `test_m5_regress_title_newgame_honesty.gd`); no `review_*.tscn` debug scenes were found in the
  repo to delete (evidently kept only in the reviewer's own scratchpad, per this project's own
  capture convention).
Checks actually run and outcomes: `tools/test.sh` -> RESULT: 34/34 cases passed. `FPS=30
  tools/test.sh` -> RESULT: 34/34 cases passed, same PASS lines. A 120-frame headless `--quit-after`
  launch of `res://scenes/main.tscn` produced zero errors/warnings. Recaptured
  `scenes/debug/m4_demo.tscn` (170 frames/12fps), `scenes/debug/m5_demo.tscn` (130 frames/12fps),
  `scenes/debug/m5b_demo.tscn` (110 frames/15fps), and `scenes/debug/m3_a05_demo.tscn` (40
  frames/10fps) — zero error/warn/script lines from any of them. Inspected frames confirm: a single
  legible "EDEN awakens..." toast (no competing "Progress saved") with a dark backing plate on SC01
  completion; the bench panel and pad swap dialog both still reached and fully functional after
  SC01; the weapon-pad toast no longer overlaps the resting-tag text; "MAINTENANCE DEPOT" reads in
  full, no longer cropped, with no new overlap with neighboring props; the title screen, real
  gameplay HUD, pause menu Journal view, and Settings view all still render correctly end to end
  through `m5b_demo.tscn`'s real button-press sequence after the debug-demos-touch-real-save fix.
Timing / machine measurements, if any: none new this pass (no tuning numbers changed).
Remaining errors / placeholders / unverified gates: unchanged from M5 part 2's own entry (Windows
  export templates; M6/M7 not started). F2 (T21 resize/readability coverage) remains open, deferred
  to M6 as noted above.
Design deviations and reasons: ADV-01's fix is a genuine behavior change from what M5 part 2 shipped
  (pause used to double as SC01's skip; it no longer does) — this was always the design intent per
  story-scenes.md/interface-and-accessibility.md, which M5 part 2 had misread as one convention
  rather than two; RouteBot's own `dismiss_modal` state was updated in the same pass so its existing
  A05 traversal keeps working unmodified. ADV-07's wallet upper bound (65) and weapon-stage upper
  bound (1) are read directly from existing project constants (the completion screen's own "/ 65"
  and CONVENTIONS.md's "only Quickcycle stage 1 purchasable" hard rule), not new design decisions.
Save/schema compatibility notes: `Session.default_state()`/`CheckpointService.validate_snapshot()`
  gained one new field, `active_seconds` (float, default 0.0) — schema_version was NOT bumped, since
  this prototype has no shipped saves to stay compatible with and CONVENTIONS.md's own versioning
  note treats the whitelist as authoritative over the raw version int; any old on-disk save from
  before this pass is missing the field and will now be rejected by `validate_snapshot()`'s exact-
  key-set check (same as any other schema change in this project) rather than silently misread.
Next concrete action: M6 (presentation pass) — unchanged from M5 part 2's own next action; this pass
  was a review/fix pass on already-implemented M4/M5, not new milestone work.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M6 presentation pass — integration
  and verification
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M0-M5 previously verified. Four M6 workstreams had already
  run in parallel and landed their own files before this pass started: (1) audio infrastructure (new
  `Audio` autoload, `tools/gen_audio.py`, 34 SFX + 2 music `.wav`s, `test_m6_audio.gd`); (2)
  characters (Hero/Resident/Clipper C11 visuals, `scripts/actors/visuals/*.gd`,
  `tools/derive_character_sprites.py`, `scenes/debug/m6_characters_demo.tscn`); (3) environment
  (Block/Scenery C11 redraw, new per-area `area_backdrop.gd` parallax layers, a new Scenery `GATE`
  kind); (4) fx/UI (Scrapjack/effects C11 visuals, `ui_move`/`ui_confirm`/`ui_back` call sites, the
  shared `c11_theme.tres` applied to the remaining blockout-styled UI scenes, `test_m6_ui.gd`). This
  pass's job (per prototype-plans' own M6/M7 split) was to integrate these four passes, resolve any
  conflicts/gaps between them, and produce the M6 verification evidence (readability captures,
  performance numbers, the asset inventory, this log entry) — not to author new visual style.
Implemented behavior / fixes this pass:
  Two real audio-cue gaps, orphaned because no single parallel agent's ownership list covered the
    file: `scripts/actors/hero.gd` had no call site for the `interact` cue (assigned to it in
    CONVENTIONS.md's cue table but outside the characters agent's explicit "9 cues" scope) — added
    one `Audio.play_sfx(&"interact", global_position)` at `_highlighted.interact(self)`.
    `scripts/objects/core_console.gd` (SC01) was in no parallel agent's ownership list at all: it
    still had zero `Audio` calls (`eden_chime`/`alarm` both unwired) and its outline constant was
    still the pre-M6 blockout purple `#2b2233`. Added `alarm` on the ward-circuits warning line
    (plays even without a `SubtitlePanel`, matching the cue's own nature) and `eden_chime` alongside
    EDEN's subtitled line; migrated `OUTLINE` to the warm-charcoal C11 token `#332a20` already used
    by `scrapjack.gd`/`practice_target.gd`. No SC01 timing/state logic touched.
  One real visual bug found while reviewing the characters-pass evidence: the Scrapjack's new M6
    workshop-tag text (`scrapjack.gd _draw()`) rendered mirrored/rotated into unreadable glyphs
    whenever the weapon's PRE-EXISTING (M1-era) aim-pivot rotate+flip-to-stay-upright mechanic
    (`hero.gd _update_aim_pivot()`, unchanged) pointed the gun anywhere other than straight right —
    the flip that correctly keeps the GUN SILHOUETTE looking right-side-up also mirrors any text
    drawn in the same local space. Fixed by drawing the tag through a corrective
    `draw_set_transform_matrix(global_transform.affine_inverse() * Transform2D(0.0, desired_global))`
    so it renders at a fixed on-screen position with zero inherited rotation/scale, while the
    housing/muzzle-flash/ground-shadow drawing above it is completely untouched (still rotates/flips
    with the weapon, which is correct). Verified visually: a `characters_m6_demo` recapture shows
    "P01" upright and legible while aiming left, where the pre-fix capture showed reversed/garbled
    glyphs.
  Checked for, and ruled out, two plausible cross-pass conflicts named in the integration brief:
    (a) a possible audio double-play where `scrapjack.gd`'s own muzzle-clamp instant-resolve path
    AND `scrap_bolt.gd`'s travel-resolve path both play `bolt_hit`/`bolt_blocked` — confirmed
    mutually exclusive (the clamp path `return`s before a bolt is ever spawned, so one shot never
    plays the cue twice); (b) a possible z-order clash between the new per-area `Parallax2D`
    backdrops and Scenery/actors/HUD — confirmed backdrops sit at `z_index` -80/-60 (behind
    Scenery's already-established -10) and HUD is a separate `CanvasLayer`, so no clash exists.
    Documented both findings in `CONVENTIONS.md`'s cue table and `reports/asset-inventory.md`
    instead of making unnecessary changes.
  Added three narrowly-scoped, env-var-gated additions to existing debug/capture scenes, used only
    for this pass's own evidence and with zero effect otherwise: `M6_REDUCED_MOTION=1` /
    `M6_MUTED=1` on `scripts/debug/m3_route_demo.gd` and `scripts/debug/m6_characters_demo.gd`
    (`Settings.set_reduced_motion(true)` / `Settings.set_master_volume(0.0)` — the same setters the
    real Settings UI calls) and `M6_PERF_LOG=1` on `m3_route_demo.gd` (prints one real-time
    `Engine.get_frames_per_second()` sample per second to stdout). No physics/state-machine/
    hitbox/collision code was touched anywhere in this pass.
  Confirmed the missing-`.import` problem the environment agent's own report had flagged mid-pass
    (`clipper_body_2x.png`/`resident_full_2x.png` referenced by `clipper.tscn`/`resident.tscn` before
    their `.import` files existed) had already resolved itself by the time this pass started — all
    six `assets/characters/*.png` and their `.import` files are present and the fresh-import full
    suite passes cleanly with no "No loader found"/parse errors.
Checks actually run and outcomes: `tools/test.sh` (fresh import, not NOIMPORT) -> RESULT: 36/36 cases
  passed, both before and after every fix in this pass. `FPS=30 tools/test.sh` -> RESULT: 36/36 cases
  passed. Filtered `tools/test.sh m1`/`m2` re-run immediately after the `scrapjack.gd` draw fix (the
  file M1's own weapon tests exercise) -> 7/7 and 5/5. A 120-frame headless `--quit-after` launch of
  `res://scenes/main.tscn` -> zero errors/warnings (only the boot print line). A 60-frame/30fps
  windowed Movie-Maker capture of `res://scenes/main.tscn` -> zero errors/warnings; title screen
  renders in the full C11 palette (cream panel, peach buttons, teal heading, sky-blue background),
  Continue correctly disabled with no save present. Readability captures (all zero errors/warnings
  during capture): `m3_route_demo.tscn` full main route (800 frames/8fps, ~97s bot run) x3 —
  normal, `M6_REDUCED_MOTION=1`, and `M6_MUTED=1`; `m2_demo.tscn` combat (300 frames/12fps);
  `m4_demo.tscn` depot bench+pad (300 frames/12fps); `m5_demo.tscn` SC01+completion (400
  frames/10fps); `m6_characters_demo.tscn` Hero/Resident/Clipper showcase (400 frames/12fps, run
  twice — once before and once after the tag-mirroring fix, to prove it); `m2_resident_solo.tscn`/
  `m2_clipper_solo.tscn` (200 frames/12fps each); `m6_resolution_probe.tscn` at 960x540/1280x720/
  2560x1080 (hud/bench/swap screenshots at each size, 9 total). Grayscale contact sheets built from
  each and reviewed alongside individual full-resolution frames at the 07-listed checkpoints (first
  Resident warning/approach, Clipper stall with the exposed-motor overlay and its charge/health bar,
  the A03 rooftop terraces, the A04 mixed Resident+Clipper square lane, the A05 depot bench dialog,
  and A06's desaturated teal "transformed exit" quarantine look behind the completion screen):
  silhouettes stay distinct, the warning-triangle/charge-bar cues read by shape (not color/audio
  alone), gems/platform edges/the hero's feet are never occluded by any prop, and the reduced-motion
  and muted-audio variants show the identical readable frame content as normal (motion/audio being
  the only difference, as intended). Real-time performance: a windowed (no `--write-movie`, so
  simulation runs at genuine wall-clock speed) run of `m3_route_demo.tscn` with `M6_PERF_LOG=1` for
  ~68 seconds on this machine (`system_profiler SPHardwareDataType`: MacBook Pro, Apple M1 Pro, 8
  cores (6P+2E), 16GB) logged one FPS sample per second; frame_ms min/avg/max across 68 samples (the
  first warm-up sample dropped) = 4.05 / 7.05 / 12.66 ms, i.e. roughly 79-247 fps uncapped —
  comfortably under the 60fps/16.6ms budget at every sampled point. This is a target/observation for
  this one development machine (per the task's own instruction), not a claimed universal minimum.
Remaining errors / placeholders / unverified gates: see `reports/asset-inventory.md` §4 for the full
  list (procedural hero with no approved concept sprite; no frame-by-frame hand animation anywhere,
  only procedural transforms; synthesized-not-composed audio; Resident/Clipper mirrored-facing
  asymmetry from flipping a single-orientation source photo; static Clipper wheels; a handful of
  world-object scripts, e.g. `weapon_pad.gd`/`gem.gd`/`service_walkway.gd`/`kill_plane.gd`/
  `moving_platform.gd`, still use the older `#2b2233` outline tone rather than the newer `#332a20`
  C11 token — a minor cosmetic hue inconsistency, not a readability regression, left alone rather
  than risking a broad low-value recolor across files this pass did not have dedicated visual
  evidence for; no automated pixel-measured hitbox/sprite alignment tool). Windows export templates
  and M7 itself remain not started, unchanged from every prior entry.
Design deviations and reasons: none beyond what `reports/asset-inventory.md` §4 already documents
  from the three parallel passes (Clipper eye-stalks/blades as redrawn vector overlays rather than
  literal cut layers; Resident WINDUP/LUNGE as a procedural vector redraw rather than a photo
  overlay; both derived sprites mirrored for their opposite facing; Parallax2D left at its default
  `scroll_scale=(1,1)` after a real engine quirk was found and worked around, with depth instead
  conveyed by z_index/overlap/contrast). This pass's own three fixes (interact/eden_chime/alarm cue
  wiring, core_console outline token, scrapjack tag transform) are corrections to reach what the
  parallel passes' own design intent already was, not new deviations.
Save/schema compatibility notes: none — no `Session`/`CheckpointService` schema field changed in
  this pass.
Next concrete action: M7 (validation/export) — M6 is now verified end to end; M7 needs Windows
  export templates and real first-time-player timing data per the plan's own outstanding
  prerequisites (see above).
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M6 adversarial review fixes
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: M0-M6 previously verified (see the M6 integration entry
  above). A separate adversarial review pass produced 17 findings (2 critical, 8 major, 7 minor)
  against the M6 presentation work; this entry verifies each one and fixes the real bugs, visual
  nodes/audio calls only, per the review's own hard constraint (no collision shapes, layers, physics
  tuning, attack timings, state machines, IDs, or game rules touched).
Findings verified and fixed (id: what was wrong -> what changed):
  AD-01 (critical): `clipper_visual.gd`'s STALL glow/hatch overlay was anchored to the painted
    gearbox's photo position (`MOTOR_LOCAL = (41.2, -45.7)`), which overlapped `clipper.gd`'s real
    `RearHitZone` (centered at `(24, -26.4)` in the same space) by only a few px in one corner — a
    shot aimed at the visible "exposed motor" cue would mostly miss the zone that actually resolves
    it. Re-anchored `MOTOR_LOCAL` to `(24.0, -26.4)` (RearHitZone's own center) and shrank the
    glow/core radii (11/7 -> 9/6) to stay inside the zone's 20x32 half-extents. No collision/hit-zone
    change; `RearHitZone`'s own position/size in `clipper.gd` is untouched.
  AD-02 (critical): `tools/derive_character_sprites.py`'s border flood-fill background removal
    leaked through thin near-background-colored seams (a highlight streak on the Resident's jacket
    collar) into the Resident's cream shirt, and through the Clipper's open shear-arm linkage into
    four ivory-toned body panels (front accent band, front-wheel hub disc, eye-mount panel, rear
    motor guard) — all rendered as holes showing the sky through the character in game. Fixed with a
    morphological "open" (erode-then-dilate, `OPEN_RADIUS = 2`) on the background candidate mask
    before flooding (snaps shut seams narrower than 5px without touching wide legitimate background,
    e.g. the Clipper's door-handle loop) plus four hand-picked `CLIPPER_PROTECT_BOXES` (same
    by-eye-against-a-grid technique the file already used for the eye/shear erase regions) that force
    those four ivory panels opaque regardless of color distance. Also cropped out a baked cast shadow
    under both sprites' feet/wheels (survived color-distance removal as a shaded, not flat, blend) via
    the existing `erase_region()` helper on two new hand-picked boxes. Re-ran the script to regenerate
    `assets/characters/{resident_full,clipper_body,clipper_full}_{1x,2x}.png` — verified byte-for-byte
    reproducible, no third-party/downloaded pixels, concept-art/ untouched (read-only). Verified by
    compositing the new cutouts on a solid test color and inspecting by eye (scratchpad only, not
    committed) before and after.
  AD-03 (major): `resident_visual.gd`'s WINDUP/LUNGE procedural redraw was bare rectangles/circles
    with no hair, face, or footwear, popping in as an off-model box figure against the detailed photo
    cutout. Added a hair cap (new `HAIR`/`SLIPPER` consts picked by eye from the approved concept art,
    since z01-resident.md's own palette table doesn't give these two an exact hex), a small face mark,
    and outlined slippers/limbs; kept the exact same timing/lean/raised-arm logic.
  AD-04 (major): the shear blades were thick `RUBBER`-colored lines (read as black rods, not steel)
    and the eye stalks had no housing; both were drawn in `Visual`'s un-rotated local space while the
    body `Photo` sprite rotates during WINDUP/CHARGE lean, so they visibly detached from the shell.
    Redrew each blade as a filled, outlined, tapered `STEEL`/`STEEL_SHADOW` polygon (one cel-shadow
    facet) and gave each eye a ribbed stalk plus an `IVORY` housing ring; both now draw under the same
    `draw_set_transform(pivot, rotation, ...)` the body's own lean uses, so they stay glued to it.
  AD-05 (major): both warning triangles (`resident.gd`, `clipper.gd`) pulsed alpha 0.2-1.0 with no
    outline stroke, measuring under 1.5:1 contrast against sky/lawn/wall backdrops. Never below 0.9
    alpha now, plus a 2px warm-charcoal outline on the triangle itself; the Clipper's triangle was
    also raised from `-HEIGHT-30` (inside its own ~80px sprite, paintable-over by the child Visual's
    eye-stalk overlay) to `-HEIGHT-48`.
  AD-06 (major): `clipper.tscn`'s root had no `z_index` (resident.tscn's already had `z_index = 1`),
    so draw order followed tree order — the hero could stand in front of a stalled Clipper and fully
    hide the exposed rear motor. Added `z_index = 1` to the Clipper root, matching the Resident.
    Rendering-only; no collision/layer change.
  AD-07 (major): `scrapjack.gd` drew the held instance's workshop tag ("P01") unconditionally, so it
    rendered on the hero's chest in every gameplay frame (duplicating the HUD's own tag). Gated the
    draw behind `not held`, so it only ever shows on a resting ground/pad instance as
    weapon-swaps.md intends; the held gun's tag stays HUD-only. The existing anti-mirroring transform
    fix for the tag text is untouched.
  AD-09 / AD-17 (major/minor): `tutorial_prompt.tscn`'s prompt, `clipper.tscn`'s `HintLabel`, and
    `subtitle_panel.tscn`'s "Enter: skip" hint were all plain white text with no outline (measured
    1.02-1.43:1 contrast on sky/lawn/wall). Added the HUD's own outline treatment
    (`font_outline_color = #332a20`, `outline_size = 4`) to all three.
  AD-10 (major): `scenery.gd`'s diagnostic ceiling PANEL filled with plain SKY plus a lightened
    top-edge band — the exact "bright top strip on a rect" cue `block.gd`'s own GROUND/PLATFORM/depot-
    floor draws use for a walkable surface top, on a non-walkable prop at hero height. Desaturated the
    fill toward a cooler ceiling-metal tone and dropped the top-edge band entirely. Separately, the
    CLOUD_PROJECTOR's projected clouds filled with SKY on a sky-colored backdrop (invisible except for
    an outline hairline); changed the fill to CREAM so they're actually visible.
  AD-11 (major): `bench_panel.gd` showed "40 gems (wallet 0 -> -40)" whenever funds were short. Now
    shows "Need 40 gems (you have 0)" when `wallet < PRICE`; the successful-purchase projection text
    is unchanged.
  AD-13 (major): `m5b_demo.gd` is the only debug demo that instances the real `Main` scene (which
    calls `Telemetry.run_start()`); it redirected `CheckpointService` but not `Telemetry`, so every
    capture run wrote a real playtest log into the actual player's default `user://sunnyvale/
    playtests/` directory. Added `Telemetry.set_playtest_dir("user://debug_demo_throwaway/m5b_demo/
    playtests")` before instancing Main, matching the existing `CheckpointService` redirect. Left the
    stray real log files this bug had already written untouched — see "Remaining errors" below.
  AD-14 (minor, partial): audio-direction.md calls for a distinct failed-purchase cue;
    `bench_panel.gd` played the same `ui_confirm` success chime on every purchase attempt regardless
    of outcome. Changed the refusal path to play the existing `ui_back` cue instead (no new audio
    asset needed). The broader ask (a cue-priority/ducking pool, dropping the redundant `interact` cue
    when a target plays its own) touches many call sites across the audio-direction spec and was left
    for a dedicated pass — see "Remaining errors" below.
  AD-15 (minor): 22 scripts still used the pre-M6 blockout outline tone `#2b2233` alongside 9 already
    on the C11 warm-charcoal token `#332a20`. Replaced the literal value in every remaining script
    (mechanical `sed` pass across `scripts/`, verified `grep` finds zero remaining `#2b2233`) rather
    than introducing a new shared-constant file, to keep this a pure value change with no new
    dependency between scripts.
  AD-08 (major, partial): the hero's procedural vector rig read as noticeably more primitive than the
    illustrated enemy cutouts next to it — flat rectangle "cap" hair with a barely-visible forelock, a
    knee patch covering most of the leg, and a belt pouch drawn BEFORE the torso so the torso
    completely painted over it. Fixed the concrete bugs: moved the pouch draw to after the torso/
    outline (now visible at the hip instead of hidden), shrank the knee patch (was the leg's full
    width x 8px, now 64% width x 6px), and rebuilt the hair as a taller band plus one centered rounded
    crown circle with a bigger forelock triangle (an earlier attempt with two side-by-side corner
    circles read as a pair of mouse ears and was reworked). A full redraw to fully match the
    illustrated enemies' fidelity (sub-pixel contours, a real face) is a production-art undertaking,
    not a visual-node bug fix, and is left as an honest gap — see "Remaining errors" below.
Findings rejected (id: reason):
  AD-16: not a bug — the Resident/Clipper mirrored-facing sleeve asymmetry is already an explicitly
    documented, accepted production-art gap in `reports/asset-inventory.md` §4 ("Resident/Clipper
    mirrored-facing asymmetry"), confirmed still present and still listed after this pass's other
    fixes; no code or doc change needed beyond leaving it tracked.
  Two review scenes referenced in the findings' own evidence paths (`review_m6/...`) do not exist in
    this repo — they were capture output under a previous session's scratchpad, not committed debug
    scenes, so there was nothing under `scenes/debug/` to delete for this pass.
Findings deferred (id: reason, out of scope for a visual-nodes-only pass):
  AD-14 (remainder): a full cue-priority/ducking pool and suppressing the generic `interact` cue when
    a target plays its own would need to touch call sites across `hero.gd`, `session.gd`,
    `level_director.gd`, and `core_console.gd` — broader than a "cheap minor fix" and better done as
    its own reviewed pass with dedicated audio-direction.md sign-off.
  AD-08 (remainder): a full hero-rig redraw (or a matching outline-thickening pass across the derived
    enemy cutouts) is production art, not a bug fix; no approved Rook concept sprite exists to draw
    from (see asset-inventory.md §4's own "Procedural hero" gap).
Verification: `tools/test.sh` and `FPS=30 tools/test.sh` both 36/36 cases passed (no gameplay/
  collision/timing code was touched by any of the fixes above). Recaptured
  `scenes/debug/m6_characters_demo.tscn` (1000 frames/60fps windowed capture — 15fps was too coarse
  for this demo's timed jump over the Backstop to resolve correctly at all, so 60fps, matching the
  project's own physics tick rate, was used instead) and inspected by eye: the Clipper's STALL glow
  now sits on the mechanical housing near the RearHitZone instead of up by the handle loop; the
  Clipper draws over the hero when stalled instead of being hidden behind him; both warning triangles
  show a clear outlined, high-contrast shape at every point in their pulse; the derived sprites show
  no background-colored holes in the shirt/ivory panels and no residual cast-shadow smear. No
  `review_*.tscn` scenes existed to delete.
Remaining errors / placeholders / unverified gates: a debug-demo bug (AD-13, now fixed going forward)
  had already written real playtest-log files into the actual player's default save location
  (`~/Library/Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale Prototype/sunnyvale/
  playtests/`) before this pass — left in place rather than bulk-deleting a directory whose full
  contents' provenance (this bug vs. genuine prior play) isn't fully known from this pass alone; flagged
  for the user to clear if they want to. AD-14's audio-priority/ducking system and AD-08's full hero-
  rig redraw remain open (see "Findings deferred" above). Every other gap already listed in
  `reports/asset-inventory.md` §4 is unchanged by this pass.
Design deviations and reasons: none — every fix above is a correction toward the M6 presentation
  pass's own already-stated design intent (RearHitZone-aligned motor cue, non-detaching vector
  overlays, readable warning shapes, C11-consistent outline token), not a new deviation.
Save/schema compatibility notes: none — no `Session`/`CheckpointService` schema field changed.
Next concrete action: M7 (validation/export) — unchanged; this was a review/fix pass on already-
  verified M6 presentation work, not new milestone scope.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M7 export and outside-editor verification
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: a separate, concurrent M7 pass had already produced
  `reports/functional-matrix.md` (T01-T21 + completion gates 1-5 verified, 40/40 headless cases via
  new `tests/cases/test_m7_*.gd`) and left T22/export explicitly as its own out-of-scope workstream. A
  separate "polish" pass had fixed presentation items (AD-12/AD-17/A03/toast) and a real a06_exit.tscn
  parser bug, unrelated to this entry. This entry is that export workstream: run the import + full
  suite, produce and verify the Windows/macOS builds, and write reports/export-report.md.
Findings verified and fixed:
  Import + full suite: `tools/test.sh` and `FPS=30 tools/test.sh` both 40/40 cases passed before any
    change here (no integration breakage from the concurrent polish pass).
  M7-1 (real bug, save-data hygiene): `LevelDirector._on_play_again_confirmed()` calls the REAL
    `Telemetry.run_start()` (correct for an actual player's "Play again"), but
    `tests/cases/test_m5_regress_play_again_hud.gd` and
    `tests/cases/test_m5_story.gd::_test_t20_completion_totals_and_replay()` both exercise that exact
    path on a directly-built `LevelDirector` without ever redirecting `Telemetry` first — every full
    suite run was silently writing 1-2 real `run_*.jsonl` files into the actual player's default
    `~/Library/Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale Prototype/sunnyvale/
    playtests/` directory, violating `telemetry.gd`'s own "no test ever writes here" contract (and
    compounding the pre-existing AD-13 instance of the same class of bug in a debug demo). Found by
    diffing that real directory's file count across `tools/test.sh` filter subsets. Fixed both tests
    with the same redirect-before/`end_run()`+reset-after pattern already used elsewhere in the suite,
    added an explicit assertion that the real `run_start()` this test triggers lands in ITS OWN
    throwaway dir, and corrected `telemetry.gd`'s doc comment (which named no exception). Re-verified:
    two full `tools/test.sh` + `FPS=30 tools/test.sh` runs added zero new files to the real directory
    (154 -> 154, both fps). The ~150 pre-existing files in that directory (from before this fix, and
    from AD-13) were NOT deleted — real user data outside this repo; the sandbox correctly refused an
    attempt to clear it, and clearing it is the user's own call.
  M7-2/M7-3 (verification-tooling bugs, not shipped game code, found by actually running the export):
    `scripts/debug/m7_export_driver.gd`'s Continue phase rebuilt its route starting at the resume
    area's own FIRST route point regardless of where the checkpoint respawn marker actually placed the
    hero (resuming at CP01 inside A02, local x=5850, it tried to walk backward to A02's own R01_Move at
    local x=300 and got stuck) — fixed by dropping every leading point behind the hero's actual resume
    x. Separately, its completion-wait loop connected `Session.level_completed` with a lambda that
    reassigned a plain outer `bool` local — GDScript captures a lambda's outer local BY VALUE, so the
    outer loop's own copy never changed, and the driver deterministically reported a false
    "level_completed never fired" on every real completion (the log proved the signal DID fire).
    Fixed by boxing the flag in a one-element Array (the same idiom `test_m5_flow.gd` already
    documents/uses for the identical reason). Re-verified against a freshly rebuilt export.
Export: `export_presets.cfg` already existed (Windows Desktop: x86_64, `binary_format/embed_pck=true`;
  macOS: universal, `codesign/enable=false`) and needed no changes. Built with
  `Godot --headless --path . --export-release "Windows Desktop" exports/windows/Sunnyvale.exe`,
  `... --export-release "macOS" exports/macos/Sunnyvale.zip`, and (for the debug-only verification
  driver below) `... --export-debug "macOS" exports/macos-debug/SunnyvaleDebug.zip`. Sizes: Windows
  110,659,768 bytes (PE32+ GUI x86-64, `file`-confirmed); macOS release 60,726,367 bytes; macOS debug
  65,400,813 bytes.
Outside-editor verification (macOS; this Mac has no Wine, so the Windows build cannot be launched
  here): the release `.app` boots cleanly to the title screen with zero ERROR/WARNING lines (confirmed
  with `stdbuf -o0` after discovering this binary's stdout is fully block-buffered when redirected —
  a libc artifact, not a defect), stays alive/responsive, no crash report. Using the debug export and
  its export-only automation (`scripts/main.gd`'s `_maybe_start_m7_export_driver()`/
  `_maybe_redirect_m7_save_dir()`, active ONLY when `OS.is_debug_build()` AND an exact
  `--m7-phase=<newgame|continue>` argument are both present — confirmed the release build ignores these
  flags entirely) with `--m7-save-dir=user://m7_final/run3` (a throwaway location, real save untouched
  throughout — confirmed by directory inspection before/after): New Game -> a real RouteBot-driven walk
  to the first recovery station -> `checkpoint_committed id=CP01` -> a real, valid `checkpoint.json` on
  disk at that throwaway path -> clean exit 0; then Continue -> resumes at CP01 -> RouteBot drives the
  rest of the real route -> `Session.level_completed` fires -> completion screen present -> CP05
  committed, wallet/gems_found=45 -> clean exit 0. This proves boot, real checkpoint save, Continue
  restore, and completion, all outside the editor. One discovered CLI gotcha recorded in
  export-report.md: `OS.get_cmdline_user_args()` only returns arguments placed after a literal `--`.
  Gatekeeper: `spctl -a -vv` reports a broken resource seal (`code has no resources but signature
  indicates they must be present` — Godot's own pre-signed arm64 template's seal is invalidated by
  appending the project `.pck`, an ordinary/expected side effect of any unsigned Godot export, not
  specific to this project), yet `open`/double-click launched the app cleanly on this Mac even with a
  simulated quarantine flag added — no dialog appeared. README's existing right-click-to-open guidance
  is kept as the general fallback since Gatekeeper strictness varies by machine, with the "app is
  damaged" harder-recovery case now also documented (re-unzip a fresh copy rather than repairing in
  place).
Remaining errors / placeholders / unverified gates: T22-Windows remains pending — exact steps for a
  Windows PC are recorded in `reports/export-report.md`. Gate 6 (>=3 first-time playtests, 07's timing
  protocol) remains explicitly pending — no testers were available this session; nothing here
  estimates or invents a result. The pre-existing real `playtests/` directory (see M7-1 above) still
  holds files from before this fix; left for the user to clear.
Design deviations and reasons: none — every fix above corrects a verification/test-hygiene defect this
  same pass discovered, none touch gameplay rules, tuning, IDs, counts, or collision.
Save/schema compatibility notes: none — no `Session`/`CheckpointService` schema field changed.
Next concrete action: recruit >=3 first-time playtesters for gate 6 (07's timing protocol) — the one
  remaining item before M7, and the prototype as a whole, can be marked verified/finished.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / M7 audit-fix pass (verification and handoff)
Exact Godot version / executable: 4.7.2.stable.official.ed1daf0bf, /Applications/Godot.app/Contents/MacOS/Godot
Starting state and pre-existing changes: the prior M7 entry (functional matrix, export, outside-editor
  verification) was complete and its own 40/40 test run passed. An independent audit of that M7 work
  (and, in passing, of some pre-existing M6-scope documentation) produced 10 findings (1 critical, 2
  major, 7 minor). This pass verified each finding against the actual code/data before touching
  anything, fixed every one that was real (all 10 were real; none were false positives), then re-ran
  the full test suite at both fixed-fps settings and re-exported + re-verified all three build
  artifacts since code changed.
Findings verified and fixed:
  AUD-01 (CRITICAL, real bug, save-data hygiene): `tests/cases/test_m6_ui.gd` ended its `run()` with
    `CheckpointService.set_save_dir(CheckpointService.DEFAULT_SAVE_DIR)` instead of restoring the dir
    it found on entry (the established pattern already used by `test_m4_state_contracts.gd`). Because
    `test_m6_ui.gd` sorts alphabetically before every `test_m7_*.gd` case, this left `CheckpointService`
    pointed at the REAL default save dir for the rest of the run, so `tests/run_tests.gd`'s own
    per-case `clear()` and final `clear()` deleted a real `checkpoint.json`/`checkpoint.bak.json` on
    this machine on every full-suite run — directly contradicting README.md ("tests never touch a real
    save"), CONVENTIONS.md, and this same file's prior M7 entry's own hygiene claims (which had only
    ever checked `playtests/*.jsonl` file counts, never checkpoint files, so it could not have caught
    this). Independently confirmed by polling the real save dir every 20ms across a full-suite run
    before any fix: `checkpoint.json`/`checkpoint.bak.json` appeared repeatedly during the `test_m7_*`
    window and were gone again by the run's end. Fixed `test_m6_ui.gd` to save/restore the runner's own
    dir (`base_dir := CheckpointService.get_save_dir()` on entry, restored at the end, never
    `DEFAULT_SAVE_DIR`). Hardened `tests/run_tests.gd` defense-in-depth: reasserts the throwaway dir
    before every case (so no case can silently redirect every later case), fails any case that leaves
    the save dir pointed elsewhere afterward, and fingerprints the real save dir's
    `checkpoint.json`/`checkpoint.bak.json` modified-times before and after the whole run, failing the
    run if either changed (never assumes the real dir starts empty — a genuine pre-existing real save
    must never be misreported as a hygiene failure).
  AUD-02 (major, doc accuracy): `functional-matrix.md`'s gate-7 row, its "Overall" line,
    `export-report.md`'s own gates-6-7 status section and its T22-macOS matrix row, and README.md all
    said the macOS export was "fully verified (boots, saves, continues, completes...)" without
    distinguishing the release template (what a player receives — only boot-to-title was verified) from
    the debug template (used only by the export-verification driver, where save/continue/complete was
    actually exercised) — two different binaries. Reworded all four to say the macOS RELEASE export
    boots verified, and save/continue/complete is verified on the macOS DEBUG export of the same
    preset/source, not separately hand-played on the release build.
  AUD-03 (major, doc accuracy): this file's "Next action" line and README both named only gate 6 as
    "the one remaining pending item," dropping T22-Windows/gate 7's Windows launch (also pending, no
    Wine on this host) — risking a future agent marking M7 "verified" without ever launch-testing
    Windows, against this file's own "only mark M7 verified after all applicable completion gates pass"
    rule. Also, M7's prior status string ("Playable, timing unverified") was not one of the statuses
    this file's own template allows. Reworded the current-state header, the M7 milestone-table status
    cell, and README to list both pending items and to lead with an allowed status
    ("implemented, unverified (gate 6 and T22-Windows pending)"), keeping "Playable, timing unverified"
    as a following, non-exclusive description rather than the status itself.
  AUD-04 (minor, doc accuracy): README and this file's prior M7 row said "functional matrix T01-T21 ...
    verified," dropping `functional-matrix.md`'s own qualifier that T21's visual-readability half is
    only partially verified (mechanical/resize contracts are verified-automated; the readability itself
    is visual and was not re-captured this pass). Reworded README and the M7 row to say "T01-T20
    verified; T21 mechanically verified, visual readability half partially verified."
  AUD-05 (minor, package hygiene): both export presets used `export_filter="all_resources"` with an
    empty `exclude_filter`, so `res://tests/*` and `res://scenes/debug/*` (RouteBot demos, the M7
    driver's own test-adjacent scaffolding, etc.) were packed into both the macOS release `.pck` and
    the Windows embedded-PCK `.exe` — confirmed unreachable by a player (the release binary rejects
    scene-path overrides; `--m7-phase=...` with no debug build is inert; `debug_invulnerable` defaults
    false) but still unnecessary package bloat/hygiene debt. Added
    `exclude_filter="tests/*,scenes/debug/*"` to both presets; kept `scripts/debug/*` (the macOS debug
    export's own verification driver loads `route_bot.gd` from there). Re-exported all three artifacts
    and confirmed via `strings` that the release `.pck`/embedded-PCK now contain zero
    `res://tests/`/`res://scenes/debug/` paths while `res://scripts/debug/` is still present (54
    matches).
  AUD-06 (minor, real bug, verification-tooling hygiene): `scripts/main.gd`'s
    `_maybe_start_m7_export_driver()` started the M7 driver on `--m7-phase=<phase>` alone, while
    `_maybe_redirect_m7_save_dir()` silently returned without redirecting anything whenever
    `--m7-save-dir` was left off — so a debug-export launch with only `--m7-phase=newgame` would run
    the driver's real New Game against the exported app's own REAL default save dir. (Confirmed inert
    on the release export both before and after — `OS.is_debug_build()` gates the whole thing off
    there regardless of arguments.) Fixed: whenever `--m7-phase` is present at all, the save dir is now
    always redirected — to the explicit `--m7-save-dir` if given, otherwise a fresh
    `user://m7_throwaway/<ticks>` — plus a defense-in-depth check in the driver-start path that refuses
    to start if `CheckpointService` is ever still pointed at `DEFAULT_SAVE_DIR`. Reproduced the exact
    original bug scenario against the freshly rebuilt macOS debug export (`--m7-phase=newgame`, no
    `--m7-save-dir`): New Game ran and committed a checkpoint under the new `user://m7_throwaway/...`
    path; the real `sunnyvale/` dir was confirmed untouched throughout (cleaned up after).
  AUD-07 (minor, doc/test-comment accuracy): `test_m7_encounter_fairness.gd`'s header called
    `L01-E07`/`L01-E11` "the two groups in the shipped level that actually pair a Resident with a
    Clipper" — false: `prototype-spec.json`/`test_m3_level.gd` show `L01-E09` (also in
    `a04_square.tscn`) also pairs a Resident with a Clipper, and `L01-E08` pairs two Residents.
    `functional-matrix.md`'s T06 row also didn't cite `test_m3_regress_route.gd` for the "usable
    retreat remains" clause it actually evidences. Corrected the test file's header comment (E08/E09 do
    still get `test_m3_regress_encounters.gd::_combat_run()`'s brief whole-route one-attacker check,
    just not this file's own sustained dwell sample) and the T06 matrix row, per the audit's own listed
    alternative fix (correct the comment/wording rather than author new dwell-test terrain for E08/E09
    against unfamiliar area geometry, which risked a flaky or wrong new test for a minor finding).
  AUD-08 (minor, stale docs, 4 parts): (a) CONVENTIONS.md's Telemetry paragraph said no test that
    builds a level directly ever calls `Main`/`run_start()` except `test_m6_audio.gd` — false since M7:
    `test_m5_regress_play_again_hud.gd` and `test_m5_story.gd`'s T20 also call
    `LevelDirector._on_play_again_confirmed()` directly (which calls the real `Telemetry.run_start()`),
    and both already redirect `Telemetry` first (that redirect is itself the fix from the prior M7
    session-log entry above). Corrected the paragraph to name all three exceptions and state the
    contract any new such test must follow. (b) README said `CheckpointService` AND `Telemetry` are
    both redirected for "the whole test run" by `tests/run_tests.gd` — only `CheckpointService` is;
    `Telemetry` is redirected per-case by whichever case actually starts a real run. Corrected. (c)
    `asset-inventory.md` section 4 still listed the A06 sign-behind-bush/toast-over-head item as fully
    open; checked the current scene data: the sign-behind-bush half is now fixed (`Sign_Entry`/`Shrub1`
    in `a06_exit.tscn` are 250px apart, no overlap) but the Interact-prompt/toast-over-head half is
    still open (`Hero._update_interact_prompt()` positions the prompt 64px above the INTERACTABLE's own
    origin, not clamped to the hero's head bounds) — reworded to reflect exactly that split, and added
    the previously-unlisted `Scenery.Kind.BEACON`/`SUPPORT`, `AlarmVisuals` (`a05_depot.tscn`), and
    A05's `EnvironmentState` backdrop retint as newly-confirmed, wired, no-gap entries. (d) this file
    had no session-log entries naming the M7 functional-matrix/playtest-kit passes specifically (only
    mentioned in passing inside the export entry) — addressed by this entry itself plus the M7 row
    above now citing `functional-matrix.md`/the playtest kit directly.
  AUD-09 (minor, doc accuracy): `pacing-risk.md` said the two RouteBot runs "agree within a few seconds
    per area," but the OPT01 branch row is 95.58s this run vs 107.95s in the prior run — a 12.4s (~13%)
    difference, larger than any other row. Corrected the sentence to call out OPT01 specifically, and
    added the qualitative note that the OPT01 detour costs almost nothing over the main route in raw
    bot-traversal time (95.53s main vs 95.58s with the detour), so its 01-specified +45-60s budget
    depends entirely on the artifact/reading content, not on distance.
  AUD-10 (minor, repo/facilitator hygiene): seven unreferenced scratch SceneTree scripts
    (`tests/_smoke_*.gd`, dated 2026-09-26, confirmed unreferenced by anything and would have been
    committed and packed into exports) were deleted. The playtest kit's `README.md` never told a
    facilitator to clear/archive a dev machine's existing `sunnyvale/playtests/` folder before a tester
    session (confirmed 154 pre-existing files still there on this machine) — added that step. The
    154 pre-existing real playtest-log files themselves were left in place, same as the prior M7 entry
    already decided — real user data outside this repo, not this pass's call to bulk-delete.
Re-verification after all code changes above: `tools/test.sh` and `NOIMPORT=1 FPS=30 tools/test.sh`
  both **40/40 cases passed**. A 40-second, 20ms-interval poll of the real save dir
  (`~/Library/Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale Prototype/sunnyvale/`)
  throughout a full, unfiltered suite run found zero `checkpoint*.json` appearances (previously
  hundreds per run) — confirms AUD-01's fix. Re-exported all three artifacts
  (`--export-release "Windows Desktop"`, `--export-release "macOS"`, `--export-debug "macOS"`), all
  three `[ DONE ]` with no errors; sizes shrank slightly as expected from AUD-05's exclude_filter
  (Windows 110,418,792 bytes, macOS release 60,526,991 bytes, macOS debug 65,201,370 bytes). Re-ran the
  macOS release boot check (`stdbuf -o0` launch): boots cleanly to the title screen, zero
  ERROR/WARNING lines, same as before. Re-ran the full outside-editor driver sequence against the
  freshly rebuilt macOS debug export with an explicit fresh throwaway dir
  (`user://m7_reverify/run1`): New Game -> `checkpoint_committed id=CP01`; Continue -> resumed, drove to
  the end, `Session.level_completed` fired, completion screen present, CP05 committed,
  `gems_found=45`, exit 0 — real save dir confirmed untouched throughout (throwaway dir removed after).
  Separately reproduced the AUD-06 bug scenario one more time against the fixed build
  (`--m7-phase=newgame` with no `--m7-save-dir`) to confirm the fix actually engages: New Game ran
  successfully under the new `user://m7_throwaway/<ticks>` default, real save dir untouched (cleaned up
  after). Confirmed the release export is still fully inert for these same arguments (no `[M7DRIVER]`
  output, real save dir untouched).
Files changed: prototypes/sunnyvale-godot/tests/cases/test_m6_ui.gd,
  prototypes/sunnyvale-godot/tests/run_tests.gd, prototypes/sunnyvale-godot/scripts/main.gd,
  prototypes/sunnyvale-godot/export_presets.cfg,
  prototypes/sunnyvale-godot/tests/cases/test_m7_encounter_fairness.gd (header comment only),
  prototypes/sunnyvale-godot/reports/functional-matrix.md,
  prototypes/sunnyvale-godot/reports/export-report.md,
  prototypes/sunnyvale-godot/reports/asset-inventory.md,
  prototypes/sunnyvale-godot/reports/pacing-risk.md,
  prototypes/sunnyvale-godot/reports/playtests/README.md, prototypes/sunnyvale-godot/README.md,
  prototypes/sunnyvale-godot/CONVENTIONS.md; deleted
  prototypes/sunnyvale-godot/tests/_smoke_{area,area2,harness,harness2,harness3,objects,platform}.gd
  (unreferenced scratch files); this file; ../../prototype-plans/level-01-sunnyvale/prototype-spec.json
  (milestone statuses M0-M6 -> verified, M7 -> implemented_unverified with a notes field summarizing
  the pending gates; engine.exact_version set from null to "4.7.2.stable.official.ed1daf0bf"). Rebuilt
  (gitignored, not tracked): exports/windows/Sunnyvale.exe, exports/macos/Sunnyvale.zip,
  exports/macos-debug/SunnyvaleDebug.zip.
Timing / machine measurements, if any: none new beyond the re-export sizes and the poll/verification
  timings already stated above; no gameplay/pacing numbers changed.
Remaining errors / placeholders / unverified gates: unchanged from the prior M7 entry — gate 6 (>=3
  first-time playtests) and T22-Windows/gate 7's Windows launch both remain explicitly pending, for the
  same reasons (no testers available, no Wine on this host). Nothing in this pass substitutes an
  estimate for either.
Design deviations and reasons: none — every change above either fixes a verified real bug (AUD-01,
  AUD-06) with no gameplay/tuning/ID/collision impact, tightens packaging hygiene (AUD-05), or corrects
  documentation/test-comment accuracy to match the code and data that already existed (AUD-02/03/04/07/
  08/09/10).
Save/schema compatibility notes: none — no `Session`/`CheckpointService` schema field changed.
Next concrete action: run >=3 first-time playtests using the kit at
  prototypes/sunnyvale-godot/reports/playtests/ (gate 6, 07's timing protocol) — the results feed both
  the timing gate and `reports/pacing-risk.md`. Separately, launch-test the Windows export
  (`exports/windows/Sunnyvale.exe`) on a real Windows PC per the steps in
  `reports/export-report.md` (T22-Windows/gate 7). Only once both are done can M7, and the prototype as
  a whole, be marked verified.
~~~

Use statuses **not started**, **in progress**, **implemented, unverified**, **verified**, or **blocked by [specific prerequisite]**. Only mark M7 verified after all applicable completion gates pass. Keep estimates separate from observations.

When a tuning number, count, route, or milestone changes, update its owner and prototype-spec.json together. Do not silently rewrite the broad campaign from a prototype experiment.

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Opus 5.5) / post-M7 follow-up (AD-17 prompt overlap)
Implemented behavior: hero Interact prompt keeps its hero-relative offset above the head instead of being
  re-placed 64 px above the interactable (which put it on the hero's torso at the console/bench/pad), and
  hides while that object's own toast is showing. Fix authored in a separate session's worktree
  (.claude/worktrees/beautiful-pike-d1b8fb) and ported into the main checkout.
Files changed: scripts/actors/hero.gd, scenes/actors/hero.tscn, scripts/world/interactable.gd
  (is_showing_toast), tests/cases/test_m7_regress_prompt_above_hero.gd (new, 8 checks)
Checks actually run and outcomes: tools/test.sh and FPS=30 NOIMPORT=1 tools/test.sh -> 41/41 cases passed;
  re-exported Windows release, macOS release and macOS debug; macOS release .app --quit-after 120 boots
  with no errors
Remaining gates: unchanged — gate 6 (first-time playtests) and Windows launch pending
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / post-M7 follow-up (controls help menu)
Implemented behavior: new "Controls (F1)" help menu (user request), reachable from the Title screen's own
  button and F1, and from gameplay via F1 opening the Pause menu directly on it (same _can_open() gating as
  Journal). New reusable scenes/ui/controls_panel.tscn + scripts/ui/controls_panel.gd (class ControlsPanel):
  a 9-row table built from a fixed ordered list, each row's binding rendered LIVE from InputMap (never
  hardcoded key names, per interface-and-accessibility.md "Input icons follow current bindings") plus a
  short spoiler-free Tips block. New `help` InputMap action (F1) added via scripts/tools/configure_project.gd.
  Adversarial review of the initial pass found the table's ScrollContainer used a hardcoded
  custom_minimum_size guess (340px) that silently clipped the last row's descenders at Settings' Normal
  text size, and clipped 3 of 9 rows entirely at Large text size with no indication anything was missing
  beyond a thin scrollbar. Fixed by measuring the Table's own real GridContainer minimum size at runtime
  (`_resize_scroll_to_table()`, re-run off `_table.minimum_size_changed`) instead of guessing — this also
  hides each host's own redundant outer title/message Label while Controls is showing (TitleScreen/
  PauseMenu already did this for Controls' M-message line; extended to the title text too) to give the
  table the shared C11 Panel's full ~460px of usable room. At Normal text size all 9 rows now render with
  zero clipping/scrolling on both screens at both 1280x720 and 960x540 (confirmed by real windowed
  screenshots, not just row-count arithmetic). At Large text size the table's real measured height (rows
  scaled 1.25x) exceeds even that full budget once the header/Back button's own (also-scaled) room is
  reserved — impossible to fit entirely within a 960x540-legible fixed 640x500 panel — so the Scroll is
  capped to the safe remaining budget (HOST_BUDGET_HEIGHT minus overhead) rather than growing the whole
  view past the Panel's own drawn edges (a real overflow bug hit and fixed during this same pass: an
  uncapped version pushed Tips and the Back button below the panel border, floating over the background).
  Large text now shows 6 of 9 rows fully, contained correctly inside the panel with a working, discoverable
  scrollbar for the rest — a real physical-space trade-off of the shared panel's fixed, 960x540-constrained
  size, not a bug. The reviewer's third finding (a faint background circle bleeding through the panel via
  assets/ui/c11_theme.tres's bg_color alpha=0.97) was confirmed real but pre-existing (untouched by this
  feature, present since the M0-M7 commit) and rejected as out of scope — a shared-theme opacity change
  affecting every C11 panel deserves its own separately reviewed decision, not one bundled into this
  feature.
Files changed: scenes/ui/controls_panel.tscn (new), scripts/ui/controls_panel.gd (new),
  scenes/debug/help_demo.tscn (new, capture demo — redirects CheckpointService to a throwaway dir, adds
  HELP_TEXT_SIZE=large env var following the M6_REDUCED_MOTION/M6_MUTED pattern), scripts/debug/help_demo.gd
  (new), scripts/tools/configure_project.gd (+help/F1 action), project.godot (regenerated, help action
  added, every other action byte-identical), scenes/ui/title_screen.tscn + scripts/ui/title_screen.gd
  ("Controls (F1)" button/view, outer title hidden while Controls shows), scenes/ui/pause.tscn +
  scripts/ui/pause_menu.gd ("Controls" button/view + F1 direct-open, outer "Paused" title hidden while
  Controls shows), tests/cases/test_help_controls.gd (new, 48 checks: every InputMap action has exactly one
  row with the exact current binding, refresh() re-reads a rebind, both entry points open/close correctly
  with focus restored, Settings text size scales the panel), tests/cases/test_help_regress_table_clip.gd
  (new, 10 checks — locks in the Normal-text no-clipping contract via a fixed-size SubViewport, the same
  technique test_m7_pause_and_resize.gd uses), tests/cases/test_help_regress_large_text_overflow.gd (new,
  4 checks — locks in that the whole view, including Back, never renders past the host Panel's edges at
  either text size).
Checks actually run and outcomes: tools/test.sh and FPS=30 tools/test.sh both -> RESULT: 45/45 cases
  passed (45 = the prior 43 + 2 new regression cases); a 120-frame headless --quit-after launch of
  res://scenes/main.tscn produced zero errors; real windowed captures (--resolution 1280x720/960x540,
  --fixed-fps 30 — this host needs --fixed-fps even for a plain windowed run, not just Movie Maker
  captures) of scenes/debug/help_demo.tscn, both from the Title screen and from gameplay's F1->Pause path,
  at both Settings text sizes, were inspected frame by frame: Normal text shows all 9 rows with no clipping
  at both resolutions; Large text shows 6 rows cleanly contained (no overflow) with a working scrollbar at
  both resolutions.
Remaining errors / placeholders / unverified gates: unchanged — gate 6 (first-time playtests) and
  T22-Windows/gate 7's Windows launch both remain pending. New, accepted trade-off: at Settings' Large text
  size the Controls table needs scrolling to reach Journal/Skip story scene/Controls help — the shared
  640x500 C11 Panel does not have room for all 9 rows at 1.25x font scale within a 960x540-legible size, so
  this is treated as an inherent constraint rather than a bug; the Panel would need to grow past what fits
  on a 960x540 window to eliminate it entirely.
Design deviations and reasons: hiding the host's own outer title/message Label while the Controls view is
  open (both Title screen and Pause menu) is a new UI decision beyond the original task literal ask,
  needed to give the table enough room without growing the shared Panel past the 960x540 budget; the
  Controls view's own "Controls" header already identifies the screen, so nothing is lost.
Save/schema compatibility notes: none — no Session/CheckpointService schema field changed; the new `help`
  InputMap action is a project-settings-only addition (Settings settings.json/checkpoint save format
  unaffected).
Next concrete action: unchanged from the prior entry — gate 6 (first-time playtests) and the Windows
  launch test are the only things blocking a fully verified M7.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / post-M7: Clipper readability
Implemented behavior: fixed the confirmed playtest report ("clipper doesn't die when I shoot") and its
  root cause (a prior session's own verification pass, tests/cases/test_clipper_real_level.gd, had already
  isolated it precisely): in a02_gardens.tscn, E02/E04's stone Backstop1/2 sat on the FAR side of their
  Clipper from the hero's approach, so the charge — which always locks toward the approaching hero — fired
  AWAY from the stone and just braked at its 4H cap with no stall, ever, on a natural first approach
  (E07/E09/E10/E11 were already correctly authored the other way and needed no change). Fix: moved
  Backstop1/2 onto the hero's approach side (matching the already-shipped, already-tested E07/E10 pattern
  exactly — the stone physically blocks the Clipper's line-of-sight raycast until the hero jumps over it as
  ordinary terrain, and the SAME wall is what the charge then stalls against, from either side, once LoS
  clears), moved the Clipper's own spawn/patrol range clear of the wall (4H-cap margin, 30-50px) AND clear
  of the hero's jump-landing spot (>=192px/2H, test_m3_regress_route.gd's own LANDING_ENEMY_MIN), widened
  each lane_rect/patrol range enough to stop patrol-direction jitter (test_m3_regress_encounters.gd), and
  re-authored the R04/R05 (E02) and R16/R17 (E04) Route points so the route bot still crosses the
  relocated wall correctly. Result (test_clipper_real_level.gd, all six, real level, real Route points):
  every Clipper now stalls on the FIRST natural charge (E02/E04 stall after 267/272px of a 384px cap, 1.60s
  window — comfortable for 3 base-pistol shots at 0.32s cadence) — no tuning change needed, wall_stall_time
  stays 1.6s. Also implemented the M7 teaching pass this fix was paired with (03/02's rule unchanged
  throughout — front always blocks, rear only damageable in STALL): (a) frontal "armored" feedback now
  reads through SHAPE as well as color — a radiating spark burst + chevron glyph at the exact impact point
  (clipper.gd) plus a brief shield-outline flash on the shell (clipper_visual.gd), alongside the existing
  shell color-flash and bolt_blocked audio; (b) the one-time motor hint now fires after 2 ineffective
  frontal hits (was 4, data/tuning/clipper.tres), reads "Armored! Make it crash into stone, then shoot the
  motor on its back.", and stays up 4s (was 2.5s); (c) a new one-shot-per-run contextual prompt
  ("Clippers are armored in front — let it crash into the stone planter.") shows the instant E02's own
  EncounterGroup activates (new `activated` signal, encounter_group.gd) and never reappears after a
  same-run death/respawn rebuild, via a new generic `Session.runtime_flags` live-only flag store (mirrors
  the existing `cutscene_active` idiom exactly: reset only by `new_run()`/`load_from_snapshot()`) plumbed
  through new optional `TutorialPrompt` exports (`trigger_node`, `once_per_run_key`, `auto_fade_time`) that
  leave every EXISTING TutorialPrompt instance (a01_gate.tscn) byte-identical in behavior; (d) STALL now
  draws a pulsing 4-bracket target ring around the exposed motor, a shrinking arc tracing the remaining
  stall window, and two small spinning "stunned" stars above it (all frozen, not spinning, under
  Settings.reduced_motion) — vanishing the instant STALL ends, since the whole block only draws while
  `stalled` is true; (e) the specific backstop a Clipper's charge actually stalls against gets a one-time
  subtle crack overlay (new `Block.cracked` flag, drawn only for `Kind.BACKSTOP`, a no-op on every other
  kind/instance).
Files changed: scenes/levels/areas/a02_gardens.tscn (Backstop1/2 relocated; E02/E04 Clipper position/
  patrol_min_x/patrol_max_x and EncounterGroup lane_rect widened; Route R04/R05/R16/R17 repositioned;
  Planter1/2 nudged to sit by the relocated stone; new TutorialPrompt_E02Clipper), scenes/levels/areas/
  a03_roofs.tscn (E05's ApproachZone moved ~250px further onto Terrace4b — see Design deviations below),
  scripts/actors/clipper.gd (hint text/threshold/display-time consts, front-hit impact-position tracking +
  spark/chevron `_draw()`, stall_remaining fraction plumbed into `_update_visual_pose()`, crack-mark hookup
  in `_enter_stall()`), scripts/actors/visuals/clipper_visual.gd (shell shield-flash, motor target-ring/
  timer-arc/stunned-stars, `_reduced_motion()`), scripts/combat/clipper_front_hit_zone.gd (`blocked_hit`
  now carries `hit_position`), scripts/combat/encounter_group.gd (new `activated` signal),
  scripts/objects/tutorial_prompt.gd (`trigger_node`/`once_per_run_key`/`auto_fade_time`),
  scripts/world/block.gd (`cracked` export + `_draw_stone_crack()`), scripts/session.gd (`runtime_flags`/
  `get_runtime_flag()`/`set_runtime_flag()`), data/tuning/clipper.tres + scripts/tuning/clipper_tuning.gd
  (frontal_hint_threshold 4 -> 2), CONVENTIONS.md (documented all of the above contracts),
  tests/cases/test_clipper_teaching.gd (new, 36 checks: hint at exactly 2 hits and only once per group,
  stall_remaining data live only during STALL, the wall actually hit gets cracked exactly once and no
  other Block ever does, front/rear damage rules provably unchanged, the E02 prompt shows once per run and
  does NOT reappear after a same-run area rebuild but DOES clear on a genuinely new run),
  scripts/debug/clipper_e02_sequence_demo.gd + scenes/debug/clipper_e02_sequence_demo.tscn (new, capture-
  only demo driving the hero through E02's own real Route points with a reactive dodge/aim/fire loop).
  tests/cases/test_clipper_real_level.gd (from the prior verification-only session) needed no further
  changes and is the test that now reads all-green.
Checks actually run and outcomes: tools/test.sh -> RESULT: 47/47 cases passed; FPS=30 tools/test.sh ->
  RESULT: 47/47 cases passed (both full-suite runs, after every change in this entry, including a
  necessary intermediate re-run after each of the three iterations the E02/E04 fix went through — first
  pass left the Clipper unreachable by walking a Route JUMP point INTO the relocated wall's own footprint,
  second pass put the Clipper's spawn only 45px past the hero's jump-landing spot (test_m3_regress_route.gd
  LANDING_ENEMY_MIN=192px) and its narrowed patrol leash jittering (test_m3_regress_encounters.gd), third
  pass fixed both); test_clipper_real_level.gd run standalone confirms, per Clipper, on the real level with
  the real Route points: L01-E02-R01-01 and L01-E04-R01-01 now both stall on charge #1 (267px/272px
  traveled of the 384px cap, 1.60s stall window, 3/3 rear hits landed, DEFEATED), matching the already-
  passing L01-E07/E09/E10/E11 (219-369px traveled, 0.95-1.60s windows); test_clipper_teaching.gd run
  standalone -> 36/36 checks; a windowed capture (tools/capture.sh, res://scenes/debug/
  clipper_e02_sequence_demo.tscn, 200 frames @15fps, written to the session scratchpad's captures/
  clipper_improve/) was inspected frame by frame end to end: the E02 contextual tutorial prompt is legible
  on natural approach, the windup warning triangle shows before the charge, the charge visibly slams into
  the relocated stone, the stall's motor-hatch/target-ring/stunned-star cues are all clearly visible and
  distinct from the pre-stall flush-cover motor, a visible crack appears on the stone block after the
  stall, and the Clipper is defeated and removed from the scene.
Remaining errors / placeholders / unverified gates: unchanged — gate 6 (first-time playtests) and
  T22-Windows/gate 7's Windows launch both remain pending. New, non-blocking notes from this pass: the
  capture demo's own simple (non-alignment-gated) reactive-fire loop needed two stall cycles to land all 3
  rear hits in this particular run (imprecise aim in the THROWAWAY DEMO's own dodge/aim logic, not a rule
  or tuning issue — test_clipper_real_level.gd's more carefully alignment-gated reactive AI kills every one
  of the six Clippers within its very first stall window, confirmed above); the capture's dodge-first
  approach never happens to throw an early frontal shot, so the new spark/chevron/shield-flash "armored"
  feedback is proven correct by test_clipper_teaching.gd/test_m2_clipper.gd (state/timers) and by reading
  the draw code, but was not itself captured on video this pass — a natural follow-up capture.
Design deviations and reasons: the task brief's illustrative narrative ("the hero stands on the step... it
  stalls with its rear motor facing AWAY from the hero... the hero drops/jumps over the STALLED Clipper")
  was not implemented literally. Instead E02/E04 were brought in line with the exact pattern the OTHER four
  Clippers already ship and already pass tests with: the stone sits on the hero's approach side and
  physically blocks the Clipper's line-of-sight raycast (both eye-heights fall inside the wall's height
  band) until the hero jumps over it as ordinary terrain; only then does the Clipper acquire and its charge
  (which always locks toward wherever the hero currently is) travel back into the very wall the hero just
  crossed, exposing the rear on the side the hero is already standing on — no separate "jump over the
  Clipper's body" step needed. This was a deliberate choice to make all six lanes share one proven,
  tested mechanic rather than inventing a second, divergent layout for only two of them; the existing
  ObservationStep1/2 set dressing was left in place (still "in the same camera view" as the stone/jump per
  02) but is not itself gameplay-load-bearing under this pattern — standing on it does not trigger a charge
  (floor_band=64 rejects the ~120px height difference) — a minor, accepted divergence from the brief's
  "waits on the step" phrasing, since the actual taught mechanic (walk in, jump the stone, shoot the
  exposed rear) is what the new tutorial prompt and hint text both describe, and no test/rule requires the
  step itself to be interactive.
  Also fixed, found only because this fix's own A02 route-point timing shift exposed it (confirmed by
  `git stash` bisection, not assumed): a03_roofs.tscn's E05 Resident `ApproachZone` sat only ~10px onto the
  Terrace4b platform, immediately past a 170px gap-jump — `body_entered` could fire on whichever exact tick
  the hero's sub-pixel position crossed that line, and with this fix's A02 timing changes that tick landed
  while the hero's downward floor-probe still read "no flat floor behind" (test_m3_regress_route.gd's own
  retreat-floor check, RETREAT_MIN=192px), intermittently in the sense that it depends deterministically on
  upstream timing rather than being flaky run-to-run. Moved the zone ~250px further onto the platform for a
  real, timing-independent margin. Unrelated to the Clipper rule/rewrite; called out here rather than
  folded silently into the Clipper diff, since a03_roofs.tscn was already mid-edit (uncommitted) by another
  session when this one started.
Save/schema compatibility notes: none — no `Session.state`/`CheckpointService` persisted schema field
  changed. The new `Session.runtime_flags` is deliberately live-only (like the existing `cutscene_active`),
  never part of `default_state()`, so `CheckpointService.validate_snapshot()`'s whitelist needed no change.
Next concrete action: unchanged — gate 6 (first-time playtests) and the Windows launch test are the only
  things blocking a fully verified M7. A good next capture: deliberately fire frontally a couple of times
  before dodging E02's charge, to also show the new spark/chevron/shield-flash cue on video (this pass's
  capture only exercises the stall-side cues).
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / post-M7: Kenney integration part A
  (audio, input-prompt icons, crosshair, particles/light masks) — verification/finalization pass
Implemented behavior: this session did not author new integration code — that was three parallel
  workflows (audio, UI, fx), each already done and reporting all-green before this pass started. This
  pass's job was to run the import step once, run the full verified suite, headless-launch the game, and
  capture/inspect real gameplay footage before signing part A off, plus write up the asset inventory. All
  three passes' work was confirmed wired and correct: `scripts/audio/audio_director.gd`'s `SFX_SOURCES`
  plays 44 curated Kenney `.ogg` files across 27 of 34 SFX cues (interface/impact/ui-audio/sci-fi packs),
  keeping the 7 remaining cues + both music loops on the original synthesized `.wav` where no Kenney
  file fit; `scripts/ui/controls_panel.gd` renders a Kenney input-prompt icon column (Keyboard & Mouse ->
  Vector -> Outline, tinted warm charcoal) beside every row's existing binding text in the Controls panel;
  `scripts/main.gd` swaps the OS mouse cursor to the Kenney crosshair-pack reticle during real gameplay
  only (arrow on Title/paused/modal); `scripts/objects/scenery.gd` + `scripts/world/environment_state.gd`
  give LAMP/BEACON props a soft additive light-mask glow (utility <-> examination retint, alarm pulse);
  and a new `scripts/effects/kenney/kenney_puff.gd` one-shot particle helper is wired at 6 call sites
  (muzzle flash, hero landing dust, gem/cache/checkpoint sparkle, resident defeat puff, pit-fall dust). All
  copied Kenney files are CC0 1.0, staged under `assets/kenney/<pack>/` (never a whole pack) with each
  pack's own `LICENSE.txt`. Per this task's concurrency rule, nothing Clipper-owned was touched
  (`clipper.gd`/`clipper_visual.gd`/`clipper_front_hit_zone.gd`/`impact_spark.gd`/`tutorial_prompt.gd` +
  their scenes, `a02_gardens.tscn`, `clipper.tres`, Clipper tests) — the Clipper's own clang/stall
  particles and tutorial-prompt icons remain part B, still pending; 3 particle-pack/smoke-particles files
  are pre-staged under `assets/kenney/particles/clipper_later/` for that later pass but not yet referenced
  anywhere.
Files changed (this pass only — see the three prior sessions' own log entries for the integration
  diffs): `prototypes/sunnyvale-godot/reports/asset-inventory.md` (new §7 "Kenney CC0 asset integration",
  documenting every wired file's source pack, CC0 status, and exact in-game use, plus the 3 staged/unwired
  Clipper-later files and known gaps), this handoff entry.
Checks actually run and outcomes: `godot --headless --path . --import` run once (clean, 75 Kenney assets
  already had `.import` files from the prior passes, none needed re-importing); `tools/test.sh` ->
  RESULT: 49/49 cases passed (including `test_kenney_ui.gd` 52 checks and `test_m65_kenney_fx.gd` 17
  checks — both initially looked missing from a `tail`-truncated log and were re-confirmed with a
  `--filter=kenney` run: 2/2 passed); `FPS=30 tools/test.sh` -> RESULT: 49/49 cases passed (full log
  captured to a file this time, no truncation); a 120-frame headless `--quit-after` launch of
  `res://scenes/main.tscn` produced zero errors beyond the expected one-line boot log message. Captured
  and frame-by-frame inspected (~20 frames total): `res://scenes/debug/m3_route_demo.tscn`, 8 fps, 800
  frames (long enough to cover the bot's full ~97s route end-to-end through "Sunnyvale complete.") — depot
  utility lamps and quarantine examination lamps both read as soft warm/cyan ambient glow cones, not the
  earlier flat debug-looking discs; the E02 Clipper's warning triangle, charge-into-stone, and post-stall
  crack were all clearly visible and on-palette; nothing covered feet, edges, gems, or the interact/save
  toasts. `res://scenes/debug/m2_demo.tscn` (Resident + Clipper combat course), 15 fps, 150 frames — hero
  fire pose, Resident hit-flash, and the Clipper's charge/stall/crack sequence all read cleanly with no
  clipping or oversized effects; the OS crosshair cursor itself isn't visible in any Movie Maker capture
  (documented limitation from the UI pass's own report — `Viewport.get_texture()` doesn't capture the
  compositor-drawn cursor), so that piece is verified via `test_kenney_ui.gd` and `Main.get_cursor_mode()`
  instead, per that pass's own note.
Remaining errors / placeholders / unverified gates: unchanged from the prior M7 entries — gate 6
  (first-time playtests) and the Windows launch test remain pending. New, non-blocking notes from this
  pass: `assets/kenney/README.md`'s own "Wiring note (next pass, not done here)" callouts for audio/
  input-prompt-icons/crosshair are now stale (that wiring is done) but that file is owned by the curation/
  staging workflow, not this pass, and was left unedited — reports/asset-inventory.md's new §7 is now the
  up-to-date reference. Part B (Clipper clang/stall particles, tutorial-prompt icons) is explicitly not
  started — see reports/asset-inventory.md §7.6.
Design deviations and reasons: none — this was a verification/documentation pass only, no gameplay,
  tuning, collision, ID, or save-format code was touched.
Save/schema compatibility notes: none — no Session/CheckpointService schema field changed by any of the
  three Kenney integration passes or by this verification pass; `Audio.play_sfx()`'s cue names and every
  call site across the project are unchanged.
Next concrete action: hand off part B (Clipper's own clang/dazed-star/stall-steam particles using the 3
  pre-staged `assets/kenney/particles/clipper_later/` files, plus swapping `tutorial_prompt.gd`'s plain
  text for a matching Kenney input-prompt icon) to the workflow that owns those Clipper-related files, once
  it's no longer mid-edit; separately, gate 6 (first-time playtests) and the Windows launch test remain the
  blockers for a fully verified M7.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / post-M7: Clipper readability-pass review
  fix ("clipper doesn't die when I shoot" follow-up — verifying/fixing the prior E02/E04 backstop +
  teaching-cues pass)
Implemented behavior: verified all 4 findings from an independent review of the prior Clipper session
  (E02/E04 backstop relocation + STALL teaching cues) and fixed the 2 that were real; the Clipper rule
  itself (front shell always blocks; rear motor damageable ONLY during the wall-stall; 3 motor hits;
  1.6s wall_stall_time) was NOT touched. F1 (CRITICAL, confirmed) and F3 (CRITICAL, confirmed, same root
  cause): `clipper.tscn`'s `Visual/Photo` Sprite2D is a CHILD of `Visual`, and a CanvasItem child draws
  AFTER (on top of) its own parent's `_draw()` by default — the opposite of the intended "STALL overlay ON
  TOP of the photo" / "spark on top of the body". Since the motor site and typical frontal-impact points
  sit on OPAQUE photo pixels (only the eye-stalk/shear regions are erased/transparent in the source
  texture), the photo was silently painting over BOTH the STALL motor-exposed cue (glow/hatch/ring/stars)
  in `clipper_visual.gd` AND the frontal "armored" blocked-spark/chevron in `clipper.gd` — exactly matching
  the original playtest report and confirmed here two ways: a full-frame color scan of a real E02
  gameplay capture found zero `MOTOR_EXPOSED` (#d97a4a) pixels anywhere during an actual STALL, and an
  isolated forced-STALL rig showed the cues render correctly ONLY once `Photo.visible` was set false. Fix:
  `show_behind_parent = true` set on BOTH `Visual/Photo` (so it draws before `Visual`'s own `_draw()`,
  i.e. underneath the shear/eye/motor overlay) AND on `Visual` itself (so the whole Visual+Photo subtree
  draws before the Clipper root's own `_draw()` — the frontal spark and windup-warning triangle — keeping
  those topmost too); this is a pure z-order fix, no collision/hit-zone/rule/tuning change. Re-verified
  with an isolated forced-STALL+blocked-hit rig (motor glow/hatch/ring/stars AND the frontal spark now all
  render correctly) and, more importantly, with a fresh real-gameplay capture of the actual E02 encounter
  (`clipper_e02_sequence_demo.tscn`): a full-frame color scan now finds `MOTOR_EXPOSED` pixels in 8 of 200
  frames during the real STALL, and the motor glow/exclamation core is clearly visible by eye in the
  capture (previously zero, per the prior session's own report). F2 (CRITICAL, confirmed, harder to fix
  than the review's own suggestion): `clipper.tscn`'s `HintLabel` (offset_top/bottom -108/-80) and
  `clipper.gd`'s windup-warning-triangle draw (local y -102..-82) occupy nearly the same band. Moving only
  the label's BOX up (tried -140/-112 first) was NOT enough: `HintLabel`'s `autowrap_mode=WORD` wraps
  `Clipper.HINT_TEXT` into 3 lines at its 200px width, and a Godot `Label` does not clip vertically, so the
  wrapped text overflows well past `offset_bottom` — a pixel-level capture of a forced-hint+forced-WINDUP
  rig proved the -140/-112 attempt still had the triangle's glyph overlapping the tail of line 3. Moved to
  -180/-152 instead and re-verified with the same rig + a pixel color scan: the wrapped text (screen rows
  490-553 in that capture) and the triangle (rows ~570-604) now have a clean ~17px gap with zero
  overlapping rows. F4 (correctly identified by the review, not a bug): L01-E07's real stall→kill window
  is 0.95s (vs 1.60s for the other five Clippers, `test_clipper_real_level.gd`'s own natural-approach
  numbers, unchanged by this pass) because its extra CentralStep hop eats into repositioning time — but 3
  base-pistol shots at 0.32s cadence need only 0.64s back-to-back, so 0.95s still clears the plan's own
  explicit re-tuning trigger ("tune stall length if three base shots cannot fit comfortably") with ~0.31s
  to spare, and `killable=true` for E07 in the same test run. No tuning change made; `data/tuning/
  clipper.tres`'s `wall_stall_time` stays 1.6s, matching the "no tuning change needed" call the prior
  session already made. Deleted the temporary verification-only debug scenes/scripts this pass created
  (`zorder_verify_demo`, `hint_overlap_verify_demo`) once each fix was confirmed by capture — neither is
  part of the shipped project.
Files changed: `prototypes/sunnyvale-godot/scenes/actors/clipper.tscn` (`show_behind_parent = true` on
  `Visual` and on `Visual/Photo`; `HintLabel` offset_top/offset_bottom moved from -108/-80 to -180/-152),
  `prototypes/sunnyvale-godot/scripts/actors/visuals/clipper_visual.gd` (header comment documenting the
  z-order bug/fix, no logic change), `prototypes/sunnyvale-godot/scripts/actors/clipper.gd` (comment on
  `_draw_warning()` documenting the hint-label-overlap bug/fix, no logic change), this handoff entry. No
  test file needed a change — the existing `test_clipper_teaching.gd`/`test_m2_clipper.gd` only assert
  `hint_label.visible`/`.text`, never its screen position, so both fixes are pure presentation/z-order and
  needed no test updates.
Checks actually run and outcomes: `tools/test.sh` -> RESULT: 49/49 cases passed; `FPS=30 tools/test.sh` ->
  RESULT: 49/49 cases passed (both run twice, once right after the z-order fix and once more after the
  final HintLabel offset, both times clean); a `--filter=clipper` run separately confirms
  `test_clipper_real_level.gd` (59 checks: all six Clippers `killable=true`, E02/E04 stall on charge #1 at
  267/272px of the 384px cap with a 1.60s window, E07 at 219px/0.95s window, E09/E10/E11 all 1.60s) and
  `test_clipper_teaching.gd` (36 checks) both still pass unchanged. Visual fixes proven by capture, not by
  the headless suite (per CONVENTIONS.md, "visual captures prove readability"): an isolated forced-STALL
  rig and a forced-2-blocked-hits+WINDUP rig (both temporary, deleted after use) were captured via
  `tools/capture.sh` and inspected both by eye and by direct pixel/color-region scans (see above); the real
  `clipper_e02_sequence_demo.tscn` encounter was recaptured (200 frames/15fps) after the fix and a
  full-frame `MOTOR_EXPOSED` color scan found the cue present during the real STALL (8/200 frames) where
  the pre-fix capture (per the prior session's own report) found zero.
Remaining errors / placeholders / unverified gates: unchanged — gate 6 (first-time playtests) and
  T22-Windows/gate 7's Windows launch both remain pending. No new gaps introduced by this pass; the frontal
  spark/chevron cue (previously only inferred, not captured, per the prior session's own "known gaps" note)
  is now directly confirmed visible in the isolated rig capture.
Design deviations and reasons: none — this was a bugfix/verification pass only; the Clipper rule (front
  always blocks, rear only damageable in STALL, 3 motor hits, 1.6s stall) is byte-for-byte unchanged, and
  `data/tuning/clipper.tres` was not touched.
Save/schema compatibility notes: none — no Session/CheckpointService schema field changed; nothing here
  touches `Session.runtime_flags` or any other persisted/live-only state.
Next concrete action: unchanged — gate 6 (first-time playtests) and the Windows launch test remain the
  blockers for a fully verified M7. A good next capture: deliberately fire 1-2 frontal shots against a real
  encounter Clipper (not just the isolated rig used here) before it stalls, to confirm the frontal spark
  also reads correctly at actual gameplay framing/scale.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / post-M7: Kenney integration part A review
  fix (independent review of the part A verification pass)
Implemented behavior: verified 2 findings from an independent review of the Kenney part A pass and fixed
  both. (1, MAJOR, confirmed) The gem/checkpoint pickup sparkle was effectively invisible at real gameplay
  camera scale: `kenney_puff.gd`'s `gem_sparkle`/`gem_sparkle_cluster`/`checkpoint_sparkle` CPUParticles2D
  configs used `scale_min/max` (0.08-0.20 of the 512px `star_04`/`star_05` source, ~41-102px) that,
  combined with those two textures' own low peak alpha (~223/255 and ~213/255 of a mostly-transparent
  512x512 canvas), rendered as only a handful of near-invisible pixels once actually placed at the real
  GameCamera zoom (1.0) — reproduced directly by re-running `kenney_fx_demo.gd`'s `_gem_pickup()` sequence
  and pixel-sampling the resulting screenshot for GOLD (0 matching pixels in the 1280x720 frame at a
  diff<90 threshold, vs 2227 matching CREAM pixels in the same pass's `landing_dust` capture, proving dust
  puffs DO read at this same scale/zoom and the detection method is valid). Fixed by raising all three
  configs' `scale_min/max` ~2.7x and `alpha` to 0.95 (lifetime/amount/spread unchanged — still a short,
  one-shot puff, well short of `dirt_03`'s/pit-dust's own footprint); re-verified with a fresh
  `kenney_fx_demo.tscn` capture showing a clearly visible gold star burst at the hero on pickup, at the
  same real-gameplay camera scale used for the original (failing) capture. (2, MINOR, confirmed)
  `assets/kenney/README.md`'s own wiring-status callouts (audio, input-prompt icons, crosshair, light
  masks, particles) were stale — each said wiring was "a separate, later pass... not done here" when the
  prior three integration passes' code (confirmed here by direct read: `scripts/main.gd`'s
  `Input.set_custom_mouse_cursor()`, `scripts/ui/controls_panel.gd`'s per-binding `TextureRect` icons,
  `scripts/audio/audio_director.gd`'s `SFX_SOURCES`, `scripts/objects/scenery.gd`'s light-mask glows, and
  `kenney_puff.gd`'s 6 wired call sites) already ships all of it, and the passing `test_kenney_ui.gd`/
  `test_m65_kenney_fx.gd` suites already prove it. The top summary table's Particle Pack row also
  miscounted "9" files where the actual total sourced from that pack is 8 (6 wired under
  `assets/kenney/particle-pack/` + 2 of the 3 `clipper_later`-staged files, which are also sourced from
  `particle-pack/star_0N.png` — the third `clipper_later` file is from Smoke Particles, counted
  separately); `reports/asset-inventory.md`'s own §7 breakdown already tallied this correctly, so the
  miscount was isolated to the README. Fixed by rewriting each section's wiring-status note to say "done"
  (pointing at `reports/asset-inventory.md` §7 as the authoritative per-file reference, as that report's
  own known-gaps note already suggested) and correcting the Particle Pack count to 8. Neither fix touched
  gameplay, tuning, collision, IDs, save format, or any Clipper-owned file (`clipper.gd`/
  `clipper_visual.gd`/`clipper_front_hit_zone.gd`/`impact_spark.gd`/`tutorial_prompt.gd` + their scenes,
  `a02_gardens.tscn`, `clipper.tres`, Clipper tests — untouched, confirmed by `git status`/`git diff`
  before and after this pass).
Files changed: `prototypes/sunnyvale-godot/scripts/effects/kenney/kenney_puff.gd` (gem/checkpoint sparkle
  scale + alpha bump, comment explaining why), `prototypes/sunnyvale-godot/assets/kenney/README.md`
  (wiring-status notes corrected to "done" for audio/icons/crosshair/light-masks/particles, Particle Pack
  file count 9 -> 8), `prototypes/sunnyvale-godot/reports/asset-inventory.md` (new §7.8 documenting both
  fixes), this handoff entry.
Checks actually run and outcomes: `NOIMPORT=1 tools/test.sh` -> RESULT: 49/49 cases passed (including
  `test_m65_kenney_fx.gd` 17 checks); `NOIMPORT=1 FPS=30 tools/test.sh` -> RESULT: 49/49 cases passed. The
  gem-sparkle visual fix was proven by capture, not the headless suite (no test asserts on-screen particle
  pixels): a real, windowed run of `res://scenes/debug/kenney_fx_demo.tscn` was captured before and after
  the scale/alpha change; the "before" capture (matching the review's own evidence) showed 0 GOLD-matching
  pixels near the hero on pickup, the "after" capture shows a clearly visible gold star burst at the same
  camera scale.
Remaining errors / placeholders / unverified gates: unchanged — gate 6 (first-time playtests) and the
  Windows launch test remain pending. Part B (Clipper clang/stall particles, tutorial-prompt icons) is
  still not started, unaffected by this pass — see `reports/asset-inventory.md` §7.6.
Design deviations and reasons: none — a particle-tuning + documentation fix only; no gameplay, tuning,
  collision, ID, or save-format code was touched.
Save/schema compatibility notes: none — no Session/CheckpointService schema field changed; `Audio.play_sfx()`
  cue names and call sites are unchanged.
Next concrete action: unchanged — gate 6 (first-time playtests) and the Windows launch test remain the
  blockers for a fully verified M7; hand off part B once the concurrent Clipper workflow is no longer
  mid-edit.
~~~

~~~text
Date / agent / milestone: 2026-09-27 / Claude Code (Sonnet 5) / post-M7: Kenney integration part B
  (Clipper clang/stall particles + readable input-icon prompts)
Implemented behavior: wired the three `assets/kenney/particles/clipper_later/` files staged (not
  referenced) by the earlier Kenney pass, and gave the tutorial prompts + Clipper 2-hit hint the same C11
  panel material as `subtitle_panel.gd`/`toast_label.gd`, with inline Kenney key/mouse icons for prompts
  that name a binding.
  (1) Frontal clang: `clipper.gd::_on_front_blocked_hit()` now also calls
  `KenneyPuff.spawn(&"clipper_spark", hit_position, ...)` — a short (0.18s), warm-white/amber
  (`star_01_metal_spark.png`) burst at the exact impact point, additive to the EXISTING shape-based
  chevron/shield-flash cues (unchanged). `kenney_puff.gd`'s `CONFIGS` gained an optional
  `max_concurrent` field (only set for `clipper_spark`, cap 3) plus a static `_active_counts` tracker so
  rapid fire can never flood the screen with overlapping bursts — every other kind is unaffected/uncapped.
  (2) STALL venting: `clipper_visual.gd` gained two new `CPUParticles2D` children on `clipper.tscn`'s
  `Visual` node — `StallSteam` (cream `whitePuff00_stall_steam.png`, looping) and `StallStars` (peach
  `star_02_dazed_star.png`, 2 particles on `orbit_velocity` so they circle the motor), both positioned at
  the same `MOTOR_LOCAL` anchor the existing hand-drawn hatch/ring/stunned-glyph already use, both
  `show_behind_parent = true` (drawn UNDER `clipper_visual.gd`'s own `_draw()` — so the existing target
  ring/timer arc/stunned-star glyph stay on top and stay readable, exactly like `Photo`). New public fields
  `stall_effects_active`/`stall_static_visible` mirror which cue is live (the same "plain data a test can
  read" idiom `stall_remaining` already established) — both flip off the instant `stalled` goes false
  (RECOVERY) or `defeat_progress >= 0` (a defeat starts), never lingering. `Settings.reduced_motion` swaps
  the two looping systems for one static, non-emitting `StallSteamStatic` sprite instead of hiding the cue
  outright, matching the project's "never fully hidden" reduced-motion convention. `clipper.gd::_defeat()`
  also fires two one-shot effects (`clipper_defeat_smoke`, `clipper_defeat_spark`) for "a small smoke puff
  + a few spark bits".
  (3) Readable prompts + icons: new `scripts/ui/input_icon_map.gd` (no `class_name`, reached by
  `preload()` like every other M6/M6.5/M7-era helper here) pulls `controls_panel.gd`'s ORIGINAL
  `KEY_ICON_FILES`/`MOUSE_ICON_FILES` table and its layout-aware `_key_label()`/`_mouse_label()` logic out
  into one shared place (`icon_path_for_event()`, `tokens_for_action()`, `label_for_event()`, ...);
  `controls_panel.gd` was refactored to call it instead of duplicating it (`test_help_controls.gd` and the
  other two `test_help_regress_*` cases still pass unchanged, proving the refactor is behavior-preserving).
  `tutorial_prompt.gd` gained `icon_actions: Array[StringName]` and `static_icon_before: String` exports:
  it now resolves the CURRENT InputMap binding for each named action into a small `TextureRect` (falling
  back to a bracketed text token, e.g. `[Q]`, for any binding this pack has no icon file for — "text
  fallback if no icon exists" per the brief) via the SAME shared mapping. `tutorial_prompt.tscn` was
  restructured from a single bare `Label` into `Panel` (PanelContainer, C11 cream/warm-charcoal stylebox,
  the same material as `subtitle_panel.tscn`) > `Row` (HBoxContainer) > `Icons` (HBoxContainer) +
  `TextLabel` (>= 22px at Normal text size, `Settings.scaled_font_size()`-scaled, `size_flags_horizontal =
  EXPAND_FILL` so long text like the E02 line actually word-wraps across the panel's real width instead of
  one word per line — a bug caught and fixed via capture, see below). Showing/hiding now toggles the whole
  `Panel`'s visibility/modulate (was the lone `Label`'s) — the same "toggle the backing panel" idiom
  `SubtitlePanel`/`ToastLabel` already use. `a01_gate.tscn`'s three prompts were updated to the new
  icon-driven form (Move -> `[A][D]` "Move", Jump -> `[Space][W][↑]` "Jump", Aim+Fire -> a static
  `mouse_move.svg` icon + `[LMB]` icon + "Aim + Fire" text) with per-instance `Panel` width overrides for
  the extra icon columns; the E02 Clipper prompt (`a02_gardens.tscn`) and the Clipper's `HintLabel`
  (neither names a single key, so neither got icons) got the same cream-panel/warm-charcoal/scaled-font
  treatment, with the HintLabel's box enlarged and set to bottom-vertical-alignment so any text overflow
  from a larger font runs AWAY from the windup-warning triangle's band, never into it. Positions were kept
  (or, for the E02 prompt/HintLabel, moved further from the ground) so no prompt ever covers the hero, the
  warning triangle, or a landing edge.
Files changed: `prototypes/sunnyvale-godot/scripts/effects/kenney/kenney_puff.gd` (3 new CONFIGS kinds,
  `max_concurrent`/`_active_counts` cap, `effect_kind` inspection field),
  `prototypes/sunnyvale-godot/scripts/actors/clipper.gd` (spark/defeat-effect spawn calls, `HintLabel`
  text-size scaling), `prototypes/sunnyvale-godot/scripts/actors/visuals/clipper_visual.gd` (StallSteam/
  StallStars/StallSteamStatic wiring), `prototypes/sunnyvale-godot/scenes/actors/clipper.tscn` (the 3 new
  Visual children, HintLabel restyle), `prototypes/sunnyvale-godot/scripts/ui/input_icon_map.gd` (new),
  `prototypes/sunnyvale-godot/scripts/ui/controls_panel.gd` (refactored to use it),
  `prototypes/sunnyvale-godot/scripts/objects/tutorial_prompt.gd` and
  `prototypes/sunnyvale-godot/scenes/objects/tutorial_prompt.tscn` (icon/panel rework),
  `prototypes/sunnyvale-godot/scenes/levels/areas/a01_gate.tscn` and `a02_gardens.tscn` (prompt
  text/icon_actions/Panel overrides), `prototypes/sunnyvale-godot/scripts/debug/clipper_e02_sequence_demo.gd`
  (a deliberate frontal volley overlaid on the existing walk-in, for capture), new
  `prototypes/sunnyvale-godot/tests/cases/test_kenney_part_b.gd`, one existing test fixed
  (`tests/cases/test_m65_kenney_fx.gd`'s 50-effects flood check now excludes kinds with `max_concurrent`
  set — a capped kind being capped is the new feature working, not a silent drop; see that file's own
  updated comment), `tests/cases/test_clipper_teaching.gd` (2 `prompt.get_node("Label")` lookups updated to
  `get_node("Panel")`, matching `tutorial_prompt.tscn`'s new hierarchy — same visibility semantics),
  `assets/kenney/README.md` and `reports/asset-inventory.md` (clipper_later files + tutorial-prompt icons
  now documented as wired), this handoff entry. `scripts/objects/scenery.gd` was NOT touched (owned by a
  separate concurrent session fixing A06's cloud-projector discs).
Checks actually run and outcomes: `NOIMPORT=1 tools/test.sh` -> RESULT: 50/50 cases passed (was 48/49
  before the `test_m65_kenney_fx.gd` fix above — the one pre-existing failure was this pass's own cap
  feature interacting with that test's flood check, fixed, not a regression elsewhere); `NOIMPORT=1
  FPS=30 tools/test.sh` -> RESULT: 50/50 cases passed. `test_kenney_part_b.gd` (36 checks) covers: a
  blocked frontal hit never damages and its spark effect is capped at <= 3 concurrent and self-frees; the
  STALL steam/dazed-star loop turns on exactly at STALL and off exactly at RECOVERY; it also turns off the
  instant a defeat starts (one physics tick after the killing blow, matching `clipper.gd`'s own
  presentation-only pose-push timing) while the defeat's own smoke+spark effects spawn and later self-free;
  `Settings.reduced_motion` swaps the loop for the static puff and back; a `TutorialPrompt` resolves a real
  icon for `jump`'s default Space binding and falls back to a bracketed `[Q]` text token after rebinding to
  a key this pack has no icon for (InputMap restored after); prompt and hint text sizes are both >= 22px at
  Normal and grow at Large. All existing Clipper tests (`test_clipper_teaching.gd` 36 checks,
  `test_clipper_real_level.gd` 59 checks, `test_m2_clipper.gd` 25 checks,
  `test_m2_regress_clipper_shell_gap.gd` 3 checks) pass unchanged — the Clipper rule/tuning/collision/state
  machine timings were never touched, confirmed both by these tests and by a `git diff` review of
  `data/tuning/clipper.tres` and `clipper.gd`'s state-machine functions (`_tick_patrol`/`_tick_windup`/
  `_tick_charge_pre`/`_tick_charge_post`/`_enter_stall`/`_tick_stall`/`_enter_brake_recovery`/
  `_tick_recovery` — all byte-for-byte unchanged apart from the additive spawn calls in
  `_on_front_blocked_hit`/`_defeat`, which run after the existing state/damage logic and never influence
  it). Visuals confirmed by capture (`tools/capture.sh`, not asserted by the headless suite): the extended
  `clipper_e02_sequence_demo.tscn` (300 frames/15fps) shows the readable E02 prompt panel, a bright
  shell-flash + spark on a deliberate frontal volley during the walk-in, the exposed motor's steam cloud +
  orbiting dazed stars + target-ring/timer-arc all together and legible during STALL, and a smoke+spark
  burst at the kill; `m3_a01_demo.tscn` (150 frames/15ffs) shows all three A01 prompts with correctly
  resolved icons (`[A][←][D][→] Move`, `[Space][W][↑] Jump`, a mouse-move icon + `[LMB]` + "Aim + Fire") on
  a legible cream panel at 1280x720. One real bug was caught THIS way, not by the headless suite: the
  first capture of the E02 prompt wrapped its long sentence one word per line (the `TextLabel` inside the
  new `HBoxContainer` had no `size_flags_horizontal`, so it sized to its narrowest child rather than the
  panel's real width) — fixed by adding `size_flags_horizontal = EXPAND_FILL` and reconfirmed by a second
  capture showing the intended two-line wrap.
Remaining errors / placeholders / unverified gates: unchanged — gate 6 (first-time playtests) and the
  Windows launch test remain pending. `scripts/objects/scenery.gd`'s `CLOUD_PROJECTOR` kind is being fixed
  in a separate concurrent session, deliberately untouched here.
Design deviations and reasons: the task brief's example prompt format "[mouse] Aim + [LMB] Fire" (icons
  interleaved with their own words) was simplified to "icons, then the combined label" (`[mouse][LMB] Aim +
  Fire`) — still names the current binding(s) with real icons and text right beside them, but avoids
  building a second, more complex per-segment layout model for the one compound prompt that needs it.
  Otherwise none — the Clipper rule/tuning/collision/IDs/save format are byte-for-byte unchanged; every
  addition here is visual/presentation-only, following the same "presentation reads state, never writes it
  back" split M6's `clipper_visual.gd` already established.
Save/schema compatibility notes: none — no Session/CheckpointService schema field changed; `Audio.play_sfx()`
  cue names, `Session.runtime_flags` keys, and every persisted field are untouched.
Next concrete action: gate 6 (first-time playtests) and the Windows launch test remain the blockers for a
  fully verified M7. The Kenney integration (parts A and B) is now complete end-to-end — every staged asset
  in `assets/kenney/` is either wired or explicitly documented as a deliberate keep (the 5 synthesized SFX
  cues, per `reports/asset-inventory.md` §1).
~~~

~~~text
Date / agent / milestone: 2026-09-28 / Claude Code (Sonnet 5) / post-M7: Kenney part B review fixes
Implemented behavior: verified all 3 findings from the Kenney part B code review end-to-end (never took the
  review's own evidence on faith — reproduced each with a temporary scene/probe, deleted after use) and
  fixed all 3; none were false positives.
  (1) **hint-label-covers-hero (major, confirmed, fixed).** `clipper.tscn`'s 2-hit `HintLabel` was a plain
  `Label` at a FIXED local offset under the Clipper itself — world-space, not screen-space — so it tracked
  the CLIPPER's position, not the hero's. A hero standing/jumping near that offset (confirmed at Hero
  tuning's own max jump-apex head height, ~250px above ground, well within the panel's local ±160px
  x-extent — reproduced with a temporary scene, deleted after use, and a capture matching the review's own
  evidence: only the hero's legs visible below an opaque panel) rendered directly behind it — a very
  ordinary "walk up and mash fire into the shield" sequence, not an edge case. Fixed by moving the Label
  under a new `HintLayer` `CanvasLayer` child of Clipper (`clipper.gd`'s `hint_label` now resolves
  `$HintLayer/HintLabel`): a `CanvasLayer` ignores its parent's world transform entirely, so the hint now
  renders as a fixed top-center screen toast (y 260-428, clear of the HUD's own Toast row at 82-120) —
  its on-screen position no longer depends on either actor's world position at all, proven by a new
  regression test (`test_clipper_teaching.gd::_test_hint_is_screen_anchored_never_tracks_clipper`, 4
  checks: the label's parent is a `CanvasLayer`, and its `get_global_rect()` is identical before/after
  triggering the hint AND after moving the Clipper 3000px away). Reconfirmed by a fresh capture at the
  original bug's exact repro pose: the hero is now fully visible above the panel with a clean gap.
  Residual, disclosed honestly: the panel is 94% opaque (not 100%) and, exactly like the HUD's own
  pre-existing top-center Toast/top-right ObjectiveLabel, CAN still coincide on-screen with a hero at a
  real jump's peak height depending on camera framing (confirmed in the E02 capture below, during the
  backstop-clearing jump, the hero's hair/hat lightly grazes the panel's bottom border, translucent, for
  that jump's peak instant only) — a fundamentally different, far less severe category (translucent,
  fleeting, coincidental) than the original bug (opaque, guaranteed, sustained for the whole 4s hint
  display at ordinary melee range). A fully pose-proof fix (e.g. dynamically repositioning around the
  hero's live on-screen rect) was judged out of scope for this fix pass; not attempted.
  (2) **space-icon-illegible-at-render-size (minor, confirmed, fixed).** `keyboard_space_outline.svg`
  bakes the word "SPACE" as vector art into its 64x64 canvas; at this project's 26-28px icon render size
  it reads as an illegible smudge (reconfirmed by zoomed capture, matching the review's own evidence),
  unlike every single-glyph key icon (A/D/W/E/arrows) which stays crisp at the same size. Checked the
  other short multi-letter icons the review flagged as "likely" affected (Esc/Tab/Enter/F1) against fresh
  captures of the real Controls-help menu — all four stay legible at this size (2-3 letters, or a
  pictogram for Enter), so only Space's table entry needed to change. Fixed by removing `KEY_SPACE` from
  `input_icon_map.gd`'s `KEY_ICON_FILES`; every caller already falls back to plain text for a binding with
  no icon file (the same mechanism used for any key this pack has no icon for at all), so Jump's row now
  shows `[Space]` `[W]` `[↑]` instead of a blurry icon — confirmed by a fresh capture of both the A01 Jump
  prompt and the Controls-help menu (title screen).
  (3) **e02-capture-never-exercises-2hit-hint (minor, confirmed, fixed) — a capture/evidence gap, not a
  gameplay bug.** `clipper_e02_sequence_demo.gd`'s own deliberate frontal volley against the real A02 E02
  encounter only ever landed 1 blocked hit before WINDUP ended and CHARGE began (reproduced with a
  temporary headless probe, deleted after use, that logs the Clipper's state/hit-count every frame). Root
  cause: the scripted hop over the stone backstop (`R05_JumpBackstop1`) happens to occur DURING WINDUP,
  and the demo's shared `jumping` branch unconditionally released fire for that jump's whole ~0.65s
  airtime, eating almost the entire 0.8s WINDUP window. Fixed by keeping the deliberate frontal volley
  active through that one hop specifically while `clipper.state` is still `PATROL`/`WINDUP` (the later
  CHARGE-dodge jump is untouched, still releases fire as before); reverified with the same probe: 2 hits
  now land at frames 100 and 115, a full 9 frames before CHARGE begins at frame 124 (was 1 hit landing 1
  frame before CHARGE). Reconfirmed by a fresh capture: the real HintLabel now legibly appears mid-WINDUP
  in this exact demo for the first time. No Clipper rule/tuning/state-machine timing changed — only this
  debug capture demo's own input-driving logic.
  `scripts/objects/scenery.gd` was NOT touched (owned by a separate concurrent session fixing A06's
  cloud-projector discs, per the task brief).
Files changed: `prototypes/sunnyvale-godot/scenes/actors/clipper.tscn` (HintLabel moved under a new
  `HintLayer` CanvasLayer, screen-anchored offsets), `prototypes/sunnyvale-godot/scripts/actors/clipper.gd`
  (`hint_label` onready path + doc comments updated for the new screen-anchored toast; stale
  "-180..-152"/"-108..-80" offset comments corrected), `prototypes/sunnyvale-godot/scripts/ui/
  input_icon_map.gd` (`KEY_SPACE` removed from `KEY_ICON_FILES`, doc comment explaining why),
  `prototypes/sunnyvale-godot/scripts/debug/clipper_e02_sequence_demo.gd` (keep firing through the
  backstop hop while still PATROL/WINDUP), `prototypes/sunnyvale-godot/tests/cases/test_clipper_teaching.gd`
  (new `_test_hint_is_screen_anchored_never_tracks_clipper`, 4 checks), `prototypes/sunnyvale-godot/
  assets/kenney/README.md` and `prototypes/sunnyvale-godot/reports/asset-inventory.md` (new §7.9
  documenting all 3 fixes; Space's table row updated), this handoff entry. No temporary review/probe
  scenes left behind (`kb_fix_hint_repro.tscn/.gd`, `test_probe_kb_fix_repro.gd`,
  `test_probe_e02_timing.gd` were all deleted after use, matching the pre-existing pattern of this
  review's own now-deleted `review_clipper_full_demo.tscn`/`test_probe_kb_e02_timing.gd`).
Checks actually run and outcomes: `NOIMPORT=1 tools/test.sh` -> RESULT: 50/50 cases passed (including the
  4 new hint-screen-anchoring checks); `NOIMPORT=1 FPS=30 tools/test.sh` -> RESULT: 50/50 cases passed.
  Headless-launched `res://scenes/main.tscn` for 120 fixed-step frames (`--quit-after 120`): zero
  errors/warnings. Visuals reconfirmed by fresh capture (`tools/capture.sh` + a runtime-screenshot capture
  for the Controls menu, not asserted by the headless suite): a temporary repro scene at the exact
  original bug pose shows the hero fully clear of the (now top-center) hint panel;
  `clipper_e02_sequence_demo.tscn` now shows the real HintLabel appearing legibly mid-WINDUP (previously
  never observed); the A01 Jump prompt and both the Title-screen and Pause-menu Controls-help views show
  `[Space]` as text next to crisp `W`/`↑` icons instead of an illegible Space icon. All existing Clipper
  tests (`test_clipper_teaching.gd` now 40 checks, `test_clipper_real_level.gd`, `test_m2_clipper.gd`,
  `test_kenney_part_b.gd`) pass unchanged apart from the one new sub-test added above — the Clipper rule/
  tuning/collision/state-machine timings were never touched (confirmed both by these tests and by `git
  diff` review: `data/tuning/clipper.tres` and clipper.gd's state-machine functions carry no changes from
  this pass beyond the `hint_label` path/comments above).
Remaining errors / placeholders / unverified gates: unchanged — gate 6 (first-time playtests) and the
  Windows launch test remain pending. The hint panel's residual "can coincide with a hero at real jump-peak
  height, translucently, briefly" behavior (see above) is disclosed as a known, low-severity, HUD-typical
  limitation, not re-opened as a new finding.
Design deviations and reasons: none beyond the review's own suggested fixes — screen-anchoring the hint
  (suggested option (c)) was chosen over clamping/repositioning in world-space (option (a)) or narrowing
  the box (option (b)) since it removes the whole HAZARD CLASS rather than one instance of it, matching
  how every other similar one-off toast in this project (`SubtitlePanel`, `Hud`'s own Toast) is already
  built. The Space-icon fix used the review's own suggested option (fall back to bracketed text) rather
  than enlarging the icon, since the project's existing icon-or-text-fallback mechanism already existed
  and needed no new code path.
Save/schema compatibility notes: none — no Session/CheckpointService schema field changed; `Audio.
  play_sfx()` cue names, `Session.runtime_flags` keys, and every persisted field are untouched. The
  Clipper rule/tuning/collision/IDs are byte-for-byte unchanged.
Next concrete action: gate 6 (first-time playtests) and the Windows launch test remain the blockers for a
  fully verified M7. Kenney part B is now review-clean (all 3 findings resolved, 0 rejected).
~~~

~~~text
Date / agent / milestone: 2026-09-28 / Claude Code (Opus 5.5) / post-M7: Rook sprite pack
Implemented behavior: the hero now uses the user-generated Rook sprite pack (ChatGPT, from
  concept-art/h01-rook/rook-sprite-brief-for-chatgpt.md) instead of the M6 procedural rig: idle x2,
  run x6, jump rise/fall, land, hurt, defeated, interact, plus a separate aiming arm on AimPivot.
  tools/process_rook_sprites.py cleans generator alpha noise, normalises the 3-16% per-frame scale
  drift, aligns feet (airborne frames by head height) and records per-frame shoulder pivots.
Gameplay-visible change: AimPivot now sits on the current frame's shoulder (was a fixed point 35 px
  above the feet) and the Scrapjack sits in the fist at arm's length, scaled 0.65; shots leave from
  the pistol there. hero.gd now updates the visual before the aim pivot so the arm never lags the body.
  Immunity tint softened (1.0/0.55/0.55 -> 1.0/0.86/0.8) for the detailed sprite.
Files changed: concept-art/h01-rook/sprites-v1/* (source pack), tools/process_rook_sprites.py,
  assets/characters/rook/*, scripts/actors/visuals/rook_frames.gd (generated),
  scripts/actors/visuals/hero_visual.gd (rewritten), scripts/actors/hero.gd, scenes/actors/hero.tscn,
  tests/cases/test_rook_sprite_rig.gd (new, 55 checks), scenes/debug/rook_rig_demo.tscn (+ script),
  reports/asset-inventory.md §8
Checks actually run and outcomes: tools/test.sh and FPS=30 tools/test.sh -> 52/52 cases passed;
  headless boot of main 120 frames, no errors; close-up captures (aim right/up/left/down, run, jump,
  land, hurt, defeated) and route captures inspected
Remaining gaps: left-facing is mirrored (forelock/eyebrow flip); run cycle bobs ~15 px as drawn;
  pistol is still the procedural drawing
~~~

~~~text
Date / agent / milestone: 2026-09-28 / Claude Code (Opus 5.5) / post-M7 playtest fixes (user feedback)
1) "When running fast the hero gets blurry": not the sprite art (1x captures show identical sharpness
   standing vs running). Cause: 60 Hz physics vs the 120 Hz ProMotion display — the hero moved on every
   other refresh while the camera moved every refresh. Fix: physics/common/physics_interpolation = true
   (via scripts/tools/configure_project.gd), GameCamera follows on physics ticks
   (process_callback = PHYSICS) so it is interpolated like the hero, and Hero.respawn_at() calls
   reset_physics_interpolation() so teleports don't draw a slide. Needs confirmation on the 120 Hz
   display (Movie Maker captures cannot show judder).
2) "Hand points backwards when the mouse is behind the body": the body now always faces the aim side
   (8 px deadzone); moving away from the aim backpedals with the run cycle reversed.
   DESIGN DEVIATION (playtest-driven): G02 (design/01-core/player-controls.md) proposes "facing follows
   deliberate aim while firing and movement otherwise"; the prototype now faces the aim at all times.
   Camera look-ahead now follows the direction of travel (falls back to facing when still) so hazards
   ahead stay previewed while backpedalling.
Checks: tools/test.sh and FPS=30 tools/test.sh -> 52/52 (test_rook_sprite_rig.gd now 60 checks: facing,
  backpedal order, interpolation + camera settings); backpedal close-up captured and inspected.
~~~

~~~text
Date / agent / milestone: 2026-09-29 / Claude Code (Opus 5.5) + 4 helper agents / REVAMP REBUILD (C24)
Why: the user replaced the story and look (design/decisions.md C14–C24): no zombies; evil corporation
  Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan (28, he/him); microchips replace
  gems; mysterious, a little scary, sci-fi (2D Metal Gear + Dangerous Dave references); no stealth.
Implemented behavior:
  - Scripted rename across 101 files: Resident->Staffer (cyborg, CY01 ids), gem->chip, artifact->evidence
    (EF01 "Lockout Notice"), bench->workbench, core_console->core_node, care_capsule->med_patch,
    EDEN->Adam, quarantine->lockdown, suburb->campus. Save schema 1->2 (old saves are rejected cleanly).
  - Keycard (P19): `L01-KC01` on the A04 porch (main route, unmissable); `ExitWicket` stays locked (red
    reader, "Clearance card required" toast) until held; HUD card icon; Session.take_keycard()/has_keycard();
    CheckpointService whitelists `^L01-KC[0-9]{2}$`; rollback restores the card.
  - SC01 is now the core-node uplink: drive plugged in, copy bar, lights dim, Adam: "Hello, Dr. Harlan. I
    was told you'd been let go." / Dave: "Word gets around." / Adam: "I'm glad you came back. Please stay
    where you are." -> copy stalls at 41%, lockdown, hatch opens. Same 19 s, same _finish_awakening().
  - World (helper W): night campus — night sky, glass towers with lit windows, Arcadia emblem tower
    landmark, "Sunny" smile holograms, fog bands, lit platform top edges, 54 extra lamps (a light near
    every landing), PointLight2D lamps/beacons/depot fixtures, Dave's wrist light, lockdown lighting
    (amber/red, slow pulses, steady under reduced motion), night overlay (vignette/grain, layer 5).
  - Enemies (helper S): fully procedural cyborg Staffer (Link implant teal/amber/red-tell/dark), zombie
    cutouts deleted (C23); Clipper night pass with lens rule; defeated Staffers stay slumped as scenery.
  - Audio (helper A): gen_audio.py rewritten; campus/lockdown music loops; cyborg, chip, keycard, door,
    uplink, lockdown and Adam-chime cues (40 cues, 16 synthesized); music loop-length bug fixed.
  - UI: dark theme (c11_theme.tres restyled), night HUD, microchip icon, speaker-colored subtitles
    (Adam teal, Dave orange), new title tagline, EF01 journal text, dark tutorial/hint panels.
Checks actually run and outcomes: tools/test.sh -> 54/54 cases passed after integration; helper captures
  of all six areas (pre/post lockdown, seams, reduced motion) and enemy state boards inspected.
Incident: a helper's capture of scenes/debug/m3_a04_demo.tscn wrote a checkpoint.json into the REAL save
  dir (that demo lacked the redirect). The file was moved out; no prior user save existed there (no
  .bak). Fixed: m3_a04_demo.gd now redirects in _enter_tree().
Remaining: first-time playtests (gate 6) and the Windows launch remain pending; exports are stale;
  placeholder hero art is the old Rook sprite pack (reads as a young man in an orange jacket).
~~~

### 2026-09-30 — Enemy roster v3 docs and the lit-cutout test (C25–C35)

- **User decisions (2026-09-29/30):** human enemies; easy-to-build but varied enemies designed around Godot's capabilities; enemy guns including futuristic ones; a mature game with visible blood; cyborg dogs; the approved 24-type roster (Thornwall confirmed as a faction; the Rivet Drone dropped); the Clipper removed entirely; Level 1 to be rebuilt from the ground up; garden-era names renamed; enemy art as a lit cutout rig with smooth realistic light, Mixamo motion and ragdoll deaths. Recorded as C25–C35 and P22–P23 in `design/decisions.md`; the docs were rewritten to match (concept, style guide, 43 art briefs in new folders, 12 level briefs with L2/L5/L6 renamed, all design system docs, campaign.json, manifest.json).
- **Lit-cutout test** (`prototypes/sunnyvale-godot/spike/lit_cutout/`, self-contained; see its README):
  - the guard is painted procedurally by `tools/spike/paint_night_guard.py` (placeholder art) with height-derived normal maps;
  - `lit_part.gdshader` lights it through Godot 2D lights with a night ambient;
  - the Level 1 lamp's stepped light is swapped at runtime for a smooth cone placed at the lamp head (normal-mapped light needs the light at its real position);
  - Dave is lit the same way through auto normal maps (`tools/spike/make_normal_maps.py`) plus a muzzle-flash light.
- **Ragdoll findings:**
  - Godot 4.7.2's PinJoint2D angular limits did not constrain anything in probes, so joint limits are a damped spring torque in `ragdoll_part.gd`;
  - snapping rotations fought the pins and pushed limbs through the floor;
  - hands, feet and the head ride on their parent part (as separate bodies they twisted past any wrist, ankle or neck);
  - bodies settle into still corpse sprites, and blood pools spread under them.
- **Mixamo:** `tools/spike/mixamo_to_rig.py` (Blender) converts FBX clips to rig rotations; verified on synthetic Mixamo-named armatures only (no real Mixamo files on this machine; the user downloads them with their own Adobe account).
- **Verified:** `tools/test.sh` → 55/55 cases; autoplay captures (`-- --autoplay`) reviewed at 1x and 2x zoom.
- **User review (2026-09-30):** the user approved the look ("i really like this"); C35 is marked validated.
- **Pending:** real Mixamo clips; final painted art; the C33 ground-up Level 1 rebuild.

### 2026-09-30 — Cleanup ("remove unnecessary code and files")

- **Removed:**
  - `exports/`: 568 MB of stale, pre-revamp builds, gitignored and rebuildable.
  - Two stale Claude Code worktrees under `.claude/worktrees/` and their merged branch.
  - 14 one-off debug capture demos. Kept: the `m3_*` area and route demos, `m4`/`m5`/`m5b`/`m6_characters`/`m6_ui` demos, `m7_export_driver`, `route_bot`/`route_point` and `sample_area`.
  - The Clipper's three unused reference images and `tools/derive_character_sprites.py`.
  - 7 Kenney interface sounds the audio code no longer uses.
  - The painter's preview images; they now go to a folder passed with `--preview`.
  - `.DS_Store` clutter.
- **How removals were made:** tracked files were removed with git (recoverable from history). Untracked files were moved to the session scratchpad instead of deleted.
- **Restored:** `scripts/tools/configure_project.gd` was restored after a mistaken removal. CONVENTIONS names it as the way to regenerate `project.godot`'s input and display settings. It now includes the F1 help action and the night clear color, and rerunning it leaves `project.godot` unchanged (verified on a copy).
- **Kept on purpose:** the Clipper, Staffer and their tests still run the current Level 1 build. They are replaced in the C33 ground-up rebuild.
- **Verified:** `tools/test.sh` → 55/55; the main scene and the lit-cutout test launch headless with no errors.

### 2026-09-30 — Level 1 rebuild built (C33)

- **What:** C33 (rebuild Level 1 from the ground up around the C31 roster), after the approved lit-cutout test (C35). The C24 build's Staffers (CY01) and the Clipper are gone. Level 1 now has three enemies, all lit cutouts that die and bleed: the SE01 Night Guard, the M01 Patrol Rover and the LK01 Staffer. The six-area route, beats, economy, checkpoints, keycard exit and Adam's scene keep their design; the A02, A03, A04 and A06 scenes were edited for the new enemies, the annex doors and the renamed route markers.
- **Enemies:**
  - **SE01 Night Guard** (`scenes/actors/night_guard.tscn`, `scripts/actors/brawler.gd`, class `Brawler`, tuning `data/tuning/night_guard.tres`, `BrawlerTuning`): 3 health, stun baton overhead swing. He patrols, notices at 520 px, winds up for 0.5 s (baton light amber, red for the last 0.25 s), swings, then has a 1.2 s recovery (the punish window). He barks lines.
  - **M01 Patrol Rover** (`scenes/actors/patrol_rover.tscn`, `scripts/actors/patrol_rover.gd`, class `PatrolRover`, tuning `data/tuning/patrol_rover.tres`, `ChargerTuning`): the armored front always blocks (`ArmorHitZone`). It patrols, acquires by line of sight (640 px), winds up for 0.8 s (lightbar amber, then red for the last 0.25 s) and charges up to 4H. A charge into a stone backstop stalls it for 1.6 s: the rear hatch swings open and the teal battery is exposed, and 3 battery hits destroy it. A missed charge brakes into a 0.6 s recovery.
  - **LK01 Staffer** (`scenes/actors/staffer.tscn`, the same `Brawler` script, `data/tuning/staffer.tres`): 2 health. It is dormant until its encounter wakes it, then walks out, winds up for 0.65 s (its hands glow), makes a grab lunge of 1.2H and has a 0.8 s stumble recovery. Its implant (the "Link") glows dim while dormant and steady once awake.
  - The Clipper is gone entirely (enemy, art, sounds, tests), as are the old Staffer visual and the M6 characters demo.
  - Humans die into a pinned ragdoll that settles into a corpse with a blood pool (visible blood, C29). A destroyed rover bursts into loose debris that settles in an oil pool, never blood. The shot's green HIT spark is skipped on anything that bleeds (`HitZone.bleeds`); the target shows its own blood.
- **Encounters and entity IDs** (the save schema is now **3**, because every enemy ID changed):
  - A02 gardens: E01 Night Guard `L01-E01-SE01-01`; E02 Patrol Rover `L01-E02-M01-01`, with the tutorial prompt `e02_rover_intro` ("Rovers are armored in front. Let it crash into the stone planter."); E03 Night Guard `L01-E03-SE01-01`; E04 Patrol Rover `L01-E04-M01-01`.
  - A03 roofs: E05 Night Guard `L01-E05-SE01-01`; E06 Night Guard `L01-E06-SE01-01`.
  - A04 square: E07 Night Guard `L01-E07-SE01-01` and Patrol Rover `L01-E07-M01-01`; E08 Night Guards `L01-E08-SE01-01` and `-02`; E09 Night Guard `L01-E09-SE01-01` and Patrol Rover `L01-E09-M01-01`.
  - A06 exit: E10 Patrol Rover `L01-E10-M01-01` and Staffer `L01-E10-LK01-01` (new; dormant in a "STAFF ANNEX" door at x 2080); E11 Staffer `L01-E11-LK01-01` (annex door at x 4300) and Patrol Rover `L01-E11-M01-01`.
  - Totals: 8 Night Guards, 6 Patrol Rovers, 2 Staffers (16; the C24 build had 9 Staffers and 6 Clippers).
  - Route markers renamed: A04 `RP02_PastGuard`, `RP07_PastRover`, `RP15_PastGuard1`, `RP16_PastGuard2`, `RP21_PastE09Guard`, `RP24_PastE09Rover`; A06 `RP11_PastRover`.
  - The help screen tip now reads "Patrol Rovers stall against stone: shoot the battery on their back."
- **Design deviation (A06):** the level brief has two Staffers and no rovers at the alarm exit. A06 keeps its two rovers and adds the second Staffer, because A06's stone backstops exist only for the rovers and its final rover encounter is the level's "use what you learned" test. A06 now has 2 Staffers and 2 rovers. Recorded in `02-area-blueprints.md`.
- **Story:** at the exit wicket a Security PA line plays: "All teams: lethal force is authorized. Harlan is armed." The completion screen opens 3.2 s later (`LevelDirector.PA_BEAT`). The level-ended signal still fires at once.
- **Look (C35 lit cutouts):**
  - The shared shader is `assets/shaders/lit_part.gdshader` (normal-mapped, with specular and emissive maps).
  - Rigs are in `assets/characters/lit/<night_guard|staffer|patrol_rover>/` (`albedo.png`, `normal.png`, `spec.png`, `rig.json`). The Night Guard has 16 parts, the Staffer 15 and the rover 10 (a machine rig: chassis, dome, lightbar, bumper, hatch, battery and four wheels).
  - Code is in `scripts/actors/lit/` (`cutout_rig.gd`, `rig_animator.gd`, `clips_night_guard.gd`, `clips_staffer.gd`, `ragdoll.gd`, `ragdoll_part.gd`, `lights.gd`). Blood is `scripts/effects/blood.gd` with `assets/effects/blood/`.
  - Art tools are in `tools/art/` (see its `README.md`): the shared `lit_rig_common.py`; the painters `paint_night_guard.py`, `paint_staffer.py`, `paint_patrol_rover.py` and `paint_blood.py`; `make_normal_maps.py` (Dave's normal maps, in `assets/characters/rook/normals/`); and the Mixamo tools `mixamo_to_rig.py`, `make_test_armature.py` and `README-mixamo.md`. The art is procedural placeholder art.
  - Dave is lit the same way (a normal map per Rook frame, used in `hero_visual.gd`).
  - Night lighting: `scenes/world/night_lighting.tscn` (a cool moonlight rim on characters), instanced by the LevelDirector. Lamps, beacons, fountains and depot fixtures use smooth light falloff, and each shot flashes a short muzzle light.
  - The `spike/` test folder and `tools/spike/` are deleted; the enemy lab replaces them.
- **Audio:** 11 new cues: `guard_windup`, `guard_swing`, `hit_flesh`, `body_fall`, `rover_patrol`, `rover_windup`, `rover_charge`, `rover_stall`, `rover_armor`, `rover_destroyed` and `debris_clatter`. The Staffer cues are revoiced (`staffer_windup` implant chirp, `staffer_lunge` grab whoosh, `staffer_defeat` collapse plus implant fizzle), and `link_chirp` now plays once when a dormant Staffer wakes and its Link light steadies (`brawler.gd` `_enter()`; its old caller, `staffer_visual.gd`, is deleted). All `clipper_*` cues and their unused Kenney sounds are removed, and the Kenney particles moved from `particles/clipper_later/` to `particles/machines/`. There are now 46 SFX cues: 27 synthesized and 19 Kenney.
- **Debug and tests:**
  - `scenes/debug/enemy_lab.tscn` is a lit test strip with all three enemies, lamps, a stone backstop and an annex door. Keys: 1 guard, 2 Staffer, 3 rover, K kill all, C clear bodies, N normal maps on/off, M moonlight, B blood, Z zoom, T slow motion, I invulnerable, F1 help, Esc quit. `-- --autoplay` plays a scripted tour for captures. Saves and logs go to `user://enemy_lab_throwaway`.
  - Tests: 56 files. New: `test_lit_enemies.gd` (rigs, blood, ragdolls, rover wreck and oil), `test_enemy_tells.gd` (tell lights) and `test_m2_night_guard.gd` (T04 for the guard: the swing warns for its full windup, its AttackBox is live only in the swing's active window, one swing costs exactly 1 health, overlap alone never hurts, a hit never interrupts a windup or a swing). Renamed from the Clipper: `test_m2_rover.gd`, `test_m2_regress_rover_shell_gap.gd`, `test_rover_hint_placement.gd`, `test_rover_real_level.gd` (all six real rovers are killable on the natural approach) and `test_rover_teaching.gd`. The test runner now reports a case that fails to compile as FAIL instead of hanging.
- **Renamed and moved:** `staffer.gd` became `brawler.gd` (`Brawler`) and `clipper.gd` became `patrol_rover.gd` (`PatrolRover`); `StafferTuning` became `BrawlerTuning` and `ClipperTuning` became `ChargerTuning`; `clipper_front_hit_zone.gd` became `armor_hit_zone.gd` (`ArmorHitZone`); `data/tuning/clipper.tres` became `patrol_rover.tres`. The spike's rig, ragdoll, blood and shader files moved into `scripts/actors/lit/`, `scripts/effects/` and `assets/shaders/`, and `tools/spike/` became `tools/art/`.
- **Verified (2026-09-30):**
  - `tools/test.sh` → 56/56 cases.
  - A full-level RouteBot screenshot tour of the real `level_01.tscn` (lighting, overlay, invulnerable hero; 67 shots): the whole route completes; guards bark, wind up and swing; rovers charge and stall against the stone; the annex Staffers walk out and lunge; the PA line and the completion screen show.
  - The enemy lab's autoplay tour at 2x zoom: the guard's ragdoll and blood pool, the rover's stall against the cracked stone and its debris, the Staffer's amber-then-red hand tell, lunge and death.
  - Real-time frame rate over the full route (`M6_PERF_LOG=1`, windowed, Apple M1 Pro): a steady 120 fps (the display's vsync cap), minimum 115 after loading.
  - Rerunning every `tools/art/` tool rewrites the committed rigs, blood and Dave's normal maps byte for byte.
- **Loose ends found while updating the docs:**
  - Removed after the docs pass as unused: the Kenney `smoke_02.png` with its `defeat_puff` kind in `kenney_puff.gd`, and `particles/machines/star_02_dazed_star.png`.
  - `night_lighting.gd` documents a known limit: in Godot 4.7.2's Compatibility renderer the moonlight also faintly washes the world, not only the characters.
  - `prototype-spec.json` is updated to its schema 3: the SE01/M01/LK01 enemy types, per-area and per-encounter Night Guard, rover and Staffer counts, the health values and the beat names.
- **Playtest change (2026-09-30), Dave's facing:** running now faces the way he runs, even with the mouse behind him ("going backward, he should face that way"). While he runs away from the aim the gun rests pointing ahead, never backwards across his body. Standing still or shooting faces the aim, so shooting while backing off still backpedals, and he stays turned for 0.4 s after the last shot (`hero.gd` `_update_facing`, `FIRE_FACING_HOLD`). This returns to G02's rule ("facing follows deliberate aim while firing and movement otherwise") and replaces the 2026-09-28 "always face the aim" deviation. Checked in `test_rook_sprite_rig.gd`.
- **Patrol Rover art (2026-10-03):** the rover now uses the user's generated parts sheet (`concept-art/m01-patrol-rover/`), imported by `tools/art/import_parts_sheet.py patrol_rover` (the importer gained a machine path: parts placed on the chassis, a grey background removed). It is a long, low patrol car with a magenta flank strip (C36 neon) and a magenta underglow light; the sensor pod sits on the hood and no longer sways. The body box is 92 px long instead of 64, with the front, rear and shell hit zones resized to stay contiguous; the hatch hinges at its front edge, so it opens with a positive angle (`HATCH_OPEN`). On death the neon, the sensor lens and the lightbar go dark, and the Night Guard's lime trim (and a Staffer's Link light) now go dark on its body too. `test_rover_teaching.gd` checks the hatch's opening by size, not sign. Full suite 57/57; all six real rovers are still killable on the natural approach.
- **Playtest fix (2026-10-04), guards running in place:** a guard in reach of Dave but waiting for the encounter's attack token (another guard or a rover holds it), or in an encounter that isn't active, stood still while playing his run cycle. He now holds in his idle pose until his turn (`brawler.gd` `_tick_approach`). New check in `test_night_guard_movement.gd`: two guards with Dave between them take turns, and neither runs in place (it failed before the fix with a 46-frame run). Full suite 57/57; the exported debug build plays New Game → CP01 → Continue → the completion screen.
- **Playtest fix (2026-10-04), fire at the left of the first area:** effects spawned at the world origin and moved into place afterwards were drawn partway from the origin on their first frame by physics interpolation (on since 2026-09-28); in the first area the origin is on screen, so each shot showed a stray muzzle-flash puff there. Kenney puffs, Scrapjack bolts, blood sprays and pools and the keycard toast now call `reset_physics_interpolation()` once placed. Confirmed fixed by the user; full suite 57/57; the exported debug build plays to the completion screen.
- **Shooting look and feel (C37, 2026-10-04):** the Scrapjack's shot is now an ivory tracer slug (`scrap_bolt.gd`: a tapered ivory streak with a dark outline, a bright head, a fading trail and a small travelling light), replacing the amber bolt that broke the style guide's color rules. The muzzle draws an ivory starburst, and one muzzle light flares per shot and holds a glow through rapid fire instead of strobing; the amber Kenney muzzle puff and `muzzle_02.png` are removed (tinted ivory it read as a white cloud). Impacts (`impact_spark.gd`) throw white sparks and dark scrap chips with a brief light: HIT is a filled flash with a round burst, BLOCKED a glancing fan back toward the shooter around an opening ring. Feel (`scripts/effects/game_feel.gd`, `GameCamera.kick/shake`): a small camera kick against the aim per shot, a 30 ms hit-pause on a hit, a short shake on a kill; Reduced Motion halves the kick and shake and drops the hit-pause, and the test runner turns the hit-pause off. New `test_shooting_feel.gd`; `test_m65_kenney_fx.gd` checks the held muzzle light. The gun itself is still the procedural placeholder until the user's generated art arrives (prompts in the W01 brief). Full suite 58/58; the exported debug build plays to the completion screen.
- **Scrapjack art (C37, 2026-10-04):** the gun is the user's generated parts sheet (`concept-art/w01-scrapjack/`), imported by `tools/art/import_parts_sheet.py scrapjack` (a new prop path) as a lit rig of four parts in `assets/characters/lit/scrapjack/`. `scrapjack.gd` mounts it at the grip (under Dave's arm, so the fist wraps the grip), moves the muzzle marker to the painted barrel's tip, snaps the upper housing and the barrel back together on each shot, flashes the copper coils hot and lets them cool, and dips the teal charge light; the drawn placeholder remains only as a fallback. The tracer's trail now starts at the muzzle instead of 6 px behind it (it covered the barrel on the first frame). `test_shooting_feel.gd` checks the painted gun. Full suite 58/58.
- **Playtest change (2026-10-04), camera zoom:** the camera zooms in to 1.2 ("camera looks too zoomed out"; `GameCamera.zoom_level`). Dave is about 1/6.25 of the screen height instead of 1/7.5, and the view still shows 533 px each side of him, past the 520 px a guard or Staffer notices him from (the rover's 640 px acquire range was already at the screen edge; the 90 px look-ahead shows more ahead). Checked in `test_rook_sprite_rig.gd`; full suite 58/58; the exported debug build plays to the completion screen.
- **Night Guard motion is all hand-keyed (C38, 2026-10-04; extended to every enemy 2026-10-05):** the user found his motion strange; on the side-on cutouts the Mixamo combat clips threw the arm straight up, bowed deeply for a flinch and reached both arms out in recovery. The user chose all hand-keyed over a mix. His converted clips (`assets/characters/lit/night_guard/mocap/`) and `tools/art/build_guard_mocap.py` are deleted; `clips_night_guard.gd` gains a new recovery (hunched but watching Dave, free hand braced on the knee) and a hit flinch (head snaps back, he rocks back a step, hands up). `rig_animator.gd` keeps its generic converted-clip support, unused. Full suite 58/58.
- **Pending:** first-time playtests (gate 6) and the Windows launch (T22-Windows). Final painted enemy art and real Mixamo clips. The captures above are the lead's own review, not a first-time player's; no playtest result exists.

