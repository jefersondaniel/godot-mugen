extends Node

var stateno: int = 0
var character: Object
var context: Object

class Context extends Object:
    var character: Object

    func _init(_character):
        character = _character

    func set_context_variable(key, value):
        pass

    func get_context_variable(key):
        if key == "command":
            return character.get_current_command()
        if key == "anim":
            return character.get_current_animation()
        elif key == "alive":
            return character.alive
        elif key == "vel_x":
            return character.vel_x
        elif key == "vel_y":
            return character.vel_y
        print("Variable not found: %s" % [key])

    func call_context_function(key, arguments):
        if key == 'abs':
            return abs(arguments[0] if arguments[0] != null else 0)
        elif key == 'const':
            var data = arguments[0].split(".", false, 1)
            if data[0] == 'states':
                return null
            return character.get_const(data[0], data[1])
        print("Method not found: %s, arguments: %s" % [key, arguments])

    func redirect_context(key):
        print("TODO: Trigger redirection")

func _init(_character):
    character = _character
    context = Context.new(_character)

func _process(_delta: float):
    #process_input_state()
    process_current_state()

func process_input_state():
    process_state(character.get_state(-1))

func process_current_state():
    process_state(character.get_state(stateno))

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
