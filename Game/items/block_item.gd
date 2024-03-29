extends Item


@export var mesher: VoxelMesherBlocky
@export var material: Material


# Called when the node enters the scene tree for the first time.
func _ready():
	var buffer = VoxelBuffer.new()
	buffer.create(3,3,3)
	buffer.set_voxel(item_data.block_id, 1, 1, 1, VoxelBuffer.CHANNEL_TYPE)
	var mesh = mesher.build_mesh(buffer, [material])
	print(mesh)
	$MeshInstance3D.mesh = mesh
	#var tool = $VoxelTerrain.get_voxel_tool()
	#tool.channel = VoxelBuffer.CHANNEL_TYPE
	#print($VoxelTerrain.is_area_meshed(AABB(Vector3i(0,0,0), Vector3.ONE)))
	#tool.set_voxel(Vector3i(0,0,0), item_data.block_id)
	#tool.update()


func load_data(new_item_data: ItemRegistry.ItemData):
	super(new_item_data)
