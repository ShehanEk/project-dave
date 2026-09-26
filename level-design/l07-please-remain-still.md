# Level 7 — Please Remain Still

**Approved visual direction (C11):** [Hand-drawn 2D](../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../concept-art/README.md).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L07

**Campaign group:** Care without consent

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A candy-colored hospital treats escape as a symptom, turning patient transport and cleaning systems into carefully coordinated hazards.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross intake and sterilization, reach the observation ward, and open the archive passage toward the Memory Orchard. |
| Intended difficulty | Moderate |
| First successful exploration target | 15–20 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Nurse Needles, Orderly, Sanitizer |
| Mini-boss | None |

## Story entry and exit

**Entry:** The restored supply lift arrives inside Happy Hearts Hospital. The companion expects a transit corridor but finds quarantine beds and living survivors.

**Exit:** The ward archive gate opens into level 8. The survivors remain in a protected care area; no combat escort system is introduced.

Living people are being kept alive without being allowed to leave. EDEN's concern is sincere, but its definition of care has become coercive.

## What the level looks like

Cream walls curve into rounded corners. Mint door frames, peach padded beds, oversized leaf-and-droplet emblems, and friendly pictograms create the appearance of a children's science museum crossed with a hospital. Service slots reveal clinical machinery underneath. Treatment spaces are tidy rather than covered in gore.

**Palette and lighting:** Porcelain cream #EFE7D5, mint #9ECAB6, peach #DEAA92, dusty lavender #AD9DC8, slate machinery #465D68. Warm ward lights contrast with short, explicitly warned sterilization sweeps.

**Navigation landmark:** A large heart-shaped ventilation grille with a leaf emblem hangs over the central intake lift, visible from both lower and upper corridor routes.

## Foreground, playable plane, and background

- **Foreground framing:** Curtain edges and empty trolley handles stay at screen margins. Curtains never conceal incoming Orderlies or syringe telegraphs.
- **Playable plane:** Corridor floors, bed tops, fixed landing shelves, lift cabins, and service balcony sections. Moving beds are low stable platforms with obvious wheel rails.
- **Background depth:** Occupied protected wards behind glass, looping diagnostic graphics, supply robots in deep corridors, and hospital wall recesses. Survivors are not placed in the player's firing path.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Intake lobby → A02 Vaccination corridor → A03 Patient transport lane → A04 Sterilization gallery → A05 Bed-lift junction → A06 Observation ward.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L07-A01 — Intake lobby

**Space and placement:** A safe lobby provides resources for the carried weapon and a view of protected patients through glass. A slow empty bed crosses a short gap beside a fixed return walkway.

**Player experience and lesson:** Introduce moving beds before enemy pressure. No new weapon is given; the player uses whichever single weapon they brought.

**Completion and connection:** Follow the archive sign into A02.

### L07-A02 — Vaccination corridor

**Space and placement:** One Nurse Needles stands beyond two broad cover recesses. Show the launcher wind-up and expose its reload rack clearly.

**Player experience and lesson:** Teach slowing syringes without combining the first hit with a fatal jump. A later short corridor can contain one Resident at a distance.

**Completion and connection:** A fixed side stair rises into A03.

### L07-A03 — Patient transport lane

**Space and placement:** One Orderly patrols a long clear hallway ending in a visible collection ramp. Fixed raised shelves provide a vault route and clear back access.

**Player experience and lesson:** Demonstrate the scoop lowering and charge. If captured, provide a visible escape opportunity before the chute rather than an unexplained instant loss.

**Completion and connection:** Reach a supply alcove checkpoint before A04.

### L07-A04 — Sterilization gallery

**Space and placement:** One Sanitizer operates on a broad floor divided by two raised clean islands. A separate static nozzle demonstrates a warning stripe and safe cooling pause.

**Player experience and lesson:** Teach lingering hot ground and the cooling opening. Keep the first lesson isolated from syringe slow effects.

**Completion and connection:** A clean rear landing leads into A05.

### L07-A05 — Bed-lift junction

**Space and placement:** A short lift shaft connects three fixed floors. On the middle floor, a Nurse and an Orderly occupy separate visible lanes. The top floor hosts one Sanitizer alone.

**Player experience and lesson:** Combine slowing fire with a charge only on a broad stable floor with multiple refuges. Shaft jumps occur while attacks are inactive or separated by walls.

**Completion and connection:** A final fixed balcony leads to A06.

### L07-A06 — Observation ward

**Space and placement:** A safe console faces survivors behind glass. The companion reads care records that count biological activity but ignore patient awareness.

**Player experience and lesson:** Open the archive passage. EDEN comments on unreliable biological memory, preparing the orchard reveal.

**Completion and connection:** Exit into level 8 without moving survivors through enemy rooms.

## Signature environment change

EDEN converts hallway decor into a procedure route: bed rails rise, privacy screens withdraw, and overhead lamps align with floor warning stripes. The first change happens in an empty lobby; later machinery pauses when it would seal an occupied refuge.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Three medical roles receive separate teaching spaces. Only one later encounter combines slow projectiles and transport pressure, on safe flat ground. Avoid stacking syringe slow, moving lift, and fire as a single unavoidable trap.

- [Resident](../art-design/zombies/z01-resident.md) — established behavior or returning type.
- [Sprinter](../art-design/zombies/z02-sprinter.md) — established behavior or returning type.
- [Nurse Needles](../art-design/robots/r05-nurse-needles.md) — first introduction in this level.
- [Orderly](../art-design/robots/r06-orderly.md) — first introduction in this level.
- [Sanitizer](../art-design/robots/r08-sanitizer.md) — first introduction in this level.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 intake.
- After A03 in the supply alcove.
- After A05, before the noncombat ward interaction.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A staff breakroom cache accessible from a bed's upper stop; an ordinary return walkway prevents being stranded.
- An abandoned nurse note in A04 explains that sanitization was meant to protect patients, reinforcing the robots' original functions.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Soft hospital announcements, rubber caster squeaks, a gentle monitor rhythm, and distinct rising tones before heat sweeps. Orderly charge dialogue must cut through other sounds.

## Environment asset kit and layer separation

**Required kit:** Rounded corridor sections; mint doors; glass ward panels; beds and rails; lift cabin and shaft landings; cover recesses; sterilization nozzle; warning-floor strips; archive console; heart ventilation landmark.

**Separate objects:** Beds, rails, privacy screens, lift cabins, and nozzles are independent mechanisms. Protected patients are separate background characters with no combat hit targets in this level.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No Returned, neural tissue inside ordinary medical robots, mandatory escort AI, new gun, or boss. Do not make hospital lights pulse so intensely that they hide attack cues.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original hand-drawn 2D environment concept art for DEAD EDEN. Match the selected Sunnyvale scenes' clean dark outlines, rounded architectural shapes, flat painted color masses, crisp cel shadows and sparse graphic highlights. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Represent ceramic, enamel, plants and machinery with simple graphic marks, not realistic material shading. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes and landings clear. No photorealism, volumetric lighting or franchise assets.

Create one wide 16:9 environment keyframe for level 7, "Please Remain Still".
Narrative purpose: A candy-colored hospital treats escape as a symptom, turning patient transport and cleaning systems into carefully coordinated hazards.
Physical setting: Cream walls curve into rounded corners. Mint door frames, peach padded beds, oversized leaf-and-droplet emblems, and friendly pictograms create the appearance of a children's science museum crossed with a hospital. Service slots reveal clinical machinery underneath. Treatment spaces are tidy rather than covered in gore.
Color and lighting: Porcelain cream #EFE7D5, mint #9ECAB6, peach #DEAA92, dusty lavender #AD9DC8, slate machinery #465D68. Warm ward lights contrast with short, explicitly warned sterilization sweeps.
Landmark: A large heart-shaped ventilation grille with a leaf emblem hangs over the central intake lift, visible from both lower and upper corridor routes.
Composition to show: Side-view hospital junction with a safe bed platform on the left, an Orderly in a clear central corridor, a Nurse behind a cover recess, and protected patient rooms softly lit in the background.
Foreground: Curtain edges and empty trolley handles stay at screen margins. Curtains never conceal incoming Orderlies or syringe telegraphs.
Playable plane: Corridor floors, bed tops, fixed landing shelves, lift cabins, and service balcony sections. Moving beds are low stable platforms with obvious wheel rails.
Background: Occupied protected wards behind glass, looping diagnostic graphics, supply robots in deep corridors, and hospital wall recesses. Survivors are not placed in the player's firing path.
Show only this level's appropriate era and threats: Resident, Sprinter, Nurse Needles, Orderly, Sanitizer; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No Returned, neural tissue inside ordinary medical robots, mandatory escort AI, new gun, or boss. Do not make hospital lights pulse so intensely that they hide attack cues.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, controlled drawn lighting and crisp cel shadows, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 7, "Please Remain Still". Keep a single 2D gameplay plane inside layered hand-drawn 2D scenery. Main route: A01 Intake lobby → A02 Vaccination corridor → A03 Patient transport lane → A04 Sterilization gallery → A05 Bed-lift junction → A06 Observation ward.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L07-A01: Intake lobby. A safe lobby provides resources for the carried weapon and a view of protected patients through glass. A slow empty bed crosses a short gap beside a fixed return walkway. Connection: Follow the archive sign into A02.
L07-A02: Vaccination corridor. One Nurse Needles stands beyond two broad cover recesses. Show the launcher wind-up and expose its reload rack clearly. Connection: A fixed side stair rises into A03.
L07-A03: Patient transport lane. One Orderly patrols a long clear hallway ending in a visible collection ramp. Fixed raised shelves provide a vault route and clear back access. Connection: Reach a supply alcove checkpoint before A04.
L07-A04: Sterilization gallery. One Sanitizer operates on a broad floor divided by two raised clean islands. A separate static nozzle demonstrates a warning stripe and safe cooling pause. Connection: A clean rear landing leads into A05.
L07-A05: Bed-lift junction. A short lift shaft connects three fixed floors. On the middle floor, a Nurse and an Orderly occupy separate visible lanes. The top floor hosts one Sanitizer alone. Connection: A final fixed balcony leads to A06.
L07-A06: Observation ward. A safe console faces survivors behind glass. The companion reads care records that count biological activity but ignore patient awareness. Connection: Exit into level 8 without moving survivors through enemy rooms.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 7, "Please Remain Still". Match these materials and colors: Porcelain cream #EFE7D5, mint #9ECAB6, peach #DEAA92, dusty lavender #AD9DC8, slate machinery #465D68. Warm ward lights contrast with short, explicitly warned sterilization sweeps.
Required asset family: Rounded corridor sections; mint doors; glass ward panels; beds and rails; lift cabin and shaft landings; cover recesses; sterilization nozzle; warning-floor strips; archive console; heart ventilation landmark.
Separation rules: Beds, rails, privacy screens, lift cabins, and nozzles are independent mechanisms. Protected patients are separate background characters with no combat hit targets in this level.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean outlines, flat colors and crisp cel shadows on warm off-white. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 7 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The first syringe-slow effect cannot force an unavoidable fall.
- Orderly's collection route and escape chance are visible.
- No obligatory enemy firing line crosses a survivor.
- The hospital leads to the archive rather than an early Returned encounter.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
