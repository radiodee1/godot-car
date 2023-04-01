extends Camera3D

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity_mult = 9.8
var jump = 2.5

var cam_accel = 40
var mouse_sense = 0.1
var snap

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

#@onready var head = $arm
#@onready var camera = $arm/Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		#rotation.x = deg_to_rad(- event.relative.x * mouse_sense)
		rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		#head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#get keyboard input
	#direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input) #.rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	
	snap = Vector3.DOWN
	accel = ACCEL_AIR
		#gravity_vec += Vector3.DOWN * gravity * delta
		
	
	
	#make it move
	#velocity = velocity.lerp(direction * speed, accel * delta)
	h_offset = direction.x
	v_offset = direction.z
	
	#floor_snap_length = Vector3(float(movement), float(snap), float(0))
	#floor_snap_length = snap.y
	#gravity = gravity_vec * gravity_mult
	#move_and_slide()
	pass
