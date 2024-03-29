class_name BlockIndicator
extends Node3D
@export var indicators: Array[Sprite3D]
@export var empty_checker: Area3D

var has_updated = false

func show_raycast(tool: VoxelTool, raycast: VoxelRaycastResult):
	visible = raycast != null

	if raycast != null:
		global_transform.origin = Vector3(raycast.position)
		var meta = tool.get_voxel_metadata(raycast.position)
		var state = 0
		if meta != null and "health" in meta and meta["health"] > 0:
			state = floor(8.0*(1 - float(meta["health"])/BlockDataRegistry.get_block_data(tool.get_voxel((raycast.position))).max_health))
		for indicator in indicators:
			indicator.frame = state
		
		# Set has_updated to false when we have to move the position
		has_updated = empty_checker.position != Vector3(raycast.previous_position - raycast.position)
		if not has_updated:
			empty_checker.position = raycast.previous_position - raycast.position

func is_empty():
	return has_updated and not empty_checker.has_overlapping_bodies()

func _physics_process(_delta):
	has_updated = true
