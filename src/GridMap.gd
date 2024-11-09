extends GridMap

var noise := FastNoiseLite.new()
 
var rng = RandomNumberGenerator.new()

var limit_pos = 30  
var limit_neg = 0
var limit_step = 1
var group_size =  9 # 15  # originally 5 !!  

var limit_filter = 5  # group_size, 5 or 3 is ok  

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
var hill_spot_vec2 = [] ## Vector2 !!

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
	include.set_maze_reference(maze)

	#hill_generate()
	include.remove_altar()
	Global.level = 0
	
	setup_level_frame() ## <<-- test me!!
	Global.first_run = 1 

	hud_map_start()
	hud_map_update(0, -1)
	hud_map.set_visibility(false)
	
	#restart_terrain()
	pass
	
func hill_generate(block_num=2):	
	hill_spot = []
	hill_spot_vec2 = []
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
					add_cell_item(i)	
	highest = change_highest(highest)
	hill_remove_extra()

func hill_remove_extra():
	for x in range( limit_neg,  limit_pos, limit_step):
		for y in range( limit_neg,  limit_pos, limit_step):
			for z in range( limit_neg, limit_pos, limit_step):
				var ii = get_cell_item( Vector3(x * group_size + group_size / 2, y, z * group_size + group_size / 2))
				if ii != -1:
					var gg = y - 2 
					for yy in range(gg, -2, -1):
						#set_cell_item(i, 0)
						set_cell_group(x, yy, z, -1 )
						#print('xx culling hill values')
	pass 

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
			#add_cell_item(Vector3(j)) # add to hill spots
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
	#i = Vector3i(i)
	var BELOW = -1
	if i.x > group_size and i.z > group_size or true:
		if i.x < (limit_pos - 1) * group_size and i.z < (limit_pos - 1) * group_size or true :
			#var g_index = Global.hill_vector_to_index(Vector2(i.x, i.z))
			if int(i.x) % limit_filter == 0 and int(i.z) % limit_filter == 0:
				if (i not in hill_spot) and (not is_player_too_close(i)):
					var v2 = Vector2(i.x, i.z)
					if v2 not in hill_spot_vec2 or true: # and Vector3(i.x, i.y + BELOW, i.z) not in hill_spot:
						hill_spot_vec2.append(v2)
					
						hill_spot.append(i)
					var num = 0 
					while Vector3(i.x, i.y + BELOW, i.z) in hill_spot and Vector3(i) in hill_spot and num < 10:
						hill_spot.erase(Vector3(i.x, i.y + BELOW, i.z))
						num += 1 


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
	hud_map.set_visibility(false)	
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
				l.append(xx )
				hill_spot.erase(xx)
		#print(hill_spot.size(), ' end hill spot random ', l.size())
		return l
		pass 
	pass
	
func place_gators(num = 5):
	var l = get_hill_spot_list(HILL_SPOT_RANDOM, num)
	for i in l:
		var j = preload("res://src/hill_gator.tscn")
		var g = j.instantiate()
		var number = Global.hill_vector_to_index(Vector2(i.x, i.z))
		var hash = str(number) + Global.g_hash()
		i.y = i.y * scale_local * scale_local + 1 * scale_local * scale_local
		var k = Vector3(i.x, i.y, i.z)
		
		g.init(k, 'GATOR-'+ hash) # str(number))
		if g == null:
			return
		print(k,' --- ', g)
		
		include.add_to_placed(g, true)
		add_child(g)
		pass
	
func restart_terrain():
	var num = 0 
	#var pre_start = 0 
	var end_num = 200 

	if Global.first_run == 0 or Global.level > 0:
		include.clear_placed()
		Global.clear_list_data()
		Global.clear_maze_data()
	
	while num < end_num + 10 and Global.count_list_items(Global.placed_items, "NEXTLEVEL") < 1:
			
		if Global.first_run == 0 or Global.level > 0:  ## <-- level 0 is set and populated by _ready()
			include.remove_altar()
			clear()
			setup_level_frame()
	
			Global.print_maze_data()
		
		hud_map_start()
		hud_map_update(0, -1)
		hud_map.set_visibility(false)
		
		num += 1
		
		if num >= end_num:
			print("NO RANDOMIZED NEXTLEVEL ITEM")
			get_tree().quit()

	#Global.first_run = 1 

func set_hill_size(left, right, depth, x, y, z):
	if left != right or left != depth or right != depth:
		print('hill uses same size for all elements!!')
	limit_origin = Vector3(x,y,z)
	limit_pos = max ( left, right, depth)
	limit_neg = 0
	Global.hill_h = left
	Global.hill_w = left 
	hill_size = Vector3(left, right, depth)
	Global.maze_center_depth = maze.center_depth

func setup_level_frame():
	var pre_start = 0 
	
	if Global.first_run == 0 or Global.level > 0:
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
			var hill_generated = false
			for ii in e['includes']:
				if ii == 'HILL':
					include.remove_altar()
					set_hill_size(e['width_x'], e['height_z'], e['depth_y'], e['x'], e['y'], e['z'])
					#if not Global.do_nextlevel_transition:
					hill_generate(e['mesh'])
					hill_generated = true
			if not hill_generated:
				Global.test_maze = true
			#include.place_rubble(highest)
			for ii in e['includes']:
				if ii != 'GATORS' and not ii.begins_with("GATE_TEST") and not ii.begins_with("HOUSE"):
					include.place_object(ii, 'RANDOM', 'HILL', Global.level, highest, lowest) # ALTAR, etc.
				elif ii == 'GATORS':
					#print('GATORS')
					place_gators(4)
				elif ii.begins_with("HOUSE"):
					var num_houses = 5
					var l = get_hill_spot_list(HILL_SPOT_RANDOM, num_houses)
					print('-- house ', l.size())
					for v in l:
						v.x *= group_size * 0.5
						v.z *= group_size * 0.5
						include.place_object(ii, 'RANDOM', 'HILL', Global.level, v, Vector3.ONE, Vector3.ZERO)
				if ii.begins_with("GATE_TEST"):
					var v = Vector3(15 * 5 / 2 - 5 , highest.y + 2, 15 * 5 / 2 - 5 )
					#v = v * 0.5 
					include.place_object(ii , 'RANDOM', 'HILL', Global.level, v, Vector3.ONE, Vector3.ZERO )
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
				if ii.begins_with('TESTRAMPS'):
					var shape_num = 0 
					maze.add_shape(shape_num, Vector2(-1,-1), ii) ## <-- this is a testramps shape!!

					pass 
		
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
				if ii == 'RAMPS':
					#var record_index = maze.get_record_index()
					var map_location = maze.find_map()
					var recorded_index = maze.get_record_index()
					#var intersection_i = include.get_intersection(2, false, recorded_index)

					#print(Global.intersections, ' zz intersections vs. record_index ', record_index)
					var end_points = []
					for z in range(len(Global.intersections)):
						var end_point = include.get_intersection(1, true)
						#print('zz single end point ', end_point)
						if end_point != -1 :
							end_points.append(end_point)
					if recorded_index not in end_points:
						end_points.append(recorded_index)
					for zz in end_points:
						#print('zz end_points ', zz)
						var zz_vec = Global.index_to_vector(zz)
						var vec_placement = Vector3.ZERO 
						var zz_hash = 'RAMP-' + str(zz)

						#var altar_mapping = maze.index_to_vector(zz)
						var sub_vec = Vector3(zz_vec.x , maze.center_depth, zz_vec.y )
						vec_placement.x = maze.hall_width * sub_vec.x + 2 - map_location.x 
						vec_placement.z = maze.hall_width * sub_vec.z + 2 - map_location.y 
						vec_placement.y =  sub_vec.y +  4
						include.place_object(zz_hash, "RANDOM", 'MAZE', Global.level, vec_placement, sub_vec)
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
	
	print(hill_spot, " hill spots ", str(hill_spot.size()), " ", hill_spot_vec2)
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


