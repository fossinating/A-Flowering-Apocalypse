extends AspectRatioContainer

var slot: int
var inventory: EntityInventory
var selected := false

@export var selected_texture: Texture2D
@export var unselected_texture: Texture2D

func update():
	for child in get_child(0).get_children():
		get_child(0).remove_child.call_deferred(child)
	if inventory.inventory[slot] != null:
		var item_icon = load("res://items/item_icon.tscn").instantiate()

		item_icon.texture = load("res://textures/" + inventory.inventory[slot].item.id + ".png")
		item_icon.find_child("Item Count", true, false).text = str(inventory.inventory[slot].count)
		get_child(0).add_child(item_icon)

func set_selected(new_selected: bool):
	if selected != new_selected:
		selected = new_selected
		get_child(0).texture = selected_texture if selected else unselected_texture
