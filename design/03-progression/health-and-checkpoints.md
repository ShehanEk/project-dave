# DEAD EDEN — Health, failure, and checkpoint recovery

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** S01  
**Status:** Working design proposal. Confirmed decisions and the established baseline remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines damage, recovery, the exact retry boundary, and prevention of duplicated rewards.

**Decision references:** C12, C04, C05, C19, C28, C29, P07, P08, P11, P19, P20 — see the [decision register](../decisions.md).  
**Read with:** [ammunition and resupply](ammunition-and-resupply.md) · [upgrades and ownership](upgrades-and-ownership.md) · [weapon swaps](../01-core/weapon-swaps.md) · [core loop and keycards](../01-core/loop-and-design-pillars.md)

## Proposed health model
Start with **6 health units**, shown as six large segments. A normal hit costs 1; a clearly signaled heavy strike costs 2. A hit grants roughly 1 second of damage immunity. Continuous hazards cannot apply all their damage in one frame. These are first-playtest targets, not balanced specifications.

Damage briefly interrupts the hero and gives a small readable push (half as much from an enemy projectile, see [G02](../01-core/player-controls.md)), but never launches him across the room. During immunity, movement remains available. Do not use mandatory camera shake or rapid flashing to communicate invulnerability.

A fall into a normal pit costs 1 unit and returns the hero to the last stable foothold outside the hazard. It does not erase recent treasure unless that damage reaches zero health. The landing point must never be a moving platform that has left, an enemy attack, a closed door, or an unlit spot. Deep background scenery is not a hidden second play plane.

At zero health, return to the latest committed checkpoint. There are no limited lives, corpse runs, dropped currency bags, or escalating retry fees in this proposal.

## Health supplies
A small med-patch *(proposed name)* restores 2 units; a large med-kit *(proposed name)* restores all missing health. Neither increases maximum health. At full health, leave the pickup in place. Health supplies have a white medical cross-shaped silhouette and warm pink center, with a rim light so they read in the dark, distinct from blue ammunition cartridges and gold microchips.

Health supplies placed on the route are finite within a checkpoint attempt. A checkpoint fully restores health. Enemy defeats are not the only source of healing; story and traversal routes must also be recoverable. Maximum-health upgrades and consumable inventory are outside this first design.

## What counts as a save
A **recovery checkpoint** is a visibly safe, lit recovery station. First activation heals, services the held weapon, and commits the state below. Returning to an already activated station can service and commit again; enemy and treasure states do not reset merely because it is used.

A **workbench checkpoint** *(proposed name)* is a recovery checkpoint with a workbench for upgrades. Put one at each level's start or first safe hub and each level's exit; additional midpoint recovery-only stations follow the existing level briefs. The L1 start is the initial entry snapshot, with its first usable workbench in the server depot after Adam answers Dave and the lockdown begins. Boss preparation stations are workbench checkpoints.

A **story checkpoint** commits after an irreversible main-story event or level transition. It saves current health and weapon resources without granting an invisible refill. Place a recovery station nearby when a refill is needed. No story scene can leave a half-committed quest state. Defeating a mini-boss is such an event: it commits at once, so a later death never repeats the fight. On levels 3, 6 and 9 the level's keycard is then released as the boss's reward, at the arena console or as a drop at a safe spot (see [W03](../04-world/objects-and-hazards.md)).

Saving and reloading use the same checkpoint boundary as death. Show "Progress saved" only after committing. Quitting before another commit returns to the previous boundary; explain that boundary in the pause screen.

## Snapshot contents
| Category | Saved together |
| --- | --- |
| Player | Safe location, health, the identity of the one held weapon, its ammunition and heat |
| World weapons | Identities, positions, resource states, and fitted stages of dropped/authored pickups in the active level |
| Progression | Microchip wallet, earned upgrade stages by weapon type, recorded evidence-file IDs |
| World progress | Consumed treasure and supplies, defeated encounter groups (their bodies come back as static corpses, see [W02](../04-world/status-and-enemy-states.md)), switches, doors, completed objectives, and the level's keycard (taken or not) |
| Story | Completed scenes, protected staff outcomes (freed clinic staff, harmless Sleepwalkers, the founder), route state, server-depot state (Adam's awareness of Dave, the partial evidence copy, the open emergency hatch) and lockdown state, the three L11 launch-circuit controls, isolation verification, manual override access, and latest committed story milestone |

On death, restore **all** of these from one snapshot. Microchips, evidence files, purchases, enemies, pickups, and the keycard acquired or changed after it roll back together. A weapon taken after it returns to its saved location; the saved held weapon returns to the hero. This is rollback, not recovery of an abandoned arsenal.

Routine particles, blood sprays, ragdoll motion, falling debris, flickering lights, and audio playback positions do not need persistence. Rebuild them in safe idle states. Bodies of enemies killed before the snapshot are rebuilt as static corpses with dry blood pools, without replaying their deaths. Moving platforms, timed hazards and any lockdown event still in progress restart at their defined checkpoint-safe phases; the saved player position cannot depend on a random phase. A lockdown event that permanently changed the route (such as the level 1 lockdown) is saved as route state.

## Purchases and exploitation rules
Every successful upgrade purchase atomically deducts microchips, records the new type-wide stage, fits the held weapon, and commits the complete current state. A failed or cancelled purchase changes nothing. A power interruption must never yield the upgrade without its cost.

A refill never creates a weapon. Swapping at a pickup never services either weapon. Reloading the same checkpoint cannot duplicate a treasure item because the wallet and that item's collected flag return together.

An evidence file found after a checkpoint is lost from the journal on death and becomes collectible again. A committed evidence file stays recorded and does not reappear. The same rule applies to finite chip caches and to the level's keycard: a card taken after a checkpoint returns to its spot on death, and a committed card stays held and never spawns a second copy.

## Level boundaries and open tuning
A level exit commits the held weapon, wallet, upgrades, evidence files, and story progress. On levels 1–11 the exit door first needs that level's keycard, which is spent at the door and never carries into the next level. Level 12 has no keycard, because its ending happens at Adam's core. Weapons left behind are not transferred to the next level. This campaign proposal has no chapter-select replay or backtracking between completed levels; adding either requires explicit persistence design first.

Checkpoint spacing should usually cover one meaningful traversal/combat section, with a station before each boss. Exact spacing, damage values, healing density, and safe-footing behavior require later prototype testing.

## Acceptance examples
- Save with pistol and 35 microchips; swap for shotgun, collect 20, die: return with pistol and 35, with the shotgun restored to its saved pickup.
- Find an evidence file, activate a station, then die: retain the file and do not spawn a second copy.
- Buy a 40-chip upgrade with 60 chips: the committed state has stage 1 and 20 chips.
- Use a station twice: heal twice, but do not respawn its surrounding defeated enemies or microchips.
- Kill a guard, activate a station, then die: reload with his body lying as a static corpse and his blood pool dry, and the guard does not return.
- Kill a guard after the last station, then die: he is alive again at his post, with no body or pool left.
- Take the level's keycard, then die before the next station: the card returns to its pickup point and the exit door stays locked.
- Take the keycard, activate a station, then die: keep the card and do not spawn a second one.
- Defeat a level 3, 6 or 9 mini-boss, then die before collecting the released keycard: return to the post-defeat story checkpoint with the boss still defeated and the card available again.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
