extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var maze = $"procedural_maze/GridMap-maze"
	maze.maze_generate()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
