class_name BlockIndicator
extends MeshInstance3D
@export var indicators: Array[Sprite3D]


func set_block_position(tool: VoxelTool, block_position):
	visible = block_position != null

	if block_position != null:
		global_transform.origin = Vector3(block_position) + Vector3(.5, 0, .5)
		var meta = tool.get_voxel_metadata(block_position)
		var state = 0
		if meta != null and "health" in meta and meta["health"] > 0:
			print(1 - float(meta["health"])/BlockDataRegistry.get_block_data(tool.get_voxel((block_position))).max_health)
			state = floor(8.0*(1 - float(meta["health"])/BlockDataRegistry.get_block_data(tool.get_voxel((block_position))).max_health))
		for indicator in indicators:
			indicator.frame = state

