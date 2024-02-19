extends CharacterBody3D # Node3D

var f_input = 0
var h_input = 0
var jump_pressed = false

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
