extends StaticBody3D

var mod_xnum =  0.7 
var mod_znum =  0.7

var floor_num = 4 

var table = {
		Vector2(1, 0): [deg_to_rad(90), Vector2(mod_xnum,0)],            #left#1  wrong:90  correct: !!! 
		Vector2(0,-1): [deg_to_rad(180),   Vector2(0, - mod_znum  ) ], # right#0 wrong:  270
		Vector2(-1,0): [deg_to_rad(270), Vector2( - mod_xnum  , 0)], # :  wrong: 0 
		Vector2(0, 1): [deg_to_rad(0),  Vector2(0, mod_znum)]          #pair  wrong: 0 correct: 270
	}


@export var test_alone = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#print("zz ramp insert ", global_transform.origin)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(v, map, location,  namex='RAMP', group='mob'):
	var scale_local = 1 
	v.y += -3.45
	 
	#var j = load("res://src/gator_walk.tscn").instantiate()
	var loc = Vector2(location.x, location.z)

	self.scale_object_local(Vector3(scale_local, scale_local ,scale_local))
	
	self.add_to_group(group)
	
	self.name = namex 
	
	self.collision_mask = 1
	self.collision_layer = 1

	if test_alone:
		return
	v *= 0.5 	
	#self.translate(v)
	
	var num = 0 
	for i in table.keys():
		num += 1 
		var xx = map[loc.x + i.x ][loc.y + i.y ]
		if xx == floor_num : #and ll == -1 :
			var j = table[i][1]
			var xmod = j.x 
			var zmod = j.y  
			v.x += xmod
			v.z += zmod
			global_transform.origin = v 
			rotate_y(table[i][0])
			print('-- v | ',  ' num ', num, ' ', i, ' x ', xmod, ' z ', zmod, ' ', map[loc.x][loc.y], ' ', loc) # FINETUNE RAMP PLACEMENT!!
			break
		if num > 5:
			break
	#global_transform.origin.y -= 0.25

