extends Node3D


@onready var streams: Dictionary = {
	"invalid": load("res://entities/EntityHealthManager.gd")
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	Signals.block_damaged.connect(block_damaged)
	Signals.block_placed.connect(block_placed)


func block_placed(position: Vector3i, id: int, _player: Player):
	var player = AudioStreamPlayer3D.new()
	player.bus = "blocks"
	# TODO: change this to separate place sounds
	player.stream = streams[BlockDataRegistry.get_block_data(id).break_sound_id]
	add_child(player)
	player.global_position = position
	player.play()
	await player.finished
	player.queue_free()

func block_damaged(position: Vector3i, _damager: Node, _damage: int):
	var player = AudioStreamPlayer3D.new()
	player.bus = "blocks"
	player.stream = streams[BlockDataRegistry.get_block_data(
		WorldManager.get_world_node().get_voxel_tool().get_voxel(position)).break_sound_id]
	add_child(player)
	player.global_position = position
	player.play()
	await player.finished
	player.queue_free()
