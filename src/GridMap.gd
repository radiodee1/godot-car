extends GridMap


var noise := FastNoiseLite.new()
#var noise.NoiseType := FastNoiseLite.TYPE_SIMPLEX 
var rng = RandomNumberGenerator.new()

var limit_pos = 30
var limit_neg = 0
var limit_step = 1
var group_size = 5

var highest = Vector3(0,0,0)
var scale_local = 0.5

signal set_highest(high_vector:Vector3)

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	
	noise.seed = rng.randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH 
	#set_cell_item(Vector3i(0,0,0), 0)
	for x in range(limit_neg, limit_pos, limit_step):
		for y in range(limit_neg, limit_pos, limit_step):
			for z in range(limit_neg, limit_pos, limit_step):
				var j = noise.get_noise_2d(x - limit_pos / 2 ,z - limit_pos / 2) * 15  #+ 15 / 2
				if y - limit_pos / 2 < j  :
					var i = Vector3(x,y,z)
					#set_cell_item(i, 0)
					set_cell_group(x,y,z, 2)
					if z == 0:
						pass
						#print(i,", ", y,", ", j )
	#print("done.")
	#print(highest)
	highest.y +=  scale_local * 2.5
	#highest.x += scale_local
	#highest.z += scale_local
	#highest = Vector3(highest.x * 2 * scale_local, highest.y * 2 * scale_local, highest.z * 2 * scale_local)
	#print(highest, " terrain")
	place_highest(highest)
	
	#highest = Vector3(highest.z, highest.y, highest.x)
	set_highest.emit(highest)
	print(get_tree().get_nodes_in_group('mob'))
	
func set_cell_group(x, y, z, index):
	for xx in range(x * group_size, x * group_size + group_size ):
		for zz in range(z * group_size, z * group_size + group_size):
			var i = Vector3(xx, y, zz)
			set_cell_item(i, index)
			if highest.y < i.y:
				highest = Vector3(x * group_size + group_size / 2, i.y ,z * group_size + group_size / 2) 
			

func place_highest(v):
	var mesh_instance_3d = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	#print(v, " vector")
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5,0.5,0.5)
	box_mesh.size = Vector3(0.5,0.5,0.5)
	mesh_instance_3d.mesh = box_mesh
	mesh_instance_3d.add_to_group('mob')
	mesh_instance_3d.scale_object_local(Vector3(scale_local,scale_local,scale_local))
	add_child(mesh_instance_3d)
	mesh_instance_3d.translate(v) 
	var static_body = StaticBody3D.new()
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


func _on_character_body_3d_hole_to_maze():
	make_hole_to_maze()
	pass # Replace with function body.

func make_hole_to_maze():
	var UPPER = 2
	var LOWER = 1
	for i in range( - (highest.y * group_size + group_size),  (highest.y ) * group_size + group_size):
		var type = get_cell_item(Vector3i(highest.x , i ,highest.z))
		#print(i, " i")
		if type == UPPER:
			set_cell_group(highest.x / group_size -1/2 ,i, highest.z / group_size -1/2 , -1 )
			#print('type ', type)
		#else:
			#print("other ", type)
