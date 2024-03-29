extends Control

@export var main_page: Control
@export var save_page: Control
@export var new_save_page: Control
@export var credits_page: Control


@export var leftside: Control
@export var current: Control
@export var rightside: Control

@export var current_carrier: Control
@export var new_carrier: Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#Globals.shared_data = SaveInfo.new("demo", "")
	#get_tree().change_scene_to_file("res://world/World.tscn")

func change_page_to(new_page: Control):
	var target_anchor
	if leftside.is_ancestor_of(new_page):
		new_carrier.anchor_left = leftside.anchor_left
		new_carrier.anchor_right = leftside.anchor_right
		target_anchor = Vector2(rightside.anchor_left, rightside.anchor_right)
	elif rightside.is_ancestor_of(new_page):
		new_carrier.anchor_left = rightside.anchor_left
		new_carrier.anchor_right = rightside.anchor_right
		target_anchor = Vector2(leftside.anchor_left, leftside.anchor_right)
	else:
		push_error("New menu was not in either left or right side")
	
	current_carrier.anchor_left = 0
	current_carrier.anchor_right = 1
	new_page.reparent(new_carrier)
	current.get_child(0).reparent(current_carrier)
	for node in [new_page, current_carrier.get_child(0)]:
		node.offset_left = 0
		node.offset_right = 0
	
	var t = get_tree().create_tween()
	t.tween_property(new_carrier, "anchor_left", 0, 0.5)
	t.parallel().tween_property(new_carrier, "anchor_right", 1, 0.5)
	t.parallel().tween_property(current_carrier, "anchor_left", target_anchor.x, 0.5)
	t.parallel().tween_property(current_carrier, "anchor_right", target_anchor.y, 0.5)
	t.tween_callback(
		func():
			if target_anchor == Vector2(rightside.anchor_left, rightside.anchor_right):
				current_carrier.get_child(0).reparent(rightside)
			else:
				current_carrier.get_child(0).reparent(leftside)
			new_page.reparent(current)
	)
