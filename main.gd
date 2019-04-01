extends Node2D

var specs = {
	'SffHeader': [
		{'name': 'signature', 'type': 'string', 'length': 12},
		{'name': 'verlo3', 'type': 'u_char'},
		{'name': 'verlo2', 'type': 'u_char'},
		{'name': 'verlo1', 'type': 'u_char'},
		{'name': 'verhi', 'type': 'u_char'},
		{'name': 'reserved1', 'type': 'bytes', 'length': 4},
		{'name': 'reserved2', 'type': 'bytes', 'length': 4},  
		{'name': 'compatverlo3', 'type': 'u_char'},
		{'name': 'compatverlo2', 'type': 'u_char'},
		{'name': 'compatverlo1', 'type': 'u_char'},
		{'name': 'compatverhi', 'type': 'u_char'},
		{'name': 'reserved1', 'type': 'bytes', 'length': 4},
		{'name': 'reserved2', 'type': 'bytes', 'length': 4},
		{'name': 'first_sprnode_offset', 'type': 'u_long'},
		{'name': 'total_frames', 'type': 'u_long'},
		{'name': 'first_palnode_offset', 'type': 'u_long'},
		{'name': 'total_palettes', 'type': 'u_long'},
		{'name': 'ldata_offset', 'type': 'u_long'},
		{'name': 'ldata_length', 'type': 'u_long'},
		{'name': 'tdata_offset', 'type': 'u_long'},
		{'name': 'tdata_length', 'type': 'u_long'},
		{'name': 'reserved5', 'type': 'bytes', 'length': 4},
		{'name': 'reserved6', 'type': 'bytes', 'length': 4},
		{'name': 'unused', 'type': 'bytes', 'length': 436},
	],
}

func fw_align(file_wrapper, size):
	var rest = file_wrapper['position'] % size
	var padding = 0
	if rest > 0:
		padding = (size - rest)
		file_wrapper['file'].get_8()
		file_wrapper['position'] = file_wrapper['position'] + padding

func fw_parse_struct(file_wrapper, struct_name):
	var spec = specs[struct_name]
	var result = {}
	var value = null
	var file = file_wrapper['file']

	for field in spec:
		if field['type'] == 'u_char':
			value = file.get_8()
			file_wrapper['position'] = file_wrapper['position'] + 1
		elif field['type'] == 'u_long':
			fw_align(file_wrapper, 4)
			value = file.get_32()
			file_wrapper['position'] = file_wrapper['position'] + 4
		elif field['type'] == 'string':
			value = file.get_buffer(field['length']).get_string_from_ascii()
			file_wrapper['position'] = file_wrapper['position'] + field['length']
		elif field['type'] == 'bytes':
			value = file.get_buffer(field['length'])
			file_wrapper['position'] = file_wrapper['position'] + field['length']
		else:
			value = null
		result[field['name']] = value

	return result

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open("res://chars/kfm/kfm.sff", file.READ)
	
	var file_wrapper = {'file': file, 'position': 0}
	var header = fw_parse_struct(file_wrapper, 'SffHeader')
	print(header)

	file.close()
