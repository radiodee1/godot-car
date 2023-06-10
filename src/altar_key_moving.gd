extends Node3D

var altar_name = 'Key_01Action'
@onready var animation_player = get_node("altar_key_moving/AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	altar_name = animation_player.get_assigned_animation()
	#print(altar_name, " altar_name")
	animation_player.play(altar_name )
	animation_player.connect("animation_finished", self.play)
	#var altar = get_node("altar-copy/altar")	
	process_mode = Node.PROCESS_MODE_ALWAYS	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func play():
	#var  animation_player = get_node("altar-copy/AnimationPlayer")
	animation_player.seek(0, true)
	animation_player.play(altar_name)
	pass #animation_player.advance(0)

func init(v: Vector3 , name='pin', group='mob'):
	#low_location_vec = v 
	#low_scene_instance = load("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	var low_scene_instance = self 
	v.x *= .5
	v.y *= .5
	v.z *= .5
	
	print(v, ' example vec')
	#add_child.call(low_scene_instance)
	#scene_instance.scale = Vector3(1,1,1)
	low_scene_instance.translate(v)
	
	#print(v, " vector")
	var low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(0.5,0.5,0.5)
	var scale_local = 0.5
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

	#static_body.layers = 1
	
	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1
	
