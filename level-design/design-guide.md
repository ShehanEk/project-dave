# DEAD EDEN — Shared level design guide

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

## Purpose and status

These twelve briefs expand the campaign for an AI design assistant, environment artist, image generator or 2D environment artist. They are concept documents, not engine instructions. Room layouts, encounter quantities, checkpoint locations, duration ranges and scenic details are proposed. The story, enemy identities, weapon order and mini-boss placement follow the [main concept](../dead-eden-concept.md) as revised on 2026-09-29, including the approved enemy roster and gun kit (C25–C35).

Read the main concept and the [visual style guide](../art-design/style-guide.md) for the wider project. Each level file repeats the minimum context so it can be shared on its own.

The [AI entry guide](../AI_START_HERE.md) identifies each system's owner. When refining geometry or encounters, read [controls](../design/01-core/player-controls.md), [weapon resources](../design/03-progression/ammunition-and-resupply.md) and [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md). Their detailed numbers, including the gun profiles and screen caps used below (P23), are proposed, not tested.

## Fixed campaign structure

- Twelve levels in four acts of three:
  - the Sunnyvale campus at night;
  - the Rootworks;
  - the Arcadia Wellness Center;
  - the Garden.
- Unique mini-bosses at 3 (the Peacekeeper), 6 (Howard Stroud), 9 (the Surgeon) and 12 (the Sower).
- Five weapon types, each with three successive upgrades, and only one carried at a time. Taking a new weapon drops the previous one at that pickup location. Pickups come at 1 (Scrapjack), 2 (Boom Broom), 4 (Arc Welder), 5 (Seedlobber) and 6 (Graviton Tether).
- Combat is lethal (C28): enemies bleed and die, with visible blood and no dismemberment for now (C29). Human enemies are Arcadia Security (Acts 1–2) and the Thornwall contractors (Acts 2–3); the Rifleman is Arcadia's Response Team in level 3 and a Thornwall man from level 4 to 9. Some enemies carry guns from a kit of nine (C27).
- The roster is 24 regular types plus the four mini-bosses (C31). All types except the two Garden machines (the Pruner and the Fitting Arm) and the two Heirs (the Fitted Heir and the Warden) are introduced by level 9. Levels 9 and 12 introduce no new type.

| Level | New enemy types |
| --- | --- |
| 1 | Night Guard, Patrol Rover, Staffer (at the alarm exit only) |
| 2 | Sidearm Guard, Security Drone, Hound (with a Night Guard handler) |
| 3 | Riot Officer, Rifleman (Arcadia Response Team) |
| 4 | Sentry Turret, Freight Loader (Thornwall Riflemen appear from here) |
| 5 | Heavy Gunner, Grenadier, Gun Hound |
| 6 | Marksman, Linked Lineman |
| 7 | Linked Nurse, Sanitizer, Orderly |
| 8 | Linked Trooper, Keeper Drone |
| 9 | None (the test level) |
| 10 | Fitted Heir, Pruner, Fitting Arm |
| 11 | Warden |
| 12 | None |

- Protected people are never targets and have no hit zone: Arcadia's founder in level 11, the staff held in the clinic, harmless Sleepwalkers (a protected NPC type, no longer an enemy) and Arcadia's executives, who appear in scenes only.
- The Linked (Staffers, Linked Linemen, Nurses and Troopers) never block progress: Dave can always jump past one, so killing them is a choice.
- Level 11 reveals Adam's dead-man switch and uses three existing controls to isolate the launch circuit, which enables the manual override. Level 12 ends at Adam's core after the fourth mini-boss. There is no separate final boss and no thirteenth level.
- There are no stealth mechanics (C16).

## Side-view space and camera

Use a readable 2D side-view action plane, with separately illustrated foreground and background layers. Optional parallax suggests depth. No level silently switches to free 3D movement. Author vertical climbs as linked side-view spaces with visible landings. Background windows, servers, machines and platforms are scenery unless a brief describes a specific accessible connection.

An area is a sequence unit, not necessarily one screen. The six area IDs per level give a stable order that an AI can reference without inventing chapters. Rooms, refuges and optional loops within an area may span several views. The JSON lists only the main area chain; it is not a complete collision graph.

The camera must reveal an attack's origin, the intended landing or a hazard's destination before the player commits, and it must show a gun's muzzle and its lane before it fires. Keep enough look-ahead for fast enemies. Avoid moving the camera at the moment a fine jump or weak-point opening must be read. Show complete boss arenas when practical, while keeping Dave legible.

## Darkness and readability

The game is dark on purpose, and it must never be dark where the player needs to read something:
- **Put a light near every landing.** Platforms have lit or rim-lit top edges.
- **Light is smooth and realistic.** Lamps, screens and each gun's muzzle flash light the scene in-engine, replacing the older flat light bands (C35, confirmed direction, validated by the approved lit-cutout test (2026-09-30)). Keep every light source visible in the scene.
- Characters and enemies read by their dark outline and flat base color even outside a lamp, and take rim light wherever an engine lamp falls on them.
- Tells use the reserved colors: amber for warning, red for an attack now, in three kinds only (glow, sight line and charge).
- Microchips glint gold, and keycards and doors carry clear light states.
- **Blood is visible and never in the way.** It is red for people and dogs (#B3212F, drying to #8A1A26), black oil for machines and grey-rose lymph for Heirs. It never glows, never uses a tell color, and never hides a tell, a ledge or a pickup. Pools sit on static floors only, below characters, tells, shots and pickups. Bodies stay where they fall, so keep landings, pickups and keycard terminals clear of likely body positions. A Blood on/off setting (*proposed*, on by default) swaps spurts for dark dust and hides pools and overlays, so nothing a level needs may depend on blood.
- Foreground silhouettes stay at the edges or thin out near the action.
- Fog is drawn in low bands and never hides feet, attack origins or pickups.
- Strobes and alarms respect the reduced-flash options, and rapid gunfire uses one held glow, never a strobe.

A more cinematic screenshot is not a more playable composition.

## Movement assumptions and sizing

The baseline actions are move/run, jump, aim, shoot and interact. There is no crouch, so every same-floor shot is flat and is answered by a jump, cover or another floor, and jump dodges assume a held jump rather than a tap hop. The Graviton Tether arrives in level 6 and enables marked-anchor pulls and object capture only while it occupies the single weapon slot. There is no approved double jump, dash, wall run, swimming, free climbing or grappling to any surface, and layouts cannot depend on them.

The temporary human height H = 1.70 m is an art-scale reference only. The controls document supplies untested starting ranges for speed, jump height, grace and buffering. Exact collision sizes and route distances are uncalibrated, so the briefs use relative terms such as broad landing, short gap, high refuge and visible throw range, plus the proposed gun distances in the fairness document. A later blockout must calibrate real measurements before calling a route playable.

Main routes have ordinary movement or interactable alternatives to tether use. Anchors offer optional approaches only while the tether is carried. Long Reach can extend optional shortcuts; Heavy Lifter cannot capture heavy enemies or bosses. No required path assumes a gun plus a separate tether.

## Single-weapon encounter requirements

Read the [core gameplay rules](../core-gameplay.md) before expanding a level. Weapon lists mean the types met so far, not an instant-access inventory. Pickups are ground swaps, and an optional safe trial comes before a one-way exit. Checkpoints do not offer stored weapons.

Every mandatory encounter must work with the weapon legitimately carried into it. Provide:
- accessible close-range positions for the Boom Broom and Arc Welder;
- usable pod arcs and exposure windows for the Seedlobber;
- reachable, replenishable throwables for the Graviton Tether.

Heavy enemies and bosses cannot be captured. A pistol sightline alone does not show that a fight supports the full roster.

Do not require:
- two-weapon combinations;
- a hidden backup pistol;
- an always-equipped tether;
- a distant abandoned gun;
- optional upgrades.

A zero-resource state must have a recoverable solution, never a softlock.

## Encounter teaching and escalation

**The introduction rule.** Introduce a new enemy type alone, in a space of its own, and under low pressure. Show its tell and its recovery, then combine it with a known threat in a later area or level. A combination never pairs two unfamiliar types. Put combat on stable landings before demanding simultaneous movement, and never teach a new enemy at the same moment as an unpreviewed lockdown change. Garden-built variants of familiar machines shorten only the amber part of their tell, and red stays the same.

An encounter specifies roles and approximate small groups, not final spawn tuning. Reinforcements are finite and visible. There are no repair units and no endless reactivation loops. Move enemies apart when their cues become hard to tell apart.

**Guns, cover and screen budget** *(proposed, P23; owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md))*:
- Same-floor guns fire flat, never at head height and never at an airborne Dave, and tracking aim points are always slower than Dave's run.
- Low cover (a crate about 0.6 H tall) blocks all same-floor fire, and Dave can shoot over it. High cover (a pillar at least 1.2 H tall, or an overhang with at least 1.1 H of headroom) is the only cover against elevated guns. Every machine-gun, rail-rifle or beam position has the right cover, or another floor, within 3 H.
- Guns reach at most 6.5 H, except the rail rifle, whose fights are advance fights with cover at most 8 H apart and a perch Dave can reach.
- Per screen: at most 2 shooters, 3 attackers and 1 heavy gun (a machine gun, rail rifle, cutter beam or plasma gun), and shooters fire only when at least 1 H inside the camera.
- Area bursts (frags, plasma, vials) are blocked by walls. A frag's escape is always forward, vial gaps are at least 0.7 H, and no gun lane has a pit edge within 1.5 H behind a spot where Dave is meant to stand.
- Protected people stay out of every fire line.

Mini-boss difficulty grows through different skills, one lesson each:
1. read the tell, dodge and punish the stall, with high cover against a tracking roof gun (the Peacekeeper);
2. keep changing platforms while finding shots, and jump the ground arcs (Howard Stroud);
3. dodge a big overhead threat (the sight-line beam and the dive) and punish it when it comes low, using overhead cover (the Surgeon);
4. recognize each learned tell and punish the vent, through chained attacks, area bursts and capped seekers (the Sower).

The hardest boss never has more than two threats live at once and starts no new windup while its shots are alive, and moving platforms never remove the last safe route. More health alone is not the planned difficulty curve.

## Checkpoints, keycards and resources

Checkpoint behavior is a working proposal owned by [health and checkpoints](../design/03-progression/health-and-checkpoints.md). A checkpoint commits these together:
- the held weapon;
- world pickups and resources;
- the microchip wallet and upgrades;
- evidence files and the level's keycard;
- encounters and story objectives.

A retry restores that complete snapshot; it does not recover an abandoned arsenal. Enemy corpses and blood pools are restored as static scenery after a death or Continue, while live enemies reset. Recovery stations service the held weapon, and story-only saves preserve current resources. Transient mechanisms restart safely. There is no checkpoint armory.

**Keycards (proposed):**
- Each exit in L1–L11 needs that level's clearance card, placed on the main route or clearly signposted.
- On levels 3, 6 and 9, the mini-boss arena console grants it after the fight.
- A keycard is never hidden behind optional content, and it is never lost on retry once committed.

Place a workbench checkpoint directly before every mini-boss, and another after each victory before a one-way exit. The final post-boss save stops the ending from repeating the fight. Early movement lessons have catch floors or ledges. Do not remove equipment or force an optional purchase for a dramatic beat, and do not add a strict countdown fail state in level 11.

## Secrets, microchips and story

The confirmed loop is explore, fight, collect microchips, overcome an obstacle, reach a checkpoint and upgrade.
- [Treasure economy](../design/03-progression/treasure-economy.md) proposes microchip budgets and upgrade costs. Enemies drop no microchips (*proposed*, P23), so every chip is hand-placed.
- [Evidence files](../design/03-progression/evidence-files.md) proposes one optional, journal-only file per level.
- Exact alcoves still need to be allocated in these layouts.

Signal interesting detours and reconnect them cleanly. Critical story information and required items belong on the main route. There is no hidden collectible quota and no backtracking for future weapons.

Quiet spaces are part of the pacing. These must all be understandable without simultaneous combat:
- plugging into Adam's core in L1;
- harmless Sleepwalkers;
- the archive consoles;
- the founder's lab;
- Adam's core in L12.

Environmental storytelling can be visual rather than a wall of text. Adam speaks on PA systems and screens in every level, calmly and politely.

The game is mature, and its horror is restrained. Atrocity is shown only as aftermath: at most one authored scene per level, out of the combat lanes, escalating by act (the level 5 Bloom test chamber, the level 7 clinic bays, the level 10 fitting line). There is no torture or execution on screen, no sexual violence, no children and no dismemberment. Implants are never treated as monstrous in themselves; the horror is what Adam does to people.

## Adam's lockdown events

Each level has one signature scripted change, such as doors sealing, lights failing, shutters dropping, machines rerouting, or platforms and conveyors changing direction. Adam announces it in a pleasant voice. Every change needs:
- a visible source;
- a preview (a light, a sound, an announcement);
- a destination;
- a recovery rule.

Projection and screen effects never silently change collision. Never seal an occupied refuge without warning. Reset lockdown states coherently after failure. Show closed and open states as the same assembly, not two unrelated generated designs. Where a story route opens, preserve that state on retry.

There is no detection system: lockdowns are authored beats, not reactions to being seen.

## Image-generation workflow

**Prompt 1: environment keyframe.** Generate one representative view; a single image is not expected to show a whole level. Keep characters small or attach their approved references. Every prompt starts with the style guide's standard opening. The keyframe is the one prompt that overrides "evenly lit": it is a lit mood reference that shows smooth, realistic light from the level's own lamps, screens and glows, with blood as restrained floor stains.

**Prompt 2: side-elevation study.** Interpret the six-area route using clean masses and readable, evenly lit surfaces, and mark low and high cover as distinct shapes. If six panels are too crowded, generate each separately with the same visual reference. The output is a conceptual map, not proof of valid collision or jumps.

**Prompt 3: modular asset sheet.** Attach the approved keyframe and request the environment kit in subsets. Keep fixed architecture, moving platforms, interactables, doors and lights, enemies and effects separate. Use consistent proportions, linework and flat base colors with no baked shadows, painted-in light or blood, so the engine can light each module (C35).

**Prompt 4: AI design handoff.** Supply the whole level file and request a player-journey analysis, asset lists, story beats and a consistency review. The AI must mark new suggestions and unknowns rather than silently inventing final mechanics.

An image model cannot reliably honor exact counts, keep identical proportions and pivots across sprite poses, or prove spatial connections. Compare every output with the written route and the character references before sprite production. Never let generated art silently change a level's gameplay.

## File and layer organization

Each level lists its own environment kit. Reuse shared corridor, catwalk, server-rack, pipe, rail and service-machine families across levels where it fits, changing light and wear within the shared visual language. Keep signature landmarks separate from generic modular pieces.

Keep individual components for hinges, lifts, rails, shutters, keycard doors, boss gates and warning lights. Boss bodies and their arenas are separate asset sets. Blood pools, stains and corpses are separate effect and prop layers and are never painted into a module. The founder's support cradle is a protected background story asset, not an enemy collision object.

No engine, code architecture, sprite resolution, atlas layout or layered source format is chosen here. Enemy art follows the style guide's lit cutout rig (C35), and environment modules are painted as flat base colors so the same in-engine lights can shade them.

## Design review checklist

- There are exactly twelve levels and four scheduled mini-bosses.
- Each area has a clear entry, an intended action, a safe response and an exit.
- Weapon types and enemies appear in the established order, each new enemy type is met alone before it is combined, and no more than one weapon is carried.
- Every encounter stays within the screen budget (2 shooters, 3 attackers, 1 heavy gun) and has the cover its guns need.
- Required routes work without assuming the tether is carried, and encounters support the actual single weapon, with visible recoveries.
- Harmless Sleepwalkers, held staff and the founder are never accidental mandatory targets, protected people have no hit zone, and the Linked never block progress.
- There are no zombies, infection, conversion, dismemberment or stealth. Blood follows the material hit and never hides a tell.
- Atrocity appears only as aftermath, at most once per level.
- The darkness never hides a tell, a landing, a pickup or a keycard.
- Every boss opening is usable without a specific optional upgrade.
- Generated images agree with the written route, part counts and approved asset identities.
- The ending cancels the Bloom launch and shuts Adam down through the override, without an extra boss.
