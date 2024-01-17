extends CharacterBody3D

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D"
#@onready var car_script = $"/root/CentralControl/procedural-terrain/GridMap/VehicleBody3D"

var anim_foot = 'footAction'
var anim_foot_001 = 'foot_001Action'
var anim_foot_002 = 'foot_002Action'
var anim_foot_003 = 'foot_003Action'
var anim_walk = 'anim'

var action_name = 'Action'


@onready var animation_walk = $'gator_walk/AnimationPlayer'
@onready var animation_pop = $"gator_pop/AnimationPlayer"
#@onready var collision_shape = $"CollisionShape3D" 
@onready var gator_walk = $"gator_walk"
#@onready var gator_pop = $"gator_pop"


var point = Vector3.ZERO
var point_global = Vector3.ZERO


var floating = false
var top = 0 
var jump_height = 3

var jumping = false
var snap
var jump = 1.5
var gravity = 90
var gravity_vec = Vector3.ZERO
var try = 0
var speed = 30
var gravity_mult = 9.8


func _ready():
	top = position.y + jump_height
	
	add_to_group('mob')
	
	collision_layer = 1
	collision_mask = 1
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
func _process(delta):
	pass
	

func _physics_process(delta):
	
	if Global.player_status == Global.STATUS_WALKING:
		point_global = player_script.global_transform.origin   
		point = to_local(point_global)
	
	if position.y < 0:
		return
	
	if not floating:
		physics_follow(delta)
	else:
		# put a timer here!!??
		physics_jump(delta)
		
		
func physics_jump(delta):
	keep_together(global_transform.origin )	
	
	gravity_vec = Vector3.UP # * gravity * delta
	velocity = gravity_vec.normalized() * gravity * delta
	
	if abs(top - position.y) < 1.0:
		floating = false
	else:
		move_and_slide()
		
func physics_follow(delta):
	keep_together(global_transform.origin )
	
	if is_on_floor() :
		move_walk()
		snap = -get_floor_normal()
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		gravity_vec = Vector3.DOWN * gravity * delta
		
	if snap.y >= 0 :
		floor_snap_length = snap.y
	else:
		floor_snap_length = 0
	
	gator_walk.look_at(point_global, Vector3.UP, true) 
	$"CollisionShape3D".look_at(point_global, Vector3.UP, true)
	
	if point.distance_to(global_transform.origin) > 1.0 :
		velocity = + point - global_transform.origin  
		velocity = speed  * velocity.normalized()  * delta  
		velocity = Vector3(  velocity.x, gravity_vec.y,  velocity.z)
		#print('gator ', point) 
	else:
		velocity = + point - global_transform.origin
		velocity = velocity * speed * delta 
		velocity = Vector3(  velocity.x, gravity_vec.y,  velocity.z) 

	if altar_in_zone() :
		velocity *= Vector3(0, 1.0, 0)	
		
	if not altar_gone() :	
		check_collision()
		move_and_slide() 
		

func set_speed(speed_val):
	self.speed = speed_val

func play(name="name"):
	pass

func altar_gone():
	var name = 'ALTAR' 
	var altar_instance = get_parent().get_placed_node(name) #['instance']
	if not altar_instance == null:
		altar_instance = altar_instance['instance']
	else:
		return true
	if not is_instance_valid(altar_instance):
		return true
	if altar_instance != null:
		return false
	else:
		return true
	pass

func altar_in_zone(closeness = 5):
	var name = 'ALTAR' # + Global.g_hash()
	var altar_instance = get_parent().get_placed_node(name)#['instance']
	var altar_point_global = null
	var altar_point = null
	var altar_distance = null
	var altar_in = false
	if altar_instance != null :
		altar_instance = altar_instance['instance']
		if not is_instance_valid(altar_instance):
			return altar_in
		altar_point_global = altar_instance.global_transform.origin
		altar_point = to_local(altar_point_global)
		altar_distance = point.distance_to(altar_point)
		if altar_distance < closeness:
			altar_in = true
	return altar_in
	
	
func init(v, name='GATOR', group='mob'):
	var scale_local = 0.125 # 0.5
	v.y += 2
	var j = load("res://src/gator_walk.tscn").instantiate()
	j.name = 'gator_walk'
	add_child(j)
	
	self.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	
	self.add_to_group(group)
	
	self.name = name
	
	self.collision_mask = 1
	self.collision_layer = 1
	move_walk()
	animation_walk = $'gator_walk/AnimationPlayer'
	var collision_shape = $"CollisionShape3D" 
	gator_walk = $"gator_walk"
		
	animation_walk.play(anim_walk)
	gator_walk.global_transform.origin = v
	global_transform.origin = v
	
	gator_walk.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	collision_shape.scale_object_local(Vector3(scale_local, scale_local, scale_local))
	

func move_walk():
	$"gator_walk".visible = true
	$"gator_walk/StaticBody3D/CollisionShape3D".disabled = false
	pass 
	
	
func move(v):
	gator_walk.global_transform.origin = v
	global_transform.origin = v
	pass
	
func keep_together(v):
	gator_walk.global_transform.origin = v   
	gator_walk.transform.origin = v
	
	gator_walk.position = v
	$"gator_walk/StaticBody3D/CollisionShape3D".global_transform.origin = v
	$"CollisionShape3D".transform.origin = v  
	
	
func check_collision():
	
	try = 0
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			if try == 0:
				if collision.get_collider().name.begins_with('GridMap'):
					if is_on_wall():
						#floating = true
						#top = position.y + jump_height
						jump_gator()
						try += 1
				if collision.get_collider().name.begins_with('CharacterBody3D'):
					## first collision with player ???
					#floating = false
					#top = 0
					jump_gator()
					try += 1

func jump_gator():
	floating = true
	top = position.y + jump_height
