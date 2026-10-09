# DEAD EDEN — Core loop and design pillars

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** G01  
**Status:** Working design proposal. Confirmed decisions and the established baseline remain constraints; new details and numbers are untested proposals.  
**Purpose:** The player rhythm, intended experience, content boundaries, keycard exits and pacing rules.

**Decision references:** C12, C01, C02, C04, C05, C06, C14, C15, C16, C19, C25, C28, C29, P01, P11, P19, P20, P23 — see the [decision register](../decisions.md).  
**Read with:** [core gameplay](../../core-gameplay.md) · [player controls](player-controls.md) · [treasure economy](../03-progression/treasure-economy.md) · [health and checkpoints](../03-progression/health-and-checkpoints.md) · [encounter and boss fairness](../04-world/encounter-and-boss-fairness.md)

## What the game should feel like

The player is Dave Harlan, a rogue AI researcher who has broken back into Arcadia Dynamics' Eon City campus after hours. The places are dark, quiet and watched, and Adam, the sentient AI that runs them, calmly and politely keeps trying to contain Dave. After the first level the campus stops being polite: the guards are armed, lethal force is authorized, and a private contractor, Thornwall, arrives to "sanitize". The mood is mysterious and scary, and the game is mature, not for kids (C28): combat is lethal, enemies bleed and stay down (C29), and the horror is what Adam does to people. Movement should feel responsive, weapons should have distinct physical character, and curiosity should frequently reveal something useful or human.

The confirmed loop is **explore → fight → collect treasure → overcome an obstacle → reach a checkpoint → upgrade**. Repeat it with different emphasis rather than putting a mandatory battle and purchase in every room. The treasure is microchips (C19); optional evidence files (P11) are a second category.

## Design pillars

| Pillar | Player experience | Design consequence |
| --- | --- | --- |
| Readable adventure | I can understand a threat, make a plan, and react, even in the dark. | Give attacks, gunfire, moving platforms, lockdown events, and weapon swaps clear previews, and keep tells, weak points, platform edges and pickups lit and legible, with blood never hiding any of them ([G04](camera-and-feedback.md)). |
| A meaningful weapon choice | The weapon in my hands changes my approach. | One carried weapon; all mandatory encounters support the legitimate choice. |
| Treasure with purpose | Looking around pays off. | Microchips reward routes and fund proposed upgrades; evidence files provide distinctive discoveries. |
| Dangerous service | The world is dangerous for a believable reason. | Guards and contractors are armed professionals, scared or cold (C25). Adam's machines reflect their original campus jobs (security, freight and clinic work), now turned to Adam's purposes. The Linked repeat fragments of their old jobs. Every gun has an answer: a jump, cover or another floor ([W04](../04-world/encounter-and-boss-fairness.md)). |
| People inside the machinery | There is more here than targets and loot. | Preserve quiet discoveries, harmless Sleepwalkers (protected people, not enemies), the staff held for implanting, and the First Patient. Kills give no drops and no score. |
| Dread with consequence | Something is wrong here, and what I do about it matters. | Build dread from dim light, wrong movement, a calm PA voice and the weight of lethal force: enemies die, bleed and stay down (C28, C29). Atrocity is shown only as aftermath, and rationed (see below). There is no stealth or detection system (C16), and every scare that can hurt is telegraphed. |

## A typical section

A short safe view introduces the next landmark, lit by a lamp, sign or screen so it reads in the dark. A visible microchip trail suggests a side route. One encounter tests a familiar behavior, followed by a movement obstacle with a recovery ledge. The route opens into a checkpoint, where the player can pause, assess the held weapon, and optionally upgrade it at a workbench.

**Proposed pacing target:** an ordinary section lasts roughly two to four minutes before a clear change of activity. This is a writing target, not a measured requirement. Long boss fights, quiet reveals, and early tutorials can differ.

Checkpoints divide sustained pressure, not every small jump. A microchip trail can cross a combat space, but it must not lure the player toward an unreadable hazard. An upgrade purchase never unlocks the next door by itself. Adam's lockdown events (P20) can reshape a space, but only after a clear telegraph and always with a readable route left open.

## Player decisions worth preserving

- Keep a familiar weapon or swap to a newly discovered one.
- Fight from a safe position or approach for stronger short-range damage.
- Take a clearly signaled optional route for microchips or an evidence file.
- Spend microchips now on the carried type or save for another type encountered later.
- Answer gunfire by reading it: jump a flat round, wait behind low cover, or leave the floor when a machine gun spins up. There is no crouch.
- Fight a Linked person or jump past. The Linked never block progress, so killing one is a choice, not a toll.
- Use the tether's environmental options if it is the carried weapon, while accepting its lack of direct gunfire.

Do not simulate choice by giving one weapon a mandatory immunity counter. No early discarded gun may become a required key later.

## Scope for the first complete design

Dave travels alone, without a follower, radio contact or portable adviser (C12). Single-player, authored twelve-level campaign, four scheduled unique mini-bosses, five weapon types with three upgrades each. No crafting tree, multiplayer, procedural campaign, random equipment rarity, stamina meter, crouch, or second weapon slot is assumed. There is no stealth, detection or alert system (C16): Adam reacts through scripted, telegraphed lockdown events, not by spotting the player.

Except for the confirmed ones (the solo hero, C12, and no stealth, C16), these exclusions are proposed scope boundaries, not permanent bans on future ideas. Proposing one requires documenting what existing design it changes.

## Mature content and hard limits *(C28 and C29 confirmed; details proposed)*

The game is mature and not for children. Combat is lethal: every hostile can die, bleeds according to what it is made of and leaves a body ([W02](../04-world/status-and-enemy-states.md)). Blood is visible, with an on/off setting in Settings (*proposed*, [N03](../05-presentation/interface-and-accessibility.md)). Kills give no drops, no score and no praise.

- **Shown:** blood by material, corpses, restrained body horror (stapled ports, shaved scalps, cracked ceramic over grown tissue), hard language in human barks, and atrocity as aftermath.
- **Rationed:** at most one authored aftermath scene per level, out of the combat lanes, escalating by act. Act 1 shows only the bodies Dave makes. Act 2 adds Thornwall's cleanup and the Bloom test chamber, Act 3 the clinic bays, Act 4 the Garden ([N01](../05-presentation/story-scenes.md)).
- **Never shown:** torture or execution on screen, sexual violence, children, and dismemberment (not for now; one "heavy death" frame for rail and plasma kills may come later).
- **Never treated as monstrous:** implants themselves. The fear comes from what Adam does to people.
- **Untouchable:** the founder, the staff held in the clinic and harmless Sleepwalkers have no hit zone at all ([W01](../04-world/factions-and-friendly-fire.md)).

## Keycards and exit doors *(proposed, P19)*

Each level's exit door on levels 1–11 needs that level's clearance card. This is the *Dangerous Dave* trophy-and-door rule in Arcadia's language: find the card, then reach the exit.

- **Placement:** the card is on the main route or clearly signposted. It comes from a terminal, a guarded room, or, on levels 3, 6 and 9, the mini-boss's reward after the fight (released at the arena console, or dropped at a safe spot away from arena hazards). Level 12 has no keycard, because its ending happens at Adam's core.
- **An exit lock, not an inventory item:** one card per level, spent at that level's exit door. It does not use the weapon slot, cannot be sold, discarded or lost, and never carries into the next level. No card opens another level's door, and no card is needed to reach another card.
- **Fair access:** the route to a card needs only baseline movement and ordinary switches. A tether anchor may offer a shortcut but never the only route. Never place a card behind an optional branch, a purchase, an evidence-file alcove, or a weapon left behind.
- **Readable:** the HUD shows a keycard indicator, and a locked exit door shows a "clearance card required" prompt when approached, so the player knows what is missing ([N03](../05-presentation/interface-and-accessibility.md)). Card rooms are lit like any landing ([G04](camera-and-feedback.md)).
- **Guarded, not stealthy:** a card room may hold an ordinary encounter, armed guards included, or one of Adam's telegraphed lockdown events. Nothing is sneaked past, because there is no detection state (C16), and no enemy carries the card on its body.
- **Saving:** every checkpoint snapshot records the level's keycard ([S01](../03-progression/health-and-checkpoints.md)). A card taken after a checkpoint returns to its spot on death.

## Completion criteria

A level is complete when Dave passes through its authored exit or reaches its story objective. On levels 1–11 the exit door needs that level's keycard (above); level 12 ends at Adam's core. Fighting is necessary in selected encounters, not a universal requirement to defeat every enemy. Microchips and evidence files do not gate the ending. A checkpoint is a safe pause, not a mandatory shop interaction.

## Review questions

Can the player name their immediate goal? Is the next danger readable in the dark? Does treasure reward deliberate attention? Does this section support every weapon that can enter it? Can the player tell where the level's keycard is, or that they still need it? Does the world still feel like Arcadia after hours (dark, watched and slightly wrong) rather than a generic combat corridor? Does every gun in the room have an answer that needs no crouch? Do deaths carry weight without becoming spectacle?

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
