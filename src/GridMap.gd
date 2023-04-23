extends GridMap

var noise := FastNoiseLite.new()
 
var rng = RandomNumberGenerator.new()

var limit_pos = 30
var limit_neg = 0
var limit_step = 1
var group_size = 5

var highest = Vector3(0,0,0)
var scale_local = 0.5

signal set_highest(high_vector:Vector3)

var mesh_instance_3d 
var box_mesh
var box_shape
var static_body
var collision_shape

@onready var maze = preload("res://src/GridMap-maze.gd").new()
@onready var include = preload("res://src/GridMap-include.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	maze.set_callable(set_cell_item)
	include.set_callable(add_child)
	
	get_node("/root/CentralControl").connect("restart_terrain", _on_central_control_restart_terrain)
	hill_generate()
	include.remove_altar()
	pass
	
func hill_generate():	
	highest = Vector3(0,0,0)
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
					set_cell_group(x,y,z, 2, true)
					
	var hh = Vector3(highest)
	#highest.y += scale_local * 2.5 ## <--
	#highest = Vector3(highest.x + 1, highest.y , highest.z + 1 ) ## <--
	#print(highest, " before")
	hh.x += 1
	hh.y += scale_local * 2.5
	hh.z += 1
	include.place_altar(hh)
	
	highest = change_highest(highest)
		
	#maze.set_callable(set_cell_item)
	
	maze.maze_generate(highest)

	
func set_cell_group(x, y, z, index, check_highest=false):
	#if x / group_size * group_size != x : print(x, " group settings")
	for xx in range(x * group_size, x * group_size + group_size ):
		for zz in range(z * group_size, z * group_size + group_size):
			var i_x = xx 
			var i_z = zz
			#if i_x != xx / group_size * group_size: print(i_x, ' ', xx, ' group settings')
			var i = Vector3(i_x, y, i_z)
			set_cell_item(i, index)
			if check_highest and highest.y < i.y:
				var group_x = x * group_size
				var group_z = z * group_size
				highest = Vector3(group_x, i.y, group_z)
				#highest = Vector3(x,y,z)
				#print(highest, ' print highest')

func change_highest(high):
	var x: int = int(high.x) / group_size * group_size
	var y: int = int(high.y) / group_size * group_size
	var z: int = int(high.z) / group_size * group_size
	if x != high.x or z != high.z:
		print(x, ' ', high.x, ' ', z , ' ', high.z)
	var vec = Vector3(x, y, z)
	return vec 



func _on_character_body_3d_hole_to_maze():
	make_hole_to_maze()
	pass # Replace with function body.

func make_hole_to_maze():
	include.remove_altar()
	#mesh_instance_3d.queue_free()
	var UPPER = 2
	var LOWER = 1
	var size = group_size
	var xz_size = 5  # 3
	var xz_size_half = xz_size / 2
	for i in range( - (highest.y * size + size),  (highest.y ) * size + size):
		for x in range(highest.x - xz_size_half, highest.x + xz_size - xz_size_half):
			for z in range(highest.z - xz_size_half, highest.z + xz_size - xz_size_half):
				pass
				var xx = x #- xz_size / 2
				var zz = z #- xz_size / 2
				#xx = ceil(xx)
				#zz = ceil(zz)
				var type = get_cell_item(Vector3(xx , i , zz)) ##<-- Vector3i
				#print(i, " i")
				if type == UPPER:
					#var some_x = highest.x / group_size - 0.5
					#var some_z = highest.z / group_size - 0.5
					set_cell_item(Vector3(xx, i, zz), -1)
					#set_cell_group(some_x ,i, some_z , -1, false )
					#print('type ', type, ' ', xx, ' ' , zz)
		
func _on_central_control_restart_terrain():
	if mesh_instance_3d != null:
		include.remove_altar()
	clear()
	hill_generate()
	pass
