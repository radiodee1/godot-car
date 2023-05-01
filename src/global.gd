extends Node

var health = 30
var score = 0
var items = []
var items_temp = []

var score_allowed = true
var do_nextlevel_transition = false

var level = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_to_items(name):
	if name not in items:
		items.append(name)
		
func  add_to_items_temp(name):
	if name not in items_temp:
		items_temp.append(name)

func add_to_score(num):
	if score_allowed:
		score += num
		score_allowed = false
		
func set_score_allowed(allowed=true):
	score_allowed = allowed
	
