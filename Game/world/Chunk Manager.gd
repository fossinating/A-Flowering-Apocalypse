extends Node3D
class_name ChunkManager

@export var render_distance: int
@export var player: Player
@onready var chunk_source = preload("res://world/chunk.tscn")
var zombie_map := FastNoiseLite.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	zombie_map.seed = 13 ^ hash(WorldManager.get_world().world_seed)
	zombie_map.frequency = 1.0 / 128.0
	zombie_map.fractal_octaves = 4
	load_around_player()


func load_around_player():
	var player_chunk = Vector3i(floor(player.global_position.x / 16), floor(player.global_position.y / 16), floor(player.global_position.z / 16))
	for x_off in range(-render_distance, render_distance+1):
		for z_off in range(-render_distance, render_distance+1):
			var chunk_coordinates = player_chunk + Vector3i(x_off, 0, z_off)
			var chunk_name = "Chunk"+str(chunk_coordinates.x)+","+str(chunk_coordinates.z)
			if not has_node(chunk_name):
				var chunk = chunk_source.instantiate()
				chunk.name = chunk_name
				chunk.chunk_coordinates = chunk_coordinates
				add_child(chunk)


func save_all():
	for child in get_children():
		child.save()

# TODO: make it so that chunk leave detection doesn't cause issues when moving above the chunk range
func on_entity_leave_chunk(entity, left_chunk):
	if entity == player:
		# Process it as a player, meaning we have to load in some chunks if they aren't already loaded
		var player_chunk = Vector3i(floor(player.global_position.x / 16), floor(player.global_position.y / 16), floor(player.global_position.z / 16))
		for chunk in get_children():
			if abs(player_chunk.x - chunk.chunk_coordinates.x) > render_distance + 1 or abs(player_chunk.z - chunk.chunk_coordinates.z) > render_distance + 1:
				chunk.unload()
		load_around_player()
	else:
		if left_chunk.object_carrier.is_ancestor_of(entity):
			var entity_chunk = Vector3i(floor(entity.global_position.x / 16), floor(entity.global_position.y / 16), floor(entity.global_position.z / 16))
			var new_chunk = find_child("Chunk"+str(entity_chunk.x)+","+str(entity_chunk.z), false, false)
			if new_chunk != null:
				entity.reparent(new_chunk.object_carrier)
			else:
				push_error("Entity walked into unloaded chunks!")


func get_zombie_map_at(chunk_coordinates: Vector3):
	return zombie_map.get_noise_2d(chunk_coordinates.x, chunk_coordinates.z)


