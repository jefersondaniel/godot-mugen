extends Node2D

var BackgroundGroup = load("res://source/gdscript/nodes/ui/background_group.gd")
var UiLabel = load("res://source/gdscript/nodes/ui/label.gd")

signal done

var kernel: Object
var store: Object
var animations: Dictionary
var background_definition: Object
var vs_screen: Object
var sprite_bundle: Object

func _ready():
    var timeout_secs = vs_screen.time / constants.TARGET_FPS
    get_tree().create_timer(timeout_secs).connect("timeout", self, "handle_timeout")

func _init():
    kernel = constants.container["kernel"]
    store = constants.container["store"]
    vs_screen = kernel.get_motif().vs_screen
    animations = kernel.get_motif().animations
    background_definition = kernel.get_motif().backgrounds["versus"]
    sprite_bundle = kernel.get_sprite_bundle()

    setup_background()
    setup_faces()

func setup_background():
    var background_group = BackgroundGroup.new()
    background_group.setup(background_definition, sprite_bundle, animations)

    add_child(background_group)

func setup_faces():
    var p1_face = false
    var p2_face = false
    var p1_name = false
    var p2_name = false

    for selection in store.character_select_result:
        if selection["team"] == 1 and not p1_face:
            setup_face(selection, vs_screen.p1, 1)
            p1_face = true
        if selection["team"] == 2 and not p2_face:
            setup_face(selection, vs_screen.p2, 2)
            p2_face = true
        if selection["team"] == 1 and not p1_name:
            setup_name(selection, vs_screen.p1)
            # TODO: Support team name
        if selection["team"] == 2 and not p2_name:
            setup_name(selection, vs_screen.p2)

func setup_face(selection, versus_player, team):
    var character = selection["character"]
    var image = character["faces"][team]
    var definition = character["definition"]
    var texture = sprite_bundle.create_texture(image)
    var sprite = Sprite.new()
    sprite.texture = texture
    sprite.centered = false
    sprite.position += versus_player.offset
    sprite.scale = definition.get_scale() * versus_player.scale
    sprite.flip_h = versus_player.facing == -1
    if versus_player.facing == -1:
       var texture_size = texture.get_data().get_size()
       sprite.position.x -= texture_size.x * sprite.scale.x
    add_child(sprite)

func setup_name(selection, versus_player):
    var label = UiLabel.new()
    var name_font = kernel.get_motif_font(versus_player.name_font)
    var character = selection["character"]
    var definition = character["definition"]
    label.set_text(definition.info.displayname)
    label.set_font(name_font)
    # TODO: Implement name_spacing
    label.position = versus_player.name_offset
    add_child(label)

func handle_timeout():
    emit_signal("done")
