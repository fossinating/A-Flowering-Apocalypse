extends Node


@export var inventory: EntityInventory
@export var hotbar: Control
var selected_index := 0
@export var hand: Node3D


func _ready():
	var i = 0
	for child in hotbar.get_node("Hotbar Items").get_children():
		child.inventory = inventory
		child.slot = i
		i += 1
	Signals.block_interacted.connect(block_interacted)

func block_interacted(raycast_result: VoxelRaycastResult, player: Player):
	if player == owner:
		if inventory.inventory[selected_index] != null and inventory.inventory[selected_index].item is ItemRegistry.BlockItemData:
			if player.block_indicator.is_empty() and await WorldManager.get_world_node().is_position_empty(raycast_result.previous_position):
				inventory.inventory[selected_index].count -= 1
				Signals.block_placed.emit(raycast_result.previous_position, inventory.inventory[selected_index].item.block_id, player)
				if inventory.inventory[selected_index].count == 0:
					inventory.inventory[selected_index] = null
					update_hand()

var old_hand = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if hotbar.is_visible_in_tree():
		if Input.is_action_just_released("scroll_left"):
			selected_index = (selected_index + 6) % 7
		if Input.is_action_just_released("scroll_right"):
			selected_index = (selected_index + 1) % 7
		
		
		for i in 7:
			if Input.is_action_just_pressed("slot " + str(i+1)):
				selected_index = i
	
	for child in hotbar.get_node("Hotbar Items").get_children():
		child.set_selected(child.name == "Hotbar Slot " + str(selected_index+1))
		child.update()
	if old_hand != inventory.inventory[selected_index]:
		update_hand()
		old_hand = inventory.inventory[selected_index]

func update_hand():
	for n in hand.get_children():
		n.queue_free()
	if inventory.inventory[selected_index] != null:
		hand.add_child(inventory.inventory[selected_index].item.get_node())

func save_data():
	return {
		"selected_index": selected_index
	}

func load_data(data):
	selected_index = data["selected_index"]
	update_hand()
