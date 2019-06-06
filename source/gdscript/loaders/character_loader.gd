extends Object

var Character = load('res://source/gdscript/nodes/character.gd')
var air_parser = load('res://source/gdscript/parsers/air_parser.gd').new()
var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()
var cns_parser = load('res://source/gdscript/parsers/cns_parser.gd').new()
var cmd_parser = load('res://source/gdscript/parsers/cmd_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()

func load(path: String, input_prefix: String):
    var sprite_path: String
    var animation_path: String
    var command_path: String
    var state_paths: Array

    var definition = cfg_parser.read(path)
    var folder = path.substr(0, path.find_last('/'))
    sprite_path = '%s/%s' % [folder, definition['files']['sprite']]
    animation_path = '%s/%s' % [folder, definition['files']['anim']]
    command_path = '%s/%s' % [folder, definition['files']['cmd']]
    state_paths = []

    if 'stcommon' in definition['files']:
        state_paths.append('%s/%s' % ['res://data/data', definition['files']['stcommon']])

    for key in ['cmd', 'st']:
        if key in definition['files']:
            state_paths.append('%s/%s' % [folder, definition['files'][key]])

    var images = sff_parser.get_images(sprite_path, -1, -1, 0)
    var animations = air_parser.read(animation_path)
    var commands: Array =  cmd_parser.read(command_path)
    var consts: Dictionary = {
        'data': {},
        'size': {},
        'velocity': {},
        'movement': {},
        'quotes': {},
        'states': {},
    }

    for path in state_paths:
        var new_states = cns_parser.read(path)
        merge_states(new_states, consts)

    return Character.new(consts, images, animations, commands, input_prefix)

func merge_states(new_states, states):
    for parent_key in states.keys():
        for child_key in new_states[parent_key]:
            if parent_key == 'states':
                if child_key in states['states']:
                    states['states'][child_key]['controllers'] += new_states['states'][child_key]['controllers']
                else:
                    states[parent_key][child_key] = new_states[parent_key][child_key]
            else:
                states[parent_key][child_key] = new_states[parent_key][child_key]
