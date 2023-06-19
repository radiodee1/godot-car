extends Node3D

@onready var dot = $"dot"

func init(v, name='DOT', group='mob'):
	#low_location_vec = v 
	#low_scene_instance = load("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	var low_scene_instance = self 
	
	global_transform.origin = v
	#var box = CubeMesh.new()	 
	#box.mesh.size = Vector3(1,1,1)
	
	var mat_red = StandardMaterial3D.new()
	mat_red.albedo_color = Color(1,0.0,0.0)
	dot.set_surface_override_material(0, mat_red)
	#box.get_active_material(0).set_albedo(Color(1,0,0))
	
	#print(v, " vector")
	var low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(0.5,0.5,0.5)
	var scale_local = 0.25
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	var low_static_body = StaticBody3D.new()
	low_static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group(group)
	collision_shape.name = name
	collision_shape.shape = low_box_shape
	collision_shape.disabled = false
	low_static_body.add_child(collision_shape)
	low_static_body.add_to_group(group)
	low_static_body.name = name
	low_static_body.set_collision_layer_value(1, true)
	low_static_body.set_collision_mask_value(1, true)
	low_scene_instance.add_child(low_static_body) 
	low_scene_instance.add_to_group(group)
	low_scene_instance.name = name
	
	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1
	
