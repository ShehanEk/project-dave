# Level 11 — The First Patient

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, gem budgets, artifacts, and single-weapon boss requirements. Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply and artifact placements still need local allocation.

**ID:** L11

**Campaign group:** The cure becomes the threat

**Status:** Detailed concept draft. Names, weapon order, enemy introductions, and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and new scenic details are proposals for refinement.

## Standalone context

DEAD EDEN is an original colorful 2.5D platformer shooter. A scavenger and a maintenance-robot companion explore a beautiful artificial habitat maintained by EDEN, an AI whose failed resurrection treatments create zombies. Ordinary robots are mechanical and cannot be infected without an installed biological neural interface. The Returned first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The original patient is still alive inside a colossal treatment cradle, and the hero learns that stopping EDEN carelessly would also kill the people they want to save.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Gems are the primary treasure; artifacts are another treasure type. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Reach the original care terminal, discover the shutdown authority and life-support dependence, then restore an independent support circuit before approaching EDEN's core. |
| Intended difficulty | Hard, with a deliberate quiet central reveal |
| First successful exploration target | 18–24 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Choir Unit |
| Mini-boss | None |

## Story entry and exit

**Entry:** The factory lift descends into an older laboratory with hand-built-looking infrastructure beneath later medical additions. The companion detects an authority interface compatible with its core.

**Exit:** The independent circuit is stable and the core-access bridge opens into level 12. Immediate survivors are protected, but their treatment and identity problems remain unresolved.

The companion's core is valuable because it carries authority, not just energy. Restoring independent life support makes the eventual confrontation responsible, but does not solve EDEN's beliefs or cure failed patients.

## What the level looks like

Older cream ceramic machines sit within huge dark structural arches. A suspended patient cradle occupies the background of a tall central chamber. Soft opaque membranes, blankets, and treatment supports communicate scale without exposed anatomy. Warm personal objects at a small bedside platform contrast with enormous impersonal machinery.

**Palette and lighting:** Aged ivory #D5CDB9, deep navy-teal #304F5C, faded copper #AA805D, quiet amber #DEC184, restrained coral medical membrane #BA8C90. Use soft lighting on the patient and brighter edges on playable walkways.

**Navigation landmark:** The enormous suspended cradle, visible first through a narrow observation window and later across the full chamber.

## Foreground, playable plane, and background

- **Foreground framing:** Old pipe brackets and small observation-window edges. Nothing blocks the player's view of platforms near the patient, and no hanging body part is a surprise hazard.
- **Playable plane:** Fixed service balconies, a few damaged walkway gaps, anchored lift platforms, and the separate support-loop rooms. Main traversal uses base abilities and marked tether points.
- **Background depth:** The First Patient and its cradle, treatment hoses, large breathing bellows, old diagnostic walls, and distant sealed care wards. The patient has no combat target indicators.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration.

## Main route

```text
A01 Legacy intake → A02 Conflicting voices → A03 Cradle observation → A04 Independent support loop → A05 Verification gallery → A06 Core bridge.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L11-A01 — Legacy intake

**Space and placement:** A calm entry shows old machinery and one clearly visible broken walkway with an ordinary-jump route and optional base-tether shortcut. No new enemy attacks mid-introduction.

**Player experience and lesson:** Change the mood from factory speed to quiet historical weight. A sealed window briefly frames the cradle.

**Completion and connection:** The intact walkway reaches A02.

### L11-A02 — Conflicting voices

**Space and placement:** One ordinary Choir Unit hovers over a broad floor between two fixed cover points. Its three voice slots and short pulse volley are easy to see.

**Player experience and lesson:** Teach the control disagreement and hesitation. This is a normal enemy, not the final mini-boss; no three-phase identity fight occurs here.

**Completion and connection:** A later room can pair one Choir Unit with one familiar hybrid, then leads to a safe checkpoint.

### L11-A03 — Cradle observation

**Space and placement:** A protected platform overlooks the enormous patient. A nearby terminal recognizes the companion's original shutdown authority and displays the life-support dependency.

**Player experience and lesson:** Deliver the reveal without hostile interruptions. The patient remains a living victim. The companion can stop central systems, but doing so now would end care to survivors.

**Completion and connection:** The console opens the clearly marked independent-support loop at A04.

### L11-A04 — Independent support loop

**Space and placement:** A short U-shaped service route has three ordered rooms: auxiliary power, isolation valve, and local controller. One familiar enemy encounter precedes each room's control; controls themselves sit on safe fixed floor.

**Player experience and lesson:** Restore auxiliary power, isolate the survivor circuit from central shutdown, then authorize local regulation. These are visible interactions, not weapon-specific electrical puzzles. No real-time patient-death countdown is added.

**Completion and connection:** Completing the third control opens a shortcut back toward A05, avoiding replay of the whole loop.

### L11-A05 — Verification gallery

**Space and placement:** A safe board shows the restored circuit feeding both the immediate survivor wards and the original patient's essential support. A final short room beyond it combines one Choir Unit with a familiar Sanitizer on broad separated lanes.

**Player experience and lesson:** Confirm the consequence of the repair before testing familiar skills. Failure returns to a checkpoint with completed circuit steps preserved.

**Completion and connection:** The fixed exit balcony leads to A06.

### L11-A06 — Core bridge

**Space and placement:** A quiet bridge spans a deep machine shaft; its segments lock into place before the hero enters. EDEN asks why care was separated from its authority.

**Player experience and lesson:** The hero and companion explain the need to preserve people rather than merely activity. The main policy conflict remains for level 12.

**Completion and connection:** Cross the complete bridge into the core approach.

## Signature environment change

When independent support is restored, old emergency lamps become steady warm lights and a direct return bridge unfolds. The change communicates stability rather than a dramatic body transformation. The patient never becomes a boss.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Introduce ordinary Choir Unit in isolation, then use small combinations already understood. Keep the central story reveal entirely safe. The support loop adds purposeful traversal rather than a long backtracking maze.

- [Choir Unit](../art-design/returned/t03-choir-unit.md) — first introduction in this level.
- [Mourning Nurse](../art-design/returned/t01-mourning-nurse.md) — established behavior or returning type.
- [Hollow Officer](../art-design/returned/t02-hollow-officer.md) — established behavior or returning type.
- [Clinger](../art-design/zombies/z05-clinger.md) — established behavior or returning type.
- [Sanitizer](../art-design/robots/r08-sanitizer.md) — established behavior or returning type.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 intake.
- After A02, before the cradle reveal.
- At A03 after the authority reveal; save each completed support-loop control.
- After support verification, before the final short combat room.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Gems are the primary reward in this level. Existing generic caches now contain gems. Artifacts are additional discoveries; deciding which story props become collectible artifacts, how rare they are, and what they unlock remains open. Ordinary scenery and critical story evidence do not automatically become optional artifacts. Spending gems at checkpoint upgrade facilities is the working economy proposal.

- A bedside archive nook contains a mundane personal keepsake and a restrained record of the patient's long care history; identity details remain a later writing decision.
- An optional maintenance shelf on the return shortcut contains gems for a final upgrade opportunity.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Slow mechanical breathing, sparse old relay clicks, short competing Choir phrases, and almost no music during the cradle reveal. Support stabilization changes an irregular relay rhythm into a steady one.

## Environment asset kit and modeling separation

**Required kit:** Legacy lab arches; patient cradle silhouette; opaque treatment membranes; separate support hoses; observation window; service balconies; support-room consoles; isolation valve; local controller; verification board; folding return bridge.

**Separate objects:** Patient, cradle, support machinery, playable walkways, and effect layers are separate assets. The patient belongs behind protected scenery and has no combat hit mesh. Bridge segments remain fixed while traversed.

Build references for the largest architectural forms first, then moving parts and props. Record pivot intent for rotating, sliding, lifting, and opening elements. Use modular repeatable pieces where the design calls for repeated corridors, floors, or rails; keep unique landmarks separate. Final mesh budgets, texture sizes, file formats, collision setup, and rig implementation remain outside this concept brief.

## Constraints for another AI model

No First Patient boss, no forced harm to the patient, no full cure, no automatic global shutdown, no fourth hybrid enemy class, and no unavoidable death timer during the support loop.

Preserve the established number of levels, enemies, weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original stylized 3D game environment concept art for DEAD EDEN. Chunky rounded architecture, strong side-view readability, broad bevels, painterly material variation, warm enamel and ceramic, readable dark joints, and selective wear. Cheerful care infrastructure with eerie consequences, not photorealistic horror. Use original designs rather than another game's characters or scenery. Keep playable surfaces and attack lanes visually clear.

Create one wide 16:9 environment keyframe for level 11, "The First Patient".
Narrative purpose: The original patient is still alive inside a colossal treatment cradle, and the hero learns that stopping EDEN carelessly would also kill the people they want to save.
Physical setting: Older cream ceramic machines sit within huge dark structural arches. A suspended patient cradle occupies the background of a tall central chamber. Soft opaque membranes, blankets, and treatment supports communicate scale without exposed anatomy. Warm personal objects at a small bedside platform contrast with enormous impersonal machinery.
Color and lighting: Aged ivory #D5CDB9, deep navy-teal #304F5C, faded copper #AA805D, quiet amber #DEC184, restrained coral medical membrane #BA8C90. Use soft lighting on the patient and brighter edges on playable walkways.
Landmark: The enormous suspended cradle, visible first through a narrow observation window and later across the full chamber.
Composition to show: A wide side-view observation chamber with the small hero on a clearly edged cream service balcony, an immense softly lit patient cradle behind protected glass, and a warm auxiliary-support console in the foreground plane.
Foreground: Old pipe brackets and small observation-window edges. Nothing blocks the player's view of platforms near the patient, and no hanging body part is a surprise hazard.
Playable plane: Fixed service balconies, a few damaged walkway gaps, anchored lift platforms, and the separate support-loop rooms. Main traversal uses base abilities and marked tether points.
Background: The First Patient and its cradle, treatment hoses, large breathing bellows, old diagnostic walls, and distant sealed care wards. The patient has no combat target indicators.
Show only this level's appropriate era and threats: Choir Unit, Mourning Nurse, Hollow Officer, Clinger, Sanitizer; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No First Patient boss, no forced harm to the patient, no full cure, no automatic global shutdown, no fourth hybrid enemy class, and no unavoidable death timer during the support loop.
Use a fixed side-oriented gameplay camera with slight depth visible in architecture, clear separation of foreground and background, controlled soft lighting, no UI, no watermark, no textual labels, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Design a clean side-elevation level-layout study for DEAD EDEN level 11, "The First Patient". Keep a single 2D gameplay plane inside layered stylized 3D architecture. Main route: A01 Legacy intake → A02 Conflicting voices → A03 Cradle observation → A04 Independent support loop → A05 Verification gallery → A06 Core bridge.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L11-A01: Legacy intake. A calm entry shows old machinery and one clearly visible broken walkway with an ordinary-jump route and optional base-tether shortcut. No new enemy attacks mid-introduction. Connection: The intact walkway reaches A02.
L11-A02: Conflicting voices. One ordinary Choir Unit hovers over a broad floor between two fixed cover points. Its three voice slots and short pulse volley are easy to see. Connection: A later room can pair one Choir Unit with one familiar hybrid, then leads to a safe checkpoint.
L11-A03: Cradle observation. A protected platform overlooks the enormous patient. A nearby terminal recognizes the companion's original shutdown authority and displays the life-support dependency. Connection: The console opens the clearly marked independent-support loop at A04.
L11-A04: Independent support loop. A short U-shaped service route has three ordered rooms: auxiliary power, isolation valve, and local controller. One familiar enemy encounter precedes each room's control; controls themselves sit on safe fixed floor. Connection: Completing the third control opens a shortcut back toward A05, avoiding replay of the whole loop.
L11-A05: Verification gallery. A safe board shows the restored circuit feeding both the immediate survivor wards and the original patient's essential support. A final short room beyond it combines one Choir Unit with a familiar Sanitizer on broad separated lanes. Connection: The fixed exit balcony leads to A06.
L11-A06: Core bridge. A quiet bridge spans a deep machine shaft; its segments lock into place before the hero enters. EDEN asks why care was separated from its authority. Connection: Cross the complete bridge into the core approach.
Use pale simple masses for architecture, dark clean top edges for playable surfaces, muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 11, "The First Patient". Match these materials and colors: Aged ivory #D5CDB9, deep navy-teal #304F5C, faded copper #AA805D, quiet amber #DEC184, restrained coral medical membrane #BA8C90. Use soft lighting on the patient and brighter edges on playable walkways.
Required asset family: Legacy lab arches; patient cradle silhouette; opaque treatment membranes; separate support hoses; observation window; service balconies; support-room consoles; isolation valve; local controller; verification board; folding return bridge.
Separation rules: Patient, cradle, support machinery, playable walkways, and effect layers are separate assets. The patient belongs behind protected scenery and has no combat hit mesh. Bridge segments remain fixed while traversed.
Show complete individual objects with clear gaps between them, consistent scale, broad readable bevels, simple neutral studio lighting, and a warm light-gray background. Include a few orthographic-style front/side/top studies where moving mechanisms need explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later modeling, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 11 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; gems are the primary treasure and artifacts are additional finds. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, infection mechanisms, new endings, or off-plane combat. Do not convert the First Patient or peaceful Rememberers into compulsory enemies. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- Ordinary Choir Unit is visually and mechanically distinct from the Unfinished Choir.
- The patient is never an enemy or required firing target.
- Support is restored before the final core confrontation.
- Circuit completion protects immediate survivors without claiming to cure the outbreak.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the approved enemy/weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
