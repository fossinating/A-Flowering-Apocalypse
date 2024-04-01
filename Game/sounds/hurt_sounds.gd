extends Node3D


@export var hurt_stream: AudioStream
@export var dead_stream: AudioStream
@export_enum("Player", "Entity") var bus = "Entity"
var has_died = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.entity_attacked.connect(entity_attacked)


func entity_attacked(_attacker: Node, attacked: Node, _damage: float):
	if get_parent() == attacked and not has_died:
		var health_manager = get_parent().find_child("EntityHealthManager", false, true)
		var player := AudioStreamPlayer3D.new()
		player.bus = bus
		player.stream = dead_stream if health_manager and health_manager.health <= 0 else hurt_stream
		add_child(player)
		player.global_position = global_position
		player.play()
		await player.finished
		player.queue_free()
		has_died = health_manager and health_manager.health <= 0

