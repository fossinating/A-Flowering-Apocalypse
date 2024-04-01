class_name BlockDataRegistry

class BlockData:
	var id: int
	var text_id: String
	var display_name: String
	var max_health: int
	var item_drops: BlockDropTable
	var is_empty: bool
	var particle_color: Color
	var step_sound_id: String
	var break_sound_id: String

	@warning_ignore("shadowed_variable")
	func _init(init_id: int, init_text_id: String, init_display_name: String, init_max_health: int, particle_color: Color, step_sound_id: String, break_sound_id: String, init_item_drops: BlockDropTable = BlockDropTable.new([]), init_is_empty: bool = false):
		self.id = init_id
		self.text_id = init_text_id
		self.display_name = init_display_name
		self.max_health = init_max_health
		self.particle_color = particle_color
		self.item_drops = init_item_drops
		self.is_empty = init_is_empty
		self.step_sound_id = step_sound_id
		self.break_sound_id = break_sound_id
	
	func get_drop():
		return item_drops.get_result()
	
class BlockDropOption:
	var item_id: String
	var item_count: int
	var weight: float

	func _init(init_item_id: String, init_item_count: int = 1, init_weight: float = 1.0):
		self.item_id = init_item_id
		self.item_count = init_item_count
		self.weight = init_weight
	
	func get_item_stack():
		return ItemStack.from_id(item_id, item_count)

class BlockDropTable:
	var options: Array[BlockDropOption]
	var total_weight: float

	static var EMPTY := BlockDropTable.new([])

	func _init(init_options: Array[BlockDropOption]):
		self.options = init_options
		self.total_weight = 0.0
		for option in init_options:
			total_weight += option.weight

	func get_result():
		var target_weight = WorldManager.get_world().get_entity_randomizer().randf_range(0, total_weight)
		for option in options:
			target_weight -= option.weight
			if target_weight <= 0:
				return option.get_item_stack()
		push_error("Ran out of options")
		return null

var data = null
static var registry: BlockDataRegistry

func _init():
	data = [
		BlockData.new(0, "air", "Air", -1, Color(0,0,0,0), "invalid", "invalid", BlockDropTable.EMPTY, true),
		BlockData.new(1, "grass", "Grass", 5, Color(0,76.0/255,5.0/255,0), "dirt", "dirt", BlockDropTable.new([BlockDropOption.new("dirt")])),
		BlockData.new(2, "dirt", "Dirt", 5, Color(70.0/255,29.0/255,0,0), "dirt", "dirt", BlockDropTable.new([BlockDropOption.new("dirt")])),
		BlockData.new(3, "stone", "Stone", 15, Color(122.0/255,122.0/255,122.0/255,0), "stone", "stone", BlockDropTable.new([BlockDropOption.new("stone")])),
		BlockData.new(4, "water_top", "Water", -1, Color(0,0,1.0,0), "invalid", "invalid", BlockDropTable.EMPTY, true),
		BlockData.new(5, "water", "Water", -1, Color(0,0,1.0,0), "invalid", "invalid", BlockDropTable.EMPTY, true),
		BlockData.new(6, "log", "Log", 10, Color(255.0/255,202.0/255,147.0/255,0), "wood", "wood", BlockDropTable.new([BlockDropOption.new("log")])),
		BlockData.new(7, "leaves", "Leaves", 3, Color(29.0/255,133.0/255,0,0), "leaves", "leaves"),
	]


static func get_registry():
	if registry == null:
		registry = BlockDataRegistry.new()
	return registry



static func get_block_data(id: int):
	return get_registry().data[id]
