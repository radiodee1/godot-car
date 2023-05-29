extends Node2D

var mat
var can_draw 
var line_width = 2
var rot = 0
#var pos3 = Vector3(0,0,0)
var pos = Vector2(0,0)

var hall_width = 5
var maze_h = 10
var maze_w = 10
var long_delta = 0

@onready var character = $"../CharacterBody3D"
@onready var gridmap = $"../GridMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	can_draw = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rot = character.get_player_rotation()
	
	var pos3 = character.get_player_position()
	pos = Vector2(pos3.x, pos3.z) ## not used!!
	
	set_draw_position(-1)
	
	#long_delta += delta
	#if long_delta > 1:
	#	queue_redraw()
	#	long_delta = 0
	pass

func init(matrix, size):
	mat = matrix	
	line_width = size
	pass

func set_visibility(v):
	visible = v
	can_draw = v

func _draw():
	if can_draw:
		for i in range(len(mat)):
			for j in range(len(mat[i])):
				var color = 0
				var type = mat[i][j]
				if type == 0:
					color = Color.GRAY
					pass
				elif type > 2000:
					color = Color.WHITE
				
				#if is_match(Vector2(i,j), pos):
					#color = Color.RED
					
				var from = Vector2(line_width * i, line_width * j)
				var to = Vector2(line_width * i + line_width, line_width * j + line_width)
				from.x -= line_width * len(mat) / 2 
				from.y -= line_width * len(mat[0]) / 2
				to.x -= (line_width * len(mat) + line_width) / 2
				to.y -= (line_width * len(mat[0]) + line_width) / 2
				draw_line(from, to, color, line_width)
	pass

func set_draw_position(pp):
	if mat != null:
		if pp != -1:
			position = pp
			return
		var p = Vector2(DisplayServer.window_get_size())
		p.x -= mat.size() * line_width / 2
		p.y -= mat.size() * line_width / 2
		position = p
		rotation = rot
		maze_h = mat[0].size()
		maze_w = mat.size()

func set_draw_rotation(r):
	rot = r

func is_match(altar_vec:Vector2, world_vec:Vector2):
	var closenes = line_width
	var map_location = gridmap.hud_map_get_map_loc()	
	altar_vec.x = ((5 * altar_vec.x - map_location.x)) / (2*2)#+ size.x
	altar_vec.y = ((5 * altar_vec.y - map_location.y)) / (2*2)#+ size.y ## -?
	#print(altar_vec, world_vec, map_location)
	if abs(altar_vec.x - world_vec.x) < closenes and abs(altar_vec.y - world_vec.y) < closenes:
		return true
	return false
	pass
