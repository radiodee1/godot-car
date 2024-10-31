extends StaticBody3D

var color:Color = Color(0.8, 0.7, 0.5)

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_color_gui(color)
	pass


func set_color_gui(x:Color):
	get_node("house/Cube").get_mesh().surface_get_material(0).albedo_color = x
