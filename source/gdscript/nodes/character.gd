extends KinematicBody2D

# Dependencies
var AnimationSprite = load('res://source/gdscript/nodes/sprite/animation_sprite.gd')
var StateManager = load('res://source/gdscript/nodes/character/state_manager.gd')
var SoundManager = load('res://source/gdscript/nodes/character/sound_manager.gd')
var HitAttribute = load('res://source/gdscript/nodes/character/hit_attribute.gd')
var Bind = load('res://source/gdscript/nodes/character/bind.gd')
var AttackState = load('res://source/gdscript/nodes/character/attack_state.gd')
var DefenseState = load('res://source/gdscript/nodes/character/defense_state.gd')

# Nodes and managers
var character_sprite = null
var command_manager = null
var state_manager = null
var sound_manager = null
var fight setget set_fight,get_fight
var fight_ref: WeakRef

# Private variables
var definition = null
var data = null
var state_defs = null
var attack_state = null
var defense_state = null
var bind = null
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
var remaining_juggle_points: int = 15
var required_juggle_points: int = 0
var string_variable_regex: RegEx
var base_z_index = 100
var posfreeze: int = 0
var clipboard: Array = []
var max_life setget ,get_max_life

# Public variables (will be available in expressions)
var fight_variables: Array = ['roundstate', 'roundno', 'matchover']
var state_variables: Array = []
var power: float = 0
var life: float = 0
var alive setget ,get_alive
var time: int = 0
var prevstateno: int = -1
var stateno: int = 0
var statetype: int = constants.FLAG_S
var physics: int = constants.FLAG_S
var movetype: int = constants.FLAG_I
var ctrl: int = 1
var team_number: int = 0
var roundsexisted: int = 0
var front_width_override: float = 0.0
var back_width_override: float = 0.0
var frontedge_width_override: float = 0.0
var backedge_width_override: float = 0.0

func setup(_definition, _data, _state_defs, sprite_bundle, animations, sounds, _command_manager):
    definition = _definition
    data = _data
    state_defs = _state_defs
    character_sprite = AnimationSprite.new(sprite_bundle, animations)
    command_manager = _command_manager
    state_manager = StateManager.new(self)
    sound_manager = SoundManager.new(sounds)
    bind = Bind.new(self)
    attack_state = AttackState.new(self)
    defense_state = DefenseState.new(self)

    info_localcoord = definition.info.localcoord
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

func _ready():
    self.add_child(character_sprite)
    self.add_child(sound_manager)
    character_sprite.change_anim(0)
    character_sprite.set_process(false)

func get_max_life() -> int:
    return data.data.life

func get_max_power():
    return data.data.power

func reset_round_state():
    # Meant to reset state between rounds
    ctrl = 0
    life = data.data.life
    attack_state.reset()
    defense_state.reset()
    remaining_juggle_points = 15
    required_juggle_points = 0
    special_flags.clear()

func get_const(fullname):
    if fullname == 'default.gethit.lifetopowermul' or fullname == 'default.attack.lifetopowermul':
        return 1 # TODO: Implement parsing global constants

    return data.get_value(fullname)

func is_falling():
    return movetype == constants.FLAG_H and defense_state.hit_def.fall

func get_hit_var(key):
    match key:
        'fall.envshake.time':
            return defense_state.hit_def.fall_envshake_time
        'fall.envshake.freq':
            return defense_state.hit_def.fall_envshake_freq
        'fall.envshake.ampl':
            return defense_state.hit_def.fall_envshake_ampl
        'fall.envshake.phase':
            return defense_state.hit_def.fall_envshake_phase
        'guarded':
            return defense_state.blocked
        'chainid':
            return defense_state.hit_def.chainid
        'fall':
            return is_falling()
        'fall.damage':
            return defense_state.hit_def.fall_damage
        'fall.recover':
            return defense_state.hit_def.fall_recover
        'fall.kill':
            return defense_state.hit_def.fall_kill
        'fall.recovertime':
            return defense_state.hit_def.fall_recovertime
        'fall.xvel':
            return defense_state.hit_def.fall_xvelocity
        'fall.yvel':
            return defense_state.hit_def.fall_yvelocity
        'recovertime':
            return 0 # TODO: implement this
        'hitcount':
            return defense_state.hit_count
        'xvel':
            return defense_state.get_hit_velocity().x
        'yvel':
            return defense_state.get_hit_velocity().y
        'type':
            if life == 0:
                return 3
            return get_hit_var('airtype') if defense_state.hit_state_type == constants.FLAG_A else get_hit_var('groundtype')
        'airtype':
            var airtype: String = defense_state.hit_def.air_type
            return constants.HIT_TYPE_ID[airtype] if constants.HIT_TYPE_ID.has(airtype) else 4
        'groundtype':
            var groundtype: String = defense_state.hit_def.ground_type
            return constants.HIT_TYPE_ID[groundtype] if constants.HIT_TYPE_ID.has(groundtype) else 0
        'animtype':
            var animtype: String = ''
            if is_falling():
                animtype = defense_state.hit_def.fall_animtype
            elif defense_state.hit_state_type == constants.FLAG_A:
                animtype = defense_state.hit_def.air_animtype
            else:
                animtype = defense_state.hit_def.animtype
            return constants.ANIM_TYPE_ID[animtype] if constants.ANIM_TYPE_ID.has(animtype) else null
        'damage':
            return defense_state.hit_def.hit_damage if not defense_state.blocked else defense_state.hit_def.guard_damage
        'hitshaketime':
            return defense_state.hit_shake_time
        'hittime':
            return defense_state.hit_time
        'slidetime':
            return defense_state.hit_def.ground_slidetime if not defense_state.blocked else defense_state.hit_def.guard_slidetime
        'ctrltime':
            return defense_state.hit_def.airguard_ctrltime if defense_state.hit_state_type == constants.FLAG_A else defense_state.hit_def.guard_ctrltime
        'xoff':
            return defense_state.hit_def.snap.x if defense_state.hit_def.snap else null
        'yoff':
            return defense_state.hit_def.snap.y if defense_state.hit_def.snap else null
        'yaccel':
            return defense_state.hit_def.yaccel
        'isbound':
            return bind.is_active and bind.is_target_bind
        _:
            printerr("Hit var not found: %s" % [key])
            return null

func get_relative_position():
    return Vector2(position.x, position.y - self.fight.stage.get_position_offset().y) / global_scale

func set_relative_position(newpos):
    newpos *= global_scale

    position.x = newpos.x if is_facing_right else newpos.x
    position.y = newpos.y + self.fight.stage.get_position_offset().y

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
        width += float(data.size.ground_front) * global_scale.x

    if is_air_state():
        width += float(data.size.air_front) * global_scale.x

    return width

func get_back_width() -> float:
    var width = back_width_override * global_scale.x

    if is_ground_state():
        width += float(data.size.ground_back) * global_scale.x

    if is_air_state():
        width += float(data.size.air_back) * global_scale.x

    return width

func is_ground_state() -> bool:
    return statetype == constants.FLAG_S or statetype == constants.FLAG_C or statetype == constants.FLAG_L

func is_air_state() -> bool:
    return statetype == constants.FLAG_A

func get_state_def(number: int):
    return state_defs[String(number)]

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
        return defense_state.hit_shake_time <= 0
    if key == "hitfall":
        return is_falling()
    if key == "hitover":
        return defense_state.hit_time <= 0
    if key == "canrecover":
        return is_falling() and defense_state.hit_def.fall_recover
    if key == "e":
        return 2.718281828
    if key == "pi":
        return PI
    if key == "random":
        randomize()
        return int(floor(rand_range(0, 999)))
    if key.begins_with("var."):
        return int_vars[int(key.substr(4, key.length() - 1))]
    if key in state_variables:
        return get(key)
    if key in fight_variables:
        return self.fight.get(key)
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
    if key == 'atan':
        return atan(arguments[0] if arguments[0] != null else 0)
    if key == 'const':
        return get_const(arguments[0])
    if key == 'cos':
        return cos(arguments[0])
    if key == 'ceil':
        return int(ceil(arguments[0]))
    if key == 'floor':
        return int(floor(arguments[0]))
    if key == 'exp':
        return exp(arguments[0])
    if key == 'ln':
        return log(arguments[0])
    if key == 'log':
        return log(arguments[1]) / log(arguments[0])
    if key == 'gethitvar':
        return get_hit_var(arguments[0])
    if key == 'sin':
        return sin(arguments[0])
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

func assert_special(key: String):
    key = key.to_lower()
    if key in constants.FIGHT_ASSERTIONS:
        self.fight.assert_special(key)
        return
    special_flags[key] = 1

func reset_assert_special():
    special_flags.clear()

func check_assert_special(key):
    key = key.to_lower()
    if key in constants.FIGHT_ASSERTIONS:
        return self.fight.check_assert_special(key)
    return special_flags.has(key)

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

func add_power(input_power):
    power = max(0, min(power + input_power, get_max_power()))

func add_life(input_life: int, kill: bool = true):
    life = max(0, min(life + input_life, get_max_life()))
    if not kill and life == 0:
        life = 1

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
    var result = defense_state.hit_def.attribute.satisfy(attribute)

    return result if operator == "=" else not result

func _process(_delta):
    draw_debug_text()

func draw_debug_text():
    if team_number != 1:
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

    get_node('/root/Node2D/debug/text').text = text

func cleanup():
    if attack_state.hit_pause_time > 1:
        in_hit_pause = true
        attack_state.hit_pause_time = attack_state.hit_pause_time - 1
    else:
        in_hit_pause = false
        attack_state.hit_pause_time = 0

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
        attack_state.handle_tick()
        defense_state.handle_tick()
        update_ko_state()

func update_ko_state():
    if life > 0 or defense_state.killed or assert_special(constants.ASSERTION_NOKO):
        return
    if not assert_special(constants.ASSERTION_NOKOSOUND):
        play_sound({"value": [11, 0]})
    defense_state.killed = true

func update_physics():
    if in_hit_pause or defense_state.hit_shake_time > 0:
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
    var stage = self.fight.stage
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
    var enemy = self.fight.get_nearest_enemy(self)

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
    var enemy = self.fight.get_nearest_enemy(self)

    if not enemy:
        return null

    return enemy.statetype

func get_enemy_stateno():
    var enemy = self.fight.get_nearest_enemy(self)

    if not enemy:
        return null

    return enemy.stateno

func get_enemy_movetype():
    var enemy = self.fight.get_nearest_enemy(self)

    if not enemy:
        return null

    return enemy.movetype

func update_z_index(new_index):
    z_index = base_z_index  + new_index

func get_stage():
    return self.fight.stage

func handle_physics():
    var ground_friction: float = 0
    var relative_position: Vector2 = get_relative_position()

    if physics == constants.FLAG_S:
        ground_friction = data.movement.stand_friction
    elif physics == constants.FLAG_C:
        ground_friction = data.movement.crouch_friction

    if physics == constants.FLAG_S or physics == constants.FLAG_C:
        if relative_position.y == 0:
            velocity.x = velocity.x * ground_friction

    if physics == constants.FLAG_A:
        if relative_position.y < 0:
            velocity += self.fight.stage.gravity

func handle_facing():
    if not ctrl:
        return

    var enemy = self.fight.get_nearest_enemy(self)

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

    var enemies = self.fight.get_enemies(self)

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

func find_targets(target_id: int):
    var results = []
    for target in attack_state.targets:
        if target_id == -1 or target_id == target.defense_state.hit_def.id:
            results.append(target)
    return results

func is_helper():
    return false

func remove_check():
    # TODO: Implement helper remove check
    pass

func set_fight(input_fight):
    fight_ref = weakref(input_fight)

func get_fight():
    return fight_ref.get_ref()

func get_alive():
    return self.life > 0
