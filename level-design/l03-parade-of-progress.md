# Level 3 — Parade of Progress

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L03

**Campaign group:** Sunnyvale's perfect lie

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A lone scavenger explores a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A relentlessly cheerful civic parade becomes a moving obstacle course and ends with its enormous robotic groundskeeper trying to prune the hero.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Ride and cross the parade route, learn the new shield and turret patterns, then defeat Mr. Mulch to access the Rootworks lift. |
| Intended difficulty | Easy; first boss test |
| First successful exploration target | 14–18 minutes including mini-boss; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom |
| New enemy types | Bloom Sentry, Courtesy Officer |
| Mini-boss | Mr. Mulch |

## Story entry and exit

**Entry:** Enter behind the parade's staging pavilions. The only open maintenance lift is at the terminus, under the authority of the grand marshal.

**Exit:** The lift descends from the sunny terminus into level 4's utility freight corridor.

EDEN describes the hero as an invasive species obstructing a public celebration. The parade continues in the background after the boss falls, emphasizing the AI's persistent routines.

## What the level looks like

Chunky flower floats, painted service mascots, striped canopies, inflated-looking metal balloons, and clean cream paving frame an absurd celebration of public wellbeing. Floats have visible powered wheel bases rather than levitating decorations. A ceremonial arch reveals the hidden lift beneath it after the fight.

**Palette and lighting:** Warm cream #EFDFB8, coral #E88F78, garden green #81A956, butter yellow #E4BF55, teal shadows #497A7B. Lighting remains cheerful; danger comes from machinery, not darkness.

**Navigation landmark:** A giant smiling sun arch with a closed floor hatch beneath it; Mr. Mulch's canopy echoes the arch's festive shapes.

## Foreground, playable plane, and background

- **Foreground framing:** Sparse bunting and low flower edges. Suspend banners high enough not to cover airborne targets or jump trajectories.
- **Playable plane:** Stationary viewing steps, slow float decks, connecting service platforms, and a wide terminal plaza. Show wheel clearance beneath moving float decks.
- **Background depth:** Additional parade lanes, looping cheering hologram silhouettes, ornamental town facades, and the habitat ceiling. Background floats cannot be entered or mistaken for active platforms.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Staging yard → A02 Turret float → A03 Security checkpoint → A04 Parade crossing → A05 Terminus refuge → A06 Mr. Mulch arena.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L03-A01 — Staging yard

**Space and placement:** Board a low stationary float, then cross to a second float moving slowly along a short visible track. A fixed service ledge runs below the practice jump.

**Player experience and lesson:** Teach movement relative to a float without attacking enemies or full-screen forced scrolling.

**Completion and connection:** Step onto a stationary viewing platform at A02.

### L03-A02 — Turret float

**Space and placement:** One Bloom Sentry stands on a slowly moving float beside broad stationary cover. Its petals open in full view before its first burst.

**Player experience and lesson:** Teach the closed armor and open-center window. The hero can wait, jump over the low burst, or shoot from the stable ledge.

**Completion and connection:** A stationary ramp leads into A03.

### L03-A03 — Security checkpoint

**Space and placement:** A single Courtesy Officer blocks a flat parade inspection lane. A low overpass allows an obvious route behind it.

**Player experience and lesson:** Demonstrate front shielding, baton warning, and back exposure. No second enemy interrupts the first observation.

**Completion and connection:** The back of the lane reconnects to the main float route at A04.

### L03-A04 — Parade crossing

**Space and placement:** Two slow floats move along offset sections, with stationary refuges between. Place one Bloom Sentry on a far deck and one Resident on the subsequent stationary landing, separated by camera space.

**Player experience and lesson:** Combine timing and target selection without attacking from outside the screen. A missed jump falls to a service path that rejoins the last refuge.

**Completion and connection:** Climb fixed steps to A05.

### L03-A05 — Terminus refuge

**Space and placement:** A maintenance kiosk, supplies, and the visible closed arena gate sit beneath the sun arch. Show a small demonstration clipper striking a planter behind a sealed safety window if needed.

**Player experience and lesson:** Establish reinforced planters as the boss's collision targets, then save immediately before the fight.

**Completion and connection:** Enter A06 deliberately via the plaza gate.

### L03-A06 — Mr. Mulch arena

**Space and placement:** A broad plaza has permanent side refuge ledges, low central platforms, and reinforced planter walls at both ends. Reserve the ground lane for Mr. Mulch's charge.

**Player experience and lesson:** Read the deck-lowering warning, use the raised route to clear the charge, bait a collision, then shoot the rear motor during reversal. Clippings sweeps occur separately.

**Completion and connection:** Victory opens the floor hatch and the noncombat maintenance lift to level 4.

## Signature environment change

The finishing arch folds its decorative panels outward to reveal service lift machinery after victory. During the fight, the plaza layout stays fixed so the player learns the boss rather than an arena transformation.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

One turret and one shield defender are introduced independently. Later combine only familiar behaviors on stable refuges. No ordinary enemies spawn during Mr. Mulch's fight.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Clipper](../art-design/robots/r01-clipper.md) — established behavior or returning type.
- [Pollinator](../art-design/robots/r04-pollinator.md) — established behavior or returning type.
- [Bloom Sentry](../art-design/robots/r03-bloom-sentry.md) — first introduction in this level.
- [Courtesy Officer](../art-design/robots/r02-courtesy-officer.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry.
- After A03 on a stationary viewing platform.
- At A05 immediately before the boss; boss retries restore the arena, supplies, and Mr. Mulch's first phase.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A small balcony cache reached from the slow float timing route in A04.
- A backstage poster showing that the grand marshal was originally a lawn-maintenance contractor, supporting the boss's identity.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Bright brass-like synthetic parade music, float motor rumble, and an unmistakable spoken charge warning. Quiet the music slightly during attack cues.

## Mini-boss encounter — Mr. Mulch

**Identity:** A fully mechanical four-wheeled mower parade float, 2.50 m tall and 3.80 m long in the art proposal, with a fixed smiling mascot and exposed rear motor after a collision.

**Arena geometry:** One ground charge lane, low stepping platforms, permanent side refuge ledges, and two reinforced planter collision faces. Both refuges connect back into the firing lane.

- Phase 1: one announced charge, planter collision, exposed rear motor and long reversal recovery; clippings sweeps occur in separate cycles.
- Phase 2: two individually signaled charges before a collision opportunity. Keep the same arena and body; no helpers or hidden third attack.

**Damage opening:** Rear motor after collision; either available weapon can deal damage from an unobstructed position.

**Fairness and recovery:** Charge route and planter endpoint are visible before motion. Raised escape routes are reachable with the calibrated basic jump. Do not stack clippings with a charge.

**Victory consequence:** Gems for upgrades and access to the Rootworks lift; no sixth weapon or automatic unplanned upgrade.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b01-mr-mulch.md).

## Environment asset kit and layer separation

**Required kit:** Float deck and wheel chassis; canopy supports; giant molded flowers; viewing steps; fence modules; reinforced planters; service refuge platforms; sun arch; folding arch panels; floor lift hatch.

**Separate objects:** Floats, wheels, rideable decks, and track motion remain distinct. Mr. Mulch is a separate boss asset; planter walls have clear collision faces and readable impact states.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No floor collapse, summon phase, new weapon, Returned, or mandatory tether. Do not make the player jump over the full boss height from flat ground without a designed raised escape route.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 3, "Parade of Progress".
Narrative purpose: A relentlessly cheerful civic parade becomes a moving obstacle course and ends with its enormous robotic groundskeeper trying to prune the hero.
Physical setting: Chunky flower floats, painted service mascots, striped canopies, inflated-looking metal balloons, and clean cream paving frame an absurd celebration of public wellbeing. Floats have visible powered wheel bases rather than levitating decorations. A ceremonial arch reveals the hidden lift beneath it after the fight.
Color and lighting: Warm cream #EFDFB8, coral #E88F78, garden green #81A956, butter yellow #E4BF55, teal shadows #497A7B. Lighting remains cheerful; danger comes from machinery, not darkness.
Landmark: A giant smiling sun arch with a closed floor hatch beneath it; Mr. Mulch's canopy echoes the arch's festive shapes.
Composition to show: A wide gameplay-side arena shot: reinforced planters at left and right, two low platforms, Mr. Mulch with mower deck lowered in the center lane, and the sun arch behind the closed maintenance lift.
Foreground: Sparse bunting and low flower edges. Suspend banners high enough not to cover airborne targets or jump trajectories.
Playable plane: Stationary viewing steps, slow float decks, connecting service platforms, and a wide terminal plaza. Show wheel clearance beneath moving float decks.
Background: Additional parade lanes, looping cheering hologram silhouettes, ornamental town facades, and the habitat ceiling. Background floats cannot be entered or mistaken for active platforms.
Show only this level's appropriate era and threats: Resident, Clipper, Pollinator, Bloom Sentry, Courtesy Officer; mini-boss Mr. Mulch only if this is its arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No floor collapse, summon phase, new weapon, Returned, or mandatory tether. Do not make the player jump over the full boss height from flat ground without a designed raised escape route.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 3, "Parade of Progress". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Staging yard → A02 Turret float → A03 Security checkpoint → A04 Parade crossing → A05 Terminus refuge → A06 Mr. Mulch arena.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L03-A01: Staging yard. Board a low stationary float, then cross to a second float moving slowly along a short visible track. A fixed service ledge runs below the practice jump. Connection: Step onto a stationary viewing platform at A02.
L03-A02: Turret float. One Bloom Sentry stands on a slowly moving float beside broad stationary cover. Its petals open in full view before its first burst. Connection: A stationary ramp leads into A03.
L03-A03: Security checkpoint. A single Courtesy Officer blocks a flat parade inspection lane. A low overpass allows an obvious route behind it. Connection: The back of the lane reconnects to the main float route at A04.
L03-A04: Parade crossing. Two slow floats move along offset sections, with stationary refuges between. Place one Bloom Sentry on a far deck and one Resident on the subsequent stationary landing, separated by camera space. Connection: Climb fixed steps to A05.
L03-A05: Terminus refuge. A maintenance kiosk, supplies, and the visible closed arena gate sit beneath the sun arch. Show a small demonstration clipper striking a planter behind a sealed safety window if needed. Connection: Enter A06 deliberately via the plaza gate.
L03-A06: Mr. Mulch arena. A broad plaza has permanent side refuge ledges, low central platforms, and reinforced planter walls at both ends. Reserve the ground lane for Mr. Mulch's charge. Connection: Victory opens the floor hatch and the noncombat maintenance lift to level 4.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: One ground charge lane, low stepping platforms, permanent side refuge ledges, and two reinforced planter collision faces. Both refuges connect back into the firing lane. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 3, "Parade of Progress". Match these materials and colors: Warm cream #EFDFB8, coral #E88F78, garden green #81A956, butter yellow #E4BF55, teal shadows #497A7B. Lighting remains cheerful; danger comes from machinery, not darkness.
Required asset family: Float deck and wheel chassis; canopy supports; giant molded flowers; viewing steps; fence modules; reinforced planters; service refuge platforms; sun arch; folding arch panels; floor lift hatch.
Separation rules: Floats, wheels, rideable decks, and track motion remain distinct. Mr. Mulch is a separate boss asset; planter walls have clear collision faces and readable impact states.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 3 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and mini-boss phases in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Boss is only at the end of level 3.
- Both new enemies have individual teaching encounters.
- A camera-stable refuge exists between each moving float section.
- Mr. Mulch's second phase is harder through sequence length, not extra enemy clutter.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
