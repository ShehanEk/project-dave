# DEAD EDEN — Environmental objects and hazards

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** W03  
**Status:** Working design proposal. The premise, Adam, Dave Harlan and microchips are confirmed (C14, C17–C19), and so are lethal combat and visible blood (C28, C29). New names, details and numbers are *proposed* and untested.  
**Purpose:** an object catalog covering appearance, allowed interactions, reset behavior, keycard doors, lockdown objects, the low and high cover kit and route safeguards, with dark-scene readability rules.

**Decision references:** C04, C05, C16, C19, C28, C29, P13, P19, P20, P21, P23 — see the [decision register](../decisions.md).  
**Read with:** [player controls](../01-core/player-controls.md) · [weapon swaps](../01-core/weapon-swaps.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md) · [ammunition and resupply](../03-progression/ammunition-and-resupply.md)

## Authoring rule
Every interactive object has one primary purpose, a consistent silhouette, and a clear distinction from background decoration. Its level placement specifies an ID, initial state, legal interactions, result, reset rule, and whether it affects the main route.

This is a **concept catalog**, not an engine component list. Exact dimensions follow later movement tests. "Interact" is a named action with remappable input, not a hard-coded keyboard key. Every look below is *proposed* and uses the [style guide](../../art-design/style-guide.md) palette; see the dark-scene rules further down.

| ID / object | Look and player action | Result and state rule |
| --- | --- | --- |
| O01 Recovery station | Steel standing service arch, broad safe floor, open circular lamp with a cold-white light pool and a small teal Arcadia mark; Interact | Heal/service held weapon and commit. Safe/ready/servicing states; never a gun rack. Its lamp stays lit through every lockdown event. |
| O02 Workbench *(proposed name)* | O01 plus a folding steel worktop and three chip sockets where microchips are re-flashed into the held weapon | Upgrade held type; same service and save rules. No stored arsenal. |
| O03 Weapon pickup pad | Low outlined cradle holding exactly one physical weapon, with its own small floor lamp so the weapon reads in the dark | Deliberate compare/swap. Previous gun occupies this same safe point with its resources intact. |
| O04 Microchip / chip cache | Loose microchips: square chips with gold contacts (#FFD166) and a small glint; a cluster is three chips on a tray. A chip cache is a dark steel component case with an angular gold seal and a rim-lit latch | Contact collects loose microchips; Interact opens a cache. Values follow [S03](../03-progression/treasure-economy.md). Unique collected state follows checkpoint rollback. |
| O05 Evidence file point *(proposed)* | A lit terminal, recorder dock, file drawer or tray holding one unique memo, photo, recording or log, with a steady pale rim light and a small square copy-port lamp (no gold, amber or red) so it can be found in the dark | Interact records the evidence file in the journal. Optional; no stat effect, no key role, never an ending gate. Look per [S05](../03-progression/evidence-files.md). |
| O06 Health supply | White medical cross-shaped case with a warm pink center and a rim light, in a small (med-patch) or large (med-kit) size per [S01](../03-progression/health-and-checkpoints.md) | Contact heals only if needed; unique consumed state. |
| O07 Feed cartridge | Blue square dual-socket cartridge with a small indicator light | Contact refills compatible held finite-ammo weapon; stays if no useful capacity. |
| O08 Service dispenser | Wall machine with cartridge pictogram, a lit dispensing slot and visible refill wheel | Renewable arena ammunition; timed dispensing, no microchip reward; cannot be disabled, including by a lockdown event. |
| O09 Throwable supply pad | Low freight chute beside two marked canister recesses, each lit from within | Supplies renewable light props; never spawns underneath Dave or on an attack mark. |
| O10 Loose throwable | Rounded matte-composite cargo canister with a lit grip stripe, or a marked light crate; it never resembles a frag grenade or a sterilant vial | Tether capture/throw; impact damages a valid hostile target. No ordinary hero pocket storage. Bloom canisters are never throwables. |
| O11 Fragile crate | Thin composite slats or a cracked cargo case with an obvious split seam and a faint rim light | Any weapon attack or thrown prop breaks it; preassigned contents only. Empty breakables stay empty. |
| O12 Switch / route door | Oversized lever or wall button with a lit ring, paired with a matching symbol on the door | Interact toggles or opens; mandatory switches remain reachable with normal movement. Clear latched state: amber ring and bar symbol while unlatched, teal ring and chevron once latched. |
| O13 Timed gate | Paired clock-face switch and visible countdown segments, a lit row along the gate edge that goes dark one segment at a time | Opens temporarily; safe retreat and repeatable trigger. Never closes on or traps Dave. |
| O14 Moving platform / lift | Broad bright top edge, visible guide or support, and a light at every stop. Includes pump-driven floor sections in the cooling station | Carries Dave; no hidden depth change. Return cycle always permits recovery from a missed boarding. |
| O15 Conveyor | Large lit direction chevrons and turning end rollers; server racks may ride it | Adds ground motion; jump remains available. Start/stop state visible before stepping on. |
| O16 Thin drop-through platform | Narrow grated deck with downward notch and a lit edge | Down + Jump drops through; distinguish from solid floors. No ordinary fall through on landing. |
| O17 Tether anchor | Azure-white three-notch ring fixed to sturdy support, matching the tether's azure field light (never violet, which is reserved for the Bloom, and never teal, which means Arcadia and Adam at rest) | Pull only while tether is held; optional shortcut, not a main-route movement unlock. |
| O18 Security laser / steam-vent sweep | Visible emitter or vent, traced amber warning lane, then the red active beam or jet | Timed damage; safe cycle or ordinary switch bypass. It runs a fixed cycle and never tracks Dave (the sight lines of the rail rifle and cutter beam belong to those weapons). Background light beams, searchlights and camera sweeps cannot secretly damage, and never detect Dave (C16). |
| O19 Hazard floor / pit | Clearly bounded coolant spill, sparking conduit, spike strip or open drop, each with a bright visible edge line | Hazard damages through common rules; pit returns to a safe foothold unless health reaches zero. |
| O21 Story console | Broad open teal screen and hand-height control | Interact advances named story state. Indestructible; never demands a special carried weapon. Adam may speak through it. |
| O23 Keycard *(proposed)* | Card-shaped clearance pass, white with a teal Arcadia stripe and a slow teal glint, resting in a lit terminal slot, guard-post tray or arena console | Contact or Interact collects it and fills the HUD keycard indicator. One per level from L1 to L11; none in L12. Not inventory: it cannot be dropped, swapped or carried to another level. Follows checkpoint rollback. |
| O24 Keycard door *(proposed)* | Wide exit door with a card reader: amber ring and bar symbol while locked, teal ring and chevron once open | Interact with the level's card opens it for good. Without the card: a harmless "Keycard required" cue, no damage. It is the level's exit. |
| O25 Emergency shutter *(proposed)* | Heavy roll-down shutter with black-and-amber hazard stripes. Amber warning lamps and a lit countdown row come first; alarm red shows only while it moves, and a steady amber lamp remains once it is sealed | Closes only on a scripted lockdown event or an authored cycle, after the full warning. Never closes on or traps Dave; reopens on its cycle or when the event ends. |
| O26 Lockdown door *(proposed)* | Lit blast door: amber warning lamps first, alarm red only while it seals, then a steady amber ring while sealed and a teal ring once released | Sealed by Adam in a scripted lockdown event with a PA warning; opens when the event's authored condition is met. Never a hidden trap; always paired with an authored way forward. |
| O27 Server rack *(proposed)* | Tall steel rack with a blinking LED face. Three variants: dim background rack; solid cover or platform block with a lit top edge; conveyor cargo | Only solid racks collide or can be stood on. Background racks never damage and are never platforms. Moving racks never crush Dave (see moving platforms). |
| O28 Low cover *(proposed)* | A crate, planter box, barricade or console about 0.6 H tall (H is one hero height), with a lit top edge | Blocks every same-floor enemy round, because guns fire flat at 0.5 H (dogs 0.3 H). Dave can shoot over it and jump onto it. It is the answer to a rifle burst on his floor and the only answer to a machine gun on his floor. |
| O29 High cover *(proposed)* | A pillar at least 1.2 H tall (a concrete planter pillar, a steel column) or an overhang with at least 1.1 H of headroom beneath it (a steel instrument shelf, a catwalk), with a lit edge | The only cover against elevated guns (turrets, the Peacekeeper's roof gun, the cutter beam), and it also stops flat fire. Dave stands behind the pillar or under the overhang. |

The IDs O20 and O22 are retired with the behaviors they served (a boss repair node and a duct grate for a burrowing enemy, both cut) and are not reassigned.

## Cover kit (*proposed*, P23)
Dave has no crouch ([G02](../01-core/player-controls.md)), so cover is how he answers a gun he cannot jump. There are two kinds, and the numbers are written into the fairness rules in [W04](encounter-and-boss-fairness.md).
- **Low cover (O28):** 0.6 H, blocks all same-floor fire, and Dave can shoot over it.
- **High cover (O29):** a pillar at least 1.2 H tall or an overhang with at least 1.1 H of headroom. It is the only cover against elevated guns.
- **Placement:** every machine-gun, rail or beam spot has the right cover, or another floor, within 3 H. Cover is fixed scenery with a lit top edge and never blocks the only route. No gun lane has a pit edge within 1.5 H behind a spot where Dave is meant to stand, cover included. A corpse is not cover.

## Keycards and exit doors (*proposed*, P19)
Each level from L1 to L11 has one keycard and one keycard door, its exit. L12 has neither, because its ending happens at Adam's core.

The card sits on the main route or is clearly signposted: a terminal, a guarded room, or (on L3, L6 and L9) the mini-boss's arena console, which grants the card after the fight. The defeat commits at once (see [S01](../03-progression/health-and-checkpoints.md)), so a later death never repeats the boss to earn the card. Dave sees the locked door and the empty keycard indicator early, so the goal is legible before the search begins.

Reaching the card needs only baseline movement and any legitimately carried weapon: no tether-only route, no burning or electrical requirement, no paid upgrade stage and no puzzle chain. Never place a card behind an optional branch, a purchase or an evidence-file alcove, and no card is needed to reach another card. The card is an exit lock, not an item hunt. It is not carried between levels and never occupies the weapon slot. A card collected after the last checkpoint returns to its pickup on retry, a committed card stays collected, and using it latches the door open for the next save.

## Lockdown and security objects (*proposed*, P20)
Adam's lockdown events are scripted, telegraphed changes: doors and shutters seal, lights die, machines reroute, platforms move and a pleasant PA announcement plays. They are authored beats, not a reactive system.
- **Telegraph first:** every change follows the order in [G04](../01-core/camera-and-feedback.md): a calm, captioned PA line, amber warning lamps with a sound, a slow lit preview, and alarm red only while the change is happening. No single channel is the only cue. The warning lasts at least as long as a heavy attack's (about 0.6–1.0 seconds, see [W02](status-and-enemy-states.md)), and about 2 seconds (proposed, untested) for anything that changes footing or could trap Dave.
- **Never a trap:** nothing moves under a landing Dave is standing on. A shutter or lockdown door never closes on Dave, never seals Dave into a space with no way forward, and never removes a recovery station, dispenser, throwable pad or the only route back. A sealed space always has an authored exit: a reachable switch, a timed release or the event's end.
- **Safe phases:** lockdown sequences restart from their telegraph after a retry, and never begin in the middle of an attack.
- **Not detection (C16):** cameras, searchlights, scanner beams and holographic billboards are set dressing or telegraphs. They never detect Dave, raise an alert, change enemy behavior or damage anything.

## Dark-scene readability rules (*proposed*, following P21)
Levels are dark by design, so objects supply their own light. Darkness is a mood, never a place to hide a hazard.
- Every interactive object and hazard has its own light: a lit edge, lamp, screen or LED, so its silhouette and state read without ambient light. Put a light near every landing and on every platform top edge.
- Hazard boundaries use a bright, hard-edged line: amber for a warning lane, red once the hazard is active. The line stays visible in mist, fog and dark water, and at the Dimmer brightness setting.
- State changes combine light, shape and sound: the switch ring changes from amber with a bar to teal with a chevron, and the sound changes too. Color is never the only cue.
- Lights that mark a landing, platform edge or hazard boundary stay steady. Only decorative fixtures flicker, and a fixture's glow may flicker while its lit edge does not.
- Reserved colors keep one meaning: red is danger now (tells, active beams, and a lockdown change while it is moving), amber is a warning or Adam's attention, teal is Arcadia and Adam at rest, violet is the Bloom and nothing else, gold is pickups, and azure-white is the Graviton Tether's field and anchor markers. Nothing Dave can pick up, grab or use is violet.
- Background LED walls, billboards and status lights blink on slow, independent cycles and never use alarm red or pickup gold, so they cannot pass for a tell or a pickup.
- Fog, mist and glow are flat, low-contrast drawn bands. They never cover a platform edge, tell, weak point or pickup.
- Blood, oil and lymph, and the bodies they pool under, lie on the floor line below every object here. They never cover a landing edge, a hazard boundary or a pickup ([W02](status-and-enemy-states.md), [G04](../01-core/camera-and-feedback.md)).
- Strobes and alarm lights (red emergency strobes, lockdown alarms, holographic billboards, electrical flashes) follow the reduced-flash rules in [G04](../01-core/camera-and-feedback.md) (no more than three flashes in any one second, nothing across the full screen) and the reduced-flash setting in [N03](../05-presentation/interface-and-accessibility.md). With reduced flash on, they become a steady or slow pulse and the hazard boundary stays drawn.

## General interaction boundaries
A main-route crate or door cannot require burning, electrical damage, heavy capture, or a paid weapon stage. Flavor reactions may vary by weapon, but their required outcome remains available with every legitimate carried weapon. If the tether is possible, a nearby reachable throwable can hit the mandatory breakable. A keycard door needs only its level's card.

Only marked loose props can be grabbed. Anchored scenery, support beams, clinic bays and the founder's cradle, decorative microchips, background machines, corpses and their dropped guns, and Bloom canisters are not physics ammunition. If an object can be moved, its grip band and slight rest motion distinguish it.

Switches usually open doors and start machinery; they are not hidden pressure plates unless explicitly briefed. A timed switch must allow the return journey needed to retry. A heavy loose prop cannot be the only object keeping an irreversible route open.

Moving platforms, emergency shutters and lockdown doors never crush Dave without a warning and escapable lane. If a lift or door would pin Dave, it pauses or returns. Use designated attack hazards for danger, not arbitrary simulation accidents.

## Swap-point safety
Place weapon pickups on stable ground away from pits, moving conveyors, projectile lanes, closing doors, shutters and lockdown paths. The dropped gun stays in that exact authored pickup area. Use a retaining cradle if necessary; do not solve a bad placement by silently teleporting the previous weapon across the room.

Offer a practice lane and a reversible path before a one-way exit, which is the keycard door. Dave can take the new weapon, test its basic behavior, return, and swap back. Trial targets are non-treasure props and supplies follow the same refill rules as elsewhere.

## Persistence classes
**Committed collectibles:** microchips, evidence files, finite health supplies, cartridges and the level's keycard track consumed state in the checkpoint snapshot. **Progress objects:** latched doors (including the keycard door), completed consoles, and encounter gates track completion. **Transient cycles:** lasers, lifts, conveyors, shutters, hazard fields and dispenser timers restart in a defined safe phase after retry.

**Bodies and blood:** the corpses of committed kills are restored as static bodies with dry pools, and sprays and ragdoll motion are never persisted; pools appear only on static floors, at most 24 per area ([W02](status-and-enemy-states.md)). **Physical weapon instances** follow the separate swap/snapshot rules. **Renewable props** reset their pad occupancy and cannot duplicate while one remains held. A lockdown event that permanently changed the route is saved as route state (see [S01](../03-progression/health-and-checkpoints.md)), and one interrupted by a retry restarts from its telegraph. Resetting transient objects must not reopen a completed route in a way that strands the player.

## Level kit guidance
The campus (L1–L3) mixes security and showcase machinery with garden dressing under night lighting: path lamps, glowing Arcadia signage, planters that double as cover and hide service hatches, and exhibit plinths. The Rootworks (L4–L6) exposes server racks, cable bundles, coolant pipes, pumps, freight equipment and test-chamber glass, lit by LED walls and red emergency strobes. The Wellness Center (L7–L9) uses treatment rails, consent screens, surgical lamps and staff records under emergency power and green exit signs. The Garden (L10–L12) shows assembly lines, Heir fitting stations and violet Bloom canisters among bioluminescent plants.

Reuse object functions across these kits. A campus dispenser and a clinic dispenser may look different, but the same pictogram and interaction mean the same result. Cover follows the same heights in every kit: planter boxes and pillars on the campus, freight crates and rack blocks in the Rootworks, steel shelves and instrument carts in the clinic, and assembly-line housings in the Garden.

## Readability review
Show the scene without HUD: can a player find footing, the next switch, a weapon swap, safe supplies, the keycard and its door, and the hazard boundary? Then show it in grayscale, at the Dimmer brightness setting, with high-contrast outlines on and off, and with reduced effects and reduced flash, and with Blood on and off. If a needed object becomes indistinguishable, revise its shape, light and placement before adding more text prompts.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
