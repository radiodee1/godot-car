extends Control

@onready var btn_start = $Control/start 
@onready var btn_quit = $Control/quit
@onready var btn_unpause = $Control/un_pause
@onready var control_buttons = $Control

@onready var terrain = $"procedural-terrain"
#@onready var start_scene = load("res://src/procedural_terrain.tscn")

#@onready var first_run = true



# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	btn_start.pressed.connect(self._do_start)
	btn_quit.pressed.connect(self._do_quit)
	btn_unpause.pressed.connect(self._do_unpause)
	btn_unpause.disabled = true
	btn_unpause.visible = false
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_tree().paused = true 	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _do_start():
	print("start")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	#control_buttons.queue_free()
	#add_child(start_scene.instantiate())
	#process_mode = Node.PROCESS_MODE_DISABLED
	#get_tree().paused = false
	
	control_buttons.hide()
	
func _do_quit():
	print("quit")
	get_tree().quit()
	
func _do_unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#if get_tree().paused == true:
	#process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false
	control_buttons.hide()
	#control_buttons.queue_free()
	#central.queue_free()
	control_buttons.visible = false
	#control_buttons.hide()
	print("unpause")
