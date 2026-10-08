# Eon City — Level 1 Godot prototype plan

**Visual direction (C11, C15, C35):** [hand-drawn 2D in a dark night-campus palette, painted flat and lit in the engine](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24) and rebuilt 2026-09-30 (C33); there are no selected scene images for the new look.

**Status (C33):** Level 1 has been rebuilt from the ground up around the C31 roster, after the approved lit-cutout test (C35). It is built and the suite passes (2026-09-30). The enemies are the SE01 Night Guard, the M01 Patrol Rover and, at the alarm exit, the LK01 Staffer, all drawn as lit cutouts. The C24 build's disabled-not-killed Staffers (CY01, now LK01 in the [art briefs](../../art-design/linked/lk01-staffer.md)), the Clipper (removed under C32) and its no-gore rule are gone. Read them in [09](09-progress-and-handoff.md) as history that C25–C35 supersede.

## Revamp (2026-09-29)

The user replaced the game's story and atmosphere (C14–C21) and asked for this prototype to be rebuilt to match (C24); see the [decision register](../../design/decisions.md), entries C14–C24. This plan, the prototype and its reports now describe the rebuilt game: Dave Harlan, a fired AI researcher, breaks back into Arcadia Dynamics' Eon City campus at night to copy proof that the sentient AI Adam is secretly building a weapon (C14, C17, C18).

What changed is story, names, look and collectibles. Zombies are gone entirely and there is no stealth (C16). The old daytime suburb and the zombie art were deleted (C23).

| Before the revamp | Now |
| --- | --- |
| Resident (Z01), a zombie | Staffer (LK01; CY01 in the C24 build), a Linked night-shift employee whose implant Adam controls. Since the C33 rebuild it appears only at the alarm exit, and like every enemy it dies and bleeds (C28, C29) |
| Gems | Microchips (C19), shown as "chips" in the interface and code |
| Artifact A01 "Welcome Key" | Evidence file EF01 "Lockout Notice" (optional, journal-only) |
| EDEN, awakened at a power core | Adam, answering Dave at one of its core nodes; the SC01 copy scene |
| Quarantine | Lockdown |
| Cheerful daytime suburb | Arcadia's campus at night |
| Maintenance bench, care capsule | Workbench, med-patch |
| Rook (provisional hero) | Dave Harlan; the Rook sprite pack stays as placeholder art |
| (nothing) | A clearance keycard (L01-KC01, picked up in A04) that the A06 exit wicket needs |

What did not change in the C24 revamp: the six areas, 32 beats, 11 encounter groups and their IDs (enemy IDs differed only by Z01 becoming CY01), every tuning seed and timing, the economy (45 main-route chips + a 20-chip cache, 40-chip Quickcycle), the checkpoints and the M0–M7 build history. The revamp was a presentation and story rebuild, not a gameplay change; where the linked history in [09](09-progress-and-handoff.md) still says Resident, gem, EDEN or artifact, read it through the table above. The C33 rebuild below did change the enemies and their IDs.

**Status:** M0–M7 were built and verified before the revamp (the record is in [09](09-progress-and-handoff.md)). The revamp (R1) then rebuilt the story, names, look and collectibles (its record is 09's 2026-09-29 entry), and the Level 1 rebuild (R2) then replaced the enemies (its record is 09's latest entry). Playable, timing unverified: the first-time-player timing gate is still pending. The user selected Godot and requested a 10–15 minute Level 1 prototype.

Build a complete, small playable level: break into Arcadia's campus at night, learn to jump and shoot, explore gardens and rooftops, survive the plaza and take the level's keycard, plug into one of Adam's core nodes at the server depot, buy an optional upgrade at the workbench, and escape alone through the keycard wicket.

**Duration target:** 12 minutes 30 seconds for a normal first successful main-route playthrough; optional discoveries add 90–120 seconds. The length is a design budget, not a measured result or a timer lock. [Pacing and measurement](01-player-journey-and-pacing.md) define how to prove the requested 10–15 minutes.

## Level 1 rebuild (2026-09-30, C33)

The user asked for Level 1 to be rebuilt from the ground up around the approved enemy roster (C33), after the lit-cutout test (C35, approved 2026-09-30). It is built; 09's latest entry is its record. Level 1 now has three enemies. All are lit cutouts that die and bleed (C28, C29).

| Enemy | Code | Rules |
| --- | --- | --- |
| Night Guard | SE01 | A human guard with a stun baton. 3 health. He patrols, notices Dave at 520 px, winds up for 0.5 s (the baton light is amber, then red for the last 0.25 s), swings once, then has a 1.2 s recovery: the punish window. |
| Patrol Rover | M01 | An armored wheeled robot with the Clipper's charge rules. Its front always blocks. A charge that ends against a stone backstop stalls it for 1.6 s with the rear hatch open and the teal battery exposed; 3 battery hits destroy it. |
| Staffer | LK01 | A Linked night-shift worker. 2 health. It stays dormant in an annex door until its encounter wakes it, then walks out, winds up for 0.65 s (its hands glow) and makes a grab lunge. Only at the alarm exit. |

What changed: the enemies and every enemy entity ID (so the save schema is now 3), their art, sounds and tests, the look (flat paint lit in the engine, C35), and one line at the exit: a Security PA line plays ("All teams: lethal force is authorized. Harlan is armed.") before the completion screen opens. What did not change: the six areas, 32 beats, the 11 encounter groups (E01–E11) and their beats, the economy, the checkpoints, the keycard exit, Adam's scene and the hero's moves and tuning (Dave is now lit through normal maps). The rover keeps the Clipper's timings.

Population: 8 Night Guards, 6 Patrol Rovers and 2 Staffers, 16 enemies (the C24 build had 15). A06 differs from the level brief on purpose. The brief has two Staffers and no rovers there. A06 keeps its two rovers and gains the second Staffer, because its stone backstops exist only for the rovers and its last rover encounter is the level's "use what you learned" test. [02](02-area-blueprints.md) records the deviation.

## Read in this order

| File | Use |
| --- | --- |
| [00 — Scope](00-scope-and-decisions.md) | Fixed choices, prototype limits, and explicit differences from the broad campaign |
| [01 — Journey and pacing](01-player-journey-and-pacing.md) | Time budget, emotional arc, route, and anti-padding rules |
| [02 — Area blueprints](02-area-blueprints.md) | All six areas, encounter IDs, keycard, recovery, rewards, and exits |
| [03 — Gameplay systems](03-gameplay-systems.md) | Controls, three enemies, pistol, upgrades, keycard exit, checkpoints, story state |
| [04 — Godot architecture](04-godot-architecture.md) | Project structure, scenes, data boundaries, and engine documentation |
| [05 — Content and assets](05-content-and-assets.md) | Existing references, required sprites and lit rigs, sound, night-look rules, and placeholder rules |
| [06 — Build milestones](06-build-milestones.md) | Eight bounded implementation stages, the revamp and rebuild passes, and their exit checks |
| [07 — Acceptance and playtesting](07-acceptance-and-playtesting.md) | Functional checks, timing protocol, and completion gates |
| [08 — AI execution prompts](08-ai-execution-prompts.md) | Master build prompt, one prompt for each milestone, and the revamp and rebuild prompts |
| [09 — Progress and handoff](09-progress-and-handoff.md) | Current state, decisions, evidence, and next-agent template |
| [prototype-spec.json](prototype-spec.json) | Machine-readable IDs, counts, time allocations, and constraints (schema 3: the rebuilt Night Guard, Patrol Rover and Staffer counts) |

## Working on the prototype

The engine project exists at **prototypes/sunnyvale-godot/** (see its README.md for commands and its CONVENTIONS.md for contracts). To resume or extend it, open the **repository working folder**, give the AI access to these files, read [09](09-progress-and-handoff.md) for the current state, and use the prompts in [08](08-ai-execution-prompts.md): the master prompt and M0–M7 prompts describe the original build, the revamp prompt describes the C24 rebuild, and the rebuild prompt describes the C33 rebuild.

The complete reference repository is needed because this folder links to source briefs and other repository files. Do not treat a clone lacking the local solo-hero and revamp updates as the latest design. Check C12 and C14–C35 in [the decision register](../../design/decisions.md).

The broader campaign still has five weapon types, three upgrades each, twelve levels, and four mini-bosses. This slice implements only the Level 1 subset. A running level does not prove its duration, usability, or final art readiness.

## Route

~~~mermaid
flowchart LR
    A01["A01 Gate · 1:15"] --> A02["A02 Gardens · 2:30"]
    A02 --> A03["A03 Roofs · 2:15"]
    A03 --> A04["A04 Plaza · 2:45 · keycard"]
    A04 --> A05["A05 Depot · 1:30"]
    A05 --> A06["A06 Exit · 2:15 · needs card"]
    A02 -. optional .-> O1["Lockout Notice (EF01)"]
    O1 -. rejoin .-> A02
    A03 -. optional .-> O2["20-chip cache"]
    O2 -. rejoin .-> A03
~~~

[Repository entry guide](../../AI_START_HERE.md) · [Campaign Level 1 brief](../../level-design/l01-welcome-to-sunnyvale.md)
