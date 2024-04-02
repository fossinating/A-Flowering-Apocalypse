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
		
		$SubViewport/VoxelTerrain.visible = false
		$SubViewport/MeshInstance3D.visible = true
		for item in ItemRegistry.get_registry().items.values():
			if item is ItemRegistry.ToolItemData or item is ItemRegistry.WeaponItemData:
				$SubViewport/MeshInstance3D.scale = 0.4*Vector3.ONE
			elif item.id == "flower_paste":
				$SubViewport/MeshInstance3D.scale = 0.7*Vector3.ONE
			else:
				$SubViewport/MeshInstance3D.scale = Vector3.ONE
			if not item is ItemRegistry.BlockItemData:
				$SubViewport/MeshInstance3D.mesh = load(item.model_path)
				for i in 1:
					viewport.set_update_mode(SubViewport.UPDATE_ONCE)
					await RenderingServer.frame_post_draw
				viewport.get_texture().get_image().save_png("res://textures/" + item.id + ".png")
		print("done!")
