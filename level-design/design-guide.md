# DEAD EDEN — Shared level design guide

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

## Purpose and status

These twelve briefs expand the existing campaign for use by an AI design assistant, environment artist, image generator, or 2D environment artist. They are concept documents, not engine instructions. Their room layouts, encounter quantities, checkpoint locations, duration ranges, and new scenic details are proposed elaborations. Established lore, enemy identities, weapon order, and mini-boss placement are preserved.

Read the [main concept](../dead-eden-concept.md) and [visual guide](../art-design/style-guide.md) for the broader project. Each level file repeats the minimum context so it can be shared independently.

The [AI entry guide](../AI_START_HERE.md) identifies each system's owner. Read [controls](../design/01-core/player-controls.md), [weapon resources](../design/03-progression/ammunition-and-resupply.md), and [boss fairness](../design/04-world/encounter-and-boss-fairness.md) when refining geometry or encounters. Their detailed numbers are proposed, not tested.

## Fixed campaign structure

- Twelve levels, organized into four groups of three.
- Unique mini-bosses at 3 (Mr. Mulch), 6 (Old Rootjaw), 9 (Matron Mercy), and 12 (The Unfinished Choir).
- Five weapon types, each with three successive upgrades, but only one weapon carried at a time. Taking a new weapon drops the previous weapon at that pickup location. Pickups occur at 1 (Scrapjack), 2 (Boom Broom), 4 (Arc Welder), 5 (Seedlobber), and 6 (Graviton Tether).
- Ten ordinary robot and ten zombie types introduced by level 9.
- Returned first appear in level 10 through installed neural interfaces and physical tissue transfer. Choir Unit appears in level 11 and is distinct from the final mini-boss.
- The First Patient is a living victim, not a compulsory enemy. Peaceful Rememberers are never required kills.
- Level 11 establishes the companion's shutdown authority and restores an independent life-support circuit. Level 12 resolves the conflict with EDEN after the fourth mini-boss. There is no separate final combat boss or thirteenth level.

## Side-view space and camera

Use a readable 2D side-view action plane with separately illustrated foreground and background layers; optional parallax suggests depth. No level silently changes to free 3D movement. Author vertical climbs as linked side-view spaces with visible landings. Background roads, windows, robots, and platforms are scenery unless a specific accessible connection is described.

One area is a sequence unit, not necessarily one screen. Six area IDs per level give a stable order that an AI can reference without inventing chapters. Within-area rooms, refuges, and optional loops may span several views. The JSON lists the main area chain only; it is not a complete collision graph.

The camera must reveal an attack origin, intended landing, or hazard destination before the player commits. Keep enough look-ahead for fast enemies. Avoid moving the camera at the exact moment a fine jump or weak-point opening must be read. Show complete boss arenas when practical, while keeping the hero legible.

Foreground decoration stays at the edges or becomes unobtrusive near action. Side platforms need visible top edges and enough contrast against the background. Do not mistake a more cinematic screenshot for a more playable composition.

## Movement assumptions and sizing

The baseline is move/run, jump, aim, shoot, and interact. The Graviton Tether is introduced in level 6 and enables marked-anchor pulls and object capture only while it occupies the single weapon slot. The project has not approved double jumping, dashing, wall running, swimming, arbitrary climbing, or grappling to any surface. Layouts cannot depend on them.

A temporary human height H = 1.70 m is an art scale reference only. The controls document supplies untested starting ranges for speed, jump height, grace, and buffering. Exact collision dimensions and route distances remain uncalibrated. Use relative concepts such as broad landing, short gap, high refuge, and visible throw range in the briefs. A later blockout must calibrate actual measurements before calling a route playable.

Main routes have ordinary movement or interactable alternatives to tether use. Anchors provide optional approaches only while the tether is carried. Long Reach can extend optional shortcuts; Heavy Lifter cannot capture heavy enemies or bosses. No required path assumes a gun plus a separate tether.

## Single-weapon encounter requirements

Read [Core gameplay rules](../core-gameplay.md) before expanding a level. Weapon lists mean types encountered by that point, not instant-access inventory. Pickups are ground swaps, and an optional safe trial precedes a one-way exit. Checkpoints do not offer stored weapons.

Every mandatory encounter must work with the weapon legitimately carried into it. Provide accessible close-range positions for the Boom Broom and Arc Welder, usable pod arcs and exposure windows for Seedlobber, and reachable replenishable throwable objects for Graviton Tether. Heavy enemies and bosses cannot be captured. A pistol sightline alone is insufficient evidence that a fight supports the full roster.

Do not require two-weapon combinations, a hidden backup pistol, an always-equipped tether, a distant abandoned gun, or optional upgrades. Replenishment and checkpoint mechanics are still proposals, but a zero-resource state must have a recoverable solution rather than a softlock.

## Encounter teaching and escalation

Introduce a new enemy alone or in a low-pressure setting, demonstrate its warning and recovery, then combine it with a known threat. Place combat on stable landings before demanding simultaneous movement. Never teach a new enemy and an unpreviewed lethal platform transformation at the same instant.

An encounter specifies roles and approximate small groups, not final spawn tuning. Reinforcements are finite and visible. The first Howler wakes a known nearby group; Patchbot and medical repair combinations cannot create endless progression locks. Move enemies apart when their cues become indistinguishable.

Mini-boss difficulty grows through different skills: charge recognition, changing terrain, support-target priority, then identity switching with controlled overlap. The hardest boss keeps at most two attack threats active; moving platforms do not eliminate the last safe route. More health alone is not the planned difficulty curve.

## Checkpoints and resource assumptions

Checkpoint behavior is a working proposal owned by [health and checkpoints](../design/03-progression/health-and-checkpoints.md). Commit the held weapon, world pickups, resources, wallet, upgrades, artifacts, encounters, and story objectives together. A retry restores that complete snapshot; it does not recover an abandoned arsenal. Recovery stations service the held weapon, while story-only saves preserve current resources. Transient mechanisms restart safely. There is no checkpoint armory.

Place a maintenance checkpoint directly before every mini-boss and after each victory, before a one-way exit; the final post-boss save prevents the resolution from repeating the fight. Early movement lessons have catch floors or ledges. Proposed health, failure, ammunition, and price defaults now live in the progression section; they still require validation. Save implementation is not part of this concept project.

Do not remove equipment or force one optional purchase for a dramatic beat. Do not add a strict patient-death countdown in level 11. Orderly's first capture needs a readable escape opportunity; see the proposed escape rule in [enemy states](../design/04-world/status-and-enemy-states.md).

## Secrets, treasure, and story

The confirmed loop is explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are an additional type. [Treasure economy](../design/03-progression/treasure-economy.md) proposes gem budgets and upgrade costs; the [artifact catalog](../design/03-progression/artifact-catalog.md) proposes one optional journal-only find per level. Exact alcoves still need allocation in these layouts. Signal interesting detours and reconnect them cleanly. Critical evidence and required items belong on the main route; no hidden collectible quota or future-weapon backtracking is assumed.

Quiet spaces are part of pacing: the companion discovery, peaceful Rememberer, transfer records, First Patient reveal, and final EDEN interface must be understandable without simultaneous combat. Environmental storytelling can be visual rather than a wall of text.

## Environment transformations

Every moving or changing feature needs a source, preview, destination, and recovery rule. Hedges move on rails; beds ride guides; roots lift platforms; core decks follow visible mechanisms. Decorative projection changes do not silently change collision.

Never seal an occupied refuge without warning. Reset transformations coherently after failure. Show closed and open states as the same assembly, not two unrelated generated designs. Where a post-story route opens, preserve that state on retry.

## Image-generation workflow

**Prompt 1: environment keyframe.** Generate one representative view. A single image is not expected to show a whole level. Keep characters small or attach their approved references.

**Prompt 2: side-elevation study.** Interpret the six-area route using clean masses and readable surfaces. If six panels are too crowded, generate each separately with the same visual reference. The output is a conceptual map, not proof of valid collision or jumps.

**Prompt 3: modular asset sheet.** Attach the approved keyframe and request the environment kit in subsets. Keep fixed architecture, moving platforms, interactables, enemies, and effects separate. Use consistent proportions and consistent linework and flat shading for sprite references.

**Prompt 4: AI design handoff.** Supply the whole level file and request player-journey analysis, asset lists, story beats, and consistency review. The AI must mark new suggestions and unknowns rather than silently inventing final mechanics.

An image model cannot reliably honor exact counts, maintain identical proportions and pivots across multiple sprite poses, or prove spatial connections. Compare every output with the written route and character references before sprite production. Do not let generated art silently change the level's gameplay.

## File and layer organization

Each level lists a unique environment kit. Reuse shared corridor, platform, pipe, rail, and service-machine families across levels where appropriate, changing color or wear within the shared visual language. Keep signature landmarks separate from generic modular pieces.

Preserve individual components for hinges, lifts, rails, roots, boss gates, and warning effects. Boss bodies and their arenas are distinct asset sets. The First Patient's body is a protected background story asset rather than an enemy collision object.

No engine, code architecture, sprite resolution, atlas layout, animation method, shader implementation or layered source format is chosen here. Those are later production decisions.

## Design review checklist

- There are exactly twelve levels and four scheduled mini-bosses.
- Each area has a clear entry, intended action, safe response, and exit.
- Weapon types and enemies appear in the established order; no more than one weapon is carried.
- Required routes work without assuming the tether is carried, and encounters support the actual single weapon with visible recoveries.
- Friendly or peaceful patients are not accidental mandatory targets.
- Returned obey the interface-and-tissue infection rule.
- Every boss opening is usable without a specific optional upgrade.
- Generated images agree with the written route, part counts, and approved asset identities.
- The ending preserves life support and halts harmful treatment without pretending the entire outbreak is cured.
