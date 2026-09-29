# The Surgeon — Arcadia's Implant Theater Robot

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** B03\
**Category:** mini-bosses\
**First appearance:** Level 9\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). The Surgeon's identity, name, appearance and palette are *proposed* (C31, P23), and no image is approved yet. Its fight follows the approved roster (P23). Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Third mini-boss; *proposed:* the surgical robot of the Arcadia Wellness Center's implant theater, where staff are fitted with Link implants. It hangs from a ceiling rail over the theater floor and treats any attempt to leave before the procedure as a medical emergency. It is entirely mechanical, with no human parts and no Link of its own. Its weapons are a cutting laser (the Cutter Beam, [EG09](../enemy-guns/eg09-cutter-beam.md)) and an injector dive.

The staff held for fitting are protected, never targets: they sit restrained behind glass in the holding bays, off the combat plane, alive. Freeing them after the fight is the level's rescue beat and opens the way onward. The fight teaches Dave to dodge a big overhead threat and punish it when it comes low: keep moving so you are off the sight line at the freeze, use overhead cover, then punish the open lens, or the core while the Surgeon hangs low.

## Scale and silhouette

3.00 m body height from the hood to the injector tips; up to 4.40 m span with the laser arm fully extended. The chest core sits about 1.55 m above the injector tips, so when the injectors touch the floor in the dive the open core hangs at Dave's head height.

An upright teardrop torso hanging from a telescoping three-segment hoist column under a carriage on the overhead rail, with a hooded head of three lamp discs, one long slim jointed laser-scalpel arm, two short folded clamp arms and a cluster of three injector barrels hanging from its underside. Its silhouette resembles a pale, tidy surgical workstation.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

The head is a smooth hood carrying three round surgical lamp discs in a vertical row: no eyes, mouth or face shapes. The torso is seamless porcelain-white ceramic with dark joint collars, and a round chest door in three iris leaves covers the core. The laser-scalpel arm on the anatomical right has three slim segments and ends in a wrist socket for the Cutter Beam's petal cowl (a single lens in a small ceramic cowl of eight petals that opens like a flower, drawn separately as EG09). The two short padded clamp arms fold flat against the anatomical left side and never attack. Under the torso hangs a padded housing with exactly three long needle barrels. The hoist column is three nested segments under a carriage with two rail wheels; the rail itself is arena environment. Small steady status lights sit on the torso.

The theater's cleanliness is the horror: the shell is spotless except for scuffs at the joints and a faint scorch where the beam cowl sits.

## Color and materials

Base colors are flat and unlit (C35). Cool porcelain #D5DDE3 (*proposed*) for the torso, hood and iris leaves, and the Garden's cool ceramic #D8DEE3 for the cowl (see EG09, so it reads as Adam's addition); dark joint collars and the rail carriage #1C2A3A; slate #2E3B4E for the hoist column and clamp pads; small, steady signal green #4DE38A for the torso status lights (never a tell); a small teal #3FE0D0 carriage light. The lamp discs, the lens ring and the sight line are drawn dark or unlit; the engine adds their amber #FFB02E, then alarm red #FF3B4E, glow as tells only. The open lens and the open core glow hot white, never amber or red. The beam itself follows EG09: a white core with a #5AA9FF edge. Fluid is black oil #14181E with a #46566A sheen rim, plus white sparks. There is no blood. Draw the porcelain as flat pale shapes and keep everything else dark; nothing washed out.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Two attacks and one phase change. No summoned enemies.

- **Cutting laser:** the Surgeon slides along its rail and the lens cowl opens. A sight line tracks Dave at 3 H/s, freezes and holds amber for 0.3 s, and turns red for 0.25 s. The beam then drags after him at 2 H/s for 1.2 s and hits at most once per firing (1 damage). Dave keeps moving, or stands under a steel instrument shelf (at least 1.1 H of headroom). The lens then hangs open for 1.5 s.
- **Injector dive:** the hood lamps glow amber, then red for the last 0.25 s, and the spot is locked. The hoist then drops the Surgeon onto Dave's locked spot, the needles stab the deck there, and it hangs at head height for 2 s with the core open.
- **Phase 2 (below 50%):** laser and dive chain together (amber x0.7; red stays 0.25 s), and the restrained staff in the holding bays (protected, no hit zone) turn their heads to follow Dave.

It hangs still on the rail with its arms folded and its lamps dark. The carriage hums along the rail, the cowl petals click open one after another, and the scalpel arm extends smoothly with no wasted motion. The dive is a pneumatic hiss and a heavy thunk; the core iris then opens leaf by leaf. Sounds are *proposed*: the rail hum, petal clicks, EG09's sizzling hum, the hiss and the thunk. As the staff's heads turn there is only a cloth-and-strap creak.

## Openings and limitations

The lens cowl, open for 1.5 s after the beam, and the chest core behind the open iris door, open for 2 s after the dive. The armor elsewhere deflects shots with sparks. Both side views must show each opening so a player on ordinary platforms can see and hit it; the hot-white glow makes the target read in the dark.

**Death:** the rail carriage jams and the hoist gives. The torso drops and bursts into parts, the laser arm falls with its petals closing, the lamp discs go dark, and black oil and sparks spill. The cowl falls with the debris. The holding bays' locks release.

## Rig parts, normal maps and sockets

All parts are rigid. Every part gets a matching normal map (green = up), so the theater's surgical lamps, the beam and the muzzle flash light the Surgeon smoothly. Keep the iris leaves and the lamp discs radially symmetric where they rotate, so turning them never turns their lit side.

- **Rail carriage:** slides along the arena rail (the rail is separate environment); two rail wheels, and a carriage body with a small teal light.
- **Hoist column:** three nested segments that telescope for the dive.
- **Torso** (root part, pivot at the top of the hoist): the porcelain shell; the chest core (with its own hot-white glow layer) and three iris leaves with pivots at the outer rim.
- **Hood:** three lamp discs, each on its own layer for the amber, then red, tell glow.
- **Laser-scalpel arm:** shoulder, elbow and wrist pivots.
- **Gun socket, scalpel wrist:** the EG09 cowl mounts here as a two-frame swap (closed, open). Its origin is the wrist mount, its muzzle marker sits at the lens center, and its flash light follows EG09. It is mounted high only. Drawn without the gun; on death it falls with the debris.
- **Clamp arms:** two short arms with shoulder and elbow pivots.
- **Injector cluster:** the padded housing plus three needle barrels that slide out and back.
- **Fluid:** black oil #14181E with a #46566A sheen rim, plus white sparks, as overlay layers attached to the hit part.
- **Debris on death:** the hood and lamp discs, torso halves, iris leaves, arm segments, clamp arms, injector housing and needles, and hoist segments become physics bodies in a burst. The carriage stays on the rail.

## Required pose and state references

Neutral hanging on the rail (arms folded, lens closed); sliding along the rail; lens opening; sight line tracking; freeze and hold; beam; lens hanging open; dive windup (lamps amber then red); dive; hanging at head height with the core open; phase-two chain; hit reaction; wreck.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment. Draw lamps and the lens as flat bright shapes with no halo, since the engine adds the glow.

## Consistency rules

One laser-scalpel arm with a single lens, two folded clamp arms, one injector cluster of exactly three needle barrels, three lamp discs and one three-leaf chest door. No legs, no face, no eyes or mouth, and no human parts or Link hardware on its body. No injection of a person is ever shown: the needles stab the deck. The held staff are protected, have no hit zone and stay off the combat plane. Amber and red appear only as tell glows; the signal-green status lights are small and steady and never a tell; the open lens and core are hot white. No blood: machine fluid only. Keep the gun socket empty in the base art.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view. Here the laser arm is on the right and the folded clamp arms are on the left. Those arms are separate parts, so the rig can swap which is nearer the camera when it mirrors for left-facing play. The torso, hood and injector cluster are safe to mirror.

## Single-weapon encounter constraint

The hero carries only one weapon. This fight must support every weapon type that can legitimately reach this level. A clear Scrapjack shot is only one case: provide safe close-range access for the Boom Broom or Arc Welder, workable arcs and fuse windows for the Seedlobber, and replenishable throwable props when the Graviton Tether can be carried. The boss cannot be grabbed. No required route assumes a separate tether, backup pistol, or two-weapon combo.

## Arena relationship and phase changes

A circular implant theater shown as a side-view platform arena: a permanent lower floor, permanent side ledges, surgical beds on lifts that reposition only between attacks (visibly, and never under a windup), and steel instrument shelves that serve as high cover (each an overhang with at least 1.1 H of headroom). The Surgeon slides on an overhead rail across the ceiling, and the rail is a separate environment asset. A checkpoint sits at the antechamber immediately before the theater.

The staff held for fitting sit restrained in padded chairs behind glass in the holding bays, off the combat plane. They are protected, never targets and never escorted through the fight, and victory releases the bays' locks. The theater stays dark around the fight and lit where it matters: surgical lamps over the beds, a light under each instrument shelf, and a light near every landing. *Proposed:* the level's keycard comes from the arena console after the fight, and level design owns its placement.

Phase one keeps one attack active at a time. Phase two chains the laser and the dive with shorter amber tells and the same red tell, and the held staff's heads turn to follow Dave. The body stays the same: no helpers, no repair cycles and no new limbs. The Surgeon starts no new windup while its beam is live.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Surgeon, a surgical robot that hangs from a ceiling rail in a corporate clinic's implant theater. Role: third mini-boss; a mechanical surgeon with a cutting laser and an injector dive. It has no face and no human parts.
Scale: 3.00 m body height from hood to injector tips; up to 4.40 m span with the laser arm extended.
Silhouette: An upright teardrop torso hanging from a telescoping three-segment hoist column under a rail carriage, with a hooded head of three lamp discs, one long slim jointed laser-scalpel arm, two short folded clamp arms, and a cluster of three injector barrels hanging from its underside. It resembles a pale, tidy surgical workstation.
Physical design: The head is a smooth hood carrying three round surgical lamp discs in a vertical row, with no eyes, mouth or face. The torso is seamless porcelain-white ceramic with dark joint collars, and a round chest door in three iris leaves is closed over the core. The laser-scalpel arm on the anatomical right has three slim segments and ends in an empty wrist socket. Two short padded clamp arms fold flat against the anatomical left side. Under the torso hangs a padded housing with exactly three long needle barrels. The hoist column is three nested segments under a rail carriage with two rail wheels, with a short length of overhead rail shown above it. Small steady green status lights sit on the torso. Spotless except for scuffs at the joints.
Materials and colors: Cool porcelain #D5DDE3 torso, hood, iris leaves; dark joint collars and rail carriage #1C2A3A; slate #2E3B4E hoist column and clamp pads; small signal-green #4DE38A status lights; a small teal #3FE0D0 carriage light. Flat base colors only, with the lamp discs drawn as dark unlit shapes.
Critical consistency: One laser arm, two clamp arms, one injector cluster with exactly three needle barrels, three lamp discs, one three-leaf chest door. No legs, no face, no eyes or mouth, no human parts or implant hardware on its body, no gun or lens cowl painted on the wrist socket.
Use a relaxed neutral pose that reveals the silhouette and joint structure: hanging still with the arms folded, no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right (the production facing; the rig mirrors it for left-facing play), centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored, painted so it can be split into rig parts (carriage, hoist segments, torso, hood and lamp discs, iris leaves, laser arm segments, clamp arms, injector cluster) with clean overlap under each joint and the hidden areas (the far side of the torso, the folded clamp arms) painted complete. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in and no gun painted in. No airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, action effects, UI, watermark, text, logos, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Surgeon design for DEAD EDEN. This is the same exact asset, not a redesign. Show a right-facing painting (the production facing) and a left-facing check drawing as separate drawings; the rig mirrors the right-facing parts for left-facing play, so the check only confirms that mirrored parts still read. Preserve anatomical left/right equipment; do not mirror asymmetry blindly. Use the same canvas scale and the same rail height in both drawings, flat base colors and a plain flat mid-grey (#808080) background. Maintain these proportions: 3.00 m body height from hood to injector tips; up to 4.40 m span with the laser arm extended. Maintain these defining forms: An upright teardrop torso hanging from a telescoping three-segment hoist column under a rail carriage, with a hooded head of three lamp discs, one long slim jointed laser-scalpel arm, two short folded clamp arms, and a cluster of three injector barrels hanging from its underside. It resembles a pale, tidy surgical workstation. Preserve construction: The head is a smooth hood carrying three round surgical lamp discs in a vertical row, with no eyes, mouth or face. The torso is seamless porcelain-white ceramic with dark joint collars, and a round chest door in three iris leaves is closed over the core. The laser-scalpel arm on the anatomical right has three slim segments and ends in an empty wrist socket. Two short padded clamp arms fold flat against the anatomical left side. Under the torso hangs a padded housing with exactly three long needle barrels. The hoist column is three nested segments under a rail carriage with two rail wheels. Small steady green status lights sit on the torso. Preserve the palette: Cool porcelain #D5DDE3; dark joint collars and carriage #1C2A3A; slate #2E3B4E; signal green #4DE38A status lights; small teal #3FE0D0 carriage light. Lock these details: One laser arm, two clamp arms, one injector cluster with exactly three needle barrels, three lamp discs, one three-leaf chest door. No legs, no face, no eyes or mouth, no human parts or implant hardware, no gun or lens cowl painted on the wrist socket. Keep all parts fully in frame and clearly separated; show all required views without overlap, including a view where the laser arm is fully readable. Use a neutral repeatable pose, no action effects, no scenery. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Surgeon reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Neutral hanging on the rail; sliding along the rail; lens opening; sight line tracking; freeze and hold; beam; lens hanging open; dive windup; dive; hanging at head height with the core open; phase-two chain; hit reaction; wreck. If no state is specified, show the lens opening. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It hangs still on the rail with its arms folded. The carriage slides along the rail, the eight cowl petals open one after another, and the scalpel arm extends smoothly. For the dive the hoist drops the machine until the three injector needles touch the floor and the open chest core hangs at head height. Capability: A cutting laser whose sight line tracks the hero, freezes, and then drags a beam after them, and an injector dive onto a locked spot. In phase two the two chain together. Important limitation or opening: The open lens cowl after the beam, and the chest core behind the three open iris leaves after the dive, both glowing hot white and visible from both side views; the rest of the shell is closed. Boss phases: Phase one keeps one attack active at a time. Phase two chains the laser and the dive with shorter amber tells; the body stays the same, with no helpers, no repair cycles and no new limbs. Draw lamps and the lens as flat bright shapes with no halos. Keep effects small and separate enough that the body silhouette is visible. Plain flat mid-grey (#808080) background, evenly lit, no baked shadows and no blood painted in; leave the wrist socket empty of any gun; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Before sprite production

- No image is approved for this asset yet. Approve one neutral image (prompt 1) before producing animation poses.
- The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): paint parts flat and unlit, with no shadows or highlights, and add a normal map per part after the parts are cut.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and tell readability at intended gameplay size, lit by the engine's lamps against the dark theater, and in grayscale. The sight line, the hood lamps and the two open targets (lens and core) must read from shape and motion as well as glow.
- Establish a consistent canvas, rail height and pivot intent; draw a few key poses before adding small details.
- Neutral and study sheets use a flat mid-grey background so pale and dark parts both read. Final parts are cut out to transparent.
- Keep effects and moving pieces separate. A concept PNG is not a finished rig, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).
