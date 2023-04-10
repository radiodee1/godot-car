extends CharacterBody3D

@onready var control_buttons = load("res://src/central_control.tscn")

signal hole_to_maze
var emit_hole_to_maze = 0

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity_mult = 9.8
var jump = 1.5

var cam_accel = 40
var mouse_sense = 0.1
var snap

var direction = Vector3()
#var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

@onready var head = $arm
@onready var camera = $arm/Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_collision_mask_value(1,true)
	set_collision_layer_value(1, true)
	self.collision_mask = 1
	self.collision_layer = 1

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		#rotation.x = deg_to_rad(- event.relative.x * mouse_sense)
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	
	camera.top_level = false #camera.set_as_toplevel(false)
	camera.global_transform = head.global_transform
	#global_transform = head.global_transform

func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	#make it move
	velocity = velocity.lerp(direction * speed, accel * delta)
	velocity = velocity + gravity_vec
	
	#floor_snap_length = Vector3(float(movement), float(snap), float(0))
	floor_snap_length = snap.y
	#gravity = gravity_vec * gravity_mult
	if position.y < -2500 :
		print(position.y, " <<< endless fall")
		get_tree().change_scene_to_packed(control_buttons)	
		pass
		
	check_collision()
	move_and_slide()
	
	
	
func check_collision():
	#set_collision_mask_value(1,true)
	#set_collision_layer_value(1, true)
	#self.collision_mask = 1
	#self.collision_layer = 1
	#print(get_slide_collision_count(),' count')
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
		#var candidate = str(collision)
		#print(collision.get_collider().name)
		
		#if collision.get_collider().name != 'GridMap':
		#	print(collision.get_collider().name)
		
		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			#var mob = collision.get_collider()
			
			if collision.get_collider().name == 'pin':

				if emit_hole_to_maze == 0:
					print(collision.get_collider().name)
					emit_hole_to_maze += 1
					hole_to_maze.emit()
					print('emit num ', emit_hole_to_maze)
			# here
			
			
