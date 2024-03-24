class_name SaveInfo

var name: String
var world_seed: String

func _init(name: String, world_seed: String = ""):
	self.name = name
	self.world_seed = world_seed