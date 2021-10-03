var pending_activation: bool = false
var current_state = null

func _init(initial_state, payload = null):
    current_state = initial_state
    pending_activation = true

func update_tick():
    if pending_activation:
        current_state.activate()
        pending_activation = false

    var next_state = current_state.update_tick()

    if next_state != null:
        current_state = next_state
        pending_activation = true
