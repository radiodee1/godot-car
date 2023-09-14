extends Node3D

var altar_name = 'altarAction002'
@onready var animation_player = get_node("altar-copy/AnimationPlayer")
#@onready var size = Vector3(0.5,0.5,0.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	var altar_name = animation_player.get_assigned_animation()
	#print(altar_name, " altar_name")
	animation_player.play(altar_name )
	animation_player.connect("animation_finished", self.play)
	#var altar = get_node("altar-copy/altar")	
	process_mode = Node.PROCESS_MODE_ALWAYS	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func play():
	#var  animation_player = get_node("altar-copy/AnimationPlayer")
	animation_player.seek(0, true)
	animation_player.play(altar_name)
	pass #animation_player.advance(0)
	
