var def_parser = load('res://source/gdscript/parsers/def_parser.gd').new()
var sff_parser = load('res://source/native/sff_parser.gdns').new()
var fnt_parser = load('res://source/native/fnt_parser.gdns').new()

func load(path: String):
    if path.to_lower().ends_with(".def"):
        return load_fnt_v2(path)
    if path.to_lower().ends_with(".fnt"):
        return load_fnt_v1(path)

    printerr("Unsupported format: %s" % [path])

func load_fnt_v2(path: String):
    var folder = path.substr(0, path.find_last('/'))
    var definition = def_parser.read(path)
    var result = {}
    var filename = definition['def']['file']
    var font = null
    var size = _parse_vector(definition['def'], 'size', Vector2(0, 0))
    var spacing = _parse_vector(definition['def'], 'spacing', Vector2(0, 0))

    if filename.to_lower().ends_with('.sff'):
        font = load_sff_font('%s/%s' % [folder, filename])
        font.height = size.y
        # TODO: Support spacing and width
    else:
        font = load_vector_font('%s/%s' % [folder, filename])
        font.size = size.y
        font.set_spacing(DynamicFont.SPACING_TOP, spacing.y / 2)
        font.set_spacing(DynamicFont.SPACING_BOTTOM, spacing.y / 2)
        # TODO: Support blend

    result['font'] = font

    return result

func load_sff_font(path: String):
    var font = BitmapFont.new()
    var data: Dictionary = sff_parser.get_images(path, 0)
    var texture_id: int = 0
    for key in data.keys():
        var key_code: int = int(key.split('-')[1])
        var image = data[key]['image']
        var texture = ImageTexture.new()
        texture.create_from_image(image, 0)
        font.add_texture(texture)
        font.add_char(
            key_code,
            texture_id,
            Rect2(Vector2(0, 0), image.get_size()),
            Vector2(data[key]['x'], data[key]['y'])
        )
        texture_id += 1

    return font

func load_vector_font(path: String):
    var font = DynamicFont.new()
    font.font_data = load(path)
    return font

func load_fnt_v1(path: String):
    var data = fnt_parser.get_font_data(path)
    var image = data['image']
    var text = data['text'].get_string_from_utf8()

    var file = File.new()
    file.open("res://font.txt", File.WRITE)
    file.store_string(text)
    file.close()

    var cfg = def_parser.read_string(text, true)
    var offset = _parse_vector(cfg['def'], 'offset', Vector2(0, 0))
    var size = _parse_vector(cfg['def'], 'size', Vector2(0, 0))
    var spacing = _parse_vector(cfg['def'], 'spacing', Vector2(0, 0))
    var font_type = cfg['def']['type'] if cfg['def'].has('type') else 'Variable'
    font_type = font_type.to_lower()

    var font = BitmapFont.new()
    var texture = ImageTexture.new()
    texture.create_from_image(image, 0)
    font.add_texture(texture)
    font.height = size.y

    var iterator = 0

    for line in cfg['map']['lines']:
        var pieces = line.split(" ")
        var character = _parse_character(pieces[0])
        var char_start_x = iterator * size.x
        var char_width = size.x

        if font_type == 'variable':
            char_start_x = int(pieces[1])
            char_width = int(pieces[2])

        font.add_char(
            character.ord_at(0),
            0,
            Rect2(
                Vector2(char_start_x, 0),
                size
            ),
            Vector2(0, 0)
        )

        iterator += 1

    font.add_texture(_create_space_texture(size))

    font.add_char(
        " ".ord_at(0),
        1,
        Rect2(Vector2(0, 0), size),
        Vector2(0, 0)
    )

    return {
        'font': font
    }

func _parse_vector(data: Dictionary, key: String, default_value):
    if not key in data:
        return default_value
    var raw = data[key]
    if not raw:
        return default_value
    var pieces = raw.split(',')
    if pieces.size() != 2:
        printerr("Font invalid parameter: %s" % [raw])
        return default_value
    return Vector2(pieces[0], pieces[1])

func _parse_character(value: String):
    if not value.to_lower().begins_with('0x'):
        return value
    var ordinal = value.hex_to_int()
    var byteArray = PoolByteArray([ordinal])
    return byteArray.get_string_from_ascii()

func _create_space_texture(size: Vector2):
    var empty_image = Image.new()
    empty_image.create(size.x, size.y, false, 5)
    var empty_texture = ImageTexture.new()
    empty_texture.create_from_image(empty_image, 0)
    return empty_texture
