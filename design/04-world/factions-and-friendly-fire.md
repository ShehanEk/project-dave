# DEAD EDEN — Factions, targeting, and friendly fire

**Document ID:** W01  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines hostility, protected characters, mechanical repair, and the physical limits of Returned conversion.

**Decision references:** E01, E02, P12 — see the [decision register](../decisions.md).  
**Read with:** [status and enemy states](status-and-enemy-states.md) · [objects and hazards](objects-and-hazards.md) · [dead eden concept](../../dead-eden-concept.md)

## Lore boundary
EDEN's ordinary robots are mechanical caretakers obeying dangerous instructions. Zombies are failed biological resurrection patients. The Returned combine recovered human memories, living neural tissue, and machines with **compatible installed neural interfaces**.

Ordinary robots cannot catch a biological infection. A Returned conversion requires physical tissue installation into a prepared interface; it does not travel over Wi-Fi, through a speech broadcast, or through a normal bullet impact. The L10 converted Patchbot is a specific prepared host, not proof that every robot can transform.

## Proposed targeting rules
All combat targets must be authored as hostile or protected. Visual species alone is not enough: a peaceful Rememberer and the First Patient are protected people.

| Actor | Hero | Ordinary robots | Hostile zombies | Returned | Protected people / PIP |
| --- | --- | --- | --- | --- | --- |
| Ordinary robot | Pursues when encounter activates | Never intentionally attacks | Contains only in authored mixed encounters | Recognizes authorized Returned as allies | No damaging gameplay target |
| Hostile zombie | Primary pursuit target | Retaliates against an active containment attacker | No intentional attack | Retaliates if physically attacked | No damaging gameplay target |
| Returned | Primary pursuit target | Treats as allies; grafts only prepared hosts | Does not seek as a default target | No intentional attack | No damaging gameplay target |
| Hero | Self-splash only where specified | Can damage hostile units | Can damage hostile individuals | Can damage hostile units | Shots and splash cannot harm or capture |
| PIP | Supports through information | No combat action | No combat action | No combat action | Noncombat companion |

Do not create a whole-world autonomous faction simulation. A mixed encounter declares participants and allowed cross-faction damage. Outside those encounters, incidental enemy attacks do not damage other enemies. This keeps authored openings predictable and prevents an unseen fight clearing the next room.

Within an authored containment encounter, the participating robot and zombie attacks can damage each other. The hero may watch, bypass, or intervene. Cross-faction kills do not spawn extra currency; any reward is the room's fixed cache.

## Projectile ownership
The hero's direct shots and arcs damage valid hostile targets and marked breakables. They cannot target PIP or protected people. Arc chains choose visible valid targets; do not jump through walls or use peaceful characters as conductive stepping stones.

Hero Seedlobber explosions can hurt the hero, hostile targets, and designated breakables; they never harm protected characters. Enemy attacks hurt the hero and flagged environmental objects. Only the mixed-encounter rule permits enemy-on-enemy damage.

All damaging sources carry an obvious owner and warning. A reflected or thrown hostile prop becomes hero-owned when deliberately thrown by the tether, but protected-target immunity remains.

## Repair is not resurrection infection
Patchbots repair mechanical allies through a visible tool connection. Proposed cap: each ordinary mechanical unit can be reactivated once per checkpoint attempt, at partial health. A reactivated unit gives no second treasure reward. Destroying or interrupting the support stops the current repair.

A Care Marshal barrier is external protection, not extra biological health. Destroying its three readable emitters removes the corresponding protections. Ordinary Patchbots do not heal zombies or neural tissue.

A Mourning Nurse can repair Returned tissue through a physical graft. A normal combat graft may restore limited health, but conversion of a prepared robot is a separate authored action with a visible interface. Never convert a dead boss, an arbitrary scenery machine, or the hero through a generic heal animation.

Cap all repeatable repairs. Boss-specific repair caps belong to their encounter briefs; healing cannot erase progress forever.

## Protected-character contract
Peaceful Rememberers have relaxed posture and no hostile targeting highlight. They stay peaceful when shot; they do not unexpectedly become enemies because the player misread a silhouette. Give a harmless blocked interaction cue rather than a hit confirmation.

The First Patient cannot be attacked, harvested, captured, or used as a boss. PIP cannot be used as a shield, tether projectile, ammunition source, or revive machine. Survivor spaces and final life-support systems are not destructible combat targets.

## Review examples
A zombie scratches a Clipper: no spontaneous Returned form. A Mourning Nurse links to a robot with no neural cradle: no conversion. A hero explosion near the First Patient: no health change. A Patchbot reactivates a robot twice: the second attempt is disallowed. A peaceful Rememberer in a hostile group: protected status still wins.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
