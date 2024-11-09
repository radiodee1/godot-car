extends CharacterBody3D

var color:Color = Color(0.8, 0.7, 0.5)

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_color_gui(x:Color):
	get_node("house/Cube").get_mesh().surface_get_material(0).albedo_color = x

func init(v, xname='HOUSE', group='mob'):
	set_color_gui(color)
	var low_scene_instance = self 
	global_transform.origin = Vector3(v)
	
	#var scale_local = 0.25
	#low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	low_scene_instance.add_to_group(group)
	low_scene_instance.name = xname
	
	low_scene_instance.collision_mask = 1
	low_scene_instance.collision_layer = 1

	set_collision_mask_value(1,true)
	set_collision_layer_value(1, true)
	self.collision_mask = 1
	self.collision_layer = 1

	check_collision_ground()
	pass

func check_collision_ground():
	var num = 0 
	while not is_on_floor() and global_transform.origin.y > 1 and num < 200:
		var y = global_transform.origin.y 
		y -= 0.1  
		global_transform.origin.y = y
		num += 1 
	return 

func check_collision():
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			#Global.set_score_allowed(true)
			
			if collision.get_collider().is_in_group("mob") :
				
				if collision.get_collider().name.begins_with('ALTAR') :
					pass 
	
