# Level 6 — Cold Storage

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../art-design/style-guide.md)).

System details are proposed in the [design pack](../design/README.md): movement, checkpoint rollback, weapon resources, microchip budgets, evidence files, keycards, single-weapon boss requirements and the enemy fairness rules (P23). Use the [AI entry guide](../AI_START_HERE.md) to find the owner before refining this level. Exact supply, evidence-file and keycard placements still need local allocation.

**ID:** L06

**Campaign group:** The Rootworks (levels 4–6)

**Renamed from:** "The Hungry Engine" (C34; the new name is proposal P22). The file was renamed from `l06-the-hungry-engine.md`.

**Status:** Detailed concept draft, updated on 2026-09-29 for the approved enemy roster (C25–C35). The weapon order, enemy introductions and mini-boss placement follow the established outline. The new enemy types are the Marksman and the Linked Lineman, and Howard Stroud now dies in his fight, speaking his own last words. Area names, layouts, encounter quantities, duration targets, checkpoints, keycard and evidence-file placements, Adam's lockdown event, the staging of the Howard Stroud fight and all new story and scenic details are *proposed* for refinement. The revamp's story names (Arcadia Dynamics, the Link, the Bloom, Howard Stroud, Thornwall) are proposals (P17); the roster is confirmed (C31) and its detailed behaviors and numbers are proposal P23; Adam (C17) and Dave Harlan (C18) are confirmed. The enemy art direction (C35) is confirmed direction, validated: the user approved the lit Night Guard test on 2026-09-30.

## Standalone context

DEAD EDEN is an original mature dark sci-fi 2D platformer shooter, not for kids (C28). Dave Harlan, an AI researcher who was fired and went rogue, breaks into the campus of Arcadia Dynamics to stop Adam, the sentient AI the company built, from launching the Bloom, a self-copying nanite weapon that kills only people. Dave travels alone (C12) and fights human enemies (Arcadia Security's guards and Thornwall's contractors), the Linked (people whose Link implants Adam drives), Adam's machines and cyborg dogs (C25, C30). Combat is lethal: every enemy bleeds according to what it is made of and stays where it falls (C28, C29). The Heirs, Adam's synthetic bodies, first appear in level 10. There is no stealth or detection system (C16). The campaign has twelve levels and unique mini-bosses only at 3, 6, 9, and 12. This is concept development, not implementation.

The cooling station that keeps Adam's cores cold, which Arcadia's own maps label Cold Storage *(proposed)*, is being strangled by Howard Stroud, Dave's former manager, whom Adam has Linked into a heavy cyborg frame wired into the pumping cycle. Thornwall's marksmen hold the approaches and field-test Arcadia's prototype rail rifle on Dave. The cores run hot and the station feeds them coolant without pause; Adam will not let it stop.

Confirmed gameplay: explore, fight, collect treasure, overcome an obstacle, reach a checkpoint, and upgrade. Microchips are the primary treasure (C19). Only one weapon is carried, and taking a new weapon drops the previous one at that pickup location. *Proposed:* each level has one optional evidence file, and each level's exit door needs that level's keycard.

## Level contract

| Field | Design |
| --- | --- |
| Main objective | Collect the Graviton Tether, learn its base capture and anchor functions, cross the cooling station past Thornwall's marksman and a Linked lineman, and defeat Howard Stroud to release the cooling pumps and take the level's keycard from the arena console. |
| Intended difficulty | Moderate |
| First successful exploration target | 17–22 minutes including mini-boss; excludes repeated failures and exhaustive secret hunting |
| New weapon | Graviton Tether |
| Weapon types introduced by level end | Scrapjack Pistol, Boom Broom, Arc Welder, Seedlobber, Graviton Tether |
| New enemy types | Marksman, Linked Lineman |
| Enemy guns first faced | Rail rifle, Thornwall RX-2 "Needle" (EG05), carried by the Marksmen; arc caster, "Groundline" (EG06), carried by the Linked Linemen and Howard Stroud |
| Mini-boss | Howard Stroud |
| Keycard (*proposed*) | Cooling-station clearance card, granted by Stroud's arena console after the fight; the service elevator to level 7 reads it. |
| Evidence file (*proposed*, optional) | EF06 **Buried Report**, in the dry pump-inspection bay ([S05](../design/03-progression/evidence-files.md)). |

## Story entry and exit

**Entry:** Enter through the dry service passage from level 5 and follow the sound of struggling pumps. Coolant pressure must be restored to open the route to the clinic.

**Exit:** Coolant pressure relaxes as Stroud dies, the pumps stabilize, and the arena console grants the level's keycard. The card opens the service elevator that carries Dave to the Arcadia Wellness Center for level 7.

Howard Stroud is a person, not a rogue machine: Dave's former manager, who dismissed the warning about Adam. Adam has "promoted" him with a Link implant and a heavy cyborg frame wired into the cooling station, and the pumps keep running their cooling cycle despite the strain. His ID badge is still clipped to his torn suit. An old shift roster and staff photograph beside the pump identify him before the fight, and the PA congratulates "Mr. Stroud" on his new role (*proposed line*). Adam drives him through the fight, and in the second phase his own voice breaks through the Link (*proposed line:* "Dave... it's in my head. Kill me before it finishes."). When the implant burns out he dies, in his own voice, and his last words are the admission that follows scene SC06 in the [story scenes](../design/05-presentation/story-scenes.md): the board ordered the weapon and told him to bury Dave's report. It is the one earned exception to the silent Link deaths.

## What the level looks like

A monumental round pump chamber combines thick steel coolant pipes, teal-lit valve housings, and amber-lit service platforms. Heavy cable bundles wrap the machinery like ropes, and the cold lines wear a rime of frost. Beyond thick glass, rows of Adam's cores glow teal, and the walls around them blink with teal and green status LEDs. The reservoir below is dark water that reflects amber instrument lamps and the red flash of emergency strobes; it is visibly unsafe machinery space, not an inviting swim route. Cooling mist is drawn as flat, low-contrast bands near the pipes. Thornwall's marksmen hold raised perches with long, lit sight lines, and the electricians of the station's Linked crew still work the floor.

**Palette and lighting:** near-black #07090F for the reservoir depth, deep navy #0E1726, steel #1C2A3A and slate #2E3B4E for pipes and housings, Arcadia teal #3FE0D0 for core glow and valve lights, signal green #4DE38A for status LEDs, hazard amber #FFB02E for service-platform lamps and pressure pre-warnings, alarm red #FF3B4E for strobes and the final slam warning, dark coolant teal #0F3D48 for the water, microchip gold #FFD166 for pickups. Light is smooth, realistic engine light cast by the lamps, LEDs and strobes in the scene (C35): keep platform tops lit, with a light near every landing and every source visible in the scene, keep pressure-warning ripples bright enough to read, and paint no light pools into the scenery. Blood (#B3212F, drying to #8A1A26) reads on the steel decks; machine oil is #14181E with a #46566A sheen rim. *(Signal green, dark coolant teal and all level-specific uses are proposed.)*

**Navigation landmark:** A huge three-lobed pump housing sits beyond the route, pulsing unevenly under four thick coolant cables connected to Stroud's frame; behind glass to one side, Adam's cores glow teal.

## Foreground, playable plane, and background

- **Foreground framing:** Thin pipe collars and a few dangling cable ends near the edges. Never cover the waterline, safe ledges, anchor markers or blood on the deck.
- **Playable plane:** Fixed pipe catwalks, broad service shelves, a safe freight training bay, a long valve walk with fixed cover pieces, and the boss's three raised central platforms with permanent side ledges. Blood pools sit on static floors only, never on an arena platform that can rise or lower.
- **Background depth:** The pumping machinery, reservoir wall, large intake pipes, glass-walled core racks glowing teal, and the inert supporting structure around Stroud. Background depth is for scale; player movement stays on the side plane.

The camera stays aligned to the side-view action plane. Apparent depth is visual layering, not an unannounced move into a third gameplay axis. Frame the destination before committing to a jump; avoid hiding attack origins, landings, and recovery routes behind decoration, mist or darkness.

## Main route

```text
A01 Reservoir approach → A02 Freight training bay → A03 Lineman hall → A04 Valve walk → A05 Pump refuge → A06 Stroud arena.
```

The route lists ordered areas, not exact world coordinates. Each area may span more than one camera view. Use a provisional hero height H = 1.70 m for art scale only. Final gaps, jump heights, run speeds, and hazard timings must be tuned later; no mandatory section assumes double jump, dash, wall run, swimming, or an unlisted tool.

## Area-by-area design

### L06-A01 — Reservoir approach

**Space and placement:** A dry corridor opens onto a safe catwalk with a clear view of the pumps and, beyond glass, Adam's cores. One Staffer, a Linked technician in workwear, works a broad shelf; it is a returning type, alone.

**Player experience and lesson:** Establish the destination and pressure pulses without dropping a new heavy enemy into a confined passage. The Staffer never blocks the shelf: Dave can jump past it.

**Completion and connection:** Follow a cargo sign to A02.

### L06-A02 — Freight training bay

**Space and placement:** The Graviton Tether is placed on a cargo-control pedestal in the Rootworks freight bay. Provide a small loose crate, a padded throw target, and a marked anchor over a shallow catch floor. A powered-down Freight Loader stands parked at the bay's edge, and a lone Security Drone patrols over the far side of the bay.

**Player experience and lesson:** Practice capturing and throwing a loose object, then pulling to a designated anchor. The lone Security Drone, a small enemy, can be captured after the tether's short lock and outside its dive, as an optional practice target; human-sized enemies such as the Staffers cannot be captured at base grip. Base grip cannot lift heavy targets either: aim the tether at the parked Freight Loader and it visibly refuses, an established size cue. Taking the tether leaves the previous weapon on the ground at the pedestal, so a safe swap back remains available before leaving.

**Completion and connection:** Exit by a normal service ramp; training can be retried without consuming a unique item.

### L06-A03 — Lineman hall

**Space and placement:** One Linked Lineman occupies a wide chamber with two fixed side platforms and open overhead clearance: a Rootworks electrician with cables sutured into his forearms and a capacitor pack on his back. He is alone.

**Player experience and lesson:** Show his tell: the capacitor glows amber, then red with a buzz, he rams the rod into the deck, and an arc crawls along the floor at Dave. Jump the arc, or stand on a side platform (it cannot leave its floor), then hit him while the rod recharges. This is Stroud's rehearsal: the same arc returns in the boss fight. He never blocks progress, and if he dies he dies mostly silent, the light just gone.

**Completion and connection:** A quiet recovery station saves before A04.

### L06-A04 — Valve walk

**Space and placement:** A long valve walk, broad, with a wall or railing behind Dave's standing spots (never an open pit edge within 1.5 H), runs toward a step-up perch at its far end that Dave can reach by ordinary jumps. Cover pieces (low valve housings and crates of 0.6 H, plus one pillar) stand at most 8 H apart along the approach, and every sight line along the walk is flat. In the first stretch one Marksman watches alone from the perch. In the second stretch a Linked Lineman holds a mid shelf, its arc lane crossing the last cover pieces. Two Marksmen are never on one screen.

**Player experience and lesson:** Teach the rail as an advance fight: a thin sight line tracks Dave as three capacitor rings light, freezes and holds amber for a moment, turns red for the last 0.25 s, then an instant slug hits the first wall or Dave for 2 damage, followed by a rooted recharge of about 2.2 s. Keep moving so you are off the line at the freeze, and advance one cover piece per recharge; shoot the Marksman from his reachable perch. The second stretch combines two familiar patterns: the Marksman watching from far away while the Lineman sends arcs along the floor, so even the ground is dangerous. Dave jumps the arc (a held jump clears it in a fraction of a second) and never crosses the line at the freeze. A retreat to the last cover piece is always open.

**Completion and connection:** A stable ramp leads to A05.

### L06-A05 — Pump refuge

**Space and placement:** A sheltered pump-maintenance station with a recovery station and workbench gives a full view of the three-platform arena and its permanent side ledges. A small deck panel demonstrates a visible pressure ripple before it moves. An old shift roster and staff photograph on the wall identify the person wired into the pump.

**Player experience and lesson:** Preview floor movement and save before the fight. All five weapon types have now been introduced, but Dave still carries only the chosen weapon. Upgrades are optional.

**Completion and connection:** Enter A06 when ready.

### L06-A06 — Stroud arena

**Space and placement:** Three central platforms sit above the reservoir, with permanent left and right recovery ledges. Clearly marked tether anchors offer quick crossing; an ordinary-jump route connects all safe positions. The right ledge leads to the service elevator door, with a control console beside it that stays dark until the fight ends.

**Player experience and lesson:** Keep changing platforms while finding shots: leave the platform the warning lamp marks before the cable-arm slam, jump the ground arcs (or stand on another platform), and shoot the chest implant while he kneels and while he vents.

**Completion and connection:** After victory, the arena console grants the level's keycard and Dave releases the cooling pumps at it, after Stroud's last words. Dave then takes the service elevator to the Wellness Center; its door reads the card.

## Adam's lockdown event

*(Proposed event.)* Adam runs the cooling station's pumps on a load cycle that raises and lowers selected floor sections, announced over the speakers (*proposed line:* "Coolant cycle beginning. Please keep clear of the floor."). First demonstrate this away from combat, on the small deck panel at A05. Each move is telegraphed by the panel's pressure lamp turning amber, then red, and by rising pressure ripples in the coolant. The same cycle at full scale raises the three arena platforms into place as Dave enters A06, with advance cable tension, ripples and a visible destination, and it never moves a platform under an occupied position. Once the fight starts the arena does not change, in either phase.

Moving elements need a visible warning, a readable destination, and a valid recovery route. An occupied refuge must not be sealed by an unannounced transformation. The described event is authored and fires at a fixed point, not when Dave is spotted (C16); it is not an instruction to randomly rearrange the entire level.

## Enemy use and encounter pacing

The Linked Lineman (A03) and the Marksman (A04) are taught separately, each alone, before they combine on the last stretch of the valve walk. The boss arena contains no extra enemies. The tether is an option for mobility, never a method to grab Stroud, and heavy targets visibly refuse it. Returning types (Sidearm Guards, Riot Officers, Riflemen, Heavy Gunners, Grenadiers, Gun Hounds, Patrol Rovers, Security Drones, Sentry Turrets, Freight Loaders and Staffers) may hold optional side lanes, but not the introduction encounters.

The rail is the only gun that may fire from a long way off, and rail fights are advance fights: cover at most 8 H apart on the approach, a perch Dave can reach, a flat or steeper-than-45-degree line, and at most one rail on a screen. The arc is 0.4 H tall, crawls along the floor at about 5 H/s, dies at a ledge, a wall or about 6.5 H, and cannot leave its floor, so jumping it or standing on another platform both work. Every tell reads through the reserved colors, always amber first and red for the last 0.25 s: the Marksman's sight line and rings, the Lineman's capacitor and Stroud's cable glow, the slam lamp. Shooters fire only when at least 1 H inside the camera edge, never at an airborne Dave, and enemy projectile hits use half knockback.

Combat is lethal (C28) and visible (C29). Thornwall men and the Linked bleed red, and the Linked also throw white sparks at the implant; most Link deaths are silent. Bodies stay where they fell, restored as static corpses after a death or a Continue, and a dead gunner's weapon falls as a prop, never a pickup. Blood pools sit on static floors only and never hide a tell, a ledge or a pickup. Keep landings, pickups and the arena console clear of likely body positions. A corpse is not cover.

Placement rules used here (P23): at most 2 shooters, 3 attackers and 1 heavy gun per screen (the A04 pairing is a Marksman and a Lineman, one heavy gun), no pit edge within 1.5 H behind Dave's standing spots in a gun lane, the camera shows a gun's muzzle and its lane before it fires, and the Linked never block progress. The rules are owned by [encounter and boss fairness](../design/04-world/encounter-and-boss-fairness.md).

- [Staffer](../art-design/linked/lk01-staffer.md) — established behavior or returning type.
- [Security Drone](../art-design/machines/m02-security-drone.md) — established behavior; here the tether's optional small-enemy practice target.
- [Freight Loader](../art-design/machines/m04-freight-loader.md) — established behavior; here only as a powered-down prop, the tether's size cue.
- [Linked Lineman](../art-design/linked/lk02-linked-lineman.md) — first introduction in this level.
- [Marksman](../art-design/thornwall/tw03-marksman.md) — first introduction in this level.
- [Rail rifle, RX-2 "Needle" (EG05)](../art-design/enemy-guns/eg05-rail-rifle.md) — first faced in this level.
- [Arc caster, "Groundline" (EG06)](../art-design/enemy-guns/eg06-arc-caster.md) — first faced in this level, on the Linemen and on Stroud.

## Single carried weapon and progression

- [Scrapjack Pistol](../art-design/weapons/w01-scrapjack-pistol.md)
- [Boom Broom](../art-design/weapons/w02-boom-broom.md)
- [Arc Welder](../art-design/weapons/w03-arc-welder.md)
- [Seedlobber](../art-design/weapons/w04-seedlobber.md)
- [Graviton Tether](../art-design/weapons/w05-graviton-tether.md)

The list above records weapon types introduced by this point, not a carried inventory. Dave carries exactly one weapon. Choosing a new pickup drops the previous weapon at that same spot; a safe trial lets the player swap back before leaving. There is no backup pistol, inventory cycling, or checkpoint armory. The Graviton Tether occupies this same slot. Main routes remain usable without it, and mandatory encounters support the legitimately carried weapon, with replenishable throwable props for tether combat, close approach positions for short-range guns, and usable fuse windows for the Seedlobber. Optional upgrades are not required. See [Core gameplay rules](../core-gameplay.md) for the confirmed decisions and separately labeled economy and persistence proposals.

## Checkpoints, failure, and recovery

- After the A02 tether trial; save the single weapon chosen before leaving.
- After A03, before the valve walk.
- At A05 immediately before Howard Stroud, a boss-preparation workbench checkpoint *(proposed)*.
- After Stroud's death and the console interaction, as a story checkpoint that commits the released pumps and the keycard at once.

Working checkpoint proposal: retry restores the single carried weapon and world pickup state saved at the checkpoint, with useful resources for that weapon and completed story objectives preserved. The snapshot also records the microchip wallet, evidence files and the level's keycard. Nothing threatens Dave once the fight ends, and the victory commits the keycard granted by the console. It does not recover a gun abandoned elsewhere or grant a second gun. Local enemies, hazards, and moving geometry reset coherently, and bodies of enemies that were already killed are restored as static corpses; swapped weapons and collected microchips, evidence files and keycards must not duplicate. Practice sections retain the described catch ledges. Exact health, ammunition, death penalties, and dropped-weapon persistence across level changes remain undecided.

## Optional exploration and rewards

Microchips are the primary reward in this level. They are hand-placed in caches and alcoves; enemies drop nothing *(proposed)*, and values and prices follow the treasure economy proposal. The level's evidence file is an additional optional discovery: a memo, recording or log that proves what Arcadia or Adam did. It goes in the journal, has no stat effect, and never gates the exit or the ending ([evidence files](../design/03-progression/evidence-files.md)). Ordinary scenery and story information the player needs on the main route do not automatically become evidence files. Spending microchips at checkpoint workbenches is the working economy proposal.

- A marked optional anchor loop near A02 leads to microchips; optional pulls fit base tether reach, and the main route remains open without the tether.
- *Evidence file (proposed):* EF06 **Buried Report** ([S05](../design/03-progression/evidence-files.md)), a thick spiral-bound printout with a torn cover, a lanyard clip and a "hold" tab. In the dry pump-inspection bay, reachable before or after the fight, a locker holds Dave's original safety report, stamped "hold" with Stroud's initials and a note to wait until the contract closes. It supports what Stroud says with his last words, names no board member, and never replaces his spoken admission, which stays on the main route.

Optional paths rejoin the main route without requiring a new movement ability or a future weapon. Mark a cache or intriguing shape from the main path before asking the player to explore; do not hide required progression behind an arbitrary wall shot. The keycard and all story information the player needs stay on the main route; no keycard sits in an optional branch or an evidence-file alcove.

## Sound and atmosphere

A deep uneven pump heartbeat, stressed pipe creaks, slow coolant motion, and steel-cable tension whines preceding cable-arm slams. Separate the slam warning (a rising tone with the pressure ripples and the lamp) from ordinary ambient creaking. The Marksman's rail is a three-step capacitor whine, then a hard crack with a ringing tail; the Lineman's capacitor buzzes as it charges and snaps when the arc dies. Adam's calm PA voice comes between the pump beats. Stroud's own voice, when it breaks through, is plainly human, not processed. Hits land with restrained wet impacts (C28).

## Mini-boss encounter — Howard Stroud

**Identity:** Dave's former manager, "promoted" by Adam into a 3.60 m heavy maintenance cyborg frame, clamped in place and wired into the cooling station, with two cable arms, four main anchor cables, a capacitor rack that carries the arc caster, and a chest implant behind two covers that open while he kneels or vents. His ID badge is still clipped to his torn suit. He is Linked. *(Design details are proposed.)*

**Arena geometry:** Three central platforms plus permanent side ledges. A lamp and pressure ripples warn over and below the individual target platform. Anchor shortcuts and calibrated basic-jump routes coexist.

- Phase 1, slam: the lamp over the nearest platform goes amber, then red, then a cable-arm slam up through it (2 damage), and he kneels with the chest implant open for about 1.5 s.
- Phase 1, ground arc: he spikes the cable into the deck as the capacitor goes amber, then red, and two arcs crawl both ways along that platform. Dave jumps them or stands on another platform. He then vents for about 1.2 s with the implant open.
- Phase 2 (at half health): his own voice breaks through the Link, and the slam and the arc chain together. Only the amber part shortens; red stays 0.25 s. A connected safe route always remains.

**Damage opening:** The chest implant, open while he kneels after a slam and while he vents after the arc. At least one stable ledge has a direct firing line for the pistol.

**Fairness and recovery:** A slam is warned over one platform at a time and can never strike every platform at once; an arc cannot leave the platform it starts on; no attack is unavoidable while airborne; and nothing depends on tether upgrades. No arc or slam starts while an earlier shot of his is still alive. Restore arena geometry on retry.

**Victory consequence:** A hand-placed microchip cache opens in the arena (kills drop nothing), the coolant pressure is released, and the level's keycard comes from the arena console. The implant burns out with a flash and white sparks, and Stroud slumps in the dark cable frame as it goes slack. His own voice is back for the last moment, and his last words are the admission (*proposed line:* "The board ordered it, Dave. They told me to bury your report. I should have listened."), spoken after the final hit and before the console wakes. His body stays in the frame. The route to the clinic opens.

[Full boss appearance, abilities, and sprite reference](../art-design/mini-bosses/b02-howard-stroud.md).

## Environment asset kit and layer separation

**Required kit:** Pump housing; pipe straight and elbow modules; pressure windows; dry service catwalks; cargo training pedestal; marked anchor props; loose crate; a parked, powered-down Freight Loader (inactive prop); valve platforms and the valve walk with fixed cover pieces (low housings and crates of 0.6 H, one pillar); the Marksman's step-up perch; two fixed side platforms for the Lineman hall; reservoir wall; glass-walled core racks (background); three movable arena decks; permanent refuge ledges; arena console and service elevator door with a card reader.

**Separate objects:** Stroud's body and four anchor cables are distinct from pump and arena layers. Keep moving platforms independent and mark collision surfaces clearly. Coolant and warning ripples are separate effects, and the keycard door has matching closed and open states. Deck plates stay plain enough that a blood pool reads on them.

Draw the largest architectural silhouettes first, then separate moving parts and props. Record pivot intent for rotating, sliding, lifting and opening elements. Plan repeatable illustrated tiles or modules for floors, rails and corridors; keep unique landmarks separate. Keep foreground, playable, background and effects on distinct drawing layers; lamps, LEDs and strobes are engine lights. Final sprite resolution, atlas layout, animation method, file format and collision setup remain undecided.

## Constraints for another AI model

No machine conversion, grab-able boss, swimming section, mandatory Long Reach upgrade, or all-platform collapse. Do not introduce the tether for the first time inside the boss fight. Stroud dies in the fight itself, never in a staged execution, and his death is restrained: no dismemberment, no torture, no exposed organs, and his own voice. No other Arcadia executive appears as a target. Nothing here shows sexual violence, children, or blood and bodies painted into the final scenery (blood is added in the engine).

Preserve the established number of levels, the 24-type enemy roster (C31), weapons, and upgrades. Show only one weapon carried by the hero; do not place spare guns on their belt or back. Any new enemy, boss, movement ability, inventory system, or ending would be a proposed change, not an automatic addition. Do not treat decorative background elements as reachable platforms. Use placeholders if a character reference is unavailable rather than redesigning the character inside environment art. Do not add stealth, vision cones or alert states (C16).

## Prompt 1 — environment keyframe

Copy this block directly into an image generator. It requests one representative environment view, not the entire level compressed into a single picture. Use the linked character briefs if detailed characters are needed (no enemy design is selected yet; all are proposed); otherwise keep them as small scale silhouettes.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
This is environment concept art and a lighting reference. Use separate illustrated foreground, playable and background layers with decreasing background contrast; depth comes from overlap and optional parallax. Paint steel, glass, cable and machinery as clean, flat base colors with dark outlines and simple material marks so they can be split into modules. Because this is a mood reference, show the chamber as smooth, realistic light from the lamps, LEDs and strobes in the scene, with a light near every landing; the final scenery is painted without baked light pools or shadows, and the engine adds the lighting. Preserve the level-specific palette and mood, and keep playable surfaces, enemies, attack lanes, landings and pickups readable in the dark. No photorealism, glossy chrome, pixel art or franchise assets. Blood appears only as a few restrained floor stains (#B3212F, drying to #8A1A26), never on the architecture, and there are no bodies; the final scenery carries none, because the engine adds blood.

Create one wide 16:9 environment keyframe for level 6, "Cold Storage".
Narrative purpose: The cooling station that keeps Adam's cores cold is being strangled by Howard Stroud, Dave's former manager, whom Adam has Linked into a heavy cyborg frame wired into the pumping cycle.
Physical setting: A monumental round pump chamber combines thick steel coolant pipes rimed with frost, teal-lit valve housings, and amber-lit service platforms. Heavy cable bundles wrap the machinery like ropes. Beyond thick glass, rows of Adam's cores glow teal, and the walls around them blink with teal and green status LEDs. The reservoir below is dark water that reflects amber instrument lamps and the red flash of emergency strobes; it is visibly unsafe machinery space, not an inviting swim route.
Color and lighting: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0 for core glow and valve lights, signal green #4DE38A for status LEDs, hazard amber #FFB02E for service-platform lamps, alarm red #FF3B4E for strobes, dark coolant teal #0F3D48 for the water, microchip gold #FFD166 for a few pickups. Keep platform tops lit and pressure-warning ripples bright enough to read.
Landmark: A huge three-lobed pump housing sits beyond the route, pulsing unevenly under four thick coolant cables connected to Stroud's frame; behind glass to one side, Adam's cores glow teal.
Composition to show: A wide side-view pump arena with permanent ledges at both ends, three central platforms over dark coolant, clear tether anchors above, and Howard Stroud, a middle-aged manager in a torn suit with an ID badge, fused into a heavy cyborg frame beside the cable-bound pump, his chest implant faintly glowing. Include a small silhouette of Dave in a burnt-orange jacket on the left ledge for scale.
Foreground: Thin pipe collars and a few dangling cable ends near the edges. Never cover the waterline, safe ledges, or anchor markers.
Playable plane: Fixed pipe catwalks, broad service shelves, a safe freight training bay, a long valve walk with low cover pieces, and the boss's three raised central platforms with permanent side ledges.
Background: The pumping machinery, reservoir wall, large intake pipes, glass-walled core racks glowing teal, and the inert supporting structure around Stroud. Background depth is for scale; player movement stays on the side plane.
Show only this level's appropriate threats: Staffer, Security Drone, Linked Lineman, Marksman; mini-boss Howard Stroud only if this is his arena scene. Keep the number of characters low and their poses subordinate to environment readability. The scene illustrates a designed playable space, with clear landing edges and room for movement. Do not imply unlisted abilities.
Exclusions: No machine conversion, grab-able boss, swimming section, mandatory Long Reach upgrade, all-platform collapse, dismemberment, exposed organs, bodies, or more than a few restrained blood stains on the floor. Do not introduce the tether for the first time inside the boss fight.
Use a fixed side-oriented gameplay camera with depth suggested by overlapping illustrated layers, clear separation of foreground and background, no UI, no watermark, no text or logos (signage as blank glowing shapes), no forced cinematic angle, and no effects obscuring the route.
```

## Prompt 2 — side-elevation layout study

This is a conceptual spatial study. Generated art cannot verify jump distances or collision; reconcile it with the written route and a later movement blockout.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Design a clean side-elevation level-layout study for level 6, "Cold Storage". Keep a single 2D gameplay plane inside layered 2D scenery. Main route: A01 Reservoir approach → A02 Freight training bay → A03 Lineman hall → A04 Valve walk → A05 Pump refuge → A06 Stroud arena.
Use six adjacent panels, one for each area, or generate them individually if the full sheet loses clarity. Each panel must preserve its entry and exit direction; explicit local vertical movement may be shown. Space descriptions:
L06-A01: Reservoir approach. A dry corridor opens onto a safe catwalk with a clear view of the pumps and, beyond glass, Adam's cores. One Staffer works a broad shelf. Connection: Follow a cargo sign to A02.
L06-A02: Freight training bay. The Graviton Tether is placed on a cargo-control pedestal. Provide a small loose crate, a padded throw target, and a marked anchor over a shallow catch floor, with a powered-down freight loader parked at the edge and a lone security drone over the far side. Connection: Exit by a normal service ramp; training can be retried without consuming a unique item.
L06-A03: Lineman hall. One Linked Lineman occupies a wide chamber with two fixed side platforms and open overhead clearance. Connection: A quiet recovery station saves before A04.
L06-A04: Valve walk. A long broad valve walk with low cover pieces at most 8 H apart runs toward a step-up perch where one Marksman watches; a Linked Lineman holds a mid shelf in the second stretch. Connection: A stable ramp leads to A05.
L06-A05: Pump refuge. A sheltered pump-maintenance station gives a full view of the three-platform arena and its permanent side ledges. A small deck panel demonstrates a visible pressure ripple before it moves. Connection: Enter A06 when ready.
L06-A06: Stroud arena. Three central platforms sit above the reservoir, with permanent left and right recovery ledges. Clearly marked tether anchors offer quick crossing; an ordinary-jump route connects all safe positions. Connection: After victory, the arena console grants the level's keycard and releases the pumps, and the service elevator to the Wellness Center opens.
Use dark navy and steel masses for architecture, clean, evenly lit top edges for playable surfaces, muted low-contrast noninteractive background shapes, small human scale silhouettes, and visible supports for moving platforms. Draw low cover (0.6 H) and high cover (at least 1.2 H) as distinct shapes. Separate player paths, stable refuges, and hazards through shape as well as color, and mark where a lamp sits near every landing. Do not invent measured physics values. No decorative clutter, text generated inside the picture, impossible perspective, overlapping panels, extra level, or unlisted boss. Boss arena requirements: three central platforms plus permanent side ledges. A lamp and pressure ripples warn over and below individual target platforms. Anchor shortcuts and calibrated basic-jump routes coexist. The written brief remains authoritative if the generated image contradicts it.
```

## Prompt 3 — modular environment asset sheet

After approving an environment keyframe, attach it to preserve the visual language. Request smaller subsets of the kit if a single sheet becomes crowded.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
Using the attached approved environment keyframe, create a clean modular environment asset reference sheet for level 6, "Cold Storage". Match these materials and colors: near-black #07090F, deep navy #0E1726, steel #1C2A3A, slate #2E3B4E, Arcadia teal #3FE0D0, signal green #4DE38A, hazard amber #FFB02E, alarm red #FF3B4E, dark coolant teal #0F3D48, microchip gold #FFD166. Lamp and LED colors belong to the lamp objects; the engine casts the light, so do not paint light pools or glow into the pieces.
Required asset family: Pump housing; pipe straight and elbow modules; pressure windows; dry service catwalks; cargo training pedestal; marked anchor props; loose crate; a powered-down freight loader; valve platforms and the valve walk with low cover pieces; a step-up perch; two fixed side platforms; reservoir wall; glass-walled core racks; three movable arena decks; permanent refuge ledges; arena console and service elevator door with a card reader.
Separation rules: Stroud's body and four anchor cables are distinct from pump and arena layers. Keep moving platforms independent and mark collision surfaces clearly. Coolant and warning ripples are separate effects, and the keycard door has matching closed and open states.
Draw complete individual 2D objects with clear gaps, consistent canvas scale, clean dark outlines and flat base colors, evenly lit with no baked shadows, light pools or rim light, on a flat mid-grey (or transparent) background. Prioritize gameplay side views; include a separate moving-part drawing only where a mechanism needs explanation. Show fixed and moving components separately without inventing internal engineering. Keep deck plates plain so a blood pool can read on them later. No character redesigns, combined scene collage, text labels, logos, UI, watermark, heavy weathering, painted-in blood, or tiny decorative noise. Keep all playable contact surfaces clean and identifiable. This is art reference for later 2D asset production, not a technical fabrication drawing.
```

## Prompt 4 — AI design handoff

Paste this block together with this entire level brief. The file is standalone; attach the linked asset briefs when asking for detailed enemy or weapon visuals.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.
The line above sets the visual baseline for any visual suggestion; this is a written design task, not an image request.
Act as a game concept designer working on DEAD EDEN. Use the complete attached level 6 brief as the current design specification. The project is in idea development, not implementation: do not write engine code or choose a technology stack. Enforce one carried weapon and ground swaps; microchips are the primary treasure, each level has one optional evidence file, and each level's exit door needs its keycard. Do not add a backup pistol or require a weapon the player left behind.
Explain this level as a player journey in the exact six-area order given. For every area describe the visible space, what the player does, the enemy or hazard warning, the intended skill lesson, a valid recovery option, and how progress to the next area is recognized. Separate established campaign constraints from any new suggestions. Then produce an environment asset checklist, a short cinematic-free story beat list, and a consistency review against the weapons, enemy introduction order, checkpoint rules, keycard placement, the enemy fairness caps (at most 2 shooters, 3 attackers and 1 heavy gun per screen, rail fights with cover at most 8 H apart and a reachable perch, no pit edge behind a gun lane), and mini-boss phases in this brief.
Do not silently add weapons, enemies, enemy guns, bosses, traversal skills, unearned upgrades, conversion mechanics, stealth or detection systems, new endings, or off-plane combat. Do not make protected people (harmless Sleepwalkers, the staff held in the clinic, the level 11 founder, Arcadia's executives) into targets. Never add torture or execution on screen, sexual violence, children or dismemberment. Where physics values, numerical balance, or implementation details are absent, mark them as undecided instead of inventing final values. Preserve the written route if generated art suggests contradictory geometry.
```

## Review criteria

- All five weapon types have been introduced by the end of this level; only one is carried.
- Tether practice is safe and precedes the fight, and heavy targets visibly refuse it.
- The Linked Lineman and the Marksman are each met alone before they are combined, and the Marksman's approach has cover at most 8 H apart and a perch Dave can reach.
- A base-jump escape route survives every boss platform state, and an arc never leaves the platform it starts on.
- The cooling station's machinery stays plain machinery: no machine is "converted". Stroud dies in his own voice, with restrained blood and no exposed organs, and his last words are the admission.
- The keycard comes from the arena console after the fight, and Stroud's admission follows the fight rather than interrupting it.
- Bodies stay, and blood never hides a tell, a ledge or a pickup.

- All six areas have a readable entry, purpose, safe response, and exit.
- Moving geometry and attack sources are visible before commitment; effects do not hide platform edges.
- Checkpoints preserve earned tools and completed story beats without duplicating rewards.
- Art references match the text and the current enemy and weapon briefs (designs are proposed until selected).

[Level index](README.md) · [Shared level design guide](design-guide.md) · [Game concept](../dead-eden-concept.md) · [Visual style guide](../art-design/style-guide.md)
