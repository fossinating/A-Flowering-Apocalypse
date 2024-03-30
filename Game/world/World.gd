extends Node3D


@export var voxel_terrain: VoxelTerrain
@export var chunk_manager: ChunkManager
@export var player: Player
@export var empty_checker: Area3D
@export var temporary_object_holder: Node3D
var voxel_tool


func get_voxel_tool():
	if voxel_tool == null:
		voxel_tool = WorldManager.get_world_node().voxel_terrain.get_voxel_tool()
	return voxel_tool


func _init():
	WorldManager.register_world(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	var stream = voxel_terrain.stream
	stream.directory = "user://saves/" + WorldManager.get_world().save_name + "/voxels"
	voxel_terrain.stream = stream
	Signals.block_damaged.connect(block_damaged)
	Signals.block_broken.connect(block_broken)
	Signals.block_placed.connect(block_placed)


func block_placed(block_position: Vector3i, block_id: int, _player: Player):
	var tool := voxel_terrain.get_voxel_tool()
	tool.set_voxel(block_position, block_id)
	tool.set_voxel_metadata(block_position, null)


func is_position_empty(block_position: Vector3i) -> bool:
	var tool := voxel_terrain.get_voxel_tool()
	if not BlockDataRegistry.get_registry().get_block_data(tool.get_voxel(block_position)).is_empty:
		return false
	empty_checker.global_position = block_position
	await get_tree().physics_frame
	return not empty_checker.has_overlapping_bodies()


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


@onready var dropped_item_scene = preload("res://items/dropped_item.tscn")


func block_broken(block_position: Vector3i, _breaker: Node):
	var tool = voxel_terrain.get_voxel_tool()
	var block_data = BlockDataRegistry.get_block_data(tool.get_voxel(block_position))
	tool.set_voxel(block_position, 0)
	var chunk_coordinates := (block_position / 16)
	var dropped_item_data = block_data.get_drop()
	if dropped_item_data != null:
		var dropped_item := dropped_item_scene.instantiate()
		dropped_item.item_stack = dropped_item_data
		get_node("Chunk Manager/Chunk" + str(chunk_coordinates.x) + "," + str(chunk_coordinates.z) + "/Objects").add_child(dropped_item)
		dropped_item.global_position = Vector3(block_position) + Vector3(0.5, 0.5, 0.5)
	tool.set_voxel_metadata(block_position, null)


func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_save_world()


func _save_world():
	voxel_terrain.save_modified_blocks()
	chunk_manager.save_all()
	player.save()

func get_chunk_for_coordinates(coordinates: Vector3):
	var chunk_coordinates := Vector3i((coordinates / 16).floor())
	return get_node("Chunk Manager/Chunk" + str(chunk_coordinates.x) + "," + str(chunk_coordinates.z))
	
func is_position_loaded(position: Vector3):
	return voxel_terrain.is_area_meshed(AABB(position, Vector3.ONE))
	
func add_temporary_node(node: Node3D, time_to_live=30):
	temporary_object_holder.add_child(node)
	await get_tree().create_timer(time_to_live).timeout
	if is_instance_valid(node):
		node.queue_free()
