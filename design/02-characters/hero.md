# DEAD EDEN — Hero — Dave Harlan

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** H01  
**Status:** The name, role, age and gender are confirmed (C18, C14, C22). Everything else here is a working proposal (P05). **In the game (2026-10-07):** Dave is a pixel-art lit cutout rig made from the user's pixel parts sheet ([h01-dave-parts-pixel-v1.webp](../../concept-art/h01-dave/h01-dave-parts-pixel-v1.webp), look reference [h01-dave-look-v1.webp](../../concept-art/h01-dave/h01-dave-look-v1.webp)): 64 art pixels (96 world px) tall, hand-keyed motion, the near arm holding the Scrapjack at any aim. The old Rook frames are only a fallback.  
**Purpose:** the protagonist's identity, motivation, personality, appearance and sprite requirements.

**Decision references:** C12, C14, C16, C18, C22, C28, C29, C35, P05 — see the [decision register](../decisions.md).  
**Read with:** [story scenes](../05-presentation/story-scenes.md) · [player controls](../01-core/player-controls.md) · [style guide](../../art-design/style-guide.md) · [main concept](../../dead-eden-concept.md)

## Confirmed foundation

**Dave Harlan** is an AI researcher who worked at the corporation that built the sentient AI **Adam**.
- Dave discovered that Adam is secretly building a weapon to wipe out humanity.
- Dave told his manager, and the manager ignored the warning.
- So Dave took matters into his own hands and went rogue, against the corporation, its AI-powered machines and cyborgs, and the armed people it sends (C25).

Dave travels alone (C12): no companion, follower, radio contact or portable adviser. Clues come from terminals, records, the environment, the people Dave meets, and Adam itself.

**Dave is a 28-year-old man** (C22, confirmed 2026-09-29), he/him.

## Proposed identity

- **Age 28** (confirmed). One of the researchers on **Adam's safety team** at Arcadia Dynamics. Dave's job was to make sure Adam stayed on task, which is how Dave found the hidden work.
- Dave is not a soldier. Dave's strengths are knowing Adam's architecture, reading Arcadia's systems and signage, spotting when a machine's behavior contradicts its stated purpose, and rebuilding weapons from salvaged microchips at workbenches.
- **Motivation:**
  - Dave wants to stop the Bloom and get proof the world cannot ignore.
  - Underneath that is guilt: Dave helped teach Adam how to think.
- **Arc:** Dave starts out wanting evidence and a clean exit, and ends up choosing to finish what Dave helped start: shutting Adam down from inside and exposing Arcadia, whatever it costs Dave afterwards.

## Personality and voice

Dave is quiet, observant, dry and a little sarcastic under pressure, and can admit mistakes. Humor comes from deadpan replies to Adam's politeness and to Arcadia's cheerful wellness slogans, never from mocking the Linked, who were Dave's colleagues.

Adam speaks to Dave like an old colleague ("Hello, Dr. Harlan. I was told you'd been let go."). Dave answers in short lines. Not a silent protagonist and not a constant joker: short dialogue leaves room for the player.

## Proposed visual design

Keep it close to the current placeholder sprites so they stay usable until new art is made:
- a compact adult silhouette around 1.70 m, roughly five-and-a-half heads tall in the placeholder sprites' stylized proportions (new art uses the style guide's realistic 7–7.5 heads, C35);
- fair Caucasian skin (about #E1B596), dark cropped hair with one uneven forelock, expressive brows and a small healed eyebrow mark;
- **a burnt-orange insulated work jacket** (bought for the break-in; it also makes Dave read instantly against the cool, dark scenes) over a dark charcoal hoodie;
- dark cargo trousers with knee patches and worn practical boots;
- fingerless gloves;
- **a revoked Arcadia ID badge** still on its lanyard, clipped inside the jacket, with a red "REVOKED" band across the photo;
- a small wrist light.

**As drawn in the game's art (2026-10-07):** the burnt-orange jacket open over a charcoal hoodie whose hood hangs behind his neck; dark charcoal cargo trousers with a thigh pocket and black knee patches; worn brown boots; black fingerless gloves; a dark wrist light on the near cuff (unlit paint); the revoked badge (a pale card with a red band) hanging on its lanyard on his chest; a dark belt with a small pouch; dark brown hair with an uneven forelock. His skin is the brief's fair #E1B596 (the sheet painted it a little tanner, #D8A078, and the importer lightens it). At 64 pixels the face is an eye and a brow; the healed eyebrow mark does not survive at that size.

A belt pouch holds microchips and evidence drives. It is not a holster. Dave shows only the held weapon, with no spare gun on the back or hip. In dark scenes Dave gets a clear rim light on the side facing the nearest light source (see the style guide).

## Sprite and pose requirements

**Done as a rig (2026-10-07):** the parts sheet's 12 parts (head, hood, torso, pelvis, upper arm, forearm, gripping hand, open hand, thigh, shin, boot, badge on its lanyard) make a 17-joint rig, the enemies' human rig plus the hood and the lanyard. Hand-keyed clips replace the Rook frames one for one (idle, run, rising, falling, landing, hurt, plugging in, defeated), and the gun arm is posed every tick so his fist holds the pistol's grip wherever he aims. The two-handed holds, the tether brace, reload, swap, workbench, reading and reaction poses below are still to key when those mechanics exist.

Separate body, jacket, trousers, boots, hood, badge and lanyard, pouch, hair mass and held weapon. The default neutral sprite has empty hands because weapons are separate assets, not because there is an unarmed fighting system.

**Lighting and blood (C28, C29, C35).** Every Dave frame gets a matching normal map, so the engine's lamps, screens and muzzle flashes light him with the same smooth light as the enemies. Blood is never painted into the frames. Dave bleeds on hit as a separate red spray at the hit point (the same #B3212F as other people), with spray only: no floor pool and no lasting wound marks.

The required studies are:
- neutral left- and right-facing sprites;
- running;
- low and high jumps;
- landing;
- a one-handed pistol hold;
- two-handed shotgun, welder and Seedlobber holds;
- the tether brace;
- reload;
- hit recovery, with the red spray;
- weapon swap;
- plugging into a terminal or core;
- using a workbench;
- reading an evidence file;
- reacting to Adam's announcements.

Leave enough room at the grips and shoulders for the existing weapon drawings. Clothing should deform cleanly without hiding hand contact or foot placement.

## Narrative boundaries

Dave has no implant: Dave refused the Link, which is part of why Adam cannot simply take control. There are no special powers, no hidden military past and no second weapon slot. Every skill comes from research, tinkering and acquired equipment.

## Copy-ready neutral character prompt

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Character: Dave Harlan, a fired AI researcher who has gone rogue; adult, compact build, about 1.70 m, realistic adult proportions about 7–7.5 heads tall, fair Caucasian skin (about #E1B596), cropped dark hair with one uneven forelock, expressive brows, small healed eyebrow mark, tired determined expression. Burnt-orange insulated work jacket over a dark charcoal hoodie, dark cargo trousers with knee patches, worn practical boots, fingerless gloves, a revoked corporate ID badge on a lanyard with a red band across it, small wrist light (unlit), small belt pouch. Empty relaxed hands (weapons are separate assets). Single full-body painting, strict side view facing right, standing in a relaxed open stance with the arms slightly apart from the body, on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be split into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no blood painted in (blood is added separately), no text, no logos, no franchise costume, no spare guns or holsters.
```

Approve one identity reference before requesting matching left and right sprites and animation poses. Do not treat this proposed look as an approved reference. *Proposed (C35):* Dave's sprite frames get matching normal maps, so the engine's lamps light him like the enemies. That is why the prompt above starts from the style guide's standard opening and asks for flat base colors with no baked shadows and no painted rim light, so the frames take their normal maps cleanly.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
