# DEAD EDEN — Shared visual and modeling guide

## Intended look

Original, colorful, stylized 3D assets for a side-view 2.5D platformer shooter. Shapes should feel tactile and expressive: broad curves, chunky equipment, generous bevels, large facial features, and selective wear. The world began as a friendly future-care environment and has become unsettling through misuse and neglect.

The game's inspiration informs clarity and playful transformation. Create original silhouettes and identity rather than reproducing characters, costumes, branding, or assets from another game.

## Scale and proportion

Use a provisional 1.70 m human silhouette for comparison. This is an art reference, not a locked hero height. Each brief sets its own relative scale. Small support robots sit below the hero's waist, standard enemies occupy roughly the hero's height, and mini-bosses visibly exceed it.

Most humanoid enemies use simplified, expressive proportions around five to six head heights; large heads, hands, and feet help side-view readability. Specific creature proportions take priority. Do not force a sphere-shaped Puffer or root-based boss into a standard humanoid skeleton.

Weapons are deliberately chunky but still need believable hand clearance. Finalize the hero's hands and grip spacing before committing final weapon proportions.

## Shared visual language

- **Ordinary robots:** Warm ivory ceramic or enamel, a colored service shell, dark protected joints, rubber wheels or feet, restrained copper details, and simple eye lenses. Original job determines the silhouette. No living tissue.
- **Zombies:** Recognizable former people, intact waxy skin, desaturated sage or mauve tones, softened clothing, closed treatment seams, and distorted routines. Character comes from posture and remnants of daily life. No photorealistic decay or exposed viscera is required.
- **Returned:** A recognizable robot chassis fitted with a visible neural-interface cradle and controlled areas of organic growth. Coral tissue and lavender bruising appear at engineered openings; growth has a physical route into the machine. Do not spread decorative flesh uniformly over every surface.
- **Weapons:** Repurposed appliances and cargo or care equipment, with clear grips, large visible controls, compact functional-looking housings, and readable upgrade attachments. The Scrapjack is more homemade than EDEN-issued tools.

Use an original leaf-in-circle or leaf-and-droplet emblem for EDEN equipment. Avoid real-world medical insignia and external brand marks. Keep logos simple; add final lettering manually after generation if needed.

## Readability in a 2.5D game

Silhouette and motion must identify an enemy before small details do. Check every design from left and right gameplay views and as a small solid-black thumbnail. Faces, shields, weapon barrels, weak-point exposures, and major pose changes need clear negative space.

Use three levels of detail: primary body shape, secondary functional parts, and a small number of surface accents. Avoid dense cables, tiny pistons, excessive scratches, and ornamental spikes that blur together at game scale.

Important attack warnings use posture, geometry, timing, and sound as well as color. Glowing materials alone must not communicate the whole mechanic. Keep particles and background scenery from covering platform edges, limbs, or targets.

## Materials and lighting

Favor broad readable surfaces with subtle painterly variation. Enamel and ceramic have soft highlights; rubber remains matte; metal has restrained specular response. Organic tissue may have a gentle waxy or moist sheen, but avoid wet photorealism. Use modest emission and bloom so color patches retain shape.

For references, use neutral soft studio light on a warm light-gray background. Avoid dramatic rim light, hard directional shadows, colored cinematic grading, perspective foreshortening, or shallow depth of field. Palette hex codes are later material targets; generated images may approximate them.

## Coordinate and view conventions

Anatomical left/right always refers to the asset's own sides. Name left and right side views explicitly. A front character view means the character faces the viewer. A front weapon view looks toward its muzzle or emitter. Turnaround views should use consistent scale, neutral articulation, and alignment.

Do not mirror asymmetrical shields, cartridge racks, growths, or mounts. Keep the same number of arms, legs, petals, eyes, pods, and emitters in every image. For bosses with many arms, verify every arm's connection and tool assignment before accepting a sheet.

No engine, modeling application, axis convention, polygon budget, or texture resolution is selected yet. Choose those production constraints later; these briefs define visual form and motion requirements.

## Reference workflow

1. **Neutral master:** Generate one clean three-quarter design from the full prompt inside the asset brief. Choose and refine a single approved result.
2. **Turnaround:** Attach that approved result and ask for front/back/side views, or the weapon-specific views. If a combined sheet drifts, request one view at a time using the same reference. Do not regenerate the design from text independently for each angle.
3. **State studies:** Reuse the approved master for anticipation, attack, recovery, damage, and special states. One state per image is easiest to inspect.
4. **Detail studies:** Request close-ups only where function needs explanation, such as a hinged armor opening, a grip, or an upgrade mount. Preserve established geometry.
5. **Scale and contact:** Put a simple hero-size silhouette or hand placeholder on a separate sheet. Keep these out of the clean asset turnaround.
6. **Modeling review:** Compare all views and reconcile contradictions. Build a simple blockout and test silhouette, poses, hand contacts, moving-part clearances, and weak-point exposure before adding detail.

Image generators can invent inconsistent hidden sides, impossible hinges, mirrored props, and extra limbs. These are reference images rather than CAD drawings; the modeler must resolve discrepancies. This pack does not assume automatic conversion from an image to a production-ready mesh.

## Model separation and animation

Use each asset's part list as the starting point for assembly. Keep rigid mechanical components separate where they rotate, slide, or open. Organic bodies need deformation around shoulders, hips, swelling tissue, and mouths; roots and tissue bands should have controllable motion rather than being an inseparable pile of geometry.

Weapons need clear contact points and room for recoil, the Boom Broom pump, and upgrades. Keep attachments modular on stable mounts so the four cumulative appearance stages can share a core model.

Separate projectiles, trails, barriers, muzzle flashes, ground effects, and impact clouds from the character or weapon. Separate arena objects from mini-boss bodies, especially Old Rootjaw's pump and Matron Mercy's care stations.

Define neutral, anticipation, attack, recovery, hit, and disabled states as appropriate. Final animation clips and technical rigs remain a later production decision.

## Lore boundaries

Ordinary robots remain mechanical. The resurrection treatment affects living tissue and does not travel as wireless malware. The Returned require neural tissue and compatible installed interfaces. Old Rootjaw is a biological mutant entangled with a pump, not an infected robot. Matron Mercy and Mr. Mulch are fully mechanical. Base Patchbots have no tissue; their level-10 conversion uses a separately labeled variant.

The Rememberer may be peaceful. The First Patient is not an enemy in the current campaign. Do not visually recast either as an obligatory combat target without a story decision.

## Upgrade conventions

Each weapon has exactly three successive upgrades. Stage 0 is the base; stage 1 adds the first attachment; stage 2 keeps the first and adds the second; stage 3 keeps both and adds the third. Capability upgrades and appearance changes are paired inside each weapon brief.

Generate an approved base before any upgrade. Reference the previous stage, maintain the same camera and size, and verify that earlier attachments persist. Upgrade art must preserve weapon identity and hand clearance. It does not authorize a sixth weapon or a different gameplay ability.
