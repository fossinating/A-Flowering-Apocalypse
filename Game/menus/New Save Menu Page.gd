extends Panel

@onready var main_menu = owner

func get_save_name():
	var save_name = $"Save Name Input".text
	var regex = RegEx.new()
	regex.compile("^([a-Z]|[0-9]| )+$")
	if regex.search(save_name) == null:
		return null
	return save_name.replace(" ", "_").to_lower()

func _on_create_save_pressed():
	pass # Replace with function body.
	# Confirm input data is valid (i.e. save file doesn't already exist)
	var save_name = get_save_name()
	if save_name == null || DirAccess.dir_exists_absolute("user://saves/"+save_name):
		return
	
	# Make directory for the save
	DirAccess.make_dir_recursive_absolute("user://saves/"+save_name)
	# Write save file data
	var save_file = FileAccess.open("user://saves/"+save_name+"/save.bin", FileAccess.WRITE)
	save_file.store_var({
		"display_name": $"Save Name Input".text,
		"seed": $"Seed Input".text if $"Seed Input".text != "" else str(randf())
	})
	save_file.close()
	# Pass save file information to shared data buffer
	Globals.shared_data = SaveInfo.new(save_name)
	# Switch scene to world
	get_tree().change_scene_to_file("res://world/World.tscn")


func _on_back_button_pressed():
	main_menu.change_page_to(main_menu.save_page)


func _on_save_name_input_text_changed(new_text):
	var save_name = get_save_name()
	if save_name == null:
		$"Save Name Message".text = "Invalid save name"
	elif save_name != $"Save Name Input".text:
		$"Save Name Message".text = "Will be saved as `" + save_name + "`"
	elif DirAccess.dir_exists_absolute("user://saves/"+save_name):
		$"Save Name Message".text = "Save location occupied"
	else:
		$"Save Name Message".text = ""
