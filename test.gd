extends SceneTree

var MugenExpression = load('res://source/native/mugen_expression.gdns')

class Context extends Object:
    var variables = {
        "command": "holddown",
    }
    var contexts = {}

    func set_context_variable(key, value):
        variables[key] = value

    func get_context_variable(key):
        return variables[key]

    func call_context_function(key, arguments):
        if key == "sqrt":
            return sqrt(arguments[0])
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
    execute_expression("sqrt(16)", context)
    execute_expression("life := 1000", context)
    execute_expression("helper, life := 100", context)
    execute_expression("life + (helper, life)", context)
    execute_expression("IfElse(command=\"holdup\", 10, 20)", context)
