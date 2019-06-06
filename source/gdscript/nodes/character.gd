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
var velocity: Vector2

# State variables

var stage_variables: Array = ['roundstate']
var state_variables: Array = []
var life: int = 0
var alive: int = 0
var time: int = 0
var prevstateno: int = -1
var stateno: int = 0
var statetype: int = constants.FLAG_S
var movetype: int = constants.FLAG_I
var ctrl: int = 1
var canwalk: int = 1

func _init(_consts, images, animations, commands, input_prefix):
    consts = _consts
    character_sprite = CharacterSprite.new(images, animations)
    command_manager = CommandManager.new(commands, input_prefix)
    state_manager = StateManager.new(self)

    alive = 1
    life = consts['data']['life']
    velocity = Vector2(0, 0)

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

func get_const(fullname):
    var data = fullname.split(".", false, 1)

    if data[0] == 'states':
        return null

    var kind = data[0]
    var name = data[1]

    if kind == 'states':
        return

    var vector_attr: String

    if name.ends_with('.x') or name.ends_with('.y'):
        vector_attr = name.substr(name.size() - 2, name.size() - 1)
        name = name.substr(0, name.size() - 2)
        print("vecotr attr")
        print(vector_attr)
        print("name attr")
        print(name)

    var result = consts[kind][name]

    if vector_attr:
        result = result[0] if vector_attr == 'x' else result[1]

    return result

func get_state_def(number: int):
    return consts['states'][String(number)]

func set_context_variable(key, value):
    if key == "vel_x":
        velocity.x = value
    elif key == "vel_y":
        velocity.y = value
    else:
        push_warning("cant assign variable: %s" % [key])

func get_context_variable(key):
    if key == "command":
        return command_manager.current_command
    if key == "anim":
        return character_sprite.current_animation
    if key == "animtime":
        return min(0, -character_sprite.animation_looptime + character_sprite.animation_time)
    if key == "animelem":
        return character_sprite.animation_element
    if key == "vel_x":
        return velocity.x
    if key == "vel_y":
        return velocity.y
    if key in state_variables:
        return get(key)
    if key in stage_variables:
        return stage.get(key)
    if key in constants.FLAGS:
        return constants.FLAGS[key]
    push_warning("variable not found: %s" % [key])

func call_context_function(key, arguments):
    if key == 'abs':
        return abs(arguments[0] if arguments[0] != null else 0)
    if key == 'const':
        return get_const(arguments[0])
    if key == 'const720p':
        return arguments[0] # todo, multiply by resolution
    if key == 'const240p':
        return arguments[0] # todo, multiply by resolution
    if key == 'selfanimexist':
        return character_sprite.has_anim(arguments[0])
    push_warning("Method not found: %s, arguments: %s" % [key, arguments])

func redirect_context(key):
    push_warning("TODO: Trigger redirection")

func change_anim(anim: int):
    character_sprite.change_anim(anim)
