extends Area3D
class_name ScentEmitter

@export var scent := 0.0
var scent_modified = false

@onready var particles: GPUParticles3D = get_node("GPUParticles3D")

func _ready():
    $CollisionShape3D.shape = $CollisionShape3D.shape.duplicate()

    update()

func update():
    $CollisionShape3D.disabled = scent == 0
    particles.emitting = scent >= 13
    if scent != 0:
        $CollisionShape3D.shape.radius = abs(scent)
    if scent > 0:
        particles.amount = clamp(int(floor(max(scent-10, 0) / 3)), 1, 32)

func set_scent(new_scent):
    #print(get_parent().name, " has been set to ", new_scent)
    scent_modified = true
    scent = new_scent

    update()

    

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

    update()