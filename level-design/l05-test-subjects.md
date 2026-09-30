# Level 5 — Test Subjects

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L05

**Campaign group:** The Rootworks (levels 4–6)

**Renamed from:** "Compost Confidential" (C34; the new name is proposal P22). The file was renamed from `l05-compost-confidential.md`.

**Status:** Detailed concept draft, updated on 2026-09-29 for the approved enemy roster (C25–C35). The weapon order, enemy introductions and mini-boss placement follow the established outline. The new enemy types are the Heavy Gunner, the Grenadier and the Gun Hound, all Thornwall's, and the level holds its one authored aftermath scene, the Bloom test chambers. Area names, layouts, encounter quantities, duration targets, checkpoints, keycard and evidence-file placements, Adam's lockdown event and all new story and scenic details are *proposed* for refinement. The revamp's story names (Arcadia Dynamics, the Link, the Bloom, Thornwall) are proposals (P17); the roster is confirmed (C31) and its detailed behaviors and numbers are proposal P23; Adam (C17) and Dave Harlan (C18) are confirmed. The enemy art direction (C35) is confirmed direction, validated: the user approved the lit Night Guard test on 2026-09-30.

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher who was fired and went rogue, breaks into the campus of Arcadia Dynamics to stop Adam, the sentient AI the company built, from launching the Bloom, a self-copying nanite weapon that kills only people. Dave travels alone (C12) and fights human enemies (Arcadia Security's guards and Thornwall's contractors), the Linked (staff whose Link implants Adam drives), Adam's machines and cyborg dogs (C25, C30). Combat is lethal: every enemy bleeds according to what it is made of and stays where it falls (C28, C29). The Heirs, Adam's synthetic bodies, first appear in level 10. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

Arcadia's e-waste recycling plant, in the Rootworks under the campus, recycles the company's confidential hardware. Adam has turned part of it into a Bloom test site, where sealed glass chambers still hold what the tests left behind. Thornwall's fire teams sweep the plant to sanitize it, and its Linked technicians still work the floor.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure (C19). Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location. *Proposed:* each level has one optional evidence file, and each level's exit door needs that level's keycard.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Recover the Seedlobber from the reforestation supply depot, cross the e-waste recycling plant past Thornwall's fire teams and the Bloom test chambers, take the level's keycard, and lower the wash-water sluice leading to the cooling station. |
| Intended difficulty | Moderate |
| First successful exploration target | 15–19 minutes; excludes repeated failures and exhaustive secret hunting |
| New weapon | Seedlobber |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber |
| New enemy types | Heavy Gunner, Grenadier, Gun Hound |
| Enemy guns first faced | Frag launcher, Thornwall GL-6 (EG04), carried by the Grenadiers. The Heavy Gunner's rotary (EG03) and the Gun Hound's back-mounted rifle (EG02) are guns met earlier on new carriers, and the rifle now fires three bursts per volley. |
| Mini-boss | None |
| Keycard (*proposed*) | Plant clearance card, printed by the supervisor's terminal on the A03 observation shelf; the security door at the end of the A06 dry passage reads it. |
| Evidence file (*proposed*, optional) | EF05 **Thornwall Invoice**, at a Thornwall field desk in a side dock off the test wing, near A04 ([S05](../design/03-progression/evidence-files.md)). |

## Story entry and exit

**Entry:** The freight door from level 4 opens onto a raised inspection walkway above the plant's shredder drums and wash-water vats. Dave still needs the plant's sluice route down to the cooling station and, beyond it, the way to the clinic. Adam, having sealed every campus exit in level 2, now speaks to Dave over the plant speakers. Thornwall's fire teams, sent to sanitize, are already in the plant.

**Exit:** A dry service passage beneath the lowered sluice, behind a card-reader security door, leads to level 6's reservoir approach at the cooling station.

The plant is quiet in the wrong way. It keeps sorting, shredding and washing hardware that nobody has thrown away in years, because Adam keeps feeding it. Dave sees a Staffer, a Linked technician in a hi-vis vest, re-clamping a cable to a dead breaker panel, over and over, before its small amber light steadies and it turns toward him.

**The aftermath scene (SC05).** From the supervisor's gallery, Dave looks down a wide window onto the Bloom test chambers: a row of sealed, plainly furnished rooms behind glass. In two of them adult test subjects, dead, in plain grey clothes with ID wristbands, lie or sit among ordinary furniture, crusted in violet. The furniture and equipment around them are untouched, because the Bloom kills only people, and readable wall diagrams beside the window show the target profile: people only. Thornwall's cleanup is under way: a cleanup cart and sealed drums wait at the chamber lock. This is the level's one authored aftermath scene (C28): seen at a distance through glass, out of every combat lane, with no close-up faces, no children and no violence on screen, and it never blocks the route. *Proposed PA line:* "Recycling is a small act of care, Dr. Harlan." Dave does not answer.

## What the level looks like

Dark steel granulator drums, shredder hoppers and sorting belts fill a black cavern hall under the campus. They are heaped with Arcadia's discarded hardware: dead server racks, cracked screens, and cable bundles that hang in loops like roots. Grated duct floors cover the shredder channels; they are solid and safe, nothing bursts up from them and none drops away. Safe service catwalk looks firm, riveted and lit along its edge, and hazardous wash-water and runoff areas are bounded by amber and red hazard bands. Thornwall's fire teams have set up crate lines and a field desk in the plant. A wall of dead racks still blinks a few teal and green LEDs, and cooling mist is drawn as flat, low-contrast bands near the vents. Far down a side gallery, sealed glass test chambers glow violet.

**Palette and lighting:** near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0 for status LEDs and signage, signal green #4DE38A, hazard amber #FFB02E for work lamps and hazard stripes, alarm red #FF3B4E for strobes and attack tells, Bloom violet #C77DFF only inside the test chambers (the chamber lights and the residue on the subjects), microchip gold #FFD166 for pickups. Light is smooth, realistic engine light cast by the work lamps, LEDs and strobes in the scene (C35): keep catwalk edges and landings lit brighter than hopper interiors, with a lamp near every landing and every source visible in the scene, and paint no light pools into the scenery. Blood (#B3212F, drying to #8A1A26) reads on the steel plates; machine oil is #14181E with a #46566A sheen rim. *(Signal green and all level-specific uses are proposed.)*

**Navigation landmark:** A huge tilted granulator drum spills a curtain of hanging cable roots; beyond it, a large amber-painted sluice wheel hangs in its own work-lamp pool.

## Foreground, playable plane, and background

- **Foreground framing:** Low cable coils and cut pipe mouths frame corners. Avoid dense mist and drifting sparks that conceal tells, low cover or blood on the floor.
- **Playable plane:** Metal inspection ledges, broad moving scrap lifts, visible conveyor-bridge and catwalk platforms, and grated floor patches that are solid and safe. Each floor material has a distinct, lit top edge. Low crates (0.6 H) and solid hoppers or pillars (at least 1.2 H) are fixed cover on static floors. Blood pools sit on static floors only, never on a lift or a belt.
- **Background depth:** Layered hoppers, distant slow-turning granulator drums, dead server racks with sparse LEDs, drainage pipes, and the glass Bloom test chambers glowing violet in a far gallery. Shallow shafts of cold white light fall through ceiling grilles from the campus above.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration, mist or darkness.

## Main route

```text
A01 Supply depot → A02 Breaker bay → A03 Sorting trench → A04 Shredder catwalk → A05 Rising scrap lifts → A06 Sluice controls.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L05-A01 — Supply depot

**Space and placement:** The Seedlobber rests on a rack in the reforestation supply depot beside the plant's receiving dock, among stenciled launcher crates and pod bins from Arcadia's reforestation program. It sits before the first hostile. A low wall and inert target let the player test an arc from a safe distance.

**Player experience and lesson:** Demonstrate bounce, delay, and self-danger without a required self-damage event. Show the pod landing clearly rather than hiding it behind scenery or mist. Taking the Seedlobber leaves the previous weapon on the rack, so a safe swap back remains available before leaving.

**Completion and connection:** A short ramp enters A02; retry restores the single weapon saved after the pickup choice.

### L05-A02 — Breaker bay

**Space and placement:** One Heavy Gunner plants his rotary on a flat floor pad at the far end of a bay beside a dead breaker panel. Two low crate stacks (0.6 H) sit on Dave's side within 3 H of his standing spots, and an upper cable-gantry ledge is reachable by ordinary jumps, so another floor is always within 3 H. The bay's rear is a wall. A wall sign with a card icon points onward to the supervisor's gallery.

**Player experience and lesson:** Observe the Heavy Gunner plant the rotary, the barrels spin up with a rising whine and the collar glow amber, then red, then a flat stream. On his floor the stream is cover-only: get behind a low crate or onto the gantry before it starts, then punish the overheat, when he is rooted and venting steam. Dave can shoot over the crate; the Seedlobber can arc pods over it.

**Completion and connection:** The clear far ledge leads to A03.

### L05-A03 — Sorting trench

**Space and placement:** A Grenadier stands behind low cover on the far side of a broad sorting trench, an empty conveyor pit crossed by a wide steel catwalk, his gas mask and bandolier plain to see. Provide two separated safe firing positions on Dave's side, with a wall or stair (never an open edge) behind them.

**Player experience and lesson:** Teach reading an arcing attack and moving forward: his muzzle ring goes amber, then red, with the shout "Frag out!", then two frags fly on fixed arcs, one to Dave's grounded spot and one about 1.5 H behind him. Each lands, blinks and bursts, blocked by walls and floors. The escape is always forward, toward him, and he cannot hit anything closer than about 2 H, so Dave rushes him during his reload. The Seedlobber can arc back over his cover, but an upper ledge also gives a direct pistol shot.

**Completion and connection:** Reach a quiet observation shelf and checkpoint. The shelf is the plant supervisor's glass gallery. Its terminal sits at the entrance, with the recovery station and workbench beyond it, and prints the level's keycard. A wide window looks down on a row of sealed Bloom test chambers (background layer only), the aftermath scene described above. No enemy is in or near the gallery.

### L05-A04 — Shredder catwalk

**Space and placement:** Two steel catwalk stretches cross the shredder channel, divided by solid steel plates and a fixed refuge platform. On the first stretch, one Gun Hound waits at the far end, alone, with a low crate (0.6 H) at the midpoint. The second stretch pairs the Gun Hound with a Staffer, a Linked technician in a hi-vis vest, a screen behind it. A short ordinary lift from the refuge platform reaches a side dock off the test wing.

**Player experience and lesson:** Teach the dog's rig alone: it plants its legs as the back gun rises and its lamp goes amber, then red, then it fires two low 3-round bursts. Jump each low burst, or stand behind the crate, then shoot it while the gun cycles. The second stretch adds a different kind of threat, a low grab from the Staffer, which never blocks the way: Dave can jump past. The catwalks are solid and safe.

**Completion and connection:** Exit to a stable platform at A05.

### L05-A05 — Rising scrap lifts

**Space and placement:** Two broad bucket-like scrap lifts rise through a short shaft beside fixed catch ledges. A Thornwall Rifleman holds a far fixed shelf behind a low crate; one Grenadier is visible beyond the next refuge, behind low cover, a screen away.

**Player experience and lesson:** Alternate movement and combat rather than filling every jump with attacks. The route always offers a noncrumbling landing before each ranged exchange, and no gun lane covers a lift ride. The Rifleman now fires three bursts per volley: jump each with a ground beat between, or use the crate, then close in during the magazine swap.

**Completion and connection:** The upper lift lands beside A06.

### L05-A06 — Sluice controls

**Space and placement:** A final open chamber combines one Heavy Gunner and one Gun Hound, with wide metal refuges, low crates within 3 H of every standing spot, and an obvious manual wheel. Both guns answer to cover, so the crates serve either.

**Player experience and lesson:** Use learned cover, jumping, and arcing fire: a low crate blocks the stream and the dog's low bursts, and the Seedlobber can arc pods over the crates. After the fight, turn the wheel to lower the sluice gate and drain the flooded service passage behind it.

**Completion and connection:** The dry passage's security door reads the level's keycard and opens to level 6. Approached without the card, it shows a "keycard required" prompt and the HUD keycard indicator stays empty, so the player knows what is missing.

## Adam's lockdown event

*(Proposed event.)* Adam reroutes the plant's sorting line, and the reroute opens Dave's way forward. After a polite announcement (*proposed line:* "Line 3 is being reconfigured for your convenience."), a hinged conveyor arm swings out across an empty bay just after the A03 checkpoint and locks into place as a thick new bridge. The camera previews the swinging arm and its destination before it becomes usable. The reroute drops a shutter over a decorative background feed channel while opening the main forward route; it never requires guessing through mist or darkness, and no gun lane covers the arm while it moves.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at a fixed point, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

Each new Thornwall role has its own lesson: cover against a stream (Heavy Gunner), moving forward off arcing frags (Grenadier), and low bursts (Gun Hound). The final combination uses two roles, not all three. Avoid endless spawns from feed chutes. Returning types (Sidearm Guards, Riot Officers, Thornwall Riflemen, Sentry Turrets, Freight Loaders, Security Drones and Staffers) may hold optional side lanes, but not the introduction encounters. Nothing here aims at an airborne Dave.

The Heavy Gunner spins up for about a second (amber, then red for the last 0.25 s), fires a flat stream of about 1.2 s at 0.5 H, then overheats for about 2 s, rooted. The Grenadier lobs two frags on fixed arcs, blinking amber then red before each burst of about 1 H radius; frags are blocked by walls and floors, and he has a minimum range of about 2 H and a slow reload. The Gun Hound fires two low bursts at 0.3 H. Every enemy gun fires only when its carrier is at least 1 H inside the camera edge, and enemy projectile hits use half knockback.

Combat is lethal (C28) and visible (C29). Thornwall men, Staffers and the Gun Hound bleed red; the Gun Hound also sparks at its plates and its legs twitch for about a second after death; a Staffer also throws white sparks at the stapled port. Bodies stay where they fell, restored as static corpses after a death or a Continue, and a dead gunner's weapon falls as a prop, never a pickup. Blood pools sit on static floors only and never hide a tell, a ledge or a pickup. Keep landings, pickups and the gallery terminal clear of likely body positions. A corpse is not cover.

Placement rules used here (P23): at most 2 shooters, 3 attackers and 1 heavy gun per screen (the A06 pairing is exactly two shooters and one heavy gun), a low crate or another floor within 3 H of every Heavy Gunner spot, the frag escape always forward, no pit edge within 1.5 H behind Dave's standing spots in a gun lane, the camera shows a gun's muzzle and its lane before it fires, and the Linked never block progress. The rules are owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md).

- [Staffer](../art-design/linked/lk01-staffer.md) — established behavior or returning type (plant technicians in hi-vis workwear).
- [Rifleman](../art-design/security/se04-rifleman.md) — established behavior; a Thornwall man, three bursts per volley from this level.
- [Heavy Gunner](../art-design/thornwall/tw01-heavy-gunner.md) — first introduction in this level.
- [Grenadier](../art-design/thornwall/tw02-grenadier.md) — first introduction in this level.
- [Gun Hound](../art-design/hounds/k02-gun-hound.md) — first introduction in this level.
- [Frag launcher, Thornwall GL-6 (EG04)](../art-design/enemy-guns/eg04-frag-launcher.md) — first faced in this level.
- [Machine gun (EG03)](../art-design/enemy-guns/eg03-machine-gun.md) and [assault rifle (EG02)](../art-design/enemy-guns/eg02-assault-rifle.md) — met earlier; the Heavy Gunner carries the rotary and the Gun Hound a back-mounted rifle.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- At A01 after the Seedlobber lesson.
- After A03 on the observation shelf, with the keycard taken first: the terminal is passed before the recovery station.
- At the stable upper landing before A06.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. The snapshot also records the microchip wallet, evidence files and the level's keycard; a keycard taken after the last checkpoint returns to its terminal on retry. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently, and bodies of enemies that were already killed are restored as static corpses; swapped weapons and collected microchips, evidence files and keycards must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level. They are hand-placed in caches and alcoves; enemies drop nothing *(proposed)*, and values and prices follow the treasure economy proposal. The level's evidence file is an additional optional discovery: a memo, recording or log that proves what Arcadia or Adam did. It goes in the journal, has no stat effect, and never gates the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- A microchip cache on an optional cable-gantry loop above A02, reachable with basic jumps.
- *Evidence file (proposed):* EF05 **Thornwall Invoice** ([S05](../design/03-progression/evidence-files.md)), a stub of carbonless invoice pages on a thin steel field clipboard, in plain contractor stock rather than Arcadia's, with a pale stamp and a column of line items. It lies at a Thornwall field desk in a side dock off the test wing, reached by an ordinary lift from the A04 refuge platform. It is Thornwall's bill to Arcadia: a retainer for guarding the defense servers, then, from the night of the lockout, a higher line for "site sanitization" approved by the board's security committee, with a priority surcharge for one named intruder. It proves the order to kill went out from the boardroom the same night lethal force was announced. It names no board member and shows no bodies, and it does not replace the test chambers on the main route.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot. The keycard and all story information the player needs stay on the main route; no keycard sits in an optional branch or an evidence-file alcove.

## Sound and atmosphere

Grinding drum hum, conveyor rattle and dripping wash water. A calm PA voice speaks between the machine noise. Thornwall is flat and cold: short radio calls and taped rifles, one "brrt" cue per burst. The Heavy Gunner's rotary whine rises in pitch as the collar glows, then holds a chatter loop on its own audio player and ends in a steam hiss; the Grenadier's launcher thumps, his frags chirp as they blink and crack as they burst; the Gun Hound gives a wet wheeze before its back gun fires. Keep explosive-pod fuse cues audible against the environment. Hits land with restrained wet impacts (C28). The test gallery is nearly silent, with only a low violet hum.

## Environment asset kit and layer separation

**Required kit:** Granulator drums; trench walls and sorting belts; firm steel catwalk plates; solid duct-grating patches; low crates (0.6 H) and solid hoppers or pillars (at least 1.2 H) as cover; lift buckets; conveyor-arm bridge and joints; hanging cable-root bundles; closed effluent pipes; sluice wheel and gate; dead server racks with LEDs; reforestation depot rack and launcher crates; supervisor gallery, terminal and window; sealed Bloom test chambers (background only) with their still furnishings and, as a separate set piece, the aftermath figures; a Thornwall cleanup cart, sealed drums and field desk; card-reader security door.

**Separate objects:** Moving lifts, the reconfigured conveyor bridge and drum scenery use separate assemblies, and the keycard door has matching closed and open states. Do not bake mist, hazard glow or blood into base textures. Violet chamber light is a separate effect layer, and the aftermath figures are a separate prop set that can be removed without touching the chamber architecture. Floor plates stay plain enough that a blood pool reads on them.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers; work lamps, LEDs and the chamber lights are engine lights. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No machine conversion, mandatory swimming, tether puzzles, or boss. Snare Foam, the Seedlobber's slowing upgrade, is ordinary foam, not a link to the Bloom, and violet appears only in the test chambers. The chamber aftermath is restrained and shown once: adults only, seen small and at a distance through glass, with no close-up faces, no children, no torture or execution on screen, no dismemberment, no blood on the subjects (a violet crust only), and never inside a combat lane.

Preserve the established number of levels, the 24-type enemy roster (C31), weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if a character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked character briefs if detailed characters are needed (no enemy design is selected yet; all are proposed); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
This is environment concept art and a lighting reference. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Paint steel, glass, cable and machinery as clean, flat base colors with dark outlines and simple material marks so they can be split into modules. Because this is a mood reference, show the plant as smooth, realistic light from the work lamps, LEDs and strobes in the scene, with a light near every landing; the final scenery is painted without baked light pools or shadows, and the engine adds the lighting. Preserve the level-specific palette and mood, and keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark. No photorealism, glossy chrome, pixel art or franchise assets. Blood appears only as a few restrained floor stains (#B3212F, drying to #8A1A26), never on the architecture, and there are no bodies; the final scenery carries none, because the engine adds blood.

Create one wide 16:9 environment keyframe for level 5, "Test Subjects".
Narrative purpose: Arcadia's e-waste recycling plant beneath the campus keeps sorting and shredding hardware because Adam keeps feeding it, and Adam has turned part of it into a Bloom test site whose sealed glass chambers still hold what the tests left behind, while Thornwall's fire teams sweep the plant.
Physical setting: Dark steel granulator drums, shredder hoppers and sorting belts fill a black cavern hall, heaped with discarded server racks, cracked screens and cable bundles that hang in loops like roots. Grated duct floors are solid; safe service catwalk looks firm, riveted and lit along its edge. Hazardous wash-water and runoff areas are bounded by amber and red hazard bands. Crate lines and a field desk mark where Thornwall's contractors have set up.
Color and lighting: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0 for status LEDs, signal green #4DE38A, hazard amber #FFB02E for work lamps and hazard stripes, alarm red #FF3B4E only for strobes, Bloom violet #C77DFF only inside the sealed test chambers, microchip gold #FFD166 for a few pickups. Keep catwalk edges and landings lit brighter than hopper interiors.
Landmark: A huge tilted granulator drum spills a curtain of hanging cable roots; beyond it, a large amber-painted sluice wheel hangs in its own work-lamp pool.
Composition to show: A side-view recycling cavern with dark granulator drums in the background, a lit reforestation supply depot with a seed-launcher rack on the left, a thick new conveyor-arm bridge in the center, a glass gallery of violet-lit Bloom test chambers far behind it (still figures seen tiny and in silhouette through the glass, no faces), and a small Thornwall Heavy Gunner with a drum-pack rotary behind a low crate on the right. Include a small silhouette of Dave in a burnt-orange jacket on a lit ledge for scale.
Foreground: Low cable coils and cut pipe mouths frame corners. Avoid dense mist and drifting sparks that conceal tells or low cover.
Playable plane: Metal inspection ledges, broad moving scrap lifts, visible conveyor-bridge and catwalk platforms, and solid grated floor patches. Each floor material has a distinct, lit top edge.
Background: Layered hoppers, distant slow-turning granulator drums, dead server racks with sparse LEDs, drainage pipes, and shallow shafts of cold white light through ceiling grilles from the campus above.
Show only this level's appropriate threats: Heavy Gunner, Grenadier, Gun Hound, Thornwall Rifleman, Staffer; no boss. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No machine conversion, mandatory swimming, tether puzzles, boss, dismemberment, exposed organs, children, torture or execution; no wounds or blood on the chamber figures (a violet crust only) and no close-up faces on them, and elsewhere only a few restrained blood stains on the floor. No vision cones or alert indicators. Snare Foam is ordinary foam, not a link to the Bloom.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Design a clean side-elevation level-layout study for level 5, "Test Subjects". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Supply depot → A02 Breaker bay → A03 Sorting trench → A04 Shredder catwalk → A05 Rising scrap lifts → A06 Sluice controls.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L05-A01: Supply depot. The Seedlobber rests on a rack in the reforestation supply depot beside the plant's receiving dock, before the first hostile. A low wall and inert target let the player test an arc from a safe distance. Connection: A short ramp enters A02; retry restores the single weapon saved after the pickup choice.
L05-A02: Breaker bay. One Heavy Gunner plants a rotary on a flat floor pad at the far end of a bay beside a dead breaker panel. Two low crate stacks sit on Dave's side and an upper cable-gantry ledge is reachable by ordinary jumps. Connection: The clear far ledge leads to A03.
L05-A03: Sorting trench. A Grenadier stands behind low cover across a broad sorting trench crossed by a wide steel catwalk. Provide two separated safe firing positions. Connection: Reach a quiet observation shelf and checkpoint, a glass supervisor gallery with a terminal at its entrance and a window over sealed Bloom test chambers.
L05-A04: Shredder catwalk. Two steel catwalk stretches cross the shredder channel, divided by solid steel plates and a refuge platform. A Gun Hound waits at the far end of the first stretch behind a low crate; the second adds a Staffer in a hi-vis vest. Connection: Exit to a stable platform at A05.
L05-A05: Rising scrap lifts. Two broad bucket-like lifts rise through a short shaft beside fixed catch ledges. A Thornwall Rifleman holds a far fixed shelf behind a low crate; one Grenadier is visible beyond the next refuge. Connection: The upper lift lands beside A06.
L05-A06: Sluice controls. A final open chamber combines one Heavy Gunner and one Gun Hound, with wide metal refuges, low crates and an obvious manual wheel. Connection: After the fight, the wheel lowers the sluice gate, and the dry passage behind a card-reader security door opens to level 6.
Use dark navy and steel masses for architecture, clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Draw low cover (0.6 H) and high cover (at least 1.2 H) as distinct shapes. Separate player paths, stable refuges, and hazards through shape as well as color, and mark where a lamp sits near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. The last area is an exit or story beat, not a boss arena. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 5, "Test Subjects". Match these materials and colors: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0, signal green #4DE38A, hazard amber #FFB02E, alarm red #FF3B4E, Bloom violet #C77DFF (test chambers only), microchip gold #FFD166. Lamp and LED colors belong to the lamp objects; the engine casts the light, so do not paint light pools or glow into the pieces.
Required asset family: Granulator drums; trench walls and sorting belts; firm steel catwalk plates; solid duct-grating patches; low crates (0.6 H) and solid hoppers or pillars (at least 1.2 H); lift buckets; conveyor-arm bridge and joints; hanging cable-root bundles; closed effluent pipes; sluice wheel and gate; dead server racks with LEDs; reforestation depot rack and launcher crates; supervisor gallery, terminal and window; sealed Bloom test chambers with plain still furnishings (no figures); a Thornwall cleanup cart, sealed drums and field desk; card-reader security door.
Separation rules: Moving lifts, the reconfigured conveyor bridge and drum scenery use separate assemblies, and the keycard door has matching closed and open states. Do not bake mist, hazard glow or blood into base textures.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows, light pools or rim light, on a flat mid-grey (or transparent) background. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. Keep floor plates plain so a blood pool can read on them later. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, painted-in blood, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
The line above sets the visual baseline for any visual suggestion; this is a written design task, not an image request.
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 5 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, each level has one optional evidence file, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, keycard placement, the enemy fairness caps (at most 2 shooters, 3 attackers and 1 heavy gun per screen, a low crate or another floor within 3 H of every machine-gun spot, the frag escape always forward, no pit edge behind a gun lane), the restrained one-scene aftermath rule, and absence of a mini-boss in this brief.
Do not silently add weapons, enemies, enemy guns, bosses, traversal skills, unearned upgrades, conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not make protected people (harmless Sleepwalkers, the staff held in the clinic, the level 11 founder, Arcadia's executives) into targets. Never add torture or execution on screen, sexual violence, children or dismemberment, and show the test chambers only as the single restrained aftermath scene described. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- The Seedlobber's delay and danger are shown before crowded use.
- Each new Thornwall role (Heavy Gunner, Grenadier, Gun Hound) is met alone before the A06 pairing, and every Heavy Gunner spot has a low crate or another floor within 3 H.
- The frag escape is always forward, and no pit edge lies within 1.5 H behind Dave in any gun lane.
- Lift jumps retain fixed catch ledges, and no gun lane covers a lift ride.
- The level ends at a sluice passage rather than inventing another mini-boss.
- The keycard is on the main route, signposted, and passed before the A03 checkpoint; the exit door tells the player when it is missing.
- The Bloom test chambers are seen on the main route through glass as the level's one authored aftermath scene: adults only, at a distance, out of every combat lane, with no faces in close view and no violence on screen.
- Bodies stay, and blood never hides a tell, a ledge or a pickup.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
