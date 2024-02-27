extends VehicleBody3D

var steer = 0
var max_torque = 120 #60
var max_rpm = 90 #60
var friction = 0
var accel_const = 250 #0
var falling = false
@export var test_alone = false

var margin_sideways = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var f_input = 0
var h_input = 0
var jump_pressed = false

var engine_f ## engine_force
var rpm = 0

@onready var camera_chase = $"arm/chase_camera"
@onready var camera_walk = $"../../CharacterBody3D/arm/Camera3D"

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D"
@onready var player_walk =   $"/root/CentralControl/procedural-terrain/CharacterBody3D/body"

@onready var car_mesh = $"./CollisionShape3D"
@onready var car_body = $"./car_body_mesh"

@onready var wheel_back_left = $"./wheel_back_left"
@onready var wheel_back_right = $"./wheel_back_right"
@onready var wheel_front_left = $"./wheel_front_left"
@onready var wheel_front_right = $"./wheel_front_right"

func _ready():
	#print('car start')
	name = "car" + Global.g_hash()
	set_name.call_deferred(name)
	
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
	mass = 160 
	init()

func _physics_process(delta):
	stop_roll()
	#do_process_input(delta)
	if Global.player_status == Global.STATUS_CAR or test_alone:
		
		if not test_alone: # and not jump_pressed:
			player_walk.position = Vector3(position)
			#if player_script.position.y < -400:
			player_script.position.y = float(position.y)

		#print(player_walk.position,' ', player_script.position, ' ',  position, ' player pos')
		wheel_back_left.brake = 0
		wheel_back_right.brake = 0
		wheel_front_left.brake = 0
		wheel_front_right.brake = 0
		
		steer = lerp(float(steer), float(h_input * 0.4), 5 * delta)			
		#steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
		steering = steer 
			
		var rpm1 = (wheel_back_left.get_rpm())
		var rpm2 = (wheel_back_right.get_rpm())
		var rpm3 = (wheel_front_left.get_rpm())
		var rpm4 = (wheel_front_right.get_rpm())
	
		var mult = 2
		if sign(rpm3) != -1 and sign(rpm4) != -1:
			accel_const = 250 * mult 
			max_torque = 120 * mult 
			mass = 160 
		else :
			accel_const = 250
			max_torque = 120 
			mass = 160 * mult
			pass 

		var acceleration = f_input * delta * accel_const
		#print(Input.get_axis("move_backward", "move_forward") , ' axis') 
		#print( f_input, ' ' , h_input, ' ' , jump_pressed, ' ', position , ' car')
		rpm = abs((rpm3 + rpm4) / 2.0)
		#rpm = abs((rpm1 + rpm2) / 2.0)
		#print('rpm ' , rpm1, ' ', rpm2, ' ', rpm3, ' ', rpm4, ' ')
	
		var margin_for_acceleration = 0.1
		var margin_for_rpm = 0.1
		
		if abs(acceleration) < margin_for_acceleration and rpm > margin_for_rpm :
			friction = delta * accel_const * max_torque  * sign(rpm3) 
		else:
			friction = 0
			
		engine_f = acceleration * max_torque * ( 1 - rpm / max_rpm ) - friction
		#wheel_back_left.engine_force = engine_f
		#wheel_back_right.engine_force = engine_f
		wheel_front_left.engine_force = engine_f
		wheel_front_right.engine_force = engine_f
		
		#print(engine_force, ' force ', friction, ' friction ', brake, ' brake')
	if Global.player_status != Global.STATUS_CAR and test_alone == false:
		engine_force = 0
		#all_brake()

func all_brake():
	wheel_back_left.brake = 1000
	wheel_back_right.brake = 1000
	wheel_front_left.brake = 1000
	wheel_front_right.brake = 1000

func stop_roll():
	wheel_back_left.wheel_roll_influence = 0
	wheel_back_right.wheel_roll_influence = 0
	wheel_front_left.wheel_roll_influence = 0
	wheel_front_right.wheel_roll_influence = 0

func is_not_on_ground():
	return not wheel_back_left.is_in_contact() and not wheel_back_right.is_in_contact() and not wheel_front_left.is_in_contact() and not wheel_front_right.is_in_contact()

func _process(delta):
	if test_alone:
		return
	
	if Global.player_status == Global.STATUS_CAR :
		h_input = - float(player_script.h_input)
		f_input = - float(player_script.f_input)
		jump_pressed = bool(player_script.jump_pressed)
		
	else:
		h_input = 0.0
		f_input = 0.0
		jump_pressed = false
		engine_force = 0
		
	if position.y < -10:
		print("car endless fall >>>", position.y)
		falling = true
		dispose()

	if Global.player_status == Global.STATUS_CAR or true:
		correct_angle(delta)
		correct_sideways_angle(delta)

func correct_angle(delta):
	if falling:
		return
	#print("correct angle ", $"arm".global_position.y , ' ', global_position.y )	
	if $"arm".global_position.y  < global_position.y  and Global.player_status == Global.STATUS_CAR :
		#print("correct angle ", $"arm".global_position.y , ' ', global_position.y )
		if not is_not_on_ground() or true:
			engine_force = 0
			print('correct angle')
			#rotate_x(deg_to_rad(150))
			rotate_x(deg_to_rad(180))
			#rotate_z(deg_to_rad(0))
			rotation = Vector3(0, rotation.y, 0)

func correct_sideways_angle(delta):
	if falling:
		return
	if Global.player_status != Global.STATUS_CAR:
		return
	var wheel_right_x = wheel_back_right.global_position.x
	var wheel_right_z = wheel_back_right.global_position.z 
	var wheel_left_x = wheel_back_left.global_position.x
	var wheel_left_z = wheel_back_left.global_position.z
	if abs(wheel_left_x - wheel_right_x) < margin_sideways and abs(wheel_left_z - wheel_right_z) < margin_sideways:
		#print('sideways ', wheel_left_x, ', ', wheel_right_x, ', ' , margin_sideways)
		#position.y += 5
		if not is_not_on_ground() or true:
			engine_force = 0
			#all_brake()
			print("correct sideways angle")
			#rotate_x(deg_to_rad(50))
			#rotate_x(deg_to_rad(0))
			#rotate_z(deg_to_rad(0))
			rotation = Vector3(0, rotation.y, 0)

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


func init(name = 'car'):
	self.name = name
	#print_tree_pretty()
	if test_alone:
		Global.player_status = Global.STATUS_CAR
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
	
	#var new_car: Vector3 = Vector3( 15 * 5 / 2, 5 * 5, 15 * 5 / 2)
	#player_script.set_player_start(new_car.x, new_car.y, new_car.z)
	
	player_script.end_game()

	if Global.count_list_items(Global.placed_items, 'car') > 0:
		Global.placed_items.erase('car')
		print("erase car")

	get_parent().remove_named_child('car')

	queue_free()
	print("car dequeue")
