var parser_helper = load('res://source/gdscript/helpers/parser_helper.gd').new()

var DEBUG = true

func hydrate_object(result, data):
    if typeof(data) == TYPE_ARRAY:
        data = __map_sections(data)

    var section_mapping = result.get("__SECTION_MAPPING__")
    if not section_mapping:
        section_mapping = {}

    for property in result.get_property_list():
        var mapped_section = section_mapping.get(property["name"], property["name"])

        if property["type"] == TYPE_OBJECT and data.has(mapped_section):
            self.hydrate_object_section(
                result.get(property["name"]),
                data[mapped_section],
                mapped_section
            )

func hydrate_object_section(result, data: Dictionary, parent_name: String):
    var propertie_mapper: Dictionary = {}
    var embeddings = []
    var embedding_mapping: Dictionary = {}

    data = __map_dict_keys(data)

    for subproperty in result.get_property_list():
        if subproperty["type"] == TYPE_OBJECT:
            embeddings.append(subproperty["name"])
        propertie_mapper[subproperty["name"]] = subproperty

    var invalidated_keys = []

    if propertie_mapper.has("__EMBEDDING_MAPPING__"):
        embedding_mapping = result.get("__EMBEDDING_MAPPING__")

    for embedding_key in embeddings:
        var embed_data = {}
        var embedding_prefix = embedding_mapping.get(embedding_key, embedding_key)
        var key_prefix: String = "%s_" % [embedding_prefix]

        for key in data:
            if not key.begins_with(key_prefix):
                continue
            invalidated_keys.append(key)
            var target_key = key.substr(len(key_prefix))
            embed_data[target_key] = data[key]

        var target = result.get(embedding_key)

        self.hydrate_object_section(
            target,
            embed_data,
            "%s.%s" % [parent_name, embedding_key]
        )

    for key in data:
        if invalidated_keys.has(key):
            continue
        hydrate_object_key(result, key, data[key], parent_name)

func hydrate_object_key(result, key, value, parent_name: String):
    var propertie_mapper: Dictionary = {}
    for subproperty in result.get_property_list():
        propertie_mapper[subproperty["name"]] = subproperty
    if not propertie_mapper.has(key):
        if DEBUG:
            print("hydrator: property not found: %s.%s" % [parent_name, key])
        return
    if not value.strip_edges():
        return
    var property = propertie_mapper[key]
    if property["type"] == TYPE_INT:
        result.set(key, int(value))
    elif property["type"] == TYPE_REAL:
        result.set(key, float(value))
    elif property["type"] == TYPE_STRING:
        if value.begins_with('"'):
            value = value.lstrip('"').rstrip('"')
        result.set(key, value)
    elif property["type"] == TYPE_VECTOR2:
        result.set(key, parser_helper.parse_vector(value))
    elif property["type"] == TYPE_RECT2:
        result.set(key, parser_helper.parse_rect(value))
    elif property["type"] == TYPE_ARRAY:
        result.set(key, value.split(","))
    elif property["type"] == TYPE_STRING_ARRAY:
        result.set(key, parser_helper.parse_string_aray(value))
    elif property["type"] == TYPE_REAL_ARRAY:
        result.set(key, parser_helper.parse_float_array(value))
    elif property["type"] == TYPE_INT_ARRAY:
        result.set(key, parser_helper.parse_int_array(value))
    else:
        push_error("unknown type: %s.%s = %s" % [parent_name, property["name"], property["type"]])

func __map_sections(sections):
    var data: Dictionary = {}
    for section in sections:
        var key = section["key"]
        if key.find("begin action") == -1 && key.find("bgdef") == -1 and key.find("bg ") == -1:
            key = key.replace(" ", "_")
        data[key] = section["attributes"]
    return data

func __map_dict_keys(input: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    for key in input:
        result[key.replace(".", "_").replace(" ", "_")] = input[key]
    return result
