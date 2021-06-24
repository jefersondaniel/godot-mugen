var Character = load('res://source/gdscript/nodes/character.gd')
var Data = load('res://source/gdscript/nodes/character/data.gd')
var Definition = load('res://source/gdscript/nodes/character/definition.gd')
var air_parser = load('res://source/gdscript/parsers/air_parser.gd').new()
var data_hydrator = load('res://source/gdscript/helpers/data_hydrator.gd').new()
var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()
var cns_parser = load('res://source/gdscript/parsers/cns_parser.gd').new()
var cmd_parser = load('res://source/gdscript/parsers/cmd_parser.gd').new()
var def_parser = load('res://source/gdscript/parsers/def_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()
var snd_parser = load('res://source/native/snd_parser.gdns').new()

func load_definition(path: String):
    var base_path = path.substr(0, path.find_last('/'))

    var definition = Definition.new()
    definition.base_path = base_path
    definition.parse(def_parser.read(path))

    return definition

func load(path: String, palette, command_manager):
    var base_path = path.substr(0, path.find_last('/'))

    var definition = Definition.new()
    definition.base_path = base_path
    definition.parse(def_parser.read(path))

    var sprite_path: String = definition.get_sprite_path()
    var animation_path: String = definition.get_animation_path()
    var command_path: String = definition.get_command_path()
    var sound_path: String = definition.get_sound_path()
    var state_paths: String = definition.get_state_paths()

    var images = sff_parser.get_images(sprite_path, palette)
    var sounds = snd_parser.get_sounds(sound_path)
    var animations = air_parser.read(animation_path)
    var commands: Array =  cmd_parser.read(command_path)
    var all_constant_data: Dictionary = {
        'states': {},
    }

    for path in state_paths:
        var new_states = cns_parser.read(path)
        merge_states(new_states, all_constant_data)

    command_manager.set_commands(commands)

    var state_defs = all_constant_data['states']
    var data = Data.new()
    data_hydrator.hydrate_object(data, all_constant_data)

    var character = Character.new()
    character.setup(definition, data, state_defs, images, animations, sounds, command_manager)
    return character

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
