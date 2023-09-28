extends VehicleBody3D

var steer = 0
var max_torque = 30
var max_rpm = 50
var friction = 0
var accel_const = 250 #0
var test_alone = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var f_input = 0
var h_input = 0
var jump_pressed = false

@onready var camera_chase = $"arm/chase_camera"
@onready var camera_walk = $"../CharacterBody3D/arm/Camera3D"

@onready var player_walk = $"../CharacterBody3D/body"
@onready var player_script = $"../CharacterBody3D"

#@onready var player_script = $"../player_collision_shape_3d"
#@onready var player_walk = $"../player_collision_shape_3d/body"

@onready var car_mesh = $"./CollisionShape3D"
@onready var car_body = $"./car_body_mesh"


@onready var wheel_back_left = $"./wheel_back_left"
@onready var wheel_back_right = $"./wheel_back_right"

func _ready():
	
	name = "car"
	set_name.call_deferred("car")
	add_to_group('mob')
	car_mesh.add_to_group('mob')
	car_body.add_to_group('mob')
	car_mesh.name = name
	car_body.name = name
	
	collision_layer = 1
	collision_mask = 1
	#disable_mode = 2
	car_mesh.disabled = false
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
	init()

func _physics_process(delta):
	if Global.player_status == Global.STATUS_CAR or player_walk == null:
		
		if not test_alone:
			player_walk.position = Vector3(position)
			player_walk.position.y += 100
			print(player_walk.position, ' player pos')
		
		steer = lerp(float(steer), float(h_input * 0.4), 5 * delta)			
		#steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
		steering = steer 
	
		var acceleration = f_input * delta * accel_const
		#print(Input.get_axis("move_backward", "move_forward") , ' axis') 
		print( f_input, ' ' , h_input, ' ' , acceleration, ' ', position , ' car')
		
		var rpm1 = (wheel_back_left.get_rpm())
		var rpm2 = (wheel_back_right.get_rpm())
		var rpm = abs((rpm1 + rpm2) / 2.0)
		
		var margin_for_acceleration = 0.1
		var margin_for_rpm = 0.1
		
		if abs(acceleration) < margin_for_acceleration and rpm > margin_for_rpm :
			friction = delta * accel_const * max_torque *  ( rpm1 / abs(rpm1) ) 
		else:
			friction = 0
		engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm ) - friction
		#engine_force = abs(acceleration)
		
		print(engine_force, ' force ', friction, ' friction ', brake, ' brake')

func _input(event):
	print('unhandled xx ')
	print(event.as_text(), ' xx')
	
	if event.is_action_pressed("jump"): # > 0.0: # or Input.is_action_just_pressed("jump"):
		jump_pressed = true
		print('jump xx')
		jump_exit()
	else:
		jump_pressed = false
		
	#h_input = 0
	if event.is_action_pressed("move_forward"): # > 0.0: # or Input.is_action_just_pressed("move_forward"):
		f_input = 1
		print('forward xx')
			
	elif event.is_action_pressed("move_backward"): # > 0.0: # or Input.is_action_just_pressed("move_backward"):
		f_input = -1
		print('back xx')
	elif event.is_action_released("move_backward") or event.is_action_released("move_forward"):
		f_input = 0
		
	
	if event.is_action_pressed("move_left"): # > 0.0: # or Input.is_action_just_pressed("move_left"):
		h_input = 1
		print('left xx')
			
	elif event.is_action_pressed("move_right"): # > 0.0: # or Input.is_action_just_pressed("move_right"):
		h_input = -1
		print('right xx')
	elif event.is_action_released("move_left") or event.is_action_released("move_right"):
		h_input = 0
	

func enter_car():
	#player_script.disabled = true
	player_walk.disabled = false ## <-- should be false
	player_walk.visible = false
	
	#player_script.disabled = true
	
	player_walk.set_process_input(false)
	player_script.set_process_input(false)
	#self.set_process_input(true)
	#self.set_process_input(true)
	set_process_input(true)
	set_process(true)
	
	car_mesh.disabled = false
	
	## enable chase camera
	camera_chase.current = true
	camera_walk.current = false
	Global.player_status = Global.STATUS_CAR
	
func leave_car():
	car_mesh.disabled = false

	#player_script.disabled = false
	
	player_walk.set_process_input(true)
	player_script.set_process_input(true)
	#self.set_process_input(false)
	self.set_process_input(false)
	set_process_input(false)
	set_process(false)
	
	camera_chase.current = false
	camera_walk.current = true
	
	#player_script.disabled = false
	player_walk.disabled = false
	player_walk.visible = true
	Global.player_status = Global.STATUS_WALKING	
	
	pass 

func jump_exit():
	if test_alone:
		return 
	if player_script.is_on_floor():
		## leave car
		Global.player_status = Global.STATUS_WALKING
		player_script.position = Vector3(position)
		player_script.position.x += 3
		player_script.position.y += 2
		leave_car()
		
		player_script.snap = Vector3.ZERO
		player_script.gravity_vec = Vector3.UP * player_script.jump
		pass
	pass

func init():
	if test_alone:
		return
	position = player_script.start_player
	position.x -= 5
	position.z -= 5
	Global.player_status = Global.STATUS_WALKING
	if player_walk != null and camera_walk != null and test_alone == false:
		leave_car()
