extends Node3D #CharacterBody3D

@onready var start = $/root/CentralControl/Control/start 
@onready var player = $"/root/CentralControl/procedural-terrain/CharacterBody3D"

func f_input():
	var f 
	if Global.player_status == Global.STATUS_CAR:
		f = Input.get_axis("move_backward", "move_forward")
	else: 
		var back = Input.get_action_strength("move_backward")
		var front = Input.get_action_strength("move_forward")
		f = back - front # Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		#Input.action_press("move_backward")
		#Input.action_press("move_forward")
	print('back-forward ', f)
	return f
	
func h_input():
	var h
	if Global.player_status == Global.STATUS_CAR:
		h = Input.get_axis("move_right", "move_left")
	else: 
		var right = Input.get_action_strength("move_right")
		var left = Input.get_action_strength("move_left")
		h = right - left # Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	print('right-left ', h)
	return h

func check_escape():
	## temporary game stop ##
	var escape = Input.get_action_strength("escape")
	if escape >= .5:
		
		start.text = 'NEW-GAME'
		player.control_show()
