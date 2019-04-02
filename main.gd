extends Node2D

var specs = {
	'SffHeader': [
		{'name': 'signature', 'type': 'string', 'length': 12},
		{'name': 'verlo3', 'type': 'char'},
		{'name': 'verlo2', 'type': 'char'},
		{'name': 'verlo1', 'type': 'char'},
		{'name': 'verhi', 'type': 'char'},
		{'name': 'reserved1', 'type': 'bytes', 'length': 4},
		{'name': 'reserved2', 'type': 'bytes', 'length': 4},  
		{'name': 'compatverlo3', 'type': 'char'},
		{'name': 'compatverlo2', 'type': 'char'},
		{'name': 'compatverlo1', 'type': 'char'},
		{'name': 'compatverhi', 'type': 'char'},
		{'name': 'reserved1', 'type': 'bytes', 'length': 4},
		{'name': 'reserved2', 'type': 'bytes', 'length': 4},
		{'name': 'first_sprnode_offset', 'type': 'long'},
		{'name': 'total_frames', 'type': 'long'},
		{'name': 'first_palnode_offset', 'type': 'long'},
		{'name': 'total_palettes', 'type': 'long'},
		{'name': 'ldata_offset', 'type': 'long'},
		{'name': 'ldata_length', 'type': 'long'},
		{'name': 'tdata_offset', 'type': 'long'},
		{'name': 'tdata_length', 'type': 'long'},
		{'name': 'reserved5', 'type': 'bytes', 'length': 4},
		{'name': 'reserved6', 'type': 'bytes', 'length': 4},
		{'name': 'unused', 'type': 'bytes', 'length': 436},
	],
	'SffPalHeader': [
		{'name': 'groupno', 'type': 'short'},
		{'name': 'itemno', 'type': 'short'},
		{'name': 'numcols', 'type': 'short'},
		{'name': 'linked', 'type': 'short'},
		{'name': 'offset', 'type': 'long'},
		{'name': 'len', 'type': 'long'},
	],
	'SffSprHeader': [
		{'name': 'groupno', 'type': 'short'},
		{'name': 'imageno', 'type': 'short'},
		{'name': 'w', 'type': 'short'},
		{'name': 'h', 'type': 'short'},
		{'name': 'x', 'type': 'short'},
		{'name': 'y', 'type': 'short'},
		{'name': 'linked', 'type': 'short'},
		{'name': 'fmt', 'type': 'char'},
		{'name': 'colordepth', 'type': 'char'},
		{'name': 'offset', 'type': 'long'},
		{'name': 'len', 'type': 'long'},
		{'name': 'palindex', 'type': 'short'},
		{'name': 'flags', 'type': 'short'},
	],
}

func check_struct_aligment(file, position, size):
	var rest = position % size
	var padding = 0
	if rest > 0:
		print('padding')
		padding = (size - rest)
		file.get_buffer(padding)
		position = position + padding
	return position

func parse_struct(file, struct_name):
	var spec = specs[struct_name]
	var result = {}
	var value = null
	var position = 0

	for field in spec:
		if field['type'] == 'char':
			value = file.get_8()
			position = position + 1
		elif field['type'] == 'short':
			position = check_struct_aligment(file, position, 2)
			value = file.get_16()
			position = position + 2
		elif field['type'] == 'long':
			position = check_struct_aligment(file, position, 4)
			value = file.get_32()
			position = position + 4
		elif field['type'] == 'string':
			value = file.get_buffer(field['length']).get_string_from_ascii()
			position = position + field['length']
		elif field['type'] == 'bytes':
			value = file.get_buffer(field['length'])
			position = position + field['length']
		else:
			print("WARNING: Not recognized type")
			value = null
		result[field['name']] = value
	return result

func rle8_decode(buffer):
	print("Unsupported format: rle8")
	get_tree().quit()

func rle5_decode(buffer):
	print("Unsupported format: rle5")
	get_tree().quit()

func lz5_decode(buffer):
	print("Unsupported format: rle5")
	get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open("res://chars/kfm/kfm.sff", file.READ)
	var header = parse_struct(file, 'SffHeader')
	var palettes = []
	var sprites = []
	var struct = null
	var buffer = null
	var offset = 0

	if header['signature'] != 'ElecbyteSpr' or header['compatverhi'] != 2:
		print('Invalid sff file. Only sffv2 are supported')
		get_tree().quit()

	file.seek(header['first_palnode_offset'])

	for i in range(0, header['total_palettes']):
		struct = parse_struct(file, 'SffPalHeader')
		palettes.append(struct)

	file.seek(header['first_sprnode_offset'])
	
	for i in range(0, header['total_frames']):
		struct = parse_struct(file, 'SffSprHeader')
		sprites.append(struct)

	for pal in palettes:
		if pal['len'] == 0: # Linked
			pal['pal'] = palettes[pal['linked']]['pal'].duplicate()
		elif pal['len'] > 0:
			pal['pal'] = []
			file.seek(header['ldata_offset'] + pal['offset'])
			for i in range(0, pal['numcols']):
				pal['pal'].append(file.get_32())

	for spr in sprites:
		if spr['len'] == 0: # Linked
			spr['image'] = sprites[spr['linked']]['image']
		elif spr['len'] > 0:
			spr['image'] = null
			if spr['flags'] == 0:
				offset = header['ldata_offset']
			else:
				offset = header['tdata_offset']
			offset += spr['offset']
			buffer = file.get_buffer(spr['len'])
			if spr['fmt'] == 2:
				rle8_decode(buffer)
			elif spr['fmt'] == 3:
				rle5_decode(buffer)
			elif spr['fmt'] == 4:
				# lz5_decode(buffer)
				pass

	file.close()
