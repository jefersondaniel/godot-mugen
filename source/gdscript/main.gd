extends Node2D

var Kernel = load('res://source/gdscript/system/kernel.gd')
var AudioPlayer = load('res://source/gdscript/system/audio_player.gd')
var TitleScreen = load('res://source/gdscript/nodes/screens/title_screen.gd')
var kernel = null
var current_screen = null
var audio_player = null

func _init():
    kernel = Kernel.new()
    kernel.load()
    audio_player = AudioPlayer.new()
    show_title_screen()
    add_child(audio_player)

func show_title_screen():
    var screen = TitleScreen.new()
    screen.setup(kernel)
    set_current_screen(screen)

func set_current_screen(screen):
    if current_screen:
        remove_child(current_screen)
    add_child(screen)
