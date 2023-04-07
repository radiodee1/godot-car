extends GridMap


var noise := FastNoiseLite.new()
#var noise.NoiseType := FastNoiseLite.TYPE_SIMPLEX 

var limit_pos = 15
var limit_neg = - 15
var limit_step = 1
var group_size = 5

var highest = Vector3(0,0,0)

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
	highest.y += 2.0
	highest = Vector3i(highest.x * 0.5, highest.y * 0.5, highest.z * 0.5)
	#print(highest, " terrain")
	place_highest(highest)
	set_highest.emit(highest)
	
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
	mesh_instance_3d.mesh = BoxMesh.new()
	mesh_instance_3d.add_to_group('mob')
	self.add_child(mesh_instance_3d)
	mesh_instance_3d.translate(v) 
	
