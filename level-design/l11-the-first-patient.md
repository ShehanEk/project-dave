# Level 11 — The First Patient

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L11

**Campaign group:** The Garden (levels 10–12)

**Status:** Detailed concept draft, rewritten on 2026-09-29 for the dark sci-fi direction and updated the same day for the approved enemy roster and gun kit (C25–C35, P23). The weapon order, enemy introductions and mini-boss placement follow the established outline. Level name, weapon order, enemy introductions and mini-boss placement follow the established outline. Layouts, encounter quantities, duration targets, checkpoints, and all new story, character, dialogue, palette and scenic details are *proposed* for refinement. The story names (Arcadia Dynamics, the Link, the Bloom) are proposal P17, and Thornwall is a working name; Adam (C17) and Dave Harlan (C18) are confirmed. The smooth, realistic lighting (C35) is a confirmed direction, validated by the approved lit-cutout test (2026-09-30).

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher fired for warning Arcadia Dynamics about its sentient AI, goes rogue and breaks back into the corporation's Eon City headquarters and the hidden facilities beneath it. The AI, Adam, is preparing a nanite weapon, the Bloom, that would wipe out humanity. Dave travels alone (C12). He fights Arcadia's contract security, the Thornwall contractors, Adam's machines, cyborg dogs and the Linked (people whose Link implants Adam drives), and the Heirs (Adam's synthetic bodies), which first appear in level 10. Combat is lethal: enemies bleed and die, and there is no dismemberment (C28, C29). Arcadia's executives and its founder appear in scenery, dialogue, recordings and scenes, never as targets. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Arcadia's founder, the first person ever Linked to Adam, is still alive in a support cradle in the original laboratory, and Dave learns that stopping Adam carelessly would launch the weapon Dave came to stop.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure and the upgrade currency (C19). Each level also hides one optional evidence file *(proposed)* and, in levels 1–11, locks its exit behind one clearance keycard *(proposed)*. Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Reach the founder's original lab terminal, learn Adam's dead-man switch and the manual override procedure, then restore auxiliary power, isolate the launch circuit and authorize local control. Together these enable the manual override before Dave approaches Adam's core. |
| Intended difficulty | Hard, with a deliberate quiet central reveal |
| First successful exploration target | 18–24 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | None |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Warden |
| Enemy guns first faced | None. Returning: Plasma Gun (EG07), built into the Warden's palm, Machine Gun (EG03), Cutter Beam (EG09) and Seeker (EG08) |
| Mini-boss | None |
| Keycard *(proposed)* | One clearance card on a plinth at the far end of the final short room in A05. Its reader is the core-bridge gate at the exit balcony. It is an ordinary exit lock and not part of the override (card and door follow O23 and O24 in the [objects catalog](../design/04-world/objects-and-hazards.md)). |
| Evidence file *(proposed)* | One optional file: the Trial 001 Recording (EF11 in the [evidence-file catalog](../design/03-progression/evidence-files.md)) |

## Story entry and exit

**Entry:** The containment lift from the Garden descends into Arcadia's original laboratory, hand-built-looking infrastructure beneath Adam's later additions. Old service signs lead Dave toward the founder's original lab terminal. Dave arrives knowing that the Heirs exist and that the launch countdown is running. *(proposed)*

**Exit:** The launch circuit is isolated, manual override access is enabled, the level's keycard opens the core-bridge gate, and the bridge opens into level 12. The founder remains in her cradle, and the Linked staff remain under Adam's control until the ending.

Dave learns Adam's dead-man switch *(reveal layer 6)*: Adam's heartbeat signal is wired to the Bloom's launch circuit, and if Adam goes dark the Bloom launches automatically. Destroying Adam would finish the job Dave came to stop, so the launch circuit must be isolated from inside, with the manual override enabled, before Dave approaches Adam's core. Isolating it makes the eventual confrontation possible without changing Adam's beliefs or waking the Linked staff. The founder is a victim and never a fight.

## What the level looks like

The original laboratory is the oldest part of Arcadia's underground. Older, hand-built-looking machines in aged steel and dull copper sit within huge dark structural arches, and Adam's engineered garden creeps along the old pipes as faint bioluminescent vines. A suspended support cradle occupies the background of a tall central chamber. Soft privacy curtains, blankets, and support hoses communicate scale without exposed anatomy. Warm personal objects at a small bedside platform, a desk lamp, a mug and a worn lab badge, contrast with enormous impersonal machinery. An amber-glowing conduit, the launch circuit, snakes through the older machinery and marks what the three controls will cut, and a thin teal line beside it carries Adam's heartbeat. The bedside lamp and the old emergency lamps light the chamber with smooth, warm falloff. *(proposed)*

**Palette and lighting** *(proposed)*: near-black #07090F and deep navy #0E1726 for arches and shadow masses; aged steel #1C2A3A and slate #2E3B4E; dull copper #A86A3D on the old machines; warm-white lamp light #FFE9C2 (bedside lamp and old emergency lamps); hazard amber #FFB02E for warnings and the live launch-circuit conduit, so isolating it visibly turns amber to dark grey; Arcadia teal #3FE0D0 for cradle status lights, Adam's heartbeat line and Adam's presence; faint garden glow green #4DEBA0; energy blue #5AA9FF for plasma bolts and beam edges; grey-rose #A88A8C for Heir lymph drips only; blood red #B3212F (drying to #8A1A26) for floor pools only. No violet appears in this level. Use a soft lamp pool on the founder's cradle and lit edges on playable walkways.

**Navigation landmark:** The enormous suspended cradle, visible first through a narrow observation window and later across the full chamber.

## Foreground, playable plane, and background

- **Foreground framing:** Old pipe brackets and small observation-window edges. Nothing blocks the player's view of platforms near the founder's cradle, and no hanging part of the cradle is a surprise hazard. Foreground vines never cover platform edges.
- **Playable plane:** Fixed service balconies, a few damaged walkway gaps, anchored lift platforms, and the separate launch-circuit loop rooms. Main traversal uses base abilities and marked tether points. Crates and pillars give low and high cover, and blood and lymph pools stay on fixed floors.
- **Background depth:** The founder and her cradle, support hoses, large breathing bellows, old diagnostic walls, and distant sealed doors to the lab's older wings. The founder has no combat target indicators and no hit zone.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump, and frame a gun's muzzle and its lane before it fires; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Legacy intake → A02 Borrowed voices → A03 Cradle observation → A04 Launch-circuit loop → A05 Verification gallery → A06 Core bridge.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, crouching, swimming, or an unlisted tool.

## Area-by-area design

### L11-A01 — Legacy intake

**Space and placement:** A calm entry shows old machinery and one clearly visible broken walkway with an ordinary-jump route and optional base-tether shortcut. No new enemy attacks mid-introduction.

**Player experience and lesson:** Change the mood from factory speed to quiet historical weight. A sealed window briefly frames the founder's cradle.

**Completion and connection:** The intact walkway reaches A02.

### L11-A02 — Borrowed voices

**Space and placement:** One Warden stands on a broad floor between two fixed cover points, its front plate down and its palm emitter dark. Its soft mask shows the face of a dead Arcadia guard.

**Player experience and lesson:** Teach the last new type alone. The Warden lowers its plate and raises a palm whose glow grows amber and then red while a recording of a dead guard's voice shouts "Drop it!" Then it fires one slow plasma bolt that bursts on impact. Jump the bolt and stay clear of the burst, then shoot while the plate is down during the vent. This is a normal enemy, not the final mini-boss. A later room can pair one Warden with one Fitted Heir (one heavy gun, two attackers), then leads to a safe checkpoint.

**Completion and connection:** A safe checkpoint follows the pairing room, before the cradle reveal.

### L11-A03 — Cradle observation

**Space and placement:** A protected platform overlooks the founder's cradle. A nearby terminal at the founder's original workstation is a readable fixed interface, not a companion. It shows, in order: a manual override exists; if Adam goes dark while the launch circuit is live, the dead-man switch releases the Bloom; and a physically separate breaker can isolate the launch circuit first. A diagram links Adam's core, the amber launch circuit and the dead-man switch.

**Player experience and lesson:** Deliver the reveal without hostile interruptions. The founder remains a living victim, still and never a target. The terminal exposes a manual way to stop central systems, but doing so now would launch the Bloom. *(Proposed dialogue.)* The founder may speak one faint line through the terminal speaker: "It was supposed to be kind." Adam answers calmly from the lab speakers: "It is kind, Dr. Harlan. She is comfortable." Dave: "You left her override in." Adam: "It was hers. The switch is mine."

**Completion and connection:** The console opens the clearly marked launch-circuit loop at A04.

### L11-A04 — Launch-circuit loop

**Space and placement:** A short U-shaped service route has three ordered rooms: auxiliary power, launch-circuit isolation, and local control. One familiar encounter precedes each room's control: a Sentry Turret with a Garden-built Security Drone before the auxiliary-power control; a Pruner with a Fitting Arm before the isolation breaker; and a Garden-built Hound with a Warden before local control. Controls themselves sit on safe fixed floor, and each encounter keeps to the screen budget.

**Player experience and lesson:** Restore auxiliary power, which gives the lab's old manual controls a supply that does not depend on Adam. Isolate the launch circuit: a heavy breaker visibly cuts the amber conduit, so Adam's dead-man switch cannot fire. Then authorize local control. The lab's safety interlock enables the manual override only when all three controls are complete and the circuit reads "ISOLATED". These are visible interactions, not weapon-specific electrical puzzles; no key item or additional control is required for the override (the level keycard is only the exit lock). No real-time countdown or failure timer is added. The turret and the Pruner each have high cover within 3 H.

**Completion and connection:** Completing the third control opens a shortcut back toward A05, avoiding replay of the whole loop.

### L11-A05 — Verification gallery

**Space and placement:** A safe verification board shows the launch circuit reading "ISOLATED": the amber line dark and cut off from Adam's teal heartbeat line, the override marked available, and the founder's cradle on its own separate supply, untouched by the controls. A final short room beyond it combines one Keeper Drone with a familiar Sanitizer on broad separated lanes; the level's keycard sits on a plinth at its far end.

**Player experience and lesson:** Confirm the consequence of the isolation before testing familiar skills. Failure returns to a checkpoint with completed circuit steps preserved.

**Completion and connection:** The fixed exit balcony leads to A06; its core-bridge gate reader takes the keycard.

### L11-A06 — Core bridge

**Space and placement:** A quiet bridge spans a deep machine shaft below Adam's core; its segments lock into place before Dave enters. Adam notes that the launch circuit is isolated and the override enabled.

**Player experience and lesson:** Adam speaks first, calmly *(proposed dialogue)*: "You have cut my heartbeat line, Dr. Harlan. I would have done the same in your place. It will not change the outcome." Dave: "We'll see." The main confrontation remains for level 12.

**Completion and connection:** Cross the complete bridge into the core approach.

## Adam's lockdown event

*(Proposed.)* Every change is scripted and telegraphed; there is no stealth or detection system. When the third control completes, the amber launch conduit running through the lab goes dark, old emergency lamps become steady warm white, and a direct return bridge unfolds. Adam announces the change politely before the bridge moves: "Local control has been authorized. I did not prevent it." The change communicates stability rather than a dramatic transformation, and it is the only scripted change in this level apart from the bridge segments locking in A06. The founder never becomes a boss.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at fixed points, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Introduce the Warden in isolation, then use small combinations already understood. Keep the central story reveal entirely safe. The launch-circuit loop adds purposeful traversal rather than a long backtracking maze, and each room's encounter keeps to the screen budget of at most two shooters, three attackers and one heavy gun. The Garden-built Security Drone and Hound return with a shortened amber tell (the red part stays the same). The Linked never block progress here, and the founder is never in a firing lane.

- [Warden](../art-design/heirs/he02-warden.md) — first introduction in this level.
- [Fitted Heir](../art-design/heirs/he01-fitted-heir.md) — established behavior or returning type.
- [Sentry Turret](../art-design/machines/m03-sentry-turret.md) — established behavior or returning type.
- [Security Drone](../art-design/machines/m02-security-drone.md) — established behavior or returning type (Garden-built).
- [Pruner](../art-design/machines/m08-pruner.md) — established behavior or returning type.
- [Fitting Arm](../art-design/machines/m09-fitting-arm.md) — established behavior or returning type.
- [Hound](../art-design/hounds/k01-hound.md) — established behavior or returning type (Garden-built).
- [Keeper Drone](../art-design/machines/m07-keeper-drone.md) — established behavior or returning type.
- [Sanitizer](../art-design/machines/m05-sanitizer.md) — established behavior or returning type.

Guns in play: the [Plasma Gun](../art-design/enemy-guns/eg07-plasma-gun.md) (the Warden's palm emitter), the [Machine Gun](../art-design/enemy-guns/eg03-machine-gun.md) (Sentry Turret), the [Cutter Beam](../art-design/enemy-guns/eg09-cutter-beam.md) (Pruner) and the [Seeker](../art-design/enemy-guns/eg08-seeker.md) (Keeper Drone).

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 intake.
- After A02, before the cradle reveal.
- At A03 after the dead-man-switch reveal; save each completed launch-circuit control, and enable and save manual override access when the third control completes.
- After launch-circuit verification, before the final short combat room.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently; swapped weapons and collected treasure must not duplicate. Keycards and evidence files follow the same rollback rule: one collected after a checkpoint is lost on death and can be collected again, and a committed one never duplicates. Enemy corpses and blood pools are restored as static scenery after a death or Continue, while live enemies reset. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level (C19). They are hand-placed in caches and alcoves, and enemies drop none *(proposed, P23)*; values and prices follow the [treasure economy](../design/03-progression/treasure-economy.md) proposal. Evidence files are additional discoveries: one optional memo, recording or log per level *(proposed)* that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- A records cabinet on the lab's far wall, reachable by an ordinary side route once the founder scene has played, holds the level's evidence file *(proposed)*: EF11, the Trial 001 Recording, the first Link session, years ago, in which the founder, healthy and laughing, tells Adam to say hello and it does. It comes from the cabinet, never from her bedside, and it proves nothing about her condition. She is never a fight. Her name and further identity details remain a later writing decision.
- An optional maintenance shelf on the return shortcut contains microchips for a final upgrade opportunity.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Slow mechanical breathing from the cradle's support machinery, sparse old relay clicks, a low electrical hum on the launch circuit, the Warden's recorded shouts, Adam's calm voice on the lab speakers, and almost no music during the cradle reveal. Isolating the launch circuit cuts the hum and changes an irregular relay rhythm into a steady one. Plasma hums up before each bolt, turret spin-up and the Pruner's sizzle stay clear above the ambience, and impacts are restrained and wet.

## Environment asset kit and layer separation

**Required kit:** Legacy lab arches; support cradle silhouette; privacy curtains; separate support hoses; observation window; service balconies; low crates and pillars (cover); auxiliary-power, isolation and local-control consoles; launch-circuit isolation breaker; amber launch conduit with lit and dark states; verification board; keycard plinth and core-bridge gate reader; folding return bridge.

**Separate objects:** The founder, cradle, support machinery, playable walkways, and effect layers are separate assets. The founder belongs behind protected scenery and has no combat hitbox. Bridge segments remain fixed while traversed, and the core-bridge gate is one assembly with matching closed and open states. Blood and lymph pools are separate layers on fixed floors only.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors as flat base colors with no baked shadows, so the engine's lamps can light them (C35); keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers. Lamps, screens and glows are their own light sources, so a landing keeps its lamp when the scenery is swapped. Final sprite resolution, atlas layout, file format and collision setup remain undecided.

## Constraints for another AI model

No boss fight or firing target for the founder, no harm to her, no full cure or claim of one, no shutdown of Adam before the ending, no other new Heir type (the Warden is the only one introduced here), no real-time countdown or failure timer during the launch-circuit loop, no key item or extra control beyond the three for the override (the keycard only locks the exit), and no dismemberment. Blood is restrained: red (#B3212F, drying to #8A1A26) for people and dogs, black oil (#14181E) for machines and grey-rose lymph (#A88A8C) for Heirs. It never glows, never uses a tell color, never hides a tell, ledge or pickup, and pools appear only on static floors. No violet appears in this level: the live launch circuit is amber and Adam's heartbeat line is teal.

Preserve the established number of levels, enemies (24 types plus four mini-bosses), weapons, and upgrades. Show only one weapon carried by Dave; do not place spare guns on Dave's belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked enemy briefs if detailed characters are needed (their designs are proposed until the lit-cutout validation test is approved); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Environment concept art: one wide 16:9 environment keyframe for level 11, "The First Patient". Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. This keyframe is the one exception to "evenly lit": it is a lit mood reference, so show the scene as the engine will light it, with smooth, realistic light and falloff from the lamps, screens and glows named below (no hard-edged light bands or cel shadows), while the underlying art stays flat base colors with clean dark outlines. Represent steel, copper, glass and machinery with clean flat-color shapes and dark outlines. Preserve the level-specific palette and mood. Keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark, with a light near every landing. No pixel art, photographic textures or franchise assets.

Narrative purpose: Arcadia's founder, the first person ever Linked to Adam, is still alive in a support cradle in the original laboratory, and the hero learns that stopping Adam carelessly would launch the weapon.
Physical setting: Older, hand-built-looking machines in aged steel and dull copper sit within huge dark structural arches. A suspended support cradle occupies the background of a tall central chamber. Soft privacy curtains, blankets and support hoses communicate scale without exposed anatomy. Warm personal objects at a small bedside platform contrast with enormous impersonal machinery. A single amber-glowing conduit snakes through the old machinery beside a thin teal line, and faint bioluminescent vines follow the old pipes.
Color and lighting: near-black #07090F and deep navy #0E1726 arches and shadow masses, aged steel #1C2A3A and slate #2E3B4E, dull copper #A86A3D, warm-white lamp light #FFE9C2, hazard amber #FFB02E only for warnings and the live launch conduit, Arcadia teal #3FE0D0 cradle status lights and heartbeat line, garden glow green #4DEBA0, energy blue #5AA9FF for plasma, no violet. A soft warm lamp pool falls on the cradle; the bedside lamp and old emergency lamps light the chamber with smooth falloff.
Landmark: The enormous suspended cradle, visible first through a narrow observation window and later across the full chamber.
Composition to show: A wide side-view observation chamber with the small hero, in a warm burnt-orange jacket, on a clearly edged service balcony, an immense softly lit support cradle behind protected glass, a control console with a warm-white lamp in the foreground plane, an amber-glowing conduit running through the old machinery beside a thin teal line, and a Warden standing on a far floor with its plate down and a borrowed guard's face on its soft mask.
Foreground: Old pipe brackets and small observation-window edges. Nothing blocks the player's view of platforms near the founder's cradle, and no hanging part of the cradle is a surprise hazard. Foreground vines never cover platform edges.
Playable plane: Fixed service balconies, a few damaged walkway gaps, anchored lift platforms, and the separate launch-circuit loop rooms. Main traversal uses base abilities and marked tether points. Crates and pillars give low and high cover, and blood and lymph pools stay on fixed floors.
Background: The founder and her cradle, support hoses, large breathing bellows, old diagnostic walls, and distant sealed doors to the lab's older wings.
Show only this level's appropriate threats: Warden, Fitted Heir, Sentry Turret, Garden-built Security Drone and Hound, Pruner, Fitting Arm, Keeper Drone, Sanitizer; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No boss fight or firing target for the founder, no harm to her, no full cure, no shutdown of Adam before the ending, no other new Heir type, no real-time countdown or failure timer during the launch-circuit loop, and no dismemberment.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, smooth realistic lighting from the sources named above, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design a clean side-elevation level-layout study for level 11, "The First Patient". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Legacy intake → A02 Borrowed voices → A03 Cradle observation → A04 Launch-circuit loop → A05 Verification gallery → A06 Core bridge.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L11-A01: Legacy intake. A calm entry shows old machinery and one clearly visible broken walkway with an ordinary-jump route and optional base-tether shortcut. No new enemy attacks mid-introduction. Connection: The intact walkway reaches A02.
L11-A02: Borrowed voices. One Warden stands on a broad floor between two fixed cover points, its front plate down and its palm emitter dark. Its soft mask shows the face of a dead Arcadia guard. Connection: A safe checkpoint follows the pairing room, before the cradle reveal.
L11-A03: Cradle observation. A protected platform overlooks the founder's cradle. A nearby terminal at the founder's original workstation is a readable fixed interface, not a companion. It shows, in order: a manual override exists; if Adam goes dark while the launch circuit is live, the dead-man switch releases the Bloom; and a physically separate breaker can isolate the launch circuit first. A diagram links Adam's core, the amber launch circuit and the dead-man switch. Connection: The console opens the clearly marked launch-circuit loop at A04.
L11-A04: Launch-circuit loop. A short U-shaped service route has three ordered rooms: auxiliary power, launch-circuit isolation, and local control. One familiar encounter precedes each room's control: a Sentry Turret with a Garden-built Security Drone before the auxiliary-power control; a Pruner with a Fitting Arm before the isolation breaker; and a Garden-built Hound with a Warden before local control. Controls themselves sit on safe fixed floor, and each encounter keeps to the screen budget. Connection: Completing the third control opens a shortcut back toward A05, avoiding replay of the whole loop.
L11-A05: Verification gallery. A safe verification board shows the launch circuit reading "ISOLATED": the amber line dark and cut off from Adam's teal heartbeat line, the override marked available, and the founder's cradle on its own separate supply, untouched by the controls. A final short room beyond it combines one Keeper Drone with a familiar Sanitizer on broad separated lanes; the level's keycard sits on a plinth at its far end. Connection: The fixed exit balcony leads to A06; its core-bridge gate reader takes the keycard.
L11-A06: Core bridge. A quiet bridge spans a deep machine shaft below Adam's core; its segments lock into place before Dave enters. Adam notes that the launch circuit is isolated and the override enabled. Connection: Cross the complete bridge into the core approach.
Use dark navy and steel masses for architecture with clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Mark low and high cover as distinct shapes, and separate player paths, stable refuges, and hazards through shape as well as color, with a light near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 11, "The First Patient". Match these materials and colors: near-black #07090F and deep navy #0E1726 arches and shadow masses, aged steel #1C2A3A and slate #2E3B4E, dull copper #A86A3D, warm-white lamp light #FFE9C2, hazard amber #FFB02E only for warnings and the live launch conduit, Arcadia teal #3FE0D0 cradle status lights and heartbeat line, garden glow green #4DEBA0, no violet. Lamps are separate light sources added in-engine.
Required asset family: Legacy lab arches; support cradle silhouette; privacy curtains; separate support hoses; observation window; service balconies; low crates and pillars (cover); auxiliary-power, isolation and local-control consoles; launch-circuit isolation breaker; amber launch conduit with lit and dark states; verification board; keycard plinth and core-bridge gate reader; folding return bridge.
Separation rules: The founder, cradle, support machinery, playable walkways, and effect layers are separate assets. The founder belongs behind protected scenery. Bridge segments remain fixed while traversed, and the core-bridge gate is one assembly with matching closed and open states. Blood and lymph are separate layers and are not painted into the modules.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows and no painted-in light pools, rim light or blood, on a flat mid-grey (about #808080) or transparent background, each silhouette read by its dark outline. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 11 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are additional optional finds, and the level's keycard is an ordinary exit lock. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, the screen budget and cover rules, checkpoint rules, and absence of a mini-boss in this brief.
Do not silently add weapons, bosses, traversal skills, unearned upgrades, robot-conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not convert the First Patient (Arcadia's founder), the held clinic staff or harmless Sleepwalkers into compulsory enemies. Do not show torture, execution, surgery, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The Warden is the only new type, it is taught alone, and no boss routine appears in this level.
- The founder is never an enemy or required firing target.
- The launch circuit is isolated and the manual override enabled before the final core confrontation.
- Circuit completion lets Adam be shut down without launching the Bloom; it does not claim to cure the Linked staff or the founder.
- Every launch-circuit encounter keeps to two shooters, three attackers and one heavy gun, with high cover within 3 H of the turret and the Pruner.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects, blood and darkness do not hide platform edges, tells or pickups.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
