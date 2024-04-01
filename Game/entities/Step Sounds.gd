extends AudioStreamPlayer3D


@onready var timer: Timer = get_node("Timer")


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
	pass # Replace with function body.
