extends VehicleBody3D

func _physics_process(delta):
	pass
	var steer = Input.get_axis("move_right", "move_left")
	steering = steer * 1
	var acceleration = Input.get_axis("move_backward", "move_forward")
	engine_force = acceleration * 100
