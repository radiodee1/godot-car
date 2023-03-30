extends CharacterBody3D

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
#var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

@onready var head = $arm
@onready var camera = $arm/Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		#rotation.x = deg_to_rad(- event.relative.x * mouse_sense)
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second and false:
		#camera.top_level = true # set_as_toplevel(true)
		#camera.global_transform.origin = camera.global_transform.origin.lerp(head.global_transform.origin, cam_accel * delta)
		#camera.rotation.y = rotation.y
		#camera.rotation.x = head.rotation.x
		pass
	else:
		camera.top_level = false #camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
		#global_transform = head.global_transform

func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	#make it move
	velocity = velocity.lerp(direction * speed, accel * delta)
	velocity = velocity + gravity_vec
	
	#floor_snap_length = Vector3(float(movement), float(snap), float(0))
	floor_snap_length = snap.y
	#gravity = gravity_vec * gravity_mult
	move_and_slide()
	
	#move_and_slide_with_snap(movement, snap, Vector3.UP)
