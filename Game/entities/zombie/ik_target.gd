extends Marker3D

@export var step_target: Node3D
@export var step_distance: float = 1.0

@export var other_target: Node3D

var t: Tween

var is_stepping: = false

func _process(_delta):
	global_position.y = step_target.global_position.y
	var current_distance = global_position.distance_squared_to(step_target.global_position)
	if not is_stepping and (not other_target.is_stepping or current_distance > pow(1.5*step_distance, 2)) and current_distance > pow(step_distance, 2):
		step()

func step():
	is_stepping = true
	var target_pos = step_target.global_position

	var sec_per_step = min(1.0 / Vector2(owner.velocity.x, owner.velocity.z).length(), 1)

	if t != null:
		t.kill()
	t = get_tree().create_tween()
	t.tween_property(self, "global_position", target_pos+Vector3.UP*.2, 0.8 * sec_per_step)
	t.tween_property(self, "global_position", target_pos, 0.2 * sec_per_step)
	t.tween_callback(func(): is_stepping = false)

func quick_step():
	is_stepping = true
	var target_pos = step_target.global_position
	if t != null:
		t.kill()
	t = get_tree().create_tween()
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback(func(): is_stepping = false)
