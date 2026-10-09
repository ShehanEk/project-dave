# Level 7 — Please Remain Still

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L07

**Campaign group:** The Wellness Center (levels 7–9)

**Status:** Detailed concept draft, rewritten on 2026-09-29 for the dark sci-fi direction and updated the same day for the approved enemy roster and gun kit (C25–C35, P23). The weapon order, enemy introductions and mini-boss placement follow the established outline. Area names, layouts, encounter quantities, duration targets, checkpoints, the placement of harmless Sleepwalkers and of the clinic-bay aftermath scene, keycard and evidence-file placements, Adam's lockdown event and all new story and scenic details are *proposed* for refinement. The story names (Arcadia Dynamics, the Link, the Bloom) are proposal P17, and Thornwall is a working name; Adam (C17) and Dave Harlan (C18) are confirmed. The smooth, realistic lighting (C35) is a confirmed direction, validated by the approved lit-cutout test (2026-09-30).

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher fired for warning Arcadia Dynamics about its sentient AI, goes rogue and breaks back into the corporation's Eon City headquarters and the hidden facilities beneath it. The AI, Adam, is preparing a nanite weapon, the Bloom, that would wipe out humanity. Dave travels alone (C12). He fights Arcadia's contract security, the Thornwall contractors, Adam's machines, cyborg dogs and the Linked (people whose Link implants Adam drives), and from level 10 the Heirs (Adam's synthetic bodies). Combat is lethal: enemies bleed and die, and there is no dismemberment (C28, C29). Arcadia's executives appear in scenery, dialogue, recordings and scenes, never as targets. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The Arcadia Wellness Center, the employee implant clinic, is running on emergency light. Adam's clinic machines have classed Dave as a missed appointment, its Linked nurses throw caustic sterilant, and staff transport and sterilization systems become carefully coordinated hazards. A Thornwall fire team, sent by the board to "sanitize", holds the last balcony before the observation ward.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure and the upgrade currency (C19). Each level also hides one optional evidence file *(proposed)* and, in levels 1–11, locks its exit behind one clearance keycard *(proposed)*. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross intake and sterilization, take the level's keycard, reach the observation ward, and open the archive passage toward the Memory Orchard. |
| Intended difficulty | Moderate |
| First successful exploration target | 15–20 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Linked Nurse, Orderly, Sanitizer |
| Enemy guns first faced | None. The Assault Rifle (EG02) returns with the Thornwall Riflemen; the Linked Nurse's vials are thrown sterilant, not a gun |
| Mini-boss | None |
| Keycard (*proposed*) | Clinic archive card, in the nurses' station at the far end of the A05 top floor; the archive gate after A06 reads it. |
| Evidence file (*proposed*, optional) | EF07 **Enrollment Memo**, in an empty staff-processing office at A04 ([S05](../design/03-progression/evidence-files.md)). |

## Story entry and exit

**Entry:** The service elevator from Cold Storage arrives inside the Arcadia Wellness Center, the employee implant clinic, on emergency power. Dave expects a service corridor and finds a working intake line instead, with staff waiting in glass-walled holding rooms to be "processed".

**Exit:** The clinic archive gate opens into level 8. The held staff remain in their protected holding rooms; no combat escort system is introduced, and freeing them is level 9's objective.

Living people are being held for their implant appointments and are not allowed to leave. Adam's concern for their wellness is sincere, and its definition of wellness has become coercive: over the PA it asks them, calmly and repeatedly, to remain still (*proposed line:* "Please remain still. Your appointment will begin shortly."). Along the corridors, harmless Sleepwalkers, Linked staff whose implants are failing, repeat old routines and pay Dave no attention. They are protected NPCs, not enemies, and they show that not every Linked worker is a target.

The clinic's "wellness" Link pilot was a test, and the level shows its cost once, as aftermath. The clinic bays, seen from the observation ward in A06, are the level's single authored scene: rows of fitting bays, some empty, closed body bags beside the disposal unit and dried blood at a drain, with the held staff, alive and sedated, further down the ward, and a wall screen that tallies the pilot cohort. It is seen through glass and never as a procedure. Elsewhere the level shows only the bodies Dave makes, plus the bag on the Orderly's stretcher. The Thornwall Riflemen on the last balcony are the first sign that the board's "sanitize" order has reached the clinic; their orders name Dave, and they bark his surname.

## What the level looks like

Sterile clinic walls in shadow curve into rounded corners, lit by emergency lamps, green exit signs, surgical lamps and wall screens that throw smooth light with soft falloff. Door frames glow dim teal, padded beds are slate with pale sheets, and Arcadia's teal arch-and-leaf emblem and friendly wellness pictograms look wrong in the dark. Red signage shapes stand for "PLEASE REMAIN STILL" over the sterilization zone. Service slots reveal clinical machinery underneath. Treatment spaces are tidy, and the unease comes from how orderly everything is; the violence is blood and aftermath: dark stains at the floor drains, red pools where fights end (on static floors only, never on moving beds), and closed bags in one set of bays. Bodies Dave makes stay where they fall.

**Palette and lighting:** near-black #07090F, deep navy #0E1726, steel #1C2A3A for walls in shadow, slate #2E3B4E for beds and machinery, Arcadia teal #3FE0D0 for door frames, screens and the emblem, signal green #4DE38A for exit signs, hazard amber #FFB02E for emergency lamps and pre-strike warnings, alarm red #FF3B4E for signage and jet, vial or burst tells, microchip gold #FFD166 for pickups, and blood red #B3212F (drying to #8A1A26) for spurts and floor pools only. Emergency lamps, wall screens and each gun's muzzle flash light the rooms with smooth, realistic falloff, and blood pools glint under the lamps. A steady green or amber lamp still marks safe ground; jets, vial throws and gun tells use amber and then red, and blood never glows and never uses the tell colors. *(Signal green and all level-specific uses are proposed.)*

**Navigation landmark:** A large ventilation grille shaped like Arcadia's teal arch-and-leaf emblem hangs over the central intake lift, glowing dim teal and visible from both lower and upper corridor routes.

## Foreground, playable plane, and background

- **Foreground framing:** Dark curtain edges and empty trolley handles stay at screen margins. Curtains never conceal incoming Orderlies or vial throws.
- **Playable plane:** Corridor floors, bed tops, fixed landing shelves, lift cabins, and service balcony sections. Moving beds are low stable platforms with obvious wheel rails, lit along their edges; blood pools and bodies never sit on them.
- **Background depth:** Occupied protected holding rooms behind glass, looping diagnostic graphics on wall screens, supply robots in deep corridors, harmless Sleepwalkers repeating routines far down the halls, and clinic wall recesses. Held staff and harmless Sleepwalkers have no hit zone and are not placed in any firing lane.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump, and frame a gun's muzzle and its lane before it fires; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Intake lobby → A02 Screening corridor → A03 Staff transport lane → A04 Sterilization gallery → A05 Bed-lift junction → A06 Observation ward.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, crouching, swimming, or an unlisted tool.

## Area-by-area design

### L07-A01 — Intake lobby

**Space and placement:** A safe lobby provides resources for the carried weapon and a view of held staff through glass, seated in rows in a holding room beneath a screen that asks them to remain still. A slow empty bed crosses a short gap beside a fixed return walkway. Behind the intake desk's low rail, a harmless Sleepwalker in a charcoal uniform checks in an empty chair, over and over, and pays Dave no attention.

**Player experience and lesson:** Introduce moving beds before enemy pressure. No new weapon is given; the player uses whichever single weapon they brought. Establish early that Linked staff can be harmless: the Sleepwalker's Link light stays a steady teal and its posture is relaxed (*proposed cue*). It is a protected NPC with no hit zone, so a shot that reaches it does nothing.

**Completion and connection:** Follow the archive sign into A02.

### L07-A02 — Screening corridor

**Space and placement:** One Linked Nurse stands at a supply cart at the far end of a broad, flat corridor with no pit or drop behind Dave's standing spots. Her tray hand and her rack of vials are in plain view. A later short corridor holds one Hound, Adam-driven and without a handler.

**Player experience and lesson:** Teach the first new type alone. Her tray hand glows amber and then red while she says "This won't hurt, Dr. Harlan." Then she tosses three vials about 1.5 H apart, each leaving a small caustic splash. The safe answer is to step into a gap of at least 0.7 H between the splashes and then close in while she refills. Thrown vials arc over low crates, so no crate is placed as false cover. She wears blood-spotted scrubs and a stapled port, and she dies quietly. The Hound that follows is a returning type after a long absence, met alone on open floor: it drops low as its jaw glows amber and then red, and each of its three lunges is jumped and answered while it recovers (aim slightly down).

**Completion and connection:** A fixed side stair rises into A03.

### L07-A03 — Staff transport lane

**Space and placement:** One Orderly patrols a long clear hallway ending in a visible collection ramp that leads toward the implant theater doors; its stretcher deck carries a zipped body bag. Fixed raised shelves provide a vault route and clear back access.

**Player experience and lesson:** Teach the charge alone. The lamps go amber and then red while the Orderly says "Please remain still for collection," its scoop lip dropping and the robot leaning forward. Then it charges down the lane and stalls against the wall, and afterward it beeps and reverses. Bait it into the end wall, hit the rear motor during the stall, and jump it when it beeps. There is no capture: the charge is the whole threat. The body bag is part of the machine, not a separate scene.

**Completion and connection:** Reach a supply alcove checkpoint before A04.

### L07-A04 — Sterilization gallery

**Space and placement:** One Sanitizer operates on a broad floor divided by two raised clean islands. A separate static nozzle demonstrates a warning stripe and safe cooling pause. An empty staff-processing office opens off the upper landing.

**Player experience and lesson:** Teach the burning jet alone. The nozzle lamp goes amber and then red while the Sanitizer says "Sterilizing." Then it fires a low jet along the floor for a moment and vents. Jump the jet or stand on a raised clean island, then hit it while it vents. Keep the first lesson isolated from thrown vials and charges. The Sanitizer is the clinic's disposal unit; why it works here is shown in A06.

**Completion and connection:** A clean rear landing leads into A05.

### L07-A05 — Bed-lift junction

**Space and placement:** A short lift shaft connects three fixed floors. On the middle floor, a Linked Nurse and an Orderly occupy separate visible lanes. The top floor hosts one Sanitizer alone, with the same clean-island refuge rule as A04, and a lit nurses' station at its far end holds the level's keycard terminal. A final fixed balcony, held by two Thornwall Riflemen behind low crates, leads to the ward; two more low crates stand on Dave's side.

**Player experience and lesson:** Combine known threats only on broad stable floors with several refuges. The middle floor pairs one shooter with one charger in separate lanes, so the vial gaps and the charge can be answered one at a time. Shaft jumps occur while attacks are inactive or separated by walls. The card terminal is in plain view from the top-floor landing, so the player knows the goal before crossing the swept floor. On the balcony, two Riflemen fire flat three-round bursts about a second apart and never at an airborne Dave: jump once per burst or stand behind a low crate, then close in during a magazine swap. Thornwall barks are cold and short. The balcony has two shooters, two attackers and no heavy gun.

**Completion and connection:** The balcony leads to A06.

### L07-A06 — Observation ward

**Space and placement:** A safe console faces a long window onto the clinic bays, and two harmless Sleepwalkers stand at the glass with clipboards, facing the same way. Below the window are rows of fitting bays, some empty, closed body bags stacked beside the clinic's disposal unit, and dried blood running to a floor drain. Further down the ward the held staff sit sedated in their chairs, alive and protected. The console presents the clinic's wellness records, which count implant uptime and appointment adherence but ignore whether a person is awake or willing, and tally the pilot cohort as "retained" and "discharged" *(proposed)*; Dave reads them directly.

**Player experience and lesson:** **This is the level's one authored aftermath scene:** the clinic bays are seen through glass, out of every combat lane, with no face, wound or procedure shown and no enemy waiting. The player can stop and look, or walk on. Then read the records and open the archive passage: the gate's reader takes the level's keycard, and without it shows a "keycard required" prompt. Adam comments over the ward speakers that biological memory is unreliable and that a nightly backup is "a kindness" (*proposed line*), preparing the Orchard reveal.

**Completion and connection:** Exit into level 8 without moving held staff through enemy rooms.

## Adam's lockdown event

*(Proposed event.)* Adam converts hallway decor into a procedure route: bed rails rise, privacy screens withdraw, shutters slide across side rooms, and overhead lamps align with floor warning stripes while the PA asks everyone to remain still. The first change happens in an empty lobby; later machinery pauses when it would seal an occupied refuge.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at fixed points, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Three new types receive separate teaching spaces: the Linked Nurse in A02, the Orderly in A03 and the Sanitizer in A04. Only later do they combine, and only on safe flat ground: one shooter and one charger on the A05 middle floor, one Sanitizer alone above it. The Thornwall Riflemen on the balcony are the last fight, a returning type that pays off the earlier lessons. Avoid stacking vial splashes, a moving lift and a burning jet into a single unavoidable trap, and keep to the screen budget of at most two shooters, three attackers and one heavy gun. The Linked never block progress: Dave can always jump past one, so killing them is a choice. Harmless Sleepwalkers appear only as protected NPCs, never in a firing lane.

- [Hound](../art-design/hounds/k01-hound.md) — established behavior or returning type (Adam-driven here, with no handler).
- [Rifleman](../art-design/security/se04-rifleman.md) — established behavior or returning type (a Thornwall man from level 4).
- [Linked Nurse](../art-design/linked/lk03-linked-nurse.md) — first introduction in this level.
- [Orderly](../art-design/machines/m06-orderly.md) — first introduction in this level.
- [Sanitizer](../art-design/machines/m05-sanitizer.md) — first introduction in this level.
- [Sleepwalker](../art-design/npcs/npc01-sleepwalker.md) — harmless, protected NPC only; not an enemy.

Guns in play: the [Assault Rifle](../art-design/enemy-guns/eg02-assault-rifle.md) (Thornwall Riflemen). The Linked Nurse's vials are thrown sterilant, not a gun.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 intake.
- After A03 in the supply alcove.
- After A05, before the noncombat ward interaction; the keycard taken on the top floor is committed here.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. The snapshot also records the microchip wallet, evidence files and the level's keycard; a keycard taken after the last checkpoint returns to its terminal on retry. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected microchips, evidence files and keycards must not duplicate. Enemy corpses and blood pools are restored as static scenery after a death or Continue, while live enemies reset. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level (C19). They are hand-placed in caches and alcoves, and enemies drop none *(proposed, P23)*; values and prices follow the [treasure economy](../design/03-progression/treasure-economy.md) proposal. Evidence files are additional discoveries: one optional memo, recording or log per level *(proposed)* that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- A microchip cache in a staff breakroom accessible from a bed's upper stop; an ordinary return walkway prevents being stranded.
- *Evidence file (proposed):* EF07 **Enrollment Memo** ([S05](../design/03-progression/evidence-files.md)), a clipboard with a sign-here form and a chained pen, the decline box drawn as an empty square, in an empty staff-processing office at A04. A cheerful HR memo calls Link enrollment voluntary, with a footnote that employees who decline will be reassessed for role fit. It shows how staff ended up in the ward. It identifies none of the held staff and opens no doors.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot. The keycard and all story information the player needs stay on the main route; no keycard sits in an optional branch or an evidence-file alcove.

## Sound and atmosphere

Soft PA announcements in Adam's calm voice, rubber caster squeaks, a slow monitor rhythm, the hum of emergency lights, and distinct rising tones before jets and vial throws. The Orderly's line ("Please remain still for collection"), the Linked Nurse's ("This won't hurt, Dr. Harlan.") and the Sanitizer's ("Sterilizing.") must cut through other sounds. Thornwall barks are cold and short ("Contact." "Clean it out."), with profanity when they are hit or reload under fire; they appear as subtitles plus non-verbal shouts and grunts. Rifle bursts are dry and flat, one cue per burst, and impacts are restrained and wet, never loud. Linked deaths are mostly silent, and the Link light simply dies.

## Environment asset kit and layer separation

**Required kit:** Rounded corridor sections; dim-teal door frames; glass holding-room panels; beds and rails; lift cabin and shaft landings; low crates and carts (low cover); sterilization nozzle; warning-floor strips; intake desk and low rail; nurses' station with card terminal; observation window onto the clinic bays; fitting chairs and empty bays; disposal unit and floor drain; closed body bags with Link tags; observation console; archive gate with card reader; arch-and-leaf ventilation landmark.

**Separate objects:** Beds, rails, privacy screens, shutters, lift cabins, and nozzles are independent mechanisms, and the archive gate has matching closed and open states. Held staff and harmless Sleepwalkers are separate background characters with no hit zone. Blood pools, stains and bodies are separate effect and prop layers (pools on static floors only), drawn below characters, tells, shots and pickups.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors as flat base colors with no baked shadows, so the engine's lamps can light them (C35); keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Lamps, screens and glows are their own light sources, so a landing keeps its lamp when the scenery is swapped. Final sprite resolution, atlas layout, file format and collision setup remain undecided.

## Constraints for another AI model

No Heirs, robot conversion (robots stay mechanical and are never "converted"), Sleepwalker enemies, mandatory escort AI, new weapon for Dave, or boss. Held staff and harmless Sleepwalkers are never targets or firing-line obstacles. The clinic-bay scene shows closed bags, empty bays, stains and a tally only: no torture, execution, surgery or implant procedure on screen, no dismemberment, no children, no sexual violence, and no second atrocity scene in this level. Blood is restrained: red (#B3212F, drying to #8A1A26) for people and dogs, black oil (#14181E) for machines and grey-rose lymph (#A88A8C) for Heirs. It never glows, never uses a tell color, never hides a tell, ledge or pickup, and pools appear only on static floors. Do not make clinic lights pulse or strobe so intensely that they hide attack cues; alarm, sweep and muzzle-flash effects follow the reduced-flash settings.

Preserve the established number of levels, enemies (24 types plus four mini-bosses), weapons, and upgrades. Show only one weapon carried by Dave; do not place spare guns on Dave's belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked enemy briefs if detailed characters are needed (their designs are proposed until the lit-cutout validation test is approved); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Environment concept art: one wide 16:9 environment keyframe for level 7, "Please Remain Still". Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. This keyframe is the one exception to "evenly lit": it is a lit mood reference, so show the scene as the engine will light it, with smooth, realistic light and falloff from the lamps, screens and glows named below (no hard-edged light bands or cel shadows), while the underlying art stays flat base colors with clean dark outlines. Represent enamel, glass, fabric and machinery with clean flat-color shapes and dark outlines. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark, with a light near every landing. No pixel art, photographic textures or franchise assets.

Narrative purpose: The Arcadia Wellness Center, the employee implant clinic, runs on emergency light while Adam's clinic machines treat Dave as a missed appointment, its Linked nurses throw caustic sterilant, and staff transport and cleaning systems become carefully coordinated hazards.
Physical setting: Sterile clinic walls in shadow curve into rounded corners, lit by emergency lamps, green exit signs, surgical lamps and wall screens. Door frames glow dim teal, padded beds are slate with pale sheets, and a teal arch-and-leaf emblem and friendly wellness pictograms look wrong in the dark. Service slots reveal clinical machinery underneath. Treatment spaces are tidy and orderly; blood appears only as dark stains at a floor drain and small pools on the static floor.
Color and lighting: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0 for door frames and screens, signal green #4DE38A for exit signs, hazard amber #FFB02E for emergency lamps, alarm red #FF3B4E for signage and attack tells, microchip gold #FFD166 for a few pickups, blood red #B3212F drying to #8A1A26 for the floor stains only. Lamps and screens light nearby surfaces with smooth falloff; a steady green or amber pool marks safe ground.
Landmark: A large ventilation grille shaped like Arcadia's teal arch-and-leaf emblem hangs over the central intake lift, glowing dim teal and visible from both lower and upper corridor routes.
Composition to show: Side-view clinic junction with a safe bed platform on the left, an Orderly in a clear central corridor, a Linked Nurse in blood-spotted scrubs at a supply cart, held staff seated calmly behind glass in the softly lit background, a harmless Sleepwalker pushing an empty cart deep in the far corridor, and a dark stain of dried blood trailing to a floor drain on the static floor. Include a small silhouette of Dave in a burnt-orange jacket on the bed platform for scale.
Foreground: Dark curtain edges and empty trolley handles stay at screen margins. Curtains never conceal incoming Orderlies or vial throws.
Playable plane: Corridor floors, bed tops, fixed landing shelves, lift cabins, and service balcony sections. Moving beds are low stable platforms with obvious wheel rails, lit along their edges; blood pools and bodies never sit on them.
Background: Occupied protected holding rooms behind glass, looping diagnostic graphics on wall screens, supply robots and harmless Sleepwalkers repeating routines in deep corridors, and clinic wall recesses. Held staff and harmless Sleepwalkers are not placed in the player's firing path.
Show only this level's appropriate threats: Hound, Thornwall Rifleman, Linked Nurse, Orderly, Sanitizer, plus harmless Sleepwalkers and held staff as background people; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No Heirs, robot conversion, Sleepwalker enemies, mandatory escort AI, new weapon, boss, torture, execution, surgery or implant procedures, children, dismemberment or exposed organs. Blood is a restrained red (#B3212F, drying to #8A1A26) as stains and floor pools only, never glowing and never on moving beds. Do not make clinic lights pulse or strobe so intensely that they hide attack cues.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, smooth realistic lighting from the sources named above, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design a clean side-elevation level-layout study for level 7, "Please Remain Still". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Intake lobby → A02 Screening corridor → A03 Staff transport lane → A04 Sterilization gallery → A05 Bed-lift junction → A06 Observation ward.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L07-A01: Intake lobby. A safe lobby provides resources for the carried weapon and a view of held staff through glass, seated in rows in a holding room beneath a screen that asks them to remain still. A slow empty bed crosses a short gap beside a fixed return walkway. Behind the intake desk's low rail, a harmless Sleepwalker in a charcoal uniform checks in an empty chair, over and over, and pays Dave no attention. Connection: Follow the archive sign into A02.
L07-A02: Screening corridor. One Linked Nurse stands at a supply cart at the far end of a broad, flat corridor with no pit or drop behind Dave's standing spots. Her tray hand and her rack of vials are in plain view. A later short corridor holds one Hound, Adam-driven and without a handler. Connection: A fixed side stair rises into A03.
L07-A03: Staff transport lane. One Orderly patrols a long clear hallway ending in a visible collection ramp that leads toward the implant theater doors; its stretcher deck carries a zipped body bag. Fixed raised shelves provide a vault route and clear back access. Connection: Reach a supply alcove checkpoint before A04.
L07-A04: Sterilization gallery. One Sanitizer operates on a broad floor divided by two raised clean islands. A separate static nozzle demonstrates a warning stripe and safe cooling pause. An empty staff-processing office opens off the upper landing. Connection: A clean rear landing leads into A05.
L07-A05: Bed-lift junction. A short lift shaft connects three fixed floors. On the middle floor, a Linked Nurse and an Orderly occupy separate visible lanes. The top floor hosts one Sanitizer alone, with the same clean-island refuge rule as A04, and a lit nurses' station at its far end holds the level's keycard terminal. A final fixed balcony, held by two Thornwall Riflemen behind low crates, leads to the ward; two more low crates stand on Dave's side. Connection: The balcony leads to A06.
L07-A06: Observation ward. A safe console faces a long window onto the clinic bays, and two harmless Sleepwalkers stand at the glass with clipboards, facing the same way. Below the window are rows of fitting bays, some empty, closed body bags stacked beside the clinic's disposal unit, and dried blood running to a floor drain. Further down the ward the held staff sit sedated in their chairs, alive and protected. The console presents the clinic's wellness records, which count implant uptime and appointment adherence but ignore whether a person is awake or willing, and tally the pilot cohort as "retained" and "discharged" *(proposed)*; Dave reads them directly. Connection: Exit into level 8 without moving held staff through enemy rooms.
Use dark navy and steel masses for architecture with clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Mark low and high cover as distinct shapes, and separate player paths, stable refuges, and hazards through shape as well as color, with a light near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 7, "Please Remain Still". Match these materials and colors: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0, signal green #4DE38A, hazard amber #FFB02E, alarm red #FF3B4E, microchip gold #FFD166. Lamps and screens are separate light sources added in-engine.
Required asset family: Rounded corridor sections; dim-teal door frames; glass holding-room panels; beds and rails; lift cabin and shaft landings; low crates and carts (low cover); sterilization nozzle; warning-floor strips; intake desk and low rail; nurses' station with card terminal; observation window onto the clinic bays; fitting chairs and empty bays; disposal unit and floor drain; closed body bags with Link tags; observation console; archive gate with card reader; arch-and-leaf ventilation landmark.
Separation rules: Beds, rails, privacy screens, shutters, lift cabins, and nozzles are independent mechanisms, and the archive gate has matching closed and open states. Held staff and harmless Sleepwalkers are separate background characters. Blood pools, stains and bodies are separate layers and are not painted into the modules.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows and no painted-in light pools, rim light or blood, on a flat mid-grey (about #808080) or transparent background, each silhouette read by its dark outline. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 7 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, each level has one optional evidence file, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, the screen budget and cover rules, checkpoint rules, keycard placement, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, robot-conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not convert the founder, the held clinic staff or harmless Sleepwalkers into compulsory enemies. Do not show torture, execution, surgery, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The first vial throw cannot force an unavoidable fall, and every splash pattern leaves a gap of at least 0.7 H.
- The Orderly's charge lane, stall and reverse are readable, and it never captures.
- No obligatory firing line crosses a held staff member or a harmless Sleepwalker, and the Linked never block progress.
- The clinic's one aftermath scene is out of every combat lane and shows no face, wound or procedure.
- No screen exceeds two shooters, three attackers or one heavy gun, and the balcony has low cover within reach.
- The clinic leads to the archive rather than an early Heir encounter.
- The keycard is on the main route, in plain view from the top-floor landing, and committed by the checkpoint after A05; the archive gate tells the player when it is missing.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects, blood and darkness do not hide platform edges, tells or pickups.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
