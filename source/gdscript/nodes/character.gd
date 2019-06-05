extends KinematicBody2D

# Dependencies
var CharacterSprite = load('res://source/gdscript/nodes/character_sprite.gd')
var CommandManager = load('res://source/gdscript/nodes/command_manager.gd')
var StateManager = load('res://source/gdscript/nodes/state_manager.gd')

# Nodes
var character_sprite = null
var command_manager = null
var state_manager = null
var stage = null

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

var stage_variables: Array = ['roundstate']
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

func _init(_consts, images, animations, commands, input_prefix):
    consts = _consts
    character_sprite = CharacterSprite.new(images, animations)
    command_manager = CommandManager.new(commands, input_prefix)
    state_manager = StateManager.new(self)

    alive = 1
    life = consts['data']['life']

    int_vars = PoolIntArray()
    int_vars.resize(64)
    float_vars = PoolRealArray()
    float_vars.resize(int_vars.size())
    for i in range(0, int_vars.size()):
        int_vars[i] = 0
        float_vars[i] = 0

    var skip = true
    for p in self.get_property_list():
        if p['name'] == 'state_variables':
            skip = false
            continue
        if skip:
            continue
        state_variables.append(p['name'])

func _ready():
    self.add_child(command_manager)
    self.add_child(state_manager)
    self.add_child(character_sprite)

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
    elif key in stage_variables:
        return stage.get(key)
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
