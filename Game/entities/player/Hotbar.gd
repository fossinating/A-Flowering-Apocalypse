extends Control


@export var inventory: EntityInventory
var selected_index := 0


func _ready():
	var i = 0
	for child in find_child("Hotbar Items").get_children():
		child.inventory = inventory
		child.slot = i
		i += 1
		print(child.name, "| ", child.name == "Hotbar Slot " + str(selected_index+1))
	print("Hotbar Slot " + str(selected_index+1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for child in find_child("Hotbar Items").get_children():
		child.set_selected(child.name == "Hotbar Slot " + str(selected_index+1))
		child.update()
	
