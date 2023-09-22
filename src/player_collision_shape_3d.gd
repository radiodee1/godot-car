extends CharacterBody3D

#@onready var control_buttons = load("res://src/central_control.tscn")

#signal hole_to_maze
#signal hole_to_nextlevel
#signal remove_child(name)

var land_in_maze = false
var hit_high_altar = false

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity_mult = 9.8
var jump = 1.5

var cam_accel = 40
var mouse_sense = 0.1
var snap

var direction = Vector3()
#var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

@onready var head = $arm
@onready var camera = $arm/Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var control = $/root/CentralControl/Control
@onready var un_pause = $/root/CentralControl/Control/un_pause
@onready var start = $/root/CentralControl/Control/start
@onready var central = $/root/CentralControl

@onready var hud = $"/root/CentralControl/procedural-terrain/HUD"

@onready var gridmap = $"/root/CentralControl/procedural-terrain/GridMap"

@onready var car_script = $"../car"

var start_player: Vector3 = Vector3( 15 * 5 / 2, 5 * 5, 15 * 5 / 2)

var player_rotation = 0

var f_input
var h_input

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_collision_mask_value(1,true)
	set_collision_layer_value(1, true)
	self.collision_mask = 1
	self.collision_layer = 1
	#set_player_start(0, 0, 0)
	#restart_player()
	position = Vector3(15 * 5 / 2, 5 * 5 , 15 * 5 / 2)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	#get_node("/root/CentralControl").connect("restart_player", _on_central_control_restart_player)
	#get_tree().paused = true
	Global.set_score_allowed(true)

func _input(event):
	#get mouse input for camera rotation
	#if Global.player_status == Global.STATUS_CAR:
		#pass
		#return
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		#rotation.x = deg_to_rad(- event.relative.x * mouse_sense)
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))
	

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	
	camera.top_level = false #camera.set_as_toplevel(false)
	camera.global_transform = head.global_transform
	#global_transform = head.global_transform
	player_rotation = rotation.y

func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	
	#if Global.player_status != Global.STATUS_CAR:
	#f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	#h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Global.player_status != Global.STATUS_CAR:	
		f_input = Physics.f_input()
		h_input = Physics.h_input()

	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
		#print(Input.get_axis("move_backward", "move_forward") , ' axis') 
	
	check_joystick()
	check_escape()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	if Input.is_action_just_pressed("jump") and Global.player_status == Global.STATUS_CAR:
		## leave car
		Global.player_status = Global.STATUS_WALKING
		position = Vector3(car_script.position)
		position.x += 3
		position.y += 2
		car_script.leave_car()
		
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
		pass
	
	#make it move
	#if Global.player_status != Global.STATUS_CAR:
	velocity = velocity.lerp(direction * speed, accel * delta)
	velocity = velocity + gravity_vec
		
	#floor_snap_length = Vector3(float(movement), float(snap), float(0))
	if snap.y >= 0:
		floor_snap_length = snap.y
	else:
		floor_snap_length = 0
		#gravity = gravity_vec * gravity_mult
	
	var found_altars = Global.count_list_items(Global.items_temp, 'ALTAR')
	var found_nextlevels = Global.count_list_items(Global.items_temp, 'NEXTLEVEL')
	
	var found_landing_global = Global.count_list_items(Global.items_temp, 'SPOT')
	var found_altars_global = Global.count_list_items(Global.items_temp, 'ALTAR')
	
	#if found_altars_global > 0:
	#	print(found_altars_global, ' ', found_landing_global, ' end' )
	
	
	if found_altars_global > 0 and found_landing_global == 0 and Global.player_status == Global.STATUS_WALKING:
		check_landing(delta)
		check_collision()
		move_and_slide()
		return
	
	if position.y < -1 and  is_on_floor() and not land_in_maze and not hit_high_altar:
		hud.set_text_stat("maze")
		hud.set_text_msg('maze', 0)
							
		#get_tree().quit()
		#control_show()
		#un_pause.hide()
		#_on_central_control_restart_player()
		land_in_maze = true
		print("here we are...")
		pass
			
	
	elif position.y < -500 : ## 2500
		print(position.y, " <<< endless fall")
		#get_tree().change_scene_to_packed(control_buttons)	
		hud.set_text_msg("start", 3)
		
		if found_nextlevels <= 0 or found_altars <= 0:
			Global.lower_all_health()
			Global.set_lives(Global.lives - 1)
			if  found_nextlevels <= 0 : # Global.is_end_game():
				Global.clear_score_lives_health()
				#central._do_lose_game()
				#end_game()
				pass
			else:
				Global.reset_health()
				return
			
			
			central._do_lose_game()			
			end_game()
		pass
		
	
	check_collision()
	move_and_slide()
	
	
func check_joystick():
	if Global.player_status == Global.STATUS_CAR:
		pass
		#return
		
	var stick_left = Input.get_action_strength("stick_left")
	var stick_right = Input.get_action_strength("stick_right")
	var stick_up = Input.get_action_strength("stick_up")
	var stick_down = Input.get_action_strength("stick_down")
	#print(stick_down, ' ' , stick_up)
	rotate_y(- (stick_right - stick_left) * deg_to_rad(2))
	head.rotate_x((stick_down - stick_up) * deg_to_rad(1) )
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-69), deg_to_rad(69))
	pass 
	
func check_escape():
	## temporary game stop ##
	var escape = Input.get_action_strength("escape")
	if escape >= .5:
		#add_child(control.instantiate())
		#get_tree().change_scene_to_file("/root/CentralControl/Control")
		start.text = 'NEW-GAME'
		control_show()

func control_show():
	control.show()
	get_tree().paused = true
	#print("also here ", get_tree().paused)
	un_pause.show()
	un_pause.visible = true 
	un_pause.disabled = false
	un_pause.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	pass
	
func check_landing(delta):
	var spot = gridmap.get_placed_node("SPOT")
	#print('spot ', spot)
	if spot != null:
		var instance = spot['instance']
		var point = instance.transform.origin
		velocity = point - transform.origin
		velocity = velocity.normalized() * speed * delta * 50
		#print(point, ' point ', velocity, ' velocity')
		#end_game()
	pass
	
func check_collision():
	#Global.set_score_allowed(true)
	var try = 0
	
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
	
		if collision != null and collision.get_collider() != null:
			#Global.set_score_allowed(true)
			
			if collision.get_collider().is_in_group("mob") :
				
				var key_items_placed = Global.count_list_items(Global.placed_items, "KEY")
				var key_items_found = Global.count_list_items(Global.items_temp, "KEY")
				var nextlevel_item_count = Global.count_list_items(Global.placed_items, 'NEXTLEVEL')
				
				#print(collision.get_collider().name)			
				if collision.get_collider().name.begins_with('ALTAR') and try == 0:
					
					hud.set_text_stat("maze")
					
					Global.add_to_items('ALTAR')
					Global.add_to_items_temp('ALTAR')
					Global.add_to_score(30)
					
					hit_high_altar = true
					gridmap.remove_named_child(collision.get_collider().name)
					gridmap.hole_to_maze()
					
					try = 1 
					
					
				if collision.get_collider().name.begins_with("NEXTLEVEL") :
					#Global.items_temp.append("NEXTLEVEL")
					#Global.add_to_items_temp("NEXTLEVEL")
					
					if key_items_found >= key_items_placed and try == 0:
						Global.level += 1
						Global.add_to_score(50)
						Global.do_nextlevel_transition = true
						
						#hit_high_altar = false
						gridmap.remove_named_child(collision.get_collider().name, true)
						
						hud.set_text_msg('hill')
						hud.set_text_stat("hill")
						#hole_to_nextlevel.emit()
						#gridmap.hole_to_nextlevel()	
						Global.add_to_items_temp('NEXTLEVEL')
						#hud.set_text_msg('hill')
						#hud.set_text_stat("hill")
						set_player_start(15 * 5 / 2, 100, 15 * 5 / 2)
						timer_to_nextlevel()
						
						try = 1
					
						
				if collision.get_collider().name.begins_with("KEY"): 
					var hash = collision.get_collider().name.substr(len("KEY")+ 1, -1)
					print("hash = ", hash)
					
					Global.add_to_items_temp(str(collision.get_collider().name))
					Global.add_to_score(30)
					
					hud.set_text_stat("maze")					
					
					gridmap.remove_named_child(collision.get_collider().name, true)
					#remove_child.emit(collision.get_collider().name)
					#Global.print_maze_data()
					
					if key_items_found >= key_items_placed - 1: ## new key was just found!!
						hud.set_text_msg('keys', 1)
						
						if nextlevel_item_count == 0 and try == 0:
							
							Global.level += 1
							#Global.add_to_score(10)
							Global.do_nextlevel_transition = true
							#Global.add_to_score(30)
							#hit_high_altar = false
							
							hud.set_text_msg('hill')
							hud.set_text_stat("hill")
							#hole_to_nextlevel.emit()

							set_player_start(5, 100, 5)
							#gridmap.hole_to_nextlevel()	
														
							timer_to_nextlevel()
							try = 1
								
						
				if collision.get_collider().name.begins_with("PATROL"): 
					var hash = collision.get_collider().name.substr(len("PATROL")+ 1, -1)
					print("hash = ", hash)
					

					if collision.get_collider().can_die == false:
						#Global.lower_health(Global.health + 1)
						Global.lower_all_health()
						if Global.is_end_life():
							Global.set_lives(Global.lives - 1)
							Global.reset_health()
						central._do_lose_life()
						hud.set_text_msg('maze', 1)
						
						if Global.is_end_game():
							Global.clear_score_lives_health()
							central._do_lose_game()
							end_game()
							pass	
						
					if collision.get_collider().can_die == true:
						gridmap.remove_named_child(str(collision.get_collider().name), true)
						Global.add_to_score(40)
						
					hud.set_text_stat("maze")	
					
					if  try == 0:
						#hud.set_text_msg('maze', 1)	
						try = 1
								
				if collision.get_collider().name.begins_with("DOT"): 
					if try == 0:
					
						if 1 <= Global.count_list_items(Global.items_temp, str(collision.get_collider().name)):
							try = 1
							break
						
						var hash = collision.get_collider().name.substr(len("DOT") + 1, -1)
						print("hash = ", hash, ' ', collision.get_collider().name)
						
						Global.add_to_items_temp(str(collision.get_collider().name))
						Global.add_to_score(30)
							
						hud.set_text_stat("maze")	
						gridmap.remove_named_child(str(collision.get_collider().name), false)
					
						hud.set_text_msg('maze', 2)	
						
						disable_patrol(hash)
						
						try = 1
								
				if collision.get_collider().name.begins_with("SPOT"): 
					if try == 0:
						
						var hash = collision.get_collider().name.substr(len("SPOT") + 1, -1)
						print("SPOT hash = ", hash, ' ', collision.get_collider().name)
						
						Global.add_to_items_temp(str(collision.get_collider().name))
						Global.add_to_items(str(collision.get_collider().name))
						Global.add_to_score(30)
							
						hud.set_text_stat("keys")	
						gridmap.remove_named_child(str(collision.get_collider().name), false)
						
						try = 1		
										
				if collision.get_collider().name.to_lower().begins_with("car") and Global.player_status == Global.STATUS_WALKING: 
					if try == 0:
						
						#var hash = collision.get_collider().name.substr(len("SPOT") + 1, -1)
						#print("CAR ", collision.get_collider().name)
						Global.player_status = Global.STATUS_CAR
						car_script.enter_car()
						
						try = 1	
						
						
func timer_to_nextlevel(t=2):
	gridmap.hole_to_nextlevel()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	#central._do_nextlevel()
	#Global.do_nextlevel_transition = false
	hud.set_text_msg('start', 0)
	
	var timer = Timer.new()
	timer.connect("timeout", timer_on_nextlevel)
	timer.wait_time = t 
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
func timer_on_nextlevel():
	set_player_start(5, 100, 5)
	central._do_nextlevel()
	#gridmap.hole_to_nextlevel()
	gridmap.restart_terrain()
	restart_player()
	hud.set_text_msg('start', 0)
	Global.items_temp = []
	pass
	
func end_game():
	set_player_start(5, 100, 5)
	control_show()
	un_pause.hide()
	start.grab_focus()
	restart_player()
	### put something splashy here!!
	pass
	
func disable_patrol(dot_hash:String):
	var count = dot_hash.get_slice_count('-')
	if count >= 2:
		var h1 = dot_hash.get_slice('-', 0)
		var h2 = dot_hash.get_slice('-', 1)
		var name = 'DOT-' + h1 + '-' + h2 + '-'
		var num = Global.count_list_items(Global.placed_items, name)
		var collect = Global.count_list_items(Global.items_temp, name)
		#print(name, ' dotname ', str(num), ' num ', str(collect), ' collected')
		if num / 2 > collect :
			return
		var patrol = 'PATROL-' + h1 + '-' + h2
		var instance = gridmap.get_placed_node(patrol)
		if instance == null:
			return
		instance['instance'].set_green()
	pass
	
func restart_player():
	position = Vector3(start_player.x , start_player.y , start_player.z)
	pass

func set_player_start(x,y,z):
	land_in_maze = false
	hit_high_altar = false
	start_player = Vector3( x, y, z)
	#start_player = Vector3(15 * 5 / 2 + 5, 25, 15 * 5 / 2 + 5 )
	
func get_player_rotation():
	return player_rotation

func get_player_position():
	return position

