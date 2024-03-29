extends PanelContainer

var slot: int
var inventory: EntityInventory

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Item Icon/Item Count".text = str(slot)


func update():
	for child in get_children():
		remove_child.call_deferred(child)
	if inventory.inventory[slot] != null:
		var item_icon = load("res://items/item_icon.tscn").instantiate()

		item_icon.texture = load("res://textures/" + inventory.inventory[slot].item.id + ".png")
		item_icon.find_child("Item Count", true, false).text = str(inventory.inventory[slot].count)
		add_child(item_icon)
