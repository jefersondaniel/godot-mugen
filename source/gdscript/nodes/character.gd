extends KinematicBody2D

# Dependencies
var MugenSprite = load('res://source/gdscript/nodes/sprite.gd')
var StateManager = load('res://source/gdscript/nodes/character/state_manager.gd')
var SoundManager = load('res://source/gdscript/nodes/character/sound_manager.gd')
var HitAttribute = load('res://source/gdscript/nodes/character/hit_attribute.gd')
var HitOverride = load('res://source/gdscript/nodes/character/hit_override.gd')
var Bind = load('res://source/gdscript/nodes/character/bind.gd')

# Nodes and managers
var character_sprite = null
var command_manager = null
var state_manager = null
var sound_manager = null
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
var info_localcoord: Vector2 = Vector2(320, 240)
var int_vars: PoolIntArray
var float_vars: PoolRealArray
var sys_int_vars: PoolIntArray
var sys_float_vars: PoolRealArray
var velocity: Vector2 = Vector2(0, 0)
var acceleration: Vector2 = Vector2(0, 0)
var special_flags = {}
var push_flag: bool = true
var in_hit_pause: bool = false
var is_facing_right: bool = true
var hit_def = null
var received_hit_def = null
var hit_by_1 = null
var hit_by_2 = null
var bind = null
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
var defense_multiplier: float = 1
var attack_multiplier: float = 1
var string_variable_regex: RegEx
var base_z_index = 100
var posfreeze: int = 0
var clipboard: Array = []

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
var ctrl: int = 1
var team: int = 0
var front_width_override: float = 0.0
var back_width_override: float = 0.0
var frontedge_width_override: float = 0.0
var backedge_width_override: float = 0.0

func setup(_consts, images, animations, sounds, _command_manager):
    consts = _consts
    character_sprite = MugenSprite.new(images, animations)
    command_manager = _command_manager
    state_manager = StateManager.new(self)
    sound_manager = SoundManager.new(sounds)
    bind = Bind.new(self)

    alive = 1
    life = consts['data']['life']
    power = consts['data'].get('power', 1000)
    velocity = Vector2(0, 0)
    acceleration = Vector2(0, 0)
    setup_vars()

    var skip = true
    for p in self.get_property_list():
        if p['name'] == 'state_variables':
            skip = false
            continue
        if skip:
            continue
        state_variables.append(p['name'])

    global_scale = constants.get_scale(info_localcoord)
    z_index = base_z_index

    string_variable_regex = RegEx.new()
    string_variable_regex.compile("^f[0-9]+$")

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

    self.hit_overrides = []

    for i in range(0, 8):
        self.hit_overrides.append(HitOverride.new())

func _ready():
    self.add_child(character_sprite)
    self.add_child(sound_manager)

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

func is_falling():
    return movetype == constants.FLAG_H and received_hit_def and received_hit_def.fall

func get_hit_var(key):
    if not received_hit_def:
        return -1

    match key:
        'fall.envshake.time':
            return received_hit_def.fall_envshake_time
        'fall.envshake.freq':
            return received_hit_def.fall_envshake_freq
        'fall.envshake.ampl':
            return received_hit_def.fall_envshake_ampl
        'fall.envshake.phase':
            return received_hit_def.fall_envshake_phase
        'guarded':
            return blocked
        'chainid':
            return received_hit_def.chainid
        'fall':
            return is_falling()
        'fall.damage':
            return received_hit_def.fall_damage
        'fall.recover':
            return received_hit_def.fall_recover
        'fall.kill':
            return received_hit_def.fall_kill
        'fall.recovertime':
            return received_hit_def.fall_recovertime
        'fall.xvel':
            return received_hit_def.fall_xvelocity
        'fall.yvel':
            return received_hit_def.fall_yvelocity
        'recovertime':
            return 0 # implement this
        'hitcount':
            return hit_count
        'xvel':
            return get_hit_velocity().x
        'yvel':
            return get_hit_velocity().y
        'type':
            if life == 0:
                return 3
            return get_hit_var('airtype') if hit_state_type == constants.FLAG_A else get_hit_var('groundtype')
        'airtype':
            var airtype: String = received_hit_def.air_type
            return constants.HIT_TYPE_ID[airtype] if constants.HIT_TYPE_ID.has(airtype) else 4
        'groundtype':
            var groundtype: String = received_hit_def.ground_type
            return constants.HIT_TYPE_ID[groundtype] if constants.HIT_TYPE_ID.has(groundtype) else 0
        'animtype':
            var animtype: String = ''
            if is_falling():
                animtype = received_hit_def.fall_animtype
            elif hit_state_type == constants.FLAG_A:
                animtype = received_hit_def.air_animtype
            else:
                animtype = received_hit_def.animtype
            return constants.ANIM_TYPE_ID[animtype] if constants.ANIM_TYPE_ID.has(animtype) else null
        'damage':
            return received_hit_def.hit_damage if not blocked else received_hit_def.guard_damage
        'hitshaketime':
            return hit_shake_time
        'hittime':
            return hit_time
        'slidetime':
            return received_hit_def.ground_slidetime if not blocked else received_hit_def.guard_slidetime
        'ctrltime':
            return received_hit_def.airguard_ctrltime if hit_state_type == constants.FLAG_A else received_hit_def.guard_ctrltime
        'xoff':
            return received_hit_def.snap.x if received_hit_def.snap else null
        'yoff':
            return received_hit_def.snap.y if received_hit_def.snap else null
        'yaccel':
            return received_hit_def.yaccel
        'isbound':
            return bind.is_active and bind.is_target_bind
        _:
            printerr("Hit var not found: %s" % [key])
            return null

func get_relative_position():
    return Vector2(position.x, position.y - fight.stage.get_position_offset().y) / global_scale

func set_relative_position(newpos):
    newpos *= global_scale

    position.x = newpos.x if is_facing_right else newpos.x
    position.y = newpos.y + fight.stage.get_position_offset().y

func add_relative_position(vector):
    var newpos = get_relative_position()

    newpos.y += vector.y
    newpos.x += vector.x if is_facing_right else -vector.x

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
        return position.x + get_front_width()

    return position.x - get_front_width()

func get_back_location() -> float:
    if is_facing_right:
        return position.x - get_back_width()

    return position.x + get_back_width()

func get_front_width() -> float:
    var width = front_width_override * global_scale.x

    if is_ground_state():
        width += float(consts['size']['ground.front']) * global_scale.x

    if is_air_state():
        width += float(consts['size']['air.front']) * global_scale.x

    return width

func get_back_width() -> float:
    var width = back_width_override * global_scale.x

    if is_ground_state():
        width += float(consts['size']['ground.back']) * global_scale.x

    if is_air_state():
        width += float(consts['size']['air.back']) * global_scale.x

    return width

func is_ground_state() -> bool:
    return statetype == constants.FLAG_S or statetype == constants.FLAG_C or statetype == constants.FLAG_L

func is_air_state() -> bool:
    return statetype == constants.FLAG_A

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
        return character_sprite.get_current_animation()
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
    if key == "p2bodydist_x":
        return get_enemy_body_dist('x')
    if key == "p2bodydist_y":
        return get_enemy_body_dist('y')
    if key == "p2statetype":
        return get_enemy_statetype()
    if key == "p2stateno":
        return get_enemy_stateno()
    if key == "p2movetype":
        return get_enemy_movetype()
    if key == "sprpriority":
        return z_index
    if key == "hitshakeover":
        return hit_shake_time <= 0
    if key == "hitfall":
        return is_falling()
    if key == "hitover":
        return hit_time <= 0
    if key == "canrecover":
        return is_falling() and received_hit_def and received_hit_def.fall_recover
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
        return state_manager.evaluate_trigger(key)
    if string_variable_regex.search(key):
        return key
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
    if key == 'acos':
        return acos(arguments[0] if arguments[0] != null else 0)
    if key == 'asin':
        return asin(arguments[0] if arguments[0] != null else 0)
    if key == 'const':
        return get_const(arguments[0])
    if key == 'gethitvar':
        return get_hit_var(arguments[0])
    if key == 'const720p':
        return arguments[0] # todo, multiply by resolution
    if key == 'const240p':
        return arguments[0] # todo, multiply by resolution
    if key == 'selfanimexist':
        var animation_manager = character_sprite.animation_manager
        return animation_manager.has_animation(arguments[0])
    if key == 'animexist':
        var animation_manager = character_sprite.animation_manager
        if animation_manager.is_foreign_animation:
            return false
        return animation_manager.has_animation(arguments[0])
    if key == 'animelemtime':
        return character_sprite.get_animation_element_time(arguments[0])
    if key == 'animelemno':
        var time_offset = arguments[0]
        if time_offset == null:
            return null
        var animation = character_sprite.animation_manager.animation
        var check_time = character_sprite.animation_manager.animation_time + time_offset
        if check_time < 0:
            return null
        var element_index = animation.get_element_from_time(check_time).id
        return element_index + 1
    if key == 'sysvar':
        return sys_int_vars[arguments[0]]
    if key == 'sysfvar':
        return sys_float_vars[arguments[0]]
    if key == 'var':
        return int_vars[arguments[0]]
    if key == 'fvar':
        return float_vars[arguments[0]]
    if key == 'assertion':
        return check_assert_special(arguments[0])
    if key == 'hitdefattr':
        return check_hit_def_attr(arguments)
    if key == 'floor':
        return floor(arguments[0])
    push_warning("Context method not found: %s, arguments: %s" % [key, arguments])

func redirect_context(key):
    push_warning("TODO: Trigger redirection")

func change_anim(anim: int, elem_index: int = 0):
    character_sprite.change_anim(anim, elem_index)

func change_foreign_anim(foreign_animation_manager, value: int, elem_index: int = 0):
    character_sprite.change_foreign_anim(foreign_animation_manager, value, elem_index)

func get_animation_manager():
    return character_sprite.animation_manager

func change_state(value: int):
    state_manager.change_state(value)

func play_sound(parameters: Dictionary):
    sound_manager.play_sound(parameters)

func assert_special(flag: String):
    special_flags[flag.to_lower()] = 1

func reset_assert_special():
    for key in special_flags:
        special_flags[key] = special_flags[key] - 1

func check_assert_special(key):
    key = key.to_lower()
    return special_flags.has(key) && special_flags[key] > 0

func set_facing_right(value: bool):
    if is_facing_right == value:
        return
    character_sprite.set_facing_right(value)
    is_facing_right = value
    command_manager.is_facing_right = is_facing_right

func set_velocity_x(x):
    velocity.x = x

func set_velocity_y(y):
    velocity.y = y

func add_velocity(_velocity):
    velocity.x += _velocity.x
    velocity.y += _velocity.y

func mul_velocity(_velocity):
    velocity.x *= _velocity.x
    velocity.y *= _velocity.y

func get_hit_velocity() -> Vector2:
    var hit_velocity: Vector2 = Vector2(0, 0)

    if blocked:
        hit_velocity = received_hit_def.airguard_velocity if hit_state_type == constants.FLAG_A else Vector2(received_hit_def.guard_velocity, 0)
    else:
        hit_velocity = received_hit_def.air_velocity if hit_state_type == constants.FLAG_A else received_hit_def.ground_velocity
        if killed:
            hit_velocity.x = hit_velocity.x * 0.66 # TODO: Put this constant in global file
            hit_velocity.y = -6

    return hit_velocity

func add_power(_power):
    power = power + _power

func get_attack_power() -> float:
    var result = get_const('data.attack')
    return float(result) if result != null else 0.0

func get_defence_power() -> float:
    var result = get_const('data.defence')
    return float(result) if result != null else 0.0

func check_collision(other: Node2D, type: int):
    return self.character_sprite.check_collision(other.character_sprite, type)

func check_attack_collision(other: Node2D):
    return self.character_sprite.check_attack_collision(other.character_sprite)

func check_command(name: String) -> bool:
    return self.command_manager.active_commands.has(name)

func check_hit_def_attr(args: Array) -> bool:
    var operator: String = args.pop_front()
    var attribute = HitAttribute.parse(args)
    var result = received_hit_def.attribute.satisfy(attribute)

    return result if operator == "=" else not result

func _process(_delta):
    draw_debug_text()

func draw_debug_text():
    if team != 1:
        return

    var text = "stateno: %s, prevstateno: %s, anim: %s, animelem: %s, time: %s, animtime: %s, fps: %s\n" % [
        get_context_variable('stateno'),
        get_context_variable('prevstateno'),
        character_sprite.get_current_animation(),
        character_sprite.get_animation_element(),
        get_context_variable('time'),
        get_context_variable('animtime'),
        Engine.get_frames_per_second()
    ]

    text += "statetype: %s, movetype: %s, physics: %s, hittime: %s, pos: (%.1f, %.1f), vel: (%.1f, %.1f)\n" % [
        constants.REVERSE_FLAGS[get_context_variable('statetype')],
        constants.REVERSE_FLAGS[get_context_variable('movetype')],
        constants.REVERSE_FLAGS[get_context_variable('physics')],
        get_hit_var('hittime'),
        get_context_variable('pos_x'),
        get_context_variable('pos_y'),
        get_context_variable('vel_x'),
        get_context_variable('vel_y')
    ]

    text += "commands: %s, facing_right: %s\n" % [command_manager.active_commands, is_facing_right]

    get_node('/root/Node2D/hud/text').text = text

func cleanup():
    if hit_pause_time > 1:
        in_hit_pause = true
        hit_pause_time = hit_pause_time - 1
    else:
        in_hit_pause = false
        hit_pause_time = 0

    if not in_hit_pause:
        posfreeze = false
        push_flag = true
        front_width_override = 0.0
        back_width_override = 0.0
        frontedge_width_override = 0.0
        backedge_width_override = 0.0
        # TODO: apply friction
        # TODO: reset scale
        reset_assert_special()

func update_animation():
    if not in_hit_pause:
        character_sprite.handle_tick()

func update_input():
    command_manager.update(in_hit_pause)

func update_state():
    bind.update()

    state_manager.update()

    if not in_hit_pause:
        update_hit_state()

func update_hit_state():
    if move_contact > 0:
        move_contact += 1

    if move_hit > 0:
        move_hit += 1

    if move_guarded > 0:
        move_guarded += 1

    if move_reversed > 0:
        move_reversed += 1

    if hit_by_1:
        hit_by_1.handle_tick()

    if hit_by_2:
        hit_by_2.handle_tick()

    if hit_shake_time > 0:
        hit_shake_time = hit_shake_time - 1
    elif hit_time > -1:
        hit_time = hit_time - 1

    if hit_shake_time < 0:
        hit_shake_time = 0

    if hit_time < 0:
        hit_time = -1

    if received_hit_def and stateno == constants.STATE_HIT_GET_UP and time == 0:
        received_hit_def.fall = 0

    for hit_override in hit_overrides:
        hit_override.handle_tick()

func update_physics():
    if in_hit_pause or hit_shake_time > 0:
        return

    handle_physics()
    handle_facing()
    handle_movement()
    handle_pushing()

func handle_movement():
    var absolute_velocity = velocity if is_facing_right else Vector2(-velocity.x, velocity.y)
    var absolute_acceleration = acceleration if is_facing_right else Vector2(-acceleration.x, acceleration.y)

    if velocity and not posfreeze:
        position += absolute_velocity * global_scale
        handle_movement_restriction()

    velocity += absolute_acceleration

func handle_movement_restriction():
    var stage = fight.stage
    var viewport: Rect2 = stage.get_movement_area()
    var min_x: float = viewport.position.x
    var max_x: float = viewport.position.x + viewport.size.x
    var width: float = get_width()
    var left_position: float = get_left_position()
    var right_position: float = get_right_position()

    if left_position < min_x:
        position.x = min_x + width / 2

    if right_position > max_x:
        position.x = max_x - width / 2

func get_width() -> float:
    return get_back_width() + get_front_width()

func get_left_position() -> float:
    return position.x - (get_back_width() + get_front_width()) / 2

func get_right_position() -> float:
    return position.x + (get_back_width() + get_front_width()) / 2

func get_enemy_body_dist(axis: String):
    var enemy = fight.get_nearest_enemy(self)

    if not enemy:
        return null

    var p1_position = get_relative_position()
    var p2_position = enemy.get_relative_position()

    if axis == 'x':
        var p1_front_position = get_front_location()
        var p2_front_position = enemy.get_front_location()
        var distance = abs(p1_front_position - p2_front_position)
        if is_facing_right:
            return distance if p2_position.x > p1_position.x else -distance
        else:
            return -distance if p2_position.x > p1_position.x else distance
    elif axis == 'y':
        return p2_position.y - p1_position.y

    return null

func get_enemy_statetype():
    var enemy = fight.get_nearest_enemy(self)

    if not enemy:
        return null

    return enemy.statetype

func get_enemy_stateno():
    var enemy = fight.get_nearest_enemy(self)

    if not enemy:
        return null

    return enemy.stateno

func get_enemy_movetype():
    var enemy = fight.get_nearest_enemy(self)

    if not enemy:
        return null

    return enemy.movetype

func update_z_index(new_index):
    z_index = base_z_index  + new_index

func get_stage():
    return fight.stage

func get_fight():
    return fight

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

func handle_facing():
    if not ctrl:
        return

    var enemy = fight.get_nearest_enemy(self)

    if not enemy:
        return

    if is_facing_right == true and enemy.position.x >= position.x:
        return

    if is_facing_right == false and  enemy.position.x <= position.x:
        return

    if stateno == constants.STATE_STANDING and character_sprite.get_current_animation() != 5 and not check_assert_special('noautoturn'):
        set_facing_right(not is_facing_right)
        change_anim(5)
        return

    if stateno == constants.STATE_WALKING and character_sprite.get_current_animation() != 5 and not check_assert_special('noautoturn'):
        set_facing_right(not is_facing_right)
        change_anim(5)
        return

    if stateno == constants.STATE_CROUCHING and character_sprite.get_current_animation() != 6 and not check_assert_special('noautoturn'):
        set_facing_right(not is_facing_right)
        change_anim(6)
        return

func handle_pushing():
    # TODO: handle player height
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
        enemy.handle_movement_restriction()
        # TODO: Fix scale

func handle_hit_target(hit_def, attacker, blocked):
    self.received_hit_def = hit_def.duplicate()
    self.attacker = attacker
    self.blocked = blocked

    if self.is_falling():
        self.received_hit_def.fall = 1
    else:
        self.remaining_juggle_points = int(self.get_const('data.airjuggle'))

    self.hit_count = self.hit_count + 1 if self.movetype == constants.FLAG_H else 1
    self.hit_state_type = self.statetype

    self.update_z_index(self.received_hit_def.p2sprpriority)
    self.ctrl = 0
    self.movetype = constants.FLAG_H

    if self.blocked:
        self.hit_shake_time = self.received_hit_def.guard_shaketime
        self.add_power(self.received_hit_def.p2_guard_power)
    else:
        self.hit_shake_time = self.received_hit_def.shaketime
        self.add_power(self.received_hit_def.p2_power)

        # TODO: Apply pallete fx

        if is_falling():
            self.remaining_juggle_points -= attacker.required_juggle_points

func handle_hit_attacker(hit_def, target, blocked):
    self.z_index = hit_def.p1sprpriority

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

func find_targets(target_id: int):
    var results = []
    for target in targets:
        if target_id == -1 or target_id == target.received_hit_def.id:
            results.append(target)
    return results

func is_helper():
    return false

func remove_check():
    # TODO: Implement helper remove check
    pass

func find_hit_override(hit_def):
    for hit_override in hit_overrides:
        if not hit_override.is_active:
            continue
        if not hit_override.attribute.satisfy(hit_def.attribute):
            continue
        return hit_override
    return null
