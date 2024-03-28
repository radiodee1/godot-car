extends Node3D

#@onready var patrol = $"patrol"
@onready var camera = $"Camera3D"
@onready var ground = $"ground_MeshInstance3D"
@onready var ground_staticbody = $"ground_MeshInstance3D/StaticBody3D2"
@onready var ground_staticbody_collisionshape = $"ground_MeshInstance3D/StaticBody3D2/CollisionShape3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.current = false
	ground_staticbody.set_collision_mask_value(1,true)
	ground_staticbody.set_collision_layer_value(1, true)
	ground_staticbody.collision_mask = 1
	ground_staticbody.collision_layer = 1

	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
