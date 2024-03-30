extends ColorRect

@export var scent_emitter: ScentEmitter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	color.a = clamp(scent_emitter.scent/55.0, 0, 1) * 200.0/255
