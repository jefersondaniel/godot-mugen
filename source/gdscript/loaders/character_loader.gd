extends Object

var Character = load('res://source/gdscript/nodes/character.gd')
var air_parser = load('res://source/gdscript/parsers/air_parser.gd').new()
var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()
var cns_parser = load('res://source/gdscript/parsers/cns_parser.gd').new()
var cmd_parser = load('res://source/gdscript/parsers/cmd_parser.gd').new()
var def_parser = load('res://source/gdscript/parsers/def_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()
var st_regex: RegEx

func _init():
    st_regex = RegEx.new()
    st_regex.compile("^st[0-9]+$")

func load(path: String, palette, command_manager):
    var sprite_path: String
    var animation_path: String
    var command_path: String
    var state_paths: Array

    var definition = def_parser.read(path)
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

    for key in definition['files']:
        var result = st_regex.search(key.to_lower())
        if not result:
            continue
        state_paths.append('%s/%s' % [folder, definition['files'][key]])
    
    state_paths.append('res://data/data/internal.cns')

    var images = sff_parser.get_images(sprite_path, palette)
    var animations = air_parser.read(animation_path)
    var commands: Array =  cmd_parser.read(command_path)
    var consts: Dictionary = {
        'data': {},
        'size': {},
        'velocity': {
            'jump': [0, -8.4],
        },
        'movement': {},
        'quotes': {},
        'states': {},
    }

    for path in state_paths:
        var new_states = cns_parser.read(path)
        merge_states(new_states, consts)

    command_manager.set_commands(commands)

    return Character.new(consts, images, animations, command_manager)

func merge_states(new_states, states):
    for parent_key in states.keys():
        for child_key in new_states[parent_key]:
            if parent_key == 'states':
                if child_key in states['states']:
                    states['states'][child_key]['controllers'] += new_states['states'][child_key]['controllers']
                    for attr_key in new_states['states'][child_key]:
                        if attr_key == 'controllers':
                            continue
                        states['states'][child_key][attr_key] = new_states['states'][child_key][attr_key]
                else:
                    states[parent_key][child_key] = new_states[parent_key][child_key]
            else:
                states[parent_key][child_key] = new_states[parent_key][child_key]
