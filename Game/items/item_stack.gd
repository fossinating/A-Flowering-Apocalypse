class_name ItemStack


var item: ItemRegistry.ItemData
var count: int


static func from_id(id: String, new_count: int = 1):
	return ItemStack.new(ItemRegistry.get_registry().get_item(id), new_count)

func _init(new_item: ItemRegistry.ItemData, new_count: int = 1):
	item = new_item
	count = new_count

static func from_data(data):
	return ItemStack.new(ItemRegistry.get_registry().get_item(data["item_id"]), data["count"])

func save_data():
	return {
		"item_id": item.id,
		"count": count
	}
