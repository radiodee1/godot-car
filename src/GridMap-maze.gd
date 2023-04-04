extends GridMap

# odd number greater than 2
var hall_width = 3

# must include padding around actual vectors
var maze_w = 5
var maze_h = 10

var start_vectors = []
var vectors_len = 3
var start_vectors_index = []

var working_map = []
var finished_map = []

var rng = RandomNumberGenerator.new()
var astar = AStar2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	working_map = make_2d_grid(maze_w, maze_h)
	show_2d_grid(working_map)
	finished_map = make_2d_grid(maze_w * hall_width, maze_h * hall_width)
	#show_2d_grid(finished_map)
	start_vectors = randomize_vector2d(vectors_len, 1, 1, maze_w, maze_h )
	print(start_vectors)
	
	add_to_astar(working_map, true)
	start_vectors_index = vector_2d_to_index_list(start_vectors)
	print(start_vectors_index)
	process_astar_vectors(start_vectors_index)
	pass # Replace with function body.


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
	
func show_2d_grid(matrix):
	for h in matrix:
		print(h)

func randomize_vector2d(length_of_array, left_padding, top_padding, width_of_map, height_of_map):
	var v = []
	var picked = []
	#top_padding -= 1
	var interval = max( abs((width_of_map - left_padding * 2 ) / length_of_array), 1 )
	var available = []
	for i in range(top_padding  , height_of_map - top_padding ):
		available.append(i)
	print(interval, " ",available)
	for i in range(length_of_array):
		print(available)
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
	print(v)
	return v

func process_astar_vectors(v):
	var z = []
	for a in range(v.size()):
		for b in range(a, v.size()):
			if a != b:
				z.append([ v[a], v[b] ])
	print(z)
	for p in z:
		var pp = astar.get_id_path(p[0], p[1])
		print(pp)
		for x in pp:
			print(index_to_vector(x), ' ', x)
