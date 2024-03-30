extends Panel


@onready var main_menu = owner
var saves = []


func _ready():
	for directory in DirAccess.get_directories_at("user://saves"):
		if FileAccess.file_exists("user://saves/" + directory + "/world.dat"):
			var save_file = FileAccess.open("user://saves/" + directory + "/world.dat", FileAccess.READ)
			saves.append(save_file.get_var())
			save_file.close()
			$"Saved Games List".add_item(directory)


func _on_new_save_pressed():
	main_menu.change_page_to(main_menu.new_save_page)


func _on_load_save_pressed():
	main_menu.find_child("Zombie").free()
	WorldManager.world_data = null
	WorldManager.world = null
	WorldManager.load_world(saves[$"Saved Games List".get_selected_items()[0]]["save_name"])
	get_tree().change_scene_to_file("res://world/World.tscn")

func _on_back_button_pressed():
	main_menu.change_page_to(main_menu.main_page)


func _on_saved_games_list_item_selected(_index:int):
	$"Load Save".disabled = false
