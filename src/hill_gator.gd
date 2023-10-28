extends CharacterBody3D

@onready var animation_walk = $'gator_walk/AnimationPlayer'

var anim_foot = 'footAction'
var anim_foot_001 = 'foot_001Action'
var anim_foot_002 = 'foot_002Action'
var anim_foot_003 = 'foot_003Action'
var anim_walk = 'anim'

var action_name = 'Action'

@onready var animation_pop = $"gator_pop/AnimationPlayer"

@onready var collision_shape = $"CollisionShape3D" 

@onready var gator_walk = $"gator_walk"
@onready var gator_pop = $"gator_pop"

var speed = 100
var point = Vector3(0,0,0)
var path = []
var path_forward = []
var path_point = 1
var anchor = Vector3(0,0,0)

var can_die = false

var try = 0

func _ready():
	animation_walk.play(anim_walk)
	#altar_name = animation_player.get_assigned_animation()
	#print(altar_name, " altar_name")
	animation_pop.play(action_name )
	#print("should play")
	#animation_walk.connect("animation_finished",  self.play)
	#var altar = get_node("altar-copy/altar")	
	process_mode = Node.PROCESS_MODE_ALWAYS	
	#set_red()
	
func _process(delta):
	pass
	#process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta):
	
	if animation_walk == null:
		return
		
	point = Vector3(3,3,3) 
	
	#print(path_point, ' ', len(path_forward),' ', velocity,' ', path_forward[path_point], ' path stuff')
	#print(global_transform.origin)
	
	#print(point.distance_to(transform.origin), ' distance')
	
	if point.distance_to(transform.origin) > 1:# and path_point < len(path_forward):
		velocity = point - transform.origin
		velocity = velocity.normalized() * speed * delta
		#velocity = velocity * speed 
	else:
		velocity = point - transform.origin
		velocity = velocity * speed * delta

	#print(transform.origin.y, ' y here')
	if transform.origin.y < -2:
		velocity.y = 0
	
	check_collision()
	move_and_slide() 
	#check_collision()
	

func set_speed(speed_val):
	self.speed = speed_val

func play(name="name"):
	pass
	#print(name)
	#print(altar_name, ' altar_name')	
	#animation_walk.seek(0, true)
	#animation_walk.play(anim_walk)

func init(v, name='GATOR', group='mob'):
	#transform.origin = v
	print(gator_walk, ' here')
	
	self.add_to_group(group)
	self.name = name
	
	self.collision_mask = 1
	self.collision_layer = 1
	move_walk()
	
	if gator_walk == null or gator_pop == null:
		return
	gator_walk.global_transform.origin = v
	gator_pop.global_transform.origin = v
	global_transform.origin = v
	#print(v, " vector")
	#var low_box_shape = BoxShape3D.new()
	#low_box_shape.size = Vector3(0.5,0.5,0.5)
	var scale_local = 0.25
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
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
	
func check_collision():
	## always reverse on collision!!
	
	var backoff = 0 ## 1 or 0 or -1
	try = 0
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			if try == 0:
				
				#path_forward.reverse()
				#path_point = min(len(path_forward) - path_point + backoff, len(path_forward) - 1)
				#path_point = max( path_point, 0)
				
				try += 1
