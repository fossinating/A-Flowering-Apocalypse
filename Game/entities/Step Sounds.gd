extends Node3D


@onready var timer: Timer = get_node("Timer")
@export_enum("Player", "Entity") var bus = "Entity"


@onready var streams: Dictionary = {
	"invalid": load("res://sounds/blocks/stone/stone_randomizer.tres"),
	"dirt": load("res://sounds/blocks/dirt/dirt_randomizer.tres"),
	"leaves": load("res://sounds/blocks/leaves/leaves_randomizer.tres"),
	"wood": load("res://sounds/blocks/log/log_randomizer.tres"),
	"stone": load("res://sounds/blocks/stone/stone_randomizer.tres"),
}


func _ready():
	if not get_parent() is VoxelCharacterBody3D:
		push_error("Step sounds must be child of VoxelCharacterBody3D")
		get_tree().quit()


var was_on_floor = false
var was_moving = false
func _physics_process(_delta):
	if not get_parent().is_on_floor():
		timer.stop()
	elif not was_on_floor:
		play_step()
	was_on_floor = get_parent().is_on_floor()


	var flat_velocity = get_parent().velocity
	flat_velocity.y = 0
	var is_moving = flat_velocity.length_squared() > 0
	if is_moving and (timer.is_stopped() or not was_moving):
		play_step()
	was_moving = is_moving


func play_step():
	var flat_velocity = get_parent().velocity
	flat_velocity.y = 0
	var block_id = WorldManager.get_world_node().get_voxel_tool().get_voxel(
				get_parent().get_voxel_position() + 1*Vector3i.DOWN)
	var stream_id = BlockDataRegistry.get_block_data(block_id).step_sound_id
	var player: AudioStreamPlayer3D
	if get_parent().is_on_floor() and flat_velocity.length_squared() > 0 and stream_id != "invalid":
		player = AudioStreamPlayer3D.new()
		player.bus = bus
		add_child(player)
		player.global_position = global_position
		player.stream = streams[stream_id]
		player.play()
	timer.wait_time = 1.7 / max(flat_velocity.length(), get_parent().MAX_WALK_SPEED)
	timer.start()
	if player != null:
		await player.finished
		player.queue_free()
