extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.shared_data = SaveInfo.new("demo", "")
	get_tree().change_scene_to_file("res://world/World.tscn")
