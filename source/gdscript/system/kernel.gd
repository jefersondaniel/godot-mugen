var CoreLoader = load('res://source/gdscript/loaders/core_loader.gd').new()
var FontLoader = load('res://source/gdscript/loaders/font_loader.gd').new()
var ShaderFactory = load('res://source/gdscript/system/shader_factory.gd')

var core_configuration = null
var base_path = "res://data"
var font_cache: Dictionary = {}
var audio_player = null
var shader_factory = ShaderFactory.new()

func load():
    core_configuration = CoreLoader.load(base_path)

func get_motif():
    return core_configuration.motif_configuration

func get_fight_configuration():
    return core_configuration.fight_configuration

func get_motif_sound(sound_def: Array):
    var sounds = core_configuration.motif_configuration.sounds
    var key = "%s-%s" % [sound_def[0], sound_def[1]]
    if not sounds.has(key):
        push_warning("Motif sound not found: %s" % [key])
        return null
    return sounds[key]

func get_fight_sound(sound_def: Array):
    var sounds = core_configuration.fight_configuration.sounds
    var key = "%s-%s" % [sound_def[0], sound_def[1]]
    if not sounds.has(key):
        push_warning("Fight sound not found: %s" % [key])
        return null
    return sounds[key]

func get_common_sound(sound_def: Array):
    var sounds = core_configuration.fight_configuration.common_sounds
    var key = "%s-%s" % [sound_def[0], sound_def[1]]
    if not sounds.has(key):
        push_warning("Common sound not found: %s" % [key])
        return null
    return sounds[key]

func get_sprite_bundle() -> Dictionary:
    return core_configuration.motif_configuration.sprite_bundle

func get_select_bundle() -> Dictionary:
    return core_configuration.motif_configuration.select_bundle

func get_motif_font(font_def: Array):
    return self.get_font(font_def, "motif", get_motif().files)

func get_fight_font(font_def: Array):
    return self.get_font(font_def, "fight", get_fight_configuration().files)

func get_font(font_def: Array, font_source: String, files) -> Dictionary:
    var cache_key = "%s-%s" % [font_source, PoolStringArray(font_def).join("-")]

    if font_cache.has(cache_key):
        return font_cache[cache_key]

    var index = font_def[0]
    var color_bank = font_def[1] if font_def.size() >= 2 else 0
    var alignment = font_def[2] if font_def.size() >= 3 else 0
    var color_r: float = font_def[3] if font_def.size() >= 4 else 0
    var color_g: float = font_def[4] if font_def.size() >= 5 else 0
    var color_b: float = font_def[5] if font_def.size() >= 6 else 0
    var color = null
    if font_def.size() >= 6:
        color = Color(color_r / 255.0, color_g / 255.0, color_b / 255.0, 1)

    var ref = files.get_font_reference(index)
    var path: String = ref[0]
    var size: int = ref[1]
    path = "%s/font/%s" % [base_path, path]
    var font = FontLoader.load(path, color_bank)

    font_cache[cache_key] = {
        'font': font,
        'alignment': alignment,
        'color': color
    }

    return font_cache[cache_key]

func get_scale() -> Vector2:
    return constants.get_scale(get_motif().info.localcoord)

