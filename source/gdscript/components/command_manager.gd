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

var buffer: Array
var buffer_size: int = 120
var buffer_index: int
var commands: Array
var current_command: String
var current_tick = 0
var is_facing_right: bool

func _init(_commands, _input_prefix, _is_facing_right):
    commands = _commands
    input_prefix = _input_prefix
    is_facing_right = _is_facing_right
    buffer = []
    for i in range(0, buffer_size):
        buffer.append({'code': 0, 'tick': 0})

func set_facing_right(value):
    is_facing_right = value

func get_current_command() -> String:
    return current_command

func _process(_delta: float):
    # TODO: Consider 60 ticks per second
    process_tick()
    current_tick += 1

func process_tick():
    var code: int = 0

    if Input.is_action_pressed(input_prefix + 'F'):
        code += constants.KEY_F if is_facing_right else constants.KEY_B
    if Input.is_action_pressed(input_prefix + 'B'):
        code += constants.KEY_B if is_facing_right else constants.KEY_F

    for input in ['U', 'D', 'a', 'b', 'c', 'x', 'y', 'z', 's']:
        if Input.is_action_pressed(input_prefix + input):
            code += input_map[input]

    current_command = ''
    buffer[buffer_index]['code'] = code
    buffer[buffer_index]['tick'] = current_tick

    var debug: bool = false

    for command in commands:
        if command['name'] == "FF":
            debug = false
        else:
            debug = false
        var n_time: int = -1
        var n_last_time: int = -1
        var curr_key_index: int = 0
        var cmd: Dictionary = command['cmd']
        var cmd_size: int = cmd.size()

        if debug:
            print("Start")
            print(cmd.size())
            print(cmd[0]['code'])
            print(constants.KEY_B)
            print(cmd[0]['code'] & constants.KEY_B != 0)

        for b in range(cmd_size - 1, -1, -1):
            var b_command: bool = false
            var modifier: int = cmd[b]['modifier']
            var game_ticks_to_hold: int = cmd[b]['ticks']
            var key_code: int = cmd[b]['code']
            var on_release: bool = (modifier & constants.KEY_MODIFIER_ON_RELEASE) != 0
            var on_hold: bool = (modifier & constants.KEY_MODIFIER_MUST_BE_HELD) != 0
            var use4_way: bool = (modifier & constants.KEY_MODIFIER_DETECT_AS_4WAY) != 0
            var ban_other_input: bool = (modifier & constants.KEY_MODIFIER_BAN_OTHER_INPUT) != 0

            while curr_key_index < buffer_size:
                var frame_input: Dictionary = buffer[(buffer_index - curr_key_index + buffer_size) % buffer_size]
                var key_down: bool = (frame_input['code'] & key_code) == key_code

                if key_down && !use4_way:
                    var key_code_dirs: int = key_code & constants.ALL_DIRECTION_KEYS
                    var frame_input_dirs: int = frame_input['code'] & constants.ALL_DIRECTION_KEYS
                    key_down = !key_code_dirs || (key_code_dirs == frame_input_dirs)

                var button_conditions_met: bool  = false

                # check hold time
                if on_release != key_down:
                    var game_ticks_held: int  = 0

                    for k in range(curr_key_index + 1, buffer_size):
                        var frame_input2: Dictionary = buffer[(buffer_index - k + buffer_size) % buffer_size]
                        var key_down2: bool = (frame_input2['code'] & code) == key_code
                        if key_down2 && !use4_way:
                            var key_code_dirs: int = key_code & constants.ALL_DIRECTION_KEYS
                            var frame_input_dirs: int = frame_input2['code'] & constants.ALL_DIRECTION_KEYS
                            key_down2 = !key_code_dirs || (key_code_dirs == frame_input_dirs)
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
                                button_conditions_met = b < cmd_size - 1
                                break
                        else:
                            button_conditions_met = !(on_hold || on_release)
                            break

                if button_conditions_met:
                    # if its the first element store the time of it
                    if b == 0:
                        n_time = frame_input['tick']

                    if b == (cmd_size - 1):
                        n_last_time = frame_input['tick']

                    b_command = true
                    curr_key_index += 1
                    break

                curr_key_index += 1

            if !b_command:
                break

        if n_time >= 0 and n_last_time > 0:
           # the last button of the sequenz must be pressed int the Current game tick to
           # be valid and then it must be check for how long it has taken to do the input
           if n_last_time >= (current_tick - command['buffer_time']) && (n_last_time - n_time) <= command['time']:
                current_command = command['name']
                print("Current command is: %s" % [current_command])
                break

        buffer_index = buffer_index + 1

        if buffer_index >= buffer_size:
            buffer_index = 0
