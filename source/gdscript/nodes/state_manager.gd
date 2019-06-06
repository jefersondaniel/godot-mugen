extends Node

var character: Object
var var_regex: RegEx

func _init(_character):
    character = _character
    var_regex = RegEx.new()
    var_regex.compile("(?<type>(fvar|var)).(?<number>[0-9]+).")

func _process(_delta: float):
    process_input_state()
    process_current_state()
    character.time = character.time + 1

func process_input_state():
    process_state(character.get_state_def(-1))

func process_current_state():
    process_state(character.get_state_def(character.stateno))

func activate_state(stateno):
    var statedef = character.get_state_def(stateno)

    character.prevstateno = character.stateno
    character.stateno = stateno

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

    print("activate state: %s, previous: %s" % [stateno, character.prevstateno])

func process_state(state):
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

        handle_state_controller(state, controller)

func handle_state_controller(state, controller):
    var method_name: String = 'handle_%s' % [controller['type']]

    if has_method(method_name):
        self.call(method_name, state, controller)
        return

    push_warning("unhandled state type %s" % [controller['type']])

func handle_changestate(state, controller):
    if controller.has('ctrl'):
        character.ctrl = controller['ctrl'].execute(character)

    activate_state(controller['value'].execute(character))

func handle_changeanim(state, controller):
    # Todo handle element property
    character.change_anim(controller['value'].execute(character))

func handle_velset(state, controller):
    if 'x' in controller:
        character.velocity.x = controller['x'].execute(character)

    if 'y' in controller:
        character.velocity.y = controller['y'].execute(character)

func handle_varset(state, controller):
    var type: String
    var number: int
    var value

    for key in controller:
        var result = var_regex.search(key)
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
