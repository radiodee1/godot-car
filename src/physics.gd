extends Node3D #CharacterBody3D

func f_input():
	if Global.player_status == Global.STATUS_CAR:
		return Input.get_axis("move_backward", "move_forward")
	else: 
		return Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	
func h_input():
	if Global.player_status == Global.STATUS_CAR:
		return Input.get_axis("move_right", "move_left")
	else: 
		return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
