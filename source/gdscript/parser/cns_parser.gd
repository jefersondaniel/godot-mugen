extends Object

var cfg_parser = load('res://source/gdscript/parser/cfg_parser.gd').new()

func read(path):
	var data = cfg_parser.read(path, false)
	var states = {
		'-3': {'controllers': []},
		'-2': {'controllers': []},
		'-1': {'controllers': []},
	}
	var item_name: String = ''

	for key in data:
		var statedef_idx: int = key.find('statedef')
		var start_index: int = 0
		var length: int = key.length()

		if statedef_idx == 0:
			start_index = statedef_idx + 9
			item_name = key.substr(start_index, length - start_index).strip_edges()
			states[item_name] = data[key]
			states[item_name]['controllers'] = []
			continue

		var state_idx = key.find('state')
		var comma_idx: int = key.find(',')

		if state_idx == 0 and comma_idx > 0:
			start_index = state_idx + 6
			item_name = key.substr(start_index, comma_idx - start_index).strip_edges()
			if item_name in states:
				states[item_name]['controllers'].append(data[key])
			continue


	return {
		'data': data.get('data', {}),
		'size': data.get('size', {}),
		'velocity': data.get('velocity', {}),
		'movement': data.get('movement', {}),
		'quotes': data.get('quotes', {}),
		'states': states,
	}
