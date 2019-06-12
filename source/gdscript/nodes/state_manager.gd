extends Node

var character: Object
var var_regex: RegEx
var trigger_counter: Dictionary = {}
var current_tick: int = 0

func _init(_character):
    character = _character
    var_regex = RegEx.new()
    var_regex.compile("(?<type>(fvar|var|sysvar|sysfvar)).(?<number>[0-9]+).")

func _physics_process(_delta: float):
    var oldstateno = character.stateno

    process_state(character.get_state_def(-1))
    process_state(character.get_state_def(-2))
    process_state(character.get_state_def(-3))

    if character.stateno == oldstateno:
        # If the state was changed, then its was already executed
        process_current_state()
    else:
        # TODO: Review assert special reset
        character.reset_assert_special()

    current_tick += 1
    character.time = character.time + 1

func process_current_state():
    process_state(character.get_state_def(character.stateno))

func activate_state(stateno):
    var statedef = character.get_state_def(stateno)

    trigger_counter = {}
    character.prevstateno = character.stateno
    character.stateno = stateno
    character.time = 0

    if statedef.has('anim'):
        character.change_anim(int(statedef['anim']))

    if statedef.has('ctrl'):
        character.ctrl = int(statedef['ctrl'])

    if statedef.has('type') && statedef['type'].to_lower() != 'u':
        character.statetype = constants.FLAGS[statedef['type'].to_lower()]
        # todo set default value when omitted

    if statedef.has('physics') && statedef['physics'].to_lower() != 'u':
        character.physics = constants.FLAGS[statedef['physics'].to_lower()]
        # todo set default value when omitted

    if statedef.has('sprpriority'):
        character.sprpriority = int(statedef['sprpriority'])

    print("activate state: %s, previous: %s, current_tick: %s" % [stateno, character.prevstateno, current_tick])

func process_state(state):
    var oldstateno = character.stateno

    for controller in state['controllers']:
        var will_activate: bool = true
        var triggerno: int = 1
        var triggerall = controller.get('triggerall', [])

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
                    triggerno += 1
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

func handle_state_controller(controller):
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

    self.call(method_name, controller)

func handle_changestate(controller):
    if controller.has('ctrl'):
        character.ctrl = controller['ctrl'].execute(character)

    activate_state(controller['value'].execute(character))
    process_state(character.get_state_def(character.stateno))

func handle_changeanim(controller):
    # Todo handle element property
    character.change_anim(controller['value'].execute(character))

func handle_velset(controller):
    if 'x' in controller:
        character.velocity.x = controller['x'].execute(character)

    if 'y' in controller:
        character.velocity.y = controller['y'].execute(character)

func handle_veladd(controller):
    if 'x' in controller:
        character.velocity.x += controller['x'].execute(character)

    if 'y' in controller:
        character.velocity.y += controller['y'].execute(character)

func handle_velmul(controller):
    if 'x' in controller:
        character.velocity.x *= controller['x'].execute(character)

    if 'y' in controller:
        character.velocity.y *= controller['y'].execute(character)

func handle_varset(controller):
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
        if type != 'var':
            print([key, type, number, controller[key].execute(character)])

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
    character.ctrl = controller['value'].execute(character)

func handle_posset(controller):
    var newpos = character.get_relative_position()

    if controller.has('x'):
        newpos.x = controller['x'].execute(character)

    if controller.has('y'):
        newpos.y = controller['y'].execute(character)

    character.set_relative_position(newpos)

func handle_posadd(controller):
    var oldpos = character.get_relative_position()
    var newpos = character.get_relative_position()

    if controller.has('x'):
        newpos.x += controller['x'].execute(character)

    if controller.has('y'):
        newpos.y += controller['y'].execute(character)

    character.set_relative_position(newpos)

func handle_assertspecial(controller):
    if controller.has('flag'):
        character.assert_special(controller['flag'].execute(character))
    if controller.has('flag2'):
        character.assert_special(controller['flag2'].execute(character))
    if controller.has('flag3'):
        character.assert_special(controller['flag3'].execute(character))
