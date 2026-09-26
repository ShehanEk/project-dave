# DEAD EDEN — Camera, readability, and moment-to-moment feedback

**Document ID:** G04  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Gameplay camera behavior and the visual language for danger, surfaces, targets, and rewards.

**Decision references:** P02, P04, P16 — see the [decision register](../decisions.md).  
**Read with:** [player controls](player-controls.md) · [interface and accessibility](../05-presentation/interface-and-accessibility.md) · [audio direction](../05-presentation/audio-direction.md)

## Proposed camera behavior

Use a side-oriented camera with depth visible in the architecture. It follows the hero smoothly without changing the gameplay plane. Lead slightly toward movement or deliberate aim, but clamp that lead so reversing aim does not make the view jerk.

The ordinary view should show the next landing, nearby attack sources, and a useful retreat space. As a starting composition target, keep the hero around one-eighth of the visible screen height in traversal; tune per scene. Boss framing may widen, but not until the hero and weak points become unreadable.

## Vertical movement and transitions

Vertical climbs preview the destination before commitment. Prefer an upward reveal from a safe ledge to a camera jump while airborne. A falling camera follows enough to reveal recovery, not merely the hero's old height.

Short door and lift transitions may reframe on a safe platform. The player should not regain control already inside a new enemy attack. Respect the established checkpoint and one-way-exit rules.

## Visual hierarchy

| Meaning | Shape and motion cue | Additional support |
| --- | --- | --- |
| Safe standing surface | Broad continuous top edge and visible support | Contrasting material edge |
| Moving platform | Track, hinge, or root attachment plus previewed motion | Warning lamp or sound |
| Attack preparation | Enemy posture and weapon alignment | Short distinctive sound |
| Weak-point opening | Armor physically withdraws or body turns | Restrained highlight |
| Gem | Faceted compact shape with gentle sparkle | Short collectible sound |
| Artifact | Unique recognizable object with a quiet outline | Distinct discovery cue |
| Weapon pickup | Full weapon silhouette on a stable anchor | Name and comparison prompt |

Color reinforces meaning but never carries it alone. Enemy and hazard colors must not be identical to gem-trail cues when that would imply a safe route.

## Hits and effects

Confirm successful hits through a small flash, restrained impact particles, sound, and appropriate target response. Show blocked hits differently from missed shots. A shield spark must not look like full damage.

The hero's damage feedback includes a brief outline or blink and a clear health change. Avoid filling the screen with red or replacing level visibility with heavy blur. Camera shake, flashes, and hit pause have adjustable or reduced settings.

Weapon identity comes from recoil, timing, animation, and audio. The shotgun can feel heavy without violently moving the camera; the Arc Welder's chain should not become a solid luminous screen.

## Occlusion and background

Foreground leaves, cables, and architecture must move out of the way or become unobtrusive when covering the hero, a landing edge, a pickup, or a threat. Background robots do not suddenly become attack sources without an explicit on-plane reveal.

During complex boss transitions, reduce background motion and effect brightness. Fixed refuge ledges remain easy to locate even while center platforms move.

## What another AI should not infer

No first-person aiming, free 3D camera orbit, blind cinematic boss attack, forced motion blur, or cinematic quick-time event is approved. Dramatic concept art does not override the written side-view route.

## Review scenes

Test a Clinger above the hero, a Pollinator marker, shotgun knockback near a ledge, a moving bed under an Orderly, a dropped gun beside gems, and the final boss with one lingering hazard. Each scene must communicate the actionable information before spectacle.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
