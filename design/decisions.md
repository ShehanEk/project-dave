# Decision register

**Status date:** 2026-09-26. This register separates what the user selected from established project material and the detailed proposals added in this design pass.

- **Confirmed:** an explicit user decision. Preserve it unless the user changes it.
- **Established:** the existing project baseline. Preserve continuity, but do not claim every earlier detail was explicitly approved.
- **Proposed:** a recommended working default for refinement. New names, appearances, quantities, economy, rules, and timings are not final or playtested.

A proposal may be used consistently for further concept work without another approval round, provided it remains labeled. It cannot override a confirmed constraint. Document IDs such as G01 or S01 identify files; decision IDs such as P07 identify decisions.

## Confirmed decisions

| ID | Decision |
| --- | --- |
| C01 | Concept-only project: develop ideas and reference documents; game implementation is not requested. |
| C02 | Gameplay loop: explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade. |
| C03 | Gems are primary treasure; artifacts are an additional treasure category. |
| C04 | Carry one weapon only. The tether occupies that slot; no permanent backup weapon. |
| C05 | Picking up a new weapon drops the previous weapon at the new weapon's location. |
| C06 | Five weapon types, including a shotgun variant, with three upgrades per weapon. |
| C07 | Twelve levels; a unique mini-boss every three levels, increasing in difficulty. |
| C08 | Use separate organized editable files; remove duplicate ZIP archives and do not recreate them. |
| C09 | At least ten robot and ten zombie varieties, with robot-zombie hybrids introduced later through a coherent lore explanation. |
| C10 | R01 Clipper uses [B — Sturdy retro machine](../concept-art/r01-clipper/SELECTED.md) as its selected visual reference. Preserve its wheeled body, separate short eye stalks, two-blade shears and retro mechanical construction. Other Clipper candidates are unselected. |

## Established baseline

| ID | Baseline |
| --- | --- |
| E01 | Existing DEAD EDEN setting and story: careless care, scavenger/maintenance companion, physical neural interfaces, L11 authority/life support, L12 policy resolution. |
| E02 | Existing named roster, five weapon identities and upgrade names, twelve named levels, introductions, and four boss identities. Unapproved visual details and room layouts remain proposals; see C10 for the confirmed Clipper reference. |

## Proposed detailed defaults

| ID | Proposal | Owning documents |
| --- | --- | --- |
| P01 | Single-player authored scope, design pillars, and ordinary section pacing. | [G01](01-core/loop-and-design-pillars.md) |
| P02 | Movement/action model, free aiming on the side plane, grace/buffer ranges, and cancellation rules. | [G02](01-core/player-controls.md), [G04](01-core/camera-and-feedback.md) |
| P03 | Deliberate pickup comparison, stable swap anchors, reversible trials, no campaign chapter replay yet. | [G03](01-core/weapon-swaps.md) |
| P04 | Side camera behavior, look-ahead, visual hierarchy, and reduced-effects feedback. | [G04](01-core/camera-and-feedback.md) |
| P05 | Hero name Rook Venn, background details, personality, appearance, and model studies. | [H01](02-characters/hero.md), [H03](02-characters/relationship-and-banter.md), [N01](05-presentation/story-scenes.md), [N02](05-presentation/dialogue-and-writing.md) |
| P06 | Companion name PIP, appearance, information/support limits, following behavior, and fitting presentation. | [H02](02-characters/companion.md), [H03](02-characters/relationship-and-banter.md), [N01](05-presentation/story-scenes.md), [N02](05-presentation/dialogue-and-writing.md) |
| P07 | Six health units, damage/recovery targets, whole-state checkpoint rollback, no lives, and save boundaries. | [S01](03-progression/health-and-checkpoints.md) |
| P08 | Type-wide paid upgrade record; physical weapon resources; three sequential tiers with campaign gates. | [G03](01-core/weapon-swaps.md), [S01](03-progression/health-and-checkpoints.md), [S04](03-progression/upgrades-and-ownership.md) |
| P09 | Weapon resource models, ammunition amounts, heat behavior, refill stations, and renewable arena supply. | [S02](03-progression/ammunition-and-resupply.md) |
| P10 | Gem denominations, 40/90/160 incremental upgrade costs, and first campaign reward budget. | [S03](03-progression/treasure-economy.md), [S04](03-progression/upgrades-and-ownership.md) |
| P11 | Twelve optional journal-only artifacts, one per level; no sale, stat effect, or ending gate. | [S05](03-progression/artifact-catalog.md) |
| P12 | Faction targeting, protected-character immunity, capped repairs, and restricted authored conversions. | [W01](04-world/factions-and-friendly-fire.md), [W02](04-world/status-and-enemy-states.md) |
| P13 | Status/capture classes, interactive object rules, encounter composition, and boss feasibility requirements. | [W02](04-world/status-and-enemy-states.md), [W03](04-world/objects-and-hazards.md), [W04](04-world/encounter-and-boss-fairness.md) |
| P14 | Scene staging, working dialogue, character relationship delivery, skip and replay handling. | [H03](02-characters/relationship-and-banter.md), [N01](05-presentation/story-scenes.md), [N02](05-presentation/dialogue-and-writing.md) |
| P15 | HUD, pickup/upgrade screens, journal, and adjustable accessibility settings. | [N03](05-presentation/interface-and-accessibility.md) |
| P16 | Sound identities, musical palettes, event priority, caption support, and audio handoff. | [G04](01-core/camera-and-feedback.md), [N04](05-presentation/audio-direction.md) |

## Changes from the previous broad gameplay draft

The earlier unanswered questions now have proposed defaults: gems fund upgrades; artifacts are optional journal discoveries; resource rules differ by weapon; checkpoint retries restore a coherent complete snapshot; completed levels do not retain a retrievable weapon warehouse; and earned upgrades apply to later physical copies of the same weapon type. Ammunition remains attached to each physical gun.

These refinements are described in the relevant files rather than left as contradictory “undecided” rules in the overview. They remain proposals for the user's refinement.

## Still needing refinement or validation

1. Hero/companion names and neutral visual designs.
2. Movement feel, jump distances, weapon damage and enemy durability. No prototype has validated the numerical targets.
3. Economy collection rates, upgrade strengths and gates, and weapon preference over a full run.
4. Exact artifact alcoves, replacement weapon pickups, and supply placement in each existing level layout.
5. Full final dialogue, journal entries, UI mockups, music, and sound assets.
6. Chapter replay, additional difficulty modes, engine/platform selection, and implementation planning if later requested.

When changing a decision, edit its owner, this register, and any affected campaign/art/level references in the same pass. Keep the status honest; only mark a proposal confirmed when the user actually confirms it. The current handoff remains concept-only.

[Design index](README.md) · [AI entry guide](../AI_START_HERE.md)
