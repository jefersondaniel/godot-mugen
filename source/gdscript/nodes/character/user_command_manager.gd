var input_prefix: String = ''
var input_map: Dictionary = {
    'U': constants.KEY_U,
    'D': constants.KEY_D,
    'a': constants.KEY_a,
    'b': constants.KEY_b,
    'c': constants.KEY_c,
    'x': constants.KEY_x,
    'y': constants.KEY_y,
    'z': constants.KEY_z,
    's': constants.KEY_s,
}

var buffer: Array
var buffer_size: int = 120
var buffer_index: int = -1
var command_countdown: Dictionary = {}
var commands: Array = []
var active_commands: Array = []
var is_facing_right: bool = true
var code: int = 0

func _init(_input_prefix):
    input_prefix = _input_prefix
    buffer = []
    buffer.resize(buffer_size)
    for i in range(0, buffer_size):
        buffer[i] = 0

func set_commands(_commands: Array) -> void:
    commands = _commands

    for command in commands:
        command_countdown[command['name']] = 0

func update(in_hit_pause: bool) -> void:
    update_input_buffer()
    update_command_countdown(in_hit_pause)
    check_commands(in_hit_pause)
    update_active_commands()

func update_input_buffer() -> void:
    buffer_index = buffer_index + 1

    if buffer_index >= buffer_size:
        buffer_index = 0

    code = 0

    if Input.is_action_pressed(input_prefix + 'F'):
        code += constants.KEY_F if is_facing_right else constants.KEY_B
    if Input.is_action_pressed(input_prefix + 'B'):
        code += constants.KEY_B if is_facing_right else constants.KEY_F

    for input in ['U', 'D', 'a', 'b', 'c', 'x', 'y', 'z', 's']:
        if Input.is_action_pressed(input_prefix + input):
            code += input_map[input]

    buffer[buffer_index] = code

func update_command_countdown(in_hit_pause: bool) -> void:
    if in_hit_pause:
        return

    for key in command_countdown:
        command_countdown[key] = max(0, command_countdown[key] - 1)

func check_commands(in_hit_pause: bool) -> void:
    for command in commands:
        if not check_command(command):
            continue

        var time: int = command['buffer_time']

        if in_hit_pause:
            time = time + 1

        command_countdown[command['name']] = time

func update_active_commands() -> void:
    active_commands = []

    for key in command_countdown:
        if command_countdown[key] <= 0:
            continue
        active_commands.push_back(key)

func check_command(command) -> bool:
    var element_index: int = len(command['cmd']) - 1
    var input_index: int = 0

    while input_index != buffer_size:
        var match_index: int = scan_for_match(command, element_index, input_index)

        if match_index == -1:
            return false

        if element_index > 0:
            if match_index > command['time']:
                return false
            element_index -= 1
            input_index = match_index
        elif element_index == 0:
            return match_index <= command['time']
        else:
            return false

        input_index += 1

    return false

func scan_for_match(command: Dictionary, element_index: int, input_index: int) -> int:
    var element: Dictionary = command['cmd'][element_index]
    var element_count: int = len(command['cmd'])
    var scan_length: int = min(buffer_size, command['time'])

    for i in range(input_index, input_index + scan_length):
        if element_index == element_count - 1:
            if element['ticks'] == -1:
                if i != input_index:
                    return -1
            elif i - 1  != input_index and i != input_index:
                return -1

        if element_match(element, i):
            if element_index < element_count - 1:
                var next_element = command['cmd'][element_index + 1]
                var nothing_else = (next_element['modifier'] & constants.KEY_MODIFIER_BAN_OTHER_INPUT) != 0
                if nothing_else and not check_identical_input(input_index, i):
                    continue

            return i

    return -1

func element_match(element: Dictionary, input_index: int) -> bool:
    var state: int = get_input_state(input_index, element)
    var must_be_held = (element['modifier'] & constants.KEY_MODIFIER_MUST_BE_HELD) != 0

    if must_be_held:
        return state == constants.INPUT_STATE_DOWN or state == constants.INPUT_STATE_PRESSED

    if element['ticks'] != -1:
        if input_index >= buffer_size:
            return false

        if input_index == 0 or get_input_state(input_index - 1, element) != constants.INPUT_STATE_RELEASED:
            return false

        var hold_count: int = 1

        for i in range(input_index + 1, buffer_size):
            if get_input_state(i, element) != constants.INPUT_STATE_DOWN:
                break
            hold_count += 1

        if hold_count < element['ticks']:
            return false
    elif state != constants.INPUT_STATE_PRESSED:
        return false

    return true

func get_input_value(index: int) -> int:
    return buffer[(buffer_index - index + buffer_size) % buffer_size]

func get_input_state(index: int, element: Dictionary) -> int:
    var current: int = get_input_value(index)
    var previous: int = get_input_value(index + 1) if index != buffer_size - 1 else 0

    var current_state: int = check_element_state(current, element)
    var previous_state: int = check_element_state(previous, element)

    if current_state:
        return constants.INPUT_STATE_DOWN if previous_state else constants.INPUT_STATE_PRESSED

    return constants.INPUT_STATE_RELEASED if previous_state else constants.INPUT_STATE_UP

func check_identical_input(start_index: int, end_index: int) -> bool:
    var input_value: int = get_input_value(start_index)

    for i in range(start_index + 1, end_index):
        if input_value != get_input_value(i):
            return false

    return true

func check_element_state(input_code: int, element: Dictionary) -> bool:
    var element_code: int = element['code']
    var use4_way: bool = (element['modifier'] & constants.KEY_MODIFIER_DETECT_AS_4WAY) != 0
    var key_down: bool = (input_code & element_code) == element_code

    if key_down && !use4_way:
        var input_direction: int = input_code & constants.ALL_DIRECTION_KEYS
        var element_direction: int = element_code & constants.ALL_DIRECTION_KEYS

        key_down = !element_direction || (input_direction == element_direction)

    return key_down
