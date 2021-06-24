var def_parser = load("res://source/gdscript/parsers/def_parser.gd").new()

func read(path: String):
    var data = def_parser.read(path, true)
    var result: Dictionary = {
        "characters": [],
        "extra_stages": [],
    }

    for line in data["characters"]["lines"]:
        var pieces = line.split(",", true, 2)
        var character = pieces[0]
        var stage = "random"
        var options = {
            "order": 1,
            "includestage": 1,
            "music": null
        }
        if len(pieces) > 1 and pieces[1]:
            stage = pieces[1]
        if len(pieces) > 2 and pieces[2]:
            var new_options = parse_options(pieces[2])
            for key in new_options:
                options[key] = new_options[key]
        result["characters"].push_back({
            "name": character,
            "stage": stage.strip_edges(),
            "options": options
        })

    for line in data.get("extrastages", {}).get("lines", []):
        if not line.strip_edges():
            continue
        result["extra_stages"].push_back(line.strip_edges())

    return result

func parse_options(line: String):
    var pieces = line.split(",")
    var result = {}

    for piece in pieces:
        if not piece:
            continue
        var equal_idx = piece.find('=')
        var key = piece.substr(0, equal_idx).to_lower().strip_edges()
        var value = piece.substr(equal_idx + 1, len(piece) - equal_idx).strip_edges()
        if key == "order" or key == "includestage":
            value = int(value)
        result[key] = value

    return result
