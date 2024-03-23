class_name VoxelCharacterBody3D
extends CharacterBody3D

func get_voxel_position():
	return Vector3i(floor(global_transform.origin.x), floor(global_transform.origin.y), floor(global_transform.origin.z))
