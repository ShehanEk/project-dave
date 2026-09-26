# DEAD EDEN — Hand-drawn 2D visual and sprite guide

**Approved visual direction (C11):** Hand-drawn 2D; [selected reference gallery](../concept-art/README.md).

## Approved direction

Decision C11 selects the generated **hand-drawn 2D style** for the whole game. Use the [selected concept-art gallery](../concept-art/README.md) as the visual reference: Clipper, Resident, front gardens, neighborhood square and quarantine exit. Clipper retains B's sturdy retro-machine identity from C10.

These references establish rendering and the depicted designs. Unpictured characters and props still need individual design choices. Hero and companion identities remain proposals. Gameplay, lore, twelve levels, four mini-bosses, five weapons and their three upgrades remain governed by their written briefs.

## Linework, color and shading

- Draw confident dark olive or warm charcoal contours, with heavier outer silhouettes and restrained interior lines.
- Use broad flat local colors, one or two crisp cel-shadow shapes and sparse graphic highlights. Keep texture subtle and inside large color areas.
- Preserve rounded, chunky shapes and readable functional detail. Simplify small bolts, plant leaves and clothing folds at gameplay size.
- Suggest enamel, ceramic, rubber, steel, waxy skin and cloth through drawn color shapes and marks. Material descriptions in asset briefs identify what an object represents; they do not request realistic surface rendering.
- Keep the warm retro civic-care character and gentle unease. Sunnyvale's cream, peach and green palette belongs to Sunnyvale; later regions retain their own documented palettes.
- Use smooth high-resolution illustration. Pixel art, photorealistic shading, volumetric lighting, strong gradients, glossy rendered surfaces and photographic blur are outside the selected direction.

## Visual families

**Ordinary robots:** Ivory and colored service shells, dark protected joints, rubber wheels or feet, a few readable fasteners and simple eye lenses. Their former jobs define their silhouettes. They have no living tissue.

**Zombies:** Recognizable former people with intact sage or mauve skin, softened clothing, closed treatment seams and broken daily routines. Use posture and facial expression rather than exposed gore. Resident's selected coral cardigan, cream shirt, teal trousers, slippers and sleeve asymmetry stay consistent.

**Returned:** Recognizable mechanical bodies with installed neural-interface cradles and controlled organic growth at engineered openings. Tissue has a physical route into the chassis; it is not arbitrary decoration.

**Weapons:** Repurposed appliances and cargo or care tools, with readable grips, controls and upgrade attachments. Use separate weapon drawings; the hero carries exactly one.

Original leaf-in-circle or leaf-and-droplet equipment emblems may be used where a brief calls for them. Final lettering should be authored separately.

## Scale, facing and silhouette

Use the existing provisional human height of 1.70 m only to compare relative proportions. Meter values in briefs are art-scale guidance, not a required sprite resolution or engine unit.

Check every design at intended gameplay size and as a solid silhouette. Hands, feet, weapon tips, weak points and attack poses must remain legible against scenery. Side-facing art is the production priority. Selected three-quarter concepts may guide identity but still need adapted side-facing poses.

Create consistent left- and right-facing drawings. Anatomical left and right belong to the character. Do not automatically flip asymmetric shields, sleeves, mounts or upgrade controls. Keep part counts and attachment positions stable. A far wheel or eye may be hidden by another part in a side pose; occlusion does not remove it from the design.

## Sprite and animation references

1. **Identity reference:** Use a selected image; for an unpictured asset, generate and choose one neutral design in the approved 2D style.
2. **Directional poses:** Draw left- and right-facing gameplay poses with matching canvas scale, foot baseline and proportions. Front/back construction drawings are optional when they clarify an attachment.
3. **State poses:** Draw neutral, anticipation, attack, recovery, hit and disabled states according to the asset brief. Keep threats and weak-point openings readable through shape and movement.
4. **Drawing separation:** Plan independent limbs, face features, wheels, blades, weapons and effects where useful. Preserve overlap under joints and mark pivot intent. The final choice between frame-by-frame, cutout or hybrid animation remains open.
5. **Contact checks:** Compare weapon grips, feet on platforms, closed/open shears and collision poses. Use simple scale silhouettes where needed; keep them out of clean character deliverables.

Generate one pose per request when multi-pose sheets introduce inconsistent anatomy. A finished illustration does not establish frame count, timing, sprite pivots or a working animation rig.

## Environment layers and camera

Use a fixed side-oriented 2D gameplay camera. Compose scenery as separate foreground, playable, background and effect layers; overlap, lower background contrast and optional parallax suggest depth. The hero, enemies, pickups and collision route stay on the same action plane.

Give playable platforms continuous visible top edges and believable support. Foreground leaves and fences must not hide feet, attack cues, gems or landing edges. Distant roads, roofs and residents remain scenery unless the level brief describes access.

Draw reusable floor, wall, porch, rail and planter modules. Keep moving platforms, gates, hinged garden panels, flower lights and warning effects separate from fixed scenery. Use matching closed/open states of the same assembly. Scene PNGs are flattened reference illustrations, not already separated parallax layers or tile sets.

The Sunnyvale front gardens and square conceal service infrastructure; the quarantine exit may expose it after the depot event. Keep the neighborhood maintained and intact.

## Materials, effects and readability

For neutral references, use flat warm off-white and a simple flat contact shadow. Scene lighting is expressed with color choices and restrained drawn shadow shapes. Use small flat translucent shapes for examination lights and warnings.

Keep projectiles, muzzle flashes, sparks, smoke, gem glints and interface elements separate from character art. Outline weight, pose and audio must reinforce color cues. Avoid effects that cover actionable silhouettes. Preserve reduced-flash and reduced-motion presentation rules.

## Lore and upgrade boundaries

Ordinary robots cannot catch the resurrection treatment wirelessly. Returned require installed compatible interfaces and infected neural tissue. Old Rootjaw remains a biological mutant entangled with a separate pump; Matron Mercy and Mr. Mulch remain fully mechanical.

The First Patient is not an enemy. Peaceful Rememberers are not compulsory targets. No visual redesign adds new attacks or traversal powers.

Each weapon has a base appearance plus exactly three cumulative upgrades. Stage 2 retains stage 1; stage 3 retains both earlier attachments. Keep the same side pose, scale, outlines and grip alignment across stages. The Graviton Tether uses the single carried-weapon slot.

## Delivery and unresolved production choices

Keep a selected PNG, selection record and current continuation prompt together. Store only selected concept images in the repository. Do not label a new exploration as selected without a user decision.

Concept PNGs are not final sprites, transparent cutouts, animation sheets or layered source documents. Sprite resolution, atlas layout, frame counts, animation method, engine, source format and export pipeline remain future choices. Keep backgrounds opaque for reference sheets unless a transparent export is specifically requested.

[AI entry guide](../AI_START_HERE.md) · [Art brief index](README.md) · [Level guide](../level-design/design-guide.md)
