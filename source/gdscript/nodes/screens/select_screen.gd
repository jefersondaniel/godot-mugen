extends Node2D

var sff_parser = load("res://source/native/sff_parser.gdns").new()
var user_input = load('res://source/gdscript/system/user_input.gd').new()
var BackgroundGroup = load("res://source/gdscript/nodes/ui/background_group.gd")
var UiLabel = load("res://source/gdscript/nodes/ui/label.gd")
var SpriteBundle = load("res://source/gdscript/system/sprite_bundle.gd")
var AnimationSprite = load("res://source/gdscript/nodes/sprite/animation_sprite.gd")

var setup: bool = false
var kernel: Object
var store: Object
var animations: Dictionary
var background_definition: Object
var select_info: Object
var title_font = null
var sprite_bundle: Object
var select_bundle: Object
var cell_slots: Array = []
var characters = []
var cursor_sprite = null
var cursor_position: Vector2 = Vector2(0, 0)
var cursor_move_snd: Array = []
var cursor_done_snd: Array = []
var current_team: int = 1
var current_character = null
var faces: Dictionary = {}
var names: Dictionary = {}
var face_layer: Node2D

func _ready():
    if setup:
        return

    setup = true
    kernel = constants.container["kernel"]
    store = constants.container["store"]
    select_info = kernel.get_motif().select_info
    animations = kernel.get_motif().animations
    title_font = kernel.get_font(select_info.title_font)
    background_definition = kernel.get_motif().backgrounds["select"]
    sprite_bundle = kernel.get_sprite_bundle()
    select_bundle = kernel.get_select_bundle()
    current_team = 1
    face_layer = Node2D.new()

    load_characters()
    setup_background()
    add_child(face_layer)
    setup_title()
    setup_cells()
    setup_character_cells()
    setup_cursor()
    update_current_character()
    # TODO: Confirm selection based on versus mode
    # TODO: Stage selection

func get_cursor_input():
    if current_team == 1:
        return user_input.p1
    else:
        return user_input.p2

func get_player_info():
    if current_team == 1:
        return select_info.p1
    else:
        return select_info.p2

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
            "faces": {
                1: p1_face,
                2: p2_face
            },
        })

func setup_character_cells():
    var index = -1
    var cell_size = select_info.cell_size

    for character in characters:
        index += 1
        if index > cell_slots.size() - 1:
            break
        var image = character["portrait"]
        var definition = character["definition"]
        var texture = sprite_bundle.create_texture(image)
        var texture_data = texture.get_data()
        var sprite = Sprite.new()
        sprite.texture = texture
        sprite.centered = false
        sprite.position += Vector2(image["x"], image["y"])
        var slot = cell_slots[index]
        sprite.position = slot
        sprite.scale = definition.get_scale() * select_info.portrait_scale
        add_child(sprite)

func setup_cursor():
    var player = get_player_info()
    cursor_move_snd = player.cursor_move_snd
    cursor_done_snd = player.cursor_done_snd
    cursor_position = player.cursor_startcell

    var cursor_animations = {}
    cursor_animations[player.cursor_active_anim] = animations[player.cursor_active_anim]

    if cursor_sprite:
        cursor_sprite.queue_free()

    cursor_sprite = AnimationSprite.new(sprite_bundle, cursor_animations)
    cursor_sprite.change_anim(player.cursor_active_anim)
    cursor_sprite.scale = kernel.get_scale()

    update_cursor_position()
    add_child(cursor_sprite)

func update_cursor_position():
    var cell_index = get_cell_index(cursor_position)
    var slot = cell_slots[cell_index]
    cursor_sprite.position = slot

func get_cell_index(cell_position: Vector2):
    return select_info.columns * cell_position.y + cell_position.x

func handle_cursor_input():
    var cursor_input = get_cursor_input()
    var moved: bool = false

    if cursor_input.is_action_just_pressed("U"):
        cursor_position.y = max(0, cursor_position.y - 1)
        moved = true
    if cursor_input.is_action_just_pressed("D"):
        cursor_position.y = min(select_info.rows - 1, cursor_position.y + 1)
        moved = true
    if cursor_input.is_action_just_pressed("B"):
        cursor_position.x = max(0, cursor_position.x - 1)
        moved = true
    if cursor_input.is_action_just_pressed("F"):
        cursor_position.x = min(select_info.columns - 1, cursor_position.x + 1)
        moved = true

    if cursor_input.is_action_just_pressed("s"):
        play_sound(cursor_done_snd)

    if moved:
        update_current_character()
        play_sound(cursor_move_snd)

func play_sound(sound_def):
    var kernel = constants.container["kernel"]
    var audio_player = constants.container["audio_player"]
    var sound = kernel.get_sound(sound_def)

    if sound:
        audio_player.play_sound(sound)

func _process(delta: float):
    handle_cursor_input()
    update_cursor_position()

func update_current_character():
    var index = get_cell_index(cursor_position)
    if index >= characters.size():
        return
    current_character = characters[index]
    update_face()
    update_name()

func update_face():
    var player_info = get_player_info()

    if faces.has(current_team):
        faces[current_team].queue_free()

    var face_window = Rect2(
        player_info.face_window[0],
        player_info.face_window[1],
        player_info.face_window[2] - player_info.face_window[0],
        player_info.face_window[3] - player_info.face_window[1]
    )
    var image = current_character["faces"][current_team]
    var definition = current_character["definition"]
    var texture = sprite_bundle.create_texture(image)
    var texture_data = texture.get_data()
    var sprite = Sprite.new()
    sprite.texture = texture
    sprite.centered = false
    sprite.position += face_window.position
    sprite.scale = definition.get_scale() * player_info.face_scale
    sprite.flip_h = player_info.face_facing == -1

    faces[current_team] = sprite
    face_layer.add_child(sprite)

func update_name():
    var player_info = get_player_info()

    if names.has(current_team):
        names[current_team].queue_free()

    var definition = current_character["definition"]
    var label = UiLabel.new()
    var name_font = kernel.get_font(player_info.name_font)
    label.set_text(definition.info.displayname)
    label.set_font(name_font)
    label.position = player_info.name_offset

    # TODO: Consider spacing (space between character names in same team)

    names[current_team] = label
    face_layer.add_child(label)
