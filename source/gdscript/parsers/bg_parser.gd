var cfg_parser = load("res://source/gdscript/parsers/cfg_parser.gd").new()
var data_hydrator = load('res://source/gdscript/helpers/data_hydrator.gd').new()
var BackgroundDefinition = load("res://source/gdscript/nodes/background/background_definition.gd")
var BackgroundItem = load("res://source/gdscript/nodes/background/background_item.gd")

func read(path: String):
    var sections: Array = cfg_parser.read(path, false, true)
    var result: Dictionary = {}
    var current_background = null

    for section in sections:
        var key = section["key"]
        var bgdef_index = key.find("bgdef")

        if bgdef_index > -1:
            var background_key = key.substr(0, bgdef_index)
            current_background = BackgroundDefinition.new()
            current_background.key = background_key
            data_hydrator.hydrate_object_section(current_background, section["attributes"], key)
            result[current_background.key] = current_background
            continue

        if current_background == null:
            continue

        if key.begins_with("%sbg" % [current_background.key]):
            var item = BackgroundItem.new()
            data_hydrator.hydrate_object_section(item, section["attributes"], key)
            current_background.items.append(item)

    return result
