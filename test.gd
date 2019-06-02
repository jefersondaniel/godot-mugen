extends SceneTree

var MugenExpression = load('res://source/native/mugen_expression.gdns')

class Context extends Object:
    var variables = {
        "command": "holddown",
        "screenpos_x": 400,
        "screenpos_y": 300,
        "gamewidth": 720,
        "gameheight": 1000,
        "gametime": 27,
        "fall.vel": 10,
        "a": "a",
        "ha": "ha",
        "sa": "sa",
        "hitfall": false,
        "lala": ["a", 1, true],
    }
    var contexts = {}

    func set_context_variable(key, value):
        variables[key] = value

    func get_context_variable(key):
        return variables[key]

    func call_context_function(key, arguments):
        if key == "sqrt":
            return sqrt(arguments[0])
        if key == "hitdefattr":
            # var op = arguments[0]
            # var values = arguments[1]
            # var check = 'ha' in values
            # return check if op == "=" else !check
            return true
        if key == "debug":
            print("DEBUG: %s" % [arguments[0]])
            return arguments[0]
        print("method not found %s" % [key])

    func redirect_context(key):
        if not contexts.get(key):
            contexts[key] = Context.new();
        return contexts[key]

func execute_expression(name, context):
    var expression = MugenExpression.new()
    expression.parse(name)
    print(name)
    if (expression.has_error()):
        print(expression.get_error_text())
    print(expression.execute(context))

func _init():
    var context = Context.new()
    execute_expression("-sqrt(9)", context)
    execute_expression("debug(16, 16)", context)
    execute_expression("16, 16", context)
    execute_expression("life := 1000", context)
    execute_expression("helper, life := 100", context)
    # execute_expression("life, helper, (life, life)", context)
    execute_expression("life + (helper, life)", context)
    execute_expression("IfElse(command=\"holdup\", 10, 20)", context)
    execute_expression("ScreenPos Y < GameHeight / 2", context)
    execute_expression("(GameTime % 27) = 0", context)
    execute_expression("ScreenPos X >= GameWidth / 2", context)
    execute_expression("fall.vel", context)
    execute_expression("HitDefAttr = A, SA, HA", context)
    execute_expression("HitDefAttr = A, SA", context)
    execute_expression("!HitFall", context)
    execute_expression("debug(\"Some variable\")", context)
    execute_expression("debug(lala)", context)
    execute_expression("debug(lala)", context)
