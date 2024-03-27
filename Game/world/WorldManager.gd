class_name WorldManager

static var world_data: WorldData

class WorldData:
    var display_name: String
    var save_name: String
    var world_seed: String

    func _init(data):
        display_name = data["display_name"]
        save_name = data["save_name"]
        world_seed = data["seed"]

static func load_world(save_name: String):
    var save_file = FileAccess.open("user://saves/" + save_name + "/world.dat", FileAccess.READ)
    world_data = WorldData.new(save_file.get_var())
    save_file.close()

static func get_world():
    return world_data

static func unload_world():
    world_data = null