extends Resource

var placed = []

var scale_local = 0.5
var add_child: Callable
var set_cell_item: Callable
var get_cell_item: Callable
var remove_child: Callable

var mesh_instance_3d
var box_shape
var box_mesh
var static_body

var scene_instance

var rubble_instance = null


var low_mesh_instance_3d
var low_box_shape
var low_box_mesh
var low_static_body
var low_collision_shape

var low_scene_instance

var low_location_vec
#var dict = preload("res://src/GridMap-dict.gd").new()

func place_high_rubble(v):
	var vv = Vector3(v)
	if rubble_instance == null:
		rubble_instance = preload("res://src/rubble.tscn").instantiate()
		add_child.call(rubble_instance)
	vv.y = -4
	rubble_instance.set_translate(vv, true)

func place_low_rubble():
	var ll = Vector3(low_location_vec)
	if rubble_instance == null:
		return
	rubble_instance.set_translate(ll, true)

func place_key_rubble(v):
	var vv = Vector3(v)
	if rubble_instance == null:
		return
	rubble_instance.set_lifetime(3)
	rubble_instance.set_translate(vv) 

func emit_rubble():
	if rubble_instance == null:
		return
	rubble_instance.set_emitting(true)
	
func stop_emit_rubble():
	if rubble_instance == null:
		return
	rubble_instance.set_emitting(false)

func place_landing_spot(v, name='SPOT', group='mob'):
	name = name + Global.g_hash()
	var spot_instance = preload("res://src/landing_spot.tscn").instantiate()
	v.x *= .5
	v.y *= .5
	v.z *= .5
	spot_instance.init(v, name, group)
	add_child.call(spot_instance)
	#spot_instance.translate(v)
	spot_instance.name = name
	add_to_placed(spot_instance, true)
	
func remove_landing_spot():
	dequeue_placed_node('SPOT', false)
	pass

func place_altar(v, name='ALTAR', group='mob'):
	name = name + Global.g_hash()
	scene_instance = preload("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	v.x *= .5
	v.y *= .5
	v.z *= .5
	add_child.call(scene_instance)
	#scene_instance.scale = Vector3(1,1,1)
	scene_instance.translate(v)
	scene_instance.name = name
	#print(v, " vector")
	box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5,0.5,0.5)
	
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	static_body = StaticBody3D.new()
	static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group(group)
	collision_shape.name = name
	collision_shape.shape = box_shape
	collision_shape.disabled = false
	static_body.add_child(collision_shape)
	static_body.add_to_group(group)
	static_body.name = name
	static_body.set_collision_layer_value(1, true)
	static_body.set_collision_mask_value(1, true)
	scene_instance.add_child(static_body) 
	scene_instance.add_to_group(group)
	scene_instance.name = name
	
	add_to_placed(scene_instance, true, true)
	#static_body.layers = 1
	
	static_body.collision_mask = 1
	static_body.collision_layer = 1

func remove_altar():
	if scene_instance != null:
		#scene_instance.queue_free()
		remove_child.call(scene_instance)
		scene_instance = null
		print('altar removed.')
	
	if mesh_instance_3d != null:
		mesh_instance_3d.queue_free()
		box_mesh = null #.free()
		box_shape = null #.free()
		static_body = null
		#collision_shape.queue_free()



func place_low_altar(v, xname='NEXTLEVEL', group='mob'):
	xname = xname + Global.g_hash()
	
	low_location_vec = v 
	low_scene_instance = preload("res://src/altar_moving.tscn").instantiate()
	#scene_instance = load_scene
	v.x *= .5
	v.y *= .5
	v.z *= .5
	#scene_instance.scale = Vector3(1,1,1)
	low_scene_instance.translate(v)
	low_scene_instance.name = xname
	#print(v, " vector")
	low_box_shape = BoxShape3D.new()
	low_box_shape.size = Vector3(0.5,0.5,0.5)
	
	#mesh_instance_3d.mesh = box_mesh
	#scene_instance.add_to_group(group)
	low_scene_instance.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	#add_child.call(mesh_instance_3d)
	#mesh_instance_3d.translate(v) 
	low_static_body = StaticBody3D.new()
	low_static_body.scale_object_local(Vector3(1,1,1))
	var collision_shape = CollisionShape3D.new()
	collision_shape.scale_object_local(Vector3(1,1,1))
	collision_shape.add_to_group(group)
	collision_shape.name = xname
	collision_shape.shape = low_box_shape
	collision_shape.disabled = false
	low_static_body.add_child(collision_shape)
	low_static_body.add_to_group(group)
	low_static_body.name = xname
	low_static_body.set_collision_layer_value(1, true)
	low_static_body.set_collision_mask_value(1, true)
	low_scene_instance.add_child(low_static_body) 
	low_scene_instance.add_to_group(group)

	add_to_placed(low_scene_instance, true, true)
	
	low_static_body.collision_mask = 1
	low_static_body.collision_layer = 1
	add_child.call(low_scene_instance)
	
	return

func remove_low_altar():
	if low_scene_instance != null:
		remove_child.call(low_scene_instance)
	if low_scene_instance != null:
		low_scene_instance.queue_free()
		low_scene_instance = null
		print('low altar removed.')
		
	if low_mesh_instance_3d != null:
		low_mesh_instance_3d.queue_free()
		low_box_mesh = null #.free()
		low_box_shape = null #.free()
		low_static_body = null
		#collision_shape.queue_free()

func place_altar_key(v: Vector3, description: String):
	description = description + Global.g_hash()
	if Global.count_list_items(Global.placed_items, 'NEXTLEVEL', true) == 0:
		low_location_vec = Vector3(v)
		
	var altar_w_key = preload("res://src/altar_key_moving.tscn")
	var altar_key = altar_w_key.instantiate()
	altar_key.init(v, description)
	
	add_child.call(altar_key)
	add_to_placed(altar_key, true, true)
	#print(v, ' vec3 ', Global.intersections)
	pass
	

func place_patrol(v_list, description: String):
	description = description + Global.g_hash()
	var patrol = load("res://src/patrol.tscn")
	var patrol_instance = patrol.instantiate()
	patrol_instance.init(v_list[0], description)
	patrol_instance.set_path(v_list)
	add_child.call(patrol_instance)
	add_to_placed(patrol_instance)
	#print(v, ' vec3 ', Global.intersections)
	pass
	
func place_dot(v, description: String):
	description = description + Global.g_hash()
	var dot = preload("res://src/patrol_dot.tscn")
	var instance_dot = dot.instantiate()
	instance_dot.init(v, description)
	
	add_child.call(instance_dot)
	add_to_placed(instance_dot, true)
	#print(v, ' vec3 ', Global.intersections)

func place_gate(v, v_back, v_aux, description: String):
	description = description + Global.g_hash()
	var gate = preload("res://src/gate.tscn")
	var instance_gate = gate.instantiate()
	instance_gate.init(v, description)
	instance_gate.scale = v_back
	instance_gate.rotation = v_aux

	add_child.call(instance_gate)
	add_to_placed(instance_gate, true)
	print('shape/node', v, ' ', v_back)
	
func place_car():
	#if hash(get_placed_node('car')) == hash(null):	
	if Global.count_list_items(Global.placed_items, 'car') == 0 :
		var car = preload("res://src/car.tscn")
		var instance_car = car.instantiate()
		
		instance_car.name = instance_car.name + Global.g_hash()
		#Global.placed_items.append('car')
		add_child.call(instance_car)
		add_to_placed(instance_car, true, true)
		instance_car.init('car' + Global.g_hash())
	else:
		var car = get_placed_node('car')
		
		#add_child.call(car)
		#add_to_placed(car, true)
		car['instance'].init('car' + Global.g_hash())
	

func make_hole_to_maze(highest, group_size=5, remove_type=[4], print_output=false):
	Global.set_score_allowed(true)
	var UPPER = remove_type
	var LOWER = 1
	var size = group_size
	var xz_size = 5  # 3
	var xz_size_half = xz_size / 2
	var increment = sign(highest.y)
	for i in range( - (highest.y * size + size),  (highest.y ) * size + size, increment):
		for x in range(highest.x - xz_size_half - 1, highest.x + xz_size - xz_size_half):
			for z in range(highest.z - xz_size_half - 1, highest.z + xz_size - xz_size_half):
				pass
				var xx = x 
				var zz = z 
				var type = get_cell_item.call(Vector3(xx , i , zz)) ##<-- Vector3
				if print_output: print(type, ' type')
				if type in UPPER :	
					set_cell_item.call(Vector3(xx, i, zz), -1)
					

func make_hole_to_nextlevel(group_size=5, remove_type=[1]):
	var ll = Vector3(low_location_vec)
	make_hole_to_maze(ll, group_size, remove_type)
	#stop_emit_rubble()


func get_intersection(num, exact=true, skip_record_index=-1):
	#var intersections = Global.intersections
	print(Global.intersections, ' intersections')
	var out = -1
	var index = -1
	var tot = -1
	
	if skip_record_index != -1 and  Global.intersections.has(skip_record_index):
		Global.intersections[skip_record_index] = 0
	
	for i in Global.intersections.keys():
		
		if i == skip_record_index:
			
			continue
		if Global.intersections[i] == num and num != 0 and exact:
			out = i 
			Global.intersections[i] = 0
			print(out)
			return out
		if Global.intersections[i] <= num and Global.intersections[i] != 0 :
			if tot < Global.intersections[i] and num != 0 and not exact:
				if Global.group_visited.has(i):
					tot = Global.intersections[i]
					out = i #intersections[i]
					index = i
					#print(i, ' ' , out, ' ', index, ' ' , intersections)
					Global.intersections[i] = 0
					return out 	
	return out 
	
func get_segment():
	var seg = []
	var len = 0
	var key = null
	for i in Global.segments:
		if i['type'] == 'empty':
			if len < i['length']:
				len = i['length']
				seg = i['segment']
				key = i
	if key != null:
		key['type'] = "patrol"
	return seg
	
	
func clear_placed():
	for i in placed:
		if i['instance'] != null:
			#i['instance'].queue_free()
			remove_child.call(i['instance'])
	placed = []
	
func add_to_placed(instance, add_global=false, skip_check=false):
	for i in placed:
		if str(i['name']).begins_with(str(instance.name)): # == str(instance.name):
			#print('bad i ', str(instance.name))
			return
	
	var d = {
		'instance': instance,
		'name': str(instance.name),
		'status': 'NEW'
	}
	placed.append(d)
	
	if not add_global:
		return
		
	for i in Global.placed_items:
		if i.begins_with(str(instance.name)) and not skip_check: # == str(instance.name):
			return
	Global.placed_items.append(str(instance.name))

func get_placed_node(name):
	var out = null
	for i in placed:
		if i['name'].begins_with(name) and is_instance_valid(i['instance']): 
			out = i
			return out
	return out

func dequeue_placed_node(name, animate=false, erase_global=false):
	#print('before ', placed)
	var found = false
	var x 
	x = get_placed_node(name)
	if x != null:
		var v = Vector3(x['instance'].position)
		remove_child.call(x['instance'])
		#x['instance'].queue_free()
		x['status'] = 'CANCEL'
		placed.erase(x)
		
		if animate and name.ends_with(Global.g_hash()):
			place_key_rubble(v)
			emit_rubble()
			print('spot key rubble... ', name)
		found = true
	if not erase_global:
		return found
	if name in Global.placed_items:
		Global.placed_items.erase(name)
		#print("erased ", name)
	return found
	#print('after ', placed)

func place_object(name, strategy, layer, frame_num, vector_high=Vector3(0,0,0), vector_back=Vector3(0,0,0), vector_aux=Vector3(0,0,0)):
	
	if layer == "HILL":
		if name == 'ALTAR':
			var hh = Vector3(vector_high)
			var hhh = Vector3(vector_high)
			hh.x += 1
			hh.y += scale_local * 2.5
			hh.z += 1
			place_altar(hh)
			hhh.x += 2.5
			hhh.y = - 4.5
			hhh.z += 2.5
			place_landing_spot(hhh)
			#print(hh, " altar here.")
			pass
		if name == 'TRAPDOOR':
			pass
		if name == 'KEY':
			pass
		if name == 'PRISON':
			pass
		if name == 'NEXTLEVEL':
			pass
		if name.to_lower() == 'car':
			#print('car ', get_placed_node('car'))
			#if get_placed_node('car') != null:
				#dequeue_placed_node('car', false, true)
			#	pass
			place_car()
			pass 
	if layer == "MAZE":
		if name == 'ALTAR':
			pass
		if name == 'TRAPDOOR':
			pass
		if name.begins_with("KEY"):# == 'KEY':
			#print(name, ' here!!')
			place_altar_key(vector_high, name)
			pass
		if name == 'PRISON':
			pass
		if name == 'NEXTLEVEL':
			var hh = Vector3(vector_high)
			place_low_altar(hh, name)
			pass
		if name.begins_with("PATROL"):
			place_patrol(vector_high, name)
			pass
		if name.begins_with("DOT"):
			place_dot(vector_high, name)
			pass
		if name.begins_with("GATE"):
			place_gate(vector_high, vector_back, vector_aux, name)
			print('shape decoration placed')
			pass 
	pass


func set_callable(set_add: Callable):
	add_child = set_add

func set_callable_get_cell(set_get: Callable):
	get_cell_item = set_get 

func set_callable_set_cell(set_set: Callable):
	set_cell_item = set_set

func set_callable_remove_child(set_remove: Callable):
	remove_child = set_remove
