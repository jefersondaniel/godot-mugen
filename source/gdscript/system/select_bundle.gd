var character_loader = load("res://source/gdscript/loaders/character_loader.gd").new()
var stage_loader = load("res://source/gdscript/loaders/stage_loader.gd").new()

var data: Dictionary = {
    "characters": [],
    "extra_stages": [],
}

func _init(data):
    if not data:
        return
    self.data = data

func get_included_stages():
    var result = []
    for character in data["characters"]:
        if not result.has(character["stage"]):
            result.push_back(character["stage"])
    for stage in data["extra_stages"]:
        if not result.has(stage):
            result.push_back(stage)
    return result

func get_character_definitions():
    var kernel = constants.container["kernel"]
    var result = []
    for character in data["characters"]:
        var def_path = character["name"]
        if def_path.find("/") < 0:
            def_path = "%s/%s.def" % [def_path, def_path]
        var path = "%s/chars/%s" % [kernel.base_path, def_path]
        var definition = character_loader.load_definition(path)
        result.push_back(definition)
    return result

func get_stage_definitions():
    var kernel = constants.container["kernel"]
    var result = []
    for def_path in get_included_stages():
        var path = "%s/%s" % [kernel.base_path, def_path]
        var definition = stage_loader.load_definition(path)
        result.push_back(definition)
    return result
