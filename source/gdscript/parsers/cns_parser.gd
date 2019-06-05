extends Object

var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()
var MugenExpression = load('res://source/native/mugen_expression.gdns')

func read(path):
    var data = cfg_parser.read(path, false)
    var states = {
        '-3': {'controllers': []},
        '-2': {'controllers': []},
        '-1': {'controllers': []},
    }
    var item_name: String = ''

    for key in data:
        var statedef_idx: int = key.find('statedef')
        var start_index: int = 0
        var length: int = key.length()

        if statedef_idx == 0:
            start_index = statedef_idx + 9
            item_name = key.substr(start_index, length - start_index).strip_edges()
            states[item_name] = data[key]
            states[item_name]['controllers'] = []
            continue

        var state_idx = key.find('state')
        var comma_idx: int = key.find(',')

        if state_idx == 0 and comma_idx > 0:
            start_index = state_idx + 6
            item_name = key.substr(start_index, comma_idx - start_index).strip_edges()
            if item_name in states:
                states[item_name]['controllers'].append(parse_controller(data[key]))
            continue

    return {
        'data': data.get('data', {}),
        'size': data.get('size', {}),
        'velocity': data.get('velocity', {}),
        'movement': data.get('movement', {}),
        'quotes': data.get('quotes', {}),
        'states': states,
    }

func parse_controller(data: Dictionary):
    # This is used in cmd parser too
    var type: String = data['type'].to_lower()
    var controller: Dictionary = {
        'type': type,
    }

    for key in data:
        if key == 'type':
            continue

        var value: String = data[key]

        if key.substr(0, 7) == 'trigger':
            controller[key] = []
            for item in value:
                controller[key].append(parse_expression(item))
        else:
            if (type == 'hitby' || type == 'nothitby') and (key == "value" or key == "value2"):
                # Hit def attributes can omit the first argument, example attr = , NA
                # this means that any of the first argument is applyed: S, C or A
                if value.substr(0, 1) == ",":
                    value = "SCA" + value
            controller[key] = parse_expression(value)

    return controller

func parse_expression(text):
    var expression = MugenExpression.new()
    expression.parse(text)
    if (expression.has_error()):
        push_error("%s: %s" % [text, expression.get_error_text()])
    return expression
