extends Control

@onready var text_msg = $Control/message
@onready var text_stat = $Control/status

@onready var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	text_msg.text = "Hi."
	text_stat.text = "Start"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_text_msg(group='start', msg=0):
	pass 
	
func set_text_stat(msg='start'):
	pass 
