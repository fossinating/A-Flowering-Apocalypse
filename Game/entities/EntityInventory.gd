extends Node
class_name EntityInventory

var inventory = []
@export var inventory_slots: int
@export var can_pickup: bool = true
var items_to_pick_up = []


func _on_body_entered(body:Node3D):
	# This should be almost 100% guaranteed true
	if body is DroppedItem:
		items_to_pick_up.append(body)


func _physics_process(_delta):
	while len(items_to_pick_up) > 0:
		var item = items_to_pick_up[0]
		var item_stack_count = item.item_stack
		for slot_id in len(inventory):
			if inventory[slot_id] == null:
				inventory[slot_id] = item.item_stack.copy()
				item_stack_count = 0
				break
			else:
				if inventory[slot_id] is ItemStack:
					item_stack_count = inventory[slot_id].try_merge(item.item_stack)
					if item_stack_count == 0:
						break
		# this may never be true, need to test(because modifying item_stack may modify body.item_stack)
		if item.item_stack.count != item_stack_count:
			Signals.item_picked_up.emit(item, item_stack_count)
		items_to_pick_up.remove_at(0)


func _ready():
	for i in inventory_slots:
		inventory.append(null)


func save_data():
	var inventory_data = []

	for slot in inventory:
		if slot == null:
			inventory_data.append(null)
		else:
			inventory_data.append(slot.save_data())
	
	return inventory_data

func load_data(data):
	inventory = []
	for slot_data in data:
		if slot_data == null:
			inventory.append(null)
		else:
			inventory.append(ItemStack.from_data(slot_data))
