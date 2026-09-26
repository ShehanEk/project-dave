# DEAD EDEN — One carried weapon and world pickups

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Document ID:** G03  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** The precise ground-swap interaction, weapon state, boundaries, and save behavior.

**Decision references:** C04, C05, C06, P03, P08 — see the [decision register](../decisions.md).  
**Read with:** [ammunition and resupply](../03-progression/ammunition-and-resupply.md) · [upgrades and ownership](../03-progression/upgrades-and-ownership.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md)

## Confirmed rule

The hero carries one weapon. Taking a new weapon drops the previous one at the location where the new weapon was found. There is no backup pistol, hidden inventory wheel, checkpoint armory, or separate always-carried tether.

The five-type roster is not a five-slot inventory. Introduced weapon lists describe what the campaign has shown, not what the player can instantly select.

## Proposed swap interaction

Approaching a grounded weapon shows its name, type, current resources, and upgrade stage. A deliberate interact action opens a compact comparison against the held weapon. Confirming completes one exchange: one weapon becomes held and the previously held weapon occupies the pickup position.

Use a short confirmation or hold option to prevent accidental changes; allow an accessibility setting for the preferred method. Declining leaves both states unchanged. Swapping back is possible while the spot remains accessible.

## Weapon identity and resources

Each physical weapon has its own identity and current resource state. Loaded rounds, reserve rounds, and heat belong to that object. A swap does not refill ammo, zero heat, create duplicate projectiles, or produce a second copy.

The proposed upgrade ledger records purchased stages by weapon type. This is progression data, not stored weapons. When a matching weapon is physically picked up, the companion applies its earned fittings. No free rounds are created by a larger magazine. See the ownership document for the exact proposal.

## Ground safety

Author pickup positions on stable surfaces. A dropped weapon stays at that pickup anchor rather than tumbling into a pit. Use stable ground for authored pickup pads; do not place a swap on a moving conveyor, temporary platform, or geometry that disappears permanently.

A throw, enemy blast, or decorative debris effect must not silently delete a grounded weapon. Give drops a readable outline and avoid overlapping them with a dense gem pile.

## Timing and combat

A swap is an intentional choice, not an instant two-gun combo. The player must reach the physical pickup location. No required encounter relies on firing one gun, immediately swapping, and using another effect.

A tether-held object must be released before swapping. Live Seedlobber pods continue their existing fuse if the player swaps away nearby; swapping does not generate another pod or reset time. Such incidental combinations are possible only through world positioning and are never required.

## Checkpoints and one-way exits

A checkpoint snapshot records the held weapon and relevant grounded weapons. Death restores that snapshot, reversing uncommitted swaps after it. This prevents multiple copies while keeping the current area's rules understandable.

Before a one-way exit, make the departing weapon choice visible. Weapons left behind do not teleport to the next checkpoint. New weapon introductions offer a safe trial before the exit.

**Proposed campaign default:** no chapter replay inventory or warehouse in the first design. Later checkpoints may contain authored replacement pickups from types already introduced; choosing one is still a ground swap. They are not menus that summon any weapon.

## Required examples

1. Pistol held, shotgun on rack: take shotgun; pistol now occupies rack anchor.
2. Swap back without leaving: same two objects, unchanged ammunition.
3. Buy a shotgun capacity stage at a checkpoint: capacity grows, current rounds do not.
4. Die after a later swap: restore the checkpoint's held weapon and pickup map.
5. Enter a boss with tether: encounter supplies throwable objects; no pistol is added.

## Not yet final

Interaction duration, pickup highlight distance, number and placement of replacement pickups, and chapter-replay behavior remain tuning or future-scope decisions.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
