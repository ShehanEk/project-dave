# DEAD EDEN — Shared level design guide

## Purpose and status

These twelve briefs expand the existing campaign for use by an AI design assistant, environment artist, image generator, or 3D modeler. They are concept documents, not engine instructions. Their room layouts, encounter quantities, checkpoint locations, duration ranges, and new scenic details are proposed elaborations. Established lore, enemy identities, weapon order, and mini-boss placement are preserved.

Read the [main concept](../dead-eden-concept.md) and [visual guide](../art-design/style-guide.md) for the broader project. Each level file repeats the minimum context so it can be shared independently.

## Fixed campaign structure

- Twelve levels, organized into four groups of three.
- Unique mini-bosses at 3 (Mr. Mulch), 6 (Old Rootjaw), 9 (Matron Mercy), and 12 (The Unfinished Choir).
- Five weapons, each with three successive upgrades. Pickups occur at 1 (Scrapjack), 2 (Boom Broom), 4 (Arc Welder), 5 (Seedlobber), and 6 (Graviton Tether).
- Ten ordinary robot and ten zombie types introduced by level 9.
- Returned first appear in level 10 through installed neural interfaces and physical tissue transfer. Choir Unit appears in level 11 and is distinct from the final mini-boss.
- The First Patient is a living victim, not a compulsory enemy. Peaceful Rememberers are never required kills.
- Level 11 establishes the companion's shutdown authority and restores an independent life-support circuit. Level 12 resolves the conflict with EDEN after the fourth mini-boss. There is no separate final combat boss or thirteenth level.

## Side-view space and camera

Use a readable side-view action plane with foreground and background depth. No level silently changes to free 3D movement. Author vertical climbs as linked side-view spaces with visible landings. Background roads, windows, robots, and platforms are scenery unless a specific accessible connection is described.

One area is a sequence unit, not necessarily one screen. Six area IDs per level give a stable order that an AI can reference without inventing chapters. Within-area rooms, refuges, and optional loops may span several views. The JSON lists the main area chain only; it is not a complete collision graph.

The camera must reveal an attack origin, intended landing, or hazard destination before the player commits. Keep enough look-ahead for fast enemies. Avoid moving the camera at the exact moment a fine jump or weak-point opening must be read. Show complete boss arenas when practical, while keeping the hero legible.

Foreground decoration stays at the edges or becomes unobtrusive near action. Side platforms need visible top edges and enough contrast against the background. Do not mistake a more cinematic screenshot for a more playable composition.

## Movement assumptions and sizing

The baseline is move/run, jump, aim, shoot, and interact. The Graviton Tether adds marked-anchor pulls and object capture from level 6. The project has not approved double jumping, dashing, wall running, swimming, arbitrary climbing, or grappling to any surface. Layouts cannot depend on them.

A temporary human height H = 1.70 m is an art scale reference only. Exact speeds, jump arcs, air control, collision dimensions, and distances are undecided. Use relative concepts such as broad landing, short gap, high refuge, and visible throw range in the briefs. A later blockout must calibrate actual measurements before calling a route playable.

Required anchors fit base tether reach. Long Reach opens optional shortcuts; Heavy Lifter does not let the player capture heavy enemies or bosses. Required paths remain accessible without buying optional upgrades.

## Encounter teaching and escalation

Introduce a new enemy alone or in a low-pressure setting, demonstrate its warning and recovery, then combine it with a known threat. Place combat on stable landings before demanding simultaneous movement. Never teach a new enemy and an unpreviewed lethal platform transformation at the same instant.

An encounter specifies roles and approximate small groups, not final spawn tuning. Reinforcements are finite and visible. The first Howler wakes a known nearby group; Patchbot and medical repair combinations cannot create endless progression locks. Move enemies apart when their cues become indistinguishable.

Mini-boss difficulty grows through different skills: charge recognition, changing terrain, support-target priority, then identity switching with controlled overlap. The hardest boss keeps at most two attack threats active; moving platforms do not eliminate the last safe route. More health alone is not the planned difficulty curve.

## Checkpoints and resource assumptions

Checkpoint behavior in this pack is a proposed player-friendly baseline. Retries preserve earned weapons, completed story interactions, and completed multi-step support objectives. Local enemies and mechanisms return to a predictable state. Essential fighting resources are restored and the Scrapjack remains a fallback. Avoid duplicate reward farming during reset.

Place a checkpoint directly before every mini-boss, and another after the last boss so failure or interruption during resolution does not repeat the fight. Early movement lessons have catch floors or ledges. Exact damage, life count, failure penalties, ammunition quantities, prices, and save implementation remain undecided.

Do not remove equipment or force one optional purchase for a dramatic beat. Do not add a strict patient-death countdown in level 11. Orderly's first capture needs a readable escape opportunity; its exact input and timing remain a later combat-design decision.

## Secrets, treasure, and story

Optional exploration gives salvage, upgrade resources, and personal environmental stories. Signal something interesting from the main route and reconnect optional paths cleanly. Critical information and required items belong on the authored route. No mandatory arbitrary wall shot, hidden collectible quota, or future-weapon backtracking is assumed.

Quiet spaces are part of pacing: the companion discovery, peaceful Rememberer, transfer records, First Patient reveal, and final EDEN interface must be understandable without simultaneous combat. Environmental storytelling can be visual rather than a wall of text.

## Environment transformations

Every moving or changing feature needs a source, preview, destination, and recovery rule. Hedges move on rails; beds ride guides; roots lift platforms; core decks follow visible mechanisms. Decorative projection changes do not silently change collision.

Never seal an occupied refuge without warning. Reset transformations coherently after failure. Show closed and open states as the same assembly, not two unrelated generated designs. Where a post-story route opens, preserve that state on retry.

## Image-generation workflow

**Prompt 1: environment keyframe.** Generate one representative view. A single image is not expected to show a whole level. Keep characters small or attach their approved references.

**Prompt 2: side-elevation study.** Interpret the six-area route using clean masses and readable surfaces. If six panels are too crowded, generate each separately with the same visual reference. The output is a conceptual map, not proof of valid collision or jumps.

**Prompt 3: modular asset sheet.** Attach the approved keyframe and request the environment kit in subsets. Keep fixed architecture, moving platforms, interactables, enemies, and effects separate. Use consistent proportions and neutral light for modeling references.

**Prompt 4: AI design handoff.** Supply the whole level file and request player-journey analysis, asset lists, story beats, and consistency review. The AI must mark new suggestions and unknowns rather than silently inventing final mechanics.

An image model cannot reliably honor exact counts, line up multiple orthographic views, or prove spatial connections. Compare every output with the written route and character references before modeling. Do not let generated art silently change the level's gameplay.

## File and modeling organization

Each level lists a unique environment kit. Reuse shared corridor, platform, pipe, rail, and service-machine families across levels where appropriate, changing color or wear within the shared visual language. Keep signature landmarks separate from generic modular pieces.

Preserve individual components for hinges, lifts, rails, roots, boss gates, and warning effects. Boss bodies and their arenas are distinct asset sets. The First Patient's body is a protected background story asset rather than an enemy collision object.

No engine, code architecture, polygon target, shader implementation, texture resolution, or file format is chosen here. Those are later production decisions.

## Design review checklist

- There are exactly twelve levels and four scheduled mini-bosses.
- Each area has a clear entry, intended action, safe response, and exit.
- Tools and enemies appear in the established order.
- Required routes work with base capabilities and leave visible recoveries.
- Friendly or peaceful patients are not accidental mandatory targets.
- Returned obey the interface-and-tissue infection rule.
- Every boss opening is usable without a specific optional upgrade.
- Generated images agree with the written route, part counts, and approved asset identities.
- The ending preserves life support and halts harmful treatment without pretending the entire outbreak is cured.
