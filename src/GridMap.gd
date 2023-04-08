extends GridMap


var noise := FastNoiseLite.new()
#var noise.NoiseType := FastNoiseLite.TYPE_SIMPLEX 

var limit_pos = 15
var limit_neg = - 15
var limit_step = 1
var group_size = 5

var highest = Vector3(0,0,0)
var scale_local = 0.5

signal set_highest(high_vector:Vector3)

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH 
	#set_cell_item(Vector3i(0,0,0), 0)
	for x in range(limit_neg, limit_pos, limit_step):
		for y in range(limit_neg, limit_pos, limit_step):
			for z in range(limit_neg, limit_pos, limit_step):
				var j = noise.get_noise_2d(x  ,z ) * 15  #+ 15 / 2
				if y < j  :
					var i = Vector3i(x,y,z)
					#set_cell_item(i, 0)
					set_cell_group(x,y,z, 2)
					if z == 0:
						pass
						#print(i,", ", y,", ", j )
	#print("done.")
	#print(highest)
	highest.y +=  scale_local * 2
	#highest = Vector3(highest.x * 2 * scale_local, highest.y * 2 * scale_local, highest.z * 2 * scale_local)
	#print(highest, " terrain")
	place_highest(highest)
	set_highest.emit(highest)
	print(get_tree().get_nodes_in_group('mob'))
	
func set_cell_group(x, y, z, index):
	for xx in range(x * group_size, x * group_size + group_size ):
		for zz in range(z * group_size, z * group_size + group_size):
			var i = Vector3i(xx, y, zz)
			set_cell_item(i, index)
			if highest.y < i.y:
				highest = i 
			#set_cell_item(i, 1)

func place_highest(v):
	var mesh_instance_3d = MeshInstance3D.new()
	var box_shape = BoxMesh.new()
	#print(v, " vector")
	mesh_instance_3d.mesh = box_shape
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
	
	static_body.add_child(collision_shape)
	static_body.add_to_group('mob')
	static_body.name = 'pin'
	mesh_instance_3d.add_child(static_body) 
	mesh_instance_3d.add_to_group('mob')
	mesh_instance_3d.name = 'pin'
	#mesh_instance_3d.set_layer_mask_value(1,true)
	
