extends AudioStreamPlayer3D


@onready var timer: Timer = get_node("Timer")
@onready var streams: Dictionary = {
	
}


func _ready():
	if not get_parent() is VoxelCharacterBody3D:
		push_error("Step sounds must be child of VoxelCharacterBody3D")
		get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var flat_velocity = get_parent().velocity
	flat_velocity.y = 0
	timer.wait_time = 1.0 / flat_velocity.length()


func _on_timer_timeout():
	if get_parent().is_on_floor():
		stream = streams[BlockDataRegistry.get_block_data(
			WorldManager.get_world_node().get_voxel_tool().get_voxel(
				get_parent().get_voxel_position() - Vector3i.DOWN)).step_sound_id]
