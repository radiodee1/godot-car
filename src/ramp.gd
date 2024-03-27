extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(v, namex='RAMP', group='mob'):
	var scale_local = 1 
	v.y += 2
	var j = load("res://src/gator_walk.tscn").instantiate()
	j.name = namex
	add_child(j)
	
	self.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	
	self.add_to_group(group)
	
	self.name = name
	
	self.collision_mask = 1
	self.collision_layer = 1
	#move_walk()
	#animation_walk = $'gator_walk/AnimationPlayer'
	var collision_shape = $"CollisionShape3D" 
	#gator_walk = $"gator_walk"
		
	#animation_walk.play(anim_walk)
	#gator_walk.global_transform.origin = v
	global_transform.origin = v
	
	#gator_walk.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#collision_shape.scale_object_local(Vector3(scale_local, scale_local, scale_local))
	
