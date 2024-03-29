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


func add_item(item: ItemData):
	items[item.id] = item

func get_item(id: String):
	return items[id]
	

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
