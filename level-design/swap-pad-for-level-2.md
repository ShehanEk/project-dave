# Weapon swap pad: kept for Level 2

**Status (2026-10-08, decision C51):** the weapon swap pad was taken out of Level 1 at the user's request ("remove the pad but store related code and the way you do it somewhere, we need it for second level"). In Level 1 it only traded Dave's Scrapjack (workshop tag **P01**) for an identical second Scrapjack (**P02**), so the HUD's "P01" and the pad's "P02" read as a mystery. The code, the art and the tests are all still in the prototype; only the pad's node in the depot scene is gone, and the HUD hides the workshop tag in a level without a pad. Level 2 ([Curfew](l02-curfew.md)) introduces the Boom Broom, which is where a swap first means something (one carried weapon: choosing a new pickup drops the old one at that spot, and a safe trial lets the player swap back; [weapon swaps, G03](../design/01-core/weapon-swaps.md)).

## What is kept (all in `prototypes/sunnyvale-godot/`)

| Piece | Where | What it does |
| --- | --- | --- |
| Swap pad | `scripts/objects/weapon_pad.gd`, `scenes/objects/weapon_pad.tscn` | An `Interactable` (class `WeaponPad`, export `pad_id`). Draws the resting weapon and its workshop tag; interact opens the confirm dialog; Confirm calls `Session.swap_weapon(pad_id)` once; Cancel or Escape changes nothing; a "Weapon swapped" toast only after a real swap. Joins the group `weapon_pad`. Never heals, services or resets anything. |
| Confirm dialog | `scripts/ui/swap_confirm.gd`, `scenes/ui/swap_confirm.tscn` | Names both instances by workshop tag; `closed(swapped: bool)`. Pixel UI frames like the other modals. |
| Pad art | the objects sheet piece `weapon_pad` (drawn through `scripts/world/object_skins.gd`; the code-drawn pad is the fallback) | Dark steel plate with a teal-lit top edge; the resting gun sits `PAINTED_TOP` (14 px) above the foot. |
| Session state | `scripts/session.gd` | `equipped_weapon` (an instance id such as `L01-W01-P01`), `world_weapons` (instance id -> pad id it rests on), `weapon_on_pad(pad_id)`, `swap_weapon(pad_id)` (an atomic exchange: the held and the resting instance trade places, never a third instance; a live change that rolls back with the next restore, like any uncommitted change), `weapon_swapped` signal, `weapon_type_of(id)` (`L01-W01-P02` -> `W01`). Upgrades belong to the weapon type (`weapon_stage(type)`), so every instance of a type is fitted the same. |
| Save checks | `scripts/checkpoint_service.gd` | `WEAPON_INSTANCES` (every instance that exists, each exactly once, held or on a pad) and `WEAPON_PADS` (the pads that exist); `validate_snapshot()` refuses anything else. |
| HUD tag | `scripts/ui/hud.gd` `set_weapon_tag_shown()`; `scripts/levels/level_director.gd` `has_swap_pad()` | The held instance's tag ("P01") shows only when the level has a swap pad; LevelDirector checks after building the areas. |
| Route bot | `scripts/debug/route_bot.gd` | Already handles the pad's modal like the workbench's. |
| Tests | `tests/cases/test_m4_regress_pad_decline_toast.gd`, `test_m7_regress_prompt_above_hero.gd` (each places a pad in the depot at run time), `test_m4_state_contracts.gd`, `test_m4_regress_save_tamper.gd`, `test_pixel_ui.gd`, `test_kenney_ui.gd`, `test_n05_ui_ticks.gd` | Swap, decline, prompt, save whitelist and dialog look. |
| Debug | `scenes/debug/sample_area.tscn` still has a pad; `scripts/debug/m4_demo.gd` and `m6_ui_demo.gd` place one at run time | For captures. |

**Left in Level 1's save data on purpose:** the state still lists the second Scrapjack, `L01-W01-P02`, resting on `L01-A05-PAD01` (nothing draws it), so the save schema, the validation and old saves are unchanged. A Level 1 save made after swapping before 2026-10-08 still loads, with P02 in hand.

## How it was in Level 1 (to put it back exactly)

In `scenes/levels/areas/a05_depot.tscn` (the server depot), 330 px right of the workbench (`Workbench` at x 1450) and with `load_steps` one higher:

```
[ext_resource type="PackedScene" path="res://scenes/objects/weapon_pad.tscn" id="6_pad"]

[node name="WeaponPad" parent="Entities" instance=ExtResource("6_pad")]
position = Vector2(1780, 0)
pad_id = "L01-A05-PAD01"
```

The area brief kept the pad at least 3 H (288 px) from the workbench and the core node, so the three interaction prompts never overlap.

## How to use it in Level 2

1. **Ids.** Give Level 2's instances and pads their own ids in the house pattern: for example `L02-W02-P01` for the Boom Broom resting at `L02-A01-PAD01` (the maintenance shed's tool rack). Add every instance to `CheckpointService.WEAPON_INSTANCES` and every pad to `WEAPON_PADS` (or make both per level when there is more than one level in the prototype), and put the resting instance in Session's starting `world_weapons`.
2. **Weapon type.** `swap_weapon()` already swaps across types; `upgrades` needs a `W02` entry, the HUD's weapon icon needs the Boom Broom's art, and the hero needs the held weapon's scene (today `AimPivot/Scrapjack` is fixed in `hero.tscn`): swap the node under `AimPivot` on `weapon_swapped`, and give the new gun its grip and muzzle like the Scrapjack's (`GRIP_LOCAL`, the `muzzle` socket; Dave's arm holds whatever gun is on the pivot by its grip, C50).
3. **Place the pad** in the area scene under `Entities`, with `pad_id` set, at least 3 H from any other interaction.
4. **The HUD tag** turns on by itself in a level with a pad (`LevelDirector.has_swap_pad()`).
5. **Safe trial:** the weapon-swaps design wants the player able to swap back before leaving; the pad already allows any number of swaps, and an uncommitted swap rolls back on a restore.
6. **Tests:** copy the two run-time-pad tests to Level 2's real pad, and update the save-whitelist tests for the new ids.

[Level 2: Curfew](l02-curfew.md) · [Level design index](README.md)
