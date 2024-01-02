extends CharacterBody3D

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D"

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
var point = Vector3(0,0,0)
var path = []
var path_forward = []
var path_point = 1
var anchor = Vector3(0,0,0)

var floating = true
var can_die = false

var jumping = false
var snap
var jump = 1.5
#var accel = 3
var gravity = 0
var gravity_vec = Vector3.DOWN * jump
var try = 0

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
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
	
	if animation_walk == null:
		return
		
	point = player_script.global_position  #global_transform.origin
	#point.y = 0.0
	
	if floating : # and transform.origin.y > 0: # and point.y > 0:
		
		if point.distance_to(global_position) > 0.25 :# and path_point < len(path_forward):
			velocity = (point - global_transform.origin) 
			#velocity = velocity.lerp(velocity * speed,  delta)
			#velocity = point - global_position
			velocity = velocity.normalized() * speed * delta  + gravity_vec
			print('gator velocity change ', velocity)
		else:
			velocity = point - global_transform.origin
			velocity = velocity * speed * delta
			pass
			
	elif not jumping and not floating and false:
		jumping = true
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
		floating = true
		pass
			
	else:
		velocity = (point - global_transform.origin) 
		#velocity = velocity.lerp(velocity * speed,  delta)
		#velocity = point - global_position
		velocity = velocity.normalized() * speed * delta 
		#velocity = Vector3(0,0,0)
		print('gator velocity 0')
	
	if is_on_floor() :
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if snap.y >= 0 :
		floor_snap_length = snap.y
		
	else:
		floor_snap_length = 0
	
	print( 'gator point ', point,' ', floating,  ' ', global_position, ' ', velocity )
	
	check_collision()
	move_and_slide() 
	#check_collision()
	#move(transform.origin)	

func set_speed(speed_val):
	self.speed = speed_val

func play(name="name"):
	pass
	

func init(v, name='GATOR', group='mob'):
	#transform.origin = v
	print(gator_walk, ' here')
	var scale_local = 0.5 #1.0
		
	var j = load("res://src/gator_walk.tscn").instantiate()
	var k = load("res://src/gator_pop.tscn").instantiate()
	j.name = 'gator_walk'
	k.name = 'gator_pop'
	add_child(j)
	add_child(k)
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5,0.5,0.5)
	
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	self.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	#var static_body = StaticBody3D.new()
	#static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.translate(Vector3(0, -1, 0))
	collision_shape.scale_object_local(Vector3(2,2,2))
	collision_shape.add_to_group(group)
	collision_shape.name = name
	collision_shape.shape = box_shape
	collision_shape.disabled = false
	self.add_child(collision_shape)
	#static_body.add_to_group(group)
	#static_body.name = name
	#static_body.set_collision_layer_value(1, true)
	#static_body.set_collision_mask_value(1, true)
	#self.add_child(static_body) 
	self.add_to_group(group)
	#self.add_to_group(group)
	self.name = name
	
	self.collision_mask = 1
	self.collision_layer = 1
	move_walk()
	
	#point = v # transform.origin #v #Vector3(v.x, v.y - 10, v.z)
	
	animation_walk = $'gator_walk/AnimationPlayer'
	animation_pop = $"gator_pop/AnimationPlayer"
	#collision_shape = $"CollisionShape3D" 
	gator_walk = $"gator_walk"
	gator_pop = $"gator_pop"
	
	if gator_walk == null or gator_pop == null:
		print('-----')
		print_tree_pretty()
		pass
		
	animation_walk.play(anim_walk)
	animation_pop.play(action_name)
		
	gator_walk.global_transform.origin = v
	gator_pop.global_transform.origin = v
	global_transform.origin = v
	
	gator_walk.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	gator_pop.scale_object_local(Vector3(scale_local, scale_local, scale_local))
	collision_shape.scale_object_local(Vector3(scale_local, scale_local, scale_local))

func move_walk():
	$"gator_pop".visible = false
	$"gator_walk".visible = true
	pass 
	
func move_pop():
	$"gator_pop".visible = true
	$"gator_walk".visible = false 
	pass
	
func move(v):
	gator_walk.global_transform.origin = v
	gator_pop.global_transform.origin = v
	global_transform.origin = v
	pass
	
func face_guy(delta):
	pass
	
func check_collision():
	## always reverse on collision!!
	
	var backoff = 0 ## 1 or 0 or -1
	try = 0
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			if try == 0:
				print('gator collision ', collision.get_collider().name)
				#path_forward.reverse()
				#path_point = min(len(path_forward) - path_point + backoff, len(path_forward) - 1)
				#path_point = max( path_point, 0)
				floating = false
				try += 1
