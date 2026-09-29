# HG-40 "Thresher" Rotary Machine Gun

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** EG03\
**Category:** enemy-guns\
**First appearance:** Level 3\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). This gun's name, look, colors and numbers are *proposed* (C27, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Arcadia Dynamics' defense division, which sells the HG-40 "Thresher" as "perimeter denial". Thornwall fields it too.

**Carried by:** the roof gun of the [Peacekeeper](../mini-bosses/b01-the-peacekeeper.md) (L3), [Sentry Turrets](../machines/m03-sentry-turret.md) (L4 on) and Thornwall [Heavy Gunners](../thornwall/tw01-heavy-gunner.md) (L5–L9). Any enemy can carry it. It drops on death as a static prop that Dave cannot pick up.

It is the gun that teaches cover: on Dave's floor it is cover-only, and against an elevated mount only high cover works.

## Look, size and socket

**Futuristic look:** a stubby three-barrel rotary in a white shroud, with a heat collar and a belt feeding from a back drum, or straight into the turret body. The heat collar is a plain ceramic-graphite ring, dark until the tell. The barrels are drawn as a fixed three-barrel cluster (the spin is an effect frame). The gun sprite carries only a short belt feed stub; the long belt and the back drum belong to the carrier's rig.

**Size:** 0.95 m long and 0.32 m tall, about half a Heavy Gunner's height. His drum pack (0.36 m across, part of his own overlay) is drawn at 1.1x scale. On a Sentry Turret the same sprite sits in the gun cradle behind the shutter (the turret is about 1.40 m long with the barrels extended), and the belt runs into the housing. On the Peacekeeper it mounts on the roof turret ring at about 1.4 times scale, with its muzzle line 1.5 H above the floor.

**Socket:** the grip origin sits at the rear pistol grip, where the weapon hand's palm socket meets it (a Heavy Gunner braces the gun on a hip harness and plants his feet); the gun rotates about this point to aim. Turret and roof mounts use a mount-point origin at the gun's center of balance. The muzzle marker sits at the barrel cluster's center. The support-hand point sits on the front carry handle, drawn on the carrier's support hand.

**Colors (flat, unlit):** Arcadia white #D5DDE3 shroud; steel #1C2A3A barrels and belt links; graphite #2E3B4E heat collar and receiver; dark round tips on the belt (no brass). The carrier's drum pack is graphite with a pale ivory stripe.

## Fire pattern, tell and dodge

**Fire:** 12 rounds 0.1 s apart (a 1.2 s stream) at 7 H/s, 1 damage, 6.5 H range. A ground gunner holds a flat 0.5 H line. Turrets and the roof gun drag an aim point after Dave at 2.5 H/s with no lead. Then a 2.0 s overheat, rooted, venting steam. Up to 12 rounds alive. The Peacekeeper's roof gun streams for 1.5 s (a boss override).

**Tell (CHARGE):** a 1.0 s spin-up. The collar glow grows amber, the looped whine rises in pitch, then it glows red for the last 0.25 s.

**Dodge:** on Dave's floor it is cover-only: get behind a low crate or onto another floor before it starts (jumping the first half still costs 1 HP). Against turrets, keep running (the aim is slower than Dave) or use high cover. Punish the overheat.

## Shot, light and sound

**Projectile:** a stream of short ivory tracers (tracer ivory #F2EBD3) with a dark outline, fading at maximum range. No casings. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** a soft round light in ivory #F2EBD3, energy 1.3, extent 2.2 H, height 0.3 H, one held additive glow for the whole stream (1.2 s, or 1.5 s on the Peacekeeper), with a 0.10 s ramp in and a 0.15 s fade out. No strobe and no flicker. It lights the carrier and the floor through their normal maps.

**Sound:** a rising spin-up whine, a chatter loop on its own AudioStreamPlayer2D, then a steam hiss on the overheat.

## Rules and production

Exactly three barrels and one heat collar; no brass, gold or legible text, and maker marks are plain stripes. The collar and barrels are dark in the base art, and the glow, steam and tracers are effects, never painted onto the gun. Cut the gun as one part with its own normal map (green = up), with the long belt as a separate stretchable part. Approve the neutral image before the carried study, and check the gun at gameplay size on a Heavy Gunner, a Sentry Turret mount and the Peacekeeper's roof, in grayscale and against near-black backgrounds. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the carried study.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the HG-40 "Thresher" rotary machine gun, sold by a corporate defense division as perimeter denial: a single gun on its own, with no hands and no carrier.
Scale: 0.95 m long and 0.32 m tall; about half the height of a heavily built adult.
Silhouette: a stubby three-barrel rotary cluster in a white shroud, a chunky receiver with a rear pistol grip and a front carry handle, a heat collar around the barrels, and a short ammunition belt feed stub hanging from the receiver's underside.
Physical design: three short barrels inside a white ceramic shroud, a plain ring-shaped heat collar behind the muzzle, a graphite receiver, a short stub of dark steel belt links ending in a loose tail (the back drum belongs to the carrier and is not drawn), and a rear pistol grip. No brass, no visible logos.
Materials and colors: Arcadia white #D5DDE3 shroud; steel #1C2A3A barrels and belt links; graphite #2E3B4E collar and receiver.
Critical consistency: exactly three barrels, one heat collar, no brass, no text or logos; the collar is drawn dark and unlit.
Show the gun in strict side view with the muzzle pointing to the right.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no steam, no blood. No hands, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — carried-in-hand study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved HG-40 "Thresher" rotary, draw one carried-in-hand study in strict side view: an adult's right hand and forearm in a warm charcoal combat-shirt cuff and a black glove, gripping the rear pistol grip, and the left hand on the front carry handle, with a short section of a hip harness strap under the receiver. Forearms and hands only, with no body and no head. The rotary keeps the exact approved design, points to the right, and sits with its grip at the palm socket; its belt runs off the left edge of the frame toward the carrier's back. Preserve the gun's proportions, colors and part counts.

Flat mid-grey (#808080) background, evenly lit and flat-colored so the hands and the gun can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no steam, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
