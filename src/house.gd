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

func init(v, xname='HOUSE', group='mob'):
	var low_scene_instance = self 
	global_transform.origin = Vector3(v)
	
	var scale_local = 0.25
	#low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	low_scene_instance.add_to_group(group)
	low_scene_instance.name = xname
	
	low_scene_instance.collision_mask = 1
	low_scene_instance.collision_layer = 1
	pass 
