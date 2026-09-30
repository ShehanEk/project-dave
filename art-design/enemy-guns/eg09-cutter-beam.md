# Cutter Beam

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** EG09\
**Category:** enemy-guns\
**First appearance:** Level 9\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). This gun's name, look, colors and numbers are *proposed* (C27, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Adam's own technology. The Cutter Beam is the Garden's "pruning" laser, and Adam has fitted the same lens to the implant theater's surgical robot as a laser scalpel: Adam "pruning" people. It is a futuristic gun.

**Carried by:** [the Surgeon](../mini-bosses/b03-the-surgeon.md), L9, on its scalpel arm; and [Pruner](../machines/m08-pruner.md) turrets, L10–L12. Both are mounted high only. The lens unit is part of its carrier and becomes one of its debris parts on death. On the Surgeon it is a separate small sprite at the scalpel wrist; on the Pruner the same cowl is built into the head's own petal parts (see its brief).

It teaches the beam: keep moving so you are off the line at the freeze, outrun the drag, or stand under cover.

## Look, size and socket

**Futuristic look:** a single lens inside a ceramic cowl of eight petals that opens like a flower. It is drawn as a two-frame swap: closed (the petals fold into a smooth pale bud) and open (the petals spread around a dark lens). On the Surgeon it sits at the end of a slim jointed laser scalpel.

**Size:** the Pruner's head is 1.10 m across with the petals open and 0.60 m tall closed. The Surgeon's cowl is the same design at about one fifth scale, 0.22 m across when open, on a 1.6 m scalpel arm of three slim segments (the arm belongs to the Surgeon's rig).

**Socket:** there is no hand grip. It mounts at the Surgeon's scalpel wrist; the Pruner's head carries the same lens at the same place. The muzzle marker sits at the lens center, and the sight line and the beam start there.

**Colors (flat, unlit):** the Garden's cool ceramic #D8DEE3 petals with a small teal #3FE0D0 seam along each spine; darker #8FA1B0 inner petal faces (a flat color, not a painted shadow); a dark glass lens #14181E with a small white-blue core.

## Fire pattern, tell and dodge

**Fire:** a held beam up to 6.5 H long. For 1.2 s its aim point drags toward Dave at 2 H/s, and it stops at the first solid thing. It hits at most once per firing, for 1 damage. Then a 1.6 s cooldown with the lens open.

**Tell (LINE):** the petals open (a two-frame swap), then a sight line tracks Dave at 3 H/s for 0.8 s, freezes, holds amber for 0.3 s and turns red for the last 0.25 s. The sight line is a thin pale line from the lens to its aim point, with a dark edge so it reads on any floor; it changes color at the hold and at the red.

**Dodge:** keep moving so you are off the line at the freeze. Outrun the drag (2 H/s, where Dave runs 4), or get behind a pillar or under a catwalk. Never cross the beam.

## Shot, light and sound

**Projectile:** a white-hot core with a blue-white #5AA9FF edge (two lines), plus sparks and a scorch mark where it touches the floor. It has its own shape: a long straight held line, never a ball or a bolt. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** soft round blue-white lights (white tinted with the energy edge), #DCEBFF. The lens light is energy 1.6, extent 2.0 H, height 0.3 H, held for the whole 1.2 s beam with a 0.10 s ramp in. A traveling impact light, energy 1.2, extent 1.2 H and height 0.2 H, follows the beam's floor point, and the scorch mark fades over about 3 s. All light the carrier and the floor through their normal maps.

**Sound:** a sizzling hum while the beam is live, and soft petal clicks as the cowl opens.

## Rules and production

Exactly eight petals and one lens; no brass, gold or legible text. The lens is dark and the cowl is flat and unlit in both frames, and the beam, sparks and scorch are effects, never painted onto the cowl. Energy blue is for the beam; the tell is amber, then red, on the sight line and the lens ring. Cut the closed and open frames as two parts with matching normal maps (green = up). Approve the neutral image before the mounted study, and check the cowl at gameplay size on the Pruner and on the Surgeon's arm, in grayscale and against near-black backgrounds. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the mounted study.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Cutter Beam lens unit, an AI's pruning laser: a single emitter on its own, with no arm, no turret and no carrier.
Scale: 1.10 m across when open and 0.60 m tall when closed (the Pruner's size; the Surgeon's is one fifth of this).
Silhouette: a ceramic cowl of eight petals that opens like a flower around a single dark lens, on a short cylindrical mount.
Physical design: eight slim, overlapping cast-ceramic petals, each with a small teal seam along its spine, a short dark mounting collar, and a single dark glass lens at the center with a small white-blue core. Draw the cowl fully open, seen from the side, with four petals visible in profile and the others foreshortened. No brass, no visible logos.
Materials and colors: cool ceramic #D8DEE3 petals with small teal #3FE0D0 spine seams; darker #8FA1B0 inner petal faces; dark glass #14181E lens.
Critical consistency: exactly eight petals, one lens, no brass, no text or logos; the lens is drawn dark and unlit.
Show the unit in strict side view with the lens pointing to the right.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no beam, no sight line, no sparks, no blood. No arm, no turret, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet. (Request the closed frame as a second image with the same reference.)
```
## Image prompt 2 — mounted study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Cutter Beam lens unit, draw one mounted study in strict side view: the end of a slim jointed ceramic scalpel arm (two porcelain-white segments with a dark joint collar) ending in a wrist socket, with the 0.22 m version of the cowl mounted on the socket and fully open, pointing to the right. The cowl keeps the exact approved design. Show only the last two segments of the arm, with no torso and no carrier. Preserve the cowl's proportions, colors and part counts.

Flat mid-grey (#808080) background, evenly lit and flat-colored so the arm and the cowl can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no beam, no sight line, no sparks, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
