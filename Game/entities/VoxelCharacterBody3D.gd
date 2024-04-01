class_name VoxelCharacterBody3D
extends CharacterBody3D

func _ready() -> void:
	Signals.entity_attacked.connect(do_knockback)

func get_voxel_position() -> Vector3i:
	return Vector3i(global_position.floor())


func _is_in_water(tool: VoxelTool) -> bool:
	for direction in [Vector3.UP, Vector3.DOWN]:
		for offset in [Vector3(1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1)]:
			var result = tool.raycast(global_transform.origin + 0.3*offset - 0.95*direction, direction, 1, 2)
			if result != null:
				return true
	return false


func do_knockback(attacker:Node, attacked: Node, _damage: float) -> void:
	if attacked == self:
		# knockback
		# I really don't like this method since its kinda reaching in but eh
		var collision_point = global_position
		var attacker_position = attacker.global_position
		if "hit_detection" in attacker:
			collision_point= attacker.hit_detection.get_collision_point()
		velocity = -(attacker_position - collision_point).normalized() * 5
		velocity.y = 3.5
