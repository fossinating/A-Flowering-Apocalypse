extends VoxelCharacterBody3D

@export var jump_ray: RayCast3D
@export var step_container: Node3D
@export var skeleton: Skeleton3D
@export var scent_detector: Area3D
@export var rotator: Node3D
const JUMP_VELOCITY = 4.5

var idle_timer = null

func _ready():
	skeleton.physical_bones_start_simulation(["upperarm.L", "lowerarm.L", "hand.L", "upperarm.R", "lowerarm.R", "hand.R"])
	# TODO: Move this to something where the signal manager sends this directly to the impacted entities if it has a SignalListener node (this will be part of a full rework to events rather than signals so that I can handle priority and canceling of events, will probably be done as part of the multiplayer implementation whenever that happens)
	Signals.entity_attacked.connect(entity_attacked)


func entity_attacked(attacker:Node, attacked: Node, _damage: float):
	if attacked == self:
		# knockback
		# I really don't like this method since its kinda reaching in but eh
		var collision_point = global_position
		var attacker_position = attacker.global_position
		if "hit_detection" in attacker:
			collision_point= attacker.hit_detection.get_collision_point()
		velocity = -(attacker_position - collision_point).normalized() * 10
		velocity.y = 5
		# TODO: maybe red tint?



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



func _is_in_water(tool: VoxelTool):
	for direction in [Vector3.UP, Vector3.DOWN]:
		for offset in [Vector3(1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1)]:
			var result = tool.raycast(global_transform.origin + 0.3*offset, direction, 1, 2)
			if result != null:
				return true
	return false


func _physics_process(delta):
	var tool = $"../VoxelTerrain".get_voxel_tool()
	var is_in_water = _is_in_water(tool)

	
	# Add the gravity.
	if not is_on_floor():
		if is_in_water:
			if velocity.y < -gravity * .15:
				velocity.y = lerp(velocity.y, -gravity*.1, 1*delta)
			else:
				velocity.y = max(velocity.y - (0 if Input.is_action_pressed("jump") else 0.5*gravity*delta), -gravity*.1)
		else:		
			velocity.y -= gravity * delta

	if is_on_floor() and jump_ray.is_colliding():
		velocity.y = JUMP_VELOCITY

	var detected_scent_level := 0
	var greatest_offender = null
	var greatest_observed_scent = -INF

	for scent_emitter in scent_detector.get_overlapping_areas():
		var observed_scent = scent_emitter.scent / scent_emitter.global_position.distance_to(global_position)
		detected_scent_level += observed_scent
		if greatest_observed_scent < detected_scent_level:
			greatest_observed_scent = detected_scent_level
			greatest_offender = scent_emitter
	
	#print("Scent Level: ", detected_scent_level)

	if is_on_floor():
		var target_position: Vector3
		var flat_velocity: Vector3
		if detected_scent_level > 0:
			# move towards scent
			var target_vector = -global_position.direction_to(greatest_offender.global_position)
			target_vector.y = 0
			var target_basis = Basis.looking_at(target_vector)
			rotator.basis = rotator.basis.slerp(target_basis, delta)
			flat_velocity = rotator.basis * Vector3(0,0,1)
			skeleton.rotation_degrees.x = 15
			
		else:
			# state machine of wandering and standing still lol
			
			flat_velocity = Vector3.ZERO
			
		velocity.x = flat_velocity.x
		velocity.z = flat_velocity.z
		step_container.position.z = flat_velocity.length()
	
	move_and_slide()
