extends VehicleBody3D

var steer = 0
var max_torque = 30
var max_rpm = 50
var friction = 0

func _physics_process(delta):
	pass
	steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
	steering = steer 
	
	var acceleration = Input.get_axis("move_backward", "move_forward") * delta * 10
	
	var rpm1 = ($wheel_back_left.get_rpm())
	var rpm2 = ($wheel_back_right.get_rpm())
	var rpm = abs((rpm1 + rpm2) / 2.0)
	
	if abs(acceleration) < 0.1 and rpm > 0.1 :
		friction = delta * 10 * max_torque *  ( rpm1 / abs(rpm1) )
	else:
		friction = 0
	engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm ) - friction
