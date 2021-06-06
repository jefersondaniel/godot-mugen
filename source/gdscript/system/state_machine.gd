signal on_state(state)

var states: Dictionary = {}
var current_state: Object

class State:
    var name: String
    var transitions: Dictionary
    var listeners: Dictionary

    func _init(name: String):
        self.name = name
        self.transitions = {}
        self.listeners = {}

    func add_transition(state: State, event: String):
        if transitions.has(event):
            push_error("transition already existis: %s" % [event])
            return

        transitions[event] = state

func start(initial_state: State):
    set_state(initial_state)

func add_state(name: String) -> State:
    if states.has(name):
        push_warning("state already exists: %s" % [name])

    var state = State.new(name)
    states[name] = state
    return state

func get_state(name: String):
    return states[name]

func trigger(event: String):
    var new_state = current_state.transitions.get(event, null)

    if not new_state:
        push_error("invalid state transition: %s, state: %s" % [event, current_state.name])
        return

    set_state(new_state)

func set_state(state):
    current_state = state
    emit_signal("on_state", current_state)
