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
			var sibling_data = sibling.save_data()
			if sibling_data != null:
				data["sibling_data"][sibling.name] = sibling_data
	if get_parent().has_method("save_data"):
		data["parent_data"] = get_parent().save_data()
	return data


func load_data(entity_data):
	get_parent().global_transform.origin = entity_data["position"]

	for sibling_name in entity_data["sibling_data"]:
		var sibling = get_parent().find_child(sibling_name)
		sibling.load_data(entity_data["sibling_data"][sibling_name])
	
	if "parent_data" in entity_data:
		get_parent().load_data(entity_data["parent_data"])

