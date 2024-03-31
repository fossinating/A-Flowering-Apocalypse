extends Control


@onready var menu = owner


func _on_resume_game_button_pressed():
	menu.close()


func _on_save_and_quit_button_pressed():
	WorldManager.save_and_quit()
