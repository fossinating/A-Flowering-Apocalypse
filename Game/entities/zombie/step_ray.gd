extends RayCast3D

@export var step_target: Node3D

func _physics_process(_delta):
    if is_colliding():
        pass#step_target.global_position.y = get_collision_point().y