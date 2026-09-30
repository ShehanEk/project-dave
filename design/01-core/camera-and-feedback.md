# DEAD EDEN — Camera, readability, and moment-to-moment feedback

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** G04  
**Status:** Working design proposal. Confirmed decisions and the established baseline remain constraints; new details and numbers are untested proposals.  
**Purpose:** Gameplay camera behavior and the visual language for danger, hits, blood, lighting, surfaces, targets, and rewards in dark scenes, with reduced-flash and reduced-motion rules.

**Decision references:** C15, C16, C27, C28, C29, C35, P02, P04, P16, P20, P21, P23 — see the [decision register](../decisions.md).  
**Read with:** [player controls](player-controls.md) · [interface and accessibility](../05-presentation/interface-and-accessibility.md) · [audio direction](../05-presentation/audio-direction.md) · [style guide](../../art-design/style-guide.md) · [objects and hazards](../04-world/objects-and-hazards.md) · [enemy states, blood and corpses](../04-world/status-and-enemy-states.md) · [encounter and boss fairness](../04-world/encounter-and-boss-fairness.md)

## Proposed camera behavior

Use a fixed side-oriented 2D camera; overlapping drawn scenery and optional parallax suggest depth. Character sprites and collisions stay on the action plane. It follows the hero smoothly without changing the gameplay plane. Lead slightly toward movement or deliberate aim, but clamp that lead so reversing aim does not make the view jerk.

The ordinary view should show the next landing, nearby attack sources, and a useful retreat space, all lit enough to read. As a starting composition target, keep the hero around one-eighth of the visible screen height in traversal; tune per scene. Boss framing may widen, but not until the hero and weak points become unreadable.

Enemy guns are part of the same readability promise. A shooter fires only when it is at least 1 H (one hero height) inside the camera rectangle, so Dave is never shot by something he cannot see. This is a readability gate, not detection (see below).

## Vertical movement and transitions

Vertical climbs preview the destination before commitment, and the destination is lit. Prefer an upward reveal from a safe ledge to a camera jump while airborne. A falling camera follows enough to reveal recovery, not merely the hero's old height.

Short door and lift transitions, including keycard exit doors, may reframe on a safe platform. The player should not regain control already inside a new enemy attack. Respect the established checkpoint and one-way-exit rules.

## Visual hierarchy

| Meaning | Shape and motion cue | Additional support |
| --- | --- | --- |
| Safe standing surface | Broad continuous top edge and visible support | Lit or rim-lit edge, with a light near every landing |
| Moving platform | Track, hinge, or cable attachment plus previewed motion | Amber warning lamp or sound |
| Attack preparation | Enemy posture and weapon alignment | A large glow on the attacking part (baton tip, muzzle lamp, hands, collar, emitter) ramps up amber, then turns alarm red for the last 0.25 s; rail and beam weapons show a sight line first; a windup sound |
| Incoming enemy shot | Short ivory tracer with a dark outline; energy shots have a white core, a blue edge and a dark ring | Muzzle-flash light at the source; a shot is never gold, violet, amber, red, teal or green |
| Weak-point opening | Armor physically withdraws or body turns | Restrained highlight, distinct from alarm-red tells |
| Blood and bodies | Spray, pools and corpses on the floor line, below everything that matters | Never glows, never uses a tell color, always falling or lying flat |
| Lockdown event | Calm PA announcement, then previewed door, shutter or platform motion | Amber warning lamps first, alarm red as the change happens; sound |
| Cover | Low crate (0.6 H) or tall pillar or overhang (at least 1.2 H, or 1.1 H of headroom), each with a lit top edge | Cover positions per [W03](../04-world/objects-and-hazards.md) |
| Microchip | Compact square chip with gold contacts | Gold glint and short collectible sound |
| Evidence file | Recognizable document or device with a quiet outline | Pale rim light; distinct discovery cue |
| Keycard and exit door | Flat card silhouette with a lit edge; the door reader shows locked or open by shape as well as light | Distinct pickup sound; HUD keycard indicator; object designs in [W03](../04-world/objects-and-hazards.md) |
| Weapon pickup | Full weapon silhouette on a stable anchor | Name and comparison prompt |

Color reinforces meaning but never carries it alone. Follow the style guide's reserved meanings: alarm red (#FF3B4E) for the last quarter-second of an attack tell and for alerts, hazard amber (#FFB02E) for the tell's ramp, warnings and Adam's attention, Arcadia teal (#3FE0D0) for Arcadia and Adam at rest, Bloom violet (#C77DFF) only for the Bloom, and microchip gold (#FFD166) for pickups. Blood is a separate, darker red and never borrows those meanings. Enemy and hazard colors must not be identical to microchip-trail cues when that would imply a safe route.

## Hits, blood and effects

Confirm every successful hit with a small flash, a spray that fits the target's material, sound, and an appropriate response (a stagger, and knockback for heavy hits). Show blocked hits differently from missed shots: a shield or armor deflection is a spark and a ring of metal or ceramic sound, never blood. The green hit spark is suppressed on anything that has a fluid, so a hit on a person reads as blood and a hit on a machine reads as sparks and oil.

**Blood by material** *(C29; full rules in [W02](../04-world/status-and-enemy-states.md))*:
- People and dogs bleed red (wet #B3212F with two or three pale highlight drops, drying to #8A1A26). The Linked also throw white sparks at the implant, and their Link light dies.
- Machines throw sparks and leak black oil (#14181E with a #46566A sheen rim).
- Heirs drip grey-rose lymph (#A88A8C), under gravity only.
- Blood is never gold, violet, teal, amber or green. There is no dismemberment for now.

**Deaths and bodies:**
- A death is a bigger spray plus a ragdoll: the painted parts become physics bodies pushed by the killing shot. Machines and bosses burst into debris parts instead.
- A floor pool spreads under a dead person or dog over about 1.5 seconds.
- Bodies stay. They lie as low, non-solid drawings that never hide a pickup, a landing or a tell.
- Dave bleeds too: a short red spray at the hit point, with no pool.

**Blood readability rules** *(proposed; check in captures with the night overlay on)*:
- **Layering:** pools sit just above the floor line, below characters, tells, shots and pickups. They never cover a landing edge, a ledge or a pickup, and a corpse is never placed over one.
- **Never a tell:** blood is drawn with normal blending, never glows or pulses, and is always darker than the red tell. A spray lasts at most 0.4 seconds, so nothing red lingers on a living enemy.
- **Contrast:** pools stay visible at night, roughly 2.2 to 3.0 to 1 against the night palette.
- **Placement:** pools are at most 1.2 H wide and appear only on static floors, never on moving platforms or over pits. Each area keeps at most 24, and the oldest goes first.
- **Never on the interface:** no blood on the screen or the HUD.
- **Blood setting:** with Blood off, sprays become dark dust and pools and blood overlays are hidden ([N03](../05-presentation/interface-and-accessibility.md)).

**The hero's damage feedback** includes a brief outline or blink, a clear health change and the red spray above. Avoid filling the screen with red (alarm red belongs to tells and alerts) or replacing level visibility with heavy blur. An enemy projectile hit uses half the usual knockback ([G02](player-controls.md)).

**Camera shake and hit pause.** The camera shakes only when Dave takes a 2-damage hit (a rail or plasma direct hit, a heavy strike), and never under reduced motion. Dave's own weapons and enemy deaths do not shake it. Camera shake, flashes, and hit pause have adjustable or reduced settings.

Weapon identity comes from recoil, timing, animation, and audio. The shotgun can feel heavy without moving the camera; the Arc Welder's chain should not become a solid luminous screen.

## Lighting *(C35)*

Characters are lit in the engine rather than painted lit. Each painted part has flat base colors and a matching normal map, so lamps, screens and muzzle flashes light the enemies and Dave with smooth, realistic light. This amends C11's flat, hard-edged light pools; the style guide owns the palette and lighting rules. Until the user approves the look, treat it as confirmed direction, validated by the approved lit-cutout test (2026-09-30).

- **Muzzle-flash lights:** every gun has its own short-lived light that briefly lights nearby surfaces, parts and bodies, without hiding a tell, a landing or a pickup. Enemy muzzle flashes are ivory. Dave's weapons keep their own colors.
- **Rapid fire:** a rifle burst or the rotary is one held glow, never a strobe.
- **Shadows** are engine-made and soft (*proposed*). They never darken a landing edge, a tell, a weak point or a pickup.
- **Amber and red:** a driven or hunting body shows only a small, dim, steady amber point (the Link light of a driven body, the lens of a hunting machine). That point is not a tell. The tell is the large glow on the attacking part.

## Dark-scene readability *(proposed)*

The game is dark on purpose (C15). Darkness supplies mood and light supplies information, so the action plane is never hard to read.

- **Characters:** every character gets a rim light or a heavier outline on the side facing its nearest light, so the silhouette separates from the background. Dave's burnt-orange jacket keeps the hero readable against cool darks. Machines add lens glow, the Linked their small amber Link light, Heirs their teal seams, dogs a lens eye, guards and contractors reflective tape and gear lamps (the Marksman's visor glint), and bosses a larger rim plus a lit weak point.
- **A light near every landing:** every landing has a lamp, screen, sign, LED strip or glow close enough to light its top edge. This covers platform ends, moving-platform stops, recovery and refuge ledges, pit-recovery footholds and checkpoints. A lit destination is visible before the player commits to a jump.
- **Tells:** attack tells are an amber glow that ramps up and turns alarm red for the last 0.25 seconds, plus a posture or motion cue and a sound, and are brighter than their surroundings. Blood, fog, foreground props and effects never cover them.
- **Weak points and pickups:** an exposed weak point is lit (a vent, lens or implant glow) and shows the opening through shape and movement as well as light. Microchips glint gold and other pickups keep their own silhouettes and lights, so nothing needed to progress sits in unlit space.
- **Steady versus flickering light:** flicker belongs to decorative lights such as signs, holographic billboards, LED walls and failing background lamps. They blink on slow, independent cycles and never use alarm red or pickup gold, so they cannot pass for a tell or a pickup. A light that marks a landing or platform edge stays steady, even on a flickering fixture: the fixture's glow may flicker, but its lit edge does not.
- **Fog and mist:** ground fog, cooling mist and steam are flat, low bands behind or below the action plane, never across a landing edge, tell or pickup.
- **Value layering:** background layers stay darker and lower in contrast than the action plane. Glows and effects never outshine the tells and platform edges they sit near.
- **When Adam kills the lights:** the ambient light dies, but landing lights and platform edges hold, or switch to a dim steady emergency lamp. A lockdown darkens the mood, never the route.
- **Visibility options:** the interface document ([N03](../05-presentation/interface-and-accessibility.md)) owns a brightness slider that moves only the dark end, and a high-contrast outline toggle. Every tell, weak point, landing and pickup must stay readable at the Default and Dimmer settings.

Review each scene at gameplay size, in grayscale and with the brightness turned down. Platforms, threats, shots, pickups and the hero must still separate, with and without blood.

## Reduced-flash and reduced-motion rules *(proposed)*

Emergency strobes, alarms, sparks and electric arcs are part of the mood, but none may become a photosensitivity risk. These are proposed design targets to check with a flash-analysis tool before release, not a certification claim.

- **Ceiling:** no effect flashes more than three times in any one second, and nothing flashes across the full screen. A strobe stays inside a bounded light pool or at the screen edge.
- **Red emergency strobes** (in the Rootworks) are background lights. They pulse slowly, about once per second at most, and never sit on a landing, a platform edge or a tell.
- **Alarms** (sirens, the Peacekeeper's lightbar, lockdown sequences) pair a light with a sound. The light swells and holds rather than strobing, and any screen-edge tint is soft and partial.
- **Attack tells** are a posture change plus a steady lit cue that ramps up. A tell never depends on a fast flash to be seen.
- **Effects:** muzzle flashes, hit flashes and Arc Welder chains stay small, brief and bounded (see Hits, blood and effects). Rapid fire is one held glow, never a per-round strobe. Arc Caster arcs re-jag at 12 Hz, changing the line's shape rather than its brightness, and stay static under reduced motion. Lasting hazards such as plasma balls and beams read as steady glowing shapes with a slow shimmer, never a strobe.
- **The reduced-flash setting** (owned by [N03](../05-presentation/interface-and-accessibility.md)) replaces every remaining strobe, screen flash and rapid flicker with a steady or slowly fading light of the same color and meaning, holds billboard and lamp flicker still, and shrinks flash size and brightness. A tell's timing then moves to posture, sound and a steady outline pulse; the setting never removes or delays a tell.
- **Reduced motion** removes camera shake entirely and holds arcs static. Hit pause and background motion keep their own adjustable settings.

## Adam's lockdown events *(proposed, P20)*

Adam reacts to Dave by sealing doors, killing lights, rerouting machines, moving shutters and platforms, and making pleasant PA announcements. Every lockdown event is an authored beat, never a random rearrangement, and it is always telegraphed in this order:

1. **Announcement:** a calm PA line, also captioned, says in plain words what is about to happen.
2. **Warning:** amber warning lamps and a sound cue mark the door, shutter or platform that will move.
3. **Preview:** the motion starts slowly enough to read, and its destination is lit.
4. **Change:** alarm red appears only while the change is happening (danger now), then settles into the new layout.

These rules protect the player:
- Nothing moves under a landing the hero is standing on. Movement happens ahead of Dave or behind a safe threshold.
- A lockdown never closes the last route. A lit recovery lane, ledge or station always remains, and a fight it locks is a locked arena with the [supply safety net](../03-progression/ammunition-and-resupply.md).
- The warning leaves time to react: at least the warning time of a heavy attack (about 0.6–1.0 seconds, see [W02](../04-world/status-and-enemy-states.md)), and longer for anything that changes footing or could trap Dave (proposed: about 2 seconds, untested).
- At most one lockdown change is active at a time, and a lockdown never hides a tell, a weak point or a landing. Dim the scenery, not the light on them.
- Lockdowns fire from authored triggers such as a position, an objective or a story beat. They are not a reaction to being seen.

## No detection feedback (C16)

The game has no stealth or detection system. There are no vision cones, alert meters, question or exclamation marks over enemies, "spotted" stings, search states, noise indicators or hiding prompts. The small dim amber point on a driven or hunting body, and the amber-then-red glow on an attacking part, are combat cues drawn on the body, not a detection meter. The rule that a shooter fires only when it is 1 H inside the camera is a readability gate, not an awareness state: nothing changes on the enemy when Dave "is noticed". Adam's watching shows up only through PA lines, screens and telegraphed lockdown events, never as an indicator that Dave was noticed.

## Occlusion and background

Foreground cables, railings, glass, fog, steam and architecture must move out of the way or become unobtrusive when covering the hero, a landing edge, a pickup, or a threat. Background machines do not suddenly become attack sources without an explicit on-plane reveal.

During complex boss transitions, reduce background motion and effect brightness. Fixed refuge ledges remain easy to locate and stay lit even while center platforms move.

## What another AI should not infer

No first-person aiming, free 3D camera orbit, blind cinematic boss attack, forced motion blur, or cinematic quick-time event is approved. There is no stealth or detection feedback (C16). Dramatic dark concept art does not override the written side-view route or the readability rules above. Smooth engine lighting on flat-painted parts is the direction (C35); painted-in lighting or baked shadows on enemy art, photoreal volumetric fog, airbrushed glow and glossy chrome are outside the style. No dismemberment is approved.

## Review scenes

Test a Security Drone's dive mark, a Rifleman burst against a low crate, a Heavy Gunner's stream with and without cover, a Sentry Turret and high cover, a Marksman's sight line, a Grenadier's frag landing spots, shotgun knockback near a ledge, a moving bed under an Orderly, a dropped gun beside microchips, a blood pool beside a pickup with Blood on and off, a lockdown event in which the lights die while the landings stay lit, a red emergency strobe with the reduced-flash setting on, an arc under reduced motion, and the final boss with one lingering hazard. Each scene must communicate the actionable information before spectacle.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
