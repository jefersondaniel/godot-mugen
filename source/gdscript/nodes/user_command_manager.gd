extends Node

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

var buffer: Array = []
var buffer_size: int = 120
var buffer_index: int
var commands: Array = []
var old_active_commands: Array = []
var active_commands: Array = []
var current_tick = 0
var is_facing_right: bool = true
var code: int = 0

func _init(_input_prefix):
    input_prefix = _input_prefix
    for i in range(0, buffer_size):
        buffer.append({'code': 0, 'tick': 0})

func set_commands(_commands: Array):
    commands = _commands

func handle_tick(_delta: float):
    code = 0

    if Input.is_action_pressed(input_prefix + 'F'):
        code += constants.KEY_F if is_facing_right else constants.KEY_B
    if Input.is_action_pressed(input_prefix + 'B'):
        code += constants.KEY_B if is_facing_right else constants.KEY_F

    for input in ['U', 'D', 'a', 'b', 'c', 'x', 'y', 'z', 's']:
        if Input.is_action_pressed(input_prefix + input):
            code += input_map[input]

    process_command()
    current_tick += 1

func process_command():
    old_active_commands = active_commands
    active_commands = []
    buffer[buffer_index]['code'] = code
    buffer[buffer_index]['tick'] = current_tick

    # Check every command in the definition order
    for command in commands:
        var start_time: int = -1 # Command start time
        var end_time: int = -1 # Command end time
        var input_index_distance: int = 0 # Input item that is being verified, 0 means the last 
        var steps: Dictionary = command['cmd']
        var num_command_steps: int = steps.size()

        for step_index in range(num_command_steps - 1, -1, -1):
            var step_match: bool = false
            var modifier: int = steps[step_index]['modifier']
            var game_ticks_to_hold: int = steps[step_index]['ticks']
            var key_code: int = steps[step_index]['code']
            var on_release: bool = (modifier & constants.KEY_MODIFIER_ON_RELEASE) != 0
            var on_hold: bool = (modifier & constants.KEY_MODIFIER_MUST_BE_HELD) != 0
            var use4_way: bool = (modifier & constants.KEY_MODIFIER_DETECT_AS_4WAY) != 0
            var ban_other_input: bool = false
            var distance_between_steps: int = 0

            if step_index < num_command_steps - 1:
                ban_other_input = (steps[step_index + 1]['modifier'] & constants.KEY_MODIFIER_BAN_OTHER_INPUT) != 0

            while input_index_distance < buffer_size:
                var input_frame: Dictionary = buffer[(buffer_index - input_index_distance + buffer_size) % buffer_size]
                var key_down: bool = (input_frame['code'] & key_code) == key_code

                if key_down && !use4_way:
                    var key_code_direction: int = key_code & constants.ALL_DIRECTION_KEYS
                    var input_frame_direction: int = input_frame['code'] & constants.ALL_DIRECTION_KEYS
                    key_down = !key_code_direction || (key_code_direction == input_frame_direction)

                var button_conditions_met: bool  = false

                # check hold time
                # if on release is true, then the conditions will be met if actual key is not down, but the previous are down
                if on_release != key_down:
                    var game_ticks_held: int  = 0

                    for k in range(input_index_distance + 1, buffer_size):
                        var input_frame2: Dictionary = buffer[(buffer_index - k + buffer_size) % buffer_size]
                        var key_down2: bool = (input_frame2['code'] & key_code) == key_code
                        if key_down2 && !use4_way:
                            var key_code_direction: int = key_code & constants.ALL_DIRECTION_KEYS
                            var input_frame_direction: int = input_frame2['code'] & constants.ALL_DIRECTION_KEYS
                            key_down2 = !key_code_direction || (key_code_direction == input_frame_direction)
                        if key_down2:
                            game_ticks_held += 1
                            if on_hold:
                                button_conditions_met = key_down
                                break
                            elif on_release:
                                if game_ticks_held >= game_ticks_to_hold:
                                    button_conditions_met = true
                                    break
                            else:
                                button_conditions_met = step_index < num_command_steps - 1
                                break
                        else:
                            button_conditions_met = !(on_hold || on_release)
                            break

                if button_conditions_met:
                    # if its the first element store the time of it
                    if step_index == 0:
                        start_time = input_frame['tick']

                    if step_index == (num_command_steps - 1):
                        end_time = input_frame['tick']

                    step_match = true
                    input_index_distance += 1
                    break

                var next_input_frame: Dictionary = buffer[(buffer_index - (input_index_distance - 1) + buffer_size) % buffer_size]
                # as the input is checked in reversal order, the next input frame is the previously checked frame

                if not key_down and ban_other_input and distance_between_steps and input_frame['code'] != next_input_frame['code']:
                   break

                # If button conditions not met, check next previous input
                input_index_distance += 1
                distance_between_steps += 1

            if !step_match:
                break

        if start_time >= 0 and end_time > 0:
           # the last button of the sequenz must be pressed int the Current game tick to
           # be valid and then it must be check for how long it has taken to do the input
           # print([current_tick, command['buffer_time'], command['time'], command['name'], (end_time - start_time)])
           if end_time >= (current_tick - command['buffer_time']) && (end_time - start_time) <= command['time']:
                active_commands.push_back(command['name'])

    buffer_index = buffer_index + 1

    if old_active_commands != active_commands:
        print("active commands: %s" % [active_commands])

    if buffer_index >= buffer_size:
        buffer_index = 0
