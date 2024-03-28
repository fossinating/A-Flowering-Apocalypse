extends RigidBody3D
class_name DroppedItem


var item_stack: ItemStack



# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.item_picked_up.connect(item_picked_up)


func item_picked_up(dropped_item: DroppedItem, remainder: int):
	if dropped_item == self:
		item_stack.count = remainder
		if remainder == 0:
			queue_free()
