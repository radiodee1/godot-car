extends Node3D


@onready var particles = $"GPUParticles3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	particles.process_mode = Node.PROCESS_MODE_ALWAYS
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func set_translate(vv: Vector3, altered=false):
	var v = Vector3(vv)
	if  altered:
		v.x *= 0.5
		v.y *= 0.5
		v.z *= 0.5
	
	#translate(v)
	position = v
	print(v, ' rubble!! - translate ', position)
	#particles.translate(v)
	
func set_emitting(emit):
	#print("emitting!!")
	if emit == true:
		particles.restart()
	#particles.emitting = emit

func set_lifetime(l):
	particles.lifetime = l 
