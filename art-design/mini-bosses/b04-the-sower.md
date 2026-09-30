# The Sower — Adam's Launch Walker

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** B04\
**Category:** mini-bosses\
**First appearance:** Level 12\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). The Sower's identity, name, appearance, sounds and palette are *proposed* (C31, P23), and no image is approved yet. Its fight (stomp and arc wave, chest plasma volley, seekers in phase two) follows the approved roster and replaces the earlier three-mode design. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Fourth and hardest mini-boss; *proposed:* Adam's walking launch machine, built to carry the violet Bloom canisters up to the climate towers. It is the secret weapon made visible, and the game's homage to the walking superweapons of the 2D *Metal Gear* games. The design is original: do not copy any *Metal Gear* machine.

In the fight it does not walk. It stands braced over the launch shaft with one foot on each side of the shaft hatch, and it flips to face Dave. It fires Adam's own weapons at scale: the Arc Caster's arcs ([EG06](../enemy-guns/eg06-arc-caster.md)) from its feet, the Lumen plasma cannon ([EG07](../enemy-guns/eg07-plasma-gun.md)) from its chest and, in phase two, seekers ([EG08](../enemy-guns/eg08-seeker.md)) from its rear vents. The fight's lesson is to recognize each learned tell and punish the vent: jump the arc waves, jump the slow plasma bolts, deal with the seekers, then punish the open vents. It combines the earlier lessons. After it falls, the interactive ending at Adam's core follows. There is no extra boss and no thirteenth level.

## Scale and silhouette

3.50 m tall including the canister crown; 2.40 m wide at rest, and its braced stance spans up to 3.20 m fore and aft, one foot on each side of the shaft.

A tall arch-shaped walker frame on two powerful jointed legs with broad flat feet, the legs spread fore and aft over the shaft. A launch rack across the top of the arch holds six violet Bloom canisters in two tiers of three, like a crown. A pearl-white chest cannon is set into the front of the armored hull, two vent stacks stand on the back of the hull, and a lamp bar glows across the toe of each foot. The open arch, the violet crown and the white chest cannon distinguish it from every other machine in the game.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

A central armored hull in two segments (upper hull and pelvis) spans the arch between the legs and covers the core chamber. The chest cannon is a short, fat emitter housing of pearl-white ceramic with a clear glass chamber where a blue-white ball grows: the Lumen look (EG07) at about three times scale, a compact emitter and never a long rail barrel. Two upright vent stacks on the back of the hull are angled outward, each with hinged louvers: closed they are plain plating, and each holds a seeker launch port (EG08). Each foot has a wide lamp bar across the toe, dark until the tell, and a ceramic striker plate on the sole wired to a capacitor bank on the shin: the Arc Caster's hardware at scale (EG06). Thick armored hoses run from the hull through visible sockets to the canister rack. Each canister is a tall sealed capsule with a violet glowing window and a narrow teal collar; the canisters are cargo, never weapons, projectiles or weak points. Two floor clamps lock the feet in place; they are arena props, separate from the body.

## Color and materials

Base colors are flat and unlit (C35). Gunmetal steel #1C2A3A for the frame; slate #2E3B4E for hull plates; seam teal #3FE0D0 on seams and joints (Adam's presence, small and steady); pearl white #E6ECEF (*proposed*) for the chest cannon housing; Bloom violet #C77DFF only in the canister windows and their glow. The foot lamps, the cannon's emitter ring and the vent slots are drawn dark; the engine adds the amber #FFB02E, then alarm red #FF3B4E, glow as tells only, and a hot-white glow when a vent is open. Keep violet exclusive to the canisters so the weapon reads at a glance; their glow stays steady and slow and is never a tell. Fluid is black oil #14181E with a #46566A sheen rim, plus white sparks. There is no blood.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Two attacks in phase one and seekers in phase two. No summoned enemies.

- **Stomp:** the lamp on the striking foot glows amber, then red for the last 0.25 s. The foot drops onto its bracing plate (2 damage) and an arc wave (EG06) crawls along the deck both ways at 5 H/s (1 damage; it dies at a ledge, a wall or 6.5 H). Dave jumps it.
- **Plasma volley:** the chest cannon charges, glowing amber and then red for the last 0.25 s, and fires 3 slow bolts (EG07) 1.0 s apart at Dave's grounded spot. Each bolt bursts on impact.
- **Rear vents:** after each attack the two rear vents open for 1.5 s.
- **Phase 2 (below 50%):** the shaft opens, violet canisters rise and Adam speaks. Each vent releases 2 seekers (EG08; at most 2 alive, 2.5 s life), and two attacks chain before each vent (amber x0.7; red stays 0.25 s). It starts no new windup while its shots are alive.

It stands braced and heavy, the hull swaying a little and the core humming. Before a stomp one leg lifts, the foot lamp warms and the sole plate flashes; after the drop the deck shakes and the vents open with a hiss. Before the volley the chest chamber swells with a rising hum. In phase two the shaft hatch opens beneath it and the canisters rise in the shaft (arena assets: they are cargo, never targets or hazards); the vents pop open and seekers slip out. Sounds are *proposed*: a deep hydraulic groan, EG06's buzz and snap, EG07's rising hum, EG08's whine, and Adam's voice from the shaft (wording owned by [story scenes](../../design/05-presentation/story-scenes.md)).

## Openings and limitations

The two rear vents, open for 1.5 s after each attack. They are distinct geometry states of the same body: plain plating when closed, and a hot-white slot against a dark recess when open, angled outward so they read in a straight side view and can be hit from either side. Nothing else takes damage. The canisters are never openings.

**Death:** the braced legs give and the frame collapses over the shaft, bursting into debris parts, with black oil and sparks and the lamp bars going dark. The six canisters stay sealed, intact and steadily glowing: they never break, leak or fire.

## Rig parts, normal maps and sockets

All parts are rigid. Every part gets a matching normal map (green = up), so the shaft's lamps, the plasma ball and the muzzle flashes light the Sower smoothly. The canister windows get a domed normal so they catch light.

- **Upper hull** (root part, pivot at the pelvis): the shell, the core chamber and the hoses.
- **Pelvis:** hip pivots for both legs.
- **Legs:** front and rear, each with a thigh (hip pivot), a shin with its capacitor bank (knee pivot) and a foot (ankle pivot). Each foot carries a lamp-bar layer and a sole striker plate (an EG06 arc-origin marker at its center).
- **Chest cannon socket:** the EG07 housing mounts here at about three times scale, with its own emitter-ring layer and ball layer. The muzzle marker sits at the emitter, and its flash light follows EG07.
- **Rear vent stacks:** two stacks, each with louvers hinged at the top edge and a seeker port. The EG08 muzzle marker sits at the port, and its flash follows EG08.
- **Canister rack:** one rigid rack and six sealed canisters, each with its own violet glow layer.
- **Fluid:** black oil #14181E with a #46566A sheen rim, plus white sparks, as overlay layers attached to the hit part.
- **Debris on death:** the hull segments, pelvis, legs, cannon housing, vent stacks, hoses and rack become physics bodies in a burst. The canisters remain sealed and whole.

## Required pose and state references

Neutral braced idle (canisters sealed); flip to face Dave; stomp windup (foot lamp amber then red); stomp landing with the arc wave; plasma volley windup (cannon amber then red); volley; vents open; phase-two shaft open with canisters rising; seeker release from the vents; hit reaction; wreck (canisters still sealed and glowing).

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment. Draw lamps and vent slots as flat bright shapes with no halo, since the engine adds the glow.

## Consistency rules

Exactly two legs, two foot lamps, two rear vent stacks, one chest cannon and six sealed canisters. Original design: no domed head, radome, railgun barrel or bulky torso-on-legs shape; keep the open arch, the violet canister crown and the white chest cannon. The canisters stay sealed and never fire, break or act as weak points. It has no arms, no extra heads, no floating body, no generic giant Heir, nothing fleshy, and no repair node or mode lenses. Amber and red appear only as tell glows, violet appears only in the canisters, and an open vent glows hot white. No blood: machine fluid only. Keep the chest socket empty in the base art.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view. The Sower is symmetrical in its painted parts (two matching legs, two matching vent stacks, six matching canisters), so the rig mirrors the right-facing painting for left-facing play; the vent stacks stay at its back and the chest cannon at its front.

## Single-weapon encounter constraint

The hero carries only one weapon. This fight must support every weapon type that can legitimately reach this level. A clear Scrapjack shot is only one case: provide safe close-range access for the Boom Broom or Arc Welder, workable arcs and fuse windows for the Seedlobber, and replenishable throwable props when the Graviton Tether can be carried. The boss cannot be grabbed. No required route assumes a separate tether, backup pistol, or two-weapon combo.

## Arena relationship and phase changes

Suspended platforms and permanent recovery ledges around the launch shaft, with marked tether anchors as optional shortcuts. The Sower stands braced over the shaft's closed hatch with a foot on each side, so platforms sit on both sides of it. Use a separate arena sheet so the character stays readable. The shaft is dark: put a light near every landing and ledge, keep the violet glow on the canisters themselves, and never let the canister glow, mist or effects hide a tell, a platform edge or a vent.

A checkpoint sits immediately before the arena. A second checkpoint after the fight, before the ending at Adam's core, means a retry never repeats the fight.

Phase one teaches the two attacks one at a time, the stomp with its arc wave and then the plasma volley, and every attack ends with the vents open. Phase two opens the shaft, which is the arena's one change: violet canisters rise, Adam speaks, the vents release seekers, and two attacks chain before each vent, always with a readable escape route. Visual damage reveals the existing hull and vents; it never silently adds new limbs.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Sower, a walking launch machine built by an AI to carry glowing violet weapon canisters up to climate towers: the secret weapon made visible. Original design, not a copy of any existing franchise mecha. Role: fourth and hardest mini-boss; a braced walker with a stomp, a chest plasma cannon and rear vents.
Scale: 3.50 m tall including the canister crown; 2.40 m wide at rest, and up to 3.20 m fore and aft when braced.
Silhouette: A tall arch-shaped walker frame on two powerful jointed legs with broad flat feet, the legs spread fore and aft, crowned by a launch rack of six upright violet canisters in two tiers of three. A pearl-white chest cannon is set into the front of the armored hull, and two upright vent stacks stand on the back of the hull. The open arch, the violet crown and the white chest cannon distinguish it.
Physical design: A central armored hull in two segments (upper hull and pelvis) spans the arch between the legs. The chest cannon is a short, fat emitter housing of pearl-white ceramic with an empty round socket where a plasma emitter would sit. Two upright vent stacks on the back of the hull are angled outward, each with closed hinged louvers. Each foot has a wide dark lamp bar across the toe and a ceramic striker plate on the sole, wired to a capacitor bank on the shin. Thick armored hoses run from the hull through visible sockets to the canister rack. Each canister is a tall sealed capsule with a violet glowing window and a narrow teal collar.
Materials and colors: Gunmetal steel #1C2A3A frame; slate #2E3B4E hull plates; seam teal #3FE0D0 on seams and joints; pearl white #E6ECEF chest cannon housing; Bloom violet #C77DFF only in the canister windows. Flat base colors only, with the lamp bars and vent slots drawn as dark unlit shapes.
Critical consistency: Exactly two legs, two foot lamps, two rear vent stacks, one chest cannon and six sealed canisters. No domed head, radome, railgun barrel or bulky torso-on-legs shape. No arms, no extra heads, no floating body, nothing fleshy. No gun painted in: leave the chest socket empty.
Use a relaxed neutral pose that reveals the silhouette and joint structure: braced on both feet, no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right (the production facing; the rig mirrors it for left-facing play), centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored, painted so it can be split into rig parts (hull segments, legs, feet, vent stacks, rack, canisters) with clean overlap under each joint and the hidden areas (the far leg, the far vent stack, the back of each canister) painted complete. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in and no gun painted in. No airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, action effects, UI, watermark, text, logos, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Sower design for DEAD EDEN. This is the same exact asset, not a redesign. Show a right-facing painting (the production facing) and a left-facing check drawing as separate drawings; the rig mirrors the right-facing parts for left-facing play, so the check only confirms that mirrored parts still read. Preserve anatomical left/right equipment; do not mirror asymmetry blindly. Use the same canvas scale and foot baseline in both drawings, flat base colors and a plain flat mid-grey (#808080) background. Maintain these proportions: 3.50 m tall including the canister crown; 2.40 m wide at rest, and up to 3.20 m fore and aft when braced. Maintain these defining forms: A tall arch-shaped walker frame on two powerful jointed legs with broad flat feet, the legs spread fore and aft, crowned by a launch rack of six upright violet canisters in two tiers of three. A pearl-white chest cannon is set into the front of the armored hull, and two upright vent stacks stand on the back of the hull. Preserve construction: A central armored hull in two segments (upper hull and pelvis) spans the arch between the legs. The chest cannon is a short, fat emitter housing of pearl-white ceramic with an empty round socket. Two upright vent stacks on the back of the hull are angled outward, each with closed hinged louvers, and are clearly visible in the rear-facing study. Each foot has a wide dark lamp bar across the toe and a ceramic striker plate on the sole, wired to a capacitor bank on the shin. Thick armored hoses run from the hull through visible sockets to the canister rack. Each canister is a tall sealed capsule with a violet glowing window and a narrow teal collar. Preserve the palette: Gunmetal steel #1C2A3A; slate #2E3B4E; seam teal #3FE0D0; pearl white #E6ECEF; Bloom violet #C77DFF only in the canister windows. Lock these details: Exactly two legs, two foot lamps, two rear vent stacks, one chest cannon and six sealed canisters. No domed head, radome, railgun barrel or bulky torso-on-legs shape. No arms, no extra heads, no floating body, nothing fleshy. No gun painted in. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, no action effects, no scenery. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Sower reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Neutral braced idle; flip to face the hero; stomp windup; stomp landing; plasma volley windup; volley; vents open; phase-two shaft open with canisters rising; seeker release; hit reaction; wreck. If no state is specified, show the stomp windup. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It stands braced and heavy over a launch shaft, the hull swaying a little. Before a stomp one leg lifts with its toe lamp bar lit; after the drop the two rear vent stacks open. Before the volley the chest chamber swells. In phase two the shaft hatch opens beneath it and violet canisters rise in the shaft, and small finned seekers slip out of the open vents. Capability: A stomp that sends an arc wave along the floor both ways, a chest cannon that fires three slow plasma bolts, and, in phase two, seekers from the vents. Important limitation or opening: The two rear vent stacks, open with a hot-white slot against a dark recess after each attack; the six violet canisters stay sealed and are never openings. Boss phases: Phase one teaches the stomp and the plasma volley one at a time. Phase two opens the shaft, releases seekers and chains two attacks before each vent. Visual damage reveals the existing hull and vents; it never silently adds new limbs. Draw lamps and vent slots as flat bright shapes with no halos. Keep effects small and separate enough that the body silhouette is visible. Plain flat mid-grey (#808080) background, evenly lit, no baked shadows and no blood painted in; leave the chest socket empty of any gun; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Before sprite production

- No image is approved for this asset yet. Approve one neutral image (prompt 1) before producing animation poses.
- The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): paint parts flat and unlit, with no shadows or highlights, and add a normal map per part after the parts are cut.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and tell readability at intended gameplay size, lit by the engine's lamps against the dark launch shaft, and in grayscale. The stomp lamp, the cannon charge and the open vents must read from shape and motion as well as glow.
- Establish a consistent canvas, foot baseline and pivot intent; draw a few key poses before adding small details.
- Neutral and study sheets use a flat mid-grey background so dark and light parts both read. Final parts are cut out to transparent.
- Keep effects and moving pieces separate. A concept PNG is not a finished rig, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).
