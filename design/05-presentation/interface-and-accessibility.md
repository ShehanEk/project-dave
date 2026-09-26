# DEAD EDEN — Interface and accessibility direction

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Document ID:** N03  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines the one-weapon HUD, swap and upgrade screens, journal, and adjustable presentation.

**Decision references:** C03, C04, C05, P15 — see the [decision register](../decisions.md).  
**Read with:** [weapon swaps](../01-core/weapon-swaps.md) · [camera and feedback](../01-core/camera-and-feedback.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md) · [upgrades and ownership](../03-progression/upgrades-and-ownership.md)

## Interface goals
Keep the world visible, the carried weapon unambiguous, and the next action understandable. This is a proposed screen/content specification, not a finished UI mockup or a claim of accessibility certification.

## Normal play HUD
| Element | Content | Behavior |
| --- | --- | --- |
| Health | Six large segments under the proposed health model | Clear partial loss and temporary immunity; shape plus value |
| Carried weapon | One icon, weapon name on change, stage 0–3 pips | Always exactly one equipped slot; no secondary silhouette |
| Resource | Shotgun loaded/reserve; Seedlobber ready/reserve; Arc heat; tether target/ready; pistol ready/charge | Only the current type's resource, using its own symbol |
| Gems | Current committed-or-current-run wallet count | Small increment on collection; cost subtraction when buying |
| Objective | One short current action | Expanded on request or milestone; no constant paragraph |
| Context prompt | The one highest-priority nearby interaction | Shows remapped input and target name; never swaps a gun automatically |
| Status | Short named effect and timer | Only while active; do not rely on hue alone |

A gem count reflects the current attempt until saved. The checkpoint indicator communicates the save boundary; do not show every unsaved gem as a separate currency. Artifacts appear as a brief discovered-item toast and are recorded in the journal.

## Weapon pickup comparison
When near a stable pickup pad, show **Held → On ground** with two clearly separated images, names, usable stages, and resources. Show the incoming type's already-earned upgrade stage where applicable.

Use an explicit action label: "Swap weapons — leave [current weapon] here." A short hold or press confirmation is configurable. No automatic exchange on contact, hidden second slot, or presentation that suggests both will be carried.

While comparing, keep the hero in the world. Pickups belong in safe spaces; do not rely on a menu to excuse hazardous placement. The screen may pause for detailed inspection in solo play, but resuming cannot complete an unconfirmed swap.

After swapping, the previous gun visibly appears in the same cradle. Clear the old comparison and display the new resources. A second deliberate interaction can swap back.

## Checkpoint and upgrade screen
Show the held weapon large enough to compare its next fittings. Present:
- Current stage and earned capability.
- Next stage's name, one-sentence effect, and appearance preview.
- Incremental gem price and wallet after purchase.
- A clear locked reason when a milestone or previous stage is missing.
- Actions: Buy next stage, inspect journal, settings, return to play.

There is no equip-from-collection action. A read-only five-type upgrade journal can explain progression, but cannot recover a dropped gun. Purchase confirmation is a gameplay transaction, not a separate real-money shop.

Service and saving confirmations are distinct from the upgrade purchase. An ordinary recovery station opens no purchase menu. Leaving a bench without buying remains a complete, valid action.

## Journal, pause, and completion
The journal has current objective, concise story recaps, discovered artifacts by level, encountered enemies, and read-only weapon knowledge. Mark a peaceful Rememberer's entry accordingly rather than classifying all patients as kill targets.

Pause shows Continue, Settings, Journal, Restart from checkpoint, and Quit. Restart and Quit explain that progress since the last committed checkpoint will be lost. A confirmation prevents an accidental restart; it does not need to interrupt ordinary play actions.

The completion screen shows campaign finished, artifact discovery, and gem/upgrade progress without implying that killing every patient is a goal. No ranked score or speedrun medal economy is included yet.

## Accessibility proposals
- Remap named actions for keyboard/mouse and controller. Provide sensitivity, aim assist strength, and independent horizontal/vertical inversion where useful.
- Support toggle/hold alternatives for repeated interactions and charging where behavior remains clear. No rapid button-mashing escape mechanic.
- Adjustable subtitle size, background opacity, speaker labels, and sound captions for important offscreen warnings.
- Separate master, music, effects, dialogue, and ambience volume.
- Adjustable screen shake, hit flash and background motion; offer reduced effects that preserve hazard boundaries.
- High-contrast interactive outlines, scalable HUD/text, and redundant shape/sound cues.
- Avoid essential red-versus-green distinctions. Keep text on solid-enough backing.
- Pause during dialogue; skip noninteractive scenes; replay essential information from the journal.
- Optional slower game speed and incoming-damage assistance can be offered as accessibility settings after their effects are specified. They are proposals, not additional campaign rules or punishment modes.

Do not make optional settings disable saving, artifacts, or story completion. Keep all UI readable over the brightest Sunnyvale and darkest medical backgrounds.

## Required later screen studies
Create separate studies for normal play with each of five weapons, a low-health warning, a weapon swap, upgrade preview and purchase result, artifact discovery, journal, checkpoint retry warning, and subtitle/danger-caption overlap. Use realistic strings and resource counts; do not fill screens with implementation terminology.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
