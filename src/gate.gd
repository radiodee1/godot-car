extends Node3D

var MODE_LOCKED = 0 
var MODE_MOVABLE = 1 
var MODE_UN_MOVABLE = 2 
var MODE_OPEN = 3 

var gate_mode = MODE_LOCKED



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(v: Vector3 , xname='gate', group='mob'):
	#low_scene_instance = load("res://src/altar_moving.tscn").instantiate()
	self.name = xname
	var low_scene_instance = self 
	#v.x *= .5
	#v.y *= .5
	#v.z *= .5
	
	#v *= 0.5  
	#global_transform.origin = v 
	#transform.origin = v
	#print('shape -00 ', transform.origin)
	low_scene_instance.translate(v)
	#print('shape -01 ', transform.origin)
	low_scene_instance.name = xname
	#print(v, " vector")
	var low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(1,1,1)
	var scale_local = 1  
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	var low_static_body = StaticBody3D.new()
	low_static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group(group)
	collision_shape.name = xname
	collision_shape.shape = low_box_shape
	collision_shape.disabled = false
	low_static_body.add_child(collision_shape)
	low_static_body.add_to_group(group)
	low_static_body.name = xname
	low_static_body.set_collision_layer_value(1, true)
	low_static_body.set_collision_mask_value(1, true)
	low_scene_instance.add_child(low_static_body) 
	low_scene_instance.add_to_group(group)

	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1
	
