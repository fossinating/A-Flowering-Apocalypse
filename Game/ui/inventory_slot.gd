extends PanelContainer

var slot: int

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Item Icon/Item Count".text = str(slot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
