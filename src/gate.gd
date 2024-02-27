extends CharacterBody3D # Node3D

var f_input = 0
var h_input = 0
var jump_pressed = false

var snap 
var gravity_vec = Vector3()

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity_mult = 9.8
var jump = 1.5
var mouse_sense = 0.1
var extra_mouse_mult_for_snap = 50  

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var xmod = 0 
var zmod = 0

var maze_center_depth = 0 

var direction = Vector3()
var movement = Vector3()
var store = Vector3()
var saved_rotation = Vector3()

@export var test_alone = false 

@onready var player_walk =   $"/root/CentralControl/procedural-terrain/CharacterBody3D/body"

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D" 
@onready var gate_mesh = $"CollisionShape3D"

var MODE_LOCKED = 0 
var MODE_MOVABLE = 1 
var MODE_UN_MOVABLE = 2 
var MODE_OPEN = 3 

var gate_mode = MODE_OPEN

var player_position = Vector3.ZERO
var player_direction = Vector3.ZERO

func _ready():
	if test_alone:
		Global.player_status = Global.STATUS_PUSH_JAIL
		gate_mode = MODE_MOVABLE
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		enter_gate()
		return


func init(v: Vector3 , xname='gate', group='mob'):
	#self.name = xname
	var low_scene_instance = self 
	low_scene_instance.translate(v)
	low_scene_instance.name = xname
	#print('gate init ', position)	
	low_scene_instance.global_transform.origin = v 
	saved_rotation = low_scene_instance.rotation
	maze_center_depth = Global.maze_center_depth 
	return


func _physics_process(delta):


	if is_on_floor()  :
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		direction = Vector3.DOWN
	
	if maze_center_depth != 0 and !test_alone and position.y > maze_center_depth:
		if not is_on_floor():
			position.y -= 0.05 * delta
		pass 

	if gate_mode != MODE_LOCKED : 	
		velocity = velocity.lerp(direction * speed, accel * delta)
		velocity = velocity + gravity_vec
	else :
		velocity =  Vector3.ZERO
	
	if snap.y >= 0 :
		floor_snap_length = snap.y
		
	else:
		floor_snap_length = 0

	move_and_slide()

func _process(delta):
	if test_alone:
		Global.player_status = Global.STATUS_PUSH_JAIL
		return

	if gate_mode != MODE_MOVABLE:
		return

	if Global.player_status == Global.STATUS_PUSH_JAIL  :
		h_input = - float(player_script.h_input)
		f_input = - float(player_script.f_input)
		jump_pressed = bool(player_script.jump_pressed)
		player_position = Vector3(player_script.position)
		player_direction = Vector3(player_script.rotation)
		carry_gate()
		#move_gate()
	else:
		h_input = 0.0
		f_input = 0.0
		jump_pressed = false
		#engine_force = 0
	
	if jump_pressed and Global.player_status == Global.STATUS_PUSH_JAIL:
		leave_gate()

	if position.y < -10:
		print("gate endless fall >>> ", position.y, ' ', position)
		#falling = true
		dispose()

func _input(event):
	if not test_alone:
		return
	#print('unhandled xx ')
	#print(event.as_text(), ' xx')
	var h_rot = global_transform.basis.get_euler().y

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
		
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	#store = Vector3(direction)	

	#get mouse input for camera rotation
	var mouse_input = 0 	
	if event is InputEventMouseMotion:
		mouse_input = (deg_to_rad(-event.relative.x * mouse_sense))
		#rotate_y(mouse_input)
		store.y += mouse_input
	
	direction.y = snap_to_angle_rot( store.y * extra_mouse_mult_for_snap , 0) ## <<-- bad call??
	if direction.y != store.y:
		store = Vector3(direction)
		rotate_y(store.y)


func closest_direction_degrees(deg):
	var test = [ 0, 90, 180, 270, 360 ]
	deg = int(deg) % 360 
	if sign(deg) == -1:
		deg += 360
	var bottom = 360
	var d = 360 
	for i in test:
		var diff = abs(i - deg)
		if diff <= d:
			bottom = i
			d = diff 
	if bottom == 360:
		bottom = 0 
	return bottom

func snap_to_angle_rot(yy, start = 0):
	var old = yy 
	old = rad_to_deg(old) + start 
	var new = closest_direction_degrees(old)
	var n = deg_to_rad(new)
	return n 

func carry_gate():
	direction = player_direction # - rotation

	var dir = rad_to_deg( direction.y )  
	dir = closest_direction_degrees(dir)  
	var dist = 1  
	var d = 0 
	var axis = Vector3(0, 1, 0)
	var rotation_amount = 0 

	if dir == 0 or dir == 360 :
		zmod = - dist
		xmod = 0 
	if dir == 90:
		xmod = - dist 
		zmod = 0 
	if dir == 180:
		zmod = dist
		xmod = 0 
	if dir == 270:
		xmod = dist
		zmod = 0 

	d = dir 	
	
	if d != store.y:
		store = Vector3(rad_to_deg(direction.x), d, rad_to_deg(direction.z))
		var a = int(rad_to_deg(rotation.y)) % 360 

		rotation_amount = deg_to_rad( d - a )  
		
		rotate_object_local(axis, rotation_amount)

	global_transform.origin = Vector3(player_position.x + xmod, player_position.y, player_position.z + zmod)	
	pass 

func enter_gate():
	
	Global.player_status = Global.STATUS_PUSH_JAIL
	gate_mode = MODE_MOVABLE
	
func leave_gate():
	
	if Global.player_status == Global.STATUS_PUSH_JAIL and not test_alone: # and not jump_pressed:
		var diff = 2 *  Vector3(- xmod, 0, - zmod) + position
		player_walk.position = Vector3(diff)
		player_script.position = Vector3(diff)
	
		Global.player_status = Global.STATUS_WALKING	
		gate_mode = MODE_OPEN	
	pass 


func dispose():
	self.leave_gate()
	
	#player_script.end_game()

	if Global.count_list_items(Global.placed_items, self.name) > 0:
		Global.placed_items.erase(self.name)
		print("erase gate ", self.name)

	get_parent().remove_named_child(self.name)

	queue_free()
	print("gate dequeue")
