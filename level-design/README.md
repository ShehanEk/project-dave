# DEAD EDEN — Detailed level design pack

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

Twelve standalone level briefs for AI-assisted concept development, environment image generation, and later layered 2D environment production. Each expands the established campaign into six ordered areas with visual direction, encounters, transformations, checkpoints, secrets, story, environment assets, and reusable prompts.

This remains a concept project. Layout specifics and duration targets are draft proposals; three selected [Sunnyvale keyframes](../concept-art/l01-sunnyvale/README.md) now exist; engine implementation and playtested geometry remain future work.

## Start here

For system-design work, read the [AI entry guide](../AI_START_HERE.md) and the relevant files in the [detailed design pack](../design/README.md). The level briefs retain their area order; the new pack owns proposed movement, resources, checkpoints, artifacts, and encounter rules.

1. Read the [shared design guide](design-guide.md) for campaign constraints and how to use the prompts.
2. Give an AI model one entire level file. It contains the context needed to interpret that level independently.
3. For environment images, start with **Prompt 1**. Use the approved keyframe as the reference for layout and modular asset studies.
4. For design expansion, use **Prompt 4** with the whole brief. Attach [enemy and weapon briefs](../art-design/README.md) when those need close visual detail.
5. Use [campaign.json](campaign.json) for structured ingestion. It mirrors the written plan and records main-route area order, not final geometry or engine data.

## Campaign index

| Level | Brief | New weapon | Mini-boss | Draft duration |
| --- | --- | --- | --- | --- |
| 1 | [Welcome to Sunnyvale](l01-welcome-to-sunnyvale.md) | Scrapjack Pistol (available at entry) | — | 10–14 minutes |
| 2 | [Hedge Your Bets](l02-hedge-your-bets.md) | Boom Broom | — | 12–16 minutes |
| 3 | [Parade of Progress](l03-parade-of-progress.md) | — | Mr. Mulch | 14–18 minutes including mini-boss |
| 4 | [Roots and Rivets](l04-roots-and-rivets.md) | Arc Welder | — | 14–18 minutes |
| 5 | [Compost Confidential](l05-compost-confidential.md) | Seedlobber | — | 15–19 minutes |
| 6 | [The Hungry Engine](l06-the-hungry-engine.md) | Graviton Tether | Old Rootjaw | 17–22 minutes including mini-boss |
| 7 | [Please Remain Still](l07-please-remain-still.md) | — | — | 15–20 minutes |
| 8 | [The Memory Orchard](l08-the-memory-orchard.md) | — | — | 16–21 minutes |
| 9 | [Discharge Denied](l09-discharge-denied.md) | — | Matron Mercy | 18–23 minutes including mini-boss |
| 10 | [Upgrade Day](l10-upgrade-day.md) | — | — | 17–22 minutes |
| 11 | [The First Patient](l11-the-first-patient.md) | — | — | 18–24 minutes |
| 12 | [The Heart of EDEN](l12-the-heart-of-eden.md) | — | The Unfinished Choir | 22–28 minutes including mini-boss and resolution |

## Contents of each brief

- Story entry, objective, and exit.
- Architecture, palette, light, landmark, and foreground/playable/background separation.
- Six ordered areas with placement, player actions, teaching purpose, and connections.
- Enemy references, introduced weapon types, single-weapon constraints, environmental changes, checkpoints, and optional exploration.
- Sound direction and a separate environment asset kit.
- Four reusable prompts: keyframe, side-elevation layout, modular asset sheet, and AI design handoff.
- Detailed boss arena and phase rules on levels 3, 6, 9, and 12.
- Constraints and review criteria to prevent an AI from adding conflicting mechanics or lore.

## Established progression

The core loop is explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade. Gems are the primary treasure; artifacts are additional finds. Only one weapon is carried. Taking a new weapon leaves the previous one at that pickup location. Weapon lists show introduced types, not a carried inventory. See [Core gameplay rules](../core-gameplay.md).

Weapons arrive in levels 1, 2, 4, 5, and 6. All ten ordinary robot and ten zombie types have appeared by level 9. Returned begin in level 10; ordinary Choir Units arrive in level 11. The First Patient stays a noncombat story character. Level 12 ends with the Unfinished Choir encounter and an interactive resolution with EDEN.

The detailed briefs add proposed room layouts and encounter sequences, not new weapons or enemy classes. The detailed design pack now proposes movement, health, resource, economy, and save defaults. Their values remain untested; exact geometry, damage, durability, and difficulty tuning still need refinement.

## Related references

- [Main game concept](../dead-eden-concept.md)
- [Art design index](../art-design/README.md)
- [Shared visual style](../art-design/style-guide.md)

The editable Markdown and JSON files are the sources of truth. Use the links above to access the main concept and the art-design references used by these levels.
