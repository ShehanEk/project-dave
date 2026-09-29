# DEAD EDEN — Factions, targeting, and friendly fire

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** W01  
**Status:** Working design proposal. The premise, Adam, Dave Harlan and microchips are confirmed (C14, C17–C19), and so are human enemies, lethal combat and the Thornwall contractor (C25, C28, C31). New names, details and numbers are *proposed* and untested.  
**Purpose:** defines the factions, who is hostile to Dave, protected people, and the limits on enemy-on-enemy damage (no infection or conversion).

**Decision references:** C14, C16, C17, C25, C28, C30, C31, P12, P17, P23 — see the [decision register](../decisions.md).  
**Read with:** [status and enemy states](status-and-enemy-states.md) · [objects and hazards](objects-and-hazards.md) · [encounter and boss fairness](encounter-and-boss-fairness.md) · [dead eden concept](../../dead-eden-concept.md)

## The factions
Every hostile belongs to one of six factions. In play they are one side: the board wants Dave stopped, Adam wants him contained, and their forces share the same target, so no encounter has factions fighting each other.

| Faction | Who (first level) | What they are |
| --- | --- | --- |
| **Arcadia Security** | Night Guard (L1), Sidearm Guard (L2), Riot Officer and Rifleman (L3, the Response Team) | Humans: campus contract guards who now follow the board's orders. Scared and angry, armed with batons, shields, pistols and rifles. After L1 the PA authorizes lethal force. Night Guards handle the Act 1 Hounds. |
| **Thornwall** | Rifleman (L4), Heavy Gunner and Grenadier (L5), Marksman (L6), Gun Hound (L5) | Humans and their K9: a private military contractor already on retainer, guarding the defense servers in the Rootworks. The board changed its orders from "guard" to "sanitize", so it arrives the same night with rifles, machine guns, rail rifles and frags. Cold and professional. |
| **Adam's machines** | Patrol Rover (L1), Security Drone (L2), Sentry Turret and Freight Loader (L4), Sanitizer and Orderly (L7), Keeper Drone (L8), and the Garden-built Pruner and Fitting Arm (L10) | Machines still doing Arcadia's security, freight and clinic jobs, now on Adam's instructions. Garden-built variants of the Rover, Drone and Loader appear in L10–L12. |
| **The Linked** | Staffer (L1), Linked Lineman (L6), Linked Nurse (L7), Linked Trooper (L8) | People whose Link implants Adam drives. They speak Adam's words in their own voices. Troopers are captured Thornwall contractors. The Linked never block progress. |
| **Cyborg dogs** | Hound (L2), Gun Hound (L5) | Debarked dogs with a steel jaw, a lens eye and a cable where the tail was. Hounds are Arcadia K9 beside a Night Guard handler in Act 1, Adam-driven with no handler in L7–L8, and Garden-built in L11. The Gun Hound is Thornwall's, with a back-mounted rifle. |
| **The Heirs** | Fitted Heir (L10), Warden (L11) | Adam's synthetic people, built in the Garden from staff minds copied in the Memory Orchard. |

Mini-bosses belong to the faction of their body: the Peacekeeper (Arcadia's driverless crowd-control truck) and the Surgeon are Adam's machines, Howard Stroud is Linked, and the Sower is Adam's Garden-built machine.

## Lore boundary
Arcadia Security and Thornwall are human and follow orders, not Adam. Thornwall arrives when the board turns "guard" into "sanitize"; Adam Links the contractors it catches and arms them with its own plasma (the Linked Troopers). Adam's machines are still doing their old campus jobs on Adam's instructions. The Linked are Arcadia staff, security agents and captured contractors whose Link implants Adam drives; they are people, and they die like people (C28). The Heirs appear from L10. Arcadia's executives and security command are human and belong to the story, not to the fight.

Nothing spreads. There is no infection and no conversion. Adam drives a person's body only through a Link implant, and that control never passes from one body to another by touch, a bullet impact, a shockwave or a broadcast. Linking is an authored story event at a fitting station (the L10 Thornwall beat in [N01](../05-presentation/story-scenes.md)), never a combat mechanic: nothing Links anyone during play. Machines are Adam's from the start, so there is nothing to convert. Dave has no implant (see [hero](../02-characters/hero.md)), so no enemy, event or announcement takes control of Dave's movement, aim or weapon.

Adam's reach is authored. In its lockdown events (*proposed*, P20) it seals doors, kills lights and reroutes machines on a script (see [objects and hazards](objects-and-hazards.md)). Rerouting activates or redirects an authored encounter group; it never changes a unit's type, faction or attacks.

## Proposed targeting rules
All combat targets must be authored as hostile or protected. Visual type alone is not enough: a harmless Sleepwalker, a held staff member and the founder are protected people, however they move or look, and they have no hit zone at all.

| Actor | Attacks Dave | Attacks other enemies | Attacks protected people |
| --- | --- | --- | --- |
| Any hostile (Arcadia Security, Thornwall, Adam's machines, the Linked, dogs, Heirs) | Yes, once its authored encounter activates | Never, except a declared crossfire hazard (below) | Never; protected people have no hit zone, so nothing can hit them |
| Dave (hero) | Self-splash only where specified | Yes: every hostile can be damaged and killed, and shield and armor rules follow [W02](status-and-enemy-states.md) | Never; shots and splash pass through them, and they cannot be harmed or captured |

Arcadia's human executives and security command are *story-only*. They appear on screens, in recordings and in scenes, and are never targets. They have no combat behavior, hit volume or target highlight, no executive stands in the play lane where it could be mistaken for a protected character, and no encounter includes them. Thornwall's L10 arrival is a scene that is seen, not fought. Contractors whom Adam has already Linked are Linked Troopers and follow the ordinary rules.

Do not create a whole-world autonomous faction simulation. Enemy attacks hurt Dave and flagged environmental objects, not other enemies. This keeps authored openings predictable and prevents an unseen fight clearing the next room.

*Proposed:* an encounter brief may declare a specific enemy hazard as **crossfire**, such as a Grenadier's frag burst or a Sanitizer's jet, and list which enemies it can damage. That would let Dave bait a group into its own area attack. Crossfire applies only inside the declared encounter and in view of the play lane. It never reaches protected people. No encounter uses it yet.

## Projectile ownership
Dave's direct shots and arcs damage valid hostile targets and marked breakables. They cannot target protected people. Arc chains choose visible valid targets; they never jump through walls or use harmless Sleepwalkers, held staff or the founder as conductive stepping stones.

Dave's Seedlobber explosions can hurt Dave, hostile targets and designated breakables; they never harm protected people. The same rule covers the Impact Pulse of a thrown target and the Arc Welder's Capacitor Burst.

Enemy rounds, bolts, beams and bursts hurt Dave and flagged environmental objects only. Enemy shots pass through other enemies, so a Rifleman fires past a Riot Officer, whose shield blocks only Dave's shots. Encounters keep protected people out of every fire line, so no shot is ever authored to cross one.

All damaging sources carry an obvious owner and warning. A hostile prop or captured enemy becomes hero-owned when deliberately thrown by the tether, but protected-target immunity remains.

## No repair, revival or conversion
Nothing heals, repairs or revives an enemy during a fight *(proposed)*. The earlier roster's repair units, which healed or reactivated other enemies, are cut, and a boss phase change is authored scheduling, not healing. A dead enemy stays dead: its body is scenery, and no enemy can revive, capture or reuse it. Nothing changes a unit's type, faction, attacks or controller, and no generic repair or takeover animation ever touches Dave.

## Protected-character contract
The protected people are the founder (the First Patient, L11), the staff held in the clinic (L7–L9) and the harmless Sleepwalkers, a protected NPC type that is no longer an enemy. They have no hit zone. Shots, arcs and blasts pass through them, so nothing can damage, bloody, capture or target them, and a pass-through gives no hit confirmation or spark.

Harmless Sleepwalkers have a relaxed posture, a dim, steady teal Link light (never amber or red), no attack and no hostile targeting highlight. They never turn hostile, so a misread silhouette cannot cost the player anything, and posture, light and sound tell them apart from the Linked, never color alone.

The held staff are never mandatory targets, never enemies and never props. Their bays, monitors and support equipment are not destructible combat targets, and neither is the founder's support cradle. The founder cannot be attacked, harvested, captured or used as a boss. Nothing Dave does in L11 harms her, and no enemy is authored to target her.

## Review examples
A Rifleman fires past a Riot Officer: the rounds pass through him, and only Dave's bolts are blocked by the shield. A Linked Trooper's plasma burst lands beside a Thornwall Rifleman: no damage to the Rifleman. A Grenadier's frag lands near a held staff member: nothing happens, and the encounter never placed staff in a fire line. A hero explosion near the founder: no health change. A harmless Sleepwalker among hostiles: it has no hit zone and stays harmless. A lockdown event reroutes a machine group: only the authored group activates, and nothing is converted. A corpse in the lane: no contact damage, no capture, no revival. An executive on a screen: no target highlight, hit volume or collision.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
