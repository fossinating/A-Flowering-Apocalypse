class_name BlockDataRegistry

class BlockData:
	var id: int
	var text_id: String
	var display_name: String
	var max_health: int
	var item_drops: Array[ItemStack]

	func _init(init_id: int, init_text_id: String, init_display_name: String, init_max_health: int, init_item_drops: Array[ItemStack] = []):
		self.id = init_id
		self.text_id = init_text_id
		self.display_name = init_display_name
		self.max_health = init_max_health
		self.item_drops = init_item_drops

var data = null
static var registry: BlockDataRegistry

func _init():
	data = [
		BlockData.new(0, "air", "Air", -1),
		BlockData.new(1, "grass", "Grass", 5, [ItemStack.from_id("dirt")]),
		BlockData.new(2, "dirt", "Dirt", 5, [ItemStack.from_id("dirt")]),
		BlockData.new(3, "stone", "Stone", 15, [ItemStack.from_id("stone")]),
		BlockData.new(4, "water_top", "Water", -1),
		BlockData.new(5, "water", "Water", -1),
		BlockData.new(6, "log", "Log", 10, [ItemStack.from_id("log")]),
		BlockData.new(7, "leaves", "Leaves", 3),
	]


static func get_registry():
	if registry == null:
		registry = BlockDataRegistry.new()
	return registry



static func get_block_data(id: int):
	return get_registry().data[id]
