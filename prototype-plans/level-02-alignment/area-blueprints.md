# Level 2 "Alignment": area blueprints (M2 greybox)

From [L02 Alignment](../../level-design/l02-alignment.md) (C59). World px, at Level 1's scale: H = 96 px (Dave), 55 px a metre. Each area's local origin is its entry seam: floor top at y = 0, up is negative (AreaRoot contract). Dave runs 384 px/s and jumps 1.6 H (154 px) high; a level jump crosses about 300 px. Design limits used here: step-ups at most 120 px, gaps at most 240 px, no required jump into an unseen landing. All numbers are first-pass and untested.

IDs follow Level 1's house pattern with the `L02-` prefix: areas `L02-A01`…, checkpoints `CP00`–`CP05` (markers `Spawn_CP00`, `Respawn_CPxx`), encounters `L02-E01`…, the keycard `L02-KC01`, the evidence file `L02-EF02`, the pad `L02-A01-PAD01` holding the Boom Broom `L02-W02-P01`.

Placeholder art until the lab sheets: Level 1's walkway, wall, terrain and props; every area except A01's bridge is `indoors = true` (no rain).

## A01 Sky bridge and coolant plant (width 2,800)

| x | What |
| --- | --- |
| 0–900 | The glass sky bridge, outdoors (rain on). `Spawn_CP00` at x 150. |
| 900 | The bridge door (built at x 920, M5): waits shut, opens when Dave is 360 px short of it, and locks once he is 100 px past it (Adam's entry line is subtitled on the bridge). |
| 900–2,800 | The coolant plant, indoors. |
| 1,300 | Swap pad `L02-A01-PAD01` with the Boom Broom, at least 3 H from any other interaction. |
| 1,600–2,600 | Practice yard: three practice targets (Level 1's PracticeTarget) at x 1,800, 2,050, 2,300; a 60 px step at x 1,950 (jump-shot practice). |
| along the route | 6 microchips. |

## A02 Range and kennel (width 5,200)

| x | What |
| --- | --- |
| 0–600 | Entry corridor. |
| 600–2,600 | The firing range lane: flat floor. **E01**: one Sidearm Guard at x 2,400, facing left, rooted. The range bench (low cover, 80 x 58 px, Dave can shoot over it) at x 1,500. The guard's lane is fully on camera before he fires. |
| 2,600–3,000 | Range control step (platform 96 px up, 2,650–2,900) with 2 microchips; `Respawn_CP01` and a recovery station at x 2,900 on the floor. |
| 3,000–5,000 | The kennel: kennel pods as background scenery; an optional ledge 3,400–3,700 at y −110 with 2 microchips. **E02**: Night Guard handler at x 4,600, Hound on lead at x 4,450; a solid kennel wall (backstop block 48 x 72) at x 4,900 behind them to stop the dog's overshoot. |
| along the route | 5 more microchips (9 in all). |

## A03 Flight cage (width 4,600, tall: camera top −640)

| x | What |
| --- | --- |
| 0–4,600 | Ground floor (the return path under every deck: a missed landing drops here, never into an unseen enemy). |
| 800–1,600 | Deck 1 at y −120 (step up from the floor). |
| 1,800–2,800 | Deck 2 at y −240, the widest. **E03**: one Security Drone hovering over x 2,300, y −420. |
| 3,000–3,800 | Deck 3 at y −360. **E04**: one Staffer (look B, the young researcher) at x 3,300 at a workstation by an open door; the deck is broad enough to jump past. |
| 3,800–4,500 | Observation room floor at y −360: workbench at x 4,000, `Respawn_CP02` and a recovery station at x 4,350 (prompts at least 3 H apart). |
| 4,500 | A drop-down to the ground floor (one-way), then the exit seam at x 4,600, y 0. |
| decks | 9 microchips, two of them on the high corners of decks 2 and 3. |

## A04 Training cells (width 5,400): Adam's lockdown

| x | What |
| --- | --- |
| 0–5,400 | Floor at y 0 with three cable trenches (floor drops 96 px; not lethal; a climb-out step at each end): trench 1 1,000–1,300, trench 2 2,400–2,700, trench 3 3,800–4,100. |
| each trench | A sliding server-rack platform (MovingPlatform, 200 x 24) that waits at the near bank until Dave presses that lane's control pad (x 900, 2,300, 3,700), then crosses with amber rail lamps, a chime and a caption; it never closes on Dave and pauses while he blocks the far bank. A glass partition at each far bank slides open as the rack arrives. |
| 500–5,000 | The fixed upper ledge at y −200 (steps up at x 500 and x 5,000): the recovery route that is always there. |
| 2,000 | Dave's old desk pod in an alcove off the lanes: the evidence file `L02-EF02` (Reassignment Memo). |
| 3,500 | A side pod on the upper ledge with two dormant Staffers (looks A and C; optional, never in the way). |
| 4,300 | From the upper ledge the freight lift's amber card reader is visible across the lab (a background sign). |
| on entry | Adam's lockdown (M5): emergency strips under the ceiling, the lab behind dimmed, six wall screens (x 760, 1,500, 2,000 over the desk, 2,950, 4,000, 4,700, at y −330) switching to Dave's file stamped TERMINATED. |
| 5,100 | `Respawn_CP03` and a recovery station. |
| racks | 9 microchips inside open server racks along the route. |

## A05 The Lattice (width 4,200, tall: camera top −800)

| x | What |
| --- | --- |
| 0–800 | Entry floor. The hologram (an animated light, no collision) centred at x 2,100, y −450. |
| 800–1,400 | Catwalk steps: y −120, −240. |
| 1,500–2,700 | The main landing at y −300, railed on its open side (no pit within 1.5 H behind any standing spot). **E05**: a Sidearm Guard on a raised step (96 px up) at x 2,500; a Security Drone circling over x 1,700–2,300 at y −520. |
| 2,800–3,600 | Steps up to the console level at y −600. |
| 3,300 | The alignment console (interact): gives `L02-KC01` and plays Adam's hologram line; `Respawn_CP04` and a recovery station at x 3,550. |
| 3,700–4,200 | Stairs down to the exit seam at y 0. |
| route | 8 microchips. |

## A06 Demo floor and freight lift (width 3,800)

| x | What |
| --- | --- |
| 0–1,200 | Entry; `Respawn_CP05` and a recovery station at x 1,100 (before the last fight). |
| 1,200–3,200 | Demo floor with crated prototypes (low cover). **E06**: a Night Guard handler at x 2,700 and a Hound at x 2,550; a crate stack (backstop block 48 x 72) at x 3,000. |
| 1,400–2,800 | Optional loading dock below, at y +160 (a ramp down at x 1,300–1,400): **E07**, a Patrol Rover patrolling 1,600–2,600 between backstop crates at both ends; a microchip cache at x 2,700. |
| 3,500 | The freight lift: the keycard door (amber reader while locked, teal once `L02-KC01` is held); interact to end the level. Exit PA line. |
| route | 4 microchips plus the cache. |

## Totals (to tune in play)

Main-route microchips 45, plus one cache; 6 checkpoints; 1 workbench; enemies: 2 Sidearm Guards, 2 Hounds with 2 handlers, 2 Security Drones, 1–3 Staffers, 1 optional Patrol Rover. At most two shooters and three attackers on a screen.
