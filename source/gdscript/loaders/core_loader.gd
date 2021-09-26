var data_hydrator = load('res://source/gdscript/helpers/data_hydrator.gd').new()
var air_parser = load("res://source/gdscript/parsers/air_parser.gd").new()
var bg_parser = load("res://source/gdscript/parsers/bg_parser.gd").new()
var cfg_parser = load("res://source/gdscript/parsers/cfg_parser.gd").new()
var select_parser = load('res://source/gdscript/parsers/select_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()
var snd_parser = load('res://source/native/snd_parser.gdns').new()
var SpriteBundle = load("res://source/gdscript/system/sprite_bundle.gd")
var SelectBundle = load("res://source/gdscript/system/select_bundle.gd")
var CoreConfiguration = load("res://source/gdscript/system/core_configuration.gd")
var MotifConfiguration = load("res://source/gdscript/system/motif_configuration.gd")
var FightConfiguration = load("res://source/gdscript/system/fight_configuration.gd")

func load(base_path: String):
    var system_path = "%s/%s" % [base_path, "data"]
    var core_path = "%s/%s" % [system_path, "mugen.cfg"]
    var core_configuration = load_core_configuration(core_path)

    var motif_path = "%s/%s" % [base_path, core_configuration.options.motif]
    var motif = load_motif_configuration(motif_path)

    var fight_path = find_file_path(motif_path, motif.files.fight)
    var fight = load_fight_configuration(fight_path)

    core_configuration.motif_configuration = motif
    core_configuration.fight_configuration = fight

    return core_configuration

func load_core_configuration(path: String):
    var sections = cfg_parser.read(path, false, true)
    var result = CoreConfiguration.new()
    data_hydrator.hydrate_object(result, sections)
    return result

func load_motif_configuration(path: String):
    var sections = cfg_parser.read(path, false, true)
    var result = MotifConfiguration.new()
    data_hydrator.hydrate_object(result, sections)

    var animations = air_parser.read(path)
    result.animations = animations

    var backgrounds = bg_parser.read(path)
    result.backgrounds = backgrounds

    if result.files.snd:
        var sound_path = find_file_path(path, result.files.snd)
        var sounds = snd_parser.read_sounds(sound_path)
        if sounds:
            result.sounds = sounds

    if result.files.spr:
        var spr_path = find_file_path(path, result.files.spr)
        var images = sff_parser.read_images(spr_path, null, null)
        if images:
            result.sprite_bundle = SpriteBundle.new(images)

    if result.files.select:
        var select_path = find_file_path(path, result.files.select)
        var select_data = select_parser.read(select_path)
        if select_data:
            result.select_bundle = SelectBundle.new(select_data)

    return result

func find_file_path(referrer: String, name: String) -> String:
    var pieces = referrer.split("/")
    var file_check = File.new()
    var base_path: String = "res://"

    while pieces.size() > 1:
        pieces.remove(pieces.size() - 1)
        base_path = pieces.join("/")
        if file_check.file_exists("%s/%s" % [base_path, name]):
            return "%s/%s" % [base_path, name]

    return "%s/%s" % [base_path, name]

func load_fight_configuration(path: String):
    var sections = cfg_parser.read(path, false, true)
    var result = FightConfiguration.new()
    data_hydrator.hydrate_object(result, sections)

    var animations = air_parser.read(path)
    result.animations = animations

    if result.files.snd:
        var sound_path = find_file_path(path, result.files.snd)
        var sounds = snd_parser.read_sounds(sound_path)
        if sounds:
            result.sounds = sounds

    if result.files.sff:
        var spr_path = find_file_path(path, result.files.sff)
        var images = sff_parser.read_images(spr_path, null, null)
        if images:
            result.sprite_bundle = SpriteBundle.new(images)

    if result.files.fightfx_sff:
        var spr_path = find_file_path(path, result.files.fightfx_sff)
        var images = sff_parser.read_images(spr_path, null, null)
        if images:
            result.fightfx_sprite_bundle = SpriteBundle.new(images)

    if result.files.fightfx_air:
        var air_path = find_file_path(path, result.files.fightfx_air)
        var fightfx_animations = air_parser.read(air_path)
        if fightfx_animations:
            result.fightfx_animations = fightfx_animations

    if result.files.common_snd:
        var sound_path = find_file_path(path, result.files.common_snd)
        var sounds = snd_parser.read_sounds(sound_path)
        if sounds:
            result.common_sounds = sounds

    return result
