extends CharacterBody3D


var altar_name = 'SphereAction'

@onready var animation_player = $"moving-sphere/AnimationPlayer"

var speed = 100
var point = Vector3(0,0,0)
var path = []
var path_forward = []
var path_point = 1
var anchor = Vector3(0,0,0)

var try = 0

func _ready():
	#altar_name = animation_player.get_assigned_animation()
	#print(altar_name, " altar_name")
	animation_player.play(altar_name )
	#print("should play")
	animation_player.connect("animation_finished",  self.play)
	#var altar = get_node("altar-copy/altar")	
	process_mode = Node.PROCESS_MODE_ALWAYS	
	
func _process(delta):
	pass
	#process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta):
	#process_mode = Node.PROCESS_MODE_ALWAYS
	
	if len(path_forward) <= 1:
		return
		
	point = Vector3(path_forward[path_point]) 
	
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
		next_path_point()
	
	#print(transform.origin.y, ' y here')
	if transform.origin.y < -2:
		velocity.y = 0
	
	check_collision()
	move_and_slide() 
	#check_collision()
	

func set_path(path_array):
	if len(path_array) <= 0:
		return
	path = path_array
	path_forward = path_array
	path_point = 1
	try = 0
	anchor = path[0]
	pass

func is_moving_forward():
	if anchor == path_forward[0]:
		return true
	else:
		return false

func next_path_point():
	var point = Vector3(path_forward[path_point])
	
	if point.distance_to(transform.origin) > 0.5:
		return
	path_point += 1
	if len(path_forward) == path_point:
		reverse_path()
		
	
func reverse_path():
	path_forward.reverse()
	path_point = 1
	try = 0
	print("reverse")

func set_speed(speed_val):
	self.speed = speed_val

func play(name="name"):
	#print(name)
	#print(altar_name, ' altar_name')	
	animation_player.seek(0, true)
	animation_player.play(altar_name)

func init(v, name='PATROL', group='mob'):
	#low_location_vec = v 
	#low_scene_instance = load("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	var low_scene_instance = self 
	#v.x *= .5
	#v.y *= .5
	#v.z *= .5
	
	#add_child.call(low_scene_instance)
	#scene_instance.scale = Vector3(1,1,1)
	
	#low_scene_instance.translate(v)
	#transform.origin = v
	global_transform.origin = v
	
	#print(v, " vector")
	var low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(0.5,0.5,0.5)
	var scale_local = 0.5
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	var low_static_body = StaticBody3D.new()
	low_static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group(group)
	collision_shape.name = name
	collision_shape.shape = low_box_shape
	collision_shape.disabled = false
	low_static_body.add_child(collision_shape)
	low_static_body.add_to_group(group)
	low_static_body.name = name
	low_static_body.set_collision_layer_value(1, true)
	low_static_body.set_collision_mask_value(1, true)
	low_scene_instance.add_child(low_static_body) 
	low_scene_instance.add_to_group(group)
	low_scene_instance.name = name
	
	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1

	
func check_collision():
	## always reverse on collision!!
	
	var backoff = 1 ## 1 or 0
	try = 0
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			if try == 0:
				path_forward.reverse()
				path_point = min(len(path_forward) - path_point - 1 - backoff, len(path_forward) - 1)
				path_point = max( path_point, 0)
				print("collision reverse ", len(path_forward))
				try += 1
