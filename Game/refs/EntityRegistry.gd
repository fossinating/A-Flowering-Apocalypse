class_name EntityRegistry

class EntitySpawnData:
    var id: String
    var packed_scene: PackedScene

    func _init(init_id: String, init_packed_scene: PackedScene):
        self.id = init_id
        self.packed_scene = init_packed_scene

static var entities = {
    "rose": EntitySpawnData.new("rose", preload("res://entities/flowers/rose/rose.tscn")),
    "zombie": EntitySpawnData.new("zombie", preload("res://entities/zombie/zombie.tscn")),
    "item": EntitySpawnData.new("item", preload("res://items/dropped_item.tscn")),
}

static func get_entity(id: String):
    if id in entities:
        return entities[id]
    else:
        return null