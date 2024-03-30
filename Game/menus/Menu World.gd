extends "res://world/World.gd"

func _init():
	WorldManager.world_data = WorldManager.WorldData.new({
		"display_name": "Menu World",
		"save_name": "Menu World",
		"seed": "seed"
	})

# Called when the node enters the scene tree for the first time.
func _ready():
	var stream = voxel_terrain.stream
	stream.directory = "res://menu/world/voxels"
	voxel_terrain.stream = stream
	#Signals.block_damaged.connect(block_damaged)
	#Signals.block_broken.connect(block_broken)
	#Signals.block_placed.connect(block_placed)
	WorldManager.register_world(self)

func _process(_delta):
	if player != null:
		player.scent_emitter.set_scent(0)
		player.get_node("EntityInventory").inventory[0] = ItemStack.from_id("grass", 99)
		player.get_node("EntityInventory").inventory[1] = ItemStack.from_id("dirt", 99)
		player.get_node("EntityInventory").inventory[2] = ItemStack.from_id("stone", 99)
		player.get_node("EntityInventory").inventory[3] = ItemStack.from_id("log", 99)
		player.get_node("EntityInventory").inventory[4] = ItemStack.from_id("leaves", 99)


func _save_world():
	if player:
		voxel_terrain.save_modified_blocks()
		chunk_manager.save_all()
		player.save()