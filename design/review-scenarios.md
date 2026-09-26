# Design consistency review scenarios

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

Use these cases after changing related documents. They are **written acceptance scenarios**, not automated tests, prototype results, or proof of balanced gameplay. Review the proposed baseline as a whole; when deliberately changing a proposal, update its expected outcomes here.

| Case | Situation | Expected outcome | Owners |
| --- | --- | --- | --- |
| RV01 | Pistol held, shotgun on pickup pad; player walks over it | No automatic swap; show comparison and deliberate action | G03, N03 |
| RV02 | Player confirms that swap, then swaps back | Exactly the same two physical weapons exchange places; their ammunition is not refilled | G03, S02 |
| RV03 | Empty stage-1 shotgun abandoned; later recover it | Stage retained, still empty until normal service; no fallback pistol | S02, S04 |
| RV04 | Earn stage 1 for a type, later find a new physical copy | Apply earned fittings without adding ammunition or a carried slot | S04 |
| RV05 | Upgrade a shotgun from 4-shell capacity while 2 shells are loaded | Capacity becomes 6; still 2 loaded unless checkpoint service separately refills it | S02, S04 |
| RV06 | Save with pistol and 35 gems, swap/collect 20, then die | Restore pistol, 35 gems, and original saved pickup states; no duplication | S01, G03 |
| RV07 | Artifact collected before versus after latest save | Before: remains recorded and absent from world. After: record rolls back and world pickup returns | S01, S05 |
| RV08 | Purchase stage 1 with 60 gems | Commit stage 1 and wallet 20 together; cancelling or failure changes neither | S01, S04 |
| RV09 | Reuse a checkpoint repeatedly | Health and held weapon service; no enemy/treasure farming reset, no ground gun refill | S01, S02 |
| RV10 | Leave a level after abandoning an upgraded gun | Only held weapon travels; upgrade record persists; gun is not summoned at next bench | G03, S04 |
| RV11 | Enter a required arena with empty shotgun or Seedlobber | Renewable accessible ammunition, no gem or kill requirement | S02, W04 |
| RV12 | Enter L6/L9/L12 boss carrying base tether | Replenishable light props, valid damage path, boss immune to capture, no backup gun | S02, W04 |
| RV13 | Hero reaches an anchor shortcut with another weapon | Ordinary route remains viable; anchor is not a universal tool unlock | G02, W03 |
| RV14 | Each boss weak point is approached with every introduced base weapon | Close-range access and sufficient pod travel/fuse windows; no upgrade requirement | W04 |
| RV15 | Shotgun reload interrupted after one shell seats | Preserve inserted shell and untouched reserve; movement remains possible | G02, S02 |
| RV16 | Arc dropped hot, immediately picked up | Heat changes only through ordinary elapsed cooling, not swap reset | S02, G03 |
| RV17 | Arc uses stage-3 Capacitor Burst | Spend accumulated heat, then enforce recharge; do not generate heat contrary to art brief | S02, S04 |
| RV18 | Zombie contacts normal robot or Mourning Nurse targets unprepared machine | No infection or conversion; prepared interface plus physical graft required | W01 |
| RV19 | Explosion or chain arc passes a peaceful Rememberer / First Patient | Protected character takes no damage or capture and does not turn hostile | W01, W02 |
| RV20 | Support repairs a unit again after its one permitted reactivation | No endless revival/reward loop; encounter can finish | W01, W04 |
| RV21 | Stage-2 tether targets heavy enemy, boss, rooted Gardener, or active medium enemy | Reject capture; medium eligibility requires exposure and stagger, roots must first release | W02 |
| RV22 | Retry, reload, or skip a major scene | Same committed story state; no skipped playable support task or forced repeat of completed boss | S01, N01 |
| RV23 | L11 manual shutdown revealed, then L12 resolution begins | Independent support verified first, manual override enabled through L11's three controls, no extra EDEN battle/cure | N01, H01 |
| RV24 | A dangerous scene is viewed without audio or in grayscale | Posture, shapes and geometry still communicate threat; essential story has text | G04, N03, N04 |
| RV25 | Collect every proposed gem and compare all upgrade costs | Available 1,340; full five-type upgrade cost 1,450; no mandatory upgrade or grind gate | S03, S04 |
| RV26 | Player skips every optional artifact | All critical evidence and normal ending still accessible | S05, N01 |
| RV27 | Review a full solo campaign and same-type weapon pickup | No follower or portable AI support; hero operates fixed benches, fits earned upgrades without extra ammo or parts inventory, and receives required clues through records, survivors, EDEN, and journal objectives | H01, G03, S04, N01, N02 |

## Visual direction review

When generating any asset or scene, use C11's selected 2D references and the shared guide. Verify linework, flat color masses, cel shadows, stable part counts and readable side poses. Review asymmetric details separately for each facing direction. A scene's drawn depth must not add an off-plane gameplay route. The concept-art folder contains five selected PNGs; unpictured assets remain proposals.

## Repository checks

Every design document should have a unique ID, explicit proposal status, valid local links, decision references, and an index entry. The manifest should resolve every document and task route. The campaign remains twelve levels with six ordered main-route areas each; art coverage remains ten robots, ten zombies, three Returned, four mini-bosses, and five weapons.

No duplicate ZIP archive, hidden extra weapon, obsolete two-weapon combo, free tether, or contradictory upgrade ownership rule should be introduced. Check names and upgrade capabilities against their existing art briefs.

## What this does not establish

A written scenario can reveal an inconsistent rule, but cannot demonstrate fun, readable timing, reachable geometry, controller feel, frame performance, accessibility effectiveness, or economy balance. Those require later prototypes or asset reviews after the user requests implementation.

[Design index](README.md) · [Decision register](decisions.md)
