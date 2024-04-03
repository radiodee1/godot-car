extends StaticBody3D

var table = {
		Vector2(1, 0): deg_to_rad(0 + 90),
		Vector2(0,-1): deg_to_rad(90 + 90),
		Vector2(-1,0): deg_to_rad(180 + 90),
		Vector2(0, 1): deg_to_rad(270 + 90)
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
	v.y += -3.0 
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
	global_transform.origin = v 

	for i in table.keys():
		var xx = map[loc.x + i.x][loc.y + i.y]
		if xx == -1:
			rotate_y(table[i])
			break

	#global_transform.origin.y -= 0.25

