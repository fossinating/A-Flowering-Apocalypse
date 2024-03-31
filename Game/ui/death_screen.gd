extends ColorRect

@onready var respawn_button = get_node("Respawn Button")
@onready var quit_button = get_node("Quit Button")


func _on_respawn_button_pressed():
	WorldManager.get_world_node().respawn_player()


func _on_quit_button_pressed():
	WorldManager.save_and_quit()

func _process(delta):
	color.a = min(color.a + 170.0/250*delta, 170.0/255)
	if color.a > 169/255.0:
		for btn in [respawn_button, quit_button]:
			btn.modulate.a = min(btn.modulate.a + delta/0.5, 1.0)
		


func _on_visibility_changed():
	if visible:
		color.a = 0
		for btn in [respawn_button, quit_button]:
			btn.modulate.a = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
