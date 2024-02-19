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

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var direction = Vector3()
var movement = Vector3()


@export var test_alone = false 

@onready var player_walk =   $"/root/CentralControl/procedural-terrain/CharacterBody3D/body"

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D" 
@onready var gate_mesh = $"./CollisionShape3D"

var MODE_LOCKED = 0 
var MODE_MOVABLE = 1 
var MODE_UN_MOVABLE = 2 
var MODE_OPEN = 3 

var gate_mode = MODE_LOCKED



# Called when the node enters the scene tree for the first time.
func _ready():
	if test_alone:
		Global.player_status = Global.STATUS_PUSH_JAIL
		gate_mode = MODE_MOVABLE
		enter_gate()
		return
	
	pass # Replace with function body.


func init(v: Vector3 , xname='gate', group='mob'):
	#low_scene_instance = load("res://src/altar_moving.tscn").instantiate()
	self.name = xname
	var low_scene_instance = self 
	low_scene_instance.translate(v)
	low_scene_instance.name = xname
	#var low_box_shape = BoxShape3D.new()
	#low_box_shape.size = Vector3(1,1,1)
	var scale_local = 1 #0.75  
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	low_scene_instance.add_to_group(group)

	#low_static_body.collision_mask = 1
	#low_static_body.collision_layer = 1

func _physics_process(delta):

	if is_on_floor()  :
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	#check_car_jump()

	if Global.player_status == Global.STATUS_PUSH_JAIL :		
		velocity = velocity.lerp(direction * speed, accel * delta)
		velocity = velocity + gravity_vec
		#print('gate ', velocity, ' ', direction)
	else :
		velocity =  Vector3.ZERO

	
		#floor_snap_length = Vector3(float(movement), float(snap), float(0))
	if snap.y >= 0 :
		floor_snap_length = snap.y
		
	else:
		floor_snap_length = 0
		
	
	move_and_slide()

func _process(delta):
	if test_alone:
		Global.player_status = Global.STATUS_PUSH_JAIL
		return
	
	if Global.player_status == Global.STATUS_PUSH_JAIL :
		h_input = - float(player_script.h_input)
		f_input = - float(player_script.f_input)
		jump_pressed = bool(player_script.jump_pressed)
		
	else:
		h_input = 0.0
		f_input = 0.0
		jump_pressed = false
		#engine_force = 0
		
	if position.y < -10:
		print("gate endless fall >>>", position.y)
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
		
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		#head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		#head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))
	
	var start = 0 
	print('gate 0 ', direction)
	var old = global_transform.basis.get_euler().y 
	print('gate 1 ', rad_to_deg(old) + start)
	old = closest_direction_degrees(rad_to_deg(old) + start)
	print('gate 2 ', old)
	old = deg_to_rad(old - start)
	print('gate 3 ', old)
	#h_rot = old
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	direction.y = old
	print('gate 4 ', direction)

func closest_direction_degrees(deg):
	var test = [ 0, 90, 180, 270, 360 ]
	deg = int(deg) % 360 
	#print(deg, ' gate closest' ) 
	var bottom = 360
	var d = 360 
	for i in test:
		var diff = abs(i - deg)
		#print(i, ' ', diff, ' gate progress' )
		if diff <= d:
			bottom = i
			d = diff 
			#print(i, ' gate low')
	if bottom == 360:
		bottom = 0 
	return bottom



func enter_gate():
	
	if not test_alone:
		player_walk.visible = false
		gate_mesh.disabled = false
	
	## enable chase camera
	#camera_chase.current = true
	#camera_walk.current = false
	Global.player_status = Global.STATUS_PUSH_JAIL
	
func leave_gate():
	gate_mesh.disabled = false
	
	if Global.player_status == Global.STATUS_PUSH_JAIL and not test_alone: # and not jump_pressed:
		player_walk.position = Vector3(position)
		#if player_script.position.y < -400:
		player_script.position = Vector3(position)
		#print('position jump')
		#player_walk.position.y += 10
	
	
	#camera_chase.current = false
	#camera_walk.current = true
	
	#player_walk.disabled = false
	if not test_alone:
		player_walk.visible = true

	Global.player_status = Global.STATUS_WALKING	
	
	pass 


func dispose():
	self.leave_gate()
	
	
	player_script.end_game()

	if Global.count_list_items(Global.placed_items, 'gate') > 0:
		Global.placed_items.erase('gate')
		print("erase gate")

	#get_parent().remove_named_child('car')

	queue_free()
	print("gate dequeue")
