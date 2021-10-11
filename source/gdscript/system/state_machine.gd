var pending_activation: bool = false
var current_state = null

func _init(initial_state, payload = null):
    current_state = initial_state
    pending_activation = true

func update_tick():
    var next_state = null

    if pending_activation:
        next_state = current_state.activate()
        pending_activation = false

    if not next_state:
        next_state = current_state.update_tick()

    if next_state:
        current_state = next_state
        pending_activation = true
