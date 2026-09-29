# DEAD EDEN — Microchips, rewards, and upgrade economy

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** S03  
**Status:** Working design proposal. Confirmed decisions and the established baseline remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines microchip values, hand-placed rewards (enemies drop nothing), spending, a twelve-level budget, and safeguards against farming.

**Decision references:** C02, C19, C28, P10, P11, P19, P23 — see the [decision register](../decisions.md).  
**Read with:** [upgrades and ownership](upgrades-and-ownership.md) · [evidence files](evidence-files.md) · [health and checkpoints](health-and-checkpoints.md)

## Confirmed foundation and proposed use
Microchips are the primary treasure and the upgrade currency (C19); evidence files are a separate treasure category. **Proposed:** microchips pay for the three successive upgrades of the held weapon at workbench checkpoints.

Arcadia's campus runs on chips: every door lock, lift and terminal carries a small identity or firmware chip. Dave finds them in server closets, on catwalks and in cases, and re-flashes them at workbenches, where the bench rewrites each chip as the upgrade module for the held weapon. **Enemies drop no microchips** *(proposed)*: kills give no drops and no score (C28), and every chip is hand-placed by the level designer. This gives microchips an in-world purpose without adding a separate scrap, experience, or crafting-material economy, and without turning people into loot.

## Microchip language *(forms proposed)*
| Pickup | Wallet value | Readable form | Placement |
| --- | --- | --- | --- |
| Small microchip | 1 | Single square chip with gold contacts (#FFD166) and a small glint | Short route trails and small discoveries |
| Microchip cluster | 5 | Three chips on one visible carrier tray | Hand-placed just past encounters and at deliberate jumps |
| Chip cache | 20 | Openable dark steel component case with an angular gold seal and a rim-lit latch | Side routes and substantial rewards |

Shape and size communicate value in addition to color. Collect by contact with a small forgiving pickup radius; a cache opens through Interact. No magnet pet or separate collection tool is required.

Microchips should indicate achievable jumps and inviting detours. Avoid placing the last chip over a death pit as if it marks a safe landing. Chips catch the light, so a trail glints where the level is lit and following it never leads the player into unlit space. A completed encounter may unlock a fixed, hand-placed cache; enemies and supply props never print more chips.

## First economy pass
The main-route figures below are **available rewards for a reasonably thorough route**, not a guaranteed wallet total. Collecting them is optional. Side-route values are additional. They are allocation targets for refining existing level briefs, not claims that exact placements already exist.

| Level | Main route | Optional route | Main-route cumulative |
| --- | ---: | ---: | ---: |
| 1 | 45 | 20 | 45 |
| 2 | 60 | 20 | 105 |
| 3 | 70 | 20 | 175 |
| 4 | 75 | 20 | 250 |
| 5 | 80 | 20 | 330 |
| 6 | 90 | 20 | 420 |
| 7 | 95 | 20 | 515 |
| 8 | 100 | 20 | 615 |
| 9 | 110 | 20 | 725 |
| 10 | 115 | 20 | 840 |
| 11 | 120 | 20 | 960 |
| 12 | 140 | 20 | 1,100 |
| **Campaign** | **1,100** | **240** | **1,340 including optional** |

Proposed prices per weapon type: stage 1 costs **40**, stage 2 costs **90**, and stage 3 costs **160**. These are incremental costs, totaling **290** for a fully upgraded type and **1,450** for all five.

A thorough run cannot buy everything in this first budget. The intent is investment in favorites, not required grinding. Three complete weapon types cost 870, leaving choices for the rest. Early players can afford a first upgrade without finding a secret, but doing so may delay upgrading the next weapon.

All required fights are designed for base weapons. Neither microchip collection nor buying an upgrade opens mandatory campaign doors. Only the level's keycard does, and it is never sold. If players consistently feel punished for trying a new weapon, change prices or budgets rather than adding free weapon storage.

## Spending and reward rules
- The wallet starts at zero and holds microchips only. It has no carrying-weight limit.
- Spending is confined to workbenches in this draft; health and mandatory ammunition are not microchip purchases.
- Evidence files and keycards cannot be sold, consumed, or converted into microchips.
- Purchases have no resale or refund loop in this draft. A purchase preview names cost, effect, and resulting wallet before confirmation.
- Fixed rewards have unique collection identities. Enemy respawns, checkpoint reloads, breakable decoration, and renewable throwables cannot duplicate them. No enemy drops microchips *(proposed)*: not a machine, a guard, a contractor or a Linked person, because people are not loot and machines are not piñatas. A harmless Sleepwalker or a freed staff member never yields a reward either. A mini-boss victory awards one fixed reward, placed in the arena and released when the fight ends rather than dropped from the body, and counted inside that level's main-route figure.
- Death restores the last committed wallet and world reward state together. There is no extra percentage penalty.

## Level-designer allocation recipe
Start with the table total; distribute small microchips along readable routes, place clusters just past encounters and obstacles, and reserve one 20-value cache for an optional branch. Keep the optional evidence file separate from the cache so treasure types feel distinct, and keep the level's keycard on the main route, never inside a cache or an optional branch. Different placement patterns are welcome if totals and fair access remain clear.

Enemies are not treasure piñatas. Chips are hand-placed: a quiet server closet can reward a clever route, while a dead guard or a Linked person needs no celebratory currency. The economy supports exploration and combat without erasing the story's sympathy.

## What still needs testing
Measure microchips actually collected, first purchase timing, unused wallet at level exits, weapon swaps after investment, and whether players can afford a satisfying tier by each boss. These are future playtest questions, not analytics already collected. Exact budget redistribution is expected.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
