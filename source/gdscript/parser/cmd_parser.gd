extends Object

var cfg_parser = load('res://source/gdscript/parser/cfg_parser.gd').new()

var KEY_MAP: Dictionary = {
	'F': constants.KEY_F,
	'B': constants.KEY_B,
	'U': constants.KEY_U,
	'D': constants.KEY_D,
	'a': constants.KEY_a,
	'b': constants.KEY_b,
	'c': constants.KEY_c,
	'x': constants.KEY_x,
	'y': constants.KEY_y,
	'z': constants.KEY_z,
	's': constants.KEY_s,
}

func read(path):
	var data: Dictionary = cfg_parser.read(path, true)
	var defaults: Dictionary = data.get('defaults', [{}])[0]
	var remap: Dictionary = data.get('remap', [{}])[0]
	var commands: Array = []

	var default_time: int = 1
	var default_buffer_time: int = 15

	if 'command.time' in defaults:
		default_time = int(defaults['command.time'])

	if 'command.buffer.time' in defaults:
		default_buffer_time = int(defaults['command.buffer.time'])

	for command in data['command']:
		var cmd: Array = []

		for item in command['command'].split(',', false):
			var modifier: int = 0
			var ticks: int = default_time
			var code: int = 0
			var aux

			item = item.strip_edges()

			if item.find('~') == 0:
				modifier += constants.KEY_MODIFIER_ON_RELEASE
				aux = int(item)
				if aux > 0:
					ticks = aux
			if item.find('/') == 0:
				modifier += constants.KEY_MODIFIER_MUST_BE_HELD
			if item.find('$') == 0:
				modifier += constants.KEY_MODIFIER_DETECT_AS_4WAY

			for key_name in KEY_MAP.keys():
				if not item.find(key_name):
					continue
				code += KEY_MAP[remap.get(key_name, key_name)]

			cmd.append({
				'modifier': modifier,
				'ticks': ticks,
				'code': code,
			})

		commands.append({
			'name': command['name'].lstrip(" \"").rstrip(" \""),
			'cmd': cmd,
			'time': int(command.get('time', default_time)),
			'buffer_time': int(command.get('buffer.time', default_buffer_time)),
		})

	return commands
