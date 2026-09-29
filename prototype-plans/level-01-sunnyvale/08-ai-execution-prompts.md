# 08 — Copy-ready AI execution prompts

**Visual direction (C11, C15):** [hand-drawn 2D in a dark night-campus palette](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24); there are no selected scene images for the new look.

These prompts were written for the implementation request, and the M0–M7 prompts built the prototype before the revamp. They now use the revamped vocabulary so a rebuild or a fresh start produces the current game; the R1 prompt below is the one that rebuilt the existing prototype (C24). Use the repository working tree containing this plan and the solo-hero changes. A URL to the old remote commit may not contain them. Read linked files from disk; do not infer missing content.

## Master prompt — execute the whole prototype

~~~text
Implement the DEAD EDEN Level 1 prototype in Godot using prototype-plans/level-01-sunnyvale/README.md as the entry point. This message authorizes implementation of that prototype; broader concept-only rules still limit unrelated campaign work.

First inspect the existing repository and preserve user changes, including staged solo-hero edits. Read 00-scope-and-decisions.md, prototype-spec.json, and 09-progress-and-handoff.md, then the documents required for the next unfinished milestone.

Create the engine project under prototypes/sunnyvale-godot/. Use Godot 4 stable and GDScript, pinning the actual version at M0. Follow M0–M7 in 06-build-milestones.md. Work from a playable blockout toward presentation. Implement all six Sunnyvale areas on Arcadia's campus at night, the solo hero Dave Harlan, the Staffer and Clipper, the Scrapjack and Quickcycle, microchips, the clearance keycard, checkpoints, Adam's core-node scene at the depot, and the keycard exit.

Preserve one carried weapon, no companion, no boss, no Heirs, no stealth or detection, and no later-level weapons or traversal abilities. Treat tuning values and 12:30 pacing as untested seeds. Selected concept art is reference material, not finished sprite sheets. Use clear placeholders without waiting for all art.

Complete each stage's checks before marking it complete and continue to the next stage while possible. Record files changed, tested behavior, commands actually run, known gaps, and the next action in 09-progress-and-handoff.md. Run meaningful save/story transaction checks and manual gameplay checks; never claim launch, export, or 10–15 minute duration without evidence.

If Godot, export templates, or first-time testers are unavailable, complete unaffected work and record the exact pending prerequisite. Do not fabricate tests or call the duration gate passed. Do not overwrite unrelated files, discard staged work, disable commit signing, publish a release, or expand into Level 2.
~~~

## Milestone prompts

Use these for smaller sessions. Each session also reads 09 to resume safely and updates it before stopping. A milestone request permits its dependency repairs, not unrelated campaign implementation.

### M0 — Setup

~~~text
Execute M0 from prototype-plans/level-01-sunnyvale/06-build-milestones.md. Read 00 and 04, inspect the workspace, preserve all existing changes, pin the available Godot 4 stable version, and create the minimal project under prototypes/sunnyvale-godot/. Set named input actions and the proposed 2D display defaults. Launch it if the runtime is available. Record actual version, paths, launch evidence or exact blocker, and next action in 09. Do not implement the full level in this step.
~~~

### M1 — Hero and pistol

~~~text
Execute M1 using 03 and 04. Build the hero, camera, infinite-ammo Scrapjack, and a movement test course with a moving platform and low ceiling. Verify variable jump, edge grace, input buffer, world-space aim, wall blocking, and platform carry. Measure jump reach and record tuning changes before laying out the campaign route. Keep one equipped slot and no reload mechanic. Update 09 with evidence.
~~~

### M2 — Enemies

~~~text
Execute M2 using the CY01 and R01 source briefs (now art-design/linked/lk01-staffer.md; the Clipper brief was removed under C32 and its file became art-design/machines/m01-patrol-rover.md), 03, and acceptance cases T03–T06. Build Staffer and Clipper state machines with visible warnings and recovery. Show the Clipper's rear motor opening after a wall stall. Add a bounded two-enemy practice lane with one committed attacker at a time. Prove both enemies are beatable with the base pistol and ordinary movement. Add no stealth or detection. Record missing art as placeholders and update 09.
~~~

### M3 — Six-area blockout

~~~text
Execute M3 using 01, 02, and prototype-spec.json. Assemble all six areas in order, 32 beats, 11 encounter groups, 9 Staffers, and 6 Clippers. Include both optional branches, SW01, safe roof recovery, and checkpoint/treasure markers. Use normal jumps and stepped ledges instead of any ladder. Complete a full traversal, record rough area times, and flag undersized sections without adding timer padding. Do not claim first-time pacing has passed. Update 09.
~~~

### M4 — Progression and saves

~~~text
Execute M4 using 03, 04, and tests T09–T15/T19. Allocate exactly 45 main-route microchips before the workbench and 20 optional chips; place the Lockout Notice evidence file (EF01) separately. Implement six-health recovery, coherent checkpoint snapshots, the optional same-type pistol swap, and Quickcycle at 40 chips. Test rollback and failed/cancelled/repeated transactions without duplicated rewards or weapon instances. Keep the workbench gated by awakening_done; use a development-only flag for isolated testing until M5. Update 09.
~~~

### M5 — Story and completion

~~~text
Execute M5 using 02/03 and the solo story source. Implement the fixed core-node copy scene (SC01: Adam answers Dave), the skip-equivalent state, the safe lockdown transformation, the emergency hatch, CP04, the keycard-gated wicket, and the completion screen. Preserve the core node in its housing. Verify Continue, replay, unique chips-found totals, and completion without an upgrade or evidence file. Remove player-facing test shortcuts. Update 09.
~~~

### M6 — Presentation

~~~text
Execute M6 using 05 and the style guide. Improve legible silhouettes, platform edges, warnings, UI, subtitles, sound, and the two environment states (night and lockdown) without changing validated mechanics. Keep original selected PNGs intact and label all remaining sprite/animation placeholders. Test reduced effects, muted audio, resized windows, and single-target interaction prompts. Update 09 with an asset inventory and visual evidence.
~~~

### M7 — Validate and deliver

~~~text
Execute M7 using 07. Run the functional matrix, obtain and record real first-time playtests, and verify the 10–15 minute main-route requirement. Fix problems using 01's rules; do not inflate time with delays or durability. Export and launch the Windows test build using the pinned engine/templates. Report actual passed checks, measurements, launch instructions, and limitations. If testers or export prerequisites are absent, deliver the verified work with those gates explicitly pending. Update 09.
~~~

### R1 — Revamp to the new game (C24)

~~~text
Execute R1 from prototype-plans/level-01-sunnyvale/06-build-milestones.md. Read the decision register (C14–C24), dead-eden-concept.md, level-design/l01-welcome-to-sunnyvale.md and art-design/style-guide.md first, then the README's revamp note and 09. Rebuild the existing prototype under prototypes/sunnyvale-godot/ to the new game without changing gameplay, collision, tuning, timings, tells or counts: rename Resident to Staffer (Z01 to CY01), gem to chip, artifact to evidence (EF01 Lockout Notice), bench to workbench, core console to core node, care capsule to med-patch, EDEN to Adam, quarantine to lockdown and suburb to campus; add the clearance keycard L01-KC01 in A04 and gate the A06 exit wicket on it; rewrite SC01 with Adam's lines ("Hello, Dr. Harlan. I was told you'd been let go." / "Word gets around." / "I'm glad you came back. Please stay where you are."); and restyle everything as a dark night campus in the style guide's palette with drawn light, a light near every landing, and no tell, ledge or pickup hidden by darkness. There is no stealth or detection. Honor reduced motion and keep alarms slow (at most three flashes per second, no full-screen flashes). Delete the zombie Resident art. Run the full suite, view captures, run leftover greps for the retired vocabulary, and update the plan documents, CONVENTIONS.md, the reports and 09. Do not claim any playtest result or the timing gate.
~~~

## Resume prompt

~~~text
Continue the Sunnyvale Godot prototype from prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md. Verify the recorded state against the actual files, then complete the first unfinished milestone from 06. Preserve local/staged changes. Re-run checks only where changes or unresolved concerns require them. Do not treat planned or implemented-but-unverified work as complete.
~~~
