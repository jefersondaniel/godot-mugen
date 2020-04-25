extends Object

var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()
var cns_parser = load('res://source/gdscript/parsers/cns_parser.gd').new()

var KEY_MAP: Dictionary = {
    'F': constants.KEY_F,
    'B': constants.KEY_B,
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

func read(path):
    var sections: Array = cfg_parser.read(path)
    var defaults: Dictionary = {}
    var remap: Dictionary = {}
    var commands: Array = []

    for section in sections:
        if section['key'] == 'defaults':
            for key in section['attributes']:
                defaults[key] = section['attributes'][key]
            continue

        if section['key'] == 'remap':
            for key in section['attributes']:
                defaults[key] = section['attributes'][key]
            continue

    var default_time: int = 1
    var default_buffer_time: int = 15

    if 'command.time' in defaults:
        default_time = int(defaults['command.time'])

    if 'command.buffer.time' in defaults:
        default_buffer_time = int(defaults['command.buffer.time'])

    for section in sections:
        if section['key'] != 'command':
            continue
        var command: Dictionary = section['attributes']
        var cmd: Array = []
        var name: String = command['name'].lstrip(" \"").rstrip(" \"")
        var actual_step
        var last_step

        for item in command['command'].split(',', false):
            var modifier: int = 0
            var ticks: int = -1
            var code: int = 0
            var is_actual_step_direction: int = 0
            var is_last_step_direction: int = 0
            var aux = null
            var should_expand_succesive_directions: bool = false

            item = item.strip_edges()

            if '~' in item:
                aux = int(item)
                if aux > 0:
                    ticks = aux
            if '/' in item:
                modifier += constants.KEY_MODIFIER_MUST_BE_HELD
            if '$' in item:
                modifier += constants.KEY_MODIFIER_DETECT_AS_4WAY
            if '>' in item:
                modifier += constants.KEY_MODIFIER_BAN_OTHER_INPUT

            for key_name in KEY_MAP.keys():
                if not key_name in item:
                    continue
                code += KEY_MAP[remap.get(key_name, key_name)]
                    
            actual_step = {
                'modifier': modifier,
                'ticks': ticks,
                'code': code,
            }

            is_actual_step_direction = actual_step['code'] & constants.ALL_DIRECTION_KEYS
            is_last_step_direction = last_step && (last_step['code'] & constants.ALL_DIRECTION_KEYS)
            should_expand_succesive_directions = is_actual_step_direction \
                && is_last_step_direction \
                && actual_step['code'] == last_step['code']

            if should_expand_succesive_directions:
                cmd.append({
                    'modifier': constants.KEY_MODIFIER_BAN_OTHER_INPUT,
                    'ticks': 0,
                    'code': code
                })

                cmd.append({
                    'modifier': constants.KEY_MODIFIER_BAN_OTHER_INPUT,
                    'ticks': -1,
                    'code': code
                })
            else:
                cmd.append(actual_step)

            last_step = actual_step

        commands.append({
            'name': name,
            'cmd': cmd,
            'time': int(command.get('time', default_time)),
            'buffer_time': min(max(int(command.get('buffer.time', default_buffer_time)), 30), 1),
        })

    return commands
