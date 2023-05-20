extends GridMap

var noise := FastNoiseLite.new()
 
var rng = RandomNumberGenerator.new()

var limit_pos = 30
var limit_neg = 0
var limit_step = 1
var group_size = 5

var limit_origin = Vector3(0,0,0)

var highest = Vector3(0,0,0)
var lowest = Vector3(0,0,0)

var scale_local = 0.5

signal set_highest(high_vector:Vector3)

#var mesh_instance_3d 
#var box_mesh
#var box_shape
#var static_body
#var collision_shape

#var level_frame = 0

@onready var maze = preload("res://src/GridMap-maze.gd").new()
@onready var include = preload("res://src/GridMap-include.gd").new()
@onready var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	maze.set_callable(set_cell_item)
	include.set_callable(add_child)
	include.set_callable_get_cell(get_cell_item)
	include.set_callable_set_cell(set_cell_item)
	#set_hill_size(30,0,0,0,0,0)
	
	#get_node("/root/CentralControl").connect("restart_terrain", _on_central_control_restart_terrain)
	
	hill_generate()
	include.remove_altar()
	
	setup_level_frame() ## <<-- test me!!
	pass
	
func hill_generate(block_num=2):	
	highest = Vector3(0,0,0)
	noise.seed = rng.randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH 
	#set_cell_item(Vector3i(0,0,0), 0)
	for x in range( limit_neg,  limit_pos, limit_step):
		for y in range( limit_neg,  limit_pos, limit_step):
			for z in range( limit_neg, limit_pos, limit_step):
				var j = noise.get_noise_2d(x - limit_pos / 2 ,z - limit_pos / 2) * 15  #+ 15 / 2
				if y - limit_pos / 2 < j  :
					var i = Vector3(x,y,z)
					#set_cell_item(i, 0)
					set_cell_group(x,y,z, block_num, true)
					
	#var hh = Vector3(highest)
	
	highest = change_highest(highest)
	#print(highest, " next")
	#maze.maze_generate(highest)
	
	#print(dict.game)

	
func set_cell_group(x, y, z, index, check_highest=false):
	#if x / group_size * group_size != x : print(x, " group settings")
	var g = limit_origin
	x += g.x
	y += g.y
	z += g.z 
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
	var y: int = high.y # int(high.y) / group_size * group_size
	var z: int = int(high.z) / group_size * group_size
	if x != high.x or z != high.z:
		print(x, ' ', high.x, ' ', z , ' ', high.z)
	var vec = Vector3(x, y, z)
	return vec 



#func _on_character_body_3d_hole_to_maze():
#	hole_to_maze()
#	pass
	
func hole_to_maze():
	#if mesh_instance_3d != null:
	include.place_rubble(highest)
	include.emit_rubble()
	include.remove_altar()
	include.make_hole_to_maze(highest)
	pass # Replace with function body.

#func _on_character_body_3d_hole_to_nextlevel():
#	hole_to_nextlevel()
#	pass
	
func hole_to_nextlevel():
	print('on hole to nextlevel')
	include.remove_low_altar()
	include.make_hole_to_nextlevel(5, 1)
	setup_level_frame()
	pass

		
#func _on_central_control_restart_terrain():
#	restart_terrain()
#	pass
	
func restart_terrain():
	include.remove_altar()
	clear()
	#hill_generate()
	#level_frame = Global.level - 1
	#print('level ', level_frame)
	#Global.level += 1
	setup_level_frame()
	
	Global.print_maze_data()
	pass

func set_hill_size(left, right, depth, x, y, z):
	if left != right or left != depth or right != depth:
		print('maze uses same size for all elements!!')
	limit_origin = Vector3(x,y,z)
	limit_pos = max ( left, right, depth)
	limit_neg = 0

func setup_level_frame():
	Global.clear_list_data()
	Global.clear_maze_data()
	
	include.clear_placed()
	
	var i = Global.level % len(dict.game['level'])
	
	var level = dict.game['level'][i]
	var name = level['name']
	#print(level)
	#print(name)
	var elements = level['elements']
	#print(elements)
	for e in elements:
		#print(e['type'])
		if e['type'] == 'hill':
			include.remove_altar()
			set_hill_size(e['width_x'], e['height_z'], e['depth_y'], e['x'], e['y'], e['z'])
			#if not Global.do_nextlevel_transition:
			hill_generate(e['mesh'])
			#include.place_rubble(highest)
			for ii in e['includes']:
				include.place_object(ii, 'RANDOM', 'HILL', Global.level, highest, lowest)
			pass
		if e['type'] == 'maze':
			include.remove_low_altar()
			maze.shape_list = []
			maze.set_maze_size(e['width_x'], e['height_z'], e['depth_y'], e['x'], e['y'], e['z'], e['endpoints'])			
			#maze.maze_generate(highest)
			
			for ii in e['includes']:
				if ii == 'PRISON' : 
					var prison_num = rng.randi_range(0, len(dict.shapes['mesh']) - 1)
					#print(len(dict.shapes['mesh']), ' len ', prison_num)
					maze.add_shape(prison_num, Vector2(-1,-1), ii) ## <-- this is a prison shape!!
			
			#if not Global.do_nextlevel_transition:
			maze.maze_generate(highest, e['mesh']) ## <-- after shapes
			#else:
			#	Global.do_nextlevel_transition = false
			
			#var size = Vector2(maze.maze_w , maze.maze_h )
			
			
			for ii in e['includes']:
				if ii == 'NEXTLEVEL':
					var map_location = maze.find_map()
					var recorded_index = maze.get_record_index()
					var intersection_index = include.get_intersection(2, false, recorded_index)
					if intersection_index != -1 :
						maze.mark_intersection(intersection_index)
						var altar_mapping = maze.index_to_vector(intersection_index)
						var altar_vec = Vector3(altar_mapping.x , e['depth_y'], altar_mapping.y )
						altar_vec.x = maze.hall_width * altar_vec.x + 2 - map_location.x #+ size.x
						altar_vec.z = maze.hall_width * altar_vec.z + 2 - map_location.y #+ size.y ## -?
						altar_vec.y =  altar_vec.y + 1.5 #+ 4
						#print(map_location, ' map location')
						
						include.place_object(ii, 'RANDOM', 'MAZE', Global.level, altar_vec)
						Global.placed_items.append(ii)
						
				if ii == "KEY":
					var map_location = maze.find_map()
					var recorded_index = maze.get_record_index()
					var intersection_i = include.get_intersection(2, false, recorded_index)
					if intersection_i != -1 :
						maze.mark_intersection(intersection_i)
						var altar_mapping = maze.index_to_vector(intersection_i)
						var altar_vec = Vector3(altar_mapping.x , e['depth_y'], altar_mapping.y )
						altar_vec.x = maze.hall_width * altar_vec.x + 2 - map_location.x #+ size.x
						altar_vec.z = maze.hall_width * altar_vec.z + 2 - map_location.y #+ size.y ## -?
						altar_vec.y =  altar_vec.y + 1.5 #+ 4
						var hashed_name = ii + "-" + str(intersection_i)
						include.place_object(hashed_name, 'RANDOM', 'MAZE', Global.level, altar_vec)
						Global.placed_items.append(hashed_name)
					else:
						print(ii, ' skip here.')
			
			pass
		if e['type'] == 'player':
			print('player handled by central_control!!')
			pass
	maze.show_2d_grid(maze.finished_map, true, 2)
	print('level ', Global.level, ', frame ', i, ' placed ', Global.placed_items)
	#Global.level += 1
	pass


#func _on_character_body_3d_remove_child(name):
#	remove_named_child(name)
#	pass
	
func remove_named_child(name):
	include.dequeue_placed_node(name)
	#var node = get_node( name)
	#print(node, ' node')
	pass # Replace with function body.
