extends Control


@onready var menu = owner


func _on_resume_game_button_pressed():
	menu.close()


func _on_save_and_quit_button_pressed():
	WorldManager.unload_world()
	get_tree().change_scene_to_file("res://menus/Main Menu.tscn")
	get_tree().paused = false
