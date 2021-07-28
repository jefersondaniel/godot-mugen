extends Node2D

var BackgroundGroup = load("res://source/gdscript/nodes/ui/background_group.gd")

signal done

var setup: bool = false
var kernel: Object
var store: Object
var animations: Dictionary
var background_definition: Object
var vs_screen: Object
var sprite_bundle: Object

func _ready():
    if setup:
        return

    setup = true
    kernel = constants.container["kernel"]
    store = constants.container["store"]
    vs_screen = kernel.get_motif().vs_screen
    animations = kernel.get_motif().animations
    background_definition = kernel.get_motif().backgrounds["versus"]
    sprite_bundle = kernel.get_sprite_bundle()

    create_background()

func create_background():
    var background_group = BackgroundGroup.new()
    background_group.setup(background_definition, sprite_bundle, animations)

    add_child(background_group)
