# "Groundline" Arc Caster

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** EG06\
**Category:** enemy-guns\
**First appearance:** Level 6\
**Design status:** Look follows C60 (approved 2026-10-12): a painted HD gun sprite on a hand socket (C56), corporate cyberpunk (C58); every Arcadia gun is a sleek white-and-graphite product with the wordless Arcadia arch mark. Concept images are still to be generated. This gun's name, look, colors and numbers are *proposed* (C27, P23). Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Arcadia Dynamics. The "Groundline" is Rootworks power-line hardware, a grounding rod that Adam turns on people. It is a futuristic gun.

**Carried by:** [Linked Linemen](../linked/lk02-linked-lineman.md), L6–L7; [Howard Stroud](../mini-bosses/b02-howard-stroud.md), L6, as a striker head on his right cable arm; and [the Sower](../mini-bosses/b04-the-sower.md)'s stomp, L12, as striker plates on its feet. It drops on death as a static prop that Dave cannot pick up (Stroud's and the Sower's strikers are part of their bodies).

It teaches the floor arc: jump it, or stand on another platform.

## Look, size and socket

**Futuristic look:** a heavy insulated rod with a composite striker tip, wired to a back capacitor pack. On the Lineman the cables run in clean armored sleeves from the pack to cuff clamps at his wrists. The rod is dark rubber-insulated steel with pale composite bands, ending in a pale composite spike with a dark metal collar, and it trails its own short cable bundle from the rear grip to a plug socket on the carrier's pack.

**Size:** the rod is 1.25 m long and the striker tip 0.14 m, about two-thirds of the Lineman's height. The back capacitor pack belongs to each carrier's own rig (the Lineman's is a boxy gunmetal pack with a composite-capped terminal; Stroud's is a rack of three capacitors). Stroud's striker head is the same design at about 1.6 times scale, and the Sower's striker plates are the same design at about 3 times scale.

**Socket:** the grip origin sits at the rear third of the rod, where the weapon hand's palm socket meets it, with the support hand forward (drawn on the carrier's hand). The rod points down when it strikes. The arc origin marker sits at the striker tip. On Stroud the origin is his right wrist socket; on the Sower it is the center of each sole plate.

**Colors (flat, unlit):** steel #1C2A3A rod with rubber insulation; pale composite #DDE5EA bands and striker; small teal #3FE0D0 status lights, steady; a short black cable bundle.

## Fire pattern, tell and dodge

**Fire:** a crackling arc 0.4 H tall crawls along the floor at 5 H/s. It dies at a ledge, a wall or 6.5 H. 1 damage. Then a 1.4 s recharge, rooted. Stroud and the Sower send an arc each way.

**Tell (CHARGE):** the capacitor pack glow grows amber, then red for the last 0.25 s, with a rising buzz, and then the rod is rammed into the deck.

**Dodge:** jump it (it crosses Dave in about 0.2 s), or stand on another platform, since the arc cannot leave its floor.

## Shot, light and sound

**Projectile:** a jagged blue-white line with a white core and a #5AA9FF edge, re-jagged at 12 Hz (held static under reduced motion), plus sparks. It has its own shape: a crawling, jagged ground line, never a ball or a straight bolt. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** a soft round blue-white light (white tinted with the energy edge), #DCEBFF, energy 1.4, extent 1.8 H at the strike, height 0.2 H, one 0.12 s pulse. The crawling arc carries a small traveling light, energy 0.7, extent 1.0 H and height 0.15 H, that follows its head along the floor. Both light the carrier and the deck through their normal maps.

**Sound:** a rising buzz during the charge, the strike, then a snap when the arc dies.

## Rules and production

One rod and one striker tip; no brass, gold or legible text, and maker marks are plain stripes. The capacitor pack and lights are dark or small and steady in the base art, and the arc, sparks and glow are effects, never painted onto the rod. Energy blue stays out of the tell: amber and red are the only tell colors. Cables run in clean armored sleeves and never into the skin. Cut the rod as one part with its own normal map (green = up). Approve the neutral image before the carried study, and check the rod at gameplay size in a Lineman's hands, on Stroud's arm and as the Sower's sole plates, in grayscale and against near-black backgrounds. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the carried study.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish.

Design the "Groundline" arc caster, a futuristic power-line grounding rod turned into a weapon: a single tool on its own, with no hands and no carrier.
Scale: the rod is 1.25 m long and the striker tip 0.14 m; about two-thirds of an adult's height.
Silhouette: a long heavy rod with a thick insulated grip section, a pale composite spike at one end, and a short bundle of cables trailing from the rear.
Physical design: a dark rubber-insulated steel rod with pale composite bands, a pale composite spike with a dark metal collar at the tip, a rear grip with a small guard, and a short bundle of black cables ending in a plain plug (the capacitor pack is separate and not drawn). Small steady teal status lights on the grip. No brass, no visible logos.
Materials and colors: steel #1C2A3A rod with rubber insulation; pale composite #DDE5EA bands and spike; small teal #3FE0D0 status lights; black cables.
Critical consistency: one rod, one composite spike, no brass, no text or logos; the rod shows no glow.
Show the rod in strict side view, horizontal, with the spike pointing to the right.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and hand-painted so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no arc, no sparks, no blood. No hands, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — carried-in-hand study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved "Groundline" arc caster, draw one carried-in-hand study in strict side view: an adult's right hand and forearm in a broad slate rubber glove, gripping the rod at its rear grip, with two armored graphite cable sleeves running down the outside of the forearm to a cuff clamp and the rod's own short cable bundle trailing off the left edge of the frame; the left hand steadies the rod forward of the grip, in a two-hand hold with the composite spike pointing down and to the right, ready to strike the floor. Forearms and hands only, with no body and no head. The rod keeps the exact approved design and sits with its grip at the palm socket. Preserve the rod's proportions, colors and part counts. Show the cuff clamps as clean hardware, with nothing entering the skin.

Flat mid-grey (#808080) background, evenly lit and hand-painted so the hands and the gun can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no arc, no sparks, no blood painted in. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
