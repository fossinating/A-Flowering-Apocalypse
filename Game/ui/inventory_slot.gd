extends AspectRatioContainer

var slot: int
var inventory: EntityInventory
var selected := false

@export var selected_texture: Texture2D
@export var unselected_texture: Texture2D

func update():
	get_node("Item Icon").visible = inventory.inventory[slot] != null
	if inventory.inventory[slot] != null:
		get_node("Item Icon").texture = load("res://textures/" + inventory.inventory[slot].item.id + ".png")
		get_node("Item Icon").find_child("Item Count", true, false).text = str(inventory.inventory[slot].count)


func set_selected(new_selected: bool):
	if selected != new_selected:
		selected = new_selected
		get_node("Slot Background").texture = selected_texture if selected else unselected_texture
