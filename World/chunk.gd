extends Node3D


var chunk_coordinates: Vector2i
@export var object_carrier: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var save_file = FileAccess.open("user://saves/" + Globals.shared_data.name + 
		"/objects/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.y), FileAccess.READ)

	if save_file != null:
		save_file.get_var()

		save_file.close()


func save():
	var save_file = FileAccess.open("user://saves/" + Globals.shared_data.name + 
		"/objects/chunk_"+str(chunk_coordinates.x)+"_" + str(chunk_coordinates.y), FileAccess.WRITE)

	save_file.store_var(object_carrier.get_children())

	save_file.close()


func unload():
	save()
