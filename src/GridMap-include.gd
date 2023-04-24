extends Resource

var mesh_instance_3d
var scale_local = 0.5
var add_child: Callable
var set_cell_item: Callable
var get_cell_item: Callable

var box_shape
var box_mesh
var static_body

#var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func place_altar(v):
	mesh_instance_3d = MeshInstance3D.new()
	box_mesh = load("res://assets/altar.obj")
	#print(v, " vector")
	box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5,0.5,0.5)
	#box_mesh.size = Vector3(0.5,0.5,0.5)
	mesh_instance_3d.mesh = box_mesh
	mesh_instance_3d.add_to_group('mob')
	mesh_instance_3d.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	add_child.call(mesh_instance_3d)
	mesh_instance_3d.translate(v) 
	static_body = StaticBody3D.new()
	static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group('mob')
	collision_shape.name = 'pin'
	collision_shape.shape = box_shape
	collision_shape.disabled = false
	static_body.add_child(collision_shape)
	static_body.add_to_group('mob')
	static_body.name = 'pin'
	static_body.set_collision_layer_value(1, true)
	static_body.set_collision_mask_value(1, true)
	mesh_instance_3d.add_child(static_body) 
	mesh_instance_3d.add_to_group('mob')
	mesh_instance_3d.name = 'pin'
	#mesh_instance_3d.add_child(kinematic)
	mesh_instance_3d.layers = 1
	
	static_body.collision_mask = 1
	static_body.collision_layer = 1

func remove_altar():
	if mesh_instance_3d != null:
		mesh_instance_3d.queue_free()
		box_mesh = null #.free()
		box_shape = null #.free()
		static_body = null
		#collision_shape.queue_free()


func make_hole_to_maze(highest, group_size=5, remove_type=2):
	var UPPER = remove_type
	var LOWER = 1
	var size = group_size
	var xz_size = 5  # 3
	var xz_size_half = xz_size / 2
	for i in range( - (highest.y * size + size),  (highest.y ) * size + size):
		for x in range(highest.x - xz_size_half, highest.x + xz_size - xz_size_half):
			for z in range(highest.z - xz_size_half, highest.z + xz_size - xz_size_half):
				pass
				var xx = x 
				var zz = z 
				var type = get_cell_item.call(Vector3(xx , i , zz)) ##<-- Vector3
				if type == UPPER:	
					set_cell_item.call(Vector3(xx, i, zz), -1)
					

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
			pass
		if name == 'TRAPDOOR':
			pass
		if name == 'KEY':
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
