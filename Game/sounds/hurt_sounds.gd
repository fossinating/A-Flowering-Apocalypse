extends Node3D


@export var stream: AudioStream
@export_enum("Player", "Entity") var bus = "Entity"


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.entity_attacked.connect(entity_attacked)


func entity_attacked(_attacker: Node, attacked: Node, _damage: float):
	if get_parent() == attacked:
		var player := AudioStreamPlayer3D.new()
		player.bus = bus
		player.stream = stream
		add_child(player)
		player.global_position = global_position
		player.play()
		await player.finished
		player.queue_free()

