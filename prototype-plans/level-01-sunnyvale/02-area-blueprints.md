# 02 — Six-area build blueprints

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

## Common layout rules

Every area is a child scene on one continuous side-view route. Use hero height H as the blockout scale. First-pass values: hero H = 96 px, run about 4H/s, jump apex 1.6H. Main-route gaps start at 0.8–1.8H and never exceed 2H before testing; ordinary rises are 0.4–0.9H. Optional jumps may approach 2.4H after the controller proves them. Tune values, not the player's ability list.

Use fixed, broad landing surfaces and a clear 2H retreat space near combat. Camera exposes hazards before the hero commits. Moving geometry has visible supports and pauses/returns if it would crush the hero. No enemy begins an attack while spawning, behind an unpreviewed door, or directly on a landing.

All enemy counts below are the total placed population, not simultaneous waves. Limit combat groups to two active enemies and one committed attacker at a time. Encounters activate from a visible approach and leash to their authored lane; entering the next group cannot accumulate a hidden mob. Progress normally permits bypassing enemies; no door depends on kill-all unless a later revision explicitly documents it.

## L01-A01 — Perimeter gate

**Budget:** 75 seconds. **Population:** 0 Residents, 0 Clippers. **Main-route treasure:** 5 gems.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A01-B01 | 20s | Arrival and route read |
| L01-A01-B02 | 20s | Two low steps and short jump |
| L01-A01-B03 | 20s | Inert shooting target |
| L01-A01-B04 | 15s | Gem trail and open gate |

**Entry and silhouette:** Broken perimeter service gate at left; the smiling clock is a distant right-side landmark. The hero starts with W01 instance W01-P01. Set CP00 with six health and zero gems.

**Geometry and lesson:** Broad flat apron, two low ledges, then one short gap with a walkable catch floor. Put the inert target beyond a clear shooting lane; it reacts to shots but awards nothing and does not lock the gate. Prompts show once and disappear after successful input. No mandatory tutorial dialog.

**Reward and recovery:** Five small gems trace achievable landings. Missing the first gap drops to safe ground with no damage. Target shots consume no ammo. A01 is completely free of hostile enemies.

**Exit:** Open physical gate to A02. It requires no key, kill, collected gem, or hidden input.

## L01-A02 — Front gardens

**Budget:** 150 seconds. **Population:** 2 Residents, 2 Clippers. **Main-route treasure:** 10 gems.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A02-B01 | 30s | First Resident in isolation |
| L01-A02-B02 | 30s | First Clipper beside stone planter |
| L01-A02-B03 | 25s | Garden-wall jump trail |
| L01-A02-B04 | 25s | Resident in the next yard |
| L01-A02-B05 | 25s | Second Clipper practice lane |
| L01-A02-B06 | 15s | Safe porch and recovery station |

**Entry and silhouette:** Two original garden yards form the front half. Add two connected rear-yard practice pockets before the porch exit. Use the selected A02 scene for shapes, never for collision guessing.

**Enemies:** E01 teaches a Resident alone. E02 teaches a Clipper alone beside an indestructible stone planter that ends its charge. E03 and E04 repeat the individual patterns in changed geometry, with no simultaneous ranged or airborne threat. Each enemy has a clear grounded approach, retreat floor, and visible warning before damage.

**First Clipper setup:** Show the stone backstop, safe jumping space, and a raised observation step in the same camera view. Its stalled wheels and exposed rear motor explain the opening. The hero can jump past its charge and shoot the rear; no special dash is needed. A short optional hint follows repeated ineffective frontal hits.

**Rewards:** Five loose small gems and one five-value cluster, all reachable with ordinary movement. OPT01 leaves near B03 via porch steps, passes an untouched breakfast and family portrait, and reaches the optional A01 Welcome Key in a loft. Collect with Interact, then rejoin B04. No ladder or new gun. The artifact adds zero gems.

**Recovery:** A two-health capsule HS01 sits on a safe shelf before E04 and remains if health is full. CP01 on the final quiet porch fully heals and commits on Interact. This extra recovery station prevents a long return to the entrance.

**Exit:** Porch steps lead up to A03. The low practice route loops back, never bypasses required story or traps the hero.

## L01-A03 — Rooftop walk

**Budget:** 135 seconds. **Population:** 2 Residents, 0 Clippers. **Main-route treasure:** 10 gems.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A03-B01 | 25s | Porch-step ascent |
| L01-A03-B02 | 30s | First moving-platform crossing |
| L01-A03-B03 | 25s | Resident on broad far terrace |
| L01-A03-B04 | 30s | Roof-height sequence and second Resident |
| L01-A03-B05 | 25s | Safe descent and recovery station |

**Entry and silhouette:** Three broad roof terraces with a visible service lane below. Clock remains the navigation landmark. Enter from normal porch steps.

**Traversal:** First demonstrate a moving maintenance platform over shallow recovery ground. Keep its travel path and both boarding ledges visible. Missing it returns via the service lane and stepped ledges in about 15–20 seconds, without a mandatory fight or damage. The far terrace's Resident E05 stands at least 2H beyond the landing. B04 combines a short static roof sequence with E06 on another broad landing; E05 must not chase into that group.

**Rewards:** Five loose small gems and one five-value cluster on the main roof path. OPT02 begins after the first safe landing and uses ordinary roof steps to a separate 20-value cache; rejoin before the final descent. No artifact is hidden inside this cache. The optional branch is visible from the route.

**Recovery:** No enemies in the lower recovery lane. CP02 at the protected descent saves roof progress and collected treasure. Falls in this tutorial area are ordinary recovery, not lethal pits.

**Exit:** Broad descending terraces lead to A04; preview the square before leaving safety.

## L01-A04 — Neighborhood square

**Budget:** 165 seconds. **Population:** 4 Residents, 2 Clippers. **Main-route treasure:** 20 gems.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A04-B01 | 20s | Clock and fountain overlook |
| L01-A04-B02 | 30s | First mixed encounter |
| L01-A04-B03 | 20s | Raised flowerbed traversal |
| L01-A04-B04 | 25s | Two staggered Residents |
| L01-A04-B05 | 20s | Service-walkway switch |
| L01-A04-B06 | 25s | Second mixed encounter |
| L01-A04-B07 | 25s | Quiet far porch and recovery station |

**Entry and silhouette:** Clock/depot to the right, fountain in the middle ground, and a clear raised flowerbed on the play plane. The fountain itself does not block firing lanes.

**Combat sequence:** E07 is one Clipper plus one Resident on separated approach lanes. A central step lets the hero separate them. E08 is two Residents entering lunge range at staggered times. E09 repeats one Clipper plus one Resident after a traversal break. Each group has two enemies total, only one attack windup/active attack at a time, and a retreat lane that does not aggro another group.

**Traversal and switch:** Raised beds reward planned jumps. B05 adds one visible hand lever SW01 that extends a short service walkway across a small channel. Show the destination and matching symbol before activation. Interact is repeatable/idempotent; it never retracts under the hero. This is an ordinary switch, not a puzzle that demands a weapon upgrade.

**Rewards:** Ten small gems and two five-value clusters distributed across B01–B06. The cumulative main-route availability now equals 45, enough for Quickcycle without a secret. Reward positions remain reachable if enemies are bypassed; enemies do not drop gems.

**Recovery:** HS02 before E09 restores two health if needed. CP03 on the quiet far porch commits before the depot. Keep the final fight away from the checkpoint activation zone.

**Exit:** Unlocked depot doorway beneath the smiling clock. It does not require all enemies dead, 40 gems, or artifact ownership.

## L01-A05 — Maintenance depot

**Budget:** 90 seconds. **Population:** 0 Residents, 0 Clippers. **Main-route treasure:** 0 gems.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A05-B01 | 15s | Workshop and mounted core |
| L01-A05-B02 | 20s | Release latch triggers EDEN |
| L01-A05-B03 | 15s | Read transformed exit and save |
| L01-A05-B04 | 25s | Optional Quickcycle purchase |
| L01-A05-B05 | 15s | Practice target and emergency hatch |

**Entry and silhouette:** Compact safe workshop. The floor-mounted power core, care console, fixed bench, and emergency hatch are distinct props. The core has no face, limbs, or personality.

**Story action:** Interact with SC01's release latch. The protective housing locks, the care console shows active ward circuits, and central EDEN wakes. Normal scene treatment is approximately 20 seconds and skippable. Brief subtitles and visual changes carry the meaning without voice acting. The core remains installed. Open the emergency hatch and switch the environment state once.

**Save boundary:** On completion or skip, record awakening_done, core_installed, hatch_open, and the exit objective together at CP04. A death or reload must never re-enact extraction or relock the hatch. This story save preserves current health; nearby bench service separately heals.

**Upgrade:** Bench UPG01 becomes available after the event. It offers Quickcycle for 40 gems and shows the resulting cadence and wallet. Purchase is optional; the base pistol can finish the level. No gems are awarded in this room.

**Swap proof:** At a separate stable pad, optionally exchange W01-P01 for another base Scrapjack instance W01-P02. The same weapon type keeps Level 2's shotgun reveal intact. Distinguish instances by a small workshop tag, not a new weapon variant. The previous gun occupies that exact pad. A purchased type-wide stage applies to either copy when picked up. The pad is clear of the bench's interaction range; use an inert target for trials. No reload/ammo system is added.

**Exit:** Leave by the lit hatch toward A06. A brief objective tells the player to reach the garden wicket, not to fight EDEN.

## L01-A06 — Alarm exit

**Budget:** 135 seconds. **Population:** 1 Residents, 2 Clippers. **Main-route treasure:** 0 gems.

| Beat | Target | Action |
| --- | ---: | --- |
| L01-A06-B01 | 25s | Preview quarantine rails |
| L01-A06-B02 | 25s | Familiar Clipper lane |
| L01-A06-B03 | 25s | Safe raised path and settled panels |
| L01-A06-B04 | 35s | Final Resident and Clipper encounter |
| L01-A06-B05 | 25s | Service wicket and completion |

**Entry and silhouette:** Familiar garden forms under quarantine light. Flower lamps swivel into examination lights, fences guide toward the wicket, and the ceiling projection looks artificial.

**Safe transformation:** Panels settle ahead of the player while the entry landing stays fixed. Re-entering the area after a retry applies the completed arrangement directly; it never replays a dangerous transition around a spawned hero. No countdown, chase enemy, or moving-floor ambush.

**Test of learning:** E10 is one familiar Clipper with a stone backstop. A fixed raised path then gives breathing room. E11 combines one Resident and one Clipper under the same one-attacker rule as the square. Both are optional to kill if a clean route is taken; the wicket stays reachable. Quickcycle should feel useful, never required.

**Recovery and reward:** HS03 before E11 offers two health. A marked low hazard drop in B03 may test the one-health pit return; its reset foothold is fixed and free of enemy attacks. Zero health uses CP04 or the later complete bench/purchase snapshot. No gems or new equipment are necessary here.

**Exit:** Crossing the service wicket commits CP05 and shows completion. Display time, gems found out of 65, optional artifact found, and upgrade obtained. Gems found is a collection total, distinct from the wallet after spending. Offer replay/new run and quit; no Level 2 scene is required.

## Encounter registry

Enemy instances use E##-Z01-01 or E##-R01-01 suffixes under the level ID. Persist individual defeated IDs, not just a group's cleared flag; surviving enemies can restart in safe idle positions on reload.

| Group | Beat | Residents | Clippers |
| --- | --- | ---: | ---: |
| L01-E01 | L01-A02-B01 | 1 | 0 |
| L01-E02 | L01-A02-B02 | 0 | 1 |
| L01-E03 | L01-A02-B04 | 1 | 0 |
| L01-E04 | L01-A02-B05 | 0 | 1 |
| L01-E05 | L01-A03-B03 | 1 | 0 |
| L01-E06 | L01-A03-B04 | 1 | 0 |
| L01-E07 | L01-A04-B02 | 1 | 1 |
| L01-E08 | L01-A04-B04 | 2 | 0 |
| L01-E09 | L01-A04-B06 | 1 | 1 |
| L01-E10 | L01-A06-B02 | 0 | 1 |
| L01-E11 | L01-A06-B04 | 1 | 1 |

**Totals:** 32 beats, 11 groups, 9 Residents, 6 Clippers. The two optional branches add discovery, not enemies.
