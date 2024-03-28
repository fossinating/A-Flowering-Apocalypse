extends Node3D


var chunk_coordinates: Vector3i
@export var object_carrier: Node
@onready var zombie_scene = preload("res://entities/zombie/zombie.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://saves/" + WorldManager.get_world().save_name + "/entities/"):
		dir.make_dir_recursive("user://saves/" + WorldManager.get_world().save_name + "/entities/")
	var save_file = FileAccess.open("user://saves/" + WorldManager.get_world().save_name + 
		"/entities/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.z), FileAccess.READ)

	global_position = 16 * Vector3(chunk_coordinates.x, 0, chunk_coordinates.z)

	if save_file != null:
		var saved_entities = save_file.get_var()

		for entity_data in saved_entities:
			if "id" in entity_data:
				var entity = EntityRegistry.get_entity(entity_data["id"]).packed_scene.instantiate()
				object_carrier.add_child(entity)
				entity.find_child("EntitySaver").load_data(entity_data)

		save_file.close()
	else:
		generate()

# TODO: change this to be something that only generates zombies at certain structures or something like that?
func generate():
	print(get_parent().get_zombie_map_at(chunk_coordinates))
	if abs(get_parent().get_zombie_map_at(chunk_coordinates)) > .75:
		var rand = RandomNumberGenerator.new()
		rand.seed = hash(WorldManager.get_world().world_seed) ^ 13*chunk_coordinates.x ^ 31 * chunk_coordinates.z
		var zombie = zombie_scene.instantiate()
		object_carrier.add_child(zombie)
		zombie.position = Vector3(rand.randi_range(0, 15), 0, rand.randi_range(0,15))
		print(WorldManager.get_world().get_height_at(zombie.global_position.x, zombie.global_position.z))
		zombie.global_position.y = WorldManager.get_world().get_height_at(zombie.global_position.x, zombie.global_position.z) + 2
	save()


func save():
	var save_file = FileAccess.open("user://saves/" + WorldManager.get_world().save_name + 
		"/entities/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.z), FileAccess.WRITE)
	if FileAccess.get_open_error():
		push_error(FileAccess.get_open_error())

	var entity_data = []

	for child in object_carrier.get_children():
		var entity_saver = child.find_child("EntitySaver")

		if entity_saver != null:
			entity_data.append(entity_saver.save_data())

	save_file.store_var(entity_data)

	save_file.close()


func unload():
	save()
	get_parent().remove_child(self)


func _on_entry_detection_body_exited(body:Node3D):
	get_parent().on_entity_leave_chunk(body, self)
