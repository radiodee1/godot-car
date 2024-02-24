extends GridMap

var noise := FastNoiseLite.new()
 
var rng = RandomNumberGenerator.new()

var limit_pos = 30
var limit_neg = 0
var limit_step = 1
var group_size = 5

var limit_filter = group_size #* 3 #int(limit_pos / 2)

var limit_origin = Vector3(0,0,0)

var highest = Vector3(0,0,0)
var lowest = Vector3(0,0,0)

var hill_size = Vector3(0,0,0)

var scale_local = 0.5

signal set_highest(high_vector:Vector3)

var HILL_SPOT_HIGHEST = 1
var HILL_SPOT_CENTER = 2
var HILL_SPOT_LOWEST = 3
var HILL_SPOT_RANDOM = 4

var hill_spot = [] ## Vector3 !!

@onready var maze = preload("res://src/GridMap-maze.gd").new()
@onready var include = preload("res://src/GridMap-include.gd").new()
@onready var dict = preload("res://src/GridMap-dict.gd").new()

@onready var hud_map = $"../map/"

@onready var player_script = $"/root/CentralControl/procedural-terrain/CharacterBody3D"

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	maze.set_callable(set_cell_item)
	maze.set_callable_get_cell(get_cell_item)
	maze.set_callable_place_object(include.place_object) ## <-- GridMap decorations!! 
	maze.set_callable_map_to_local(map_to_local)
	maze.set_callable_to_global(to_global)
	maze.set_callable_local_to_map(local_to_map)

	include.set_callable(add_child)
	include.set_callable_get_cell(get_cell_item)
	include.set_callable_set_cell(set_cell_item)
	include.set_callable_remove_child(remove_child)
	
	#hill_generate()
	include.remove_altar()
	Global.level = 0
	setup_level_frame() ## <<-- test me!!
	pass
	
func hill_generate(block_num=2):	
	hill_spot = []
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
					
	highest = change_highest(highest)
	#print(highest, " next")

func set_cell_group(x, y, z, index, check_highest=false):
	#if x / group_size * group_size != x : print(x, " group settings")
	var j = Vector3(x, y  ,z)
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
			add_cell_item(Vector3(j)) # add to hill spots
			if check_highest and highest.y < i.y:
				var group_x = x * group_size
				var group_z = z * group_size
				highest = Vector3(group_x, i.y, group_z)
				#highest = Vector3(x,y,z)
				#add_cell_item(highest)
				#print(highest, ' print highest')

func change_highest(high):
	var x: int = int(high.x) / group_size * group_size
	var y: int = high.y # int(high.y) / group_size * group_size
	var z: int = int(high.z) / group_size * group_size
	if x != high.x or z != high.z:
		print(x, ' ', high.x, ' ', z , ' ', high.z)
	var vec = Vector3(x, y, z)
	return vec 

func add_cell_item(i):
	## does hill_generation always build up from bottom??
	## will i.y be highest always??
	var BELOW = -1 
	if i.x > group_size and i.z > group_size:
		if i.x < (limit_pos - 1) * group_size and i.z < (limit_pos - 1) * group_size:
			var g_index = Global.hill_vector_to_index(Vector2(i.x, i.z))
			if int(g_index) % limit_filter == 0 and int(i.x) % limit_filter == 0 and int(i.z) % limit_filter == 0:
				#i.y /= group_size
				#i.x /= group_size
				#i.z /= group_size
				if (i not in hill_spot) and (not is_player_too_close(i)):
					hill_spot.append(i)
					if Vector3(i.x, i.y + BELOW, i.z) in hill_spot:
						hill_spot.erase(Vector3(i.x, i.y + BELOW, i.z))
						#print(i.y, ' i.y')


func hole_to_maze():
	#if mesh_instance_3d != null:
	include.place_high_rubble(highest)
	include.emit_rubble()
	include.remove_altar()
	include.make_hole_to_maze(highest, 8)
	hud_map.set_visibility(true)
	

	
func hole_to_nextlevel():
	print('on hole to nextlevel')
	include.place_low_rubble()
	include.emit_rubble()
	
	include.remove_low_altar()
	include.make_hole_to_nextlevel(5,[2, 1])
	
	pass

func is_player_too_close(hillspot, distance=15):
	var p = player_script.get_player_position()
	var q = Vector2(p.x, p.z)
	var h = Vector2(hillspot.x, hillspot.z)
	if h.distance_to(q) > distance:
		return false
	else:
		return true

func get_hill_spot_list(type, num=5):
	var l = []
	if type == HILL_SPOT_CENTER:
		return l
		pass 
	if type == HILL_SPOT_HIGHEST:
		return l
		pass 
	if type == HILL_SPOT_LOWEST:
		return l
		pass
	if type == HILL_SPOT_RANDOM:
		#print('hill spot random ', hill_spot.size())
		for i in range(num):
			var x = randi_range(0, hill_spot.size() - 1)
			if x < hill_spot.size() and x > -1:
				var xx = hill_spot[x]
				l.append(xx)
				hill_spot.erase(xx)
		#print(hill_spot.size(), ' end hill spot random ', l.size())
		return l
		pass 
	pass
	
func place_gators(num = 5):
	var l = get_hill_spot_list(HILL_SPOT_RANDOM, num)
	#var map_location = maze.find_map()	
	
	print('here len of l list ', l.size(), ' >>> ', l)
	for i in l:
		var j = preload("res://src/hill_gator.tscn")
		var g = j.instantiate()
		var number = Global.hill_vector_to_index(Vector2(i.x, i.z))
		var hash = str(number) + Global.g_hash()
		i.y = i.y * scale_local * scale_local + 1 * scale_local * scale_local
		i.x = i.x * 5 / 4
		i.z = i.z * 5 / 4 
		var k = Vector3(i.x, i.y, i.z)
		
		#print('gator-i ', i)
		#i.x -= map_location.x
		#i.z -= map_location.y
		g.init(k, 'GATOR-'+ hash) # str(number))
		if g == null:
			return
		print(k,' --- ', g)
		
		include.add_to_placed(g, true)
		add_child(g)
		pass
	
func restart_terrain():
	var num = 0
	
	include.clear_placed()
	Global.clear_list_data()
	Global.clear_maze_data()
	#print(Global.count_list_items(Global.placed_items, "NEXTLEVEL"), ' NEXTLEVEL')
	while num < 110 and Global.count_list_items(Global.placed_items, "NEXTLEVEL") < 1:
		
		include.remove_altar()
		clear()
		
		setup_level_frame()
		
		Global.print_maze_data()
		
		hud_map_start()
		hud_map_update(0, -1)
		hud_map.set_visibility(false)
		num += 1
		
		if num >= 100:
			print("NO RANDOMIZED NEXTLEVEL ITEM")
			get_tree().quit()

func set_hill_size(left, right, depth, x, y, z):
	if left != right or left != depth or right != depth:
		print('hill uses same size for all elements!!')
	limit_origin = Vector3(x,y,z)
	limit_pos = max ( left, right, depth)
	limit_neg = 0
	Global.hill_h = left
	Global.hill_w = left 
	hill_size = Vector3(left, right, depth)

func setup_level_frame():
	Global.clear_list_data()
	Global.clear_maze_data()
	
	include.clear_placed()
	include.dequeue_placed_node('SPOT', false, true)
	
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
				if ii != 'GATORS' and not ii.begins_with("GATE_TEST"):
					include.place_object(ii, 'RANDOM', 'HILL', Global.level, highest, lowest)
				elif ii == 'GATORS':
					#print('GATORS')
					place_gators(4)
				if ii.begins_with("GATE_TEST"):
					#var lst = get_hill_spot_list(HILL_SPOT_RANDOM, 1)
					var v = Vector3(15 , 5 * 5 * 4 * 2 , 15 )
					#v = v * 0.5 
					print(v, ' gate')
					include.place_object(ii , 'RANDOM', 'HILL', Global.level, v, Vector3.ZERO, Vector3.ZERO)
			pass

		if e['type'] == 'maze':
			var multiplier = float(e['multiplier'])
			var endpoints = float(e['endpoints'])
			if int(multiplier) != -1:
				endpoints = int(Global.level * multiplier + endpoints)
			include.remove_low_altar()
			maze.shape_list = []
			maze.set_maze_size(e['width_x'], e['height_z'], e['depth_y'], e['x'], e['y'], e['z'], endpoints)			
			#maze.maze_generate(highest)
			
			for ii in e['includes']:
				if ii.begins_with('PRISON') : # == 'PRISON' : 
					var prison_num = 0 
					if ii == 'PRISON':
						prison_num = rng.randi_range(0, len(dict.shapes['mesh']) - 1)
					else:
						prison_num = 0  
						var p = ii.to_lower()
						for prison in range(1, len(dict.shapes['mesh']) ):
							var prison_name = dict.shapes['name'][prison]
							if prison_name.begins_with('prison') and prison_name[-1] == p[-1]:
								prison_num = prison 
							pass  
					#print(len(dict.shapes['mesh']), ' len prison ', prison_num)
					maze.add_shape(prison_num, Vector2(-1,-1), ii) ## <-- this is a prison shape!!
			
			#if not Global.do_nextlevel_transition:
			maze.maze_generate(highest, e['mesh']) ## <-- after shapes

			#Global.add_to_items_temp("CAR")
			
			for ii in e['includes']:
				if ii == 'NEXTLEVEL':
					var map_location = maze.find_map()
					var recorded_index = maze.get_record_index()
					var intersection_index = include.get_intersection(2, false, recorded_index)
					#print(maze.group_visited, ' group_visited')
					if intersection_index != -1 and intersection_index in Global.group_visited :
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
					if intersection_i != -1 and intersection_i in Global.group_visited:
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
				if ii == 'PATROL':
					var map_segment = include.get_segment()
					if len(map_segment) > 0:
						#maze.mark_intersection(map_segment[0])
						#maze.mark_intersection(map_segment[1])
						var local_segment = globalize_segment(map_segment)
						
						var name_suffix = str(min(map_segment[0], map_segment[-1])) + "-" + str(max(map_segment[0], map_segment[-1]))
						var hashed_name = ii + "-" + str(name_suffix)
						include.place_object(hashed_name, "RANDOM", "MAZE", Global.level, local_segment)
						Global.placed_items.append(hashed_name)
						if len(map_segment) > 4:
							var num = 0
							#var dot_segment = globalize_segment(map_segment, true)
							for xx in map_segment:
								#print(xx, " xx")
								if num < 2 or num >= len(map_segment) - 2:
									num += 1
									continue
									
								var name_for_hash = "DOT-" + name_suffix + "-" + str(xx)
								#print(name_for_hash)
								var vec3_list = globalize_segment([xx], true)
								include.place_object(name_for_hash, "RANDOM", "MAZE", Global.level, vec3_list[0])
								#print(name_for_hash)
								num += 1
					pass
			
			pass
		if e['type'] == 'player':
			#print('player handled by central_control!!')
			print('player ', int(e['x']), ' ',  int(e['y']), ' ', int(e['z']))			
			player_script.set_player_start(int(e['x']), int(e['y']), int(e['z']))
			player_script.restart_player()
			pass
	#maze.show_2d_grid(maze.finished_map, true, 2, false, false)
	
	print_tree_pretty()
	
	print(hill_spot, " hill spots ", str(hill_spot.size()))
	pass


func globalize_segment(segment, dot=false):
	var out = []
	var map_location = maze.find_map()	
	var num = 0
	for i in segment:
		var j = Global.index_to_vector(i)
		var ii = Vector3(
			j.x * maze.hall_width + 2 - map_location.x, 
			maze.center_depth + 1 , 
			j.y * maze.hall_width + 2 - map_location.y
		) * 0.5
		
		#var jj = map_to_local(ii) 
		#var k = to_global(jj)
		#if not dot or num >= 2 or num < len(segment) - 2: 	
		out.append(ii)
		num += 1
	if dot:
		var name = 'patrol dot '
	else: 
		var name = 'patrol '
	#print(name, out)
	return out

	
func remove_named_child(name, animate=false, erase_global=false):
	return include.dequeue_placed_node(name, animate, erase_global)
	#var node = get_node( name)
	#print(node, ' node')
	pass # Replace with function body.

func place_follow_rubble(follow):
	include.place_high_rubble(follow)
	
func get_placed_node(name):
	return include.get_placed_node(name)
	
func hud_map_start():
	
	hud_map.init(maze.finished_map, 2)
	hud_map.set_visibility(true)
	hud_map.queue_redraw()
	pass

func hud_map_update(deg, pos):
	## negative values use default vals
	hud_map.set_draw_position(pos)
	hud_map.set_draw_rotation(deg)
	
	pass

func hud_map_get_map_loc():
	#return maze.find_map()
	return maze.map_start


