extends Node
class_name EntityHealthManager


@export var max_health: int

@export_category("Passive Regen")
@export var passive_regen_enabled := false
@export var passive_regen_rate: float
@export var passive_regen_delay: float

var passive_regen_timer: Timer
var health: float


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.entity_attacked.connect(entity_attacked)
	health = max_health
	if passive_regen_enabled:
		passive_regen_timer = Timer.new()
		passive_regen_timer.set_wait_time(passive_regen_delay)
		passive_regen_timer.one_shot = true
		add_child(passive_regen_timer)


func _process(delta):
	if passive_regen_enabled and passive_regen_timer.is_stopped():
		health = min(max_health, health + passive_regen_rate*delta)



func save_data():
	return {
		"health": health
	}

func load_data(entity_data):
	health = entity_data["health"]
	if health == 0 and get_parent().has_method("die"):
		get_parent().die()


func entity_attacked(attacker: Node, attacked: Node, damage: float):
	if attacked == get_parent():
		if passive_regen_enabled:
			passive_regen_timer.start()
		health -= damage
		if health <= 0:
			Signals.entity_killed.emit(attacker, attacked)