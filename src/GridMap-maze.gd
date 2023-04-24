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
var vectors_len =  7 #+ 10
var start_vectors_index = []

var working_map = []
var finished_map = []

var rng = RandomNumberGenerator.new()
var astar = AStar2D.new()
var HALL = 4
var NONE = 0
var USED = -1

var center_h = 0
var center_w = 0
var center_depth = - 6 

var record_center_a = 0
var record_center_b = 0
var record_index = 0

var h_vector: Vector3 #= Vector3(0,0,0)

var set_cell_item: Callable
  
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func clear_variables():
	start_vectors = []
	vectors_len =  7 #+ 10
	start_vectors_index = []

	working_map = []
	finished_map = []

	center_h = 0
	center_w = 0
	center_depth = - 6 

	record_center_a = 0
	record_center_b = 0
	record_index = 0

	h_vector = Vector3(0,0,0)
	astar = AStar2D.new()
	
	pass

	
func maze_generate(hvec=Vector3(0,0,0), block_num=1):
	#print(center_h, ' ', center_w, ' center h, w  0')
	
	clear_variables()
	
	h_vector = hvec

	working_map = make_2d_grid(maze_w, maze_h)
	
	finished_map = make_2d_grid(maze_w * hall_width, maze_h * hall_width)
	
	start_vectors = randomize_vector2d(vectors_len, 1, 1, maze_w, maze_h )
	
	add_to_astar(working_map, true)
	
	prepare_working_map()
		
	start_vectors_index = vector_2d_to_index_list(start_vectors)
	
	process_astar_vectors(start_vectors_index)
	print("finished")
	
	#show_2d_grid(working_map)
	
	show_2d_grid(finished_map, true)
	
	var n = find_map() 
	
	copy_map_to_scene(n, block_num)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func make_2d_grid(width, height):
	var matrix = []
	for h in range(height):
		matrix.append([])
		for w in range(width):
			matrix[h].append(0)
			pass
	return matrix
	
func show_2d_grid(matrix, advance = false):
	if not advance:
		for h in matrix:
			print(h)
	else:
		var line = "|"
		for h in range(matrix.size()):
			line += "---"
		line += "|"
		print(line)	
		for h in range(matrix.size()):
			line = "|"
			for j in range(matrix[h].size()):
				if matrix[h][j] == 0:
					line += "   " ## 3 spaces
				else:
					var jj = abs(j / hall_width)
					var hh = abs(h / hall_width)
					var line_temp = " " + str( vector_to_index(Vector2(hh,jj)) ) + "   "
					line += line_temp.substr(0, 3)
			line += "|"
			print(line)
		line = "|"
		for h in range(matrix.size()):
			line += "---"
		line += "|"
		print(line)			

func prepare_working_map():
	var map = working_map
	for i in range(map.size()):
		for j in range(map[i].size()):
			if i == 0:
				map[i][j] = USED
			if i == map.size() - 1:
				map[i][j] = USED
			if j == 0:
				map[i][j] = USED
			if j == map[i].size() - 1:
				map[i][j] = USED
				
			if map[i][j] == USED:
				astar.set_point_disabled(vector_to_index(Vector2(j,i)))
			## assume x-size equals y-size
	


func randomize_vector2d(length_of_array, left_padding, top_padding, width_of_map, height_of_map):
	var v = []

	#var picked = []
	#top_padding -= 1
	var interval = max( abs((width_of_map - left_padding * 2 ) / length_of_array), 1 )
	var available = []
	for i in range(top_padding  , height_of_map - top_padding ):
		available.append(i)
	
	#available = available.slice(0, width_of_map - 1)
	var l = min(length_of_array, available.size())
	
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
	return v

func add_to_astar(grid, print_rows = false):
	var num = 0
	for i in range(grid.size()):
		var line = []
		for j in range(grid[i].size()):
			var v = Vector2(i, j)
			astar.add_point(vector_to_index(v), v)
			if i > 0:
				var v_prev = Vector2(i - 1, j)
				astar.connect_points(vector_to_index(v), vector_to_index(v_prev), true)
				pass
			if j > 0:
				var v_prev = Vector2(i, j-1)
				astar.connect_points(vector_to_index(v), vector_to_index(v_prev), true)
				pass
			if print_rows:
				line.append([ vector_to_index(v) , v])
			num += 1
		if print_rows:
			print(line)

func vector_2d_to_index_list(v):
	var i = []
	for j in v:
		var k = vector_to_index(j[1]) # j[1].y * maze_w + j[1].x
		i.append(k)
	return i
		
func vector_to_index(v):
	return v.x * maze_w + v.y  

func index_to_vector(i):
	var v = Vector2(abs(i / maze_w), i - abs(i / maze_w) * maze_w)
	return v

func process_astar_vectors(v):
	var z = []
	for a in range(v.size()):
		for b in range(a, v.size()):
			if a != b:
				z.append([ v[a], v[b] ])
	#print(z)
	for p in z:
		var pp = astar.get_id_path(p[0], p[1])	
		print(pp, ' pp')
		#pp = [26,21,16]
		#pp.reverse()
		hallway_in_map(pp)
		hallway_mask_previous(pp)
		
func hallway_in_map(hallway):
	
	for h in range(hallway.size()):
		var hh = hallway[h]
		var v = index_to_vector(hh)
		for j in range(v.x * hall_width + hall_padding, v.x * hall_width + hall_width - hall_padding):
			for i in range(v.y * hall_width + hall_padding, v.y * hall_width + hall_width - hall_padding):
				#finished_map[j][i] = HALL
				assign_map(j, i, HALL)
				working_map[v.x][v.y] = HALL
				record_center_a = j
				record_center_b = i #+ working_map.size()
				record_index = hh
	
	for h in range(hallway.size()):
		var hh = hallway[h]
		var v = index_to_vector(hh)
		## UP
		if v.x > 0 and working_map[v.x -1][v.y] == HALL:
			#print("here up")
			for j in range(v.x * hall_width , v.x * hall_width  + hall_padding ):
				for i in range(v.y * hall_width  + hall_padding , v.y * hall_width +hall_width - hall_padding ):
					#finished_map[j][i] = 1
					assign_map(j,i,1)
					pass
							
		## LEFT
		if v.y > 0 and working_map[v.x][v.y - 1] == HALL:
			#print("here left")
			for j in range(v.x * hall_width + hall_padding , v.x * hall_width + hall_width - hall_padding ):
				for i in range(v.y * hall_width , v.y * hall_width + hall_padding ):
					#finished_map[j][i] = 5
					assign_map(j,i, 5)
					pass
		
		## DOWN
		if v.x <  maze_h -1 and working_map[v.x + 1][v.y] == HALL:
			#print('here down')
			for j in range(v.x * hall_width + hall_width - hall_padding, v.x * hall_width + hall_width  ):
				for i in range(v.y * hall_width + hall_padding, v.y * hall_width + hall_width - hall_padding ):
					#finished_map[j][i] = 2
					assign_map(j,i,2)
					pass
		## RIGHT
		if  v.y < maze_w - 1 and  working_map[v.x][v.y + 1] == HALL:
			#print("here right")
			for j in range(v.x * hall_width + hall_padding , v.x * hall_width + hall_width - hall_padding ):
				for i in range(v.y * hall_width + hall_width - hall_padding , v.y * hall_width +  hall_width  ):
					#finished_map[j][i] = 3
					assign_map(j,i, 3)
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
			v.z = - jj - n.y + b 
			if finished_map[ii][jj] > 0:
				set_cell_item.call(v, block_num)
			if finished_map[ii][jj] == 0:
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
	#var rr = Vector2(- r.x - vec.x * width_w, - r.y -  vec.y * width_h)
	#sign_w = sign(r.x) *  1
	#sign_h = sign(r.y) *  1
	
	#r.x += -(i) * sign_w
	#r.y += -(j) * sign_h
	
	#print(i,' ', j, ' signs i,j')
	print(r, " r ", h_vector, ' ' , vec,' ')
	
	return  r

func set_maze_size(left, right, depth, x, y, z):
	print('maze location is set dynamically!!')
	center_depth = depth
	print('maze width should match height and div by 5')
	var dim = max(left, right)
	maze_h = dim
	maze_w = dim
	pass

func set_callable(set_cell: Callable):
	set_cell_item = set_cell


	
