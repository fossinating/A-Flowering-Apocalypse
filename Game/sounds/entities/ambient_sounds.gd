extends Node3D


@export var stream: AudioStream
@export_enum("Player", "Entity") var bus = "Entity"
@export var min_time := 1.5
@export var max_time := 2.5
@onready var timer = get_node("Timer")


# Called when the node enters the scene tree for the first time.
func _ready():
	trigger_timer()

func trigger_timer():
	timer.wait_time = randf_range(min_time, max_time)
	timer.start()


func _on_timer_timeout():
	if "dead" in get_parent() and get_parent().dead:
		return
	var player := AudioStreamPlayer3D.new()
	player.bus = bus
	player.stream = stream
	add_child(player)
	player.global_position = global_position
	player.play()
	await player.finished
	player.queue_free()
