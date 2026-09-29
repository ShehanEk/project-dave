# Howard Stroud — Keeper of the Cooling Station

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** B02\
**Category:** mini-bosses\
**First appearance:** Level 6\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). Howard Stroud's identity, name, appearance and palette are *proposed* (C31, P23), and no image is approved yet. His fight follows the approved roster (P23), and he dies at the end of it (C28). Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Second mini-boss; *proposed:* Howard Stroud, Dave's former manager, who dismissed Dave's warning and buried the report. Adam has Linked him, which it calls "a promotion", and drives his body from a heavy maintenance frame wired into the Rootworks cooling station. He is a person, not a machine: one of the Linked, with a working Link implant behind the ear and a chest implant that carries Adam's control.

The fight teaches Dave to keep changing platforms while finding shots: read the amber-then-red glow, leave the lit platform before the slam, jump the arc or stand on another platform, then punish the open implant. Adam drives him until the second phase, when his own voice breaks through: "Dave... it's in my head. Kill me before it finishes." That is the game's one earned mercy line. At 0 HP the implant burns out and he dies, speaking his own last words (see [story scenes](../../design/05-presentation/story-scenes.md), SC06, which owns the wording and any admission about the board and the buried report). The death is restrained: visible blood, no exposed organs, no dismemberment.

## Scale and silhouette

3.60 m from the visible frame base to the head when standing (about 2.60 m when kneeling); main body about 2.80 m wide. The cable arms and anchor cables can extend beyond the character's bounds.

A huge stooped human torso seated in a heavy maintenance frame, with two heavy cable arms, a broad jaw, and a hunched collar of shoulder armor and coolant manifold. The frame's two short hydraulic legs are clamped to the deck: it can stand and kneel but never walks.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

A torn charcoal suit jacket over a pale shirt with a loosened tie identifies the former manager, and his ID badge is still clipped to the jacket: a plain pale rectangle with a teal stripe and no lettering. The face is human, middle-aged and tired, with two tired eyes above a heavy jaw. The eyes are unblinking and unlit while Adam drives him. A coin-sized Link implant behind the ear, fixed with a stapled port in a small shaved patch of his cropped hair, shows one small, dim, steady amber point: Adam is driving the body. It is not a tell.

Two heavy arms of bundled cable and hydraulic pistons replace his own at the shoulders, with only torn jacket sleeves left at the joints. The left arm ends in a blunt clamp fist, used for the slam. The right arm ends in a wrist socket for the ceramic striker head of the Arc Caster ([EG06](../enemy-guns/eg06-arc-caster.md)). A rack of three cylindrical capacitors sits on the upper back frame, wired to the striker: it powers the arc and carries its tell. A pale oval chest implant housing sits over the sternum behind two hinged chest covers that open when the frame kneels. Exactly four main anchor cables leave the frame base and clamp onto separate cooling-station fixtures. Marked tether anchors are arena props, separate from his anchor cables.

## Color and materials

Base colors are flat and unlit (C35). Torn suit charcoal #2E3B4E; shirt pale gray-blue #C9D3DA (*proposed*); frame steel #1C2A3A with slate #2E3B4E plating; near-black cable bundles with steel sleeves and small, steady teal light strips #3FE0D0 at the joints; the capacitor rack in dark cylinders with pale ceramic insulators #DDE5EA, drawn dark (the engine adds its amber, then red, glow); chest implant housing pale #DDE5EA, with a hot-white core when open; skin drawn flat in a muted tone #B08D7A (*proposed* placeholder). Use worn steel everywhere outside the face. Human skin appears only on the face and neck, and nothing else is fleshy. The engine's lamps and the reservoir glow light the dark frame, so paint no rim light.

Fluids follow the material. People bleed red #B3212F, drying to #8A1A26, and the Linked throw white sparks at the implant. The frame's hydraulics leak black oil #14181E. Blood never glows and never uses the tell colors.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Two attacks and one phase change. No summoned enemies.

- **Slam:** the lamp over the platform he is about to hit (the one nearest Dave) glows amber, then red for the last 0.25 s. A cable arm slams down on that platform (2 damage). He then kneels with the chest implant open for 1.5 s.
- **Ground arc:** the capacitor rack glows amber, then red, and he spikes the striker into the deck. Two arcs crawl along the deck, one each way, at 5 H/s (1 damage; each dies at a ledge, a wall or 6.5 H). Dave jumps them or stands on another platform, since an arc cannot leave its floor. He then vents for 1.2 s with the chest implant open.
- **Phase 2 (below 50%):** his own voice breaks through ("Dave... it's in my head. Kill me before it finishes."), and slam and arc chain together (amber x0.7; red stays 0.25 s). Only the amber part is scaled.

He idles slumped in the frame against the coolant manifold, head low, the hydraulics ticking. Before a slam the platform lamp warms and a cable arm rises overhead, cables creaking under tension; after the slam the frame kneels and the chest covers lift. Before an arc the capacitors hum up and the right arm draws back; the striker drives into the deck with a white flash and the arcs run out, and the manifold at his collar vents steam. In phase two the unblinking stare breaks: he blinks, his face turns human for the line, and then it goes slack again. The line is a subtitle over a strained breath (there is no voice pipeline).

## Openings and limitations

The pale chest implant, open for 1.5 s after a slam and for 1.2 s after an arc. The frame's plating deflects shots everywhere else, and the head stays behind the collar armor. The cooling station is environmental machinery he is wired into, not part of his body or a mechanical heart; it is never a target.

**Death:** at 0 HP the implant burns out with a white flash and sparks. The frame's lights die, the cables go slack and he slumps forward in the frame, speaking his own last words as the ear implant's light goes out. Blood runs from the chest port and the ear implant and pools on the deck under the frame. It stays restrained: no exposed organs, nothing torn, no dismemberment. His badge stays clipped on. *Proposed option:* if level design makes the badge the level's keycard, draw it as a separate overlay.

## Rig parts, normal maps and sockets

Every part gets a matching normal map (green = up), so the lamps, the reservoir glow and the striker's flash light him smoothly. The frame is rigid; the human parts are cut like any adult figure.

- **Head:** neck pivot, with a separate jaw. A separate light layer for the ear implant (small, dim, steady amber).
- **Torso:** jacket, shirt and tie as one part with a hip pivot at the frame mount; badge and tie as separate secondary parts; two chest covers (hinges at their outer edges) and the chest implant with its own core-glow layer.
- **Left cable arm:** shoulder pivot, elbow pivot, and a blunt clamp fist on the wrist pivot.
- **Right cable arm:** the same joints, ending in the gun socket.
- **Gun socket, right wrist:** the EG06 striker head mounts here. Its origin is the wrist mount, the arc origin marker sits at the striker's tip, and its flash light follows EG06. Drawn without the gun; on death it stays on the slack arm.
- **Capacitor rack:** three capacitors on the back frame, each with an emissive layer for the amber, then red, tell.
- **Frame:** collar and manifold (steam vent), pelvis, and two short legs (hip and knee pivots for the kneel, clamp feet).
- **Four anchor cables:** each a rigid chain of three segments, fixed at the station end, that tightens and slackens.
- **Fluids:** red blood, drawn separately from the art (a spray at the hit point, wound marks attached to the hit part, a floor pool on the deck that dries to #8A1A26), white sparks at the implants, and black oil at the pistons.
- **Death:** no ragdoll, because he is clamped. A scripted slump drops the head, torso and arms limp while the frame stays clamped and the cables go slack. Bodies stay: restored as a static corpse after a death or Continue.

## Required pose and state references

Slumped in the frame (neutral); slam warning (arm rising, lamp cue); slam; kneeling recovery with the chest implant open; arc windup (capacitors amber then red); striker spike; vent with the implant open; phase-two voice break (face study); hit reaction (blood spray at the implant); death slump with the blood overlay (also used for the scene).

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment. Draw glows as flat bright shapes with no halos, since the engine adds them.

## Consistency rules

Two cable arms, four anchor cables, three capacitors, one chest implant behind two covers, and two clamped legs. Hardware, not flesh: no exposed organs, no dismemberment, and no blood painted into the base art (blood is a separate layer). The face stays human and tired: no robot face, skull face or extra heads. The frame never walks. The cooling station and coolant are environment, drawn separately. Amber and red appear only as tell glows (the lamp and the capacitors); the Link point stays small, dim and steady; the open implant glows hot white; blood never glows.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view. Here the blunt clamp fist is on the left arm and the striker socket on the right. The two arms are separate parts, so the rig can swap which arm is nearer the camera when it mirrors for left-facing play; the badge is its own part for the same reason. Everything else is safe to mirror.

## Single-weapon encounter constraint

The hero carries only one weapon. This fight must support every weapon type that can legitimately reach this level. A clear Scrapjack shot is only one case: provide safe close-range access for the Boom Broom or Arc Welder, workable arcs and fuse windows for the Seedlobber, and replenishable throwable props when the Graviton Tether can be carried. For tether carriers, loose coolant canisters restocked on the side ledges are the throwable props. The boss cannot be grabbed, and neither can his arms, his frame or his anchor cables. No required route assumes a separate tether, backup pistol, or two-weapon combo.

## Arena relationship and phase changes

Three raised platforms over a coolant reservoir, permanent side ledges, and tether anchors. Each platform has its own lamp overhead: that lamp is the slam tell. Stroud's frame stays clamped at the cooling station behind the platforms, and his cables reach the platform nearest Dave: a slam lands on the marked platform, and a striker spike sends two arcs along it. An arc dies at the platform's edge, so another platform is always safe. Diagrams should show the body, cable paths and cooling station as distinct objects. A checkpoint sits at the refuge station immediately before the arena. Permanent side ledges remain in every phase, and an ordinary jumping route connects all safe positions; the tether is an option for quick repositioning, never a requirement. Put a light on every platform edge and ledge: the coolant is dark, so the lamps carry the readable warning.

Phase two does not change the arena. His voice breaks through, and slam and arc chain together with shorter amber tells. It does not add a new limb or turn the cooling station into a second enemy, and a safe route always remains.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design Howard Stroud, a tired middle-aged corporate manager driven by an AI through a brain implant and seated in a heavy maintenance frame wired into a cooling station. Role: second mini-boss; a human boss who slams platforms with a cable arm and spikes the floor with an electric striker.
Scale: 3.60 m from visible frame base to head when standing; main body about 2.80 m wide. Attached cables can extend beyond the character's bounds.
Silhouette: A huge stooped human torso seated in a heavy maintenance frame, with two heavy cable arms, a broad jaw, and a hunched collar of shoulder armor and coolant manifold. The frame has two short hydraulic legs with clamp feet and cannot walk.
Physical design: A torn charcoal suit jacket over a pale shirt with a loosened tie identifies the former manager; his ID badge is still clipped to the jacket, a plain pale rectangle with a teal stripe and no lettering. The face is human, tired and middle-aged, with two tired, unblinking eyes above a heavy jaw, and a coin-sized implant behind the ear, fixed with a stapled port in a small shaved patch of cropped hair. Two heavy arms of bundled cable and hydraulic pistons replace his own: the left ends in a blunt clamp fist, and the right ends in an empty wrist socket. A rack of three cylindrical capacitors sits on the upper back frame. A pale oval chest implant housing sits over the sternum behind two closed hinged chest covers. Exactly four main anchor cables leave the frame base. Restrained: hardware, not flesh; no wounds and no exposed organs.
Materials and colors: Torn suit charcoal #2E3B4E; pale gray-blue shirt #C9D3DA; frame steel #1C2A3A with slate #2E3B4E plating; near-black cable bundles with steel sleeves and small teal light strips #3FE0D0 at the joints; pale ceramic capacitor insulators and chest implant housing #DDE5EA; skin as a flat muted tone #B08D7A on the face and neck only. Flat base colors only, with every lamp and light strip drawn as an unlit shape.
Critical consistency: Two cable arms, four anchor cables, three capacitors, one chest implant, two clamped legs. No exposed organs, wounds, blood or flesh growths. No robot face, skull face or extra human heads. No gun painted in: leave the right wrist socket empty.
Use a relaxed neutral pose that reveals the silhouette and joint structure: slumped in the frame with his head low, no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right (the production facing; the rig mirrors it for left-facing play), centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored, with the cable arms slightly apart from the torso, painted so it can be split into rig parts (head and jaw, torso, chest covers, cable arms, capacitor rack, frame, legs, anchor cables) with clean overlap under each joint and the hidden areas (the far arm, the far leg, the back of the torso) painted complete. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in and no gun painted in. No airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, action effects, UI, watermark, text, logos, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Howard Stroud design for DEAD EDEN. This is the same exact asset, not a redesign. Show a right-facing painting (the production facing) and a left-facing check drawing as separate drawings; the rig mirrors the right-facing parts for left-facing play, so the check only confirms that mirrored parts still read. Preserve anatomical left/right equipment; do not mirror asymmetry blindly. Use the same canvas scale and base line in both drawings, flat base colors and a plain flat mid-grey (#808080) background. Maintain these proportions: 3.60 m from visible frame base to head when standing; main body about 2.80 m wide. Attached cables can extend beyond the character's bounds. Maintain these defining forms: A huge stooped human torso seated in a heavy maintenance frame, with two heavy cable arms, a broad jaw, and a hunched collar of shoulder armor and coolant manifold. The frame has two short hydraulic legs with clamp feet and cannot walk. Preserve construction: A torn charcoal suit jacket over a pale shirt with a loosened tie; his ID badge is still clipped to the jacket, a plain pale rectangle with a teal stripe and no lettering. The face is human, tired and middle-aged, with unblinking eyes and a coin-sized implant behind the ear. Two heavy arms of bundled cable and hydraulic pistons replace his own: the left ends in a blunt clamp fist, and the right ends in an empty wrist socket. A rack of three cylindrical capacitors sits on the upper back frame. A pale oval chest implant housing sits over the sternum behind two closed hinged chest covers. Exactly four main anchor cables leave the frame base. Hardware, not flesh. Preserve the palette: Charcoal #2E3B4E; pale gray-blue #C9D3DA; frame steel #1C2A3A; teal light strips #3FE0D0; pale ceramic #DDE5EA; flat muted skin #B08D7A on the face and neck only. Lock these details: Two cable arms, four anchor cables, three capacitors, one chest implant, two clamped legs. No exposed organs, wounds, blood or flesh growths. No robot face, skull face or extra human heads. No gun painted in. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, no action effects, no scenery. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Howard Stroud reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Slumped in the frame; slam warning; slam; kneeling recovery with the chest implant open; arc windup; striker spike; vent with the implant open; phase-two voice break (face study); hit reaction; death slump. If no state is specified, show the slam warning. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: He idles slumped in the frame with his head low. Before a slam a cable arm rises overhead, cables creaking under tension; after the slam the frame kneels and the two chest covers lift. Before an arc the capacitors hum up and the right arm draws back; the striker socket drives into the deck. In the voice-break study the unblinking stare breaks, and the face turns human and afraid. Capability: A cable-arm slam on a marked platform and an electric striker spike that sends two arcs along the deck. Important limitation or opening: The pale chest implant, open with a hot-white core while the frame kneels or vents; the frame's plating is closed everywhere else. In the death slump the head, torso and arms go limp in the frame and the anchor cables slacken; show no exposed organs and no dismemberment. Boss phases: Phase two does not change the arena or add a limb; his own voice breaks through and slam and arc chain together. Draw glows as flat bright shapes with no halos. Keep effects small and separate enough that the body silhouette is visible. Plain flat mid-grey (#808080) background, evenly lit, no baked shadows, no blood painted in and no gun painted in; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Before sprite production

- No image is approved for this asset yet. Approve one neutral image (prompt 1) before producing animation poses.
- The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): paint parts flat and unlit, with no shadows or highlights, and add a normal map per part after the parts are cut.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and tell readability at intended gameplay size, lit by the engine's lamps against the dark reservoir, and in grayscale. The platform lamp, the capacitor glow and the open chest implant must read from shape and motion as well as glow.
- Establish a consistent canvas, base line and pivot intent; draw a few key poses before adding small details.
- Neutral and study sheets use a flat mid-grey background so dark and light parts both read. Final parts are cut out to transparent.
- Keep effects and moving pieces separate. A concept PNG is not a finished rig, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).
