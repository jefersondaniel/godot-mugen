extends Node

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

var shared_buffer = StreamPeerBuffer.new()

func check_struct_aligment(file, position, size):
	var rest = position % size
	var padding = 0
	if rest > 0:
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

func rle8_decode(data):
	var dest = PoolByteArray()
	var ch = 0
	var color = 0

	shared_buffer.set_data_array(data)
	shared_buffer.get_32() # skip first 4 bytes

	while shared_buffer.get_available_bytes():
		ch = shared_buffer.get_u8()
		if (ch & 0xc0) == 0x40:
			color = shared_buffer.get_u8()
			for a in range(0, ch & 0x3f):
				dest.append(color)
		if (ch & 0xc0) != 0x40:
			dest.append(ch)

	return dest

func rle5_packet(buffer):
	var run_len = buffer.get_u8()
	var byte_process = buffer.get_u8()
	var color_bit = (byte_process & 0x80) /0x80; # 1 if bit7 = 1; 0 if bit7 = 0
	var data_len = byte_process & 0x7f; # value of bits 0-6

	return {
		'color_bit': color_bit,
		'data_len': data_len
	}

func rle5_decode(data):
	print("Untested format: rle5")

	var dest = PoolByteArray()
	var shared_buffer = StreamPeerBuffer.new()
	var color = 0
	var one_byte = 0
	var run_len = 0

	shared_buffer.set_data_array(data)
	shared_buffer.get_32() # skip first 4 bytes

	while shared_buffer.get_available_bytes():
		var rle5 = rle5_packet(shared_buffer)

		if rle5['color_bit'] == 1:
			color = shared_buffer.get_u8()
		elif rle5['color_bit'] == 0:
			color = 0

		for run_count in range(0, rle5['run_len'] + 1):
			dest.append(color)

		for bytes_processed in range(0, rle5['data_len']):
			one_byte = shared_buffer.get_u8()
			color = one_byte & 0x1f
			run_len = one_byte >> 5
			for run_count in range(0, rle5['run_len'] + 1):
				dest.append(color)

	return dest

func lz5_decode(data):
	var dest = PoolByteArray()
	var recycle = [0, 0]

	shared_buffer.set_data_array(data)
	shared_buffer.get_32() # skip first 4 bytes

	while shared_buffer.get_available_bytes():
		var flags_byte = shared_buffer.get_u8()
		var masks = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
		var flags = [0, 0, 0, 0, 0, 0, 0, 0]
		for a in range(0, 8):
			flags[a] = (flags_byte & masks[a]) / masks[a]

		for a in range(0, 8):
			if not shared_buffer.get_available_bytes():
				break
			if flags[a] == 0:
				var byte1 = shared_buffer.get_u8()
				var numtimes = (byte1 & 0xe0) >> 5
				if numtimes == 0:
					numtimes = shared_buffer.get_u8() + 8
				var color = byte1 & 0x1f
				for b in range(0, numtimes):
					dest.append(color)
			else:
				var byte1 = shared_buffer.get_u8()
				var offset = 0
				var length = byte1 & 0x3f
				if length == 0:
					var byte2 = shared_buffer.get_u8()
					var byte3 = shared_buffer.get_u8()
					offset = byte1 & 0xc0;
					offset = offset * 4;
					offset = offset + byte2
					offset = offset + 1
					length = byte3
					length = length + 3
				else:
					length = length + 1
					var tmp_recyc = byte1 & 0xc0
					if recycle[1] == 2:
						tmp_recyc = tmp_recyc >> 2
					elif recycle[1] == 4:
						tmp_recyc = tmp_recyc >> 4
					elif recycle[1] == 6:
						tmp_recyc = tmp_recyc >> 6
					recycle[0] = recycle[0] + tmp_recyc
					recycle[1] = recycle[1] + 2
					if recycle[1] < 8:
						var byte2 = shared_buffer.get_u8()
						offset = byte2
					elif recycle[1] == 8:
						offset = recycle[0]
						recycle[0] = 0
						recycle[1] = 0
					offset = offset + 1
				var tmp_arr = PoolByteArray(dest)
				var tmp_arr_size = tmp_arr.size()
				var start_index = tmp_arr_size - offset
				var end_index = min(start_index + length, tmp_arr_size - 1)
				tmp_arr = tmp_arr.subarray(start_index, end_index)
				while tmp_arr.size() < length:
					tmp_arr.append_array(tmp_arr)
				if tmp_arr.size() > length:
					tmp_arr = tmp_arr.subarray(0, length - 1)
				dest.append_array(tmp_arr)

	return dest

func buffer_to_image(buffer, w, h, colors):
	var dest = PoolByteArray()

	for i in range(0, w * h):
		dest.append_array(colors[buffer[i]])

	var image = Image.new()
	image.create_from_data(w, h, false, Image.FORMAT_RGBA8, dest)

	return image

func load_sff(file):
	file.seek(0)

	var header = parse_struct(file, 'SffHeader')
	var palettes = []
	var sprites = []
	var struct = null
	var buffer = null
	var offset = 0

	if header['signature'] != 'ElecbyteSpr' or header['compatverhi'] != 2:
		print('Invalid sff file. Only sffv2 are supported')
		return null

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
				var color = file.get_buffer(3)
				color.append(0 if i == 0 else 255)
				file.get_8() # Ignore fourth byte
				pal['pal'].append(color)

	return {
		'header': header,
		'sprites': sprites,
		'palettes': palettes
	}

func get_images(file, sff, filters = null):
	var images = {}
	var offset = 0
	var buffer = null
	var sprites = sff['sprites']
	var palettes = sff['palettes']

	for spr in sprites:
		if not spr['groupno'] in images:
			images[spr['groupno']] = {}
		if not 'image' in spr:
			if spr['len'] == 0: # Linked
				spr['image'] = sprites[spr['linked']]['image']
			elif spr['len'] > 0:
				spr['image'] = null
				if spr['flags'] == 0:
					offset = sff['header']['ldata_offset']
				else:
					offset = sff['header']['tdata_offset']
				offset += spr['offset']
				file.seek(offset)
				buffer = file.get_buffer(spr['len'])
				if spr['fmt'] == 2:
					buffer = rle8_decode(buffer)
				elif spr['fmt'] == 3:
					buffer = rle5_decode(buffer)
				elif spr['fmt'] == 4:
					buffer = lz5_decode(buffer)
				spr['image'] = buffer_to_image(buffer, spr['w'], spr['h'], palettes[spr['palindex']]['pal'])
		images[spr['groupno']][spr['imageno']] = spr

	return images
