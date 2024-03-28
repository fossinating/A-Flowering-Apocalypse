class_name ItemStack


var item: Item
var count: int


static func from_id(id: String, new_count: int = 1):
    return ItemStack.new(ItemRegistry.get_registry().get_item(id), new_count)

func _init(new_item: Item, new_count: int = 1):
    item = new_item
    count = new_count