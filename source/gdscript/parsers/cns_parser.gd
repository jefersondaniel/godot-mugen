var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()
var HitAttribute = load('res://source/gdscript/nodes/character/hit_attribute.gd')
var MugenExpression = load('res://source/native/mugen_expression.gdns')

func read(path):
    var sections = cfg_parser.read(path)

    var states = {
        '-3': {'controllers': []},
        '-2': {'controllers': []},
        '-1': {'controllers': []},
    }
    var current_state: String = ''

    var definitions = {
        'data': {},
        'size': {},
        'velocity': {},
        'movement': {},
        'quotes': {},
    }

    for section in sections:
        var key: String = section['key']

        if definitions.has(key):
            for attribute in section['attributes']:
                definitions[key][attribute] = section['attributes'][attribute]
            continue

        var statedef_idx: int = key.find('statedef')
        var start_index: int = 0
        var length: int = key.length()

        if statedef_idx == 0:
            start_index = statedef_idx + 9
            current_state = key.substr(start_index, length - start_index).strip_edges()
            if states.has(current_state) == false:
                states[current_state] = section['attributes']
                states[current_state]['number'] = key
                states[current_state]['controllers'] = []
            continue

        var state_idx = key.find('state ')

        if current_state != '' && state_idx == 0:
            if section['attributes'].has('type') == false:
                continue
            if section['attributes']['type'].to_lower() == 'null':
                continue
            states[current_state]['controllers'].append(parse_controller(section['attributes'], key))
            continue

    return {
        'data': definitions['data'],
        'size': definitions['size'],
        'velocity': definitions['velocity'],
        'movement': definitions['movement'],
        'quotes': definitions['quotes'],
        'states': states,
    }

func parse_controller(data: Dictionary, key: String):
    # This is used in cmd parser too
    var type: String = data['type'].to_lower()
    var controller: Dictionary = {
        'type': type,
        'key': key.strip_edges(),
    }

    for key in data:
        if key == 'type':
            continue

        var value = data[key]

        if key.substr(0, 7) == 'trigger':
            controller[key] = []
            for item in value:
                controller[key].append(parse_expression(item))
        else:
            if (type == 'hitby' || type == 'nothitby') and (key == "value" or key == "value2"):
                var hitattr = HitAttribute.new()
                hitattr.parse(value)
                controller[key] = hitattr
            elif type == 'hitoverride' and key == 'attr':
                var hitattr = HitAttribute.new()
                hitattr.parse(value)
                controller[key] = hitattr
            elif type == 'hitdef':
                # This will be parsed at state manager
                controller[key] = value.to_lower()
            else:
                controller[key] = parse_expression(value)

    return controller

func parse_expression(text):
    var expression = MugenExpression.new()
    expression.parse(text)
    if (expression.has_error()):
        push_error("%s: %s" % [text, expression.get_error_text()])
    return expression
