extends Node3D
class_name Item

var item_data: ItemRegistry.ItemData


func load_data(new_item_data: ItemRegistry.ItemData):
	item_data = new_item_data
