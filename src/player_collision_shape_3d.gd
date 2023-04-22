extends CharacterBody3D

@onready var control_buttons = load("res://src/central_control.tscn")

signal hole_to_maze
#signal pause_from_terrain



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

@onready var control = $/root/CentralControl/Control
@onready var un_pause = $/root/CentralControl/Control/un_pause


func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_collision_mask_value(1,true)
	set_collision_layer_value(1, true)
	self.collision_mask = 1
	self.collision_layer = 1
	position = Vector3(15 * 5 / 2, 5 * 5 , 15 * 5 / 2)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	get_node("/root/CentralControl").connect("restart_player", _on_central_control_restart_player)
	#get_tree().paused = true

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
	
	check_joystick()
	check_escape()
	
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
		#get_tree().change_scene_to_packed(control_buttons)	
		control_show()
		pass
		
	check_collision()
	move_and_slide()
	
	
func check_joystick():
	
	var stick_left = Input.get_action_strength("stick_left")
	var stick_right = Input.get_action_strength("stick_right")
	var stick_up = Input.get_action_strength("stick_up")
	var stick_down = Input.get_action_strength("stick_down")
	#print(stick_down, ' ' , stick_up)
	rotate_y(- (stick_right - stick_left) * deg_to_rad(2))
	head.rotate_x((stick_down - stick_up) * deg_to_rad(1) )
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))
	pass 
	
func check_escape():
	## temporary game stop ##
	var escape = Input.get_action_strength("escape")
	if escape >= .5:
		#add_child(control.instantiate())
		#get_tree().change_scene_to_file("/root/CentralControl/Control")
		control_show()

func control_show():
	control.show()
	get_tree().paused = true
	#print("also here ", get_tree().paused)
	un_pause.show()
	un_pause.visible = true 
	un_pause.disabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	pass
	
func check_collision():
	
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			if collision.get_collider().is_in_group("mob"):
			#var mob = collision.get_collider()
			
				if collision.get_collider().name == 'pin':


					print(collision.get_collider().name)
					
					hole_to_maze.emit()
						#print('emit num ', emit_hole_to_maze)
						#print("player")
						#print('position ', position)
						#print("x,y,z ", position.x / 5, ' ', position.y / 5, ' ', position.z / 5)
			# here
			
func _on_central_control_restart_player():
	position = Vector3(15 * 5 / 2, 5 * 5 , 15 * 5 / 2)
	pass
