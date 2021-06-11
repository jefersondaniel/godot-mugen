var def_parser = load('res://source/gdscript/parsers/def_parser.gd').new()
var Definition = load("res://source/gdscript/nodes/character/definition.gd")

func load(path: String):
    var base_path = path.substr(0, path.find_last('/'))

    var definition = Definition.new()
    definition.base_path = base_path
    definition.parse(def_parser.read(path))

    return definition
