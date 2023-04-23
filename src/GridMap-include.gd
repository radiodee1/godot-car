extends Resource

var mesh_instance_3d
var scale_local = 0.5
var add_child: Callable

var box_shape
var box_mesh
var static_body

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func place_altar(v):
	
	mesh_instance_3d = MeshInstance3D.new()
	
	box_mesh = load("res://assets/altar.obj")
	#print(v, " vector")
	box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5,0.5,0.5)
	#box_mesh.size = Vector3(0.5,0.5,0.5)
	mesh_instance_3d.mesh = box_mesh
	mesh_instance_3d.add_to_group('mob')
	mesh_instance_3d.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	add_child.call(mesh_instance_3d)
	mesh_instance_3d.translate(v) 
	static_body = StaticBody3D.new()
	static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group('mob')
	collision_shape.name = 'pin'
	collision_shape.shape = box_shape
	collision_shape.disabled = false
	static_body.add_child(collision_shape)
	static_body.add_to_group('mob')
	static_body.name = 'pin'
	static_body.set_collision_layer_value(1, true)
	static_body.set_collision_mask_value(1, true)
	mesh_instance_3d.add_child(static_body) 
	mesh_instance_3d.add_to_group('mob')
	mesh_instance_3d.name = 'pin'
	#mesh_instance_3d.add_child(kinematic)
	mesh_instance_3d.layers = 1
	
	static_body.collision_mask = 1
	static_body.collision_layer = 1

func remove_altar():
	if mesh_instance_3d != null:
		mesh_instance_3d.queue_free()
		box_mesh = null #.free()
		box_shape = null #.free()
		static_body.free()
		#collision_shape.queue_free()

func set_callable(set_add: Callable):
	add_child = set_add
