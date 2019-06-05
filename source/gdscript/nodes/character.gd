extends KinematicBody2D

# Dependencies
var CharacterSprite = load('res://source/gdscript/nodes/character_sprite.gd')
var CommandManager = load('res://source/gdscript/nodes/command_manager.gd')
var StateManager = load('res://source/gdscript/nodes/state_manager.gd')
var air_parser = load('res://source/gdscript/parser/air_parser.gd').new()
var cfg_parser = load('res://source/gdscript/parser/cfg_parser.gd').new()
var cns_parser = load('res://source/gdscript/parser/cns_parser.gd').new()
var cmd_parser = load('res://source/gdscript/parser/cmd_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()

# Paths
var sprite_path: String
var animation_path: String
var command_path: String
var state_paths: Array

# Nodes
var character_sprite = null
var command_manager = null
var state_manager = null

# Constants
var consts: Dictionary = {
    'data': {},
    'size': {},
    'velocity': {},
    'movement': {},
    'quotes': {},
    'states': {},
}

# Custom Variables
var int_vars: PoolIntArray
var float_vars: PoolRealArray

# State variables

var state_variables: Array = []
var life: int = 0
var alive: int = 0
var vel_x: int = 0
var vel_y: int = 0
var time: int = 0
var stateno: int = 0
var statetype: int = constants.STATE_CONSTS['s']
var ctrl: int = 1
var canwalk: int = 1

func _init(path):
    var definition = cfg_parser.read(path)
    var folder = path.substr(0, path.find_last('/'))
    sprite_path = '%s/%s' % [folder, definition['files']['sprite']]
    animation_path = '%s/%s' % [folder, definition['files']['anim']]
    command_path = '%s/%s' % [folder, definition['files']['cmd']]
    state_paths = ['res://data/data/internal.cns']

    if 'stcommon' in definition['files']:
        state_paths.append('%s/%s' % ['res://data/data', definition['files']['stcommon']])

    for key in ['cmd', 'st']:
        if key in definition['files']:
            state_paths.append('%s/%s' % [folder, definition['files'][key]])

    setup_animation()
    setup_state()

    var skip = true

    for p in self.get_property_list():
        if p['name'] == 'state_variables':
            skip = false
            continue
        if skip:
            continue
        state_variables.append(p['name'])

    alive = 1
    life = consts['data']['life']

    int_vars = PoolIntArray()
    int_vars.resize(64)
    float_vars = PoolRealArray()
    float_vars.resize(int_vars.size())
    for i in range(0, int_vars.size()):
        int_vars[i] = 0
        float_vars[i] = 0

func _ready():
    self.add_child(command_manager)
    self.add_child(state_manager)
    self.add_child(character_sprite)

func setup_animation():
    var images = sff_parser.get_images(sprite_path, -1, -1, 0)
    var animations = air_parser.read(animation_path)
    character_sprite = CharacterSprite.new(images, animations)

func setup_state():
    var commands: Array =  cmd_parser.read(command_path)

    command_manager = CommandManager.new(commands, 'P1_', true)

    for path in state_paths:
        var new_states = cns_parser.read(path)
        merge_states(new_states, consts)

    state_manager = StateManager.new(self)

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

func get_const(kind, name):
    if kind == 'states':
        return
    # TODO: handle name.x, where the value is an array [x, y]
    return consts[kind][name]

func get_state_def(number: int):
    return consts['states'][String(number)]

func set_context_variable(key, value):
    pass

func get_context_variable(key):
    if key == "command":
        return command_manager.current_command
    if key == "anim":
        return character_sprite.current_animation
    elif key in state_variables:
        return get(key)
    elif key in constants.STATE_CONSTS:
        return constants.STATE_CONSTS[key]
    push_warning("variable not found: %s" % [key])

func call_context_function(key, arguments):
    if key == 'abs':
        return abs(arguments[0] if arguments[0] != null else 0)
    elif key == 'const':
        var data = arguments[0].split(".", false, 1)
        if data[0] == 'states':
            return null
        return get_const(data[0], data[1])
    push_warning("Method not found: %s, arguments: %s" % [key, arguments])

func redirect_context(key):
    push_warning("TODO: Trigger redirection")
