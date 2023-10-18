extends Node3D

@onready var animation_player = $'gator_walk/AnimationPlayer'

var anim_foot = 'footAction'
var anim_foot_001 = 'foot_001Action'
var anim_foot_002 = 'foot_002Action'
var anim_foot_003 = 'foot_003Action'
var anim_walk = 'walk'

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play(anim_foot)
	#animation_player.play(anim_foot_001)
	#animation_player.play(anim_foot_002)
	#animation_player.play(anim_foot_003)
	#animation_player.play(anim_walk)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
