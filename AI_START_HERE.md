# Project Dave / DEAD EDEN — Start here, AI agent

This repository develops an original colorful 2.5D platformer shooter concept. **The current task is idea development, not implementation.** Use the separate documents below to refine one area without inventing incompatible mechanics elsewhere.

## Minimum reading

1. Read [core-gameplay.md](core-gameplay.md) for the confirmed loop, treasure, and weapon rules.
2. Read [design/decisions.md](design/decisions.md) to distinguish user-confirmed constraints, the established baseline, and proposed defaults.
3. Choose a task route below. Read those owning documents and the relevant existing art or level brief.
4. Use [design/manifest.json](design/manifest.json) when you need structured file IDs and dependencies. Dependency links are a context graph, not a requirement to load the entire repository recursively.

## Task routes

| Task | Read first | Add only when relevant |
| --- | --- | --- |
| Overall gameplay | G01 loop, G02 controls, G03 swaps | G04 camera, S01 checkpoint, W04 encounters |
| Hero or companion concept art | H01 hero or H02 companion | H03 relationship, shared art style, relevant held weapon brief |
| Health or save behavior | S01 health/checkpoints | G03 swap, S02 ammunition, S04 ownership |
| Weapon behavior or balance | S02 resources, S04 upgrades | Existing weapon art brief, W02 statuses, W04 boss fairness |
| Treasure and progression | S03 economy, S04 upgrades, S05 artifacts | S01 saving and relevant level brief |
| Enemy or environmental interaction | W01 factions, W02 states, W03 objects | Existing enemy brief and W04 fairness |
| Level refinement | Existing level brief and shared level guide | G02 movement, W04 encounters, S02 supply, S03 budget, S05 artifacts |
| Story or dialogue | N01 scenes, N02 writing | H03 relationship, main concept, relevant level |
| UI / accessibility | N03 interface | G03 swaps, G04 camera, S01 checkpoint, S04 upgrades |
| Sound / music | N04 audio | N02 voices and relevant enemy, weapon, or level brief |

Find every ID in the [design index](design/README.md). Use the five section indexes for the user's preferred full reading order.

## Rules that must survive every edit

- Explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade.
- Gems are primary treasure; artifacts are additional discoveries.
- One carried weapon. A pickup exchanges it with the grounded weapon at that pickup's location.
- No automatic secondary pistol, backpack arsenal, checkpoint armory, or free separate tether.
- Five weapon types, three cumulative upgrades each; no silent sixth weapon or fourth upgrade.
- Twelve levels, four unique escalating mini-bosses at 3, 6, 9, and 12.
- Ordinary robots do not catch biological infection. Returned need physical neural tissue and compatible installed interfaces.
- The First Patient and peaceful Rememberers are not mandatory enemies. L11 protects life support; L12 resolves EDEN after the guardian without an extra combat boss or instant cure.
- Every required route and fight supports the legitimate single weapon. Tether routes have baseline alternatives; tether fights have replenishable props.
- Work in editable individual files. Do not recreate removed duplicate archives.

Some of these are confirmed user choices, others established continuity or their direct design consequences. The decision register identifies which is which.

## Ownership and conflict resolution

The latest explicit user decision outranks an older document. Confirmed entries outrank incompatible proposals. For a system's detailed behavior, use its named owner in the manifest. Existing art briefs own visual geometry and named upgrade appearances; level briefs own area order and local scene layout; the main concept owns broad lore. The new system files supply detailed proposed rules where the old overview was incomplete.

An image or atmospheric paragraph cannot silently add an ability. A proposed health number cannot override a confirmed weapon limit. If two owners disagree, identify the specific conflict, preserve confirmed constraints, and repair the inconsistent references instead of averaging rules.

The manifest and campaign JSON are navigation/structured summaries, not a second independent design authority. Update their applicable fields when written source content changes. Do not duplicate whole specifications into new all-in-one documents.

## Editing and handoff procedure

State the area being refined and its current status. Read its owner and direct dependencies. Make a concrete proposal in the correct file, preserve named entities and IDs, and explain any intentional scope change. Update dependent summaries and links. Review the relevant cases in [review-scenarios.md](design/review-scenarios.md).

Keep new balancing figures labeled untested. Keep proposed names/visuals editable. Do not claim an image, model, asset, or behavior is implemented because its brief exists. No engine, code, generated media, production schedule, or external publication is authorized merely by this guide.

## Reusable task prompt

> Read AI_START_HERE.md and design/decisions.md. Refine [named topic] at the concept level using its owning document and direct dependencies in design/manifest.json. Preserve confirmed constraints and established lore. Keep new decisions labeled proposed; use existing entity IDs and names. Update conflicting references, then check the relevant review scenarios. Deliver the revised separate documents and a short description of what changed and what remains untested. Do not implement the game or add duplicate archives.

## Existing packs

[Main concept](dead-eden-concept.md) · [Twenty system documents](design/README.md) · [Twelve levels](level-design/README.md) · [Thirty-two enemy/weapon art briefs](art-design/README.md)
