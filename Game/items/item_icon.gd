extends TextureRect


func set_item(item_stack: ItemStack):
	visible = item_stack != null
	if item_stack == null:
		return
	texture = load("res://textures/" + item_stack.item.id + ".png")
	get_node("Item Count").text = str(item_stack.count)
