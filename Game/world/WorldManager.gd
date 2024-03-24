extends Node3D


@export var voxel_terrain: VoxelTerrain
@export var chunk_manager: ChunkManager


func _init():
	if not Globals.shared_data is SaveInfo:
		push_error("SaveInfo not in shared data!")

# Called when the node enters the scene tree for the first time.
func _ready():
	var stream = voxel_terrain.stream
	stream.directory = "user://saves/" + Globals.shared_data.name + "/voxels"
	voxel_terrain.stream = stream
	Signals.block_damaged.connect(block_damaged)
	Signals.block_broken.connect(block_broken)


func block_damaged(block_position: Vector3i, damager: Node, damage: int):
	var tool = voxel_terrain.get_voxel_tool()
	var block_data = BlockDataRegistry.get_block_data(tool.get_voxel(block_position))
	if block_data.max_health < 0:
		return
	
	var block_meta = tool.get_voxel_metadata(block_position)
	if block_meta == null:
		block_meta = {}
	
	if "health" in block_meta:
		block_meta["health"] -= damage
	else:
		block_meta["health"] = block_data.max_health - damage
	
	if block_meta["health"] <= 0:
		Signals.block_broken.emit(block_position, damager)
	else:
		tool.set_voxel_metadata(block_position, block_meta)


func block_broken(block_position: Vector3i, _breaker: Node):
	var tool = $VoxelTerrain.get_voxel_tool()
	tool.set_voxel(block_position, 0)

func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_save_world()


func _save_world():
	voxel_terrain.save_modified_blocks()
	chunk_manager.save_all()
