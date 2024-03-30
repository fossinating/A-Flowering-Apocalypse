extends Node3D

@onready var blood_spurt_particle_scene := preload("res://particles/blood_spurt_particles.tscn")
@onready var mining_particle_scene := preload("res://particles/mining_particle.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.entity_attacked.connect(entity_attacked)
	Signals.block_damaged.connect(block_damaged)


func entity_attacked(attacker: Node, attacked: Node, _damage: float):
	var blood_spurt := blood_spurt_particle_scene.instantiate()
	add_child(blood_spurt)
	blood_spurt.emitting = true
	blood_spurt.global_position = attacker.hit_detection.get_collision_point() if "hit_detection" in attacker else attacked.global_position + Vector3.UP
	await get_tree().create_timer(1.5).timeout
	blood_spurt.queue_free()


func block_damaged(block_position: Vector3i, damager: Node, damage: int):
	var mining_particle: GPUParticles3D = mining_particle_scene.instantiate()
	add_child(mining_particle)
	mining_particle.emitting = true
	mining_particle.amount = 8*damage
	var draw_pass = mining_particle.draw_pass_1.duplicate()

	draw_pass.material.albedo_color = BlockDataRegistry.get_block_data(WorldManager.get_world_node().get_voxel_tool().get_voxel(block_position)).particle_color

	mining_particle.draw_pass_1 = draw_pass

	var process_material = mining_particle.process_material.duplicate()
	process_material.direction = damager.block_hit_detection.get_collision_normal() if "block_hit_detection" in damager else Vector3.ONE
	if process_material.direction.y == 0:
		process_material.direction.y = 1
	mining_particle.process_material = process_material
	mining_particle.global_position = damager.block_hit_detection.get_collision_point() if "block_hit_detection" in damager else block_position
	await get_tree().create_timer(1.5).timeout
	mining_particle.queue_free()
