extends Control


# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		var tool = $SubViewport/VoxelTerrain.get_voxel_tool()
		var viewport = $SubViewport
		viewport.set_update_mode(SubViewport.UPDATE_DISABLED)

		for block_data in BlockDataRegistry.get_registry().data:
			tool.set_voxel(Vector3.ZERO, block_data.id)
			for i in 5:
				viewport.set_update_mode(SubViewport.UPDATE_ONCE)
				await RenderingServer.frame_post_draw
			viewport.get_texture().get_image().save_png("res://textures/" + block_data.text_id + ".png")
