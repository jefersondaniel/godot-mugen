var cfg_parser = load('res://source/gdscript/parsers/cfg_parser.gd').new()

func read_string(text, allow_lines=false):
    return map_sections(cfg_parser.read_string(text, allow_lines))

func read(path, allow_lines=false):
    return map_sections(cfg_parser.read(path, allow_lines))

func map_sections(sections):
    var result = {}

    for section in sections:
        result[section['key']] = section['attributes']

    return result
