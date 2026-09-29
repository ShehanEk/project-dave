# DEAD EDEN — Upgrade stages and ownership

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** S04  
**Status:** Working design proposal. Confirmed decisions and the established baseline remain constraints; new details and numbers are untested proposals.  
**Purpose:** Keeps all fifteen upgrades (five renamed under C34) and proposes ownership across copies of a weapon type.

**Decision references:** C12, C04, C05, C06, C19, C34, P08, P10, P22 — see the [decision register](../decisions.md).  
**Read with:** [treasure economy](treasure-economy.md) · [ammunition and resupply](ammunition-and-resupply.md) · [weapon swaps](../01-core/weapon-swaps.md) · [README](../../art-design/README.md)

## Fixed roster
There are five weapon types and exactly three cumulative upgrades for each. Stage 0 is the base weapon, not a fourth upgrade. Stages must be purchased in order; every later stage retains earlier capabilities and visible fittings.

| Weapon | Stage 1 — 40 microchips | Stage 2 — 90 microchips | Stage 3 — 160 microchips |
| --- | --- | --- | --- |
| Scrapjack Pistol | Quickcycle: shorter firing interval | Punch-Through: penetrates light armor and continues through one small enemy | Power Shot: deliberate charged shot |
| Boom Broom | Extended Tube: 4-shell tube becomes 6 | Incendiary Shells: burning damage over time | Twin Shell: optional two-shell blast |
| Arc Welder | Chain Reaction: arcs to nearby valid hostile targets | Coolant Jacket: longer sustained use before overheating | Capacitor Burst: spend accumulated heat on a staggering pulse, then recharge |
| Seedlobber | Snare Foam: pods leave a temporary slowing patch of foam | Burst Pods: larger explosion, still hazardous near the hero | Cluster Charges: secondary explosive charge scatter |
| Graviton Tether | Long Reach: greater capture and marked-anchor reach | Heavy Lifter: medium objects and staggered medium enemies | Impact Pulse: thrown impacts create a small damaging pulse |

*Renamed under C34 (new names proposed as P22):* Deep Clean is now Extended Tube, Furnace Shells is Incendiary Shells, Double Sweep is Twin Shell, Deep Roots is Snare Foam and Cluster Seeds is Cluster Charges. Incendiary Shells add burning damage over time; their old effect of stopping self-repair went with the repair units, which are cut. Snare Foam keeps the same slowing effect. Dave's other upgrades and all five weapons' behavior are unchanged.

Exact visual changes remain owned by the five existing weapon art briefs. Do not replace a barrel, add another ring, or invent a fourth attachment stage because of this table. Upgrade attachments may show a re-flashed microchip module (a small gold-contact chip seated in the fitting).

## Proposed ownership model
The campaign records an **earned stage for each weapon type**. This is a record of paid designs, not five carried weapons. A physical instance has its own ammunition, heat, world location, and currently fitted stage.

Dave operates a fixed workbench to buy and fit a stage to the held weapon, recording the new earned stage; the bench re-flashes microchips into that weapon's upgrade module. On later pickup of another physical copy of that type, Dave fits the already-earned modular upgrades during the pickup presentation. This is an abstract progression benefit, not a separate parts inventory or crafting system. No extra microchips are charged. Copies lying elsewhere do not visibly change from a distance; they adopt the earned fittings when picked up.

A dropped weapon keeps its fitted stage. Upgrades never decrease through ordinary swapping. The pickup comparison displays the stage that will be usable after pickup. A checkpoint rollback restores both the earned-stage record and the physical weapon states together.

This proposal resolves the earlier open question about separate copies. It lets players experiment without losing their long-term investment while preserving the single carried slot. It does not authorize a weapon-selection menu, remote recovery, or a hidden inventory.

## Resource separation
Applying fittings does not manufacture ammunition. A shotgun holding 2 loaded shells still holds 2 after Extended Tube; its capacity changes to 6. A recovered empty upgraded shotgun is still empty until serviced. The Arc Welder preserves its current heat when fittings apply; any capacity interpretation must not become a swap-to-cool exploit.

A workbench checkpoint can separately provide its normal refill. Present that as station service, not as a free refill attached to purchasing or picking up a weapon.

## Where and when to buy
Proposed gates:
- Stage 1 becomes eligible once that weapon has been introduced and is physically held at a workbench.
- Stage 2 purchases open after defeating the Peacekeeper at level 3; later-introduced weapons still require their own stage 1 first.
- Stage 3 purchases open after defeating Howard Stroud at level 6; later stages still require their earlier stages and full costs.
- The post-boss workbench checkpoint is available before each one-way exit. A player never has to cross the next level just to use a newly unlocked tier.

A workbench offers purchases for **the currently held type only**. It may display collected records in a read-only journal, but cannot equip an abandoned type. Picking up an earlier type at an authored location is how the player returns to it.

## Transaction flow
Interact at a safe workbench → see current type and installed stage → preview the next effect, appearance and microchip cost → confirm purchase → deduct and fit together → save complete state → return to play.

Show a clear reason when unavailable: insufficient microchips, preceding stage required, or campaign milestone pending. There is no random roll, downgrade, paid reroll, or loss of microchips on a cancelled action.

## Boundary examples
- Upgrade shotgun to stage 1, swap it for Arc Welder: only Arc is carried. The shotgun remains at the swap point with its loaded shells.
- Later find a base shotgun copy: it gains already-earned stage 1 upon pickup, but keeps its authored ammunition.
- Buy pistol stage 2, then die: the purchase was a committed save, so the stage and reduced wallet both remain.
- Reach a boss with stage 0: the encounter remains solvable. Upgrades may shorten or broaden solutions; they never supply the sole key.

## Remaining decisions
Costs, tier gates, strength of each effect, and pickup fitting presentation are proposed. Alternate branches, passive hero skill trees, and evidence-file-based weapon stages are outside this baseline.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
