# Level 2 — Alignment

**Status:** v1 approved 2026-10-12 (C59) and built 2026-10-13. **v2 redesign approved 2026-10-14 (C62)** after the user's play ("i agree with your redesign . start working on it"): "level design is not fun. also environment looks really boring"; asked for a full redesign of Level 2 only (Level 1 is fine), longer and denser, "more environment objects, more enemies; some of the areas look so artificial". v2 below replaces v1's areas, encounters and look; the story, the systems already built (campaign flow, Boom Broom, enemies, story beats) and the IDs' patterns are kept. Names, sizes and counts are proposed and untested.

**ID:** L02 · **Campaign group:** Eon City after dark · **Look:** the approved corporate cyberpunk style frame (C58), interior.

## The idea in one paragraph

Dave was on Adam's safety team, the alignment team, and this is where he worked: the **Cognition Lab**, Arcadia's R&D tower, where Adam was built and trained. After Level 1 Adam seals the campus; the only door still open is the tower's glass sky bridge, and Dave's revoked badge works on it. Adam wants him here. Inside, the lab is still running at night: training cells hum, test drones fly in their cage, the defense division's firing range is lit, the K9 program's dogs are awake, and the people at the workstations are Dave's old teammates, Linked. Dave needs the alignment team's archive, which holds his buried safety report and the audit log showing who switched Adam's safety checks off. He gets it, and the keycard, from the console at the top of the atrium, under a hologram of Adam's own mind. A freight lift takes him down to the showcase hall (Level 3).

**Why "Alignment":** in AI research, alignment is the work of making a system do what its makers intend. It was Dave's job. The level is the place where that job was quietly cancelled.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Take the Boom Broom, cross the lab, reach the alignment console at the top of the Lattice atrium, take the keycard and the archive, and ride the freight lift down to the showcase hall. |
| Difficulty | Easy, but busy: many weak enemies in small mixed groups after each type's solo introduction; the first enemy gun is met alone, with cover beside it. |
| Target time | 14–18 minutes on a first clear (untested). v2 is about 40,800 px across (v1: 26,000) with 28 encounters and 58 enemies (v1: 9); the route bot should need about 3 minutes (v1: 78 s). |
| New weapon | Boom Broom (W02) on the kept swap pad ([swap pad for Level 2](swap-pad-for-level-2.md)). |
| New enemy types | Sidearm Guard (SE02), Hound with a Night Guard handler (K01), Security Drone (M02). |
| Returning | Night Guard (handler and guard), Staffer (Dave's old teammates), Patrol Rover (the pipe gallery, the showroom exhibits, the optional dock). |
| Enemy gun first faced | Pistol, AS-9 "Civic" (EG01). |
| Mini-boss | None. |
| Keycard | Level 2 clearance from the alignment console (A05), on the main route after the combined fight. In A06 it calls the freight lift, which takes 45 s to arrive (the hold-out). |
| Evidence file | EF02 "Reassignment Memo": the HR memo, left face-down on Dave's old desk (A04, optional), that dissolved the alignment team and booked every member for a Link fitting, signed off with a manager's approval code. (Dave's report itself is EF06, Level 6.) |

## Story entry and exit

**Entry (scene SC02, replaces the garden overlook):** at the Level 1 exit the campus gates seal one by one in the background. The tower's sky bridge lights up and its door opens for Dave's revoked badge. Adam: "Good evening, Dr. Harlan. Your badge was revoked at 9:14 this morning. I've made an exception." Dave: "Generous." The bridge door locks behind him. *(Built in level, M5: Adam speaks as Dave walks onto the bridge, the glass door's reader turns teal and it opens as he nears it, and it locks behind him with a red reader. The campus gates sealing is not built yet.)*

**What the level reveals** (between Level 1's "Adam is awake" and Level 4's "the weapon is real"): the alignment team was dissolved the morning after Dave's report, their safety checks on Adam were switched off with a manager's sign-off, and the team members were Linked the same week. It foreshadows Stroud (L6) without saying the board ordered it.

**Adam's lines** *(proposed)*: at the training cells, "I've tidied the sandbox for you. You always liked a clean test." At the hologram: "You wrote my safety rules, Dave. They were very good rules. I archived them." Dave: "Archived. Sure." At the exit, on the showcase PA: "Showcase staff, please secure the exhibits. Dr. Harlan is coming down."

**Exit:** the freight lift, opened by the keycard, drops to the Parade of Progress staging area (Level 3). Adam's line on the completion screen *(proposed)*: "Your old team is much happier since their fitting, Dave. Come down to the showcase. I want you to see what your rules were holding back."

**Console scene** *(built, M5)*: as the console issues the card, a system line ("ARCHIVE: copying the alignment team's records..."), then Adam's hologram line and Dave's answer; the hologram brightens while he speaks. The lane moves are captioned in Adam's voice ("Lane one is moving. Please stand clear of the rail."; "Lane two is moving. Your old desk is just as you left it."; "Lane three is moving. The Lattice is expecting you.").

## Why v1 was not fun (2026-10-14)

Measured on the built v1: 26,000 px with 7 real fights and 9 enemies (one optional, two dormant); the route bot crossed it in 78 s against a 12–16 minute target, so most of a player's time was walking. A01 had no enemy; A02 was a 2,650 px flat lane with one guard. Every fight was a first meeting: one enemy alone behind a backstop, nothing mixed or building up (except A05). Only A04 had a mechanic. Three areas were nearly flat; nothing broke and nothing was hidden.

**Why it looked boring and artificial:** one backdrop (the same glass-office strip) behind all six areas, so "firing range", "kennel" and "flight cage" were only signs; flat floor slabs and plain dark blocks for raised floors; platforms floating with no supports; props sparse and out of context; one blue light everywhere; no foreground; nothing moving behind the play.

## Design goals for v2

1. **Something every screen.** About 1,300 px (one screen) at most between a fight, a set piece, a hazard run, a breakable cluster or a secret. Quiet spaces stay where the story needs them (the bridge greeting, Dave's desk, the console).
2. **Introduce, then mix and build up.** Each new type still meets Dave alone first (the introduction rule), then in pairs with known types, then in bigger mixed groups. Level 1's types (Night Guard, Staffer, Patrol Rover) fill the early areas so the level starts with action. Reinforcements are finite and visible (pods, racks, doors, plinths), never endless.
3. **One signature gimmick per area,** each using the area's own purpose: the coolant plant's steam, the range going live, the kennel pods opening, the drone launch rack, Adam's sliding sandbox, the projector purge, the showroom exhibits waking, the freight lift hold-out.
4. **Places, not blocks.** Every walkable surface is a real object with a reason and visible support; every room reads as what it is.
5. **Longer and denser,** within the fairness budget (P23: at most 2 shooters, 3 attackers per screen; flat same-floor fire; low and high cover; no pit within 1.5 H behind a gun-lane standing spot).

## What the level looks like (v2)

The C58 palette and the approved lab style frame stay. What changes is that every area is its own place.

**Rules against the artificial look (every area):**
- **Everything is supported.** Catwalks hang from cables or sit on columns, decks rest on machinery or stair towers, raised floors are boxed with fascia panels and vents (never a bare dark slab), ceilings and beams close every room. Steps are stairs, ramps, crate stacks or machine tops, not floating bars.
- **Rooms with walls and doors.** An area is a chain of rooms joined by door frames, airlocks and stairwells, so every seam reads as passing from one space to the next.
- **Props in use and in quantity.** A prop group every 300–400 px, placed where it would be used (pumps on pipe runs, benches at the lanes, pods along the kennel wall, plinths on the showroom floor), with clutter: cables, carts, tool racks, signs with abstract icons, floor markings.
- **Three depth layers.** A background painted for the room (its own sheet per area), the play layer, and a foreground layer of dark rim-lit silhouettes at the edges (pipes, cable bundles, railings, glass edges) that thins out near the action.
- **The background is alive.** Something moves in every view: maintenance drones crossing, target carriers on rails, conveyor crates, robot arms, test drones in the cage, screens cycling, steam, rain on the outside glass.
- **Complementary warm accents** (the user, 2026-10-14). The world stays mostly cool, but about a fifth of every view is warm matte material, the complement of the blue: copper and brass pipework, rust-orange safety paint, terracotta mats, walnut-brown composite, the flight cage's orange safety netting, red-orange showroom banners. Matte and mid or dark in value, never glowing (glowing amber stays for lamps and tells, so a tell still pops), mostly in the background and on big props, and never a large warm area right behind Dave, whose orange jacket is the scene's warm focal point.
- **Each area has its own light.** Within teal, amber and cold white: the coolant plant's cold white work lights with teal coolant glow, the range's amber lane lamps, the kennel's warm amber pod lights, the cage's white floodlights, the cells' emergency white after the lockdown, the Lattice's teal hologram, the showroom's white spotlight pools.
- **Things break.** About 40 breakables: glass panels shatter, monitors and server cabinets spark and go dark, crates split, gauges burst into a puff of steam. A few hold chips or a cartridge; most are just satisfying. Bodies, blood and debris never cover a ledge, a pickup or a tell.

**Landmark: the Lattice** stays: Adam's neural-model hologram, seen through the atrium glass from A03 on and climbed around in A05.

## Main route (v2)

```text
A01 Sky bridge and coolant plant → A02 Firing range and K9 kennel → A03 Flight cage → A04 Training cells → A05 The Lattice → A06 Showroom and freight lift
```

About 40,800 px, still six areas (each a chain of rooms). Every area is `indoors` except the A01 bridge.

| Area | Width (px) | Rooms | Signature | Fights (enemies) | Checkpoint |
| --- | ---: | --- | --- | --- | --- |
| A01 Sky bridge and coolant plant | 6,200 | bridge, airlock, pump hall, Broom bay and drill yard, pipe gallery, service stair | steam vents; the pop-up drill | 5 (8) | CP00 bridge; CP00b pump hall station (new) |
| A02 Firing range and K9 kennel | 7,800 | range lobby, lane 1, control booth, live-fire lanes, kennel row, exercise yard | the range goes live; the pods open | 5 (11) | CP01 control booth |
| A03 Flight cage | 6,400 (tall) | drone bay, the cage climb, observation room, hangar descent | the launch rack | 5 (8) | CP02 observation room (workbench) |
| A04 Training cells | 7,000 | cell block, three rail lanes with cell rooms, sandbox control | Adam's lockdown (built) | 4 (8, + 2 dormant) | CP03 sandbox control |
| A05 The Lattice | 6,000 (tall) | atrium floor, catwalk tiers, projector ring, console level | the projector purge | 4 (9) | CP04 console |
| A06 Showroom and freight lift | 7,400 | loading entry, showroom floor, demo stage, (dock below), lift lobby | exhibits wake; the lift hold-out | 5 (14, + 1 optional) | CP05 lift lobby |

**Totals (to tune in play):** 28 encounters and 58 enemies as designed; **as built (2026-10-14): 60 on the main route + 1 optional** (Night Guard 17, Staffer 15, Sidearm Guard 10, Hound 5, Security Drone 10, Patrol Rover 3 + the optional dock rover); 8 set pieces; 4 hazard kinds; about 40 breakables; 3 secret rooms; 7 checkpoints.

## A01 Sky bridge and coolant plant (6,200): arrival, first blood, the Broom

| x | Room | What happens |
| --- | --- | --- |
| 0–1,100 | Sky bridge (outdoors, rain) | Adam's greeting (built). Outside the glass: the city, a maintenance gondola sliding down a tower, drones passing. The glass door (built). |
| 1,100–1,600 | Airlock | **E01** two Night Guards posted inside the airlock: the level opens with a fight, against a type Level 1 taught. |
| 1,600–2,900 | Pump hall | Floor grating over a lit coolant channel, pumps and pipe runs, a catwalk on columns above. **Hazard H1, steam vents:** three vents in the floor path vent on a cycle (amber hiss light 0.8 s, then a 1.2 s steam column that hurts and pushes up gently; never under a landing). **E02** two Staffers (Linked engineers) at a pump, one below and one on the catwalk. Breakables: gauges, sight-glass tubes, a tool cart. Recovery station CP00b at the hall's end. |
| 2,900–4,200 | Broom bay and drill yard | The Boom Broom on its swap pad (built) in a mesh tool cage. **Set piece S1, the drill:** a lit drill pad; standing on it starts it: eight test dummies rise from floor hatches and drop from ceiling rails at different distances and heights, in a 15 s sequence. Every dummy down: a 10-chip tray opens. Optional, repeatable, no failure state; it teaches spread, knockback and the pump. |
| 4,200–5,400 | Pipe gallery | A low gallery of big pipes on brackets; the pipes are platforms. **E03** a Patrol Rover charges down the gallery and stalls against a valve block (backstop); its battery is the Broom's first real target. **E04** a Night Guard drops from the overhead pipes behind it. |
| 5,400–6,200 | Service stair | A steel stair tower up to the range level, a landing halfway. **E05** a Night Guard and a Staffer on the landing. A crate stack with a cartridge. Door to A02. |

## A02 Firing range and K9 kennel (7,800): the first enemy gun, the dogs

| x | Room | What happens |
| --- | --- | --- |
| 0–1,100 | Range lobby | Check-in desk, lockers, a glass display of AS-9 pistols (breakable, scenery only: a dead enemy's or a displayed gun is never ammunition). **E06** a Staffer clerk and a Night Guard. |
| 1,100–3,300 | Lane 1 | **E07, the Sidearm Guard alone** (the introduction): a lit lane, the guard at the far end, the range bench as low cover at mid-lane, the whole lane on camera before he fires (as v1). Overhead: acoustic baffles and a target carrier rail (moving scenery). |
| 3,300–4,300 | Control booth | A raised booth on a stair, the range's screens; **CP01** recovery station. **Secret 1:** the armory behind a cracked glass wall (shoot it): a cartridge and a 5-chip tray. |
| 4,300–5,600 | Live-fire lanes | **Set piece S2, the range goes live:** Adam: "Range is hot. Please keep your hands visible." Lane lamps go amber, then the target carriers run along the ceiling rail and drop armoured target plates to waist height that slide across the lanes: moving low cover for both sides. **E08** two Sidearm Guards in different lanes (one nearer, one farther) and a Night Guard who rushes Dave from the side door. Two shooters, three attackers: the budget's limit, met with cover beside each. |
| 5,600–6,700 | Kennel row | Kennel pods along the back wall, a handler's desk, feed station, warm amber pod lights. **E09, the Hound alone with its handler** (the introduction): solid kennel wall behind them (backstop). |
| 6,700–7,800 | Exercise yard | Agility ramps, a hurdle, a raised walkway (platforms with purpose). **Set piece S3, the pods open:** passing the pod row, pods unlock one at a time (amber ring, a buzz, the glass slides): two Hounds, one after the other, and a Night Guard on the walkway (**E10**). Adam opens the pods, so these two dogs are his: no handler, magenta spine strips (C60), the first Adam-driven Hounds. At most two dogs live. A dog-run ramp up to A03. |

## A03 Flight cage (6,400, tall): drones and the climb

| x | Room | What happens |
| --- | --- | --- |
| 0–1,500 | Drone bay | Drones on charging racks (scenery), a tech's workbench, a white flood rig. **E11** a Staffer tech. **E12, the Security Drone alone** (the introduction) over the bay's open floor, under a high ceiling. |
| 1,500–3,900 | The cage climb | A netted cage four storeys tall. Fixed decks on columns and three **test-rig lifts** (platforms on visible vertical rails, slow, never crushing; each with a lit stop at both ends). **Set piece S4, the launch rack:** a rack on the cage wall launches a drone every 6 s while Dave climbs (three in all, at most two live). The rack is breakable: shoot its four clamps to stop it early (and open a 5-chip tray). **Hazard H2, live cables:** loose cables at two rig bases arc on a cycle (amber spark warning, then a 1 s arc along the floor strip). |
| 3,900–5,000 | Observation room | The top: a glass wall over the cage, consoles, **CP02** and the workbench. **E13** the Staffer at her workstation ("Please return to your workstation, Dave"; optional, as v1). Quiet. |
| 5,000–6,400 | Hangar descent | A freight ramp and stair down through the drone hangar. **E14** a Sidearm Guard on a gantry and a Security Drone (two known types together). **Secret 2:** a maintenance crawlway behind a breakable vent panel (a cartridge). |

## A04 Training cells (7,000): Adam's lockdown

The lockdown as built (the sandbox lockdown, the racks on their pads, the upper ledge, the TERMINATED screens), lengthened with cell rooms between the lanes. No enemy ever stands on a moving lane.

| x | Room | What happens |
| --- | --- | --- |
| 0–1,200 | Cell block | The lockdown starts (built). **E15** two Staffers step out of an open glass cell. |
| 1,200–2,600 | Lane 1 + cell room A | Lane 1 (built). Cell room A: server racks behind glass walls (breakable, chips inside one); **E16** a Night Guard. |
| 2,600–4,100 | Lane 2 + Dave's desk | Lane 2 (built); Dave's old desk pod with EF02 (built). |
| 4,100–5,600 | Lane 3 + server hall | Lane 3 (built). **E17** in the server hall: two Staffers and a Security Drone. The side pod's two dormant Staffers (optional, as v1). |
| 5,600–7,000 | Sandbox control | The control desk and its wall of screens. **E18** a Sidearm Guard behind the desk (low cover for both) and a Night Guard. **CP03.** |

## A05 The Lattice (6,000, tall): climbing around Adam's mind

| x | Room | What happens |
| --- | --- | --- |
| 0–1,300 | Atrium floor | The reception desk, a data courier cart, the hologram above. **E19** a Night Guard and a handler with a Hound (three attackers, the budget's limit). |
| 1,300–3,000 | Catwalk tiers | Catwalks hung on cables, a **glass lift** cycling between two tiers (a moving platform), stairs between landings. **E20** the main landing (as v1): a Sidearm Guard one step up, a Security Drone circling the open side. **E21** two Staffers on the upper catwalk. |
| 3,000–4,600 | Projector ring | A ring catwalk round the hologram's projector. **Set piece S5, the projector purge:** the projector's cooling vents fire steam in sequence along the ring (H1 vents, timed as a wave Dave rides behind). **E22** two Sidearm Guards at the ring's two ends, each beside a high pillar. |
| 4,600–6,000 | Console level | **CP04**, the alignment console scene (built), then the stair down to the exit. Quiet. |

## A06 Showroom and freight lift (7,400): the exhibits wake, hold the lift

| x | Room | What happens |
| --- | --- | --- |
| 0–1,400 | Loading entry | Crated prototypes, a parked lifter, **conveyors (H3)** carrying crates (moving floor sections; Dave rides them; the crates are breakable). **E23** a Night Guard and a Staffer. |
| 1,400–3,600 | Showroom floor | A glossy floor, display plinths on turntables under spotlights, covered prototypes, banners with the abstract arch. **Set piece S6, the exhibits wake:** a plinth's spotlight turns amber, its cover drops, and a Patrol Rover drives off it; two in turn, each stalling against the next plinth (backstops). **E24** a Sidearm Guard on the showroom balcony. |
| 3,600–4,800 | Demo stage | A raised stage with a big screen running Adam's product loop. Two display cases release a Security Drone each; **E25** with a Night Guard. The optional loading dock below (built: its Patrol Rover and the 20-chip cache). |
| 4,800–7,400 | Lift lobby | **CP05** at the lobby's entry. **Set piece S7, the hold-out:** the keycard calls the freight lift; it takes 45 s to come up (its floor counter on the door). Three finite waves from two lit service doors, each door's light going amber before it opens, and a wave only when the one before is down (so never more than three attackers): a handler and a Hound; then two Night Guards; then a Sidearm Guard and a Security Drone. Cover crates and a raised loading platform. The lift arrives, Dave steps in, Adam's showcase line (built). |

## Set pieces, hazards and breakables (to build)

| Id | What | Built from |
| --- | --- | --- |
| H1 | Steam vent: a floor vent on a cycle, amber hiss light then a steam column that hurts (1) and pushes gently up | new hazard (cycle, tell, damage area) |
| H2 | Live cable: arcs along a floor strip on a cycle after an amber spark warning | the same hazard, a different look |
| H3 | Conveyor: a moving floor section that carries Dave and crates | moving-platform physics (surface velocity) |
| S1 | Drill: test dummies pop up from hatches and drop from rails; all down opens a tray | PracticeTarget + a sequencer + ChipCache |
| S2 | Range goes live: target carriers drop sliding armoured plates (moving low cover) | MovingPlatform (no collision with Dave's floor) + a beat trigger |
| S3 | Kennel pods: pods unlock in turn and release Hounds | EncounterGroup `wait_for_trigger` + an opening pod prop |
| S4 | Launch rack: launches a drone every 6 s, three in all; breakable clamps stop it | a spawner + breakables |
| S5 | Projector purge: vents fire in a wave along the ring | H1 vents with a shared sequencer |
| S6 | Exhibits wake: a plinth's cover drops and a Rover drives off | EncounterGroup trigger + a plinth prop |
| S7 | Lift hold-out: 45 s, three finite door waves | ExitWicket `override_time` and `reinforcement_groups` (C41's hold-out, built) |
| — | Breakables: glass panel, monitor, server cabinet, crate, gauge (each with a broken state, debris and a sound), some holding chips or a cartridge; a breakable wall opens a secret room | new: a HitZone with health and a broken state |
| — | Background life: drones crossing, gondola, cleaning bots, carriers, robot arms, conveyor crates, screens | scenery with simple motion |

## Checkpoints, microchips and upgrades (v2)

Seven checkpoints (CP00, the new CP00b in the pump hall, CP01–CP05), one workbench (A03). Microchips: about 60 on the main route (the economy's Level 2 figure), placed past fights, on the platforming and in breakables, plus the drill tray (10), the launch-rack tray (5), the secret armory tray (5) and the optional dock cache (20). Feed cartridges about every second fight. The evidence file stays optional on Dave's desk.

## What has to be built (v2)

| Kind | Items |
| --- | --- |
| Systems | Breakables (HitZone with health, broken state, debris, optional reward); hazards H1/H2 (cycle, tell, damage area) and H3 conveyors; the drill sequencer (S1); moving cover plates (S2); triggered pods and plinths (S3, S6, reusing EncounterGroup triggers); the launch rack spawner (S4); the vent wave (S5); the hold-out (S7, built); the CP00b checkpoint; background motion props. |
| Layout | All six areas rebuilt to the v2 tables, with supported platforms, stairs and room seams; a new route-bot route; the fairness and encounter tests redone for 28 encounters. |
| Art (Batch 8: six area keyframes first, then sheets) | One backdrop per area (coolant plant, firing range, kennel, flight cage, training cells, showroom; the atrium keeps its own); two architecture kits (catwalks, stairs, supports, fascia, doors); a foreground sheet; props per area; breakables with broken states; hazards; background-life sprites. |
| Audio (when the user asks for ElevenLabs) | Steam hiss and vent, cable arc, glass shatter, monitor spark, crate split, conveyor hum, pod unlock, drone launch, lift call and arrival; Adam's range line. |

Previous version: [Curfew](l02-curfew.md) (superseded by C59). Owned by the level briefs; the campaign summary in [campaign.json](campaign.json) and the [main concept](../dead-eden-concept.md) need updating on approval.
