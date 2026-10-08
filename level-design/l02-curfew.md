# Level 2 — Curfew

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L02

**Campaign group:** Eon City after dark

**Renamed from:** "Hedge Your Bets" (C34; the new name is proposal P22). The file was renamed from `l02-hedge-your-bets.md`.

**Status:** Detailed concept draft, updated on 2026-09-29 for the approved enemy roster (C25–C35). The level is now called Curfew, and its enemies are Sidearm Guards, Hounds with Night Guard handlers and Security Drones, with the first enemy gun. Names, weapon order, enemy introductions and mini-boss placement follow the established outline, and the story beats follow the concept document's level table. Layouts, encounter quantities, duration targets, checkpoints, and every new name, prop and scenic detail are *proposed* for refinement. The enemy art direction (C35) is confirmed direction, validated: the user approved the lit Night Guard test on 2026-09-30.

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, a fired AI researcher who went rogue, works alone through the Eon City campus of Arcadia Dynamics *(proposed name)* at night to expose Adam, Arcadia's sentient AI, which is secretly building a weapon to wipe out humanity. Dave fights human enemies (Arcadia Security's guards and, later, the contractors of Thornwall), the Linked (staff whose Link implants Adam drives), Adam's machines and cyborg dogs (C25, C30). Combat is lethal: every enemy bleeds according to what it is made of and stays where it falls (C28, C29). Since the lethal-force announcement at the end of level 1, Arcadia's guards shoot live rounds. The Heirs first appear in level 10. The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Campus curfew falls over an ornamental garden at night. Arcadia's guards, their dogs and Adam's machines enforce it, and the hedge maze becomes a moving funnel that herds Dave toward the Arcadia Wellness Center, forcing him to clear safe landings while the first live rounds of the night are fired.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure (C19). Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location. Proposed additions: one optional evidence file per level, and one keycard per level that opens the exit door. There is no stealth or detection system (C16).

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Recover the Boom Broom, work through the reconfiguring hedge maze under curfew, take the level's keycard from the water-tower pavilion and open the Parade gate into the showcase hall. |
| Intended difficulty | Easy (the first enemy gun is met alone, with cover beside it) |
| First successful exploration target | 12–16 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Boom Broom |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom |
| New enemy types | Sidearm Guard, Security Drone, Hound (with a Night Guard handler) |
| Enemy guns first faced | Pistol, AS-9 "Civic" (EG01), carried by the Sidearm Guards |
| Mini-boss | None |
| Keycard *(proposed)* | Level 2 clearance card from a lit terminal slot in the A05 pavilion, on the main route after the combined encounter. It opens the A06 service gate. |

## Story entry and exit

**Entry:** Dave passes through the service wicket from level 1 into the campus hedge maze and sculpture gardens. The PA's announcement still hangs over the campus: lethal force is authorized. Adam is sealing every campus exit, calls it a curfew, and its calm voice now follows Dave over the garden speakers. From a garden overlook near the entrance, Dave sees the campus gates seal, and a service map beside it points toward the showcase hall and a lift below (scene SC02 in the [story scenes](../design/05-presentation/story-scenes.md)). Near the entrance, Dave finds a labeled pipe-cleaning tool, the Boom Broom, in an irrigation and coolant maintenance shed *(proposed)*.

**Exit:** A one-way service door, opened with the level's keycard, enters the Parade of Progress staging area used in level 3; the apparent surface exit, the campus main gate, is visibly sealed.

Adam calls the lockdown a comfort measure. Dave follows the signs and discovers that every apparently helpful route leads toward the Arcadia Wellness Center, the employee clinic where every worker received the Link. Adam's lines are *proposed*: "Good evening, Dr. Harlan. Campus curfew is now in effect. For your comfort, please stay on the illuminated paths." Dave's reply is short and dry: "Comfort. Sure." The guards enforce the curfew with barks (subtitles plus non-verbal shouts): a Sidearm Guard shouting "Drop it! I will shoot, I swear to God!" *(proposed)*, scared and angry, with the pistol already up.

## What the level looks like

Sculpted hedges are dense dark masses cut into arches and geometric animal shapes, with teal rim light along their edges. Each mass sits in a large rectangular mobile planter riding on recessed rails. Tulip-shaped garden lamps carry small camera lenses that are scenery only, because there is no detection system (C16). Steel irrigation and coolant pipes run between glass-roofed garden pavilions, and steel sculptures with teal light rings dot the lawns. Slow amber curfew lights on the lamp posts pulse along the illuminated paths Adam wants Dave to stay on. The route feels hushed and manicured even as the geometry becomes controlling, and the guards and dogs on the paths are the first sign that the campus has stopped being polite.

**Palette and lighting:** Navy night #0E1726 with deep hedge green-black #14261E *(proposed)* masses; steel #1C2A3A planter chassis and slate #2E3B4E paving; cold path-light white #D8E6F0 *(proposed)* lamps on the paths; Arcadia teal #3FE0D0 rim light and speaker status lights; hazard amber #FFB02E warning lamps on rails, control pads and curfew lights. Keep amber used as a warning accent rather than covering the scene. Alarm red #FF3B4E appears only on the sealed main gate's lockout light and on attack tells. Light is smooth, realistic engine light cast by the lamps, screens and curfew lights in the scene (C35), with a light near every landing and every source visible in the scene; do not paint light pools into the scenery. Blood (#B3212F, drying to #8A1A26) reads on the stone paths and stays off the sliding planters; machine oil is #14181E with a #46566A sheen rim.

**Navigation landmark:** A tall spiral topiary wrapped around Arcadia's cooling-water tower *(proposed)*, a steel tower ringed with teal lights, repeatedly reappears as the player climbs toward the exit.

## Foreground, playable plane, and background

- **Foreground framing:** Thin leaf silhouettes and occasional rail covers near the frame edge. Dense hedge faces belong behind the playable lane, never as opaque dark screens covering enemies, landings or blood on the floor.
- **Playable plane:** Stone paths, planter tops, fixed pavilion ledges, and rail-mounted hedge platforms, all with lit or rim-lit top edges. Track joints make potential movement visible. Blood pools sit on static floors only, never on the sliding planters.
- **Background depth:** Rows of sculpted hedges, slow nonhostile maintenance activity such as a sprinkler arm, glass greenhouse roofs lit teal, and the campus main gate, which Adam seals as the level opens.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration or darkness.

## Main route

```text
A01 Tool shed → A02 Curfew lawn → A03 Drone terraces → A04 Moving hedge lanes → A05 Water-tower crossing → A06 Parade gate.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L02-A01 — Tool shed

**Space and placement:** A quiet irrigation and coolant maintenance shed immediately offers the Boom Broom on an uncluttered tool rack. Its asset tag reads "high-pressure debris removal device", and the shed's log shows every use filed as plumbing service. Outside is a practice yard with inert targets and a sturdy backstop.

**Player experience and lesson:** Provide the weapon before new enemies. Teach short-range spread, pump recovery, knockback, and individual-shell reloading through one optional target group.

**Completion and connection:** The only onward path is a broad lawn into A02.

### L02-A02 — Curfew lawn

**Space and placement:** A long lawn path in two courts, split by a low hedge wall. In the first court, one Sidearm Guard waits at the far end of a long visible path beside a solid hedge wall, with a low raised planter (a 0.6 H cover piece) at the midpoint. In the second court, a Night Guard handler stands at the far end of a shorter path, holding one Hound on a lead, with a solid hedge wall behind the pair to catch the dog's overshoot.

**Player experience and lesson:** Introduce each new enemy alone. The Sidearm Guard is the campaign's first gun. Show the two-hand stance, the muzzle lamp going amber, then red with a click, the single flat round, and the slide-rack reload. Dave can jump the flat round, keep moving, or stand behind the low planter (it blocks all same-floor fire, and Dave can shoot over it), then rush him while he racks the slide; the Boom Broom rewards the rush. The Hound follows: it drops low as its jaw glows amber, then red, with a wet wheeze, lunges 2 H, crouches for half a second with its own amber-red blip, and lunges once more. Jump each lunge, then shoot it during its rigid recovery, aiming slightly down; the Boom Broom's knockback throws it clear. The handler's baton tell starts 1.5 s after the lunge chain, so the dog is always the first problem and the handler a known one. Both kills leave bodies on the path.

**Completion and connection:** A short garden stair leads to A03.

### L02-A03 — Drone terraces

**Space and placement:** Three broad terraces sit above a shallow irrigation trench. Introduce one Security Drone over the widest terrace, alone. A later terrace contains one Staffer, standing at a routine such as swiping a badge at a gate that is already open.

**Player experience and lesson:** Teach the locked-spot dive before mixing ground and air: the drone noses up as its lightbar goes amber, then red, then dives at Dave's locked spot; sidestep it, then hit it while it hangs at head height. The first missed landing drops to a return path, not directly into an unseen enemy. The Staffer, a returning type, never blocks the gate: the path is broad and Dave can jump past it.

**Completion and connection:** Reach a quiet gazebo checkpoint before A04.

### L02-A04 — Moving hedge lanes

**Space and placement:** Two hedge planters slide horizontally to form alternating short paths. Each has a visible rail, travel endpoint, and amber warning lamp. Provide solid waiting alcoves beside both. No guard, dog or drone covers these lanes, and no gun lane crosses a sliding planter.

**Player experience and lesson:** Trigger the first movement by stepping onto a safe control pad, a visitor-maze guidance pad *(proposed)* that Adam has taken over. Watch the route change, then cross. Movements never close on the hero; an occupied choke point postpones movement.

**Completion and connection:** A permanent upper ledge reconnects both temporary routes to A05. From that ledge, the service gate's amber-ringed card reader is glimpsed across the maze, so the locked exit and the empty keycard indicator are seen before the card is found *(proposed)*.

### L02-A05 — Water-tower crossing

**Space and placement:** A wide planter platform rises beside the spiral topiary. After reaching its fixed landing, face one Sidearm Guard and one Security Drone with a refuge ledge between them: the guard holds a raised pavilion step one ordinary jump above the far side of the landing, so his round comes from another floor, and the drone circles over the wide part. The landing's rear is a wall or a railing, never an open pit edge within 1.5 H of Dave's standing spots in the pistol's lane. Beyond the encounter, a terminal in the pavilion at the top of the roof descent holds the level's keycard *(proposed)* in a lit slot, a white card with a teal stripe whose glint is visible from the landing.

**Player experience and lesson:** Test clearing a landing and separating attack timings: one shooter and one diver. From the step the guard aims at Dave's grounded spot and locks at red, and the drone dives at Dave's locked spot, so the answer to both is to keep moving off the spot, then rush the guard during his reload (the step is one ordinary jump) and hit the drone when it hangs at head height. Never initiate the dive while the player is making the first mandatory blind transition, and never fire at an airborne Dave.

**Completion and connection:** A pavilion roof descends to A06.

### L02-A06 — Parade gate

**Space and placement:** Adam closes a visible surface door in the background, the campus main gate, and lights a signed service gate on the actual play plane. The gate is the level's keycard door: its reader shows an amber ring and bar symbol while locked, and a teal ring and chevron once the level's keycard opens it. The curfew checkpoint at the gate is held by a Night Guard handler and his Hound on a broad approach.

**Player experience and lesson:** Confirm that progress means moving deeper, and reuse the K9 lesson from A02 without teaching anything new. The pair is cleared before the reader; the gate interaction is not under attack, and without the card the reader gives a harmless "card required" cue.

**Completion and connection:** Exit into level 3's Parade of Progress staging area.

## Adam's lockdown event

As the level opens, Dave watches from the garden overlook as the campus main gate lowers and its lockout light turns red. This happens outside the playable plane while Dave is safe near the shed. Adam then turns the maze into a herding funnel: hedge planters slide along visible tracks after a polite announcement, converting a strolling maze into a route that leads toward the Wellness Center signs. Each movement is telegraphed by a pulse of the amber rail lamps, a motor chime and a caption, with Adam's PA line on the first. The camera shows both endpoints before each first activation. A stable alternative floor prevents moving geometry from softlocking Dave. Dave's reaction is short and dry: "That hedge wasn't here when I worked here." *(proposed)* The event is scripted and telegraphed. There is no stealth or detection system (C16), so Adam's cameras, speakers and drones never "spot" Dave; they only announce or warn, and the guards and drones fight only where the level places them, never on a hedge movement.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced lockdown change. The described event is authored, not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Introduce each new type alone: the Sidearm Guard first (the campaign's first enemy gun), then the Hound with its Night Guard handler, then the Security Drone. Combine one shooter and one diver only near the end (A05). The Hound and its handler return at the gate. Staffers and Patrol Rovers may occupy optional side lanes, but do not exceed the readability of the main two-threat exercise.

The pistol fires one round per shot. On Dave's floor the round is flat at 0.5 H, so a held jump clears it and a low crate blocks it. From another floor the guard aims at Dave's last grounded spot, locked at red, so moving is the answer. Guards never aim at an airborne Dave, they fire only when they are at least 1 H inside the camera edge, and the reload leaves them rooted and open. The Hound is fast and low; jump each lunge. Every tell reads through the reserved colors, always amber first and red for the last 0.25 s: the muzzle lamp and its click, the Hound's jaw and its wheeze, the drone's lightbar as it noses up. The drone's dive is an attack telegraph, not a detection state.

Combat is lethal (C28) and visible (C29). Guards and Hounds bleed red, and a Hound's legs twitch for about a second after death. Drones throw sparks and leak black oil. A Staffer bleeds red and throws white sparks at the stapled port. Bodies stay where they fell, restored as static corpses after a death or a Continue. A dead guard's pistol falls as a prop, never a pickup. Blood pools sit on static floors only and never hide a tell, a ledge or a pickup. Keep landings, pickups and the keycard terminal clear of likely body positions. A corpse is not cover.

Placement rules used here (P23): at most 2 shooters, 3 attackers and 1 heavy gun per screen (this level has at most one shooter and no heavy gun on a screen), no pit edge within 1.5 H behind Dave's standing spots in a gun lane, the camera shows a gun's muzzle and its lane before it fires, and the Linked never block progress. The rules are owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md).

- [Night Guard](../art-design/security/se01-night-guard.md) — established behavior; also the Hound's handler.
- [Staffer](../art-design/linked/lk01-staffer.md) — established behavior or returning type.
- [Patrol Rover](../art-design/machines/m01-patrol-rover.md) — established behavior or returning type (optional side lanes).
- [Sidearm Guard](../art-design/security/se02-sidearm-guard.md) — first introduction in this level.
- [Hound](../art-design/hounds/k01-hound.md) — first introduction in this level, with a Night Guard handler.
- [Security Drone](../art-design/machines/m02-security-drone.md) — first introduction in this level.
- [Pistol, AS-9 "Civic" (EG01)](../art-design/enemy-guns/eg01-pistol.md) — first enemy gun, carried by the Sidearm Guards.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md) — the pump-action blaster Arcadia maintenance crews used to clear clogged coolant pipes.

The list above records weapon types introduced by this point, not a carried inventory. The hero carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 after the Boom Broom trial, the level's first workbench checkpoint *(proposed)*; save the chosen carried weapon and the dropped weapon at the pickup spot.
- At the gazebo after A03.
- At the quiet service-gate approach after A05, a workbench checkpoint before the exit *(proposed)*. Take the keycard first and then use the station to commit it: a card taken after the last checkpoint returns to its terminal on death.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently, and bodies of enemies that were already killed are restored as static corpses; swapped weapons, collected microchips and the keycard must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level. They are hand-placed in caches and alcoves; enemies drop nothing *(proposed)*. Evidence files are additional discoveries: one optional memo, recording or log per level that proves what Arcadia or Adam did. They go in the journal, have no stat effect and never gate the ending; the [evidence-file catalog](../design/03-progression/evidence-files.md) owns the final list, and how they are presented remains open. Ordinary scenery and mandatory story beats do not automatically become evidence files. Spending microchips at workbenches is the working economy proposal.

- A flowerbed side route reveals a small microchip cache behind a moving hedge; the entrance becomes obvious after seeing its movement.
- A maze-keeper's hut at the center of the hedge maze, behind a timed hedge-gate route off the A04 lanes, holds the level's evidence file: EF02, the Wellness Pilot Photo, a curled instant print of Arcadia's first Link "wellness pilot" night team at the maze entrance, each with a small teal Link light behind the ear. The matching lights are the only wrong note. It presents the Link as a perk and shows no one under Adam's control. The gate cycle is previewed, with solid waiting alcoves and an ordinary-jump return, and the route rejoins the main path. The file is not the level's keycard.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot.

## Sound and atmosphere

Night wind through hedges, distant unanswered alarms, a low pump-and-server hum from the base of the water tower, and rail motors. Adam's warm, slightly reverberant voice comes over the garden speakers, with soft ambient garden music under it. The guards bring boots and hard barks (subtitles plus non-verbal shouts). The pistol is a sharp crack, one cue per shot, with the click of the lock that comes with the red lamp, then the slide-rack. The Hound never pants or barks: a wet wheeze and claws on stone carry its tell. The drone's rising whine as it noses up carries its own. Hits land with restrained wet impacts (C28).

## Environment asset kit and layer separation

**Required kit:** Straight and corner hedge planters; topiary and sculpted shapes; recessed rail modules; stone path edges; irrigation-pipe bends; gazebo; irrigation and coolant maintenance shed; weapon rack; cooling-water tower; fixed refuge ledges; low cover pieces (0.6 H planters and crates, fixed to the ground, never on a sliding planter); garden speaker posts and amber curfew light posts; visitor-maze guidance pads; garden overlook with service map; maze-keeper's hut and timed hedge gate; a K9 kennel and handler post (A02 and A06); pavilion terminal with keycard slot; keycard-door service gate with card reader (amber locked and teal open states); sealed campus main gate for the background.

**Separate objects:** Mobile planter chassis must be separate from the fixed route. Leaf decoration cannot define hidden collision. Keep rails, lamps, platform surfaces, and the background gate distinct, and keep the service gate's locked and open states matched. Path stone stays plain enough that a blood pool reads on it.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers; lamps, curfew lights and screens are engine lights, and fog bands and blood live on the effects layer. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No Linked Lineman, Marksman, Thornwall contractors, machine guns, rifles or plasma (the only enemy gun in this level is the pistol), no Seedlobber, tether anchors requiring use, Heirs, or mini-boss. Do not turn the lockdown into a randomized maze with no readable exit. No stealth: camera lenses, drone lights and speakers decorate or warn, and never form detection cones or alert states (C16). Hedges are ordinary clipped shrubs; no blood or bodies are painted into the scenery (blood is added in the engine). Never show torture, execution, sexual violence, children or dismemberment.

Preserve the established number of levels, the 24-type enemy roster (C31), weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if an approved character reference is unavailable rather than redesigning the character inside environment art; Dave has no final design yet, so keep Dave a small silhouette in a warm burnt-orange jacket.

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use existing approved character references if detailed characters are needed; otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
This is environment concept art and a lighting reference. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Paint foliage, steel, glass and machinery as clean, flat base colors with dark outlines and simple material marks so they can be split into modules. Because this is a mood reference, show the night as smooth, realistic light from the lamps, screens and curfew lights in the scene, with a light near every landing; the final scenery is painted without baked light pools or shadows, and the engine adds the lighting. Preserve the level-specific palette and mood, and keep playable surfaces, enemies, attack lanes, microchips and landings clear. No photorealism, glossy chrome, pixel art or franchise assets. Blood appears only as a few restrained floor stains (#B3212F, drying to #8A1A26), never on the architecture, and there are no bodies; the final scenery carries none, because the engine adds blood.

Create one wide 16:9 environment keyframe for level 2, "Curfew".
Narrative purpose: Campus curfew falls over an ornamental garden at night. Arcadia's guards, their dogs and Adam's machines enforce it, and the hedge maze becomes a moving funnel that herds Dave toward the Arcadia Wellness Center.
Physical setting: Sculpted hedges are dense dark masses cut into arches and geometric animal shapes, with teal rim light along their edges. Each mass sits in a large rectangular mobile planter riding on recessed rails. Tulip-shaped garden lamps carry small camera lenses, slow amber curfew lights pulse along the paths, and steel irrigation and coolant pipes run between glass-roofed garden pavilions. Steel sculptures with teal light rings dot the lawns. The route feels hushed and manicured even as the geometry becomes controlling.
Color and lighting: Navy night #0E1726 with deep hedge green-black #14261E masses; steel #1C2A3A planter chassis and slate #2E3B4E paving; cold path-light white #D8E6F0 lamps on the paths; Arcadia teal #3FE0D0 rim light and speaker status lights; hazard amber #FFB02E warning lamps on rails, control pads and curfew lights. Keep amber used as a warning accent rather than covering the scene. Alarm red #FF3B4E only on the distant sealed gate's lockout light.
Landmark: A tall spiral topiary wrapped around Arcadia's steel cooling-water tower, ringed with teal lights, repeatedly reappears as the player climbs toward the exit.
Composition to show: A side-view garden cross-section showing a safe gazebo on the left, two hedge planters on visible rails in the center, and the spiral water-tower topiary on the right, with a single small Security Drone over a broad landing and a small Sidearm Guard behind a low planter.
Foreground: Thin leaf silhouettes and occasional rail covers near the frame edge. Dense hedge faces belong behind the playable lane, never as opaque dark screens covering enemies or landings.
Playable plane: Stone paths, planter tops, fixed pavilion ledges, and rail-mounted hedge platforms, all with lit top edges. Track joints make potential movement visible.
Background: Rows of sculpted hedges, slow nonhostile maintenance activity such as a sprinkler arm, glass greenhouse roofs lit teal, and the sealed campus main gate.
Show only this level's appropriate era and threats: Night Guard, Sidearm Guard, Hound, Security Drone, Staffer; no boss. Keep the number of characters low and their poses subordinate to environment readability. If Dave appears, draw a small silhouette in a warm burnt-orange jacket carrying exactly one weapon. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No Linked Lineman, Thornwall contractors, rifles, machine guns, Seedlobber, tether anchors requiring use, Heirs, or mini-boss. Do not turn the lockdown into a randomized maze with no readable exit. No vision cones, detection beams or alert icons; no dismemberment, exposed organs, bodies, or more than a few restrained blood stains on the floor.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, no UI, no watermark, no textual labels, no logos, no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Design a clean side-elevation level-layout study for DEAD EDEN level 2, "Curfew". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Tool shed → A02 Curfew lawn → A03 Drone terraces → A04 Moving hedge lanes → A05 Water-tower crossing → A06 Parade gate.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L02-A01: Tool shed. A quiet irrigation and coolant maintenance shed immediately offers the Boom Broom on an uncluttered tool rack. Outside is a practice yard with inert targets and a sturdy backstop. Connection: The only onward path is a broad lawn into A02.
L02-A02: Curfew lawn. A long lawn path in two courts split by a low hedge wall. In the first, one Sidearm Guard waits at the far end beside a solid hedge wall, with a low raised planter at the midpoint. In the second, a Night Guard handler holds one Hound on a lead in front of a solid hedge wall. Connection: A short garden stair leads to A03.
L02-A03: Drone terraces. Three broad terraces sit above a shallow irrigation trench. Introduce one Security Drone over the widest terrace. A later terrace contains one Staffer at a routine, swiping a badge at an open gate. Connection: Reach a quiet gazebo checkpoint before A04.
L02-A04: Moving hedge lanes. Two hedge planters slide horizontally to form alternating short paths. Each has a visible rail, travel endpoint, and amber warning lamp. Provide solid waiting alcoves beside both. Connection: A permanent upper ledge reconnects both temporary routes to A05.
L02-A05: Water-tower crossing. A wide planter platform rises beside the spiral topiary. After reaching its fixed landing, face one Sidearm Guard on a raised pavilion step and one Security Drone with a refuge ledge between them. A terminal in the pavilion beyond the encounter holds the level's keycard in a lit slot. Connection: A pavilion roof descends to A06.
L02-A06: Parade gate. Adam closes a visible surface door in the background and lights a signed service gate on the actual play plane, with a card reader (amber ring while locked, teal ring once open). A Night Guard handler and his Hound hold a broad approach. Connection: Exit into level 3's Parade of Progress staging area.
Use dark simple masses for architecture, clean, evenly lit top edges for playable surfaces (mark where a lamp sits near every landing), muted noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Draw low cover (0.6 H) and high cover (at least 1.2 H) as distinct shapes. Separate player paths, stable refuges, and hazards through shape as well as color. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for DEAD EDEN level 2, "Curfew". Match these materials and colors: Navy night #0E1726 with deep hedge green-black #14261E masses; steel #1C2A3A planter chassis and slate #2E3B4E paving; Arcadia teal #3FE0D0 speaker status lights; hazard amber #FFB02E warning lamps on rails, control pads and curfew lights. Keep amber used as a warning accent rather than covering the scene. Lamp colors belong to the lamp objects; the engine casts the light, so do not paint light pools or glow into the pieces.
Required asset family: Straight and corner hedge planters; topiary and sculpted shapes; recessed rail modules; stone path edges; irrigation-pipe bends; gazebo; irrigation and coolant maintenance shed; weapon rack; cooling-water tower; fixed refuge ledges; low cover pieces (0.6 H planters and crates); garden speaker posts and amber curfew light posts; visitor-maze guidance pads; garden overlook with service map; maze-keeper's hut and timed hedge gate; a K9 kennel and handler post; pavilion terminal with keycard slot; keycard-door service gate with card reader (amber locked and teal open states); sealed campus main gate for the background.
Separation rules: Mobile planter chassis must be separate from the fixed route. Leaf decoration cannot define hidden collision. Keep rails, lamps, platform surfaces, and the background gate distinct, and keep the service gate's locked and open states matched.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows, light pools or rim light, on a flat mid-grey (or transparent) background. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. Keep path stone plain so a blood pool can read on it later. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, painted-in blood, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
The line above sets the visual baseline for any visual suggestion; this is a written design task, not an image request.
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 2 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, evidence files are optional finds, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, keycard placement, the enemy fairness caps (at most 2 shooters, 3 attackers and 1 heavy gun per screen, cover for every gun lane, no pit edge behind a gun lane), and absence of a mini-boss in this brief.
Do not silently add weapons, enemies, enemy guns, bosses, traversal skills, unearned upgrades, conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not make protected people (harmless Sleepwalkers, the staff held in the clinic, the level 11 founder, Arcadia's executives) into targets, and do not add a radio contact or companion. Never add torture or execution on screen, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The shotgun appears before the first enemy gun.
- The Sidearm Guard, the Hound and the Security Drone are each met alone before they are combined, and every same-floor pistol lane has a low crate or planter within reach of Dave's standing spots.
- All hedge movements have previewed endpoints and a safe waiting area, and no gun lane crosses a sliding planter.
- The combined guard-and-drone encounter happens on a broad landing, not during a blind jump, and no pit edge lies within 1.5 H behind Dave in the pistol's lane.
- The keycard terminal is on the main route in A05 after the combined encounter, is seen as a goal before it is found, cannot be missed, and opens only the A06 service gate.
- Adam's directions and signs steer toward the Wellness Center without ever contradicting the readable route or trapping Dave; nothing depends on being seen.
- Bodies stay, and blood never hides a tell, a ledge or a pickup.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects and darkness do not hide platform edges.
- Checkpoints preserve earned tools, the keycard and completed story beats without duplicating rewards.
- Art matches the text, the night palette and the approved enemy and weapon designs.

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
