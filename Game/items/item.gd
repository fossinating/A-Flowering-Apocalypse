extends Node3D
class_name Item

var item_data: ItemRegistry.ItemData


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_data(new_item_data: ItemRegistry.ItemData):
	item_data = new_item_data
