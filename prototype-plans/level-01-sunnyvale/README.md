# Sunnyvale — Level 1 Godot prototype plan

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

**Status:** Planning complete; implementation, art production, and playtesting have not started. The user selected Godot and requested a 10–15 minute Level 1 prototype plan. This folder is the handoff for a later build request.

Build a complete, small playable level: arrive in a cheerful suburb, learn to jump and shoot, explore gardens and rooftops, survive the square, awaken EDEN at the depot, buy an optional upgrade, and escape alone.

**Duration target:** 12 minutes 30 seconds for a normal first successful main-route playthrough; optional discoveries add 90–120 seconds. The length is a design budget, not a measured result or a timer lock. [Pacing and measurement](01-player-journey-and-pacing.md) define how to prove the requested 10–15 minutes.

## Read in this order

| File | Use |
| --- | --- |
| [00 — Scope](00-scope-and-decisions.md) | Fixed choices, prototype limits, and explicit differences from the broad campaign |
| [01 — Journey and pacing](01-player-journey-and-pacing.md) | Time budget, emotional arc, route, and anti-padding rules |
| [02 — Area blueprints](02-area-blueprints.md) | All six areas, encounter IDs, recovery, rewards, and exits |
| [03 — Gameplay systems](03-gameplay-systems.md) | Controls, two enemies, pistol, upgrades, checkpoints, story state |
| [04 — Godot architecture](04-godot-architecture.md) | Project structure, scenes, data boundaries, and engine documentation |
| [05 — Content and assets](05-content-and-assets.md) | Existing references, required sprites, sound, and placeholder rules |
| [06 — Build milestones](06-build-milestones.md) | Eight bounded implementation stages and their exit checks |
| [07 — Acceptance and playtesting](07-acceptance-and-playtesting.md) | Functional checks, timing protocol, and completion gates |
| [08 — AI execution prompts](08-ai-execution-prompts.md) | Master build prompt and one prompt for each milestone |
| [09 — Progress and handoff](09-progress-and-handoff.md) | Current state, decisions, evidence, and next-agent template |
| [prototype-spec.json](prototype-spec.json) | Machine-readable IDs, counts, time allocations, and constraints |

## Start implementation later

Open the **repository working folder**, give the AI access to these files, and paste the master prompt in [08](08-ai-execution-prompts.md). Start at M0, then follow the dependency order. Future game files belong under **prototypes/sunnyvale-godot/** in the repository; that directory has not been created by this planning task.

The complete reference repository is needed because this folder links to source briefs and selected PNGs. Do not treat a clone lacking the local solo-hero updates as the latest design. Check C12 in [the decision register](../../design/decisions.md).

The broader campaign still has five weapon types, three upgrades each, twelve levels, and four bosses. This slice implements only the Level 1 subset. A running level does not prove its duration, usability, or final art readiness.

## Route

~~~mermaid
flowchart LR
    A01["A01 Gate · 1:15"] --> A02["A02 Gardens · 2:30"]
    A02 --> A03["A03 Roofs · 2:15"]
    A03 --> A04["A04 Square · 2:45"]
    A04 --> A05["A05 Depot · 1:30"]
    A05 --> A06["A06 Exit · 2:15"]
    A02 -. optional .-> O1["Welcome Key"]
    O1 -. rejoin .-> A02
    A03 -. optional .-> O2["20-gem cache"]
    O2 -. rejoin .-> A03
~~~

[Repository entry guide](../../AI_START_HERE.md) · [Campaign Level 1 brief](../../level-design/l01-welcome-to-sunnyvale.md)
