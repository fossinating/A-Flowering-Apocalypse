class_name BlockDataRegistry

class BlockData:
	var id: int
	var text_id: String
	var display_name: String
	var max_health: int

	func _init(id: int, text_id: String, display_name: String, max_health: int):
		self.id = id
		self.text_id = text_id
		self.display_name = display_name
		self.max_health = max_health


static var data = [
	BlockData.new(0, "air", "Air", -1),
	BlockData.new(1, "grass", "Grass", 5),
	BlockData.new(2, "dirt", "Dirt", 5),
	BlockData.new(3, "stone", "Stone", 10),
	BlockData.new(4, "water_top", "Water", -1),
	BlockData.new(5, "water", "Water", -1)
]

static func get_block_data(id: int):
	return data[id]
