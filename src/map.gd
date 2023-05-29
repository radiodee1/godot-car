extends Node2D

var mat
var can_draw 
var line_width = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	can_draw = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
					color = Color.BLACK
					pass
				elif type > 2000:
					color = Color.WHITE
				var from = Vector2(line_width * i, line_width * j)
				var to = Vector2(line_width * i + line_width, line_width * j + line_width)
				draw_line(from, to, color, line_width)
	pass

func set_draw_position(pos):
	if pos != -1:
		position = pos
		return
	var p = Vector2(DisplayServer.window_get_size())
	p.x -= mat.size() * line_width
	p.y -= mat.size() * line_width
	position = p

func set_draw_rotation(rot):
	rotation = rot	
