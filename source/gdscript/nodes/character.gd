extends KinematicBody2D

# Dependencies
var CharacterSprite = load('res://source/gdscript/nodes/character_sprite.gd')
var StateManager = load('res://source/gdscript/nodes/character/state_manager.gd')

# Nodes and managers
var character_sprite = null
var command_manager = null
var state_manager = null
var fight = null

# Constants
var consts: Dictionary = {
    'data': {},
    'size': {},
    'velocity': {},
    'movement': {},
    'quotes': {},
    'states': {},
}

# Private variables
var int_vars: PoolIntArray
var float_vars: PoolRealArray
var sys_int_vars: PoolIntArray
var sys_float_vars: PoolRealArray
var velocity: Vector2
var special_flags = {}
var push_flag: bool = true
var in_hit_pause: bool = false
var is_facing_right: bool = true
var hit_def = null
var received_hit_def = null
var hit_by_1 = null
var hit_by_2 = null
var is_falling: bool = false
var is_hit_def_active: bool = false
var hit_count: int = 0
var unique_hit_count: int = 0
var attacker = null
var targets: Array = []
var blocked: bool = false
var killed: bool = false
var remaining_juggle_points: int = 15
var required_juggle_points: int = 0
var hit_pause_time: int = 0
var move_contact: int = 0
var move_guarded: int = 0
var move_hit: int = 0
var move_reversed: int = 0
var hit_overrides: Array = []
var hit_time: int = 0
var hit_shake_time: int = 0
var hit_state_type: int = 0

# Public variables (will be available in expressions)
var fight_variables: Array = ['roundstate']
var state_variables: Array = []
var power: float = 0
var life: float = 0
var alive: int = 0
var time: int = 0
var prevstateno: int = -1
var stateno: int = 0
var statetype: int = constants.FLAG_S
var physics: int = constants.FLAG_S
var movetype: int = constants.FLAG_I
var sprpriority: int = 0
var ctrl: int = 1
var team: int = 0

func _init(_consts, images, animations, _command_manager):
    consts = _consts
    character_sprite = CharacterSprite.new(images, animations)
    command_manager = _command_manager
    state_manager = StateManager.new(self)

    alive = 1
    life = consts['data']['life']
    power = consts['data'].get('power', 1000)
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

func reset_state_variables():
    self.time = 0
    self.hit_def = null
    self.hit_by_1 = null
    self.hit_by_2 = null
    self.is_hit_def_active = false

func _ready():
    self.add_child(character_sprite)

func get_const(fullname):
    if fullname == 'default.gethit.lifetopowermul' or fullname == 'default.attack.lifetopowermul':
        return 1 # TODO: Implement parsing global constants

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
    return Vector2(position.x, position.y - fight.stage.ground_y)

func set_relative_position(newpos):
    position.x = newpos.x
    position.y = newpos.y + fight.stage.ground_y

func add_relative_position(vector):
    var newpos = get_relative_position()

    newpos.y += vector.y

    if is_facing_right:
        newpos.x += vector.x
    else:
        newpos.x -= vector.x

    set_relative_position(newpos)

func get_left_location() -> float:
    if is_facing_right:
        return get_back_location()

    return get_front_location()

func get_right_location() -> float:
    if is_facing_right:
        return get_front_location()

    return get_back_location()

func get_front_location() -> float:
    if is_facing_right:
        return get_relative_position().x + get_front_width()

    return get_relative_position().x - get_front_width()

func get_back_location() -> float:
    if is_facing_right:
        return get_relative_position().x - get_back_width()

    return get_relative_position().x + get_back_width()

func get_front_width() -> float:
    if is_ground_state():
        return float(consts['size']['ground.front'])

    if is_air_state():
        return float(consts['size']['air.front'])

    return 0.0

func get_back_width() -> float:
    if is_ground_state():
        return float(consts['size']['ground.back'])

    if is_air_state():
        return float(consts['size']['air.back'])

    return 0.0

func is_ground_state() -> bool:
    return statetype == constants.FLAG_S or statetype == constants.FLAG_C or statetype == constants.FLAG_L

func is_air_state() -> bool:
    return statetype == constants.FLAG_A

func get_state_def(number: int):
    return consts['states'][String(number)]

func set_context_variable(key, value):
    if key == "vel_x":
        velocity.x = value if is_facing_right else -value
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
        return velocity.x if is_facing_right else -velocity.x
    if key == "vel_y":
        return velocity.y
    if key == "pos_x":
        return get_relative_position().x
    if key == "pos_y":
        return get_relative_position().y
    if key == "hitshakeover":
        return hit_shake_time <= 0
    if key == "hitfall":
        return is_falling
    if key.begins_with("var."):
        return int_vars[int(key.substr(4, key.length() - 1))]
    if key in state_variables:
        return get(key)
    if key in fight_variables:
        return fight.get(key)
    if key in constants.FLAGS:
        return constants.FLAGS[key]
    if key == "statetime":
        return get("time")
    if key in state_manager.trigger_names:
        return state_manager.handle_trigger(key)
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
        return check_assert_special(arguments[0])
    push_warning("Method not found: %s, arguments: %s" % [key, arguments])

func redirect_context(key):
    push_warning("TODO: Trigger redirection")

func change_anim(anim: int):
    character_sprite.change_anim(anim)

func change_state(stateno: int):
    state_manager.activate_state(stateno)

func assert_special(flag: String):
    special_flags[flag.to_lower()] = 2

func reset_assert_special():
    for key in special_flags:
        special_flags[key] = special_flags[key] - 1

func check_assert_special(key):
    key = key.to_lower()
    return special_flags.has(key) && special_flags[key] > 0

func set_facing_right(value: bool):
    character_sprite.set_flip_h(!value)
    is_facing_right = value
    command_manager.is_facing_right = is_facing_right

func set_velocity_x(x):
    if not is_facing_right:
       x = -x
    velocity.x = x

func set_velocity_y(y):
    velocity.y = y

func add_velocity(_velocity):
    if not is_facing_right:
       _velocity.x = -_velocity.x
    velocity.x += _velocity.x
    velocity.y += _velocity.y

func mul_velocity(_velocity):
    if not is_facing_right:
       _velocity.x = -_velocity.x
    velocity.x *= _velocity.x
    velocity.y *= _velocity.y

func add_power(_power):
    power = power + _power

func check_collision(other: Node2D, type: int):
    return self.character_sprite.check_collision(other.character_sprite, type)

func check_attack_collision(other: Node2D):
    return self.character_sprite.check_attack_collision(other.character_sprite)

func check_command(name: String) -> bool:
    return self.command_manager.active_commands.has(name)

func _process(delta):
    draw_debug_text()

func draw_debug_text():
    if team != 1:
        return

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

func update_state():
    self.reset_assert_special()

    self.command_manager.update()
    self.state_manager.update()

    if not self.in_hit_pause:
        self.update_hit_state()

func update_hit_state():
    if self.move_contact > 0:
        self.move_contact += 1

    if self.move_hit > 0:
        self.move_hit += 1

    if self.move_guarded > 0:
        self.move_guarded += 1

    if self.move_reversed > 0:
        self.move_reversed += 1

    if self.hit_by_1:
        self.hit_by_1.update()
    
    if self.hit_by_2:
        self.hit_by_2.update()

    if self.hit_shake_time > 0:
        self.hit_shake_time = self.hit_shake_time - 1
    elif self.hit_time > -1:
        self.hit_time = self.hit_time - 1

    if self.hit_shake_time < 0:
        self.hit_shake_time = 0

    if self.hit_time < 0:
        self.hit_time = 0

    if self.received_hit_def and self.stateno == constants.STATE_HIT_GET_UP and self.time == 0:
        self.received_hit_def.fall = 0

    for hit_override in self.hit_overrides:
        hit_override.update()

func update_physics():
    self.handle_physics()
    self.move_and_collide(self.velocity)
    self.handle_pushing()

func handle_physics():
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
            velocity += fight.stage.gravity

    self.handle_facing()

func handle_facing():
    var enemy = fight.get_nearest_enemy(self)

    if not enemy:
        return

    if is_facing_right == true and enemy.position.x >= position.x:
        return

    if is_facing_right == false and  enemy.position.x <= position.x:
        return

    if stateno == constants.STATE_STANDING and character_sprite.current_animation != 5 and not check_assert_special('noautoturn'):
        set_facing_right(not is_facing_right)
        change_anim(5)
        return

    if stateno == constants.STATE_WALKING and character_sprite.current_animation != 5 and not check_assert_special('noautoturn'):
        set_facing_right(not is_facing_right)
        change_anim(5)
        return

    if stateno == constants.STATE_CROUCHING and character_sprite.current_animation != 6 and not check_assert_special('noautoturn'):
        set_facing_right(not is_facing_right)
        change_anim(6)
        return

func handle_pushing():
    if not push_flag:
        return

    var enemies = fight.get_enemies(self)

    for enemy in enemies:
        if not enemy.push_flag:
            continue

        if not self.check_collision(enemy, 2):
            continue

        var overlap: float = 0
        var overlap_direction = 1

        if position.x >= enemy.position.x:
            overlap = enemy.get_right_location() - get_left_location()
            overlap_direction = -1
        else:
            overlap = get_right_location() - enemy.get_left_location()
            overlap_direction = 1

        if overlap < 0:
            continue

        enemy.position = enemy.position + Vector2(overlap * overlap_direction, 0)

func handle_hit_target(hit_def, attacker, blocked):
    self.received_hit_def = hit_def.duplicate()
    self.attacker = attacker
    self.blocked = blocked

    if self.is_falling:
        self.received_hit_def.fall = 1
    else:
        self.remaining_juggle_points = int(self.get_const('data.airjuggle'))
        print("remaining juggle points = %s" % [self.remaining_juggle_points])

    self.hit_count = self.hit_count + 1 if self.movetype == constants.FLAG_H else 1
    self.hit_state_type = self.statetype

    self.set_z_index(self.received_hit_def.p2sprpriority)
    self.ctrl = 0
    self.movetype = constants.FLAG_H

    if self.blocked:
        self.hit_shake_time = self.received_hit_def.guard_shaketime
        self.add_power(self.received_hit_def.p2_guard_power)
    else:
        self.hit_shake_time = self.received_hit_def.shaketime
        self.add_power(self.received_hit_def.p2_power)

        # TODO: Apply pallete fx

        if is_falling:
            self.remaining_juggle_points -= attacker.required_juggle_points

func handle_hit_attacker(hit_def, target, blocked):
    self.set_z_index(hit_def.p1sprpriority)

    if not self.targets.has(target):
        self.targets.append(target)

    if blocked:
        self.add_power(hit_def.p1_guard_power)
        hit_pause_time = hit_def.guard_pausetime
        move_contact = 1
        move_guarded = 1
        move_hit = 0
        move_reversed = 0
    else:
        self.add_power(hit_def.p1_power)
        hit_pause_time = hit_def.pausetime
        move_contact = 1
        move_guarded = 0
        move_hit = 1
        move_reversed = 0
