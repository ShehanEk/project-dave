# DEAD EDEN — Encounter planning and boss fairness

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** W04  
**Status:** Working design proposal. The premise, Adam, Dave Harlan and microchips are confirmed (C14, C17–C19), and so are lethal combat, enemy guns and the approved roster (C25–C31). New names, details and numbers are *proposed* and untested.  
**Purpose:** defines the fairness rules for enemy guns, screen caps, escalating encounter composition and lockdown events inside fights, and checks every boss against the available single weapons.

**Decision references:** C04, C06, C07, C16, C25, C26, C27, C28, C31, P13, P20, P23 — see the [decision register](../decisions.md).  
**Read with:** [status and enemy states](status-and-enemy-states.md) · [objects and hazards](objects-and-hazards.md) · [ammunition and resupply](../03-progression/ammunition-and-resupply.md) · [design guide](../../level-design/design-guide.md)

Boss identities and arenas belong to their art briefs: [the Peacekeeper](../../art-design/mini-bosses/b01-the-peacekeeper.md), [Howard Stroud](../../art-design/mini-bosses/b02-howard-stroud.md), [the Surgeon](../../art-design/mini-bosses/b03-the-surgeon.md) and [the Sower](../../art-design/mini-bosses/b04-the-sower.md).

## The encounter promise
A mandatory encounter is beatable with **any weapon legitimately brought there, at base stage**, using baseline movement. No backup pistol, free tether, two-weapon combo, hidden respec, or optional evidence file is assumed, no fight requires having found a keycard, and no gun in the room needs a crouch to answer.

Weapon introductions remain L1 pistol, L2 shotgun, L4 Arc Welder, L5 Seedlobber, and L6 tether. "Introduced" means a type may have been encountered; it never means all introduced weapons are carried.

## Fairness rules for enemy guns *(proposed, P23)*
These rules apply to every encounter that has a gun in it. They are written in hero heights (H, one Dave), seconds and health units from the prototype's hero data. Every number is proposed and untested, and the layout rules are meant to be checked by an automated placement test.

**Dave's baseline**
- **No crouch.** Dave has move, jump, fire, interact and pause (plus journal, skip and help), and his hurtbox is a full-height standing box. Every dodge is a jump, cover or another floor. No encounter relies on a drop-through grate yet.
- **Jump.** The real apex is about 1.5 H (147 px) and the airtime about 0.80 seconds. Dave's feet stay above 0.3, 0.5 and 0.75 H for about 0.68, 0.63 and 0.55 seconds. A tap hop clears nothing, so every jump dodge assumes a held jump. He runs at 4 H per second, has 6 health, and is immune for 1 second after a hit.

**Aim, range and damage**
- **Flat fire.** Same-floor guns fire flat at 0.5 H (dogs at 0.3 H) with no random spread, only a fixed ±0.04 H jitter, and are designed to clear a 0.75 H jump. Nothing is ever fired at head height on Dave's floor.
- **Never at the airborne.** Enemies aim at Dave's x and his last grounded height plus 0.5 H, never at him in the air. A same-floor gunner turns to face him only between bursts.
- **Jumpable means quick.** A single shot or burst is jumpable when it passes Dave within 0.5 seconds. Repeat fire on Dave's floor needs at least 1.0 second from start to start, or it is cover-only (the machine gun).
- **Tracking is slow.** An aim point moves in H per second, always slower than Dave's 4, with no lead: turret and roof gun 2.5, sight lines 3.0, beam drag 2.0. Keeping moving is always a valid counter.
- **Sight lines.** Only the rail rifle and the cutter beam use a sight line: track, freeze, hold amber for 0.3 seconds, turn red for 0.25 seconds, fire. Lines run flat on Dave's floor or come down at 45 degrees or steeper. The band Dave must clear is 0.4 H + 1 H / tan(angle).
- **Range.** Every gun reaches at most 6.5 H (Dave's bolt reaches 6.7 H), except the rail. Rail fights are advance fights, with cover at most 8 H apart and a perch Dave can reach.
- **Damage.** A hit costs 1 health. Rail and plasma direct hits and a boss's heavy strikes cost 2, and a beam hits once per firing. Enemy shots pass through other enemies.
- **Area bursts.** Frag and plasma bursts and vial splashes are blocked by walls and floors (one line-of-sight test). The frag escape is always forward, and the gaps between vial splashes are at least 0.7 H.

**Tells and pacing**
- **Tell.** An amber glow, a windup sound and a pose, then red for the last 0.25 seconds, in three kinds only: GLOW, LINE and CHARGE ([W02](status-and-enemy-states.md)). It is a large glow on the attacking part; a driven or hunting body shows only a small, dim, steady amber point.
- **Bosses and Garden-built variants** shorten only the amber part, and red stays 0.25 seconds. A boss starts no windup while its shots are alive.
- **Readability gate.** A shooter fires only when it is at least 1 H inside the camera rectangle. This is not detection ([G04](../01-core/camera-and-feedback.md)).
- **Hounds.** Every lunge has its own tell, at least 0.9 seconds from lunge to lunge. The hit zone is 0.8 H tall, and a handler starts 1.5 seconds after the chain.
- **The Linked never block progress.** Dave can always jump past one.

**Cover and layout**
- **Cover kit** ([W03](objects-and-hazards.md)). Low cover is a 0.6 H crate that blocks all same-floor fire, and Dave can shoot over it. High cover is a pillar at least 1.2 H tall or an overhang with at least 1.1 H of headroom, and it is the only cover against elevated guns. Every machine-gun, rail or beam spot has the right cover, or another floor, within 3 H.
- **Half knockback and pits.** An enemy projectile hit uses half knockback ([G02](../01-core/player-controls.md)). No gun lane has a pit edge within 1.5 H behind a spot where Dave is meant to stand.

**Screen caps** *(placement rules, not runtime limits)*
- **Per screen:** at most 2 shooters, 3 attackers, and 1 machine gun, rail, beam or plasma gun. The rail is limited to 1 on screen.
- **Live shots at once, per gun:** pistol 1, rifle 3, machine gun 12, frag 2, plasma 1, seeker 2.

**Effects and colors**
- **Shot colors.** Tracers are ivory with a dark outline. Energy shots have a white core, a #5AA9FF edge, a dark ring and their own shape (teal lights stay small and still). A shot is never gold, violet, amber, red, teal or green. There are no casings, and an enemy's muzzle flash is ivory.
- **No strobes.** Rapid fire is one held glow. Arcs re-jag at 12 Hz and stay static under reduced motion. The camera shakes only on 2-damage hits, and never under reduced motion.
- **Blood and bodies** draw below tells, shots and pickups, and pools sit on static floors only.
- **Protected people** have no hit zone and stay out of every fire line.

## Enemy gun kit at a glance *(proposed, P23)*
The answer to every gun is a jump, cover or another floor, plus the rooted pause that ends its pattern. Full profiles and looks are in the [enemy gun briefs](../../art-design/README.md).

| Gun (first faced) | Carried by | How Dave answers it |
| --- | --- | --- |
| EG01 Pistol, AS-9 "Civic" (L2) | Sidearm Guard | Jump the flat round or keep moving, since the aim locks at red with no lead; rush him during the 1.2 s reload |
| EG02 Assault Rifle, AR-7 "Warrant" (L3) | Rifleman, Gun Hound | One relaxed jump per 3-round burst, or stand behind a low crate; close in during the 1.6 s magazine swap |
| EG03 Machine Gun, HG-40 "Thresher" (L3) | Peacekeeper roof gun, Sentry Turret, Heavy Gunner | On Dave's floor it is cover-only: get behind a low crate or onto another floor before it starts. Against a turret or the roof gun, keep running or use high cover. Punish the 2.0 s overheat |
| EG04 Frag Launcher, GL-6 (L5) | Grenadier | Move forward, toward him and off the two landing spots (the second lands 1.5 H behind Dave); rush him during the 1.8 s reload |
| EG05 Rail Rifle, RX-2 "Needle" (L6, futuristic) | Marksman | Keep moving so Dave is off the line at the freeze; advance one cover piece per 2.2 s recharge |
| EG06 Arc Caster, "Groundline" (L6, futuristic) | Linked Lineman, Howard Stroud, the Sower's stomp | Jump the arc that crawls along the floor, or stand on another platform; hit the wielder during the 1.4 s recharge |
| EG07 Plasma Gun, "Lumen" (L8) | Linked Trooper, Warden, the Sower's chest cannon | Jump the slow bolt or walk away, staying 1 H clear of the wall it will hit; punish the 1.4 s vent |
| EG08 Seeker (L8, futuristic) | Keeper Drone, the Sower in phase 2 | Jump it late so it overshoots, lead it into a wall, or shoot it down |
| EG09 Cutter Beam (L9, futuristic) | The Surgeon, Pruner | Keep moving so Dave is off the line at the freeze, outrun the 2 H/s drag, or get behind a pillar or under a catwalk. Never cross the beam |

## Enemy introductions *(proposed, P23)*
| Level | New enemy types |
| --- | --- |
| L1 | Night Guard, Patrol Rover, Staffer (at the alarm exit only) |
| L2 | Sidearm Guard, Security Drone, Hound (with a Night Guard handler) |
| L3 | Riot Officer, Rifleman (Arcadia Response Team). Mini-boss: the Peacekeeper |
| L4 | Sentry Turret, Freight Loader. Thornwall Riflemen appear from here |
| L5 | Heavy Gunner, Grenadier, Gun Hound |
| L6 | Marksman, Linked Lineman. Mini-boss: Howard Stroud |
| L7 | Linked Nurse, Sanitizer, Orderly |
| L8 | Linked Trooper, Keeper Drone |
| L9 | None (the test level). Mini-boss: the Surgeon |
| L10 | Fitted Heir, Pruner, Fitting Arm |
| L11 | Warden |
| L12 | None. Mini-boss: the Sower |

That is 24 regular types. All of them except the two Garden machines (Pruner, Fitting Arm) and the two Heirs (Fitted Heir, Warden) are introduced by L9, and enemies recur in later levels. New mechanics stay isolated in their first encounter: the floor arc and the sight line first appear at L6 (the Linked Lineman, Howard Stroud and the Marksman), the cutter beam reuses the sight line at L9, and the sweep first appears at L10 (the Fitting Arm).

## Room pattern
1. **Preview:** show the arena, main hazard, safe footing, cover and supply points before activation, each lit so it reads in the dark.
2. **Teach or recall:** begin with one readable action or familiar enemy role.
3. **Combine:** add a complementary pressure, leaving at least one clear route of response.
4. **Recover:** let the player reach resources and exploit a meaningful opening, such as a gunner's rooted pause.
5. **Release:** open the exit or, on L3, L6 and L9, let the arena console grant the level's keycard (*proposed*), award the fixed reward, then reach a checkpoint.

Suggested active pressure: L1–3 one main attack with at most one low-pressure support; L4–6 combine ranged and ground pressure; L7–9 add front armor, area denial (jets, vials) and homing seekers; L10–12 mix Heir behaviors (the hop, plate and plasma) with a familiar hazard. These are proposed pacing limits, not exact counts in every room, and the screen caps above always apply.

Avoid multiple independent offscreen attackers. A support enemy can remain alive without constantly firing. A crowd may look large while only a few units commit to attacks. Adam's coordination shows as timing, not as extra attackers: a lockdown reroute draws one authored group once. Keep new mechanics isolated before combining them.

## Lockdown events in encounters (*proposed*, P20)
Adam's lockdown events can punctuate an encounter, but they are authored beats between attack cycles. They are never a reactive system and never a response to being "seen" (C16). Each event needs:
- the telegraph order from [G04](../01-core/camera-and-feedback.md) (a calm captioned PA line, amber warning lamps with a sound, a slow lit preview, then alarm red only while the change happens), and a warning at least as long as a heavy attack's (about 0.6–1.0 seconds), or about 2 seconds (proposed, untested) for anything that changes footing or could trap Dave;
- a safe window before the next attack starts;
- unchanged footing for the seconds it takes to react, and nothing moving under a landing Dave is standing on;
- at most one lockdown change active at a time.

A shutter, door or lights-out event never closes on Dave, never removes a recovery station, dispenser or throwable pad from an active required fight, and never hides a tell or a landing. Dim the scenery, not the light on a landing, a weak point or an attack mark. After a retry the event restarts from its telegraph.

## Boss escalation
Each boss owns one lesson: L3 the Peacekeeper, read the tell, dodge and punish the stall; L6 Howard Stroud, keep changing platforms while finding shots; L9 the Surgeon, dodge a big overhead threat and punish it when it comes low; L12 the Sower, recognize each learned tell and punish the vent.

| Level / boss | Main test | Later phase | Fairness constraint |
| --- | --- | --- | --- |
| L3 the Peacekeeper | **Ram:** the siren and lightbar go amber then red, the wheels spin for 1 s, then it rams its lane into the bollards (2 damage) and stalls 3 s with the hatch open. **Roof gun:** it reverses to center, the rotary spins up amber then red, then a 1.5 s stream from 1.5 H up creeps after Dave at 2.5 H/s; the overheat opens the hatch for 1.8 s | Phase 2 (50%): the stream runs straight into a ram; amber shortens ×0.7, red stays 0.25 s | Dave keeps running the side walkway or stands behind a concrete planter pillar (high cover); a broad grounded route around the stopped truck; tracking capped at 2.5 H/s; do not demand a dash or grapple |
| L6 Howard Stroud | **Slam:** the lamp over the nearest platform goes amber then red, then a 2-damage slam, and he kneels with the chest implant open for 1.5 s. **Ground arc:** he spikes his cable into the deck as the capacitor goes amber then red, and two arcs crawl both ways for Dave to jump; he then vents for 1.2 s with the implant open | Phase 2 (50%): his own voice breaks through ("Dave... it's in my head. Kill me before it finishes."), and slam and arc chain together (amber ×0.7). At 0 health he dies, speaking his own last words | Only the amber part is scaled; fixed refuge ledges remain; the arcs cannot leave their floor; no required tether pull, burn or slow |
| L9 the Surgeon | **Cutting laser:** it slides along its rail, the lens opens, a sight line tracks Dave at 3 H/s, freezes amber 0.3 s and red 0.25 s, then the beam drags after him at 2 H/s for 1.2 s; the lens then hangs open 1.5 s. **Injector dive:** it drops on Dave's locked spot and hangs at head height for 2 s with its core open | Phase 2 (50%): laser and dive chain together (amber ×0.7), and the restrained staff (protected, no hit zone) turn their heads to follow Dave | Dave keeps moving or stands under a steel instrument shelf (at least 1.1 H of headroom); the beam is capped at 6.5 H and stops at the first solid thing; it reuses the sight-line mode from L6 |
| L12 the Sower | **Stomp:** the foot lamp goes amber then red, a 2-damage drop, and an arc wave crawls both ways for Dave to jump. **Plasma volley:** the chest cannon charges amber then red, then fires 3 slow bolts 1.0 s apart at Dave's grounded spot, each bursting on impact. The rear vents open for 1.5 s after each attack | Phase 2 (50%): the shaft opens, violet canisters rise and Adam speaks. Each vent releases 2 seekers (at most 2 alive, 2.5 s life), and two attacks chain before each vent (amber ×0.7, red stays 0.25 s) | It starts no new windup while its shots are alive; the volley spacing lets every bolt be jumped; the seekers are capped and shootable; fixed recovery ledges; at most two simultaneous attack threats; no sixth weapon or extra Adam fight |

Difficulty grows through decisions, timing, and combinations. Do not simply double health or remove all recovery windows. Every phase transition visibly changes posture, arena state, or scheduling; for the Sower that means its sound, light color and stance. Howard Stroud dies when his implant burns out, speaking his own last words, and the machine bosses burst into debris. No boss ends in dismemberment.

## Single-weapon feasibility matrix
| Boss | Scrapjack | Boom Broom | Arc Welder | Seedlobber | Graviton Tether |
| --- | --- | --- | --- | --- | --- |
| The Peacekeeper | Fire into the open roof hatch (the drive core) during the 3 s ram stall or the 1.8 s overheat | Reach the raised walkway beside the rear body, within spread range of the open hatch, before it closes | Not introduced | Not introduced | Not introduced |
| Howard Stroud | Shoot the open chest implant from a fixed ledge during the 1.5 s kneel or the 1.2 s vent | The lowered chest opening comes within safe spread range of a ledge the arcs cannot reach | A close ledge reaches the chest implant without touching an attack zone | Lob the pod as the windup starts so travel plus the fuse ends inside the opening (to be measured) | Replenishable canisters from the arena's supply pad can be thrown into the open implant |
| The Surgeon | Shoot the open lens after the laser, or the open core during the dive hang | The dive hangs at head height, within spread range from the floor | Close approach to the hanging core, outside the beam's reach | The 2 s hang fits pod travel plus fuse | Throw canisters at the open lens or core; neither target requires capture |
| The Sower | Shoot the open rear vents during their 1.5 s window | Grounded flanks reach the vents | Safe ledges within arc range; no need to stand inside the stomp zone | Predictable landing spots and the 1.5 s vent window allow pod arrival and detonation | Supply props reach the vents; the whole machine stays immune |

The matrix states **requirements for refining arena geometry**, not a claim that a playable layout has already passed testing. If a platform, weak-point height, or exposure window fails its row, revise that detail.

## Boss supply and recovery
Each arena has renewable finite-ammunition service and, from L6 onward, renewable tether props. Keep supplies reachable throughout every phase. Fixed recovery ledges cannot vanish together. An empty shotgun must be able to regain ammunition without first damaging the boss.

A healing pickup can be finite; it cannot be the only way to survive an unavoidable attack. No boss attack is intended to be unavoidable. Preparation checkpoints fully service the carried weapon and provide an upgrade workbench, while never requiring a purchase.

No boss repairs or heals. Its weak point opens on a timer after each attack (a hatch, an implant, a lens, a vent) and must yield to ordinary base-weapon damage. It cannot require electrical immunity, a specific status effect such as burning, or a tether-only action. Boss arenas keep their cover (planter pillars, instrument shelves) clear of the supply points.

## Encounter review record
For each required room, record: available weapon types; movement needed; enemy roles and active-pressure limit; the guns in the room and the answer to each (jump, cover or another floor); cover within 3 H of every machine-gun, rail or beam spot; sight-line angles; shooters, attackers and heavy guns per screen; pit edges behind standing spots; fire lines clear of protected people; attack tells and how each reads at the Dimmer brightness setting; recovery positions; finite-ammo access; tether prop source; close-range access; pod trajectory/fuse window; lockdown event and its telegraph, if any; keycard source, if the room holds it; exit condition; retry boundary.

A side challenge may favor a specific equipped weapon only if it is clearly optional and its essential reward (an evidence file or a chip cache) has a baseline alternative route under the evidence-file proposal. Keep most secrets discoverable through observation and platforming.

## Failure cases to reject
- A route across an anchor gap that traps a player carrying the shotgun.
- An arena gate or lockdown shutter that closes with an empty Seedlobber and no dispenser.
- A machine-gun, rail or beam spot with no cover, and no other floor, within 3 H.
- A shot that can only be answered by crouching, or a flat shot at head height on Dave's floor.
- A shot aimed at an airborne Dave, or a tracking aim point faster than its cap (2.5 H/s for turrets and the roof gun, 3.0 for sight lines).
- A sight line at a shallow angle, between flat and 45 degrees.
- A frag landing spot with no forward escape, or a gap between vial splashes under 0.7 H.
- A gun lane with a pit edge within 1.5 H behind a standing spot.
- More than 2 shooters, 3 attackers, or 1 machine gun, rail, beam or plasma gun on one screen.
- A tell that is not amber and then red for its last 0.25 s, or one that blood, fog or a corpse hides.
- A shooter that fires from less than 1 H inside the camera.
- A boss weak point visible for less than a pod's travel plus fuse.
- A heavy target that only stage-2 tether capture can defeat.
- Any enemy that heals, repairs or revives another.
- A protected person in a fire line, or given a hit zone.
- A lockdown event with no telegraph, or one that closes on Dave or removes the only supply.
- A tell, weak point or landing visible only at the brightest setting, or only as a strobe that reduced flash removes.
- A keycard reachable only by the tether or by one specific weapon.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
