extends Control

@onready var text_msg = $Control/message
@onready var text_stat = $Control/status

@onready var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#text_msg.text = "Hi."
	set_text_msg('start', 0)
	
	#text_stat.text = "Start"
	set_text_stat('hill')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_text_msg(group='start', msg=0):
	text_msg.text = dict.message[group][msg]
	pass 
	
func set_text_stat(msg='start'):
	var line = ""
	line += "Level: " + str(Global.level) + " - "
	if msg == 'start':
		line += 'start'
	if msg == "hill":
		line += 'objective: high altar'
	if msg == "maze":
		line += 'Keys :' + str(Global.count_list_items(Global.items_temp, 'KEY')) 
		line += "/" + str(Global.count_list_items(Global.placed_items, "KEY"))
	
	text_stat.text = line
