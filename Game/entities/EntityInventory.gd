extends Node
class_name EntityInventory

var inventory = []
@export var inventory_slots: int
@export var can_pickup: bool = true
var items_to_pick_up = []


func _on_body_entered(body:Node3D):
	# This should be almost 100% guaranteed true
	if body is DroppedItem:
		var item_stack_count = add_item_stack(body.item_stack)
		if body.item_stack.count != item_stack_count:
			Signals.item_picked_up.emit(body, item_stack_count)
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
	# Just in case saved inventory isn't the right size
	while len(inventory) > inventory_slots:
		inventory.remove_at(len(inventory)-1)
	while len(inventory) < inventory_slots:
		inventory.append(null)

func add_item_stack(item_stack: ItemStack) -> int:
	var items_remaining = item_stack.count
	for fill_empty in [false, true]:
		for slot_id in len(inventory):
			if inventory[slot_id] == null and fill_empty:
				inventory[slot_id] = ItemStack.new(item_stack.item, min(items_remaining, item_stack.item.max_stack_size))
				items_remaining = max(0, items_remaining - item_stack.item.max_stack_size)
				if items_remaining == 0:
					return 0
			else:
				if inventory[slot_id] is ItemStack:
					items_remaining = inventory[slot_id].try_merge(ItemStack.new(item_stack.item, items_remaining))
					if items_remaining == 0:
						return 0
	return items_remaining
