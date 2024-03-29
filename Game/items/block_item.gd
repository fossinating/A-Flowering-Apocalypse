extends Item


@export var mesher: VoxelMesherBlocky
@export var material: Material


# TODO: convert the item image generator to using this
# Called when the node enters the scene tree for the first time.
func _ready():
	var buffer = VoxelBuffer.new()
	buffer.create(3,3,3)
	buffer.set_voxel(item_data.block_id, 1, 1, 1, VoxelBuffer.CHANNEL_TYPE)
	var mesh = mesher.build_mesh(buffer, [material])
	$MeshInstance3D.mesh = mesh


func load_data(new_item_data: ItemRegistry.ItemData):
	super(new_item_data)
