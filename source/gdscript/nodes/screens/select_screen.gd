extends Node2D

var BackgroundGroup = load('res://source/gdscript/nodes/ui/background_group.gd')
var UiLabel = load('res://source/gdscript/nodes/ui/label.gd')

var setup = false
var kernel = null
var store = null
var background_definition = null
var select_info = null
var title_font = null

func _ready():
    if setup:
        return

    setup = true
    kernel = constants.container["kernel"]
    store = constants.container["store"]
    select_info = kernel.get_motif().select_info
    title_font = kernel.get_font(select_info.title_font)
    background_definition = kernel.get_motif().backgrounds["select"]

    setup_background()
    setup_title()

func setup_background():
    var background_group = BackgroundGroup.new()
    background_group.images = kernel.get_images()
    background_group.setup(background_definition)

    add_child(background_group)

func setup_title():
    var label = UiLabel.new()
    label.set_text(store.fight_type_text)
    label.set_font(title_font)
    label.position = select_info.title_offset * kernel.get_scale()
    add_child(label)
