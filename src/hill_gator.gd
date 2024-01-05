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
@onready var gator_pop = $"gator_pop"

#var speed = 1000
var point = Vector3.ZERO
var point_global = Vector3.ZERO
#var path = []
#var path_forward = []
#var path_point = 1
#var anchor = Vector3(0,0,0)

var floating = true
#var can_die = false

var jumping = false
var snap
var jump = 1.5
#var accel = 3
var gravity = 90
var gravity_vec = Vector3.ZERO
var try = 0

var speed = 30
#const ACCEL_DEFAULT = 7
#const ACCEL_AIR = 1
#@onready var accel = ACCEL_DEFAULT
var gravity_mult = 9.8
#var jump = 1.5

func _ready():
	
	#name = "gator"
	#set_name.call_deferred("car")
	add_to_group('mob')
	
	collision_layer = 1
	collision_mask = 1
	
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
func _process(delta):

	pass
	#process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta):
	
	point_global = player_script.global_transform.origin   
	point = to_local(point_global)
	
	if Global.player_status == Global.STATUS_WALKING :
		if floating:
			physics_follow(delta)
		else:
			# put a timer here!!
			physics_jump(delta)
	else :
		physics_follow(delta)
		pass
		
		
func physics_jump(delta):
	keep_together(global_transform.origin )	
	
	gravity_vec = Vector3.UP * gravity * delta
	position += gravity_vec
	floating = true
	
		
func physics_follow(delta):
	keep_together(global_transform.origin )
	
	if is_on_floor() :
		move_walk()
		snap = -get_floor_normal()
		gravity_vec = Vector3.ZERO
	else:
		#move_pop()
		snap = Vector3.DOWN
		gravity_vec = Vector3.DOWN * gravity * delta
		
	if snap.y >= 0 :
		floor_snap_length = snap.y
	else:
		floor_snap_length = 0
	
	gator_walk.look_at(point_global, Vector3.UP, true) 
	gator_pop.look_at(point_global, Vector3.UP, true)
	$"CollisionShape3D".look_at(point_global, Vector3.UP, true)
		
	
	if point.distance_to(global_transform.origin) >= 3.0 :
		#position = point - global_transform.origin / (100 * speed )
		velocity = + point - global_transform.origin  
		#velocity =  - velocity.inverse()  
		velocity = speed  * velocity.normalized()  * delta #* -1 
		velocity = Vector3(  velocity.x, gravity_vec.y,  velocity.z)
	else:
		pass
		#position = point - global_transform.origin
		velocity = + point - global_transform.origin
		#velocity = - velocity.inverse() 
		velocity = velocity * speed * delta #* -1
		velocity = Vector3(  velocity.x, gravity_vec.y,  velocity.z) 
		
	
	#print( 'gator point ', point,' ', delta,  ' ', global_position, ' ', gator_walk.transform.origin, ' ', gravity_vec )
	
	if Global.player_status == Global.STATUS_WALKING :	
		check_collision()
		move_and_slide() 
		#move_and_collide(velocity)
		#print('gator velocity changed ', velocity)

func set_speed(speed_val):
	self.speed = speed_val

func play(name="name"):
	pass
	
func init(v, name='GATOR', group='mob'):
	#transform.origin = v
	#print(gator_walk, ' here')
	var scale_local = 0.5 #1.0
		
	v.y += 2
	var j = load("res://src/gator_walk.tscn").instantiate()
	var k = load("res://src/gator_pop.tscn").instantiate()
	j.name = 'gator_walk'
	k.name = 'gator_pop'
	add_child(j)
	add_child(k)
	
	self.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	
	self.add_to_group(group)
	#self.add_to_group(group)
	self.name = name
	
	self.collision_mask = 1
	self.collision_layer = 1
	move_walk()
	
	animation_walk = $'gator_walk/AnimationPlayer'
	animation_pop = $"gator_pop/AnimationPlayer"
	var collision_shape = $"CollisionShape3D" 
	gator_walk = $"gator_walk"
	gator_pop = $"gator_pop"
		
	animation_walk.play(anim_walk)
	animation_pop.play(action_name)
		
	gator_walk.global_transform.origin = v
	gator_pop.global_transform.origin = v
	global_transform.origin = v
	
	gator_walk.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	gator_pop.scale_object_local(Vector3(scale_local, scale_local, scale_local))
	collision_shape.scale_object_local(Vector3(scale_local, scale_local, scale_local))
	#collision_shape.transform.origin = Vector3(0,1,0)

func move_walk():
	$"gator_pop".visible = false
	$"gator_walk".visible = true
	$"gator_pop/StaticBody3D/CollisionShape3D".disabled = true
	$"gator_walk/StaticBody3D/CollisionShape3D".disabled = false
	pass 
	
func move_pop():
	$"gator_pop".visible = true
	$"gator_walk".visible = false 
	$"gator_pop/StaticBody3D/CollisionShape3D".disabled = false
	$"gator_walk/StaticBody3D/CollisionShape3D".disabled = true
	pass
	
func move(v):
	gator_walk.global_transform.origin = v
	gator_pop.global_transform.origin = v
	global_transform.origin = v
	pass
	
func keep_together(v):
	gator_walk.global_transform.origin = v  
	gator_pop.global_transform.origin = v 
	gator_walk.transform.origin = v
	gator_pop.transform.origin = v
	#$"gator_pop/StaticBody3D".global_transform.origin = v
	#$"gator_walk/StaticBody3D".global_transform.origin = v
	gator_walk.position = v
	gator_pop.position = v 
	$"gator_pop/StaticBody3D/CollisionShape3D".global_transform.origin = v
	$"gator_walk/StaticBody3D/CollisionShape3D".global_transform.origin = v
	$"CollisionShape3D".transform.origin = v  
	
	
func check_collision():
	
	try = 0
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			if try == 0:
				#print('gator collision ', collision.get_collider().name)
				#velocity = Vector3.ZERO
				if collision.get_collider().name.begins_with('GridMap'):
					if is_on_wall():
						floating = false
				try += 1
