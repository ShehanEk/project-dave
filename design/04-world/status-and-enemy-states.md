# DEAD EDEN — Enemy states, status effects, and capture rules

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** W02  
**Status:** Working design proposal. The premise, Adam, Dave Harlan and microchips are confirmed (C14, C17–C19), and so are lethal combat, visible blood and the shared behavior templates (C26, C28, C29). New names, details and numbers are *proposed* and untested.  
**Purpose:** standardizes the five behavior templates, warnings and tells, armor, lethal deaths, blood, ragdolls and corpses, status limits and tether capture classes.

**Decision references:** C04, C16, C26, C28, C29, C30, C31, C35, P12, P13, P23 — see the [decision register](../decisions.md).  
**Read with:** [factions and friendly fire](factions-and-friendly-fire.md) · [encounter and boss fairness](encounter-and-boss-fairness.md) · [camera and feedback](../01-core/camera-and-feedback.md) · [ammunition and resupply](../03-progression/ammunition-and-resupply.md) · [README](../../art-design/README.md)

## Shared encounter language
Use this behavioral sequence where appropriate: **idle → notice → prepare → act → recover → choose next action**. Patrol and support movement can branch before preparation. Death, stagger, and capture are explicit alternate states. "Notice" is an authored encounter trigger, not a detection system: there are no vision cones, alert meters, search states or hiding (C16), and lockdown events never respond to Dave being "seen". A shooter also fires only when it is at least 1 H (one hero height) inside the camera rectangle, which is a readability gate and not detection.

A dangerous action needs a visible preparation pose before damage begins. A starting target is about 0.6–1.0 seconds for a new heavy attack and 0.35–0.6 for familiar light attacks, adjusted for distance and camera framing. These numbers require testing. Quicker later attacks retain their identifying pose and sound, and the red part of a tell is always 0.25 seconds; only the amber ramp changes length.

Once an attack commits to a marked location, it does not track Dave invisibly. A Security Drone's dive and a Sidearm Guard's aim lock at red, and a Hound's lunge commits to a direction. The few attacks that keep tracking (a turret stream, a sight line, a beam drag) do so at a capped, visible speed that is slower than Dave's run ([W04](encounter-and-boss-fairness.md)).

Being near an enemy is not automatically damaging. Damage comes from its defined strike, projectile, active charge, or hazard volume. Corpses and enemies recovering from a stagger cause no contact damage.

## The five behavior templates *(C26)*
Every regular enemy is built from one of five shared templates, so each behavior is implemented once, and the four mini-bosses share a boss base. A template fixes the state sequence and the counter; each enemy's tell, weapon and look come from its own brief.

| Template | Core loop | Enemies |
| --- | --- | --- |
| Brawler | Closes in, tells, one melee strike, then a winded pause | Night Guard, Riot Officer (front armor), Staffer (low lunge), Sanitizer (low held jet), Fitted Heir (with a hop) |
| Charger | Winds up, charges a marked lane, then stalls | Patrol Rover, Freight Loader (heavy), Orderly (reverses after the stall), Hound (light lunges) |
| Gunner | Takes a stance, tells, fires its gun's pattern, then reloads, recharges or vents rooted | Sidearm Guard, Rifleman, Heavy Gunner, Marksman, Grenadier, Linked Lineman, Linked Nurse, Linked Trooper, Gun Hound, Warden (front armor) |
| Drone | Flies a path or hovers, tells, dives or releases a shot, then hangs low | Security Drone, Keeper Drone |
| Turret | Fixed mount, opens, tells, fires or sweeps, then overheats or hangs low | Sentry Turret, Pruner, Fitting Arm |
| Boss base | An authored attack list, a phase change at 50%, and no new windup while its shots are alive | The Peacekeeper, Howard Stroud, the Surgeon, the Sower |

The rooted pause that ends every gun pattern (reload, magazine swap, overheat, recharge, vent) is the enemy's opening, and the counter is written around it.

## Tells *(proposed, from the P21 palette)*
There are three kinds of tell, the same everywhere:
- **GLOW:** the attacking part (a baton tip, muzzle lamp, jaw, hands, nozzle or lightbar) glows amber and ramps up, then turns alarm red for the last 0.25 seconds.
- **LINE:** a sight line tracks Dave, freezes, holds amber for 0.3 seconds, then turns red for 0.25 seconds before the shot. Only the rail rifle and the cutter beam use it.
- **CHARGE:** a collar, capacitor pack or emitter glow grows amber, then red, while a sound rises (the rotary's whine, the plasma hum, the arc's buzz).

A tell is always a large glow on the attacking part, plus a posture cue and a sound. A driven or hunting body shows only a small, dim, steady amber point (the Link light of a driven body, the lens of a hunting machine), and that point is never a tell. A teal Link light marks a harmless or protected person, never a hostile one. Bosses and Garden-built variants shorten only the amber part (about ×0.7 in a boss's second phase), never the red. Color is never the only cue: each tell also has a posture and a sound (see [sound direction](../05-presentation/audio-direction.md)), and a red flash follows the reduced-flash setting, becoming a steady or slow pulse (see [interface and accessibility](../05-presentation/interface-and-accessibility.md)).

## Death, bodies and blood *(C28, C29)*
Combat is lethal. Every hostile can die: a hit that takes the last health kills, and there is no knock-out, disabling or reviving. Kills give no drops and no score. Dave's shots cannot harm protected people, who have no hit zone ([W01](factions-and-friendly-fire.md)). There is no dismemberment for now.

### Blood by material
| Body | On a hit | On death |
| --- | --- | --- |
| People (Arcadia Security, Thornwall) | Red spurt sent along the shot direction | A bigger spurt, a ragdoll and a floor pool |
| The Linked | As people, plus white sparks at the implant | As people. The Link light dies, and most deaths are silent |
| Cyborg dogs | Red spurt, and sparks at the plates | As people. The legs twitch for about 1 second after death |
| Machines | Sparks and a thin oil leak | Burst into debris parts with a shower of sparks, then an oil pool |
| Heirs | Grey-rose lymph drips under gravity, never sprayed along the shot; cracked ceramic shows grown tissue | Slump, with the seams fading and the mask going blank; lymph pools |
| Bosses | By their body. Howard Stroud bleeds and sparks at his implant; the Peacekeeper, the Surgeon and the Sower leak oil | Machine bosses burst into large debris; Stroud dies on the spot |

Fluids: wet blood is #B3212F with two or three pale highlight drops, drying to #8A1A26 and never darker; oil is #14181E with a #46566A sheen rim; Heir lymph is #A88A8C at about 80% opacity. Blood is never gold, violet, teal, amber or green. Dave bleeds too, as a spurt with no pool.

**Rules** *(proposed)*:
- A hit spurt is about 8 to 12 drops under gravity for roughly 0.35 seconds. A death spurt is bigger, and the floor pool spreads over about 1.5 seconds.
- Blood, wound marks and pools are separate from the painted art (C35). Wound marks attach to the hit part, and a death shows a bloodied appearance drawn as an overlay.
- The green hit spark is suppressed on anything that has a fluid, so a hit on a person reads as blood, not as a generic spark.
- Pools sit just above the floor line, below characters, tells, shots and pickups, at most 1.2 H wide, on static floors only (never on moving platforms or over pits). Each area keeps at most 24; the oldest goes first.
- Blood never glows, never uses a tell color and never hides a tell, a ledge or a pickup ([G04](../01-core/camera-and-feedback.md)).
- With the Blood setting off, spurts become dark dust and pools and blood overlays are hidden; nothing else changes ([N03](../05-presentation/interface-and-accessibility.md)).

### Ragdolls and corpses
- A dead person, Linked person or dog becomes a ragdoll: its painted parts turn into physics bodies pushed by the killing shot, and they settle where they land. Its gun falls with it and lies beside the body as scenery ([G03](../01-core/weapon-swaps.md)).
- A corpse is a low, non-solid drawing. It never hides a pickup, a landing or a tell, deals no contact damage, drops nothing, and cannot be captured, revived or used by any enemy.
- Bodies stay. After a death or a Continue the level rebuilds from the last checkpoint: enemies killed before it come back as static corpses in their final rest pose, with their pools already dry and no ragdoll replayed, and enemies killed after it are alive again ([S01](../03-progression/health-and-checkpoints.md)).
- Linked deaths are mostly silent: the light just dies. Rarely a victim says something confused and human, such as "...Dave?", their own name or "what time is it?". The Linked never block progress, so killing them is a choice.
- Howard Stroud is the one exception. At 50% his own voice breaks through ("Dave... it's in my head. Kill me before it finishes."), and at 0 health his implant burns out and he dies, speaking his own last words ([N01](../05-presentation/story-scenes.md)). He is the only enemy who asks to be killed.
- Machines and bosses that burst leave debris parts and an oil pool. Heirs slump and drip. Harmless Sleepwalkers and held staff cannot die, because they have no hit zone.

## Armor and weak points
Ordinary exposed body hits work unless a brief specifies armor. A ballistic shield or armor plate blocks frontal hits, including upgraded pistol bolts; light-armor penetration is not permission to ignore all defenses. The Riot Officer's shield blocks Dave's shots while it is up, but enemy rounds pass through him. The Warden's plate blocks frontal hits until it lowers to vent.

Blocked hits make a short ceramic or metal deflection cue and a spark, never blood. Successful weak-point hits use a sharper response and visible opening. Weak points are existing body parts with named exposure states (an open core during an overheat, a rear power unit or battery during a stall, an open lens, a gunner's rooted pause, a chest implant), not arbitrary glowing circles added by each AI agent. In the dark an opening shows its own restrained light, distinct from the red tell, or a posture change, so it stays findable at every brightness setting.

A boss opening lasts long enough to approach safely and land a base-weapon attack. Test Seedlobber travel plus fuse, not just instant pistol hits. Status damage cannot bypass a closed invulnerability state unless that exact state explicitly permits lingering damage.

## Proposed status rules
Enemy statuses are kept minimal.

| Effect | Cause | Behavior | Limit / counter |
| --- | --- | --- | --- |
| Burn | Incendiary Shells; selected burning surfaces | Short damage over time on valid targets | Same effect refreshes duration, never stacks indefinitely; drawn as ember sparks and a warm light on the burning part, never charring |
| Slow | Snare Foam on enemies (a short-lived patch of foam) | Reduced ground speed for about 2 seconds | Does not stack; preserve jump height and required escape range; boss path timing is not slowed. No enemy in the first roster slows Dave; if a later one does, the same limits apply |
| Electrical interruption | Arc attacks when a unit is in an interruptible state | Brief stumble or stopped action; a Linked person's Link light stutters and a machine's lens flickers | Not every tick stuns; roughly 2-second protection after an interruption; no permanent stun lock |
| Stagger | Heavy hit, clear environmental impact, or a Charger's scripted missed charge | Brief recovery exposes an opening; can qualify a medium tether target | An attack marked committed may resist it; bosses use their authored exposure rather than generic stun |
| Knockback | Shotgun, impacts, select attacks | Short displacement respecting walls and protected zones | Heavy or anchored bodies resist; never push a mandatory target beyond reachable geometry. An enemy projectile hit on Dave uses half knockback |
| Bursts and jets | Frag and plasma bursts (about 1.0 H radius for 0.15 seconds), the Sanitizer's jet (0.6 seconds), arcs | Damage only while the volume is live | Finite duration and a safe exit; blocked by walls and floors; a bright, bounded outline stays readable in the dark; never a permanent meter |

There are no bleed-out timers (a wound never weakens or slows an enemy), no morale or fleeing, no fear, no poison meters and no revival. Poison progression, infection or corruption meters, freezing, mind control of Dave, conversion, elemental crafting, and permanent injuries are outside this baseline. Do not infer them from a Link light color or from Adam's control of the Linked. The Bloom is a story weapon and the Sower's cargo; it never becomes a status effect or damage type that Dave suffers.

Dave uses the common damage immunity window, so overlapping hazards cannot drain all six health units at once. A short status icon includes a shape and fading timer, not color alone.

## Proposed tether classes
These are gameplay eligibility proposals, not changes to the art proportions.

| Class | Examples | Base tether | Heavy Lifter stage 2 |
| --- | --- | --- | --- |
| Light loose object | Marked canister, loose small crate, approved debris | Capture | Capture |
| Small enemy | Security Drone, Keeper Drone, Hound, Gun Hound | Capture after the short lock, outside protected attack states (a dive, a lunge, a burst) | Same |
| Medium enemy | Human-sized enemies: Night Guard, Sidearm Guard, Rifleman, Grenadier, Staffer, Linked Nurse, Linked Trooper, Warden; also the Fitted Heir and the Patrol Rover | Cannot capture | Capture only while visibly staggered and physically exposed (the Rover only during its stall) |
| Rooted medium | Linked Lineman, Marksman | Cannot capture | Only after the rod or rifle stance releases and a visible stagger; no pulling through a solid floor or off a perch Dave cannot reach |
| Fixed or heavy | Riot Officer, Heavy Gunner, Sentry Turret, Pruner, Fitting Arm, Freight Loader, Orderly, Sanitizer | Immune | Immune |
| Boss or protected | All four mini-bosses, the founder, the held staff, harmless Sleepwalkers | Immune | Immune |

These classes are *proposed*. The Riot Officer is immune because his shield and armor make him a heavy target. Garden-built variants keep the class of the machine they are built on. Capture immunity has a distinct broken-lock cue. A shielded front or closed shell cannot be bypassed by locking through it. Corpses, seekers and other enemy shots, and off-plane scenery are invalid targets.

Hold at most one object or enemy. A live captive tries to break free after a proposed 2 seconds, with a clear escalating shake, and cannot attack while held; a prop has no escape timer. Drop or release produces a safe nearby placement where possible; a throw produces a committed projectile. The tether cannot capture enemy bullets, whole platforms, or arbitrary architecture.

## Special limits by role
- **Riot Officer and Warden:** the front armor is a toggle, not a permanent shield. The Riot Officer's bash and the Warden's vent lower it, and that is the window.
- **Hounds:** every lunge has its own tell, with at least 0.9 seconds from lunge to lunge and a hit zone 0.8 H tall. A handler's own windup starts 1.5 seconds after the lunge chain, so the handler never adds to a lunge.
- **Keeper Drones:** one seeker per lap. A seeker dies to one bolt, fizzles after 2.5 seconds, cannot be captured, and at most two are alive at once.
- **The Linked:** they never block progress, and Dave can always jump past one. Adam's phrases come out in their own voices.
- **Every gunner:** the rooted pause after its pattern is the opening. No gunner fires at an airborne Dave; each aims at his x and his last grounded height ([W04](encounter-and-boss-fairness.md)).

## Future tuning handoff
A later prototype should measure attack readability, recovery safety, capture breakouts, status overlap and blood readability. Do not assign final enemy health or damage-per-second tables from these prose targets; first validate the shared player movement and the five base weapons.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
