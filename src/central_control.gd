extends Control

@onready var btn_start = $Control/start 
@onready var btn_quit = $Control/quit
@onready var btn_unpause = $Control/un_pause
@onready var control_buttons = $Control

@onready var start_scene = load("res://src/procedural_terrain.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	btn_start.pressed.connect(self._do_start)
	btn_quit.pressed.connect(self._do_quit)
	btn_unpause.pressed.connect(self._do_unpause)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _do_start():
	print("start")
	control_buttons.queue_free()
	add_child(start_scene.instantiate())
	
func _do_quit():
	print("quit")
	get_tree().quit()
	
func _do_unpause():
	print("unpause")
