extends Item


# Called when the node enters the scene tree for the first time.
func _ready():
	var tool = $VoxelTerrain.get_voxel_tool()
	tool.set_voxel(Vector3i(0,0,0), item_data.block_id)


func load_data(new_item_data: ItemRegistry.ItemData):
	super(new_item_data)