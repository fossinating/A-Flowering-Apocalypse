extends VoxelCharacterBody3D
class_name Player

const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.002  # radians/pixel
const MAX_WALK_SPEED = 3.0
const SPRINT_MULT := 1.5
const ACCEL = MAX_WALK_SPEED / 0.2

@export var camera: Camera3D
@export var mesh: MeshInstance3D
@export var block_indicator: BlockIndicator
@export var scent_emitter: ScentEmitter
@export var hit_detection: RayCast3D

const swim_blocks = [4,5]

# physics material factors
const AIR_FACTOR = 1.5
const GROUND_FACTOR = 1



var attack_timer = null

func _ready():
	attack_timer = Timer.new()
	attack_timer.set_wait_time(.15)
	attack_timer.one_shot = true
	add_child(attack_timer)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mesh.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func _process(delta):
	var tool = $"../VoxelTerrain".get_voxel_tool()
	scent_emitter.add_scent(delta)
	
	# Highlight the block the player is looking at
	var facing_raycast_result = tool.raycast(camera.global_transform.origin, -camera.global_transform.basis.z, 5, 1)
	
	block_indicator.set_block_position(tool, facing_raycast_result.position if facing_raycast_result != null else null)

	if attack_timer.is_stopped():
		if hit_detection.is_colliding() and Input.is_action_just_pressed("attack"):
			Signals.entity_attacked.emit(self, hit_detection.get_collider(), 1)
			attack_timer.start()
		# Give option for player to attack the block
		if not hit_detection.is_colliding() and facing_raycast_result != null and Input.is_action_pressed("attack"):
			Signals.block_damaged.emit(facing_raycast_result.position, self, 1)
			attack_timer.start()



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
	# Handle Jump.
	if Input.is_action_pressed("jump") and not is_in_water and (is_on_floor()):
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("jump") and is_in_water:
		velocity.y = clamp(velocity.y + 1.2*JUMP_VELOCITY*delta, -.25*JUMP_VELOCITY, 0.5*JUMP_VELOCITY)
 
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Generate flat_velocity

	var flat_velocity = Vector3(velocity.x, 0, velocity.z)

	# Generate acceleration_vector from input dir, converted into global coordinates
	var acceleration_vector = mesh.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized() * ACCEL * (SPRINT_MULT if Input.is_action_pressed("sprint") else 1.0)

	# apply the acceleration but reduced if in air
	flat_velocity += acceleration_vector * delta * (0.6 if is_in_water else (1.0 if is_on_floor() else 0.4))

	# Apply friction
	flat_velocity += -flat_velocity.normalized() * min(flat_velocity.length(), delta * MAX_WALK_SPEED * 3) * (2.0 if is_in_water else (1.0 if is_on_floor() else 0.5))

	# Clamp velocity to max_speed
	flat_velocity = flat_velocity.normalized() * min(flat_velocity.length(), MAX_WALK_SPEED * (SPRINT_MULT if Input.is_action_pressed("sprint") else 1.0))

	# Apply velocity

	velocity = Vector3(flat_velocity.x, velocity.y, flat_velocity.z)

	#print(flat_velocity.length())
	
	move_and_slide()
