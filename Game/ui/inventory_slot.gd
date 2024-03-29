extends AspectRatioContainer
class_name InventorySlot

var slot: int
var inventory: EntityInventory
var selected := false

@export var selected_texture: Texture2D
@export var unselected_texture: Texture2D
@export var inventory_controller: Control

func update():
	get_node("Item Icon").visible = inventory.inventory[slot] != null
	if inventory.inventory[slot] != null:
		get_node("Item Icon").set_item(inventory.inventory[slot])


func set_selected(new_selected: bool):
	if selected != new_selected:
		selected = new_selected
		get_node("Slot Background").texture = selected_texture if selected else unselected_texture


func _on_gui_input(event:InputEvent):
	if inventory_controller != null:
		if event is InputEventMouseButton:
			if event.pressed:
				inventory_controller.on_click(self)

