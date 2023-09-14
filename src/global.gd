extends Node

var health = 30
var score = 0
var lives = 3
var items = []
var items_temp = []

var placed_items = []

var score_allowed = true
var do_nextlevel_transition = false

var level = 0

## maze data ##
var intersections = {}
var segments = []

var maze_w = 0
var maze_h = 0
var hall_width = 0

var group_visited = []

func _ready():
	#print_tree_pretty()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_to_items(name):
	if name not in items:
		items.append(name)
		
func  add_to_items_temp(name):
	if not items_temp.has(name):
	#if name not in items_temp:
		items_temp.append(name)

	
func count_list_items(list, item):
	var num = 0
	for i in list:
		if i.begins_with(item): #  item == i:
			num += 1
		pass
	return num
	

##############################

func vector_to_index(v):
	return int(v.x * maze_w + v.y)  

func index_to_vector(i):
	var v = Vector2( int(i / maze_w), i - int(i / maze_w) * maze_w)
	return v

##############################
func clear_maze_data():
	intersections = {}
	segments = []
	
func clear_list_data():
	placed_items = []
	items_temp = []
	
func add_maze_segments(segment):
	var d = {
		"type": "empty",
		"segment": segment,
		"length": segment.size(),
		#"status": "normal"
	}
	segments.append(d)
	
func print_maze_data():
	print("++++")
	print(intersections)
	print(segments)
	print("len ", segments.size())
	print('placed ', placed_items)
	print("items temp ", items_temp)
	print("items ", items)
	#print('placed include ')
	print("++++")

func clear_score_lives_health():
	score = 0
	lives = 3
	health = 30
	level = 0

#################################

func lower_health(h):
	var hh = abs(h)
	health -= hh 
	
func lower_all_health():
	health = 0
	
func is_end_life():
	if health <= 0:
		return true 
	else :
		return false 
		
func is_end_game():
	if lives <= 0:
		return true
	else :
		return false
		
func reset_health():
	health = 30 
	
func reset_game():
	lives = 3
	score = 0
	reset_health()

func set_lives(life):
	lives = life

func add_to_score(num):
	if score_allowed or true:
		score += num
		score_allowed = false
		
func set_score_allowed(allowed=true):
	score_allowed = allowed
