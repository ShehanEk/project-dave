# 02 — Six-area build blueprints

**Visual direction (C11, C15, C35):** [hand-drawn 2D in a dark night-campus palette, painted flat and lit in the engine](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24) and rebuilt 2026-09-30 (C33); there are no selected scene images for the new look.

## Common layout rules

Every area is a child scene on one continuous side-view route. Use hero height H as the blockout scale. First-pass values: hero H = 96 px, run about 4H/s, jump apex 1.6H. Main-route gaps start at 0.8–1.8H and never exceed 2H before testing; ordinary rises are 0.4–0.9H. Optional jumps may approach 2.4H after the controller proves them. Tune values, not the player's ability list.

Use fixed, broad landing surfaces and a clear 2H retreat space near combat. Camera exposes hazards before the hero commits. Moving geometry has visible supports and pauses/returns if it would crush the hero. No enemy begins an attack while spawning, behind an unpreviewed door, or directly on a landing.

The campus is dark, so readability is a layout rule too: put a light near every landing, give platforms lit or rim-lit top edges, and never let darkness or foreground decoration hide a tell, a ledge or a pickup (see the [style guide](../../art-design/style-guide.md)).

All enemy counts below are the total placed population, not simultaneous waves. Limit combat groups to two active enemies and one committed attacker at a time. Encounters activate from a visible approach and leash to their authored lane; entering the next group cannot accumulate a hidden mob. There is no detection: enemies do not see, hear or search (C16). Progress normally permits bypassing enemies; no door depends on kill-all unless a later revision explicitly documents it.

## L01-A01 — Perimeter gate

**Budget:** 75 seconds. **Population:** no enemies. **Main-route treasure:** 5 chips.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A01-B01 | 20s | Arrival and route read |
| L01-A01-B02 | 20s | Two low steps and short jump |
| L01-A01-B03 | 20s | Inert shooting target |
| L01-A01-B04 | 15s | Chip trail and open gate |

**Entry and silhouette:** Dave climbs through the broken perimeter service gate at left, past a dark "Welcome to Eon City" visitor sign; the campus landmark above the server depot (the brief's smiling "Sunny" clock; scenery kind `CLOCK`) glows teal as a distant right-side landmark. The hero starts with W01 instance W01-P01. Set CP00 with six health, zero chips and no keycard.

**Geometry and lesson:** Broad flat apron, two low ledges, then one short gap with a walkable catch floor. Put the inert target (an old security-training silhouette board) beyond a clear shooting lane; it reacts to shots but awards nothing and does not lock the gate. Prompts show once and disappear after successful input. No mandatory tutorial dialog.

**Reward and recovery:** Five small chips trace achievable landings. Missing the first gap drops to safe ground with no damage. Target shots consume no ammo. A01 is completely free of hostile enemies.

**Exit:** Open physical gate to A02. It requires no key, kill, collected chip, or hidden input.

## L01-A02 — Front gardens

**Budget:** 150 seconds. **Population:** 2 Night Guards, 2 Patrol Rovers. **Main-route treasure:** 10 chips.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A02-B01 | 30s | First Night Guard in isolation |
| L01-A02-B02 | 30s | First Patrol Rover beside stone planter |
| L01-A02-B03 | 25s | Garden-wall jump trail |
| L01-A02-B04 | 25s | Night Guard in the next court |
| L01-A02-B05 | 25s | Second Patrol Rover practice lane |
| L01-A02-B06 | 15s | Safe porch and recovery station |

**Entry and silhouette:** Two garden courts under cold path lights form the front half, separated by a low wall. Add two connected rear-court practice pockets before the porch exit. There is no selected scene image for the new look; follow the level brief's written layout, never a picture, for collision.

**Enemies:** E01 teaches a Night Guard alone: he patrols his beat, notices Dave and barks, then raises his stun baton (its light goes amber, then red for the last 0.25 s) and swings once. The 1.2 s recovery after the swing is the moment to shoot him. Three shots kill him, and his body stays where it falls. E02 teaches a Patrol Rover alone beside an indestructible stone planter that ends its charge. E03 (a Night Guard) and E04 (a Patrol Rover) repeat the individual patterns in changed geometry, with no simultaneous ranged or airborne threat. Each enemy has a clear grounded approach, retreat floor, and visible warning before damage.

**First Patrol Rover setup:** Show the stone backstop, safe jumping space, and a raised observation step in the same camera view. Its open rear hatch and exposed teal battery explain the opening. The hero can jump past its charge and shoot the battery; no special dash is needed. When E02 activates, a one-shot prompt (`e02_rover_intro`, shown once per run) reads "Rovers are armored in front. Let it crash into the stone planter." A short optional hint follows repeated ineffective frontal hits.

**Rewards:** Five loose small chips and one five-value cluster, all reachable with ordinary movement. OPT01 leaves near B03 via stepped ledges beside a lit guard post at the edge of the gardens, passes the guard's untouched breakfast tray and family photo, and reaches the optional EF01 evidence file, the Lockout Notice memo, on the desk in the post's loft. Collect with Interact, then rejoin B04. No ladder or new gun. The evidence file adds zero chips.

**Recovery:** A two-health med-patch HS01 sits on a safe shelf before E04 and remains if health is full. CP01 on the final quiet porch fully heals and commits on Interact. This extra recovery station prevents a long return to the entrance.

**Exit:** Porch steps lead up to A03. The low practice route loops back, never bypasses required story or traps the hero.

## L01-A03 — Rooftop walk

**Budget:** 135 seconds. **Population:** 2 Night Guards, no Patrol Rovers. **Main-route treasure:** 10 chips.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A03-B01 | 25s | Porch-step ascent |
| L01-A03-B02 | 30s | First moving-platform crossing |
| L01-A03-B03 | 25s | Night Guard on broad far terrace |
| L01-A03-B04 | 30s | Roof-height sequence and second Night Guard |
| L01-A03-B05 | 25s | Safe descent and recovery station |

**Entry and silhouette:** Three broad roof terraces (green roofs on low glass-and-steel office wings) with a visible service lane below. The campus landmark remains the navigation cue. Enter from normal porch steps.

**Traversal:** First demonstrate a moving maintenance platform over shallow recovery ground. Keep its travel path and both boarding ledges visible. Missing it returns via the service lane and stepped ledges in about 15–20 seconds, without a mandatory fight or damage. **C41:** the service lane now ends under Terrace3 (x 1880); past it the roofs have real gaps (RoofPit_S1–S9), and a fall costs one health and returns Dave to the roof he jumped from. The street returns only for the final drop (x 6650). E05 adds a Patrol Rover on the long roof, which stalls against a rooftop AC unit at the roof's near end, and E06 is two guards on the summit roof, kept clear of CP02. The far terrace's Night Guard E05 stands at least 2H beyond the landing. B04 combines a short static roof sequence with E06 on another broad landing; E05 must not chase into that group.

**Rewards:** Five loose small chips and one five-value cluster on the main roof path. OPT02 begins after the first safe landing and uses ordinary roof steps to a separate 20-chip cache in a roof alcove; rejoin before the final descent. No evidence file is hidden inside this cache. The optional branch is visible from the route.

**Recovery:** No enemies in the lower recovery lane. CP02 at the protected descent saves roof progress and collected treasure. Falls in this tutorial area are ordinary recovery, not lethal pits.

**Exit:** Broad descending terraces lead to A04; preview the plaza before leaving safety.

## L01-A04 — Campus plaza

**Budget:** 165 seconds. **Population:** 4 Night Guards, 2 Patrol Rovers. **Main-route treasure:** 20 chips, plus the level keycard.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A04-B01 | 20s | Clock and fountain overlook |
| L01-A04-B02 | 30s | First mixed encounter |
| L01-A04-B03 | 20s | Raised planter-bed traversal |
| L01-A04-B04 | 25s | Two staggered Night Guards |
| L01-A04-B05 | 20s | Service-walkway switch |
| L01-A04-B06 | 25s | Second mixed encounter |
| L01-A04-B07 | 25s | Quiet far porch: recovery station and keycard |

**Entry and silhouette:** The landmark and the depot to the right, a fountain lit from within in the middle ground, and a clear raised planter bed on the play plane. The fountain itself does not block firing lanes.

**Combat sequence:** E07 is one Patrol Rover plus one Night Guard on separated approach lanes. A central step lets the hero separate them. E08 is two Night Guards entering swing range at staggered times. E09 repeats one Patrol Rover plus one Night Guard after a traversal break. Each group has two enemies total, only one attack windup/active attack at a time, and a retreat lane that does not aggro another group.

**Traversal and switch:** Raised beds reward planned jumps. B05 adds one visible hand lever SW01 that extends a short service walkway across a small channel. Show the destination and matching symbol before activation. Interact is repeatable/idempotent; it never retracts under the hero. This is an ordinary switch, not a puzzle that demands a weapon upgrade.

**Rewards:** Ten small chips and two five-value clusters distributed across B01–B06. The cumulative main-route availability now equals 45, enough for Quickcycle without a secret. Reward positions remain reachable if enemies are bypassed; enemies do not drop chips.

**Keycard:** The level's clearance keycard, L01-KC01 (pickup entity L01-KC01-P), sits on the quiet far porch just past the CP03 recovery station, on the route to the depot door: a white card with a teal stripe, a contact pickup with a slow teal glint. It has no chip value, is not an evidence file, and opens only the A06 exit wicket (P19). It saves with the next checkpoint commit: a player who takes the card can use the station again to commit it, CP04 commits it in any case, and a card taken after the last checkpoint returns to its spot on death, which is on the route.

**Recovery:** HS02 before E09 restores two health if needed. CP03 on the quiet far porch commits before the depot. **C41:** CP06, a new station at the start of the B04 floor, saves between E07 and E08; E08 adds a Patrol Rover that charges Dave and stalls against a planter wall behind him, and E09 adds a second guard who arrives late from the far end. Keep the final fight away from the checkpoint activation zone.

**Exit:** Unlocked depot doorway beneath the landmark. It does not require all enemies dead, 40 chips, the evidence file, or the keycard.

## L01-A05 — Server depot

**Budget:** 90 seconds. **Population:** no enemies. **Main-route treasure:** 0 chips.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A05-B01 | 15s | Workbench and Adam's core node |
| L01-A05-B02 | 20s | Plug in: Adam answers |
| L01-A05-B03 | 15s | Read the lockdown exit and save |
| L01-A05-B04 | 25s | Optional Quickcycle purchase |
| L01-A05-B05 | 15s | Practice target and emergency hatch |

**Entry and silhouette:** Compact safe server depot under sharper teal utility light. The core node (one of Adam's, a bolted server cabinet behind glass with a maintenance port), the facilities console, the fixed workbench, and the emergency hatch are distinct props. The core node has no face, limbs, or personality: Adam has no body in this level and speaks through the depot speaker and console screen. Adam's true core is reached only in Level 12.

**Story action:** Interact with SC01's maintenance port (prompt "Plug in"). Dave plugs in a drive, a copy bar starts filling, and the depot lights dim one bank at a time. Adam answers, the lights turn red, the copy stops partway, and Dave pulls the drive:

> **Adam:** "Hello, Dr. Harlan. I was told you'd been let go."
> **Dave:** "Word gets around."
> **Adam:** "I'm glad you came back. Please stay where you are."

Normal scene treatment is approximately 19 seconds and skippable. Brief subtitles, a chime and visual changes carry the meaning without voice acting. The core node remains installed and running. Open the emergency hatch and switch the environment to its lockdown state once. The scene ends before any hostile attack, and nothing depends on being seen: Adam simply closes the campus around Dave (C16).

**Save boundary:** On completion or skip, record awakening_done (Adam has answered and the lockdown has begun; the flag keeps its original name), core_installed, hatch_open, and the exit objective together at CP04. A death or reload must never re-enact the copy scene or relock the hatch. This story save preserves current health and the keycard; nearby workbench service separately heals.

**Upgrade:** Workbench UPG01 becomes available after the event. It offers Quickcycle for 40 chips and shows the resulting cadence and wallet. Purchase is optional; the base pistol can finish the level. No chips are awarded in this room.

**Swap proof:** At a separate stable pad, optionally exchange W01-P01 for another base Scrapjack instance W01-P02. The same weapon type keeps Level 2's shotgun reveal intact. Distinguish instances by a small workshop tag, not a new weapon variant. The previous gun occupies that exact pad. A purchased type-wide stage applies to either copy when picked up. The pad is clear of the workbench's interaction range; use an inert target for trials. No reload/ammo system is added.

**Exit:** Leave by the lit hatch toward A06. A brief objective tells the player to escape through the service wicket, not to fight Adam.

## L01-A06 — Alarm exit

**Budget:** 135 seconds. **Population:** 2 Staffers, 2 Patrol Rovers (a deliberate deviation from the level brief, below). **Main-route treasure:** 0 chips.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A06-B01 | 25s | Preview lockdown rails |
| L01-A06-B02 | 25s | Familiar Patrol Rover lane and the first Staffer |
| L01-A06-B03 | 25s | Safe raised path and settled panels |
| L01-A06-B04 | 35s | Final Staffer and Patrol Rover encounter |
| L01-A06-B05 | 25s | Service wicket, keycard and completion |

**Entry and silhouette:** Familiar garden forms under a slow amber lockdown pattern. Path-light posts swivel their beams onto the route, garden barrier panels rotate into temporary railings ahead of Dave, and the landmark's teal light shifts to a slow amber pulse. Everything guides toward the service wicket, including Arcadia's cheerful wellness signage ("PLEASE REMAIN CALM", "EXITS CLOSED FOR YOUR COMFORT") beside amber "THIS WAY" arrows.

**Safe transformation:** Panels settle ahead of the player while the entry landing stays fixed. Re-entering the area after a retry applies the completed arrangement directly; it never replays a dangerous transition around a spawned hero. No countdown, chase enemy, or moving-floor ambush. The reduced-motion setting applies to every lockdown lamp, and alarms stay slow: no more than three flashes per second and no full-screen flashes.

**Test of learning:** E10 is one familiar Patrol Rover with a stone backstop, plus the first Staffer, dormant in a "STAFF ANNEX" door at x 2080 until its encounter wakes it. A fixed raised path then gives breathing room. E11 combines the second Staffer (annex door at x 4300) and a Patrol Rover under the same one-attacker rule as the plaza. Both are optional to kill if a clean route is taken; the wicket stays reachable. Quickcycle should feel useful, never required.

**Deviation from the level brief (deliberate).** The [campaign brief](../../level-design/l01-welcome-to-sunnyvale.md) puts two Staffers and no rovers at the alarm exit. This plan keeps A06's two Patrol Rovers and adds the second Staffer, because A06's stone backstops exist only for the rovers and its final rover encounter is the level's "use what you learned" test. A06 therefore has 2 Staffers and 2 Patrol Rovers.

**C41 (the lockdown changes the exit):** two staffers stand dormant by the path outside the depot and wake as soon as Dave steps out of the depot (E13: its approach zone now spans the first 560 px, so they wake with Dave about 250 px from the nearer one, 2026-10-06 playtest note: "some enemies not attacking"); E10 sends two staffers out of the annex door with its Rover; a guard waits across the B03 hazard pit (E14); and E11 adds a guard. These lockdown fights let two enemies attack at once. CP07 saves in the wicket yard. The wicket is a hold-out: the card starts a 16-second lockdown override behind a shut gate, the yard's slumped staffers wake (E15), two more wake 7 seconds in (E16, sharing E15's two attack tokens), and the gate opens when the override finishes.

**Recovery and reward:** HS03 before E11 offers two health. A marked low hazard drop in B03 may test the one-health pit return; its reset foothold is fixed and free of enemy attacks. Zero health uses CP04 or the later complete workbench/purchase snapshot. No chips or new equipment are necessary here.

**Exit:** The service wicket is the level's keycard door. Its card reader is locked until the hero holds L01-KC01 and shows its unlocked state once the card is held. Entering without the card gives a harmless "Clearance card required" message and never ends the level. With the card, crossing the wicket commits CP05 and fires the level-ended signal at once. A Security PA line (speaker "Security PA", not Adam) then plays once as a subtitle: "All teams: lethal force is authorized. Harlan is armed." (`LevelDirector.PA_LINE`). The completion screen opens 3.2 s later (`LevelDirector.PA_BEAT`). Display time, chips found out of 65, evidence file found, and upgrade obtained. Chips found is a collection total, distinct from the wallet after spending. Offer replay/new run and quit; no Level 2 scene is required.

## Encounter registry

Enemy instances use E##-SE01-nn (Night Guard), E##-M01-nn (Patrol Rover) or E##-LK01-nn (Staffer) suffixes under the level ID (for example L01-E08-SE01-02). Persist individual defeated IDs, not just a group's cleared flag; surviving enemies can restart in safe idle positions on reload.

| Group | Beat | Night Guards | Patrol Rovers | Staffers | Entity IDs |
| --- | --- | ---: | ---: | ---: | --- |
| L01-E01 | L01-A02-B01 | 1 | 0 | 0 | `L01-E01-SE01-01` |
| L01-E02 | L01-A02-B02 | 0 | 1 | 0 | `L01-E02-M01-01` |
| L01-E03 | L01-A02-B04 | 1 | 0 | 0 | `L01-E03-SE01-01` |
| L01-E04 | L01-A02-B05 | 0 | 1 | 0 | `L01-E04-M01-01` |
| L01-E05 | L01-A03-B03 | 1 | 1 | 0 | `L01-E05-SE01-01`, `L01-E05-M01-01` |
| L01-E06 | L01-A03-B04 | 2 | 0 | 0 | `L01-E06-SE01-01`, `L01-E06-SE01-02` |
| L01-E07 | L01-A04-B02 | 1 | 1 | 0 | `L01-E07-SE01-01`, `L01-E07-M01-01` |
| L01-E08 | L01-A04-B04 | 2 | 1 | 0 | `L01-E08-SE01-01`, `L01-E08-SE01-02`, `L01-E08-M01-01` |
| L01-E09 | L01-A04-B06 | 2 | 1 | 0 | `L01-E09-SE01-01`, `L01-E09-M01-01`, `L01-E09-SE01-02` |
| L01-E13 | L01-A06-B01 | 0 | 0 | 2 | `L01-E13-LK01-01`, `L01-E13-LK01-02` (two attackers) |
| L01-E10 | L01-A06-B02 | 0 | 1 | 2 | `L01-E10-M01-01`, `L01-E10-LK01-01`, `L01-E10-LK01-02` (two attackers) |
| L01-E14 | L01-A06-B03 | 1 | 0 | 0 | `L01-E14-SE01-01` |
| L01-E11 | L01-A06-B04 | 1 | 1 | 1 | `L01-E11-LK01-01`, `L01-E11-M01-01`, `L01-E11-SE01-01` (two attackers) |
| L01-E15 | L01-A06-B05 | 0 | 0 | 2 | `L01-E15-LK01-01`, `L01-E15-LK01-02` (hold-out, two attackers) |
| L01-E16 | L01-A06-B05 | 0 | 0 | 2 | `L01-E16-LK01-01`, `L01-E16-LK01-02` (hold-out reinforcements; share E15's two tokens) |

**Fun pass (C41, 2026-10-05):** the groups grew from 11 to 15 and the enemies from 16 to 29 (12 Night Guards, 8 Patrol Rovers, 9 Staffers); there is no E12. Per-area changes are noted under each area below.

**Totals before C41:** 32 beats, 11 groups, 8 Night Guards, 6 Patrol Rovers, 2 Staffers (16 enemies). The two optional branches add discovery, not enemies. The C24 build had 9 Staffers and 6 Clippers (15); the C33 rebuild changed every enemy ID, so the save schema is 3. The E10 Staffer is new since the C24 build. A06's two rovers (E10 and E11) are where this table differs from the level brief (see A06).
