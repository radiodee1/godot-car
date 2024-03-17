extends Control

@onready var text_msg = $Control/message
@onready var text_stat = $Control/status

var old_msg = ''
var timer = null

@onready var dict = preload("res://src/GridMap-dict.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#text_msg.text = "Hi."
	set_text_msg('start', 0)
	
	#text_stat.text = "Start"
	set_text_stat('hill')

	process_mode = Node.PROCESS_MODE_ALWAYS
	timer = Timer.new()
	timer.autostart = false
	add_child(timer)
	timer.wait_time = 1 
	timer.name = 'Timer-HUD'
	timer.start()
	timer.one_shot = false
	timer.connect('timeout', _on_timer_timeout)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_text_msg(group='start', msg=0, time_me=false, wait_time=40):
	if time_me:
		if timer.is_stopped() == true: # timer.time_left != wait_time:
			timer = Timer.new()
			timer.autostart = true
			timer.process_mode = Node.PROCESS_MODE_ALWAYS 
			#add_child(timer)
			#timer.wait_time = 1 
			timer.name = 'Timer-HUD'
			#timer.start()
			timer.one_shot = true 
			timer.set_timer_process_callback(Timer.TIMER_PROCESS_IDLE)
			#timer.connect('timeout', _on_timer_timeout)
		if old_msg == '' and  text_msg.text != '': # dict.message[group][msg]:
			old_msg = text_msg.text 
			timer.start(wait_time)
			#add_child(timer)
	text_msg.text = dict.message[group][msg]

func _on_timer_timeout():
	if old_msg != '': # text_msg.text:
		text_msg.text = old_msg
		old_msg = ''

	
func set_text_stat(msg='start'):
	var line = ""
	line += "Level: " + str(Global.level + 1) + " - "
	line += "Score: " + str(Global.score) + " - "
	line += "Health: " + str(Global.health) + " - "
	line += "Lives: " + str(Global.lives) + " - "
	if msg == 'start':
		line += 'start'
	if msg == "hill":
		line += 'objective: high altar'
	if msg == "maze":
		line += 'Keys :' + str(Global.count_list_items(Global.items_temp, 'KEY', true)) 
		line += "/" + str(Global.count_list_items(Global.placed_items, "KEY", true))
	
	text_stat.text = line
