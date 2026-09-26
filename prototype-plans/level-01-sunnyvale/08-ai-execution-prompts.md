# 08 — Copy-ready AI execution prompts

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

These prompts are for a **later implementation request**. Use the repository working tree containing this plan and the solo-hero changes. A URL to the old remote commit may not contain them. Read linked files from disk; do not infer missing content.

## Master prompt — execute the whole prototype

~~~text
Implement the DEAD EDEN Level 1 prototype in Godot using prototype-plans/level-01-sunnyvale/README.md as the entry point. This message authorizes implementation of that prototype; broader concept-only rules still limit unrelated campaign work.

First inspect the existing repository and preserve user changes, including staged solo-hero edits. Read 00-scope-and-decisions.md, prototype-spec.json, and 09-progress-and-handoff.md, then the documents required for the next unfinished milestone.

Create the engine project under prototypes/sunnyvale-godot/. Use Godot 4 stable and GDScript, pinning the actual version at M0. Follow M0–M7 in 06-build-milestones.md. Work from a playable blockout toward presentation. Implement all six Sunnyvale areas, the solo hero, Resident and Clipper, the Scrapjack and Quickcycle, treasure, checkpoints, the depot awakening, and the exit.

Preserve one carried weapon, no companion, no boss, no Returned, and no later-level weapons or traversal abilities. Treat tuning values and 12:30 pacing as untested seeds. Selected concept art is reference material, not finished sprite sheets. Use clear placeholders without waiting for all art.

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
Execute M2 using the Z01 and R01 source briefs, 03, and acceptance cases T03–T06. Build Resident and Clipper state machines with visible warnings and recovery. Show the Clipper's rear motor opening after a wall stall. Add a bounded two-enemy practice lane with one committed attacker at a time. Prove both enemies are beatable with the base pistol and ordinary movement. Record missing art as placeholders and update 09.
~~~

### M3 — Six-area blockout

~~~text
Execute M3 using 01, 02, and prototype-spec.json. Assemble all six areas in order, 32 beats, 11 encounter groups, 9 Residents, and 6 Clippers. Include both optional branches, SW01, safe roof recovery, and checkpoint/treasure markers. Use normal jumps instead of the old porch-ladder suggestion. Complete a full traversal, record rough area times, and flag undersized sections without adding timer padding. Do not claim first-time pacing has passed. Update 09.
~~~

### M4 — Progression and saves

~~~text
Execute M4 using 03, 04, and tests T09–T15/T19. Allocate exactly 45 main-route gems before the bench and 20 optional gems; place the Welcome Key separately. Implement six-health recovery, coherent checkpoint snapshots, the optional same-type pistol swap, and Quickcycle at 40 gems. Test rollback and failed/cancelled/repeated transactions without duplicated rewards or weapon instances. Keep the bench gated by awakening_done; use a development-only flag for isolated testing until M5. Update 09.
~~~

### M5 — Story and completion

~~~text
Execute M5 using 02/03 and the solo story source. Implement the fixed core latch, one-time EDEN awakening, skip-equivalent state, safe quarantine transformation, CP04, and the wicket completion screen. Preserve the core in its housing. Verify Continue, replay, unique gems-found totals, and completion without an upgrade or artifact. Remove player-facing test shortcuts. Update 09.
~~~

### M6 — Presentation

~~~text
Execute M6 using 05 and the selected 2D references. Improve legible silhouettes, platform edges, warnings, UI, subtitles, sound, and the two environment states without changing validated mechanics. Keep original selected PNGs intact and label all remaining sprite/animation placeholders. Test reduced effects, muted audio, resized windows, and single-target interaction prompts. Update 09 with an asset inventory and visual evidence.
~~~

### M7 — Validate and deliver

~~~text
Execute M7 using 07. Run the functional matrix, obtain and record real first-time playtests, and verify the 10–15 minute main-route requirement. Fix problems using 01's rules; do not inflate time with delays or durability. Export and launch the Windows test build using the pinned engine/templates. Report actual passed checks, measurements, launch instructions, and limitations. If testers or export prerequisites are absent, deliver the verified work with those gates explicitly pending. Update 09.
~~~

## Resume prompt

~~~text
Continue the Sunnyvale Godot prototype from prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md. Verify the recorded state against the actual files, then complete the first unfinished milestone from 06. Preserve local/staged changes. Re-run checks only where changes or unresolved concerns require them. Do not treat planned or implemented-but-unverified work as complete.
~~~
