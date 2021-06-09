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

func get_sound(sound_def: Array):
    var sounds = core_configuration.motif_configuration.sounds
    return sounds["%s-%s" % [sound_def[0], sound_def[1]]]

func get_sprite_bundle() -> Dictionary:
    return core_configuration.motif_configuration.sprite_bundle

func get_font(font_def: Array) -> Dictionary:
    var cache_key = PoolStringArray(font_def).join("-")

    if font_cache.has(cache_key):
        return font_cache[cache_key]

    var index = font_def[0]
    var color_bank = font_def[1] if font_def.size() >= 2 else 0
    var alignment = font_def[2] if font_def.size() >= 3 else 0
    var color_r: float = font_def[3] if font_def.size() >= 4 else 0
    var color_g: float = font_def[4] if font_def.size() >= 5 else 0
    var color_b: float = font_def[5] if font_def.size() >= 6 else 0

    var ref = get_motif().files.get_font_reference(index)
    var path: String = ref[0]
    var size: int = ref[1]
    path = "%s/font/%s" % [base_path, path]
    var font = FontLoader.load(path, color_bank)

    # TODO: Implement color bank support

    font_cache[cache_key] = {
        'font': font,
        'alignment': alignment,
        'color': Color(color_r / 255.0, color_g / 255.0, color_b / 255.0, 255)
    }

    return font_cache[cache_key]

func get_scale() -> Vector2:
    return constants.get_scale(get_motif().info.localcoord)

