extends VehicleBody3D

var steer = 0
var max_torque = 30
var max_rpm = 50
var friction = 0
var accel_const = 250

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_chase = $"arm/chase_camera"
@onready var camera_walk = $"../CharacterBody3D/arm/Camera3D"

@onready var player_walk = $"../CharacterBody3D/body"
@onready var player_script = $"../CharacterBody3D"
@onready var car_mesh = $"CollisionShape3D"
@onready var car_body = $"car_body_mesh"

@onready var wheel_back_left = $"wheel_back_left"
@onready var wheel_back_right = $"wheel_back_right"

func _ready():
	position = Vector3(15 * 5 / 2 - 5, 5 * 5 * 1 , 15 * 5 / 2 - 5 )
	name = "car"
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
	#car_body.collision_layer = 1
	#car_body.collision_mask = 1
	#Global.player_status = Global.STATUS_CAR
	#enter_car()
	Global.player_status = Global.STATUS_WALKING
	leave_car()

func _physics_process(delta):
	if Global.player_status == Global.STATUS_CAR:
		
		player_walk.position = Vector3(position)
		
		var f_input : float = float(Physics.f_input() + 0) / 1.0 #Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input : float = float(Physics.h_input() + 0) / 1.0 #Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
		print( f_input, ' ' , h_input, ' ' , position, ' car')
		#var direction = player_walk.direction 	
		steer = lerp(float(steer), float(h_input * 0.4), 5 * delta)			
		#steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
		steering = steer 
	
		var acceleration = f_input * delta * accel_const
		#print(Input.get_axis("move_backward", "move_forward") , ' axis') 
		print(acceleration, ' acc')
		
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
		print(engine_force, ' force ', friction, ' friction')

func enter_car():
	player_walk.disabled = false ## <-- 
	player_walk.visible = false
	
	car_mesh.disabled = false
	
	## enable chase camera
	camera_chase.current = true
	camera_walk.current = false
	Global.player_status = Global.STATUS_CAR
	
func leave_car():
	car_mesh.disabled = false
	
	camera_chase.current = false
	camera_walk.current = true
	
	player_walk.disabled = false
	player_walk.visible = true
	Global.player_status = Global.STATUS_WALKING	
	
	pass 
