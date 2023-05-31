extends Node2D

var mat
var can_draw 
var line_width = 2
var rot = 0
#var pos3 = Vector3(0,0,0)
var pos = Vector3(0,0,0)

var hall_width = 5
var maze_h = 10
var maze_w = 10
var long_delta = 0

@onready var character = $"../CharacterBody3D"
@onready var gridmap = $"../GridMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	can_draw = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rot = character.get_player_rotation()
	
	pos = character.get_player_position()
	#pos = Vector2(pos3.x, pos3.z) 
	
	set_draw_position(-1)
	
	long_delta += delta
	if long_delta > 1 or true:
		queue_redraw()
		long_delta = 0
	pass

func init(matrix, size):
	mat = matrix	
	line_width = size
	pass

func set_visibility(v):
	visible = v
	can_draw = v

func _draw():
	draw_map()
	draw_red_dot(pos)
	#can_draw = false
	visible = true

func draw_map():
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
				#draw_rect(Rect2(from, to), color, true)
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



func draw_red_dot(world_vec:Vector3):
	var map_local = gridmap.hud_map_get_map_loc()
	#map_local = Vector3(map_local.x , 0, map_local.y )
	map_local = gridmap.to_local(map_local)
	map_local = gridmap.local_to_map(map_local)
	
	var map_location = gridmap.to_local(world_vec)
	var vec_out = gridmap.local_to_map(map_location)
	
	var vec = Vector2(0,0)
	vec.x =  vec_out.x 
	vec.y =  vec_out.z
	vec.x -= map_local.x /2
	vec.y -= map_local.z /2
		
	vec.x = int(vec.x)
	vec.y = int(vec.y)

	var hatch_size = 5
	var from_h = Vector2(line_width * vec.x , line_width * vec.y - hatch_size )
	var to_h = Vector2(line_width * vec.x  + line_width , line_width * vec.y  + line_width + hatch_size)
	from_h.x -= line_width * len(mat) / 2
	from_h.y -= line_width * len(mat[0]) / 2
	to_h.x -= (line_width * len(mat) + line_width) / 2
	to_h.y -= (line_width * len(mat[0]) + line_width) / 2
	draw_line(from_h, to_h, Color.RED, line_width)
	var from_w = Vector2(line_width * vec.x - hatch_size, line_width * vec.y )
	var to_w = Vector2(line_width * vec.x  + line_width + hatch_size, line_width * vec.y  + line_width)
	from_w.x -= line_width * len(mat) / 2
	from_w.y -= line_width * len(mat[0]) / 2
	to_w.x -= (line_width * len(mat) + line_width) / 2
	to_w.y -= (line_width * len(mat[0]) + line_width) / 2
	draw_line(from_w, to_w, Color.RED, line_width)
	draw_line(from_h, to_w, Color.RED, line_width)
	
