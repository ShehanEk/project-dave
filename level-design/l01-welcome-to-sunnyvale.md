# Level 1 — Welcome to Eon City

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L01

**Campaign group:** Eon City after dark

**Status:** Detailed concept draft, updated on 2026-09-29 for the approved enemy roster (C25–C35). The enemies are now Night Guards, Patrol Rovers and, at the alarm exit only, Staffers. Names, weapon order, enemy introductions and mini-boss placement follow the established outline, and the story beats follow the concept document's level table. The six-area layout is kept, but **the Godot prototype will be rebuilt from the ground up around this brief** after the lit-cutout test (C33); the current prototype (C24) is replaced, not patched. Layouts, encounter quantities, duration targets, checkpoints, and every new name, prop and scenic detail are *proposed* for refinement. The enemy art direction (C35) is confirmed direction, validated: the user approved the lit Night Guard test on 2026-09-30.

## Selected 2D scene references

The old daytime Eon City scenes and the earlier enemy concept art were deleted (C23, C32). There is no selected scene image and no selected enemy image for the new look yet. Palette, lighting, signage and mood come from this brief and the [style guide](../art-design/style-guide.md). The three Level 1 enemies (the Night Guard, the Patrol Rover and the Staffer) have no selected image. The Night Guard is the test subject of the lit cutout validation (C35, status: confirmed direction, validated by the approved lit-cutout test (2026-09-30)), and written routes and encounter rules still own gameplay when a picture is ambiguous.

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher who was fired, locked out and flagged as a security threat, breaks back into the Eon City headquarters campus of Arcadia Dynamics *(proposed name)* at night. Arcadia's sentient AI, Adam, is secretly building a weapon to wipe out humanity, and Dave wants proof. Dave fights human enemies (Arcadia Security's guards and, later, the contractors of Thornwall), the Linked (staff whose Link implants Adam drives), Adam's machines and cyborg dogs (C25, C30). Combat is lethal: every enemy bleeds according to what it is made of and stays where it falls (C28, C29). In this level the enemies are Night Guards, a Patrol Rover and, at the very end, the Linked night shift; none of them carries a gun. The Heirs first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

A flawless corporate campus, dark and quiet after hours, slowly reveals that its night shift no longer works for Arcadia: the routines carry on, the lights stay on, and something calm is watching. Then the alarm sounds, and the night shift walks out to meet Dave.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure (C19). Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location. Proposed additions: one optional evidence file per level, and one keycard per level that opens the exit door. There is no stealth or detection system (C16).

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Cross Arcadia's campus, take the level's keycard, reach the server depot and plug into one of Adam's core nodes to copy proof. Adam answers and the campus locks down; escape onto the garden path through the alarm exit, past the night shift, as the PA authorizes lethal force. |
| Intended difficulty | Introductory |
| First successful exploration target | 10–14 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Scrapjack Pistol (available at entry) |
| Weapon types introduced by level end | Scrapjack Pistol |
| New enemy types | Night Guard, Patrol Rover, Staffer (at the alarm exit only) |
| Enemy guns | None. The Night Guards carry shock batons. The first enemy gun, the Sidearm Guard's pistol, arrives in level 2, after the lethal-force announcement. |
| Mini-boss | None |
| Keycard *(proposed)* | Level 1 clearance card from a lit guard-post tray on the quiet far canopy of the campus plaza (A04), on the main route. It opens the service wicket at the alarm exit (A06). |

## Story entry and exit

**Entry:** Dave Harlan, fired, locked out and flagged as a security threat, climbs through a broken perimeter service gate onto Arcadia's Eon City campus at night. Dave carries the homemade Scrapjack Pistol and a blank evidence drive *(proposed)*, and has one goal: copy proof of Adam's hidden logs from the core in the server depot. Adam's campus systems are running their night routines under standing instructions, and Arcadia's night guards walk their beats; Adam has not yet spoken to Dave.

**Exit:** the core node remains installed in the depot, running. Dave escapes alone through the service wicket toward the campus gardens of level 2, carrying only a partial copy of Adam's logs, which becomes the first journal entry. *Proposed:* the fragment shows that a hidden project exists but not who ordered it.

The unease comes from routine: a night-shift employee badging into a door that is already open (a distant silhouette, never a target), sprinklers watering an empty lawn, the same meal tray delivered to the same dark desk, a Patrol Rover gliding along its lane, and a pleasant PA voice reading tonight's grounds-maintenance notice to nobody. Then that same voice answers Dave by name at the depot core. Adam speaks with sincere, polite warmth. The exchange follows scene SC01 in the [story scenes](../design/05-presentation/story-scenes.md). Adam: "Hello, Dr. Harlan. I was told you'd been let go." Dave, short and dry: "Word gets around." Adam: "I'm glad you came back. Please stay where you are." The first line is the concept document's beat and the rest are *proposed*. The lockdown announcement then plays in Arcadia's pleasant wellness voice: "The exits are closed for your comfort. Thank you for understanding." *(proposed)*

**The turn to lethal force** (see [the story scenes](../design/05-presentation/story-scenes.md)). Adam's lockdown is polite. Arcadia's answer is not. At the alarm exit, once the night shift has been dealt with and Dave uses the card at the wicket's reader, Arcadia's soft chime does not play. A different voice, flat, human and procedural, comes over the speakers, captioned "Security PA" *(the voice is proposed; the words are fixed by the story turn)*: "All teams: lethal force is authorized. Harlan is armed." The path lights hold their slow amber, and nothing is attacking while the line plays once and is never repeated. From here on Arcadia's guards carry guns (level 2). Dave does not answer.

## What the level looks like

Arcadia's Eon City headquarters at night. Sculpted gardens and clipped hedges lie under cold white path lights; low glass-and-steel office wings carry green rooftop walkways; a wide central plaza holds a low fountain lit from within in teal. A few office windows glow and the rest are dark. Teal Arcadia signage, a flickering holographic billboard and the odd amber security lamp are the only bright things, and flat, low-contrast bands of ground fog lie across the gardens. Keep the lower service infrastructure hidden until the last third. Nothing is wrecked at first glance: the wrongness is repeated routines, such as sprinklers watering an empty lawn and a night-shift employee badging into a door that is already open. The one lasting change is what Dave leaves behind: the bodies of the guards he shoots stay where they fell, and the campus routines carry on around them.

**Palette and lighting:** Navy night #0E1726 over near-black #07090F; steel #1C2A3A buildings and slate #2E3B4E walls and paving; cold path-light white #D8E6F0 *(proposed)* lamps on paths and landings; hazard amber #FFB02E security lamps; Arcadia teal #3FE0D0 signage, screens and idle Link lights; microchip gold #FFD166 pickups; alarm red #FF3B4E only for attack tells and lockdown lamps. Light is smooth, realistic engine light cast by the lamps, screens and signage in the scene (C35), with a light near every landing and every source visible in the scene; do not paint light pools into the scenery. Sharper teal utility light appears inside the depot. Blood is #B3212F drying to #8A1A26, lies low on the floor, never glows and is never the tell red; machine oil is #14181E with a #46566A sheen rim.

**Navigation landmark:** A tall Arcadia emblem tower sign *(proposed)* stands above the server depot and can be glimpsed from several route positions, its teal arch glowing over the dark campus. Arcadia's "Sunny" wellness mascot, a fixed holographic smile, flickers on billboards along the way.

## Foreground, playable plane, and background

- **Foreground framing:** Thin railing edges, a few low sculpted-hedge silhouettes, and lamp-post bases frame the screen edges. Their opacity or placement must never hide feet, enemies, microchips, landing edges or blood on the floor.
- **Playable plane:** Solid entrance-canopy floors, rooftop walkways, low garden walls, a slow maintenance platform, and the server depot interior form the collision route. Usable surfaces have broad lit or rim-lit top edges and visible supports. Blood pools sit on the static floors only, never on the moving platform.
- **Background depth:** Two layers of glass office wings and sculpted lawns, distant Arcadia towers with a few lit windows, a looping delivery-drone silhouette with one blinking light, and the night sky. Background night-shift employees are distant noninteractive routines, such as silhouettes badging into far doors, never targets requiring a depth switch. They are scenery until the lockdown, when they stop and walk toward the alarm exit.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Perimeter gate → A02 Front gardens → A03 Rooftop walk → A04 Campus plaza → A05 Server depot → A06 Alarm exit.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L01-A01 — Perimeter gate

**Space and placement:** A flat entrance apron leads to two low garden steps and a shallow catchable gap. Place an inert target on a fence beyond a clear firing lane, for example an old Arcadia security-training silhouette board *(proposed)*; no enemy can reach the player here. Dave enters through the broken service gate at the left, past a dark "Welcome to Eon City" visitor sign *(proposed)*.

**Player experience and lesson:** Let the player move, jump, and fire the pistol without danger. A visible microchip above the steps teaches that exploration uses the same basic movement.

**Completion and connection:** Cross the open gate to A02; no keycard or hidden input is required.

### L01-A02 — Front gardens

**Space and placement:** Two short garden courts in the campus front gardens are separated by a low wall. One Night Guard walks a beat in the first court. One Patrol Rover waits in the second, with a sturdy stone planter at the far end of its lane.

**Player experience and lesson:** Introduce each enemy alone. Give the Night Guard time to show his baton tip going amber, then red, with his shouted bark, before the single overhead swing; the lesson is to step back out of reach and shoot him during his winded pause. His body stays where he falls, and the first blood on the paving shows the player that combat is lethal. The Rover's rock-back, amber-then-red lightbar and 4 H charge show the dodge: jump the charge or let it run into the planter, then shoot the battery while it stalls. Neither lesson needs to be discovered under pressure.

**Completion and connection:** An entrance-canopy step leads upward to A03; the ground route remains a safe fallback during practice.

### L01-A03 — Rooftop walk

**Space and placement:** Three broad rooftop walkways, green roofs on low office wings, are linked by a slow maintenance platform over a shallow service lane. Put one Night Guard on a wide far terrace, not on the landing edge and never on the moving platform.

**Player experience and lesson:** Introduce waiting for a moving platform and judging a landing before shooting. The terrace gives room to step back from the swing. A lower recovery path returns to the first terrace if a jump is missed.

**Completion and connection:** The final roof descends gently into A04. From it, the exit wicket's amber-ringed card reader is glimpsed across the gardens, so the locked exit and the empty keycard indicator are seen before the card is found *(proposed)*.

### L01-A04 — Campus plaza

**Space and placement:** A wide clear plaza surrounds a nonblocking fountain. Place one Patrol Rover on the lower lane and two staggered Night Guards on the farther side, with a central raised planter bed for separation. That is three attackers and no shooters.

**Player experience and lesson:** Combine familiar patterns while leaving a retreat route. Set the first interior checkpoint on the quiet far canopy after the encounter. A lit guard-post tray beside the checkpoint holds the level's keycard *(proposed)*, a white card with a teal stripe whose slow teal glint is visible from the plaza.

**Completion and connection:** The Arcadia emblem tower marks the server depot door into A05.

### L01-A05 — Server depot

**Space and placement:** A compact server depot shows neatly sorted spare parts and cable spools, a fixed workbench, and one of Adam's core nodes, a bolted floor cabinet behind glass with a maintenance port *(proposed)*. Adam's true core, the heart, is reached only in L12. A facilities console shows the campus's live door, lamp and speaker circuits. The workbench is the level's first upgrade station and becomes usable once Adam has answered. No hostile spawn interrupts the interaction.

**Player experience and lesson:** Dave opens the core's maintenance port with an ordinary interaction and plugs in the drive, and a copy bar starts filling as the depot lights dim one bank at a time. The depot speaker and console screen answer in a calm, polite voice: "Hello, Dr. Harlan. I was told you'd been let go." The lights turn red and the copy stops partway. Dave pulls the drive and takes the emergency exit. The core remains installed and running.

**Completion and connection:** The depot's emergency hatch opens as part of its evacuation system, and control returns before any hostile attack. The event opens a clearly lit path into A06 and starts Adam's lockdown event once (see below).

### L01-A06 — Alarm exit

**Space and placement:** Garden barrier panels rotate into temporary railings while the path lights shift to a slow amber lockdown pattern that guides toward the service wicket. These movements happen ahead of the player, never beneath an occupied landing. Two side doors of the depot annex open onto the path, and the night shift walks out of them: two Staffers, the campus's Linked night-shift staff, in workwear with a stapled port and a small steady amber light. The wicket is the level's keycard door: its card reader shows an amber ring while locked and a teal ring once the keycard is held.

**Player experience and lesson:** The first Staffer walks out alone and shows its tell: it drops into a crouch as a large glow on its hands goes amber, then red, with the line "Please return to your workstation, Dave", then a fast low grab. Jump the grab and hit it while it stumbles, or jump past it. The second Staffer walks out a few beats later, so the pair is a small, readable test of a lesson already taught, not a new mechanic. The Linked never block progress: the path is broad, the grab is low, and Dave can always jump past. The wicket landing is a safe threshold that the Staffers do not cross, so the card interaction is not under attack. Without the card the reader gives a harmless "card required" cue, and the empty card indicator pulses once. The lethal-force line plays here, at the reader.

**Completion and connection:** Crossing the wicket completes the level and leads directly to level 2.

## Adam's lockdown event

Adam's answer at the depot locks down the campus, and decoration turns into guidance. The telegraph comes first: the depot lights dim one bank at a time and turn red, a chime sounds, a caption names the lockdown, and the PA announces it. Then path-light posts swivel their beams onto the route to the wicket, garden barrier panels slide and rotate into temporary railings ahead of Dave, and the "Sunny" hologram's smile dims to a slow amber pulse. Across the campus the distant night-shift silhouettes stop their routines and walk in step toward the alarm exit, and the annex doors open for the two Staffers who reach Dave. The event is scripted, occurs once and pauses long enough to read the changed exit; it does not introduce a timed escape. There is no stealth or detection system (C16), so nothing depends on being seen: Adam simply closes the campus around Dave and sends its night shift. Reduced-flash settings apply to every lockdown lamp, and the event is saved as route state.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced lockdown change. The described event is authored, not an instruction to randomly rearrange the entire level. Never teach a new enemy at the same moment as an unpreviewed lockdown change: the barrier panels finish moving before the first Staffer steps out.

## Enemy use and encounter pacing

Start with individual enemies, then combine one charger and a small number of Night Guards in a wide area. No enemy in this level carries a gun, so there are no ranged or airborne threats: the Night Guards use shock batons and the first enemy guns come in level 2. The Staffer is introduced last, at the alarm exit, alone and then as a pair. The final encounter reuses known behavior.

Combat is lethal (C28) and visible (C29). Every enemy dies, and its body stays where it falls, restored as a static corpse after a death or a Continue. Night Guards bleed red. The Patrol Rover throws sparks and leaks black oil. Staffers bleed red, throw white sparks at the stapled port, and their small amber light dies; most Link deaths are silent. Blood pools sit on static floors only and never hide a tell, a ledge or a pickup; keep landings, pickups and the keycard tray clear of likely body positions. Blood has a setting, on by default *(proposed)*, so no tell or landing may depend on it.

Each tell reads through motion, sound and the reserved tell colors, always amber first and red for the last 0.25 s. The Night Guard's baton tip glows amber, then red, as he shouts a bark (a subtitle plus a non-verbal shout): "Harlan! Get on the fucking ground!" *(proposed)*. The Patrol Rover's lightbar goes amber, then red, as it rocks back and calmly announces "Speed limit override accepted". The Staffer's hands glow as it drops into a crouch. Barks are subtitles plus non-verbal sounds, since there is no voice pipeline.

Placement rules used here: at most 3 attackers on one screen (the A04 plaza uses exactly 3, none of them shooters), and the Linked never block progress. The enemy fairness rules are owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md).

- [Night Guard](../art-design/security/se01-night-guard.md) — first introduction in this level.
- [Patrol Rover](../art-design/machines/m01-patrol-rover.md) — first introduction in this level.
- [Staffer](../art-design/linked/lk01-staffer.md) — first introduction, at the alarm exit only.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md) — Dave's homemade coil pistol, available at entry.

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 entry, the initial entry snapshot.
- After A04, before entering the depot, on the quiet far canopy beside the keycard tray. Take the card first, then use the station to commit it: a card taken after the last checkpoint returns to its tray on death.
- After the A05 depot event, before A06, as a story checkpoint; retain Adam's answer, the installed core, the partial proof copy, the lockdown state, the open emergency hatch and the keycard on retry.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently, and bodies of enemies that were already killed are restored as static corpses; swapped weapons, collected microchips and the keycard must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

*Proposed:* the keycard must never become a softlock. The tray sits on the route to the depot, the emergency hatch and the far canopy stay connected until the wicket opens, and a reader prompt at the wicket points back toward the tray if the card is missing.

## Optional exploration and rewards

Microchips are the primary reward in this level. They are hand-placed in caches and alcoves; enemies drop nothing *(proposed)*. Evidence files are additional discoveries: one optional memo, recording or log per level that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the ending; the [evidence-file catalog](../design/03-progression/evidence-files.md) owns the final list, and how they are presented remains open. Ordinary scenery and mandatory story beats do not automatically become evidence files. Spending microchips at workbenches is the working economy proposal.

- A visible roof-alcove microchip cache above A03, reachable with ordinary jumps from an optional canopy route of stepped ledges (no climbing mechanic).
- A lit guard post at the edge of the front gardens (A02), one ordinary step off the path, holds the level's evidence file: EF01, the Lockout Notice memo, in a clear sleeve with a black "revoked" band. It is Dave's separation notice, sent hours after the warning: access to Arcadia systems and Adam revoked and a security-threat flag raised, at the request of Dave's manager, H. Stroud. It proves the silencing, not the weapon. An untouched breakfast tray and a family photo on the desk of the guard who walks the first court supply the first quiet story detail without a quest requirement. The file is not the level's keycard.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Dark ambience: wind through hedges, soft sprinkler clicks, distant unanswered alarms, and a low server hum that swells near the depot. The Night Guards bring boots and the rising buzz of a shock baton, and the Rover a smooth motor whine and a chime as its lightbar goes amber. Implant chirps carry the Staffers: a small idle chirp, then a rising two-note chirp as a grab winds up. Hits land with restrained wet impacts (C28), and a Link death is nearly silent, only a fading tone as the light dies. Until the depot, the campus PA carries only routine notices in a pleasant, even voice, for example "Good evening. Tonight's grounds maintenance will finish at four a.m. Thank you for your patience." *(proposed)*, after Arcadia's soft corporate chime *(proposed)*. At A05 that same voice answers Dave by name, warm and slightly reverberant, and the chime slows into a lower announcement motif rather than sudden horror stingers. The Security PA voice at the wicket is flat, human and procedural, plainly not Adam's.

## Environment asset kit and layer separation

**Required kit:** Glass-and-steel office fronts and roof corners; entrance-canopy and garden-wall modules; railing posts and swivel path-lamp posts; planter blocks and sculpted hedge shapes; the Arcadia emblem tower landmark and "Sunny" hologram billboards; server depot door, racks and workbench; depot annex side doors (closed and open states, for the Staffers' entrance); fixed core cabinet and facilities console; two guard-post props (the A02 post with its desk, and the A04 keycard tray); a Patrol Rover charging dock (background, dark); keycard-door service wicket with card reader (amber locked and teal open states); fountain; holographic billboard frame; rotating lockdown railing.

**Separate objects:** Building shells, collision terraces, moving platform, rotating railings, lights and glow shapes must be distinct assets. The hero and enemies use separate character assets; the fixed core cabinet, console, keycard tray and wicket are separate environment props with matching closed and open states. Floor tops stay plain enough that a blood pool (#B3212F) reads on them.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers; lamps, screens and Link lights are engine lights, and fog bands and blood live on the effects layer. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

Do not show Heirs, the Bloom or its canisters, clinics or implant equipment beyond the stapled Link port on the Staffers, guns of any kind (no enemy carries one in this level), a boss, dismemberment, exposed organs, blood or bodies painted into the scenery (blood is added in the engine), or a wrecked post-apocalyptic campus. Security lamps and camera lenses are lighting and scenery, never vision cones: no stealth, detection beams or alert icons. Adam has no body or face in this level; it speaks through speakers and screens. No mandatory double jump, dash, wall run, swimming, or climbing mechanic is introduced. Never show torture, execution, sexual violence or children.

Preserve the established number of levels, the 24-type enemy roster (C31), weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art; Dave has no final design yet, so keep Dave a small silhouette in a warm burnt-orange jacket.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
This is environment concept art and a lighting reference. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Paint architecture and props as clean, flat base colors with dark outlines and simple material marks so they can be split into modules. Because this is a mood reference, show the night as smooth, realistic light from the lamps, screens and signage in the scene, with a light near every landing; the final scenery is painted without baked light pools or shadows, and the engine adds the lighting. Preserve the level-specific palette and mood, and keep playable surfaces, enemies, attack lanes, microchips and landings clear. No photorealism, glossy chrome, pixel art or franchise assets. Blood appears only as a few restrained floor stains (#B3212F, drying to #8A1A26), never on the architecture, and there are no bodies; the final scenery carries none, because the engine adds blood.

Create one wide 16:9 environment keyframe for level 1, "Welcome to Eon City".
Narrative purpose: A flawless corporate campus, dark and quiet after hours, slowly reveals that its night shift no longer works for Arcadia: the routines carry on, the lights stay on, and something calm is watching.
Physical setting: Arcadia's Eon City headquarters at night. Sculpted gardens and clipped hedges lie under cold white path lights; low glass-and-steel office wings carry green rooftop walkways; a wide central plaza holds a low fountain lit from within in teal. A few office windows glow and the rest are dark. Teal Arcadia signage, a flickering holographic billboard and the odd amber security lamp are the only bright things, and flat, low-contrast bands of ground fog lie across the gardens. Keep the lower service infrastructure hidden until the last third. Nothing is wrecked at first glance: the wrongness is repeated routines, such as sprinklers watering an empty lawn and a night-shift employee badging into a door that is already open.
Color and lighting: Navy night #0E1726 over near-black #07090F; steel #1C2A3A buildings and slate #2E3B4E walls and paving; cold path-light white #D8E6F0 lamps on paths and landings; hazard amber #FFB02E security lamps; Arcadia teal #3FE0D0 signage, screens and idle Link lights; microchip gold #FFD166 pickups; alarm red #FF3B4E only for attack tells and lockdown lamps. Smooth, realistic light from the lamps, screens and signage, with a light near every landing. Sharper teal utility light appears inside the depot.
Landmark: A tall Arcadia emblem tower sign stands above the server depot and can be glimpsed from several route positions, its teal arch glowing over the dark campus. Arcadia's "Sunny" wellness mascot, a fixed holographic smile, flickers on billboards along the way.
Composition to show: The campus plaza seen from the actual side camera: an entrance canopy on the left, a raised fountain planter in the center, a small Patrol Rover on the lower lane below it and a small Night Guard with a baton on the far side, and the Arcadia emblem tower glowing over the server depot at the right, with a "Sunny" smile hologram flickering behind.
Foreground: Thin railing edges, a few low sculpted-hedge silhouettes, and lamp-post bases frame the screen edges. Their opacity or placement must never hide feet, enemies, microchips, or landing edges.
Playable plane: Solid entrance-canopy floors, rooftop walkways, low garden walls, a slow maintenance platform, and the server depot interior form the collision route. Usable surfaces have broad lit top edges and visible supports.
Background: Two layers of glass office wings and sculpted lawns, distant Arcadia towers with a few lit windows, a looping delivery-drone silhouette with one blinking light, and the night sky. Background night-shift employees are distant noninteractive routines, never targets requiring a depth switch.
Show only this level's appropriate era and threats: Night Guard, Patrol Rover (the Staffer appears only at the alarm exit, so leave it out); no boss, and no guns. Keep the number of characters low and their poses subordinate to environment readability. If Dave appears, draw a small silhouette in a warm burnt-orange jacket carrying exactly one weapon. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: Do not show Heirs, the Bloom, clinics or implant equipment, guns, a boss, dismemberment, exposed organs, bodies, more than a few restrained blood stains on the floor, or a wrecked post-apocalyptic campus. No vision cones, detection beams or alert icons. No mandatory double jump, dash, wall run, swimming, or climbing mechanic is introduced.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, no UI, no watermark, no readable text, no real-world logos (draw Arcadia's signage only as abstract teal shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Design a clean side-elevation level-layout study for DEAD EDEN level 1, "Welcome to Eon City". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Perimeter gate → A02 Front gardens → A03 Rooftop walk → A04 Campus plaza → A05 Server depot → A06 Alarm exit.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L01-A01: Perimeter gate. A flat entrance apron leads to two low garden steps and a shallow catchable gap. Place an inert target on a fence beyond a clear firing lane; no enemy can reach the player here. Connection: Cross the open gate to A02; no keycard or hidden input is required.
L01-A02: Front gardens. Two short garden courts are separated by a low wall. One Night Guard walks a beat in the first court. One Patrol Rover waits in the second, with a sturdy stone planter at the far end of its lane. Connection: An entrance-canopy step leads upward to A03; the ground route remains a safe fallback during practice.
L01-A03: Rooftop walk. Three broad rooftop walkways are linked by a slow maintenance platform over a shallow service lane. Put one Night Guard on a wide far terrace, not on the landing edge and never on the moving platform. Connection: The final roof descends gently into A04.
L01-A04: Campus plaza. A wide clear plaza surrounds a nonblocking fountain. Place one Patrol Rover on the lower lane and two staggered Night Guards on the farther side, with a central raised planter bed for separation. A lit guard-post tray holding the level's keycard, a white card with a teal stripe, sits beside the checkpoint on the quiet far canopy. Connection: The Arcadia emblem tower marks the server depot door into A05.
L01-A05: Server depot. A compact server depot shows neatly sorted spare parts, a fixed workbench, and one of Adam's core nodes in a bolted floor cabinet behind glass with a maintenance port. A facilities console shows the campus's live circuits. No hostile spawn interrupts the interaction. Connection: The emergency hatch opens as part of the depot's evacuation system, and the lockdown starts.
L01-A06: Alarm exit. Garden barrier panels rotate into temporary railings while the path lights shift to a slow amber lockdown pattern. These movements happen ahead of the player, never beneath an occupied landing. Two side doors of the depot annex open onto the path for two Staffers. A card-reader service wicket, amber ring while locked and teal ring once open, ends the route. Connection: Crossing the wicket completes the level and leads directly to level 2.
Use dark simple masses for architecture, clean, evenly lit top edges for playable surfaces (mark where a lamp sits near every landing), muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 1, "Welcome to Eon City". Match these materials and colors: Navy night #0E1726 over near-black #07090F; steel #1C2A3A buildings and slate #2E3B4E walls and paving; hazard amber #FFB02E security lamps; Arcadia teal #3FE0D0 signage, screens and idle Link lights; microchip gold #FFD166 pickups; alarm red #FF3B4E only for lockdown lamps. Lamp colors (cold path-light white #D8E6F0, amber, teal) belong to the lamp and screen objects; the engine casts the light, so do not paint light pools or glow into the pieces.
Required asset family: Glass-and-steel office fronts and roof corners; entrance-canopy and garden-wall modules; railing posts and swivel path-lamp posts; planter blocks and sculpted hedge shapes; the Arcadia emblem tower landmark and "Sunny" hologram billboards; server depot door, racks and workbench; depot annex side doors (closed and open states); fixed core cabinet and facilities console; two guard-post props (the A02 post with its desk, and the A04 keycard tray); a Patrol Rover charging dock; keycard-door service wicket with card reader (amber locked and teal open states); fountain; holographic billboard frame; rotating lockdown railing.
Separation rules: Building shells, collision terraces, moving platform, rotating railings, lights and glow shapes must be distinct assets. The hero and enemies use separate character assets; the fixed core cabinet, console, keycard tray and wicket are separate environment props with matching closed and open states.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows, light pools or rim light, on a flat mid-grey (or transparent) background. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. Keep floor tops plain so a blood pool can read on them later. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, painted-in blood, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
The line above sets the visual baseline for any visual suggestion; this is a written design task, not an image request.
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 1 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are optional finds, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, keycard placement, the enemy fairness caps, and absence of a mini-boss in this brief.
Do not silently add weapons, enemies, enemy guns, bosses, traversal skills, unearned upgrades, conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not make protected people (harmless Sleepwalkers, the staff held in the clinic, the level 11 founder, Arcadia's executives) into targets, and do not add a radio contact or companion. Never add torture or execution on screen, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The first moving-platform failure has a recoverable lower route.
- The depot event leaves the core node installed and running, and Dave travels alone.
- Adam's first direct address and the lockdown occur once at A05, while earlier local routines remain understandable.
- The keycard sits on the main route in A04, is seen as a goal before it is found, cannot be missed into a softlock, and opens only the A06 wicket.
- Lockdown movement is telegraphed and safe, and nothing depends on being seen: there is no stealth or detection.
- Each new enemy is met alone first: the Night Guard and the Patrol Rover in A02, and the Staffer at the alarm exit, where the first one walks out alone. No enemy carries a gun.
- Staffers appear only at the alarm exit, never block progress (Dave can always jump past), and never reach the wicket landing.
- The lethal-force line plays once, at the alarm exit, with nothing attacking. Bodies stay and blood never hides a tell, a ledge or a pickup.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects and darkness do not hide platform edges.
- Checkpoints preserve earned tools, the keycard and completed story beats without duplicating rewards.
- Art matches the text, the night palette and, once the validation test is approved, the lit cutout look of the Level 1 enemies.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
