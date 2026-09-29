# M7 functional matrix (07-acceptance-and-playtesting.md T01-T23)

Compiled for M7 (verification and handoff) and updated for the 2026-09-29
revamp (C24). **Revamp note:** the rows below were verified at M7 on the
pre-revamp build. The revamp renamed the vocabulary, the test files and the
identifiers they assert (Resident to Staffer, gem to chip, artifact to
evidence file, bench to workbench, core console to core node, care capsule to
med-patch, EDEN to Adam, quarantine to lockdown) and added the keycard exit
(T23); this file uses the current names, and every result and count in it is
the M7 result unless a row says otherwise. The revamp pass's own re-run and
verification record is in
`../../prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md` (latest
entry). For every row, "evidence" names
the actual test file/function (read against the live code to confirm it
asserts the stated pass condition, not something weaker) or capture path.
"status" follows 06/07's own vocabulary:

- **verified-automated** — a headless `tests/cases/test_*.gd` case asserts
  the exact pass condition and was run (see "Run log" below) and passed.
- **partially verified** — some part of the pass condition is automated;
  another part is only evidenced by a visual capture or is narrower than the
  full condition.
- **pending — reason** — not verified in this pass, with the concrete reason
  (never an estimate presented as a measurement, per 06/07).

Engine: Godot 4.7.2.stable.official, `/Applications/Godot.app/Contents/MacOS/Godot`,
run from `prototypes/sunnyvale-godot/`. M7 run: `NOIMPORT=1 tools/test.sh` and
`NOIMPORT=1 FPS=30 tools/test.sh`, both **40/40 cases passed** (see "Run log";
the suite has grown since M7, and the revamp's own run is recorded in 09).

## Functional matrix

| ID | Scenario | Pass condition | Evidence (test file + check) | Status |
| --- | --- | --- | --- | --- |
| T01 | New Game | Six health, zero chips, stage 0, one held W01-P01, core node installed, Adam quiet (`awakening_done` false), CP00 | `test_m0_session.gd` (`run()`): asserts health==6, wallet==0, `weapon_stage("W01")==0`, `equipped_weapon()=="L01-W01-P01"`, `get_story("core_installed")==true`, `get_story("awakening_done")==false`, `state["checkpoint_id"]=="CP00"` — every clause of the pass condition, individually | verified-automated |
| T02 | Movement course | Variable jump, grace/buffer, low ceiling, and platform carry work without extra abilities | `test_m1_jump.gd` (`_test_full_hold_apex`/`_test_short_tap_apex` variable jump, `_test_coyote` grace, `_test_jump_buffer`/`_test_jump_buffer_expires` buffer, `_test_ceiling_bonk` low ceiling); `test_m1_platform.gd` (moving-platform carry); `test_m1_regress_buffered_jump_cut.gd` | verified-automated |
| T03 | Wall / enemy shots | Solid walls block; Staffer body hits damage; Clipper frontal hits show blocked feedback | `test_m1_weapon.gd` (point-blank wall muzzle-clamp -> `bolt_blocked`); `test_m2_staffer.gd` (whole-body shot accepted, 3 hits defeat); `test_m2_clipper.gd` (frontal shots always resolve `&"blocked"`, motor hint once `frontal_hint_threshold` ineffective hits land: 4 at M7, 2 in the current tuning); `test_m1_regress_muzzle_overlap_hitzone.gd` | verified-automated |
| T04 | Staffer | Every lunge warns; one attack deals at most one health during immunity | `test_m2_staffer.gd` (52 checks: AttackBox inactive through APPROACH/WINDUP until >=0.6s of observed windup; one lunge + its one possible immunity re-hit costs at most 1 health); `test_m2_regress_staffer_lunge.gd` | verified-automated |
| T05 | Clipper | Charge stays grounded and straight; backstop exposes rear; three base hits fit a fair opening | `test_m2_clipper.gd` (27 checks: charge keeps constant y / monotonic x; backstop hit stalls it and exposes the rear HitZone while the front stays blocked; three stage-0-paced shots 0.32s apart fit inside the 1.6s stall and defeat it); `test_m2_regress_clipper_shell_gap.gd` | verified-automated |
| T06 | Mixed lane | At most two enemies active; only one windup/active attacker; usable retreat remains | `test_m2_mixed_lane.gd` (isolated synthetic pair, 20.5s: never >1 concurrent windup/active, both get turns); `test_m3_regress_encounters.gd::_combat_run()` (whole assembled level, per-tick `n>1` check across every real `EncounterGroup`, including `L01-E08`/`L01-E09`, while a RouteBot walks the full main route — brief per group); **`test_m7_encounter_fairness.gd`** (NEW — real `L01-E07`/`L01-E11` groups specifically (not the only Staffer+Clipper/multi-enemy groups in the level — `L01-E09` also pairs a Staffer with a Clipper and `L01-E08` pairs two Staffers; those two get only the brief whole-route check above), a scripted RouteBot hero walks each group's own authored approach/backstop-hop lane and dwells 8s at each real enemy's measured position: never >1 concurrent windup/active over the whole ~20.5s run, both the real Staffer and the real Clipper actually attack (5/4 turns for E07, 5/4 for E11), hero input never disabled); "usable retreat remains" is evidenced separately by `test_m3_regress_route.gd` (every MAIN-route encounter activation asserts >=2H of flat retreat floor behind the hero) | verified-automated |
| T07 | Roof fall | Recovery lane reaches the route by normal jumps; no damage, trap, or forced fight | `test_m3_regress_recovery.gd::_probe_roof_fall_recovery()` (RouteBot reaches back to the main route across 7 moving-platform phases; prints but does not assert health); **`test_m7_roof_fall_zero_damage.gd`** (NEW — same assembled-level recovery climb, hero genuinely vulnerable (not `debug_invulnerable`): asserts the climb succeeds by normal jumps AND costs exactly zero health (6->6), hero input stays enabled throughout, no fight/skip is forced; measured recovery time 4.35s) | verified-automated |
| T08 | SW01 | Walkway extends once; repeated use/reload cannot retract it under the hero | `test_m3_foundation.gd::_test_walkway_extends_persists_never_retracts()` (starts retracted, extends live on the switch, idempotent repeat pulls, a freshly re-instanced walkway — simulating a reload — reads `Session` and comes back already extended, by construction never retracts since `is_extended()` only ever reflects the one-way switch); `test_m3_a04.gd` (main route pulls `L01-SW01`; a fresh A04 instance starts extended); `test_m4_state_contracts.gd` (the `switches` field round-trips byte-correct through a REAL `CheckpointService.save_snapshot()`/`load_latest()` disk cycle) | verified-automated |
| T09 | Main treasure | 45 chips available before the workbench; ignoring some/all never blocks a route | `test_m4_state_contracts.gd` (T09: 45 main-route chip value collected at runtime through `Session`, summing exactly to wallet/`chips_found()`); `test_m3_level.gd` (population count: 45 main-route + 20 cache = 65 total chips); `test_m5_story.gd::_test_t18_zero_upgrade_finish()` (a full A01->A06 completion collecting ZERO optional treasure and spending nothing — nothing in `LevelDirector`/`Session` gates the objective chain or the exit wicket on any chip/wallet threshold; the wicket's own gate is the keycard, see T23) | verified-automated |
| T10 | Optional routes | Lockout Notice (EF01) and separate 20-chip cache reachable without new abilities | `test_m3_level.gd::_test_optional_branches()` (OPT01/OPT02 both complete and rejoin the main route via RouteBot's named-action-only input — no new ability); **`test_m7_optional_rewards.gd`** (NEW — same normal-movement branch runs, now asserting the actual reward: `Session.has_evidence("EF01")` true after OPT01, `Session.is_collected("L01-OPT02-CACHE01")` true and `chips_found()>=20` after OPT02 — the prior test only proved the branch's own route finished, not that its reward was actually picked up) | verified-automated |
| T11 | Rollback | Save, collect treasure, take damage, defeat enemy, then die: restore one consistent snapshot | `test_m4_state_contracts.gd` (a): station-save -> chip collect -> damage -> enemy defeat -> weapon swap -> death cycle restores one consistent snapshot (chip collectible again, wallet matches, enemy back at idle placement/full health, no duplicate ids); `test_m4_regress_save_tamper.gd` | verified-automated |
| T12 | Med-patch / station | Full-health med-patch remains; station heals and saves without respawning rewards/enemies | `test_m4_state_contracts.gd` (T12: a full-health med-patch is not collected and stays in place; a station reused heals + re-commits without respawning the chip or reviving the defeated enemy) | verified-automated |
| T13 | Same-type swap | Confirm exchanges two existing IDs; cancel changes neither; swap-back yields no third instance | `test_m4_state_contracts.gd` (T13: confirm/cancel/swap-back — exactly one instance ever resting anywhere, no third instance ever created); `test_m4_regress_pad_decline_toast.gd` (decline never shows the "swapped" toast) | verified-automated |
| T14 | Upgrade | 40 chips deducted once; stage 1 fitted and saved; refusal/insufficient funds/repeat buy changes nothing | `test_m4_state_contracts.gd` (T14/b: exact 40-chip debit, stage 1 recorded and persisted, `"locked"`/`"insufficient_funds"`/`"already_owned"` refusals leave state byte-for-byte unchanged, including a forced `CheckpointService` write failure leaving no partial purchase) | verified-automated |
| T15 | Post-upgrade swap | Incoming pistol receives earned stage 1 without a second purchase or extra equipment | `test_m4_state_contracts.gd` (T15: the instance that swaps onto the hero already carries the type-wide earned stage, no second purchase, no extra equipment created) | verified-automated |
| T16 | SC01 normal / skip | Same objective, installed core node, open hatch, Adam-answered/lockdown state (`awakening_done`), and CP04; no duplicate event | `test_m5_story.gd::_test_t16_sc01_normal_vs_skip()` (a full watch-through and a skip both land in byte-identical committed snapshots via the same private `_finish_awakening()`; re-interacting afterward never re-runs the scene body or re-commits) | verified-automated |
| T17 | Resume after the depot event | Lockdown geometry already settled; no blocked spawn, surprise damage, or replayed copy scene | `test_m5_story.gd::_test_t17_resume_after_awakening()` (resume from CP04 and from UPG01 both land in the settled lockdown look with the hatch already open, no replayed SC01, no surprise damage) | verified-automated |
| T18 | Zero-upgrade finish | Base pistol and normal movement finish A06 (with the main-route keycard); no chip or evidence gate | `test_m5_story.gd::_test_t18_zero_upgrade_finish()` (a stage-0 RouteBot — named-action input only — clears A01->A06 through the real SC01 to real completion: `level_complete` true, CP05 committed, objective COMPLETE, `weapon_stage("W01")==0`, no evidence file, only the 45 main-route chip value; since the revamp the route also collects the `L01-KC01` keycard on its way through A04, without which the wicket would not fire) | verified-automated |
| T19 | Save failure / invalid save | No partial purchase; valid backup or clear recovery option; no half-loaded world | `test_m4_state_contracts.gd` (`validate_snapshot()` rejects every tampered/out-of-range/extra-field shape — ADV-07; a corrupt primary transparently falls back to the valid backup and is never itself copied over it — ADV-08; T14's forced-write-failure case above: no partial purchase); `test_m4_regress_save_tamper.gd`; `test_m5_flow.gd::_test_invalid_save_backup_and_no_save()` (a corrupt-then-valid pair recovers the backup with an honest message; both invalid shows a message pointing at New Game, never a crash or a half-loaded world); `test_m5_regress_title_newgame_honesty.gd` | verified-automated |
| T20 | Completion / replay | Found-chip total is independent of wallet spend; fresh run resets all run progress | `test_m5_story.gd::_test_t20_completion_totals_and_replay()` (`chips_found()` stays correct after spending at the workbench; Play again resets every field of `state` — including `equipped_weapon`/`world_weapons` — back to `default_state()` and clears the on-disk save); `test_m5_regress_play_again_hud.gd` (the never-recreated HUD's weapon tag/Quickcycle pip also reset, not just `Session` state) | verified-automated |
| T21 | Pause / subtitles / resize | Gameplay stops while paused; text and warnings remain readable; input resumes correctly | `test_m5_flow.gd::_test_pause_stops_gameplay()` (hero input has no effect and the active-time clock does not advance while paused; both resume correctly on unpause); `test_m5_regress_sc01_pause_not_skip.gd` (SC01's own hold timer also freezes under pause, distinct from `skip`); `test_m6_ui.gd` (subtitles/text-size/reduced-motion settings persist and the HUD's text visibly scales live — readability controls); **`test_m7_pause_and_resize.gd`** (NEW — closes the two remaining gaps: (1) an isolated Staffer's AND an isolated Clipper's own state machine — and the Clipper's position — genuinely stop advancing for 1.5s of paused physics frames that would otherwise easily contain a full attack cycle, then both resume correctly on unpause, proving pause freezes ENEMIES too, not just the hero/clock/SC01; (2) a live viewport size change (a `SubViewport`'s own `size`, a real render-target resize that — unlike the headless display server's root `Window.size` — actually takes effect headless) keeps the HUD's left-anchored health/weapon bar flush at x=16, its right-anchored objective label tracking `width-460`, and its centered toast tracking `width/2`, checked at 1600x900/960x600/1280x720) | verified-automated (mechanical contracts); readability itself is visual — see M6 note below |
| T22 | Export | Local Windows build starts, saves, continues, and completes outside the editor | Produced and verified by the separate M7 export workstream on the pre-revamp build (the exports were not rebuilt by the revamp) — see `reports/export-report.md`: macOS release/debug builds exported and the debug build's own export-only automation (gated `OS.is_debug_build()` + `--m7-phase=...`) drove a real New Game to a real checkpoint save, then Continue -> real completion, both outside the editor, never touching the real save location. Windows build exported (single embedded-PCK `.exe`, file-type confirmed) but not launch-tested — this host has no Wine | T22-macOS verified (export-report.md); T22-Windows pending — no Wine on this host, exact steps for a Windows PC recorded in export-report.md |
| T23 | Keycard exit | A new run starts without the card; the A06 wicket refuses entry without `L01-KC01` (harmless "Clearance card required" message, `keycard_denied` cue, no completion, no damage); the card is collected on the A04 main route; a committed card never duplicates and survives CP04; a card taken after the last checkpoint returns on death; the wicket opens and completes with the card; no softlock | `test_revamp_keycard.gd` (added by the revamp): `_test_wicket_locked_then_unlocked()` (a fresh run holds no card and the HUD icon is hidden; entering the A06 wicket without the card emits `wicket_denied` and does not end the level; touching the A04 card takes it, marks `L01-KC01-P` collected, shows the HUD icon and unlocks the reader; the wicket then ends the level), `_test_save_whitelist()` (a save holding `L01-KC01` validates; a non-whitelisted id and a missing `keycards` field are rejected), `_test_rollback_restores_card()` (a card taken after CP00 is dropped by `restore_committed()` and the rebuilt plaza has the card again); `test_m5_story.gd::_test_t18_zero_upgrade_finish()`'s full-route completion also exercises the card on the real route. Not asserted: survival across CP04, and no duplication across repeated commits (`Session.take_keycard()` itself refuses repeats) | covered by the revamp's new case (its run result is recorded in 09); CP04 survival and repeat-commit duplication not asserted |

### T21 readability note

The manual/visual half of T21 ("text and warnings remain readable") is not
re-captured in this pass. Existing evidence: 09-progress-and-handoff.md's M6
session log entry records windowed captures at three window sizes
(960x540/1280x720/2560x1080, via `scenes/debug/m6_resolution_probe.tscn`, a one-off capture demo since removed) with
grayscale/reduced-motion/muted-audio contact sheets reviewed for silhouette,
warning-triangle, and HUD-text legibility. This M7 pass adds the mechanical
resize-anchoring proof above; a fresh capture at additional window sizes was
not run here for lack of scope/time and is left **partially verified** for
the purely visual half of T21 pending a follow-up capture if desired.

## 07 completion gates

| # | Gate | Status | Evidence |
| --- | --- | --- | --- |
| 1 | No parser errors, missing required resources, or blocking runtime errors | verified | `NOIMPORT=1 tools/test.sh` and `NOIMPORT=1 FPS=30 tools/test.sh` both **40/40 cases passed** with a clean import (see "Run log"); 09's M5/M6 log entries additionally record clean 120-frame headless `--quit-after` launches of `res://scenes/main.tscn`. (The `Parse JSON failed`/`unknown cue` lines in the raw test output are test cases deliberately feeding corrupt JSON / an unknown cue name to prove graceful handling — T19/`test_m6_audio.gd` — not real errors.) |
| 2 | All six areas in order; two enemy types; one carried pistol; no companion, boss or stealth system | verified | `test_m3_level.gd` (six areas in exact order, exact widths, seams checked); `test_m3_regress_encounters.gd` (`kinds.keys().size()==2`, exactly 9 Staffer + 6 Clipper, no other enemy kind); CONVENTIONS.md "Hard rules" (solo hero, W01 Scrapjack only, no companion/boss; the revamp adds no stealth or detection, C16) unmodified by this or any M7 pass |
| 3 | Fair stage-0 completion with zero optional chips, no evidence file, no purchase (the main-route keycard is still needed) | verified | T18 above (`test_m5_story.gd::_test_t18_zero_upgrade_finish()`) |
| 4 | Coherent checkpoint, swap, purchase, keycard and story persistence | verified at M7 for everything except the keycard clause, which is new with the revamp | T11/T13/T14/T16/T17/T19 above; keycard persistence: T23 (`test_revamp_keycard.gd`; CP04 survival not asserted) |
| 5 | Readable chosen 2D direction with any remaining art placeholders explicitly listed | verified at M7 for the pre-revamp daytime look; the night look's captures are recorded by the revamp pass in 09 | `reports/asset-inventory.md` (full per-asset provenance + an honest "remaining production-art gaps" section: no frame-by-frame animation, synthesized-not-composed audio, mirrored-sprite asymmetry, static Clipper wheels, no pixel-measured hitbox tool; the M7-era hero rig and Resident cutout entries in it have since been superseded by the Rook sprite pack and the procedural Staffer); M6 capture passes (09 session log) |
| 6 | First-playthrough timing evidence satisfies the protocol below | **pending** | No first-time testers were available for this session (explicitly authorized by the task brief to proceed as "playable, timing unverified" rather than invent or estimate a result). Nothing in this pass substitutes an estimate or an AI prediction for a measured playtest, per 07's own instruction |
| 7 | Windows test export launches and matches the verified editor route | **partially verified** | See T22 above / `reports/export-report.md` — the macOS **release** export (what a player receives) is verified to boot to the title screen with no errors; save/continue/complete (matching this same report's T18) is verified only on the macOS **debug** export of the same preset and source (the release and debug templates are different binaries — the release build was not separately hand-played through save/continue/complete). The Windows export is built and file-type-confirmed but not launch-tested; no Wine on this macOS host to launch it |

**Overall:** gates 1-5 verified, gate 7 partially verified (macOS release
export boots to title, verified; save/continue/complete verified on the
macOS debug export of the same preset/source, not separately hand-played on
the release build; Windows export pending an actual Windows PC — see
`reports/export-report.md`), gate 6 pending for the reason stated (never
invented). Per 06's own M7 proof line, the "finished prototype" claim
requires gate 6 (and, for a true release claim, full gate 7 including the
Windows launch) to pass — this report deliberately does not claim either.

## Run log (M7, pre-revamp build)

```
cd prototypes/sunnyvale-godot
NOIMPORT=1 tools/test.sh
  -> RESULT: 40/40 cases passed
NOIMPORT=1 FPS=30 tools/test.sh
  -> RESULT: 40/40 cases passed (identical PASS lines to the 60fps run)
```

New M7 cases and their check counts from that run:
`test_m7_encounter_fairness.gd` (18 checks), `test_m7_optional_rewards.gd`
(5 checks), `test_m7_pause_and_resize.gd` (19 checks),
`test_m7_roof_fall_zero_damage.gd` (7 checks) — 49 new checks, all passing,
on top of the pre-existing 36 M0-M6 cases (unchanged, still passing).
