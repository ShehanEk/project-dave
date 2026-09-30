# "Lantern" Seeker

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** EG08\
**Category:** enemy-guns\
**First appearance:** Level 8\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). This gun's name, look, colors and numbers are *proposed* (C27, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and carriers

**Maker:** Adam's own technology. The "Lantern" round is Adam's hunting ammunition: a small homing round that looks like a pale eye. It is a futuristic gun.

**Carried by:** [Keeper Drones](../machines/m07-keeper-drone.md), L8–L9 and L11, which release one from the bottom hatch of the lantern; and [the Sower](../mini-bosses/b04-the-sower.md) in phase two, which releases two from each vent opening. It is not hand-held, so it has no drop.

It teaches the homing round: a seeker can be jumped late, led into a wall or shot down.

## Look, size and socket

**Futuristic look:** a small pale "eye" round with three fins, trailing a thin wisp. The body is a smooth pale ceramic teardrop with a round lens at the nose, a dark iris and a small white pupil, and three curved fins around the tail.

**Size:** 0.20 m long and 0.10 m across, with a fin span of 0.14 m, about the length of an adult's hand. The two-door hatch under the Keeper Drone's lantern opens about 0.14 m across.

**Socket:** there is no hand grip. The launch ports are the Keeper Drone's lantern hatch (two doors under a frosted glass lantern) and the Sower's two rear vent ports. The muzzle marker sits at the center of the port, and the seeker sprite's origin sits at its center of mass. It leaves the port along the port's axis and then turns toward its heading.

**Colors (flat, unlit):** pale ceramic #E6ECEF body; #C9D3DA fins; dark #14181E iris with a small white pupil; a dark outline. The wisp is a thin pale blue-white line at low opacity.

## Fire pattern, tell and dodge

**Fire:** 1 seeker (2 from the Sower) at 3 H/s, turning at most 90 degrees per second (a turning radius of about 1.9 H). It lasts 2.5 s and then fizzles. 1 damage. One bolt of Dave's kills it. At most 2 alive.

**Tell (CHARGE):** the lantern glow grows amber, then red for the last 0.25 s, and a sonar ping sounds when the seeker locks on. The tell is on the launch port, never on the round.

**Dodge:** wait until it is close, then jump over it (it cannot turn tightly enough to follow), lead it into a wall, or shoot it down.

## Shot, light and sound

**Projectile:** a white-core finned shape with a dark outline and a short wisp. It has its own shape: a small finned teardrop, never a ball or a line. The lens is white, not red. Shots are never gold, violet, amber, red, teal or green.

**Muzzle-flash light (*proposed* preset):** soft round blue-white lights (white tinted with the energy edge), #DCEBFF, all at height 0.3 H. The launch pulse is energy 0.8, extent 1.0 H, 0.10 s. The seeker carries a faint light of its own, energy 0.4 and extent 0.6 H, while it lives. A shot-down seeker pops with energy 1.0, extent 1.0 H, 0.08 s, and a fizzle fades over 0.3 s. All light the carrier and the floor through their normal maps.

**Sound:** a whine that rises as it closes in, a sonar ping at lock, and a glassy pop when shot.

## Rules and production

One lens and three fins; no brass, gold or legible text. Adam's shots are strange but never fleshy: the round is ceramic, and its lens is white, never red. The wisp, glow and pop are effects, never painted onto the round. Cut the round as one small sprite with its own normal map (green = up) and a shootable hit zone; the launch hatch or vent belongs to its carrier. Approve the neutral image before the mounted study, and check the round at gameplay size in flight, in grayscale and against near-black backgrounds: it must read as a shot, not a pickup or a drone. The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35).

## Image prompt 1 — neutral side view

Copy the entire block into an image generator. Generate and approve this base design before requesting the mounted study.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the "Lantern" seeker, a small homing round from an AI's own weapon technology: a single round on its own, with no launcher and no carrier.
Scale: 0.20 m long and 0.10 m across, with a fin span of 0.14 m; about the length of an adult's hand.
Silhouette: a smooth teardrop with a round lens at the nose and three curved fins around the tail, like a pale eye with a tail.
Physical design: a seamless pale ceramic teardrop body, a round lens at the nose with a dark iris and a small white pupil, three curved fins around the tail, and a thin dark seam ring around the middle. No brass, no visible logos.
Materials and colors: pale ceramic #E6ECEF body; #C9D3DA fins; dark #14181E iris with a small white pupil.
Critical consistency: one lens, three fins, no fleshy details, no brass, no text or logos.
Show the round in strict side view with the nose pointing to the right, two fins visible and the third foreshortened behind.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no wisp, no muzzle flash, no blood. No launcher, no carrier, no airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, UI, watermark, text, logos, labels, measurement arrows or franchise props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — mounted study

Attach the approved neutral image as the visual reference.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved "Lantern" seeker, draw one mounted study in strict side view: the lower part of a small frosted glass lantern in a slim steel cage, seen from the side, with its two-door hatch open at the bottom (about 0.14 m across) and one seeker seated in the opening with its nose pointing down and to the right. The lantern is dark and unlit, and the seeker keeps the exact approved design at its true size. Show only the lantern's lower part, with no drone body. Preserve the seeker's proportions, colors and part counts.

Flat mid-grey (#808080) background, evenly lit and flat-colored so the lantern and the seeker can be cut apart: no baked shadows, no cast shadow, no highlights, no rim light, no glow, no wisp, no muzzle flash, no blood. No text, logos, labels, motion blur, cinematic framing or new equipment.
```

See [shared style guide](../style-guide.md), [asset index](../README.md) and [encounter and boss fairness](../../design/04-world/encounter-and-boss-fairness.md).
