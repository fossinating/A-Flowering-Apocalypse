class_name ItemStack


var item: ItemRegistry.ItemData
var count: int


static func from_id(id: String, new_count: int = 1):
	return ItemStack.new(ItemRegistry.get_registry().get_item(id), new_count)

func _init(new_item: ItemRegistry.ItemData, new_count: int = 1):
	item = new_item
	count = new_count

func copy():
	return ItemStack.new(item, count)

# Returns the number of items remaining in other_stack
func try_merge(other_stack: ItemStack) -> int:
	if not item.equals(other_stack.item):
		return other_stack.count
	else:
		var original_count = count
		count = min(item.max_stack_size, count + other_stack.count)
		return other_stack.count - (count - original_count)

static func from_data(data):
	return ItemStack.new(ItemRegistry.get_registry().get_item(data["item_id"]), data["count"])

func save_data():
	return {
		"item_id": item.id,
		"count": count
	}
