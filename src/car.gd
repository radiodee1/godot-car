extends VehicleBody3D

var steer = 0
var max_torque = 60 #30
var max_rpm = 50
var friction = 0
var accel_const = 250 #0
var test_alone = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var f_input = 0
var h_input = 0
var jump_pressed = false

#@onready var f_input_in =  $"../CharacterBody3D"
#@onready var h_input_in =  $"../CharacterBody3D"
#@onready var jump_pressed_in =  $"../CharacterBody3D"

@onready var camera_chase = $"arm/chase_camera"
@onready var camera_walk = $"../../CharacterBody3D/arm/Camera3D"

#@onready var player_walk = $"../CharacterBody3D/body"
#@onready var player_script = $"../CharacterBody3D"

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D"
@onready var player_walk =   $"/root/CentralControl/procedural-terrain/CharacterBody3D/body"

@onready var car_mesh = $"./CollisionShape3D"
@onready var car_body = $"./car_body_mesh"


@onready var wheel_back_left = $"./wheel_back_left"
@onready var wheel_back_right = $"./wheel_back_right"

func _ready():
	#print('car start')
	name = "car"
	set_name.call_deferred("car")
	add_to_group('mob')
	car_mesh.add_to_group('mob')
	car_body.add_to_group('mob')
	car_mesh.name = 'mesh_' + name
	car_body.name = 'body_' + name
	
	collision_layer = 1
	collision_mask = 1
	#disable_mode = 2
	car_mesh.disabled = false
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	init()

func _physics_process(delta):
	
	#do_process_input(delta)
	if Global.player_status == Global.STATUS_CAR or test_alone:
		
		if not test_alone: # and not jump_pressed:
			player_walk.position = Vector3(position)
			#if player_script.position.y < -400:
			player_script.position.y = float(position.y)

		#print(player_walk.position,' ', player_script.position, ' ',  position, ' player pos')
			
		
		steer = lerp(float(steer), float(h_input * 0.4), 5 * delta)			
		#steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
		steering = steer 
	
		var acceleration = f_input * delta * accel_const
		#print(Input.get_axis("move_backward", "move_forward") , ' axis') 
		#print( f_input, ' ' , h_input, ' ' , jump_pressed, ' ', position , ' car')
		
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
		
		#print(engine_force, ' force ', friction, ' friction ', brake, ' brake')

func _process(delta):
	if Global.player_status == Global.STATUS_CAR :
		h_input = - float(player_script.h_input)
		f_input = - float(player_script.f_input)
		jump_pressed = bool(player_script.jump_pressed)
		
	else:
		h_input = 0.0
		f_input = 0.0
		jump_pressed = false
		engine_force = 0
		
	if position.y < -500:
		print("car endless fall >>>", position.y)
		dispose()

	correct_angle(delta)

func correct_angle(delta):
	if $"arm".transform.origin.y + position.y < position.y  and Global.player_status == Global.STATUS_CAR :
		print("correct angle ", $"arm".transform.origin.y + position.y, ' ', position.y )
		rotate_x(deg_to_rad(180))

func _input(event):
	if not test_alone:
		return
	
	#print('unhandled xx ')
	#print(event.as_text(), ' xx')
	
	
	if event.is_action_pressed("jump"): 
		jump_pressed = true
		#print('jump xx')
		#jump_exit()
	else:
		jump_pressed = false
		
	#h_input = 0
	if event.is_action_pressed("move_forward"): 
		f_input = 1
		#print('forward xx')
			
	elif event.is_action_pressed("move_backward"): 
		f_input = -1
		#print('back xx')
	elif event.is_action_released("move_backward") or event.is_action_released("move_forward"):
		f_input = 0
		
	
	if event.is_action_pressed("move_left"): 
		h_input = 1
		#print('left xx')
			
	elif event.is_action_pressed("move_right"): 
		h_input = -1
		#print('right xx')
	elif event.is_action_released("move_left") or event.is_action_released("move_right"):
		h_input = 0
	

func enter_car():
	
	player_walk.visible = false
	
	car_mesh.disabled = false
	
	## enable chase camera
	camera_chase.current = true
	camera_walk.current = false
	Global.player_status = Global.STATUS_CAR
	
func leave_car():
	car_mesh.disabled = false
	
	if Global.player_status == Global.STATUS_CAR: # and not jump_pressed:
		player_walk.position = Vector3(position)
		#if player_script.position.y < -400:
		player_script.position = Vector3(position)
		#print('position jump')
		#player_walk.position.y += 10
	
	
	camera_chase.current = false
	camera_walk.current = true
	
	#player_walk.disabled = false
	player_walk.visible = true
	Global.player_status = Global.STATUS_WALKING	
	
	pass 


func init():
	#print_tree_pretty()
	if test_alone:
		return
	position = player_script.start_player
	position.x += 5
	position.y += 5 * 5 ## place car above and out of site at start
	position.z += 5
	Global.player_status = Global.STATUS_WALKING
	print(position, ' car position !!!')
	if player_walk != null and camera_walk != null and test_alone == false:
		leave_car()

func dispose():
	self.leave_car()
	
	if Global.count_list_items(Global.placed_items, 'car') > 0:
		Global.placed_items.erase('car')
		print("erase car")
	queue_free()
	print("car dequeue")
