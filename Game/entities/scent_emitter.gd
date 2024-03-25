extends Area3D
class_name ScentEmitter

var scent := 0.0

func set_scent(new_scent):
    scent = new_scent

    $CollisionShape3D.disabled = scent == 0
    if scent != 0:
        $CollisionShape3D.shape.radius = abs(scent)

func add_scent(additional_scent):
    set_scent(scent + additional_scent)