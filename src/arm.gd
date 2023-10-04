extends Node3D

var direction = Vector3.FORWARD
@export var smooth_speed = 2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var current_velocity = get_parent().get_linear_velocity()
	current_velocity.y = 0
	if current_velocity.length_squared() > 1:
		direction = lerp(direction, - current_velocity.normalized(), smooth_speed * delta )
	global_transform.basis = get_rotation_from_direction(direction)
	
func get_rotation_from_direction(look_direction : Vector3):
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis, Vector3.UP, -look_direction)
	
