extends Control


@onready var inventory_slot_scene = preload("res://ui/inventory_slot.tscn")
@onready var dropped_item_scene = preload("res://items/dropped_item.tscn")
@export var main_inventory: Control
@export var hotbar: Control
@export var inventory: EntityInventory
@export var hud: Control
var held_item: ItemStack


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 7:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot = i
		inventory_slot.inventory = inventory
		inventory_slot.inventory_controller = self
		hotbar.add_child(inventory_slot)
	for i in 21:
		var inventory_slot = inventory_slot_scene.instantiate()
		inventory_slot.slot = i + 7
		inventory_slot.inventory = inventory
		inventory_slot.inventory_controller = self
		main_inventory.add_child(inventory_slot)


func update():
	for inventory_holder in [hotbar, main_inventory]:
		for inventory_slot in inventory_holder.get_children():
			inventory_slot.update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if held_item != null:
		get_node("Held Item Icon").position = get_global_mouse_position() - Vector2(25,25)
	if Input.is_action_just_pressed("inventory"):
		visible = !visible
		hud.visible = !visible
		owner.ui_open = visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
		if not visible:
			if held_item != null:
				var dropped_item = dropped_item_scene.instantiate()
				dropped_item.item_stack = held_item
				dropped_item.global_position = owner.global_position
				held_item = null
				# Hoping and praying that owner is the player
				WorldManager.get_world_node().get_chunk_for_coordinates(owner.global_position).get_node("Objects").add_child(dropped_item)
				dropped_item.global_position = owner.global_position
				#print("Dropped item at ", dropped_item.global_position, WorldManager.get_world_node().get_chunk_for_coordinates(owner.global_position).chunk_coordinates, owner.name)
				get_node("Held Item Icon").set_item(null)
	# TODO: change this to something that only updates when the underlying inventory updates
	if visible:
		update()


func on_click(slot: InventorySlot):
	if held_item == null:
		held_item = inventory.inventory[slot.slot]
		inventory.inventory[slot.slot] = null
	else:
		if inventory.inventory[slot.slot] == null:
			inventory.inventory[slot.slot] = held_item
			held_item = null
		else:
			var remainder = inventory.inventory[slot.slot].try_merge(held_item)
			if remainder == held_item.count:
				var tmp = inventory.inventory[slot.slot]
				inventory.inventory[slot.slot] = held_item
				held_item = tmp
			else:
				if remainder == 0:
					held_item = null
				else:
					held_item.count = remainder
	get_node("Held Item Icon").set_item(held_item)
	slot.update()
