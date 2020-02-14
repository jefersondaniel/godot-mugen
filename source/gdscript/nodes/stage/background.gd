extends ParallaxLayer

var images: Dictionary = {}
var animations: Dictionary = {}
var id: int = 0
var type: String = 'normal'
var positionlink: int = 0
var velocity: Vector2 = Vector2(0, 0)
var sin_x: Array = []
var sin_y: Array = []
var spriteno: Array = []
var layerno: int = 0
var start: Vector2 = Vector2(0, 0)
var delta: Vector2 = Vector2(1, 1)
var trans: String = 'none'
var alpha: Array = []
var mask: int = 0
var tile: Vector2 = Vector2(0, 0)
var tilespacing: Vector2 = Vector2(0, 0)
var window: Array = []
var windowdelta: Vector2 = Vector2(0, 0)
var actionno: int = 0
var xscale: Array = []
var yscalestart: int = 0
var yscaledelta: int = 0
var stage_scale: Vector2 = Vector2(1, 1)

func setup(stage):
    stage_scale = constants.get_scale(stage.stageinfo_localcoord)

    if type == 'normal':
        setup_normal(stage)
    elif type == 'parallax':
        setup_parallax(stage)
    else:
        printerr("Unsupported type: %s" % [type])

    z_index = layerno
    motion_scale = delta

func setup_normal(stage):
    var spritekey = '%s-%s' % [spriteno[0], spriteno[1]]

    if not images.has(spritekey):
        printerr("Invalid spriteno: %s,%s" % spriteno)
        return

    var image = images[spritekey]
    var offset = Vector2(image['x'], image['y'])
    var sprite = create_sprite(image['image'])

    sprite.centered = false
    sprite.position = (start - offset)

    # Scale
    sprite.position = stage_scale * sprite.position
    sprite.scale = stage_scale

    create_tiles(stage, sprite)

    add_child(sprite)

func setup_parallax(stage):
    pass

func create_tiles(stage, base: Sprite):
    var requested_tiles_top: int = tile.y
    var requested_tiles_left: int = tile.x
    var requested_tiles_right: int = tile.x
    var requested_tiles_bottom: int = tile.y
    var bound_left = stage.get_bound_left()
    var bound_right = stage.get_bound_right()
    var bound_top = stage.get_bound_top()
    var bound_bottom = stage.get_bound_bottom()


    if tile.x == 1:
        requested_tiles_left = ceil(abs(base.position.x - bound_left) / (base.texture.size.x * stage_scale.x))
        requested_tiles_right = ceil(abs(base.position.x - bound_right) / (base.texture.size.x * stage_scale.x))

    if tile.y == 1:
        requested_tiles_top = ceil(abs(base.position.y - bound_top) / (base.texture.size.y * stage_scale.y))
        requested_tiles_bottom = ceil(abs(base.position.y - bound_bottom) / (base.texture.size.y * stage_scale.y))

    for i in range(requested_tiles_left):
        var tile: Sprite = base.duplicate()
        tile.position.x = base.position.x - (tilespacing.x + base.texture.size.x * stage_scale.x * (i + 1))
        add_child(tile)

    for i in range(requested_tiles_right):
        var tile: Sprite = base.duplicate()
        tile.position.x = base.position.x + (tilespacing.x + base.texture.size.x * stage_scale.x * (i + 1))
        add_child(tile)

    for i in range(requested_tiles_top):
        var tile: Sprite = base.duplicate()
        tile.position.y = base.position.y - (tilespacing.y + base.texture.size.y * stage_scale.y * (i + 1))
        add_child(tile)

    for i in range(requested_tiles_bottom):
        var tile: Sprite = base.duplicate()
        tile.position.y = base.position.y + (tilespacing.y + base.texture.size.y * stage_scale.y * (i + 1))
        add_child(tile)

func create_sprite(image):
    var texture = ImageTexture.new()
    var sprite = Sprite.new()
    texture.create_from_image(image, 0)
    sprite.texture = texture
    return sprite
