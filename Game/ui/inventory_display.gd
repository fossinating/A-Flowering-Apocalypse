extends Control


@onready var inventory_slot_scene = preload("res://ui/inventory_slot.tscn")
@export var main_inventory: Control
@export var hotbar: Control
@export var inventory: Control


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 5:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot = i
		hotbar.add_child(inventory_slot)
	for i in 20:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot = i + 10
		main_inventory.add_child(inventory_slot)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
