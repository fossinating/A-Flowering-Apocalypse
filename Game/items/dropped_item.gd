extends RigidBody3D
class_name DroppedItem

var item_stack: ItemStack

# Called when the node enters the scene tree for the first time.
func _ready():
	if item_stack != null:
		add_child(item_stack.item.get_node())
		Signals.item_picked_up.connect(item_picked_up)


func _physics_process(_delta):
	freeze = not WorldManager.get_world_node().is_position_loaded(global_position)
		

func item_picked_up(dropped_item: DroppedItem, remainder: int):
	if dropped_item == self:
		item_stack.count = remainder
		if remainder == 0:
			queue_free()

func save_data():
	return {
		"item_stack_data": item_stack.save_data()
	}

func load_data(data):
	item_stack = ItemStack.from_data(data["item_stack_data"])
	_ready()
