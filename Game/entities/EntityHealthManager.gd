extends Node
class_name EntityHealthManager


@export var max_health: int
var health: float


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.entity_attacked.connect(entity_attacked)
	health = max_health


func save_data():
	return {
		"health": health
	}

func load_data(entity_data):
	health = entity_data["health"]
	if health == 0 and get_parent().has_method("die"):
		get_parent().die()


func entity_attacked(attacker: Node, attacked: Node, damage: float):
	print("Entity attacked")
	if attacked == get_parent():
		print("parent attacked")
		health -= damage
		if health <= 0:
			Signals.entity_killed.emit(attacker, attacked)