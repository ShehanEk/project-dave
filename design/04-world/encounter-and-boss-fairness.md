# DEAD EDEN — Encounter planning and boss fairness

**Document ID:** W04  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines escalating encounter composition and checks every boss against the available single weapons.

**Decision references:** C04, C06, C07, E02, P13 — see the [decision register](../decisions.md).  
**Read with:** [status and enemy states](status-and-enemy-states.md) · [objects and hazards](objects-and-hazards.md) · [ammunition and resupply](../03-progression/ammunition-and-resupply.md) · [design guide](../../level-design/design-guide.md)

## The encounter promise
A mandatory encounter is beatable with **any weapon legitimately brought there, at base stage**, using baseline movement. No backup pistol, free tether, two-weapon combo, hidden respec, or optional artifact is assumed.

Weapon introductions remain L1 pistol, L2 shotgun, L4 Arc Welder, L5 Seedlobber, and L6 tether. "Introduced" means a type may have been encountered; it never means all introduced weapons are carried.

## Room pattern
1. **Preview:** show the arena, main hazard, safe footing, and supply points before activation.
2. **Teach or recall:** begin with one readable action or familiar enemy role.
3. **Combine:** add a complementary pressure, leaving at least one clear route of response.
4. **Recover:** let the player reach resources and exploit a meaningful opening.
5. **Release:** open the exit and fixed reward, then reach a checkpoint.

Suggested active pressure: L1–3 one main attack with at most one low-pressure support; L4–6 combine ranged and ground pressure; L7–9 add shield/repair choices; L10–12 mix Returned state changes with a familiar hazard. These are proposed pacing limits, not exact counts in every room.

Avoid multiple independent offscreen attackers. A support enemy can remain alive without constantly firing. A crowd may look large while only a few units commit to attacks. Keep new mechanics isolated before combining them.

## Boss escalation
| Level / boss | Main test | Later phase | Fairness constraint |
| --- | --- | --- | --- |
| L3 Mr. Mulch | Bait a charge into planters, reach rear motor | Two committed charges before recovery | Broad grounded route around the stopped mower; do not demand a dash or grapple |
| L6 Old Rootjaw | Read ground slams and seed arcs; hit open chest | One platform lowers and the rhythm tightens | Fixed refuge ledges remain; no required tether pull, burn or slow |
| L9 Matron Mercy | Interrupt active external station, then attack open chest | One support robot joins a scheduled attack | Three visible stations are attackable from ordinary platforms; capped repair |
| L12 Unfinished Choir | Identify Warden turn, Hunger landing, Caretaker repair | One lingering hazard, then moving central platforms | At most two simultaneous attack threats, fixed recovery ledges, no sixth weapon or extra EDEN fight |

Difficulty grows through decisions, timing, and combinations. Do not simply double health or remove all recovery windows. Every phase transition visibly changes posture, arena state, or scheduling.

## Single-weapon feasibility matrix
| Boss | Scrapjack | Boom Broom | Arc Welder | Seedlobber | Graviton Tether |
| --- | --- | --- | --- | --- | --- |
| Mr. Mulch | Fire into rear motor after collision | Reach rear flank and fire before restart | Not introduced | Not introduced | Not introduced |
| Old Rootjaw | Shoot chest from fixed ledge | Lower chest opening comes within safe spread range | Close ledge reaches chest without touching attack zone | Chest remains exposed through pod travel and fuse | Replenishable canisters can be thrown into exposed chest |
| Matron Mercy | Shoot active station, then chest | Each station and lowered chest have a safe close firing perch | Electrical damage works without an exclusive electrical puzzle | Station socket accepts an arcing pod and fuse; chest window supports another cycle | Throw at active station and then open chest; neither target requires capture |
| Unfinished Choir | Rear port, landing tissue, or repair socket | Grounded flanks reach each relevant opening | Safe ledges within beam range; no need to stand inside the boss | Predictable landing and repair openings allow pod arrival and detonation | Supply props reach rear/landing/repair targets; whole guardian stays immune |

The matrix states **requirements for refining arena geometry**, not a claim that a playable layout has already passed testing. If a platform, weak-point height, or exposure window fails its row, revise that detail.

## Boss supply and recovery
Each arena has renewable finite-ammunition service and, from L6 onward, renewable tether props. Keep supplies reachable throughout every phase. Fixed recovery ledges cannot vanish together. An empty shotgun must be able to regain ammunition without first damaging the boss.

A healing pickup can be finite; it cannot be the only way to survive an unavoidable attack. No boss attack is intended to be unavoidable. Preparation checkpoints fully service the carried weapon and provide an upgrade bench, while never requiring a purchase.

Interrupting Matron's station or the Choir's Caretaker node must work through ordinary damage. It cannot require electrical immunity, tissue-specific flame, or a tether-only action. A repair loop has a cap or a guaranteed recurring interruption window so a low-damage weapon can still make progress.

## Encounter review record
For each required room, record: available weapon types; movement needed; enemy roles and active-pressure limit; attack tells; recovery positions; finite-ammo access; tether prop source; close-range access; pod trajectory/fuse window; exit condition; retry boundary.

A side challenge may favor a specific equipped weapon only if it is clearly optional and its essential treasure has a baseline alternative under the artifact proposal. Keep most secrets discoverable through observation and platforming.

## Failure cases to reject
- A route across an anchor gap that traps a player carrying the shotgun.
- An arena gate that closes with an empty Seedlobber and no dispenser.
- A Care Marshal barrier hiding the only throwable supply forever.
- A boss weak point visible for less than a pod's travel plus fuse.
- A heavy target that only stage-2 tether capture can defeat.
- A hostile Rememberer mixed with an indistinguishable protected one.
- Several repair units restoring each other without a cap.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
