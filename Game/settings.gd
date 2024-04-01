extends Node


var audio = AudioSettings.new()
var controls = ControlsSettings.new()


class ControlsSettings:
	var sensitivity := 1.0

	func from_config(config: ConfigFile):
		sensitivity = config.get_value("controls", "sensitivity", 1.0)

	func to_config(config: ConfigFile):
		config.set_value("controls", "sensitivity", sensitivity)

class AudioSettings:
	var master_volume := 1.0
	var player_volume := 1.0
	var entities_volume := 1.0
	var blocks_volume := 1.0

	func from_config(config: ConfigFile):
		master_volume = config.get_value("audio", "master_volume", 1.0)
		player_volume = config.get_value("audio", "player_volume", 1.0)
		entities_volume = config.get_value("audio", "entities_volume", 1.0)
		blocks_volume = config.get_value("audio", "blocks_volume", 1.0)
		apply()
	
	func _set_bus_volume_percent(bus, volume_percent):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), 10.0 * log(volume_percent))

	func apply():
		_set_bus_volume_percent("Master", master_volume)
		_set_bus_volume_percent("Player", player_volume)
		_set_bus_volume_percent("Entities", entities_volume)
		_set_bus_volume_percent("Blocks", blocks_volume)

	func to_config(config: ConfigFile):
		config.set_value("audio", "master_volume", master_volume)
		config.set_value("audio", "player_volume", player_volume)
		config.set_value("audio", "entities_volume", entities_volume)
		config.set_value("audio", "blocks_volume", blocks_volume)


# Called when the node enters the scene tree for the first time.
func _ready():
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

	audio.from_config(config)
	controls.from_config(config)


func apply():
	audio.apply()


func save():
	# Create new ConfigFile object.
	var config = ConfigFile.new()

	# Store some values.
	audio.to_config(config)
	controls.to_config(config)

	# Save it to a file (overwrite if already exists).
	config.save("user://settings.cfg")
