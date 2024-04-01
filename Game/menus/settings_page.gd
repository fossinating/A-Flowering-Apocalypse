extends Panel

@onready var main_menu = owner

func _ready():
	get_node("TabContainer/Controls/Mouse Sensitivity Slider").value = int(Settings.controls.sensitivity * 100)
	get_node("TabContainer/Audio/Master Volume Slider").value = int(Settings.audio.master_volume*100)
	get_node("TabContainer/Audio/Player Volume Slider").value = int(Settings.audio.player_volume*100)
	get_node("TabContainer/Audio/Entities Volume Slider").value = int(Settings.audio.entities_volume*100)
	get_node("TabContainer/Audio/Blocks Volume Slider").value = int(Settings.audio.blocks_volume*100)


func _on_back_button_pressed():
	main_menu.back()

func _on_save_button_pressed():
	Settings.controls.sensitivity = get_node("TabContainer/Controls/Mouse Sensitivity Slider").value / 100.0
	Settings.audio.master_volume = get_node("TabContainer/Audio/Master Volume Slider").value / 100.0
	Settings.audio.player_volume = get_node("TabContainer/Audio/Player Volume Slider").value / 100.0
	Settings.audio.entities_volume = get_node("TabContainer/Audio/Entities Volume Slider").value / 100.0
	Settings.audio.blocks_volume = get_node("TabContainer/Audio/Blocks Volume Slider").value / 100.0
	Settings.apply()
	Settings.save()


func _on_mouse_sensitivity_slider_value_changed(value:float):
	get_node("TabContainer/Controls/Mouse Sensitivity Label").text = "Mouse Sensitivity: " + str(value)
