extends Node3D

@onready var patrol = $"patrol"
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	var path = [
		Vector3(5, 0, 0), 
		#Vector3(10, 0, 0),
		#Vector3(15, 0, 0),
		#Vector3(15, 0, 5),
		#Vector3(15, 0, 10),
		Vector3(5, 0, 0)
	]
	patrol.set_path(path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
