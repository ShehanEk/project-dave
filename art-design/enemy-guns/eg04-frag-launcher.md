# GL-6 Frag Launcher

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** EG04\
**Category:** enemy-guns\
**First appearance:** Level 5\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). This gun's name, look, colors and numbers are *proposed* (C27, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Thornwall's own field kit (the GL-6). The contractors came to sanitize, not to arrest, and this is the gun that says so.

**Carried by:** Thornwall [Grenadiers](../thornwall/tw02-grenadier.md), L5–L9. Any enemy can carry it. It drops on death as a static prop that Dave cannot pick up.

It teaches the forward escape: the landing spots are always behind and under Dave, so the safe move is toward the launcher.

## Look, size and socket

**Futuristic look:** a stubby black revolving-drum launcher with a ring light around the muzzle. A six-chamber drum sits ahead of the pistol grip, under a short fat barrel, with a folded stock. The ring around the muzzle is the tell and stays dark until it glows.

**Size:** 0.58 m long and 0.28 m tall at the drum, about the length of the carrier's torso; it reads as short, wide and heavy.

**Socket:** the grip origin sits at the pistol grip, where the weapon hand's palm socket meets it; the launcher rotates about this point to aim. The muzzle marker sits at the center of the muzzle ring. The support-hand point sits on the foregrip under the barrel (drawn on the carrier's support hand).

**Colors (flat, unlit):** matte Thornwall black #1F252D body and barrel; graphite #2E3B4E drum with dark chamber openings; dark steel #1C2A3A muzzle ring; black cloth tape on the foregrip and stock.

## Fire pattern, tell and dodge

**Fire:** 2 frags 0.6 s apart on fixed 0.9 s arcs. The first lands at Dave's grounded spot, and the second 1.5 H behind him (away from the Grenadier). Each frag lands, blinks amber for 0.3 s and then red for 0.25 s, and bursts in a 1.0 H radius for 0.15 s (1 damage, blocked by walls and floors). Minimum range 2 H. At most 2 alive. Then a 1.8 s reload, rooted.

**Tell (GLOW):** the muzzle ring glows amber, then red for the last 0.25 s, with a "Frag out!" subtitle and a shout.

**Dodge:** move forward, toward the Grenadier, off the landing spots; the escape is always forward. Rush him during the reload.

## Shot, light and sound

**Projectile:** a dark graphite grenade with a dark outline and one pale ivory band. After it lands the band is the only part that changes: amber for 0.3 s, then red for 0.25 s, as a tell, never as a shot color. The burst is a flat cool-grey smoke puff with ivory sparks, with no orange fireball.

**Muzzle-flash light (*proposed* preset):** a soft round light in ivory #F2EBD3, energy 1.5, extent 1.6 H, height 0.3 H, one 0.08 s pulse per launch. The burst carries its own light: warm white #F6F1E0, energy 1.8, extent 2.0 H, height 0.2 H, 0.15 s to match the burst. Both light the carrier and the floor through their normal maps.

**Sound:** a thump on launch, a drum-turn ratchet on the reload, and a crack on the burst.

## Rules and production

One drum and one barrel with a ring; no brass, gold or legible text, and maker marks are plain stripes. The ring is dark in the base art, and the blinking band, smoke and sparks are effects, never painted onto the gun or the grenade (draw the grenade and the burst puff as separate effect sprites). Cut the gun as one part with its own normal map (green = up). Approve the neutral image before the carried study, and check the launcher at gameplay size in the carrier's hands, in grayscale and against near-black backgrounds. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the carried study.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the GL-6 frag launcher, a private military contractor's field grenade launcher: a single gun on its own, with no hands and no carrier.
Scale: 0.58 m long and 0.28 m tall at the drum; about the length of an adult's torso.
Silhouette: a stubby, wide revolving-drum launcher with a short fat barrel, a chunky six-chamber drum ahead of the pistol grip, and a folded stock.
Physical design: a matte black body and barrel, a graphite drum with six dark chamber openings, a pistol grip and a short foregrip with black cloth tape, a folded stock, and a plain round ring set around the muzzle, dark. No brass, no visible logos.
Materials and colors: matte black #1F252D body and barrel; graphite #2E3B4E drum; dark steel #1C2A3A muzzle ring; black tape.
Critical consistency: one drum with six chambers, one barrel with a ring, no brass, no text or logos; the ring is drawn dark and unlit.
Show the launcher in strict side view with the muzzle pointing to the right.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no blood. No hands, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — carried-in-hand study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved GL-6 frag launcher, draw one carried-in-hand study in strict side view: an adult's right hand and forearm in a warm charcoal combat-shirt cuff and a black glove, gripping the pistol grip, and the left hand on the foregrip, in a braced two-hand hold. Forearms and hands only, with no body and no head. The launcher keeps the exact approved design, points to the right, and sits with its grip at the palm socket. Preserve the launcher's proportions, colors and part counts.

Flat mid-grey (#808080) background, evenly lit and flat-colored so the hands and the gun can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
