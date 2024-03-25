extends Marker3D

@export var step_target: Node3D
@export var step_distance: float = 1.0

@export var other_target: Node3D

var is_stepping: = false

func _process(_delta):
    global_position.y = step_target.global_position.y
    var current_distance = global_position.distance_squared_to(step_target.global_position)
    if not is_stepping and (not other_target.is_stepping or current_distance > pow(1.5*step_distance, 2)) and current_distance > pow(step_distance, 2):
        step()

func step():
    is_stepping = true
    var target_pos = step_target.global_position
    var halfway = (global_position + step_target.global_position) / 2

    var t = get_tree().create_tween()
    t.tween_property(self, "global_position", target_pos+basis.y, 0.6)
    t.tween_property(self, "global_position", target_pos, 0.2)
    t.tween_callback(func(): is_stepping = false)