extends Node2D

var BackgroundGroup = load('res://source/gdscript/nodes/ui/background_group.gd')
var UiLabel = load('res://source/gdscript/nodes/ui/label.gd')

var setup: bool = false
var kernel: Object
var store: Object
var background_definition: Object
var select_info: Object
var title_font = null
var sprite_bundle: Object

func _ready():
    if setup:
        return

    setup = true
    kernel = constants.container["kernel"]
    store = constants.container["store"]
    select_info = kernel.get_motif().select_info
    title_font = kernel.get_font(select_info.title_font)
    background_definition = kernel.get_motif().backgrounds["select"]
    sprite_bundle = kernel.get_sprite_bundle()

    setup_background()
    setup_title()
    setup_cells()

func setup_background():
    var background_group = BackgroundGroup.new()
    background_group.sprite_bundle = sprite_bundle
    background_group.setup(background_definition)

    add_child(background_group)

func setup_title():
    var label = UiLabel.new()
    label.set_text(store.fight_type_text)
    label.set_font(title_font)
    label.position = select_info.title_offset * kernel.get_scale()
    add_child(label)

func setup_cells():
    var base_sprite = sprite_bundle.create_sprite(select_info.cell_bg_spr)
    for row in range(0, select_info.rows):
        for column in range(0, select_info.columns):
            # TODO: Check showemptyboxes and moveemptyboxes
            create_cell(row, column, base_sprite)
    base_sprite.queue_free()

func create_cell(row: int, column: int, base_sprite: Sprite):
    var sprite = Sprite.new()
    sprite.centered = false
    sprite.texture = base_sprite.texture
    sprite.offset -= base_sprite.offset
    sprite.scale = kernel.get_scale()
    sprite.position = Vector2(
        column * select_info.cell_size.x + column * select_info.cell_spacing,
        row * select_info.cell_size.y + row * select_info.cell_spacing
    )
    sprite.position += select_info.pos
    sprite.position *= kernel.get_scale()
    add_child(sprite)
