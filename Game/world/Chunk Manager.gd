extends Node3D
class_name ChunkManager

@export var render_distance: int
@export var player: Player
@onready var chunk_source = preload("res://world/chunk.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(-render_distance, render_distance+1):
		for y in range(-render_distance, render_distance+1):
			var chunk = chunk_source.instantiate()
			chunk.name = "Chunk"+str(x)+","+str(y)
			chunk.chunk_coordinates = Vector2(x,y)
			add_child(chunk)


func save_all():
	for child in get_children():
		child.save()
