extends VoxelCharacterBody3D

@export var jump_ray: RayCast3D
@export var step_container: Node3D
@export var skeleton: Skeleton3D
@export var scent_detector: Area3D
@export var rotator: Node3D
@export var ik_nodes: Array[SkeletonIK3D]
@export var hit_range: Area3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var JUMP_VELOCITY = gravity * .4
const MAX_WALK_SPEED = 4.0
const SPRINT_MULT := 1.7
const ACCEL = MAX_WALK_SPEED / 0.2

var dead = false

var idle_timer = null
var attack_cooldown: Timer

func _ready():
	attack_cooldown = Timer.new()
	attack_cooldown.set_wait_time(.3)
	attack_cooldown.one_shot = true
	add_child(attack_cooldown)
	


	skeleton.physical_bones_start_simulation(["upperarm.L", "lowerarm.L", "hand.L", "upperarm.R", "lowerarm.R", "hand.R"])
	# TODO: Move this to something where the signal manager sends this directly to the impacted entities if it has a SignalListener node (this will be part of a full rework to events rather than signals so that I can handle priority and canceling of events, will probably be done as part of the multiplayer implementation whenever that happens)
	Signals.entity_attacked.connect(entity_attacked)
	Signals.entity_killed.connect(entity_killed)


func entity_attacked(attacker:Node, attacked: Node, _damage: float):
	if attacked == self:
		# knockback
		# I really don't like this method since its kinda reaching in but eh
		var collision_point = global_position
		var attacker_position = attacker.global_position
		if "hit_detection" in attacker:
			collision_point= attacker.hit_detection.get_collision_point()
		velocity = -(attacker_position - collision_point).normalized() * 5
		velocity.y = 3.5
		if "scent_emitter" in attacker:
			attacker.scent_emitter.add_scent(.5)
		# TODO: maybe red tint?



func die():
	skeleton.physical_bones_start_simulation()
	$CollisionShape3D.set_deferred("disabled", true)
	dead = true
	for ik_node in ik_nodes:
		ik_node.stop()


func entity_killed(_attacker:Node, killed: Node):
	if killed == self:
		die()


var was_on_floor = true


func _is_in_water(tool: VoxelTool):
	for direction in [Vector3.UP, Vector3.DOWN]:
		for offset in [Vector3(1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1)]:
			var result = tool.raycast(global_transform.origin + 0.3*offset - 0.95*direction, direction, 1, 2)
			if result != null:
				return true
	return false

# TODO: make it so that when the zombie is in the air for > .5 second, ragdoll legs, then restore legs to below body when touching the ground again

func _physics_process(delta):
	var tool = WorldManager.get_world_node().voxel_terrain.get_voxel_tool()
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
 
	

	# Generate flat_velocity

	var flat_velocity = Vector3(velocity.x, 0, velocity.z)

	if not dead:
		# Apply velocity

		var detected_scent_level := 0
		var greatest_offender = null
		var greatest_observed_scent = -INF

		for scent_emitter in scent_detector.get_overlapping_areas():
			var observed_scent = scent_emitter.scent / scent_emitter.global_position.distance_to(global_position)
			detected_scent_level += observed_scent
			if greatest_observed_scent < detected_scent_level:
				greatest_observed_scent = detected_scent_level
				greatest_offender = scent_emitter.get_parent()
		var sprinting = false


		if detected_scent_level > 0:
			# move towards scent
			var target_vector = -global_position.direction_to(greatest_offender.global_position)
			target_vector.y = 0
			var target_basis = Basis.looking_at(target_vector)
			rotator.basis = target_basis#rotator.basis.slerp(target_basis, 2*delta)

			#print((target_basis.x - rotator.basis.x).length_squared(), " | ",( target_basis.z - rotator.basis.z).length_squared())

			# Make zombie slump a bit
			skeleton.rotation_degrees.x = lerp(skeleton.rotation_degrees.x, 15.0, 0.5*delta)

			# Only move the zombie if it is looking vaguely at target
			if (target_basis.x - rotator.basis.x).length_squared() < .08 and (target_basis.z - rotator.basis.z).length_squared() < .08:
				# Generate acceleration_vector from current facing direction, converted into global coordinates
				var acceleration_vector = rotator.basis * Vector3(0, 0, 1) * ACCEL * (SPRINT_MULT if sprinting else 1.0)
				
				# apply the acceleration but reduced if in air / water
				flat_velocity += acceleration_vector * min(delta * (0.8 if is_in_water else (1.0 if is_on_floor() else 0.4)), max(MAX_WALK_SPEED - flat_velocity.length(), 0))
			
			if attack_cooldown.is_stopped() and greatest_offender in hit_range.get_overlapping_bodies():
				Signals.entity_attacked.emit(self, greatest_offender, 1)
				attack_cooldown.start()
		else:
			# Make zombie slump a lot
			skeleton.rotation_degrees.x = lerp(skeleton.rotation_degrees.x, 30.0, 0.5*delta)
			
		if is_on_floor():
			step_container.position.z = min(flat_velocity.length(), 1)
		if is_on_floor() != was_on_floor:
			if is_on_floor():
				step_container.position.z = 0
				$LeftIKTarget.quick_step()
				$RightIKTarget.quick_step()
			was_on_floor = is_on_floor()

	# Apply friction
	flat_velocity += -flat_velocity.normalized() * min(flat_velocity.length(), delta * MAX_WALK_SPEED * 3) * (1.0 if is_on_floor() else 0.5)

	# Clamp velocity to max_speed
	#flat_velocity = flat_velocity.normalized() * min(flat_velocity.length(), MAX_WALK_SPEED * (SPRINT_MULT if sprinting else 1.0))


	velocity = Vector3(flat_velocity.x, velocity.y, flat_velocity.z)
	
	if WorldManager.get_world_node().is_position_loaded(global_position):
		move_and_slide()
