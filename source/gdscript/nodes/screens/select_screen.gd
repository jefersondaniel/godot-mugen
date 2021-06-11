extends Node2D

var sff_parser = load('res://source/native/sff_parser.gdns').new()
var BackgroundGroup = load('res://source/gdscript/nodes/ui/background_group.gd')
var UiLabel = load('res://source/gdscript/nodes/ui/label.gd')
var SpriteBundle = load("res://source/gdscript/system/sprite_bundle.gd")

var setup: bool = false
var kernel: Object
var store: Object
var background_definition: Object
var select_info: Object
var title_font = null
var sprite_bundle: Object
var select_bundle: Object
var cell_slots: Array = []
var characters = []

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
    select_bundle = kernel.get_select_bundle()

    load_characters()
    setup_background()
    setup_title()
    setup_cells()
    setup_character_cells()

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
    sprite.scale = kernel.get_scale()
    sprite.position = Vector2(
        column * select_info.cell_size.x + column * select_info.cell_spacing,
        row * select_info.cell_size.y + row * select_info.cell_spacing
    )
    sprite.offset = base_sprite.offset
    sprite.position += select_info.pos
    sprite.position *= kernel.get_scale()
    cell_slots.append(sprite.position)
    add_child(sprite)

func load_characters():
    var definitions = select_bundle.get_character_definitions()

    var sprite_groups = [
        select_info.portrait_spr[0],
        select_info.p1.face_spr[0],
        select_info.p2.face_spr[0],
    ]

    for definition in definitions:
        var images = sff_parser.read_images(definition.get_sprite_path(), null, sprite_groups)
        var char_sprite_bundle = SpriteBundle.new(images)
        var portrait = char_sprite_bundle.get_image(select_info.portrait_spr)
        var p1_face = char_sprite_bundle.get_image(select_info.p1.face_spr)
        var p2_face = char_sprite_bundle.get_image(select_info.p2.face_spr)
        characters.push_back({
            "definition": definition,
            "portrait": portrait,
            "p1_face": p1_face,
            "p2_face": p2_face,
        })

func setup_character_cells():
    var index = -1
    var cell_size = select_info.cell_size

    for character in characters:
        index += 1
        var image = character["portrait"]
        var texture = sprite_bundle.create_texture(image)
        var texture_data = texture.get_data()
        var sprite_scale = Vector2(cell_size.x / texture_data.get_width(), cell_size.y / texture_data.get_height())
        var sprite = Sprite.new()
        sprite.texture = texture
        sprite.centered = false
        sprite.position += Vector2(image["x"], image["y"])
        # TODO: Fix missing slots and scroll
        var slot = cell_slots[index]
        sprite.position = slot
        sprite.scale = kernel.get_scale() * sprite_scale * select_info.portrait_scale
        add_child(sprite)
