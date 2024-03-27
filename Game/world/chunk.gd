extends Node3D


var chunk_coordinates: Vector2i
@export var object_carrier: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://saves/" + WorldManager.get_world().save_name + "/entities/"):
		dir.make_dir_recursive("user://saves/" + WorldManager.get_world().save_name + "/entities/")
	var save_file = FileAccess.open("user://saves/" + WorldManager.get_world().save_name + 
		"/entities/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.y), FileAccess.READ)

	if save_file != null:
		var saved_entities = save_file.get_var()

		for entity_data in saved_entities:
			var entity = EntityRegistry.get_entity(entity_data["id"]).packed_scene.instantiate()
			object_carrier.add_child(entity)
			entity.find_child("EntitySaver").load_data(entity_data)

		save_file.close()
	else:
		generate()


func generate():
	save()


func save():
	print("user://saves/" + WorldManager.get_world().save_name + 
		"/entities/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.y))
	var save_file = FileAccess.open("user://saves/" + WorldManager.get_world().save_name + 
		"/entities/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.y), FileAccess.WRITE)
	push_error(FileAccess.get_open_error())

	var entity_data = []

	for child in object_carrier.get_children():
		var entity_saver = child.find_child("EntitySaver")

		if entity_saver != null:
			entity_data.append(entity_saver.save_data())

	save_file.store_var(object_carrier.get_children())

	save_file.close()


func unload():
	save()
