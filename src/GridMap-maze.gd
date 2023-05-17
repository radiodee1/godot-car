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
var group_visited = []
var decorate = []
var mask_list = []

var working_map = []
var finished_map = []

var shape_list = []
var intersections = {}

var rng = RandomNumberGenerator.new()
var astar = AStar2D.new()
var HALL = 4
var NONE = 0
var USED = -1
var SHAPE = 9
var SPOT = 5

var PRINTOUT_SYMBOL = 'X'

var MAZE_WALKWAY = 2000
var MAZE_BRICK = 2001
var MAZE_OTHER = 2002

var center_h = 0
var center_w = 0
var center_depth = - 6 

#var record_center_a = 0
#var record_center_b = 0

var record_index = 0

var h_vector: Vector3 #= Vector3(0,0,0)

var set_cell_item: Callable
  
var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

func clear_variables():
	start_vectors = []
	intersections = {}
	#vectors_len =  7 #+ 10
	#start_vectors_index = []
	group_visited = []
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
	
	shapes_to_map() ## after add_to_astar
	
	process_astar_vectors(start_vectors)
	
	hallway_decorate()
	
	#show_2d_grid(finished_map, true)	
	
	print("finished")
	
	var n = find_map() 
	
	copy_map_to_scene(n, block_num)
	
	#show_2d_grid(working_map, true)
	
	pass 

func add_shape(shape_num, place=Vector2(-1,-1), name="PRISON"):
	if shape_num == 0:
		return
	var shape = [shape_num, place, name]	
	shape_list.append(shape)
	if name == 'ALTAR':
		#print(shape)
		pass

func add_mesh_hallways(hallway_array, block_num):
	var temp = {
		"mesh": block_num,
		"nodes": hallway_array
	}
	decorate.append(temp)
	#print(decorate)


func shapes_to_map(move_old_vectors=false):
	#print(start_vectors, ' start_vectors')
	#print(working_map, ' working_map')
	#print(shape_list, ' shape_list')
	for i in range(shape_list.size()):
		var x = shape_list[i]
		if x[2] != 'PRISON' :
			continue
		var layout = dict.shapes['layout'][x[0]]
		var mesh = dict.shapes['mesh'][x[0]]
		var start = dict.shapes['start'][x[0]]
		var end = dict.shapes['end'][x[0]]
		#print(layout, ' shape ', mesh, ' ', start, ' ' , end)
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
			var mesh_num = 3
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
					intersections[v[0]] = 1
					#print('enabled ', v, ' - ', hallway, ' - ', start_vectors)
				
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
		pass
	pass

func hallway_decorate():
	for i in decorate:
		var low_h = maze_h * hall_width
		var low_w = maze_w * hall_width
		var high_h = 0
		var high_w = 0
		var block_num = MAZE_BRICK
		var hallway = i['nodes']
		print(hallway)
		for j in hallway:
			if j.y < low_h :
				low_h = j.y
			if j.x < low_w :
				low_w = j.x
			if j.y > high_h:
				high_h = j.y 
			if j.x > high_w:
				high_w = j.x 
		for j in hallway:
			var end_h = hall_width
			var end_w = hall_width
			var start_h = 0
			var start_w = 0
			if j.y == low_h :
				start_h =  2 
			if j.x == low_w :
				start_w =  2 
			if j.y == high_h :
				end_h = 2 #hall_width - 2
				#print(' y consider')
			if j.x == high_w :
				end_w = 2 #hall_width - 2
				#print(' x consider')
			for ww in range(j.x * hall_width + start_w, j.x * hall_width + end_w ):
				for hh in range(j.y * hall_width + start_h, j.y * hall_width + end_h ):
					
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
	
func show_2d_grid(matrix, advance = false, line_size=3, show_hidden=false):
	if not advance:
		for h in matrix:
			print(h)
	else:
		var line = "|"
		for h in range(matrix.size()):
			line += "-----".substr(0, line_size)
		line += "|"
		print(line)	
		for h in range(matrix.size()):
			line = "|"
			for j in range(matrix[h].size()):
				if matrix[h][j] == SPOT:
					var line_spot = ' X  '.substr(0, line_size)
					#var line_spot = ' ' + PRINTOUT_SYMBOL + ' '
					#var line_spot_mod = line_spot.substr(0, line_size)
					line += line_spot
					continue
				if matrix[h][j] == MAZE_OTHER: # or matrix[h][j] == 0:
					var line_spot = ' H  '.substr(0, line_size)
					line += line_spot
					continue
				if matrix[h][j] == 0 :
					var three = '     ' # 5 spaces
					line += three.substr(0, line_size) ## 3 spaces
				else:
					var jj = abs(j / hall_width)
					var hh = abs(h / hall_width)
					var line_temp = " " + str( vector_to_index(Vector2(hh,jj)) ) + "   "
					line += line_temp.substr(0, line_size)
			line += "|"
			print(line)
		line = "|"
		for h in range(matrix.size()):
			line += "-----".substr(0, line_size)
		line += "|"
		print(line)			

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
	return v.x * maze_w + v.y  

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
	group_visited.append(z[0][0])
	for p in z:
		if p[0] < 0 or p[1] < 0:
			#continue
			pass
		
		#if p[0] not in group_visited and p[1] not in group_visited:
			#print('not in group ', p[0], ' or ', p[1])
		#	continue
		if p[0] in mask_list or p[1] in mask_list:
			continue
				
		var pp = astar.get_id_path(p[0], p[1])	
		if pp.size() > 0:
			group_visited.append(p[0])
			group_visited.append(p[1])
			
			if p[0] not in intersections:
				intersections[p[0]] = 0
			if p[1] not in intersections:
				intersections[p[1]] = 0
				
			if intersections[p[0]] < 4:
				intersections[p[0]] += 1
			if intersections[p[1]] < 4:
				intersections[p[1]] += 1
		
			#print(pp, ' pp')

			hallway_in_map(pp)
			hallway_mask_previous(pp)
			
			Global.add_maze_segments(pp)
			
	Global.intersections = intersections

		
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
		astar.set_point_disabled(hh)
		

func copy_map_to_scene(n:Vector2, block_num=1):
	#print('h_vector now ', h_vector)
	for i in range(- ( finished_map.size() -1),0 ): ## mirror
		for j in range( -(finished_map[i].size() -1),0):
			var ii =  finished_map.size() + i
			var jj =  finished_map[0].size() + j 
			var a =  finished_map.size()
			var b =  finished_map[0].size()
			var v = Vector3(i - n.x + a , center_depth ,j - n.y + b  )	
			#print(v.x, " v.x new")
			#v.z = - jj - n.y + b 
			if finished_map[ii][jj] == MAZE_WALKWAY:
				block_num = 1
				set_cell_item.call(v, block_num)
				continue
			if finished_map[ii][jj] == MAZE_OTHER:
				block_num = 2
			if finished_map[ii][jj] == MAZE_BRICK:
				block_num = 3
				
			for y in range(center_depth, center_depth + 4):
				v.y = y
				set_cell_item.call(v, block_num)
		

func find_map():
	#if not skip_loops:
	print('record index ', record_index)
	var vec = index_to_vector(record_index)
	var hall =  4
	var i =   hall 
	var j =   hall

	var sign_w = 0
	var sign_h = 1 
	
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
	

