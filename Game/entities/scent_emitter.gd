extends Area3D
class_name ScentEmitter

@export var scent := 0.0
var scent_modified = false

func _ready():
    $CollisionShape3D.shape.radius = abs(scent)

func set_scent(new_scent):
    scent_modified = true
    scent = new_scent

    $CollisionShape3D.disabled = scent == 0
    if scent != 0:
        $CollisionShape3D.shape.radius = abs(scent)

func add_scent(additional_scent, bypass=false):
    set_scent(scent + additional_scent if bypass else max(scent + additional_scent, 0))

func save_data():
    if scent_modified:
        return {
            "scent": scent
        }
    else:
        return null

func load_data(data):
    scent = data["scent"]
    scent_modified = true