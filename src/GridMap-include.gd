extends Resource


var scale_local = 0.5
var add_child: Callable
var set_cell_item: Callable
var get_cell_item: Callable

var mesh_instance_3d
var box_shape
var box_mesh
var static_body

var scene_instance

var low_mesh_instance_3d
var low_box_shape
var low_box_mesh
var low_static_body
var low_collision_shape

var low_scene_instance

var low_location_vec
#var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func place_altar(v, name='pin', group='mob'):
	scene_instance = load("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	v.x *= .5
	v.y *= .5
	v.z *= .5
	add_child.call(scene_instance)
	#scene_instance.scale = Vector3(1,1,1)
	scene_instance.translate(v)
	
	#print(v, " vector")
	box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5,0.5,0.5)
	
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	static_body = StaticBody3D.new()
	static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group(group)
	collision_shape.name = name
	collision_shape.shape = box_shape
	collision_shape.disabled = false
	static_body.add_child(collision_shape)
	static_body.add_to_group(group)
	static_body.name = name
	static_body.set_collision_layer_value(1, true)
	static_body.set_collision_mask_value(1, true)
	scene_instance.add_child(static_body) 
	scene_instance.add_to_group(group)
	scene_instance.name = name

	#static_body.layers = 1
	
	static_body.collision_mask = 1
	static_body.collision_layer = 1

func remove_altar():
	if scene_instance != null:
		scene_instance.queue_free()
		scene_instance = null
		print('altar removed.')
	
	if mesh_instance_3d != null:
		mesh_instance_3d.queue_free()
		box_mesh = null #.free()
		box_shape = null #.free()
		static_body = null
		#collision_shape.queue_free()



func place_low_altar(v, name='pin', group='mob'):
	low_location_vec = v 
	low_scene_instance = load("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	v.x *= .5
	v.y *= .5
	v.z *= .5
	
	add_child.call(low_scene_instance)
	#scene_instance.scale = Vector3(1,1,1)
	low_scene_instance.translate(v)
	
	#print(v, " vector")
	low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(0.5,0.5,0.5)
	
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	low_static_body = StaticBody3D.new()
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

	#static_body.layers = 1
	
	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1
	
	return

func remove_low_altar():
	if low_scene_instance != null:
		low_scene_instance.queue_free()
		low_scene_instance = null
		print('low altar removed.')
		
	if low_mesh_instance_3d != null:
		low_mesh_instance_3d.queue_free()
		low_box_mesh = null #.free()
		low_box_shape = null #.free()
		low_static_body = null
		#collision_shape.queue_free()

func place_altar_key(v: Vector3, description: String):
	#var intersection_index = get_intersection(2, false)
	#var vec = Global.index_to_vector(intersection_index)
	#var vec3 = Vector3(vec.x, v.y, vec.y)
	#vec3.x = 
	#vec3.y = 
	#vec3.z = 	
	var altar_w_key = load("res://src/altar_key_moving.tscn")
	var altar_key = altar_w_key.instantiate()
	altar_key.init(v, 'KEY')
	add_child.call(altar_key)
	print(v, ' vec3 ', Global.intersections)
	pass

func make_hole_to_maze(highest, group_size=5, remove_type=4, print_output=false):
	Global.set_score_allowed(true)
	var UPPER = remove_type
	var LOWER = 1
	var size = group_size
	var xz_size = 5  # 3
	var xz_size_half = xz_size / 2
	var increment = sign(highest.y)
	for i in range( - (highest.y * size + size),  (highest.y ) * size + size, increment):
		for x in range(highest.x - xz_size_half - 1, highest.x + xz_size - xz_size_half):
			for z in range(highest.z - xz_size_half - 1, highest.z + xz_size - xz_size_half):
				pass
				var xx = x 
				var zz = z 
				var type = get_cell_item.call(Vector3(xx , i , zz)) ##<-- Vector3
				if print_output: print(type, ' type')
				if type == UPPER:	
					set_cell_item.call(Vector3(xx, i, zz), -1)
					

func make_hole_to_nextlevel(group_size=5, remove_type=1):
	var ll = low_location_vec
	
	make_hole_to_maze(ll, group_size, remove_type)


func get_intersection(num, exact=true):
	#var intersections = Global.intersections
	print(Global.intersections, ' intersections')
	var out = -1
	var index = -1
	var tot = -1
	for i in Global.intersections:
		#print(i, ' i in intersections')
		if Global.intersections[i] == num and exact:
			out = i #intersections[i]
			Global.intersections[i] = 0
			print(out)
		if Global.intersections[i] <= num and tot != 0 and tot < Global.intersections[i] and not exact:
			tot = Global.intersections[i]
			out = i #intersections[i]
			index = i
			#print(i, ' ' , out, ' ', index, ' ' , intersections)
	Global.intersections[index] = 0
	
	return out 
	



func place_object(name, strategy, layer, frame_num, vector_high=Vector3(0,0,0), vector_low=Vector3(0,0,0)):
	
	if layer == "HILL":
		if name == 'ALTAR':
			var hh = Vector3(vector_high)
			hh.x += 1
			hh.y += scale_local * 2.5
			hh.z += 1
			place_altar(hh)
			#print(hh, " altar here.")
			pass
		if name == 'TRAPDOOR':
			pass
		if name == 'KEY':
			pass
		if name == 'PRISON':
			pass
		if name == 'NEXTLEVEL':
			pass
	if layer == "MAZE":
		if name == 'ALTAR':
			#print(vector_high, ' vector_high')
			place_low_altar(vector_high, "NEXTLEVEL")
			pass
		if name == 'TRAPDOOR':
			pass
		if name == 'KEY':
			#print(name, ' here!!')
			place_altar_key(vector_high, "KEY")
			pass
		if name == 'PRISON':
			pass
		if name == 'NEXTLEVEL':
			pass
	pass


func set_callable(set_add: Callable):
	add_child = set_add

func set_callable_get_cell(set_get: Callable):
	get_cell_item = set_get 

func set_callable_set_cell(set_set: Callable):
	set_cell_item = set_set
