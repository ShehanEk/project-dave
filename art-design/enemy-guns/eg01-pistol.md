# AS-9 "Civic" Smart Pistol

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** EG01\
**Category:** enemy-guns\
**First appearance:** Level 2\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). This gun's name, look, colors and numbers are *proposed* (C27, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Arcadia Dynamics' defense division. The AS-9 "Civic" is the campus sidearm, a "smart pistol" Arcadia sells to its own security and abroad.

**Carried by:** Arcadia Security [Sidearm Guards](../security/se02-sidearm-guard.md), L2–L6. Any enemy can carry it. It drops on death as a static prop that Dave cannot pick up.

It is the first enemy gun, and it teaches the pattern every gunner repeats: a tell, one flat round, then a rooted recovery.

## Look, size and socket

**Futuristic look:** a matte ivory polymer slab with no hammer, a thin status strip along the slide and a flush lamp at the muzzle. The strip is a small, steady teal light and never a tell. The muzzle lamp is the tell and stays dark until it glows. There is no ejection port and no brass.

**Size:** 0.21 m long and 0.14 m tall, about the length of the carrier's head.

**Socket:** the grip origin sits at the center of the grip, one third up from the heel, where the weapon hand's palm socket meets it; the gun rotates about this point to aim. The muzzle marker sits at the muzzle lamp. The support-hand point sits under the slide for the two-hand stance, and is drawn on the carrier's support hand, not on the gun.

**Colors (flat, unlit):** warm ivory #D9D3BF slide and frame; graphite #2A3341 grip and slide details; dark #1C2A3A muzzle lamp housing; small teal #3FE0D0 status strip.

## Fire pattern, tell and dodge

**Fire:** 1 round at 9 H/s, 1 damage, 6.5 H range. On Dave's floor it flies flat at 0.5 H. From another floor it aims at Dave's grounded spot, locked at red, with no lead. Then a 1.2 s reload racking the slide, rooted. One round alive at a time.

**Tell (GLOW):** a two-hand stance, then the muzzle lamp goes amber, then red for the last 0.25 s with a lock click.

**Dodge:** on his floor, jump the flat round. From a ledge, keep moving, since the aim is locked with no lead. Rush the shooter while he racks the slide.

## Shot, light and sound

**Projectile:** a short ivory tracer (tracer ivory #F2EBD3) with a dark outline, roughly a fifth of a hero height long. No casings. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** a soft round light in ivory #F2EBD3, energy 1.2, extent 1.5 H, height 0.3 H above the play plane, one 0.06 s pulse. It lights the carrier's hands, face and sleeve through their normal maps, so give the gun its own normal map and paint no highlights into it.

**Sound:** a sharp crack plus the lock click on the tell, and a metallic slide rack on the reload.

## Rules and production

No hammer, brass, gold, laser sight (sight lines belong to the rail rifle and the cutter beam) or legible text; maker marks are plain stripes. The lamp is dark in the base art, and the flash and tracer are effects, never painted onto the gun. Cut the gun as one part with its own normal map (green = up). Approve the neutral image before the carried study, and check the gun at gameplay size in the carrier's hand, in grayscale and against near-black backgrounds. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the carried study.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the AS-9 "Civic" smart pistol, the campus sidearm made by a corporate defense division: a single gun on its own, with no hands and no carrier.
Scale: 0.21 m long and 0.14 m tall; about the length of an adult's head.
Silhouette: a slim slab-sided pistol with a short slide, no hammer and a slightly raked grip.
Physical design: a matte ivory polymer slab with a smooth slide and frame, a thin status strip along the slide, and a flush round lamp at the very front of the muzzle. No visible hammer, ejection port, laser sight or brass. A graphite grip panel with fine texture.
Materials and colors: warm ivory #D9D3BF slide and frame; graphite #2A3341 grip and slide details; dark #1C2A3A lamp housing; small teal #3FE0D0 status strip.
Critical consistency: no hammer, no brass, no laser sight, no text or logos; the muzzle lamp is drawn dark and unlit.
Show the pistol in strict side view with the muzzle pointing to the right and the grip at the lower left.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no blood. No hands, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — carried-in-hand study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved AS-9 "Civic" pistol, draw one carried-in-hand study in strict side view: an adult's right hand and forearm in a pale grey shirt cuff (#C7CED5) and a thin black glove, gripping the pistol at its grip with the trigger finger outside the guard, and the left hand cupped under the slide in a two-hand stance. Forearms and hands only, with no body and no head. The pistol keeps the exact approved design and is about the length of the hand plus half; it points to the right, with the grip at the palm socket. Preserve the pistol's proportions, colors and part counts.

Flat mid-grey (#808080) background, evenly lit and flat-colored so the hand and the gun can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
