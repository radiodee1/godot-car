#extends GridMap

extends Resource

var hall_padding = 1
var hall_walkway = 3

# odd number greater than 2
var hall_width = hall_padding + hall_walkway + hall_padding ## 5??

# must include padding around actual vectors
var maze_w = 10 #5
var maze_h = 10

var start_vectors = []
var vectors_len =  + 20
#var start_vectors_index = []
#var group_visited = []
var decorate = []
var mask_list = []

var working_map = []
var finished_map = []

var shape_list = []
#var intersections = {}

var rng = RandomNumberGenerator.new()
var astar = AStar2D.new()
var HALL = 4
var NONE = 0
var USED = -1
var SHAPE = 9
var SPOT = 5 + 2000

var PRINTOUT_SYMBOL = 'X'

var MAZE_BASE = 2000
var MAZE_WALKWAY = 1 + MAZE_BASE
var MAZE_BRICK = 3 + MAZE_BASE
var MAZE_OTHER = 2 + MAZE_BASE

var center_h = 0
var center_w = 0
var center_depth = - 6 


var record_index = 0
var map_start = Vector3(0,0,0)

var h_vector: Vector3 #= Vector3(0,0,0)

var set_cell_item: Callable
var get_cell_item: Callable
var local_to_map: Callable
var map_to_local: Callable
var to_global: Callable
  
var dict = preload("res://src/GridMap-dict.gd").new()


var place_object: Callable

func clear_variables():
	start_vectors = []
	Global.intersections = {}
	#vectors_len =  7 #+ 10
	#start_vectors_index = []
	Global.group_visited = []
	decorate = []
	mask_list = []

	working_map = []
	finished_map = []

	center_h = 0
	center_w = 0
	center_depth = - 6 

	#record_center_a = 0
	#record_center_b = 0
	record_index = 0
	map_start = Vector3(0,0,0)

	h_vector = Vector3(0,0,0)
	astar = AStar2D.new()
	
	pass

	
func maze_generate(hvec=Vector3(0,0,0), block_num=1):
	
	rng.seed = Time.get_ticks_usec()
	
	clear_variables()
	
	h_vector = hvec

	working_map = make_2d_grid(maze_w, maze_h)
	
	finished_map = make_2d_grid(maze_w * hall_width, maze_h * hall_width, MAZE_OTHER)
	
	start_vectors = randomize_vector2d(vectors_len, 2, 2, maze_w , maze_h )
	
	#shapes_to_map()
	
	#print(start_vectors, ' after start')
	add_to_astar(working_map)
	
	prepare_working_map()
	
	#var n = find_map()

	#print('shape early n:', n)
	#make_map_start(n)
	#copy_map_to_scene(n, block_num, true) ## just set map_start

	shapes_to_map() ## after add_to_astar
	
	process_astar_vectors(start_vectors)
	
	hallway_decorate()
	
	#show_2d_grid(finished_map, true)	
	
	print("finished")
	
	#var n = find_map() 
	var n = find_map()
	#print("shape late n:", n)

	copy_map_to_scene(n, block_num)

	shapes_to_map_plus_decorate()

	#show_2d_grid(working_map, true)
	
	pass 

func add_shape(shape_num, place=Vector2(-1,-1), name="PRISON"):
	if shape_num == 0 and name.begins_with( "PRISON"):
		return
	var shape = [shape_num, place, name]	
	shape_list.append(shape)
	print('-- shape_list ', shape_list)


func add_mesh_hallways(hallway_array, block_num):
	var temp = {
		"mesh": block_num,
		"nodes": hallway_array
	}
	decorate.append(temp)
	#print(decorate)

func decorate_helper( place, container):
	for i in range(shape_list.size()):
		if shape_list[i][2].begins_with('TESTRAMP') and container.begins_with('PRISON') and (shape_list[i][2][-1] == container[-1]):

			if len(shape_list[i]) < 4:
				shape_list[i].append(place)
				print("-- shapes ", shape_list[i])
		pass 

func shapes_to_map(move_old_vectors=false):
	for i in range(shape_list.size()):
		var x = shape_list[i]
		if not x[2].begins_with('PRISON'): # and not x[2].begins_with('TESTRAMPS'): 
			continue
		var layout = dict.shapes['layout'][x[0]]
		var mesh = dict.shapes['mesh'][x[0]]
		var start = dict.shapes['start'][x[0]]
		var end = dict.shapes['end'][x[0]]
		#print( x[2], ' -- ' ,layout, ' shape ', mesh, ' ', start, ' ' , end)
		if x[1].x == -1 or x[1].y == -1:
			#print('place randomly')
			#var widths = []
			var width = -1
			for j in layout:
				if j.x > width:
					width = j.x
			var height = -1
			for j in layout:
				if j.y > height:
					height = j.y
			var place = Vector2(-1,-1)
			place.x = rng.randi_range(2 + 2, working_map.size() - 2 - width)
			place.y = rng.randi_range(2 + 2, working_map[0].size() - 2 - height)
			#print(place, ' place')
			shape_list[i].append(place)
			decorate_helper( place, x[2])
			print("-- decorate_helper ", shape_list)

			if place.x + width > working_map.size() or place.y + height > working_map[0].size():
				continue
			var hallway = []
			#var hall_vec = []
			for z in layout:
				var v = Vector2(place.x + z.x, place.y + z.y)
				working_map[v.x][v.y] = USED #  SHAPE
				astar.set_point_disabled(vector_to_index(v))
				hallway.append(vector_to_index(v))
				
			#print(width, ' width ', height, ' height ', hallway, ' ', hallway.size())
			hallway_in_map(hallway)
			hallway_mask_previous(hallway)
			
			## MASK
			var mask = start.size() ## 2 !!
			var mesh_list = []
			var local_hallway = []
			var mesh_num = MAZE_BRICK #3 
			for jj in range(place.x - mask + 1 , place.x + width + mask ):
				for mm in range(place.y - mask + 1 , place.y + height + mask ):
					## decorate
					if jj != 0 and mm != 0:
						if jj != place.x + width + mask and mm != place.y + height + mask:
							mesh_list.append(Vector2(jj , mm  ))
							
					if jj >= 0 and mm >= 0:
						working_map[jj][mm] = USED
						#mesh_list.append(Vector2(jj , mm  ))
						mask_list.append(vector_to_index(Vector2(jj,mm)))
						
						if  astar.has_point(vector_to_index(Vector2(jj,mm))) and not astar.is_point_disabled(vector_to_index(Vector2(jj,mm))) :
							astar.set_point_disabled(vector_to_index(Vector2(jj,mm)))
						local_hallway.append(vector_to_index(Vector2(jj,mm)))
			add_mesh_hallways(mesh_list, mesh_num)
			
			#hallway_in_map(local_hallway) ## <-- not good
			hallway_mask_previous(local_hallway)
			
			
			if start[0].x != -1 or start[0].y != -1:
				for st in start:
					st.x += place.x
					st.y += place.y
					var v = [vector_to_index(st), st ]
					#start_vectors.append(v)
					start_vectors.push_front(v)
					hallway.append(vector_to_index(st))
					working_map[st.x][st.y] = USED
					#astar.set_point_disabled(v[0])
					astar.set_point_disabled(v[0], false)
					#if str(v[0]) not in Global.intersections.keys():
					if not Global.intersections.has(v[0]):
						Global.intersections[str(v[0])] = 1
					#print('shape start ', st)
				
			if end[0].x != -1 or end[0].y != -1:
				for en in end:
					en.x += place.x
					en.y += place.y
					var v = [vector_to_index(en), en ]
					#start_vectors.append(v)
					start_vectors.push_front(v)
					hallway.append(vector_to_index(en))
					working_map[en.x][en.y] = USED
					#astar.set_point_disabled(v[0])
					astar.set_point_disabled(v[0], false)
				
			var temp = []
			for a in range(start_vectors.size() - 1):
				if start_vectors[a] not in temp:
					temp.append(start_vectors[a])
			start_vectors = temp
			
			hallway_in_map(hallway) ## <--
			
			#hallway_mask_previous(hallway)
			#decoration_in_shape(place, dec_offset, dec_scale, dec_rotation, dec_name)
		pass 
		#show_2d_grid_shape(layout, start) ## <-- not include end array


func shapes_to_map_plus_decorate():
	for i in range(shape_list.size()):
		var x = shape_list[i]
		if not x[2].begins_with('PRISON') and not x[2].begins_with("TESTRAMPS"): # != 'PRISON' :
			continue
		if x[2].begins_with('PRISON'):
			var shape_index = x[0]
			var place = shape_list[i][3]

			var dec_offset = dict.shapes['decoration_offset'][shape_index]
			var dec_scale = dict.shapes['decoration_scale'][shape_index]
			var dec_rotation = dict.shapes['decoration_rotation'][shape_index]
			var dec_name = dict.shapes['decoration_name'][shape_index]
			#print(layout, ' shap
			decoration_in_shape(place, dec_offset, dec_scale, dec_rotation, dec_name)

			for ii in range(dict.test.size()):
				#print('-- here ', dict.test[ii]['reference'])
				if ii != 2:
					#continue
					pass
				if dict.test[ii]['reference'] == x[2].to_lower():
					var t_place = shape_list[i][3] #+ place
					var t_offset = dict.test[ii]['position']
					var t_scale = Vector3.ZERO
					var t_rotation = Vector3.ZERO
					var t_name = dict.test[ii]['name'].to_upper() # x[2]
					var t_extra = dict.test[ii]['extra']
					decoration_in_shape(t_place, [t_offset], [t_scale], [t_rotation], [t_name], [t_extra])
					#place_object.call(t_name, 'random', 'MAZE', 0, t_place, t_scale, t_rotation )

					print('-- v ', t_place, ' ', t_name,' ', ii)
				pass 


func decoration_in_shape(place, offset, scale, rotation, name, extra=Vector2.ZERO):
	var a = - index_to_vector(record_index) * hall_width 
	var b =  h_vector 
	if len(offset) != len(scale) or len(scale) != len(rotation):
		print('bad shape dict values!!')
		return
	for i in range(len(offset)):
		var off =   offset[i] + place # * 2 # Vector2(place.y, place.x)
		var gate_place = Vector3( 
			(off.x  ) * hall_width + a.x + b.x ,  
			-3,  
			(off.y  ) * hall_width + a.y + b.z  
		)   
		gate_place.y =  -5
		gate_place = gate_place * 0.5 # + Vector3(0.25, 0.25, 0.25)
		var gate_scale = scale[i]
		var gate_rot = rotation[i]
		var gate_name = name[i].to_upper()
		if not name[i].begins_with('TEST'):
			place_object.call(gate_name, 'random', 'MAZE', 0, gate_place, gate_scale, gate_rot )
		else:
			var vsize = extra[i]
			var aa = - index_to_vector(record_index) # + Vector2.ONE
			var gate_off = Vector3(offset[i].x + place.x , 0, offset[i].y + place.y ) 
			gate_place = Vector3(
				aa.x  * hall_width, #- map_location.x, # + b.x, 
				0, 
				aa.y  * hall_width #- map_location.y #+ b.y 
			) + gate_off  * hall_width
			gate_place += Vector3(2 , 0 , 2 )
			var ramp_off =  Vector2(vsize.x - offset[i].x ,  offset[i].y)
			#var ramp_off = Vector2( offset[i].x,  offset[i].y)
			gate_place.y = 0 #-2 ## temp setting 
			var calc =   ramp_off + place 
			var gate_calc = Vector3(calc.x, 0, calc.y)  
			print('-- v offset', offset[i], ' ', ramp_off )
			place_object.call('TESTRAMPS', 'random', 'MAZE', 0, gate_place, gate_calc, Vector3.ZERO )

	pass 

func hallway_decorate():
	for i in decorate:
		var low_h = maze_h * hall_width
		var low_w = maze_w * hall_width
		var high_h = 0
		var high_w = 0
		var block_num = MAZE_BRICK
		#for i in decorate:
		var hallway = i['nodes']
		print(hallway, ' hallway_decorate')
		var k = Vector2(low_w, low_h)
		var m = Vector2(high_w, high_h)
		for j in hallway:
			if j.y <= low_h :
				low_h = j.y
				k.y = j.y
			if j.x <= low_w :
				low_w = j.x
				k.x = j.x
			if j.y >= high_h:
				high_h = j.y
				m.y = j.y 
			if j.x >= high_w:
				high_w = j.x
				m.x = j.x 
		
		var large_piece = 0.8
		var small_piece = 0.2
		k.x += large_piece
		m.x += small_piece
		k.y += large_piece
		m.y += small_piece
			
		for ww in range(k.x * hall_width, m.x * hall_width):
			
			for hh in range(k.y * hall_width, m.y * hall_width):	
				var v = Vector2(ww,hh)
				#print(v)
				if finished_map[v.x][v.y] == MAZE_OTHER or finished_map[v.x][v.y] == 0:
					assign_map(v.x, v.y, block_num)
					#print(v, ' v ', block_num)
						

func make_2d_grid(width, height, fill_with=0):
	var matrix = []
	for h in range(height):
		matrix.append([])
		for w in range(width):
			matrix[h].append(0)
			pass
	return matrix
	
func show_2d_grid(matrix, advance = false, line_size=3, show_hidden=false, show_mesh=false, depth=35, specialvec=Vector2.ZERO):
	if not advance:
		for h in matrix:
			print(h)
	else:
		var line = "|"
		for h in range(matrix.size()):
			if depth != -1 and h > depth:
				break
			line += "-----".substr(0, line_size)
		line += "|"
		print(line)	
		for h in range(matrix.size()):
			line = "|"
			for j in range(matrix[h].size()):
				if depth != -1 and j > depth:
					break 
				if matrix[h][j] == SPOT or (h == specialvec.x and j == specialvec.y):
					var line_spot = ' X  '.substr(0, line_size)
					#var line_spot = ' ' + PRINTOUT_SYMBOL + ' '
					#var line_spot_mod = line_spot.substr(0, line_size)
					line += line_spot
					continue
				if matrix[h][j] == MAZE_OTHER: # or matrix[h][j] == 0:
					var line_spot = ' H  '.substr(0, line_size)
					line += line_spot
					continue
				if matrix[h][j] == 0 and not show_mesh:
					var three = '     ' # 5 spaces
					line += three.substr(0, line_size) ## 3 spaces
				elif not show_mesh:
					var jj = abs(j / hall_width)
					var hh = abs(h / hall_width)
					var line_temp = " " + str( vector_to_index(Vector2(hh,jj)) ) + "   "
					line += line_temp.substr(0, line_size)
				else :
					#var jj = (j / hall_width)
					#var hh = (h / hall_width)
					var w = matrix[h][j] -  MAZE_BASE
					var vec = Vector3(0,0,0)
					
					var line_temp = str( w ) + "   "
					line += line_temp.substr(0, line_size)
			line += "|"
			print(line)
		line = "|"
		for h in range(matrix.size()):
			if depth != -1 and h > depth:
				break
			line += "-----".substr(0, line_size)
		line += "|"
		print(line)			

func show_2d_grid_shape(nodex, starts=[], ends=[]):
	var nodes = nodex + starts + ends
	var findme = 'shape/node: '
	var padding = str('                    ')
	var highest_x = 0 
	var highest_y = 0 
	var lowest_x = 0 
	var lowest_y = 0 
	for i in nodes:
		if i.x >= highest_x:
			highest_x = i.x + 1 
		if i.y >= highest_y:
			highest_y = i.y + 1 
		pass
	lowest_x = highest_x
	lowest_y = highest_y
	for i in nodes:
		if i.x <= lowest_x:
			lowest_x = i.x - 1 
		if i.y <= lowest_y:
			lowest_y = i.y - 1 
	
	var mat_w = []
	for h in range(lowest_x, highest_x):
		var mat_h = []
		for w in range(lowest_y, highest_y):
			var label =  str(h) + "," + str(w)
			if Vector2(h,w) in nodes:
				label = "*" + label + "*"
			if Vector2(h,w) in starts:
				label = 'S' + label + 'S'
			if Vector2(h,w) in ends:
				label = 'E' + label + 'E'
			mat_h.append(label)
		mat_w.append(mat_h)
	
	#print(findme, mat_w)
	for i in mat_w:
		#print(findme,end = '')
		var line = findme 
		for j in i:
			var value = j + padding 
			value = value.left(10)
			if value.begins_with('*') or value.begins_with('S') or value.begins_with('E'):
				line += value
				#print(value, end = '')
			else:
				line += padding.left( len(value) )
		print(line)
	
	#print(findme + str( nodes))

func prepare_working_map():
	var map = working_map
	var hallway = []
	for i in range(map.size()):
		for j in range(map[i].size()):
			if i == 0:
				map[i][j] = USED
				#hallway.append(Vector2(i,j))
			if i == map.size() - 1:
				map[i][j] = USED
				#hallway.append(Vector2(i,j))
			if j == 0:
				map[i][j] = USED
				
			if j == map[i].size() - 1:
				map[i][j] = USED
				
			if map[i][j]  == USED or map[i][j] == SHAPE:
				if  astar.has_point(vector_to_index(Vector2(i,j))) and not astar.is_point_disabled(vector_to_index(Vector2(i,j))) :
					astar.set_point_disabled(vector_to_index(Vector2(i,j)))
				pass
			
	


func randomize_vector2d(length_of_array, left_padding, top_padding, width_of_map, height_of_map):
	var v = []
	
	var interval = max( abs((width_of_map - left_padding * 2 ) / length_of_array), 1 )
	var available = []
	for i in range(top_padding  , height_of_map - top_padding ):
		available.append(i)
	
	var l = min(length_of_array, available.size())
	print(available, ' available')
	for i in range(l):
		#print(available)
		#print(length_of_array," ", width_of_map, " length, width")
		var num = 0
		var ii = i * interval
		var j = rng.randi_range(0, available.size() - 1 )
		
		var k = int( available[j] ) 
		var x = Vector2(k, ii + left_padding) ## 
		v.append([ vector_to_index(x) ,x]) ## 
		available.remove_at(j)
	#print(v, ' avail out')
	return v

func add_to_astar(grid, print_rows = false, w_limit=1, h_limit=1):
	var num = 0
	for i in range(w_limit, grid.size() - w_limit):
		var line = []
		for j in range(h_limit, grid[i].size() - h_limit):
			var v = Vector2(i, j)
			#var z = vector_to_index(v)
			#if z in mask_list:
			#	print(' z ', z)
			#	continue
			astar.add_point(vector_to_index(v), v)
			if i > 0 + w_limit:
				var v_prev = Vector2(i - 1, j)
				astar.connect_points(vector_to_index(v), vector_to_index(v_prev), true)
				pass
			if j > 0 + h_limit:
				var v_prev = Vector2(i, j-1)
				astar.connect_points(vector_to_index(v), vector_to_index(v_prev), true)
				pass
			if print_rows:
				line.append([ vector_to_index(v) , v])
			num += 1
		if print_rows:
			print(line, ' add_to_astar')

		
func vector_to_index(v):
	return int(v.x * maze_w + v.y)  

func index_to_vector(i):
	var v = Vector2( int(i / maze_w), i - int(i / maze_w) * maze_w)
	return v

func process_astar_vectors(v):
	Global.clear_maze_data()
	
	var vv = []
	for g in range(v.size()):
		var f = vector_to_index(v[g][1])
		vv.append(f)
		pass
	
	var z = []
	for a in range(vv.size()):
		for b in range(a, vv.size()):
			if a != b and vv[a] != vv[b]:
				z.append([ vv[a], vv[b] ])
				#z.append([ v[b], v[a] ])
	#z.reverse()
	#print(z)
	
	#Global.group_visited.append(z[0][0])
	for p in z:
		if p[0] < 0 or p[1] < 0:
			#continue
			pass
		
		
		if p[0] in mask_list or p[1] in mask_list:
			continue
				
		var pp = astar.get_id_path(p[0], p[1])	
		
		if len(pp) > 0 and pp[0] == pp[-1]:
			continue
			pass
			
		if pp.size() > 0:
			Global.group_visited.append(p[0])
			Global.group_visited.append(p[1])
			
			if not Global.intersections.has(p[0]):
				#if p[0] not in Global.intersections.keys():
				Global.intersections[p[0]] = 0
			if not Global.intersections.has(p[1]):
				#if p[1] not in Global.intersections.keys():
				Global.intersections[p[1]] = 0
				
			if Global.intersections[p[0]] < 4 and p[0] in Global.intersections.keys():
				Global.intersections[p[0]] += 1
			if Global.intersections[p[1]] < 4 and p[1] in Global.intersections.keys():
				Global.intersections[p[1]] += 1
		
			#print(pp, ' pp')

			hallway_in_map(pp)
			hallway_mask_previous(pp)
			
			Global.add_maze_segments(pp)
			
	#Global.intersections = intersections

		
func hallway_in_map(hallway, skip_walkway=false):
		
	for h in range(hallway.size()):
		var hh = hallway[h]
		var v = index_to_vector(hh)
		for j in range(v.x * hall_width + hall_padding, v.x * hall_width + hall_width - hall_padding):
			for i in range(v.y * hall_width + hall_padding, v.y * hall_width + hall_width - hall_padding):
				#finished_map[j][i] = HALL
				assign_map(j, i, MAZE_WALKWAY)
				if not skip_walkway:
					working_map[v.x][v.y] = HALL
				#record_center_a = j
				#record_center_b = i #+ working_map.size()
				record_index = hh
				#print('shape v:', v)
	
	for h in range(hallway.size()):
		var hh = hallway[h]
		var v = index_to_vector(hh)
		## UP
		if v.y > 0 and working_map[v.x ][v.y - 1] == HALL:
			#print("here up")
			for j in range(v.y * hall_width , v.y * hall_width  + hall_padding ):
				for i in range(v.x * hall_width  + hall_padding , v.x * hall_width +hall_width - hall_padding ):
					#finished_map[j][i] = 1
					assign_map(i,j, MAZE_WALKWAY)
					pass
							
		## LEFT
		if v.x > 0 and working_map[v.x - 1][v.y ] == HALL:
			#print("here left")
			for j in range(v.y * hall_width + hall_padding , v.y * hall_width + hall_width - hall_padding ):
				for i in range(v.x * hall_width , v.x * hall_width + hall_padding ):
					#finished_map[j][i] = 5
					assign_map(i,j, MAZE_WALKWAY)
					pass
		
		## DOWN
		if v.y <  maze_h -1 and working_map[v.x ][v.y + 1] == HALL:
			#print('here down')
			for j in range(v.y * hall_width + hall_width - hall_padding, v.y * hall_width + hall_width  ):
				for i in range(v.x * hall_width + hall_padding, v.x * hall_width + hall_width - hall_padding ):
					#finished_map[j][i] = 2
					assign_map(i,j, MAZE_WALKWAY)
					pass
		## RIGHT
		if  v.x < maze_w - 1 and  working_map[v.x + 1][v.y ] == HALL:
			#print("here right")
			for j in range(v.y * hall_width + hall_padding , v.y * hall_width + hall_width - hall_padding ):
				for i in range(v.x * hall_width + hall_width - hall_padding , v.x * hall_width +  hall_width  ):
					#finished_map[j][i] = 3
					assign_map(i,j, MAZE_WALKWAY)
					pass


func assign_map(i, j, k):
	finished_map[i][j] = k 

func hallway_mask_previous(hallway):
	for h in range(hallway.size()):
		var hh = hallway[h]
		var v = index_to_vector(hh)
		
		working_map[v.x][v.y] = USED
		
		if  astar.has_point(hh) and not astar.is_point_disabled(hh) :
			astar.set_point_disabled(hh)


func make_map_start(n:Vector2):
	#var set_map_start_only = true 
	#print('h_vector now ', h_vector)
	map_start = null
	for i in range(- ( finished_map.size() -1),0 ): ## mirror
		for j in range( -(finished_map[i].size() -1),0):
			#var ii =  finished_map.size() + i
			#var jj =  finished_map[0].size() + j 
			var a =  finished_map.size()
			var b =  finished_map[0].size()
			#var v = Vector3(i - n.x + a , center_depth ,j - n.y + b  )	
			#print(v.x, " v.x new")
			#v.z = - jj - n.y + b 
			if map_start == null : #or set_map_start_only:
				map_start = Vector3( i - n.x + a, center_depth, j - n.y + b)
				return
				


func copy_map_to_scene(n:Vector2, block_num=2, set_map_start_only=false):
	#print('h_vector now ', h_vector)
	map_start = null
	for i in range(- ( finished_map.size() -1),0 ): ## mirror
		for j in range( -(finished_map[i].size() -1),0):
			var ii =  finished_map.size() + i
			var jj =  finished_map[0].size() + j 
			var a =  finished_map.size()
			var b =  finished_map[0].size()
			var v = Vector3(i - n.x + a , center_depth ,j - n.y + b  )	
			#print(v.x, " v.x new")
			#v.z = - jj - n.y + b 
			if map_start == null : #or set_map_start_only:
				map_start = Vector3( i - n.x + a, center_depth, j - n.y + b)
				if set_map_start_only:
					return
			if finished_map[ii][jj] == MAZE_WALKWAY:
				block_num = 1
				set_cell_item.call(v, block_num)
				continue
			if finished_map[ii][jj] == MAZE_OTHER or finished_map[ii][jj] == 0:
				block_num = 1 #2
			if finished_map[ii][jj] == MAZE_BRICK:
				block_num = 3
				
			for y in range(center_depth, center_depth + 4):
				v.y = y
				set_cell_item.call(v, block_num)
				
			#for y in range(center_depth + 4, center_depth + 6):
			#	v.y = y
			#	set_cell_item.call(v, 1)
	#print('shape map_start ', map_start)	

func find_map():
	#if not skip_loops:
	#print('record index ', record_index)
	var vec = index_to_vector(record_index)
	#var hall =  4
	#var i =   hall 
	#var j =   hall

	#var sign_w = 0
	#var sign_h = 1 
	
	var c =  h_vector.x 
	var d =  h_vector.z 
	#c *= sign_w
	#d *= sign_h
	
	var width_h = hall_width 
	var width_w = hall_width 
	#print(c, ' ', d, ' c/d w,h ' , vec )
	var r = Vector2(  ( vec.x * width_w  - c)  ,  (  vec.y * width_h  - d)   )
	
	return  r

func set_maze_size(left, right, depth, x, y, z, endpoints):
	print('maze location is set dynamically!!')
	center_depth = depth
	print('maze width should match height and div by 5')
	var dim = max(left, right)
	maze_h = dim
	maze_w = dim
	vectors_len = endpoints
	Global.maze_h = dim 
	Global.maze_w = dim 
	Global.hall_width = hall_width
	pass

func set_callable(set_cell: Callable):
	set_cell_item = set_cell

func set_callable_get_cell(set_get: Callable):
	get_cell_item = set_get 

func set_callable_place_object(place: Callable):
	place_object = place 

func set_callable_to_global(to_g: Callable):
	to_global = to_g

func set_callable_map_to_local(get_local: Callable):
	map_to_local = get_local

func set_callable_local_to_map(get_map: Callable):
	local_to_map = get_map

#func get_local_to_map(vec):
#	return local_to_map.call(vec)

#func get_map_to_local(vec):
#	return map_to_local.call(vec)

func mark_intersection(out):
	#PRINTOUT_SYMBOL = symbol
	var g = index_to_vector(out)
	#finished_map[g.x * 5 + 2][g.y * 5 + 2] = 9
	g.x = g.x * 5 + 2 #+ maze_w
	g.y = g.y * 5 + 2 #+ maze_h
	if g.x > -1 and g.y > -1:
		assign_map(g.x , g.y , SPOT)
	print(out, ' ', g, ' g vector')
	return out 
	

func get_record_index():
	return record_index
