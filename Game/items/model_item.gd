extends Item


# Called when the node enters the scene tree for the first time.
func _ready():
	$MeshInstance3D.mesh = load(item_data.model_path)
