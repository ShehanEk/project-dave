# DEAD EDEN — Artifacts and discovery catalog

**Document ID:** S05  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Proposes twelve optional lore artifacts, with appearance, placement intent, and narrative limits.

**Decision references:** C03, E01, P11 — see the [decision register](../decisions.md).  
**Read with:** [treasure economy](treasure-economy.md) · [health and checkpoints](health-and-checkpoints.md) · [story scenes](../05-presentation/story-scenes.md) · [README](../../level-design/README.md)

## Collection rules
Proposed roster: **one optional artifact per level, twelve total**. These are additional to gems and to mandatory story evidence. A player may complete the campaign without collecting any of them.

Artifacts add a small journal entry and a distinctive object illustration. They do not occupy the weapon slot, confer combat powers, unlock mandatory doors, or act as currency. The journal is a record; the hero's small collection pouch is abstracted and never shown holding full-size weapons.

Use a warm amber rim light, a square display plinth, and a short unique discovery sound. Collection requires Interact and records a stable artifact ID. In combat, record it quietly and defer the description until the player is safe. Do not freeze the hero in a damaging animation.

The locations below are placement proposals within the existing level themes; the detailed route briefs still need exact alcove allocation. Each can be reached with baseline movement and ordinary switches. A tether shortcut may exist, but tether ownership is not required to complete the collection.

## Catalog
| ID / level | Object and visual brief | Optional discovery | Journal idea and guardrail |
| --- | --- | --- | --- |
| A01 / 1 | **Welcome Key:** palm-size cream ceramic house key with a smiling sun head and worn brass teeth | Porch loft visible above a safe jump trail | A resident's first day in Sunnyvale. It is a souvenir key, not the maintenance-depot access item. |
| A02 / 2 | **Topiary Medal:** scalloped mint medal with a raised leaf and faded cloth loop | Garden judging booth behind a timed planter route | A neighborhood gardening contest cared more about neatness than people. No biological upgrade. |
| A03 / 3 | **Golden Parade Ticket:** thick gold-colored punched card with a sun-wheel emboss | Safe parade viewing niche before the arena | Celebrates automation's promise. Mr. Mulch does not need this ticket to activate. |
| A04 / 4 | **Rootworks Shift Token:** dark teal hexagonal tag with a copper gear inset | Worker rest shelf reached by an ordinary lift | Maintenance staff left signs of exhaustion beneath cheerful slogans. Not a new currency. |
| A05 / 5 | **Sealed Seed Locket:** amber seed inside a small clear capsule on a ceramic chain | Dry side alcove above the compost route | Someone saved a seed from a garden beyond EDEN. It is preserved and inert, not an infection cure. |
| A06 / 6 | **Pressure Keeper Seal:** fist-size blue enamel dial seal with a broken red pointer | Pump inspection bay accessible before or after the boss | A worker's service award ties Rootjaw to a former occupation without making the artifact necessary to understand him. |
| A07 / 7 | **Care Consent Bracelet:** white rounded band with two mechanical choice tabs | Empty observation room off the patient corridor | Earlier care procedures included a meaningful refusal. It does not open doors or identify the First Patient. |
| A08 / 8 | **Memory Prism:** thumb-size translucent violet triangular prism in a padded frame | Quiet orchard balcony reached by normal platforms | Contains a brief ordinary recollection, not a complete soul or a transferable companion. |
| A09 / 9 | **Discharge Stamp:** small teal hand stamp with a broad circular base | Vacant records alcove outside Matron's arena | A bureaucratic tool once meant a patient could leave. It is an inert keepsake, not the system's shutdown authority. |
| A10 / 10 | **Rejected Neural Cartridge:** empty cream cartridge with a copper tissue cradle and red rejection stripe | Disconnected test bench behind a safe optional route | Failed compatibility trials foreshadow the Returned. No living tissue remains; collecting it cannot infect the hero. |
| A11 / 11 | **First Patient Music Cylinder:** cream spool with brass ends and a blue winding tab | Personal-effects cabinet offered after the main scene | A voluntary memento of a life before treatment. Do not steal from an occupied bedside or make this proof of personhood. |
| A12 / 12 | **Original Mission Leaf:** small etched copper plaque shaped like a broad leaf | Accessible observation pocket before the final guardian gate | Its early mission wording supports an optional reflection. PIP already carries the unique authority; this plaque is not another shutdown key. |

## Image and model handoff
For each artifact, create one neutral isolated object, a strict side silhouette, and a simple three-quarter pickup presentation. Keep lettering out of the generated mesh; small inscriptions can be represented by abstract grooves until readable text is designed separately.

Use the existing world materials: rounded ceramic housings, enamel, brass, padded polymer, restrained wear. Keep most items around palm to forearm size. Distinguish silhouette first; avoid twelve glowing cubes with different colors. Artifact halos are effects, not permanent geometry.

## Completion and saving
A journal shows discovered entries and undiscovered level slots without revealing solutions. Collecting all twelve gives a completion acknowledgement and optional gallery, not a stronger weapon, alternate mandatory ending, or thirteenth level.

Artifacts follow checkpoint rollback exactly. A unique record and its world pickup commit together. Keep optional flavor text short: roughly 30–60 words per item in a future writing pass. This catalog establishes objects and meaning; it is not yet the final written journal.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)
