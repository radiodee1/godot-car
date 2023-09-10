extends VehicleBody3D

var steer = 0
var max_torque = 30
var max_rpm = 50


func _physics_process(delta):
	pass
	steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
	
	steering = steer 
	var acceleration = Input.get_axis("move_backward", "move_forward")
	var rpm = 0
	rpm = abs($wheel_back_left.get_rpm())
	$wheel_back_left.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm)
	rpm = abs($wheel_back_right.get_rpm())
	$wheel_back_right.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm)
	
