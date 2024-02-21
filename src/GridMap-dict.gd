extends Resource

var game = {
	'level': [
		{
			'name': 'starters',
			'elements': [
				{
					'type': 'hill',
					'width_x': 30,
					'height_z': 30,
					'depth_y': 30,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 4, ## 2
					'includes': ['ALTAR', 'CAR', 'GATORS']
				},
				{
					'type': 'maze',
					'width_x': 15,
					'height_z': 15,
					'depth_y': -6,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 1,
					'endpoints': 3 , #10,
					'multiplier': - 1,
					'includes': [ 'KEY', 'NEXTLEVEL', 'KEY', 'PRISON_A', 'PATROL' ] # 'PATROL'
				},
				{
					'type': 'player',
					'x': 15 * 5 / 2,
					'y': 5 * 5 * 4,
					'z': 15 * 5 / 2
					
				}
			] ## <--
		},
		{
			'name': 'midway',
			'elements': [
				{
					'type': 'hill',
					'width_x': 30,
					'height_z': 30,
					'depth_y': 30,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 4,
					'includes': ['ALTAR', 'CAR', 'GATORS']
				},
				{
					'type': 'maze',
					'width_x': 15,
					'height_z': 15,
					'depth_y': -6,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 1,
					'endpoints': 3,
					'multiplier': 1.5,
					'includes': [ 'KEY', 'PRISON_A', 'NEXTLEVEL', 'KEY', 'PATROL']
				},
				{
					'type': 'player',
					'x': 15 * 5 / 2,
					'y': 5 * 5 * 4,
					'z': 15 * 5 / 2
					
				}
			] ##<--
		},
		{
			'name': 'difficult',
			'elements': [
				{
					'type': 'hill',
					'width_x': 30,
					'height_z': 30,
					'depth_y': 30,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 4,
					'includes': ['ALTAR', 'CAR', 'GATORS']
				},
				{
					'type': 'maze',
					'width_x': 15,
					'height_z': 15,
					'depth_y': -6,
					'x': 0,
					'y': 0,
					'z': 0,
					'mesh': 1,
					'endpoints': 3, #10,
					'multiplier': 1.5,
					'includes': [ 'KEY', 'PRISON_A', 'NEXTLEVEL', 'PATROL'] #, 'PRISON']
				},
				{
					'type': 'player',
					'x': 15 * 5 / 2,
					'y': 5 * 5 * 4,
					'z': 15 * 5 / 2
					
				}
			] ## <--
		}
	]
	
}


var shapes = {
	'mesh': [
		0,
		
		1,
		1,

		1,
		1,

		1,
		1 
	],
	'layout': [
		[],
		[Vector2(1,0), Vector2(1,1), Vector2(1,2), Vector2(1,3), Vector2(0,0), Vector2(0,2), Vector2(2,1)],
		[Vector2(1,0), Vector2(1,1), Vector2(1,2), Vector2(2,0), Vector2(2,2), Vector2(0,1), Vector2(1,3)],

		[Vector2(0,1), Vector2(0,2), Vector2(1,0), Vector2(1,1), Vector2(2,1), Vector2(2,2), Vector2(3,1)],
		[Vector2(0,0), Vector2(0,1), Vector2(1,1), Vector2(1,2), Vector2(2,0), Vector2(2,1), Vector2(3,1)],
		
		[Vector2(0,1), Vector2(1,1), Vector2(1,2), Vector2(2,0), Vector2(2,1), Vector2(3,1), Vector2(3,2)],
		[Vector2(0,1), Vector2(1,0), Vector2(1,1), Vector2(2,1), Vector2(2,2), Vector2(3,0), Vector2(3,1)]
	],
	'start': [
		[Vector2(-1,-1), Vector2(-1,-1)],
		[Vector2(1,-1), Vector2(1,-2)],
		[Vector2(1,-1), Vector2(1,-2)],
		
		[Vector2(-1,1), Vector2(-2,1)],
		[Vector2(-1,1), Vector2(-2,1)],
		
		[Vector2(4,1), Vector2(5,1)],
		[Vector2(4,1), Vector2(5,1)]
	],
	'end': [
		[Vector2(-1,-1)],
		[Vector2(-1,-4)], ## Vector2(1,4)
		[Vector2(-1,-4)],
		
		[Vector2(-4,-1)],
		[Vector2(-4,-1)],
		
		[Vector2(-1,-1)],
		[Vector2(-1,-1)]
	],
	'name': [
		"none",
		'prison_a',
		'prison_b',
		
		'prison_c',
		'prison_d',
		
		'prison_e',
		'prison_f'
	],
	'decoration_name': [
		['none'],

		['gate', 'gate', 'gate'],
		['gate', 'gate', 'gate'],

		['gate', 'gate', 'gate'],
		['gate', 'gate', 'gate'],

		['gate'],
		['gate'],


	],
	'decoration_offset': [
		[Vector2(0,0)],

		[Vector2(1.20, 0.5), Vector2(1.80, 1.5), Vector2(1.20, 2.5)],
		[Vector2(-1,-1), Vector2(0,0), Vector2(0,0)],

		[Vector2(-1, -1), Vector2(-1,-1), Vector2(0,0)],
		[Vector2(-1, -1), Vector2(-1,-1), Vector2(0,0)],

		[Vector2(-1, -1)],
		[Vector2(-1, -1)],
	],
	'decoration_rotation': [
		[Vector3.ZERO],

		[Vector3(0, deg_to_rad(90), 0), Vector3(0, deg_to_rad(90), 0), Vector3(0, deg_to_rad(90), 0)],
		[Vector3.ZERO, Vector3.ZERO, Vector3.ZERO],

		[Vector3.ZERO, Vector3.ZERO, Vector3.ZERO],
		[Vector3.ZERO, Vector3.ZERO, Vector3.ZERO],

		[Vector3.ZERO],
		[Vector3.ZERO],

	],
	'decoration_scale' : [
		[Vector3.ONE],


		[Vector3.ONE * 0.5, Vector3.ONE * 0.5, Vector3.ONE * 0.5],
		[Vector3.ONE, Vector3.ONE, Vector3.ONE],

		[Vector3.ONE, Vector3.ONE, Vector3.ONE],
		[Vector3.ONE, Vector3.ONE, Vector3.ONE],

		[Vector3.ONE],
		[Vector3.ONE],

		]
}

var message = {
	'start': {
		0: "welcome",
		1: "greetings",
		2: "greetings and salutations",
		3: "falling!!"
	},
	'keys': {
		0: "get the keys!!",
		1: "get the last bare altar"
	},
	'hill': {
		0: "find the high altar!",
		1: "that hurts",
		2: "gators!! Hide in the car!"
	},
	'maze': {
		0: "you skipped something??",
		1: "that hurts",
		2: "points!!"
	}
}


