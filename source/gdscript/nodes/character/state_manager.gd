extends Object

var HitDef = load('res://source/gdscript/nodes/character/hit_def.gd')
var HitAttribute = load('res://source/gdscript/nodes/character/hit_attribute.gd')
var HitBy = load('res://source/gdscript/nodes/character/hit_by.gd')

var INFINITE_LOOP_LIMIT = 1000

var character_ref: WeakRef
var var_regex: RegEx
var trigger_counter: Dictionary = {}
var trigger_names: Array = [
    'movecontact'
]
var foreign_manager = null # TODO: Implement foreign
var current_state = null

func _init(_character):
    character_ref = weakref(_character)
    var_regex = RegEx.new()
    var_regex.compile("(?<type>(fvar|var|sysvar|sysfvar)).(?<number>[0-9]+).")
    current_state = get_state(get_character().stateno, false)

func get_character():
    return character_ref.get_ref()

func evaluate_parameter(controller, key, default_value):
    if not controller.has(key):
        return default_value

    return controller[key].execute(get_character())

func update():
    # TODO: Implement helper state manager
    var character = get_character()

    if not foreign_manager:
        run_state(get_state(-3, true))
    run_state(get_state(-2, true))
    run_state(get_state(-1, true))
    run_current_state()

    if not character.in_hit_pause:
        character.time = character.time + 1

func get_state(stateno: int, force_self: bool):
    var character = get_character()
    if foreign_manager and not force_self:
        return foreign_manager.get_character().get_state_def(stateno)
    return character.get_state_def(stateno)

func run_current_state():
    var character = get_character()
    var infinite_loop_counter = 0
    while infinite_loop_counter < INFINITE_LOOP_LIMIT:
        var current_state_backup = current_state
        if character.time == -1:
            activate_state(current_state)
        run_state(current_state)
        if current_state_backup == current_state:
            break
        infinite_loop_counter += 1
    if infinite_loop_counter == INFINITE_LOOP_LIMIT:
        printerr("Infinite loop detected on changestate")

func activate_state(statedef):
    var character = get_character()
    character.time = 0

    trigger_counter = {}

    if statedef.has('anim'):
        character.change_anim(int(statedef['anim']))

    if statedef.has('ctrl'):
        character.ctrl = int(statedef['ctrl'])

    if statedef.has('type') && statedef['type'].to_lower() != 'u':
        character.statetype = constants.FLAGS[statedef['type'].to_lower()]
    elif not statedef.has('type'):
        character.statetype = constants.FLAG_S

    if statedef.has('movetype') && statedef['movetype'].to_lower() != 'u':
        character.movetype = constants.FLAGS[statedef['movetype'].to_lower()]
    elif not statedef.has('movetype'):
        character.movetype = constants.FLAG_I

    if statedef.has('physics') && statedef['physics'].to_lower() != 'u':
        character.physics = constants.FLAGS[statedef['physics'].to_lower()]
    elif not statedef.has('physics'):
        character.physics = constants.FLAG_N

    if statedef.has('sprpriority'):
        character.update_z_index(int(statedef['sprpriority']))

    if statedef.has('velset'):
        var velset = statedef['velset'].split_floats(",")
        character.set_velocity_x(velset[0])
        character.set_velocity_y(velset[1])

    if statedef.has('poweradd'):
        character.add_power(float(statedef['poweradd']))

    if statedef.has('juggle'):
        character.required_juggle_points = int(statedef['juggle'])

    var hitdefpersist: int = 0
    var movehitpersist: int = 0
    var hitcountpersist: int = 0

    if statedef.has('hitdefpersist'):
        hitdefpersist = int(statedef['hitdefpersist'])

    if statedef.has('movehitpersist'):
        movehitpersist = int(statedef['movehitpersist'])

    if statedef.has('hitcountpersist'):
        hitcountpersist = int(statedef['hitcountpersist'])

    if not hitdefpersist:
        character.is_hit_def_active = false
        character.hit_pause_time = 0

    if not movehitpersist:
        character.move_reversed = 0
        character.move_hit = 0
        character.move_guarded = 0
        character.move_contact = 0

    if not hitcountpersist:
        character.hit_count = 0
        character.unique_hit_count = 0

    # TODO: Implement facep2

func run_state(state):
    var character = get_character()
    var oldstateno = character.stateno

    for controller in state['controllers']:
        var will_activate: bool = true
        var triggerno: int = 1
        var triggerall = controller.get('triggerall', [])
        var ignorehitpause: int = 0

        if controller.has('ignorehitpause'):
            ignorehitpause = controller['ignorehitpause'].execute(character)

        if character.in_hit_pause and not ignorehitpause:
            continue

        for trigger in triggerall:
            if not trigger.execute(character):
                will_activate = false
                break

        if not will_activate:
            continue

        while controller.has('trigger' + String(triggerno)):
            var triggers = controller.get('trigger' + String(triggerno), [])
            will_activate = true
            for trigger in triggers:
                if not trigger.execute(character):
                    will_activate = false
                    break
            if will_activate:
                break
            triggerno += 1

        if not will_activate:
            continue

        handle_state_controller(controller)

        if oldstateno != character.stateno:
            # If the controller changed the state, skip the next controllers
            break

func change_state(stateno: int):
    var character = get_character()
    var state = get_state(stateno, false)

    if not state:
        printerr("Invalid state: %s" % [stateno])

    current_state = state
    character.time = -1
    character.prevstateno = character.stateno
    character.stateno = stateno

func handle_state_controller(controller):
    var character = get_character()

    if controller['type'] == 'null':
        return

    var method_name: String = 'handle_%s' % [controller['type']]

    if not has_method(method_name):
        push_warning("unhandled controller type %s" % [controller['type']])
        return

    if controller.has('persistent'):
        var persistence: int = controller['persistent'].execute(character)
        var counter: int = 1

        if trigger_counter.has(controller['key']):
            counter = trigger_counter[controller['key']]
        else:
            trigger_counter[controller['key']] = counter

        trigger_counter[controller['key']] += 1

        if persistence == 0 and counter > 1:
            return
        elif persistence > 0 and counter % persistence != 0:
            return

    return self.call(method_name, controller)

func handle_trigger(name):
    return self.handle_state_controller({
        'type': name
    })

func handle_debug(controller):
    var character = get_character()
    print('DEBUG: %s' % [controller['value'].execute(character)])

func handle_changestate(controller):
    var character = get_character()
    if controller.has('ctrl'):
        character.ctrl = controller['ctrl'].execute(character)
    if controller.has('anim'):
        character.change_anim(controller['anim'].execute(character))
    var stateno = controller['value'].execute(character)
    change_state(stateno)

func handle_selfstate(controller):
    foreign_manager = null
    handle_changestate(controller)

func handle_changeanim(controller):
    var character = get_character()
    var value: int = controller['value'].execute(character)
    var elem: int = 0

    if 'elem' in controller:
        elem = controller['elem'].execute(character)
        elem = int(max(elem - 1, 0)) # Convert ordinal to index

    character.change_anim(value, elem)

func handle_changeanim2(controller):
    var character = get_character()
    var value: int = controller['value'].execute(character)
    var elem: int = 0

    if 'elem' in controller:
        elem = controller['elem'].execute(character)
        elem = int(max(elem - 1, 0)) # Convert ordinal to index

    if foreign_manager == null:
        return

    var animation_manager = foreign_manager.get_character().get_animation_manager()
    character.change_foreign_anim(animation_manager, value, elem)

func handle_velset(controller):
    var character = get_character()
    if 'x' in controller:
        character.set_velocity_x(controller['x'].execute(character))

    if 'y' in controller:
        character.set_velocity_y(controller['y'].execute(character))

func handle_veladd(controller):
    var character = get_character()
    if 'x' in controller:
        character.add_velocity(Vector2(controller['x'].execute(character), 0))

    if 'y' in controller:
        character.add_velocity(Vector2(0, controller['y'].execute(character)))

func handle_velmul(controller):
    var character = get_character()
    if 'x' in controller:
        character.mul_velocity(Vector2(controller['x'].execute(character), 1))

    if 'y' in controller:
        character.mul_velocity(Vector2(1, controller['y'].execute(character)))

func handle_varset(controller):
    var character = get_character()
    var type: String
    var number: int
    var value

    for key in controller:
        var result = var_regex.search(key.to_lower())
        if not result:
            continue
        type = result.get_string('type')
        number = int(result.get_string('number'))
        value = controller[key].execute(character)

    if 'v' in controller:
        type = 'var'
        number = controller['v'].execute(character)
        value = controller['value'].execute(character)

    if 'fv' in controller:
        type = 'fvar'
        number = controller['v'].execute(character)
        value = controller['value'].execute(character)

    if not type:
        push_error("Invalid varset: [%s, %s, %s]" % [type, number, value])
        return

    if type == 'var':
        character.int_vars[number] = value
    elif type == 'fvar':
        character.float_vars[number] = value
    if type == 'sysvar':
        character.sys_int_vars[number] = value
    elif type == 'sysfvar':
        character.sys_float_vars[number] = value

func handle_ctrlset(controller):
    var character = get_character()
    character.ctrl = controller['value'].execute(character)

func handle_posset(controller):
    var character = get_character()
    var newpos = character.get_relative_position()

    if controller.has('x'):
        newpos.x = controller['x'].execute(character)

    if controller.has('y'):
        newpos.y = controller['y'].execute(character)

    character.set_relative_position(newpos)

func handle_posadd(controller):
    var character = get_character()
    var newpos = Vector2(0, 0)

    if controller.has('x'):
        newpos.x = controller['x'].execute(character)

    if controller.has('y'):
        newpos.y = controller['y'].execute(character)

    character.add_relative_position(newpos)

func handle_posfreeze(controller):
    var character = get_character()
    var value: int = 1

    if controller.has('value'):
        value = controller['value'].execute(character)

    character.posfreeze = value

func handle_assertspecial(controller):
    var character = get_character()
    if controller.has('flag'):
        character.assert_special(controller['flag'].execute(character))
    if controller.has('flag2'):
        character.assert_special(controller['flag2'].execute(character))
    if controller.has('flag3'):
        character.assert_special(controller['flag3'].execute(character))

func handle_defencemulset(controller):
    var character = get_character()
    var value = controller['value'].execute(character)
    if value == null:
        printerr("defencemulset: invalid value")
        return
    character.defense_multiplier = float(value)

func handle_attackmulset(controller):
    var character = get_character()
    var value = controller['value'].execute(character)
    character.attack_multiplier = float(value)

func handle_hitdef(controller):
    var character = get_character()
    var hit_def = HitDef.new()
    hit_def.parse(controller, character)
    character.hit_def = hit_def
    character.is_hit_def_active = true

func handle_hitvelset(controller):
    var character = get_character()
    var xflag = 1
    var yflag = 1

    if controller.has('x'):
        xflag = controller['x'].execute(character)

    if controller.has('y'):
        yflag = controller['y'].execute(character)

    var new_velocity = character.get_hit_velocity()

    if character.attacker.is_facing_right == character.is_facing_right:
        new_velocity.x = -new_velocity.x

    if not xflag:
        new_velocity.x = character.velocity.x

    if not yflag:
        new_velocity.x = character.velocity.x

    character.set_velocity_x(new_velocity.x)
    character.set_velocity_y(new_velocity.y)

func handle_hitfallvel(controller):
    var character = get_character()

    if not character.received_hit_def or not character.is_falling():
        return

    var hitdef = character.received_hit_def

    if hitdef.fall_xvelocity:
        character.set_velocity_x(hitdef.fall_xvelocity)

    character.set_velocity_y(hitdef.fall_yvelocity)

func handle_hitfallset(controller):
    var character = get_character()

    if not character.received_hit_def:
        return

    var value = -1
    var yvel = null
    var xvel = null

    if controller.has('value'):
        value = controller['value'].execute(character)

    if controller.has('yvel'):
        yvel = controller['yvel'].execute(character)

    if controller.has('xvel'):
        xvel = controller['xvel'].execute(character)

    if value == 1 or value == 0:
        character.received_hit_def.fall = value

    if xvel != null:
        character.received_hit_def.fall_xvelocity = xvel

    if yvel != null:
        character.received_hit_def.fall_yvelocity = yvel

func handle_movecontact(controller):
    var character = get_character()
    return character.move_contact if character.movetype == constants.FLAG_A else 0

func handle_sprpriority(controller):
    var character = get_character()
    var value = controller['value'].execute(character)
    character.update_z_index(value)

func handle_statetypeset(controller):
    var character = get_character()
    if controller.has('statetype'):
        character.statetype = controller['statetype'].execute(character)

    if controller.has('movetype'):
        character.movetype = controller['movetype'].execute(character)

    if controller.has('physics'):
        character.physics = controller['physics'].execute(character)

func handle_playsnd(controller):
    var character = get_character()
    var parameters: Dictionary = {
        'value': controller['value'].execute(character),
    }

    character.play_sound(parameters)

func handle_fallenvshake(_controller):
    var character = get_character()
    var hit_def = character.received_hit_def
    var stage = character.get_stage()

    if not hit_def:
        push_error("Invalid fallenvshake, not hitdef")

    stage.setup_envshake(
        float(hit_def.fall_envshake_time),
        hit_def.fall_envshake_freq,
        hit_def.fall_envshake_ampl,
        float(hit_def.fall_envshake_phase)
    )

func handle_envshake(controller):
    var character = get_character()
    var stage = character.get_stage()
    var time = evaluate_parameter(controller, 'time', 1)
    var freq = evaluate_parameter(controller, 'freq', 60)
    var ampl = evaluate_parameter(controller, 'ampl', -4) # TODO: Defaults to -4 in 240p, -8 in 480p, -16 in 720p.
    var phase = evaluate_parameter(controller, 'phase', 90)

    stage.setup_envshake(time, freq, ampl, phase)

func handle_hitfalldamage(_controller):
    var character = get_character()
    var hit_def = character.received_hit_def
    var attacker = character.attacker
    var fight = character.get_fight()

    if not hit_def or not attacker:
        push_error("Invalid hitfalldamage")

    fight.apply_damage(attacker, character, hit_def.fall_damage, hit_def.kill)

func apply_hit_by(controller, is_negation: bool):
    var character = get_character()
    var value1 = controller['value'] if controller.has('value') else null
    var value2 = controller['value2'] if controller.has('value2') else null
    var time: int = controller['time'].execute(character)

    if value1 and value2:
        push_error("Only one of the value parameters can be specified")
        return

    if not value1 and not value2:
        push_error("Invalid hitattribute")
        return

    var hit_attribute = value1 if value1 else value2
    var slot: int = 1 if value1 else 2
    var hit_by = HitBy.new()

    hit_by.setup(hit_attribute, time, is_negation)

    if slot == 1:
        character.hit_by_1 = hit_by
    else:
        character.hit_by_2 = hit_by

func handle_nothitby(controller):
    self.apply_hit_by(controller, true)

func handle_hitby(controller):
    self.apply_hit_by(controller, false)

func handle_hitoverride(controller):
    var character = get_character()
    var attr = controller['attr'] if controller.has('attr') else null
    var stateno = controller['stateno'].execute(character)
    var slot = evaluate_parameter(controller, 'slot', 0)
    var time = evaluate_parameter(controller, 'time', 1)
    var forceair = evaluate_parameter(controller, 'forceair', 0)

    if not attr:
        printerr("hitoverride: invalid attr: %s" + attr)
        return

    character.hit_overrides[slot].setup(
        attr,
        stateno,
        time,
        forceair
    )

func handle_targetbind(controller):
    var character = get_character()
    var target_id: int = -1
    var pos = [0, 0]
    var time = 1

    if 'time' in controller:
        time = controller['time'].execute(character)
    if 'id' in controller:
        target_id = controller['id'].execute(character)
    if 'pos' in controller:
        pos = controller['pos'].execute(character)

    for target in character.find_targets(target_id):
        target.bind.setup(character, Vector2(pos[0], pos[1]), time, 0, true)

func handle_turn(controller):
    var character = get_character()
    character.set_facing_right(not character.is_facing_right)

func handle_targetfacing(controller):
    var character = get_character()
    var target_id: int = -1 # Specifies the desired target ID to affect. Only targets with this target ID will be affected. Defaults to -1 (affects all targets.)
    var value = 0 # If facing_val is positive, all targets will turn to face the same direction as the player. If facing_val is negative, all targets will turn to face the opposite direction as the player.

    if 'id' in controller:
        target_id = controller['id'].execute(character)

    if 'value' in controller:
        value = controller['value'].execute(character)

    for target in character.find_targets(target_id):
        if value > 0:
            target.set_facing_right(character.is_facing_right)
        if value < 0:
            target.set_facing_right(not character.is_facing_right)

func handle_targetlifeadd(controller):
    var character = get_character()
    var target_id: int = -1 # Specifies the desired target ID to affect. Only targets with this target ID will be affected. Defaults to -1 (affects all targets.)
    var value = 0 # value is added toe ach target's life.
    var kill = 1 # If kill is 0, then the addition will not take any player below 1 life point. Defaults to 1.
    var absolute = 0 # If absolute is 1, then value will not be scaled (i.e. attack and defense multipliers will be ignored). Defaults to 0.

    if 'id' in controller:
        target_id = controller['id'].execute(character)

    if 'value' in controller:
        value = controller['value'].execute(character)

    if 'kill' in controller:
        kill = controller['kill'].execute(character)

    if 'absolute' in controller:
        absolute = controller['absolute'].execute(character)

    if not value:
        return

    for target in character.find_targets(target_id):
        var new_value = value
        if not absolute and new_value < 0:
            new_value = int(new_value * character.attack_multiplier)
            new_value = int(new_value / target.defense_multiplier)
        target.life += new_value
        if target.life < 0 and not kill:
            target.life = 1

func handle_targetpoweradd(controller):
    var character = get_character()
    var target_id = evaluate_parameter(controller, 'id', -1)
    var value = evaluate_parameter(controller, 'value', 0)

    for target in character.find_targets(target_id):
        target.power += value

func handle_targetstate(controller):
    var character = get_character()
    var target_id: int = -1 # Specifies the number of the state to change the targets to.
    var value = 0 # value is added toe ach target's life.

    if 'id' in controller:
        target_id = controller['id'].execute(character)

    if 'value' in controller:
        value = controller['value'].execute(character)

    for target in character.find_targets(target_id):
        target.state_manager.foreign_manager = self
        target.change_state(value)

func handle_width(controller):
    var character = get_character()
    var player = null
    var edge = null
    var value = null

    if controller.has('player'):
        player = controller['player'].execute(character)

    if controller.has('edge'):
        edge = controller['edge'].execute(character)

    if controller.has('value'):
        value = controller['value'].execute(character)

    if value != null:
        player = value
        edge = value

    if player:
        character.front_width_override = player[0]
        character.back_width_override = player[1]

    if edge:
        character.frontedge_width_override = edge[0]
        character.backedge_width_override = edge[1]

func handle_attackdist(controller):
    # Changes the value of the guard.dist parameter for the player's current HitDef.
    # The guard.dist is the x-distance from P1 in which P2 will go into a guard state if P2 is holding the
    # direction away from P1. The effect of guard.dist only takes effect when P1 has movetype = A.
    var character = get_character()
    var value = controller['value'].execute(character)

    if not value or not character.hit_def:
        printerr("attackdist: invalid value or missing hitdef")
        return

    character.hit_def.guard_dist = value

func handle_lifeadd(controller):
    var character = get_character()
    var value = evaluate_parameter(controller, 'value', 0) # Specifies amount of life to add to the player's life bar.
    var kill = evaluate_parameter(controller, 'kill', 1) # If kill_flag is 0, then the addition will not take the player below 1 life point. Defaults to 1
    var absolute = evaluate_parameter(controller, 'absolute', 0) # If abs_flag is 1, then exactly add_amt is added to the player's life (the defense multiplier is ignored). Defaults to 0.

    if value == null:
        printerr("lifeadd: invalid value")
        return

    if not absolute:
        value = int(value / character.defense_multiplier)

    character.life += value

    if character.life <= 0 and not kill:
        character.life = 1

func handle_lifeset(controller):
    var character = get_character()
    var value = evaluate_parameter(controller, 'value', 0) # Specifies amount of life that the player will have after execution.
    character.life = value

func handle_powerset(controller):
    var character = get_character()
    var value = evaluate_parameter(controller, 'value', 0) # Specifies amount of life that the player will have after execution.
    character.power = value

func handle_poweradd(controller):
    var character = get_character()
    var value = evaluate_parameter(controller, 'value', 0) # Specifies amount of life that the player will have after execution.
    character.power += value

func handle_makedust(controller):
    # TODO: http://www.elecbyte.com/mugendocs/sctrls.html#makedust
    pass

func handle_explod(controller):
    # TODO: http://www.elecbyte.com/mugendocs/sctrls.html#explod
    pass

func handle_forcefeedback(controller):
    # TODO: http://www.elecbyte.com/mugendocs/sctrls.html#forcefeedback
    pass

func handle_displaytoclipboard(controller):
    pass

func handle_appendtoclipboard(controller):
    pass
