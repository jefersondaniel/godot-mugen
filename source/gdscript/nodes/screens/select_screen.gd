extends Node2D

var BackgroundGroup = load('res://source/gdscript/nodes/ui/background_group.gd')

var select_info = null
var background_definition = null
var kernel = null
var setup = false

func _ready():
    if setup:
        return

    setup = true
    kernel = constants.container["kernel"]
    select_info = kernel.get_motif().select_info
    background_definition = kernel.get_motif().backgrounds["select"]

    setup_background()


func setup_background():
    var background_group = BackgroundGroup.new()
    background_group.images = kernel.get_images()
    background_group.setup(background_definition)

    add_child(background_group)
