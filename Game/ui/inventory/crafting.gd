extends Control


class CraftingRecipe:
	var result: ItemStack
	var ingredients: Dictionary

	@warning_ignore("shadowed_variable")
	func _init(result: ItemStack, ingredients: Dictionary):
		self.result = result
		self.ingredients = ingredients
	
	func can_craft(inventory_manager: EntityInventory) -> bool:
		return _run(inventory_manager, false)

	func _run(inventory_manager: EntityInventory, consume=false):
		var remaining_ingredients = ingredients.duplicate(true)
		var remaining_room_required = result.count

		for i in len(inventory_manager.inventory):
			var item_stack = inventory_manager.inventory[i]
			if item_stack == null:
				remaining_room_required = max(0, remaining_room_required - (result.item.max_stack_size))
				continue
			if remaining_room_required > 0 and item_stack.item == result.item:
				remaining_room_required = max(0, remaining_room_required - (item_stack.item.max_stack_size - item_stack.count))
			if item_stack.item in remaining_ingredients:
				var items_consumed = min(remaining_ingredients[item_stack.item], item_stack.count)
				remaining_ingredients[item_stack.item] -= items_consumed
				if consume:
					item_stack.count -= items_consumed
				if remaining_ingredients[item_stack.item] == 0:
					remaining_ingredients.erase(item_stack.item)
				if item_stack.count == 0:
					if consume:
						item_stack = null
					remaining_room_required = max(0, remaining_room_required - (result.item.max_stack_size))
			if consume:
				inventory_manager.inventory[i] = item_stack
				
		
		return remaining_ingredients.size() == 0 and remaining_room_required == 0
		
	
	func craft(inventory_manager: EntityInventory) -> bool:
		return _run(inventory_manager, true)


@export var inventory_display: Control
@onready var inventory_manager: EntityInventory = inventory_display.inventory


var recipes = [
	CraftingRecipe.new(ItemStack.from_id("leaves", 1), {
		ItemRegistry.get_registry().get_item("log"): 3
	})
]


func _ready():
	for recipe in recipes:
		get_node("Recipe Selector").add_item(recipe.result.item.id.capitalize() + ((" x" + recipe.result.count) if recipe.result.count > 1 else ""), load("res://textures/" + recipe.result.item.id + ".png"))
	_on_visibility_changed()


# Called when the node enters the scene tree for the first time.
func _on_visibility_changed():
	get_node("Recipe Selector").deselect_all()
	get_node("Item Icon").visible = false
	get_node("Item Name").visible = false
	get_node("Requires Label").visible = false
	get_node("Recipe Ingredients").visible = false
	get_node("Craft Button").visible = false


func _on_recipe_selector_item_selected(index:int):
	var recipe = recipes[index]
	get_node("Item Icon").set_item(recipe.result)
	get_node("Item Icon").visible = true
	get_node("Item Name").text = recipe.result.item.id.capitalize()
	get_node("Item Name").visible = true
	get_node("Recipe Ingredients").clear()
	for ingredient in recipe.ingredients.keys():
		get_node("Recipe Ingredients").add_item(ingredient.id.capitalize() + " x" + str(recipe.ingredients[ingredient]), load("res://textures/" + ingredient.id + ".png"), false)
	get_node("Recipe Ingredients").visible = true
	get_node("Craft Button").visible = true
	get_node("Craft Button").disabled = not recipe.can_craft(inventory_manager)




func _process(_delta):
	if len(get_node("Recipe Selector").get_selected_items()) == 1:
		var recipe: CraftingRecipe = recipes[get_node("Recipe Selector").get_selected_items()[0]]
		get_node("Craft Button").disabled = not recipe.can_craft(inventory_manager)


func _on_craft_button_pressed():
	var recipe: CraftingRecipe = recipes[get_node("Recipe Selector").get_selected_items()[0]]
	if recipe.can_craft(inventory_manager):
		recipe.craft(inventory_manager)
		inventory_manager.add_item_stack(recipe.result)
	inventory_display.update()
