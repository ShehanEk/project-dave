# "Lumen" Plasma Gun

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** EG07\
**Category:** enemy-guns\
**First appearance:** Level 8\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). This gun's name, look, colors and numbers are *proposed* (C27, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Adam's own technology. The "Lumen" plasma carbine is what Adam arms its captives with, and its first appearance hints at the Garden. Adam's guns look stranger than Arcadia's: seamless, curved and grown-looking, with no visible fasteners.

**Carried by:** [Linked Troopers](../linked/lk04-linked-trooper.md), L8–L10, as a carbine; the [Warden](../heirs/he02-warden.md), L11–L12, as an emitter grown into its ceramic palm; and [the Sower](../mini-bosses/b04-the-sower.md), L12, as a chest cannon at about three times scale. A carbine drops on death as a static prop that Dave cannot pick up.

It teaches the slow bolt: jump it, and stay clear of the wall it will hit.

## Look, size and socket

**Futuristic look:** a pearl-white body with a clear glass chamber where a blue-white ball grows. The body is a smooth ceramic curve with no fasteners, an emitter ring at the muzzle, and a few thin teal seam lines. On the Heirs the emitter is built into the ceramic palm as a ceramic disc holding a small round clear-glass chamber and a slim vent ring.

**Size:** the carbine is 0.78 m long and 0.26 m tall, with a glass chamber 0.14 m across and 0.30 m long; about 40 percent of a Trooper's height. The Heir palm emitter is an 0.08 m disc set in the palm, and the Sower's cannon is the same design at about three times scale.

**Socket:** the grip origin sits at the curved grip, where the weapon hand's palm socket meets it; the carbine rotates about this point to aim. The muzzle marker sits at the center of the emitter ring. The support-hand point sits under the chamber (drawn on the carrier's support hand). The Heir version has no grip: its socket is the palm center, drawn as an overlay on the hand part.

**Colors (flat, unlit):** pearl white #E6ECEF body; dark #2E3B4E seam lines; a pale blue-tinted glass panel #BFD8EE, empty in the base art (the ball is an effect); a dark pearl #C9D3DA emitter ring with a dark outline; small teal #3FE0D0 seam lights, steady.

## Fire pattern, tell and dodge

**Fire:** 1 bolt 0.5 H across at 3.5 H/s, flat at 0.5 H. A direct hit deals 2 damage. It bursts on impact in a 1.0 H radius for 0.15 s (1 damage, blocked by walls). Range 6.5 H. At most 1 alive. Then a 1.4 s vent. The Sower fires 3 bolts 1.0 s apart, as its own boss profile.

**Tell (CHARGE):** the emitter ring glows amber, then red for the last 0.25 s, while the ball swells blue-white in the chamber and a deep hum rises.

**Dodge:** jump it (it is slow, so the timing is generous) or walk away. Stay at least 1 H from the wall it will hit.

## Shot, light and sound

**Projectile:** a large round ball with a dominant white core, a #5AA9FF edge and a dark outline ring, plus a ring flash on the burst. It has its own shape: a big slow sphere, never a line or a streak. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** soft round blue-white lights (white tinted with the energy edge), #DCEBFF, all at height 0.3 H except the burst. The launch pulse is energy 1.8, extent 2.0 H, 0.12 s. The chamber light grows from energy 0.3 to 1.2 over the windup, and the ball carries its own light, energy 0.9 and extent 1.2 H, while it flies. The burst is energy 2.0, extent 2.4 H, height 0.2 H, 0.15 s. All of them light the carrier, the floor and the wall through their normal maps.

**Sound:** a hum that rises during the charge, a "whump" on launch, and a crackle on the burst.

## Rules and production

One chamber and one emitter ring, with no fasteners, brass, gold or legible text. The chamber is empty and the ring is dark in the base art, and the ball, glow and burst are effects, never painted onto the gun. Energy blue is for the shot; the tell is amber, then red, on the emitter ring only. Implants are shown as hardware, never as monstrous. Cut the gun as one part with its own normal map (green = up), with the glass chamber, emitter ring and seam lights as separate layers. Approve the neutral image before the carried studies, and check the gun at gameplay size in a Trooper's hands, on the Warden's palm and on the Sower's chest, in grayscale and against near-black backgrounds. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the carried study.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the "Lumen" plasma carbine, an AI's own weapon technology: a single gun on its own, with no hands and no carrier.
Scale: 0.78 m long and 0.26 m tall; the glass chamber is 0.14 m across and 0.30 m long.
Silhouette: a smooth, flowing carbine with a curved grip, a fat clear glass chamber above the barrel, and a ring-shaped emitter at the muzzle. It looks grown rather than assembled.
Physical design: a seamless pearl-white ceramic body with no visible fasteners, a curved grip, a clear pale glass chamber that is empty, a dark pearl emitter ring at the muzzle, and a few thin teal seam lines along the body. No brass, no visible logos.
Materials and colors: pearl white #E6ECEF body; dark #2E3B4E seam lines; pale blue-tinted glass #BFD8EE; dark pearl #C9D3DA emitter ring; small teal #3FE0D0 seam lights.
Critical consistency: one chamber, one emitter ring, no fasteners, no brass, no text or logos; the chamber is empty and the ring is drawn dark and unlit.
Show the carbine in strict side view with the muzzle pointing to the right.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no plasma ball, no muzzle flash, no blood. No hands, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — carried-in-hand study

Attach the approved neutral image as the visual reference. Request one of the two studies at a time.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved "Lumen" plasma carbine, draw one carried study in strict side view, of the study chosen: (a) the Trooper hold: an adult's right hand and forearm in a warm charcoal combat-shirt cuff and a black glove, gripping the curved grip, and the left hand under the glass chamber, in a level two-hand hold, forearms and hands only; or (b) the Heir palm: a pale ceramic adult right hand with the palm open toward the right edge, a ceramic disc set into the center of the palm holding a small empty round clear-glass chamber ringed by a slim vent ring, and teal seam lines along the fingers, forearm only. In (a) the carbine keeps the exact approved design, points to the right, and sits with its grip at the palm socket. Preserve the proportions, colors and part counts. No body and no head.

Flat mid-grey (#808080) background, evenly lit and flat-colored so the hands and the gun can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no plasma ball, no muzzle flash, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
