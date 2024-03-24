extends VoxelCharacterBody3D
class_name Player

const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.002  # radians/pixel
const MAX_VELOCITY = 7.0
const ACCEL = 15.0

@export var camera: Camera3D
@export var mesh: MeshInstance3D
@export var block_indicator: BlockIndicator

const swim_blocks = [4,5]

# physics material factors
const AIR_FACTOR = 1.5
const GROUND_FACTOR = 1


const MAX_CHILL = 100.0
const MAX_FIRE = 150.0
var chill = 0.0
var fire = MAX_FIRE
var chill_rate = 2
var warm_rate = -5
var fire_rate = 20
var coyote_timer = null
var attack_timer = null

func _ready():
	coyote_timer = Timer.new()
	coyote_timer.set_wait_time(.15)
	coyote_timer.one_shot = true
	add_child(coyote_timer)
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


func _process(_delta):
	var tool = $"../VoxelTerrain".get_voxel_tool()
	
	# Highlight the block the player is looking at
	var facing_raycast_result = tool.raycast(camera.global_transform.origin, -camera.global_transform.basis.z, 5, 1)
	
	block_indicator.set_block_position(tool, facing_raycast_result.position if facing_raycast_result != null else null)

	# Give option for player to attack the block
	if facing_raycast_result != null and Input.is_action_pressed("attack") and attack_timer.is_stopped():
		Signals.block_damaged.emit(facing_raycast_result.position, self, 1)
		attack_timer.start()



func _is_in_water(tool: VoxelTool):
	for direction in [Vector3.UP, Vector3.DOWN]:
		for offset in [Vector3(1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1)]:
			var result = tool.raycast(global_transform.origin + 0.475*offset - direction, direction, 2, 2)
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
	if Input.is_action_pressed("jump") and not is_in_water and (is_on_floor()):# || not coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("jump") and is_in_water:
		velocity.y = clamp(velocity.y + 1.2*JUMP_VELOCITY*delta, -.25*JUMP_VELOCITY, 0.5*JUMP_VELOCITY)
 
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	
	# friction 
	var factor = AIR_FACTOR
	if is_on_floor():
		factor = GROUND_FACTOR
	
	
	
	var direction = (mesh.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var accel = Vector3()
	if direction:
		accel.x = direction.x * ACCEL / factor
		accel.z = direction.z * ACCEL / factor
	else:
		if is_on_floor:
			var friction = 3*delta
			velocity.x = lerp(velocity.x, 0.0, friction)
			velocity.z = lerp(velocity.z, 0.0, friction)

	
	velocity += accel*delta
	var h_vel = Vector2(velocity.x, velocity.z)
	
	if h_vel.length_squared() > pow(MAX_VELOCITY*factor, 2.0):
		h_vel = h_vel.normalized() * lerp(h_vel.length(), MAX_VELOCITY*factor, min(0.3/factor, 1.0))
	velocity.x = h_vel.x
	velocity.z = h_vel.y
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
