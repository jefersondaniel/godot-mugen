var data_hydrator = load('res://source/gdscript/helpers/data_hydrator.gd').new()
var air_parser = load("res://source/gdscript/parsers/air_parser.gd").new()
var bg_parser = load("res://source/gdscript/parsers/bg_parser.gd").new()
var cfg_parser = load("res://source/gdscript/parsers/cfg_parser.gd").new()
var snd_parser = load('res://source/native/snd_parser.gdns').new()
var CoreConfiguration = load("res://source/gdscript/system/core_configuration.gd")
var MotifConfiguration = load("res://source/gdscript/system/motif_configuration.gd")

func load(base_path: String):
    var system_path = "%s/%s" % [base_path, "data"]
    var core_path = "%s/%s" % [system_path, "mugen.cfg"]
    var core_configuration = load_core_configuration(core_path)

    var motif_path = "%s/%s" % [base_path, core_configuration.options.motif]
    var motif = load_motif_configuration(motif_path, system_path)

    core_configuration.motif_configuration = motif

    return core_configuration

func load_core_configuration(path: String):
    var sections = cfg_parser.read(path, false, true)
    var result = CoreConfiguration.new()
    data_hydrator.hydrate_object(result, sections)
    return result

func load_motif_configuration(path: String, system_path: String):
    var sections = cfg_parser.read(path, false, true)
    var result = MotifConfiguration.new()
    data_hydrator.hydrate_object(result, sections)

    var animations = air_parser.read(path)
    result.animations = animations

    var backgrounds = bg_parser.read(path)
    result.backgrounds = backgrounds

    if result.files.snd:
        var sound_path = "%s/%s" % [system_path, result.files.snd]
        var sounds = snd_parser.read_sounds(sound_path)
        if sounds:
            result.sounds = sounds

    return result
