# 06 — Build milestones and exit checks

**Visual direction (C11, C15):** [hand-drawn 2D in a dark night-campus palette](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24); there are no selected scene images for the new look.

Follow M0 → M1 → M2 → M3 → M4 → M5 → M6 → M7. Each stage has a playable or inspectable result and a handoff entry. A later full-build request authorizes proceeding through the sequence without repeated approvals; stop for a real missing prerequisite or user decision, not at every file. M0–M7 were completed before the revamp and are kept as history (their exit evidence is in [09](09-progress-and-handoff.md)); the vocabulary below is the current one, so read a pre-revamp record through the table in the [README's revamp note](README.md#revamp-2026-09-29). The post-M7 revamp pass (R1) follows the table.

Do not implement later campaign systems as preparation. Do not mark a milestone complete on code presence alone. If checks cannot run, mark it **implemented, unverified** and record why.

| ID | Build | Required exit evidence |
| --- | --- | --- |
| M0 | Godot setup and constraints | Pinned stable version; empty project launches; named inputs; known display/renderer; documented source-control baseline |
| M1 | Hero, camera, pistol | Playable movement course; base shots hit/block correctly; safe moving-platform carry; jump range measured |
| M2 | Staffer and Clipper | Isolated attack/recovery examples plus a two-enemy lane; stage-0 pistol can beat both fairly |
| M3 | Entire graybox route | All six areas and 32 beats connected; 11 encounter placements; both optional branches; exit reachable |
| M4 | Treasure, upgrade, persistence | Exact microchip allocation; evidence file; swap; health; complete checkpoint and purchase transactions |
| M5 | Core-node event and level flow | SC01 once, skip/resume parity, settled lockdown state, completion and replay |
| M6 | Visual/audio/readability pass | Selected style represented; warnings clear; placeholder status honest; HUD/settings readable |
| M7 | Verification and test build | Functional matrix passed, measured playtest report, local Windows export and known limitations |
| R1 | Revamp to the new game (C24, post-M7) | Story, names, look and collectibles match C14–C24; keycard exit added; gameplay, tuning and timings unchanged; full suite passes; night-look captures reviewed against the readability rules |

## M0 — Project foundation

Read 00/04 and inspect the workspace before edits. Preserve pending solo-hero changes and existing staged files. Create prototypes/sunnyvale-godot/ with a minimal launch scene. Record the exact Godot build and executable location in 09, not a guessed version. Confirm the chosen stable version supports the nodes in 04; adjust to its documented API if necessary. Add only useful project files and appropriate ignores.

**Proof:** launch to a simple level placeholder without import/parser errors. If Godot or export templates are unavailable, document the missing item and finish safe project preparation; do not claim a launch/export.

## M1 — Movement first

Build hero/camera/pistol in a disposable test course inside the prototype project. Add ordinary slopes only if needed by the actual layout; flat tiles suffice. Test low ceilings, jump release, edge grace, landing buffer, walking onto/off moving platforms, and shooting into nearby walls. Calibrate main-route jump limits from measured reach.

**Proof:** capture run/jump/shoot footage or observations at two frame-rate conditions; update tuning seeds. The hero cannot jump through ceilings, drift off a stationary platform, or fire through a wall.

## M2 — Enemy rules

Build two state machines, grounded lane bounds, real attack windows, rear motor hit zone, and attack-token coordination. Use temporary art if needed. First test each alone, then one mixed pair.

**Proof:** a base-pistol, six-health hero can beat either enemy without unavoidable damage. Warnings precede every damaging attack. Clipper reliably hits its backstop and exposes the motor. No stealth or detection, no unlisted ability.

## M3 — Full playable blockout

Assemble six area scenes and every beat in 02. Add all 15 enemies by stable ID, static/moving platforms, SW01, safe return paths, and both optional branches. Place temporary treasure/workbench/checkpoint markers for later systems. Provide a temporary explicit end marker until M5; it is not a boss.

**Proof:** one start-to-finish traversal, branch reachability, safe moving-platform failure, no ladder requirement, all 11 encounter groups counted. Collect a rough area-time run to find empty stretches early. Do not certify 10–15 minutes from the builder's familiar run.

## M4 — Full progression loop

Replace markers with microchips, the evidence file, three med-patches, recovery stations, safe weapon pad, workbench, and snapshot persistence. Implement the infinite pistol correctly; do not build unused ammo systems. Validate no-upgrade completion. Add the three focused state-contract checks described in 07.

**Proof:** total available microchips 65, main-route 45 before the workbench, first purchase costs 40, same-type swap leaves exactly one gun on the pad, and retries restore a coherent world. Workbench remains locked until the story flag supplied by M5; a development toggle may simulate it for this milestone only.

## M5 — Story and completion

Integrate SC01 (the core-node copy scene), objectives, the core node's interlock, safe hatch, lockdown scenery state, CP04/CP05, completion totals, New Game, Continue, and replay. Replace M3's temporary end trigger with the real wicket. Remove any test-only shortcut that appears in normal play.

**Proof:** normal and skipped SC01 produce identical persistent states; reloading never repeats the scene or relocks the hatch. Completion uses actual unique chips found, not wallet balance. A fresh replay clears run state.

## M6 — Cohesive presentation

Use 05 to replace the most important placeholders, beginning with hero/enemy silhouette and attack warnings. Preserve movement/hitbox behavior established earlier. Add sound, subtitle behavior, interaction highlighting, HUD, pause, basic accessibility settings, and readable night and lockdown looks.

**Proof:** game-scale and grayscale inspections; reduced-effects run; hero, threats, and platform edges remain visible. Label remaining production art gaps. Do not regenerate selected references or pause the functional build for a full animation commission.

## M7 — Verification and handoff

Run the functional matrix and at least three first-time playtests using 07. Fix reproducible route, save, combat, and timing problems; rerun only affected checks. Export and launch the Windows build on the documented test machine. Record performance rather than claiming an unspecified universal minimum.

**Proof:** launch instructions, exact engine version, measured durations, pass/fail matrix, asset status, and known issues. If suitable testers are unavailable, deliver **playable, timing unverified** with an explicit pending gate; never invent results. The finished prototype claim requires that gate to pass.

## R1 — Revamp to the new game (C24, post-M7)

Rebuild the presentation, story and collectibles of the M0–M7 prototype to the revamped game (C14–C24) without changing gameplay. Read the [decision register](../../design/decisions.md) (C14–C24), the [concept](../../dead-eden-concept.md), the [level brief](../../level-design/l01-welcome-to-sunnyvale.md) and the [style guide](../../art-design/style-guide.md) first.

Scope:
- Rename through code, scenes, tests, assets and docs: Resident to Staffer (Z01 to CY01), gem to chip, artifact to evidence, bench to workbench, core console to core node, care capsule to med-patch, EDEN to Adam, quarantine to lockdown, suburb to campus. Bump the save schema.
- Add the clearance keycard (L01-KC01, A04) and gate the A06 exit wicket on it.
- Rewrite SC01 as Adam's scene (Adam / Dave / Adam) at one of its core nodes.
- Restyle the whole game as a dark night campus: drawn light pools, rim light, glow, an optional night overlay, a night UI theme, a procedural Staffer with a Link light, a night pass on the Clipper, and revamp audio cues and music.
- Delete the zombie Resident art and the daytime concept art (C23).

Do not change collision, tuning, timings, tells or counts; placed-entity IDs change only through the rename (Z01 to CY01 in enemy IDs). There is no stealth or detection (C16). Honor reduced motion, keep alarms and strobes slow (no more than three flashes per second, no full-screen flashes), and never let darkness hide a tell, a ledge or a pickup.

**Proof:** the full automated suite passes with the revamp's tests updated (including the new `tests/cases/test_revamp_keycard.gd` for the keycard exit); captures of the area demo scenes and the enemy demo scenes are viewed against the readability rules; leftover greps for the retired vocabulary come back clean apart from deliberate history notes. Record the commands and results in 09 (its latest entry); do not claim any playtest-based result the revamp did not produce, and the first-time-player timing gate remains pending.
