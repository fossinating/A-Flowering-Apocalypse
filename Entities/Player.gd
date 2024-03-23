extends VoxelCharacterBody3D

const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.002  # radians/pixel
const MAX_VELOCITY = 7.0
const ACCEL = 15.0

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

func _ready():
	coyote_timer = Timer.new()
	coyote_timer.set_wait_time(.15)
	coyote_timer.one_shot = true
	add_child(coyote_timer)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -1.5, 1.5)


func _process(delta):
	pass


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || not coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
 
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	
	# friction 
	var factor = AIR_FACTOR
	if is_on_floor():
		factor = GROUND_FACTOR
	
	
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
	
	var tool = $"../VoxelTerrain".get_voxel_tool()
	
	var facing_raycast_result = tool.raycast($Camera3D.global_transform.origin, -$Camera3D.global_transform.basis.z, 5)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
