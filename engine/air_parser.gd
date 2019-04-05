extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func load_air(path):
	var file = File.new()
	file.open(path, File.READ)
	var lines = file.get_as_text().split("\n", false)
	file.close()

	var animations = {}

	var current_animation = null
	var current_animation_key = null
	var current_animation_set = null
	var current_animation_time = 0

	for line in lines:
		var comment_idx = line.find(';')
		if comment_idx != -1:
			line = line.substr(0, comment_idx)
		line = line.strip_edges().to_lower()

		if not line:
			continue

		if line.begins_with('[begin action '):
			if current_animation:
				animations[current_animation_key] = current_animation
				current_animation_set = null
				current_animation_time = 0

			var idx_start = 14
			var idx_end = line.find(']')
			current_animation_key = line.substr(idx_start, idx_end - idx_start)
			current_animation_set = {'frames': []}
			current_animation = {
				'collisions': [],
				'sets': [current_animation_set],
			}
			continue

		if not current_animation:
			continue

		var is_collision_1 = line.begins_with('clsn1[')
		var is_collision_2 = line.begins_with('clsn2[')
		var is_loopstart = line.begins_with('loopstart')

		if is_collision_1 or is_collision_2:
			var idx_start = line.find('=') + 1
			var idx_end = line.length() - 1
			var points = line.substr(idx_start, idx_end - idx_start)
			points = points.split_floats(',')
			current_animation['collisions'].append({
				'type': 1 if is_collision_1 else 2,
				'points': points,
				'time': current_animation_time,
			})
			continue

		if is_loopstart:
			current_animation_set = {'frames': []}
			current_animation['sets'].append(current_animation_set)
			continue

		if line.begins_with('clsn'):
			continue

		line = line.replace(' ', '').replace(',,', '')
		var parameters = line.split(',')
		var parameters_size = parameters.size()
		if parameters_size < 5:
			print("Invalid animation frame: %s" % [line])
			continue
		var flags = []
		if parameters_size > 5:
			for i in range(5, parameters_size):
				flags.append(parameters[i])
		current_animation_set['frames'].append({
			'image': [float(parameters[0]), float(parameters[1])],
			'offset': [float(parameters[2]), float(parameters[3])],
			'ticks': float(parameters[4]),
			'flags': flags,
		})
		current_animation_time += 1

	if current_animation:
		animations[current_animation_key] = current_animation

	return animations
