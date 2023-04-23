extends Resource

var game = {
	'level': [
		{
			'name': 'starters',
			'elements': {
				'hill': {
					'width': 0,
					'height': 0,
					'depth': 0,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 0,
					'includes': ['ALTAR', 'TRAPDOOR']
				},
				'maze': {
					'width': 0,
					'height': 0,
					'depth': 0,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 0,
					'endpoints': 7,
					'includes': ['ALTAR', 'TRAPDOOR', 'KEY']
				}
			}
		},
		{
			'name': 'midway',
			'elements': {
				'hill': {
					'width': 0,
					'height': 0,
					'depth': 0,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 0,
					'includes': ['ALTAR', 'TRAPDOOR']
				},
				'maze': {
					'width': 0,
					'height': 0,
					'depth': 0,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 0,
					'endpoints': 10,
					'includes': ['ALTAR', 'TRAPDOOR', 'KEY']
				}
			}
		},
		{
			'name': 'difficult',
			'elements': {
				'hill': {
					'width': 0,
					'height': 0,
					'depth': 0,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 0,
					'includes': ['ALTAR', 'TRAPDOOR']
				},
				'maze': {
					'width': 0,
					'height': 0,
					'depth': 0,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 0,
					'endpoints': 10,
					'includes': ['ALTAR', 'TRAPDOOR', 'KEY']
				}
			}
		}
	]
	
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
