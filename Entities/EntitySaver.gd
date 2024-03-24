extends Node

@export var id: String

func save_data():
	var data = {
		"id": id,
		"position": get_parent().global_transform.origin,
		"sibling_data": {}
	}
	for sibling in get_parent().get_children():
		if sibling == self:
			continue
		if sibling.has_method("save_data"):
			data["sibling_data"][sibling.name] = sibling.save_data()
	return data


func load_data(entity_data):
	get_parent().global_transform.origin = entity_data["position"]

	for sibling_name in entity_data["sibling_data"]:
		var sibling = get_parent().find_child(sibling_name)
		sibling.load_data(entity_data["sibling_data"][sibling_name])

