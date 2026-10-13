extends RefCounted
## What the hero is standing on, as the footstep cue to play (the three
## ElevenLabs cues `footstep_paving`, `footstep_metal`, `footstep_roof`, see
## CONVENTIONS.md "Audio"). Pure lookups, no state, no tree access: hero.gd
## probes the floor under his feet and passes the collider in. No `class_name`
## (M6 art-pass import-cache rule): reached by `preload()` path.
##
## Per area (the dominant surface; Block.skin_name() and terrain_skins.gd are
## the art side of the same choice):
##   L01-A01 gate     paving  (campus path and apron)
##   L01-A02 gardens  paving  (garden paths, planter ledges and walls are concrete)
##   L01-A03 roofs    roof    (the low planted slabs; the street run-in and the
##                             landing at each end are paving, see for_block())
##   L01-A04 square   paving  (wet plaza paving)
##   L01-A05 depot    metal   (steel grating floor)
##   L01-A06 exit     paving  (the exit yard)
## A moving platform is a steel plate: metal, wherever it runs. Anything
## unknown, and any isolated test scene with no AreaRoot, is paving.

const PAVING := &"footstep_paving"
const METAL := &"footstep_metal"
const ROOF := &"footstep_roof"
## The cue when nothing says otherwise (no floor found, no AreaRoot above it).
const DEFAULT := PAVING

const BlockScript := preload("res://scripts/world/block.gd")
const MovingPlatformScript := preload("res://scripts/objects/moving_platform.gd")

## AreaRoot.area_id -> the area's dominant surface.
const AREA_SURFACE := {
	"L01-A01": PAVING,
	"L01-A02": PAVING,
	"L01-A03": ROOF,
	"L01-A04": PAVING,
	"L01-A05": METAL,
	"L01-A06": PAVING,
}


## The dominant surface of the area `area_id` ("" or an unknown id: paving).
static func for_area(area_id: String) -> StringName:
	return AREA_SURFACE.get(area_id, DEFAULT)


## A solid `Block` of `kind` (Block.Kind) in area `area_id`. Mixed areas:
## a roof-kind slab is a roof slab anywhere, and the roofs' own ground and
## porch blocks (the street run-in and the landing) are paving, not roof.
## Everything else takes its area's dominant surface (the depot is steel
## throughout, ceiling included).
static func for_block(area_id: String, kind: int) -> StringName:
	var area_surface := for_area(area_id)
	if area_surface == METAL:
		return METAL
	if kind == BlockScript.Kind.ROOF:
		return ROOF
	if area_surface == ROOF and (kind == BlockScript.Kind.GROUND or kind == BlockScript.Kind.PORCH):
		return PAVING
	return area_surface


## The surface under a floor `collider` (what a downward ray from the hero's
## feet hit): null or a node outside every area gives DEFAULT.
static func for_collider(collider: Object) -> StringName:
	if collider == null:
		return DEFAULT
	if collider is MovingPlatformScript:
		return METAL
	var area_id := area_id_of(collider as Node)
	if collider is BlockScript:
		return for_block(area_id, int(collider.get("kind")))
	return for_area(area_id)


## The `area_id` of the AreaRoot above `node` ("" when it has none).
static func area_id_of(node: Node) -> String:
	var n: Node = node
	while n != null:
		if "area_id" in n:
			return str(n.get("area_id"))
		n = n.get_parent()
	return ""
