# DEAD EDEN — Detailed game design

Twenty focused design documents in the requested five-part order. This pack connects the existing lore, art briefs, and twelve-level campaign with player and system rules. It is a concept specification, not game code or a claim of tested balance.

**Start with [AI_START_HERE](../AI_START_HERE.md)** and the [decision register](decisions.md). The user-confirmed one-weapon ground swap and gem-led loop remain fixed. Hero names, health, resource counts, costs, artifacts, and presentation details are proposed defaults.

## Reading order

| Order | Section | Files |
| --- | --- | ---: |
| 1 | [Core gameplay and player rules](01-core/README.md) | 4 |
| 2 | [Hero and companion](02-characters/README.md) | 3 |
| 3 | [Health, ammunition, treasure, and upgrades](03-progression/README.md) | 5 |
| 4 | [Enemy interactions and environmental objects](04-world/README.md) | 4 |
| 5 | [Story scenes, interface, and sound direction](05-presentation/README.md) | 4 |

## Find a specific document

| ID | Document | Main responsibility |
| --- | --- | --- |
| G01 | [Core loop and design pillars](01-core/loop-and-design-pillars.md) | The player rhythm, intended experience, content boundaries, and pacing rules. |
| G02 | [Player movement, aiming, and action rules](01-core/player-controls.md) | Input actions, jump behavior, aiming, action priorities, and movement exclusions. |
| G03 | [One carried weapon and world pickups](01-core/weapon-swaps.md) | The precise ground-swap interaction, weapon state, boundaries, and save behavior. |
| G04 | [Camera, readability, and moment-to-moment feedback](01-core/camera-and-feedback.md) | Gameplay camera behavior and the visual language for danger, surfaces, targets, and rewards. |
| H01 | [Hero — Rook Venn (working proposal)](02-characters/hero.md) | Proposed protagonist identity, motivation, silhouette, personality, and modeling reference. |
| H02 | [Companion — PIP (working proposal)](02-characters/companion.md) | The maintenance companion's identity, limited abilities, appearance, and authority reveal. |
| H03 | [Hero–companion relationship and dialogue behavior](02-characters/relationship-and-banter.md) | Relationship arc, scene-level changes, and rules for useful banter without hint spam. |
| S01 | [Health, failure, and checkpoint recovery](03-progression/health-and-checkpoints.md) | Defines damage, recovery, the exact retry boundary, and prevention of duplicated rewards. |
| S02 | [Weapon resources and ammunition](03-progression/ammunition-and-resupply.md) | Gives every weapon a distinct resource rhythm and keeps required encounters possible with any carried weapon. |
| S03 | [Gems, rewards, and upgrade economy](03-progression/treasure-economy.md) | Defines treasure values, spending, a twelve-level budget, and safeguards against farming. |
| S04 | [Upgrade stages and ownership](03-progression/upgrades-and-ownership.md) | Keeps all fifteen established upgrades and proposes ownership across copies of a weapon type. |
| S05 | [Artifacts and discovery catalog](03-progression/artifact-catalog.md) | Proposes twelve optional lore artifacts, with appearance, placement intent, and narrative limits. |
| W01 | [Factions, targeting, and friendly fire](04-world/factions-and-friendly-fire.md) | Defines hostility, protected characters, mechanical repair, and the physical limits of Returned conversion. |
| W02 | [Enemy states, status effects, and capture rules](04-world/status-and-enemy-states.md) | Standardizes warnings, armor, interruptibility, status limits, and tether target classes. |
| W03 | [Environmental objects and hazards](04-world/objects-and-hazards.md) | An object catalog describing appearance, allowed interactions, reset behavior, and route safeguards. |
| W04 | [Encounter planning and boss fairness](04-world/encounter-and-boss-fairness.md) | Defines escalating encounter composition and checks every boss against the available single weapons. |
| N01 | [Story scenes and campaign continuity](05-presentation/story-scenes.md) | A twelve-level scene plan, with detailed opening, reveal, and ending treatments. |
| N02 | [Dialogue, voices, and writing direction](05-presentation/dialogue-and-writing.md) | Defines character voices, sample lines, humor limits, and delivery rules. |
| N03 | [Interface and accessibility direction](05-presentation/interface-and-accessibility.md) | Defines the one-weapon HUD, swap and upgrade screens, journal, and adjustable presentation. |
| N04 | [Sound and music direction](05-presentation/audio-direction.md) | Defines act moods, weapon identities, attack cues, mix priorities, and an audio asset handoff. |

## Handoff tools

- [Decision register](decisions.md): confirmed constraints, established material, proposals, and remaining questions.
- [Machine-readable manifest](manifest.json): file IDs, dependencies, decision references, and task-specific reading routes. It is an index, not runtime data.
- [Consistency review scenarios](review-scenarios.md): concrete cases for checking future edits.
- [Core gameplay summary](../core-gameplay.md): short overview for people reading the concept first.
- [Existing level pack](../level-design/README.md) and [art pack](../art-design/README.md): authoritative detailed layouts and visual briefs within their stated proposal status.

The current pack adds written hero/companion art direction and artifact descriptions. It does not contain generated reference images, finished models, UI screens, audio, or a playable build. Keep the individual editable sources; do not bundle duplicate ZIPs.
