extends Node3D


@onready var particles = $"GPUParticles3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func set_translate(v: Vector3):
	particles.translate(v)
	
func set_emitting(emit):
	print("emitting!!")
	particles.emitting = emit
