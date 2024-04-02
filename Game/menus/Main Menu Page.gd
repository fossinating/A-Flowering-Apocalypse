extends Control


@onready var main_menu = owner


func _on_play_singleplayer_pressed():
	main_menu.change_page_to(main_menu.save_page)


func _on_play_multiplayer_pressed():
	pass # Replace with function body.


func _on_settings_pressed():
	main_menu.change_page_to(main_menu.settings_page)


func _on_quit_pressed():
	print("quit pressed!")
	get_tree().quit()


func _on_credits_pressed():
	main_menu.change_page_to(main_menu.credits_page)
