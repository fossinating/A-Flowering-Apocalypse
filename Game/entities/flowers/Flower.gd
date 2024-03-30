extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.entity_attacked.connect(entity_attacked)


func entity_attacked(attacker: Node, attacked: Node, damage: float):
	if is_ancestor_of(attacked):
		var dropped_item = load("res://items/dropped_item.tscn").instantiate()
		dropped_item.item_stack = ItemStack.from_id("rose", 1)
		get_parent().add_child(dropped_item)
		dropped_item.global_position = global_position
		dropped_item.linear_velocity = Vector3(.05-.1*randf(), 3, .05-.1*randf())
		queue_free()
