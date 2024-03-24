class_name EntityRegistry

class EntitySpawnData:
    var id: String
    var packed_scene: PackedScene

    func _init(id: String, packed_scene: PackedScene):
        self.id = id
        self.packed_scene = packed_scene

static var entities = {
    "rose": EntitySpawnData.new("rose", preload("res://entities/flowers/rose/rose.tscn"))
}

static func get_entity(id: String):
    if id in entities:
        return entities[id]
    else:
        return null