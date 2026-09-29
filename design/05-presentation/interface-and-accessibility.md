# DEAD EDEN — Interface and accessibility direction

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** N03  
**Status:** Working design proposal. The premise, Adam, Dave Harlan and microchips are confirmed (C14, C17–C19), and so is visible blood (C29). The Blood setting, new names, details and numbers are *proposed* and untested.  
**Purpose:** defines the one-weapon HUD, microchip counter, keycard indicator, swap and upgrade screens, the evidence-file journal and adjustable presentation, including the Blood setting and dark-scene accessibility options.

**Decision references:** C04, C05, C15, C19, C28, C29, P15, P19, P21 — see the [decision register](../decisions.md).  
**Read with:** [weapon swaps](../01-core/weapon-swaps.md) · [camera and feedback](../01-core/camera-and-feedback.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md) · [upgrades and ownership](../03-progression/upgrades-and-ownership.md)

## Interface goals
Keep the world visible, the carried weapon unambiguous, and the next action understandable. This is a proposed screen/content specification, not a finished UI mockup or a claim of accessibility certification. The interface has to work over dark scenes without becoming bright noise: panels are compact, backed in near-black, and drawn from the palette below.

## Interface palette (*proposed*, from P21)
| Token | Hex | Interface use |
| --- | --- | --- |
| Night | #07090F | Text backing and the deepest panel fill |
| Navy | #0E1726 | Panels, journal pages, menu backgrounds |
| Steel | #1C2A3A | Panel borders, empty health segments, inactive controls |
| Slate | #2E3B4E | Dividers, disabled controls, the empty keycard outline |
| Arcadia teal | #3FE0D0 | Focus highlight, "progress saved", keycard held, terminal and Adam screens |
| Hazard amber | #FFB02E | Warnings, status effects, the "card required" prompt |
| Alarm red | #FF3B4E | Low-health warning, danger captions, alarms |
| Bloom violet | #C77DFF | Reserved for the Bloom, such as journal diagrams of the weapon; never a general accent |
| Microchip gold | #FFD166 | Microchip counter and pickup glints |
| Dave orange | warm burnt orange | Dave's marker in journal recaps |

Every color is paired with a shape, icon or word, so no meaning depends on hue alone. Blood, oil and lymph tones are world colors only: they never appear on the HUD, and no blood is drawn on the screen.

## Normal play HUD
| Element | Content | Behavior |
| --- | --- | --- |
| Health | Six large segments under the proposed health model | Clear partial loss and temporary immunity; shape plus value |
| Carried weapon | One icon, weapon name on change, stage 0–3 pips | Always exactly one equipped slot; no secondary silhouette |
| Resource | Shotgun loaded/reserve; Seedlobber ready/reserve; Arc heat; tether target/ready; pistol ready/charge | Only the current type's resource, using its own symbol |
| Microchips | Current committed-or-current-run wallet count beside a small gold chip icon | Small increment on collection; cost subtraction when buying |
| Keycard *(proposed)* | A card-shaped indicator: an empty outline until this level's clearance card is held, then filled teal with a checked corner | Shown only in levels with a keycard exit (L1–L11) and hidden in L12. It is not an inventory slot and never touches the weapon slot |
| Objective | One short current action | Expanded on request or milestone; no constant paragraph |
| Context prompt | The one highest-priority nearby interaction | Shows remapped input and target name; never swaps a gun automatically |
| Status | Short named effect and timer | Only while active; do not rely on hue alone |

A microchip count reflects the current attempt until saved. The checkpoint indicator communicates the save boundary; do not show every unsaved microchip as a separate currency. Evidence files appear as a brief discovered-item toast and are recorded in the journal. The keycard indicator follows the same save boundary: a card collected after the last checkpoint empties again on retry, just like the wallet, and the indicator resets at the start of the next level.

**Keycard prompts** *(proposed)*: at a keycard door, the context prompt reads "Use keycard" and the door name when the card is held. Without it, the prompt reads "Keycard required" in amber with a padlock icon, and the empty indicator pulses once. Neither is a damage or failure state.

There is no kill counter, no score and no on-screen reward for a kill (C28).

A launch countdown, if a scene shows one, is a story display on Adam's screens and in the journal recap. It never becomes a HUD timer or a limit on play.

## Weapon pickup comparison
When near a stable pickup pad, show **Held → On ground** with two clearly separated images, names, usable stages, and resources. Show the incoming type's already-earned upgrade stage where applicable.

Use an explicit action label: "Swap weapons — leave [current weapon] here." A short hold or press confirmation is configurable. No automatic exchange on contact, hidden second slot, or presentation that suggests both will be carried.

While comparing, keep Dave in the world. Pickups belong in safe spaces; do not rely on a menu to excuse hazardous placement. The screen may pause for detailed inspection in solo play, but resuming cannot complete an unconfirmed swap.

After swapping, the previous gun visibly appears in the same cradle. Clear the old comparison and display the new resources. A second deliberate interaction can swap back.

## Checkpoint and upgrade screen
Show the held weapon large enough to compare its next fittings. Present:
- Current stage and earned capability.
- Next stage's name, one-sentence effect, and appearance preview, including any re-flashed microchip module on the weapon.
- Incremental microchip price and wallet after purchase.
- A clear locked reason when a milestone or previous stage is missing.
- Actions: Buy next stage, inspect journal, settings, return to play.

There is no equip-from-collection action. A read-only five-type upgrade journal can explain progression, but cannot recover a dropped gun. Purchase confirmation is a gameplay transaction, not a separate real-money shop.

Service and saving confirmations are distinct from the upgrade purchase. An ordinary recovery station opens no purchase menu. Leaving a workbench without buying remains a complete, valid action.

## Journal, pause, and completion
The journal has the current objective, concise story recaps, evidence files by level (memos, photos, recordings and logs that can be reread or replayed, with captions), encountered enemies, and read-only weapon knowledge. Enemies are listed by faction (Arcadia Security, Thornwall, Adam's machines, the Linked, cyborg dogs, the Heirs). Mark harmless Sleepwalkers and the held staff as protected in their entries. Describe the Linked as people driven by Adam, never as a kill target or a count.

Pause shows Continue, Settings, Journal, Restart from checkpoint, and Quit. Restart and Quit explain that progress since the last committed checkpoint will be lost. A confirmation prevents an accidental restart; it does not need to interrupt ordinary play actions.

The completion screen shows campaign finished, evidence-file discovery, and microchip/upgrade progress with no kill count and no suggestion that killing every enemy is a goal. No ranked score or speedrun medal economy is included yet.

## Accessibility proposals
- Remap named actions for keyboard/mouse and controller. Provide sensitivity, aim assist strength, and independent horizontal/vertical inversion where useful.
- Support toggle/hold alternatives for repeated interactions and charging where behavior remains clear. No rapid button-mashing escape mechanic.
- Adjustable subtitle size, background opacity, speaker labels (Adam's PA, Adam on a screen, Security PA, Dave, Stroud, Guard, Thornwall and the others), and sound captions for important offscreen warnings, gunfire direction and lockdown events. Barks are always subtitled, because they are text plus a non-verbal sound.
- Separate master, music, effects, dialogue, and ambience volume.
- Adjustable screen shake, hit flash and background motion; offer reduced effects that preserve hazard boundaries. A reduced-motion toggle removes camera shake entirely (the camera shakes only on 2-damage hits) and holds arcs static.
- High-contrast interactive outlines (see the dark-scene options below), scalable HUD/text, and redundant shape/sound cues.
- Avoid essential red-versus-green distinctions. Keep text on solid-enough backing.
- Pause during dialogue; skip noninteractive scenes; replay essential information from the journal.
- Optional slower game speed and incoming-damage assistance can be offered as accessibility settings after their effects are specified. They are proposals, not additional campaign rules or punishment modes.

Do not make optional settings disable saving, evidence files, or story completion. Keep all UI readable over the brightest campus signage and the darkest server-hall or clinic backgrounds.

## Blood setting *(proposed, C29)*
A **Blood** toggle sits in Settings and is also reachable from the pause menu. **It is on by default.**
- **Off** swaps blood spurts for dark dust and hides floor pools and blood overlays (oil and lymph included, since they pool the same way). Sparks stay.
- Nothing else changes. Bodies still fall and stay, ragdolls, tells, timings and hit reactions are identical, and Dave's own spray follows the same setting.
- Every readability rule holds in both states, and no scene depends on the blood: an aftermath scene must still read with Blood off, from its bodies, bags and lights.
- The setting never disables saving, evidence files or story completion.

## Dark-scene accessibility (*proposed*)
The game is dark by design (C15), so three options keep shape and timing readable without flattening the mood. Each preserves hazard boundaries and attack tells.

- **Brightness / gamma.** A slider runs from Dimmer (the lowest setting) through Default to Brighter, with a calibration screen on first launch. The screen shows a dark test panel, a platform edge in shadow, a dim landing light and a gold microchip, and Default is the point where the darkest gameplay-relevant edge is still distinguishable. The slider moves only the dark end (the Night, Navy, Steel and Slate tokens). Accent lights, rim lights, outlines and text are unaffected, so the mood survives while shape stays legible. Menus ignore it.
- **High-contrast outline.** A toggle adds a bright outline pass around Dave, enemies, pickups, interactive objects and platform tops so silhouettes separate from dark backgrounds. Outlines are shape-coded as well as color-coded: a solid line for characters (heavier for Dave), dashed for hazards and enemy shots, dotted for pickups and interactive objects, and a soft double line for protected characters, with the object that holds the interaction prompt drawn thicker. Dave uses a warm orange-white line, hostile units a pale cool white, hazards and enemy shots amber (red only while active), pickups gold, and interactive objects and protected characters teal (tether anchors keep their azure-white marker). Harmless Sleepwalkers, held staff and the founder never receive the hostile outline. Corpses and blood get no outline, so nothing on the floor competes with a pickup.
- **Reduced flash.** A toggle replaces strobes and alarm flashes with steady or slowly fading light of the same color and meaning: red emergency strobes, lockdown alarm lights, attack-tell flashes on the attacking part, muzzle-flash lights and impact flashes, and electrical flashes. Rapid fire is already one held glow. It also holds billboard and lamp flicker still and shrinks flash size and brightness. The default already follows the ceiling in [G04](../01-core/camera-and-feedback.md): no effect flashes more than three times in any one second, and nothing flashes across the full screen (*proposed*, to be checked with a flash-analysis tool). The setting never removes or delays a tell: timing moves to posture, sound and a steady outline pulse. No mandatory scene depends on a strobe, and alarm sounds still play with captions.

Acceptance checks: every platform top, hazard boundary, pickup and attack tell stays distinguishable at Default and at Dimmer; with high-contrast outlines on, Dave, hostile units, hazards, pickups and protected characters can be told apart in a grayscale screenshot by outline style alone; with reduced flash on, no scene flashes above the cap and every tell still has a non-flashing form; with Blood off, every tell, ledge, pickup and aftermath scene still reads.

## Required later screen studies
Create separate studies for normal play with each of five weapons, a low-health warning, a weapon swap, upgrade preview and purchase result, evidence-file discovery, keycard pickup and door prompts (with and without the card), journal, checkpoint retry warning, brightness calibration, high-contrast outlines on and off, reduced flash on and off, Blood on and off, and subtitle/danger-caption overlap. Use realistic strings and resource counts; do not fill screens with implementation terminology.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
