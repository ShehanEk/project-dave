# DEAD EDEN — Health, failure, and checkpoint recovery

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Document ID:** S01  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines damage, recovery, the exact retry boundary, and prevention of duplicated rewards.

**Decision references:** C04, C05, P07, P08 — see the [decision register](../decisions.md).  
**Read with:** [ammunition and resupply](ammunition-and-resupply.md) · [upgrades and ownership](upgrades-and-ownership.md) · [weapon swaps](../01-core/weapon-swaps.md)

## Proposed health model
Start with **6 health units**, shown as six large segments. A normal hit costs 1; a clearly signaled heavy strike costs 2. A hit grants roughly 1 second of damage immunity. Continuous hazards cannot apply all their damage in one frame. These are first-playtest targets, not balanced specifications.

Damage briefly interrupts the hero and gives a small readable push, but never launches them across the room. During immunity, movement remains available. Do not use mandatory camera shake or rapid flashing to communicate invulnerability.

A fall into a normal pit costs 1 unit and returns the hero to the last stable foothold outside the hazard. It does not erase recent treasure unless that damage reaches zero health. The landing point must never be a moving platform that has left, an enemy attack, or a closed door. Deep background scenery is not a hidden second play plane.

At zero health, return to the latest committed checkpoint. There are no limited lives, corpse runs, dropped currency bags, or escalating retry fees in this proposal.

## Health supplies
A small care capsule restores 2 units; a large care kit restores all missing health. Neither increases maximum health. At full health, leave the pickup in place. Health supplies have a white medical cross-shaped silhouette and warm pink center, distinct from blue ammunition cartridges and angular gems.

Care supplies placed on the route are finite within a checkpoint attempt. A checkpoint fully restores health. Enemy kills are not the only source of healing; story and traversal routes must also be recoverable. Maximum-health upgrades and consumable inventory are outside this first design.

## What counts as a save
A **recovery checkpoint** is a visibly safe maintenance station. First activation heals, services the held weapon, and commits the state below. Returning to an already activated station can service and commit again; enemy and treasure states do not reset merely because it is used.

A **maintenance checkpoint** is a recovery checkpoint with an upgrade bench. Put one at each level's start or first safe hub and each level's exit; additional midpoint recovery-only stations follow the existing level briefs. The L1 start is the initial entry snapshot, with its first usable bench in the depot after meeting PIP. Boss preparation stations are maintenance checkpoints.

A **story checkpoint** commits after an irreversible main-story event or level transition. It saves current health and weapon resources without granting an invisible refill. Place a recovery station nearby when a refill is needed. No story scene can leave a half-committed quest state.

Saving and reloading use the same checkpoint boundary as death. Show "Progress saved" only after committing. Quitting before another commit returns to the previous boundary; explain that boundary in the pause screen.

## Snapshot contents
| Category | Saved together |
| --- | --- |
| Player | Safe location, health, the identity of the one held weapon, its ammunition and heat |
| World weapons | Identities, positions, resource states, and fitted stages of dropped/authored pickups in the active level |
| Progression | Gem wallet, earned upgrade stages by weapon type, recorded artifact IDs |
| World progress | Consumed treasure and supplies, defeated encounter groups, switches, doors, completed objectives |
| Story | Completed scenes, protected survivor outcomes, route state and latest committed story milestone |

On death, restore **all** of these from one snapshot. Gems, artifacts, purchases, enemies, and pickups acquired or changed after it roll back together. A weapon taken after it returns to its saved location; the saved held weapon returns to the hero. This is rollback, not recovery of an abandoned arsenal.

Routine particles, falling debris, audio playback positions, and PIP's exact hover position do not need persistence. Rebuild them in safe idle states. Moving platforms and timed hazards restart at their defined checkpoint-safe phases; the saved player position cannot depend on a random phase.

## Purchases and exploitation rules
Every successful upgrade purchase atomically deducts gems, records the new type-wide stage, fits the held weapon, and commits the complete current state. A failed or cancelled purchase changes nothing. A power interruption must never yield the upgrade without its cost.

A refill never creates a weapon. Swapping at a pickup never services either weapon. Reloading the same checkpoint cannot duplicate a treasure item because the wallet and that item's collected flag return together.

An artifact found after a checkpoint is lost from the collection on death and becomes collectible again. A committed artifact stays recorded and does not reappear. The same rule applies to finite gem caches.

## Level boundaries and open tuning
A level exit commits the held weapon, wallet, upgrades, artifacts, and story progress. Weapons left behind are not transferred to the next level. This campaign proposal has no chapter-select replay or backtracking between completed levels; adding either requires explicit persistence design first.

Checkpoint spacing should usually cover one meaningful traversal/combat section, with a station before each boss. Exact spacing, damage values, healing density, and safe-footing behavior require later prototype testing.

## Acceptance examples
- Save with pistol and 35 gems; swap for shotgun, collect 20, die: return with pistol and 35, with the shotgun restored to its saved pickup.
- Find an artifact, activate a station, then die: retain the artifact and do not spawn a second copy.
- Buy a 40-gem upgrade with 60 gems: the committed state has stage 1 and 20 gems.
- Use a station twice: heal twice, but do not respawn its surrounding defeated enemies or gems.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
