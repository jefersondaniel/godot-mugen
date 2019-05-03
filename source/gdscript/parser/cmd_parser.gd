extends Object

var cfg_parser = load('res://source/gdscript/parser/cfg_parser.gd').new()

func read(path):
	var data = cfg_parser.read(path, true)

	return {
		'command': data.get('command', []),
		'defaults': data.get('defaults', {}),
		'remap': data.get('remap', {}),
	}
