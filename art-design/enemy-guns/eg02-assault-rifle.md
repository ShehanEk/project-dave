# AR-7 "Warrant" Assault Rifle

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** EG02\
**Category:** enemy-guns\
**First appearance:** Level 3\
**Design status:** Look follows C60 (approved 2026-10-12): a painted HD gun sprite on a hand socket (C56), corporate cyberpunk (C58); every Arcadia gun is a sleek white-and-graphite product with the wordless Arcadia arch mark. Thornwall's guns are matte charcoal. Concept images are still to be generated. This gun's name, look, colors and numbers are *proposed* (C27, P23). Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Arcadia Dynamics' defense division (the AR-7 "Warrant" carbine). Thornwall's rifles are the same silhouette in its own matte charcoal finish: the TK-12.

**Carried by:** the [Rifleman](../security/se04-rifleman.md), as Arcadia's Response Team at L3 and as a Thornwall man from L4 to L9; and the [Gun Hound](../hounds/k02-gun-hound.md)'s back mount, L5–L6. Any enemy can carry it. It drops on death as a static prop that Dave cannot pick up.

It is Thornwall's workhorse gun and teaches the burst: one relaxed jump per burst, with a ground beat between.

## Look, size and socket

**Futuristic look:** a sleek compact graphite-and-white bullpup with a glowing ammo readout, a small wordless Arcadia arch mark on the cheek and a long flat muzzle shroud. The readout is a thin window of small, steady teal-white bars on the receiver side that drop as it fires; it is never a tell. The muzzle lamp at the shroud's tip is the tell and stays dark until it glows. Thornwall's TK-12 is the same shape in matte charcoal with a plain dark grip wrap on the foregrip and stock and a dark cover over the readout window (Thornwall gear shows no teal).

**Size:** 0.68 m long and 0.24 m tall, a little over a third of an adult carrier's height. On the Gun Hound the same sprite is rigged to a back mount, with its muzzle 0.3 H above the floor.

**Socket:** the grip origin sits at the pistol grip, forward of the magazine housing (a bullpup), where the weapon hand's palm socket meets it; the gun rotates about this point to aim. The muzzle marker sits at the muzzle lamp. The support-hand point sits on the foregrip under the shroud (drawn on the carrier's support hand).

**Colors (flat, unlit):** graphite #2A3341 body; white #DCE0E3 shroud and cheek trim; dark #1C2A3A magazine housing and lamp; small teal-white readout bars. Thornwall's finish is matte charcoal #25272A with a dark grip wrap.

## Fire pattern, tell and dodge

**Fire:** 3-round bursts, 0.08 s between rounds and 0.9 s between bursts (about 1.06 s start to start), with 2 bursts per volley at L3–L4 and 3 from L5. 8.5 H/s, 1 damage, 6.5 H range. Rounds fly flat at 0.5 H (dogs 0.3 H) with a fixed ±0.04 H jitter. The carrier turns to face Dave only between bursts. Then a 1.6 s magazine swap, rooted. Up to 3 rounds alive.

**Tell (GLOW):** the muzzle lamp glows amber, then red for the last 0.25 s before the first burst, with a 0.2 s red blink before each later burst.

**Dodge:** one relaxed jump per burst with a ground beat in between, or stand behind a low crate. Close in during the magazine swap.

## Shot, light and sound

**Projectile:** three short ivory tracers per burst (tracer ivory #F2EBD3), each with a dark outline. No casings. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** a soft round light in ivory #F2EBD3, energy 1.1, extent 1.8 H, height 0.3 H, one held glow per burst for 0.25 s with a 0.05 s fade. One flash per burst, never a strobe. It lights the carrier through its normal maps.

**Sound:** one "brrt" per burst, and a magazine clatter on the swap.

## Rules and production

One barrel shroud; no scope, brass, gold or legible text, and the maker mark is the wordless Arcadia arch. Arcadia's and Thornwall's versions share one silhouette and differ only in finish (make Thornwall's as a re-skin of the same part). The lamp and readout are dark or small and steady in the base art, and the flash and tracers are effects, never painted onto the gun. Cut the gun as one part with its own normal map (green = up). Approve the neutral image before the carried study, and check the gun at gameplay size in the carrier's hands, in grayscale and against near-black backgrounds. The carried study shows Thornwall's cuff; for the Arcadia Response Team's Rifleman, recolor the cuff Arcadia navy (#2A3B5C). The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the carried study.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish.

Design the AR-7 "Warrant" assault carbine, made by a corporate defense division: a single gun on its own, with no hands and no carrier.
Scale: 0.68 m long and 0.24 m tall; a little over a third of an adult's height.
Silhouette: a compact bullpup carbine with the magazine behind the grip, a short stock cheek, and a long flat muzzle shroud extending well past the receiver.
Physical design: a graphite receiver with white trim on the shroud and cheek and a tiny wordless arch mark; a foregrip under the shroud; a thin window of small teal-white ammo bars on the receiver side; a plain round lamp at the tip of the shroud, dark. No scope, no brass, no lettering.
Materials and colors: graphite #2A3341 body; white #DCE0E3 shroud and cheek trim; dark #1C2A3A magazine housing and lamp; small teal-white readout bars.
Critical consistency: one barrel shroud, no scope, no brass, no text or lettering; the muzzle lamp and readout are small and unlit.
Show the carbine in strict side view with the muzzle pointing to the right.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and hand-painted so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no blood. No hands, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — carried-in-hand study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved AR-7 "Warrant" carbine, draw one carried-in-hand study in strict side view: an adult's right hand and forearm in a charcoal combat-shirt cuff (#3E4043) and a black glove, gripping the pistol grip, and the left hand on the foregrip under the shroud, in a shouldered two-hand stance. Forearms and hands only, with no body and no head. The carbine keeps the exact approved design, points to the right, and sits with its grip at the palm socket. Preserve the carbine's proportions, colors and part counts.

Flat mid-grey (#808080) background, evenly lit and hand-painted so the hands and the gun can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no muzzle flash, no projectile, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
