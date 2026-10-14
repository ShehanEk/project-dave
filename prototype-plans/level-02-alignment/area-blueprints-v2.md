# Level 2 "Alignment" v2: area blueprints (R2 layout, R3 encounters)

From [L02 Alignment v2](../../level-design/l02-alignment.md) (C62). Supersedes [area-blueprints.md](area-blueprints.md) (v1). World px at Level 1's scale: H = 96 px, 55 px a metre. Each area's local origin is its entry seam, floor top at y = 0, up negative (AreaRoot contract: every area enters and leaves at y = 0). Dave runs 384 px/s, jumps 1.6 H (154 px), a level jump crosses about 300 px.

**Limits used here:** a step-up at most 120 px; a gap at most 240 px; no required jump into an unseen landing; P23: per screen at most 2 shooters and 3 attackers, guns reach at most 6.5 H (624 px) and fire only 1 H inside the camera, low cover 0.6 H, no pit edge within 1.5 H behind a standing spot in a gun lane; vents and arcs never under a landing or a checkpoint. Every number is a first pass, to tune in play.

**Ids** keep Level 1's pattern with the `L02-` prefix: encounters `L02-E01`… in route order (v2 renumbers them), enemies `L02-Exx-<type>-nn` (SE01 Night Guard, LK01 Staffer, M01 Patrol Rover, SE02 Sidearm Guard, K01 Hound, M02 Security Drone), chips `L02-Axx-Gnnn`, breakables with a reward or a secret `L02-Axx-BRnn`, cartridges `L02-Axx-AMnn`, the drill `L02-A01-DRILL01`, the rack `L02-A03-RACK01`, checkpoints `CP00`, `CP00B`, `CP01`–`CP05`, keycard `L02-KC01`, evidence `L02-EF02`, the pad `L02-A01-PAD01` resting `L02-W02-P01`.

**Kit (from R1):** Block (GROUND, PLATFORM with railing and hanger/column supports, ROOF, WALL, BACKSTOP, SCENERY_SOLID cover), stairs/ramps, room seams, breakables (glass panel, monitor, server cabinet, crate, gauge, vent panel, display case; `solid` secret walls), hazard vents (steam, cable), vent sequencer, conveyors, drill pad and pop-up targets, cover plates and the range controller, release props (pod, plinth, door), the launch rack, the hold-out waves; existing: rail racks, lane partitions, the keycard console, the freight lift (ExitWicket), recovery stations, the workbench, chips, chip caches, cartridges, evidence, scenery, decals, beat zones, route points.

## A01 Sky bridge and coolant plant (6,200)

| Room (x) | Floor / ceiling | Geometry | Play |
| --- | --- | --- | --- |
| Bridge 0–1,100 | y 0; outdoors (`wet_until_x` 1,100) | glass bridge floor; the bridge door at 1,120 under a lintel (1,100–1,140, y −460 to −260) | `Spawn_CP00` 150; beat `L02-A01-B01` 220–860 (the greeting); background life: gondola, drones |
| Airlock 1,140–1,600 | y 0 / −300 | ceiling; room seam (inner door) at 1,600 | **E01** 2 Night Guards at 1,350 and 1,480 |
| Pump hall 1,600–2,900 | y 0 / −560 | floor grating over the coolant channel 1,800–2,700 (visual); stairs up 1,700–1,950 to a catwalk at y −170 (1,950–2,650) on columns; pumps (scenery) under it | **H1** steam vents at 2,050, 2,300, 2,550 (offsets 0, 0.7, 1.4 s); **E02** Staffer floor 2,200, Staffer catwalk 2,400; breakables: 3 gauges, 2 sight glasses, a tool cart; `Respawn_CP00B` + recovery station 2,820 |
| Broom bay 2,900–4,200 | y 0 / −480 | mesh tool cage (scenery) 2,950–3,200; a deck at y −120 (3,850–4,150, columns) | swap pad 3,050 (as built); **S1** drill pad 3,350: 8 targets (hatches 3,550, 3,700, 3,950; rail drops 3,650 y −160, 3,900 y −160; deck 3,900 and 4,100; far hatch 4,150), 15 s, reward tray 10 chips at 3,250; beat `L02-A01-B02` |
| Pipe gallery 4,200–5,400 | y 0 / −300 | pipe platforms at y −150 (4,450–4,750, 4,950–5,250) hung from the ceiling; valve block BACKSTOP 48 × 72 at 4,420 | **E03** Patrol Rover patrolling 4,600–5,300, charging left into the valve block; **E04** Night Guard on the pipe at 5,050, drops when E03 is engaged; breakables: 2 gauges |
| Service stair 5,400–6,200 | y 0 / −520 | stairs up 5,450–5,700 to a landing at y −180 (5,700–6,000, columns); the floor continues under it | **E05** Night Guard floor 5,850, Staffer landing 5,900; breakable crate with `L02-A01-AM01` at 5,980 (landing); exit seam 6,200; beat `L02-A01-B03` |

Chips: 9 (G001–G009) along the bridge, catwalk, deck, pipes and landing. Camera: top −560 (pump hall), −300 in the airlock and gallery.

## A02 Firing range and K9 kennel (7,800)

| Room (x) | Floor / ceiling | Geometry | Play |
| --- | --- | --- | --- |
| Range lobby 0–1,100 | y 0 / −420 | check-in desk (SCENERY_SOLID cover 0.6 H) at 600; lockers; pistol display case (breakable) at 850 | **E06** Staffer clerk 520 (behind the desk), Night Guard 900 |
| Lane 1 1,100–3,300 | y 0 / −380 | flat lane; range bench cover 80 × 58 at 1,900; baffles and a moving target carrier (scenery) overhead | **E07** Sidearm Guard alone at 3,050 facing left, rooted (the introduction; the lane on camera before he fires); `L02-A02-AM01` at 1,250 |
| Control booth 3,300–4,300 | y 0 / −460 | stairs up 3,350–3,600 to the booth deck at y −160 (3,600–4,000, columns); **Secret 1**: a solid cracked glass wall `L02-A02-BR01` at 4,050–4,066 in front of the armory (4,066–4,280) on the floor | `Respawn_CP01` + recovery station 3,450 (floor); armory: `L02-A02-AM02` + a 5-chip tray |
| Live-fire lanes 4,300–5,600 | y 0 / −380 | the carrier rail at y −300; **S2** 3 cover plates sliding 4,500–4,800, 4,850–5,150, 5,200–5,450 | **E08** Sidearm Guard 5,050, Sidearm Guard 5,450, Night Guard from the side door at 4,700 (enters when the group activates); beat `L02-A02-B02` (Adam's range line) at 4,350 |
| Kennel row 5,600–6,700 | y 0 / −420 | 6 pods along the back wall (scenery) 5,700–6,600; kennel wall BACKSTOP 48 × 72 at 6,600 | **E09** handler 6,450 + Hound 6,300 (the introduction; backstop behind them) |
| Exercise yard 6,700–7,800 | y 0 / −480 | agility ramp (stairs kit, ramp) 6,800–7,000 up to a walkway at y −140 (7,000–7,500, columns); a hurdle 0.6 H at 7,200 (floor) | **S3** two pods (release props) at 6,900 and 7,150 open in turn after E09 (delay 1.5 s), one Hound each; **E10** handler on the walkway 7,300; exit up the dog-run ramp to the seam 7,800 |

Chips: 10. Breakables: the display case, 2 monitors in the booth, 2 lockers' glass, the feed station.

## A03 Flight cage (6,400; camera top −900)

| Room (x) | Floor / ceiling | Geometry | Play |
| --- | --- | --- | --- |
| Drone bay 0–1,500 | y 0 / −640 | charging racks (scenery); a workbench prop | **E11** Staffer tech 450; **E12** Security Drone alone over 1,100, y −300 (the introduction) |
| Cage climb 1,500–3,900 | y 0 / −900 | decks on columns: D1 y −140 (1,650–2,050), D2 y −280 (2,300–2,750), D3 y −420 (2,950–3,350), D4 y −560 (3,500–3,900); lifts L1 (2,100–2,250, y 0 ↔ −140), L2 (2,800–2,900, −280 ↔ −420), L3 (3,380–3,480, −420 ↔ −560); stairs between where a lift is not; the ground floor runs under all (the catch floor) | **S4** launch rack on the wall at 2,600, y −480: 3 drones, 1 every 6 s, max 2 live, clamps reward 5 chips on D3; **H2** live cables at 2,050 and 3,350 (D-bases); `L02-A03-AM01` at 1,600 |
| Observation room 3,900–5,000 | y −560 / −900 | the room on top (floor y −560) with a glass wall | `Respawn_CP02` + recovery 4,600, workbench 4,250 (≥ 3 H apart); **E13** Staffer at her workstation 4,050 (optional) |
| Hangar descent 5,000–6,400 | from −560 to 0 | stairs down 5,000–5,350 to a gantry at y −380 (5,350–5,800), stairs down 5,800–6,150 to the floor | **E14** Sidearm Guard on the gantry 5,700, Security Drone over 5,500; **Secret 2**: a vent panel `L02-A03-BR01` at 6,250 opening a crawlway with a cartridge `L02-A03-AM02`; exit seam 6,400 |

Chips: 10 (corners of D2–D4, the lifts' tops, the gantry).

## A04 Training cells (7,000)

The built lanes keep their mechanics; positions move to fit the cell rooms between them.

| Room (x) | Floor / ceiling | Geometry | Play |
| --- | --- | --- | --- |
| Cell block 0–1,200 | y 0 / −500 | glass cells (breakable fronts) along the back; upper ledge from 500 (as built) | the lockdown on `L02-A04-B01` (as built); **E15** 2 Staffers stepping out of a cell at 900, 1,050 |
| Lane 1 + cell room A 1,200–2,600 | trench 1,300–1,600 | rack and partition (as built); cell room A 1,700–2,550: server racks behind glass (2 breakables, one with chips) | **E16** Night Guard 2,200 |
| Lane 2 + desk 2,600–4,100 | trench 2,700–3,000 | as built | Dave's desk pod with EF02 at 3,400; screens |
| Lane 3 + server hall 4,100–5,600 | trench 4,200–4,500 | as built; server hall 4,600–5,500 (2 server cabinets breakable) | **E17** Staffer 4,900, Staffer 5,200, Security Drone over 5,050; the side pod's two dormant Staffers on the ledge (optional) |
| Sandbox control 5,600–7,000 | y 0 / −500 | the control desk (cover) 6,300, a wall of screens (breakable monitors) | **E18** Sidearm Guard behind the desk 6,450, Night Guard 6,100; `Respawn_CP03` + recovery 6,850; exit seam 7,000 |

Chips: 9.

## A05 The Lattice (6,000; camera top −1,000)

| Room (x) | Floor / ceiling | Geometry | Play |
| --- | --- | --- | --- |
| Atrium floor 0–1,300 | y 0 | reception desk (cover) 700; courier cart; the hologram centred at 2,600, y −500 | **E19** Night Guard 900, handler 1,150 + Hound 1,050; `L02-A05-AM01` at 400 |
| Catwalk tiers 1,300–3,000 | catwalks at y −160 (1,300–1,900) and −320 (2,000–3,000), hung on cables | stairs 1,300–1,550 up to tier 1; a glass lift (2,000–2,120, y −160 ↔ −320); the main landing on tier 2 with a raised step (96 px) at 2,700–3,000 | **E20** Sidearm Guard on the step 2,850, Security Drone circling 2,200–2,700 at y −560 (as v1's main landing); **E21** 2 Staffers on tier 2 at 2,100, 2,350 (wake after E20 starts) |
| Projector ring 3,000–4,600 | ring catwalk y −480 (3,000–4,600) with high pillars (1.2 H) at 3,150 and 4,450 | stairs 3,000–3,200 from tier 2 | **S5** a vent wave of 6 vents along the ring (3,300–4,300, spacing 0.35 s, rest 2 s); **E22** Sidearm Guards at 3,250 and 4,350, each beside its pillar |
| Console level 4,600–6,000 | y −640 (4,600–5,200), stairs down 5,200–5,900 | the console (as built) at 4,900 | `Respawn_CP04` + recovery 5,100; the console scene; exit seam 6,000 at y 0 |

Chips: 10.

## A06 Showroom and freight lift (7,400)

| Room (x) | Floor / ceiling | Geometry | Play |
| --- | --- | --- | --- |
| Loading entry 0–1,400 | y 0 / −460 | **H3** conveyors 300–700 and 800–1,200 (speed 90, with crates riding; breakable crates on the floor ends) | **E23** Night Guard 1,000, Staffer 1,250 |
| Showroom floor 1,400–3,600 | y 0 / −560 | plinths (BACKSTOP-sized solid bases) at 2,050, 2,800, 3,450; a balcony at y −220 (2,400–3,300, columns) with stairs 2,200–2,400 | **S6** plinth releases: Rover 1 from 2,050 (after E23 + 1 s, stalls against the 2,800 plinth), Rover 2 from 2,800 (after Rover 1 is down, stalls against 3,450); **E24** Sidearm Guard on the balcony 3,100; breakables: display cases 2 |
| Demo stage 3,600–4,800 | stage y −100 (3,700–4,500) with stairs | the big screen (breakable) 4,100; two display cases (release props, door variant) at 3,850 and 4,350 | **E25** 2 Security Drones from the cases + Night Guard 4,600; the optional loading dock below (as built, under 1,400–2,800 at y +160: its Rover and the 20-chip cache) |
| Lift lobby 4,800–7,400 | y 0 / −460 | cover crates (SCENERY_SOLID 0.6 H) at 5,600 and 6,300; a loading platform at y −120 (5,900–6,200, columns); two service doors (release props, door variant) at 5,200 and 6,900 | `Respawn_CP05` + recovery 4,950; the freight lift at 7,150 (ExitWicket, `override_time` 45 s); **S7** waves: (1) handler + Hound from 6,900; (2) 2 Night Guards from 5,200; (3) Sidearm Guard + Security Drone from 6,900; each wave after the one before is down |

Chips: 12 + the dock cache (20).

## Totals check

| Area | Width | Encounters | Enemies | Chips |
| --- | ---: | ---: | ---: | ---: |
| A01 | 6,200 | 5 | 8 | 9 + drill 10 |
| A02 | 7,800 | 5 | 11 | 10 + secret 5 |
| A03 | 6,400 | 5 | 8 | 10 + rack 5 |
| A04 | 7,000 | 4 | 8 (+2) | 9 |
| A05 | 6,000 | 4 | 9 | 10 |
| A06 | 7,400 | 5 | 14 (+1) | 12 + cache 20 |
| **Level** | **40,800** | **28** | **58 (+3)** | **60 main, 20 in set-piece trays, 20 cache** |
