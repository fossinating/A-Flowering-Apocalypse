extends Node

var inventory = []
@export var inventory_slots: int
@export var can_pickup: bool = true


func _on_body_entered(body:Node3D):
	var item_stack = body.item_stack
	# This should be almost 100% guaranteed true
	if body is DroppedItem:
		for slot in inventory:
			if slot == null:
				slot = item_stack
			else:
				if slot is ItemStack:
					item_stack = slot.try_merge(item_stack)
					if item_stack.count == 0:
						break
	# this may never be true, need to test(because modifying item_stack may modify body.item_stack)
	if body.item_stack.count != item_stack.count:
		Signals.item_picked_up.emit(body, item_stack.count)


func _ready():
	for i in inventory_slots:
		inventory.append(null)