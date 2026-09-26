# Level 5 — Compost Confidential

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L05

**Campaign group:** Beneath the roots

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A botanical recycling plant has become a luminous underground garden where treatment runoff makes the plants and former workers grow in the wrong ways.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Recover the Seedlobber, cross the overgrown recycling system, and lower the soil sluice leading to the pumping station. |
| Intended difficulty | Moderate |
| First successful exploration target | 15–19 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Seedlobber |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber |
| New enemy types | Gardener, Spitter, Burrower |
| Mini-boss | None |

## Story entry and exit

**Entry:** The compost freight door opens onto a raised inspection walkway above soil-processing vats. The hero still needs the pump route to reach the hospital.

**Exit:** A dry service passage beneath the lowered sluice leads to level 6's reservoir approach.

The garden is beautiful because it is being overfed with experimental treatment waste. The hero sees a Gardener tending one undamaged flower before it notices them.

## What the level looks like

Large ivory compost drums, terracotta planting troughs, and broad green processing belts have been invaded by bulbous mushrooms, coiled roots, and giant leaves. Soil looks soft and patterned; safe service metal looks firm and clean-edged. Growth is exuberant and colorful, with clearly bounded areas of hazardous runoff.

**Palette and lighting:** Terracotta #B97850, moss green #769950, pale cream #E3D5B9, muted violet fungi #A291BF, honey bioluminescence #D9C16D. Keep the playable floor brighter than vat interiors.

**Navigation landmark:** A giant leaf canopy grows out of a tilted compost drum, with a hanging orange sluice wheel visible beyond it.

## Foreground, playable plane, and background

- **Foreground framing:** Low rounded fungi and cut pipe mouths frame corners. Avoid dense fog and drifting spores that conceal ground-ripple warnings.
- **Playable plane:** Metal inspection ledges, broad moving compost lifts, visible root platforms, and isolated patches of diggable soil. Each floor material has a distinct top edge.
- **Background depth:** Layered vats, distant slow-turning drums, huge leaf shapes, drainage pipes, and shallow light shafts from the garden above.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Supply depot → A02 Root nursery → A03 Spitter troughs → A04 Soft-soil crossing → A05 Rising compost lifts → A06 Sluice controls.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L05-A01 — Supply depot

**Space and placement:** The Seedlobber rests in a protected botanical depot before the first mutated worker. A low wall and inert target let the player test an arc from a safe distance.

**Player experience and lesson:** Demonstrate bounce, delay, and self-danger without a required self-damage event. Show the pod landing clearly rather than hiding it behind scenery.

**Completion and connection:** A short ramp enters A02; retry restores the single weapon saved after the pickup choice.

### L05-A02 — Root nursery

**Space and placement:** One Gardener occupies a flat soil bed separated from the hero by a low root. Fixed metal side ledges remain safe from ground growth.

**Player experience and lesson:** Observe anchoring and the traveling pulse before thorns emerge. A visible exposed root can be shot; jumping to metal provides another response.

**Completion and connection:** The clear far ledge leads to A03.

### L05-A03 — Spitter troughs

**Space and placement:** A Spitter sits behind low cover across a broad planter trench. Its pouch and projectile arc remain visible above the wall. Provide two separated safe firing positions.

**Player experience and lesson:** Teach reading an arcing attack and moving between positions. Seedlobber can arc back over cover, but an upper ledge also gives a direct pistol shot.

**Completion and connection:** Reach a quiet observation shelf and checkpoint.

### L05-A04 — Soft-soil crossing

**Space and placement:** Two isolated soil patches are divided by firm plates. The first Burrower creates a clear traveling ripple under an otherwise empty patch.

**Player experience and lesson:** Teach moving away from the last marked position. The second patch combines a Burrower with a distant Resident only after the player has seen an emergence.

**Completion and connection:** Exit to a stable platform at A05.

### L05-A05 — Rising compost lifts

**Space and placement:** Two broad bucket-like lifts rise through a short shaft beside fixed catch ledges. A Gardener occupies a far fixed shelf; one Spitter is visible beyond the next refuge.

**Player experience and lesson:** Alternate movement and combat rather than filling every jump with attacks. The route always offers a noncrumbling landing before each ranged exchange.

**Completion and connection:** The upper lift lands beside A06.

### L05-A06 — Sluice controls

**Space and placement:** A final open chamber combines one Gardener and one Spitter, with wide metal refuges and an obvious manual wheel. Burrower soil is absent here to avoid three simultaneous area hazards.

**Player experience and lesson:** Use learned cover, jumping, and arcing fire. After the fight, turn the wheel to drain a blocked dry passage.

**Completion and connection:** The dry passage opens to level 6.

## Signature environment change

A growth-treatment pipe leaks into an empty bed, rapidly raising a thick root bridge. The camera previews the growing platform before it becomes usable. Growth closes a decorative background channel while opening the main forward route; it never requires guessing through obscuring foliage.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Each new biological role has its own material and warning lesson: rooted thorns, arcing spit, and moving soil. The final combination uses two roles, not all three. Avoid endless spawns from vats.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Gardener](../art-design/zombies/z03-gardener.md) — first introduction in this level.
- [Spitter](../art-design/zombies/z04-spitter.md) — first introduction in this level.
- [Burrower](../art-design/zombies/z08-burrower.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 after the Seedlobber lesson.
- After A03 on the observation shelf.
- At the stable upper landing before A06.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A cache on an optional root loop above A02, reachable with basic jumps.
- A worker's annotated planting chart in a dry recess at A04 explaining that rapid-growth compounds were used on people as well as crops.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Wet soil shifts, hollow drum creaks, soft plant rustle, and distinct Burrower scraping. Keep explosive-pod fuse cues audible against the environment.

## Environment asset kit and layer separation

**Required kit:** Compost drums; trough walls; firm metal plates; soft-soil patches; lift buckets; root bridges and joints; broad leaf canopy; closed runoff pipes; sluice wheel and door; fungi clusters.

**Separate objects:** Diggable soil warning surfaces and thorn segments are independent from the base floor. Moving lifts, grown bridge, and vat scenery use separate assemblies. Do not bake hazard clouds into diffuse textures.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No robot-zombie hybrids, autonomous infected machinery, compulsory swimming, tether puzzles, or boss. Seedlobber roots are botanical effects rather than a route for robot infection.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 5, "Compost Confidential".
Narrative purpose: A botanical recycling plant has become a luminous underground garden where treatment runoff makes the plants and former workers grow in the wrong ways.
Physical setting: Large ivory compost drums, terracotta planting troughs, and broad green processing belts have been invaded by bulbous mushrooms, coiled roots, and giant leaves. Soil looks soft and patterned; safe service metal looks firm and clean-edged. Growth is exuberant and colorful, with clearly bounded areas of hazardous runoff.
Color and lighting: Terracotta #B97850, moss green #769950, pale cream #E3D5B9, muted violet fungi #A291BF, honey bioluminescence #D9C16D. Keep the playable floor brighter than vat interiors.
Landmark: A giant leaf canopy grows out of a tilted compost drum, with a hanging orange sluice wheel visible beyond it.
Composition to show: A side-view recycling cavern with ivory vats in the background, a seed-launcher depot on the left, a thick new root bridge in the center, and a Spitter behind a low terracotta trough on the right.
Foreground: Low rounded fungi and cut pipe mouths frame corners. Avoid dense fog and drifting spores that conceal ground-ripple warnings.
Playable plane: Metal inspection ledges, broad moving compost lifts, visible root platforms, and isolated patches of diggable soil. Each floor material has a distinct top edge.
Background: Layered vats, distant slow-turning drums, huge leaf shapes, drainage pipes, and shallow light shafts from the garden above.
Show only this level's appropriate era and threats: Resident, Gardener, Spitter, Burrower; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No robot-zombie hybrids, autonomous infected machinery, compulsory swimming, tether puzzles, or boss. Seedlobber roots are botanical effects rather than a route for robot infection.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 5, "Compost Confidential". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Supply depot → A02 Root nursery → A03 Spitter troughs → A04 Soft-soil crossing → A05 Rising compost lifts → A06 Sluice controls.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L05-A01: Supply depot. The Seedlobber rests in a protected botanical depot before the first mutated worker. A low wall and inert target let the player test an arc from a safe distance. Connection: A short ramp enters A02; retry restores the single weapon saved after the pickup choice.
L05-A02: Root nursery. One Gardener occupies a flat soil bed separated from the hero by a low root. Fixed metal side ledges remain safe from ground growth. Connection: The clear far ledge leads to A03.
L05-A03: Spitter troughs. A Spitter sits behind low cover across a broad planter trench. Its pouch and projectile arc remain visible above the wall. Provide two separated safe firing positions. Connection: Reach a quiet observation shelf and checkpoint.
L05-A04: Soft-soil crossing. Two isolated soil patches are divided by firm plates. The first Burrower creates a clear traveling ripple under an otherwise empty patch. Connection: Exit to a stable platform at A05.
L05-A05: Rising compost lifts. Two broad bucket-like lifts rise through a short shaft beside fixed catch ledges. A Gardener occupies a far fixed shelf; one Spitter is visible beyond the next refuge. Connection: The upper lift lands beside A06.
L05-A06: Sluice controls. A final open chamber combines one Gardener and one Spitter, with wide metal refuges and an obvious manual wheel. Burrower soil is absent here to avoid three simultaneous area hazards. Connection: The dry passage opens to level 6.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 5, "Compost Confidential". Match these materials and colors: Terracotta #B97850, moss green #769950, pale cream #E3D5B9, muted violet fungi #A291BF, honey bioluminescence #D9C16D. Keep the playable floor brighter than vat interiors.
Required asset family: Compost drums; trough walls; firm metal plates; soft-soil patches; lift buckets; root bridges and joints; broad leaf canopy; closed runoff pipes; sluice wheel and door; fungi clusters.
Separation rules: Diggable soil warning surfaces and thorn segments are independent from the base floor. Moving lifts, grown bridge, and vat scenery use separate assemblies. Do not bake hazard clouds into diffuse textures.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 5 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The Seedlobber's delay and danger are shown before crowded use.
- Only clearly marked soil supports Burrower attacks.
- Lift jumps retain fixed catch ledges.
- The level ends at a sluice passage rather than inventing another mini-boss.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
