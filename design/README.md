# DEAD EDEN — Detailed game design

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

Eighteen focused design documents, in five sections. This pack connects the story, art briefs and twelve-level campaign with player and system rules. It is a concept specification, not game code or a claim of tested balance.

**Start with [AI_START_HERE](../AI_START_HERE.md)** and the [decision register](decisions.md). These are fixed by user decisions:
- the one-weapon ground swap;
- the microchip-led loop;
- no stealth;
- the new story;
- the names Adam and Dave Harlan;
- a mature game with lethal combat and visible blood (C28, C29);
- human enemies, cyborg dogs and an enemy gun kit (C25, C27, C30).

Health, resource counts, costs, evidence files, keycards, presentation details and the enemy roster's behaviors, numbers and fairness rules (P23) are proposed defaults.

## Reading order

| Order | Section | Files |
| --- | --- | ---: |
| 1 | [Core gameplay and player rules](01-core/README.md) | 4 |
| 2 | [Hero](02-characters/README.md) | 1 |
| 3 | [Health, ammunition, microchips and upgrades](03-progression/README.md) | 5 |
| 4 | [Enemy interactions and environmental objects](04-world/README.md) | 4 |
| 5 | [Story scenes, interface and sound direction](05-presentation/README.md) | 4 |

## Find a specific document

| ID | Document | Main responsibility |
| --- | --- | --- |
| G01 | [Core loop and design pillars](01-core/loop-and-design-pillars.md) | The player rhythm, intended experience, mature-content boundaries, keycard exits and pacing rules. |
| G02 | [Player movement, aiming and action rules](01-core/player-controls.md) | Input actions, jump behavior (no crouch), aiming, action priorities, half knockback from enemy shots and movement exclusions. |
| G03 | [One carried weapon and world pickups](01-core/weapon-swaps.md) | The precise ground-swap interaction, weapon state, boundaries and save behavior. Enemy guns are never pickups. |
| G04 | [Camera, readability and moment-to-moment feedback](01-core/camera-and-feedback.md) | Camera behavior and the visual language for danger, hits, blood, engine lighting, surfaces, targets and rewards in dark scenes. |
| H01 | [Hero — Dave Harlan](02-characters/hero.md) | The protagonist's identity, motivation, personality, appearance and sprite requirements. |
| S01 | [Health, failure and checkpoint recovery](03-progression/health-and-checkpoints.md) | Damage, recovery, the exact retry boundary, and preventing duplicated rewards. |
| S02 | [Weapon resources and ammunition](03-progression/ammunition-and-resupply.md) | A distinct resource rhythm per weapon, keeping required encounters possible with any carried weapon. |
| S03 | [Microchips, rewards and upgrade economy](03-progression/treasure-economy.md) | Hand-placed microchip values (enemies drop nothing), spending, a twelve-level budget and safeguards against farming. |
| S04 | [Upgrade stages and ownership](03-progression/upgrades-and-ownership.md) | Keeps all fifteen upgrades (five renamed under C34) and proposes ownership across copies of a weapon type. |
| S05 | [Evidence files](03-progression/evidence-files.md) | Twelve optional evidence files, including the Peacekeeper's export contract and Thornwall's invoice, with their content, placement intent and narrative limits. |
| W01 | [Factions, targeting and friendly fire](04-world/factions-and-friendly-fire.md) | Arcadia Security, Thornwall, Adam's machines, the Linked, cyborg dogs and the Heirs; who is hostile, protected people, and enemy-on-enemy limits. |
| W02 | [Enemy states, status effects and capture rules](04-world/status-and-enemy-states.md) | The five behavior templates, tells, armor, lethal deaths, blood, ragdolls and corpses, status limits and tether capture classes. |
| W03 | [Environmental objects and hazards](04-world/objects-and-hazards.md) | An object catalog covering appearance, allowed interactions, reset behavior, keycard doors, the low and high cover kit and route safeguards. |
| W04 | [Encounter planning and boss fairness](04-world/encounter-and-boss-fairness.md) | Fairness rules and screen caps for enemy guns, escalating encounter composition, and checking every boss against each single weapon. |
| N01 | [Story scenes and campaign continuity](05-presentation/story-scenes.md) | A twelve-level scene plan, with detailed treatments of the opening, the turn to lethal force, the dead-man-switch reveal and the ending, and the rationed aftermath scenes. |
| N02 | [Dialogue, voices and writing direction](05-presentation/dialogue-and-writing.md) | Voices for Adam, Dave, Arcadia, the guards and Thornwall, the Linked and the machines; barks, profanity limits, sample lines and delivery rules. |
| N03 | [Interface and accessibility direction](05-presentation/interface-and-accessibility.md) | The one-weapon HUD, microchip counter, keycard indicator, journal, the Blood setting and dark-scene accessibility options. |
| N04 | [Sound and music direction](05-presentation/audio-direction.md) | Act moods, weapon and enemy-gun identities, attack cues, restrained wet impacts, Adam's voice, mix priorities and an audio asset handoff. |

## Handoff tools

- [Decision register](decisions.md): confirmed constraints (including the C14–C35 revamp), established material, proposals and remaining questions.
- [Machine-readable manifest](manifest.json): file IDs, dependencies, decision references and task-specific reading routes. It is an index, not runtime data.
- [Consistency review scenarios](review-scenarios.md): concrete cases for checking future edits.
- [Core gameplay summary](../core-gameplay.md): a short overview for people reading the concept first.
- [Level pack](../level-design/README.md) and [art pack](../art-design/README.md): the detailed layouts and visual briefs, within their stated proposal status.

Generated images live in the [concept-art gallery](../concept-art/README.md). Only Dave's placeholder sprite pack remains there; the zombie, old daytime and removed-machine concept art was deleted (C23, C32). Finished sprite sheets, UI screens, audio and an updated playable build remain future work. Keep the individual editable sources, and do not bundle duplicate ZIPs.
