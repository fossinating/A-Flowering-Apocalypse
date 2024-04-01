extends Label

@export var slider: Slider
@export var title: String

func _ready():
    slider.value_changed.connect(value_changed)
    update()

func update(value=slider.value):
    text = title + ": " + str(value)

func value_changed(value: float):
    update(value)