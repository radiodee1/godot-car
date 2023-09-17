extends Control

@onready var btn_start = $Control/start 
@onready var btn_quit = $Control/quit
@onready var btn_unpause = $Control/un_pause
@onready var control_buttons = $Control

@onready var terrain = $"procedural-terrain"
@onready var start_scene = load("res://src/procedural_terrain.tscn")

@onready var hud = $"procedural-terrain/HUD"
@onready var gridmap = $"procedural-terrain/GridMap"
@onready var player = $"procedural-terrain/CharacterBody3D"


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
	#terrain.free()
	#terrain.request_ready()
	#Global.level = 0
	Global.clear_score_lives_health()
	
	hud.set_text_stat("hill")
	#restart_terrain.emit()
	gridmap.restart_terrain()
	#restart_player.emit()
	player.restart_player()
	#get_node("procedural-terrain/GridMap").queue_free()
	#get_node("procedural-terrain").add_child(get_node('procedural-terrain/GridMap') )
	#get_node("procedural-terrain/GridMap").request_ready()
	#print_tree_pretty()
	control_buttons.hide()
	
func _do_quit():
	print("quit")
	get_tree().quit()
	
func _do_unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#if get_tree().paused == true:
	#process_mode = Node.PROCESS_MODE_INHERIT
	btn_start.show()
	get_tree().paused = false
	control_buttons.hide()
	#control_buttons.queue_free()
	#central.queue_free()
	control_buttons.visible = false
	#control_buttons.hide()
	print("unpause")

func _do_nextlevel():
	btn_start.hide()
	btn_unpause.show()
	btn_unpause.grab_focus()
	get_tree().paused = true
	
	hud.set_text_stat("hill")
	
	#restart_terrain.emit()
	
	#gridmap.restart_terrain() ## <--- ??
	
	#restart_player.emit()
	player.restart_player()
	control_buttons.show()
	control_buttons.visible = true 
	btn_unpause.visible = true
	btn_unpause.disabled = false

func _do_lose_life():
	#$"Control/canvas/splash/text_die".process_mode = Node.PROCESS_MODE_ALWAYS
	$"Control/canvas/splash/text_die".show()
	
	var timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.connect("timeout", _un_show_sprite )
	timer.wait_time = 2
	timer.one_shot = true
	add_child(timer)
	timer.start()
	pass 
	
func _do_lose_game():
	#$"Control/canvas/splash/text_endgame".process_mode = Node.PROCESS_MODE_ALWAYS
	$"Control/canvas/splash/text_endgame".show()
	
	var timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.connect("timeout", _un_show_sprite )
	timer.wait_time = 2
	timer.one_shot = true
	add_child(timer)
	timer.start()
	hud.set_text_msg("start", 0)
	pass  

func _un_show_sprite():
	$"Control/canvas/splash/text_die".hide()
	$"Control/canvas/splash/text_endgame".hide()
