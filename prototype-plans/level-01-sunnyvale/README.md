# Sunnyvale — Level 1 Godot prototype plan

**Visual direction (C11, C15):** [hand-drawn 2D in a dark night-campus palette](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24); there are no selected scene images for the new look.

**Status (C33):** the current prototype is the C24 build (Staffers and the Clipper). Under C33 Level 1 will be rebuilt from the ground up around the C31 roster, after the lit-cutout test (`prototypes/sunnyvale-godot/spike/lit_cutout`). These plans describe the C24 build: its disabled-not-killed Staffers (CY01, now LK01 in the [art briefs](../../art-design/linked/lk01-staffer.md)), the Clipper (removed under C32) and its no-gore rule are history that C25–C35 supersede.

## Revamp (2026-09-29)

The user replaced the game's story and atmosphere (C14–C21) and asked for this prototype to be rebuilt to match (C24); see the [decision register](../../design/decisions.md), entries C14–C24. This plan, the prototype and its reports now describe the rebuilt game: Dave Harlan, a fired AI researcher, breaks back into Arcadia Dynamics' Sunnyvale campus at night to copy proof that the sentient AI Adam is secretly building a weapon (C14, C17, C18).

What changed is story, names, look and collectibles. Zombies are gone entirely and there is no stealth (C16). The old daytime suburb and the zombie art were deleted (C23).

| Before the revamp | Now |
| --- | --- |
| Resident (Z01), a zombie | Staffer (CY01), a cyborg night-shift employee whose Link implant Adam controls; disabled, never killed, no gore (C24 build; C28 and C29 supersede this) |
| Gems | Microchips (C19), shown as "chips" in the interface and code |
| Artifact A01 "Welcome Key" | Evidence file EF01 "Lockout Notice" (optional, journal-only) |
| EDEN, awakened at a power core | Adam, answering Dave at one of its core nodes; the SC01 copy scene |
| Quarantine | Lockdown |
| Cheerful daytime suburb | Arcadia's campus at night |
| Maintenance bench, care capsule | Workbench, med-patch |
| Rook (provisional hero) | Dave Harlan; the Rook sprite pack stays as placeholder art |
| (nothing) | A clearance keycard (L01-KC01, picked up in A04) that the A06 exit wicket needs |

What did not change: the six areas, 32 beats, 11 encounter groups and their IDs (enemy IDs differ only by Z01 becoming CY01), every tuning seed and timing, the economy (45 main-route chips + a 20-chip cache, 40-chip Quickcycle), the checkpoints and the M0–M7 build history. The revamp is a presentation and story rebuild, not a gameplay change; where the linked history in [09](09-progress-and-handoff.md) still says Resident, gem, EDEN or artifact, read it through the table above.

**Status:** M0–M7 were built and verified before the revamp (the record is in [09](09-progress-and-handoff.md)). The revamp (R1) then rebuilt the story, names, look and collectibles; its verification record is 09's latest entry. Playable, timing unverified: the first-time-player timing gate is still pending. The user selected Godot and requested a 10–15 minute Level 1 prototype.

Build a complete, small playable level: break into Arcadia's campus at night, learn to jump and shoot, explore gardens and rooftops, survive the plaza and take the level's keycard, plug into one of Adam's core nodes at the server depot, buy an optional upgrade at the workbench, and escape alone through the keycard wicket.

**Duration target:** 12 minutes 30 seconds for a normal first successful main-route playthrough; optional discoveries add 90–120 seconds. The length is a design budget, not a measured result or a timer lock. [Pacing and measurement](01-player-journey-and-pacing.md) define how to prove the requested 10–15 minutes.

## Read in this order

| File | Use |
| --- | --- |
| [00 — Scope](00-scope-and-decisions.md) | Fixed choices, prototype limits, and explicit differences from the broad campaign |
| [01 — Journey and pacing](01-player-journey-and-pacing.md) | Time budget, emotional arc, route, and anti-padding rules |
| [02 — Area blueprints](02-area-blueprints.md) | All six areas, encounter IDs, keycard, recovery, rewards, and exits |
| [03 — Gameplay systems](03-gameplay-systems.md) | Controls, two enemies, pistol, upgrades, keycard exit, checkpoints, story state |
| [04 — Godot architecture](04-godot-architecture.md) | Project structure, scenes, data boundaries, and engine documentation |
| [05 — Content and assets](05-content-and-assets.md) | Existing references, required sprites, sound, night-look rules, and placeholder rules |
| [06 — Build milestones](06-build-milestones.md) | Eight bounded implementation stages, the revamp pass, and their exit checks |
| [07 — Acceptance and playtesting](07-acceptance-and-playtesting.md) | Functional checks, timing protocol, and completion gates |
| [08 — AI execution prompts](08-ai-execution-prompts.md) | Master build prompt, one prompt for each milestone, and the revamp prompt |
| [09 — Progress and handoff](09-progress-and-handoff.md) | Current state, decisions, evidence, and next-agent template |
| [prototype-spec.json](prototype-spec.json) | Machine-readable IDs, counts, time allocations, and constraints |

## Working on the prototype

The engine project exists at **prototypes/sunnyvale-godot/** (see its README.md for commands and its CONVENTIONS.md for contracts). To resume or extend it, open the **repository working folder**, give the AI access to these files, read [09](09-progress-and-handoff.md) for the current state, and use the prompts in [08](08-ai-execution-prompts.md): the master prompt and M0–M7 prompts describe the original build, and the revamp prompt describes the C24 rebuild.

The complete reference repository is needed because this folder links to source briefs and other repository files. Do not treat a clone lacking the local solo-hero and revamp updates as the latest design. Check C12 and C14–C24 in [the decision register](../../design/decisions.md).

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
