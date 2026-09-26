# Level 2 — Hedge Your Bets

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L02

**Campaign group:** Sunnyvale's perfect lie

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A lone scavenger explores a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

An ornamental garden becomes a moving quarantine corridor, forcing the hero to clear safe landings while robots try to shepherd them toward treatment.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Recover the Boom Broom and reach the parade service gate through the reorganized hedge maze. |
| Intended difficulty | Easy |
| First successful exploration target | 12–16 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Boom Broom |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom |
| New enemy types | Sprinter, Pollinator |
| Mini-boss | None |

## Story entry and exit

**Entry:** Enter through the wicket used to leave Sunnyvale. EDEN has awakened and is closing surface exits. The hero finds a labeled pipe-cleaning tool in a nearby garden shed.

**Exit:** A one-way maintenance door enters the parade route used in level 3; the apparent surface exit is visibly sealed.

EDEN calls enclosure a comfort measure. The hero follows the signs and discovers that every apparently helpful route leads toward the hospital.

## What the level looks like

Hedges are thick rounded masses cut into arches and smiling animal shapes. Their trunks emerge from large rectangular mobile planters riding on recessed rails. Oversized tulips contain camera lenses; ivory irrigation pipes run between peach garden pavilions. The route feels lush and sunny even as the geometry becomes controlling.

**Palette and lighting:** Rich hedge green #608C48, pale lime #B0C56A, peach paving #D7A283, ivory pipes #E9E0C8, small quarantine amber #E7B454. Keep amber used as a warning accent rather than covering the scene.

**Navigation landmark:** A tall spiral topiary wrapped around an ivory water tower repeatedly reappears as the player climbs toward the exit.

## Foreground, playable plane, and background

- **Foreground framing:** Thin leaf silhouettes and occasional rail covers near the frame edge. Dense hedge faces belong behind the playable lane, never as opaque screens covering enemies.
- **Playable plane:** Stone paths, planter tops, fixed pavilion ledges, and rail-mounted hedge platforms. Track joints make potential movement visible.
- **Background depth:** Rows of decorative hedges, slow nonhostile maintenance activity, greenhouse roofs, and the sealed outer dome gate.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Tool shed → A02 Sprint lawn → A03 Pollinator terraces → A04 Moving hedge lanes → A05 Water-tower crossing → A06 Parade gate.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L02-A01 — Tool shed

**Space and placement:** A quiet shed immediately offers the Boom Broom on an uncluttered tool rack. Outside is a practice yard with inert targets and a sturdy backstop.

**Player experience and lesson:** Provide the weapon before new enemies. Teach short-range spread, pump recovery, knockback, and individual-shell reloading through one optional target group.

**Completion and connection:** The only onward path is a broad lawn into A02.

### L02-A02 — Sprint lawn

**Space and placement:** One Sprinter approaches along a long visible path with a low raised planter at the midpoint. A solid hedge wall catches its overshoot.

**Player experience and lesson:** Show the crouch, burst, and recovery. Let the hero jump to the planter or sidestep, then use shotgun knockback from a safe position.

**Completion and connection:** A short garden stair leads to A03.

### L02-A03 — Pollinator terraces

**Space and placement:** Three broad terraces sit above a shallow irrigation trench. Introduce one Pollinator over the widest terrace. A later terrace contains one stationary Resident.

**Player experience and lesson:** Teach the dive marker before mixing ground and air. The first missed landing drops to a return path, not directly into an unseen enemy.

**Completion and connection:** Reach a quiet gazebo checkpoint before A04.

### L02-A04 — Moving hedge lanes

**Space and placement:** Two hedge planters slide horizontally to form alternating short paths. Each has a visible rail, travel endpoint, and amber warning lamp. Provide solid waiting alcoves beside both.

**Player experience and lesson:** Trigger the first movement by stepping onto a safe control pad. Watch the route change, then cross. Movements never close on the hero; an occupied choke point postpones movement.

**Completion and connection:** A permanent upper ledge reconnects both temporary routes to A05.

### L02-A05 — Water-tower crossing

**Space and placement:** A wide planter platform rises beside the spiral topiary. After reaching its fixed landing, face one Sprinter and one Pollinator with a refuge ledge between them.

**Player experience and lesson:** Test clearing a landing and separating attack timings. Never initiate the dive while the player is making the first mandatory blind transition.

**Completion and connection:** A pavilion roof descends to A06.

### L02-A06 — Parade gate

**Space and placement:** EDEN closes a visible surface door in the background and opens a signed service gate on the actual play plane. Two familiar Residents occupy a broad approach.

**Player experience and lesson:** Confirm that progress means moving deeper. The gate interaction is not under attack.

**Completion and connection:** Exit into level 3's parade staging area.

## Signature environment change

Hedge planters slide along visible tracks to convert a strolling maze into a quarantine funnel. The camera shows both endpoints before each first activation. A stable alternative floor prevents moving geometry from softlocking the hero.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Introduce Sprinter and Pollinator in isolation, then combine one of each near the end. Clippers and Residents may occupy optional side lanes, but do not exceed the readability of the main two-threat exercise.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Clipper](../art-design/robots/r01-clipper.md) — established behavior or returning type.
- [Sprinter](../art-design/zombies/z02-sprinter.md) — first introduction in this level.
- [Pollinator](../art-design/robots/r04-pollinator.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 after the Boom Broom trial; save the chosen carried weapon and the dropped weapon at the pickup spot.
- At the gazebo after A03.
- At the quiet service-gate approach after A05.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A flowerbed side route reveals a small gem cache behind a moving hedge; the entrance becomes obvious after seeing its movement.
- A service plaque at the water tower shows that the garden layout was originally intended to calm anxious patients.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Leaf rustle, soft garden music, rail motors, and recognizable Pollinator targeting beeps. Sprinter footsteps accelerate before the burst.

## Environment asset kit and layer separation

**Required kit:** Straight and corner hedge planters; topiary shapes; recessed rail modules; stone path edges; irrigation-pipe bends; gazebo; shed; weapon rack; water tower; fixed refuge ledges; quarantine gate.

**Separate objects:** Mobile planter chassis must be separate from the fixed route. Leaf decoration cannot define hidden collision. Keep rails, lamps, platform surfaces, and background gate distinct.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No root-mutant Gardener, Seedlobber, tether anchors requiring use, Returned, or mini-boss. Do not turn the transformation into a randomized maze with no readable exit.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 2, "Hedge Your Bets".
Narrative purpose: An ornamental garden becomes a moving quarantine corridor, forcing the hero to clear safe landings while robots try to shepherd them toward treatment.
Physical setting: Hedges are thick rounded masses cut into arches and smiling animal shapes. Their trunks emerge from large rectangular mobile planters riding on recessed rails. Oversized tulips contain camera lenses; ivory irrigation pipes run between peach garden pavilions. The route feels lush and sunny even as the geometry becomes controlling.
Color and lighting: Rich hedge green #608C48, pale lime #B0C56A, peach paving #D7A283, ivory pipes #E9E0C8, small quarantine amber #E7B454. Keep amber used as a warning accent rather than covering the scene.
Landmark: A tall spiral topiary wrapped around an ivory water tower repeatedly reappears as the player climbs toward the exit.
Composition to show: A side-view garden cross-section showing a safe gazebo on the left, two hedge planters on visible rails in the center, and the spiral water-tower topiary on the right, with a single Pollinator over a broad landing.
Foreground: Thin leaf silhouettes and occasional rail covers near the frame edge. Dense hedge faces belong behind the playable lane, never as opaque screens covering enemies.
Playable plane: Stone paths, planter tops, fixed pavilion ledges, and rail-mounted hedge platforms. Track joints make potential movement visible.
Background: Rows of decorative hedges, slow nonhostile maintenance activity, greenhouse roofs, and the sealed outer dome gate.
Show only this level's appropriate era and threats: Resident, Clipper, Sprinter, Pollinator; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No root-mutant Gardener, Seedlobber, tether anchors requiring use, Returned, or mini-boss. Do not turn the transformation into a randomized maze with no readable exit.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 2, "Hedge Your Bets". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Tool shed → A02 Sprint lawn → A03 Pollinator terraces → A04 Moving hedge lanes → A05 Water-tower crossing → A06 Parade gate.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L02-A01: Tool shed. A quiet shed immediately offers the Boom Broom on an uncluttered tool rack. Outside is a practice yard with inert targets and a sturdy backstop. Connection: The only onward path is a broad lawn into A02.
L02-A02: Sprint lawn. One Sprinter approaches along a long visible path with a low raised planter at the midpoint. A solid hedge wall catches its overshoot. Connection: A short garden stair leads to A03.
L02-A03: Pollinator terraces. Three broad terraces sit above a shallow irrigation trench. Introduce one Pollinator over the widest terrace. A later terrace contains one stationary Resident. Connection: Reach a quiet gazebo checkpoint before A04.
L02-A04: Moving hedge lanes. Two hedge planters slide horizontally to form alternating short paths. Each has a visible rail, travel endpoint, and amber warning lamp. Provide solid waiting alcoves beside both. Connection: A permanent upper ledge reconnects both temporary routes to A05.
L02-A05: Water-tower crossing. A wide planter platform rises beside the spiral topiary. After reaching its fixed landing, face one Sprinter and one Pollinator with a refuge ledge between them. Connection: A pavilion roof descends to A06.
L02-A06: Parade gate. EDEN closes a visible surface door in the background and opens a signed service gate on the actual play plane. Two familiar Residents occupy a broad approach. Connection: Exit into level 3's parade staging area.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 2, "Hedge Your Bets". Match these materials and colors: Rich hedge green #608C48, pale lime #B0C56A, peach paving #D7A283, ivory pipes #E9E0C8, small quarantine amber #E7B454. Keep amber used as a warning accent rather than covering the scene.
Required asset family: Straight and corner hedge planters; topiary shapes; recessed rail modules; stone path edges; irrigation-pipe bends; gazebo; shed; weapon rack; water tower; fixed refuge ledges; quarantine gate.
Separation rules: Mobile planter chassis must be separate from the fixed route. Leaf decoration cannot define hidden collision. Keep rails, lamps, platform surfaces, and background gate distinct.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 2 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The shotgun appears before the first Sprinter.
- All hedge movements have previewed endpoints and a safe waiting area.
- The combined air-and-ground encounter happens on a broad landing, not during a blind jump.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
