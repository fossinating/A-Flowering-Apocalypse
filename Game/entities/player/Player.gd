extends VoxelCharacterBody3D
class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var JUMP_VELOCITY = gravity * .4
const mouse_sensitivity = 0.002  # radians/pixel
const MAX_WALK_SPEED = 4.0
const SPRINT_MULT := 1.7
const ACCEL = MAX_WALK_SPEED / 0.2

@export var camera: Camera3D
@export var mesh: MeshInstance3D
@export var block_indicator: BlockIndicator
@export var scent_emitter: ScentEmitter
@export var hit_detection: RayCast3D
@export var block_hit_detection: RayCast3D
@export var arm_animator: AnimationPlayer
@export var death_screen: Control
@export var hotbar_controller: Node
var ui_open = false
var dead = false

const swim_blocks = [4,5]

# physics material factors
const AIR_FACTOR = 1.5
const GROUND_FACTOR = 1



var attack_cooldown = null
var interact_cooldown = null

func _ready():
	super()
	attack_cooldown = Timer.new()
	attack_cooldown.set_wait_time(.3)
	attack_cooldown.one_shot = true
	add_child(attack_cooldown)
	interact_cooldown = Timer.new()
	interact_cooldown.set_wait_time(.15)
	interact_cooldown.one_shot = true
	add_child(interact_cooldown)
	
	if FileAccess.file_exists("user://saves/" + WorldManager.get_world().save_name + "/player.dat"):
		var save_file = FileAccess.open("user://saves/" + WorldManager.get_world().save_name + "/player.dat", FileAccess.READ)
		var data = save_file.get_var()
		if data == null:
			return
		if "position" in data:
			global_position = data["position"]
		if "mesh_transform" in data: 
			mesh.transform = data["mesh_transform"]
		if "camera_transform" in data:
			camera.transform = data["camera_transform"]
		if "children_data" in data:
			for child_name in data["children_data"]:
				var child = find_child(child_name)
				child.load_data(data["children_data"][child_name])
	Signals.entity_killed.connect(entity_killed)


func entity_killed(_killer: Node, killed: Node):
	if killed == self:
		die()


func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if not dead and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mesh.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)


func _process(delta):
	var tool = $"../VoxelTerrain".get_voxel_tool()
	
	# Highlight the block the player is looking at
	var facing_raycast_result = tool.raycast(camera.global_transform.origin, -camera.global_transform.basis.z, 5, 1)
	
	if not dead:
		block_indicator.show_raycast(tool, facing_raycast_result if not hit_detection.is_colliding() else null)
	if dead:
		death_screen.color.a = lerp(death_screen.color.a, 160.0/255, 0.5*delta)





var was_in_water = false


func _physics_process(delta):
	var tool = $"../VoxelTerrain".get_voxel_tool()
	var is_in_water = _is_in_water(tool)
	if was_in_water != is_in_water:
		was_in_water = is_in_water
		if is_in_water:
			pass# Play water splash
	
	# Highlight the block the player is looking at
	var facing_raycast_result = tool.raycast(camera.global_transform.origin, -camera.global_transform.basis.z, 5, 1)
	
	block_indicator.show_raycast(tool, facing_raycast_result if block_hit_detection.is_colliding() and not hit_detection.is_colliding() else null)

	if not dead and not ui_open:
		if not arm_animator.is_playing():
			# Give option for player to attack the block
			if Input.is_action_pressed("interact") and hotbar_controller.inventory.inventory[hotbar_controller.selected_index] != null and \
						hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item.id == "flower_paste":
				scent_emitter.add_scent(-25)
				hotbar_controller.inventory.inventory[hotbar_controller.selected_index].count -= 1
				if hotbar_controller.inventory.inventory[hotbar_controller.selected_index].count == 0:
					hotbar_controller.inventory.inventory[hotbar_controller.selected_index] = null
				arm_animator.play("swing")
				interact_cooldown.start()
			if not hit_detection.is_colliding() and facing_raycast_result != null and Input.is_action_pressed("attack"):
				var damage = 1
				if hotbar_controller.inventory.inventory[hotbar_controller.selected_index] != null and \
						hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item is ItemRegistry.ToolItemData:
					var block_id = tool.get_voxel(facing_raycast_result.position)
					print(BlockDataRegistry.get_block_data(block_id).harvest_flags, "|", hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item.harvest_flags, "|", BlockDataRegistry.get_block_data(block_id).harvest_flags & hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item.harvest_flags)
					if BlockDataRegistry.get_block_data(block_id).harvest_flags & hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item.harvest_flags:
						damage = hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item.damage
				Signals.block_damaged.emit(facing_raycast_result.position, self, damage)
				arm_animator.play("swing")
				scent_emitter.add_scent(0.1)
			elif Input.is_action_just_pressed("attack"):
				arm_animator.play("swing")
				scent_emitter.add_scent(0.1)
				if hit_detection.is_colliding():
					Signals.entity_attacked.emit(self, hit_detection.get_collider(), 
						1 if (hotbar_controller.inventory.inventory[hotbar_controller.selected_index] == null or \
						not hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item is ItemRegistry.WeaponItemData) else
						hotbar_controller.inventory.inventory[hotbar_controller.selected_index].item.damage)
					attack_cooldown.start()
				else:
					get_node("Whiff Sound").play()
		if interact_cooldown.is_stopped() and block_hit_detection.is_colliding() and not hit_detection.is_colliding() and facing_raycast_result != null and Input.is_action_pressed("interact"):
			Signals.block_interacted.emit(facing_raycast_result, self)
			arm_animator.play("swing")
			interact_cooldown.start()

	
	# Add the gravity.
	if not is_on_floor():
		if is_in_water:
			if velocity.y < -gravity * .15:
				velocity.y = lerp(velocity.y, -gravity*.1, 1*delta)
			else:
				velocity.y = max(velocity.y - (0 if Input.is_action_pressed("jump") else 0.5*gravity*delta), -gravity*.1)
		else:		
			velocity.y -= gravity * delta
	if not dead:
		# Handle Jump.
		if Input.is_action_pressed("jump") and not is_in_water and (is_on_floor()):
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_pressed("jump") and is_in_water:
			velocity.y = clamp(velocity.y + 1.2*JUMP_VELOCITY*delta, -.25*JUMP_VELOCITY, 0.5*JUMP_VELOCITY)
 
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Generate flat_velocity

	var flat_velocity := Vector3(velocity.x, 0, velocity.z)

	if not dead:
		# Generate acceleration_vector from input dir, converted into global coordinates
		var acceleration_vector = mesh.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized() * ACCEL * (SPRINT_MULT if Input.is_action_pressed("sprint") else 1.0)

		# apply the acceleration but reduced if in air
		flat_velocity += acceleration_vector * delta * (0.8 if is_in_water else (1.0 if is_on_floor() else 0.4))

	# Apply friction
	flat_velocity += -flat_velocity.normalized() * min(flat_velocity.length(), delta * MAX_WALK_SPEED * 3) * (1.0 if is_on_floor() else 0.5)

	# Clamp velocity to max_speed
	flat_velocity = flat_velocity.normalized() * min(flat_velocity.length(), MAX_WALK_SPEED * (SPRINT_MULT if Input.is_action_pressed("sprint") else 1.0))

	# Apply velocity

	velocity = Vector3(flat_velocity.x, velocity.y, flat_velocity.z)

	scent_emitter.add_scent(0.0002*pow(flat_velocity.length(), 4.3)*delta)
	if is_in_water:
		scent_emitter.add_scent(-1*delta)
	#print("Scent: ", scent_emitter.scent)

	#print(flat_velocity.length())
	
	if WorldManager.get_world_node() != null and WorldManager.get_world_node().is_position_loaded(global_position):
		move_and_slide()

func save():
	var save_file = FileAccess.open("user://saves/" + WorldManager.get_world().save_name + "/player.dat", FileAccess.WRITE)
	var data = {
		"position": global_position,
		"mesh_transform": mesh.transform,
		"camera_transform": camera.transform,
		"children_data": {}
	}
	for child in get_children():
		if child.has_method("save_data"):
			data["children_data"][child.name] = child.save_data()
	save_file.store_var(data)
	save_file.close()
	
func die():
	dead = true
	death_screen.visible = true

func respawn():
	death_screen.visible = false
	for child in get_children():
		if child.has_method("reset"):
			child.reset()
	dead = false
	position = Vector3(0,128,0)
