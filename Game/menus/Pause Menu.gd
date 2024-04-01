extends ColorRect


func back():
	get_node("Main Pause Page").visible = true
	get_node("Settings Page").visible = false


func close():
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func open():
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		visible = !visible
		get_tree().paused = visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED


func _on_options_button_pressed():
	get_node("Main Pause Page").visible = false
	get_node("Settings Page").visible = true
