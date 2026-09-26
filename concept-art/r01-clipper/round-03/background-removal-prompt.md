# Clipper E — Background removal

**Method:** Built-in image-generation background extraction.  
**Input:** [Original humanoid candidate](r01-clipper-e-humanoid-v1.png).  
**Output:** [Transparent PNG](r01-clipper-e-humanoid-v1-transparent.png).

The original image is preserved. The output is an alpha-channel PNG cutout, with the full robot, shears and feet visible.

## Exact edit prompt

```text
Use case: background-extraction. Edit the attached image only by removing its plain gray studio backdrop and the studio floor/cast shadow. Keep the entire foreground robot unchanged and fully intact: exactly the same pose, position, scale, silhouette, green and ivory enamel, worn textures, lighting on the robot, amber eyes and lamps, head, back handle, every joint and rod, both legs and complete feet, both shear hands with all FOUR full blade tips. Preserve all original foreground detail rather than redraw, restyle or regenerate the character. Maintain the original portrait framing and ample full-body coverage; do not crop, zoom, resize the character inside the frame, or alter its anatomy. Make the background genuinely transparent with a PNG alpha channel, NOT a painted checkerboard, black, white, gray, or another replacement color. Accurately clear background visible between arms and torso, between legs, between each pair of shear blades, and through the upper carry-handle opening, while preserving dark mechanical recesses that belong to the robot. Clean smooth antialiased edges without gray halos, erased metal edges, leftover floor haze, or missing fine mechanisms. Output a transparent-background PNG cutout of this exact original foreground subject. No added shadows, effects, labels, or objects.
```

[Round index](README.md)
