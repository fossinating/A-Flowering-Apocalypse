extends Node3D


var chunk_coords: Vector2i
@export var object_carrier: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var save_file = FileAccess.open("user://saves/" + Globals.save_name + "/objects/chunk_"+str(chunk_coords.x)+"_" + str(chunk_coords.y), FileAccess.READ)

	save_file.get_var()

	save_file.close()


func save():
	var save_file = FileAccess.open("user://saves/" + Globals.save_name + "/objects/chunk_"+str(chunk_coords.x)+"_" + str(chunk_coords.y), FileAccess.WRITE)

	save_file.store_var(object_carrier.get_children())

	save_file.close()


func unload():
	save()