extends Node3D #CharacterBody3D

func f_input():
	var f 
	if Global.player_status == Global.STATUS_CAR:
		f = Input.get_axis("move_backward", "move_forward")
	else: 
		f = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	print('forward ', f)
	return f
	
func h_input():
	var h
	if Global.player_status == Global.STATUS_CAR:
		h = Input.get_axis("move_right", "move_left")
	else: 
		h = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	print('left-right ', h)
	return h
