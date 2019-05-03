extends KinematicBody2D


# Dependencies
var CharacterSprite = load('res://source/gdscript/components/character_sprite.gd')
var air_parser = load('res://source/gdscript/parser/air_parser.gd').new()
var cfg_parser = load('res://source/gdscript/parser/cfg_parser.gd').new()
var cns_parser = load('res://source/gdscript/parser/cns_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()

# Character Definition
var sprite_path: String
var animation_path: String
var state_paths: Array
var character_sprite = null
var states = null

func _init(path):
	var definition = cfg_parser.read(path)
	var folder = path.substr(0, path.find_last('/'))
	sprite_path = '%s/%s' % [folder, definition['files']['sprite']]
	animation_path = '%s/%s' % [folder, definition['files']['anim']]
	state_paths = []

	if 'stcommon' in definition['files']:
		state_paths.append('%s/%s' % ['res://data/data', definition['files']['stcommon']])

	for key in ['cmd', 'st']:
		if key in definition['files']:
			state_paths.append('%s/%s' % [folder, definition['files'][key]])

	setup_animation()
	setup_state()

func _ready():
	self.add_child(character_sprite)

func setup_animation():
	var images = sff_parser.get_images(sprite_path, -1, -1, 0)
	var animations = air_parser.read(animation_path)
	character_sprite = CharacterSprite.new(images, animations)

func setup_state():
	states = {
		'data': {},
		'size': {},
		'velocity': {},
		'movement': {},
		'quotes': {},
		'states': {},
	}

	for path in state_paths:
		var new_states = cns_parser.read(path)
		for parent_key in states.keys():
			for child_key in new_states[parent_key]:
				if parent_key == 'states':
					if child_key in states['states']:
						states['states'][child_key]['controllers'] += new_states['states'][child_key]['controllers']
					else:
						states[parent_key][child_key] = new_states[parent_key][child_key]
				else:
					states[parent_key][child_key] = new_states[parent_key][child_key]

	print(states['states']['180'])
