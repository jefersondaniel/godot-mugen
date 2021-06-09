extends Node2D

var Background = load('res://source/gdscript/nodes/ui/background.gd')

# Mugen Variables
var key: String = ""
var spr: String = "" # Optional sprite file. Empty on motif backgrounds
var bgclearcolor: PoolIntArray = PoolIntArray([])
var debugbg: int = 0
# Custom Variables
var sprite_bundle: Object
var texture: ImageTexture
var custom_rect: Rect2

func setup(definition):
    key = definition.key
    spr = definition.spr
    bgclearcolor = definition.bgclearcolor
    debugbg = definition.debugbg

    setup_texture()

    for item in definition.items:
        var background = Background.new()
        background.position = constants.get_screen_coordinate(item.start)
        background.image = sprite_bundle.get_image(item.spriteno)
        background.type = item.type
        background.positionlink = item.positionlink
        background.velocity = item.velocity
        background.sin_x = item.sin_x
        background.sin_y = item.sin_y
        background.spriteno = item.spriteno
        background.layerno = item.layerno
        background.start = item.start
        background.delta = item.delta
        background.trans = item.trans
        background.alpha = item.alpha
        background.mask = item.mask
        background.tile = item.tile
        background.tilespacing = item.tilespacing
        background.window = item.window
        background.windowdelta = item.windowdelta
        background.actionno = item.actionno
        background.width = item.width
        background.top_xscale = item.top_xscale
        background.bottom_xscale = item.bottom_xscale
        background.yscalestart = item.yscalestart
        background.yscaledelta = item.yscaledelta
        background.setup()

        add_child(background)

func setup_texture():
    var image_data = PoolByteArray([255, 255, 255, 255])

    if bgclearcolor.size() > 2:
        image_data[0] = bgclearcolor[0]
        image_data[1] = bgclearcolor[1]
        image_data[2] = bgclearcolor[2]

    var empty_image = Image.new()
    empty_image.create_from_data(1, 1, false, 5, image_data)
    texture = ImageTexture.new()
    texture.create_from_image(empty_image, 0)
    custom_rect = Rect2(0, 0, constants.WINDOW_SIZE.x, constants.WINDOW_SIZE.y)

func _draw():
    draw_texture_rect(texture, custom_rect, true)
