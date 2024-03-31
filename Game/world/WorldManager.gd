class_name WorldManager

static var world_data: WorldData
static var world
const HeightmapCurve = preload("res://generator/heightmap_curve.tres")


class WorldData:
	var display_name: String
	var save_name: String
	var world_seed: String
	var heightmap_noise := FastNoiseLite.new()
	var entity_randomizer := RandomNumberGenerator.new()

	func _init(data):
		display_name = data["display_name"]
		save_name = data["save_name"]
		world_seed = data["seed"]

		heightmap_noise.seed = hash(world_seed)
		heightmap_noise.frequency = 1.0 / 128.0
		heightmap_noise.fractal_octaves = 4
		HeightmapCurve.bake()

		entity_randomizer.seed = hash(world_seed)
	
	func get_height_at(x: int, z: int) -> int:
		var t = 0.5 + 0.5 * heightmap_noise.get_noise_2d(x, z)
		return int(HeightmapCurve.sample_baked(t))
	
	func get_entity_randomizer():
		return entity_randomizer

static func load_world(save_name: String):
	var save_file = FileAccess.open("user://saves/" + save_name + "/world.dat", FileAccess.READ)
	world_data = WorldData.new(save_file.get_var())
	save_file.close()

static func get_world() -> WorldData:
	return world_data

static func unload_world():
	if world != null:
		world._save_world()
		world.get_tree().process_frame.connect(func():
			world = null
			world_data = null
		, CONNECT_ONE_SHOT)
	
	
static func register_world(new_world):
	world = new_world
	
static func get_world_node():
	return world
	
static func save_and_quit():
	if world != null:
		WorldManager.unload_world()
		world.get_tree().change_scene_to_file("res://menus/Main Menu.tscn")
		world.get_tree().paused = false
