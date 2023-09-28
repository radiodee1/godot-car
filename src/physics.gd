extends Node3D #CharacterBody3D

@onready var start = $/root/CentralControl/Control/start 
@onready var player = $"/root/CentralControl/procedural-terrain/CharacterBody3D"


func check_escape():
	## temporary game stop ##
	var escape = Input.get_action_strength("escape")
	if escape >= .5:
		
		start.text = 'NEW-GAME'
		player.control_show()
