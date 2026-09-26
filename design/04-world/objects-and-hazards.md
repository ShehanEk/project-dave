# DEAD EDEN — Environmental objects and hazards

**Document ID:** W03  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** An object catalog describing appearance, allowed interactions, reset behavior, and route safeguards.

**Decision references:** C03, C04, C05, P13 — see the [decision register](../decisions.md).  
**Read with:** [player controls](../01-core/player-controls.md) · [weapon swaps](../01-core/weapon-swaps.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md) · [ammunition and resupply](../03-progression/ammunition-and-resupply.md)

## Authoring rule
Every interactive object has one primary purpose, a consistent silhouette, and a clear distinction from background decoration. Its level placement specifies an ID, initial state, legal interactions, result, reset rule, and whether it affects the main route.

This is a **concept catalog**, not an engine component list. Exact dimensions follow later movement tests. "Interact" is a named action with remappable input, not a hard-coded keyboard key.

| ID / object | Look and player action | Result and state rule |
| --- | --- | --- |
| O01 Recovery station | Cream standing service arch, broad safe floor, open circular lamp; Interact | Heal/service held weapon and commit. Safe/ready/servicing states; never a gun rack. |
| O02 Maintenance bench | O01 plus folding mint worktop and three fitting sockets | Upgrade held type; same service and save rules. No stored arsenal. |
| O03 Weapon pickup pad | Low outlined cradle holding exactly one physical weapon | Deliberate compare/swap. Previous gun occupies this same safe point with its resources intact. |
| O04 Gem / cache | Angular crystals or cream sealed reward case | Contact collects loose gems; Interact opens case. Unique collected state follows checkpoint rollback. |
| O05 Artifact display | Amber-lit square plinth with unique object | Interact records artifact; optional journal. No mandatory key role. |
| O06 Care supply | Cross-shaped cream case with pink center | Contact heals only if needed; unique consumed state. |
| O07 Feed cartridge | Blue square dual-socket cartridge | Contact refills compatible held finite-ammo weapon; stays if no useful capacity. |
| O08 Service dispenser | Wall machine with cartridge pictogram and visible refill wheel | Renewable arena ammunition; timed dispensing, no gem reward; cannot be disabled. |
| O09 Throwable supply pad | Low maintenance chute beside two marked canister recesses | Supplies renewable light props; never spawns underneath the hero or on an attack mark. |
| O10 Loose throwable | Rounded cream canister with dark grip band, or marked light crate | Tether capture/throw; impact damages a valid hostile target. No ordinary hero pocket storage. |
| O11 Fragile crate | Thin timber/ceramic slats with an obvious split seam | Any weapon attack or thrown prop breaks it; preassigned contents only. Empty breakables stay empty. |
| O12 Switch / route door | Oversized lever paired with matching symbol on door | Interact toggles or opens; mandatory switches remain reachable with normal movement. Clear latched state. |
| O13 Timed gate | Paired clock-shaped switch and visible countdown segments | Opens temporarily; safe retreat and repeatable trigger. Never closes on or traps the hero. |
| O14 Moving platform / lift | Broad bright top edge, visible guide or support | Carries the hero; no hidden depth change. Return cycle always permits recovery from a missed boarding. |
| O15 Conveyor | Large direction chevrons and turning end rollers | Adds ground motion; jump remains available. Start/stop state visible before stepping on. |
| O16 Thin drop-through platform | Narrow grated deck with downward notch | Down + Jump drops through; distinguish from solid floors. No ordinary fall through on landing. |
| O17 Tether anchor | Violet three-notch ring fixed to sturdy support | Pull only while tether is held; optional shortcut, not a main-route movement unlock. |
| O18 Laser / heat sweep | Visible emitter, traced warning lane, then active beam | Timed damage; safe cycle or ordinary switch bypass. Background light beams cannot secretly damage. |
| O19 Hazard floor / pit | Clearly bounded spill, spikes, thorns, or open drop with visible edge | Hazard damages through common rules; pit returns to a safe foothold unless health reaches zero. |
| O20 Boss repair node | Arena-specific cream pedestal with an exposed connected socket | Attack the active socket with any valid weapon/throw; interrupts linked repair. No tether-only pull. |
| O21 Story console | Broad open screen and hand-height control | Interact advances named story state. Indestructible; never demands a special carried weapon. |
| O22 Soft soil patch | Loose dark earth, stones moving before emergence | Burrower path only where authored; ripple warns before attack. Cannot extend under every platform. |

## General interaction boundaries
A main-route crate or door cannot require burning, electrical damage, heavy capture, or a paid weapon stage. Flavor reactions may vary by weapon, but their required outcome remains available with every legitimate carried weapon. If the tether is possible, a nearby reachable throwable can hit the mandatory breakable.

Only marked loose props can be grabbed. Anchored scenery, support beams, survivor equipment, decorative gems, and background robots are not physics ammunition. If an object can be moved, its grip band and slight rest motion distinguish it.

Switches usually open doors and start machinery; they are not hidden pressure plates unless explicitly briefed. A timed switch must allow the return journey needed to retry. A heavy loose prop cannot be the only object keeping an irreversible route open.

Moving platforms never crush the hero without a warning and escapable lane. If a lift would pin the hero, it pauses or returns. Use designated attack hazards for danger, not arbitrary simulation accidents.

## Swap-point safety
Place weapon pickups on stable ground away from pits, moving conveyors, projectile lanes, and closing doors. The dropped gun stays in that exact authored pickup area. Use a retaining cradle if necessary; do not solve a bad placement by silently teleporting the previous weapon across the room.

Offer a practice lane and a reversible path before a one-way exit. The hero can take the new weapon, test its basic behavior, return, and swap back. Trial targets are non-treasure props and supplies follow the same refill rules as elsewhere.

## Persistence classes
**Committed collectibles:** gems, artifacts, finite care supplies, and cartridges track consumed state in the checkpoint snapshot. **Progress objects:** latched doors, completed consoles, and encounter gates track completion. **Transient cycles:** lasers, lifts, conveyors, clouds and dispenser timers restart in a defined safe phase after retry.

**Physical weapon instances** follow the separate swap/snapshot rules. **Renewable props** reset their pad occupancy and cannot duplicate while one remains held. Resetting transient objects must not reopen a completed route in a way that strands the player.

## Level kit guidance
Sunnyvale disguises machines as gardening and parade equipment. Rootworks exposes pipes, pumps, compost and cargo. Medical levels use treatment rails, consent screens and records. Returned areas show physical tissue interfaces attached to existing designs.

Reuse object functions across these kits. A garden dispenser and a hospital dispenser may look different, but the same pictogram and interaction mean the same result.

## Readability review
Show the scene without HUD: can a player find footing, the next switch, a weapon swap, safe supplies, and the hazard boundary? Then show it in grayscale and with reduced effects. If a needed object becomes indistinguishable, revise its shape and placement before adding more text prompts.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
