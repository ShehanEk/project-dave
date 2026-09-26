# DEAD EDEN — Gems, rewards, and upgrade economy

**Document ID:** S03  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines treasure values, spending, a twelve-level budget, and safeguards against farming.

**Decision references:** C02, C03, P10 — see the [decision register](../decisions.md).  
**Read with:** [upgrades and ownership](upgrades-and-ownership.md) · [artifact catalog](artifact-catalog.md) · [health and checkpoints](health-and-checkpoints.md)

## Confirmed foundation and proposed use
Gems are the primary treasure; artifacts are a separate treasure category. **Proposed:** gems pay for the three successive upgrades of the held weapon at maintenance checkpoints.

EDEN used faceted energy crystals as durable maintenance credits. Stations accept these recovered crystals to print replacement fittings. This gives gems an in-world purpose without adding a separate scrap, experience, or crafting-material economy.

## Gem language
| Pickup | Wallet value | Readable form | Placement |
| --- | --- | --- | --- |
| Small gem | 1 | Single angular turquoise crystal | Short route trails and small discoveries |
| Gem cluster | 5 | Three crystals on one visible base | Encounter rewards and deliberate jumps |
| Gem cache | 20 | Openable cream case with an angular gold seal | Side routes and substantial rewards |

Shape and size communicate value in addition to color. Collect by contact with a small forgiving pickup radius; a cache opens through Interact. No magnet pet or separate collection tool is required.

Gems should indicate achievable jumps and inviting detours. Avoid placing the last gem over a death pit as if it marks a safe landing. A completed encounter may unlock a fixed cache; repeatedly spawned enemies and supply props never print more gems.

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

All required fights are designed for base weapons. Neither gem collection nor buying an upgrade opens mandatory campaign doors. If players consistently feel punished for trying a new weapon, change prices or budgets rather than adding free weapon storage.

## Spending and reward rules
- The wallet starts at zero and holds gems only. It has no carrying-weight limit.
- Spending is confined to maintenance benches in this draft; health and mandatory ammunition are not gem purchases.
- Artifacts cannot be sold, consumed, or converted into gems.
- Purchases have no resale or refund loop in this draft. A purchase preview names cost, effect, and resulting wallet before confirmation.
- Fixed rewards have unique collection identities. Enemy respawns, checkpoint reloads, breakable decoration, and renewable throwables cannot duplicate them.
- Death restores the last committed wallet and world reward state together. There is no extra percentage penalty.

## Level-designer allocation recipe
Start with the table total; distribute small gems along readable routes, use clusters at successful encounters and obstacles, and reserve one 20-value cache for an optional branch. Keep the optional artifact separate from the cache so treasure types feel distinct. Different placement patterns are welcome if totals and fair access remain clear.

Do not turn all enemies into mandatory treasure pinatas. A quiet observation room can reward a clever route; a defeated captive need not be rewarded with celebratory currency. The economy supports exploration and combat without erasing the story's sympathy.

## What still needs testing
Measure gems actually collected, first purchase timing, unused wallet at level exits, weapon swaps after investment, and whether players can afford a satisfying tier by each boss. These are future playtest questions, not analytics already collected. Exact budget redistribution is expected.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
