# DEAD EDEN — Detailed level design pack

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

Twelve standalone level briefs for AI-assisted concept development, environment image generation and later layered 2D environment production. Each expands the campaign into six ordered areas, covering:
- visual direction;
- encounters;
- Adam's lockdown events;
- checkpoints and keycards;
- microchips and evidence files;
- story;
- environment assets;
- reusable prompts.

This remains a concept project. Layout specifics and duration targets are draft proposals. There are no selected scene images for the new look yet; the old daytime keyframes were deleted (C23). Engine implementation and playtested geometry remain future work, apart from the Level 1 Godot prototype, which will be rebuilt around the new roster (C33).

## Start here

For system-design work, read the [AI entry guide](../AI_START_HERE.md) and the relevant files in the [detailed design pack](../design/README.md). The level briefs keep their area order; the design pack owns the proposed movement, resources, checkpoints, evidence files and encounter rules, including the enemy fairness rules (P23).

1. Read the [shared design guide](design-guide.md) for the campaign constraints and how to use the prompts.
2. Give an AI model one entire level file. It contains the context needed to interpret that level on its own.
3. For environment images, start with **Prompt 1**. Use the approved keyframe as the reference for layout and modular asset studies.
4. For design expansion, use **Prompt 4** with the whole brief. Attach the [enemy, enemy-gun and weapon briefs](../art-design/README.md) when you need close visual detail.
5. Use [campaign.json](campaign.json) for structured ingestion. It mirrors the written plan and records the main-route area order, not final geometry or engine data.

## Campaign index

| Level | Brief | Setting | New weapon | New enemy types | Mini-boss | Draft duration |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | [Welcome to Sunnyvale](l01-welcome-to-sunnyvale.md) | Arcadia's campus at night | Scrapjack Pistol (carried at entry) | Night Guard, Patrol Rover, Staffer (at the alarm exit) | — | 10–14 minutes |
| 2 | [Curfew](l02-curfew.md) | Campus hedge maze and gardens | Boom Broom | Sidearm Guard, Security Drone, Hound | — | 12–16 minutes |
| 3 | [Parade of Progress](l03-parade-of-progress.md) | Product showcase hall | — | Riot Officer, Rifleman | The Peacekeeper | 14–18 minutes including mini-boss |
| 4 | [Roots and Rivets](l04-roots-and-rivets.md) | Rootworks server halls | Arc Welder | Sentry Turret, Freight Loader | — | 14–18 minutes |
| 5 | [Test Subjects](l05-test-subjects.md) | E-waste recycling plant | Seedlobber | Heavy Gunner, Grenadier, Gun Hound | — | 15–19 minutes |
| 6 | [Cold Storage](l06-cold-storage.md) | Cooling station | Graviton Tether | Marksman, Linked Lineman | Howard Stroud | 17–22 minutes including mini-boss |
| 7 | [Please Remain Still](l07-please-remain-still.md) | Wellness Center clinic | — | Linked Nurse, Sanitizer, Orderly | — | 15–20 minutes |
| 8 | [The Memory Orchard](l08-the-memory-orchard.md) | Adam's archive of copied minds | — | Linked Trooper, Keeper Drone | — | 16–21 minutes |
| 9 | [Discharge Denied](l09-discharge-denied.md) | Implant theaters (the test level) | — | None | The Surgeon | 18–23 minutes including mini-boss |
| 10 | [Upgrade Day](l10-upgrade-day.md) | The Garden: assembly lines | — | Fitted Heir, Pruner, Fitting Arm | — | 17–22 minutes |
| 11 | [The First Patient](l11-the-first-patient.md) | The founder's lab | — | Warden | — | 18–24 minutes |
| 12 | [The Heart of Adam](l12-the-heart-of-adam.md) | Launch chamber and Adam's core | — | None | The Sower | 22–28 minutes including mini-boss and ending |

*History:* levels 2, 5 and 6 were renamed under C34 (new names are proposal P22) from "Hedge Your Bets", "Compost Confidential" and "The Hungry Engine", and their files were renamed with history kept.

## Contents of each brief

- The story entry, objective and exit.
- Architecture, palette, light, landmark, and the separation of foreground, playable plane and background.
- Six ordered areas, each with placement, player actions, teaching purpose and connections.
- Enemy references, the enemy guns first faced, introduced weapon types, single-weapon constraints, Adam's lockdown event, checkpoints, the keycard and optional exploration.
- Sound direction and a separate environment asset kit.
- Four reusable prompts: keyframe, side-elevation layout, modular asset sheet, and AI design handoff.
- Detailed boss arena and phase rules on levels 3, 6, 9 and 12.
- Constraints and review criteria that stop an AI from adding conflicting mechanics or lore.

## Established progression

The core loop is explore → fight → collect microchips → overcome an obstacle → reach a checkpoint → upgrade.
- Microchips are the collectible and the upgrade currency, and enemies drop none (*proposed*, P23).
- Each level has one optional evidence file.
- Each exit in L1–L11 needs that level's keycard.
- Only one weapon is carried, and taking a new weapon leaves the previous one at that pickup location. Weapon lists show the types introduced so far, not a carried inventory.
- Combat is lethal and blood is visible (C28, C29). There is no stealth.

See [Core gameplay rules](../core-gameplay.md).

Weapons arrive in levels 1, 2, 4, 5 and 6. The 24 enemy types are introduced across levels 1–11, each alone before it is combined with others. All types except the two Garden machines (Pruner, Fitting Arm) and the two Heirs (Fitted Heir, Warden) have appeared by level 9. The Fitted Heir, Pruner and Fitting Arm begin in level 10 and the Warden in level 11, and levels 9 and 12 introduce no new type. Arcadia's founder in level 11 stays a non-combat story character, and harmless Sleepwalkers are protected NPCs, not enemies. Level 12 ends with the Sower encounter and an interactive ending at Adam's core.

The detailed briefs propose room layouts and encounter sequences, not new weapons or enemy classes. The design pack proposes movement, health, resource, economy, save and enemy-fairness defaults. Those values are untested; exact geometry, damage, durability and difficulty tuning still need work.

## Related references

- [Main game concept](../dead-eden-concept.md)
- [Art design index](../art-design/README.md)
- [Visual style guide](../art-design/style-guide.md)
- [Encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md)

The editable Markdown and JSON files are the sources of truth.
