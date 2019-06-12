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
var sys_int_vars: PoolIntArray
var sys_float_vars: PoolRealArray
var velocity: Vector2
var special_flags = []

# State variables

var stage_variables: Array = ['roundstate']
var state_variables: Array = []
var life: int = 0
var alive: int = 0
var time: int = 0
var prevstateno: int = -1
var stateno: int = 0
var statetype: int = constants.FLAG_S
var physics: int = constants.FLAG_S
var movetype: int = constants.FLAG_I
var sprpriority: int = 0
var ctrl: int = 1

func _init(_consts, images, animations, commands, input_prefix):
    consts = _consts
    character_sprite = CharacterSprite.new(images, animations)
    command_manager = CommandManager.new(commands, input_prefix)
    state_manager = StateManager.new(self)

    alive = 1
    life = consts['data']['life']
    velocity = Vector2(0, 0)
    setup_vars()

    var skip = true
    for p in self.get_property_list():
        if p['name'] == 'state_variables':
            skip = false
            continue
        if skip:
            continue
        state_variables.append(p['name'])

func setup_vars():
    int_vars = PoolIntArray()
    float_vars = PoolRealArray()
    sys_int_vars = PoolIntArray()
    sys_float_vars = PoolRealArray()

    int_vars.resize(64)
    float_vars.resize(64)
    sys_int_vars.resize(64)
    sys_float_vars.resize(64)

    for i in range(0, 64):
        int_vars[i] = 0
        float_vars[i] = 0
        sys_int_vars[i] = 0
        sys_float_vars[i] = 0

func _ready():
    self.add_child(command_manager)
    self.add_child(state_manager)
    self.add_child(character_sprite)

func get_const(fullname):
    var data = fullname.to_lower().split(".", false, 1)
    var kind = data[0]
    var name = data[1]

    if kind == 'states':
        return

    var vector_attr: String

    if name.ends_with('.x') or name.ends_with('.y'):
        vector_attr = name.substr(name.length() - 1, name.length() - 1)
        name = name.substr(0, name.length() - 2)

    var result = consts[kind][name]
    var x: float = 0
    var y: float = 0

    if typeof(result) == TYPE_ARRAY:
        x = result[0]
        y = result[1]
    else:
        x = result

    if vector_attr:
        result = x if vector_attr == 'x' else y

    return result

func get_relative_position():
    return Vector2(position.x, position.y - stage.ground_y)

func set_relative_position(newpos):
    position.x = newpos.x
    position.y = newpos.y + stage.ground_y
    velocity = Vector2(0, 0)

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
    if key == "anim":
        return character_sprite.current_animation
    if key == "animtime":
        return character_sprite.get_time_from_the_end()
    if key == "vel_x":
        return velocity.x
    if key == "vel_y":
        return velocity.y
    if key == "pos_x":
        return get_relative_position().x
    if key == "pos_y":
        return get_relative_position().y
    if key.begins_with("var."):
        return int_vars[int(key.substr(4, key.length() - 1))]
    if key in state_variables:
        return get(key)
    if key in stage_variables:
        return stage.get(key)
    if key in constants.FLAGS:
        return constants.FLAGS[key]
    push_warning("variable not found: %s" % [key])

func call_context_function(key, arguments):
    if key == "debug":
        print("DEBUG: ", arguments[0])
        return 1
    if key == "command":
        var has_command: bool = command_manager.active_commands.has(arguments[1])
        var op: String = arguments[0]
        return has_command if op == "=" else !has_command
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
    if key == 'animelemtime':
        var lala = (character_sprite.animation_time - character_sprite.get_element_time(arguments[0]))
        return lala
    if key == 'sysvar':
        return sys_int_vars[arguments[0]]
    if key == 'sysfvar':
        return sys_float_vars[arguments[0]]
    if key == 'var':
        return int_vars[arguments[0]]
    if key == 'fvar':
        return float_vars[arguments[0]]
    if key == "assertion":
        return special_flags.has(arguments[0])
    push_warning("Method not found: %s, arguments: %s" % [key, arguments])

func redirect_context(key):
    push_warning("TODO: Trigger redirection")

func change_anim(anim: int):
    character_sprite.change_anim(anim)

func change_state(stateno: int):
    state_manager.activate_state(stateno)

func assert_special(flag: String):
    special_flags.append(flag)

func reset_assert_special():
    special_flags = []

func _process(delta):
    var text = "stateno: %s, prevstateno: %s, time: %s, animtime: %s, fps: %s\n" % [
        get_context_variable('stateno'),
        get_context_variable('prevstateno'),
        get_context_variable('time'),
        get_context_variable('animtime'),
        Engine.get_frames_per_second()
    ]

    text += "statetype: %s, movetype: %s, physics: %s, pos: (%.1f, %.1f), vel: (%.1f, %.1f)\n" % [
        constants.REVERSE_FLAGS[get_context_variable('statetype')],
        constants.REVERSE_FLAGS[get_context_variable('movetype')],
        constants.REVERSE_FLAGS[get_context_variable('physics')],
        get_context_variable('pos_x'),
        get_context_variable('pos_y'),
        get_context_variable('vel_x'),
        get_context_variable('vel_y'),
    ]

    text += "commands: %s\n" % [command_manager.active_commands]

    get_node('/root/Node2D/text').text = text

    #print([command_manager.current_tick, state_manager.current_tick])

func _physics_process(delta):
    var ground_friction: float = 0
    var relative_position: Vector2 = get_relative_position()

    if physics == constants.FLAG_S:
        ground_friction = consts['movement']['stand.friction']
    elif physics == constants.FLAG_C:
        ground_friction = consts['movement']['crouch.friction']

    if physics == constants.FLAG_S or physics == constants.FLAG_C:
        if relative_position.y == 0:
            velocity.x = velocity.x * ground_friction

    if physics == constants.FLAG_A:
        if relative_position.y < 0:
            velocity += stage.gravity

    self.move_and_collide(velocity)
