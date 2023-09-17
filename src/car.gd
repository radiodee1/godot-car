extends VehicleBody3D

var steer = 0
var max_torque = 30
var max_rpm = 50
var friction = 0
var accel_const = 250

func _ready():
	position = Vector3(15 * 5 / 2, 5 * 5 , 15 * 5 / 2)


func _physics_process(delta):
	
	steer = lerp(float(steer), float(Input.get_axis("move_right", "move_left") * 0.4), 5 * delta)
	steering = steer 
	
	var acceleration = Input.get_axis("move_backward", "move_forward") * delta * accel_const
	
	var rpm1 = ($wheel_back_left.get_rpm())
	var rpm2 = ($wheel_back_right.get_rpm())
	var rpm = abs((rpm1 + rpm2) / 2.0)
	
	if abs(acceleration) < 0.1 and rpm > 0.1 :
		friction = delta * accel_const * max_torque *  ( rpm1 / abs(rpm1) )
	else:
		friction = 0
	engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm ) - friction
