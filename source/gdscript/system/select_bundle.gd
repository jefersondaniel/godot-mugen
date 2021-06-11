var character_definition_loader = load("res://source/gdscript/loaders/character_definition_loader.gd").new()

var data: Dictionary = {
    "characters": [],
    "extra_stages": [],
}

func _init(data):
    if not data:
        return
    self.data = data

func get_character_definitions():
    var kernel = constants.container["kernel"]
    var result = []
    for character in data["characters"]:
        var def_path = character["name"]
        if def_path.find("/") < 0:
            def_path = "%s/%s.def" % [def_path, def_path]
        var path = "%s/chars/%s" % [kernel.base_path, def_path]
        var definition = character_definition_loader.load(path)
        result.push_back(definition)
    return result
