# Project Dave / DEAD EDEN — Start here, AI agent

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](art-design/style-guide.md)).

This repository develops an original **dark sci-fi 2D platformer shooter** concept. Its references are the 2D *Metal Gear* games and *Dangerous Dave*. **The current task is idea development, not implementation.** Use the separate documents below to refine one area without inventing incompatible mechanics elsewhere.

On 2026-09-29 the user replaced the story and atmosphere (C14–C21 in the [decision register](design/decisions.md)), then approved a new enemy roster and enemy gun kit (C25–C35): human enemies with guns, a mature and lethal game with visible blood, cyborg dogs, the Thornwall contractors, no Clipper, and a lit cutout art method for enemies. Anything that still mentions zombies, EDEN as the AI, gems, Rook Venn, a cheerful palette, the Clipper or any other removed enemy, "disabled, not killed" or "no gore" is out of date and should be fixed, not followed.

## Level 1 prototype route

A separate [Godot prototype execution plan](prototype-plans/level-01-sunnyvale/README.md) defines a 10–15 minute slice of Level 1, and the prototype was built from it. **Both describe the C14–C24 build, not the current roster.** They still use disabled-not-killed Staffers and the Clipper. Under C33 the Level 1 prototype will be rebuilt from the ground up around the new roster (Night Guards, Patrol Rovers and Staffers at the alarm exit only), after the lit-cutout test on one Night Guard (C35). Read the plan's scope and progress record before any implementation work, and only change the prototype when the user asks.

## Minimum reading

1. Read [dead-eden-concept.md](dead-eden-concept.md) for the story, the enemy roster and enemy guns, Dave's weapons and the levels.
2. Read [core-gameplay.md](core-gameplay.md) for the confirmed loop, treasure and weapon rules.
3. Read [design/decisions.md](design/decisions.md) to tell confirmed user decisions from the established baseline and proposed defaults.
4. Choose a task route below, then read the owning documents and the relevant art or level brief.
5. Use [design/manifest.json](design/manifest.json) when you need structured file IDs and dependencies. Dependency links are a context graph, not a requirement to load the whole repository recursively.

## Task routes

| Task | Read first | Add only when relevant |
| --- | --- | --- |
| Level 1 Godot prototype | [Prototype plan](prototype-plans/level-01-sunnyvale/README.md), scope and progress record | Area blueprints, Godot architecture, current milestone and acceptance checks |
| Overall gameplay | G01 loop, G02 controls, G03 swaps | G04 camera, S01 checkpoint, W04 encounters |
| Hero concept art | H01 hero | N01 story scenes, style guide, the relevant held-weapon brief |
| Enemy or enemy-gun concept art | Style guide (the lit cutout rig), the relevant enemy or gun brief | The concept's Enemies tables, W02 states, N04 audio for gun cues |
| Health or save behavior | S01 health/checkpoints | G03 swap, S02 ammunition, S04 ownership |
| Weapon behavior or balance | S02 resources, S04 upgrades | Existing weapon art brief, W02 states, W04 boss fairness |
| Microchips and progression | S03 economy, S04 upgrades, S05 evidence files | S01 saving and the relevant level brief |
| Enemy, enemy gun or environmental interaction | W01 factions, W02 states, W03 objects | The concept's Enemies tables, the existing enemy or gun brief, and W04 fairness |
| Level refinement | Existing level brief and shared level guide | G02 movement, W04 encounters, S02 supply, S03 budget, S05 evidence files |
| Story or dialogue | N01 scenes, N02 writing | H01 hero, main concept, relevant level |
| UI / accessibility | N03 interface | G03 swaps, G04 camera, S01 checkpoint, S04 upgrades |
| Sound / music | N04 audio | N02 voices and relevant enemy, weapon or level brief |

Find every ID in the [design index](design/README.md).

## Rules that must survive every edit

- **The hero, Dave Harlan, travels alone (C12, C18).** There is no companion, follower, radio contact or portable AI adviser. Use fixed terminals and workbenches for story and upgrades.
- **The loop:** explore → fight → collect microchips → overcome an obstacle → reach a checkpoint → upgrade.
- **Microchips are the primary collectible and the upgrade currency (C19).** Evidence files are optional extra finds (proposed).
- **Weapons:**
  - One carried weapon. A pickup exchanges it with the grounded weapon at that pickup's location.
  - No automatic secondary pistol, backpack arsenal, checkpoint armory or free separate tether.
  - Five weapon types, three cumulative upgrades each. No silent sixth weapon or fourth upgrade.
- **Twelve levels**, with four unique escalating mini-bosses at 3, 6, 9 and 12.
- **No stealth (C16).** It is a run-and-gun game. Adam's lockdown events are scripted and telegraphed, with no detection system.
- **No zombies, infection or resurrection anywhere (C14).**
  - Machines are never "converted": Adam drives Arcadia's own machines, and the Garden builds new ones.
  - The Linked are people with Link implants that Adam drives. They can die like every other enemy (C28).
  - The Heirs are built by Adam.
- **The roster is fixed (C31):** 24 regular enemy types in six factions (Arcadia Security, Thornwall, the Linked, cyborg dogs, Adam's machines, the Heirs) plus four mini-bosses. Human enemies (C25) carry guns from a nine-gun kit (C27), and there are cyborg dogs (C30). The Clipper is removed entirely, as an enemy and as scenery (C32). Enemies are built from five shared behavior templates plus a boss base (C26).
- **Mature game, not for kids (C28, C29).** Combat is lethal and bodies stay. Blood is visible by material and never glows, never uses the tell colors and never hides a tell, ledge or pickup. Hard limits: no torture or execution on screen, no sexual violence, no children, no dismemberment for now, implants never treated as monstrous, and atrocity only as aftermath, at most one authored scene per level.
- **Protected people are never targets and have no hit zone:** harmless Sleepwalkers (a non-combat NPC type), the staff held in the clinic, Arcadia's founder in L11, and Arcadia's executives (story only). L11 isolates the launch circuit, and L12 ends at Adam's core after the Sower, with no extra boss.
- **Every required route and fight supports the single weapon legitimately carried.** Tether routes have ordinary alternatives, and tether fights have replenishable props.
- **Darkness and blood never hide gameplay:** tells, weak points, landings and pickups stay readable.
- **Work in editable individual files.** Do not recreate removed duplicate archives.

Some of these are confirmed user choices; others are established continuity or direct consequences of those choices. The decision register says which is which.

## Ownership and conflict resolution

The latest explicit user decision outranks an older document. Confirmed entries outrank incompatible proposals. For a system's detailed behavior, use its named owner in the manifest:
- art briefs own visual geometry and named upgrade appearances;
- level briefs own area order and local layout;
- the main concept owns broad story and lore.

An image or atmospheric paragraph cannot silently add an ability, and a proposed health number cannot override a confirmed weapon limit. If two owners disagree, identify the specific conflict, preserve the confirmed constraints, and repair the inconsistent references instead of averaging the rules.

The manifest and campaign JSON are navigation aids and structured summaries, not a second design authority. Update their fields when the written source changes. Do not duplicate whole specifications into new all-in-one documents.

## Editing and handoff procedure

1. State the area being refined and its current status.
2. Read its owner and direct dependencies.
3. Make a concrete proposal in the correct file, preserving named entities and IDs, and explain any intentional scope change.
4. Update dependent summaries and links.
5. Review the relevant cases in [review-scenarios.md](design/review-scenarios.md).

Keep new balancing figures labeled untested. Keep proposed names and visuals editable. Do not claim an image, model, asset or behavior is implemented because a brief exists. This guide authorizes no engine work, code, generated media, production schedule or external publication.

## Reusable task prompt

> Read AI_START_HERE.md, dead-eden-concept.md and design/decisions.md. Refine [named topic] at the concept level using its owning document and direct dependencies in design/manifest.json. Preserve confirmed constraints and established lore. Keep new decisions labeled proposed; use existing entity IDs and names. Update conflicting references, then check the relevant review scenarios. Deliver the revised separate documents and a short description of what changed and what remains untested. Do not implement the game or add duplicate archives.

## Existing packs

**Visual direction:** hand-drawn 2D rendering (C11) with the new dark sci-fi palette, lighting and mood (C15, P21). Enemies are drawn as a lit cutout rig with smooth, realistic engine lighting, Mixamo motion and ragdoll deaths (C35): confirmed direction, validated by the approved lit-cutout test (2026-09-30). See the [style guide](art-design/style-guide.md).

**Selected references:** none are current. The Clipper's selected design (C10) ended when the Clipper was removed (C32), and the zombie Resident art and the old daytime Sunnyvale scenes were deleted (C23). The [concept-art gallery](concept-art/README.md) now holds only the hero's placeholder sprite pack. A test build of one lit Night Guard will validate the enemy look; new concept art for Dave, the enemies, the mini-bosses and the night campus is still needed.

[Main concept](dead-eden-concept.md) · [Design documents](design/README.md) · [Twelve levels](level-design/README.md) · [Forty-three enemy, gun and weapon art briefs](art-design/README.md)
