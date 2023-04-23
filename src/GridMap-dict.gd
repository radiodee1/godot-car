extends Resource

var game = {
	'level': [
		{
			'name': 'starters',
			'elements': {
				'hill': {
					'width_x': 30,
					'height_z': 30,
					'depth_y': 30,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 2,
					'includes': ['ALTAR', 'TRAPDOOR']
				},
				'maze': {
					'width_x': 10,
					'height_z': 10,
					'depth_y': -6,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 1,
					'endpoints': 7,
					'includes': ['ALTAR', 'TRAPDOOR', 'KEY']
				},
				'player': {
					'x': 15 * 5 / 2,
					'y': 5 * 5 ,
					'z': 15 * 5 / 2
					
				}
			}
		},
		{
			'name': 'midway',
			'elements': {
				'hill': {
					'width_x': 30,
					'height_z': 30,
					'depth_y': 30,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 2,
					'includes': ['ALTAR', 'TRAPDOOR']
				},
				'maze': {
					'width_x': 10,
					'height_z': 10,
					'depth_y': -6,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 1,
					'endpoints': 10,
					'includes': ['ALTAR', 'TRAPDOOR', 'KEY', 'PRISON']
				},
				'player': {
					'x': 15 * 5 / 2,
					'y': 5 * 5 ,
					'z': 15 * 5 / 2
					
				}
			}
		},
		{
			'name': 'difficult',
			'elements': {
				'hill': {
					'width_x': 30,
					'height_z': 30,
					'depth_y': 30,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 2,
					'includes': ['ALTAR', 'TRAPDOOR']
				},
				'maze': {
					'width_x': 10,
					'height_z': 10,
					'depth_y': -6,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 1,
					'endpoints': 10,
					'includes': ['ALTAR', 'TRAPDOOR', 'KEY', 'PRISON']
				},
				'player': {
					'x': 15 * 5 / 2,
					'y': 5 * 5 ,
					'z': 15 * 5 / 2
					
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
