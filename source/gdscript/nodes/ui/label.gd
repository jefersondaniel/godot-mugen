extends Node2D

const MUGEN_ALIGN_LEFT = -1
const MUGEN_ALIGN_CENTER = 0
const MUGEN_ALIGN_RIGHT = 1

var font_data = null
var text: String = ""
var cache: Array = []
var cache_dimension: Vector2 = Vector2(0, 0)

func set_font(font_data: Dictionary):
    self.font_data = font_data
    update_cache()

func set_text(text):
    self.text = text
    update_cache()

func update_cache():
    if not font_data or not text:
        cache = []
        return

    var cursor: Vector2 = Vector2(0, 0)
    var font = font_data["font"]["font"]
    var spacing: Vector2 = font_data["font"]["spacing"]
    var font_size: Vector2 = font_data["font"]["size"]
    var data = text.to_utf8()

    cache_dimension = Vector2(0, 0)

    for i in range(0, data.size()):
        var current_char = data[i]
        var next_char = data[i + 1] if data.size() > i + 1 else 0
        var char_size = font.get_char_size(current_char, next_char)

        # char_size = font_data["font"]["size"]

        cache.append({
            'x': cursor.x,
            'y': cursor.y,
            'current_char': current_char,
            'next_char': next_char
        })

        cursor.x += char_size.x + spacing.x

        cache_dimension.y = max(char_size.y, cache_dimension.y)
        cache_dimension.x = cursor.x

    update()

func _draw():
    if cache.size() == 0:
        return

    var font = font_data["font"]["font"]

    var offset = font_data["font"]["offset"]

    offset.y -= font_data["font"]["size"].y

    if font_data["alignment"] == MUGEN_ALIGN_CENTER:
       offset.x -= cache_dimension.x / 2
    elif font_data["alignment"] == MUGEN_ALIGN_LEFT:
        offset.x -= cache_dimension.x

    for item in cache:
        var position: Vector2 = Vector2(item["x"], item["y"])
        var current_char: String = PoolByteArray([item["current_char"]]).get_string_from_utf8()
        var next_char: String = PoolByteArray([item["next_char"]]).get_string_from_utf8()
        draw_char(font, offset + position, current_char, next_char)
