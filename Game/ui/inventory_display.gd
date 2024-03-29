extends Control


@onready var inventory_slot_scene = preload("res://ui/inventory_slot.tscn")
@export var main_inventory: Control
@export var hotbar: Control
@export var inventory: EntityInventory


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 5:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot = i
		inventory_slot.inventory = inventory
		hotbar.add_child(inventory_slot)
	for i in 20:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot = i + 10
		inventory_slot.inventory = inventory
		main_inventory.add_child(inventory_slot)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		visible = !visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
		if visible:
			for slot in hotbar.get_children():
				slot.update()
			for slot in main_inventory.get_children():
				slot.update()