extends Node


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


func entity_attacked(attacker: Node, attacked: Node, damage: float):
	if attacked == get_parent():
		health -= damage
		if health <= 0:
			Signals.entity_killed.emit(attacker, attacked)