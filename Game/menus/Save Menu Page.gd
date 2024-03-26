extends Panel


@onready var main_menu = owner


func _on_new_save_pressed():
	main_menu.change_page_to(main_menu.new_save_page)


func _on_load_save_pressed():
	pass # Replace with function body.


func _on_back_button_pressed():
	main_menu.change_page_to(main_menu.main_page)
