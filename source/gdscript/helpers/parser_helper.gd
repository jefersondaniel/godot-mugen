
func parse_int_array(value: String):
    var raw_values = value.split(',')
    var values = []
    for value in raw_values:
        values.append(int(value))
    return values

func parse_float_array(value: String):
    var raw_values = value.split(',')
    var values = []
    for value in raw_values:
        values.append(float(value))
    return values

func parse_vector(value):
    var raw_values = [0, 0]

    if typeof(value) == TYPE_STRING:
        raw_values = value.split(',')
    elif typeof(value) == TYPE_ARRAY:
        raw_values = value
    elif value:
        raw_values = [value]

    var vector: Vector2 = Vector2(0, 0)

    if raw_values.size() > 0:
        vector.x = float(raw_values[0])
    if raw_values.size() > 1:
        vector.y = float(raw_values[1])

    return vector
