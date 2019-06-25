extends Object

var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()

func read(path, allow_key_extends=false):
    var result = {}
    var sections = cfg_parser.read(path)

    for section in sections:
        result[section['key']] = section['attributes']

    return result
