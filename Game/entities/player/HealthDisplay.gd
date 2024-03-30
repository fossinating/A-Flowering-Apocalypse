extends ColorRect


@export var health_manager: EntityHealthManager
@onready var catchup_bar = get_node("Catchup Health Bar")
@onready var live_bar = get_node("Live Health Bar")


var has_setup = false
const MAX_CHANGE_RATE = 2.5


func setup():
	catchup_bar.max_value = health_manager.max_health
	catchup_bar.value = health_manager.health
	live_bar.max_value = health_manager.max_health
	live_bar.value = health_manager.health
	has_setup = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not has_setup and health_manager != null:
		setup()
	
	catchup_bar.value += clamp(health_manager.health - catchup_bar.value, -MAX_CHANGE_RATE*delta, MAX_CHANGE_RATE*delta)
	live_bar.value = health_manager.health
