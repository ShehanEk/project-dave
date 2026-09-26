# Level 1 — Welcome to Sunnyvale

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L01

**Campaign group:** Sunnyvale's perfect lie

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Selected 2D scene references

Use the selected [Sunnyvale gallery](../concept-art/l01-sunnyvale/README.md): A02 front gardens, A04 neighborhood square and A06 quarantine exit. The [2D Clipper](../concept-art/r01-clipper/SELECTED.md) and [2D Resident](../concept-art/z01-resident/SELECTED.md) are the complete Level 1 enemy roster. These images select the visual direction; written routes and encounter rules still own gameplay when a picture is ambiguous.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A lone scavenger explores a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A perfect artificial suburb slowly reveals that its inhabitants have died and its cheerful maintenance routines cannot tell the difference.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Find the rumored power core in the neighborhood maintenance depot and escape onto the garden path after attempting to release its mounted housing awakens EDEN. |
| Intended difficulty | Introductory |
| First successful exploration target | 10–14 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Scrapjack Pistol (available at entry) |
| Weapon types introduced by level end | Scrapjack Pistol |
| New enemy types | Resident, Clipper |
| Mini-boss | None |

## Story entry and exit

**Entry:** The scavenger climbs through a broken perimeter service gate seeking a valuable power core. EDEN's local systems still operate under standing instructions; the central intelligence has not yet fully awakened.

**Exit:** The power core remains installed in the depot. The hero escapes alone toward the quarantine gardens of level 2.

The horror comes from the same meal being delivered to the same unresponsive resident, then from discovering that the advertised treasure is still powering an occupied facility. EDEN initially speaks with sincere hospitality.

## What the level looks like

Pastel cream houses have rounded rooflines, fat ceramic gutters, scalloped porch awnings, and perfectly clipped bulbous shrubs. Oversized flowers grow in neat mechanical planters. A pale blue sky is an illuminated habitat ceiling, first visible through one broken cloud projector. Keep the lower service infrastructure hidden until the last third. Nothing is abandoned-looking at first glance: the wrongness is repeated routines and unattended meals.

**Palette and lighting:** Warm cream #EFE0BE, soft peach #DF9E80, lawn green #87B45E, pale sky blue #A9D6DD, dark teal service recesses #365D62. Golden simulated morning light; sharper cyan utility light appears inside the depot.

**Navigation landmark:** A smiling sun-shaped neighborhood clock sits above the maintenance depot and can be glimpsed from several route positions.

## Foreground, playable plane, and background

- **Foreground framing:** Thin fence edges, a few oversized flowers, and mailbox corners frame the screen edges. Their opacity or placement must never hide feet, enemies, or landing edges.
- **Playable plane:** Solid porch floors, roof terraces, low garden walls, a slow maintenance platform, and the depot interior form the collision route. Usable surfaces have broad light top edges and visible supports.
- **Background depth:** Two layers of homes, orderly lawns, looping robot-bird silhouettes, and the cloud ceiling. Background Residents are distant noninteractive routines, never targets requiring a depth switch.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Perimeter gate → A02 Front gardens → A03 Rooftop walk → A04 Neighborhood square → A05 Maintenance depot → A06 Alarm exit.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L01-A01 — Perimeter gate

**Space and placement:** A flat entrance apron leads to two low garden steps and a shallow catchable gap. Place an inert target on a fence beyond a clear firing lane; no enemy can reach the player here.

**Player experience and lesson:** Let the player move, jump, and fire the pistol without danger. A visible gem above the steps teaches that exploration uses the same basic movement.

**Completion and connection:** Cross the open gate to A02; no key or hidden input is required.

### L01-A02 — Front gardens

**Space and placement:** Two short yards are separated by a low wall. One Resident patrols the first yard. One Clipper waits in the second, facing a sturdy stone planter.

**Player experience and lesson:** Introduce each enemy alone. Give the Resident time to show its lunge. The Clipper's failed wall charge demonstrates recovery openings without requiring the player to discover them under pressure.

**Completion and connection:** A porch step leads upward to A03; the ground route remains a safe fallback during practice.

### L01-A03 — Rooftop walk

**Space and placement:** Three broad roof terraces are linked by a slow maintenance platform over a shallow service lane. Put one Resident on a wide far terrace, not on the landing edge.

**Player experience and lesson:** Introduce waiting for a moving platform and judging a landing before shooting. A lower recovery path returns to the first terrace if a jump is missed.

**Completion and connection:** The final roof descends gently into A04.

### L01-A04 — Neighborhood square

**Space and placement:** A wide clear square surrounds a nonblocking fountain. Place one Clipper on the lower lane and two staggered Residents on the farther side, with a central raised flowerbed for separation.

**Player experience and lesson:** Combine familiar patterns while leaving a retreat route. Set the first interior checkpoint on the quiet far porch after the encounter.

**Completion and connection:** The clock landmark marks the depot door into A05.

### L01-A05 — Maintenance depot

**Space and placement:** A compact workshop shows neatly sorted spare parts, a fixed maintenance bench, and the sought-after power core inside a bolted floor-mounted housing. A care console displays active ward circuits. No hostile spawn interrupts the interaction.

**Player experience and lesson:** The hero opens the power-core access panel and tries its release latch. A safety interlock locks the housing and calls the central intelligence. EDEN fully awakens and orders containment; the hero takes the emergency exit. The core remains installed and powering the facility.

**Completion and connection:** The event opens a clearly lit emergency hatch into A06 and changes the neighborhood's lighting.

### L01-A06 — Alarm exit

**Space and placement:** Garden panels rotate into temporary railings while ceiling cloud lights shift to a quarantine pattern. These movements happen ahead of the player, never beneath an occupied landing.

**Player experience and lesson:** A single familiar Clipper tests movement under new presentation, not a new mechanic. Reach the service wicket alone.

**Completion and connection:** Crossing the wicket completes the level and leads directly to level 2.

## Signature environment change

The awakening turns neighborhood decoration into medical wayfinding: flower lamps swivel into examination lights and neat fences become quarantine guides. It occurs once, with a pause to read the changed exit; it does not introduce a timed escape.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Start with individual enemies, then combine one charger and a small number of shamblers in a wide area. Avoid simultaneous airborne or ranged threats. The final encounter reuses known behavior.

- [Resident](../art-design/zombies/z01-resident.md) — first introduction in this level.
- [Clipper](../art-design/robots/r01-clipper.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A04, before entering the depot.
- After the A05 depot event, before A06; retain EDEN's awakening, the installed power core, and the open emergency hatch on retry.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A visible roof-alcove gem cache above A03, reachable with ordinary jumps from an optional porch ladder route.
- A readable family portrait and untouched breakfast in a side room at A02; supplies the first quiet story detail without a quest requirement.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Birdlike mechanical chirps, soft sprinkler clicks, and a gentle neighborhood jingle. At awakening, the same jingle shifts to a slower announcement motif rather than sudden horror stingers.

## Environment asset kit and layer separation

**Required kit:** Rounded house fronts and roof corners; porch and garden-wall modules; fence posts; planter blocks; clock landmark; depot workbench; fixed power-core housing and care console; cloud-ceiling panels; examination-flower light; rotating quarantine rail.

**Separate objects:** House shells, collision terraces, moving platform, rotating fences, and lights must be distinct assets. The hero and enemies use separate character assets; the fixed core housing and console are separate environment props.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

Do not show Returned, overt medical laboratories before the depot reveal, advanced weapons, a boss, gore, or a destroyed post-apocalyptic town. No mandatory double jump, dash, wall run, swimming, or climbing mechanic is introduced.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 1, "Welcome to Sunnyvale".
Narrative purpose: A perfect artificial suburb slowly reveals that its inhabitants have died and its cheerful maintenance routines cannot tell the difference.
Physical setting: Pastel cream houses have rounded rooflines, fat ceramic gutters, scalloped porch awnings, and perfectly clipped bulbous shrubs. Oversized flowers grow in neat mechanical planters. A pale blue sky is an illuminated habitat ceiling, first visible through one broken cloud projector. Keep the lower service infrastructure hidden until the last third. Nothing is abandoned-looking at first glance: the wrongness is repeated routines and unattended meals.
Color and lighting: Warm cream #EFE0BE, soft peach #DF9E80, lawn green #87B45E, pale sky blue #A9D6DD, dark teal service recesses #365D62. Golden simulated morning light; sharper cyan utility light appears inside the depot.
Landmark: A smiling sun-shaped neighborhood clock sits above the maintenance depot and can be glimpsed from several route positions.
Composition to show: The neighborhood square seen from the actual side camera: a cream porch on the left, a raised fountain planter in the center, a Clipper below it, and the smiling clock over the depot at the right.
Foreground: Thin fence edges, a few oversized flowers, and mailbox corners frame the screen edges. Their opacity or placement must never hide feet, enemies, or landing edges.
Playable plane: Solid porch floors, roof terraces, low garden walls, a slow maintenance platform, and the depot interior form the collision route. Usable surfaces have broad light top edges and visible supports.
Background: Two layers of homes, orderly lawns, looping robot-bird silhouettes, and the cloud ceiling. Background Residents are distant noninteractive routines, never targets requiring a depth switch.
Show only this level's appropriate era and threats: Resident, Clipper; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: Do not show Returned, overt medical laboratories before the depot reveal, advanced weapons, a boss, gore, or a destroyed post-apocalyptic town. No mandatory double jump, dash, wall run, swimming, or climbing mechanic is introduced.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 1, "Welcome to Sunnyvale". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Perimeter gate → A02 Front gardens → A03 Rooftop walk → A04 Neighborhood square → A05 Maintenance depot → A06 Alarm exit.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L01-A01: Perimeter gate. A flat entrance apron leads to two low garden steps and a shallow catchable gap. Place an inert target on a fence beyond a clear firing lane; no enemy can reach the player here. Connection: Cross the open gate to A02; no key or hidden input is required.
L01-A02: Front gardens. Two short yards are separated by a low wall. One Resident patrols the first yard. One Clipper waits in the second, facing a sturdy stone planter. Connection: A porch step leads upward to A03; the ground route remains a safe fallback during practice.
L01-A03: Rooftop walk. Three broad roof terraces are linked by a slow maintenance platform over a shallow service lane. Put one Resident on a wide far terrace, not on the landing edge. Connection: The final roof descends gently into A04.
L01-A04: Neighborhood square. A wide clear square surrounds a nonblocking fountain. Place one Clipper on the lower lane and two staggered Residents on the farther side, with a central raised flowerbed for separation. Connection: The clock landmark marks the depot door into A05.
L01-A05: Maintenance depot. A compact workshop shows neatly sorted spare parts, a fixed maintenance bench, and the sought-after power core inside a bolted floor-mounted housing. A care console displays active ward circuits. No hostile spawn interrupts the interaction. Connection: The event opens a clearly lit emergency hatch into A06 and changes the neighborhood's lighting.
L01-A06: Alarm exit. Garden panels rotate into temporary railings while ceiling cloud lights shift to a quarantine pattern. These movements happen ahead of the player, never beneath an occupied landing. Connection: Crossing the wicket completes the level and leads directly to level 2.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 1, "Welcome to Sunnyvale". Match these materials and colors: Warm cream #EFE0BE, soft peach #DF9E80, lawn green #87B45E, pale sky blue #A9D6DD, dark teal service recesses #365D62. Golden simulated morning light; sharper cyan utility light appears inside the depot.
Required asset family: Rounded house fronts and roof corners; porch and garden-wall modules; fence posts; planter blocks; clock landmark; depot workbench; fixed power-core housing and care console; cloud-ceiling panels; examination-flower light; rotating quarantine rail.
Separation rules: House shells, collision terraces, moving platform, rotating fences, and lights must be distinct assets. The hero and enemies use separate character assets; the fixed core housing and console are separate environment props.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 1 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The first moving-platform failure has a recoverable lower route.
- The depot event leaves the power core installed and the hero traveling alone.
- EDEN's central awakening occurs once at A05, while earlier local routines remain understandable.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
