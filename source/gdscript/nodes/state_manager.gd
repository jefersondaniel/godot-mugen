extends Node

var constants: Dictionary = {
    'data': {},
    'size': {},
    'velocity': {},
    'movement': {},
    'quotes': {},
    'states': {},
}

var stateno: int = 0

class Context extends Object:
    func set_context_variable(key, value):
        pass

    func get_context_variable(key):
        return 0

    func call_context_function(key, arguments):
        if key == 'abs':
            return abs(arguments[0] if arguments[0] != null else 0)
        elif key == 'const':
            return arguments[0]
        print("Method not found: %s, arguments: %s" % [key, arguments])

    func redirect_context(key):
        print("TODO: Trigger redirection")

var context = Context.new()

func _init(_constants):
    constants = _constants

func _process(_delta: float):
    #process_input_state()
    process_current_state()

func process_input_state():
    process_state(constants['states']['-1'])

func process_current_state():
    process_state(constants['states'][String(stateno)])

func process_state(state):
    for controller in state['controllers']:
        var will_activate: bool = true
        var triggerno: int = 1
        var triggerall = controller.get('triggerall', [])

        for trigger in triggerall:
            if not trigger.execute(context):
                will_activate = false
                break

        if not will_activate:
            continue

        while controller.has('trigger' + String(triggerno)):
            var triggers = controller.get('trigger' + String(triggerno), [])
            will_activate = true
            for trigger in triggers:
                if not trigger.execute(context):
                    triggerno += 1
                    will_activate = false
                    break
            if will_activate:
                break
            triggerno += 1

        if not will_activate:
            continue

        handle_state_controller(controller)

func handle_state_controller(controller):
    print(controller)
    pass
