class_name ItemRegistry

static var registry = null

static func get_registry():
	if registry == null:
		registry = ItemRegistry.new()
	return registry

var items = {}


func _init():

	# Add all the block items
	add_item(BlockItemData.new(1))
	add_item(BlockItemData.new(2))
	add_item(BlockItemData.new(3))
	
	# Water items, not possible to get
	add_item(BlockItemData.new(4))
	add_item(BlockItemData.new(5))


	add_item(BlockItemData.new(6))
	add_item(BlockItemData.new(7))

	# Actual items

	add_item(ModelItemData.new("rose", "res://entities/flowers/rose/rose.obj"))

	# Weapons
	add_item(WeaponItemData.new("wooden_sword", "res://items/wooden_sword.obj", 2))
	add_item(WeaponItemData.new("stone_sword", "res://items/stone_sword.obj", 3))

	# Tools
	add_item(ToolItemData.new("wooden_pickaxe", "res://items/wooden_pickaxe.obj", HarvestFlag.PICKAXE, 2))
	add_item(ToolItemData.new("stone_pickaxe", "res://items/stone_pickaxe.obj", HarvestFlag.PICKAXE, 4))
	add_item(ToolItemData.new("wooden_axe", "res://items/wooden_axe.obj", HarvestFlag.AXE, 2))
	add_item(ToolItemData.new("stone_axe", "res://items/stone_axe.obj", HarvestFlag.AXE, 4))


func add_item(item: ItemData):
	items[item.id] = item

func get_item(id: String):
	return items[id]

enum HarvestFlag { PICKAXE = 1, AXE = 2, SHOVEL = 4}

class ItemData:
	var max_stack_size := 99
	var id: String

	func _init(init_id: String, init_mss: int = 99):
		max_stack_size = init_mss
		id = init_id

	func get_node():
		var item_node = load("res://items/item.tscn").instantiate()
		item_node.load_data(self)
		return item_node

	func equals(other: ItemData):
		return id == other.id

class BlockItemData extends ItemData:
	var block_id: int

	func _init(init_block_id: int, init_mss: int = 99):
		super(BlockDataRegistry.get_block_data(init_block_id).text_id, init_mss)
		block_id = init_block_id

	func get_node():
		var item_node = load("res://items/block_item.tscn").instantiate()
		item_node.load_data(self)
		return item_node

class ModelItemData extends ItemData:
	var model_path: String

	func _init(init_id: String, init_model_path: String, init_mss: int = 99):
		super(init_id, init_mss)
		self.model_path = init_model_path

	func get_node():
		var item_node = load("res://items/model_item.tscn").instantiate()
		item_node.load_data(self)
		return item_node

class ToolItemData extends ModelItemData:
	var harvest_flags: int
	var damage: int

	@warning_ignore("shadowed_variable")
	func _init(id: String, model_path: String, harvest_flags: int, damage: int, mss: int = 1):
		super(id, model_path, mss)
		self.harvest_flags = harvest_flags
		self.damage = damage

class WeaponItemData extends ModelItemData:
	var damage: int

	@warning_ignore("shadowed_variable")
	func _init(id: String, model_path: String, damage: int, mss: int = 1):
		super(id, model_path, mss)
		self.damage = damage



# TODO: Object items
#class ObjectItemData extends ModelItemData:
