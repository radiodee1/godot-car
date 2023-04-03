extends GridMap


var noise := FastNoiseLite.new()
#var noise.NoiseType := FastNoiseLite.TYPE_SIMPLEX 

var limit_pos = 15
var limit_neg = - 15
var limit_step = 1
var group_size = 5
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
	
func set_cell_group(x, y, z, index):
	for xx in range(x * group_size, x * group_size + group_size ):
		for zz in range(z * group_size, z * group_size + group_size):
			var i = Vector3i(xx, y, zz)
			set_cell_item(i, index)
			#set_cell_item(i, 1)

