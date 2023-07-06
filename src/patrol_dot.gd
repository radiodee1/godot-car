extends Node3D

@onready var dot = $"dot"
@onready var can_die = false

func init(v, description='DOT', group='mob'):
	name = description
	var low_scene_instance = self 
	global_transform.origin = v
	
	self.set_green()
	#print(v, " vector")
	var low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(0.5,0.5,0.5)
	var scale_local = 0.25
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#low_scene_instance.name = name
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

	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1

func set_red():
	var mat_red = StandardMaterial3D.new()
	mat_red.albedo_color = Color(1,0.5,0.5)
	$"dot".set_surface_override_material(0, mat_red)
	can_die = false
	pass
	
func set_green():
	var mat_green = StandardMaterial3D.new()
	mat_green.albedo_color = Color(0.5, 1, 0.5)
	$"dot".set_surface_override_material(0, mat_green)
	can_die = true
	pass
