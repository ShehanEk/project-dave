# DEAD EDEN — Weapon resources and ammunition

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Document ID:** S02  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Gives every weapon a distinct resource rhythm and keeps required encounters possible with any carried weapon.

**Decision references:** C04, C05, C06, P09 — see the [decision register](../decisions.md).  
**Read with:** [upgrades and ownership](upgrades-and-ownership.md) · [health and checkpoints](health-and-checkpoints.md) · [encounter and boss fairness](../04-world/encounter-and-boss-fairness.md) · [w02 boom broom](../../art-design/weapons/w02-boom-broom.md)

## Design intent
Resource management should change positioning and timing. It must not force the player to exchange a favorite weapon just to finish a mandatory room. The figures below are **proposed tuning seeds**, not final balance.

Only the held weapon's resource appears on the normal HUD. There is no reserve inventory for uncarried weapons. A dropped physical weapon keeps its ammunition, heat, and installed fittings.

## Resource table
| Weapon | Proposed base resource | Recovery | Empty or overheated behavior |
| --- | --- | --- | --- |
| Scrapjack Pistol | Unlimited basic shots from a low-output recycling cell; no magazine | Short firing interval; no reload | Stage-3 charge takes time, cannot be stored through a swap |
| Boom Broom | 4 loaded shells + up to 24 reserve shells | Insert shells individually, about 0.7 seconds per shell; Deep Clean raises loaded capacity to 6 | Can fire already loaded shells to interrupt reload; zero total shells requires resupply |
| Arc Welder | Heat 0–100; about 3 seconds continuous base fire to overheat | About 0.5 seconds delay then cool over roughly 2 seconds when idle | Overheat prevents firing until heat falls to 40; no damage to the hero from the tool itself |
| Seedlobber | 1 ready pod + up to 8 reserve pods | About 1.1 seconds to seat another pod; base fuse about 1 second after impact | Cannot fire without a seated pod; nearby explosions remain dangerous |
| Graviton Tether | One held target; no ammunition stock | About 0.5 seconds target lock and 0.7 seconds recovery after throw | Without a target, seek reachable props; there is no invisible fallback bullet |

The pistol's unlimited fire is a property of that weapon, not an always-carried emergency sidearm. Seedlobber numbers assume an impact-triggered fuse; a pod does not explode simply because the aim button was held. Keep a visible pulse during the fuse. Final damage, range, fire cadence, and enemy durability remain unbalanced.

## Resource behavior during other actions
Movement and jumping remain possible while reloading. A shotgun reload commits one shell at a time: cancelling preserves already inserted shells and unused reserve. A Seedlobber reload transfers one reserve pod only when seating completes. There is no duplicated round from cancelling an animation.

Swapping cancels unfinished charges and reload actions, preserves completed ammunition transfers, and never clears heat. An Arc Welder dropped into the world continues ordinary time-based cooling; swapping cannot reset the cooling timer. The newly held weapon shows its actual current resource.

A tether-held object must be released safely before a weapon swap. Tether capture and throws belong exclusively to the held Graviton Tether. An existing fired projectile may finish its short lifetime after a swap, but no required encounter depends on that combination.

## Supplies and fiction
**Universal feed cartridges** are blue square cartridges with two distinct sockets. Their internal recyclable material is configured by the held weapon. A finite cartridge gives up to 8 shotgun shells or 3 Seedlobber pods, capped at reserve capacity. A partially useful cartridge is consumed once; unused excess is discarded, with no hidden inventory.

Pistol and tether do not consume ammunition pickups. The Arc Welder uses cooling time, so a normal cartridge also remains in the world when it is held. This avoids rewarding pointless swaps to collect a different ammunition bank.

Recovery stations fill the carried shotgun's loaded and reserve capacity, or Seedlobber's ready and reserve capacity, and cool the Arc Welder. They do not refill guns lying nearby. The player can deliberately bring a dropped gun to a station by carrying it; this is an ordinary preparation trip.

New authored weapon pickups start with useful ammunition specified by the level designer. A previously dropped gun retains its actual count. Do not mark every pickup as "new" to manufacture a refill loop.

## Mandatory encounter safety net
An arena that locks its exits provides a reachable **service dispenser** with renewable, non-treasure ammunition and a separate renewable **throwable prop pad** wherever tether entry is possible. Dispensers are fixed environmental machines operated by the hero.

A dispenser grants one cartridge at a time, with a proposed 6-second cooldown. It works even at zero ammunition, requires no gems and no kill, and cannot become permanently destroyed or blocked. It refills only the held finite-ammunition weapon. Its safe approach still requires ordinary timing.

A throw pad maintains at most two light ceramic canisters in its marked supply area. A destroyed, thrown-away, or inaccessible canister is replaced after roughly 3 seconds; one held by the hero counts as active. These props carry no gems and create no farming reward. Their appearance belongs to the arena's maintenance machinery.

Provide a protected recovery lane to supplies and a viable attack window after returning. For ranged bosses, add openings near the hero and collision-valid arcs for thrown props and Seedlobber pods. For ordinary open encounters, avoidance/backtracking may supply recovery, but a one-way gate cannot silently remove the last supply route.

## Upgrades and safety
Quickcycle changes pistol cadence; Power Shot adds charge time. Double Sweep spends exactly 2 loaded shells and is unavailable with only 1; normal fire still works. Coolant Jacket increases Arc firing endurance; Capacitor Burst spends accumulated heat, matching its established art brief: a proposed minimum of 60 heat, consuming 60 and forcing a 2-second recharge pause with no firing. It cannot be used during an overheat lock or its own recharge. This is a deliberate venting attack, not another ammunition pool; thresholds and pause length require testing.

Seedlobber splash can hurt the hero; Cluster Bloom must remain legible and allow retreat. Friendly-fire protection prevents harm to noncombatants. Impact Pulse cannot damage the hero, preventing a close-range tether hit from becoming a mandatory self-hit. See the world interaction rules for status effects.

Review each mandatory room with an empty finite-ammunition weapon and a base tether. If the only proposed fix is adding a second carried gun, redesign the room.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
