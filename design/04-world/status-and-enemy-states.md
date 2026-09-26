# DEAD EDEN — Enemy states, status effects, and capture rules

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Document ID:** W02  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Standardizes warnings, armor, interruptibility, status limits, and tether target classes.

**Decision references:** C04, E02, P12, P13 — see the [decision register](../decisions.md).  
**Read with:** [factions and friendly fire](factions-and-friendly-fire.md) · [encounter and boss fairness](encounter-and-boss-fairness.md) · [ammunition and resupply](../03-progression/ammunition-and-resupply.md) · [README](../../art-design/README.md)

## Shared encounter language
Use this behavioral sequence where appropriate: **idle → notice → prepare → act → recover → choose next action**. Patrol and support movement can branch before preparation. Defeat, stagger, and capture are explicit alternate states.

A dangerous action needs a visible preparation pose before damage begins. A starting target is about 0.6–1.0 seconds for a new heavy attack and 0.35–0.6 for familiar light attacks, adjusted for distance and camera framing. These numbers require testing. Quicker later attacks retain their identifying pose and sound.

Once an attack commits to a marked location, it does not track the hero invisibly. Pollinator dives, Sprinter bursts, Burrower emergence, and large boss slams all preserve a readable escape. A moving target mark may track during preparation, then visibly lock.

Being near an enemy is not automatically damaging. Damage comes from its defined strike, projectile, active charge, or hazard volume. Harmless recovering bodies do not cause repeated contact damage.

## Armor and weak points
Ordinary exposed body hits work unless a brief specifies armor. A heavy shield blocks frontal hits, including upgraded pistol bolts; light-armor penetration is not permission to ignore all defenses.

Blocked hits make a short ceramic or metal deflection cue. Successful weak-point hits use a sharper response and visible opening. Weak points are existing body parts with named exposure states, not arbitrary glowing circles added by each AI agent.

A boss opening lasts long enough to approach safely and land a base-weapon attack. Test Seedlobber travel plus fuse, not just instant pistol hits. Status damage cannot bypass a closed invulnerability state unless that exact state explicitly permits lingering damage.

## Proposed status rules
| Effect | Cause | Behavior | Limit / counter |
| --- | --- | --- | --- |
| Burn | Furnace Shells; selected burning surfaces | Short damage-over-time on valid targets; biological burn suppresses regeneration while active | Same effect refreshes duration, never stacks indefinitely; robots take heat damage without an infection implication |
| Slow | Nurse syringe on hero; Deep Roots on enemies | Reduced ground speed for about 2 seconds | Does not stack; preserve jump height and required escape range; boss path timing is not slowed |
| Electrical interruption | Arc attacks when a unit is in an interruptible state | Brief stumble or stopped support action | Not every tick stuns; roughly 2-second protection after an interruption; no permanent stun lock |
| Stagger | Heavy hit, clear environmental impact, or scripted missed charge | Brief recovery exposes an opening; can qualify a medium tether target | An attack marked committed may resist it; bosses use their authored exposure rather than generic stun |
| Knockback | Shotgun, impacts, select attacks | Short displacement respecting walls and protected zones | Heavy/anchored bodies resist; never push a mandatory target beyond reachable geometry |
| Hazard cloud | Puffer; localized treatment leaks | Damage while inside a visible cloud | Finite duration and a safe exit; not a permanent infection meter |

Poison progression, disease buildup, freezing, mind control, instant conversion, elemental crafting, and permanent injuries are outside this baseline. Do not infer them from an enemy's color or the resurrection theme.

The hero uses the common damage immunity window, so overlapping hazards cannot drain all six health units at once. Any hero slow expires or clears at a recovery checkpoint. A short status icon includes a shape and fading timer, not color alone.

## Proposed tether classes
These are gameplay eligibility proposals, not changes to the art proportions.

| Class | Examples | Base tether | Heavy Lifter stage 2 |
| --- | --- | --- | --- |
| Light loose object | Marked canister, loose small crate, approved debris | Capture | Capture |
| Small enemy | Clipper, Pollinator, Patchbot | Capture after the short lock, outside protected attack states | Same |
| Medium enemy | Courtesy Officer, Nurse Needles; Resident, Sprinter, Spitter, Clinger, Puffer, Howler, Burrower, hostile Rememberer; Hollow Officer, Mourning Nurse | Cannot capture | Capture only while visibly staggered and physically exposed |
| Rooted medium | Gardener | Cannot capture | Only after roots release and a visible stagger; no pulling through solid floor |
| Fixed or heavy | Bloom Sentry, Orderly, Sanitizer, Loadbearer, Care Marshal, Graftback, ordinary Choir Unit | Immune | Immune |
| Boss or protected | All four mini-bosses, First Patient, peaceful Rememberers | Immune | Immune |

A converted Patchbot retains its small frame classification. Capture immunity has a distinct broken-lock cue. A shielded front or closed shell cannot be bypassed by locking through it. Burrowed enemies and off-plane scenery are invalid targets.

Hold at most one object or enemy. A live captive tries to break free after a proposed 2 seconds, with a clear escalating shake; a prop has no escape timer. Drop/release produces a safe nearby placement where possible; a throw produces a committed projectile. The tether cannot capture enemy bullets, whole platforms, or arbitrary architecture.

## Special limits by role
Howlers alert an authored nearby group once; they do not summon infinite waves. Puffers signal inflation before rupture, with a finite cloud afterward. Burrowers travel only through visibly soft soil. Clingers must be visible or separately foreshadowed before dropping into the play lane.

Rememberers' learned behaviors do not imply universal player-like intelligence. Their cover use, door interaction, or thrown prop are authored encounter actions. Returned Choir Units use a short directed volley and interruption pause, never the full Unfinished Choir boss routine.

**Orderly capture proposal:** its marked scoop deals one normal hit and briefly puts the hero on the stretcher. A single Jump input during a clearly shown escape window vaults the hero to a safe adjacent side; no rapid button mashing is required. Input buffering accepts an already-pressed jump when the window opens. Give at least two seconds before reaching a disposal chute. If the hero does not escape, the chute uses the normal pit-return rule rather than instant death or weapon loss. Its return point cannot be inside another scoop. Exact timings remain untested.

## Future tuning handoff
A later prototype should measure attack readability, recovery safety, capture breakouts, and status overlap. Do not assign final enemy health or damage-per-second tables from these prose targets; first validate the shared player movement and five base weapons.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
